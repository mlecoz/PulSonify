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

class Uke1 : Sound {
    var rateRelativeToHeartBeat: Int = 1
    var isPlaying: Bool = false
    var mixer = AKMixer()
    var file: String
    
    init(file: String) {
        self.file = file
    }
    
    func makePlayer(file: String) -> AKAudioPlayer? {
        do {
            
            let uke = try AKAudioFile(readFileName: file)
            
            do {
                let player = try AKAudioPlayer(file: uke)
                player.looping = false
                return player
            }
            catch {
                print("Problem making AKAudioPlayer from audio file")
                return nil
            }
        }
        catch {
            print("Problem converting audio file to audio file type")
            return nil
        }
    }
    
    func play() {
        if !mixer.isStarted {
            mixer.start()
        }
        let player = makePlayer(file: file)
        mixer.connect(input: player)
        player?.start()
    }
    func stop() {
        mixer.stop()
    }
    
}
