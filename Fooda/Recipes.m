//
//  Recipes.m
//  Fooda
//
//  Created by Ramon Gilabert Llop on 2/11/15.
//  Copyright (c) 2015 Ramon Gilabert. All rights reserved.
//

#import "Recipes.h"
#import "AFNetworking.h"
#import "UIImageView+AFNetworking.h"

@implementation Recipes

@dynamic created_at;
@dynamic descriptions;
@dynamic difficulty;
@dynamic favorite;
@dynamic idValue;
@dynamic instructions;
@dynamic name;
@dynamic photo;
@dynamic updated_at;
@dynamic identifier;

- (void)loadFromOurDictionary:(NSDictionary *)dictionaryLoaded
{
    // We would check everything, if it's not the class we want, then add something.
    
    self.name = dictionaryLoaded[@"name"];
    self.idValue = dictionaryLoaded[@"id"];
    self.descriptions = dictionaryLoaded[@"description"];

    if ([dictionaryLoaded[@"instructions"] isKindOfClass:[NSString class]]) {
        self.instructions = dictionaryLoaded[@"instructions"];
    } else {
        self.instructions = @"";
    }

    if ([dictionaryLoaded[@"favorite"] isKindOfClass:[NSNumber class]]) {
        self.favorite = dictionaryLoaded[@"favorite"];
    } else {
        self.favorite = [NSNumber numberWithBool:false];
    }

    self.created_at = dictionaryLoaded[@"created_at"];
    self.updated_at = dictionaryLoaded[@"updated_at"];
    self.difficulty = dictionaryLoaded[@"difficulty"];
}

+ (Recipes *)findOrCreateARecipeWithIdentifier:(NSString *)identifier inContext:(NSManagedObjectContext *)context withDictionary:(NSDictionary *)dictionary
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Recipes"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"identifier = %@", identifier];
    NSError *error = nil;
    NSArray *result = [context executeFetchRequest:fetchRequest error:&error];
    
    if (error) {
        NSLog(@"error: %@", error.localizedDescription);
    }

    // Sadly I don't delete the object if it's deleted from the backend, what could we do? We have an array of objects in core data once we've saved everything, then, compare, the ones that don't appear in the array of the backend, those get deleted.

    if (result.lastObject) {
        return result.lastObject;
    } else {
        Recipes *recipeToAdd = [NSEntityDescription insertNewObjectForEntityForName:@"Recipes" inManagedObjectContext:context];
        recipeToAdd.identifier = identifier;
        return recipeToAdd;
    }
}

@end
