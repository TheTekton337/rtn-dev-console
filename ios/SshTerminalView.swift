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

@objc(SshTerminalView)
public class SshTerminalView: TerminalView, TerminalViewDelegate {
    var shell: SSHShell?
    var authenticationChallenge: AuthenticationChallenge?
    var sshQueue: DispatchQueue
    
    @objc
    public override init(frame: CGRect) {
        self.sshQueue = DispatchQueue(label: "com.ixqus.sshQueue")
        
        super.init(frame: frame)
        terminalDelegate = self
        
        // Initialize the SSH connection
        do {
            try setupSSHConnection()
        } catch {
            print("Failed to setup SSH connection: \(error)")
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupSSHConnection() throws {
        // Assuming host, port, environment, and terminal details are correctly set
        let host = "127.0.0.1"
        let port: UInt16 = 22
        let environment: [Environment] = [] // Customize your environment if needed
        let terminal: SwiftSH.Terminal? = nil // Customize your terminal settings if needed
        
        shell = try SSHShell(sshLibrary: Libssh2.self, host: host, port: port, environment: environment, terminal: terminal)

        let username = "TODO"
        let password = "TODO"
        
        // Handle authentication and connect
        shell?.connect().authenticate(AuthenticationChallenge.byPassword(username: username, password: password)).open { error in
            if let error = error {
                print("SSH Connection Error: \(error)")
                return
            }
            
            // Connection and shell session successfully opened
            // Setup read and write handlers here...
        }
        
        // Configure readDataCallback or readStringCallback based on your needs
        shell?.withCallback { [weak self] (data: Data?, error: Data?) in
            // Handle incoming data and errors
            if let data = data, let string = String(data: data, encoding: .utf8) {
                DispatchQueue.main.async {
                    self?.feed(text: string)
                }
            }
            
            if let error = error {
                // Handle error
                print("SSH Error: \(error)")
            }
        }
    }

    // Implement TerminalViewDelegate methods
    
    public func send(source: TerminalView, data: ArraySlice<UInt8>) {
    // @objc public func send(source: TerminalView, data: Data) {
        // Forward input from the terminal to the SSH shell
        let inputData = Data(data)
        shell?.write(inputData)
    }

    @objc
    public func sendData(source: TerminalView, data: Data) {
        let byteArray = [UInt8](data)
        let arraySlice = byteArray[0..<byteArray.count]
        self.send(source: source, data: arraySlice)
    }
    
    // Remaining methods (TerminalViewDelegate conformance) are unchanged
    // Since the rest of your delegate methods do not directly interact with React Native,
    // they remain unchanged. However, ensure they are properly documented and clear
    // in their purpose to maintain readability and maintainability.

    // For React Native Fabric integration:
    // - You would typically expose this UIView through a manager that bridges UIKit to React Native.
    // - React Native's codegen can generate necessary bindings for this view, but you need to define it in JS with TurboModule specs or a similar approach, depending on your RN version.

    // Note: Ensure you replace "<#password#>" with a secure way to handle passwords, potentially leveraging iOS's Keychain Services.
    
    @objc
    public func scrolled(source: TerminalView, position: Double) {
        // This method is called when the terminal content is scrolled.
        // You can use this to notify React Native about the scroll event if needed.
        // Example:
        // reactNativeBridge.sendEvent("terminalScrolled", position)
        print("Terminal scrolled to position: \(position)")
    }
    
    @objc
    public func setTerminalTitle(source: TerminalView, title: String) {
        // This method is triggered when the terminal title is set or updated.
        // You can use this to update the UI or notify React Native about the title change.
        // Example:
        // reactNativeBridge.sendEvent("terminalTitleChanged", title)
        print("Terminal title set to: \(title)")
    }
    
    @objc
    public func sizeChanged(source: TerminalView, newCols: Int, newRows: Int) {
        // This method is called when the terminal size changes, e.g., due to a rotation or resizing of the view.
        // Here you might adjust the terminal view's frame or constraints based on new size.
        // Ensure the SSH shell knows about the new size to properly format the content.
        sshQueue.async { [weak self] in
            self?.shell?.setTerminalSize(width: UInt(newCols), height: UInt(newRows))
        }
        // Optionally, notify React Native about the size change if it needs to react accordingly.
        // reactNativeBridge.sendEvent("terminalSizeChanged", ["cols": newCols, "rows": newRows])
        print("Terminal size changed to columns: \(newCols), rows: \(newRows)")
    }

    @objc
    public func bell(source: TerminalView) {
        // React to the terminal bell signal, such as playing a sound or giving visual feedback.
        print("Bell signal received")
    }
    
    @objc
    public func clipboardCopy(source: TerminalView, content: Data) {
        if let str = String(bytes: content, encoding: .utf8) {
            UIPasteboard.general.string = str
            print("Copied to clipboard: \(str)")
        }
        // Optionally, notify React Native that content has been copied to the clipboard.
        // reactNativeBridge.sendEvent("contentCopied", UIPasteboard.general.string ?? "")
    }

    // iTermContent not handled by SwiftTerm
    @objc
    public func iTermContent(source: TerminalView, content: Data) {
        // Handle iTerm2-specific content that was not processed by SwiftTerm
        // let byteArray = [UInt8](data)
        // let arraySlice = byteArray[0..<byteArray.count]
        print("Received iTerm content: \(content)")
    }
    
    // Visual changes in the terminal buffer
    @objc
    public func rangeChanged(source: TerminalView, startY: Int, endY: Int) {
        // Handle visual changes in the specified range of the terminal buffer
        print("Visual range changed from \(startY) to \(endY)")
    }
    
    @objc
    public func hostCurrentDirectoryUpdate(source: TerminalView, directory: String?) {
        // This method could be used to update the UI or notify React Native about the current directory change.
        // This might be useful for UI elements that display the current directory or for analytics.
        // reactNativeBridge.sendEvent("directoryChanged", directory ?? "")
        if let directory = directory {
            print("Current directory updated to: \(directory)")
        }
    }
    
    @objc
    public func requestOpenLink(source: TerminalView, link: String, params: [String:String]) {
        guard let fixedup = link.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: fixedup) else { return }
        DispatchQueue.main.async {
            UIApplication.shared.open(url)
        }
        // Optionally, notify React Native about the link opening request.
        // reactNativeBridge.sendEvent("linkOpened", link)
        print("Request to open link: \(link) with params: \(params)")
    }
}
