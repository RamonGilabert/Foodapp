//
//  DataManager.h
//  Fooda
//
//  Created by Ramon Gilabert Llop on 2/11/15.
//  Copyright (c) 2015 Ramon Gilabert. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Recipes.h"

@interface DataManager : NSObject

@property NSArray *arrayWithAllTheRecipes;
@property NSManagedObjectModel *managedObjectModel;
@property NSManagedObjectContext *managedObjectContext;
@property NSFetchedResultsController *fetchedResultsController;

- (void)importAllDataWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@end
