//
//  LoginKitURLs.swift
//  FacebookWebLogin
//
//  Created by Satendra Dagar on 23/11/17.
//  Copyright © 2017 Satendra. All rights reserved.
//

import Foundation

struct LoginURLConstants {

     struct URLs {
        
        static let AuthorizeURL = "https://graph.facebook.com/oauth/authorize?client_id=%@&redirect_uri=%@&type=user_agent&display=popup"

//        static let AuthorizeWithScopeURL = "https://graph.facebook.com/oauth/authorize?client_id=%@&redirect_uri=%@&scope=%@&type=user_agent&display=popu"
        static let AuthorizeWithScopeURL = "https://www.facebook.com/v2.11/dialog/oauth?"

        static let LoginSuccessURL = "https://www.facebook.com/connect/login_success.html"
        
        static let UIServerURL = "http://www.facebook.com/connect/uiserver.php"
        static let URL = "http://facebook.com"
        static let SecureURL = "https://facebook.com"
        
        static func authUrlWith(clientID:String) -> String {
            
            return self.authUrlWith(clientID: clientID, redirectURL: URLs.LoginSuccessURL)
        }
        
        static func authUrlWith(clientID:String, redirectURL:String) -> String {
            
            return URLs.AuthorizeWithScopeURL + "client_id=\(clientID)" + "&redirect_uri=\(redirectURL)"
        }

        static func authUrlWith(clientID:String,andScode scope:String ) -> String {
            
            let str = authUrlWith(clientID: clientID ) + "&scope=\(scope)" + "&response_type=token"
            return str
        }

    }
    
    struct GraphApis {

        static let GetURL = "https://graph.facebook.com/%@?access_token=%@"
        static let GetURLWithParams = "https://graph.facebook.com/%@&access_token=%@"

        static let PostURL = "https://graph.facebook.com/%@"

        static let FqlURL = "https://api.facebook.com/method/fql.query?query=%@&access_token=%@&format=json"

    }
    
    struct ResponseKeys {
        static let FBAccessToken = "access_token="
        static let FBExpiresIn = "expires_in="
        static let FBErrorReason = "error_description="
    }
}
