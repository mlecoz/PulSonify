//
//  ViewController.swift
//  PulseVisualizer
//
//  Created by Marissa Le Coz on 2/20/18.
//  Copyright © 2018 Marissa Le Coz. All rights reserved.
//

import UIKit
import AudioKit

class ViewController: UIViewController {

    let oscillator = AKOscillator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func playSound(_ sender: UIButton) {
        
        AudioKit.output = oscillator
        AudioKit.start()
        oscillator.start()
        
        var i = 0
        while i < 5 {
            oscillator.frequency = random(in: 220...880)
            i = i + 1
            sleep(1)
        }
        oscillator.stop()
        
    }
    @IBAction func stopSound(_ sender: UIButton) {
        oscillator.stop()
    }
    
}

