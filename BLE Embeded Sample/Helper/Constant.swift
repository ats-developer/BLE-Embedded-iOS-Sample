//
//  Constant.swift
//  BLE Embeded Sample
//
//  Created by AtharvaSystem on 08/01/19.
//  Copyright © 2019 AtharvaSystem. All rights reserved.
//

import Foundation
import UIKit

let APPDELEGATE = UIApplication.shared.delegate as! AppDelegate

// MARK: - Common - Keywords

let kYES        = "YES"
let kNO         = "NO"
let kDismiss    = "Dismiss"
let CANCEL      = "Cancel"
let CONNECT     = "Connect"

// MARK: - STRINGS

let STREMPTY    = ""
let STRSPACE    = " "
let NEWLINE     = "\n"

//MARK: - BLE Messages -

let TITLESCAN              = "SCAN"
let TITLESTOP              = "STOP"
let TITLEBLEDEVICELIST     = "BLE DEVICES"
let TITLEDEVICEDISCONNECT  = "Device Disconnected"
let CLOSEREMOTE            = "Close"
let GOTIT                  = "Ok, Got it."

let STRCONNECTED           = "Your device connected successfully. Now send command to recieve response from your device."
let MSGNODEVICE            = "No device found to connect. Please try again."
let MSGNOBLUETOOTH         = "Your bluetooth is turned off. Please turn on it."
let MSGUNABLETOCONNECT     = "Failed to connect this device. Please try again."
let MSGRECONNECTDEVICE     = "Your device is disconnected. Please connect it again."
