//
//  DidFault.m
//  PerformanceTuning
//
//  Created by Rob Warner on 11/4/14.
//  Copyright (c) 2014 Michael Privat and Rob Warner. All rights reserved.
//

#import "DidFault.h"
#import "Selfie.h"
#import "SocialNetwork.h"

@implementation DidFault

-(NSString *)runTestWithContext:(NSManagedObjectContext *)context {
  NSString *result = nil;
  
  // 1) Fetch the first selfie
  NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Selfie"];
  fetchRequest.predicate = [NSPredicate predicateWithFormat:@"name = %@", @"Selfie 1"];
  NSArray *selfies = [context executeFetchRequest:fetchRequest error:nil];
  if ([selfies count] == 1) {
    Selfie *selfie = selfies[0];
    
    // 2) Grab a social network from the selfie
    SocialNetwork *socialNetwork = [selfie.socialNetworks anyObject];
    if (socialNetwork != nil) {
      // 3) Check if it's a fault
      result = [NSString stringWithFormat:@"Social Network %@ a fault\n",
                [socialNetwork isFault] ? @"is" : @"is not"];
      
      // 4) Get the name
      result = [result stringByAppendingFormat:@"Social Network is named '%@'\n",
                socialNetwork.name];
      
      // 5) Check if it's a fault
      result = [result stringByAppendingFormat:@"Social Network %@ a fault\n",
                [socialNetwork isFault] ? @"is" : @"is not"];
      
      // 6) Turn it back into a fault
      [context refreshObject:socialNetwork mergeChanges:NO];
      result = [result stringByAppendingFormat:@"Turning Social Network into a fault\n"];
      
      // 7) Check if it's a fault
      result = [result stringByAppendingFormat:@"Social Network %@ a fault\n",
                [socialNetwork isFault] ? @"is" : @"is not"];
    } else {
      result = @"Couldn't find social networks for selfie";
    }
  } else {
    result = @"Failed to fetch first selfie";
  }
  return result;
}

@end
