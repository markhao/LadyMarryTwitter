//
//  TwitterClient.swift
//  LadyMarryTwitter
//
//  Created by Yu Qi Hao on 6/22/16.
//  Copyright © 2016 Yu Qi Hao. All rights reserved.
//

import Foundation
import STTwitter

class TwitterClient {
    
    // authentication state
    var oauthToken: String? = nil
    var oauthTokenSecret: String? = nil
    
    private lazy var sttwitter = Utilities.appDelegate.sttwitter!
    
    static let sharedInstance = TwitterClient()
    private init() {}
    
    
    
    //MARK: - OAuth Methods
    func authenticateWithViewController(hostViewController: UIViewController, completionHandlerForAuth: (success: Bool, errorString: String?) -> Void) {
        
        sttwitter.postTokenRequest({ (url, token) in
            
            self.loginWithUrlAndToken(url, token: token, hostViewController: hostViewController, completionHandlerForLogin: { (success, errorString, token, verifier) in
                
                if success {
                    
                    self.setOAuthTokenAndVerifier(token!, verifier: verifier!, completionHandlerForSetOauth: { (success, errorString, oauthToken, oauthTokenSecret) in
                        
                        if success {
                            
                            self.oauthToken = oauthToken!
                            self.oauthTokenSecret = oauthTokenSecret!
                            Utilities.userDefault.setValue(oauthToken!, forKey: "OauthToken")
                            Utilities.userDefault.setValue(oauthTokenSecret!, forKey: "OauthTokenSecret")
                            
                            completionHandlerForAuth(success: true, errorString: nil)
                            
                        } else {
                            
                            completionHandlerForAuth(success: false, errorString: errorString)
                        }
                    })
                    
                } else {
                    completionHandlerForAuth(success: false, errorString: errorString)
                }
            })
            }, oauthCallback: Constants.OAuthCallback) { (error) in
                completionHandlerForAuth(success: false, errorString: error.localizedDescription)
        }
    }
    
    private func loginWithUrlAndToken(authorizationURL: NSURL?, token: String?, hostViewController: UIViewController, completionHandlerForLogin: (success: Bool, errorString: String?, oauthToken: String?, oauthVerifier: String?) -> Void) {
        
        let request = NSURLRequest(URL: authorizationURL!)
        let webAuthViewController = hostViewController.storyboard!.instantiateViewControllerWithIdentifier("LMTAuthViewController") as! LMTAuthViewController
        webAuthViewController.urlRequest = request
        webAuthViewController.requestToken = token
        webAuthViewController.completionHandlerForView = completionHandlerForLogin
        
        let webAuthNavigationController = UINavigationController()
        webAuthNavigationController.pushViewController(webAuthViewController, animated: false)
        
        performUIUpdatesOnMain {
            hostViewController.presentViewController(webAuthNavigationController, animated: true, completion: nil)
        }
    }
    
    private func setOAuthTokenAndVerifier(token: String, verifier: String, completionHandlerForSetOauth: (success: Bool, errorMessage: String?, oauthToken: String?, oauthTokenSecret: String?)-> Void) {
        sttwitter.postAccessTokenRequestWithPIN(verifier, successBlock: { (oauthToken, oauthTokenSecret, userID, screenName) in
            
            completionHandlerForSetOauth(success: true, errorMessage: nil, oauthToken: oauthToken, oauthTokenSecret: oauthTokenSecret)
            }) { (error) in
               completionHandlerForSetOauth(success: false, errorMessage: error.localizedDescription, oauthToken: nil, oauthTokenSecret: nil)
        }
    }
}


//MARK: - Streaming Methods

extension TwitterClient {
    
    func getStatusesSample() {
        let request = sttwitter.postStatusesFilterKeyword("Warriors", tweetBlock: { (statuses) in
            print(statuses.count)
            }) { (error) in
                print(error.localizedDescription)
        }
    }
}

extension TwitterClient {
    func verifiedCredentials () -> Bool {
        sttwitter.verifyCredentialsWithUserSuccessBlock({ (userName, userID) in
            return true
            }) { (error) in
                return false
        }
        return false
    }
}







