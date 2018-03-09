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
import CloudKit

class ViewController: UIViewController {
    
    // sounds
    var beep = false
    
    let MAX_BPM = 200
    
    let oscillator = AKOscillator()
    
    let healthStore = HKHealthStore()

    var db = CKContainer.default().publicCloudDatabase
    var container = CKContainer.default()
    
    var ckUserId: CKRecordID?
    var lastDate: Date?
    
    var bpmArray = [Double]()
    
    var currentRoundedBpm: Int? { // rounded to the 100th of a ms
        didSet {
            print("last bpm changed")
        }
    }
    
    var currentMillisecLoopNum = 0
    
    var beepIsOn = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.container.fetchUserRecordID() { userRecordID, err in
            if err == nil {
                self.ckUserId = userRecordID
                print("Successfully fetched user record id")
                
            }
            else {
                print("\(err!)")
            }
        }
    }
    
    func queryRecords(since lastDate: Date) {
        
        let predicate = NSPredicate(format: "%K > %@", "creationDate", lastDate as CVarArg) // TODO: filter by the user as well, if this were to go to the app store
        let query = CKQuery(recordType: "HeartRateSample", predicate: predicate)
        let sort = NSSortDescriptor(key: "creationDate", ascending: true)
        query.sortDescriptors = [sort]
        self.db.perform(query, inZoneWith: nil) { records, error in
            if error == nil {
                guard let records = records else { return }
                for record in records {
                    guard let bpm = record.object(forKey: "bpm") as? Double else { return }
                    self.bpmArray.append(bpm)
                }
                if records.count > 0 {
                    guard let date = records[records.count - 1].object(forKey: "creationDate") as? Date else { return }
                    self.lastDate = date
                }
                else {
                    self.lastDate = Date()
                }
            }
            else {
                print("\(error!)")
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func playSound(_ sender: UIButton) {
        
        self.lastDate = Date()
        
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            guard let date = self.lastDate else { return }
            self.queryRecords(since: date)
        }
        
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in // every 100 milliseconds
            
            self.currentMillisecLoopNum = self.currentMillisecLoopNum + 1
            
            guard let currRoundedBpm = self.currentRoundedBpm else { return }
            
            // fires on every heart beat and beep is turned on => beep on each heart beat
            if (self.currentMillisecLoopNum * 100) % currRoundedBpm == 0 && self.beep {
                
            }
        }
        
//        AudioKit.output = oscillator
//        AudioKit.start()
//        oscillator.start()
//
//        var i = 0
//        while i < 5 {
//            oscillator.frequency = random(in: 220...880)
//            i = i + 1
//            sleep(1)
//        }
//        oscillator.stop()
        
    }
    @IBAction func stopSound(_ sender: UIButton) {
        oscillator.stop()
    }
    
    func fireInterval(bpm: Double) -> Double {
        return 60.0 / bpm * 1000 // interval between beats, in ms
    }
    
    @IBOutlet weak var beepSwitch: UISwitch!
    @IBAction func beepSwitchIsToggled(_ sender: UISwitch) {
        self.beep = sender.isOn
    }
    
    func playBeep() {
        
        AudioKit.output = oscillator
        AudioKit.start()
        oscillator.start()
        oscillator.frequency = random(in: 220...880)
        // sleep
        //oscillator.stop()
        
    }
    
}

