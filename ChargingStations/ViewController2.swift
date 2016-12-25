//
//  ViewController2.swift
//  ChargingStations
//
//  Created by Tommy Gaessler on 12/13/16.
//  Copyright © 2016 Tommy Gaessler. All rights reserved.
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
        let alertController = UIAlertController(title: "ChargingStations", message:
            "In order to find closest stations, go to settings and enable location services :)", preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
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
            UIApplication.shared.open(NSURL(string: "http://maps.apple.com/?address=\(linkLocation)")! as URL)
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
        
        // MARK: Get Screen Size
        let screenSize: CGRect = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        
        // MARK: Google Maps
        let camera = GMSCameraPosition.camera(withLatitude: latitude, longitude: Longitude, zoom: 10.0)
        let mapView = GMSMapView.map(withFrame: CGRect(x: 0, y: 60, width: screenWidth, height: screenHeight - 60), camera: camera)
        self.view.addSubview(mapView)
        
        //MARK: Set current location pin
        let position3 = CLLocationCoordinate2DMake(latitude, Longitude)
        let marker3 = GMSMarker(position: position3)
        marker3.title = "Current Location"
        marker3.icon = GMSMarker.markerImage(with: UIColor.green)
        marker3.map = mapView
        
        mapView.delegate = self
        
        //MARK: Send Location to Austins API
        Alamofire.request("https://guarded-garden-39811.herokuapp.com/lat/\(latitude)/long/\(Longitude)").responseJSON { response in
            
            if (response.result.value as! Array<Any>).isEmpty {
                let alertController = UIAlertController(title: "ChargingStations", message: "No Stations Found", preferredStyle: UIAlertControllerStyle.alert)
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
