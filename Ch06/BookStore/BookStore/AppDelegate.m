//
// From the book Pro iOS Persistence
// Michael Privat and Rob Warner
// Published by Apress, 2014
// Source released under The MIT License
// http://opensource.org/licenses/MIT
//
// Contact information:
// Michael: @michaelprivat -- http://michaelprivat.com -- mprivat@mac.com
// Rob: @hoop33 -- http://grailbox.com -- rwarner@grailbox.com
//

#import "AppDelegate.h"
#import "BookCategory.h"
#import "Book.h"
#import "Page.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

/* Moved to ViewController */
//- (void)initStore {
//  NSFileManager *fm = [NSFileManager defaultManager];
//  
//  NSString *seed = [[NSBundle mainBundle] pathForResource: @"seed" ofType: @"sqlite"];
//  NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"BookStoreEnhanced.sqlite"];
//  
//  if([fm fileExistsAtPath:[storeURL path]]) {
//    [fm removeItemAtPath:[storeURL path] error:nil];
//  }
//  
//  if (![fm fileExistsAtPath:[storeURL path]]) {
//    NSLog(@"Using the original seed");
//    NSError *error = nil;
//    if (![fm copyItemAtPath:seed toPath:[storeURL path] error:&error]) {
//      NSLog(@"Error seeding: %@", error);
//      return;
//    }
//    
//    NSLog(@"Store successfully initialized using the original seed");
//  }
//  else {
//    NSLog(@"The original seed isn't needed. There is already a backing store.");
//
//    // Update 1
//    {
//      NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Book"];
//      request.predicate = [NSPredicate predicateWithFormat:@"title=%@", @"The fourth book"];
//      NSUInteger count = [self.managedObjectContext countForFetchRequest:request error:nil];
//      if(count == 0) {
//        NSLog(@"Applying batch update 1");
//        
//        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Category"];
//        NSArray *categories = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
//        
//        BookCategory *category = [categories lastObject];
//        Book *book4 = [NSEntityDescription insertNewObjectForEntityForName:@"Book" inManagedObjectContext:self.managedObjectContext];
//        book4.title = @"The fourth book";
//        book4.price = 12;
//        
//        [category addBooks:[NSSet setWithObjects:book4, nil]];
//        
//        [self.managedObjectContext save:nil];
//        
//        NSLog(@"Update 1 successfully applied");
//      }
//    }
//  }
//  /* Code to add the fourth book */
//  /*
//  NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"BookCategory"];
//  NSArray *categories = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
//  BookCategory *category = [categories lastObject];
//  
//  Book *book4 = [NSEntityDescription insertNewObjectForEntityForName:@"Book" inManagedObjectContext:self.managedObjectContext];
//  book4.title = @"The fourth book";
//  book4.price = 12;
//  
//  [category addBooks:[NSSet setWithObjects:book4, nil]];
//  
//  [self saveContext];
//  */
//}
//
//- (void)insertSomeData {
//  NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"BookCategory"];
//  NSArray *categories = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
//  
//  BookCategory *category = [categories lastObject];
//  
//  // Tell the undo manager that from now on, we manage grouping
//  [self.managedObjectContext.undoManager setGroupsByEvent:NO];
//
//  for(int i=5; i<10; i++) {
//    // Start a new group
//    [self.managedObjectContext.undoManager beginUndoGrouping];
//
//    Book *book = [NSEntityDescription insertNewObjectForEntityForName:@"Book" inManagedObjectContext:self.managedObjectContext];
//    book.title = [NSString stringWithFormat:@"The %dth book", i];
//    book.price = i;
//    [category addBooksObject:book];
//    
//    // End the current group
//    [self.managedObjectContext.undoManager endUndoGrouping];
//  }
//  
//  [self.managedObjectContext.undoManager undo];
//  [self saveContext];
//}
//
//- (void)showExampleData {
//  NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Book"];
//  NSArray *books = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
//  NSLog(@"Size: %lu", [books count]);
//  for (Book *book in books) {
//    NSLog(@"Title: %@, price: %.2f", book.title, book.price);
//  }
//}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
  if ([keyPath isEqualToString:@"migrationProgress"]) {
    NSMigrationManager *manager = (NSMigrationManager*)object;
    NSLog(@"Migration progress: %d%%", (int)(manager.migrationProgress * 100.0));
  }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
//  [self initStore];
//  [self insertSomeData];
//  [self showExampleData];
  return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
  // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
  // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
  // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
  // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
  // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
  // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
  // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  // Saves changes in the application's managed object context before the application terminates.
  [self saveContext];
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "book.persistence.BookStore" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"BookStore" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
  if (_persistentStoreCoordinator != nil) {
      return _persistentStoreCoordinator;
  }
  
  _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
  NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"BookStoreEnhanced.sqlite"];

//    NSDictionary *options = @{
//      NSMigratePersistentStoresAutomaticallyOption: @YES
//    };

  NSError *error = nil;
  NSDictionary *sourceMetadata = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:NSSQLiteStoreType URL:storeURL error:&error];

  NSManagedObjectModel *destinationModel = [_persistentStoreCoordinator managedObjectModel];

  BOOL pscCompatible = [destinationModel isConfiguration:nil compatibleWithStoreMetadata:sourceMetadata];

  if (!pscCompatible) {
    // Migration is needed
    NSManagedObjectModel *sourceModel = [NSManagedObjectModel mergedModelFromBundles:nil forStoreMetadata:sourceMetadata];
    _migrationManager = [[MyMigrationManager alloc] initWithSourceModel:sourceModel destinationModel:[self managedObjectModel]];
    [_migrationManager addObserver:self forKeyPath:@"migrationProgress" options:NSKeyValueObservingOptionNew context:NULL];
    NSMappingModel *mappingModel = [NSMappingModel inferredMappingModelForSourceModel:sourceModel destinationModel:[self managedObjectModel] error:nil];
    
    NSURL *tempURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"BookStoreEnhanced-temp.sqlite"];

    
    if(![_migrationManager migrateStoreFromURL:storeURL
                                          type:NSSQLiteStoreType
                                       options:nil
                              withMappingModel:mappingModel
                              toDestinationURL:tempURL
                               destinationType:NSSQLiteStoreType
                            destinationOptions:nil
                                         error:&error]) {
      // Deal with error
      NSLog(@"%@", error);
    }
    else {
      // Delete the old store, rename the new one
      NSFileManager *fm = [NSFileManager defaultManager];
      [fm removeItemAtPath:[storeURL path] error:nil];
      [fm moveItemAtPath:[tempURL path] toPath:[storeURL path] error:nil];
    }
  }
  
  if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
    [self showCoreDataError];
  }
  
  return _persistentStoreCoordinator;
}

- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    
    // Add the undo manager
    [_managedObjectContext setUndoManager:[[NSUndoManager alloc] init]];
    
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Core Data Error

- (void)showCoreDataError {
  self.unstable = YES;
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"BookStore can't continue.\nPress the Home button to close the app." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
  [alert show];
}

@end
