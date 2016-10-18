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

#import "PublicationToPublicationMigrationPolicy.h"

@implementation PublicationToPublicationMigrationPolicy

- (BOOL)createDestinationInstancesForSourceInstance:(NSManagedObject *)sourceInstance entityMapping:(NSEntityMapping *)mapping manager:(NSMigrationManager *)manager error:(NSError **)error {
  // Create the book managed object
  NSManagedObject *book =
  [NSEntityDescription insertNewObjectForEntityForName:[mapping destinationEntityName]
   
                                inManagedObjectContext:[manager destinationContext]];
  [book setValue:[sourceInstance valueForKey:@"title"] forKey:@"title"];
  [book setValue:[sourceInstance valueForKey:@"price"] forKey:@"price"];
  
  // Get the author name from the source
  NSString *author = [sourceInstance valueForKey:@"author"];
  
  // Split the author name into first name and last name
  NSRange firstSpace = [author rangeOfString:@" "];
  NSString *firstName = [author substringToIndex:firstSpace.location];
  NSString *lastName = [author substringFromIndex:firstSpace.location+1];
  
  // Set the first and last names into the bbok
  [book setValue:firstName forKey:@"firstName"];
  [book setValue:lastName forKey:@"lastName"];
  
  // Set up the association between the old Publication and the new Publication for the migration manager
  [manager associateSourceInstance:sourceInstance withDestinationInstance:book forEntityMapping:mapping];
  return YES;
}

@end
