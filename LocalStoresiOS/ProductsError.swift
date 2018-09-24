//
//  ProductsErrors.swift
//  LocalStoresiOS
//
//  Created by Juan Murillo on 6/10/17.
//  Copyright © 2017 Juan Murillo. All rights reserved.
//

struct ProductsErrors: Error {
    enum ErrorKind {
        case invalidCode
        case productNotFound
        case internalError
        case userLocationError
    }
    
    let msg: String
    let kind: ErrorKind
}
