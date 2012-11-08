//
//  RCSwitchButton.h
//  browserHD
//
//  Created by imac on 12-11-1.
//  Copyright (c) 2012年 2345. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RCSwitchButton : UIControl
@property (nonatomic,strong) UIImageView* imageView;
@property (nonatomic,strong) UILabel* titleLabel;
@property (nonatomic,unsafe_unretained) BOOL on;

-(void)setImage:(UIImage*)image forState:(BOOL)on;


@end
