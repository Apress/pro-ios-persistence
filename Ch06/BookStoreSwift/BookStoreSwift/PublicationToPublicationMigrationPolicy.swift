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

@objc(PublicationToPublicationMigrationPolicy)
class PublicationToPublicationMigrationPolicy : NSEntityMigrationPolicy {
    override func createDestinationInstancesForSourceInstance(sInstance: NSManagedObject, entityMapping mapping: NSEntityMapping, manager: NSMigrationManager, error: NSErrorPointer) -> Bool {
        // Create the book managed object
        
        var book = NSEntityDescription.insertNewObjectForEntityForName(mapping.destinationEntityName!, inManagedObjectContext: manager.destinationContext) as NSManagedObject
        
        book.setValue(sInstance.valueForKey("title"), forKey: "title")
        book.setValue(sInstance.valueForKey("price"), forKey: "price")
        
        // Get the author name from the source
        let author = sInstance.valueForKey("author") as String?
      
        // Split the author name into first name and last name
        let firstSpace = author?.rangeOfString(" ")
        if let firstSpace = firstSpace {
            let firstName = author?.substringToIndex(firstSpace.startIndex)
            let lastName = author?.substringFromIndex(firstSpace.endIndex)
          
            // Set the first and last names into the bbok
            book.setValue(firstName, forKeyPath: "firstName")
            book.setValue(lastName, forKeyPath: "lastName")
        }
        
        // Set up the association between the old Publication and the new Publication for the migration manager
        manager.associateSourceInstance(sInstance, withDestinationInstance: book, forEntityMapping: mapping)
        return true
    }
}
