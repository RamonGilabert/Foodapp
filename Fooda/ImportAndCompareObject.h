//
//  ImportAndCompareObject.h
//  Fooda
//
//  Created by Ramon Gilabert Llop on 2/11/15.
//  Copyright (c) 2015 Ramon Gilabert. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataManager.h"
#import <CoreData/CoreData.h>
#import "Recipes.h"

@interface ImportAndCompareObject : NSObject

@property NSManagedObjectModel *managedObjectModel;
@property NSManagedObjectContext *managedObjectContext;
@property DataManager *getThatJSON;

- (void)importData;

@end
