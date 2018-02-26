//
//  HealthStoreManager.swift
//  PulseVisualizer WatchKit Extension
//
//  This file is from sample Workout App provided by Apple. Modifications mine.
//  https://developer.apple.com/library/content/samplecode/SpeedySloth/Introduction/Intro.html#//apple_ref/doc/uid/TP40017338-Intro-DontLinkElementID_2
//

/*
 See LICENSE.txt for this sample’s licensing information.
 
 Abstract:
 Manager for reading from and saving data into HealthKit
 */

import WatchKit
import HealthKit
import CoreLocation

class HealthStoreManager: NSObject, CLLocationManagerDelegate {
    
    // MARK: - Properties
    
    var workoutEvents = [HKWorkoutEvent]()
    var totalDistance: Double = 0
    
    private let healthStore = HKHealthStore()
    private var activeDataQueries = [HKQuery]()
    private var locationManager: CLLocationManager!
    
    // MARK: - Health Store Wrappers
    
    func start(_ workoutSession: HKWorkoutSession) {
        healthStore.start(workoutSession)
    }
    
    func end(_ workoutSession: HKWorkoutSession) {
        healthStore.end(workoutSession)
    }
    
    func pause(_ workoutSession: HKWorkoutSession) {
        healthStore.pause(workoutSession)
    }
    
    func resume(_ workoutSession: HKWorkoutSession) {
        healthStore.resumeWorkoutSession(workoutSession)
    }
    
    // MARK: - Data Accumulation
    
    func startWalkingRunningQuery(from startDate: Date, updateHandler: @escaping ([HKQuantitySample]) -> Void) {
        let typeIdentifier = HKQuantityTypeIdentifier.distanceWalkingRunning
        startQuery(ofType: typeIdentifier, from: startDate) { _, samples, _, _, error in
            guard let quantitySamples = samples as? [HKQuantitySample] else {
                print("Distance walking running query failed with error: \(String(describing: error))")
                return
            }
            updateHandler(quantitySamples)
        }
    }
    
    func startActiveEnergyBurnedQuery(from startDate: Date, updateHandler: @escaping ([HKQuantitySample]) -> Void) {
        let typeIdentifier = HKQuantityTypeIdentifier.activeEnergyBurned
        startQuery(ofType: typeIdentifier, from: startDate) { _, samples, _, _, error in
            guard let quantitySamples = samples as? [HKQuantitySample] else {
                print("Active energy burned query failed with error: \(String(describing: error))")
                return
            }
            updateHandler(quantitySamples)
        }
    }
    
    func stopAccumulatingData() {
        for query in activeDataQueries {
            healthStore.stop(query)
        }
        activeDataQueries.removeAll()
        
        locationManager?.stopUpdatingLocation()
    }
    
    private func startQuery(ofType type: HKQuantityTypeIdentifier, from startDate: Date, handler: @escaping
        (HKAnchoredObjectQuery, [HKSample]?, [HKDeletedObject]?, HKQueryAnchor?, Error?) -> Void) {
        let datePredicate = HKQuery.predicateForSamples(withStart: startDate, end: nil, options: .strictStartDate)
        let devicePredicate = HKQuery.predicateForObjects(from: [HKDevice.local()])
        let queryPredicate = NSCompoundPredicate(andPredicateWithSubpredicates:[datePredicate, devicePredicate])
        
        let quantityType = HKObjectType.quantityType(forIdentifier: type)!
        
        let query = HKAnchoredObjectQuery(type: quantityType, predicate: queryPredicate, anchor: nil,
                                          limit: HKObjectQueryNoLimit, resultsHandler: handler)
        query.updateHandler = handler
        healthStore.execute(query)
        
        activeDataQueries.append(query)
    }
    
    // MARK: - Saving Data
    
//    func saveWorkout(withSession workoutSession: HKWorkoutSession, from startDate: Date, to endDate: Date) {
//        // Create and save a workout sample
//        let configuration = workoutSession.workoutConfiguration
//        var metadata = [String: Any]()
//        metadata[HKMetadataKeyIndoorWorkout] = (configuration.locationType == .indoor)
//
//        let workout = HKWorkout(activityType: configuration.activityType,
//                                start: startDate,
//                                end: endDate,
//                                workoutEvents: workoutEvents,
//                                totalEnergyBurned: totalEnergyBurnedQuantity(),
//                                totalDistance: totalDistanceQuantity(),
//                                metadata: metadata)
//
//        healthStore.save(workout) { success, _ in
//            if success {
//                self.addSamples(toWorkout: workout, from: startDate, to: endDate)
//            }
//        }
//    }
    
//    private func addSamples(toWorkout workout: HKWorkout, from startDate: Date, to endDate: Date) {
        // Create energy and distance samples
//        let totalEnergyBurnedSample = HKQuantitySample(type: HKQuantityType.activeEnergyBurned(),
//                                                       quantity: totalEnergyBurnedQuantity(),
//                                                       start: startDate,
//                                                       end: endDate)
//
//        let totalDistanceSample = HKQuantitySample(type: HKQuantityType.distanceWalkingRunning(),
//                                                   quantity: totalDistanceQuantity(),
//                                                   start: startDate,
//                                                   end: endDate)
//
        // Add samples to workout
//        healthStore.add([totalEnergyBurnedSample, totalDistanceSample], to: workout) { (success: Bool, error: Error?) in
//            guard success else {
//                print("Adding workout subsamples failed with error: \(String(describing: error))")
//                return
//            }
//
//            // Samples have been added
//            DispatchQueue.main.async {
//                WKInterfaceController.reloadRootPageControllers(withNames: ["SummaryInterfaceController"],
//                                                                contexts: [workout],
//                                                                orientation: .vertical,
//                                                                pageIndex: 0)
//            }
//        }
//    }
//
    // MARK: - Convenience
    
    func processWalkingRunningSamples(_ samples: [HKQuantitySample]) {
        totalDistance = samples.reduce(totalDistance) { (total, sample) in
            total + sample.quantity.doubleValue(for: .meter())
        }
    }
}
