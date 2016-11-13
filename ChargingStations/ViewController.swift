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
        
        // MARK: Get Screen Size
        let screenSize: CGRect = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        
        // MARK: Google Maps
        let camera = GMSCameraPosition.camera(withLatitude: 37.7749, longitude: -122.4194, zoom: 6.0)
        let mapView = GMSMapView.map(withFrame: CGRect(x: 0, y: 60, width: screenWidth, height: screenHeight - 60), camera: camera)
        self.view.addSubview(mapView)
        
        //MARK: Send Location to Austins API
        Alamofire.request("https://guarded-garden-39811.herokuapp.com/lat/37.7749/long/-122.4194").responseJSON { response in
            
            //MARK: Set current location pin
            let position3 = CLLocationCoordinate2DMake(37.7749, -122.4194)
            let marker3 = GMSMarker(position: position3)
            marker3.title = "Current Location"
            marker3.icon = GMSMarker.markerImage(with: UIColor.green)
            marker3.map = mapView
            
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
    
    // MARK: Action: FindStationsAlongRoute
    
    @IBAction func FindStationsAlongRoute(_ sender: UIButton) {
        
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
        
        //MARK: Send Location to Austins API
        Alamofire.request("https://guarded-garden-39811.herokuapp.com/start/lat/\(startLatInput! as Double)/long/\(startLongInput! as Double)/end/lat/\(endLatInput! as Double)/long/\(endLongInput! as Double)").responseJSON { response in
            
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
