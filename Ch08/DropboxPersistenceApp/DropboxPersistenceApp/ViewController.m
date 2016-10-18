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

#import "TargetConditionals.h"
#import <Dropbox/Dropbox.h>
#import "ViewController.h"

@interface ViewController ()
@property (nonatomic, strong) DBDatastore* datastore;
@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  if ([[DBAccountManager sharedManager] linkedAccount]) {
    [self.theButton setTitle:@"Store" forState:UIControlStateNormal];
  }
  else {
    [self.theButton setTitle:@"Link Dropbox" forState:UIControlStateNormal];
  }
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (IBAction)didPressLink {
  DBAccount *linkedAccount = [[DBAccountManager sharedManager] linkedAccount];
  if (linkedAccount) {
    // If there isn't a store yet, make one
    if (!self.datastore) self.datastore = [DBDatastore openDefaultStoreForAccount:linkedAccount error:nil];
    
    // Create or get a handle to the Notes table if it already exists
    DBTable *notes = [self.datastore getTable:@"Notes"];
    
    // Make a new note to store. In a normal app, this comes from typed text. To keep things
    // simple, we just manufacture the text with a timestamp
    NSDate *now = [NSDate date];
    NSString *noteText = [NSDateFormatter localizedStringFromDate:now
                                                        dateStyle:NSDateFormatterShortStyle
                                                        timeStyle:NSDateFormatterFullStyle];
    
    // Insert the new note into the table
    [notes insert:@{ @"details": noteText, @"createDate": now, @"encrypted": @NO }];
    
    NSLog(@"Inserted new note: %@", noteText);
    
    // Make sure to tell Dropbox to sync the store
    [self.datastore sync:nil];
  }
  else {
    [[DBAccountManager sharedManager] linkFromController:self];
  }
}

@end
