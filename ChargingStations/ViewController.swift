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

    // MARK: Actions
    @IBAction func FindClosestStation(_ sender: UIButton) {
        print("hi tommy")
        
        // MARK: Google Maps
        let camera = GMSCameraPosition.camera(withLatitude: 30, longitude: 40, zoom: 6.0)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView.isMyLocationEnabled = true
        view = mapView
        
        Alamofire.request("https://guarded-garden-39811.herokuapp.com/lat/30/long/40").responseJSON { response in
            
            if let addresses = response.result.value {
                for address in addresses as! [AnyObject] {
                    
                    let info = address["AddressInfo"] as! [String : AnyObject]
                    
                    let lat = info["Latitude"] as! Double
                    let long = info["Longitude"] as! Double
    
                    print(lat)
                    print(long)
                    
                    let position = CLLocationCoordinate2DMake(lat, long)
                    let marker = GMSMarker(position: position)
                    marker.title = "Hello World"
                    marker.map = mapView
                }
            }
        }
    }
}

