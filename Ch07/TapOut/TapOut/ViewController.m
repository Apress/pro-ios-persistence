//
//  ViewController.m
//  TapOut
//
//  Created by Rob Warner on 10/13/14.
//  Copyright (c) 2014 Michael Privat and Rob Warner. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import "Persistence.h"

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewWasTapped:)];
  [self.view addGestureRecognizer:tapGestureRecognizer];
}

- (void)viewWasTapped:(UIGestureRecognizer *)sender {
  if (sender.state == UIGestureRecognizerStateEnded) {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    Persistence *persistence = appDelegate.persistence;
    CGPoint point = [sender locationInView:sender.view];
    [persistence addTap:point];
    [self.view setNeedsDisplay];
  }
}

@end
