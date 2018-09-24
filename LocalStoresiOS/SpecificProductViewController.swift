//
//  SpecificProductViewController.swift
//  LocalStoresiOS
//
//  Created by David Mauricio Delgado Ruiz on 14/11/17.
//  Copyright © 2017 Juan Murillo. All rights reserved.
//

import UIKit
import Firebase
class SpecificProductViewController: UIViewController {

    @IBOutlet weak var specificProductLabel: UILabel!
    
    var product: Product?
    var listViewController: ListViewController?
    var tableView: UITableView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        specificProductLabel.text = product?.name
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func dismissSpecificProductView(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func deleteProductFromList(_ sender: Any) {

        //listViewController?.deleteProductFromList(product!)
        deleteSpecificProductFromListBackend()
        //tableView?.reloadData()
        //listViewController?.viewWillAppear(true);
        print("calls delete product from list")
        
    }
    
    func deleteSpecificProductFromListBackend() {
        // deletes from database
        
        var newRawProducts: Dictionary<String, AnyObject> = [String: AnyObject]()
        
        for product in (product?.rawProducts!)! {
            newRawProducts.updateValue(product.value, forKey: product.key)
        }
        
        newRawProducts.removeValue(forKey: (product?.barcode)!)
        
        Firestore.firestore().collection("lists").document((product?.listIDFirebase)!).updateData([
            "products": newRawProducts
        ]) { err in
            if let err = err {
                self.showAlert(title: "Error deleting product", message: "Error deleting product from list. Please try again", closeButtonTitle: "Ok", onCancel: {})
                print("Error deleting product from list: \(err)")
            } else {
                self.showAlert(title: "Product deleted", message: "Product successfully deleted from list", closeButtonTitle: "Ok", onCancel: {
                    self.dismiss(animated: true, completion: nil)
                })
                print("Product successfully deleted from list")
                
            }
        }
        print("deletes product from list")
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
