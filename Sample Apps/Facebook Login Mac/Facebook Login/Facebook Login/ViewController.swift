//
//  ViewController.swift
//  Facebook Login
//
//  Created by Satendra Singh on 09/11/17.
//  Copyright © 2017 Satendra. All rights reserved.
//

import Cocoa
import Accounts
import FacebookWebLogin

class ViewController: NSViewController, FBTokenFacebookDelegate {
    
    func tokenResult(_ result: [AnyHashable : Any]) {
        print(result)

        let answer = dialogOKCancel(question: "Ok?", text: result.description)

    }
    
    func requestResult(_ result: [AnyHashable : Any]) {
        print(result)

    }
    
    func needsAuthentication(_ authenticationURL: String, forPermissions permissions: String) -> Bool {
        print(permissions)

        return true
    }
    
    func willShowUINotification(_ sender: PhFacebook) {
        print("willShow Not")

    }
    
    func didDismissUI(_ sender: PhFacebook) {
        print("Dismiss ")
    }
    
    var loginController: PhFacebook?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginController = PhFacebook.init(appID: "1636501749741684", andDelegate: self)
        
        self.view.addSubview((loginController?.webViewController?.view)!)
        // Do any additional setup after loading the view.
    }
    @IBAction func login(sender:Any?){//"publish_stream",
            loginController?.getAccessToken(forPermissions: ["user_events"], cached: false)
//        self.post(text: "") { (bool) in
        
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


    func dialogOKCancel(question: String, text: String) -> Bool {
        let alert = NSAlert()
        alert.messageText = question
        alert.informativeText = text
        alert.alertStyle = NSAlert.Style.warning
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Cancel")
        return alert.runModal() == NSApplication.ModalResponse.alertFirstButtonReturn
    }

}

