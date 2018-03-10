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

class RandomNote : Sound {
    var rateRelativeToHeartBeat: Int = 1
    var isPlaying: Bool = false
    var oscillator = AKOscillator()
    func play() {
        //guard let osc = node as? AKOscillator else { return }
        self.oscillator.frequency = random(in: 220...880)
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
        shaker.trigger(amplitude: 3.0)
    }
    func stop() {
        self.shaker.stop()
    }
}
