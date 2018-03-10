//
//  CloudKitManager.swift
//  PulseVisualizer
//
//  Created by Marissa Le Coz on 3/9/18.
//  Copyright © 2018 Marissa Le Coz. All rights reserved.
//

import Foundation
import CloudKit

class CloudKitManager {
    
    private var db = CKContainer.default().publicCloudDatabase
    private var container = CKContainer.default()
    private var ckUserId: CKRecordID?
    
    // not actually using this right now
    // but if I had more than 1 user, I'd want to include the user id in the CloudKit query
    private func fetchUserRecordId() {
        self.container.fetchUserRecordID() { userRecordID, err in
            if err == nil {
                self.ckUserId = userRecordID
                print("Successfully fetched user record id")
            }
            else {
                print("\(err!)")
            }
        }
    }
    
    func queryRecords(since lastDate: Date, bpmDidChange: @escaping (_ mostRecentRecordInBatch: CKRecord?, _ date: Date) -> Void, bpmDidNotChange: @escaping (_ date: Date) -> Void) {
        
        let predicate = NSPredicate(format: "%K > %@", "creationDate", lastDate as CVarArg) // TODO: filter by the user as well if more users than just me
        let query = CKQuery(recordType: "HeartRateSample", predicate: predicate)
        let sort = NSSortDescriptor(key: "creationDate", ascending: true)
        query.sortDescriptors = [sort]
        self.db.perform(query, inZoneWith: nil) { records, error in
            if error == nil {
                guard let records = records else { return }
                
                // resurrect this if I for some reason do indeed want a list of all bpm's as they come in (most recent is all i need for my purposes right now)
//                for record in records {
//                    guard let bpm = record.object(forKey: "bpm") as? Int else { return }
//                    self.bpmArray.append(bpm)
//                }
                
                if records.count > 0 {
                    guard let date = records[records.count - 1].object(forKey: "creationDate") as? Date else { return }
                    bpmDidChange(records[records.count-1], date)
                }
                else {
                    bpmDidNotChange(Date())
                }
            }
            else {
                print("\(error!)")
            }
        }
    }
    
    
    
}
