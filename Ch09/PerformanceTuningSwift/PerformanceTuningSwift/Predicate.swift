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

class Predicate : PerfTest {
    func runTestWithContext(context: NSManagedObjectContext) -> String! {
        let result = NSMutableString()
        
        // Set up the first fetch request
        let fetchRequest1 = NSFetchRequest(entityName: "Selfie")
        fetchRequest1.predicate = NSPredicate(format: "(name LIKE %@) OR (rating < %d)", "*e*ie*", 5)
        
        // Run the first fetch request and measure
        let start1 = NSDate()
        for var i=0; i<1000; i++ {
            context.reset()
            context.executeFetchRequest(fetchRequest1, error: nil)
        }
        let end1 = NSDate()
        result.appendFormat("Slow predicate: %.3f s\n", end1.timeIntervalSinceDate(start1))
        
        // Set up the second fetch request
        let fetchRequest2 = NSFetchRequest(entityName: "Selfie")
        fetchRequest2.predicate = NSPredicate(format: "(rating < %d) OR (name LIKE %@)", 5, "*e*ie*")
        
        // Run the first fetch request and measure
        let start2 = NSDate()
        for var i=0; i<1000; i++ {
            context.reset()
            context.executeFetchRequest(fetchRequest2, error: nil)
        }
        let end2 = NSDate()
        result.appendFormat("Fast predicate: %.3f s\n", end2.timeIntervalSinceDate(start2))
        
        return result
    }
}
