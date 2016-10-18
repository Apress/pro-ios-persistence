//
//  SingleFault.m
//  PerformanceTuning
//
//  Created by Rob Warner on 11/4/14.
//  Copyright (c) 2014 Michael Privat and Rob Warner. All rights reserved.
//

#import "SingleFault.h"
#import "Selfie.h"
#import "SocialNetwork.h"
#import "Person.h"

@implementation SingleFault

- (NSString *)runTestWithContext:(NSManagedObjectContext *)context {
  // Fetch all the selfies
  NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Selfie"];
  NSArray *selfies = [context executeFetchRequest:fetchRequest error:nil];
  
  // Loop through all the selfies
  for (Selfie *selfie in selfies) {
    // Fire a fault just for this selfie
    [selfie valueForKey:@"name"];
    
    // Loop through the social networks for this selfie
    for (SocialNetwork *socialNetwork in selfie.socialNetworks) {
      // Fire a fault just for this social network
      [socialNetwork valueForKey:@"name"];
      
      // Put this social network back in a fault
      [context refreshObject:socialNetwork mergeChanges:NO];
    }
    
    // Loop through the people for this selfie
    for (Person *person in selfie.people) {
      // Fire a fault for this person
      [person valueForKey:@"name"];
      
      // Put this person back in a fault
      [context refreshObject:person mergeChanges:NO];
    }
  }
  return @"Test complete";
}

@end
