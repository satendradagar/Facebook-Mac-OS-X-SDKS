//
//  FacebookLoginController.swift
//  FacebookWebLogin
//
//  Created by Satendra Dagar on 23/11/17.
//  Copyright © 2017 Satendra. All rights reserved.
//

import Foundation
import Cocoa
import WebKit

public class FacebookLoginController: NSViewController, WebFrameLoadDelegate {
    
//    @IBOutlet var window: NSWindow!
//    @IBOutlet var webView: WKWebView!
    @IBOutlet var webView: WebView!

    @IBOutlet var cancelButton: NSButton!
    var loginControler: PhFacebook?
    var permissions = ""
    
//    init() {
//        let bundle = Bundle(for: PhFacebook.self)
//        super.init(nibName: NSNib.Name(rawValue: "FacebookLoginController"), bundle: bundle)
//    }
//
//    required public init?(coder: NSCoder) {
//        super.init(coder: coder)
//    }
    
    deinit {
        
    }
    
    override public func awakeFromNib() {
        webView.frameLoadDelegate = self
    }
    func windowWillClose(_ notification: Notification) {
        cancel(nil)
    }
    
    public func webView(_ sender: WebView!, didCommitLoadFor frame: WebFrame!) {
        let url: String = sender.mainFrameURL
        print("didCommitLoadForFrame: {\(url)}" )
//        var index = url.index(url.startIndex, offsetBy: 7)//HTTP:// (total 7 characters)
//        var urlWithoutSchema = url[index...]  //After HTTP://
//
//        if url.hasPrefix("https://") {
//             index = url.index(url.startIndex, offsetBy: 8)//HTTPS:// (total 8 characters)
//             urlWithoutSchema = url[index...]  //After HTTPS://
//        }
//        let uiServerURLWithoutSchema = LoginURLConstants.URLs.URL[index...]
//        let res: ComparisonResult? = urlWithoutSchema.compare(uiServerURLWithoutSchema ?? "", options: .caseInsensitive, range: NSRange(location: 0, length: (uiServerURLWithoutSchema.count ?? 0)), locale: .current)
//        if (res == ComparisonResult.orderedSame){
//            showUI()
//        }
//        #if ALWAYS_SHOW_UI
//            showUI()
//        #endif
    }
    func extractParameter(_ param: String, fromURL url: String) -> String {
        var res: String? = nil
        let paramNameRange: NSRange = (url as NSString).range(of: param, options: .caseInsensitive)
        if paramNameRange.location != NSNotFound {
            // Search for '&' or end-of-string
            let searchRange = NSRange(location: paramNameRange.location + paramNameRange.length, length: (url.count) - (paramNameRange.location + paramNameRange.length))
            var ampRange: NSRange = (url as NSString).range(of: "&", options: .caseInsensitive, range: searchRange)
            if ampRange.location == NSNotFound {
                ampRange.location = url.count
            }
            res = (url as NSString).substring(with: NSRange(location: searchRange.location, length: ampRange.location - searchRange.location))
        }
        return res ?? ""
    }
    public func webView(_ sender: WebView!, didFinishLoadFor frame: WebFrame!) {
        let url: String = sender.mainFrameURL
        print("didFinishLoadForFrame: {\(url)}")
        var index = url.index(url.startIndex, offsetBy: 7)//HTTP:// (total 7 characters)
        var urlWithoutSchema = url[index...]  //After HTTP://
        
        if url.hasPrefix("https://") {
            index = url.index(url.startIndex, offsetBy: 8)//HTTPS:// (total 8 characters)
            urlWithoutSchema = url[index...]  //After HTTPS://
        }
        let loginSuccessURLWithoutSchema = LoginURLConstants.URLs.LoginSuccessURL[index...]

        let range = loginSuccessURLWithoutSchema.startIndex..<loginSuccessURLWithoutSchema.endIndex

        let result: ComparisonResult = urlWithoutSchema.compare(loginSuccessURLWithoutSchema, options: NSString.CompareOptions.caseInsensitive, range: range, locale: nil)

        if result == ComparisonResult.orderedSame {
            let accessToken: String = extractParameter(LoginURLConstants.ResponseKeys.FBAccessToken, fromURL: url)
            let tokenExpires: String = extractParameter(LoginURLConstants.ResponseKeys.FBExpiresIn, fromURL: url)
            let errorReason: String = extractParameter(LoginURLConstants.ResponseKeys.FBErrorReason, fromURL: url)
            print("error:\(errorReason)")
//            window.orderOut(self)
//            loginControler?.setAccessToken(accessToken, expires: TimeInterval(Float(tokenExpires) ?? 0.0), permissions: permissions)
            loginControler?.setAccessToken(accessToken, expires: TimeInterval(Float(tokenExpires) ?? 0.0), permissions: permissions, error: errorReason)
        }
        else {
            // If access token is not retrieved, UI is shown to allow user to login/authorize
        }
        #if ALWAYS_SHOW_UI
            showUI()
        #endif
    }
    
    @IBAction func cancel(_ sender: Any?) {
//        loginControler.perform(#selector(self.didDismissUI))
//        window.orderOut(nil)
    }

}
