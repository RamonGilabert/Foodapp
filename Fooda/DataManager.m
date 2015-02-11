//
//  DataManager.m
//  Fooda
//
//  Created by Ramon Gilabert Llop on 2/11/15.
//  Copyright (c) 2015 Ramon Gilabert. All rights reserved.
//

#import "DataManager.h"
#import "AFNetworking.h"

static NSString *const BaseURLString = @"http://hyper-recipes.herokuapp.com/recipes";

// Here in this file we're going to download all the files and then send a notification or even use delegates to send the information back to the main view.

@implementation DataManager

- (void)importAllDataWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    // First of all, the delegate will call that everytime the app opens, then, we're going to check in our backend for all the recipes, that will bring us to inside the for loop.
    NSURL *urlOfRecipes = [NSURL URLWithString:BaseURLString];
    NSURLRequest *requestOfData = [NSURLRequest requestWithURL:urlOfRecipes];
    AFHTTPRequestOperation *operationToGetData = [[AFHTTPRequestOperation alloc] initWithRequest:requestOfData];
    operationToGetData.responseSerializer = [AFJSONResponseSerializer serializer];
    [operationToGetData setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        self.arrayWithAllTheRecipes = (NSArray *)responseObject;

        int i = 0;

        for (NSDictionary *dictionaryInsideArray in self.arrayWithAllTheRecipes) {
            i = i + 1;
            // Making a counter, classic, not the best way to do it, but was a little tweak I did to solve a problem of the loading, because I want the scroll of the app to be smoth, I wanted to load all the images etc. the first time, then you just store the data of it and it's easier for the collection view, as it's working in the background, I'll have to wait until everything is done, here's where the counter makes his job.

            NSString *stringIdentifier = [[dictionaryInsideArray[@"name"] stringByAppendingString:@" "] stringByAppendingString:[NSString stringWithFormat:@"%d", [dictionaryInsideArray[@"id"] intValue]]];
            Recipes *recipe = [Recipes findOrCreateARecipeWithIdentifier:stringIdentifier inContext:managedObjectContext withDictionary:dictionaryInsideArray];

            // We call the recipe method, if the recipe exists, it puts back the recipe, the good thing is that if it's already there, we don't mess with it, the bad thing is that if there are some changes (not in the name or ID), then we cannot realize here, we should do another thing for it like not downloading the image into coredata, I've been thinking a lot to it, which is the best way? Whatsapp does something like sending a notification to all your friends, then that's why you don't see your image changing at first, 1 year ago they said to you that the others could have to wait 1 day to see your new image, it's kinda the same problem.

            if (!recipe.name && !recipe.photo && !recipe.difficulty) {

                // So it's a new recipe, let's then show the loading indicator in the main view and then load with our array.
                [[NSNotificationCenter defaultCenter] postNotificationName:@"WeNeedToShowIt" object:nil];

                [recipe loadFromOurDictionary:dictionaryInsideArray];

                // Now, if there's a url, let's add another background request and load the image.

                if ([[dictionaryInsideArray[@"photo"] objectForKey:@"url"] isKindOfClass:[NSString class]]) {
                    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[dictionaryInsideArray[@"photo"] objectForKey:@"url"]]];
                    AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
                    requestOperation.responseSerializer = [AFImageResponseSerializer serializer];
                    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                        recipe.photo = UIImagePNGRepresentation((UIImage *)responseObject);
                        NSError *error = nil;
                        [managedObjectContext save:&error];

                        // We save everytime our managed object, the thing is, once we've done all the new recipes then we check the if statement.

                        if (i == self.arrayWithAllTheRecipes.count) {

                            // Here we're done loading, what we want to check here if, from the dictionaries we have, there's something that we have already, meaning, we're going to check every recipe, if that recipe exists already in core data, then we don't want to do anything, if doesn't exist, meaning, it's not in the dictionary, we want to delete it.
                            NSError *error = nil;
                            NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Recipes"];
                            NSArray *result = [managedObjectContext executeFetchRequest:fetchRequest error:&error];

                            // Not the most efficient way to do it.

                            for (Recipes *recipe in result) {
                                int i = 0;

                                for (NSDictionary *dictionary in self.arrayWithAllTheRecipes) {
                                    if ([recipe.identifier isEqualToString:[[dictionary[@"name"] stringByAppendingString:@" "] stringByAppendingString:[NSString stringWithFormat:@"%d", [dictionary[@"id"] intValue]]]]) {
                                        i = i + 1;
                                        break;
                                    }
                                }
                                
                                if (i == 0) {
                                    [managedObjectContext deleteObject:recipe];
                                    [managedObjectContext save:nil];
                                }
                            }

                            [[NSNotificationCenter defaultCenter] postNotificationName:@"LoadingDone" object:nil];
                            
                            if (error) {
                                NSLog(@"Error: %@", error.localizedDescription);
                            }
                        }
                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                        NSLog(@"Image error: %@", error);
                    }];
                    [requestOperation start];
                }
            }
        }

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ThereWasAnError" object:error];
    }];
    
    [operationToGetData start];
}

@end
