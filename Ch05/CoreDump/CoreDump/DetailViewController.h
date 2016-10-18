//
//  DetailViewController.h
//  CoreDump
//
//  Created by Rob Warner on 9/23/14.
//  Copyright (c) 2014 Michael Privat and Rob Warner. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Project;

@interface DetailViewController : UITableViewController

@property (strong, nonatomic) Project *project;

@end

