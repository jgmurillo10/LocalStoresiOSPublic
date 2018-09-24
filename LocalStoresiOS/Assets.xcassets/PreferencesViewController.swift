//
//  PreferencesViewController.swift
//  LocalStoresiOS
//
//  Created by Juan Murillo on 3/10/17.
//  Copyright © 2017 Juan Murillo. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class PreferencesViewController: UIViewController {
    
    @IBOutlet weak var userPreferenceSegementedControl: UISegmentedControl!
    @IBOutlet weak var radiusSlider: UISlider!
    @IBOutlet weak var maxRadiusLabel: UILabel!
    
    var userOptimizationPreference: String = "money"
    var userMaxRadiusPreference: Int = 1
    
    var userOptimizationDocumentID: String?
    let defaults = UserDefaults.standard
    
    override func viewWillAppear(_ animated: Bool) {
        // get user preferences from singleton
        if let savedPreference = defaults.string(forKey: "optimizationPreference") {
            userOptimizationPreference = savedPreference
            setSegmentedControlToSavedPreference(preference: userOptimizationPreference)
            changeGlobalUserPreference(preference: userOptimizationPreference)
        }
        else {
            userOptimizationPreference = "money"
            userPreferenceSegementedControl.selectedSegmentIndex = 0;
            defaults.set("money", forKey: "optimizationPreference")
            
        }
        
        let radius = defaults.integer(forKey: "distance")
        userMaxRadiusPreference = radius
        print("user max radius: " + String(userMaxRadiusPreference))
        radiusSlider.value = Float(userMaxRadiusPreference)
        self.maxRadiusLabel.text = String(format:"%.0f",radiusSlider.value) + " km"
        
        defaults.set(radius, forKey: "distance")
        
        print("user Defaults preference: " + defaults.string(forKey: "optimizationPreference")!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    func setSegmentedControlToSavedPreference(preference: String) {
        if preference == "money" {
            userPreferenceSegementedControl.selectedSegmentIndex = 0;
        }
        else {
            userPreferenceSegementedControl.selectedSegmentIndex = 1;
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func changeGlobalUserPreference(preference: String) {
        GlobalPreferences.sharedInstance.optimizationPreference = preference
        //print("In Singleton: " + GlobalPreferences.sharedInstance.optimizationPreference!)
    }
    
    @IBAction func logOutButtonIsPressed(_ sender: UIButton) {
        logOut()
        self.performSegue(withIdentifier: "toLogin", sender: self)
    }
    @IBAction func preferenceSelected(_ sender: Any) {
        switch userPreferenceSegementedControl.selectedSegmentIndex {
        case 0: do {
            // save the change locally
            self.userOptimizationPreference = "money"
            
            // save it in the singleton
            changeGlobalUserPreference(preference: self.userOptimizationPreference)
            
            // save it in user defaults
            defaults.set("money", forKey: "optimizationPreference")
            
            // send change to Firestore
            //Firestore.firestore().collection("user-preferences").document(userOptimizationDocumentID!)
            
            }
        case 1: do{
            // save the change locally
            self.userOptimizationPreference = "distance"
            
            // save it in the singleton
            changeGlobalUserPreference(preference: self.userOptimizationPreference)
            
            // save it in user defaults
            defaults.set("distance", forKey: "optimizationPreference")
            
            // send the change to Firestore
            
            }
        default: break;
        }
        
        
    }
    
    @IBAction func maxRadiusChanged(_ sender: Any) {
        self.maxRadiusLabel.text = String(format:"%.0f",radiusSlider.value) + " km"
        
        // save it in the singleton
        changeGlobalPreferenceRadius(newMaxRadius: radiusSlider.value)
        
        
    }
    
    func changeGlobalPreferenceRadius(newMaxRadius: Float){
        let r = Int(newMaxRadius)
        GlobalPreferences.sharedInstance.maxRadius = r
        userMaxRadiusPreference = r
        //print("In Singleton: " + String(GlobalPreferences.sharedInstance.maxRadius!))
        // save it in user defaults
        UserDefaults.standard.set(r, forKey: "distance")
        print("se guarda en user defaults el nuevo radio: " + String(r))
    }
    
    
    func logOut () -> Bool{
        // [START signout]
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
            return false
            
        }
        return true
        // [END signout]
    }
    
}

