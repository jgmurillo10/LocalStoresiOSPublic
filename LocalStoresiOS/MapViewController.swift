//
//  MapViewController.swift
//  LocalStoresiOS
//
//  Created by Juan Murillo on 3/10/17.
//  Copyright © 2017 Juan Murillo. All rights reserved.
//

import UIKit
import Firebase
import GoogleMaps
import CoreLocation
var userLocation: CLLocation!
class MapViewController: UIViewController, CLLocationManagerDelegate {
    var locationManager: CLLocationManager = CLLocationManager()
    @IBOutlet weak var viewContentMap: GMSMapView!
    @IBOutlet weak var searchProductButton: UIButton!
    var counter : Int8 = 30
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        userLocation = nil
       
        view.addSubview(searchProductButton)
        view.bringSubview(toFront: searchProductButton)
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let latestLocation : CLLocation  = locations[locations.count - 1]
        if userLocation == nil {
            userLocation = latestLocation
            loadMap()
        }
        else {
            userLocation = latestLocation
            updateMap()
        }
    }
    func updateMap() {
        print(counter)
        if counter == 0 {
            let camera: GMSCameraPosition = GMSCameraPosition.camera(withLatitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude, zoom: 16)
            viewContentMap.camera = camera
            counter = 30
        } else {
            counter-=1
        }
        
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.showAlert(title: "GPS Error", message: "An error occurred getting your current location, Please make sure your GPS is active, working and that you allowed our app to use your location. If you did not allow the app to use the GPS you have to do manually in Settings>General>LocalStores and enable the GPS.", closeButtonTitle: "Close")
    }
    func loadMap() {
        let camera = GMSCameraPosition.camera(withLatitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude, zoom: 16)
        viewContentMap.camera = camera
        viewContentMap.settings.myLocationButton = true
        viewContentMap.settings.compassButton = true
        viewContentMap.isMyLocationEnabled = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        locationManager.stopUpdatingLocation()
        print("viewWillDisappear")
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    func showAlert(title: String, message: String, closeButtonTitle: String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: closeButtonTitle, style: .default, handler: {(action: UIAlertAction) in})
        
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: {})
    }
}
