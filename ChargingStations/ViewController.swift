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
// 9. Add loading icon

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var StationsAlongRouteButton: UIButton!
    @IBOutlet weak var ClosestStationsButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
