//
// From the book Pro iOS Persistence
// Michael Privat and Rob Warner
// Published by Apress, 2014
// Source released under The MIT License
// http://opensource.org/licenses/MIT
//
// Contact information:
// Michael: @michaelprivat -- http://michaelprivat.com -- mprivat@mac.com
// Rob: @hoop33 -- http://grailbox.com -- rwarner@grailbox.com
//

import Foundation
import CoreData

class Cache : PerfTest {
    func runTestWithContext(context: NSManagedObjectContext) -> String! {
        let result = NSMutableString()
        
        // Load the data while it's not cached
        let start1 = NSDate()
        self.loadDataWithContext(context)
        let end1 = NSDate()
        
        // Record the results
        result.appendFormat("Without cache: %.3f s\n", end1.timeIntervalSinceDate(start1))
        
        // Load the data while it's cached
        let start2 = NSDate()
        self.loadDataWithContext(context)
        let end2 = NSDate()
        
        // Record the results
        result.appendFormat("With cache: %.3f s\n", end2.timeIntervalSinceDate(start2))
        
        return result
    }
    
    func loadDataWithContext(context: NSManagedObjectContext) {
        // Load the selfies
        let fetchRequest = NSFetchRequest(entityName: "Selfie")
        let selfies = context.executeFetchRequest(fetchRequest, error: nil) as [Selfie]
        
        // Loop through the selfies
        for selfie in selfies {
            // Load the selfie's data
            selfie.valueForKey("name")
            
            // Loop through the social networks
            for obj in selfie.socialNetworks {
                let socialNetwork = obj as SocialNetwork
                
                // Load the social network's data
                socialNetwork.valueForKey("name")
            }
        }
    }
}

