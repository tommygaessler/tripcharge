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

    let locationManager = CLLocationManager()
    
    var latitude = 0.00
    var Longitude = 0.00
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse:
            locationManager.requestLocation()
        case .denied, .restricted:
            // Handle the case where the user has denied access
            print("Location services denied or restricted.")
            disableLocationFeatures()
        case .notDetermined:
            // This case should be handled in viewDidLoad or similar
            locationManager.requestWhenInUseAuthorization()
        case .authorizedAlways:
            print("always")
        @unknown default:
            // Handle any future cases
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            latitude = location.coordinate.latitude
            Longitude = location.coordinate.longitude
            print("User's current location: \(latitude), \(Longitude)")
            // Use these coordinates as needed in your app
            searchChargers()
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error getting location: \(error.localizedDescription)")
    }
    
    func disableLocationFeatures() {
        let alertController = UIAlertController(title: "Trip Charge", message:
            "Please allow location access to find charging stations.", preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Settings", style: .default) { (UIAlertAction) in
            UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!)
        })
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default,handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
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
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    
    func searchChargers() {
        
        if Connectivity.isConnectedToInternet {
        
            // MARK: Get Screen Size
            let screenSize: CGRect = UIScreen.main.bounds
            let screenWidth = screenSize.width
            let screenHeight = screenSize.height
            let topNavHeight = UIApplication.shared.delegate?.window??.safeAreaInsets.bottom ?? 0
            
            // MARK: Google Maps
            let options = GMSMapViewOptions()
            options.camera = GMSCameraPosition.camera(withLatitude: latitude, longitude: Longitude, zoom: 12.0)
            options.frame = CGRect(x: 0, y: topNavHeight + 60, width: screenWidth, height: screenHeight - (topNavHeight + 60))
            let mapView = GMSMapView(options:options)
            
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
            AF.request("https://tripcharge.herokuapp.com/lat/\(latitude)/long/\(Longitude)").responseData { response in
                
                guard response.error == nil else {
                    // got an error in getting the data, need to handle it
                    let alertController = UIAlertController(title: "Something went wrong", message:
                        "Please try again later.", preferredStyle: UIAlertController.Style.alert)
                    alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default,handler: nil))
                    
                    self.present(alertController, animated: true, completion: nil)
                    return
                }
                
                if let data = response.value {
                    
                    let chargers = JSON(data)
                    
                    if chargers.count == 0 {
                        let alertController = UIAlertController(title: "Invalid Location", message:
                            "Please try something more specific.", preferredStyle: UIAlertController.Style.alert)
                        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default,handler: nil))
                        
                        self.present(alertController, animated: true, completion: nil)
                    } else {
                        
                        for index in 0...chargers.count-1 {
                            

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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
