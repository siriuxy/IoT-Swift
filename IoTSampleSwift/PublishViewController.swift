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

class PublishViewController: UIViewController {

    @IBOutlet weak var publishSlider: UISlider!

    @IBOutlet weak var subscribedTemp: UIProgressView!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func fanOff(_ sender: Any) {
        let iotDataManager = AWSIoTDataManager.default()
        print("sent val 1 to topic fan_off");
        iotDataManager.publishString("1", onTopic:"fan_off", qoS:.messageDeliveryAttemptedAtMostOnce)

    }

    @IBOutlet weak var tempLabel: UILabel!
    var temp = -100.0;
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    var counter = 0;
    override func viewWillAppear(_ animated: Bool) {
        let iotDataManager = AWSIoTDataManager.default()
        let tabBarViewController = tabBarController as! IoTSampleTabBarController
        let topic = "temperature_feed";
        print(topic)
        iotDataManager.subscribe(toTopic: topic, qoS: .messageDeliveryAttemptedAtMostOnce, messageCallback: {
            (payload) ->Void in
            let stringValue = NSString(data: payload, encoding: String.Encoding.utf8.rawValue)!
            
            print("received: \(stringValue)")
            DispatchQueue.main.async {
                self.subscribedTemp.progress = stringValue.floatValue/80.0
                if (stringValue.floatValue <= -20){
                    self.tempLabel.text = "waiting...";
                }
                else if (stringValue.floatValue >= 30) {
                    self.subscribedTemp.progressTintColor = UIColor.red;
                    if self.counter >= 5 {
                        self.showAlert();
                    }
                        self.counter += 1;
                    self.tempLabel.text = String(stringValue)+" Celsius";
                }
                else
                {
                    self.subscribedTemp.progressTintColor = UIColor.blue;
                    self.counter = 0;
                    self.tempLabel.text = String(stringValue)+" Celsius";
                    self.alertView.dismiss(withClickedButtonIndex: -1, animated: true)
                }
            }
        } )
    }
    
    var alertView = UIAlertView();
    func showAlert() {
        // Initialize Alert View
        alertView = UIAlertView(title: "Alert", message: "Temperature has been consistently high for the last \(counter) seconds", delegate: self, cancelButtonTitle: "Dismiss")

        // Configure Alert View
        alertView.tag = 1
        
        // Show Alert View
        alertView.show()
    }
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        print("\(sender.value)")

        let iotDataManager = AWSIoTDataManager.default()
        let tabBarViewController = tabBarController as! IoTSampleTabBarController

        iotDataManager.publishString("\(sender.value)", onTopic:tabBarViewController.topic, qoS:.messageDeliveryAttemptedAtMostOnce)
    }
}
