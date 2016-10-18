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

    var persistence: Persistence?
    var managedObjectContext: NSManagedObjectContext? {
        didSet {
            self.initiate()
        }
    }
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
            self.persistence = Persistence()
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.managedObjectContext = self.persistence?.managedObjectContext
            })
        })
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        self.progressView.progress = 0
        self.label.text = "Initializing Core Data"
    }

    func initiate() {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
            self.writeData()
        })
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
            var status : Float = 0
            while(status < 1) {
                status = self.reportStatus()
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.progressView.progress = status
                    self.label.text = NSString(format: "Status: %lu%%", Int(status * 100))
                })
                    
                //println(NSString(format: "Status: %lu%%", Int(status * 100)))
            }

            println("All done")
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func writeDataVersion1() {
        if let context = self.managedObjectContext {
            println("Writing");
            for var i=0; i<10000; i++ {
                let obj = NSEntityDescription.insertNewObjectForEntityForName("MyData", inManagedObjectContext: context) as NSManagedObject
                obj.setValue(Int(i), forKey: "myValue")
            }
            
            persistence?.saveContext()
            
            println("Done")
        }
        else {
            println("Missing context. Cannot write.")
        }
    }
 
    func writeDataVersion2() {
        if let context = self.persistence?.createManagedObjectContext() {
            println("Writing");
            for var i=0; i<10000; i++ {
                let obj = NSEntityDescription.insertNewObjectForEntityForName("MyData", inManagedObjectContext: context) as NSManagedObject
                obj.setValue(Int(i), forKey: "myValue")
                
                context.save(nil)
            }
            
            println("Done")
        }
        else {
            println("Missing context. Cannot write.")
        }
    }
    
    func writeData() {
        if let context = self.persistence?.createManagedObjectContext() {
            println("Writing");
            for var i=0; i<10000; i++ {
                let obj = NSEntityDescription.insertNewObjectForEntityForName("MyData", inManagedObjectContext: context) as NSManagedObject
                obj.setValue(Int(i), forKey: "myValue")
            }
          context.save(nil)

            println("Done")
        }
        else {
            println("Missing context. Cannot write.")
        }
    }
    
    func reportStatus() -> Float {
        if let context = self.managedObjectContext {
            let request = NSFetchRequest(entityName: "MyData")
            var error: NSError? = nil
            let count = context.countForFetchRequest(request, error: &error)
            if error != nil {
                println("Error while reading")
            }
            
            return Float(count) / 10000.0
        }
        else {
            println("Missing context. Cannot report status")
            return 0
        }
    }
}

