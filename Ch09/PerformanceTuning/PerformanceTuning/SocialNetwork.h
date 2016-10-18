//
//  SocialNetwork.h
//  PerformanceTuning
//
//  Created by Rob Warner on 11/4/14.
//  Copyright (c) 2014 Michael Privat and Rob Warner. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface SocialNetwork : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * rating;
@property (nonatomic, retain) NSSet *selfies;
@end

@interface SocialNetwork (CoreDataGeneratedAccessors)

- (void)addSelfiesObject:(NSManagedObject *)value;
- (void)removeSelfiesObject:(NSManagedObject *)value;
- (void)addSelfies:(NSSet *)values;
- (void)removeSelfies:(NSSet *)values;

@end
