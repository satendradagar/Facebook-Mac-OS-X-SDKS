//
//  FBLoginController.swift
//  FacebookWebLogin
//
//  Created by Satendra Singh on 19/11/17.
//  Copyright © 2017 Satendra. All rights reserved.
//

import Foundation

let kFBStoreAccessToken = "FBAStoreccessToken"
let kFBStoreTokenExpiry = "FBStoreTokenExpiry"
let kFBStoreAccessPermissions = "FBStoreAccessPermissions"

class PhFacebook: NSObject {
    private var appID = ""
    private var delegate: Any?
    private var webViewController: PhWebViewController?
    private var authToken: FBAuthenticationToken?
    private var permissions = ""
        // MARK: Initialization
    init(applicationID appID: String, delegate: Any) {
        super.init()
        if appID != "" {
            self.appID = appID
        }
        self.delegate = delegate
        // Don't retain delegate to avoid retain cycles
        webViewController = nil
        authToken = nil
        prin("Initialized with AppID \(self.appID)")
        
    }

    func notifyDelegate(for tokenIn:FBAuthenticationToken? , withError errorReason: String) {
        var result = [AnyHashable: Any]()
        if let token = tokenIn  {
            // Save it to user defaults
            var defaults: UserDefaults? = UserDefaults.standard
            defaults?.set(token.authenticationToken, forKey: kFBStoreAccessToken)
            if (token.expiry != nil) {
                defaults?.set(token.expiry, forKey: kFBStoreTokenExpiry)
            }
            else {
                defaults?.removeObject(forKey: kFBStoreTokenExpiry)
            }
            defaults?.set(token.permissions, forKey: kFBStoreAccessPermissions)
            result["valid"] = (1)
        }
        else {
            result["valid"] = (0)
            result["error"] = errorReason
        }
        if delegate.responds(to: #selector(self.tokenResult)) {
            delegate.tokenResult(result)
        }
    }

    func clearToken() {
        authToken = nil
    }
    
    func invalidateCachedToken() {
        clearToken()
        let defaults: UserDefaults? = UserDefaults.standard
        defaults?.removeObject(forKey: kFBStoreAccessToken)
        defaults?.removeObject(forKey: kFBStoreTokenExpiry)
        defaults?.removeObject(forKey: kFBStoreAccessPermissions)
        // Allow logout by clearing the left-over cookies (issue #35)
        let facebookUrl = URL(string: kFBURL)
        let facebookSecureUrl = URL(string: kFBSecureURL)
        let cookieStorage = HTTPCookieStorage.shared
        let cookies = (cookieStorage.cookies(for: facebookUrl!))! + cookieStorage.cookies(for: facebookSecureUrl!) ?? [Any]()
        for cookie: HTTPCookie in cookies {
            cookieStorage.deleteCookie(cookie)
        }
    }
    
    func setAccessToken(_ accessToken: String, expires tokenExpires: TimeInterval, permissions perms: String) {
        clearToken()
        if accessToken != "" {
            authToken = PhAuthenticationToken(token: accessToken, secondsToExpiry: tokenExpires, permissions: perms)
        }
    }

    // permissions: an array of required permissions
    //              see http://developers.facebook.com/docs/authentication/permissions
    // canCache: save and retrieve token locally if not expired
    func getAccessToken(forPermissions permissions: [Any], cached canCache: Bool) {
        var validToken = false
        var scope: String = permissions.joined(separator: ",")
        if canCache && authToken == nil {
            var defaults: UserDefaults? = UserDefaults.standard
            var accessToken: String? = defaults?.string(forKey: kFBStoreAccessToken)
            var date = defaults?.object(forKey: kFBStoreTokenExpiry) as? Date
            var perms: String? = defaults?.string(forKey: kFBStoreAccessPermissions)
            if accessToken && perms {
                // Do not notify delegate yet...
                setAccessToken(accessToken, expires: date?.timeIntervalSinceNow, permissions: perms)
            }
        }
        if authToken.permissions.isCaseInsensitiveLike(scope) {
            // We already have a token for these permissions; check if it has expired or not
            if authToken.expiry == nil || authToken.expiry.laterDate(Date()).isEqual(authToken.expiry) {
                validToken = true
            }
        }
        //  The converted code is limited to 1 KB.
        //  Launch "Swiftify for Xcode" and enter your API key to remove this limitation.
        if validToken {
            notifyDelegate(forToken: authToken, withError: nil)
        }
        else {
            clearToken()
            // Use _webViewController to request a new token
            var authURL = ""
            if scope {
                authURL = String(format: kFBAuthorizeWithScopeURL, appID, kFBLoginSuccessURL, scope)
            }
            else {
                authURL = String(format: kFBAuthorizeURL, appID, kFBLoginSuccessURL)
            }
            if delegate.responds(to: Selector("needsAuthentication:forPermissions:")) {
                if delegate.needsAuthentication(authURL, forPermissions: scope) {
                    // If needsAuthentication returns YES, let the delegate handle the authentication UI
                    return
                }
            }
            // Retrieve token from web page
            if webViewController == nil {
                webViewController = PhWebViewController()
                Bundle.loadNibNamed("FacebookBrowser", owner: webViewController)
            }
            // Prepare window but keep it ordered out. The _webViewController will make it visible

    }
    // request: the short version of the Facebook Graph API, e.g. "me/feed"
    // see http://developers.facebook.com/docs/api
    func sendRequest(_ request: String) {
        
    }
     
    func setAccessToken(_ accessToken: String, expires tokenExpires: TimeInterval, permissions perms: String, error errorReason: String) {
        setAccessToken(accessToken, expires: tokenExpires, permissions: perms)
        notifyDelegate(forToken: authToken, withError: errorReason)
    }
        
    func accessToken() -> String {
        return (authToken.authenticationToken?.copy())!
    }

    func sendFacebookRequest(_ allParams: [AnyHashable: Any]) {
        let pool = NSAutoreleasePool()
        if authToken {
            let request = allParams["request"] as? String
            var str: String
            let postRequest: Bool = allParams["postRequest"]! != 0
            if postRequest {
                str = String(format: kFBGraphApiPostURL, request)
            }
            else {
                // Check if request already has optional parameters
                var formatStr: String = kFBGraphApiGetURL
                let rng: NSRange? = (request as NSString?)?.range(of: "?")
                if rng?.length > 0 {
                    formatStr = kFBGraphApiGetURLWithParams
                }
                str = String(format: formatStr, request, authToken.authenticationToken)
            }
        }
        //  The converted code is limited to 1 KB.
        //  Launch "Swiftify for Xcode" and enter your API key to remove this limitation.
        var params = allParams["params"] as? [AnyHashable: Any]
        var strPostParams: String? = nil
        if params != nil {
            if postRequest {
                strPostParams = "access_token=\(authToken.authenticationToken)"
                for p: String in params?.keys {
                    strPostParams ?? "" += "&\(p)=\(params?[p])"
                }
            }
            else {
                var strWithParams: String = str
                for p: String in params?.keys {
                    strWithParams += "&\(p)=\(params?[p])"
                }
                str = strWithParams
            }
        }
        var req = NSMutableURLRequest(url: URL(string: str)!)
        if postRequest {
            var requestData = Data(bytes: strPostParams?.utf8CString, length: strPostParams?.count ?? 0)
            req.httpMethod = "POST"
            req.httpBody = requestData
            req.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "content-type")
        }
        var response: URLResponse? = nil
        var error: Error? = nil
        var data: Data? = try? NSURLConnection.sendSynchronousRequest(req, returning: response)
        if delegate.responds(to: #selector(self.requestResult)) {
            var str = String(bytes: (data?.bytes as? Void)!, length: Int(data?.count ?? 0), encoding: .ascii, freeWhenDone: false)
            var result = [
                "result" : str!,
                "request" : request,
                "raw" : data!,
                "sender" : self
            ]
            delegate.performSelector(onMainThread: #selector(self.requestResult), with: result, waitUntilDone: true)
        }

    }

        //  The converted code is limited to 1 KB.
        //  Launch "Swiftify for Xcode" and enter your API key to remove this limitation.
        func sendRequest(_ request: String, params: [AnyHashable: Any], usePostRequest postRequest: Bool) {
            var allParams = [ "request" : request ]
            if params != nil {
                allParams["params"] = params
            }
            allParams["postRequest"] = (postRequest ? 1 : 0)
            Thread.detachNewThreadSelector(#selector(self.sendFacebookRequest), toTarget: self, with: allParams)
        }
        
        func sendRequest(_ request: String) {
            sendRequest(request, params: nil, usePostRequest: false)
        }
        //  The converted code is limited to 1 KB.
        //  Launch "Swiftify for Xcode" and enter your API key to remove this limitation.
        func sendFacebookFQLRequest(_ query: String) {
            let pool = NSAutoreleasePool()
            if authToken {
                let str = String(format: kFBGraphApiFqlURL, (query as NSString).addingPercentEscapes(using: .utf8), authToken.authenticationToken)
                var req = NSMutableURLRequest(url: URL(string: str)!)
                var response: URLResponse? = nil
                var error: Error? = nil
                let data: Data? = try? NSURLConnection.sendSynchronousRequest(req as! URLRequest, returning: response)
                if delegate.responds(to: #selector(self.requestResult)) {
                    let str = String(bytes: (data?.bytes as? Void)!, length: Int(data?.count ?? 0), encoding: .ascii, freeWhenDone: false)
                    let result = [
                        "result" : str!,
                        "request" : query,
                        "raw" : data!,
                        "sender" : self
                    ]
                    delegate.performSelector(onMainThread: #selector(self.requestResult), with: result, waitUntilDone: true)
    
                }
            }
    }
    func sendFQLRequest(_ query: String) {
        Thread.detachNewThreadSelector(#selector(self.sendFacebookFQLRequest), toTarget: self, with: query)
    }
    // MARK: Notifications
    func webViewWillShowUI() {
        if delegate.responds(to: #selector(self.willShowUINotification)) {
            delegate.performSelector(onMainThread: #selector(self.willShowUINotification), with: self, waitUntilDone: true)
        }
    }
    func didDismissUI() {
        if delegate.responds(to: #selector(self.didDismissUI)) {
            delegate.performSelector(onMainThread: #selector(self.didDismissUI), with: self, waitUntilDone: true)
        }
    }
}

protocol FBTokenFacebookDelegate: class {
    
    func tokenResult(_ result: [AnyHashable: Any])
    
    func requestResult(_ result: [AnyHashable: Any])
    // needsAuthentication is called before showing the authentication WebView.
    // If it returns YES, the default login window will not be shown and
    // your application is responsible for the authentication UI.
    func needsAuthentication(_ authenticationURL: String, forPermissions permissions: String) -> Bool
    
    func willShowUINotification(_ sender: PhFacebook)
    
    func didDismissUI(_ sender: PhFacebook)
}
