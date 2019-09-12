//
//  ViewController3.swift
//  ChargingStations
//
//  Created by Tommy Gaessler on 12/13/16.
//  Copyright © 2017 Tommy Gaessler. All rights reserved.
//

import UIKit
import GoogleMaps
import SwiftyJSON
import Alamofire
import CoreLocation

class ViewController3: UIViewController, CLLocationManagerDelegate, UITextFieldDelegate, GMSMapViewDelegate {
    
    // MARK: Find Stations Along Route Input
    
    @IBOutlet weak var EndAddress: UITextField!
    
    let locationManager = CLLocationManager()
    
    @IBOutlet weak var DestinationInput: UITextField!
    @IBOutlet weak var GoButton: UIButton!
    
    var latitude = 0.00
    var Longitude = 0.00
    
    // MARK: Properties
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController3.dismissKeyboard))
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
        DestinationInput.isEnabled = true
        GoButton.isEnabled = true
        if let location11 = locations.first {
            latitude = location11.coordinate.latitude
            Longitude = location11.coordinate.longitude
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        
        if(marker.title! != "Current Location" && marker.title! != self.EndAddress.text!) {
            let linkLocation: String = (marker.userData! as AnyObject).replacingOccurrences(of: " ", with: "+")
            
            if (UIApplication.shared.canOpenURL(NSURL(string:"comgooglemaps://")! as URL)) {
                UIApplication.shared.open(NSURL(string:"comgooglemaps://?saddr=&daddr=\(linkLocation)&directionsmode=driving")! as URL)
            } else {
                UIApplication.shared.open(NSURL(string: "http://maps.apple.com/?address=\(linkLocation)")! as URL)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DestinationInput.isEnabled = false
        GoButton.isEnabled = false
        let alertController = UIAlertController(title: "Trip Charge", message:
            "Please allow location access to find charging stations.", preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Settings", style: .default) { (UIAlertAction) in
            UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!)
        })
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default,handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    struct Connectivity {
        static let sharedInstance = NetworkReachabilityManager()!
        static var isConnectedToInternet:Bool {
            return self.sharedInstance.isReachable
        }
    }
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    
    @IBAction func GoPressed(_ sender: Any) {
        FindStationsAlongRoute(nil)
    }
    
    
    // MARK: Action: FindStationsAlongRoute
    @IBAction func FindStationsAlongRoute(_ sender: UIButton?) {
        
        // MARK: Check if input is empty or invalid
        
        if EndAddress.text!.isEmpty {
            
            let alertController = UIAlertController(title: "Trip Charge", message:
                "Please Enter A Destination", preferredStyle: UIAlertController.Style.alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default,handler: nil))
            
            self.present(alertController, animated: true, completion: nil)
            
        } else {
            
             self.view.endEditing(true)
            
            if Connectivity.isConnectedToInternet {
            
                let EndAddress: String = self.EndAddress.text!.replacingOccurrences(of: " ", with: "%20")
                
                let screenSize: CGRect = UIScreen.main.bounds
                let screenWidth = screenSize.width
                let screenHeight = screenSize.height
                
                // MARK: Google Maps
                let camera = GMSCameraPosition.camera(withLatitude: self.latitude, longitude: self.Longitude, zoom: 10.0)
                let mapView = GMSMapView.map(withFrame: CGRect(x: 0, y: UIApplication.shared.statusBarFrame.maxY + 80, width: screenWidth, height: screenHeight-UIApplication.shared.statusBarFrame.maxY + 80), camera: camera)
                self.view.addSubview(mapView)
                
                //MARK: Set starting pin
                let position1 = CLLocationCoordinate2DMake(self.latitude, self.Longitude)
                let marker1 = GMSMarker(position: position1)
                marker1.title = "Current Location"
                marker1.icon = GMSMarker.markerImage(with: UIColor.green)
                marker1.map = mapView
                
                // MARK: Send Location to Austins API
                Alamofire.request("https://tripcharge.herokuapp.com/start/lat/\(latitude)/long/\(Longitude)/end/address/\(EndAddress)").responseJSON { response in
                    
                    guard response.result.error == nil else {
                        // got an error in getting the data, need to handle it
                        let alertController = UIAlertController(title: "Invalid Location", message:
                            "Please try something more specific.", preferredStyle: UIAlertController.Style.alert)
                        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default,handler: nil))
                        
                        self.present(alertController, animated: true, completion: nil)
                        return
                    }
                    
                    if let data = response.result.value {
                        
                        let chargers = JSON(data)
                        
                        if chargers.count == 0 {
                            let alertController = UIAlertController(title: "Invalid Location", message:
                                "Please try something more specific.", preferredStyle: UIAlertController.Style.alert)
                            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default,handler: nil))
                            
                            self.present(alertController, animated: true, completion: nil)
                        } else {

                            let endLat = chargers[chargers.count-1]["startingEndCords"]["endLat"].double
                            let endLng = chargers[chargers.count-1]["startingEndCords"]["endLng"].double
                            
                            //MARK: Set destination pin
                            let position2 = CLLocationCoordinate2DMake(endLat!, endLng!)
                            let marker2 = GMSMarker(position: position2)
                            marker2.title = self.EndAddress.text!
                            marker2.icon = GMSMarker.markerImage(with: UIColor.blue)
                            marker2.map = mapView
                            
                            mapView.delegate = self
                            
                            for index in 0...chargers.count-2 {

                                let lat = chargers[index]["AddressInfo"]["Latitude"].double
                                let long = chargers[index]["AddressInfo"]["Longitude"].double

                                let position = CLLocationCoordinate2DMake(lat!, long!)
                                let marker = GMSMarker(position: position)

                                marker.title = chargers[index]["OperatorInfo"]["Title"].string
                                marker.snippet =
                                    (chargers[index]["Connections"].isEmpty ? "" : String(chargers[index]["Connections"][0]["Quantity"].int!)) + " " +
                                    (chargers[index]["Connections"].isEmpty ? "" : chargers[index]["Connections"][0]["ConnectionType"]["Title"].string!) + "'s | " +
                                    (chargers[index]["Connections"].isEmpty ? "" : chargers[index]["Connections"][0]["Level"]["Title"].string!)  + " | " +
                                    chargers[index]["GeneralComments"].string!
                                marker.userData = chargers[index]["AddressInfo"]["AddressLine1"].string! + " " + chargers[index]["AddressInfo"]["Town"].string! + " " + chargers[index]["AddressInfo"]["StateOrProvince"].string!
                                marker.map = mapView
                            }
                        }
                    }
                }
            } else {
                let alertController = UIAlertController(title: "No Internet Connection", message: "Make sure your airplane mode is off and that you have service/wifi. Then try again.", preferredStyle: UIAlertController.Style.alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default,handler: nil))
                
                DispatchQueue.main.async { self.present(alertController, animated: true, completion: nil) }
            }
        }
    }
}
