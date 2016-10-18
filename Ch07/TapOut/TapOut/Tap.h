//
//  Tap.h
//  TapOut
//
//  Created by Rob Warner on 10/13/14.
//  Copyright (c) 2014 Michael Privat and Rob Warner. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>

@interface Tap : NSManagedObject

@property (nonatomic) float x;
@property (nonatomic) float y;
@property (nonatomic, retain) UIColor *color;

@end
