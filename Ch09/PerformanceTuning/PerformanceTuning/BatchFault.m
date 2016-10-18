//
//  BatchFault.m
//  PerformanceTuning
//
//  Created by Rob Warner on 11/4/14.
//  Copyright (c) 2014 Michael Privat and Rob Warner. All rights reserved.
//

#import "BatchFault.h"
#import "Selfie.h"
#import "SocialNetwork.h"
#import "Person.h"

@implementation BatchFault

- (NSString *)runTestWithContext:(NSManagedObjectContext *)context {
  // Fetch all the selfies
  NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Selfie"];
  
  // Return the selfies as non-faults
  [fetchRequest setReturnsObjectsAsFaults:NO];
  NSArray *selfies = [context executeFetchRequest:fetchRequest error:nil];
  
  // Loop through all the selfies
  for (Selfie *selfie in selfies) {
    // Doesn't fire a fault, the data are already in memory
    [selfie valueForKey:@"name"];
    
    // For this selfie, fire faults for all the social networks
    NSFetchRequest *snFetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"SocialNetwork"];
    [snFetchRequest setReturnsObjectsAsFaults:NO];
    [context executeFetchRequest:snFetchRequest error:nil];
    
    // For this selfie, fire faults for all the social networks
    NSFetchRequest *pFetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Person"];
    [pFetchRequest setReturnsObjectsAsFaults:NO];
    [context executeFetchRequest:pFetchRequest error:nil];
    
    // Loop through the social networks for this selfie
    for (SocialNetwork *socialNetwork in selfie.socialNetworks) {
      // Doesn't fire a fault, the data are already in memory
      [socialNetwork valueForKey:@"name"];
      
      // Put this social network back in a fault
      [context refreshObject:socialNetwork mergeChanges:NO];
    }
    
    // Loop through the people for this selfie
    for (Person *person in selfie.people) {
      // Doesn't fire a fault, the data are already in memory
      [person valueForKey:@"name"];
      
      // Put this person back in a fault
      [context refreshObject:person mergeChanges:NO];
    }
  }
  return @"Test complete";
}

@end
