//
//  PasswordViewController.swift
//  SecureNoteSwift
//
//  Created by Michael Privat on 10/10/14.
//  Copyright (c) 2014 Pro iOS Persistence. All rights reserved.
//

import Foundation
import UIKit

class PasswordViewController : UIViewController {
    @IBOutlet weak var passwordField: UITextField!
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "logIn" {
            // Set the managed object context in the master view controller
            let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
            let controller = segue.destinationViewController as MasterViewController
            controller.managedObjectContext = appDelegate.managedObjectContext
        }
    }
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        // Make sure they've entered something in the password field
        let enteredPassword = self.passwordField.text
        if identifier == "logIn" {
            // Store whatever they've entered in the application delegate
            let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
            appDelegate.password = enteredPassword
            
            // Retrieve the password from the keychain
            let password = SSKeychain.passwordForService("SecureNote", account: "default")
            
            // If they've never entered a password, they're creating a new one
            if password == nil {
                // Store the password in the keychain and allow segue to be performed
                SSKeychain.setPassword(enteredPassword, forService: "SecureNote", account: "default")
                return true
            } else {
                // Verify password and allow segue only if verified
                return password == enteredPassword
            }
        }
        else {
            return false;
        }
    }
}