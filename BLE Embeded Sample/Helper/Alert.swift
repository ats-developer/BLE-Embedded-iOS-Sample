//
//  Alert.swift
//  AtharvaSystem
//
//  Created by AtharvaSystem on 08/01/19.
//  Copyright © 2018 AtharvaSystem. All rights reserved.
//

import Foundation
import UIKit

typealias alertAction = (UIAlertAction) -> ()

func showAlertWithTwoButton(title: String, msg: String, btn1Title: String, btn2Title: String, btn1Handler: @escaping alertAction, vc: UIViewController?) {
    
    let controller = UIAlertController(title: title, message: msg, preferredStyle: UIAlertController.Style.alert)
    let okAction = UIAlertAction(title: btn1Title, style: UIAlertAction.Style.default, handler: btn1Handler)
    let cancelAction = UIAlertAction(title: btn2Title, style: UIAlertAction.Style.cancel, handler: nil)
    
    controller.addAction(okAction)
    controller.addAction(cancelAction)
    
    if vc != nil {
        vc!.present(controller, animated: true, completion: nil)
    } else {
        if let rootVC = UIApplication.shared.keyWindow?.rootViewController {
            rootVC.present(controller, animated: true, completion: nil)
        }
    }
}

func showAlert(_ message: String, title: String = STREMPTY, vc: UIViewController?) {
    // run following code on main thread
    DispatchQueue.main.async {
        // create alert
        let alert = UIAlertController(title:title, message:message, preferredStyle:.alert)
        
        // add action
        alert.addAction(UIAlertAction(title:kDismiss, style:.cancel, handler:nil))
        
        if vc != nil {
            vc!.present(alert, animated: true, completion: nil)
        } else {
            // get the root view and show alert on it, in case sender is nil
            if let controller = UIApplication.shared.windows[0].rootViewController {
                if controller is UINavigationController {
                    let nav = controller as! UINavigationController
                    nav.visibleViewController?.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
}
