//
//  DetailViewController.swift
//  CoreDumpSwift
//
//  Created by Rob Warner on 9/28/14.
//  Copyright (c) 2014 Michael Privat and Rob Warner. All rights reserved.
//

import UIKit

class DetailViewController: UITableViewController {
  
  var project: Project? = nil
  
  func configureView() {
    var addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "insertNewObject:")
    self.navigationItem.rightBarButtonItem = addButton
  }
  
  func insertNewObject(sender: AnyObject?) {
    let bugViewController = BugViewController(project: self.project!, andBug: nil)
    self.presentViewController(bugViewController, animated: true, completion: nil)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    self.configureView()
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    self.title = self.project?.name
    self.tableView.reloadData()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  //MARK: Table View
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    let result = self.project?.bugs.count
    return result!
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("DetailCell") as UITableViewCell
    self.configureCell(cell, atIndexPath: indexPath)
    return cell
    
  }

  override func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
    let bug = sortedBugs()?[indexPath.row]
    let bugViewController = BugViewController(project: self.project!, andBug: bug)
    self.presentViewController(bugViewController, animated: true, completion: nil)
  }
  
  func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
    let bug = sortedBugs()?[indexPath.row]
    cell.textLabel?.text = bug?.title
  }
  
  func sortedBugs() -> [Bug]? {
    let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
    let results = self.project?.bugs.sortedArrayUsingDescriptors([sortDescriptor])
    return results as [Bug]?
  }
}
