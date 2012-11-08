//
//  RCPopoverMenu.m
//  browserHD
//
//  Created by imac on 12-11-1.
//  Copyright (c) 2012年 2345. All rights reserved.
//

#import "RCPopoverMenu.h"
#import "RCSwitchButton.h"
#import "UIColor+HexValue.h"
#import "RCSettingViewController.h"
#import "RCRecordData.h"
#import "EGOCache.h"
#import "RCAppDelegate.h"

@implementation RCPopoverMenu

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        NSInteger offsetX = 20;
        NSInteger gap = 15;
        NSInteger offsetY = 25;
        
        
        UIImageView* bgimage = [[UIImageView alloc] initWithFrame:self.bounds];
        bgimage.image = [UIImage imageNamed:@"menuBG"];
        [self addSubview:bgimage];
        
        UIImageView* arrowimage = [[UIImageView alloc] initWithFrame:CGRectMake(247, 0, 20, 16)];
        arrowimage.image = [UIImage imageNamed:@"menuNorch"];
        [self addSubview:arrowimage];
        
        
        RCSwitchButton* rotationLock = [[RCSwitchButton alloc] initWithFrame:CGRectMake(offsetX, offsetY, 71, 85)];
        rotationLock.imageView.frame = CGRectMake(11, 0, 49, 53);
        [rotationLock setImage:[UIImage imageNamed:@"menu_rotationlock_off"] forState:NO];
        [rotationLock setImage:[UIImage imageNamed:@"menu_rotationlock_on"] forState:YES];
        rotationLock.titleLabel.frame = CGRectMake(0, 63, 71, 22);
        rotationLock.titleLabel.text = @"屏幕锁定";
        [rotationLock addTarget:self action:@selector(handleRotationLock:) forControlEvents:UIControlEventValueChanged];
        rotationLock.on = [[NSUserDefaults standardUserDefaults] boolForKey:defaultKeyForRoationLock];
        [self addSubview:rotationLock];
        
        
        RCSwitchButton* tracesless = [[RCSwitchButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(rotationLock.frame)+gap, offsetY, 71, 85)];
        tracesless.imageView.frame = CGRectMake(11, 0, 49, 53);
        [tracesless setImage:[UIImage imageNamed:@"menu_traceless_off"] forState:NO];
        [tracesless setImage:[UIImage imageNamed:@"menu_traceless_on"] forState:YES];
        tracesless.titleLabel.frame = CGRectMake(0, 63, 71, 22);
        tracesless.titleLabel.text = @"无痕浏览";
        [tracesless addTarget:self action:@selector(handletracesless:) forControlEvents:UIControlEventValueChanged];
        tracesless.on = [[NSUserDefaults standardUserDefaults] boolForKey:defaultKeyForTraceless];
        [self addSubview:tracesless];
        
        
        RCSwitchButton* shortCut = [[RCSwitchButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(tracesless.frame)+gap, offsetY, 71, 85)];
        shortCut.imageView.frame = CGRectMake(11, 0, 49, 53);
        [shortCut setImage:[UIImage imageNamed:@"menu_shortcut_off"] forState:NO];
        [shortCut setImage:[UIImage imageNamed:@"menu_shortcut_on"] forState:YES];
        shortCut.titleLabel.frame = CGRectMake(0, 63, 71, 22);
        shortCut.titleLabel.text = @"快捷工具";
        [shortCut addTarget:self action:@selector(handleshortCut:) forControlEvents:UIControlEventValueChanged];
        shortCut.on = [[NSUserDefaults standardUserDefaults] boolForKey:defaultKeyForShortcut];
        [self addSubview:shortCut];
        
        
        
        UISlider* brightSlider = [[UISlider alloc] initWithFrame:CGRectMake(30, CGRectGetMaxY(shortCut.frame)+40, self.bounds.size.width-60, 27)];
        [brightSlider setMinimumValueImage:[UIImage imageNamed:@"menu_sliderMin"]];
        [brightSlider setMaximumValueImage:[UIImage imageNamed:@"menu_sliderMax"]];
        [brightSlider setThumbImage:[UIImage imageNamed:@"menu_sliderThumb"] forState:UIControlStateNormal];
        [brightSlider setMinimumValue:0.0f];
        [brightSlider setMaximumValue:0.8f];
        if ([[UIScreen mainScreen] respondsToSelector:@selector(setBrightness:)]) {
            [brightSlider setMinimumTrackTintColor:[UIColor colorWithHexValue:@"6ca7f0"]];
            [brightSlider setMaximumTrackTintColor:[UIColor colorWithRed:172.0/255.0 green:173.0/255.0 blue:178.0/255.0 alpha:1]];
            [brightSlider addTarget:self action:@selector(handleBrightSlider:) forControlEvents:UIControlEventValueChanged];
            brightSlider.value =  0.8-[[NSUserDefaults standardUserDefaults] floatForKey:defaultKeyForBrightness];//[[UIScreen mainScreen] brightness];
        }else{
            brightSlider.enabled = NO;
        }
        [self addSubview:brightSlider];
        
        
        UIImageView* seperater = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"menu_seperater"]];
        seperater.frame = CGRectMake(0, CGRectGetMaxY(brightSlider.frame)+25, self.bounds.size.width, 1);
        [self addSubview:seperater];
        
        UIButton* rate = [UIButton buttonWithType:UIButtonTypeCustom];
        rate.frame = CGRectMake(offsetX, CGRectGetMaxY(brightSlider.frame)+30, 71, 75);
        [rate setImageEdgeInsets:UIEdgeInsetsMake(10, 18, 30, 18)];
        [rate setTitleEdgeInsets:UIEdgeInsetsMake(40, -35, 0, 0)];
        [rate setImage:[UIImage imageNamed:@"menu_rate"] forState:UIControlStateNormal];
        [rate setTitle:@"反馈评分" forState:UIControlStateNormal];
        [rate setTitleColor:[UIColor colorWithHexValue:@"5d646d"] forState:UIControlStateNormal];
        rate.titleLabel.font = [UIFont systemFontOfSize:14];
        [rate setBackgroundImage:[UIImage imageNamed:@"menu_ButtonBG"] forState:UIControlStateHighlighted];
        [rate addTarget:self action:@selector(handleRate:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:rate];
        
        UIButton* clear = [UIButton buttonWithType:UIButtonTypeCustom];
        clear.frame = CGRectMake(CGRectGetMaxX(rate.frame)+gap, CGRectGetMaxY(brightSlider.frame)+30, 71, 75);
        [clear setImageEdgeInsets:UIEdgeInsetsMake(10, 18, 30, 18)];
        [clear setTitleEdgeInsets:UIEdgeInsetsMake(40, -35, 0, 0)];
        [clear setImage:[UIImage imageNamed:@"menu_clearHistory"] forState:UIControlStateNormal];
        [clear setTitle:@"清除痕迹" forState:UIControlStateNormal];
        [clear setTitleColor:[UIColor colorWithHexValue:@"5d646d"] forState:UIControlStateNormal];
        clear.titleLabel.font = [UIFont systemFontOfSize:14];
        [clear setBackgroundImage:[UIImage imageNamed:@"menu_ButtonBG"] forState:UIControlStateHighlighted];
        [clear addTarget:self action:@selector(handleClear:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:clear];
        
        UIButton* setting = [UIButton buttonWithType:UIButtonTypeCustom];
        setting.frame = CGRectMake(CGRectGetMaxX(clear.frame)+gap, CGRectGetMaxY(brightSlider.frame)+30, 71, 75);
        [setting setImageEdgeInsets:UIEdgeInsetsMake(10, 18, 30, 18)];
        [setting setTitleEdgeInsets:UIEdgeInsetsMake(40, -35, 0, 0)];
        [setting setImage:[UIImage imageNamed:@"menu_setting"] forState:UIControlStateNormal];
        [setting setTitle:@"系统设置" forState:UIControlStateNormal];
        [setting setTitleColor:[UIColor colorWithHexValue:@"5d646d"] forState:UIControlStateNormal];
        setting.titleLabel.font = [UIFont systemFontOfSize:14];
        [setting setBackgroundImage:[UIImage imageNamed:@"menu_ButtonBG"] forState:UIControlStateHighlighted];
        [setting addTarget:self action:@selector(handleSetting:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:setting];
        
    }
    return self;
}


-(void)handleRotationLock:(RCSwitchButton*)sender{
    [[NSUserDefaults standardUserDefaults] setBool:sender.on forKey:defaultKeyForRoationLock];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)handletracesless:(RCSwitchButton*)sender{
    [[NSUserDefaults standardUserDefaults] setBool:sender.on forKey:defaultKeyForTraceless];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)handleshortCut:(RCSwitchButton*)sender{
    [[NSUserDefaults standardUserDefaults] setBool:sender.on forKey:defaultKeyForShortcut];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.delegate ShortcutShouldShow:sender.on];
}

-(void)handleBrightSlider:(UISlider*)sender{
    if (sender.value>=0 && sender.value<=1) {
//        [[UIScreen mainScreen] setBrightness:sender.value];
        RCAppDelegate* appdelegate = (RCAppDelegate*)[[UIApplication sharedApplication] delegate];
        appdelegate.brightnessView.alpha = (0.8 - sender.value);
        [[NSUserDefaults standardUserDefaults] setFloat:(0.8 - sender.value) forKey:defaultKeyForBrightness];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}


-(void)handleRate:(UIButton*)sender{
    NSString *appId = @"563833448";
    NSString* url = [NSString stringWithFormat: @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@", appId];
    [[UIApplication sharedApplication] openURL: [NSURL URLWithString: url]];
}
-(void)handleClear:(UIButton*)sender{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil message:@"是否清除浏览历史等痕迹" delegate:self cancelButtonTitle:@"清除" otherButtonTitles:@"取消",nil];
    [alert show];
}
-(void)handleSetting:(UIButton*)sender{
    [self.delegate SettingShouldShow];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"清除"]) {
        [RCRecordData updateRecord:nil ForKey:RCRD_HISTORY];
        [RCRecordData updateRecord:nil ForKey:RCRD_FAV];
        [[EGOCache currentCache] clearCache];
    }
}


@end
