//
//  DetailRecipeViewController.m
//  Fooda
//
//  Created by Ramon Gilabert Llop on 2/10/15.
//  Copyright (c) 2015 Ramon Gilabert. All rights reserved.
//

#import "DetailRecipeViewController.h"

@interface DetailRecipeViewController ()

// Let's create the things we're going to need here, first of all, the header view, then the title, a button to love the recipe, button to unwind to the previous view controller, the image view and the text, we could use a textView but I want to use labels instead.

@property (nonatomic) CGSize sizeOfDevice;
@property (strong, nonatomic) UIView *mainHeaderView;
@property (strong, nonatomic) UILabel *titleOfViewController;
@property (strong, nonatomic) UIButton *backButton;
@property (strong, nonatomic) UIButton *loveButton;
@property (strong, nonatomic) UILabel *descriptionTitleLabel;
@property (strong, nonatomic) UILabel *descriptionTextLabel;
@property (strong, nonatomic) UILabel *instructionsTitleLabel;
@property (strong, nonatomic) UILabel *instructionsTextLabel;
@property (strong, nonatomic) UIImageView *mainImageImageView;

@end

@implementation DetailRecipeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Call the update bar to white method

    [self setNeedsStatusBarAppearanceUpdate];

    self.sizeOfDevice = [UIScreen mainScreen].bounds.size;

    self.mainHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.sizeOfDevice.width, self.sizeOfDevice.height/8)];
    self.mainHeaderView.backgroundColor = [UIColor colorWithRed:0.93 green:0.49 blue:0.44 alpha:1];

    self.titleOfViewController = [[UILabel alloc] initWithFrame:CGRectMake(50, (self.mainHeaderView.frame.size.height - 25.5) - 25, self.sizeOfDevice.width - 100, 50)];
    self.titleOfViewController.textColor = [UIColor whiteColor];
    self.titleOfViewController.textAlignment = NSTextAlignmentCenter;
    self.titleOfViewController.adjustsFontSizeToFitWidth = YES;
    self.titleOfViewController.font = [UIFont fontWithName:@"Helvetica Neue" size:25];
    [self.mainHeaderView addSubview:self.titleOfViewController];

    self.backButton = [[UIButton alloc] initWithFrame:CGRectMake(11, (self.mainHeaderView.frame.size.height - 25.5) - 12.5, 15.5, 25.5)];
    [self.backButton setImage:[UIImage imageNamed:@"back-arrow-image"] forState:UIControlStateNormal];
    [self.backButton addTarget:self action:@selector(onBackButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.mainHeaderView addSubview:self.backButton];

    self.loveButton = [[UIButton alloc] initWithFrame:CGRectMake(self.mainHeaderView.frame.size.width - 25.5 - 11, (self.mainHeaderView.frame.size.height - 25.5) - 12.5, 27.5, 25.5)];
    [self.loveButton setImage:[UIImage imageNamed:@"love-button-image"] forState:UIControlStateNormal];
    [self.loveButton addTarget:self action:@selector(onLoveButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.mainHeaderView addSubview:self.loveButton];

    self.mainImageImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.mainHeaderView.frame.size.height, self.sizeOfDevice.width, self.sizeOfDevice.height/2 - self.mainHeaderView.frame.size.height)];
    self.mainImageImageView.backgroundColor = [UIColor blackColor];

    self.descriptionTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, self.mainImageImageView.frame.origin.y + self.mainImageImageView.frame.size.height + 20, self.sizeOfDevice.width - 30, 25)];
    self.descriptionTitleLabel.text = @"DESCRIPTION";
    self.descriptionTitleLabel.textColor = [UIColor colorWithRed:0.92 green:0.45 blue:0.39 alpha:1];
    self.descriptionTitleLabel.font = [UIFont fontWithName:@"AvenirNextCondensed-DemiBold" size:28];

    [self.view addSubview:self.descriptionTitleLabel];
    [self.view addSubview:self.mainImageImageView];
    [self.view addSubview:self.mainHeaderView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    // We put all that stuff here because then, when you'll have the information of the size of the description, you'll be able to get the best position for the instructions title.

    self.titleOfViewController.text = self.stringWithTitle;

    self.descriptionTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, self.descriptionTitleLabel.frame.origin.y + self.descriptionTitleLabel.frame.size.height + 5, self.sizeOfDevice.width - 30, 30)];
    self.descriptionTextLabel.numberOfLines = 20;
    self.descriptionTextLabel.text = self.stringWithDescription;
    self.descriptionTextLabel.textColor = [UIColor colorWithRed:0.23 green:0.22 blue:0.22 alpha:1];

    CGRect requiredHeight = [self.descriptionTextLabel.text boundingRectWithSize:CGSizeMake(self.sizeOfDevice.width - 30, 10000) options:NSStringDrawingUsesLineFragmentOrigin attributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"HelveticaNeue" size:22], NSFontAttributeName, nil] context:nil];

    if (requiredHeight.size.width > self.descriptionTextLabel.frame.size.width) {
        requiredHeight = CGRectMake(0,0, self.descriptionTextLabel.frame.size.width, requiredHeight.size.height);
    }

    CGRect newFrameForDescription = self.descriptionTextLabel.frame;
    newFrameForDescription.size.height = requiredHeight.size.height;
    self.descriptionTextLabel.frame = newFrameForDescription;

    self.instructionsTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, self.descriptionTextLabel.frame.origin.y + self.descriptionTextLabel.frame.size.height + 20, self.sizeOfDevice.width - 30, 25)];
    self.instructionsTitleLabel.text = @"INSTRUCTIONS";
    self.instructionsTitleLabel.textColor = [UIColor colorWithRed:0.78 green:0.27 blue:0.22 alpha:1];
    self.instructionsTitleLabel.font = [UIFont fontWithName:@"AvenirNextCondensed-DemiBold" size:28];

    self.instructionsTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, self.instructionsTitleLabel.frame.origin.y + self.instructionsTitleLabel.frame.size.height + 5, self.sizeOfDevice.width - 30, 30)];
    self.instructionsTextLabel.numberOfLines = 20;
    self.instructionsTextLabel.text = self.stringWithInstructions;
    self.instructionsTextLabel.textColor = [UIColor colorWithRed:0.23 green:0.22 blue:0.22 alpha:1];

    if (requiredHeight.size.width > self.instructionsTextLabel.frame.size.width) {
        requiredHeight = CGRectMake(0,0, self.instructionsTextLabel.frame.size.width, requiredHeight.size.height - 10);
    }

    CGRect newFrameForInstructions = self.instructionsTextLabel.frame;
    newFrameForInstructions.size.height = requiredHeight.size.height;
    self.instructionsTextLabel.frame = newFrameForInstructions;

    self.mainImageImageView.image = self.imageOfReceip;

    [self.view addSubview:self.descriptionTextLabel];
    [self.view addSubview:self.instructionsTitleLabel];
    [self.view addSubview:self.instructionsTextLabel];

}

#pragma mark - Handle back and love button pressed

- (IBAction)onBackButtonPressed:(UIButton *)sender
{
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (IBAction)onLoveButtonPressed:(UIButton *)sender
{
    // It's funny how they don't tell that UIAlertView is deprecated in iOS 8!

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Hey, glad you tap here!" message:@"Adding a little bit of code in core data would have done the job, but I just wanted to say here a big thank you for reading this, and a big thank you for that oportunity that you're giving to me." preferredStyle:UIAlertControllerStyleAlert];

    [self presentViewController:alertController animated:YES completion:nil];

    UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"NICE" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        [alertController dismissViewControllerAnimated:YES completion:nil];
    }];

    [alertController addAction:alertAction];
}

#pragma mark - Set white status bar

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

@end