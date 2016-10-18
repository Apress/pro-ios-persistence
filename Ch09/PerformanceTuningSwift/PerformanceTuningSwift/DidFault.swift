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

class DidFault : PerfTest {
    func runTestWithContext(context: NSManagedObjectContext) -> String! {
        var result : String?
        
        // 1) Fetch the first selfie
        let fetchRequest = NSFetchRequest(entityName: "Selfie")
        fetchRequest.predicate = NSPredicate(format: "name = %@", "Selfie 1")
        let selfies = context.executeFetchRequest(fetchRequest, error: nil)
        if selfies?.count == 1 {
            let selfie = selfies?[0] as Selfie
            
            // 2) Grab a social network from the selfie
            let socialNetwork = selfie.socialNetworks.anyObject() as SocialNetwork?
            if let socialNetwork = socialNetwork {
                // 3) Check if it's a fault
                result = NSString(format: "Social Network %@ a fault\n", socialNetwork.fault ? "is" : "is not")
                
                // 4) Get the name
                result = result?.stringByAppendingFormat("Social Network is named '%@'\n", socialNetwork.name)
                
                // 5) Check if it's a fault
                result = result?.stringByAppendingFormat("Social Network %@ a fault\n", socialNetwork.fault ? "is" : "is not")
                
                // 6) Turn it back into a fault
                context.refreshObject(socialNetwork, mergeChanges: false)
                result = result?.stringByAppendingFormat("Turning Social Network into a fault\n")
                
                // 7) Check if it's a fault
                result = result?.stringByAppendingFormat("Social Network %@ a fault\n", socialNetwork.fault ? "is" : "is not")
            }
            else {
                result = "Couldn't find social networks for selfie"
            }
        }
        else {
            result = "Failed to fetch first selfie"
        }
        
        return result!
    }
}
