//
//  ResultsViewController.swift
//  LocalStoresiOS
//
//  Created by Juan Murillo on 8/10/17.
//  Copyright © 2017 Juan Murillo. All rights reserved.
//

import UIKit
import Firebase
import GoogleMaps
import CoreLocation
var productLocation: CLLocation!
class ResultsViewController: UIViewController, CLLocationManagerDelegate {
    var selectedProduct : DocumentSnapshot!
    var locationManager: CLLocationManager = CLLocationManager()
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var buttonGo: UIButton!
    override func viewWillAppear(_ animated: Bool) {
        buttonGo.layer.cornerRadius = 0.5 * buttonGo.bounds.size.width
        buttonGo.clipsToBounds = true
        buttonGo.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        buttonGo.layer.shadowOffset = CGSizeMake(0.0, 2.0)
        buttonGo.layer.shadowOpacity = 1.0
        buttonGo.layer.shadowRadius = 0.0
        buttonGo.layer.masksToBounds = false
        view.addSubview(buttonGo)
        view.bringSubview(toFront: buttonGo)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // if selectedProduct is not nil then we show the marker for each store
        setUpLocationManager()
        loadMap()
        //draw map with markers
        if selectedProduct != nil {
            drawMarker()
        }
        updateMap()
        // Do any additional setup after loading the view.
    }
    func setUpLocationManager() {
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    func loadMap() {
        
        // Create a GMSCameraPosition that tells the map to display the
        // coordinate -33.86,151.20 at zoom level 6.
        let camera = GMSCameraPosition.camera(withLatitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude, zoom: 15)
        mapView.camera = camera
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        
    }
    func updateMap() {
        let point: GeoPoint = selectedProduct["geo"] as! GeoPoint
        let camera = GMSCameraPosition.camera(withLatitude: point.latitude, longitude: point.longitude, zoom: 15)
        mapView.camera = camera
   }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let latestLocation : CLLocation  = locations[locations.count - 1]
        if userLocation == nil {
            userLocation = latestLocation
            loadMap()
        }
        if selectedProduct == nil {
            userLocation = latestLocation
        }
    }
    func getMarker(lat: Double, lon: Double, title: String, snippet: String) -> GMSMarker{
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        marker.title = title
        marker.snippet = snippet
        return marker
    }
    func drawMarker(){
        let point: GeoPoint = selectedProduct["geo"] as! GeoPoint
        let place: String = (selectedProduct["place"] as? String)!
        var price :String!
        price = String(describing: selectedProduct["price"] as! Int)
        let name: String = (selectedProduct["name"] as? String)!
        let a: CLLocation = CLLocation(latitude: userLocation.coordinate.latitude,longitude: userLocation.coordinate.longitude)
        let b: CLLocation = CLLocation(latitude: point.latitude,longitude: point.longitude)
        let distance = a.distance(from: b)
        let snippet: String = "$\(price as! String)  COP  \n \(place) \n \(Double(round(1000*distance)/1000))m"
        let marker:GMSMarker = getMarker(lat: point.latitude, lon: point.longitude, title: name, snippet: snippet  )
        marker.map = mapView
        mapView.selectedMarker = marker
    }
    func CGSizeMake(_ width: CGFloat, _ height: CGFloat) -> CGSize {
        return CGSize(width: width, height: height)
    }
    
    @IBAction func buttonGoTapped(_ sender: Any) {
        if currentReachabilityStatus == .notReachable {
            self.present(UIAlertController().showAlert(title: "Error in connection", message: "Error in yout network status. Check you have mobile network or wifi connection.", acceptButtonTitle: "Accept", closeButtonTitle: "Close", onCancel: {}, onAccept: {}), animated: true, completion: nil)
            return
        }
        let point: GeoPoint = self.selectedProduct["geo"] as! GeoPoint
        if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
            UIApplication.shared.openURL(URL(string:"https://www.google.com/maps/dir/?api=1&origin=\(userLocation.coordinate.latitude),\(userLocation.coordinate.longitude)&destination=\(point.latitude),\(point.longitude)")!)
        } else {
            self.present(UIAlertController().showAlert(title: "Error", message: "Can't use Google Maps on this device. Please, install it to see the route", acceptButtonTitle: "Accept", closeButtonTitle: "Close", onCancel: {}, onAccept: {}), animated: true, completion: nil)
            NSLog("Can't use Google Maps on this device.")
        }
    }
    @IBAction func showInfo(_ sender: Any) {
        self.present(UIAlertController().showAlert(title: "Info", message: "Here you can visualize the current location of the product/products. Tap 'go' to get the route to your product with Google Maps. Also tap on the marker to get additional info", acceptButtonTitle: "Accept", closeButtonTitle: "Close", onCancel: {}, onAccept: {}), animated: true, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
