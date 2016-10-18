//
//  Selfie.h
//  PerformanceTuning
//
//  Created by Rob Warner on 11/4/14.
//  Copyright (c) 2014 Michael Privat and Rob Warner. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Person, SocialNetwork;

@interface Selfie : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * rating;
@property (nonatomic, retain) NSSet *people;
@property (nonatomic, retain) NSSet *socialNetworks;
@end

@interface Selfie (CoreDataGeneratedAccessors)

- (void)addPeopleObject:(Person *)value;
- (void)removePeopleObject:(Person *)value;
- (void)addPeople:(NSSet *)values;
- (void)removePeople:(NSSet *)values;

- (void)addSocialNetworksObject:(SocialNetwork *)value;
- (void)removeSocialNetworksObject:(SocialNetwork *)value;
- (void)addSocialNetworks:(NSSet *)values;
- (void)removeSocialNetworks:(NSSet *)values;

@end
