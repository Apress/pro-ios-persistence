//
//  ProjectViewController.swift
//  CoreDumpSwift
//
//  Created by Rob Warner on 9/28/14.
//  Copyright (c) 2014 Michael Privat and Rob Warner. All rights reserved.
//

import UIKit
import CoreData

class ProjectViewController: UIViewController {
  
  var fetchedResultsController: NSFetchedResultsController? = nil
  var project: Project? = nil
  
  @IBOutlet weak var name: UITextField!
  @IBOutlet weak var url: UITextField!
  
  convenience init(project: Project?, fetchedResultsController: NSFetchedResultsController) {
    self.init(nibName: "ProjectViewController", bundle: nil)
    
    self.fetchedResultsController = fetchedResultsController
    self.project = project
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    if let project = self.project {
      self.name.text = project.name
      self.url.text = project.url
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func host() -> String {
    let url : NSString = self.project!.url
    let regex = NSRegularExpression(pattern: ".*?//(.*?)/.*", options: nil, error: nil)
    let match = regex.firstMatchInString(url, options: NSMatchingOptions.ReportCompletion, range: NSMakeRange(0, url.length))
    if match != nil {
      let range = match?.rangeAtIndex(1)
      if let range = range {
        return url.substringWithRange(range)
      }
      else {
        return url
      }
    }
    else {
      return url
    }
  }
  
  @IBAction func cancel(sender: AnyObject) {
    self.dismissViewControllerAnimated(true, completion: nil)
  }

  @IBAction func save(sender: AnyObject) {
    if let context = fetchedResultsController?.managedObjectContext {
      
      if self.project == nil {
        var entity = self.fetchedResultsController?.fetchRequest.entity
        self.project = NSEntityDescription.insertNewObjectForEntityForName(entity!.name, inManagedObjectContext: context) as? Project
      }
      
      self.project?.name = self.name.text
      self.project?.url = self.url.text
      self.project?.host = self.host()
      
      var error: NSError? = nil
      if context.hasChanges && !context.save(&error) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog("Unresolved error \(error), \(error!.userInfo)")
        abort()
      }
      
      self.dismissViewControllerAnimated(true, completion: nil)
    }
  }
  
  /*
  // MARK: - Navigation
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
  // Get the new view controller using segue.destinationViewController.
  // Pass the selected object to the new view controller.
  }
  */
  
}
