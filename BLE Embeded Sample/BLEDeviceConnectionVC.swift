//
//  BLEDeviceConnectionVC.swift
//  BLE Embeded Sample
//
//  Created by AtharvaSystem on 08/01/19.
//  Copyright © 2019 AtharvaSystem. All rights reserved.
//

import UIKit
import CoreBluetooth

class BLEDeviceConnectionVC: UIViewController
{
    //MARK: - IBOUTLET/VARIABLE -

    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var txtViewResponse: UITextView!
    @IBOutlet weak var txtCommand: UITextField!
    @IBOutlet weak var btnSend: UIButton!
    
    var controller = UIAlertController() // THIS WILL DISPLAY BLUETOOTH ON ALERT IN CASE OF BLUETOOTH GOES OFF
    var peripherals: [(peripheral: CBPeripheral, RSSI: Float)] = [] // THIS WILL SCAN AND STORE PERIPHERAL DEVICE IN CASE OF BLUETOOTH GOES OFF
    var selectedPeripheral: CBPeripheral? // THIS WILL STORE CONNECTED PERIPHERAL DEVICE IN CASE OF BLUETOOTH GOES OFF
    
    // MARK: - VIEW LIFE CYCLE -
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        serial.delegate = self
        lblMessage.text = STRCONNECTED
        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        
        //REMOVE DELEGATE
        serial.delegate = nil
    }
    
    // MARK: - IBACTION METHODS -

    @IBAction func actionSend(_ sender: UIButton)
    {
        //HIDE KEYBOARD
        txtCommand.resignFirstResponder()
        
        //CHECK IF TEXTFILELD HAVE VALUE OR NOT
        if txtCommand.text == STREMPTY
        {
            showAlert("Please enter command.", vc: self)
            return
        }
        serial.sendMessageToDevice(txtCommand.text!)
    }
    
    @IBAction func actionBack(_ sender: UIButton)
    {
        //DISCONNECT BLE
        serial.disconnect()
        
        APPDELEGATE.popToScan()
    }
    
    // MARK: - CUSTOM METHODS -
    
    //SCAN NEAR BY BLE
    func scanBLE()
    {
        serial.startScan()
        lblMessage.text = "Scanning...."
        
        Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(BLEDeviceConnectionVC.scanTimeOut), userInfo: nil, repeats: false)
    }
    
    /// Should be called 10s after we've begun scanning
    @objc func scanTimeOut()
    {
        // timeout has occurred, stop scanning and give the user the option to try again
        serial.stopScan()
        
        if peripherals.count == 0
        {
            lblMessage.text = MSGNODEVICE
            showAlert(MSGNODEVICE, vc: self)
        }
    }
    
    /// Should be called 10s after we've begun connecting
    @objc func connectTimeOut()
    {
        // don't if we've already connected
        if let _ = serial.connectedPeripheral {
            return
        }
        if let _ = selectedPeripheral {
            serial.disconnect()
            selectedPeripheral = nil
        }
        connnectFail()
    }
    
    func connnectFail()
    {
        showAlert(MSGUNABLETOCONNECT, vc: self)
        lblMessage.text = MSGNODEVICE
    }
    
    //ASK USER TO RECONNECT DEVICE IF DEVICE DISCONNECTS
    func connectDeviceAlert()
    {
        controller = UIAlertController(title: TITLEDEVICEDISCONNECT, message: MSGRECONNECTDEVICE, preferredStyle: UIAlertController.Style.alert)
        let okAction = UIAlertAction(title: CONNECT, style: .default) { (UIAlertAction) in
            if serial.pendingPeripheral != nil
            {
                serial.connectToPeripheral(serial.pendingPeripheral!)
            }
            else
            {
                showAlert(MSGNODEVICE, vc: self)
                self.lblMessage.text = MSGNODEVICE
            }
        }
        let cancelAction = UIAlertAction(title: CLOSEREMOTE, style: .cancel) { (UIAlertAction) in
            
            APPDELEGATE.popToScan()

        }
        
        controller.addAction(okAction)
        controller.addAction(cancelAction)
        self.present(controller, animated: true, completion: nil)
    }
    
    //ASK USER TO SWITCH ON THE BLUETOOTH
    func turnOnBLuetooth()
    {
        controller = UIAlertController(title: STREMPTY, message: MSGNOBLUETOOTH, preferredStyle: UIAlertController.Style.alert)
        
        let okAction = UIAlertAction(title: GOTIT, style: .default) { (UIAlertAction) in
            
            DispatchQueue.main.asyncAfter(deadline:.now(), execute:
                {
                    if serial.centralManager.state != .poweredOn
                    {
                        self.turnOnBLuetooth()
                    }
            })
        }
        
        let cancelAction = UIAlertAction(title: CLOSEREMOTE, style: .destructive) { (UIAlertAction) in
            APPDELEGATE.popToScan()
        }
        
        controller.addAction(okAction)
        controller.addAction(cancelAction)
        self.present(controller, animated: true, completion: nil)
    }
}

extension BLEDeviceConnectionVC : BluetoothSerialDelegate
{
    func serialDidDiscoverPeripheral(_ peripheral: CBPeripheral, RSSI: NSNumber?)
    {
        // add to the array, next sort & reload
        let theRSSI = RSSI?.floatValue ?? 0.0
        peripherals.append((peripheral: peripheral, RSSI: theRSSI))
        peripherals.sort { $0.RSSI < $1.RSSI }
    }
    
    func serialDidReceiveString(_ message: String)
    {
        NSLog("response = %@",message)
        txtViewResponse.text = message + NEWLINE + txtViewResponse.text
    }
    
    func serialDidDisconnect(_ peripheral: CBPeripheral, error: NSError?)
    {
        serial.pendingPeripheral = peripheral
        print("device Disconnected")
        
        if serial.centralManager.state == .poweredOn
        {
            connectDeviceAlert()
        }
    }
    
    func serialDidChangeState()
    {
        if serial.centralManager.state != .poweredOn
        {
            turnOnBLuetooth()
        }
        else if serial.centralManager.state == .poweredOn
        {
            controller.dismiss(animated: true, completion: nil)
            scanBLE()
        }
    }
    
    func serialDidFailToConnect(_ peripheral: CBPeripheral, error: NSError?)
    {
        connectDeviceAlert()
    }
    
    func serialIsReady(_ peripheral: CBPeripheral)
    {
        print("Connected device again")
        serial.pendingPeripheral = nil
        lblMessage.text = STRCONNECTED
    }
}

extension BLEDeviceConnectionVC : UITextFieldDelegate
{
    // MARK: - UITextField - Delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
}
