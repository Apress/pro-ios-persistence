//
//  MasterViewController.swift
//  CoreDumpSwift
//
//  Created by Rob Warner on 9/28/14.
//  Copyright (c) 2014 Michael Privat and Rob Warner. All rights reserved.
//

import UIKit
import CoreData

class MasterViewController: UITableViewController, NSFetchedResultsControllerDelegate, UISearchResultsUpdating {

  var managedObjectContext: NSManagedObjectContext? = nil
  var searchController: UISearchController!
  var searchPredicate: NSPredicate? = nil

  override func awakeFromNib() {
    super.awakeFromNib()
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.navigationItem.leftBarButtonItem = self.editButtonItem()

    let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "insertNewObject:")
    self.navigationItem.rightBarButtonItem = addButton
    
    // Create the search controller with this controller displaying the search results
    self.searchController = UISearchController(searchResultsController: nil)
    self.searchController.dimsBackgroundDuringPresentation = false
    self.searchController.searchResultsUpdater = self
    self.searchController.searchBar.sizeToFit()
    self.tableView.tableHeaderView = self.searchController?.searchBar
    self.tableView.delegate = self
    self.definesPresentationContext = true
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  func insertNewObject(sender: AnyObject) {
    let projectViewController = ProjectViewController(project: nil, fetchedResultsController: self.fetchedResultsController)
    
    self.presentViewController(projectViewController, animated: true, completion: nil)
  }
  
  // MARK: - UISearchController
  
  func updateSearchResultsForSearchController(searchController: UISearchController) {
    let searchText = self.searchController?.searchBar.text
    if let searchText = searchText {
      self.searchPredicate = searchText.isEmpty ? nil : NSPredicate(format: "name contains[c] %@ or url contains[c] %@", searchText, searchText)
      
      self.tableView.reloadData()
    }
  }

  // MARK: - Segues

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "showDetail" {
      if let indexPath = self.tableView.indexPathForSelectedRow() {
        
        let project = self.searchPredicate == nil ?
          self.fetchedResultsController.objectAtIndexPath(indexPath) as Project :
          self.fetchedResultsController.fetchedObjects?.filter() {
            return self.searchPredicate!.evaluateWithObject($0)
            }[indexPath.row] as Project

        (segue.destinationViewController as DetailViewController).project = project
      }
    }
  }

  // MARK: - Table View

  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return self.searchPredicate == nil ? self.fetchedResultsController.sections?.count ?? 0 : 1
  }

  override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    if self.searchPredicate == nil {
      let sectionInfo = self.fetchedResultsController.sections![section] as NSFetchedResultsSectionInfo
      return sectionInfo.name
    } else {
      return nil
    }
  }

  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if self.searchPredicate == nil {
      let sectionInfo = self.fetchedResultsController.sections![section] as NSFetchedResultsSectionInfo
      return sectionInfo.numberOfObjects
    } else {
      let filteredObjects = self.fetchedResultsController.fetchedObjects?.filter() {
        return self.searchPredicate!.evaluateWithObject($0)
      }
      return filteredObjects == nil ? 0 : filteredObjects!.count
    }
  }

  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
    self.configureCell(cell, atIndexPath: indexPath)
    return cell
  }

  override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    return self.searchPredicate == nil
  }

  override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    if editingStyle == .Delete {
        let context = self.fetchedResultsController.managedObjectContext
        context.deleteObject(self.fetchedResultsController.objectAtIndexPath(indexPath) as NSManagedObject)
            
        var error: NSError? = nil
        if !context.save(&error) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            //println("Unresolved error \(error), \(error.userInfo)")
            abort()
        }
    }
  }

  override func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
    if tableView.editing {
      let project = self.fetchedResultsController.objectAtIndexPath(indexPath) as? Project
      let projectViewController = ProjectViewController(project: project, fetchedResultsController: self.fetchedResultsController)
      self.presentViewController(projectViewController, animated: true, completion: nil)
    }
  }

  func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
    let project = self.searchPredicate == nil ?
      self.fetchedResultsController.objectAtIndexPath(indexPath) as Project :
        self.fetchedResultsController.fetchedObjects?.filter() {
            return self.searchPredicate!.evaluateWithObject($0)
        }[indexPath.row] as Project

    cell.textLabel?.text = project.name
    cell.detailTextLabel?.text = project.url
  }

  // MARK: - Fetched results controller

  var fetchedResultsController: NSFetchedResultsController {
      if _fetchedResultsController != nil {
          return _fetchedResultsController!
      }
      
      let fetchRequest = NSFetchRequest(entityName: "Project")
      
      // Set the batch size to a suitable number.
      fetchRequest.fetchBatchSize = 20
      
      // Edit the sort key as appropriate.
      let hostSortDescriptor = NSSortDescriptor(key: "host", ascending: true)
      let nameSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
      let sortDescriptors = [hostSortDescriptor, nameSortDescriptor]
      
      fetchRequest.sortDescriptors = sortDescriptors
      
      // Edit the section name key path and cache name if appropriate.
      // nil for section name key path means "no sections".
      let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: "host", cacheName: "Master")

      aFetchedResultsController.delegate = self
      _fetchedResultsController = aFetchedResultsController
      
  	var error: NSError? = nil
  	if !_fetchedResultsController!.performFetch(&error) {
  	     // Replace this implementation with code to handle the error appropriately.
  	     // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
           //println("Unresolved error \(error), \(error.userInfo)")
  	     abort()
  	}
      
      return _fetchedResultsController!
  }    
  var _fetchedResultsController: NSFetchedResultsController? = nil

  func controllerWillChangeContent(controller: NSFetchedResultsController) {
      self.tableView.beginUpdates()
  }

  func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
      switch type {
          case .Insert:
              self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
          case .Delete:
              self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
          default:
              return
      }
  }

  func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath) {
      switch type {
          case .Insert:
              tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Fade)
          case .Delete:
              tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
          case .Update:
              self.configureCell(tableView.cellForRowAtIndexPath(indexPath)!, atIndexPath: indexPath)
          case .Move:
              tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
              tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Fade)
          default:
              return
      }
  }

  func controllerDidChangeContent(controller: NSFetchedResultsController) {
      self.tableView.endUpdates()
  }

  /*
   // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
   
   func controllerDidChangeContent(controller: NSFetchedResultsController) {
       // In the simplest, most efficient, case, reload the table view.
       self.tableView.reloadData()
   }
   */

}

