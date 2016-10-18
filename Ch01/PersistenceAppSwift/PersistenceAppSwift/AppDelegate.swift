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
  var persistence: Persistence?

  func application(application: UIApplication!, didFinishLaunchingWithOptions launchOptions: NSDictionary!) -> Bool {
    persistence = Persistence()
    
    createObjects()
    fetchObjects()
    
    return true
  }
  
  func createObjects() {
    if let persistence = persistence {
      let iPad = NSEntityDescription.insertNewObjectForEntityForName("Gadget", inManagedObjectContext: persistence.managedObjectContext!) as NSManagedObject
      iPad.setValue("iPad", forKey: "name")
      iPad.setValue(499, forKey: "price")
      
      let iPadMini = NSEntityDescription.insertNewObjectForEntityForName("Gadget", inManagedObjectContext: persistence.managedObjectContext!) as NSManagedObject
      iPadMini.setValue("iPad Mini", forKey: "name")
      iPadMini.setValue(329, forKey: "price")
      
      let iPhone = NSEntityDescription.insertNewObjectForEntityForName("Gadget", inManagedObjectContext: persistence.managedObjectContext!) as NSManagedObject
      iPhone.setValue("iPhone", forKey: "name")
      iPhone.setValue(199, forKey: "price")
      
      let iPodTouch = NSEntityDescription.insertNewObjectForEntityForName("Gadget", inManagedObjectContext: persistence.managedObjectContext!) as NSManagedObject
      iPodTouch.setValue("iPod Touch", forKey: "name")
      iPodTouch.setValue(299, forKey: "price")
      
      persistence.saveContext()
    }
    else {
      println("Error, persistence layer not initialized")
    }
  }
  
  func fetchObjects() {
    if let persistence = persistence {
      let fetchRequest = NSFetchRequest(entityName: "Gadget")
      var error : NSError?
      let objects = persistence.managedObjectContext!.executeFetchRequest(fetchRequest, error: &error) as [NSManagedObject]
      if let error = error {
        println("Something went wrong: \(error.localizedDescription)")
      }
      
      for object in objects {
        println(object)
      }
    }
    else {
      println("Error, persistence layer not initialized")
    }
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
  }
}

