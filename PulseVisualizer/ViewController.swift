//
//  ViewController.swift
//  PulseVisualizer
//
//  Created by Marissa Le Coz on 2/20/18.
//  Copyright © 2018 Marissa Le Coz. All rights reserved.
//

import UIKit
import AudioKit
import HealthKit
import WatchConnectivity

class ViewController: UIViewController, WCSessionDelegate {
    
    @IBOutlet weak var bpmLabel: UILabel!
    let oscillator = AKOscillator()
    
    let healthStore = HKHealthStore()
    
    var bpmArray = [Double]()
    
    // Watch Connectivity help from https://kristina.io/watchos-2-tutorial-using-sendmessage-for-instantaneous-data-transfer-watch-connectivity-1/
    var wcSession: WCSession?
    
    // WC Session Delegate methods
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("WC Session activation failed with error: \(error.localizedDescription)")
            return
        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("WC has become inactive")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        print("WC was deactivated")
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) { //, replyHandler: @escaping ([String : Any]) -> Void) {
        guard let bpm = message["bpm"] as? Double else { return }
        
        //Use this to update the UI instantaneously (otherwise, takes a little while)
        DispatchQueue.main.async {
            self.bpmArray.append(bpm)
            self.bpmLabel.text = String(bpm)
        }
        
//        // send response
//        if (self.wcSession?.isPaired)! && (self.wcSession?.isWatchAppInstalled)! && (self.wcSession?.isReachable)! {
//            let respDict = ["all good":"true"]
//            replyHandler(respDict)
//        }
    }
    
    // modified from https://github.com/coolioxlr/watchOS-2-heartrate/blob/master/VimoHeartRate%20WatchKit%20App%20Extension/InterfaceController.swift
    func createHeartRateStreamingQuery() -> HKQuery? {
        
        if !HKHealthStore.isHealthDataAvailable() {
            print("health data not available")
        }
        
        guard let quantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate) else { return nil }
        
        let heartRateQuery = HKAnchoredObjectQuery(type: quantityType, predicate: nil, anchor: nil, limit: Int(HKObjectQueryNoLimit)) { (query, sampleObjects, deletedObjects, newAnchor, error) -> Void in
            self.updateHeartRate(samples: sampleObjects)
        }
        
        heartRateQuery.updateHandler = {(query, samples, deleteObjects, newAnchor, error) -> Void in
            self.updateHeartRate(samples: samples)
        }
        return heartRateQuery
    }
    
    // modified from https://github.com/coolioxlr/watchOS-2-heartrate/blob/master/VimoHeartRate%20WatchKit%20App%20Extension/InterfaceController.swift
    func updateHeartRate(samples: [HKSample]?) {
        
        guard let heartRateSamples = samples as? [HKQuantitySample] else { return }
        guard let sample = heartRateSamples.first else { return }
        let value = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
        
        DispatchQueue.main.async() {
            self.bpmLabel.text = String(UInt16(value))
        }
    
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if WCSession.isSupported() {
            wcSession = WCSession.default
            wcSession?.delegate = self
            wcSession?.activate()
        }
        
        if !(wcSession?.isPaired)! || !(wcSession?.isWatchAppInstalled)! {
            print("PAIRING PROBLEM")
        }
        
        if HKHealthStore.isHealthDataAvailable() {
            if let query = createHeartRateStreamingQuery() {
                self.healthStore.execute(query)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func playSound(_ sender: UIButton) {
        
        AudioKit.output = oscillator
        AudioKit.start()
        oscillator.start()
        
        var i = 0
        while i < 5 {
            oscillator.frequency = random(in: 220...880)
            i = i + 1
            sleep(1)
        }
        oscillator.stop()
        
    }
    @IBAction func stopSound(_ sender: UIButton) {
        oscillator.stop()
    }
    
}

