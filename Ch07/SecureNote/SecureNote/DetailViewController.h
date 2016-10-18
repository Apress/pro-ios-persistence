//
//  DetailViewController.h
//  SecureNote
//
//  Created by Rob Warner on 10/13/14.
//  Copyright (c) 2014 Michael Privat and Rob Warner. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Note;

@interface DetailViewController : UIViewController

@property (strong, nonatomic) Note *note;
@property (weak, nonatomic) IBOutlet UITextField *noteTitle;
@property (weak, nonatomic) IBOutlet UITextView *noteBody;

@end

