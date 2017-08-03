//
//  Login.swift
//  iDECIDE
//
//  Created by Mona Cook on 7/24/17.
//  Copyright © 2017 Danielle. All rights reserved.
//

import Foundation
import UIKit
import CloudKit

class LoginViewController: UIViewController {

    
    @IBOutlet weak var username_input: UITextField!
    @IBOutlet weak var password_input: UITextField!
    @IBOutlet weak var LoginButton: UIButton!
    
    let input1 = Username_input.text
    let input2 = Password_input.text
    
    var username_inputtext = ""
    var password_inputtext = ""
    
    let LogIn = CKRecord(recordType: "Patient")

    @IBAction func login_button(_ sender: AnyObject) {

        // login verification
        if (input1 == username_input.text) && (input2 == password_input.text) {
        performSegue(withIdentifier: "loggedIn" , sender: self)
        
        }
    }

        // ckrecord for patients
    
        publicDatabase.save(LogIn){ (success, error) -> Void in
            if(success != nil)
            {
                print("Saved Patient to CK")
            } else {
                print("CK Patient Save Error")
            }
        }
    }

//    let isUsername = emailTextField.text
//
//    let UsernameValid = ValidUser(UserDefaults: isUsername)
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        if UsernameValid {
//            print("Username is valid")
//        } else {
//            print("Usernameis not valid")
//            displayAlertMessage(messageToDisplay: "Username is not valid")
//        }
//    }
//
//    func isValidUser(testStr:String) -> Bool {
//        var returnValue = true
//        let userRegEx = "[A-Z0-9a-z.-_]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,3}"
//        
//        do {
//            let regex = try NSRegularExpression(pattern: userRegEx)
//            let nsString =  NSString()
//            let results = regex.matches(in: String, range: NSRange(location: 0, length: nsString.length))
//            
//            if results.count == 0
//            {
//                returnValue = false
//            }
//            
//        } catch let error as NSError {
//            print("Invalid regex: \(error.localizedDescription)")
//            returnValue = false
//        }
//            return returnValue
//        }
//    
//    func displayAlertMessage(messageToDisplay: String) {
//        let alertController = UIAlertController(title: "Alert", message: messageToDisplay, preferredStyle: .alert)
//        
//        let OKAction = UIAlertAction(title: "Ok", style: .default){
//            (action:UIAlertAction!) in
//            print("Press okay")
//        }
//        alertController.addAction(OKAction)
//        
//        self.present(alertController, animated:true, completion: nil)
//    }
//    
//    }

    
    // sign in code
    
    
    
    // verification code
    
    
    
    // When user types a password when signing up, encrypt password
    
    
    
    // verification code with User and password

