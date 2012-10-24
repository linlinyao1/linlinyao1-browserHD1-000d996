//
//  TLTabsView.h
//  test
//
//  Created by imac on 12-9-26.
//  Copyright (c) 2012年 2345. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TLTabsViewDataSource;
@protocol TLTabsViewDelegate;

@interface TLTabsView : UIView
@property (nonatomic,strong,readonly) UITableView* tableView;
@property (nonatomic,assign) NSObject<TLTabsViewDataSource> *dataSource;
@property (nonatomic,assign) NSObject<TLTabsViewDelegate> *delegate;

-(void)setHeaderView:(UIView*)view;
-(void)setFooterView:(UIView*)view;


-(UIView*)tabAtIndexPath:(NSIndexPath*)indexPath;
-(NSIndexPath*)indexPathForSelectedTab;
-(NSIndexPath*)indexPathForTab:(UIView*)tab;

-(void)insertTabAtIndexPath:(NSIndexPath*)indexPath;
-(void)removeTabAtIndexPath:(NSIndexPath*)indexPath;

-(void)scrollToTabAtIndexPath:(NSIndexPath*)indexPath;
-(void)selectTabAtIndexPath:(NSIndexPath*)indexPath;
-(void)selectTabWithoutAnimationAtIndexPath:(NSIndexPath *)indexPath;
@end


@protocol TLTabsViewDataSource <NSObject>
@required
-(CGFloat)tabsView:(TLTabsView*)tabsView widthForTabAtIndexPath:(NSIndexPath*)indexPath;
-(NSInteger)numberOfTabInTabsView:(TLTabsView*)tabsView;

-(UIView*)tabsView:(TLTabsView*)tabsView createTabForViewAtIndexPath:(NSIndexPath*)indexPath;
-(void)tabsView:(TLTabsView*)tabsView configureTab:(UIView*)tab forViewAtIndexPath:(NSIndexPath*)indexPath;

@optional
-(UIView*)viewForFooterInTabsView:(TLTabsView*)tabsView;
-(CGFloat)widthForFooterInTabsView:(TLTabsView*)tabsView;

-(UIView*)viewForHeaderInTabsView:(TLTabsView*)tabsView;
-(CGFloat)widthForHeaderInTabsView:(TLTabsView*)tabsView;

@end

@protocol TLTabsViewDelegate <NSObject>
@optional
-(void)tabsView:(TLTabsView*)tabsView didSelectTabAtIndexPath:(NSIndexPath*)indexPath;
-(void)tabsView:(TLTabsView*)tabsView didDeselectTabAtIndexPath:(NSIndexPath*)indexPath;

-(void)tabsView:(TLTabsView *)tabsView willDisplayTab:(UIView*)tab atIndexPath:(NSIndexPath *)indexPath;

-(void)tabsViewDidEndScrollingAnimation:(TLTabsView *)tabsView;


@end