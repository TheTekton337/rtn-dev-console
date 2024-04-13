//
//  SshTerminalViewController.swift
//  iOS
//
//  Created by Miguel de Icaza on 3/19/19.
//  Copyright © 2019 Miguel de Icaza. All rights reserved.
//

import UIKit
import SwiftTerm

@objc(SshTerminalViewController)
public class SshTerminalViewController: UIViewController {
    var tv: SshTerminalView!
//    TODO: Wire up for RTN
    var transparent: Bool = false
//    TODO: Add support for disabling keyboard to SwiftTerm
//    var isInputEnabled: Bool = true
    var inputBlockerView: UIView?
    
    var useAutoLayout: Bool {
        get { true }
    }
    
    @objc
    func makeFrame (keyboardDelta: CGFloat, _ fn: String = #function, _ ln: Int = #line) -> CGRect
    {
        if useAutoLayout {
            return CGRect.zero
        } else {
            return CGRect (x: view.safeAreaInsets.left,
                           y: view.safeAreaInsets.top,
                           width: view.frame.width - view.safeAreaInsets.left - view.safeAreaInsets.right,
                           height: view.frame.height - view.safeAreaInsets.top - keyboardDelta)
        }
    }
    
    @objc
    func setupKeyboardMonitor ()
    {
        if #available(iOS 15.0, *), useAutoLayout {
            tv.translatesAutoresizingMaskIntoConstraints = false
            tv.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
            tv.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            tv.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            
            tv.keyboardLayoutGuide.topAnchor.constraint(equalTo: tv.bottomAnchor).isActive = true
        } else {
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(keyboardWillShow),
                name: UIWindow.keyboardWillShowNotification,
                object: nil)
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(keyboardWillHide),
                name: UIWindow.keyboardWillHideNotification,
                object: nil)
        }
    }
    
    var keyboardDelta: CGFloat = 0
    @objc private func keyboardWillShow(_ notification: NSNotification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        keyboardDelta = keyboardViewEndFrame.height
        tv.frame = makeFrame(keyboardDelta: keyboardViewEndFrame.height)
    }
    
    @objc
    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        tv.frame = CGRect (origin: tv.frame.origin, size: size)
    }
    
    @objc private func keyboardWillHide(_ notification: NSNotification) {
        //let key = UIResponder.keyboardFrameBeginUserInfoKey
        keyboardDelta = 0
        tv.frame = makeFrame(keyboardDelta: 0)
    }
    
    @objc
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        
        tv = SshTerminalView(frame: makeFrame (keyboardDelta: 0))
        
        if transparent {
            let x = UIImage (contentsOfFile: "/tmp/Lucia.png")!.cgImage
            //let x = UIImage (systemName: "star")!.cgImage
            let layer = CALayer()
            tv.isOpaque = false
            tv.backgroundColor = UIColor.clear
            tv.nativeBackgroundColor = UIColor.clear
            layer.contents = x
            layer.frame = tv.bounds
            view.layer.addSublayer(layer)
        }
        
        view.addSubview(tv)
        setupKeyboardMonitor()
        let _ = tv.becomeFirstResponder()
//        TODO: Troubleshoot issue with initialization without an initial feed
        self.tv.feed(text: "Welcome to SshTerminal - initializing\r\n\n")
        
        #if false
        var text = UITextField(frame: CGRect (x: 0, y: 100, width: 300, height: 20))
        view.addSubview(text)
        text.backgroundColor = UIColor.white
        text.text = "HELLO WORLD"
        text.font = UIFont(name: "Courier", size: 30)
        #endif
    }
    
    @objc
    public override func viewWillLayoutSubviews() {
        if useAutoLayout, #available(iOS 15.0, *) {
        } else {
            tv.frame = makeFrame (keyboardDelta: keyboardDelta)
        }
        if transparent {
            tv.backgroundColor = UIColor.clear
        }
    }
    
    @objc
    public func destroySshTerminalView(){
        tv.closeSSHConnection({
            super.removeFromParent()
        })
    }
    
    @objc
    public func closeSSHConnection(_ completion: (() -> Void)?) {
        tv.closeSSHConnection(completion)
    }
    
    @objc
    public func initSSHConnection(withConfig config: [String: Any]) {
        tv.initSSHConnection(withConfig: config)
    }
    
    @objc
    public func registerOscHandlers(oscCodes: [Int]) {
        let terminal = self.tv.getTerminal()
        
        for code in oscCodes {
            let handler = createOscHandler(forCode: code)
            terminal.registerOscHandler(code: code, handler: handler)
        }
    }
    
    private func createOscHandler(forCode code: Int) -> (ArraySlice<UInt8>) -> Void {
        let handler: (ArraySlice<UInt8>) -> Void = { data in            
            // TODO: Get feedback on encoding behavior
            if let message = String(bytes: Array(data), encoding: .utf8) {
                self.tv.notifyOSC(code: code, data: message)
            } else {
                let encodedData = Data(Array(data)).base64EncodedString()
                self.tv.notifyOSC(code: code, data: encodedData)
            }
        }
        return handler
    }
    
    @objc
    public func writeCommand(command: String) {
        tv.writeCommand(command: command)
    }
    
    @objc
    public func scpRead(callbackId: String, from: String, to: String) {
        tv.scpRead(callbackId: callbackId, from: from, to: to)
    }
    
    @objc
    public func scpWrite(callbackId: String, from: String, to: String) {
        tv.scpWrite(callbackId: callbackId, from: from, to: to)
    }
    
    @objc
    public func sendMotion(buttonFlags: Int, x: Int, y: Int, pixelX: Int, pixelY: Int) {
        tv.sendMotion(buttonFlags: buttonFlags, x: x, y: y, pixelX: pixelX, pixelY: pixelY)
    }
    
    @objc
    public func encodeButton(button: Int, release: Bool, shift: Bool, meta: Bool, control: Bool) -> Int {
        return tv.encodeButton(button: button, release: release, shift: shift, meta: meta, control: control)
    }
    
    @objc
    public func sendEvent(buttonFlags: Int, x: Int, y: Int) {
        tv.sendEvent(buttonFlags: buttonFlags, x: x, y: y)
    }
    
    @objc
    public func sendEvent(buttonFlags: Int, x: Int, y: Int, pixelX: Int, pixelY: Int) {
        tv.sendEvent(buttonFlags: buttonFlags, x: x, y: y, pixelX: pixelX, pixelY: pixelY)
    }
    
    @objc
    public func feed(buffer: Data) {
        tv.feedBuffer(buffer: buffer)
    }
    
    @objc
    public func feed(text: String) {
        tv.feedText(text: text)
    }
    
    @objc
    public func feed(byteArray: Data) {
        tv.feedByteArray(byteArray: byteArray)
    }
    
//    TODO: Support custom typing
//    @objc
//    public func getText() {
//        tv.getText()
//    }
    
    @objc
    public func sendResponse(items: Any) {
        tv.sendResponse(items: items)
    }
    
    @objc
    public func sendResponse(text: String) {
        tv.sendResponse(text: text)
    }
    
    @objc
    public func changedLines() -> Set<Int> {
        return tv.changedLines()
    }
    
    @objc
    public func clearUpdateRange() {
        tv.clearUpdateRange()
    }
    
    @objc
    public func emitLineFeed() {
        tv.emitLineFeed()
    }
    
    @objc
    public func garbageCollectPayload() {
        tv.garbageCollectPayload()
    }
    
    @objc
    public func getBufferAsString() -> NSString {
        let bufferData = tv.getBufferAsData()
        let base64String = bufferData.base64EncodedString()
        return base64String as NSString
    }
    
//    TODO: Support custom typing
//    @objc
//    public func getCharData(col: Int, row: Int) -> CharData {
//        return tv.getCharData(col: col, row: row)
//    }
    
//    @objc
//    public func getCharData(col: Int, row: Int) -> Character? {
//        return tv.getCharData(col: col, row: row)
//    }
    
//    @objc
//    public func getCursorLocation() -> (x: Int, y: Int) {
//        return tv.getCursorLocation()
//    }
    
//    @objc
//    public func getDims() -> (x: Int, y: Int) {
//        return tv.getDims()
//    }
    
//    @objc
//    public func getLine(row: Int) -> BufferLine? {
//        return tv.getLine(row: row)
//    }
    
//    @objc
//    public func getScrollInvariantLine(row: Int) -> BufferLine? {
//        return tv.getScrollInvariantLine(row: row)
//    }
    
//    @objc
//    public func getScrollInvariantUpdateRange(row: Int) -> BufferLine? {
//        return tv.getScrollInvariantUpdateRange(row: row)
//    }
    
    @objc
    public func getTopVisibleRow() -> Int {
        return tv.getTopVisibleRow()
    }
    
//    TODO: Support custom typing
//    @objc
//    public func getUpdateRange() -> (startY: Int, endY: Int)? {
//        return tv.getUpdateRange()
//    }
    
    @objc
    public func hideCursor() {
        tv.hideCursor()
    }
    
    @objc
    public func showCursor() {
        tv.showCursor()
    }
    
    @objc
    public func installColors(colors: [String]) {
        tv.installTerminalColors(colors: colors)
    }
    
    @objc
    public func refresh(startRow: Int, endRow: Int) {
        tv.refresh(startRow: startRow, endRow: endRow)
    }
    
//    TODO: Review feasiblity of supporting via RN.
//    @objc
//    public func registerOscHandler(code: Int, handler: ArraySlice<UInt8>) {
//        tv.registerOscHandler(code: code, handler: handler)
//    }
    
    @objc
    public func resetToInitialState() {
        tv.resetToInitialState()
    }
    
    @objc
    public func resize(cols: Int, rows: Int) {
        tv.resizeTerminal(cols: cols, rows: rows)
    }
    
    @objc
    public func scroll() {
        tv.scroll()
    }
    
    @objc
    public func scroll(isWrapped: Bool) {
        tv.scroll(isWrapped: isWrapped)
    }
    
//    TODO: Support custom typing
//    @objc
//    public func setCursorStyle(cursorStyle: CursorStyle) {
//        tv.setCursorStyle(cursorStyle)
//    }
    
    @objc
    public func setIconTitle(text: String) {
        tv.setIconTitle(text: text)
    }
    
    @objc
    public func setTitle(text: String) {
        tv.setTitle(text: text)
    }
    
    @objc
    public func softReset() {
        tv.softReset()
    }
    
    @objc
    public func updateFullScreen() {
        tv.updateFullScreen()
    }
}

