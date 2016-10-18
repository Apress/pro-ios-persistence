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

class MyMigrationManager : NSMigrationManager {
    override func associateSourceInstance(sourceInstance: NSManagedObject, withDestinationInstance destinationInstance: NSManagedObject, forEntityMapping entityMapping: NSEntityMapping) {
        super.associateSourceInstance(sourceInstance, withDestinationInstance: destinationInstance, forEntityMapping: entityMapping)
        
        let name = entityMapping.destinationEntityName
        if name == "Publication" {
            let title = sourceInstance.valueForKey("title") as? String
            destinationInstance.setValue(title, forKeyPath: "synopsis")
        }
    }
}
