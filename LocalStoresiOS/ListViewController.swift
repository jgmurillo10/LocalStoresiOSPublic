//
//  ListViewController.swift
//  LocalStoresiOS
//
//  Created by Juan Murillo on 9/10/17.
//  Copyright © 2017 Juan Murillo. All rights reserved.
//

import UIKit
import Firebase
class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var productsTableView: UITableView!
    @IBOutlet weak var labelName: UILabel!
    var selectedList: DocumentSnapshot!
    var rawProducts: Dictionary<String, AnyObject> = [String: AnyObject]()
    var products: [String] = []
    var productsIds: [String] = []
    var productsObjArray: [Product] = []
    @IBOutlet weak var deleteList: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        productsTableView.delegate = self
        productsTableView.dataSource = self
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        productsObjArray = []
        print("will appear is called")
        labelName.text = selectedList.data()["name"] as? String
        let listIDFirebase = selectedList.documentID as String
        print("list firebase ID: " + listIDFirebase)
        productsTableView.isHidden = true
        let user = Auth.auth().currentUser
        if let user  = user {
            let uid = user.uid
            print("userid : \(uid)")
            Firestore.firestore().collection("lists").document(listIDFirebase).getDocument(completion: { (document, error) in
                if let document = document {
                    print("List data: \(document.data())")
                    if document.data()["products"] != nil {
                        self.rawProducts = self.selectedList.data()["products"] as! Dictionary<String, AnyObject>
                        for product in self.rawProducts {
                            let productData: [String: AnyObject] = [
                                "barcode": product.key,
                                "name": product.value
                                ] as [String : AnyObject]
                            
                            let currentProduct = Product(productData)
                            currentProduct.setListID(listIDFirebase    )
                            self.productsObjArray.append(currentProduct)
                            self.productsTableView.reloadData()
                        }
                        for productObj in self.productsObjArray {
                            productObj.setRawProductsOfContainerList(self.rawProducts)
                        }
                        self.productsTableView.reloadData()
                        self.productsTableView.isHidden = false
                    }
                    
                } else {
                    print("List does not exist")
                }

            })

        }
        
        self.productsTableView.isHidden = false
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return products.count
        return productsObjArray.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //performSegue(withIdentifier: "specificProduct", sender: products[indexPath.row])
        performSegue(withIdentifier: "specificProduct", sender: productsObjArray[indexPath.row])
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "MyProductCell")!
        cell.textLabel!.text = productsObjArray[indexPath.row].name
        //cell.textLabel!.text = products[indexPath.row]
        return cell
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func deleteList(_ sender: Any) {
        if currentReachabilityStatus != .notReachable {
            Firestore.firestore().collection("lists").document(selectedList.documentID).delete() { err in
                let listName: String = self.selectedList.data()["name"] as! String
                if let err = err {
                    print("Error removing list: \(err)")
                    self.showAlert(title: "Error removing list", message: err.localizedDescription +  ". The list " + listName +  " was not removed. Please try again.", closeButtonTitle: "close", onCancel:  {})
                } else {
                    
                    self.showAlert(title: "List removed", message: "The list " + listName + " was successfuly removed.", closeButtonTitle: "close", onCancel: { self.dismiss(animated: true, completion: nil) })
                    print("List successfully removed!")
                }
            }
        } else {
            self.showAlert(title: "No Internet connection found", message: "Please check mobile data connection. Then, try to delete the list again.", closeButtonTitle: "ok", onCancel:  {})
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "specificProduct" {
            let targetController: SpecificProductViewController = segue.destination as! SpecificProductViewController
            targetController.product = sender as? Product
            targetController.tableView = self.productsTableView
            targetController.listViewController = self
        }
        else if segue.identifier == "optimizationResults" {
            let targetController2: OptimizationResultsViewController = segue.destination as! OptimizationResultsViewController
            targetController2.productsObjArray = self.productsObjArray
            
        } else {}
        
        
    }
    
    func deleteProductFromList(_ product: Product) {
        // deletes from database
        
        var newRawProducts: Dictionary<String, AnyObject> = [String: AnyObject]()
        
        for product in rawProducts {
            newRawProducts.updateValue(product.value, forKey: product.key)
        }
        
        newRawProducts.removeValue(forKey: product.barcode)
        
        Firestore.firestore().collection("lists").document(selectedList.documentID).updateData([
            "products": newRawProducts
        ]) { err in
            if let err = err {
                self.showAlert(title: "Error deleting product", message: "Error deleting product from list. Please try again", closeButtonTitle: "Ok")
                print("Error deleting product from list: \(err)")
            } else {
                self.showAlert(title: "Product deleted", message: "Product successfully deleted from list", closeButtonTitle: "Ok")
                print("Product successfully deleted from list")
            }
        }
        print("deletes product from list")
        
        //rawProducts = newRawProducts
        
        //productsTableView.reloadData()
    }
    
    // changes the datasource for the product table view
    func updateProductTableView(_ newVersionOfRawProducts: Dictionary<String, AnyObject>) {
        self.rawProducts = newVersionOfRawProducts
    }
    
    // function to show alerts in case there is no input in textfields
    func showAlert(title: String, message: String, closeButtonTitle: String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: closeButtonTitle, style: .default, handler: {(action: UIAlertAction) in})
        
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: {})
    }
   
    @IBAction func optimizeList(_ sender: Any) {
        if currentReachabilityStatus != .notReachable {
            performSegue(withIdentifier: "optimizationResults", sender: self)
        } else {
            self.showAlert(title: "No Internet connection found", message: "Please check mobile data connection. Then, try to optimize the list again.", closeButtonTitle: "ok", onCancel:  {})
        }
        
    }
    
    
    
    @IBAction func dismissView(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
}

