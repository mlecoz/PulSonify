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
    
    let mixer = AKMixer()
    
    // sounds
    var beep = false
    var test = false
    
    var isFirstTime = true
    
    let MAX_BPM = 200
    
    let oscillator = AKOscillator()
    let shaker = AKShaker()
    
    let healthStore = HKHealthStore()

    var db = CKContainer.default().publicCloudDatabase
    var container = CKContainer.default()
    
    var ckUserId: CKRecordID?
    var lastDate: Date?
    
    var bpmArray = [Int]()
    
    var currentRoundedFireInterval: Int? // rounded to the 100th of a ms
    
    var isPaused = false
    
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
        
//        AudioKit.start()
        self.lastDate = Date()
        
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            guard let date = self.lastDate else { return }
            self.queryRecords(since: date)
        }
            
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in // every 100 milliseconds
            
            self.currentMillisecLoopNum = self.currentMillisecLoopNum + 1
            
            guard let fireInterval = self.currentRoundedFireInterval else { return }
            
//            guard !self.isPaused else { return } // stop right here if we're paused. do not generate any sounds
            
            // fires on every heart beat and beep is turned on => beep on each heart beat
            if (self.currentMillisecLoopNum * 100) % fireInterval == 0 && self.beep { //&& !self.isPaused {
                self.playBeep()
            }
            if (self.currentMillisecLoopNum * 100) % fireInterval == 0 && self.test { //&& !self.isPaused {
                self.playTest()
            }
            // to play every other, fireInterval * 2
            // to do an offset, the mod would equal 100, 200, 300, ...
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
                    guard let bpm = record.object(forKey: "bpm") as? Int else { return }
                    self.bpmArray.append(bpm)
                }
                if records.count > 0 {
                    guard let date = records[records.count - 1].object(forKey: "creationDate") as? Date else { return }
                    self.lastDate = date
                    self.bpmDidChange(mostRecentRecordInBatch: records[records.count-1])
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
    
    func bpmDidChange(mostRecentRecordInBatch: CKRecord) {
        guard let bpm = mostRecentRecordInBatch.object(forKey: "bpm") as? Int else { return }
        let fireInterval = self.fireInterval(bpm: bpm)
        self.currentRoundedFireInterval = Int(round(fireInterval / 100.0) * 100) // round to nearest 100 milliseconds
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func playSound(_ sender: UIButton) {
        
//        if AudioKit.output != nil {
//            AudioKit.start()
//        }
//        self.isPaused = false
//        self.lastDate = Date()
//
//        if isFirstTime {
//            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
//                guard let date = self.lastDate else { return }
//                self.queryRecords(since: date)
//            }
//
//            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in // every 100 milliseconds
//
//                self.currentMillisecLoopNum = self.currentMillisecLoopNum + 1
//
//                guard let fireInterval = self.currentRoundedFireInterval else { return }
//
//                guard !self.isPaused else { return } // stop right here if we're paused. do not generate any sounds
//
//                // fires on every heart beat and beep is turned on => beep on each heart beat
//                if (self.currentMillisecLoopNum * 100) % fireInterval == 0 && self.beep && !self.isPaused {
//                    self.playBeep()
//                }
//                if (self.currentMillisecLoopNum * 100) % fireInterval == 0 && self.test && !self.isPaused {
//                    self.playTest()
//                }
//                // to play every other, fireInterval * 2
//                // to do an offset, the mod would equal 100, 200, 300, ...
//            }
//        }
//
//        self.isFirstTime = false
//
////        AudioKit.output = oscillator
////        AudioKit.start()
////        oscillator.start()
////
////        var i = 0
////        while i < 5 {
////            oscillator.frequency = random(in: 220...880)
////            i = i + 1
////            sleep(1)
////        }
////        oscillator.stop()
//
    }
    @IBAction func stopSound(_ sender: UIButton) {
//        self.isPaused = true
//        //oscillator.stop()
//        AudioKit.stop()
//        self.bpmArray.removeAll()
//        self.currentMillisecLoopNum = 0
//        self.currentRoundedFireInterval = nil
//        self.lastDate = nil
    }
    
    func fireInterval(bpm: Int) -> Double {
        return 60.0 / bpm * 1000 // interval between beats, in ms
    }
    
    @IBOutlet weak var beepSwitch: UISwitch!
    @IBAction func beepSwitchIsToggled(_ sender: UISwitch) {
        self.beep = sender.isOn
    }
    
    func playBeep() {
        if !oscillator.isPlaying {
            AudioKit.output = oscillator
            AudioKit.start()
            oscillator.start()
        }
        oscillator.frequency = random(in: 220...880)
        // sleep
        //oscillator.stop()
        
    }
    
    func playTest() {
//        if !shaker.isPlaying {
        AudioKit.output = shaker
        AudioKit.start()
        shaker.start()
//        }
        usleep(50) // half second i think
        shaker.stop()
        
    }
    
    
    @IBAction func testSwitchIsChanged(_ sender: UISwitch) {
        self.test = sender.isOn
        if !sender.isOn {
            oscillator.stop()
        }
    }
    
}

