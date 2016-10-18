//
//  ViewController.m
//  PerformanceTuning
//
//  Created by Rob Warner on 11/3/14.
//  Copyright (c) 2014 Michael Privat and Rob Warner. All rights reserved.
//

#import "ViewController.h"
#import "FetchAll.h"
#import "AppDelegate.h"
#import "Persistence.h"
#import "DidFault.h"
#import "SingleFault.h"
#import "BatchFault.h"
#import "Prefetch.h"
#import "Cache.h"
#import "Uniquing.h"
#import "Predicate.h"
#import "Subquery.h"
#import "BatchUpdate.h"

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.startTime.text = @"";
  self.stopTime.text = @"";
  self.elapsedTime.text = @"";
  self.results.text = @"";
  
  self.tests = @[[[FetchAll alloc] init],
                 [[DidFault alloc] init],
                 [[SingleFault alloc] init],
                 [[BatchFault alloc] init],
                 [[Prefetch alloc] init],
                 [[Cache alloc] init],
                 [[Uniquing alloc] init],
                 [[Predicate alloc] init],
                 [[Subquery alloc] init],
                 [[BatchUpdate alloc] init]];
}

#pragma mark - UIPickerViewDataSource methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
  return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
  return [self.tests count];
}

#pragma mark - UIPickerViewDelegate methods

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
  id <PerfTest> test = self.tests[row];
  return [[test class] description];
}

#pragma mark - Handlers

- (IBAction)runTest:(id)sender {
  // Get the selected test
  id <PerfTest> test = self.tests[[self.testPicker selectedRowInComponent:0]];
  AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
  NSManagedObjectContext *context = delegate.persistence.managedObjectContext;
  
  // Clear out any objects so we get clean test results
  [context reset];
  
  // Mark the start time, run the test, and mark the stop time
  NSDate *start = [NSDate date];
  NSString *results = [test runTestWithContext:delegate.persistence.managedObjectContext];
  NSDate *stop = [NSDate date];
  
  // Update the UI with the test results
  self.startTime.text = [start description];
  self.stopTime.text = [stop description];
  self.elapsedTime.text = [NSString stringWithFormat:@"%.03f seconds", [stop timeIntervalSinceDate:start]];
  self.results.text = results;
}

@end
