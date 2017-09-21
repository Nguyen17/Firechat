//
//  GradientView.swift
//  Smack
//
//  Created by Joshua Ramos on 8/30/17.
//  Copyright © 2017 Krevalent. All rights reserved.
//

import UIKit

@IBDesignable
class GradientView: UIView {
    
    @IBInspectable var topColor: UIColor = #colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1) {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    @IBInspectable var bottomColor: UIColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1) {
        didSet {
            self.setNeedsLayout()
        }
    }

    // called with set needs layout
    override func layoutSubviews() {
        // CA stands for core animation
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [topColor.cgColor, bottomColor.cgColor]
        
        // top left
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        // bottom right
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        
        // makes gradient same size as view
        gradientLayer.frame = self.bounds
        
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
}
