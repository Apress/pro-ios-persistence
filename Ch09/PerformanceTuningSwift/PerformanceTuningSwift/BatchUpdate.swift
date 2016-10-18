//
//  BatchUpdate.swift
//  PerformanceTuningSwift
//
//  Created by Rob Warner on 11/5/14.
//  Copyright (c) 2014 Pro iOS Persistence. All rights reserved.
//

import Foundation
import CoreData

class BatchUpdate : PerfTest {
    func runTestWithContext(context: NSManagedObjectContext) -> String! {
        let result = NSMutableString()
        
        // Update all the selfies one at a time
        let fetchRequest = NSFetchRequest(entityName: "Selfie")
        let start1 = NSDate()
        let selfies = context.executeFetchRequest(fetchRequest, error: nil) as [Selfie]
        for selfie in selfies {
            selfie.setValue(5, forKey:"rating")
        }
        context.save(nil)
        let end1 = NSDate()
        result.appendFormat("One-at-a-time update: %.3f s\n", end1.timeIntervalSinceDate(start1))
        
        // Update the selfies as a batch
        
        // Create the batch update request for the Selfie entity
        let batchUpdateRequest = NSBatchUpdateRequest(entityName: "Selfie")
        
        // Set the desired result type to be the count of updated objects
        batchUpdateRequest.resultType = .UpdatedObjectsCountResultType;
        
        // Update the rating property to 7
        batchUpdateRequest.propertiesToUpdate = [ "rating" : 7 ];
        
        // Mark the time and run the update
        let start2 = NSDate()
        let batchUpdateResult = context.executeRequest(batchUpdateRequest, error: nil) as NSBatchUpdateResult
        let end2 = NSDate()
        
        // Record the results
        result.appendFormat("Batch update (\(batchUpdateResult.result!) rows): %.3f s\n", end2.timeIntervalSinceDate(start2))
        
        return result
    }
}
