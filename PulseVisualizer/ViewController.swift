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
    
    // TO MIX SOUNDS
    var mixer: AKMixer?
    
    // SOUNDS FOR MIXER
    let randNote = RandomNote()
    let maraca = Maraca()
    let drip = Drip()
    let ukeCGAmF = Uke1(file: "CGAmF.wav")
    
    // MANAGERS
    var ckManager = CloudKitManager()
    
    // STATE
    var lastDate: Date? // date/time at which CloudKit was last queried for heartbeats
    var currentRoundedFireInterval: Int? // rounded to the 100th of a ms
    var currentMillisecLoopNum = 0
    //    var bpmArray = [Int]() // keeps track of incoming bpms // <-- NOT USING THIS FOR NOW
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Init mixer and start AudioKit
        self.mixer = AKMixer(self.randNote.oscillator,
                             self.maraca.shaker,
                             self.drip.drip,
                             self.ukeCGAmF.mixer)
        AudioKit.output = self.mixer
        AudioKit.start()
        
        // save state
        self.lastDate = Date() // init
        
        // Timer for checking cloudkit for new heartrate samples
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            guard let date = self.lastDate else { return }
            self.ckManager.queryRecords(since: date, bpmDidChange: { mostRecentRecord, date in
                self.lastDate = date
                self.bpmDidChange(mostRecentRecordInBatch: mostRecentRecord!)
            })
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
            if self.randNote.isPlaying && (self.currentMillisecLoopNum * self.INTERVAL_ROUNDING_VALUE) % (self.randNote.rateRelativeToHeartBeat * fireInterval) == 0  { // on every heartbeat
                self.randNote.play()
            }
            if self.maraca.isPlaying && (self.currentMillisecLoopNum * self.INTERVAL_ROUNDING_VALUE) % (self.maraca.rateRelativeToHeartBeat * fireInterval) == 0 {
                self.maraca.play()
            }
            if self.drip.isPlaying && (self.currentMillisecLoopNum * self.INTERVAL_ROUNDING_VALUE) % (self.drip.rateRelativeToHeartBeat * fireInterval) == 0 {
                self.drip.play()
            }
            if self.ukeCGAmF.isPlaying && (self.currentMillisecLoopNum * self.INTERVAL_ROUNDING_VALUE) % (self.ukeCGAmF.rateRelativeToHeartBeat * fireInterval) == 0 {
                self.ukeCGAmF.play()
            }
            
            // to account for different rounding values, would want the mod to fall within some range propotional to the size of the rounding value
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
    
    
    // IB FUNCTIONS FOR EACH SOUND/TOGGLE
    @IBOutlet weak var beepSwitch: UISwitch! // actually the randNote switch
    @IBAction func beepSwitchIsToggled(_ sender: UISwitch) { // actually the randNote switch
        self.randNote.isPlaying = sender.isOn
        if !sender.isOn {
            self.randNote.stop()
        }
    }
    
    @IBOutlet weak var maracaSwitch: UISwitch!
    @IBAction func maracaSwitchIsToggled(_ sender: UISwitch) {
        self.maraca.isPlaying = sender.isOn
        if !sender.isOn {
            self.maraca.stop()
        }
    }
    
    @IBOutlet weak var dripSwitch: UISwitch!
    @IBAction func dripSwitchIsToggled(_ sender: UISwitch) {
        self.drip.isPlaying = sender.isOn
        if !sender.isOn {
            self.drip.stop()
        }
    }
    
    @IBOutlet weak var ukeCGAmFSwitch: UISwitch!
    @IBAction func ukeCGAmFSwitchIsToggled(_ sender: UISwitch) {
        self.ukeCGAmF.isPlaying = sender.isOn
        if !sender.isOn {
            self.ukeCGAmF.stop()
        }
    }
    
}

