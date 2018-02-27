//
//  InterfaceController.swift
//  PulseVisualizer WatchKit Extension
//
//  Created by Marissa Le Coz on 2/20/18.
//  Copyright © 2018 Marissa Le Coz. All rights reserved.
//

import WatchKit
import Foundation
import HealthKit
import WatchConnectivity


class InterfaceController: WKInterfaceController, HKWorkoutSessionDelegate, WCSessionDelegate {
    
    var wcSession: WCSession?
    
    @IBOutlet var bpm: WKInterfaceLabel!
    let healthStore = HKHealthStore()
    var workoutSession: HKWorkoutSession?
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("WC activation did complete")
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        print("here")
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        print("Workout session failure")
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        workoutSession?.delegate = self
        
        guard let wcSess = self.wcSession else { return }
        wcSess.delegate = self
        wcSess.activate()
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
            self.bpm.setText(String(UInt16(value)))
        }
        
        let dataToSendToPhone = ["bpm":String(value)]
        
        self.wcSession?.sendMessage(dataToSendToPhone, replyHandler: nil) { error in
            print("\(error.localizedDescription)")
        }
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        if WCSession.isSupported() {
            wcSession = WCSession.default
            wcSession?.delegate = self
            wcSession?.activate()
        }
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    @IBOutlet var recordButton: WKInterfaceButton!
    
    
    @IBAction func recordIsTapped() {
        
        let workoutConfiguration = HKWorkoutConfiguration()
        workoutConfiguration.activityType = .other
        workoutConfiguration.locationType = .unknown
        
        // Inspired by https://developer.apple.com/library/content/samplecode/SpeedySloth/Introduction/Intro.html
        do {
            try self.workoutSession = HKWorkoutSession(configuration: workoutConfiguration)
            healthStore.start(self.workoutSession!)
            if HKHealthStore.isHealthDataAvailable() {
                if let query = createHeartRateStreamingQuery() {
                    self.healthStore.execute(query)
                }
            }
            else {
                print("Healthkit unavailable")
            }
        }
        catch {
            fatalError(error.localizedDescription)
        }
        
    }
    
    @IBAction func stopIsTapped() {
        guard let sess = self.workoutSession else { return }
        self.bpm.setText("BPM")
        healthStore.end(sess)
    }
    
}
