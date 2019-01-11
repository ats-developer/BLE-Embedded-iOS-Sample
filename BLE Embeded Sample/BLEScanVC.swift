//
//  BLEScanVC.swift
//  BLE Embeded Sample
//
//  Created by AtharvaSystem on 08/01/19.
//  Copyright © 2019 AtharvaSystem. All rights reserved.
//

import UIKit
import CoreBluetooth

class BLEScanVC: UIViewController {
    
    //MARK: - IBOUTLET/VARIABLE -
    
    @IBOutlet weak var tryAgainButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lblTitle: UILabel!
    
    /// The peripherals that have been discovered (no duplicates and sorted by asc RSSI)
    var peripherals: [(peripheral: CBPeripheral, RSSI: Float)] = []
    
    /// The peripheral the user has selected
    var selectedPeripheral: CBPeripheral?
    
    // MARK: - VIEW LIFE CYCLE -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initOnce()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        DispatchQueue.main.asyncAfter(deadline:.now() + 2.0, execute: {
                self.scanBLE()
        })
    }
    
    // MARK: - CUSTOM METHODS -
    
    //INITIALIZE ONCE
    func initOnce() {
        self.navigationController?.navigationBar.isHidden = true
        
        DispatchQueue.main.asyncAfter(deadline:.now(), execute: {
                // init serial
                serial = BluetoothSerial(delegate: self)
        })
        
        lblTitle.text = TITLEBLEDEVICELIST
        
        // remove extra seperator insets (looks better imho)
        tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    //SCAN NEAR BY BLE DEVICE
    func scanBLE() {
        if serial.centralManager.state != .poweredOn {
            print("called")
            peripherals.removeAll()
            tableView.reloadData()
            turnOnBLuetooth()
            return
        }
        
        tryAgainButton.setTitle(TITLESTOP, for: .normal)
        serial.startScan()
        Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(BLEScanVC.scanTimeOut), userInfo: nil, repeats: false)
    }
    
    /// Should be called 10s after we've begun scanning
    @objc func scanTimeOut() {
        // timeout has occurred, stop scanning and give the user the option to try again
        serial.stopScan()
        tryAgainButton.setTitle(TITLESCAN, for: .normal)
        if peripherals.count == 0 {
            showAlert(MSGNODEVICE, vc: self)
        }
    }
    
    /// Should be called 10s after we've begun connecting
    @objc func connectTimeOut() {
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
    
    //CALLED WHEN FAIL TO CONNECT
    func connnectFail() {
        showAlert(MSGUNABLETOCONNECT, vc: self)
    }
    
    //CALLED WHEN BLUETOOTH GOES OFF
    func turnOnBLuetooth() {
        showAlert(MSGNOBLUETOOTH, vc: self)
    }
    
    // MARK: - IBACTION METHODS -
    
    @IBAction func tryAgain(_ sender: UIButton) {
        if serial.centralManager.state != .poweredOn {
            turnOnBLuetooth()
        } else {
            // empty array an start again
            if sender.title(for: .normal) == TITLESCAN {
                peripherals = []
                tableView.reloadData()
                scanBLE()
            } else {
                serial.stopScan()
                tryAgainButton.setTitle(TITLESCAN, for: .normal)
            }
        }
    }
}

extension BLEScanVC : UITableViewDataSource {
    // MARK: - UITABLEVIEW DATASOURCE -
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return peripherals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // return a cell with the peripheral name as text in the label
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        let label = cell.viewWithTag(1) as! UILabel?
        let desclabel = cell.viewWithTag(2) as! UILabel?
        let strname : String = peripherals[(indexPath as NSIndexPath).row].peripheral.name ?? "Unknown Device"
        label?.text = strname
        desclabel?.text = peripherals[(indexPath as NSIndexPath).row].peripheral.identifier.uuidString
        return cell
    }
}

extension BLEScanVC : UITableViewDelegate {
   
    // MARK: - UITABLEVIEW DELEGATE -
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if serial.centralManager.state != .poweredOn {
            turnOnBLuetooth()
            return
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        // the user has selected a peripheral, so stop scanning and proceed to the next view
        serial.stopScan()
        selectedPeripheral = peripherals[(indexPath as NSIndexPath).row].peripheral
        
        serial.connectToPeripheral(selectedPeripheral!)
        
        Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(BLEScanVC.connectTimeOut), userInfo: nil, repeats: false)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 102
    }
}

extension BLEScanVC : BluetoothSerialDelegate {
    
    //MARK:- BluetoothSerialDelegate -
    
    //DISCOVER NEARBY BLE DEVICE
    func serialDidDiscoverPeripheral(_ peripheral: CBPeripheral, RSSI: NSNumber?) {
        // check whether it is a duplicate
        for exisiting in peripherals {
            if exisiting.peripheral.identifier == peripheral.identifier { return }
        }
        
        // add to the array, next sort & reload
        let theRSSI = RSSI?.floatValue ?? 0.0
        peripherals.append((peripheral: peripheral, RSSI: theRSSI))
        peripherals.sort { $0.RSSI < $1.RSSI }
        
        tableView.reloadData()
    }
    
    //CALLED WHEN FAIL TO CONNEC BLE DEVICE
    func serialDidFailToConnect(_ peripheral: CBPeripheral, error: NSError?) {
        let msg = "\(MSGUNABLETOCONNECT) \(String(describing: peripheral.name))"
        showAlert(msg, vc: self)
    }
    
    func serialDidDisconnect(_ peripheral: CBPeripheral, error: NSError?) {
        print("Disconnected")
    }
    
    //CALLED WHEN DEVICE GET CONNECTED
    func serialIsReady(_ peripheral: CBPeripheral) {
        //NAVIGATE TO NEXT SCREEN WHEN BLE GOT CONNECTED
        self.performSegue(withIdentifier: "scanToDevice", sender: nil)
    }
    
    //CALLED WHEN BLUETOOTH STATE CHANGE
    func serialDidChangeState() {
        if serial.centralManager.state != .poweredOn {
            peripherals = []
            tableView.reloadData()
            turnOnBLuetooth()
        } else if serial.centralManager.state == .poweredOn {
            scanBLE()
        }
    }
}
