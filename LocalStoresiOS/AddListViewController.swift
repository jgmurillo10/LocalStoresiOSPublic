//
//  AddListViewController.swift
//  LocalStoresiOS
//
//  Created by Juan Murillo on 5/12/17.
//  Copyright © 2017 Juan Murillo. All rights reserved.
//

import UIKit
import Firebase
class AddListViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    var selectedProduct : DocumentSnapshot!
    var userLists: [DocumentSnapshot] = []
    @IBOutlet weak var picker: UIPickerView!
    var pickerData:[String] = [String]()
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    var collectionRef: CollectionReference!
    var db: Firestore!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.picker.isHidden = true
        self.picker.delegate = self
        self.picker.dataSource = self
        startSpinner()
        //setup cloud firestore
        db = Firestore.firestore()
        requestLists()
    }
    func startSpinner() {
        picker.isHidden = true
        spinner.isHidden = false
        spinner.startAnimating()
    }
    func stopSpinner(){
        picker.isHidden = false
        spinner.stopAnimating()
        spinner.isHidden=true
    }
    func reloadPickerData(){
        pickerData = [String]()
        for list in self.userLists {
            pickerData.append((list["name"] as? String)!)
        }
        print(pickerData)
    }
    func requestLists(){
        let user = Auth.auth().currentUser
        if let user  = user {
            let uid = user.uid
            print("userid : \(uid)")
            Firestore.firestore().collection("lists").whereField("user", isEqualTo: uid)
                .getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        self.present(UIAlertController().showAlert(title: "Error", message: "Error showing the lists", acceptButtonTitle: "Accept", closeButtonTitle: "Close", onCancel: {}, onAccept: {}), animated: true, completion: nil)
                    } else {
                        self.userLists = querySnapshot!.documents
                        self.reloadPickerData()
                        self.picker.reloadAllComponents()
                        self.stopSpinner()
                    }
            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func cancelTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addTapped(_ sender: Any) {
        let i = picker.selectedRow(inComponent: 0)
        let list = userLists[i]
        let id = list["id"] as? String
        let barcode : String = (selectedProduct["barcode"] as? String)!
        let name : String = (selectedProduct["name"] as? String)!
        var products = list["products"] as! [String: Any]
        products[barcode] = name
        if let id = id {
            db.collection("lists").document(id).updateData([
                "products": products
                ])
            { err in
                if let err = err {
                    print("Error adding document: \(err)")
                    let alert = UIAlertController().showAlert(title: "Error adding product", message: "Product \(name) was not added to the list \((list["name"] as? String)!)", acceptButtonTitle: "Accept", closeButtonTitle: "Close", onCancel: {}, onAccept: {})
                    self.present(alert, animated: true, completion: nil)
                } else {
                    let alert = UIAlertController().showAlert(title: "Product added", message: "Product \(name) added succesfully to the list \((list["name"] as? String)!)", acceptButtonTitle: "Accept", closeButtonTitle: "Close", onCancel: {}, onAccept: {
                        self.navigationController?.popViewController(animated: true)
                    })
                    self.present(alert, animated: true, completion: nil)
                    self.navigationController?.popViewController(animated: true)
                }
            }
        } else {
            let alert = UIAlertController().showAlert(title: "Error adding product", message: "Product \(name) was not added to the list", acceptButtonTitle: "Accept", closeButtonTitle: "Close", onCancel: {}, onAccept: {})
            self.present(alert, animated: true, completion: nil)
            return
        }
        
       
    }
    
}
