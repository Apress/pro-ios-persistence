//
//  ProjectViewController.m
//  CoreDump
//
//  Created by Rob Warner on 9/28/14.
//  Copyright (c) 2014 Michael Privat and Rob Warner. All rights reserved.
//

#import "ProjectViewController.h"
#import "Project.h"

@interface ProjectViewController ()

@end

@implementation ProjectViewController

- (id)initWithProject:(Project *)project fetchedResultsController:(NSFetchedResultsController *)fetchedResultsController {
  self = [super init];
  if (self) {
    self.project = project;
    self.fetchedResultsController = fetchedResultsController;
  }
  return self;
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  if (self.project != nil) {
    self.name.text = self.project.name;
    self.url.text = self.project.url;
  }
}

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (IBAction)cancel:(id)sender {
  [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)save:(id)sender {
  NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
  
  if (self.project == nil) {
    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
    self.project = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
  }
  
  self.project.name = self.name.text;
  self.project.url = self.url.text;
  self.project.host = [self host];
  
  // Save the context.
  NSError *error = nil;
  if (![context save:&error]) {
    // Replace this implementation with code to handle the error appropriately.
    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    abort();
  }
  
  [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSString *)host {
  NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@".*?//(.*?)/.*"
                                                                         options:0
                                                                           error:nil];
  NSTextCheckingResult *match = [regex firstMatchInString:self.project.url
                                                  options:0
                                                    range:NSMakeRange(0, [self.project.url length])];
  if (match) {
    return [self.project.url substringWithRange:[match rangeAtIndex:1]];
  } else {
    return self.project.url;
  }
}

  /*
   #pragma mark - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
   - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
   // Get the new view controller using [segue destinationViewController].
   // Pass the selected object to the new view controller.
   }
   */
  
  @end
