//
//  FetchAll.m
//  PerformanceTuning
//
//  Created by Rob Warner on 11/3/14.
//  Copyright (c) 2014 Michael Privat and Rob Warner. All rights reserved.
//

#import "FetchAll.h"

@implementation FetchAll

- (NSString *)runTestWithContext:(NSManagedObjectContext *)context {
  NSFetchRequest *peopleFetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Person"];
  NSFetchRequest *selfiesFetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Selfie"];
  NSFetchRequest *socialNetworksFetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"SocialNetwork"];
  
  NSArray *people = [context executeFetchRequest:peopleFetchRequest
                                           error:nil];
  NSArray *selfies = [context executeFetchRequest:selfiesFetchRequest
                                            error:nil];
  NSArray *socialNetworks = [context executeFetchRequest:socialNetworksFetchRequest
                                                   error:nil];
  
  return [NSString stringWithFormat:@"Fetched %ld people, %ld selfies, and %ld social networks", [people count], [selfies count], [socialNetworks count]];
}

@end
