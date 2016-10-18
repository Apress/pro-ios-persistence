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

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
                            
  var window: UIWindow?

  func initStore() {
    deleteAllObjects("Book")
    deleteAllObjects("BookCategory")
    
    var fiction = NSEntityDescription.insertNewObjectForEntityForName("BookCategory", inManagedObjectContext: self.managedObjectContext!) as BookCategory
    fiction.name = "Fiction"
    
    var biography = NSEntityDescription.insertNewObjectForEntityForName("BookCategory", inManagedObjectContext: self.managedObjectContext!) as BookCategory
    biography.name = "Biography"
    
    var book1 = NSEntityDescription.insertNewObjectForEntityForName("Book", inManagedObjectContext: self.managedObjectContext!) as Book
    book1.title = "The first book"
    book1.price = 10
    
    var book2 = NSEntityDescription.insertNewObjectForEntityForName("Book", inManagedObjectContext: self.managedObjectContext!) as Book
    book2.title = "The second book"
    book2.price = 15
    
    var book3 = NSEntityDescription.insertNewObjectForEntityForName("Book", inManagedObjectContext: self.managedObjectContext!) as Book
    book3.title = "The third book"
    book3.price = 10
    
    var fictionRelation = fiction.mutableSetValueForKeyPath("books")
    fictionRelation.addObject(book1)
    fictionRelation.addObject(book2)
    
    var biographyRelation = biography.mutableSetValueForKeyPath("books")
    biographyRelation.addObject(book3)
    
    
    self.saveContext()
  }
  
  func deleteAllObjects(entityName: String) {
    let fetchRequest = NSFetchRequest(entityName: entityName)
    
    let objects = self.managedObjectContext?.executeFetchRequest(fetchRequest, error: nil)
    for object in objects as [NSManagedObject] {
      self.managedObjectContext?.deleteObject(object)
    }
    
    var error: NSError? = nil
    if !self.managedObjectContext!.save(&error) {
      println("Error deleting \(entityName) - error:\(error)")
    }
  }

  func showExampleData() {
    let fetchRequest = NSFetchRequest(entityName: "Book")
    fetchRequest.predicate = NSPredicate(format: "title='The first book'")
    
    let books = self.managedObjectContext?.executeFetchRequest(fetchRequest, error: nil)
    for book in books as [Book] {
      println(String(format: "Title: \(book.title), price: %.2f",  book.price))

      // Register this object for KVO
      book.addObserver(self, forKeyPath: "title", options: .Old | .New, context: nil)
      book.title = "The new title"
    }
  }
  
  /*
  func showExampleData() {
    let fetchRequest = NSFetchRequest(entityName: "Book")
    
    let exprTitle = NSExpression(forKeyPath: "title")
    let exprValue = NSExpression(forConstantValue: "The first book")
    let predicate = NSComparisonPredicate(leftExpression: exprTitle, rightExpression: exprValue, modifier: .DirectPredicateModifier, type: .EqualToPredicateOperatorType, options: nil)
    fetchRequest.predicate = predicate
    
    let books = self.managedObjectContext?.executeFetchRequest(fetchRequest, error: nil)
    for book in books as [Book] {
      println(String(format: "Title: \(book.title), price: %.2f",  book.price))
    }
  }
  */
 
  /*
  func showExampleData() {
    let fetchRequest = NSFetchRequest(entityName: "BookCategory")
    let categories = self.managedObjectContext?.executeFetchRequest(fetchRequest, error: nil)
    for category in categories as [BookCategory] {
      println("Bargains for category: \(category.name)")
      let bargainBooks = category.valueForKey("bargainBooks") as [Book!]
      for book in bargainBooks {
        println(String(format: "Title: \(book.title), price: %.2f", book.price))
      }
    }
  }
  */
  
  override func observeValueForKeyPath(keyPath: String!,
    ofObject object: AnyObject!,
    change: [NSObject : AnyObject]!,
    context: UnsafeMutablePointer<()>) {
    println("Changed value for \(keyPath): \(change[NSKeyValueChangeOldKey]!) -> \(change[NSKeyValueChangeNewKey]!)")
  }

  func application(application: UIApplication!, didFinishLaunchingWithOptions launchOptions: NSDictionary!) -> Bool {
    initStore()
    showExampleData()
    return true
  }

  func applicationWillResignActive(application: UIApplication!) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
  }

  func applicationDidEnterBackground(application: UIApplication!) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }

  func applicationWillEnterForeground(application: UIApplication!) {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
  }

  func applicationDidBecomeActive(application: UIApplication!) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }

  func applicationWillTerminate(application: UIApplication!) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    self.saveContext()
  }

  // MARK: - Core Data stack

  lazy var applicationDocumentsDirectory: NSURL = {
      // The directory the application uses to store the Core Data store file. This code uses a directory named "book.persistence.BookStoreSwift" in the application's documents Application Support directory.
      let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
      return urls[urls.count-1] as NSURL
  }()

  lazy var managedObjectModel: NSManagedObjectModel = {
      // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
      let modelURL = NSBundle.mainBundle().URLForResource("BookStoreSwift", withExtension: "momd")
      return NSManagedObjectModel(contentsOfURL: modelURL!)
  }()

  lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
      // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
      // Create the coordinator and store
      var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
      let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("BookStoreSwift.sqlite")
      var error: NSError? = nil
      var failureReason = "There was an error creating or loading the application's saved data."
      if coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil, error: &error) == nil {
          coordinator = nil
          // Report any error we got.
          let dict = NSMutableDictionary()
          dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
          dict[NSLocalizedFailureReasonErrorKey] = failureReason
          dict[NSUnderlyingErrorKey] = error
          error = NSError.errorWithDomain("YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
          // Replace this with code to handle the error appropriately.
          // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
          NSLog("Unresolved error \(error), \(error!.userInfo)")
          abort()
      }
      
      return coordinator
  }()

  lazy var managedObjectContext: NSManagedObjectContext? = {
      // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
      let coordinator = self.persistentStoreCoordinator
      if let coordinator = coordinator {
          var managedObjectContext = NSManagedObjectContext()
          managedObjectContext.persistentStoreCoordinator = coordinator
          return managedObjectContext
      }
      else {
          return nil
      }
  }()

  // MARK: - Core Data Saving support

  func saveContext () {
      if let moc = self.managedObjectContext {
          var error: NSError? = nil
          if moc.hasChanges && !moc.save(&error) {
              // Replace this implementation with code to handle the error appropriately.
              // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
              NSLog("Unresolved error \(error), \(error!.userInfo)")
              abort()
          }
      }
  }

}

