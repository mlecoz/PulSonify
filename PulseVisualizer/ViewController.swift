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
    
    let oscillator = AKOscillator()
    
    let healthStore = HKHealthStore()
    
    // Watch Connectivity help from https://kristina.io/watchos-2-tutorial-using-sendmessage-for-instantaneous-data-transfer-watch-connectivity-1/
    var wcSession: WCSession?
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("WC was activated")
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("WC has become inactive")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        print("WC was deactivated")
    }
    
    private func session(session: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: ([String : AnyObject]), -&gt; Void) {
        let bpm = message["bpm"] as? String
        
        //Use this to update the UI instantaneously (otherwise, takes a little while)
        dispatch_async(dispatch_get_main_queue()) {
            self.counterData.append(counterValue!)
            self.mainTableView.reloadData()
        }
    }
    

    
    
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

