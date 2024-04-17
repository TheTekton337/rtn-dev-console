//
//  SshTerminalView.swift
//  iOS
//
//  Created by Miguel de Icaza on 4/22/20.
//  Copyright © 2020 Miguel de Icaza. All rights reserved.
//

import Foundation
import UIKit
import SwiftSH
import SwiftTerm

struct EnvironmentVariable: Codable {
    let name: String
    let variable: String
}

struct SSHConnectionConfig: Codable {
    let method: String
    let host: String
    let terminal: String
    let environment: [EnvironmentVariable]?
    let port: UInt16
    let username: String
    let password: String?
    let publicKeyPath: String?
    let privateKeyPath: String?
    let publicKey: String?
    let privateKey: String?
    let initialText: String
    let inputEnabled: Bool
    let debug: Bool
}

extension SSHConnectionConfig {
    init(dictionary: [String: Any]) {
        self.method = dictionary["method"] as? String ?? Utils.nsString(from: AuthMethod.password)
        self.host = dictionary["host"] as? String ?? ""
        self.port = dictionary["port"] as? UInt16 ?? 22
        self.terminal = dictionary["terminal"] as? String ?? ""
        self.username = dictionary["username"] as? String ?? ""
        self.password = dictionary["password"] as? String
        self.publicKeyPath = dictionary["publicKeyPath"] as? String
        self.privateKeyPath = dictionary["privateKeyPath"] as? String
        self.publicKey = dictionary["publicKey"] as? String
        self.privateKey = dictionary["privateKey"] as? String
        self.initialText = dictionary["initialText"] as? String ?? ""
        self.inputEnabled = dictionary["inputEnabled"] as? Bool ?? true
        self.debug = dictionary["debug"] as? Bool ?? true
        
        if let envArray = dictionary["environment"] as? [[String: String]] {
            self.environment = envArray.compactMap { dict in
                let name = dict["name"]
                let variable = dict["variable"]
                return EnvironmentVariable(name: name ?? "", variable: variable ?? "")
            }
        } else {
            self.environment = []
        }
    }
}

@objc(SshTerminalViewDelegate)
public protocol SshTerminalViewDelegate: AnyObject {
//    rtn-dev-console events
    func onTerminalLog(source: TerminalView?, logType: String, message: String)
    func onConnect(source: TerminalView)
    func onClosed(source: TerminalView, reason: String)
    func onOSC(source: TerminalView, code: Int, data: String)
    func onUploadComplete(source: TerminalView, callbackId: String, bytesTransferred: Int, error: String?)
    func onDownloadComplete(source: TerminalView, callbackId: String, data: String?, fileInfo: String?, error: String?)
    func onUploadProgress(source: TerminalView, callbackId: String, bytesTransferred: Int, totalBytes: Int)
    func onDownloadProgress(source: TerminalView, callbackId: String, bytesTransferred: Int)
    func onCommandExecuted(source: TerminalView, callbackId: String, data: String?, error: String?)
//    SwiftTerm delegate events
    func onSizeChanged(source: TerminalView, newCols: Int, newRows: Int)
    func onHostCurrentDirectoryUpdate(source: TerminalView, directory: String?)
    func onScrolled(source: TerminalView, position: Double)
    func onRequestOpenLink(source: TerminalView, link: String, params: [String:String])
    func onBell(source: TerminalView)
    func onClipboardCopy(source: TerminalView, content: String)
    func onITermContent(source: TerminalView, content: Data)
    func onRangeChanged(source: TerminalView, startY: Int, endY: Int)
}

@objc(SshTerminalView)
public class SshTerminalView: TerminalView, TerminalViewDelegate {
    var shell: SSHShell?
    var authenticationChallenge: AuthenticationChallenge?
    var sshQueue: DispatchQueue
    var useAutoLayout: Bool
    var debugTerminal: Bool
    var lastScrollPosition: Double?
    var lastTerminalSize: (lastCols: Int, lastRows: Int)?
    var lastTitle: String?
    
    var scpSession: SCPSession?
    var scpTransfer: SCPTransfer?
    var sshCommand: SSHCommand!
    
    @objc
    weak public var sshTerminalViewDelegate: (SshTerminalViewDelegate)?
    
    @objc
    public override init(frame: CGRect) {
        self.sshQueue = DispatchQueue(label: "com.ixqus.sshQueue")
        
        self.debugTerminal = false
        self.useAutoLayout = true
        
        super.init(frame: frame)
        terminalDelegate = self
                
        self.nativeBackgroundColor = .systemBackground
        self.nativeForegroundColor = .label
        
        self.shell?.setTerminalSize(width: UInt(frame.size.width), height: UInt(frame.size.height))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc
    public func closeSSHConnection(_ completion: (() -> Void)?) {
        shell?.close(completion)
    }

    @objc
    public func initSSHConnection(withConfig config: [String: Any]) {
        do {
            let configuration = SSHConnectionConfig(dictionary: config)
            try setupSSHConnection(with: configuration)
        } catch {
//            TODO: Send error to RTN
            let message = "Failed to setup SSH connection: \(error)"
            self.logMessage(message: message, logType: LogType.error, terminalMessage: nil)
        }
    }
    
    func setupSSHConnection(with config: SSHConnectionConfig) throws {
        let host = config.host
        let port = config.port
        let terminalType = config.terminal
        
        let username = config.username
        
//        let inputEnabled = config.inputEnabled
        let initialText = config.initialText
        
        let debug = config.debug

        let environmentVariables: [EnvironmentVariable] = config.environment ?? []
        let environment: [Environment] = environmentVariables.map { variable in
            return Environment(name: variable.name, variable: variable.variable)
        }
        
        let terminal = getTerminal()
        
        if !initialText.isEmpty {
            terminal.feed(text: initialText)
        }
        
        debugTerminal = debug
        
        self.terminalMessage(message: "connecting to my \(host):\(port) [\(terminalType)]...")
        
        let shellTerminal = Terminal(stringLiteral: terminalType)
        
        shell = try SSHShell(sshLibrary: Libssh2.self, host: host, port: port, environment: environment, terminal: shellTerminal)
        
        shell?.onSessionClose = {
            DispatchQueue.main.async {
                self.onClosed(source: self, reason: "close")
            }
        }
        
        if let authenticationChallenge: AuthenticationChallenge = determineAuthenticationChallenge(from: config, username: username) {
            shell?
            .withCallback { [weak self] (data: Data?, error: Data?) in
                guard let self = self else {
                    return
                }
                
                if let data = data, let string = String(data: data, encoding: .utf8) {
                    DispatchQueue.main.async {
                        self.feed(text: string)
                    }
                }
                
                if let error = error {
//                    TODO: Send error to RTN
                    let jsonError = Utils.jsonString(from: error)
                    let message = "SSH error: \(jsonError!)"
                    self.logMessage(message: message, logType: LogType.error, terminalMessage: nil)
                }
            }
            .connect().authenticate(authenticationChallenge).open { [weak self] error in
                guard let self = self else {
//                    TODO: Improve error handling
                    print("Error: Unable to open SSH connection")
                    return
                }
                
                if let error = error {
                    let message = "SSH connection error: \(error)"
                    self.logMessage(message: message, logType: LogType.error, terminalMessage: nil)
                    return
                }
                
//                self.sshCommand = try! SSHCommand(session: self.shell!.sharedSession)
//                shell?.addChannel(self.sshCommand)
                
                self.terminalMessage(message: "onConnect")
                
                self.onConnect(source: self)
                
                self.setupSCPConnection()
            }
        }
    }
    
    private func setupSCPConnection() {
        guard let shell = shell else {
//            TODO: Send error to RTN
            let message = "setupSCPConnection could not be initialized due to missing shell"
            self.logMessage(message: message, logType: LogType.error, terminalMessage: nil)
            return
        }
        
        do {
//            TODO: Review scpTransfer vars and guard scpSession/scpTransfer results
            self.scpSession = try SCPSession(sshLibrary: Libssh2.self, session: shell.session)
            self.scpTransfer = try SCPTransfer(sshLibrary: Libssh2.self, sshSession: shell.session, scpSession: self.scpSession!)
            shell.addChannel(self.scpSession!)
        } catch {
//            TODO: Send error to RTN
            let message = "setupSCPConnection Error: \(error)"
            self.logMessage(message: message, logType: LogType.error, terminalMessage: nil)
        }
    }

    private func determineAuthenticationChallenge(from config: SSHConnectionConfig, username: String) -> AuthenticationChallenge? {
        switch (config.method) {
        case "PubkeyFile":
            if let privateKeyPath = config.privateKeyPath {
                let fileManager = FileManager.default
                if let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
                    let privateKeyDocumentPath = documentsPath.appendingPathComponent(privateKeyPath).path
                    var publicKeyDocumentPath: String? = nil
                    
//                    TODO: Review auth terminal messaging
                    if let publicKeyPath = config.publicKeyPath {
                        publicKeyDocumentPath = documentsPath.appendingPathComponent(publicKeyPath).path
                        self.terminalMessage(message: "Using pubKey auth from file")
                    } else {
                        self.terminalMessage(message: "Using privateKey auth from file, no publicKey provided")
                    }

                    return .byPublicKeyFromFile(username: username, password: config.password ?? "", publicKey: publicKeyDocumentPath, privateKey: privateKeyDocumentPath)
                } else {
//                    TODO: Notify RTN
                    let message = "Failed to get documents path."
                    logMessage(message: message, logType: .error, terminalMessage: message)
                }
            } else {
//                TODO: Notify RTN
                let message = "PrivateKey path is not provided in config."
                logMessage(message: message, logType: .error, terminalMessage: message)
            }
            return nil
        case "PubkeyMemory":
            if let publicKey = config.publicKey,
                      let privateKey = config.privateKey {
                if let publicKeyData = publicKey.data(using: .utf8),
                   let privateKeyData = privateKey.data(using: .utf8) {
                    
//                    TODO: Review auth terminal messaging
                    self.terminalMessage(message: "using pubKey auth from memory")
                    
                    return .byPublicKeyFromMemory(username: username, password: config.password ?? "", publicKey: publicKeyData, privateKey: privateKeyData)
                } else {
//                    TODO: Notify RTN
                    let message = "Failed to decode publicKey or privateKey from base64."
                    logMessage(message: message, logType: LogType.error, terminalMessage: message)
                }
            } else {
//                TODO: Notify RTN
                let message = "Failed to get publicKey/privateKey (memory) from config."
                logMessage(message: message, logType: LogType.error, terminalMessage: message)
            }
            return nil
        case "Password":
            if let password = config.password {
                self.terminalMessage(message: "using password auth")
                
                return .byPassword(username: username, password: password)
            }
            
//            TODO: Notify RTN
            let message = "Failed to get password from config."
            logMessage(message: message, logType: LogType.error, terminalMessage: message)
            
            return nil
        // TODO: implement callback and interactive auth
        // case "interactive"
        //     if let callback = ???? {
        //         return .byKeyboardInteractive(username: username, callback: callback)
        //     }
        //     return nil
        default:
//            TODO: Notify RTN
            let message = "Unknown auth method type provided: \(config.method)."
            logMessage(message: message, logType: LogType.error, terminalMessage: nil)
            return nil
        }
    }
    
    func terminalMessage(message: String?) {
        if self.debugTerminal && message != nil {
            let terminal = getTerminal()
            terminal.feed(text: "rtn-dev-console - \(message ?? "")\r\n\n")
        }
    }
    
    func logMessage(message: String, logType: LogType, terminalMessage: String?) {
        print(message)
        
        self.terminalMessage(message: terminalMessage)
        
        DispatchQueue.main.async {
            let logType = Utils.nsString(from: logType)
            self.sshTerminalViewDelegate?.onTerminalLog(source: self, logType: logType!, message: message)
        }
    }
    
    @objc
    public func executeCommand(callbackId: String, command: String) {
        let cmd = try! SSHCommand(session: self.shell!.sharedSession)
        
        cmd.execute(command) { [weak self] (command: String, data: String?, error: Error?) in
            guard let self = self else {
                print("executeCommand: self instance unavailable")
                return
            }
            
            guard let shell = shell else {
                let shellError = "executeCommand: shell instance unavailable"
                DispatchQueue.main.async {
                    self.sshTerminalViewDelegate?.onCommandExecuted(source: self, callbackId: callbackId, data: nil, error: shellError)
                }
                return
            }
            shell.removeChannel(cmd)
            if let error = error {
                let errorMessage = (error as? DescriptiveError)?.description() ?? "\(error)"
                DispatchQueue.main.async {
                    self.sshTerminalViewDelegate?.onCommandExecuted(source: self, callbackId: callbackId, data: nil, error: errorMessage)
                }
                return
            }
            guard let data = data else {
                let fallbackError = "executeCommand: unable to read data"
                DispatchQueue.main.async {
                    self.sshTerminalViewDelegate?.onCommandExecuted(source: self, callbackId: callbackId, data: nil, error: fallbackError)
                }
                return
            }
            DispatchQueue.main.async {
                self.sshTerminalViewDelegate?.onCommandExecuted(source: self, callbackId: callbackId, data: data, error: nil)
            }
        }
    }
    
    @objc
    public func writeCommand(command: String) {
        shell?.write(command) { error in
            if let error = error {
                let message = "SSH write error: \(error)"
                self.logMessage(message: message, logType: LogType.error, terminalMessage: nil)
                return
            }
            
            let message = "Command sent successfully."
            self.logMessage(message: message, logType: LogType.info, terminalMessage: nil)
        }
    }
    
    @objc
    public func notifyOSC(code: Int, data: String) {
        DispatchQueue.main.async {
            self.sshTerminalViewDelegate?.onOSC(source: self, code: code, data: data)
        }
    }

    // MARK: TerminalViewDelegate methods
    
    public func send(source: TerminalView, data: ArraySlice<UInt8>) {
        let inputData = Data(data)
        shell?.write(inputData)
    }
    
    @objc
    public func sizeChanged(source: TerminalView, newCols: Int, newRows: Int) {
        if (lastTerminalSize != nil && lastTerminalSize?.lastCols == newCols && lastTerminalSize?.lastRows == newRows) {
            return
        }
        lastTerminalSize = (lastCols: newCols, lastRows: newRows)
        let message = "SshTerminalView onSizeChanged - columns: \(newCols), rows: \(newRows)"
        self.logMessage(message: message, logType: LogType.info, terminalMessage: nil)
        DispatchQueue.main.async {
            self.sshTerminalViewDelegate?.onSizeChanged(source: source, newCols: newCols, newRows: newRows)
        }
    }
    
    @objc
    public func hostCurrentDirectoryUpdate(source: TerminalView, directory: String?) {
        guard let directory = directory else {
            return
        }
        DispatchQueue.main.async {
            self.sshTerminalViewDelegate?.onHostCurrentDirectoryUpdate(source: source, directory: directory)
        }
    }
    
    @objc
    public func scrolled(source: TerminalView, position: Double) {
        if (lastScrollPosition == position) {
            return
        }
        lastScrollPosition = position
        print("SshTerminalView onScrolled position: \(position)")
        DispatchQueue.main.async {
            self.sshTerminalViewDelegate?.onScrolled(source: source, position: position)
        }
    }
    
    @objc
    public func requestOpenLink(source: TerminalView, link: String, params: [String:String]) {
        guard let fixedup = link.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: fixedup) else { return }
        print("SshTerminalView onRequestOpenLink - link: \(link) | params: \(params)")
        DispatchQueue.main.async {
            UIApplication.shared.open(url)
            self.sshTerminalViewDelegate?.onRequestOpenLink(source: source, link: link, params: params)
        }
    }

    @objc
    public func bell(source: TerminalView) {
        let message = "SshTerminalView onBell"
        self.logMessage(message: message, logType: LogType.info, terminalMessage: nil)
        #if os(iOS)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
        #endif
        sshTerminalViewDelegate?.onBell(source: source)
    }
    
    @objc
    public func clipboardCopy(source: TerminalView, content: Data) {
        let str = String(bytes: content, encoding: .utf8) ?? ""
        
        UIPasteboard.general.string = str
        let message = "SshTerminalView onClipboardCopy content: \(str)"
        self.logMessage(message: message, logType: LogType.info, terminalMessage: nil)
        
        sshTerminalViewDelegate?.onClipboardCopy(source: source, content: str)
    }

    @objc
    public func iTermContent(source: TerminalView, content: Data) {
        let message = "SshTerminalView onITermContent content: \(content)"
        self.logMessage(message: message, logType: LogType.info, terminalMessage: nil)
        sshTerminalViewDelegate?.onITermContent(source: source, content: content)
    }
    
    @objc
    public func rangeChanged(source: TerminalView, startY: Int, endY: Int) {
        let message = "SshTerminalView onRangeChanged - startY: \(startY) | endY: \(endY)"
        self.logMessage(message: message, logType: LogType.info, terminalMessage: nil)
        sshTerminalViewDelegate?.onRangeChanged(source: source, startY: startY, endY: endY)
    }
    
    @objc
    public func onConnect(source: TerminalView) {
        let message = "SshTerminalView onConnect"
        self.logMessage(message: message, logType: LogType.info, terminalMessage: nil)
        sshTerminalViewDelegate?.onConnect(source: source)
    }
    
    @objc
    public func onClosed(source: TerminalView, reason: String) {
        let message = "SshTerminalView onClosed reason: \(reason)"
        self.logMessage(message: message, logType: LogType.info, terminalMessage: "\nSshTerminal - connection closed\n\n")
        sshTerminalViewDelegate?.onClosed(source: source, reason: reason)
    }
    
    @objc
    public func sendData(source: TerminalView, data: Data) {
        let byteArray = [UInt8](data)
        let arraySlice = byteArray[0..<byteArray.count]
        self.send(source: source, data: arraySlice)
    }
    
    @objc
    public func setTerminalTitle(source: TerminalView, title: String) {
        let terminal = getTerminal()
        terminal.setTitle(text: title)
    }
    
    @objc
    public func upload(callbackId: String, from: String, to: String) {
        guard let scpTransfer = scpTransfer else {
            return
        }
        
        scpTransfer.upload(localPath: from, remotePath: to, completion: { bytesTransferred, error in
            DispatchQueue.main.async {
                let finalBytesTransferred = bytesTransferred ?? 0
                self.sshTerminalViewDelegate?.onUploadComplete(source: self, callbackId: callbackId, bytesTransferred: NSInteger(finalBytesTransferred), error: nil)
            }
        }, progress: { bytesTransferred, totalBytes in
            DispatchQueue.main.async {
                self.sshTerminalViewDelegate?.onUploadProgress(source: self, callbackId: callbackId, bytesTransferred: NSInteger(bytesTransferred), totalBytes: NSInteger(totalBytes))
            }
        })
    }
    
    @objc
    public func download(callbackId: String, from: String, to: String) {
        guard let scpTransfer = scpTransfer else {
            self.sshTerminalViewDelegate?.onDownloadComplete(source: self, callbackId: callbackId, data: nil, fileInfo: nil, error: "Unable to initialize download")
            return
        }
        
        scpTransfer.download(remotePath: from, localPath: to, completion: { fileInfo, data, error in
            DispatchQueue.main.async {
                if let error = error {
                    let descriptiveError = error as! any DescriptiveError
                    self.sshTerminalViewDelegate?.onDownloadComplete(source: self, callbackId: callbackId, data: nil, fileInfo: nil, error: descriptiveError.description())
                    return
                }
                
                guard let data = data, let fileInfo = fileInfo else {
                    self.sshTerminalViewDelegate?.onDownloadComplete(source: self, callbackId: callbackId, data: nil, fileInfo: nil, error: "File data unavailable for save")
                    return
                }                
                
                let fileInfoString = fileInfo.toJSONString()
                
                self.sshTerminalViewDelegate?.onDownloadComplete(source: self, callbackId: callbackId, data: to, fileInfo: fileInfoString, error: nil)
            }
        }, progress: { bytesTransferred in
            DispatchQueue.main.async {
                self.sshTerminalViewDelegate?.onDownloadProgress(source: self, callbackId: callbackId, bytesTransferred: NSInteger(bytesTransferred))
            }
        })
    }
    
    /// Writes data to the specified file, optionally overwriting it with specified attributes based on FileInfo.
    /// - Parameters:
    ///   - data: The data to write to the file.
    ///   - filename: The name of the file.
    ///   - directory: The directory in which to save the file, default is `.documentDirectory`.
    ///   - fileInfo: FileInfo object containing file attributes such as permissions.
    ///   - overwrite: Whether to overwrite the file if it already exists.
    /// - Throws: An error if the operation cannot be completed.
//    func saveFile(with data: Data, filename: String, in directory: FileManager.SearchPathDirectory = .documentDirectory, using fileInfo: FileInfo, overwrite: Bool = true) throws {
////        TODO: Fix error handling
//        let fileManager = FileManager.default
//        guard let directoryURL = fileManager.urls(for: directory, in: .userDomainMask).first else {
//            throw NSError(domain: "FileManagerError", code: 1001, userInfo: [NSLocalizedDescriptionKey: "Unable to find specified directory."])
//        }
//
//        let fileURL = directoryURL.appendingPathComponent(filename)
//
//        // Check if the file exists
//        if fileManager.fileExists(atPath: fileURL.path) {
//            if overwrite {
//                do {
//                    try fileManager.removeItem(at: fileURL)
//                } catch {
//                    throw NSError(domain: "FileManagerError", code: 1002, userInfo: [NSLocalizedDescriptionKey: "Failed to remove existing file: \(error.localizedDescription)"])
//                }
//            } else {
//                throw NSError(domain: "FileManagerError", code: 1004, userInfo: [NSLocalizedDescriptionKey: "File already exists and overwrite is set to false."])
//            }
//        }
//
//        // Create the new file with data and attributes
//        if !fileManager.createFile(atPath: fileURL.path, contents: data, attributes: [.posixPermissions: NSNumber(value: fileInfo.permissions)]) {
//            throw NSError(domain: "FileManagerError", code: 1003, userInfo: [NSLocalizedDescriptionKey: "Failed to create file at \(fileURL.path)"])
//        }
//
//        // Optionally set modification and access times
//        let modificationDate = Date(timeIntervalSince1970: fileInfo.modificationTime)
//        let accessDate = Date(timeIntervalSince1970: fileInfo.accessTime)
//        try fileManager.setAttributes([.modificationDate: modificationDate, .creationDate: accessDate], ofItemAtPath: fileURL.path)
//    }
    
    @objc
    public func sendMotion(buttonFlags: Int, x: Int, y: Int, pixelX: Int, pixelY: Int) {
        let terminal = getTerminal()
        terminal.sendMotion(buttonFlags: buttonFlags, x: x, y: y, pixelX: pixelX, pixelY: pixelY)
    }
    
    @objc
    public func encodeButton(button: Int, release: Bool, shift: Bool, meta: Bool, control: Bool) -> Int {
        let terminal = getTerminal()
        return terminal.encodeButton(button: button, release: release, shift: shift, meta: meta, control: control)
    }
    
    @objc
    public func sendEvent(buttonFlags: Int, x: Int, y: Int) {
        let terminal = getTerminal()
        terminal.sendEvent(buttonFlags: buttonFlags, x: x, y: y)
    }
    
    @objc
    public func sendEvent(buttonFlags: Int, x: Int, y: Int, pixelX: Int, pixelY: Int) {
        let terminal = getTerminal()
        terminal.sendEvent(buttonFlags: buttonFlags, x: x, y: y, pixelX: pixelX, pixelY: pixelY)
    }
    
    @objc
    public func feedBuffer(buffer: Data) {
        let terminal = getTerminal()
        let byteArray = [UInt8](buffer)
        let convertedBuffer = byteArray[0..<byteArray.count]
        terminal.feed(buffer: convertedBuffer)
    }
    
    @objc
    public func feedText(text: String) {
        let terminal = getTerminal()
        terminal.feed(text: text)
    }
    
    @objc
    public func feedByteArray(byteArray: Data) {
        let terminal = getTerminal()
        let convertedByteArray: [UInt8] = Array(byteArray)
        terminal.feed(byteArray: convertedByteArray)
    }
    
//    TODO: Support custom Position typing, if feasible
//    @objc
//    public func getText(text: String) {
//        let terminal = getTerminal()
//        terminal.getText(start: <#T##Position#>, end: <#T##Position#>)
//    }
    
    @objc
    public func sendResponse(items: Any) {
        let terminal = getTerminal()
        terminal.sendResponse(items)
    }
    
    @objc
    public func sendResponse(text: String) {
        let terminal = getTerminal()
        terminal.sendResponse(text: text)
    }
    
    @objc
    public func changedLines() -> Set<Int> {
        let terminal = getTerminal()
        return terminal.changedLines()
    }
    
    @objc
    public func clearUpdateRange() {
        let terminal = getTerminal()
        terminal.clearUpdateRange()
    }
    
    @objc
    public func emitLineFeed() {
        let terminal = getTerminal()
        terminal.emitLineFeed()
    }
    
    @objc
    public func garbageCollectPayload() {
        let terminal = getTerminal()
        terminal.garbageCollectPayload()
    }
    
//    TODO: Support BufferKind/Encoding parameter conversions from terminal.getBufferAsData()
    @objc
    public func getBufferAsData() -> Data {
        let terminal = getTerminal()
        return terminal.getBufferAsData()
    }
    
//    TODO: Support getCharData return type conversion.
//    @objc
//    public func getCharData(col: Int, row: Int) -> CharData {
//        let terminal = getTerminal()
//        return terminal.getCharData(col: col, row: row)
//    }
    
//    TODO: Support getCharacter return type conversion.
//    @objc
//    public func getCharacter(col: Int, row: Int) -> Character? {
//        let terminal = getTerminal()
//        return terminal.getCharacter(col: col, row: row)
//    }
    
//    TODO: Support getCursorLocation return type conversion.
//    @objc
//    public func getCursorLocation() -> (x: Int, y: Int) {
//        let terminal = getTerminal()
//        terminal.getCursorLocation()
//    }
    
//    TODO: Support getDims return type conversion.
//    @objc
//    public func getDims() -> (x: Int, y: Int) {
//        let terminal = getTerminal()
//        return terminal.getDims()
//    }
    
//    TODO: Support getLine return type conversion.
//    @objc
//    public func getLine(row: Int) -> BufferLine? {
//        let terminal = getTerminal()
//        return terminal.getLine(row: row)
//    }
    
//    TODO: Support getScrollInvariantLine return type conversion.
//    @objc
//    public func getScrollInvariantLine(row: Int) -> BufferLine? {
//        let terminal = getTerminal()
//        terminal.getScrollInvariantLine(row: row)
//    }
    
//    TODO: Support getScrollInvariantUpdateRange return type conversion.
//    @objc
//    public func getScrollInvariantUpdateRange() -> (startY: Int, endY: Int)? {
//        let terminal = getTerminal()
//        return terminal.getScrollInvariantUpdateRange()
//    }
    
    @objc
    public func getTopVisibleRow() -> Int {
        let terminal = getTerminal()
        return terminal.getTopVisibleRow()
    }
    
//    TODO: Support getUpdateRange return type conversion.
//    @objc
//    public func getUpdateRange() -> (startY: Int, endY: Int)? {
//        let terminal = getTerminal()
//        return terminal.getUpdateRange()
//    }
    
    @objc
    public func hideCursor() {
        let terminal = getTerminal()
        terminal.hideCursor()
    }
    
    @objc
    public func showCursor() {
        let terminal = getTerminal()
        terminal.showCursor()
    }
    
//    TODO: Support installPalette argument conversion.
//    this should be an array of 16 values that correspond to the 16 ANSI colors,
    @objc
    public func installTerminalColors(colors: [String]) {
        var convertedColors: [Color] = []
        
        for hexString in colors {
            var red: UInt16 = 0
            var green: UInt16 = 0
            var blue: UInt16 = 0

            if Utils.hexString(to: &red, green: &green, blue: &blue, from: hexString) {
                let color = Color(red: red, green: green, blue: blue)
                convertedColors.append(color)
            } else {
                print("Failed to convert hex string to color")
                return;
            }
        }
        
//        TODO: Since [Color] must be an array of 16 color values, add a length check at the RN component level.
       
        self.installColors(convertedColors)
    }
    
//    Internal
//    @objc
//    public func parse(buffer: Data) {
//        let terminal = getTerminal()
//        let byteArray = [UInt8](buffer)
//        let convertedBuffer = byteArray[0..<byteArray.count]
//        terminal.parse(buffer: convertedBuffer)
//    }
    
    @objc
    public func refresh(startRow: Int, endRow: Int) {
        let terminal = getTerminal()
        terminal.refresh(startRow: startRow, endRow: endRow)
    }
    
//    TODO: Review feasiblity of supporting via RN.
//    @objc
//    public func registerOscHandler(code: Int, handler: ArraySlice<UInt8>) {
//        let terminal = getTerminal()
//        terminal.registerOscHandler(code: code, handler: handler)
//    }
    
    @objc
    public func resetToInitialState() {
        let terminal = getTerminal()
        terminal.resetToInitialState()
    }
    
    @objc
    public func resizeTerminal(cols: Int, rows: Int) {
        let terminal = getTerminal()
        terminal.resize(cols: cols, rows: rows)
    }
    
    @objc
    public func scroll() {
        let terminal = getTerminal()
        terminal.scroll()
    }
    
    @objc
    public func scroll(isWrapped: Bool) {
        let terminal = getTerminal()
        terminal.scroll(isWrapped: isWrapped)
    }
    
//    TODO: Support setCursorStyle argument conversion.
//    @objc
//    public func setCursorStyle(cursorStyle: CursorStyle) {
//        let terminal = getTerminal()
//        terminal.setCursorStyle(cursorStyle)
//    }
    
    @objc
    public func setIconTitle(text: String) {
        let terminal = getTerminal()
        terminal.setIconTitle(text: text)
    }
    
    @objc
    public func setTitle(text: String) {
        if (lastTitle != nil && lastTitle == text) {
            return
        }
        lastTitle = text
        let terminal = getTerminal()
        terminal.setTitle(text: text)
    }
    
    @objc
    public func softReset() {
        let terminal = getTerminal()
        terminal.softReset()
    }
    
    @objc
    public func updateFullScreen() {
        let terminal = getTerminal()
        terminal.updateFullScreen()
    }
}
