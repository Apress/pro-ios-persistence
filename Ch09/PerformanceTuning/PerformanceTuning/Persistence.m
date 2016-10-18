//
//  Persistence.m
//  PerformanceTuning
//
//  Created by Rob Warner on 11/3/14.
//  Copyright (c) 2014 Michael Privat and Rob Warner. All rights reserved.
//

#import "Persistence.h"

@implementation Persistence

- (instancetype)init {
  self = [super init];
  if (self != nil) {
    // Initialize the managed object model
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"PerformanceTuning" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    // Initialize the persistent store coordinator
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"PerformanceTuning.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                   configuration:nil
                                                             URL:storeURL
                                                         options:nil
                                                           error:&error]) {
      NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
      abort();
    }
    
    // Initialize the managed object context
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
  }
  return self;
}

#pragma mark - Helper Methods

- (void)saveContext {
  NSError *error = nil;
  if ([self.managedObjectContext hasChanges] && ![self.managedObjectContext save:&error]) {
    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    abort();
  }
}

- (NSURL *)applicationDocumentsDirectory {
  return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (void)loadData {
  static int NumberOfRows = 500;
  
  // Fetch the people. If we have NumberOfRows, assume our data is loaded.
  NSFetchRequest *peopleFetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Person"];
  NSArray *people = [self.managedObjectContext executeFetchRequest:peopleFetchRequest
                                                             error:nil];
  if ([people count] != NumberOfRows) {
    NSLog(@"Creating objects");
    // Load the objects
    for (int i = 1; i <= NumberOfRows; i++) {
      [self insertObjectForName:@"Person" index:i];
      [self insertObjectForName:@"Selfie" index:i];
      [self insertObjectForName:@"SocialNetwork" index:i];
    }
    
    // Get all the people, selfies, and social networks
    people = [self.managedObjectContext executeFetchRequest:peopleFetchRequest
                                                      error:nil];
    
    NSFetchRequest *selfiesFetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Selfie"];
    NSArray *selfies = [self.managedObjectContext executeFetchRequest:selfiesFetchRequest
                                                                error:nil];
    
    NSFetchRequest *socialNetworksFetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"SocialNetwork"];
    NSArray *socialNetworks = [self.managedObjectContext executeFetchRequest:socialNetworksFetchRequest error:nil];
    
    // Set up all the relationships
    NSLog(@"Creating relationships");
    for (NSManagedObject *selfie in selfies) {
      NSMutableSet *peopleSet = [selfie mutableSetValueForKey:@"people"];
      [peopleSet addObjectsFromArray:people];
      
      NSMutableSet *socialNetworksSet = [selfie mutableSetValueForKey:@"socialNetworks"];
      [socialNetworksSet addObjectsFromArray:socialNetworks];
    }
    
    [self saveContext];
  }
}

- (NSManagedObject *)insertObjectForName:(NSString *)name index:(NSInteger)index {
  NSManagedObject *object = [NSEntityDescription insertNewObjectForEntityForName:name
                                                          inManagedObjectContext:self.managedObjectContext];
  [object setValue:[NSString stringWithFormat:@"%@ %ld", name, (long)index]
            forKey:@"name"];
  [object setValue:[NSNumber numberWithInt:((arc4random() % 10) + 1)]
            forKey:@"rating"];
  return object;
}

@end
