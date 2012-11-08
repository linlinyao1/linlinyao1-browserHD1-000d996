//
//  RCSwitchButton.m
//  browserHD
//
//  Created by imac on 12-11-1.
//  Copyright (c) 2012年 2345. All rights reserved.
//

#import "RCSwitchButton.h"
#import "UIColor+HexValue.h"


@interface RCSwitchButton ()
@property (nonatomic,strong) UIImage* imageOn;
@property (nonatomic,strong) UIImage* imageOff;
@end

@implementation RCSwitchButton


-(void)setOn:(BOOL)on
{
    if (_on != on) {
        _on = on;
        
        if (_on) {
            self.imageView.image = self.imageOn;
        }else{
            self.imageView.image = self.imageOff;
        }
    }
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.imageView = [[UIImageView alloc] init];
        [self addSubview:self.imageView];
        
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.font = [UIFont systemFontOfSize:14];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.textColor = [UIColor colorWithHexValue:@"5d646d"];
        
        [self addSubview:self.titleLabel];
        
        UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        [self addGestureRecognizer:tap];
        
        UISwipeGestureRecognizer* swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeLeft:)];
        swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
        [self addGestureRecognizer:swipeLeft];
        
        UISwipeGestureRecognizer* swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeRight:)];
        swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
        [self addGestureRecognizer:swipeRight];
    }
    return self;
}


-(void)setImage:(UIImage *)image forState:(BOOL)on
{
    if (on) {
        self.imageOn = image;
    }else{
        self.imageOff = image;
    }
    
    if (self.on) {
        self.imageView.image = self.imageOn;
    }else{
        self.imageView.image = self.imageOff;
    }
}

-(void)handleTap:(UITapGestureRecognizer*)gesture
{
    self.on = !self.on;
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

-(void)handleSwipeLeft:(UISwipeGestureRecognizer*)gesture
{
    if (self.on) {
        self.on  = NO;
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
}
-(void)handleSwipeRight:(UISwipeGestureRecognizer*)gesture
{
    if (!self.on) {
        self.on = YES;
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
}

@end
