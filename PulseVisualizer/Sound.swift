//
//  Sound.swift
//  PulseVisualizer
//
//  Created by Marissa Le Coz on 3/9/18.
//  Copyright © 2018 Marissa Le Coz. All rights reserved.
//

import Foundation
import AudioKit

protocol Sound {
    
    // 1 would mean this sound occurs on every heartbeat. 2 would mean every other heartbeat. and so on.
    var rateRelativeToHeartBeat: Int { get set }
    var isPlaying: Bool { get set }
    func play()
    func stop()
    
}

class RandomNote : Sound { // now plays a triad instead of random notes
    let C_FREQ = 261.63
    let E_FREQ = 329.63
    let G_FREQ = 392.0
    let C_FREQ2 = 523.25
    var rateRelativeToHeartBeat: Int = 1
    var isPlaying: Bool = false
    var oscillator = AKOscillator()
    var currentNoteNum = 1
    func play() {
        
        // back when this was playing random notes on each heartbeat:
        // self.oscillator.frequency = random(in: 220...880)
        
        if currentNoteNum == 1 {
            self.oscillator.frequency = C_FREQ
            self.currentNoteNum = self.currentNoteNum + 1
        }
        else if currentNoteNum == 2 {
            self.oscillator.frequency = E_FREQ
            self.currentNoteNum = self.currentNoteNum + 1
        }
        else if currentNoteNum == 3 {
            self.oscillator.frequency = G_FREQ
            self.currentNoteNum = self.currentNoteNum + 1
        }
        else if currentNoteNum == 4 {
            self.oscillator.frequency = C_FREQ2
            self.currentNoteNum = 1
        }
        self.oscillator.start()
    }
    func stop() {
        self.oscillator.stop()
    }
}

class Maraca : Sound {
    var rateRelativeToHeartBeat: Int = 1
    var isPlaying: Bool = false
    var shaker = AKShaker()
    func play() {
        self.shaker.trigger(amplitude: 3.0)
    }
    func stop() {
        self.shaker.stop()
    }
}

class Drip: Sound {
    var rateRelativeToHeartBeat: Int = 2
    var isPlaying: Bool = false
    var drip = AKDrip()
    func play() {
        self.drip.dampingFactor = random(in: 10...100)
        self.drip.trigger()
    }
    func stop() {
        self.drip.stop()
    }
}

class CustomSound : Sound {
    var fileToPlayerManager = FileToPlayerManager()
    var rateRelativeToHeartBeat: Int
    var isPlaying: Bool = false
    var mixer = AKMixer()
    var file: String
    
    init(file: String, rate: Int) {
        self.file = file
        self.rateRelativeToHeartBeat = rate
    }
    
    func play() {
        if !mixer.isStarted {
            mixer.start()
        }
        let player = fileToPlayerManager.makePlayer(file: file)
        mixer.connect(input: player)
        player?.start()
    }
    func stop() {
        mixer.stop()
    }
    
}
