//
//  Product.swift
//  LocalStoresiOS
//
//  Created by Juan Murillo on 8/10/17.
//  Copyright © 2017 Juan Murillo. All rights reserved.
// change

import UIKit

class Product: NSObject {
    var barcode: String!
    var name: String!
    var prices: [String: Any]?
    var imagen: String?
    var listIDFirebase: String?
    //var rawProducts: Dictionary<String, AnyObject> = [String: AnyObject]()
    var rawProducts: Dictionary<String, AnyObject>?
    
    override init() {
        super.init()
    }
    convenience init(_ dictionary: Dictionary<String, AnyObject>) {
        self.init()
        barcode = dictionary["barcode"] as! String
        name = dictionary["name"] as! String
        imagen = dictionary["imagen"] as? String
        prices = dictionary["prices"] as? [String:Any]
    }
    
    func setListID(_ newListAID: String) {
        self.listIDFirebase = newListAID
    }
    
    func setRawProductsOfContainerList(_ dictionary: Dictionary<String, AnyObject>) {
        rawProducts = dictionary
    }

}
