//
//  Subquery.m
//  PerformanceTuning
//
//  Created by Rob Warner on 11/5/14.
//  Copyright (c) 2014 Michael Privat and Rob Warner. All rights reserved.
//

#import "Subquery.h"
#import "Selfie.h"
#import "Person.h"

@implementation Subquery

- (NSString *)runTestWithContext:(NSManagedObjectContext *)context {
  NSMutableString *result = [NSMutableString string];
  
  // Set up the first fetch request, with no subquery
  NSFetchRequest *fetchRequest1 = [NSFetchRequest fetchRequestWithEntityName:@"Selfie"];
  fetchRequest1.predicate = [NSPredicate predicateWithFormat:@"(rating < %d) OR (name LIKE %@)", 5, @"*e*ie*"];
  
  // Mark the time and get the results
  NSDate *start1 = [NSDate date];
  NSArray *selfies = [context executeFetchRequest:fetchRequest1 error:nil];
  NSMutableDictionary *people1 = [NSMutableDictionary dictionary];
  for (Selfie *selfie in selfies) {
    for (Person *person in selfie.people) {
      [people1 setObject:person forKey:[[[person objectID] URIRepresentation] description]];
    }
  }
  NSDate *end1 = [NSDate date];
  
  // Record the results of the manual request
  [result appendFormat:@"No subquery: %.3f s\n", [end1 timeIntervalSinceDate:start1]];
  [result appendFormat:@"People retrieved: %ld\n", [people1 count]];
  
  // Reset the context so we get clean results
  [context reset];
  
  // Set up the second fetch request, with subquery
  NSFetchRequest *fetchRequest2 = [NSFetchRequest fetchRequestWithEntityName:@"Person"];
  fetchRequest2.predicate = [NSPredicate predicateWithFormat:@"(SUBQUERY(selfies, $x, ($x.rating < %d) OR ($x.name LIKE %@)).@count > 0)", 5, @"*e*ie*"];
  
  // Mark the time and get the results
  NSDate *start2 = [NSDate date];
  NSArray *people2 = [context executeFetchRequest:fetchRequest2 error:nil];
  NSDate *end2 = [NSDate date];
  
  // Record the results of the subquery request
  [result appendFormat:@"Subquery: %.3f s\n", [end2 timeIntervalSinceDate:start2]];
  [result appendFormat:@"People retrieved: %ld\n", [people2 count]];
  
  return result;
}

@end
