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

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var startTime: UILabel!
    @IBOutlet weak var stopTime: UILabel!
    @IBOutlet weak var elapsedTime: UILabel!
    @IBOutlet weak var results: UITextView!
    @IBOutlet weak var testPicker: UIPickerView!
    
    var tests = [PerfTest]()
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.tests.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        let test = self.tests[row]
        let fullName = _stdlib_getDemangledTypeName(test)
        let tokens = split(fullName, { $0 == "." })
        return tokens.last
    }
    
    @IBAction func runTest(sender: AnyObject) {
        // Get the selected test
        let test = self.tests[self.testPicker.selectedRowInComponent(0)]
        
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let context = appDelegate.persistence?.managedObjectContext
        if let context = context {
            // Clear out any objects so we get clean test results
            context.reset()
            
            // Mark the start time, run the test, and mark the stop time
            let start = NSDate()
            let testResults = test.runTestWithContext(context)
            let stop = NSDate()
            
            let formatter = NSDateFormatter()
            formatter.timeStyle = .MediumStyle
            
            // Update the UI witht the test results
            self.startTime.text = formatter.stringFromDate(start)
            self.stopTime.text = formatter.stringFromDate(stop)
            self.elapsedTime.text = NSString(format: "%.03f seconds", stop.timeIntervalSinceDate(start))
            self.results.text = testResults
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        self.startTime.text = ""
        self.stopTime.text = ""
        self.elapsedTime.text = ""
        self.results.text = ""
        
        self.tests.append(FetchAll())
        self.tests.append(DidFault())
        self.tests.append(SingleFault())
        self.tests.append(BatchFault())
        self.tests.append(Prefetch())
        self.tests.append(Cache())
        self.tests.append(Uniquing())
        self.tests.append(Predicate())
        self.tests.append(Subquery())
        self.tests.append(BatchUpdate())
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

