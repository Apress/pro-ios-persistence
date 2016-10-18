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
#import "Persistence.h"

@implementation ViewController

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [self updateStatistics];
}

- (void)updateStatistics {
  AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
  self.textView.text = [appDelegate.persistence statistics];
}

- (IBAction)loadWordList:(id)sender {
  // Hide the button while we're loading
  [(UIButton *)sender setHidden:YES];
  
  // Load the words
  NSURL *url = [NSURL URLWithString:@"https://dotnetperls-controls.googlecode.com/files/enable1.txt"];
  NSURLRequest *request = [NSURLRequest requestWithURL:url];
  NSLog(@"Loading words");
  [NSURLConnection sendAsynchronousRequest:request
                                     queue:[NSOperationQueue mainQueue]
                         completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                           NSString *words = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                           NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
                           // Check for successful load
                           if (words != nil && statusCode == 200) {
                             // Give the word list to the persistence layer
                             AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                             [appDelegate.persistence loadWordList:words];
                           }
                           else {
                             // Load failed; show any errors
                             NSLog(@"Error: %lu", statusCode);
                             if (error != NULL)
                               NSLog(@"Error: %@", [error localizedDescription]);
                           }
                           
                           // Show the button
                           [(UIButton *)sender setHidden:NO];
                           
                           // Update the text view with statistics
                           [self updateStatistics];
                         }];
}

@end
