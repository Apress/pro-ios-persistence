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

class Book: NSManagedObject {
  
  @NSManaged var price: Float
  @NSManaged var title: String
  @NSManaged var category: BookCategory
  @NSManaged var pages: NSOrderedSet
  @NSManaged var firstName: String
  @NSManaged var lastName: String
  
  override func awakeFromInsert() {
    super.awakeFromInsert()
    println("New book created")
  }
  
  override func awakeFromFetch() {
    super.awakeFromFetch()
    println("Book fetched: \(self.title)")
  }
}
