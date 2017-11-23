//
//  ViewController.swift
//  Facebook Login
//
//  Created by Satendra Singh on 09/11/17.
//  Copyright © 2017 Satendra. All rights reserved.
//

import Cocoa
import Facebook_Mac_Login
import Accounts

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    @IBAction func login(sender:Any?){
        self.post(text: "") { (bool) in
            
        }
    }
     func post(text:String,completion:@escaping ((Bool)->Void)) {
        
        let accountStore = ACAccountStore()
        let accountType = accountStore.accountType(withAccountTypeIdentifier: ACAccountTypeIdentifierFacebook)
        
//        let options : [String:Any] = [
//            "ACFacebookAppIdKey": "1636501749741684",
//            "ACFacebookPermissionsKey": ["publish_actions", "manage_pages","publish_pages"],"ACFacebookAudienceKey":"ACFacebookAudienceEveryone"
//        ]
        let options : [String:Any] = [
            ACFacebookAppIdKey: "1636501749741684",
            ACFacebookPermissionsKey: ["publish_stream"],
            ACFacebookAudienceKey: ACFacebookAudienceFriends];

        accountStore.requestAccessToAccounts(with: accountType, options: options) {
            granted, error in
            
            if granted {
                let fbAccounts = accountStore.accounts(with: accountType)
                
                if fbAccounts != nil {
                    completion(true)
                } else {
                    print("no accounts")
                    completion(false)
                }
            }
            else{
                print(error?.localizedDescription);
            }
        }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

