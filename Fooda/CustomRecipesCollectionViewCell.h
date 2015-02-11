//
//  CustomRecipesCollectionViewCell.h
//  Fooda
//
//  Created by Ramon Gilabert Llop on 2/10/15.
//  Copyright (c) 2015 Ramon Gilabert. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomRecipesCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) UIImageView *imageViewPhoto;
@property (strong, nonatomic) UIView *difficultyOfRecipeView;
@property (strong, nonatomic) UILabel *titleRecipeLabel;
@property (strong, nonatomic) UILabel *difficultyRecipeLabel;

@end
