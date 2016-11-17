//
//  ViewController.swift
//  ChargingStations
//
//  Created by Tommy Gaessler on 11/9/16.
//  Copyright © 2016 Tommy Gaessler. All rights reserved.
//
// Goals:
// 2. Use current location as option for finding closest charger
// 3. Use current location as option for starting point
// 4. When you click on a pin there will be a link to route to it and open google maps
//
// Stretch:
// 1. Change inputs to accept Addresses instead of cords (mostly server side work)
// 2. Add route line from starting point to destination that is fatest and hits most chargers
// 3. Add route line to closest charger when finding nearest charger
// 4. Add ability to send put post and delete requests to open charge api if charging info needs to be updated
// 5. See how many charging spots are currently availble when you click on pin
// 6. See how many total charging spots there are
// 7. Check if the price is free, if not list the price

import UIKit
import GoogleMaps
import SwiftyJSON
import Alamofire
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, UITextFieldDelegate, GMSMapViewDelegate {
    
    // MARK: Find Closest Stations Inputs
    
    @IBOutlet weak var CurrentLat: UITextField!
    @IBOutlet weak var CurrentLong: UITextField!
    
    // MARK: Find Stations Along Route Inputs
    
    @IBOutlet weak var StartAddress: UITextField!
    @IBOutlet weak var EndAddress: UITextField!
    
    // MARK: Properties
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: Action: FindClosestStations
    
    @IBAction func FindClosestStations(_ sender: UIButton) {
        
        // MARK: Hides keyboard on submit
        self.view.endEditing(true)
        
        // MARK: Check if input is empty or invalid
        
        if CurrentLat.text!.isEmpty || CurrentLong.text!.isEmpty || NumberFormatter().number(from: CurrentLat.text!) == nil || NumberFormatter().number(from: CurrentLong.text!) == nil {
            
            let alertController = UIAlertController(title: "ChargingStations", message:
                "Please Enter Valid Coordinates", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
            
            self.present(alertController, animated: true, completion: nil)
        } else {
            
            let currentLatInput = Double(CurrentLat.text!)
            let currentLongInput = Double(CurrentLong.text!)
            
            // MARK: Get Screen Size
            let screenSize: CGRect = UIScreen.main.bounds
            let screenWidth = screenSize.width
            let screenHeight = screenSize.height
            
            // MARK: Google Maps
            let camera = GMSCameraPosition.camera(withLatitude: currentLatInput!, longitude: currentLongInput!, zoom: 6.0)
            let mapView = GMSMapView.map(withFrame: CGRect(x: 0, y: 100, width: screenWidth, height: screenHeight - 100), camera: camera)
            self.view.addSubview(mapView)
            
            //MARK: Set current location pin
            let position3 = CLLocationCoordinate2DMake(currentLatInput!, currentLongInput!)
            let marker3 = GMSMarker(position: position3)
            marker3.title = "Search Location"
            marker3.icon = GMSMarker.markerImage(with: UIColor.green)
            marker3.map = mapView
            
            //MARK: Send Location to Austins API
            Alamofire.request("https://guarded-garden-39811.herokuapp.com/lat/\(currentLatInput! as Double)/long/\(currentLongInput! as Double)").responseJSON { response in
                
                if (response.result.value as! Array<Any>).isEmpty {
                    let alertController = UIAlertController(title: "ChargingStations", message:
                        "No Stations Found", preferredStyle: UIAlertControllerStyle.alert)
                    alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
                    
                    self.present(alertController, animated: true, completion: nil)
                } else {
                    
                    //MARK: Add pins for each charging station location
                    if let addresses = response.result.value {
                        for address in addresses as! [AnyObject] {
                            
                            let info = address["AddressInfo"] as! [String : AnyObject]
                            
                            let addressLine1 = info["AddressLine1"] as! String
                            let lat = info["Latitude"] as! Double
                            let long = info["Longitude"] as! Double
                            
                            let position = CLLocationCoordinate2DMake(lat, long)
                            let marker = GMSMarker(position: position)
                            marker.title = addressLine1
                            marker.snippet = "Take Me Here"
                            marker.map = mapView
                        }
                    }
                }
            }
        }
    }
    
    // MARK: Action: FindStationsAlongRoute
    
    @IBAction func FindStationsAlongRoute(_ sender: UIButton) {
        
        // MARK: Hides keyboard on submit
        self.view.endEditing(true)
        
        // MARK: Check if input is empty or invalid
        
        if StartAddress.text!.isEmpty || EndAddress.text!.isEmpty {
            
            let alertController = UIAlertController(title: "ChargingStations", message:
                "Please Enter All Fields", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
            
            self.present(alertController, animated: true, completion: nil)
            
        } else {
            
            let StartAddress: String = self.StartAddress.text!.replacingOccurrences(of: " ", with: "%20")
            let EndAddress: String = self.EndAddress.text!.replacingOccurrences(of: " ", with: "%20")
            
            let screenSize: CGRect = UIScreen.main.bounds
            let screenWidth = screenSize.width
            let screenHeight = screenSize.height
            
            // MARK: Send Location to Austins API
            Alamofire.request("https://guarded-garden-39811.herokuapp.com/start/address/\(StartAddress)/end/address/\(EndAddress)").responseJSON { response in
                
                guard response.result.error == nil else {
                    // got an error in getting the data, need to handle it
                    print("error")
                    print(response.result.error!)
                    return
                }
                
                if let data = response.result.value {
                    
                    let addresses = JSON(data)
                    
                    let startLat = addresses[addresses.count-1]["startingEndCords"]["startLat"].double
                    let startLng = addresses[addresses.count-1]["startingEndCords"]["startLng"].double
                    let endLat = addresses[addresses.count-1]["startingEndCords"]["endLat"].double
                    let endLng = addresses[addresses.count-1]["startingEndCords"]["endLng"].double
                    
                    // MARK: Google Maps
                    let camera = GMSCameraPosition.camera(withLatitude: startLat!, longitude: startLng!, zoom: 6.0)
                    let mapView = GMSMapView.map(withFrame: CGRect(x: 0, y: 100, width: screenWidth, height: screenHeight-100), camera: camera)
                    self.view.addSubview(mapView)
                    
                    //MARK: Set starting pin
                    let position1 = CLLocationCoordinate2DMake(startLat!, startLng!)
                    let marker1 = GMSMarker(position: position1)
                    marker1.title = "Starting Location"
                    marker1.icon = GMSMarker.markerImage(with: UIColor.green)
                    marker1.map = mapView
                    
                    //MARK: Set destination pin
                    let position2 = CLLocationCoordinate2DMake(endLat!, endLng!)
                    let marker2 = GMSMarker(position: position2)
                    marker2.title = "Destination"
                    marker2.icon = GMSMarker.markerImage(with: UIColor.blue)
                    marker2.map = mapView
                    
                    for index in 0...addresses.count-2 {
                        
                        let lat = addresses[index]["AddressInfo"]["Latitude"].double
                        let lng = addresses[index]["AddressInfo"]["Longitude"].double
                        let address = addresses[index]["AddressInfo"]["AddressLine1"].string
                        
                        let position = CLLocationCoordinate2DMake(lat!, lng!)
                        let marker = GMSMarker(position: position)
                        marker.title = address
                        marker.snippet = "Take Me Here"
                        marker.map = mapView
                    }
                }
            }
        }
    }
}


