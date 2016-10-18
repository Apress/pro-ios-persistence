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

#import "Book.h"
#import "BookCategory.h"
#import "Page.h"


@implementation Book

@dynamic title;
@dynamic price;
@dynamic category;
@dynamic pages;
@dynamic firstName;
@dynamic lastName;

- (void)awakeFromInsert {
  [super awakeFromInsert];
  NSLog(@"New book created");
}

- (void)awakeFromFetch {
  [super awakeFromFetch];
  NSLog(@"Book fetched: %@", self.title);
}

@end
