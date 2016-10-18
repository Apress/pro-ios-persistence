//
//  BugViewController.swift
//  CoreDumpSwift
//
//  Created by Rob Warner on 9/29/14.
//  Copyright (c) 2014 Michael Privat and Rob Warner. All rights reserved.
//

import UIKit
import CoreData

class BugViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
  
  var project: Project? = nil
  var bug: Bug? = nil
  
  @IBOutlet weak var bugTitle: UITextField!
  @IBOutlet weak var details: UITextView!
  @IBOutlet weak var screenshot: UIImageView!
  
  convenience init(project: Project, andBug bug: Bug?) {
    self.init(nibName: "BugViewController", bundle: nil)
    
    self.project = project
    self.bug = bug
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    if let bug = self.bug {
      self.bugTitle.text = bug.title
      self.details.text = bug.details
      self.screenshot.image = UIImage(data: bug.screenshot)
    }
    else {
      self.details.text = ""
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.screenshot.layer.borderColor = UIColor.blackColor().CGColor
    self.screenshot.layer.borderWidth = 1
    
    let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("screenshotTapped:"))
    self.screenshot.addGestureRecognizer(tapGestureRecognizer)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func screenshotTapped(recognizer: UITapGestureRecognizer) {
    let imagePickerController = UIImagePickerController()
    imagePickerController.delegate = self
    imagePickerController.sourceType = .PhotoLibrary
    imagePickerController.allowsEditing = true
    self.presentViewController(imagePickerController, animated: true, completion: nil)
  }
  
  @IBAction func cancel(sender: AnyObject) {
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
  @IBAction func save(sender: AnyObject) {
    if let context = self.project?.managedObjectContext {
      if bug == nil {
        self.bug = NSEntityDescription.insertNewObjectForEntityForName("Bug", inManagedObjectContext: context) as? Bug
      }
      
      self.bug?.project = self.project!
      self.bug?.title = self.bugTitle.text
      self.bug?.details = self.details.text
      if self.screenshot.image != nil {
        self.bug?.screenshot = UIImagePNGRepresentation(self.screenshot.image)
      }
      
      var error: NSError? = nil
      if context.hasChanges && !context.save(&error) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog("Unresolved error \(error), \(error!.userInfo)")
        abort()
      }
    }
    
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
  func imagePickerControllerDidCancel(picker: UIImagePickerController) {
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
  func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
    self.dismissViewControllerAnimated(true, completion: nil)
    let image = info[UIImagePickerControllerEditedImage] as UIImage
    
    dispatch_async(dispatch_get_main_queue(), { () -> Void in
      self.screenshot.image = image
    })
  }  
}
