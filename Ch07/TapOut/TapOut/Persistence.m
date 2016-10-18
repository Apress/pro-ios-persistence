//
//  Persistence.m
//  TapOut
//
//  Created by Rob Warner on 10/13/14.
//  Copyright (c) 2014 Michael Privat and Rob Warner. All rights reserved.
//

#import "Persistence.h"
#import "Tap.h"

@implementation Persistence

- (id)init {
  self = [super init];
  if (self != nil) {
    // Initialize the managed object model
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"TapOut" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    // Initialize the persistent store coordinator
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"TapOut.sqlite"];
    
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

#pragma mark - Taps

- (void)addTap:(CGPoint)point {
  Tap *tap = [NSEntityDescription insertNewObjectForEntityForName:@"Tap" inManagedObjectContext:self.managedObjectContext];
  tap.x = point.x;
  tap.y = point.y;
  tap.color = [self randomColor];
  [self saveContext];
}

- (UIColor *)randomColor {
  float red = (arc4random() % 256) / 255.0f;
  float green = (arc4random() % 256) / 255.0f;
  float blue = (arc4random() % 256) / 255.0f;
  
  return [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
}

- (NSArray *)taps {
  NSError *error = nil;
  NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Tap"];
  NSArray *taps = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
  if (taps == nil) {
    NSLog(@"Error fetching taps %@, %@", error, [error userInfo]);
  }
  return taps;
}

@end
