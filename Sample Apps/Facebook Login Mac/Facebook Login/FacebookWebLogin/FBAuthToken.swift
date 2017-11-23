//
//  FBAuthToken.swift
//  FacebookWebLogin
//
//  Created by Satendra Singh on 19/11/17.
//  Copyright © 2017 Satendra. All rights reserved.
//

import Foundation


class FBAuthenticationToken: NSObject {
    var authenticationToken = ""
    var expiry: Date?
    var permissions = ""

    init(token: String, secondsToExpiry seconds: TimeInterval, permissions perms: String) {
            super.init()
            authenticationToken = token
            if seconds != 0 {
                expiry = Date(timeIntervalSinceNow: seconds)
            }
            permissions = perms
        }
}

