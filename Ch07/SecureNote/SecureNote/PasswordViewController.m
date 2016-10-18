//
//  PasswordViewController.m
//  SecureNote
//
//  Created by Rob Warner on 10/14/14.
//  Copyright (c) 2014 Michael Privat and Rob Warner. All rights reserved.
//

#import "PasswordViewController.h"
#import "AppDelegate.h"
#import "MasterViewController.h"
#import "SSKeychain.h"

@implementation PasswordViewController

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if ([segue.identifier isEqualToString:@"logIn"]) {
    // Set the managed object context in the master view controller
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    MasterViewController *controller = (MasterViewController *)[segue destinationViewController];
    controller.managedObjectContext = appDelegate.managedObjectContext;
  }
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
  // Make sure they've entered something in the password field
  NSString *enteredPassword = self.passwordField.text;
  if ([identifier isEqualToString:@"logIn"] && enteredPassword.length > 0) {
    
    // Store whatever they've entered in the application delegate
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.password = enteredPassword;
    
    // Retrieve the password from the keychain
    NSString *password = [SSKeychain passwordForService:@"SecureNote" account:@"default"];
    
    // If they've never entered a password, they're creating a new one
    if (password == nil) {
      // Store the password in the keychain and allow segue to be performed
      [SSKeychain setPassword:enteredPassword forService:@"SecureNote" account:@"default"];
      return YES;
    } else {
      // Verify password and allow segue only if verified
      return [password isEqualToString:enteredPassword];
    }
  } else {
    return NO;
  }
}

@end
