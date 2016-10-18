//
//  Uniquing.m
//  PerformanceTuning
//
//  Created by Rob Warner on 11/5/14.
//  Copyright (c) 2014 Michael Privat and Rob Warner. All rights reserved.
//

#import "Uniquing.h"
#import "Selfie.h"
#import "Person.h"

@implementation Uniquing

- (NSString *)runTestWithContext:(NSManagedObjectContext *)context {
  // Array to hold the people for comparison purposes
  NSArray *referencePeople = nil;
  
  // Sorting for the people
  NSSortDescriptor *sortDescriptor  = [[NSSortDescriptor alloc] initWithKey:@"name"
                                                                  ascending:YES];
  
  // Fetch all the selfies
  NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Selfie"];
  NSArray *selfies = [context executeFetchRequest:fetchRequest error:nil];
  
  // Loop through the selfies
  for (Selfie *selfie in selfies) {
    // Get the sorted people
    NSArray *people = [selfie.people sortedArrayUsingDescriptors:@[sortDescriptor]];
    
    // Store the first selfie's people for comparison purposes
    if (referencePeople == nil) {
      referencePeople = people;
    } else {
      // Do the comparison
      for (int i = 0, n = (int)[people count]; i < n; i++) {
        if (people[i] != referencePeople[i]) {
          return [NSString stringWithFormat:@"Uniquing test failed; %@ != %@",
                  people[i], referencePeople[i]];
        }
      }
    }
  }
  return @"Test complete";
}

@end
