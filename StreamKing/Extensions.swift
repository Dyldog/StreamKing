//
//  Extensions.swift
//  StreamKing
//
//  Created by ELLIOTT, Dylan on 5/5/18.
//  Copyright © 2018 Dylan Elliott. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func alert(title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
