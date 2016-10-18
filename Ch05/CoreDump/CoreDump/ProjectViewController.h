//
//  ProjectViewController.h
//  CoreDump
//
//  Created by Rob Warner on 9/28/14.
//  Copyright (c) 2014 Michael Privat and Rob Warner. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@class Project;

@interface ProjectViewController : UIViewController

@property (strong, nonatomic) Project *project;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (weak, nonatomic) IBOutlet UITextField *name;
@property (weak, nonatomic) IBOutlet UITextField *url;

- (id)initWithProject:(Project *)project fetchedResultsController:(NSFetchedResultsController *)fetchedResultsController;
- (IBAction)save:(id)sender;
- (IBAction)cancel:(id)sender;

@end
