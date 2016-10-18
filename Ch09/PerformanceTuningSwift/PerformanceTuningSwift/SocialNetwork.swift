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

@objc(SocialNetwork)
class SocialNetwork: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var rating: NSNumber
    @NSManaged var selfies: NSSet

    /*
    override func willTurnIntoFault() {
        println(NSString(format: "%@ named %@ will turn into fault", self, self.name))
    }
    
    override func didTurnIntoFault() {
        println(NSString(format: "%@ did turn into fault", self))        
    }
    */
}
