//
//  Cache.m
//  PerformanceTuning
//
//  Created by Rob Warner on 11/4/14.
//  Copyright (c) 2014 Michael Privat and Rob Warner. All rights reserved.
//

#import "Cache.h"
#import "Selfie.h"
#import "SocialNetwork.h"
#import "Person.h"

@implementation Cache

- (NSString *)runTestWithContext:(NSManagedObjectContext *)context {
  NSMutableString *result = [NSMutableString string];
  
  // Load the data while it's not cached
  NSDate *start1 = [NSDate date];
  [self loadDataWithContext:context];
  NSDate *end1 = [NSDate date];
  
  // Record the results
  [result appendFormat:@"Without cache: %.3f s\n", [end1 timeIntervalSinceDate:start1]];
  
  // Load the data while it's cached
  NSDate *start2 = [NSDate date];
  [self loadDataWithContext:context];
  NSDate *end2 = [NSDate date];
  
  // Record the results
  [result appendFormat:@"With cache: %.3f s\n", [end2 timeIntervalSinceDate:start2]];
  
  return result;
}

- (void)loadDataWithContext:(NSManagedObjectContext *)context {
  // Load the selfies
  NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Selfie"];
  NSArray *selfies = [context executeFetchRequest:fetchRequest error:nil];
  
  // Loop through the selfies
  for (Selfie *selfie in selfies) {
    // Load the selfie's data
    [selfie valueForKey:@"name"];
    
    // Loop through the social networks
    for (SocialNetwork *socialNetwork in selfie.socialNetworks) {
      // Load the social network's data
      [socialNetwork valueForKey:@"name"];
    }
  }
}

@end
