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
    let randNote = Arpeggio()
    let maraca = Maraca()
    let drip = Drip()
    let ukeCGAmF = CustomSound(file: "CGAmF.wav", rate: 1)
    let singing = CustomSound(file: "Latin3.wav", rate: 1)
    let cramproll = CustomSound(file: "Cramproll.wav", rate: 3)
    let flap = CustomSound(file: "Flap.wav", rate: 2)
    let perrydiddle = CustomSound(file: "Perrydiddle.wav", rate: 4)
    let doubleShuffle = CustomSound(file: "Shuffle-shuffle.wav", rate: 5)
    let brush = CustomSound(file: "Slide.wav", rate: 3)
    let click = CustomSound(file: "Click2.wav", rate: 3)
    let bells = Bells()
    
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
                             self.ukeCGAmF.mixer,
                             self.singing.mixer,
                             self.cramproll.mixer,
                             self.flap.mixer,
                             self.perrydiddle.mixer,
                             self.doubleShuffle.mixer,
                             self.brush.mixer,
                             self.click.mixer,
                             self.bells.bells)
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
            if self.singing.isPlaying && (self.currentMillisecLoopNum * self.INTERVAL_ROUNDING_VALUE) % (self.singing.rateRelativeToHeartBeat * fireInterval) == 0 {
                self.singing.play()
            }
            if self.cramproll.isPlaying && (self.currentMillisecLoopNum * self.INTERVAL_ROUNDING_VALUE) % (self.cramproll.rateRelativeToHeartBeat * fireInterval) == (self.INTERVAL_ROUNDING_VALUE) { // play on an offset of 100ms
                self.cramproll.play()
            }
            if self.flap.isPlaying && (self.currentMillisecLoopNum * self.INTERVAL_ROUNDING_VALUE) % (self.flap.rateRelativeToHeartBeat * fireInterval) == 0 {
                self.flap.play()
            }
            if self.perrydiddle.isPlaying && (self.currentMillisecLoopNum * self.INTERVAL_ROUNDING_VALUE) % (self.perrydiddle.rateRelativeToHeartBeat * fireInterval) == 0 {
                self.perrydiddle.play()
            }
            if self.doubleShuffle.isPlaying && (self.currentMillisecLoopNum * self.INTERVAL_ROUNDING_VALUE) % (self.doubleShuffle.rateRelativeToHeartBeat * fireInterval) == 0 {
                self.doubleShuffle.play()
            }
            if self.brush.isPlaying && (self.currentMillisecLoopNum * self.INTERVAL_ROUNDING_VALUE) % (self.brush.rateRelativeToHeartBeat * fireInterval) == 0 {
                self.brush.play()
            }
            if self.click.isPlaying && (self.currentMillisecLoopNum * self.INTERVAL_ROUNDING_VALUE) % (self.click.rateRelativeToHeartBeat * fireInterval) == 0 {
                self.click.play()
            }
            if self.bells.isPlaying && (self.currentMillisecLoopNum * self.INTERVAL_ROUNDING_VALUE) % (self.bells.rateRelativeToHeartBeat * fireInterval) == (self.INTERVAL_ROUNDING_VALUE) { // offset 100ms
                self.bells.play()
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
    @IBAction func beepSwitchIsToggled(_ sender: UISwitch) { // actually arpeggio
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
    
    @IBOutlet weak var ukeSwitch: UISwitch!
    @IBAction func ukeSwitchIsToggled(_ sender: UISwitch) {
        self.ukeCGAmF.isPlaying = sender.isOn
        if !sender.isOn {
            self.ukeCGAmF.stop()
        }
    }
    
    @IBOutlet weak var singingSwitch: UISwitch!
    @IBAction func singingSwitchIsToggled(_ sender: UISwitch) {
        self.singing.isPlaying = sender.isOn
        if !sender.isOn {
            self.singing.stop()
        }
    }
    
    @IBOutlet weak var cramprollSwitch: UISwitch!
    @IBAction func cramprollSwitchIsToggled(_ sender: UISwitch) {
        self.cramproll.isPlaying = sender.isOn
        if !sender.isOn {
            self.cramproll.stop()
        }
    }

    @IBOutlet weak var shufflesSwitch: UISwitch!
    @IBAction func shufflesSwitchIsToggled(_ sender: UISwitch) {
        self.doubleShuffle.isPlaying = sender.isOn
        if !sender.isOn {
            self.doubleShuffle.stop()
        }
    }
    
    @IBOutlet weak var perrydiddleSwitch: UISwitch!
    @IBAction func perrydiddleSwitchIsToggled(_ sender: UISwitch) {
        self.perrydiddle.isPlaying = sender.isOn
        if !sender.isOn {
            self.perrydiddle.stop()
        }
    }
    
    @IBOutlet weak var flapSwitch: UISwitch!
    @IBAction func flapSwitchIsToggled(_ sender: UISwitch) {
        self.flap.isPlaying = sender.isOn
        if !sender.isOn {
            self.flap.stop()
        }
    }
    
    @IBOutlet weak var brushSwitch: UISwitch!
    @IBAction func brushSwitchIsToggled(_ sender: UISwitch) {
        self.brush.isPlaying = sender.isOn
        if !sender.isOn {
            self.brush.stop()
        }
    }

    @IBOutlet weak var clickSwitch: UISwitch!
    @IBAction func clickSwitchIsToggled(_ sender: UISwitch) {
        self.click.isPlaying = sender.isOn
        if !sender.isOn {
            self.click.stop()
        }
    }
    
    @IBOutlet weak var bellsSwitch: UISwitch!
    @IBAction func bellsSwitchIsToggled(_ sender: UISwitch) {
        self.bells.isPlaying = sender.isOn
        if !sender.isOn {
            self.bells.stop()
        }
    }
    
}

