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

class Prefetch : PerfTest {
    func runTestWithContext(context: NSManagedObjectContext) -> String! {
        // Set up the fetch request for all the selfies
        let fetchRequest = NSFetchRequest(entityName: "Selfie")
        
        // Prefetch the social networks and people
        fetchRequest.relationshipKeyPathsForPrefetching = ["socialNetwork", "people"]
        
        // Perform the fetch
        let selfies = context.executeFetchRequest(fetchRequest, error: nil) as [Selfie]
        
        // Loop through the selfies
        for selfie in selfies {
            // For a fault just for the selfie
            selfie.valueForKey("name")
            
            // Loop through the social networks for this selfie
            for obj in selfie.socialNetworks {
                let socialNetwork = obj as SocialNetwork
                
                // Fire a fault for this social network
                socialNetwork.valueForKey("name")
                
                // Put this social network back in a fault
                context.refreshObject(socialNetwork, mergeChanges: false)
            }
            
            // Loop through the people for this selfie
            for obj in selfie.people {
                let person = obj as Person
                
                // Fire a fault for this person
                person.valueForKey("name")
                
                // Put this person back in a fault
                context.refreshObject(person, mergeChanges: false)
            }
        }
        
        return "Test complete"
    }
}
