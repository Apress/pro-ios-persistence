//
//  Note.h
//  SecureNote
//
//  Created by Rob Warner on 10/13/14.
//  Copyright (c) 2014 Michael Privat and Rob Warner. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface Note : NSManagedObject

@property (nonatomic, retain) NSString *body;
@property (nonatomic, retain) NSDate *timeStamp;
@property (nonatomic, retain) NSString *title;

@end
