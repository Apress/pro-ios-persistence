//
//  DetailViewController.m
//  CoreDump
//
//  Created by Rob Warner on 9/23/14.
//  Copyright (c) 2014 Michael Privat and Rob Warner. All rights reserved.
//

#import "DetailViewController.h"
#import "Project.h" 
#import "Bug.h"  
#import "BugViewController.h"

@interface DetailViewController ()
@end

@implementation DetailViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
  self.navigationItem.rightBarButtonItem = addButton;
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  self.title = self.project.name;
  [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)insertNewObject:(id)sender {
  BugViewController *bugViewController = [[BugViewController alloc] initWithBug:nil project:self.project];
  [self presentViewController:bugViewController animated:YES completion:nil];
}

#pragma mark - Table View  

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [self.project.bugs count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DetailCell" forIndexPath:indexPath];
  [self configureCell:cell atIndexPath:indexPath];
  return cell;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
  Bug *bug = [self sortedBugs][indexPath.row];
  BugViewController *bugViewController = [[BugViewController alloc] initWithBug:bug project:self.project];
  [self presentViewController:bugViewController animated:YES completion:nil];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
  Bug *bug = [self sortedBugs][indexPath.row];
  cell.textLabel.text = bug.title;
}

- (NSArray *)sortedBugs {
  NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
  return [self.project.bugs sortedArrayUsingDescriptors:@[sortDescriptor]];
}

@end