//
//  Product.swift
//  LocalStoresiOS
//
//  Created by Juan Murillo on 8/10/17.
//  Copyright © 2017 Juan Murillo. All rights reserved.
// change

import UIKit

class List: NSObject {
    var name: String!
    var products: [String: Any]?
    var dateCreated: Date!
    
    override init() {
        super.init()
    }
    convenience init(_ dictionary: Dictionary<String, AnyObject>) {
        self.init()
        name = dictionary["name"] as! String
        products = dictionary["products"] as? [String:Any]
        dateCreated = dictionary["dateCreated"] as! Date
    }
    
    
}

