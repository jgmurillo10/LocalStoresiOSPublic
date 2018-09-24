//
//  LoginRegisterViewController.swift
//  LocalStoresiOS
//
//  Created by David Mauricio Delgado Ruiz on 4/10/17.
//  Copyright © 2017 Juan Murillo. All rights reserved.
//

import UIKit
import FirebaseAuth
import LocalAuthentication
import SwiftKeychainWrapper

class LoginRegisterViewController: UIViewController, UITextFieldDelegate {
    
    // scroll view reference
    @IBOutlet weak var scrollView: UIScrollView!
    
    
    @IBOutlet weak var signInSelector: UISegmentedControl!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var signInButton: UIButton!
    
    @IBOutlet weak var touchIDButton: UIButton!
    
    @IBOutlet weak var touchIDLabel: UILabel!
    
    
    var isSignIn: Bool = true
    
    var userSignedIn: Bool = false
    
    /** @var handle
     @brief The handler for the auth state listener, to allow cancelling later.
     */
    var handle: AuthStateDidChangeListenerHandle?
    
    let errorConnectionText = "No network detected, please connect to WiFi or mobile data connection"
    
    let invalidPasswordError = "The password is invalid or the user does not have a password."
    let invalidPasswordResponseMessage = "The password is invalid. Please enter a valid password"
    
    // functions related to scrollable contentview
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        
        // [START auth_listener]
            handle = Auth.auth().addStateDidChangeListener { (auth, user) in
                if let user = user {
                    // User is signed in.
                    self.performSegue(withIdentifier: "goToHomeFromLogin", sender: self)
                    self.userSignedIn = true
                    print("listener user signed in")
                } else {
                    // No User is signed in.
                    self.userSignedIn = false
                    print("listener user signed out")
                }
        }
        // [END auth_listener]
        
        
        /// Move TextFields to keyboard. Step 7: Add observers to receive UIKeyboardWillShow and UIKeyboardWillHide notification.
        addObservers()
    }
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // [START remove_auth_listener]
        Auth.auth().removeStateDidChangeListener(handle!)
        // [END remove_auth_listener]
        /// Move TextFields to keyboard. Step 8: Remove observers to NOT receive notification when viewcontroller is in the background.
        removeObservers()
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        self.emailTextField.delegate = self;
        self.passwordTextField.delegate = self;
        
        // Do any additional setup after loading the view.
        
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapView(gesture:)))
        view.addGestureRecognizer(tapGesture)
        
        
    }

    /// Move TextFields to keyboard. Step 2: Add method to handle tap event on the view and dismiss keyboard.
    @objc func didTapView(gesture: UITapGestureRecognizer) {
        // This should hide keyboard for the view.
        view.endEditing(true)
    }
    
    
    /// Move TextFields to keyboard. Step 3: Add observers for 'UIKeyboardWillShow' and 'UIKeyboardWillHide' notification.
    func addObservers() {
        NotificationCenter.default.addObserver(forName: .UIKeyboardWillShow, object: nil, queue: nil) {
            notification in
            self.keyboardWillShow(notification: notification)
        }
        NotificationCenter.default.addObserver(forName: .UIKeyboardWillHide, object: nil, queue: nil) {
            notification in
            self.keyboardWillHide(notification: notification)
        }
    }
    
    /// Move TextFields to keyboard. Step 4: Add method to handle keyboardWillShow notification, we're using this method to adjust scrollview to show hidden textfield under keyboard.
    func keyboardWillShow(notification: Notification) {
        guard let userInfo = notification.userInfo,
            let frame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
                return
        }
        let contentInset = UIEdgeInsets(top: 0, left: 0, bottom: frame.height, right: 0)
        scrollView.contentInset = contentInset
    }
    
    /// Move TextFields to keyboard. Step 5: Method to reset scrollview when keyboard is hidden.
    func keyboardWillHide(notification: Notification) {
        scrollView.contentInset = UIEdgeInsets.zero
    }
    
    /// Move TextFields to keyboard. Step 6: Method to remove observers.
    func removeObservers() {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return (true)
    }
    
    // sign in Functions
    
    @IBAction func signInSelectorChanged(_ sender: UISegmentedControl) {
        isSignIn = !isSignIn
        
        if isSignIn {
            signInButton.setTitle("Sign in", for: .normal)
            touchIDButton.isHidden =  false
            touchIDLabel.isHidden = false
        }
        else {
            signInButton.setTitle("Register", for: .normal)
            touchIDButton.isHidden = true
            touchIDLabel.isHidden = true
        }
    
    }
    
    @IBAction func signInButtonTapped(_ sender: UIButton) {
        if self.emailTextField.text == nil || self.emailTextField.text == "" {
            self.showAlert(title: "Email empty", message: "email can't be empty. Add a valid email", closeButtonTitle: "Close")
            return
        }
        
        if self.passwordTextField.text == nil || self.passwordTextField.text == "" {
            self.showAlert(title: "Password empty", message: "password can't be empty. Add a valid password", closeButtonTitle: "Close")
            return
        }
        
        // checks if it is signed in or register
        if isSignIn {
            if let email = self.emailTextField.text, let password = self.passwordTextField.text {
                    signInFirebase(email: email, password: password)
            } else {
                print("email/password can't be empty in sign in")
            }
        }
        else {
            // registers the user with Firebase
            
            
            if let email = self.emailTextField.text, let password = self.passwordTextField.text {
                registerFirebase(email: email, password: password)
            } else {
                
                print("email/password can't be empty in register")
            }
            
        }
    }
    func forgotPasswordFirebase(email: String){
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            if let error = error {
                print(error.localizedDescription)
                if error.localizedDescription == "Network error (such as timeout, interrupted connection or unreachable host) has occurred." {
                    self.showAlert(title: "Error sending recovery email.", message: self.errorConnectionText, closeButtonTitle: "Close")
                }
                else {
                    self.showAlert(title: "Error sending recovery email.", message: error.localizedDescription, closeButtonTitle: "Close")
                }
                
                return
            }
            self.showAlert(title: "Reset password", message: "Email sent to \(email) with link to reset password", closeButtonTitle: "Close")
            
        }
    }
    func signInFirebase(email: String, password: String) {
        // [START headless_email_auth]
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            // [START_EXCLUDE]
            if let error = error {
                if error.localizedDescription == "Network error (such as timeout, interrupted connection or unreachable host) has occurred." {
                    self.showAlert(title: "Error signing in", message: self.errorConnectionText, closeButtonTitle: "Close")
                    
                }
                else {
                    if error.localizedDescription == self.invalidPasswordError {
                        self.showAlert(title: "Error signing in", message: self.invalidPasswordResponseMessage, closeButtonTitle: "Close")
                    } else {
                        self.showAlert(title: "Error signing in", message: error.localizedDescription, closeButtonTitle: "Close")
                    }
                    
                }
                print(error.localizedDescription)
                return
            }
            
            self.performSegue(withIdentifier: "goToHomeFromLogin", sender: self)
            
            // [END_EXCLUDE]
        }
        // [END headless_email_auth]
    }
    
    func registerFirebase(email: String, password: String) {
        // [START create_user]
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            // [START_EXCLUDE]
            
            if let error = error {
                if error.localizedDescription == "Network error (such as timeout, interrupted connection or unreachable host) has occurred." {
                    self.showAlert(title: "Error registering user", message: self.errorConnectionText, closeButtonTitle: "Close")
                    
                }
                else {
                    self.showAlert(title: "Error registering user", message: error.localizedDescription, closeButtonTitle: "Close")
                }
                print(error.localizedDescription)
                return
            } else {
                
                let sucess: Bool = self.saveCredentialsKeyChain(email: email, password: password)
                if sucess {
                    print("\(user!.email!) created")
                    self.performSegue(withIdentifier: "goToHomeFromLogin", sender: self)
                }
                else {
                    self.showAlertWithTitle(title: "Error", message: "Login Credentials could not be saved on the device. Try again.")
                }
            }
            
            
            
            
            // [END_EXCLUDE]
        }
        // [END create_user]
    }
    
    // sign in functions with touchID
    func saveCredentialsKeyChain(email: String, password: String) -> Bool {
        let saveSuccessfulEmail: Bool = KeychainWrapper.standard.set(email, forKey: "userEmail")
        
        let saveSuccessfulPassword: Bool = KeychainWrapper.standard.set(password, forKey: "userPassword")
        return saveSuccessfulEmail && saveSuccessfulPassword
    }
    
    @IBAction func useTouchIDButtonWasPressed(_ sender: UIButton) {
        let authenticationContext = LAContext()
        var error: NSError?
        
        if authenticationContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            
            authenticationContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Only a valid user can access the application", reply: { (success, error) in
                if success{
                    // get user email and password using wrapper for keychain interface
                    
                    if let retrievedEmail = KeychainWrapper.standard.string(forKey: "userEmail"), let retrievedPassword = KeychainWrapper.standard.string(forKey: "userPassword"){
                        self.signInFirebase(email: retrievedEmail, password: retrievedPassword)
                    }
                    else {
                        self.showAlertWithTitle(title: "Error", message: "No credentials found on this device. Please register a user")
                    }
                    
                } else {
                    // display an error of an specific type
                    if let error = error as NSError? { // OJO
                        
                        let message = self.errorMessageForLAErrorCode(errorCode: error.code)
                        print(message)
                        self.showAlertViewAfterEvaluatingPolicyWithMessage(message: message)
                    }
                    
                    
                }
            })
          
            // Touch ID navigating to success VC, handle errors
        } else {
            showAlertViewForNoBiometrics()
            return
        }
        
        
    }
    
    func showAlertViewAfterEvaluatingPolicyWithMessage(message: String) {
        showAlertWithTitle(title: "Error", message: message)
    }
    
    func errorMessageForLAErrorCode(errorCode: Int) -> String {
        var message = ""
        
        switch errorCode {
        case LAError.appCancel.rawValue:
            message = "Authentication was cancelled by application"
            
        case LAError.authenticationFailed.rawValue:
            message = "The user failed to provide valid credentials"
            
        case LAError.invalidContext.rawValue:
            message = "The context is invalid"
            
        case LAError.passcodeNotSet.rawValue:
            message = "Passcode is not set on the device"
            
        case LAError.systemCancel.rawValue:
            message = "Authentication was cancelled by the system"
            
        case LAError.touchIDLockout.rawValue:
            message = "Too many failed attempts."
            
        case LAError.touchIDNotAvailable.rawValue:
            message = "TouchID is not available on the device"
            
        case LAError.userCancel.rawValue:
            message = "The user did cancel"
            
        case LAError.userFallback.rawValue:
            message = "The user chose to use the fallback"
            
        default:
            message = "Did not find error code on LAError object"
        }
        return message
    }
    
    func navigatetoAuthenticatedVC() {
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "goToHomeFromLogin", sender: self)
            }
    }
    
    func showAlertViewForNoBiometrics() {
        showAlertWithTitle(title: "Error", message: "This device does not have TouchID")
    }
    
    func showAlertWithTitle(title: String, message: String){
        let alertVC = UIAlertController(title: title,message: message, preferredStyle: .alert )
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alertVC.addAction(okAction)
        
        DispatchQueue.main.async {
            self.present(alertVC, animated: true, completion: nil)
        }
    }
    
    
    
    
    // other system functions
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // alert functions
    // function to show alerts in case there is no input in textfields
    func showAlert(title: String, message: String, closeButtonTitle: String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: closeButtonTitle, style: .default, handler: {(action: UIAlertAction) in})
        
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: {})
    }
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        if segue.identifier == "goToHomeFromLogin" {
            let targetController: UITabBarController = segue.destination as! UITabBarController
            targetController.selectedIndex = 2
        }
        // Pass the selected object to the new view controller.
    }
    
    @IBAction func forgotPasswordTapped(_ sender: Any) {
        if self.emailTextField.text == nil || self.emailTextField.text == "" {
            self.showAlert(title: "Email empty", message: "email can't be empty. Add a valid email to reset your password", closeButtonTitle: "Close")
            return
        }
        
        forgotPasswordFirebase(email: self.emailTextField.text!)
        
        
    }
    

}

extension UIView {
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
}
