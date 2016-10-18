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

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if let managedObjectContext = self.managedObjectContext {
//            self.populateAuthors()
            self.showExampleData()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    lazy var managedObjectContext: NSManagedObjectContext? = {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        return appDelegate.managedObjectContext
    }()
    
    func saveContext() {
        var error: NSError? = nil
        if let managedObjectContext = self.managedObjectContext {
            if managedObjectContext.hasChanges && !managedObjectContext.save(&error) {
                let message = validationErrorText(error!)
                println("Error: \(message)")
            }
        }
    }
    
    func initStore() {
        let fm = NSFileManager.defaultManager()
        
        let seed = NSBundle.mainBundle().pathForResource("seed", ofType: "sqlite")
        if let seed = seed {
            let storeURL = AppDelegate.applicationDocumentsDirectory.URLByAppendingPathComponent("BookStoreEnhancedSwift.sqlite")
            
            // Remove the old store to force re-seeding
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
            }
        }
        else {
            println("Could not find the seed.")
        }
        
        // Update 1
        let fetchRequest1 = NSFetchRequest(entityName: "Publication")
        fetchRequest1.predicate = NSPredicate(format: "title=%@", argumentArray: ["The fourth book"])
        if self.managedObjectContext?.countForFetchRequest(fetchRequest1, error: nil) == 0 {
            println("Applying batch update 1")
            let fetchRequest = NSFetchRequest(entityName: "BookCategory")
            let categories = self.managedObjectContext?.executeFetchRequest(fetchRequest, error: nil)
            
            let category = categories?.last as BookCategory
            var book4 = NSEntityDescription.insertNewObjectForEntityForName("Publication", inManagedObjectContext: self.managedObjectContext!) as Book
            book4.title = "The fourth book"
            book4.price = 12
            
            var booksRelation = category.mutableSetValueForKeyPath("books")
            booksRelation.addObject(book4)
            
            saveContext()
            println("Update 1 successfully applied")
        }
    }
    
    func insertSomeData() {
        let ad = UIApplication.sharedApplication().delegate as? AppDelegate
        
        if let unstable = ad?.unstable {
            if unstable {
                println("The app is unstable. Preventing updates.")
                return
            }
        }
  
        let category = self.managedObjectContext?.executeFetchRequest(NSFetchRequest(entityName: "BookCategory"), error: nil)?.last as BookCategory?
        
        if let managedObjectContext = self.managedObjectContext {
            managedObjectContext.undoManager?.groupsByEvent = false
            
            if let category = category {
                for i in 5..<10 {
                    managedObjectContext.undoManager?.beginUndoGrouping()
                    
                    var book = NSEntityDescription.insertNewObjectForEntityForName("Publication", inManagedObjectContext: managedObjectContext) as Book
                    book.title = "The \(i)th book"
                    book.price = Float(i)
                    
                    var booksRelation = category.mutableSetValueForKeyPath("books")
                    booksRelation.addObject(book)
                    
                    managedObjectContext.undoManager?.endUndoGrouping()
                }
                
                managedObjectContext.undoManager?.undo()

                saveContext()
            }
        }
    }
    
    func showExampleData() {
        let fetchRequest = NSFetchRequest(entityName: "Publication")
        let books = self.managedObjectContext?.executeFetchRequest(fetchRequest, error: nil)
        for book in books as [Book] {
            println(String(format: "Title: \(book.title), price: %.2f",  book.price))
        }
    }

    func populateAuthors() {
        // 1. Create a list of author names to assign
        let authors = ["John Doe", "Jane Doe", "Bill Smith", "Jack Brown"]
        
        // 2. Get all the publications from the data store
        let fetchRequest = NSFetchRequest(entityName: "Publication")
        let books = self.managedObjectContext?.executeFetchRequest(fetchRequest, error: nil)
        if let books = books {
            for var i = 0; i<books.count; i++ {
                var book = books[i] as Book
                book.price = 20 + Float(i)
                // 3. Set the author using one of the names in the array we created
                book.setValue(authors[i % authors.count], forKeyPath: "author")
            }
        }
        
        // 4. Commit everything to the store
        saveContext()
    }
    
    func validationErrorText(error : NSError) -> String {
        // Create a string to hold all the error messages
        let errorText = NSMutableString(capacity: 100)
        // Determine whether we're dealing with a single error or multiples, and put them all
        // in an array
        let errors : NSArray = error.code == NSValidationMultipleErrorsError ? error.userInfo?[NSDetailedErrorsKey] as NSArray : NSArray(object: error)
        
        // Iterate through the errors
        for err in errors {
            // Get the property that had a validation error
            let e = err as NSError
            let info = e.userInfo
            let propName : AnyObject? = info!["NSValidationErrorKey"]
            var message : String?
            
            // Form an appropriate error message
            switch err.code {
            case NSValidationNumberTooSmallError:
                message = "\(propName!) must be at least $15"
            default:
                message = "Unknown error. Press Home button to halt."
            }
            
            // Separate the error messages with line feeds
            if errorText.length > 0 {
                errorText.appendString("\n")
            }
            
            errorText.appendString(message!)
        }
        
        return errorText
    }
}

