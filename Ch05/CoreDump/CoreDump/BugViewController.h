//
//  BugViewController.h
//  CoreDump
//
//  Created by Rob Warner on 9/29/14.
//  Copyright (c) 2014 Michael Privat and Rob Warner. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Bug;
@class Project;

@interface BugViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (strong, nonatomic) Bug *bug;
@property (strong, nonatomic) Project *project;
@property (weak, nonatomic) IBOutlet UITextField *bugTitle;
@property (weak, nonatomic) IBOutlet UITextView *details;
@property (weak, nonatomic) IBOutlet UIImageView *screenshot;

- (id)initWithBug:(Bug *)bug project:(Project *)project;
- (IBAction)save:(id)sender;
- (IBAction)cancel:(id)sender;

@end
