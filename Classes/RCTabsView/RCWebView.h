//
//  RCWebView.h
//  browserHD
//
//  Created by imac on 12-8-15.
//  Copyright (c) 2012年 2345. All rights reserved.
//

#import <UIKit/UIKit.h>



@protocol RCWebViewDelegate <NSObject>
-(void)openlink:(NSURL*)link;
-(void)openlinkAtNewTab:(NSURL*)link;
-(void)openlinkAtBackground:(NSURL*)link;

//-(void)loadingProgressChange:(CGFloat)progress;
@end


@interface RCWebView : UIWebView

@property (nonatomic,unsafe_unretained) CGFloat loadingProgress;
@property (nonatomic,unsafe_unretained) NSInteger loadingCount;
@property (nonatomic,assign) BOOL isWebPage;
@property (nonatomic,copy) NSString* title;
@property (nonatomic,copy) NSString* currentURL;
@property (nonatomic,unsafe_unretained) BOOL suspend;
@property(nonatomic,assign) NSObject<RCWebViewDelegate>* longPressDelegate;

-(NSURL*)url;
-(NSString*)updateTitle;

- (void) cleanForDealloc;

-(void)startLoadingProgress;
-(void)stopLoadingProgress;

- (CGPoint)scrollOffset;

-(UIScrollView*)webScrollView;


@end
