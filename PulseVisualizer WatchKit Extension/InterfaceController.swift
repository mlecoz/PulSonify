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


class InterfaceController: WKInterfaceController, HKWorkoutSessionDelegate {
    
    @IBOutlet var bpm: WKInterfaceLabel!
//    let healthStoreManager = HealthStoreManager()
    let healthStore = HKHealthStore()
    var workoutSession: HKWorkoutSession?
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        print("here")
        
        if HKHealthStore.isHealthDataAvailable() {
            if toState == .running {
                if let query = createHeartRateStreamingQuery() {
                    self.healthStore.execute(query)
                }
            }
        }
        else {
            print("Healthkit unavailable")
        }
        
        
        
//            let heartRate = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!
//            let query = HKSampleQuery(sampleType: heartRate, predicate: .none, limit: 0, sortDescriptors: nil) { query, results, error in
//
//                guard let count = results?.count else { return }
//                if count > 0 {
//                    guard let results = results as? [HKQuantitySample] else { return }
//                    for result in results {
//                        let heartRate = result.quantity.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute()))
//                        self.bpm.setText(String(heartRate))
//                    }
//                }
//            }
//            self.healthStore.execute(query)
        
        
        
        
        
        
        
            
//            let datePredicate = HKQuery.predicateForSamples(withStart: Date(), end: nil, options: .strictStartDate)
//            let devicePredicate = HKQuery.predicateForObjects(from: [HKDevice.local()])
//            let queryPredicate = NSCompoundPredicate(andPredicateWithSubpredicates:[datePredicate, devicePredicate])
//            let quantityType = HKObjectType.quantityType(forIdentifier: .heartRate)!
//
//            let query = HKAnchoredObjectQuery(type: quantityType, predicate: queryPredicate, anchor: nil,
//                                              limit: HKObjectQueryNoLimit) { (query, samplesOrNil, deletedObjectsOrNil, newAnchor, errorOrNil) in
//
//                                                guard let heartSamples = samplesOrNil else { return }
//                                                for heartSample in heartSamples {
//                                                    self.bpm.setText(String(heartSample))
//                                                }
//            }
////            query.updateHandler = handler
//            self.healthStore.execute(query)
            
            
            
//            startQuery(ofType: typeIdentifier, from: Date()) { _, samples, _, _, error in
//                guard let quantitySamples = samples as? [HKQuantitySample] else {
//                    print("Distance walking running query failed with error: \(String(describing: error))")
//                    return
//                }
//                updateHandler(quantitySamples)
//            }
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        print("Workout session failure")
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        workoutSession?.delegate = self
//        let workoutConfiguration = HKWorkoutConfiguration()
//        workoutConfiguration.activityType = .other
//        workoutConfiguration.locationType = .unknown
//
//        do {
//            try self.workoutSession = HKWorkoutSession(configuration: workoutConfiguration)
//        }
//        catch {
//            fatalError(error.localizedDescription)
//        }
        
//        guard let workoutSession = self.workoutSession else { return }
//        self.healthStoreManager.start(workoutSession)
//
//        let bpmType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)
        
        
//        let sampleType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!
//
//        let query = HKObserverQuery(sampleType: sampleType, predicate: nil) { query, completionHandler, error in
//
//            if error != nil {
//
//                // Perform Proper Error Handling Here...
//                print("\(error.localizedDescription)")
//                abort()
//            }
//
//            // Take whatever steps are necessary to update your app's data and UI
//            // This may involve executing other queries
////            self.updateDailyStepCount()
//            self.bpm.setText()
//
//            // If you have subscribed for background updates you must call the completion handler here.
//            // completionHandler()
//        }
//
//        healthStore.executeQuery(query)
        
        
        
        
    }
    
    // from https://github.com/coolioxlr/watchOS-2-heartrate/blob/master/VimoHeartRate%20WatchKit%20App%20Extension/InterfaceController.swift
    func createHeartRateStreamingQuery() -> HKQuery? {
        
        if !HKHealthStore.isHealthDataAvailable() {
            print("health data not available")
        }
        
        guard let quantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate) else { return nil }
        
        let heartRateQuery = HKAnchoredObjectQuery(type: quantityType, predicate: nil, anchor: nil, limit: Int(HKObjectQueryNoLimit)) { (query, sampleObjects, deletedObjects, newAnchor, error) -> Void in
//            guard let newAnchor = newAnchor else {return}
//            self.anchor = newAnchor
            self.updateHeartRate(samples: sampleObjects)
        }
        
        heartRateQuery.updateHandler = {(query, samples, deleteObjects, newAnchor, error) -> Void in
//            self.anchor = newAnchor!
            self.updateHeartRate(samples: samples)
        }
        return heartRateQuery
    }
    
    // from https://github.com/coolioxlr/watchOS-2-heartrate/blob/master/VimoHeartRate%20WatchKit%20App%20Extension/InterfaceController.swift
    func updateHeartRate(samples: [HKSample]?) {
        guard let heartRateSamples = samples as? [HKQuantitySample] else {return}
        
        DispatchQueue.main.async() {
            guard let sample = heartRateSamples.first else { return }
            let value = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
            self.bpm.setText(String(UInt16(value)))
        }
    }
    
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
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
        
        do {
            try self.workoutSession = HKWorkoutSession(configuration: workoutConfiguration)
            healthStore.start(self.workoutSession!)
        }
        catch {
            fatalError(error.localizedDescription)
        }
        
        if HKHealthStore.isHealthDataAvailable() {
            if let query = createHeartRateStreamingQuery() {
                self.healthStore.execute(query)
            }
        }
        else {
            print("Healthkit unavailable")
        }
        
        
        
//        let heartRate = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!
//        let query = HKSampleQuery(sampleType: heartRate, predicate: .none, limit: 0, sortDescriptors: nil) { query, results, error in
//
//            guard let count = results?.count else { return }
//            if count > 0 {
//                guard let results = results as? [HKQuantitySample] else { return }
//                for result in results {
//                    let heartRate = result.quantity.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute()))
//                    self.bpm.setText(String(heartRate))
//                }
//            }
//        }
//        self.healthStore.execute(query)
        
    }
    
    @IBAction func stopIsTapped() {
        guard let sess = self.workoutSession else { return }
        healthStore.end(sess)
    }
    
}
