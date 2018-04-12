//
//  ViewController.swift
//  ChargingStations
//
//  Created by Tommy Gaessler on 11/9/16.
//  Copyright © 2017 Tommy Gaessler. All rights reserved.
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
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    var locationManager = CLLocationManager()
    
    var latitude = 0.00
    var Longitude = 0.00
    
    @IBOutlet weak var StationsAlongRouteButton: UIButton!
    @IBOutlet weak var ClosestStationsButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestLocation()
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        StationsAlongRouteButton.isEnabled = true;
        ClosestStationsButton.isEnabled = true;
        if let location11 = locations.first {
            latitude = location11.coordinate.latitude
            Longitude = location11.coordinate.longitude
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        StationsAlongRouteButton.isEnabled = false;
        ClosestStationsButton.isEnabled = false;
        let alertController = UIAlertController(title: "Trip Charge", message:
            "Please allow location access to find charging stations.", preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Settings", style: .default) { (UIAlertAction) in
            UIApplication.shared.open(URL(string:UIApplicationOpenSettingsURLString)!)
        })
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default,handler: nil))
        
        
        self.present(alertController, animated: true, completion: nil)
    }
}
