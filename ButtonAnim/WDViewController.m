//
//  WDViewController.m
//  ButtonAnim
//
//  Created by David Stockley on 05/02/2014.
//  Copyright (c) 2014 David Stockley. All rights reserved.
//

#import "WDViewController.h"

#import "UIImage+ImageEffects.h"

static const NSUInteger kTileCount = 12;
static const NSUInteger kTileSize = 80;
static const NSUInteger kTileEdgePadding = 20;
static const NSUInteger kTileTopPadding = 30;

static const NSUInteger kOptionCount = 8;
static const NSUInteger kOptionSpread = 120;

#define DEG_RAD(angle) ((angle) / 180.0 * M_PI)

@interface WDViewController ()

@property (nonatomic, strong) NSMutableArray* buttonTiles;
@property (nonatomic, strong) NSMutableArray* optionTiles;

@property (nonatomic, assign) BOOL animatedOut;

@property (nonatomic, strong) UIImage* normalImage;
@property (nonatomic, strong) UIImage* darkImage;

@end

@implementation WDViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.buttonTiles = [NSMutableArray arrayWithCapacity:kTileCount];
    self.optionTiles = [NSMutableArray arrayWithCapacity:kOptionCount];
    
    for (NSUInteger i = 0; i < kOptionCount; i++) {
        UIView* button = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kTileSize/2, kTileSize/2)];
        button.backgroundColor = [UIColor redColor];
        button.alpha = 0.0;
        button.center = self.view.center;
        
        UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(optionPressed:)];
        [button addGestureRecognizer:tapGesture];
        
        [self.optionTiles addObject:button];
        [self.view addSubview:button];
    }
    
    for (NSUInteger i = 0; i < kTileCount; i++) {
        UIView* tile = [[UIView alloc] initWithFrame:CGRectZero];
        tile.backgroundColor = [UIColor purpleColor];
        
        UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tilePressed:)];
        [tile addGestureRecognizer:tapGesture];
        
        CGRect tileFrame;
        tileFrame.origin.x = kTileEdgePadding + (kTileSize * (i%3) + (i%3) * kTileEdgePadding);
        tileFrame.origin.y = kTileTopPadding + kTileEdgePadding + (kTileSize * (i/3) + (i/3) * kTileEdgePadding);
        tileFrame.size.width = kTileSize;
        tileFrame.size.height = kTileSize;
        
        tile.frame = tileFrame;
        
        [self.buttonTiles addObject:tile];
        [self.view addSubview:tile];
    }
    
    self.normalImage = self.imageView.image;
    
    self.darkImage = [self.imageView.image applyDarkEffect];
    self.darkImageView.image = self.darkImage;
    
    [self.view insertSubview:self.imageView aboveSubview:self.darkImageView];
}

- (void)tilePressed:(UITapGestureRecognizer*)sender
{
    if (self.animatedOut) {
        [self animateOptionsInOnTile:sender.view];
    }
    else {
        [self animateTileOut:sender.view];
    }
}

- (void)optionPressed:(UITapGestureRecognizer*)sender
{
    [self animateOptionsInOnTile:sender.view];
}

- (void)animateTileOut:(UIView*)tile
{
    [UIView animateWithDuration:0.6
                     animations:^{
                         for (UIView* otherTile in self.buttonTiles) {
                             if (![tile isEqual:otherTile]) {
                                 otherTile.alpha = 0.0;
                             }
                         }
                         
                         tile.center = self.view.center;
                     }
                     completion:^(BOOL finished) {
                         [self animateOptionsOutOnTile:tile];
                     }];
}
- (void)animateOptionsOutOnTile:(UIView*)tile
{
    for (UIView* options in self.optionTiles) {
        options.alpha = 1.0;
    }
    
    [UIView animateWithDuration:0.45
                     animations:^{
                         for (NSUInteger i = 0; i < self.optionTiles.count; i++) {
                             UIView* option = self.optionTiles[i];
                             
                             CGPoint newCenter = option.center;
                             newCenter.x = newCenter.x + kOptionSpread * cos(DEG_RAD(i * (360.0 / kOptionCount)));
                             newCenter.y = newCenter.y + kOptionSpread * sin(DEG_RAD(i * (360.0 / kOptionCount)));
                             option.center = newCenter;
                             
                             self.imageView.alpha = 0.0;
                         }
                     } completion:^(BOOL finished) {
                         self.animatedOut = YES;
                         [self.view insertSubview:self.darkImageView aboveSubview:self.imageView];
                         self.imageView.alpha = 1.0;
                     }];
}

- (void)animateOptionsInOnTile:(UIView*)tile
{
    [UIView animateWithDuration:0.45
                     animations:^{
                         for (NSUInteger i = 0; i < self.optionTiles.count; i++) {
                             UIView* option = self.optionTiles[i];
                             option.center = self.view.center;
                             self.darkImageView.alpha = 0.0;
                         }
                     } completion:^(BOOL finished) {
                         for (UIView* options in self.optionTiles) {
                             options.alpha = 0.0;
                         }
                         [self.view insertSubview:self.imageView aboveSubview:self.darkImageView];
                         self.darkImageView.alpha = 1.0;
                         [self animateTileIn:tile];
                     }];
}
- (void)animateTileIn:(UIView*)tile
{
    [UIView animateWithDuration:0.6
                     animations:^{
                         for (NSUInteger i = 0; i < self.buttonTiles.count; i++) {
                             UIView* otherTile = self.buttonTiles[i];
                             if (![tile isEqual:otherTile]) {
                                 otherTile.alpha = 1.0;
                             }
                             
                             CGRect tileFrame = otherTile.frame;
                             tileFrame.origin.x = kTileEdgePadding + (kTileSize * (i%3) + (i%3) * kTileEdgePadding);
                             tileFrame.origin.y = kTileTopPadding + kTileEdgePadding + (kTileSize * (i/3) + (i/3) * kTileEdgePadding);
                             otherTile.frame = tileFrame;
                         }
                     }
                     completion:^(BOOL finished) {
                         self.animatedOut = NO;
                     }];
}

@end
