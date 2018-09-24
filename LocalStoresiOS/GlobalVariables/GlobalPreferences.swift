//
//  GlobalPreferences.swift
//  LocalStoresiOS
//
//  Created by David Mauricio Delgado Ruiz on 4/11/17.
//  Copyright © 2017 Juan Murillo. All rights reserved.


import Foundation

class GlobalPreferences {
    var optimizationPreference: String?
    var maxRadius: Int?
    static let sharedInstance = GlobalPreferences()
    private init() {
        optimizationPreference = "money"
        maxRadius = 400
    }
}

