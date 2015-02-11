//
//  ViewController.m
//  Fooda
//
//  Created by Ramon Gilabert Llop on 2/10/15.
//  Copyright (c) 2015 Ramon Gilabert. All rights reserved.
//

#import "MainViewController.h"
#import "CustomRecipesCollectionViewCell.h"
#import "AFNetworking.h"
#import "DetailRecipeViewController.h"

#define IS_IPHONE5 (([[UIScreen mainScreen] bounds].size.height-568)?NO:YES)
#define IS_IPHONE4 (([[UIScreen mainScreen] bounds].size.height-480)?NO:YES)

static NSString *const MainViewControllerTitle = @"FOODA";

// Normally, without using storyboard we should use declarations and constants of all the values of sizes, etc. I haven't done it, but I could doing pretty much the same as above, just wanted to show you the syntax. :D

@interface MainViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic) CGSize sizeOfDevice;

// Let's create the main views, we're going to use code and not storyboard because of the animations I want to do, I know I could still use both (I've been doing that since I started), but since Xcode 6.0 was a bit buggy, I got used to do it that way (using an hybrid).

@property (strong, nonatomic) UIView *mainHeaderView;
@property (strong, nonatomic) UILabel *titleOfViewLabel;
@property (strong, nonatomic) UIButton *allRecipesButton;
@property (strong, nonatomic) UIButton *easyRecipesButton;
@property (strong, nonatomic) UIButton *mediumRecipesButton;
@property (strong, nonatomic) UIButton *difficultRecipesButton;
@property (strong, nonatomic) UIView *sorterBottomView;

// Let's get started with the collection view, a bit afraid, first time doing it in code.

@property (strong, nonatomic) UICollectionView *collectionView;

// Tap gesture recognizer, never done before in code, but it's going to be like the collection view, we can!

@property (strong, nonatomic) UITapGestureRecognizer *tapGestureRecognizer;

// Finally, I'm here!

// I've been doing the conventional way in the properties, but in my opinion, adding array at first makes more sense, then when you're writing in line 200 you just have to add self.a and the autocomplete will help you remember, it's true that if you have lots of arrays, then you should use another keyword, but for small projects, I think makes more sense, arrayOf, labelFor, etc. :D
@property (strong, nonatomic) NSArray *arrayWithAllRecipes;
@property (strong, nonatomic) NSArray *arrayWithAllRecipesReal; // It'll make sense! I would explain that more, but it's a surprise!
@property (strong, nonatomic) NSMutableArray *arrayWithEasyRecipes;
@property (strong, nonatomic) NSMutableArray *arrayWithMediumRecipes;
@property (strong, nonatomic) NSMutableArray *arrayWithDifficultRecipes;

// Hit me for this, but I don't know which is the most efficient way to store the image, because if I store it as a Binary Data in core data, then it's slow, then, I'll store in an array all the images.

@property (strong, nonatomic) NSArray *arrayWithAllImagesReal;
@property (strong, nonatomic) NSMutableArray *arrayWithAllImages;
@property (strong, nonatomic) NSMutableArray *arrayWithEasyImages;
@property (strong, nonatomic) NSMutableArray *arrayWithMediumImages;
@property (strong, nonatomic) NSMutableArray *arrayWithDifficultImages;

// Send the information there through the segue

@property (strong, nonatomic) NSString *stringWithTitle;
@property (strong, nonatomic) UIImage *imageToSend;
@property (strong, nonatomic) NSString *stringOfDescriptionToSend;
@property (strong, nonatomic) NSString *stringOfInstructionsToSend;

// Loading view

@property (strong, nonatomic) UIVisualEffectView *viewForBlurBackground;
@property (strong, nonatomic) UIView *viewContainerLoading;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) UILabel *labelOfLoading;

@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Just in case we have all the things in core data stored, let's call the array loading method, that will populate our arrays and then reload the collection view.

    [self arrayLoading];

    // Call the update bar to white method

    [self setNeedsStatusBarAppearanceUpdate];

    // First, we set the main header view, at first it will have the height of the device devided by 6, then it will have the device height devided by 8 (once we enter to a recipe).

    self.sizeOfDevice = [UIScreen mainScreen].bounds.size;

    // We set here our views, the colors were extracted by the app Sip.

    self.mainHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.sizeOfDevice.width, self.sizeOfDevice.height/6)];
    self.mainHeaderView.backgroundColor = [UIColor colorWithRed:0.93 green:0.49 blue:0.44 alpha:1];
    [self.view addSubview:self.mainHeaderView];

    if (IS_IPHONE4) {
        self.titleOfViewLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.sizeOfDevice.width, 70)];
    } else if (IS_IPHONE5) {
        self.titleOfViewLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.sizeOfDevice.width, 80)];
    } else {
        self.titleOfViewLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.sizeOfDevice.width, 100)];
    }
    self.titleOfViewLabel.text = MainViewControllerTitle;
    self.titleOfViewLabel.textAlignment = NSTextAlignmentCenter;
    self.titleOfViewLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:25];
    self.titleOfViewLabel.textColor = [UIColor whiteColor];
    [self.mainHeaderView addSubview:self.titleOfViewLabel];

    // We need to instantiate the button here for some reason, if not, we're not going to be able to edit it.

    self.allRecipesButton = [UIButton new];
    self.easyRecipesButton = [UIButton new];
    self.mediumRecipesButton = [UIButton new];
    self.difficultRecipesButton = [UIButton new];

    [self initButton:self.allRecipesButton withATitle:@"ALL RECIPES"];
    [self.allRecipesButton addTarget:self action:@selector(onShowAllRecipesButtonPressed:) forControlEvents:UIControlEventTouchUpInside];

    [self initButton:self.easyRecipesButton withATitle:@"EASY"];
    [self.easyRecipesButton addTarget:self action:@selector(onShowEasyRecipesButtonPressed:) forControlEvents:UIControlEventTouchUpInside];

    [self initButton:self.mediumRecipesButton withATitle:@"MEDIUM"];
    [self.mediumRecipesButton addTarget:self action:@selector(onShowMediumRecipesButtonPressed:) forControlEvents:UIControlEventTouchUpInside];

    [self initButton:self.difficultRecipesButton withATitle:@"DIFFICULT"];
    [self.difficultRecipesButton addTarget:self action:@selector(onShowDifficultRecipesButtonPressed:) forControlEvents:UIControlEventTouchUpInside];

    // Correction of the frames to make them responsive

    self.easyRecipesButton.frame = CGRectMake(self.sizeOfDevice.width/2 - self.easyRecipesButton.frame.size.width - 12.5, self.easyRecipesButton.frame.origin.y, self.easyRecipesButton.frame.size.width, self.easyRecipesButton.frame.size.height);

    self.mediumRecipesButton.frame = CGRectMake(self.sizeOfDevice.width/2 + 12.5, self.mediumRecipesButton.frame.origin.y, self.mediumRecipesButton.frame.size.width, self.mediumRecipesButton.frame.size.height);

    self.allRecipesButton.frame = CGRectMake(self.sizeOfDevice.width/2 - self.easyRecipesButton.frame.size.width - 37.5 - self.allRecipesButton.frame.size.width, self.allRecipesButton.frame.origin.y, self.allRecipesButton.frame.size.width, self.allRecipesButton.frame.size.height);

    self.difficultRecipesButton.frame = CGRectMake(self.sizeOfDevice.width/2 + self.mediumRecipesButton.frame.size.width + self.difficultRecipesButton.frame.size.width - 37.5, self.difficultRecipesButton.frame.origin.y, self.difficultRecipesButton.frame.size.width, self.difficultRecipesButton.frame.size.height);

    self.sorterBottomView = [[UIView alloc] initWithFrame:CGRectMake(self.sizeOfDevice.width/2 - self.easyRecipesButton.frame.size.width - 40.5 - self.allRecipesButton.frame.size.width, self.mainHeaderView.frame.size.height-6, self.allRecipesButton.frame.size.width + 5, 6)];
    self.sorterBottomView.backgroundColor = [UIColor whiteColor];
    [self.mainHeaderView addSubview:self.sorterBottomView];

    // Instantiate the tap gesture

    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapGestureRecognizerMethod:)];
    self.tapGestureRecognizer.numberOfTapsRequired = 1;

    // Let's instantiate the collection view

    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, self.mainHeaderView.frame.size.height, self.sizeOfDevice.width, self.sizeOfDevice.height - self.mainHeaderView.frame.size.height) collectionViewLayout:[UICollectionViewFlowLayout new]];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView registerClass:[CustomRecipesCollectionViewCell class] forCellWithReuseIdentifier:@"CellID"];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self.collectionView addGestureRecognizer:self.tapGestureRecognizer];
    
    [self.view addSubview:self.collectionView];

    // Let's create the effect we want and then add it to the view blur background, then we add the other stuff to show that we're loading new content, an activity indicator, etc.

    UIVisualEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    self.viewForBlurBackground = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    self.viewForBlurBackground.frame = CGRectMake(0, 0, self.sizeOfDevice.width, self.sizeOfDevice.height);

    self.viewContainerLoading = [[UIView alloc] initWithFrame:CGRectMake((self.sizeOfDevice.width - 75)/2, (self.sizeOfDevice.height - 75)/3, 75, 75)];
    self.viewContainerLoading.backgroundColor = [UIColor whiteColor];
    self.viewContainerLoading.layer.cornerRadius = 10;
    self.viewContainerLoading.alpha = 0.7;

    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 75, 75)];
    self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    self.activityIndicator.color = [UIColor grayColor];
    [self.activityIndicator startAnimating];

    self.labelOfLoading = [[UILabel alloc] initWithFrame:CGRectMake(25, (self.sizeOfDevice.height - 30)/2, self.sizeOfDevice.width - 50, 50)];
    self.labelOfLoading.text = @"Loading new content";
    self.labelOfLoading.textColor = [UIColor whiteColor];
    self.labelOfLoading.textAlignment = NSTextAlignmentCenter;
    self.labelOfLoading.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:20];

    self.viewForBlurBackground.hidden = YES;

    [self.viewContainerLoading addSubview:self.activityIndicator];
    [self.viewForBlurBackground addSubview:self.viewContainerLoading];
    [self.viewForBlurBackground addSubview:self.labelOfLoading];
    [self.view addSubview:self.viewForBlurBackground];

    // Let's notify this app

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(doneLoadingAllTheStuff:)
                                                 name:@"LoadingDone"
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showLoadingIndicator:)
                                                 name:@"WeNeedToShowIt"
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(thereWasAnErrorLoading:)
                                                 name:@"ThereWasAnError"
                                               object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self checkNSUserDefaults];
}

#pragma mark - Handle notifications

- (void)doneLoadingAllTheStuff:(NSNotification *)notification
{
    // We're done loading, let's hide the view for blur background and then let's load the array with the method.
    self.viewForBlurBackground.hidden = YES;
    [self checkNSUserDefaults];
    [self arrayLoading];
}

- (void)showLoadingIndicator:(NSNotification *)notification
{
    self.viewForBlurBackground.hidden = NO;
}

- (void)thereWasAnErrorLoading:(NSNotification *)notification
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Oops!" message:[NSString stringWithFormat:@"%@", [notification.object localizedDescription]] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [alertController dismissViewControllerAnimated:YES completion:nil];
    }];

    [alertController addAction:alertAction];

    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - Array loading

- (void)arrayLoading
{
    // We take all we have from core data, once done that, let's instantiate the arrays and check the difficulty of it, we're going to use that for the top bar thing (we're sorting them there).

    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Recipes"];
    NSArray *resultOfFeatching = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];

    self.arrayWithAllRecipes = resultOfFeatching;
    self.arrayWithAllRecipesReal = resultOfFeatching;
    [self.collectionView reloadData];

    self.arrayWithEasyRecipes = [NSMutableArray new];
    self.arrayWithMediumRecipes = [NSMutableArray new];
    self.arrayWithDifficultRecipes = [NSMutableArray new];
    self.arrayWithAllImages = [NSMutableArray new];
    self.arrayWithEasyImages = [NSMutableArray new];
    self.arrayWithMediumImages = [NSMutableArray new];
    self.arrayWithDifficultImages = [NSMutableArray new];

    for (Recipes *recipe in resultOfFeatching) {
        if ([recipe.difficulty isEqualToString:@"1.0"] || [recipe.difficulty isEqualToString:@"1"] || [recipe.difficulty isEqualToString:@"1."]) {
            [self.arrayWithEasyRecipes addObject:recipe];
            if (!recipe.photo) {
                [self.arrayWithEasyImages addObject:[UIImage imageNamed:@"recipe-placeholder"]];
            } else {
                [self.arrayWithEasyImages addObject:[UIImage imageWithData:recipe.photo]];
            }
        } else if ([recipe.difficulty isEqualToString:@"2.0"] || [recipe.difficulty isEqualToString:@"2"] || [recipe.difficulty isEqualToString:@"2."]) {
            [self.arrayWithMediumRecipes addObject:recipe];
            if (!recipe.photo) {
                [self.arrayWithMediumImages addObject:[UIImage imageNamed:@"recipe-placeholder"]];
            } else {
                [self.arrayWithMediumImages addObject:[UIImage imageWithData:recipe.photo]];
            }
        } else if ([recipe.difficulty isEqualToString:@"3.0"] || [recipe.difficulty isEqualToString:@"3"] || [recipe.difficulty isEqualToString:@"3."]) {
            [self.arrayWithDifficultRecipes addObject:recipe];
            if (!recipe.photo) {
                [self.arrayWithDifficultImages addObject:[UIImage imageNamed:@"recipe-placeholder"]];
            } else {
                [self.arrayWithDifficultImages addObject:[UIImage imageWithData:recipe.photo]];
            }
        }

        if (!recipe.photo) {
            [self.arrayWithAllImages addObject:[UIImage imageNamed:@"recipe-placeholder"]];
        } else {
            [self.arrayWithAllImages addObject:[UIImage imageWithData:recipe.photo]];
        }
    }

    self.arrayWithAllImagesReal = self.arrayWithAllImages;
}

#pragma mark - UICollectionView delegate methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.arrayWithAllRecipes.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CustomRecipesCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CellID" forIndexPath:indexPath];

    Recipes *recipe = self.arrayWithAllRecipes[indexPath.row];

    cell.imageViewPhoto = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height - cell.frame.size.height/4)];

    cell.difficultyOfRecipeView = [[UIView alloc] initWithFrame:CGRectMake(0, cell.imageViewPhoto.frame.size.height, cell.frame.size.width, cell.frame.size.height/4)];

    if ([recipe.difficulty isEqualToString:@"1.0"] || [recipe.difficulty isEqualToString:@"1"] || [recipe.difficulty isEqualToString:@"1."]) {
        cell.difficultyOfRecipeView.backgroundColor = [UIColor colorWithRed:0.58 green:0.78 blue:0.4 alpha:1];
    } else if ([recipe.difficulty isEqualToString:@"2.0"] || [recipe.difficulty isEqualToString:@"2"] || [recipe.difficulty isEqualToString:@"2."]) {
        cell.difficultyOfRecipeView.backgroundColor = [UIColor colorWithRed:0.95 green:0.49 blue:0.22 alpha:1];
    } else if ([recipe.difficulty isEqualToString:@"3.0"] || [recipe.difficulty isEqualToString:@"3"] || [recipe.difficulty isEqualToString:@"3."]) {
        cell.difficultyOfRecipeView.backgroundColor = [UIColor colorWithRed:0.87 green:0.35 blue:0.28 alpha:1];
    }

    cell.titleRecipeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, cell.frame.size.width - 25, cell.difficultyOfRecipeView.frame.size.height/1.5)];
    cell.titleRecipeLabel.text = @"I LOVE YOU HYPER";
    cell.titleRecipeLabel.adjustsFontSizeToFitWidth = YES;
    cell.titleRecipeLabel.font = [UIFont fontWithName:@"AvenirNextCondensed-DemiBold" size:22];
    cell.titleRecipeLabel.textColor = [UIColor whiteColor];

    cell.difficultyRecipeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, cell.difficultyOfRecipeView.frame.size.height - 25, cell.frame.size.width - 25, 25)];
    cell.difficultyRecipeLabel.text = @"SERIOUSLY";
    cell.difficultyRecipeLabel.font = [UIFont fontWithName:@"AvenirNext-Medium" size:12];
    cell.difficultyRecipeLabel.textColor = [UIColor whiteColor];

    [cell.difficultyOfRecipeView addSubview:cell.difficultyRecipeLabel];
    [cell.difficultyOfRecipeView addSubview:cell.titleRecipeLabel];

    [cell addSubview:cell.imageViewPhoto];
    [cell addSubview:cell.difficultyOfRecipeView];

    // Now let's add some data

    cell.imageViewPhoto.image = self.arrayWithAllImages[indexPath.row];
    cell.titleRecipeLabel.text = recipe.name;
    cell.difficultyRecipeLabel.text = recipe.difficulty;

    cell.backgroundColor = [UIColor redColor];

    return cell;

    // It wasn't that bad
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(self.sizeOfDevice.width/2 - 2, 190);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 2;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 4;
}

#pragma mark - Handle all the actions in the navigation bar

- (IBAction)onShowAllRecipesButtonPressed:(UIButton *)buttonAllRecipes
{
    self.arrayWithAllRecipes = self.arrayWithAllRecipesReal;
    self.arrayWithAllImages = [NSMutableArray new];
    [self.arrayWithAllImages addObjectsFromArray:self.arrayWithAllImagesReal];
    [self.collectionView reloadData];
    [self performAnimationWithAnXPositionOf:(self.allRecipesButton.frame.origin.x - 2.5) andAWithOf:(self.allRecipesButton.frame.size.width + 5)];
}

- (IBAction)onShowEasyRecipesButtonPressed:(UIButton *)buttonAllRecipes
{
    self.arrayWithAllRecipes = self.arrayWithEasyRecipes;
    self.arrayWithAllImages = [NSMutableArray new];
    [self.arrayWithAllImages addObjectsFromArray:self.arrayWithEasyImages];
    [self.collectionView reloadData];
    [self performAnimationWithAnXPositionOf:(self.easyRecipesButton.frame.origin.x - 2.5) andAWithOf:(self.easyRecipesButton.frame.size.width + 5)];
}

- (IBAction)onShowMediumRecipesButtonPressed:(UIButton *)buttonAllRecipes
{
    self.arrayWithAllRecipes = self.arrayWithMediumRecipes;
    self.arrayWithAllImages = [NSMutableArray new];
    [self.arrayWithAllImages addObjectsFromArray:self.arrayWithMediumImages];
    [self.collectionView reloadData];
    [self performAnimationWithAnXPositionOf:(self.mediumRecipesButton.frame.origin.x - 2.5) andAWithOf:(self.mediumRecipesButton.frame.size.width + 5)];
}

- (IBAction)onShowDifficultRecipesButtonPressed:(UIButton *)buttonAllRecipes
{
    self.arrayWithAllRecipes = self.arrayWithDifficultRecipes;
    self.arrayWithAllImages = [NSMutableArray new];
    [self.arrayWithAllImages addObjectsFromArray:self.arrayWithDifficultImages];
    [self.collectionView reloadData];
    [self performAnimationWithAnXPositionOf:(self.difficultRecipesButton.frame.origin.x - 2.5) andAWithOf:(self.difficultRecipesButton.frame.size.width + 5)];
}

#pragma mark - Helper methods

- (void)performAnimationWithAnXPositionOf:(CGFloat)xPosition andAWithOf:(CGFloat)widthForFrame
{
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.sorterBottomView.frame = CGRectMake(xPosition, self.sorterBottomView.frame.origin.y, widthForFrame, 6);
    } completion:^(BOOL finished) {
    }];
}

- (void)checkNSUserDefaults
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    if (![defaults objectForKey:@"firstTimeInApp"]) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Hey! :)" message:@"I just wanted to say thank you for this, it made me so happy, just that small thing you have, to be offered one of your dream jobs, that feeling, that feeling is amazing, I would, ideally work more on this app, but I'm that excited that I cannot wait anymore for you to see it, hope you underestand, welcome to FOODA, my passport to happines! :)" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"WE'LL MAKE IT" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            [alertController dismissViewControllerAnimated:YES completion:nil];
        }];

        [alertController addAction:alertAction];

        [self presentViewController:alertController animated:YES completion:nil];

        [defaults setObject:[NSDate date] forKey:@"firstTimeInApp"];
    }

    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Handle actions of the tap gesture recognizer

- (IBAction)onTapGestureRecognizerMethod:(UITapGestureRecognizer *)tapGestureRecognizer
{
    CGPoint locationView = [tapGestureRecognizer locationInView:self.collectionView];

    NSIndexPath *tappedIndexPath = [self.collectionView indexPathForItemAtPoint:locationView];

    // And here's the warning, I underestand I should use UICollectionView, but then you cannot manipulate all the things in the actual collectionViewCell, I always have that warning... Is there any way to fix it?

    CustomRecipesCollectionViewCell *collectionViewCell = [self.collectionView cellForItemAtIndexPath:tappedIndexPath];

    Recipes *recipe = self.arrayWithAllRecipes[tappedIndexPath.row];

    CGRect cellFrameInSuperview = [self.collectionView convertRect:collectionViewCell.frame toView:self.collectionView.superview];

    // What we are basically doing here is making a copy of the imageView, hide it in the cell and make the views move.

    collectionViewCell.imageViewPhoto.alpha = 0;
    UIImageView *imageViewToRecoverCell = [[UIImageView alloc] initWithFrame:CGRectMake(cellFrameInSuperview.origin.x, cellFrameInSuperview.origin.y, collectionViewCell.imageViewPhoto.frame.size.width, collectionViewCell.imageViewPhoto.frame.size.height)];
    imageViewToRecoverCell.backgroundColor = [UIColor blackColor];
    imageViewToRecoverCell.image = collectionViewCell.imageViewPhoto.image;
    [self.view addSubview:imageViewToRecoverCell];

    self.stringWithTitle = [recipe.name uppercaseString];
    self.imageToSend = collectionViewCell.imageViewPhoto.image;
    self.stringOfDescriptionToSend = recipe.descriptions;
    self.stringOfInstructionsToSend = recipe.instructions;

    // Here we simulate a transition between view controllers doing like a magic transition (in keynote), but what we're doing is to translate the views and change some frames to, at the end of the animation, perform the segue without animation.

    [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        imageViewToRecoverCell.frame = CGRectMake(0, self.sizeOfDevice.height/8, self.sizeOfDevice.width, self.sizeOfDevice.height/2 - self.sizeOfDevice.height/8);
        self.mainHeaderView.frame = CGRectMake(0, 0, self.sizeOfDevice.width, self.sizeOfDevice.height/8);
        self.titleOfViewLabel.frame = CGRectMake(50, (self.mainHeaderView.frame.size.height - 25.5) - 25, self.sizeOfDevice.width - 100, 50);
        self.titleOfViewLabel.adjustsFontSizeToFitWidth = YES;
        self.titleOfViewLabel.text = [recipe.name uppercaseString];
        self.collectionView.alpha = 0;
    } completion:^(BOOL finished) {
        [self performSegueWithIdentifier:@"seeTheReceip" sender:self];

        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [imageViewToRecoverCell removeFromSuperview];
            collectionViewCell.imageViewPhoto.alpha = 1;
            self.titleOfViewLabel.text = MainViewControllerTitle;
            self.titleOfViewLabel.frame = CGRectMake(0, 0, self.sizeOfDevice.width, 90);
            self.mainHeaderView.frame = CGRectMake(0, 0, self.sizeOfDevice.width, self.sizeOfDevice.height/6);
            self.collectionView.alpha = 1;
        });
    }];

    // After grabbing the point where we touch, let's now add the animation to see the recip and then that's going to be it!
}

#pragma mark - Segue methods

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"seeTheReceip"]) {
        DetailRecipeViewController *detailViewController = segue.destinationViewController;
        detailViewController.stringWithTitle = self.stringWithTitle;
        detailViewController.imageOfReceip = self.imageToSend;
        detailViewController.stringWithDescription = self.stringOfDescriptionToSend;
        detailViewController.stringWithInstructions = self.stringOfInstructionsToSend;
    }
}

#pragma mark - Instantiations

- (void)initButton:(UIButton *)buttonToInstantiate withATitle:(NSString *)titleForButton
{
    [buttonToInstantiate setTitle:titleForButton forState:UIControlStateNormal];
    [buttonToInstantiate setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [buttonToInstantiate setTitleColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1] forState:UIControlStateHighlighted];
    if (IS_IPHONE5) {
        buttonToInstantiate.frame = CGRectMake(15, self.mainHeaderView.frame.size.height - 35, 25, 25);
        buttonToInstantiate.titleLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:13];
    } else if (IS_IPHONE4) {
        buttonToInstantiate.frame = CGRectMake(15, self.mainHeaderView.frame.size.height - 30, 20, 20);
        buttonToInstantiate.titleLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:13];
    } else {
        buttonToInstantiate.frame = CGRectMake(15, self.mainHeaderView.frame.size.height - 37.5, 40, 40);
        buttonToInstantiate.titleLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:15];
    }
    [buttonToInstantiate sizeToFit];
    [self.mainHeaderView addSubview:buttonToInstantiate];
}

#pragma mark - Set white status bar

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

@end