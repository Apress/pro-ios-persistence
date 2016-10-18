//
//  BatchUpdate.m
//  PerformanceTuning
//
//  Created by Rob Warner on 11/5/14.
//  Copyright (c) 2014 Michael Privat and Rob Warner. All rights reserved.
//

#import "BatchUpdate.h"

@implementation BatchUpdate

- (NSString *)runTestWithContext:(NSManagedObjectContext *)context {
  NSMutableString *result = [NSMutableString string];
  
  // Update all the selfies one at a time
  NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Selfie"];
  NSDate *start1 = [NSDate date];
  NSArray *selfies = [context executeFetchRequest:fetchRequest error:nil];
  for (NSManagedObject *selfie in selfies) {
    [selfie setValue:@5 forKey:@"rating"];
  }
  [context save:nil];
  NSDate *end1 = [NSDate date];
  [result appendFormat:@"One-at-a-time update: %.3f s\n", [end1 timeIntervalSinceDate:start1]];
  
  // Update the selfies as a batch
  
  // Create the batch update request for the Selfie entity
  NSBatchUpdateRequest *batchUpdateRequest = [NSBatchUpdateRequest batchUpdateRequestWithEntityName:@"Selfie"];
  
  // Set the desired result type to be the count of updated objects
  batchUpdateRequest.resultType = NSUpdatedObjectsCountResultType;
  
  // Update the rating property to 7
  batchUpdateRequest.propertiesToUpdate = @{ @"rating" : @7 };
  
  // Mark the time and run the update
  NSDate *start2 = [NSDate date];
  NSBatchUpdateResult *batchUpdateResult = (NSBatchUpdateResult *)[context executeRequest:batchUpdateRequest error:nil];
  NSDate *end2 = [NSDate date];
  
  // Record the results
  [result appendFormat:@"Batch update (%@ rows): %.3f s\n", batchUpdateResult.result, [end2 timeIntervalSinceDate:start2]];
  
  return result;
}

@end
