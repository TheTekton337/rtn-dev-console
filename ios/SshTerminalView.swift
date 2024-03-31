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

@objc(SshTerminalViewDelegate)
public protocol SshTerminalViewDelegate: AnyObject {
    func onSizeChanged(source: TerminalView, newCols: Int, newRows: Int)
    func onHostCurrentDirectoryUpdate(source: TerminalView, directory: String?)
    func onScrolled(source: TerminalView, position: Double)
    func onRequestOpenLink(source: TerminalView, link: String, params: [String:String])
    func onBell(source: TerminalView)
    func onClipboardCopy(source: TerminalView, content: String)
    func onITermContent(source: TerminalView, content: Data)
    func onRangeChanged(source: TerminalView, startY: Int, endY: Int)
    func onTerminalLoad(source: TerminalView)
    func onConnect(source: TerminalView)
    func onClosed(source: TerminalView, reason: String)
    func onSshError(source: TerminalView?, error: Data)
    func onSshConnectionError(source: TerminalView, error: Error)
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
    public func initSSHConnection(host: String, port: UInt16, username: String, password: String, inputEnabled: Bool, initialText: String, debug: Bool) {
        do {
//            self.onTerminalLoad(source: self)
            try setupSSHConnection(host: host, port: port, username: username, password: password, inputEnabled: inputEnabled, initialText: initialText, debug: debug)
        } catch {
            print("Failed to setup SSH connection: \(error)")
        }
    }
    
    func setupSSHConnection(host: String, port: UInt16, username: String, password: String, inputEnabled: Bool, initialText: String, debug: Bool) throws {
        let environment: [Environment] = []
        
        let terminal = getTerminal()
        
        if !initialText.isEmpty {
            terminal.feed(text: "\(initialText)\r\n\n")
        }
        
        debugTerminal = debug
        
        if debugTerminal {
            terminal.feed(text: "rtn-dev-console - connecting to my \(host):\(port) with password authentication...\r\n\n")
        }
        
        shell = try SSHShell(sshLibrary: Libssh2.self, host: host, port: port, environment: environment, terminal: "vanilla")
        
        shell?.onSessionClose = {
            DispatchQueue.main.async {
                print("SshTerminalView onSessionClose")
                self.onClosed(source: self, reason: "close")
            }
        }
        
        shell?
        .withCallback { [weak self] (data: Data?, error: Data?) in
            if let data = data, let string = String(data: data, encoding: .utf8) {
                DispatchQueue.main.async {
                    self?.feed(text: string)
                }
            }
            
            if let error = error {
                self?.onSshError(source: self, error: error)
            }
        }
        .connect().authenticate(AuthenticationChallenge.byPassword(username: username, password: password)).open { error in
            if let error = error {
                self.onSshConnectionError(source: self, error: error)
                return
            }
            
            self.onConnect(source: self)
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
        print("SshTerminalView onSizeChanged - columns: \(newCols), rows: \(newRows)")
        sshTerminalViewDelegate?.onSizeChanged(source: source, newCols: newCols, newRows: newRows)
    }
    
    @objc
    public func hostCurrentDirectoryUpdate(source: TerminalView, directory: String?) {
        if let directory = directory {
            print("SshTerminalView onHostCurrentDirectoryUpdate updated: \(directory)")
        }
        sshTerminalViewDelegate?.onHostCurrentDirectoryUpdate(source: source, directory: directory)
    }
    
    @objc
    public func scrolled(source: TerminalView, position: Double) {
        if (lastScrollPosition == position) {
            return
        }
        lastScrollPosition = position
        print("SshTerminalView onScrolled position: \(position)")
        sshTerminalViewDelegate?.onScrolled(source: source, position: position)
    }
    
    @objc
    public func requestOpenLink(source: TerminalView, link: String, params: [String:String]) {
        guard let fixedup = link.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: fixedup) else { return }
        DispatchQueue.main.async {
            UIApplication.shared.open(url)
        }
        print("SshTerminalView onRequestOpenLink - link: \(link) | params: \(params)")
        sshTerminalViewDelegate?.onRequestOpenLink(source: source, link: link, params: params)
    }

    @objc
    public func bell(source: TerminalView) {
        print("SshTerminalView onBell")
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
        print("SshTerminalView onClipboardCopy content: \(str)")
        
        sshTerminalViewDelegate?.onClipboardCopy(source: source, content: str)
    }

    @objc
    public func iTermContent(source: TerminalView, content: Data) {
        print("SshTerminalView onITermContent content: \(content)")
        sshTerminalViewDelegate?.onITermContent(source: source, content: content)
    }
    
    @objc
    public func rangeChanged(source: TerminalView, startY: Int, endY: Int) {
        print("SshTerminalView onRangeChanged - startY: \(startY) | endY: \(endY)")
        sshTerminalViewDelegate?.onRangeChanged(source: source, startY: startY, endY: endY)
    }
    
    @objc
    public func onSshError(source: TerminalView?, error: Data) {
        print("SshTerminalView onSshError: \(error)")
        
        if debugTerminal && (source != nil) {
            let terminal = source!.getTerminal()
            terminal.feed(text: "SSH Error: \(error)")
        }
        
        sshTerminalViewDelegate?.onSshError(source: source, error: error)
    }
    
    @objc
    public func onSshConnectionError(source: TerminalView, error: Error) {
        print("SshTerminalView onSshConnectionError: \(error)")
        
        if debugTerminal {
            let terminal = source.getTerminal()
            terminal.feed(text: "SSH Connection Error: \(error)")
        }
        
        sshTerminalViewDelegate?.onSshConnectionError(source: source, error: error)
    }
    
    @objc
    public func onTerminalLoad(source: TerminalView) {
//        print("SshTerminalView onTerminalLoad")
//        sshTerminalViewDelegate?.onTerminalLoad(source: source)
    }
    
    @objc
    public func onConnect(source: TerminalView) {
        print("SshTerminalView onConnect")
        sshTerminalViewDelegate?.onConnect(source: source)
    }
    
    @objc
    public func onClosed(source: TerminalView, reason: String) {
        print("SshTerminalView onClosed reason: \(reason)")
        sshTerminalViewDelegate?.onClosed(source: source, reason: reason)
    }
    
    @objc
    public func sendData(source: TerminalView, data: Data) {
        let byteArray = [UInt8](data)
        let arraySlice = byteArray[0..<byteArray.count]
//        print("SshTerminalView sendData: \(data)")
        self.send(source: source, data: arraySlice)
    }
    
    @objc
    public func setTerminalTitle(source: TerminalView, title: String) {
        print("SshTerminalView setTerminalTitle: \(title)")
        let terminal = getTerminal()
        terminal.setTitle(text: title)
    }
    
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
}
