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

class ViewController: UIViewController, WCSessionDelegate {
    
    @IBOutlet weak var bpmLabel: UILabel!
    let oscillator = AKOscillator()
    
    let healthStore = HKHealthStore()
    
    var bpmArray = [Double]()
    
    // Watch Connectivity help from https://kristina.io/watchos-2-tutorial-using-sendmessage-for-instantaneous-data-transfer-watch-connectivity-1/
    var wcSession: WCSession?
    
    // WC Session Delegate methods
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("WC was activated")
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("WC has become inactive")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        print("WC was deactivated")
    }
    
    private func session(session: WCSession, didReceiveMessage message: [String : AnyObject]) {
        guard let bpm = message["bpm"] as? Double else { return }
        
        //Use this to update the UI instantaneously (otherwise, takes a little while)
        DispatchQueue.main.async {
            self.bpmArray.append(bpm)
            self.bpmLabel.text = String(bpm)
        }
        
        // send response
        self.wcSession?.sendMessage(["all good":"true"], replyHandler: { dataDictionary in
            print("phone told watch it received data")
        }, errorHandler: { error in
            print("\(error.localizedDescription)")
            
        })
    }
    //////////////////////////////
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if WCSession.isSupported() {
            wcSession = WCSession.default
            wcSession?.delegate = self
            wcSession?.activate()
        }
        
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

