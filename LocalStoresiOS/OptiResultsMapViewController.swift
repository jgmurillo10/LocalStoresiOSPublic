//
//  OptiResultsMapViewController.swift
//  LocalStoresiOS
//
//  Created by David Mauricio Delgado Ruiz on 4/12/17.
//  Copyright © 2017 Juan Murillo. All rights reserved.
//

import UIKit
import GoogleMaps
import Firebase
class OptiResultsMapViewController: UIViewController {
    var results : [DocumentSnapshot] = []
    var points : [GeoPoint] = []
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
    func CGSizeMake(_ width: CGFloat, _ height: CGFloat) -> CGSize {
        return CGSize(width: width, height: height)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var camera = GMSCameraPosition.camera(withLatitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude, zoom: 15)
        mapView.camera = camera
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        for res in results {
            drawMarker(selectedProduct: res)
            let point: GeoPoint = res["geo"] as! GeoPoint
            points.append(point)
        }
        camera = GMSCameraPosition.camera(withLatitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude, zoom: 8)
        mapView.camera = camera
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    func getMarker(lat: Double, lon: Double, title: String, snippet: String) -> GMSMarker{
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        marker.title = title
        marker.snippet = snippet
        return marker
    }
    func drawMarker(selectedProduct: DocumentSnapshot){
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
    
    @IBAction func goButtonTapped(_ sender: Any) {
        if currentReachabilityStatus == .notReachable {
            self.present(UIAlertController().showAlert(title: "Error in connection", message: "Error in yout network status. Check you have mobile network or wifi connection.", acceptButtonTitle: "Accept", closeButtonTitle: "Close", onCancel: {}, onAccept: {}), animated: true, completion: nil)
            return
        }
        var query : String = "https://www.google.com/maps/dir"
       
        for point in points {
            query += "/\(point.latitude),\(point.longitude)"
        }
        
        if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
            UIApplication.shared.openURL(URL(string:query)!)
        } else {
            self.present(UIAlertController().showAlert(title: "Error", message: "Can't use Google Maps on this device. Please, install it to see the route", acceptButtonTitle: "Accept", closeButtonTitle: "Close", onCancel: {}, onAccept: {}), animated: true, completion: nil)
            NSLog("Can't use Google Maps on this device.")
        }
    }
}
