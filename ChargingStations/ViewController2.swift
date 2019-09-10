//
//  ViewController2.swift
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

class ViewController2: UIViewController, CLLocationManagerDelegate, UITextFieldDelegate, GMSMapViewDelegate {

    var locationManager = CLLocationManager()
    
    var latitude = 0.00
    var Longitude = 0.00
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let alertController = UIAlertController(title: "Trip Charge", message:
            "Please allow location access to find charging stations.", preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Settings", style: .default) { (UIAlertAction) in
            UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!)
        })
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default,handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location11 = locations.first {
            latitude = location11.coordinate.latitude
            Longitude = location11.coordinate.longitude
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        
        if(marker.title! != "Current Location") {
            let linkLocation: String = (marker.userData! as AnyObject).replacingOccurrences(of: " ", with: "+")
            
            if (UIApplication.shared.canOpenURL(NSURL(string:"comgooglemaps://")! as URL)) {
                UIApplication.shared.open(NSURL(string:"comgooglemaps://?saddr=&daddr=\(linkLocation)&directionsmode=driving")! as URL)
            } else {
                UIApplication.shared.open(NSURL(string: "http://maps.apple.com/?address=\(linkLocation)")! as URL)
            }
        }
    }
    
    struct Connectivity {
        static let sharedInstance = NetworkReachabilityManager()!
        static var isConnectedToInternet:Bool {
            return self.sharedInstance.isReachable
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        latitude = (locationManager.location?.coordinate.latitude)!
        Longitude = (locationManager.location?.coordinate.longitude)!
        
        
        locationManager.delegate = self
        locationManager.requestLocation()
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        
        
        if Connectivity.isConnectedToInternet {
        
            // MARK: Get Screen Size
            let screenSize: CGRect = UIScreen.main.bounds
            let screenWidth = screenSize.width
            let screenHeight = screenSize.height
            
            // MARK: Google Maps
            let camera = GMSCameraPosition.camera(withLatitude: latitude, longitude: Longitude, zoom: 12.0)
            let mapView = GMSMapView.map(withFrame: CGRect(x: 0, y: UIApplication.shared.statusBarFrame.maxY + 40, width: screenWidth, height: screenHeight - UIApplication.shared.statusBarFrame.maxY + 40), camera: camera)
            self.view.addSubview(mapView)
            
            //MARK: Set current location pin
            let position3 = CLLocationCoordinate2DMake(latitude, Longitude)
            let marker3 = GMSMarker(position: position3)
            marker3.title = "Current Location"
            marker3.icon = GMSMarker.markerImage(with: UIColor.green)
            marker3.map = mapView
            
            mapView.delegate = self
            
            //MARK: Send Location to Austins API
            // check if connectivity add popup
            Alamofire.request("https://tripcharge.herokuapp.com/lat/\(latitude)/long/\(Longitude)").responseJSON { response in
                
                if (response.result.value as! Array<Any>).isEmpty {
                    let alertController = UIAlertController(title: "Trip Charge", message: "No Stations Found", preferredStyle: UIAlertController.Style.alert)
                    alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default,handler: nil))
                    
                    self.present(alertController, animated: true, completion: nil)
                } else {
                    
                    //MARK: Add pins for each charging station location
                    if let Chargers = response.result.value {
                        for Charger in Chargers as! [AnyObject] {
                            
                            let charger = JSON(Charger)
                            
                            let lat = charger["AddressInfo"]["Latitude"].double
                            let long = charger["AddressInfo"]["Longitude"].double
                            
                            let position = CLLocationCoordinate2DMake(lat!, long!)
                            let marker = GMSMarker(position: position)

                            marker.title = charger["OperatorInfo"]["Title"].string
                            
                            marker.snippet =
                                (charger["Connections"].isEmpty ? "" : String(charger["Connections"][0]["Quantity"].int!)) + " " +
                                (charger["Connections"].isEmpty ? "" : charger["Connections"][0]["ConnectionType"]["Title"].string!) + "'s | " +
                                (charger["Connections"].isEmpty ? "" : charger["Connections"][0]["Level"]["Title"].string!)  + " | " +
                                charger["GeneralComments"].string!
                            marker.userData = charger["AddressInfo"]["AddressLine1"].string! + " " + charger["AddressInfo"]["Town"].string! + " " + charger["AddressInfo"]["StateOrProvince"].string!
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
