//
//  MaxLengthTextFields.swift
//  LocalStoresiOS
//
//  Created by David Mauricio Delgado Ruiz on 15/11/17.
//  Copyright © 2017 Juan Murillo. All rights reserved.
//

import Foundation
import UIKit
private var maxLengths = [UITextField: Int]()

// 2
extension UITextField {
    
    // 3
    @IBInspectable var maxLength: Int {
        get {
            // 4
            guard let length = maxLengths[self] else {
                return Int.max
            }
            return length
        }
        set {
            maxLengths[self] = newValue
            // 5
            addTarget(
                self,
                action: #selector(limitLength),
                for: UIControlEvents.editingChanged
            )
        }
    }
    
    func limitLength(textField: UITextField) {
        // 6
        guard let prospectiveText = textField.text, prospectiveText.characters.count > maxLength else {
                return
        }
        
        let selection = selectedTextRange
        // 7
        text = prospectiveText.substring(with:
            Range<String.Index>(prospectiveText.startIndex ..< prospectiveText.startIndex.advanced(by: maxLength))
        )
        selectedTextRange = selection
    }
    
}
