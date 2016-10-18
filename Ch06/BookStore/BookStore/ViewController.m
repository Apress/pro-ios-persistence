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

#import "ViewController.h"
#import "AppDelegate.h"
#import "BookCategory.h"
#import "Book.h"
#import "Page.h"

@interface ViewController ()

@end

@implementation ViewController

- (NSURL *)applicationDocumentsDirectory {
  return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectContext*)managedObjectContext {
  AppDelegate *ad = [UIApplication sharedApplication].delegate;
  return ad.managedObjectContext;
}

- (void)saveContext {
  NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
  if (managedObjectContext != nil) {
    NSError *error = nil;
    if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
      NSString *message = [self validationErrorText:error];
      NSLog(@"Error: %@", message);
    }
  }
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
//  [self populateAuthors];
  [self showExampleData];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)initStore {
  NSFileManager *fm = [NSFileManager defaultManager];
  
  NSString *seed = [[NSBundle mainBundle] pathForResource: @"seed" ofType: @"sqlite"];
  NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"BookStoreEnhanced.sqlite"];
  
  if([fm fileExistsAtPath:[storeURL path]]) {
    [fm removeItemAtPath:[storeURL path] error:nil];
  }
  
  if (![fm fileExistsAtPath:[storeURL path]]) {
    NSLog(@"Using the original seed");
    NSError *error = nil;
    if (![fm copyItemAtPath:seed toPath:[storeURL path] error:&error]) {
      NSLog(@"Error seeding: %@", error);
      return;
    }
    
    NSLog(@"Store successfully initialized using the original seed");
  }
  else {
    NSLog(@"The original seed isn't needed. There is already a backing store.");
    
    // Update 1
    {
      NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Publication"];
      request.predicate = [NSPredicate predicateWithFormat:@"title=%@", @"The fourth book"];
      NSUInteger count = [self.managedObjectContext countForFetchRequest:request error:nil];
      if(count == 0) {
        NSLog(@"Applying batch update 1");
        
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Category"];
        NSArray *categories = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
        
        BookCategory *category = [categories lastObject];
        Book *book4 = [NSEntityDescription insertNewObjectForEntityForName:@"Publication" inManagedObjectContext:self.managedObjectContext];
        book4.title = @"The fourth book";
        book4.price = 12;
        
        [category addBooks:[NSSet setWithObjects:book4, nil]];
        
        [self.managedObjectContext save:nil];
        
        NSLog(@"Update 1 successfully applied");
      }
    }
  }
  /* Code to add the fourth book */
  /*
   NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"BookCategory"];
   NSArray *categories = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
   BookCategory *category = [categories lastObject];
   
   Book *book4 = [NSEntityDescription insertNewObjectForEntityForName:@"Book" inManagedObjectContext:self.managedObjectContext];
   book4.title = @"The fourth book";
   book4.price = 12;
   
   [category addBooks:[NSSet setWithObjects:book4, nil]];
   
   [self saveContext];
   */
}

- (void)insertSomeData {
  NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"BookCategory"];
  NSArray *categories = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];

  AppDelegate *ad = [UIApplication sharedApplication].delegate;
  if(ad.unstable) {
    NSLog(@"The app is unstable. Preventing updates.");
    return;
  }
  
  BookCategory *category = [categories lastObject];
  
  // Tell the undo manager that from now on, we manage grouping
  [self.managedObjectContext.undoManager setGroupsByEvent:NO];
  
  for(int i=5; i<10; i++) {
    // Start a new group
    [self.managedObjectContext.undoManager beginUndoGrouping];
    
    Book *book = [NSEntityDescription insertNewObjectForEntityForName:@"Publication" inManagedObjectContext:self.managedObjectContext];
    book.title = [NSString stringWithFormat:@"The %dth book", i];
    book.price = i;
    [category addBooksObject:book];
    
    // End the current group
    [self.managedObjectContext.undoManager endUndoGrouping];
  }
  
  [self.managedObjectContext.undoManager undo];
  [self saveContext];
}

- (void)showExampleData {
  NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Publication"];
  NSArray *books = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
  NSLog(@"Size: %lu", [books count]);
  for (Book *book in books) {
    NSLog(@"Title: %@, price: %.2f", book.title, book.price);
  }
}

- (NSString *)validationErrorText:(NSError *)error {
  // Create a string to hold all the error messages
  NSMutableString *errorText = [NSMutableString stringWithCapacity:100];
  // Determine whether we're dealing with a single error or multiples, and put them all
  // in an array
  NSArray *errors = [error code] == NSValidationMultipleErrorsError ? [[error userInfo] objectForKey:NSDetailedErrorsKey] : [NSArray arrayWithObject:error];
  
  // Iterate through the errors
  for (NSError *err in errors) {
    // Get the property that had a validation error
    NSString *propName = [[err userInfo] objectForKey:@"NSValidationErrorKey"];
    NSString *message;
    
    // Form an appropriate error message
    switch ([err code]) {
      case NSValidationNumberTooSmallError:
        message = [NSString stringWithFormat:@"%@ must be at least $15", propName];
        break;
      default:
        message = @"Unknown error. Press Home button to halt.";
        break;
    }
    
    // Separate the error messages with line feeds
    if ([errorText length] > 0) {
      [errorText appendString:@"\n"];
    }
    [errorText appendString:message];
  }
  return errorText;
}

- (void)populateAuthors {
  // 1. Create a list of author names to assign
  NSArray *authors = @[@"John Doe", @"Jane Doe", @"Bill Smith", @"Jack Brown"];
  
  // 2. Get all the publications from the data store
  NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Publication"];
  NSArray *books = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
  for(int i=0; i<books.count; i++) {
    Book *book = books[i];
    book.price = 20+i;
    
    // 3. Set the author using one of the names in the array we created
    [book setValue:authors[i % authors.count] forKey:@"author"];
  }

  // 4. Commit everything to the store
  [self saveContext];
}

@end
