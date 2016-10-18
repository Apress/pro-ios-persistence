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

#import "MyMigrationManager.h"  

@implementation MyMigrationManager

- (void)associateSourceInstance:(NSManagedObject*)sourceInstance withDestinationInstance:(NSManagedObject *)destinationInstance forEntityMapping:(NSEntityMapping *)entityMapping {
  [super associateSourceInstance:sourceInstance withDestinationInstance:destinationInstance forEntityMapping:entityMapping];
  
  NSString *name = [entityMapping destinationEntityName];
  if([name isEqualToString:@"Publication"]) {
    NSString *title = [sourceInstance valueForKey:@"title"];
    [destinationInstance setValue:title forKey:@"synopsis"];
  }
}
@end
