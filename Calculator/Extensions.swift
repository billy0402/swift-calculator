//
//  Extensions.swift
//  Calculator
//
//  Created by User on 2019/7/18.
//  Copyright © 2019 User. All rights reserved.
//

import Foundation
import UIKit

extension String {
    
    var isNumber: Bool {
        return self.allSatisfy { $0.isNumber || $0 == "." || $0 == "E" }
    }
    
}

extension Decimal {
    
    var isComputable: Bool {
        return isNormal || isZero
    }
    
    var pointCount: Int {
        return max(-exponent, 0)
    }
    
}

extension Array where Element: Equatable {
    
    func indexes(of element1: Element, or element2: Element) -> Array<Int> {
        return enumerated().compactMap {
            $0.element == element1 || $0.element == element2 ? $0.offset : nil
        }
    }
    
}

extension UILabel {
    
    func getMaxTextLength() -> Int {
        let attributes = [NSAttributedString.Key.font: self.font]
        let fontWidth = "0".size(withAttributes: attributes as [NSAttributedString.Key: Any]).width
        let labelWidth = self.bounds.width
        
        return Int(labelWidth / fontWidth)
    }
    
}
