//
//  Project.h
//  CoreDump
//
//  Created by Rob Warner on 9/28/14.
//  Copyright (c) 2014 Michael Privat and Rob Warner. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Bug;

@interface Project : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSString * host;
@property (nonatomic, retain) NSSet *bugs;
@end

@interface Project (CoreDataGeneratedAccessors)

- (void)addBugsObject:(Bug *)value;
- (void)removeBugsObject:(Bug *)value;
- (void)addBugs:(NSSet *)values;
- (void)removeBugs:(NSSet *)values;

@end
