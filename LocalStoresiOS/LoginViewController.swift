//
//  LoginViewController.swift
//  LocalStoresiOS
//
//  Created by Juan Murillo on 3/10/17.
//  Copyright © 2017 Juan Murillo. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
    @IBOutlet weak var signInSelector: UISegmentedControl!
    
    @IBOutlet weak var signInLabel: UILabel!
    
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var signInRegisterbutton: UIButton!
    
    var isSignIn: Bool = true
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func signInSelectorChanged(_ sender: UISegmentedControl) {
        isSignIn = !isSignIn
        
        if isSignIn {
            signInLabel.text = "Sign In"
            signInRegisterbutton.setTitle("Sign in", for: .normal)
        }
        else {
            signInLabel.text = "Register"
            signInRegisterbutton.setTitle("Register", for: .normal)
        }
    
    }
    
    
    @IBAction func signInRegisterButtonTapped(_ sender: UIButton) {
        
        // checks if it is signed in or register
        if isSignIn {
            if let email = self.emailTextField.text, let password = self.passwordTextField.text {
                    // [START headless_email_auth]
                    Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
                        // [START_EXCLUDE]
                            if let error = error {
                                print(error.localizedDescription)
                                return
                            }
                        
                            self.performSegue(withIdentifier: "goToHome", sender: self)
                        
                        // [END_EXCLUDE]
                    }
                    // [END headless_email_auth]
            } else {
                print("email/password can't be empty")
            }
        }
        else {
            // registers the user with Firebase
            
            if let email = self.emailTextField.text, let password = self.passwordTextField.text {
                    // [START create_user]
                    Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
                        // [START_EXCLUDE]

                            if let error = error {
                                print(error.localizedDescription)
                                return
                            }
                            print("\(user!.email!) created")
                        self.performSegue(withIdentifier: "goToHome", sender: self)
                        
                        // [END_EXCLUDE]
                    }
                    // [END create_user]
            } else {
                print("email/password can't be empty")
            }
            
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
