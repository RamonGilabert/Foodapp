//
//  RecipesSessionManager.h
//  Fooda
//
//  Created by Ramon Gilabert Llop on 2/10/15.
//  Copyright (c) 2015 Ramon Gilabert. All rights reserved.
//

#import "AFHTTPSessionManager.h"

@interface RecipesSessionManager : AFHTTPSessionManager

+ (RecipesSessionManager *)sharedJSONInformation;

@end
