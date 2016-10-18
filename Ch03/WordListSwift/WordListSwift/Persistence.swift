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

class Persistence: NSObject {
    var managedObjectContext: NSManagedObjectContext? = {
        // Initialize the managed object model
        let modelURL = NSBundle.mainBundle().URLForResource("WordListSwift", withExtension: "momd")
        let managedObjectModel = NSManagedObjectModel(contentsOfURL: modelURL!)
        
        // Initialize the persistent store coordinator
        let storeURL = Persistence.applicationDocumentsDirectory.URLByAppendingPathComponent("WordListSwift.sqlite")
        var error: NSError? = nil
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel!)

        if(persistentStoreCoordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: nil, error: &error) == nil) {
            abort()
        }
        
        var managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator
        
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
    
    func deleteAllObjectsForEntityWithName(name: String) {
        println("Deleting all objects in entity \(name)")
        var fetchRequest = NSFetchRequest(entityName: name)
        fetchRequest.resultType = .ManagedObjectIDResultType
        
        if let managedObjectContext = managedObjectContext {
            var error: NSError? = nil
            let objectIDs = managedObjectContext.executeFetchRequest(fetchRequest, error: &error)
            for objectID in objectIDs! {
                managedObjectContext.deleteObject(managedObjectContext.objectWithID(objectID as NSManagedObjectID))
            }
            
            saveContext()
            
            println("All objects in entity \(name) deleted")
        }
    }
    
    func loadWordList(wordList: String) {
        // Delete all the existing words and categories
        deleteAllObjectsForEntityWithName("Word")
        deleteAllObjectsForEntityWithName("WordCategory")
        
        // Create the categories
        var wordCategories = NSMutableDictionary(capacity: 26)
        for c in "abcdefghijklmnopqrstuvwxyz" {
            let firstLetter = "\(c)"
            var wordCategory: AnyObject! = NSEntityDescription.insertNewObjectForEntityForName("WordCategory", inManagedObjectContext: self.managedObjectContext!)
            wordCategory.setValue(firstLetter, forKey: "firstLetter")
            wordCategories.setValue(wordCategory, forKey: firstLetter)
            println("Added category '\(firstLetter)'")
        }
        
        // Add the words from the list
        var wordsAdded = 0
        let newWords = wordList.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        for word in newWords {
            if countElements(word) > 0 {
                var object: AnyObject! = NSEntityDescription.insertNewObjectForEntityForName("Word", inManagedObjectContext: self.managedObjectContext!)
                object.setValue(word, forKey: "text")
                object.setValue(countElements(word), forKey: "length")
                object.setValue(wordCategories.valueForKey((word as NSString).substringToIndex(1)), forKey: "wordCategory")
                wordsAdded++
                if wordsAdded % 100 == 0 {
                    println("Added \(wordsAdded) words")
                    saveContext()
                    println("Context saved")
                }
            }
        }
        saveContext()
        println("Context saved")
    }
    
    func wordCount() -> String {
        let fetchRequest = NSFetchRequest(entityName: "Word")
        var error: NSError? = nil
        let count = self.managedObjectContext!.countForFetchRequest(fetchRequest, error: &error)
        return "Word Count: \(count)\n"
    }
    
    func statistics() -> String {
        var string = NSMutableString()

        string.appendString(wordCount())
        
        for c in "abcdefghijklmnopqrstuvwxyz" {
            string.appendString(wordCountForCategory("\(c)"))
        }

        string.appendString(zyzzyvasUsingQueryLanguage())
        string.appendString(zyzzyvasUsingNSExpression())
        string.appendString(wordCountForRange(NSMakeRange(20, 25)))
        string.appendString(endsWithGryWords())
        string.appendString(anyWordContainsZ())
        string.appendString(caseInsensitiveFetch("qiviut"))
        string.appendString(twentyLetterWordsEndingInIng())
        string.appendString(highCountCategories())
        string.appendString(averageWordLengthFromCollection())
        string.appendString(averageWordLengthFromExpressionDescription())
        string.appendString(longestWords())
        string.appendString(wordCategoriesWith25LetterWords())
        string.appendString(zWords())

        return string
    }
    
    func wordCountForCategory(firstLetter: String) -> String {
        var fetchRequest = NSFetchRequest(entityName: "Word")
        fetchRequest.predicate = NSPredicate(format: "wordCategory.firstLetter = %@", argumentArray: [firstLetter])
        
        var error: NSError? = nil
        let count = self.managedObjectContext!.countForFetchRequest(fetchRequest, error: &error)
        
        return "Words beginning with \(firstLetter): \(count)\n"
    }
    
    func zyzzyvasUsingQueryLanguage() -> String {
        var fetchRequest = NSFetchRequest(entityName: "Word")
        fetchRequest.predicate = NSPredicate(format: "text = 'zyzzyvas'", argumentArray: [])

        var error: NSError? = nil
        if let words = self.managedObjectContext!.executeFetchRequest(fetchRequest, error: &error) {
            if words.isEmpty { return "" }
            else {
                let word: AnyObject! = words[0].valueForKey("text")
                return "\(word)\n"
            }
        }
        else { return "" }
    }
    
    func zyzzyvasUsingNSExpression() -> String {
        let expressionText = NSExpression(forKeyPath: "text")
        let expressionZyzzyvas = NSExpression(forConstantValue: "zyzzyvas")
        let predicate = NSComparisonPredicate(leftExpression: expressionText, rightExpression: expressionZyzzyvas, modifier: .DirectPredicateModifier, type: .EqualToPredicateOperatorType, options: nil)
        
        println("Predicate: \(predicate.predicateFormat)")
        
        var fetchRequest = NSFetchRequest(entityName: "Word")
        fetchRequest.predicate = predicate
        
        var error: NSError? = nil
        if let words = self.managedObjectContext!.executeFetchRequest(fetchRequest, error: &error) {
            if words.isEmpty { return "" }
            else {
                let word: AnyObject! = words[0].valueForKey("text")
                return "\(word)\n"
            }
        }
        else { return "" }
    }
    
    func wordCountForRange(range: NSRange) -> String {
        let length = NSExpression(forKeyPath: "length")
        let lower = NSExpression(forConstantValue: range.location)
        let upper = NSExpression(forConstantValue: range.length)
        let expr = NSExpression(forAggregate: [lower, upper])
        let predicate = NSComparisonPredicate(leftExpression: length, rightExpression: expr, modifier: .DirectPredicateModifier, type: .BetweenPredicateOperatorType, options: nil)
        
        println("Aggregate predicate: \(predicate.predicateFormat)")
        
        var fetchRequest = NSFetchRequest(entityName: "Word")
        fetchRequest.predicate = predicate

        var error: NSError? = nil
        let count = self.managedObjectContext!.countForFetchRequest(fetchRequest, error: &error)
        
        return "\(range.location)-\(range.length) letter words: \(count)\n"
    }
    
    func endsWithGryWords() -> String {
        let text = NSExpression(forKeyPath: "text")
        let gry = NSExpression(forConstantValue: "gry")
        let predicate = NSComparisonPredicate(leftExpression: text, rightExpression: gry, modifier: .DirectPredicateModifier, type: .EndsWithPredicateOperatorType, options: nil)
        
        println("Predicate: \(predicate.predicateFormat)")
        
        var fetchRequest = NSFetchRequest(entityName: "Word")
        fetchRequest.predicate = predicate
        
        let list = NSMutableString()
        var error: NSError? = nil
        if let gryWords = self.managedObjectContext!.executeFetchRequest(fetchRequest, error: &error) {
            for word in gryWords {
                list.appendString(((word as NSManagedObject).valueForKey("text") as String)+",")
            }
        }
        return "-gry words: \(list)\n"
    }
    
    func anyWordContainsZ() -> String {
        let text = NSExpression(forKeyPath: "words.text")
        let z = NSExpression(forConstantValue: "z")
        let predicate = NSComparisonPredicate(leftExpression: text, rightExpression: z, modifier:.AnyPredicateModifier, type: .ContainsPredicateOperatorType, options: nil)
        
        println("Predicate: \(predicate.predicateFormat)")
        
        var fetchRequest = NSFetchRequest(entityName: "WordCategory")
        fetchRequest.predicate = predicate
        
        let list = NSMutableString()
        var error: NSError? = nil
        if let categories = self.managedObjectContext!.executeFetchRequest(fetchRequest, error: &error) {
            for word in categories {
                list.appendString(((word as NSManagedObject).valueForKey("firstLetter") as String)+",")
            }
        }
        
        return "ANY: \(list)\n"
    }
    
    func caseInsensitiveFetch(word: String) -> String {
        let text = NSExpression(forKeyPath: "text")
        let allCapsWord = NSExpression(forConstantValue: word.uppercaseString)
        let predicate = NSComparisonPredicate(leftExpression: text, rightExpression: allCapsWord, modifier: .DirectPredicateModifier, type: .EqualToPredicateOperatorType, options: .CaseInsensitivePredicateOption)
        
        println("Predicate: \(predicate.predicateFormat)")
        
        var fetchRequest = NSFetchRequest(entityName: "Word")
        fetchRequest.predicate = predicate

        var error: NSError? = nil
        if let words = self.managedObjectContext!.executeFetchRequest(fetchRequest, error: &error) {
            if words.isEmpty { return "" }
            else {
                let word: AnyObject! = words[0].valueForKey("text")
                return "\(word)\n"
            }
        }
        else { return "" }
    }
    
    func twentyLetterWordsEndingInIng() -> String {
        // Create a predicate that compares length to 20
        let length = NSExpression(forKeyPath: "length")
        let twenty = NSExpression(forConstantValue: 20)
        let predicateLength = NSComparisonPredicate(leftExpression: length, rightExpression: twenty, modifier: .DirectPredicateModifier, type: .EqualToPredicateOperatorType, options: nil)
        
        // Create a predicate that compares text to "ends with -ing"
        let text = NSExpression(forKeyPath: "text")
        let ing = NSExpression(forConstantValue: "ing")
        let predicateIng = NSComparisonPredicate(leftExpression: text, rightExpression: ing, modifier: .DirectPredicateModifier, type: .EndsWithPredicateOperatorType, options: nil)
        
        // Combine the predicates
        let predicate = NSCompoundPredicate.andPredicateWithSubpredicates([predicateLength, predicateIng])
        
        println("Compound predicate: \(predicate.predicateFormat)")
        
        var fetchRequest = NSFetchRequest(entityName: "Word")
        fetchRequest.predicate = predicate
        
        let list = NSMutableString()
        var error: NSError? = nil
        if let words = self.managedObjectContext!.executeFetchRequest(fetchRequest, error: &error) {
            for word in words {
                list.appendString(((word as NSManagedObject).valueForKey("text") as String)+",")
            }
        }
        
        return "\(list)\n"
    }
    
    func highCountCategories() -> String {
        let predicate = NSPredicate(format: "words.@count > %d", argumentArray: [10000])
        println("Predicate: \(predicate.predicateFormat)")
        
        var fetchRequest = NSFetchRequest(entityName: "WordCategory")
        fetchRequest.predicate = predicate
        
        let list = NSMutableString()
        var error: NSError? = nil
        if let categories = self.managedObjectContext!.executeFetchRequest(fetchRequest, error: &error) {
            for word in categories {
                list.appendString(((word as NSManagedObject).valueForKey("firstLetter") as String)+",")
            }
        }
        
        return "High count categories: \(list)\n"
    }
    
    func averageWordLengthFromCollection() -> String {
        var fetchRequest = NSFetchRequest(entityName: "Word")
        
        var error: NSError? = nil
        let words = self.managedObjectContext!.executeFetchRequest(fetchRequest, error: &error)
        
        var formattedAverage = "0"
        if let words = words {
            if let avg = (words as NSArray).valueForKeyPath("@avg.length") as? Float {
              let format = ".2"
              formattedAverage = avg.format(format)
            }
        }
        return "Average from collection: \(formattedAverage)\n"
    }
    
    func averageWordLengthFromExpressionDescription() -> String {
        let length = NSExpression(forKeyPath: "length")
        let average = NSExpression(forFunction: "average:", arguments: [length])
        
        var averageDescription = NSExpressionDescription()
        averageDescription.name = "average"
        averageDescription.expression = average
        averageDescription.expressionResultType = .FloatAttributeType
        
        var fetchRequest = NSFetchRequest(entityName: "Word")
        fetchRequest.propertiesToFetch = [averageDescription]
        fetchRequest.resultType = .DictionaryResultType
        
        var error: NSError? = nil
        let results = self.managedObjectContext!.executeFetchRequest(fetchRequest, error: &error)
        
        var formattedAverage = "0"
        if let results = results {
            if let avg = (results[0] as NSDictionary).valueForKey("average") as? Float {
              let format = ".2"
              formattedAverage = avg.format(format)
            }
        }
        return "Average from expression description: \(formattedAverage)\n"
    }
    
    func longestWords() -> String {
        var fetchRequest = NSFetchRequest(entityName: "Word")
        let predicate = NSPredicate(format: "length = max:(length)", argumentArray: [])

        println("Predicate: \(predicate.predicateFormat)")
        
        fetchRequest.predicate = predicate        
        
        let list = NSMutableString()
        var error: NSError? = nil
        if let words = self.managedObjectContext!.executeFetchRequest(fetchRequest, error: &error) {
            for word in words {
                list.appendString(((word as NSManagedObject).valueForKey("text") as String)+",")
            }
        }
        
        return "Longest words: \(list)\n"
    }
    
    func wordCategoriesWith25LetterWords() -> String {
        var fetchRequest = NSFetchRequest(entityName: "WordCategory")
        let predicate = NSPredicate(format: "SUBQUERY(words, $x, $x.length = 25).@count > 0", argumentArray: [])

        println("Subcategoy predicate: \(predicate.predicateFormat)")
        
        fetchRequest.predicate = predicate
        
        let list = NSMutableString()
        var error: NSError? = nil
        if let categories = self.managedObjectContext!.executeFetchRequest(fetchRequest, error: &error) {
            for word in categories {
                list.appendString(((word as NSManagedObject).valueForKey("firstLetter") as String)+",")
            }
        }
        
        return "Categories with 25-letter words: \(list)\n"
    }
    
    func zWords() -> String {
        var fetchRequest = NSFetchRequest(entityName: "Word")
        let predicate = NSPredicate(format: "text BEGINSWITH 'z'", argumentArray: [])
        
        println("Predicate: \(predicate.predicateFormat)")
        
        let lengthSort = NSSortDescriptor(key: "length", ascending: true)
        let alphaSort = NSSortDescriptor(key: "text", ascending: false)
        
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [lengthSort, alphaSort]
        
        let list = NSMutableString()
        var error: NSError? = nil
        if let words = self.managedObjectContext!.executeFetchRequest(fetchRequest, error: &error) {
            for word in words {
                list.appendString(((word as NSManagedObject).valueForKey("text") as String)+",")
            }
        }
        
        return "Z words: \(list)\n"
    }
}

extension Float {
    func format(f: String) -> String {
        return NSString(format: "%\(f)f", self)
    }
}