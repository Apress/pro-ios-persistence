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

class BatchFault : PerfTest {
    func runTestWithContext(context: NSManagedObjectContext) -> String! {
        // Fetch all the selfies
        let fetchRequest = NSFetchRequest(entityName: "Selfie")
        
        // Return the selfies as non-faults
        fetchRequest.returnsObjectsAsFaults = true
        let selfies = context.executeFetchRequest(fetchRequest, error: nil) as [Selfie]
        
        // Loop through all the selfies
        for selfie in selfies {
            // Doesn't fire a fault, the data are already in memory
            selfie.valueForKey("name")
            
            // For this selfie, fire faults for all the social networks
            let snFetchRequest = NSFetchRequest(entityName: "SocialNetwork")
            snFetchRequest.returnsObjectsAsFaults = false
            context.executeFetchRequest(snFetchRequest, error: nil)
            
            // For this selfie, fire faults for all the people
            let pFetchRequest = NSFetchRequest(entityName: "Person")
            pFetchRequest.returnsObjectsAsFaults = false
            context.executeFetchRequest(pFetchRequest, error: nil)
            
            // Loop through the social networks for this selfie
            for obj in selfie.socialNetworks {
                let socialNetwork = obj as SocialNetwork
                
                // Doesn't fire a fault, the data are already in memory
                socialNetwork.valueForKey("name")
                
                // Put this social network back in a fault
                context.refreshObject(socialNetwork, mergeChanges: false)
            }
            
            // Loop through the people for this selfie
            for obj in selfie.people {
                let person = obj as Person

                // Doesn't fire a fault, the data are already in memory
                person.valueForKey("name")
                
                // Put this person back in a fault
                context.refreshObject(person, mergeChanges: false)
            }
        }
        
        return "Test complete"
    }
}
