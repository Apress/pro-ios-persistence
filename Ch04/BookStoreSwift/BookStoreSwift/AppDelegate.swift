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

// Copy bundle resources to make sure seed.sqlite is included

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
                            
  var window: UIWindow?
  var unstable: Bool?

  func initStore() {
    let fm = NSFileManager.defaultManager()
    
    let seed = NSBundle.mainBundle().pathForResource("seed", ofType: "sqlite")
    if let seed = seed {
        let storeURL = AppDelegate.applicationDocumentsDirectory.URLByAppendingPathComponent("BookStoreEnhancedSwift.sqlite")
      
      if fm.fileExistsAtPath(storeURL.path!) {
        fm.removeItemAtPath(storeURL.path!, error: nil)
      }
        if !fm.fileExistsAtPath(storeURL.path!) {
            println("Using the original seed")
            var error: NSError? = nil
            if !fm.copyItemAtPath(seed, toPath: storeURL.path!, error: &error) {
                println("Seeding error: \(error?.localizedDescription)")
                return
            }
            println("Store successfully initialized using the original seed.")
        }
        else {
            println("The seed isn't needed. There is already a backing store.")

          // Update 1
            if let managedObjectContext = self.managedObjectContext {
                let fetchRequest1 = NSFetchRequest(entityName: "Book")
                fetchRequest1.predicate = NSPredicate(format: "title=%@", argumentArray: ["The fourth book"])
                if managedObjectContext.countForFetchRequest(fetchRequest1, error: nil) == 0 {
                    println("Applying batch update 1")
                    let fetchRequest = NSFetchRequest(entityName: "BookCategory")
                    let categories = managedObjectContext.executeFetchRequest(fetchRequest, error: nil)

                    let category = categories?.last as BookCategory
                    var book4 = NSEntityDescription.insertNewObjectForEntityForName("Book", inManagedObjectContext: managedObjectContext) as Book
                    book4.title = "The fourth book"
                    book4.price = 12

                    var booksRelation = category.valueForKeyPath("books") as NSMutableSet
                    booksRelation.addObject(book4)

                    saveContext()
                    println("Update 1 successfully applied")
                }
            }
        }
    }
    else {
        println("Could not find the seed.")
    }

    /* === Adding the fourth book manually ===*/
    /*
    let fetchRequest = NSFetchRequest(entityName: "BookCategory")
    let categories = self.managedObjectContext?.executeFetchRequest(fetchRequest, error: nil)

    let category = categories?.last as BookCategory
    var book4 = NSEntityDescription.insertNewObjectForEntityForName("Book", inManagedObjectContext: self.managedObjectContext!) as Book
    book4.title = "The fourth book"
    book4.price = 12

    var booksRelation = category.valueForKeyPath("books") as NSMutableSet
    booksRelation.addObject(book4)
    saveContext()
    */
  }
  
func insertSomeData() {
    let category = self.managedObjectContext?.executeFetchRequest(NSFetchRequest(entityName: "BookCategory"), error: nil)?.last as BookCategory?
    
    if let managedObjectContext = self.managedObjectContext {
        // Tell the undo manager that from now on, we manage grouping
        managedObjectContext.undoManager?.groupsByEvent = false
      
        if let category = category {
            for i in 5..<10 {
                // Start a new group
                managedObjectContext.undoManager?.beginUndoGrouping()
              
                var book = NSEntityDescription.insertNewObjectForEntityForName("Book", inManagedObjectContext: managedObjectContext) as Book
                book.title = "The \(i)th book"
                book.price = Float(i)
                
                var booksRelation = category.valueForKeyPath("books") as NSMutableSet
                booksRelation.addObject(book)
                
                // End the current group
                managedObjectContext.undoManager?.endUndoGrouping()
            }
            
            managedObjectContext.undoManager?.undo()
            saveContext()
        }
    }
}
    
  func showExampleData() {
    let fetchRequest = NSFetchRequest(entityName: "Book")
    let books = self.managedObjectContext?.executeFetchRequest(fetchRequest, error: nil)
    for book in books as [Book] {
      println(String(format: "Title: \(book.title), price: %.2f", book.price))
    }
  }
  
  override func observeValueForKeyPath(keyPath: String!,
    ofObject object: AnyObject!,
    change: [NSObject : AnyObject]!,
    context: UnsafeMutablePointer<()>) {
    println("Changed value for \(keyPath): \(change[NSKeyValueChangeOldKey]!) -> \(change[NSKeyValueChangeNewKey]!)")
  }

  func application(application: UIApplication!, didFinishLaunchingWithOptions launchOptions: NSDictionary!) -> Bool {
//    initStore()
//    insertSomeData()
//    showExampleData()
    
    self.window?.rootViewController = ViewController()
    
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

    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Initialize the managed object model
        let modelURL = NSBundle.mainBundle().URLForResource("BookStoreSwift", withExtension: "momd")
        let managedObjectModel = NSManagedObjectModel(contentsOfURL: modelURL!)
        
        // Initialize the persistent store coordinator
        let storeURL = AppDelegate.applicationDocumentsDirectory.URLByAppendingPathComponent("BookStoreEnhancedSwift.sqlite")
        var error: NSError? = nil
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        
        if(persistentStoreCoordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: nil, error: &error) == nil) {
            self.showCoreDataError()
            return nil
        }
        
        var managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator
        
        // Add the undo manager
        managedObjectContext.undoManager = NSUndoManager()
        
        return managedObjectContext
    }()
    
    
    func saveContext() {
        var error: NSError? = nil
        if let managedObjectContext = self.managedObjectContext {
            if managedObjectContext.hasChanges && !managedObjectContext.save(&error) {
                abort()
            }
        }
    }
    
    class var applicationDocumentsDirectory: NSURL {
    let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.endIndex-1] as NSURL
    }
    
    func showCoreDataError() {
        self.unstable = true
        
        var alert = UIAlertController(title: "Error!", message: "BookStore can't continue.\nPress the Home button to close the app.", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.window?.rootViewController?.presentViewController(alert, animated: true, completion: nil)
    }
}

