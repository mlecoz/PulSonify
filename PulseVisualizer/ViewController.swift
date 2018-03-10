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
    
    // CONSTANTS
    let INTERVAL_ROUNDING_VALUE = 100 // intervals (in ms) should be rounded to the nearest <this value>
    let MS_IN_SEC = 1000
    let SEC_IN_MIN = 60.0
    
    // SOUND BOOLEANS - indicates whether or not they're on
    var beep = false
    var maraca = false

    // NODES - nodes for each sound type to go into the mixer
    var mixer: AKMixer?
    let oscillator = AKOscillator()
    var maracaShaker = AKShaker()
    
    // CLOUDKIT
    var db = CKContainer.default().publicCloudDatabase
    var container = CKContainer.default()
    var ckUserId: CKRecordID?
    
    // STATE
    var lastDate: Date? // date/time at which CloudKit was last queried for heartbeats
    var bpmArray = [Int]() // keeps track of incoming bpms
    var currentRoundedFireInterval: Int? // rounded to the 100th of a ms
    var currentMillisecLoopNum = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Init mixer and start AudioKit
        self.mixer = AKMixer(self.oscillator, self.maracaShaker)
        AudioKit.output = self.mixer
        AudioKit.start()
        
        // not actually using this right now
        // but if I had more than 1 user, I'd want to include the user id in the CloudKit query
        self.container.fetchUserRecordID() { userRecordID, err in
            if err == nil {
                self.ckUserId = userRecordID
                print("Successfully fetched user record id")
            }
            else {
                print("\(err!)")
            }
        }
        
        // save state
        self.lastDate = Date()
        
        // Timer for checking cloudkit for new heartrate samples
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            guard let date = self.lastDate else { return }
            self.queryRecords(since: date)
        }
        
        // Timer for playing sounds
        Timer.scheduledTimer(withTimeInterval: INTERVAL_ROUNDING_VALUE / MS_IN_SEC, repeats: true) { timer in // every 100 milliseconds
            
            // state
            self.currentMillisecLoopNum = self.currentMillisecLoopNum + 1
            guard let fireInterval = self.currentRoundedFireInterval else { return }
            
            // VARIOUS SOUNDS - check whether they should fire on this invocation of the timer
            // Check:
            // - whether that sound is on
            // - whether the sound should be played in this 100 ms multiple
            // Examples: to play on every other heartbeat, fireInterval * 2; to do an offset, the mod would equal 100, 200, 300, ...
            if self.beep && (self.currentMillisecLoopNum * self.INTERVAL_ROUNDING_VALUE) % fireInterval == 0  { // on every heartbeat
                self.playBeep() // really less of a beep and more of a sustained note
            }
            if self.maraca && (self.currentMillisecLoopNum * self.INTERVAL_ROUNDING_VALUE) % fireInterval == 0 {
                self.playMaraca()
            }
            
            // to account for different rounding values, would want the mod to fall within some range propotional to the size of the rounding value
        }
    }
    
    func queryRecords(since lastDate: Date) {
        
        let predicate = NSPredicate(format: "%K > %@", "creationDate", lastDate as CVarArg) // TODO: filter by the user as well if more users than just me
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
        self.currentRoundedFireInterval = Int(round(fireInterval / Double(INTERVAL_ROUNDING_VALUE)) * INTERVAL_ROUNDING_VALUE)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fireInterval(bpm: Int) -> Double {
        return SEC_IN_MIN / bpm * MS_IN_SEC // interval between beats, in ms
    }
    
    @IBOutlet weak var beepSwitch: UISwitch!
    @IBAction func beepSwitchIsToggled(_ sender: UISwitch) {
        self.beep = sender.isOn
        if !sender.isOn {
            oscillator.stop()
        }
        else {
            oscillator.start() // don't do this (start it somewhere else)
        }
    }
    
    @IBOutlet weak var maracaSwitch: UISwitch!
    @IBAction func maracaSwitchIsToggled(_ sender: UISwitch) {
        self.maraca = sender.isOn
        if !sender.isOn {
            maracaShaker.stop()
        }
    }
    
    
    func playBeep() {
        oscillator.frequency = random(in: 220...880)
    }
    
    func playMaraca() {
        maracaShaker.trigger(amplitude: 3.0)
    }
    
    
}

