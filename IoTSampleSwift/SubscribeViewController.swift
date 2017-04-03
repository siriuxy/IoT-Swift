/*
* Copyright 2010-2016 Amazon.com, Inc. or its affiliates. All Rights Reserved.
*
* Licensed under the Apache License, Version 2.0 (the "License").
* You may not use this file except in compliance with the License.
* A copy of the License is located at
*
*  http://aws.amazon.com/apache2.0
*
* or in the "license" file accompanying this file. This file is distributed
* on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
* express or implied. See the License for the specific language governing
* permissions and limitations under the License.
*/

import UIKit
import AWSIoT
import CoreLocation
import MapKit
class SubscribeViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var subscribeSlider: UISlider!

    @IBOutlet weak var fanOffButton: UIButton!
    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view, typically from a nib.
       // subscribeSlider.isEnabled = false
        super.viewDidLoad()
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        print(CLLocationManager.locationServicesEnabled())
        print ("hey")
        
        //mapview setup to show user location
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.mapType = MKMapType(rawValue: 0)!
        mapView.userTrackingMode = MKUserTrackingMode(rawValue: 2)!
        
        mapView.isScrollEnabled = false;
        mapView.isUserInteractionEnabled = false;
        // mapView.add(MKPolyline(coordinates: <#T##UnsafePointer<CLLocationCoordinate2D>#>, count: <#T##Int#>)
//        let newloc = CLLocation(latitude: 38.63779096, longitude: -90.3429794)
//        let newloc2 = CLLocation(latitude: 38.63779097, longitude: 90.3343963)
//        var areas = [newloc.coordinate, newloc2.coordinate];
//        var circ = MKPolyline(coordinates: &areas, count: 2)
//        mapView.add(circ);
//        <wpt lat="  " lon="-90.3429794">
//        <ele>164.00000</ele>
//        <time>2010-01-01T00:00:00Z</time>
//        </wpt>
//        <wpt lat="38.63779096" lon="-90.3343963">
//        <ele>171.00000</ele>
//        <time>2010-01-01T00:00:27Z</time>
//        </wpt>
//        <wpt lat="38.63497509" lon="-90.3180885">
//        <ele>169.00000</ele>
//        <time>2010-01-01T00:01:21Z</time>
//        </wpt>

    }

    override func viewWillAppear(_ animated: Bool) {
        let iotDataManager = AWSIoTDataManager.default()
        let tabBarViewController = tabBarController as! IoTSampleTabBarController

        iotDataManager.subscribe(toTopic: tabBarViewController.topic, qoS: .messageDeliveryAttemptedAtMostOnce, messageCallback: {
            (payload) ->Void in
            let stringValue = NSString(data: payload, encoding: String.Encoding.utf8.rawValue)!

            print("received: \(stringValue)")
            DispatchQueue.main.async {
              //  self.subscribeSlider.value = stringValue.floatValue
            }
        } )
    }
    
    var prevLoc:CLLocation?
    var counter = 7;
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("locMAnager");
        let userLocation:CLLocation = locations.last!
        let long = userLocation.coordinate.longitude;
        let lat = userLocation.coordinate.latitude;
        //Do What ever you want with it
        print (long);
        print (lat);
        // if locations.count == 1 {
         //   return;
        //}
        // create drawing frame.
        print("not 1")
        let newCoord = userLocation.coordinate;
        if let oldCoord = prevLoc?.coordinate {
            if counter > 10 {
                var area = [newCoord,oldCoord];
                let polyline = MKPolyline(coordinates: &area, count: 2)
                mapView.add(polyline);
                if counter%30 == 0{
                let iotDataManager = AWSIoTDataManager.default()
                iotDataManager.publishString("\(long),\(lat)", onTopic: "location", qoS:.messageDeliveryAttemptedAtMostOnce)
                }
            }
        }
        counter += 1;
        prevLoc = userLocation;
    }
    
    //http://stackoverflow.com/questions/39695853/clgeocodecompletionhandler-ios-swift3
    class func getMapByAddress(_ locationMap:MKMapView?, address:String?, title: String?, subtitle: String?)
    {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address!, completionHandler: {(placemarks, error) -> Void in
            if let validPlacemark = placemarks?[0]{
                print(validPlacemark.location?.coordinate)
                
                let span = MKCoordinateSpanMake(0.05, 0.05)
                let region = MKCoordinateRegion(center: (validPlacemark.location?.coordinate)!, span: span)
                locationMap?.setRegion(region, animated: true)
                
                let annotation = MKPointAnnotation()
                annotation.coordinate = (validPlacemark.location?.coordinate)!
                annotation.title = title
                annotation.subtitle = subtitle
                locationMap?.addAnnotation(annotation)
            }
            
        })
    }

    
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        print("\(sender.value)")
        
        let iotDataManager = AWSIoTDataManager.default()
        let tabBarViewController = tabBarController as! IoTSampleTabBarController
        
        iotDataManager.publishString("\(sender.value)", onTopic:tabBarViewController.topic, qoS:.messageDeliveryAttemptedAtMostOnce)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        // if (overlay is MKPolyline) {
            print("map update")
            let pr = MKPolylineRenderer(overlay: overlay)
            pr.strokeColor = UIColor.darkGray
            pr.lineWidth = 5
            return pr
//        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("ERR");
        print(error);
    }

    override func viewWillDisappear(_ animated: Bool) {
        let iotDataManager = AWSIoTDataManager.default()
        let tabBarViewController = tabBarController as! IoTSampleTabBarController
        iotDataManager.unsubscribeTopic(tabBarViewController.topic)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

