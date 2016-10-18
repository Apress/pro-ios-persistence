//
//  TapView.m
//  TapOut
//
//  Created by Rob Warner on 10/13/14.
//  Copyright (c) 2014 Michael Privat and Rob Warner. All rights reserved.
//

#import "TapView.h"
#import "AppDelegate.h"
#import "Persistence.h"
#import "Tap.h"

@implementation TapView

- (void)drawRect:(CGRect)rect {
  static float DIAMETER = 10.0f;
  
  CGContextRef context = UIGraphicsGetCurrentContext();
  
  AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
  NSArray *taps = [appDelegate.persistence taps];
  for (Tap *tap in taps) {
    const CGFloat *rgb = CGColorGetComponents(tap.color.CGColor);
    CGContextSetRGBFillColor(context, rgb[0], rgb[1], rgb[2], 1.0f);
    CGContextFillEllipseInRect(context, CGRectMake(tap.x - DIAMETER/2, tap.y - DIAMETER/2, DIAMETER, DIAMETER));
  }
}

@end
