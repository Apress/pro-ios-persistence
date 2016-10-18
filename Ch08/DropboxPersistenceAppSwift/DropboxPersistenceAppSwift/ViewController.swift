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

class ViewController: UIViewController {

    @IBOutlet var theButton : UIButton?
    var datastore: DBDatastore?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let linkedAccount = DBAccountManager.sharedManager().linkedAccount {
            self.theButton?.setTitle("Store", forState: .Normal)
        }
        else {
            self.theButton?.setTitle("Link Dropbox", forState: .Normal)
        }      
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func didPressLink(sender: AnyObject) {
        if let linkedAccount = DBAccountManager.sharedManager().linkedAccount {
            // if there isn't a store yet, make one
            if self.datastore == nil {
                self.datastore = DBDatastore.openDefaultStoreForAccount(linkedAccount, error: nil)
            }
            
            // Create or get a handle to the Notes table if it already exists
            let notes = datastore?.getTable("Notes")
            
            // Make a new note to store. In a normal app, this comes from typed text. To keep things
            // simple, we just manufacture the text with a timestamp
            let now = NSDate()
            let noteText = NSDateFormatter.localizedStringFromDate(now, dateStyle: .ShortStyle, timeStyle: .FullStyle)
            
            // Insert the new note into the table
            notes?.insert(["details": noteText, "createDate": now, "encrypted": false])
            
            println("Inserted new note \(noteText)")
            
            // Make sure to tell Dropbox to sync the store
            datastore?.sync(nil)
        }
        else {
            DBAccountManager.sharedManager().linkFromController(self)
        }
    }
}

