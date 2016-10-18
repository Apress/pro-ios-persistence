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

#import "Persistence.h"

@implementation Persistence

- (id)init {
  self = [super init];
  if (self != nil) {
    // Initialize the managed object model
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"WordList" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    // Initialize the persistent store coordinator
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"WordList.sqlite"];
    
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

- (void)loadWordList:(NSString *)wordList {
  // Delete all the existing words and categories
  [self deleteAllObjectsForEntityWithName:@"Word"];
  [self deleteAllObjectsForEntityWithName:@"WordCategory"];
  
  // Create the categories
  NSMutableDictionary *wordCategories = [NSMutableDictionary dictionaryWithCapacity:26];
  for (char c = 'a'; c <= 'z'; c++) {
    NSString *firstLetter = [NSString stringWithFormat:@"%c", c];
    NSManagedObject *wordCategory = [NSEntityDescription insertNewObjectForEntityForName:@"WordCategory" inManagedObjectContext:self.managedObjectContext];
    [wordCategory setValue:firstLetter forKey:@"firstLetter"];
    [wordCategories setValue:wordCategory forKey:firstLetter];
    NSLog(@"Added category '%@'", firstLetter);
  }
  
  // Add the words from the list
  NSUInteger wordsAdded = 0;
  NSArray *newWords = [wordList componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  for (NSString *word in newWords) {
    if (word.length > 0) {
      NSManagedObject *object = [NSEntityDescription insertNewObjectForEntityForName:@"Word" inManagedObjectContext:self.managedObjectContext];
      [object setValue:word forKey:@"text"];
      [object setValue:[NSNumber numberWithInteger:word.length] forKey:@"length"];
      [object setValue:[wordCategories valueForKey:[word substringToIndex:1]] forKey:@"wordCategory"];
      ++wordsAdded;
      if (wordsAdded % 100 == 0)
        NSLog(@"Added %lu words", wordsAdded);
    }
  }
  NSLog(@"Added %lu words", wordsAdded);
  [self saveContext];
  NSLog(@"Context saved");
}

- (NSString *)statistics {
  NSMutableString *string = [[NSMutableString alloc] init];
  [string appendString:[self wordCount]];
  for (char c = 'a'; c <= 'z'; c++) {
    [string appendString:[self wordCountForCategory:[NSString stringWithFormat:@"%c", c]]];
  }
  [string appendString:[self zyzzyvasUsingQueryLanguage]];
  [string appendString:[self zyzzyvasUsingNSExpression]];
  [string appendString:[self wordCountForRange:NSMakeRange(20, 25)]];
  [string appendString:[self endsWithGryWords]];
  [string appendString:[self anyWordContainsZ]];
  [string appendString:[self caseInsensitiveFetch:@"qiviut"]];
  [string appendString:[self twentyLetterWordsEndingInIng]];
  [string appendString:[self highCountCategories]];
  [string appendString:[self averageWordLengthFromCollection]];
  [string appendString:[self averageWordLengthFromExpressionDescription]];
  [string appendString:[self longestWords]];
  [string appendString:[self wordCategoriesWith25LetterWords]];
  [string appendString:[self zWords]];
  return string;
}

- (NSString *)wordCount {
  NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Word"];
  NSUInteger count = [self.managedObjectContext countForFetchRequest:fetchRequest error:nil];
  return [NSString stringWithFormat:@"Word Count: %lu\n", count];
}

- (NSString *)wordCountForCategory:(NSString *)firstLetter {
  NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Word"];
  fetchRequest.predicate = [NSPredicate predicateWithFormat:@"wordCategory.firstLetter = %@", firstLetter];
  NSUInteger count = [self.managedObjectContext countForFetchRequest:fetchRequest error:nil];
  return [NSString stringWithFormat:@"Words beginning with %@: %lu\n", firstLetter, count];
}

- (NSString *)zyzzyvasUsingQueryLanguage {
  NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Word"];
  fetchRequest.predicate = [NSPredicate predicateWithFormat:@"text = 'zyzzyvas'"];
  NSArray *words = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
  return words.count == 0 ? @"" : [NSString stringWithFormat:@"%@\n", [words[0] valueForKey:@"text"]];
}

- (NSString *)zyzzyvasUsingNSExpression {
  NSExpression *expressionText = [NSExpression expressionForKeyPath:@"text"];
  NSExpression *expressionZyzzyvas = [NSExpression expressionForConstantValue:@"zyzzyvas"];
  NSPredicate *predicate = [NSComparisonPredicate predicateWithLeftExpression:expressionText
                                                              rightExpression:expressionZyzzyvas
                                                                     modifier:NSDirectPredicateModifier
                                                                         type:NSEqualToPredicateOperatorType
                                                                      options:0];
  NSLog(@"Predicate: %@", [predicate predicateFormat]);
  NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Word"];
  fetchRequest.predicate = predicate;
  NSArray *words = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
  return words.count == 0 ? @"" : [NSString stringWithFormat:@"%@\n", [words[0] valueForKey:@"text"]];
}

- (NSString *)wordCountForRange:(NSRange)range {
  NSExpression *length = [NSExpression expressionForKeyPath:@"length"];
  NSExpression *lower = [NSExpression expressionForConstantValue:@(range.location)];
  NSExpression *upper = [NSExpression expressionForConstantValue:@(range.length)];
  NSExpression *expr = [NSExpression expressionForAggregate:@[lower, upper]];
  NSPredicate *predicate = [NSComparisonPredicate predicateWithLeftExpression:length
                                                              rightExpression:expr
                                                                     modifier:NSDirectPredicateModifier
                                                                         type:NSBetweenPredicateOperatorType
                                                                      options:0];
  NSLog(@"Aggregate Predicate: %@", [predicate predicateFormat]);
  NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Word"];
  fetchRequest.predicate = predicate;
  NSUInteger count = [self.managedObjectContext countForFetchRequest:fetchRequest error:nil];
  return [NSString stringWithFormat:@"%lu-%lu letter words: %lu\n", range.location, range.length, count];
}

- (NSString *)endsWithGryWords {
  NSExpression *text = [NSExpression expressionForKeyPath:@"text"];
  NSExpression *gry = [NSExpression expressionForConstantValue:@"gry"];
  NSPredicate *predicate = [NSComparisonPredicate predicateWithLeftExpression:text
                                                              rightExpression:gry
                                                                     modifier:NSDirectPredicateModifier
                                                                         type:NSEndsWithPredicateOperatorType
                                                                      options:0];
  NSLog(@"Predicate: %@", [predicate predicateFormat]);
  NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Word"];
  fetchRequest.predicate = predicate;
  NSArray *gryWords = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
  return [NSString stringWithFormat:@"-gry words: %@\n",
          [[gryWords valueForKey:@"text"] componentsJoinedByString:@","]];
}

- (NSString *)anyWordContainsZ {
  NSExpression *text = [NSExpression expressionForKeyPath:@"words.text"];
  NSExpression *z = [NSExpression expressionForConstantValue:@"z"];
  NSPredicate *predicate = [NSComparisonPredicate predicateWithLeftExpression:text
                                                              rightExpression:z
                                                                     modifier:NSAnyPredicateModifier
                                                                         type:NSContainsPredicateOperatorType
                                                                      options:0];
  NSLog(@"Predicate: %@", [predicate predicateFormat]);
  NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"WordCategory"];
  fetchRequest.predicate = predicate;
  NSArray *categories = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
  return [NSString stringWithFormat:@"ANY: %@\n",
          [[categories valueForKey:@"firstLetter"] componentsJoinedByString:@","]];
}

- (NSString *)caseInsensitiveFetch:(NSString *)word {
  NSExpression *text = [NSExpression expressionForKeyPath:@"text"];
  NSExpression *allCapsWord = [NSExpression expressionForConstantValue:[word uppercaseString]];
  NSPredicate *predicate = [NSComparisonPredicate predicateWithLeftExpression:text
                                                              rightExpression:allCapsWord
                                                                     modifier:NSDirectPredicateModifier
                                                                         type:NSEqualToPredicateOperatorType
                                                                      options:NSCaseInsensitivePredicateOption];
  NSLog(@"Predicate: %@", [predicate predicateFormat]);
  NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Word"];
  fetchRequest.predicate = predicate;
  NSArray *words = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
  return [NSString stringWithFormat:@"%@\n", words.count == 0 ? @"" : [words[0] valueForKey:@"text"]];
}

- (NSString *)twentyLetterWordsEndingInIng {
  // Create a predicate that compares length to 20
  NSExpression *length = [NSExpression expressionForKeyPath:@"length"];
  NSExpression *twenty = [NSExpression expressionForConstantValue:@20];
  NSPredicate *predicateLength = [NSComparisonPredicate predicateWithLeftExpression:length
                                                                    rightExpression:twenty
                                                                           modifier:NSDirectPredicateModifier
                                                                               type:NSEqualToPredicateOperatorType
                                                                            options:0];
  
  // Create a predicate that compares text to "ends with -ing"
  NSExpression *text = [NSExpression expressionForKeyPath:@"text"];
  NSExpression *ing = [NSExpression expressionForConstantValue:@"ing"];
  NSPredicate *predicateIng = [NSComparisonPredicate predicateWithLeftExpression:text
                                                                 rightExpression:ing
                                                                        modifier:NSDirectPredicateModifier
                                                                            type:NSEndsWithPredicateOperatorType
                                                                         options:0];
  
  // Combine the predicates
  NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicateLength, predicateIng]];
  NSLog(@"Compound predicate: %@", [predicate predicateFormat]);
  
  NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Word"];
  fetchRequest.predicate = predicate;
  NSArray *words = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
  return [NSString stringWithFormat:@"%@\n", [[words valueForKey:@"text"] componentsJoinedByString:@","]];
}

- (NSString *)highCountCategories {
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"words.@count > %d", 10000];
  NSLog(@"Predicate: %@", [predicate predicateFormat]);
  
  NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"WordCategory"];
  fetchRequest.predicate = predicate;
  NSArray *categories = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
  return [NSString stringWithFormat:@"High count categories: %@\n",
          [[categories valueForKey:@"firstLetter"] componentsJoinedByString:@","]];
}

- (NSString *)averageWordLengthFromCollection {
  NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Word"];
  NSArray *words = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
  return [NSString stringWithFormat:@"Average from collection: %.2f\n",
          [[words valueForKeyPath:@"@avg.length"] floatValue]];
}

- (NSString *)averageWordLengthFromExpressionDescription {
  NSExpression *length = [NSExpression expressionForKeyPath:@"length"];
  NSExpression *average = [NSExpression expressionForFunction:@"average:" arguments:@[length]];
  
  NSExpressionDescription *averageDescription = [[NSExpressionDescription alloc] init];
  averageDescription.name = @"average";
  averageDescription.expression = average;
  averageDescription.expressionResultType = NSFloatAttributeType;
  
  NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Word"];
  fetchRequest.propertiesToFetch = @[averageDescription];
  fetchRequest.resultType = NSDictionaryResultType;
  NSArray *results = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
  return [NSString stringWithFormat:@"Average from expression description: %.2f\n",
          [[results[0] valueForKey:@"average"] floatValue]];
}

- (NSString *)longestWords {
  NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Word"];
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"length = max:(length)"];
  NSLog(@"Predicate: %@", [predicate predicateFormat]);
  fetchRequest.predicate = predicate;
  NSArray *words = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
  return [NSString stringWithFormat:@"Longest words: %@\n",
          [[words valueForKey:@"text"] componentsJoinedByString:@","]];
}

- (NSString *)wordCategoriesWith25LetterWords {
  NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"WordCategory"];
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SUBQUERY(words, $x, $x.length = 25).@count > 0"];
  fetchRequest.predicate = predicate;
  NSLog(@"Subquery Predicate: %@", [predicate predicateFormat]);
  NSArray *categories = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
  return [NSString stringWithFormat:@"Categories with 25-letter words: %@\n",
          [[categories valueForKey:@"firstLetter"] componentsJoinedByString:@","]];
}

- (NSString *)zWords {
  NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Word"];
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"text BEGINSWITH 'z'"];
  NSSortDescriptor *lengthSort = [NSSortDescriptor sortDescriptorWithKey:@"length" ascending:YES];
  NSSortDescriptor *alphaSort = [NSSortDescriptor sortDescriptorWithKey:@"text" ascending:NO];
  
  fetchRequest.predicate = predicate;
  fetchRequest.sortDescriptors = @[lengthSort, alphaSort];
  
  NSLog(@"Predicate: %@", predicate);
  NSArray *words = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
  return [NSString stringWithFormat:@"Z words:\n%@\n",
          [[words valueForKey:@"text"] componentsJoinedByString:@"\n"]];
}

#pragma mark - Helper Methods

- (void)deleteAllObjectsForEntityWithName:(NSString *)name {
  NSLog(@"Deleting all objects in entity %@", name);
  
  NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:name];
  fetchRequest.resultType = NSManagedObjectIDResultType;
  
  NSArray *objectIDs = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
  for (NSManagedObjectID *objectID in objectIDs) {
    [self.managedObjectContext deleteObject:[self.managedObjectContext objectWithID:objectID]];
  }
  
  [self saveContext];
  
  NSLog(@"All objects in entity %@ deleted", name);
}

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

@end
