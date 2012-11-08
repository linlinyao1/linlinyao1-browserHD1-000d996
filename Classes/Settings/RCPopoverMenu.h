//
//  RCPopoverMenu.h
//  browserHD
//
//  Created by imac on 12-11-1.
//  Copyright (c) 2012年 2345. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RCPopoverMenuDelegate <NSObject>

-(void)SettingShouldShow;
-(void)ShortcutShouldShow:(BOOL)show;

@end

@interface RCPopoverMenu : UIView<UIAlertViewDelegate>

@property (nonatomic,unsafe_unretained) NSObject<RCPopoverMenuDelegate>* delegate;
@end
