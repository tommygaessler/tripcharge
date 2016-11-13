//
//  ViewController.swift
//  ChargingStations
//
//  Created by Tommy Gaessler on 11/9/16.
//  Copyright © 2016 Tommy Gaessler. All rights reserved.
//

import UIKit
import GoogleMaps
import SwiftyJSON
import Alamofire
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, UITextFieldDelegate {
    
    // MARK: Find Closest Stations Inputs
    
    @IBOutlet weak var CurrentLat: UITextField!
    @IBOutlet weak var CurrentLong: UITextField!
    
    // MARK: Find Stations Along Route Inputs
    
    @IBOutlet weak var StartLat: UITextField!
    @IBOutlet weak var StartLong: UITextField!
    @IBOutlet weak var EndLat: UITextField!
    @IBOutlet weak var EndLong: UITextField!
    
    // MARK: Properties

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: Action: FindClosestStations
    
    @IBAction func FindClosestStations(_ sender: UIButton) {
        
        
        // MARK: Check if input is empty or invalid
        
        if CurrentLat.text!.isEmpty || CurrentLong.text!.isEmpty {
            
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
                            marker.map = mapView
                        }
                    }
                }
            }
        }
    }
    
    // MARK: Action: FindStationsAlongRoute
    
    @IBAction func FindStationsAlongRoute(_ sender: UIButton) {
        
        // MARK: Check if input is empty or invalid
        
        if StartLat.text!.isEmpty || StartLong.text!.isEmpty || EndLat.text!.isEmpty || EndLong.text!.isEmpty {
            
            let alertController = UIAlertController(title: "ChargingStations", message:
                "Please Enter Valid Coordinates", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
            
            self.present(alertController, animated: true, completion: nil)
            
        } else {
            let startLatInput = Double(StartLat.text!)
            let startLongInput = Double(StartLong.text!)
            let endLatInput = Double(EndLat.text!)
            let endLongInput = Double(EndLong.text!)
            
            let screenSize: CGRect = UIScreen.main.bounds
            let screenWidth = screenSize.width
            let screenHeight = screenSize.height
            
            // MARK: Google Maps
            let camera = GMSCameraPosition.camera(withLatitude: startLatInput!, longitude: startLongInput!, zoom: 6.0)
            let mapView = GMSMapView.map(withFrame: CGRect(x: 0, y: 100, width: screenWidth, height: screenHeight-100), camera: camera)
            self.view.addSubview(mapView)
            
            //MARK: Set starting pin
            let position1 = CLLocationCoordinate2DMake(startLatInput!, startLongInput!)
            let marker1 = GMSMarker(position: position1)
            marker1.title = "Starting Location"
            marker1.icon = GMSMarker.markerImage(with: UIColor.green)
            marker1.map = mapView
            
            //MARK: Set destination pin
            let position2 = CLLocationCoordinate2DMake(endLatInput!, endLongInput!)
            let marker2 = GMSMarker(position: position2)
            marker2.title = "Destination"
            marker2.icon = GMSMarker.markerImage(with: UIColor.blue)
            marker2.map = mapView
            
            //MARK: Send Location to Austins API
            Alamofire.request("https://guarded-garden-39811.herokuapp.com/start/lat/\(startLatInput! as Double)/long/\(startLongInput! as Double)/end/lat/\(endLatInput! as Double)/long/\(endLongInput! as Double)").responseJSON { response in
                
                // MARK: Through error is starting location and ending location are the same, or if the starting location/ending location are invalid
                if (response.result.value is NSNull) {
                    let alertController = UIAlertController(title: "ChargingStations", message:
                        "Invalid Starting and Ending Location", preferredStyle: UIAlertControllerStyle.alert)
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
                            marker.map = mapView
                        }
                    }
                }
            }
        }
    }
}


