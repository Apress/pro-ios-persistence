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

class SingleFault : PerfTest {
    func runTestWithContext(context: NSManagedObjectContext) -> String! {
        // Fetch all the selfies
        let fetchRequest = NSFetchRequest(entityName: "Selfie")
        let selfies = context.executeFetchRequest(fetchRequest, error: nil)
        
        // Loop through all the selfies
        for selfie in selfies as [Selfie] {
            // Fire a fault just for this selfie
            selfie.valueForKey("name")
            
            // Loop through the social networks for this selfie
            for obj in selfie.socialNetworks {
                let socialNetwork = obj as SocialNetwork
                
                // Fire a fault just for this social network
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