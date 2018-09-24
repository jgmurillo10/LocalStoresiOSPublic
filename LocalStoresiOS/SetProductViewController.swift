//
//  SetProductViewController.swift
//  LocalStoresiOS
//
//  Created by Juan Murillo on 4/10/17.
//  Copyright © 2017 Juan Murillo. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation
import GoogleMaps
class SetProductViewController: UIViewController, CLLocationManagerDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    var textCode: String!
    var exists : Bool!
    var locationManager: CLLocationManager = CLLocationManager()
//    var userLocation: CLLocation!
    // label that shows the code analyzed
    
    
    @IBOutlet weak var labelCode: UILabel!
    // textFields
    @IBOutlet weak var crudButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var storeTextField: UITextField!
    @IBOutlet weak var picker: UIPickerView!
    var pickerData:[String] = [String]()
    @IBOutlet weak var loadingSpinner: UIActivityIndicatorView!
    @IBOutlet weak var container: UIView!
    var timer: Timer!
    var collectionRef: CollectionReference!
    var db: Firestore!
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.isHidden = true
        
        storeTextField.delegate = self
        self.picker.delegate = self
        self.picker.dataSource = self
        
        
        //set up user location
        setUpLocationManager()
        //hides content and move spinner
        startSpinner()
        // Do any additional setup after loading the view.
        //asign label the value of the code reader
        labelCode.text = textCode
        //setup cloud firestore
        db = Firestore.firestore()
        //get the document with the barcode/qrcode
        
        do {
            let docRef: DocumentReference = try getDocumentReferenceByDocumentId(code: textCode)
            docRef.getDocument { (document, error) in
                if let document = document {
                    
                    if document.exists {
                        //  if it exists, assign the labels the actual values, set exists to true and set crubutton title to edit
                        self.handleExistingDocument(document: document)
                    }
                    else {
                        // if the document does not exists, then change the title of the crud button to add and sef exists to false.
                        self.handleUnexistingDocument()
                    }
                }
                self.loadPickerData()
                self.stopSpinner()
            }
            
        } catch let e as ProductsErrors{
            print(e.kind)
            print(e.msg)
        } catch is NSException{
            print("NSException")
        } catch {
            print("Error")
        }
    }
    func loadPickerData(){
        
        let latitude1 = userLocation.coordinate.latitude
        let longitude1 = userLocation.coordinate.longitude
        let coordinate0 = CLLocation(latitude: latitude1, longitude: longitude1)
        db.collection("flat-stores").getDocuments() { (querySnapshot,err) in
            if let err = err {
                print("Error \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let p : GeoPoint = document["geo"] as! GeoPoint
                    let coordinate1 = CLLocation(latitude: p.latitude, longitude: p.longitude)
                    let distance = coordinate0.distance(from: coordinate1)
                    //print(distance)
                    //print("user defaults \(UserDefaults.standard.double(forKey: "distance"))")
                    if distance < UserDefaults.standard.double(forKey: "distance") {
                        print("inner if")
                        self.pickerData.append(document["place"] as! String)
                    }
                }
                
                if self.pickerData.count == 0 {
                    self.pickerData.append("No stores near you, change preferences")
                }
                self.picker.reloadAllComponents()
            }
        }
        
    }
    func setUpLocationManager(){
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        userLocation = nil
    }
    func startSpinner(){
        container.isHidden = true
        loadingSpinner.startAnimating()
    }
    func stopSpinner(){
        loadingSpinner.stopAnimating()
        container.isHidden = false
    }
    func handleExistingDocument(document: DocumentSnapshot){
        let currentProduct : Product = Product(document.data() as Dictionary<String, AnyObject>)
        self.nameTextField.text = currentProduct.name
        self.nameTextField.isEnabled = false
        if currentProduct.prices != nil {
            //                            let index = currentProduct.prices?.startIndex.advancedBy(0)
            let key = Array(currentProduct.prices!.keys)[0]
            self.storeTextField.text = key
            self.pickerData.append(key)
            self.picker.reloadAllComponents()
            let dict : Dictionary<String, AnyObject> = currentProduct.prices![key] as! Dictionary<String, AnyObject>
            let price = dict["price"]
            self.priceTextField.text = price as? String
        }
        self.exists = true
        self.crudButton.setTitle("edit", for: .normal)
    }
    func handleUnexistingDocument(){
        self.exists = false
        self.crudButton.setTitle("add", for: .normal)
        self.nameTextField.isEnabled = true
    }
    // function that gets the document reference by document id
    func getDocumentReferenceByDocumentId(code: String) throws -> DocumentReference {
        guard let doc = db.collection("products").document(code) as DocumentReference? else {
            throw ProductsErrors(msg: "Error in the product ID", kind: .invalidCode)
        }
        return doc
    }
    //function to hide keyboard on touch outside the keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //function to crud the product
    func persistProduct(name: String, store: String, price: String, latitude: CLLocationDegrees, longitude: CLLocationDegrees){
        let geo = GeoPoint(latitude: latitude, longitude: longitude)
        // Add a new document or update an existing document in collection "products"
        db.collection("products").document(textCode).setData([
            "barcode": textCode,
            "name": name,
            "prices": [store : [ "geo": geo, "price": Double(price) ?? 0 ]  ]
        ]) { err in
            
            if let err = err {
                self.showAlertWithTitle(title: "Error updating product", message: "The product was not updated due to error:  \(err)")
                
            } else {
                self.showAlert(title: "Product updated succesfully", message: "Product \(name) updated", closeButtonTitle: "OK", onCancel: {self.navigationController?.popViewController(animated: true)})
                
                
                
                
            }
        }
    }
    func showAlertWithTitle(title: String, message: String){
        let alertVC = UIAlertController(title: title,message: message, preferredStyle: .alert )
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alertVC.addAction(okAction)
        
        DispatchQueue.main.async {
            self.present(alertVC, animated: true, completion: nil)
        }
    }
    @IBAction func addTapped(_ sender: Any) {
        if currentReachabilityStatus == .notReachable {
            showAlertWithTitle(title: "Error", message: "You do not have internet connection, you can't edit or add products without internet. Please check your mobile or wifi network.")
            return
        }
        let lat = userLocation.coordinate.latitude
        let lon = userLocation.coordinate.longitude
        guard let nameText = nameTextField.text, !nameText.isEmpty else {
            self.showAlertWithTitle(title: "Error", message: "Product name must not be empty.")
            return
        }
        guard let priceText = priceTextField.text, !priceText.isEmpty else {
            self.showAlertWithTitle(title: "Error", message: "Product price must not be empty.")
            return
        }
        if priceText.count > 6 {
            self.showAlertWithTitle(title: "Error", message: "Price must not be more than 999999")
            return
        }
        guard let storeText  = storeTextField.text, !storeText.isEmpty else {
            self.showAlertWithTitle(title: "Error", message: "Product store must not be empty.")
            return
        }
        persistProduct(name: nameText, store: storeText, price: priceText, latitude: lat, longitude: lon)
        
        
       
    }
    //function to cancel the crud process
    @IBAction func cancelButtonTapped(_ sender: Any) {
        _ = navigationController?.popViewController(animated: true)
    }
    //function to change the current user location every time the user change its coordinates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let latestLocation: CLLocation = locations[locations.count - 1]
        userLocation = latestLocation
        
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)  {
        self.showAlertWithTitle(title: "Error", message: "There are no GPS permissions. Enable the GPS permission in Settings/General/LocalStores")
        self.dismiss(animated: true, completion: nil)
        return
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentCharacterCount = nameTextField.text?.characters.count ?? 0
        if (range.length + range.location > currentCharacterCount){
            return false
        }
        let newLength = currentCharacterCount + string.characters.count - range.length
        return newLength <= 20
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.storeTextField.isHidden = false
        self.crudButton.isHidden = false
        self.cancelButton.isHidden = false
        self.picker.isHidden = true
        self.storeTextField.text = pickerData[row]
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.storeTextField.isHidden = true
        self.crudButton.isHidden = true
        self.cancelButton.isHidden = true
        self.picker.isHidden = false
        return false
        
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
    
}
