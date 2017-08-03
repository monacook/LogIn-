//
//  KeyboardScroll.swift
//  Test
//
//  Created by Danielle on 2/23/17.
//  Copyright © 2017 Danielle. All rights reserved.
//

import Foundation
import UIKit


extension UIViewController
{
    
    func hideKeyboard()
    {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard()
    {
        view.endEditing(true)
    }
    
}
