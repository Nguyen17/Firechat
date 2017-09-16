//
//  UIView+Extension.swift
//  Firechat
//
//  Created by Amanuel Ketebo on 9/10/17.
//  Copyright © 2017 Krevalent. All rights reserved.
//

import Foundation
import UIKit

extension UIView
{
    func fadeIn(duration: TimeInterval)
    {
        self.alpha = 0
        
        UIView.animate(withDuration: duration) {
            self.alpha = 1
        }
    }
    
    func fadeOut(duration: TimeInterval)
    {
        UIView.animate(withDuration: duration) {
            self.alpha = 0
        }
    }
}
