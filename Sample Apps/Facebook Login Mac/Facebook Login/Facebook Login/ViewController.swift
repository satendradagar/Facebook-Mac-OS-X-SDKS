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
import Facebook_Mac_Login
import Facebook_Mac_Core

class ViewController: NSViewController, FBTokenFacebookDelegate {
    var fbToken :AccessToken? = AccessToken.current
    
    
    func tokenResult(_ result: [AnyHashable : Any]) {
        print(result)
        
        fbToken = AccessToken.init(appId: "1636501749741684", authenticationToken: result["token"] as! String, userId: nil, refreshDate: Date(), expirationDate: result["expiry"] as! Date, grantedPermissions: Set.init(arrayLiteral: Permission.init(name: result["permissions"] as! String)), declinedPermissions: nil)
        AccessToken.current = fbToken
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
    var manager : LoginManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginController = PhFacebook.init(appID: "1636501749741684", andDelegate: self)
        //        [FBSDKSettings accessTokenCache]
        
        self.view.addSubview((loginController?.webViewController?.view)!)
        // Do any additional setup after loading the view.
//         manager = LoginManager.init(loginBehavior: .native, defaultAudience: .friends)
    
    }
    @IBAction func login(sender:Any?){//"publish_stream",
//        if let accessToken = AccessToken.current {
//            // User is logged in, use 'accessToken' here.
//            print(accessToken.authenticationToken)
//        }else{
            loginController?.getAccessToken(forPermissions: ["user_events"], cached: false)

//        }
        

//            loginController?.getAccessToken(forPermissions: ["user_events"], cached: false)
//        manager?.logIn(readPermissions: [.userEvents], viewController: self, completion: { (result) in
//            print(result)
//
//        })
        
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

    func refreshEventsWithCompletion(parameters: [String : Any]) {
        let req = GraphRequest(graphPath: "me/events", parameters:parameters, accessToken: fbToken, httpMethod: GraphRequestHTTPMethod(rawValue: "GET")!)
        req.start({ (connection, result) in
            switch result {
            case .failed(let error):
                print(error)
                
            case .success(let graphResponse):
                if let responseDictionary = graphResponse.dictionaryValue {
                    print(responseDictionary)
                    if let paging = responseDictionary["paging"] as? [String:Any] {
                        if let cursors = paging["cursors"] as? [String:Any] {
//                            self.refreshEventsWithCompletion(parameters:cursors)

                            if let after = cursors["after"] as? String {
                            
                                print("\n\n\n\n\ntrying to load next page")

                                self.refreshEventsWithCompletion(parameters:["after":after])
                            }
                            
                        }
                    } else {
                        print("Can't read next!!!")
                    }

                }
            }
        })
    }
    
    @IBAction func request(sender:Any?){//"publish_stream",
//["fields":"email,first_name,last_name,gender,picture"]
        /*
         FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
         initWithGraphPath:@"/me/events"
         parameters:nil
         HTTPMethod:@"GET"];
         [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
         // Insert your code here
         }];
 */
        refreshEventsWithCompletion(parameters: [:])
        return
        let req = GraphRequest(graphPath: "me/events", parameters:[:], accessToken: fbToken, httpMethod: GraphRequestHTTPMethod(rawValue: "GET")!)
        req.start({ (connection, result) in
            switch result {
            case .failed(let error):
                print(error)
                
            case .success(let graphResponse):
                if let responseDictionary = graphResponse.dictionaryValue {
                    print(responseDictionary)
                    if let paging = responseDictionary["paging"] as? [String:Any] {
                        if let cursors = paging["paging.cursors.after"] as? [String:Any] {
                            if let after = cursors["after"] as? [String:Any] {
                                
                            }

                        }
                            print("error")
                    } else {
                        print("Can't read next!!!")
                    }
//                    let firstNameFB = responseDictionary["first_name"] as? String
//                    let lastNameFB = responseDictionary["last_name"] as? String
//                    let socialIdFB = responseDictionary["id"] as? String
//                    let genderFB = responseDictionary["gender"] as? String
//                    let pictureUrlFB = responseDictionary["picture"] as? [String:Any]
//                    let photoData = pictureUrlFB["data"] as? [String:Any]
//                    let photoUrl = photoData["url"] as? String
//                    print(firstNameFB, lastNameFB, socialIdFB, genderFB, photoUrl)
                }
            }
        })
        
    }
}

