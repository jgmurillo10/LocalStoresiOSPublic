//
//  NewListViewController.swift
//  LocalStoresiOS
//
//  Created by David Mauricio Delgado Ruiz on 13/11/17.
//  Copyright © 2017 Juan Murillo. All rights reserved.
//

import UIKit
import Firebase

class NewListViewController: UIViewController {
    @IBOutlet weak var newListButton: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    var listName: String = "No name"
    override func viewDidLoad() {
        super.viewDidLoad()


    }

    //function to hide keyboard on touch outside the keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addNewList(_ sender: UIButton) {

        if currentReachabilityStatus != .notReachable {
            newListButton.isHidden = true
            if self.nameTextField.text == nil || self.nameTextField.text == "" {
                self.showAlert(title: "Name for new list empty", message: "Name for a list can't be empty. Add a name with one ", closeButtonTitle: "Close", onCancel: { print("empty name") })
            } else {
                let user = Auth.auth().currentUser
                if let user = user {
                    let uid = user.uid
                    var ref: DocumentReference? = nil
                    let data = [
                        "name": self.nameTextField.text!,
                        "dateCreated":Date(),
                        "user": uid,
                        "products": []
                        ] as [String : Any]
                    ref = Firestore.firestore().collection("lists").addDocument(data: data){
                        err in
                        if let err = err {
                            print("Error adding list: \(err)")
                            self.newListButton.isHidden = false
                            
                        } else {
                            self.listName = self.nameTextField.text!
                            self.showAlert(title: "List added", message: "The new list " + self.listName + " was created", closeButtonTitle: "close", onCancel: { self.dismiss(animated: true, completion: nil) })
                            self.navigationController?.popViewController(animated: true)
                            print("New list added added with ID: \(ref!.documentID)")
                            
                        }

                    }
                }
            }
            self.newListButton.isHidden = false
        } else {
            self.showAlert(title: "No internet connection detected", message: "Please check your internet or mobile data connection, then you will be able to add a new list", closeButtonTitle: "ok", onCancel: {})
        }
    }
    
    // function to show alerts in case there is no input in textfields
    func showAlert(title: String, message: String, closeButtonTitle: String, onCancel: @escaping () -> ()){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: closeButtonTitle, style: .default, handler: {(action: UIAlertAction) in
            onCancel()
            
        })
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    @IBAction func cancelNewList(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
        
 }
    

    
 
