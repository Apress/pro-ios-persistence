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

class Uniquing : PerfTest {
    func runTestWithContext(context: NSManagedObjectContext) -> String! {
        // Array to hold the people for comparison purposes
        var referencePeople : [Person]?
        
        // Sorting for the people
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        
        // Fetch all the selfies
        let fetchRequest = NSFetchRequest(entityName: "Selfie")
        let selfies = context.executeFetchRequest(fetchRequest, error: nil) as [Selfie]
        
        // Loop through the selfies
        for selfie in selfies {
            // Get the sorted people
            let people = selfie.people.sortedArrayUsingDescriptors([sortDescriptor]) as [Person]
            
            // Store the first selfie's people for comparison purposes
            if let referencePeople = referencePeople {
                // Do the comparison
                for var i=0, n = people.count; i<n; i++ {
                    if people[i] != referencePeople[i] {
                        return NSString(format: "Uniquing test failed; %@ != %@", people[i], referencePeople[i])
                    }
                }
            }
            else {
                referencePeople = people
            }
        }
        
        return "Test complete"
    }
}
