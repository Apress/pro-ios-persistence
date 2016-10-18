//
//  DetailViewController.m
//  SecureNote
//
//  Created by Rob Warner on 10/13/14.
//  Copyright (c) 2014 Michael Privat and Rob Warner. All rights reserved.
//

#import "DetailViewController.h"
#import "Note.h"

@implementation DetailViewController

#pragma mark - Managing the note

- (void)setNote:(Note *)note {
  if (_note != note) {
    _note = note;
    [self configureView];
  }
}

- (void)configureView {
  if (self.note) {
    self.noteTitle.text = self.note.title;
    self.noteBody.text = self.note.body;
  } else {
    self.noteTitle.text = @"";
    self.noteBody.text = @"";
  }
}

- (void)viewDidLoad {
  [super viewDidLoad];
  [self configureView];
}

- (void)viewWillDisappear:(BOOL)animated {
  self.note.title = self.noteTitle.text;
  self.note.body = self.noteBody.text;
  
  NSError *error;
  if (![[self.note managedObjectContext] save:&error]) {
    NSLog(@"Error saving note %@ -- %@ %@", self.noteTitle.text, error, [error userInfo]);
  }
}

@end
