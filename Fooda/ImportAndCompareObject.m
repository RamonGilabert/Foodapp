//
//  ImportAndCompareObject.m
//  Fooda
//
//  Created by Ramon Gilabert Llop on 2/11/15.
//  Copyright (c) 2015 Ramon Gilabert. All rights reserved.
//

#import "ImportAndCompareObject.h"

@implementation ImportAndCompareObject

- (void)importData
{
    [self.getThatJSON getJSONDataAndCompareThem:^(NSArray *recipes)
     {
         [self.managedObjectContext performBlock:^
          {
              // Let's now compare all the recipes, we're going to separate them by name, each name should be different, as in the JSON there are some same names, we're going to use also the id

              for (NSDictionary *recipeOneByOne in recipes) {
                  NSString *identifier = [[recipeOneByOne[@"name"] stringByAppendingString:@" "] stringByAppendingString:@"id"];
                  Recipes *recipe;
                  //Pod *pod = [Pod findOrCreatePodWithIdentifier:identifier inContext:self.context];
                  //[pod loadFromDictionary:podSpec];
              }
          }];
     }];
}

- (NSManagedObjectContext *)setupManagedObjectContextWithConcurrencyType:(NSManagedObjectContextConcurrencyType)concurrencyType
{
    self.managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:concurrencyType];
    self.managedObjectContext.persistentStoreCoordinator =
    [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
    NSError *error;
    [self.managedObjectContext.persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                                  configuration:nil
                                                                            URL:self.storeURL
                                                                        options:nil
                                                                          error:&error];
    if (error) {
        NSLog(@"error: %@", error.localizedDescription);
    }

    return self.managedObjectContext;
}

@end
