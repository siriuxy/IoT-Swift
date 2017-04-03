//
//  mapVC.swift
//  IoTSampleSwift
//
//  Created by Likai Yan on 4/3/17.
//  Copyright © 2017 Amazon. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
// http://stackoverflow.com/questions/25296691/get-users-current-location-coordinates
class mapVC:UIViewController, CLLocationManagerDelegate{
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let locationManager = CLLocationManager()
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        var userLocation:CLLocation = locations[0] as! CLLocation
        let long = userLocation.coordinate.longitude;
        let lat = userLocation.coordinate.latitude;
        //Do What ever you want with it
        print (long);
        print (lat);
    }
}
