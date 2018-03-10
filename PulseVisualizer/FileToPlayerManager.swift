//
//  FileToPlayerManager.swift
//  PulseVisualizer
//
//  Created by Marissa Le Coz on 3/10/18.
//  Copyright © 2018 Marissa Le Coz. All rights reserved.
//

import Foundation
import AudioKit

class FileToPlayerManager {
    
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

}
