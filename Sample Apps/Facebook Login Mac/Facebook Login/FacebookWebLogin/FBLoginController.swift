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

 public class PhFacebook: NSObject {
    var appID = ""
    var delegate: FBTokenFacebookDelegate?
   public var webViewController: FacebookLoginController?
    private var authToken: FBAuthenticationToken?
    private var permissions = ""
        // MARK: Initialization

     public init( appID: String, andDelegate delegate: FBTokenFacebookDelegate?) {
        super.init()
        if appID != "" {
            self.appID = appID
        }
        self.delegate = delegate
        let bundle = Bundle(for: PhFacebook.self)
        // Don't retain delegate to avoid retain cycles
        webViewController = FacebookLoginController(nibName: NSNib.Name(rawValue: "FacebookLoginController"), bundle: bundle)
        authToken = nil
        print("Initialized with AppID \(self.appID)")
        
    }

    func notifyDelegate(for tokenIn:FBAuthenticationToken? , withError errorReason: String?) {
        var result = [AnyHashable: Any]()
        if let token = tokenIn  {
            // Save it to user defaults
            let defaults: UserDefaults? = UserDefaults.standard
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
        //SS TODO:
//        if delegate.responds(to: #selector(self.tokenResult)) {
//            delegate.tokenResult(result)
//        }
    }

   public func clearToken() {
        authToken = nil
    }
    
   public func invalidateCachedToken() {
        clearToken()
        let defaults: UserDefaults? = UserDefaults.standard
        defaults?.removeObject(forKey: kFBStoreAccessToken)
        defaults?.removeObject(forKey: kFBStoreTokenExpiry)
        defaults?.removeObject(forKey: kFBStoreAccessPermissions)
        // Allow logout by clearing the left-over cookies (issue #35)
//        let facebookUrl = URL(string: LoginURLConstants.URLs.URL)
        let facebookSecureUrl = URL(string: LoginURLConstants.URLs.SecureURL)
        let cookieStorage = HTTPCookieStorage.shared
//        let cookies = (cookieStorage.cookies(for: facebookUrl!))! + cookieStorage.cookies(for: facebookSecureUrl!) ?? [Any]()
        let cookies =  cookieStorage.cookies(for: facebookSecureUrl!)

        for cookie: HTTPCookie in cookies! {
            cookieStorage.deleteCookie(cookie)
        }
    }
    
    func setAccessToken(_ accessToken: String, expires tokenExpires: TimeInterval = 100, permissions perms: String) {
        clearToken()
        if accessToken != "" {
            authToken = FBAuthenticationToken(token: accessToken, secondsToExpiry: tokenExpires, permissions: perms)
        }
    }

    // permissions: an array of required permissions
    //              see http://developers.facebook.com/docs/authentication/permissions
    // canCache: save and retrieve token locally if not expired
   public func getAccessToken(forPermissions permissions: [String], cached canCache: Bool) {
        var validToken = false
    let scope: String = permissions.joined(separator: ",")

        if canCache && authToken == nil {
            let defaults: UserDefaults? = UserDefaults.standard
            let accessToken: String? = defaults?.string(forKey: kFBStoreAccessToken)
            let date = defaults?.object(forKey: kFBStoreTokenExpiry) as? Date
            let perms: String? = defaults?.string(forKey: kFBStoreAccessPermissions)
            if (accessToken != nil) && (perms != nil) {
                
                // Do not notify delegate yet...
                self.setAccessToken(accessToken!, expires: (date?.timeIntervalSinceNow)!, permissions: perms!)
            }
        }
        if(authToken?.permissions.caseInsensitiveCompare(scope) == ComparisonResult.orderedSame){
            // We already have a token for these permissions; check if it has expired or not
            if authToken?.expiry == nil || (authToken?.expiry)! < Date() {
                validToken = true
            }
        }

        if validToken {
            notifyDelegate(for: authToken, withError: nil)
        }
        else {
            clearToken()
            // Use _webViewController to request a new token
            var authURL = ""
            if scope.count > 0 {
                authURL = LoginURLConstants.URLs.authUrlWith(clientID: appID, andScode: scope)
            }
            else {
                authURL = LoginURLConstants.URLs.authUrlWith(clientID: appID)

            }

            if let del = delegate{
                if del.responds(to: Selector(("needsAuthentication:forPermissions:"))) {
                    if del.needsAuthentication(authURL, forPermissions: scope) {
                        // If needsAuthentication returns YES, let the delegate handle the authentication UI
                        return
                    }
                }
            }
            // Retrieve token from web page
            
            if webViewController == nil {
                webViewController = FacebookLoginController.init()
            }
            // Prepare window but keep it ordered out. The _webViewController will make it visible
            // if it needs to.
            webViewController?.loginControler = self;
            webViewController?.permissions = scope;
//            let url = URL(string: authURL)
//            let request = URLRequest(url:url!)
//            webViewController?.webView.load(request)
            webViewController?.webView.mainFrameURL = authURL

     }
    }
    
    func setAccessToken(_ accessToken: String, expires tokenExpires: TimeInterval, permissions perms: String, error errorReason: String) {
        self.setAccessToken(accessToken, expires: tokenExpires, permissions: perms)
        notifyDelegate(for: authToken, withError: errorReason)
    }
        
    func accessToken() -> String? {
        return authToken?.authenticationToken
    }

    func sendFacebookRequest(_ allParams: [AnyHashable: Any]) {
//
//        if (authToken != nil) {
//            let request = allParams["request"] as? String
//            var str: String
//            var postRequest: Bool = false
//            if allParams["postRequest"] != nil{
//             postRequest = true
//            }
//            if postRequest {
//                str = String(format: LoginURLConstants.GraphApis.PostURL, request!)
//            }
//            else {
//                // Check if request already has optional parameters
//                var formatStr: String = LoginURLConstants.GraphApis.GetURL
//                if let rng = (request as NSString?)?.range(of: "?"){
//                    if rng.length > 0 {
//                        formatStr = LoginURLConstants.GraphApis.GetURLWithParams
//                    }
//
//                }
//                str = formatStr + request! + (authToken?.authenticationToken)!
//            }
//        }
//        //  Launch "Swiftify for Xcode" and enter your API key to remove this limitation.
//        var params = allParams["params"] as? [String: Any]
//        var strPostParams: String? = ""
//        if params != nil {
//            strPostParams = "access_token=\(String(describing: authToken?.authenticationToken))"
//                for p: String in params!.keys {
//                    strPostParams = strPostParams! + "&\(p)=\(String(describing: params?[p]))"
//                }
//            }
//            else {
//                var strWithParams: String = str
//                for p: String in params?.keys {
//                    strWithParams += "&\(p)=\(params?[p])"
//                }
//                str = strWithParams
//            }
//        }
//        var req = NSMutableURLRequest(url: URL(string: str)!)
//        if postRequest {
//            var requestData = Data(bytes: strPostParams?.utf8CString, length: strPostParams?.count ?? 0)
//            req.httpMethod = "POST"
//            req.httpBody = requestData
//            req.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "content-type")
//        }
//        var response: URLResponse? = nil
//        var error: Error? = nil
//        var data: Data? = try? NSURLConnection.sendSynchronousRequest(req, returning: response)
//        if delegate.responds(to: #selector(self.requestResult)) {
//            var str = String(bytes: (data?.bytes as? Void)!, length: Int(data?.count ?? 0), encoding: .ascii, freeWhenDone: false)
//            var result = [
//                "result" : str!,
//                "request" : request,
//                "raw" : data!,
//                "sender" : self
//            ]
//            delegate.performSelector(onMainThread: #selector(self.requestResult), with: result, waitUntilDone: true)
//        }
//        if (authToken != nil) {
//            let request = allParams["request"] as? String
//            var str = ""
//            var postRequest: Bool = false
//            if allParams["postRequest"] != nil{
//             postRequest = true
//            }
//            if postRequest {
//                str = String(format: LoginURLConstants.GraphApis.PostURL, request!)
//            }
//            else {
//                // Check if request already has optional parameters
//                var formatStr: String = LoginURLConstants.GraphApis.GetURL
//                if let rng = (request as NSString?)?.range(of: "?"){
//                    if rng.length > 0 {
//                        formatStr = LoginURLConstants.GraphApis.GetURLWithParams
//                    }
//
//                }
//                str = formatStr + request! + (authToken?.authenticationToken)!
//            }
//            var params = allParams["params"] as? [String: Any]
//            var strPostParams: String? = nil
//            if params != nil {
//                if postRequest {
//                    strPostParams = "access_token=\(String(describing: authToken?.authenticationToken))"
//                    for p: String in params!.keys {
//                        strPostParams = strPostParams! + "&\(p)=\(String(describing: params?[p]))"
//                        }
//                    }
//                }
//                else {
//                    var strWithParams: String = str
//                for p: String in (params?.keys)! {
//                    strWithParams += "&\(p)=\(String(describing: params?[p]))"
//                    }
//                    str = strWithParams
//                }
//            var req = NSMutableURLRequest(url: URL(string: str)!)
//            if postRequest {
//
//            var requestData = strPostParams?.data(using: .utf8)
//
////                var requestData = Data(bytes: strPostParams?.utf8CString, length: strPostParams?.count ?? 0)
//                req.httpMethod = "POST"
//                req.httpBody = requestData
//                req.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "content-type")
//            }
//            var response: URLResponse? = nil
//            var error: Error? = nil
//            var data: Data? = try? NSURLConnection.sendSynchronousRequest(req as URLRequest , returning: &response)
//
//            if let del = delegate{
//                if del.responds(to: Selector(("requestResult"))) {
//
//                    var str = String.init(data: data!, encoding: String.Encoding.utf8)
//                    var result:[String:Any] = [
//                        "result" : str!,
//                        "request" : request!,
//                        "raw" : data!,
//                        "sender" : self
//                    ]
//                    del.requestResult(result)
//                }
//            }
//        }
//
    }
//
//        func sendRequest(_ request: String, params: [String: Any], usePostRequest postRequest: Bool) {
//            var allParams = [ "request" : request ]
//            if params != nil {
//                allParams["params"] = params
//            }
//            allParams["postRequest"] = (postRequest ? 1 : 0)
//            Thread.detachNewThreadSelector(#selector(self.sendFacebookRequest), toTarget: self, with: allParams)
//        }
//
//        // request: the short version of the Facebook Graph API, e.g. "me/feed"
//        // see http://developers.facebook.com/docs/api
//
//        func sendRequest(_ request: String) {
//            sendRequest(request, params: nil, usePostRequest: false)
//        }
//
//        func sendFacebookFQLRequest(_ query: String) {
//            let pool = NSAutoreleasePool()
//            if authToken {
//                let str = String(format: kFBGraphApiFqlURL, (query as NSString).addingPercentEscapes(using: .utf8), authToken.authenticationToken)
//                var req = NSMutableURLRequest(url: URL(string: str)!)
//                var response: URLResponse? = nil
//                var error: Error? = nil
//                let data: Data? = try? NSURLConnection.sendSynchronousRequest(req as! URLRequest, returning: response)
//                if delegate.responds(to: #selector(self.requestResult)) {
//                    let str = String(bytes: (data?.bytes as? Void)!, length: Int(data?.count ?? 0), encoding: .ascii, freeWhenDone: false)
//                    let result = [
//                        "result" : str!,
//                        "request" : query,
//                        "raw" : data!,
//                        "sender" : self
//                    ]
//                    delegate.performSelector(onMainThread: #selector(self.requestResult), with: result, waitUntilDone: true)
//
//                }
//            }
//    }
    func sendFQLRequest(_ query: String) {
//        Thread.detachNewThreadSelector(#selector(self.sendFacebookFQLRequest), toTarget: self, with: query)
    }
    // MARK: Notifications
    func webViewWillShowUI() {
//        if delegate.responds(to: #selector(self.willShowUINotification)) {
//            delegate.performSelector(onMainThread: #selector(self.willShowUINotification), with: self, waitUntilDone: true)
//        }
    }
    func didDismissUI() {
//        if delegate.responds(to: #selector(self.didDismissUI)) {
//            delegate.performSelector(onMainThread: #selector(self.didDismissUI), with: self, waitUntilDone: true)
//        }
    }
}

public protocol FBTokenFacebookDelegate : NSObjectProtocol {
    
    func tokenResult(_ result: [AnyHashable: Any])
    
    func requestResult(_ result: [AnyHashable: Any])
    // needsAuthentication is called before showing the authentication WebView.
    // If it returns YES, the default login window will not be shown and
    // your application is responsible for the authentication UI.
    func needsAuthentication(_ authenticationURL: String, forPermissions permissions: String) -> Bool
    
    func willShowUINotification(_ sender: PhFacebook)
    
    func didDismissUI(_ sender: PhFacebook)
}
