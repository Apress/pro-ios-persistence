//
//  PerfTest.h
//  PerformanceTuning
//
//  Created by Rob Warner on 11/3/14.
//  Copyright (c) 2014 Michael Privat and Rob Warner. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreData;

@protocol PerfTest <NSObject>

- (NSString *)runTestWithContext:(NSManagedObjectContext *)context;

@end
