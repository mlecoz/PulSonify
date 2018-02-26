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
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        //self.bpm.setText()
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        print("Workout session")
    }
    

    @IBOutlet var bpm: WKInterfaceLabel!
    
    let healthStoreManager = HealthStoreManager()
    let healthStore = HKHealthStore()
    var workoutSession: HKWorkoutSession?
    
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
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
        }
        catch {
            fatalError(error.localizedDescription)
        }
    }
    
}
