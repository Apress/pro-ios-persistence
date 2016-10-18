//
//  Predicate.m
//  PerformanceTuning
//
//  Created by Rob Warner on 11/5/14.
//  Copyright (c) 2014 Michael Privat and Rob Warner. All rights reserved.
//

#import "Predicate.h"

@implementation Predicate

- (NSString *)runTestWithContext:(NSManagedObjectContext *)context {
  NSMutableString *result = [NSMutableString string];
  
  // Set up the first fetch request
  NSFetchRequest *fetchRequest1 = [NSFetchRequest fetchRequestWithEntityName:@"Selfie"];
  fetchRequest1.predicate = [NSPredicate predicateWithFormat:@"(name LIKE %@) OR (rating < %d)", @"*e*ie*", 5];
  
  // Run the first fetch request and measure
  NSDate *start1 = [NSDate date];
  for (int i = 0; i < 1000; i++) {
    [context reset];
    [context executeFetchRequest:fetchRequest1 error:nil];
  }
  NSDate *end1 = [NSDate date];
  [result appendFormat:@"Slow predicate: %.3f s\n", [end1 timeIntervalSinceDate:start1]];
  
  // Set up the second fetch request
  NSFetchRequest *fetchRequest2 = [NSFetchRequest fetchRequestWithEntityName:@"Selfie"];
  fetchRequest1.predicate = [NSPredicate predicateWithFormat:@"(rating < %d) OR (name LIKE %@)", 5, @"*e*ie*"];
  
  // Run the first fetch request and measure
  NSDate *start2 = [NSDate date];
  for (int i = 0; i < 1000; i++) {
    [context reset];
    [context executeFetchRequest:fetchRequest2 error:nil];
  }
  NSDate *end2 = [NSDate date];
  [result appendFormat:@"Fast predicate: %.3f s\n", [end2 timeIntervalSinceDate:start2]];
  
  return result;
}

@end
