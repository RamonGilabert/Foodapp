//
//  Recipes.h
//  Fooda
//
//  Created by Ramon Gilabert Llop on 2/11/15.
//  Copyright (c) 2015 Ramon Gilabert. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Recipes : NSManagedObject

@property (nonatomic, retain) NSString * created_at;
@property (nonatomic, retain) NSString * descriptions;
@property (nonatomic, retain) NSString * difficulty;
@property (nonatomic, retain) NSNumber * favorite;
@property (nonatomic, retain) NSNumber * idValue;
@property (nonatomic, retain) NSString * instructions;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSData * photo;
@property (nonatomic, retain) NSString * updated_at;
@property (nonatomic, retain) NSString * identifier;

- (void)loadFromOurDictionary:(NSDictionary *)dictionaryLoaded;
+ (Recipes *)findOrCreateARecipeWithIdentifier:(NSString *)identifier inContext:(NSManagedObjectContext *)context withDictionary:(NSDictionary *)dictionary;

@end
