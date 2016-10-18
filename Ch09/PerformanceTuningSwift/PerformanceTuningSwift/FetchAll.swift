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

class FetchAll : PerfTest {
    func runTestWithContext(context: NSManagedObjectContext) -> String! {
        let peopleFetchRequest = NSFetchRequest(entityName: "Person")
        let selfiesFetchRequest = NSFetchRequest(entityName: "Selfie")
        let socialNetworkFetchRequest = NSFetchRequest(entityName: "SocialNetwork")
        
        let people = context.executeFetchRequest(peopleFetchRequest, error: nil)!
        let selfies = context.executeFetchRequest(selfiesFetchRequest, error: nil)!
        let socialNetworks = context.executeFetchRequest(socialNetworkFetchRequest, error: nil)!
        
        return NSString(format: "Fetched %ld people, %ld selfies, and %ld social networks", people.count, selfies.count, socialNetworks.count)
    }
}
