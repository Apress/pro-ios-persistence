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

class Subquery : PerfTest {
    func runTestWithContext(context: NSManagedObjectContext) -> String! {
        let result = NSMutableString()
        
        // Set up the first fetch request, with no subquery
        let fetchRequest1 = NSFetchRequest(entityName: "Selfie")
        fetchRequest1.predicate = NSPredicate(format: "(rating < %d) OR (name LIKE %@)", 5, "*e*ie*")
        
        // Mark the time and get the results
        let start1 = NSDate()
        let selfies = context.executeFetchRequest(fetchRequest1, error: nil) as [Selfie]
        var people1 = [String: Person]()
        for selfie in selfies {
            for obj in selfie.people {
                let person = obj as Person
                let key : String = person.objectID.URIRepresentation().description
                people1[key] = person
            }
        }
        let end1 = NSDate()
        
        // Record the results of the manual request
        result.appendFormat("No subquery: %.3f s\n", end1.timeIntervalSinceDate(start1))
        result.appendFormat("People retrieved: %ld\n", people1.count)
        
        // Reset the context so we get clean results
        context.reset()
        
        // Set up the second fetch request, with subquery
        let fetchRequest2 = NSFetchRequest(entityName: "Person")
        fetchRequest2.predicate = NSPredicate(format: "(SUBQUERY(selfies, $x, ($x.rating < %d) OR ($x.name LIKE %@)).@count > 0)", 5, "*e*ie*")
        
        // Mark the time and gee the results
        let start2 = NSDate()
        let people2 = context.executeFetchRequest(fetchRequest2, error: nil) as [Selfie]
        let end2 = NSDate()
        
        // Record the results of the subquery request
        result.appendFormat("Subquery: %.3f s\n", end2.timeIntervalSinceDate(start2))
        result.appendFormat("People retrieved: %ld\n", people2.count)
        
        return result
    }
}
