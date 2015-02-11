//
//  ViewController.h
//  Fooda
//
//  Created by Ramon Gilabert Llop on 2/10/15.
//  Copyright (c) 2015 Ramon Gilabert. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Recipes.h"

@interface MainViewController : UIViewController <NSFetchedResultsControllerDelegate>

@property NSManagedObjectContext *managedObjectContext;
@property NSFetchedResultsController *fetchedResultsController;

@end

