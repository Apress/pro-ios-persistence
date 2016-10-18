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
    @IBOutlet weak var textView: UITextView!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateStatistics()
    }
    
    func updateStatistics() {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        textView.text = appDelegate.persistence?.statistics()
    }
    
    @IBAction func loadWordList(sender: AnyObject) {
        // Hide the button while we're loading
        (sender as UIButton).hidden = true
        
        // Load the words
        let url = NSURL(string: "https://dotnetperls-controls.googlecode.com/files/enable1.txt")
        let request = NSURLRequest(URL: url!)
        println("Loading words")
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            let words = NSString(data: data, encoding: NSUTF8StringEncoding)
            
            // Check for successful load
            if error == nil && response != nil && (response as NSHTTPURLResponse).statusCode == 200 {
                // Give the word list to the persistence layer
                let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
                appDelegate.persistence?.loadWordList(words!)
            }
            else {
                // Load failed; show any errors
                if response != nil { println("Error: \((response as NSHTTPURLResponse).statusCode)") }
                println("Error: \(error.localizedDescription)")
            }
            
            // Show the button
            (sender as UIButton).hidden = false
            
            // Update the text view with statistics
            self.updateStatistics()
        }
    }
}

