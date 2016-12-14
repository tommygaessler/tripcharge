//
//  ViewController.swift
//  ChargingStations
//
//  Created by Tommy Gaessler on 11/9/16.
//  Copyright © 2016 Tommy Gaessler. All rights reserved.
//
// Goals:
// 3. Use starting location as an address/place
//
// Stretch:
// 4. Add ability to send put post and delete requests to open charge api if charging info needs to be updated
// 5. See how many charging spots are currently availble when you click on pin
// 6. See how many total charging spots there are
// 7. Check if the price is free, if not list the price
// 8. Use google maps auto fill api for route inputs

import UIKit
import GoogleMaps
import SwiftyJSON
import Alamofire
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, UITextFieldDelegate, GMSMapViewDelegate {
    
    // MARK: Find Stations Along Route Input
    
    @IBOutlet weak var EndAddress: UITextField!
    
    let locationManager = CLLocationManager()
    
    var latitude = 0.00
    var Longitude = 0.00
    
    // MARK: Properties
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        locationManager.delegate = self
        locationManager.requestLocation()
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Mark: Helper Functions
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location11 = locations.first {
            latitude = location11.coordinate.latitude
            Longitude = location11.coordinate.longitude
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        
        let linkLocation: String = marker.title!.replacingOccurrences(of: " ", with: "+")

        
        if (UIApplication.shared.canOpenURL(NSURL(string:"comgooglemaps://")! as URL)) {
            UIApplication.shared.open(NSURL(string:"comgooglemaps://?saddr=&daddr=\(linkLocation)&directionsmode=driving")! as URL)
        } else {
            NSLog("Can't use comgooglemaps://");
            UIApplication.shared.open(NSURL(string: "http://maps.apple.com/?address=\(linkLocation)")! as URL)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let alertController = UIAlertController(title: "ChargingStations", message:
            "In order to find closest stations, go to settings and enable location services :)", preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    
    // MARK: Action: FindStationsAlongRoute
    
    @IBAction func FindStationsAlongRoute(_ sender: UIButton) {
        
        // MARK: Hides keyboard on submit
        self.view.endEditing(true)
        
        // MARK: Check if input is empty or invalid
        
        if EndAddress.text!.isEmpty {
            
            let alertController = UIAlertController(title: "ChargingStations", message:
                "Please Enter All Fields", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
            
            self.present(alertController, animated: true, completion: nil)
            
        } else {
            
            let EndAddress: String = self.EndAddress.text!.replacingOccurrences(of: " ", with: "%20")
            
            let screenSize: CGRect = UIScreen.main.bounds
            let screenWidth = screenSize.width
            let screenHeight = screenSize.height
            
            // MARK: Send Location to Austins API
            Alamofire.request("https://guarded-garden-39811.herokuapp.com/start/lat/\(latitude)/long/\(Longitude)/end/address/\(EndAddress)").responseJSON { response in

                guard response.result.error == nil else {
                    // got an error in getting the data, need to handle it
                    let alertController = UIAlertController(title: "ChargingStations", message:
                        "Invalid Locations", preferredStyle: UIAlertControllerStyle.alert)
                    alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
                    
                    self.present(alertController, animated: true, completion: nil)
                    return
                }
                
                if let data = response.result.value {
                    
                    let addresses = JSON(data)
                    
                    if addresses.count == 0 {
                        let alertController = UIAlertController(title: "ChargingStations", message:
                            "No Stations Found", preferredStyle: UIAlertControllerStyle.alert)
                        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
                        
                        self.present(alertController, animated: true, completion: nil)
                    } else {
                        let startLat = addresses[addresses.count-1]["startingEndCords"]["startLat"].double
                        let startLng = addresses[addresses.count-1]["startingEndCords"]["startLng"].double
                        let endLat = addresses[addresses.count-1]["startingEndCords"]["endLat"].double
                        let endLng = addresses[addresses.count-1]["startingEndCords"]["endLng"].double
                        
                        // MARK: Google Maps
                        let camera = GMSCameraPosition.camera(withLatitude: startLat!, longitude: startLng!, zoom: 10.0)
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
                        
                        mapView.delegate = self
                        
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
}


