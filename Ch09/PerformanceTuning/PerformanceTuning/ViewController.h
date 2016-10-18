//
//  ViewController.h
//  PerformanceTuning
//
//  Created by Rob Warner on 11/3/14.
//  Copyright (c) 2014 Michael Privat and Rob Warner. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, weak) IBOutlet UILabel *startTime;
@property (nonatomic, weak) IBOutlet UILabel *stopTime;
@property (nonatomic, weak) IBOutlet UILabel *elapsedTime;
@property (nonatomic, weak) IBOutlet UITextView *results;
@property (nonatomic, weak) IBOutlet UIPickerView *testPicker;
@property (nonatomic, strong) NSArray *tests;

- (IBAction)runTest:(id)sender;

@end

