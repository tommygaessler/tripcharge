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

class ViewController: UIViewController {
    
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
                    
                    let lat = info["Latitude"] as! Double
                    let long = info["Longitude"] as! Double
                    
                    let position = CLLocationCoordinate2DMake(lat, long)
                    let marker = GMSMarker(position: position)
                    marker.title = "Hello World"
                    marker.map = mapView
                }
            }
        }
    }
    
    // MARK: Action: FindStationsAlongRoute
    
    @IBAction func FindStationsAlongRoute(_ sender: UIButton) {
        
        let screenSize: CGRect = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        
        // MARK: Google Maps
        let camera = GMSCameraPosition.camera(withLatitude: 39.733501, longitude: -104.992597, zoom: 6.0)
        let mapView = GMSMapView.map(withFrame: CGRect(x: 0, y: 60, width: screenWidth, height: screenHeight-60), camera: camera)
        self.view.addSubview(mapView)
        
        //MARK: Send Location to Austins API
        Alamofire.request("https://guarded-garden-39811.herokuapp.com/start/lat/39.733501/long/-104.992597/end/lat/39.916591/long/-104.930168").responseJSON { response in
            
            //MARK: Set starting pin
            let position1 = CLLocationCoordinate2DMake(39.733501, -104.992597)
            let marker1 = GMSMarker(position: position1)
            marker1.title = "Starting Location"
            marker1.icon = GMSMarker.markerImage(with: UIColor.green)
            marker1.map = mapView
            
            //MARK: Set destination pin
            let position2 = CLLocationCoordinate2DMake(39.916591, -104.930168)
            let marker2 = GMSMarker(position: position2)
            marker2.title = "Destination"
            marker2.icon = GMSMarker.markerImage(with: UIColor.blue)
            marker2.map = mapView
            
            //MARK: Add pins for each charging station location
            if let addresses = response.result.value {
                for address in addresses as! [AnyObject] {
                    
                    let info = address["AddressInfo"] as! [String : AnyObject]
                    
                    let lat = info["Latitude"] as! Double
                    let long = info["Longitude"] as! Double
                    
                    let position = CLLocationCoordinate2DMake(lat, long)
                    let marker = GMSMarker(position: position)
                    marker.title = "Hello World"
                    marker.map = mapView
                }
            }
        }
    }
}
