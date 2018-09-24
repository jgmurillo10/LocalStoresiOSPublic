//
//  OptimizationResultsViewController.swift
//  LocalStoresiOS
//
//  Created by David Mauricio Delgado Ruiz on 4/12/17.
//  Copyright © 2017 Juan Murillo. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation
class OptimizationResultsViewController: UIViewController, UITableViewDelegate,  UITableViewDataSource {

    @IBOutlet weak var totalNumbersLabel: UILabel!
    @IBOutlet weak var resultsTableView: UITableView!
    @IBOutlet weak var resultsSpinner: UIActivityIndicatorView!
    var productsObjArray: [Product] = []
    var optimizedResults: [DocumentSnapshot] = []
    let defaults = UserDefaults.standard
    var totalPrice: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        resultsTableView.delegate = self
        resultsTableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        totalPrice = 0
        resultsSpinner.startAnimating()
        resultsTableView.isHidden = true
        // clean the array so no duplicates appear when data comes from Firebase
        optimizedResults = []
        var optimizationPreference: String = defaults.string(forKey: "optimizationPreference")!
        print("optimization preference is: " + optimizationPreference)
        if optimizationPreference == "money" {
            print("enters money optimization")
            optimizationPreference = "price"
            
            for productObj in productsObjArray {
                Firestore.firestore().collection("flat-stores").whereField("name", isEqualTo: productObj.name).order(by: optimizationPreference, descending: true).limit(to: 1)
                    .getDocuments() { (querySnapshot, err) in
                        
                        if let err = err {
                            print("Error getting documents: \(err)")
                        } else {
                            for document in querySnapshot!.documents {
                                self.optimizedResults.append(document)
                                self.totalPrice = self.totalPrice + (document.data()["price"] as! Int)
                                print("\(document.documentID) => \(document.data())")
                            }
                            self.totalNumbersLabel.text! = String(self.totalPrice)
                            self.resultsTableView.reloadData()
                            self.resultsTableView.isHidden = false
                            self.resultsSpinner.stopAnimating()
                        }
                }
            }
        }
        else if optimizationPreference == "distance" {
            print("enters distance optimization")
            optimizationPreference = "price"
            for productObj in productsObjArray {
                Firestore.firestore().collection("flat-stores").whereField("name", isEqualTo: productObj.name).order(by: optimizationPreference, descending: true).limit(to: 1)
                    .getDocuments() { (querySnapshot, err) in
                        
                        if let err = err {
                            print("Error getting documents: \(err)")
                        } else {
                            for document in querySnapshot!.documents {
                                self.optimizedResults.append(document)
                                self.totalPrice = self.totalPrice + (document.data()["price"] as! Int)
                                print("\(document.documentID) => \(document.data())")
                            }
                            
                            for result in self.optimizedResults {
                                let fgp: GeoPoint = result.data()["geo"] as! GeoPoint
                                let storeLocation: CLLocation = CLLocation(latitude: fgp.latitude,longitude: fgp.longitude)
                                let currentLocation: CLLocation = CLLocation(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
                                
                                let distance: Double = storeLocation.distance(from: currentLocation)
                                let distanceAsInt: Int = Int(distance)
                                if distanceAsInt > (GlobalPreferences.sharedInstance.maxRadius! * 1000)  {
                                    self.optimizedResults.remove(at: self.optimizedResults.index(of: result)!)
                                }

                            }
                            self.totalNumbersLabel.text! = String(self.totalPrice)
                            self.resultsTableView.reloadData()
                            self.resultsTableView.isHidden = false
                            self.resultsSpinner.stopAnimating()
                        }
                }
            }
        }
        else {}
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return optimizedResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = resultsTableView.dequeueReusableCell(withIdentifier: "resultCell")!
        let store: String = optimizedResults[indexPath.row].data()["place"] as! String
        let product: String = optimizedResults[indexPath.row].data()["name"] as! String
        let priceNumber = optimizedResults[indexPath.row].data()["price"] as! Int
        print(type(of: priceNumber))
        var price: String = String(describing: priceNumber)
        price = price.replacingOccurrences(of: "Optional(", with: "")
        price = price.replacingOccurrences(of: ")", with: "")
        cell.textLabel!.text = product + " at " + store + ": $" + price
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func viewStoresInMapPressed(_ sender: Any) {
        if currentReachabilityStatus != .notReachable {
            if checkGPSPermission() == 1 {
                self.performSegue(withIdentifier: "OptiResultsMapSegue", sender: optimizedResults)
            }
            else {
                 self.showAlert(title: "Local Stores has no permission to know your location", message: "Please check GPS/location app permissions.Then, try again to visualize the map with the stores", closeButtonTitle: "ok", onCancel:  {})
            }
            
            
        } else {
            self.showAlert(title: "No Internet connection found", message: "Please check mobile data connection. Then, try again to visualize the map with the stores", closeButtonTitle: "ok", onCancel:  {})
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "OptiResultsMapSegue" {
            let viewController : OptiResultsMapViewController = segue.destination as! OptiResultsMapViewController
            viewController.results = sender as! [DocumentSnapshot]
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
