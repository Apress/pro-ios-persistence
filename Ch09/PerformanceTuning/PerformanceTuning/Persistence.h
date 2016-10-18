//
//  Persistence.h
//  PerformanceTuning
//
//  Created by Rob Warner on 11/3/14.
//  Copyright (c) 2014 Michael Privat and Rob Warner. All rights reserved.
//

@import CoreData;

@interface Persistence : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
- (void)loadData;

@end
