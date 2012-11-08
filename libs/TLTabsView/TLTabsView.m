//
//  TLTabsView.m
//  test
//
//  Created by imac on 12-9-26.
//  Copyright (c) 2012年 2345. All rights reserved.
//

#import "TLTabsView.h"

#define kContentViewTag 101

@interface TLTabsView ()<UITableViewDataSource,UITableViewDelegate>

@end

@implementation TLTabsView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
        _tableView.scrollsToTop = NO;
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.showsHorizontalScrollIndicator = NO;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.transform = CGAffineTransformMakeRotation(-M_PI/2);
        _tableView.rowHeight = 200;
        [self addSubview:_tableView];
    }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    _tableView.frame = self.bounds;
}


#pragma mark - public methods
-(void)setHeaderView:(UIView *)view
{
    if (view) {
        UIView* header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, view.bounds.size.height, view.bounds.size.width)];
        view.transform = CGAffineTransformMakeRotation(M_PI/2);
        view.frame = header.bounds;
        [header addSubview:view];
        _tableView.tableHeaderView = header;
    }else{
        _tableView.tableHeaderView = nil;
    }
}

-(void)setFooterView:(UIView *)view
{
    if (view) {
        UIView* footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, view.bounds.size.height, view.bounds.size.width)];
        view.transform = CGAffineTransformMakeRotation(M_PI/2);
        view.frame = footer.bounds;
        [footer addSubview:view];
        _tableView.tableFooterView = footer;
    }else{
        _tableView.tableFooterView = nil;
    }
}

-(UIView *)tabAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [_tableView cellForRowAtIndexPath:indexPath];
    return [cell viewWithTag:kContentViewTag];
}

-(NSIndexPath *)indexPathForSelectedTab
{
    return [_tableView indexPathForSelectedRow];
}

-(NSIndexPath *)indexPathForTab:(UIView *)tab
{
    NSArray *visibleCells = [self.tableView visibleCells];
	
	__block NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
	
	[visibleCells enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		UITableViewCell *cell = obj;
        
		if ([cell viewWithTag:kContentViewTag] == tab) {
            indexPath = [self.tableView indexPathForCell:cell];
			*stop = YES;
		}
	}];
	return indexPath;
}

-(void)insertTabAtIndexPath:(NSIndexPath *)indexPath
{
    [_tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
}

-(void)removeTabAtIndexPath:(NSIndexPath *)indexPath
{
    [_tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
}

-(void)scrollToTabAtIndexPath:(NSIndexPath *)indexPath
{
    [_tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
}

-(void)selectTabAtIndexPath:(NSIndexPath *)indexPath
{

    if ([self.delegate respondsToSelector:@selector(tabsView:didDeselectTabAtIndexPath:)]) {
        [self.delegate tabsView:self didDeselectTabAtIndexPath:[self indexPathForSelectedTab]];
    }
    [_tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
    if ([self.delegate respondsToSelector:@selector(tabsView:didSelectTabAtIndexPath:)]) {
        [self.delegate tabsView:self didSelectTabAtIndexPath:indexPath];
    }

}
-(void)selectTabWithoutAnimationAtIndexPath:(NSIndexPath *)indexPath
{
    [_tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionMiddle];
}

#pragma mark - UITableViewDataSource

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.dataSource tabsView:self widthForTabAtIndexPath:indexPath];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataSource numberOfTabInTabsView:self];
}

-(UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if ([self.dataSource respondsToSelector:@selector(viewForFooterInTabsView:)]) {
        UIView* view = [self.dataSource viewForFooterInTabsView:self];
        UIView* footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, view.bounds.size.height, view.bounds.size.width)];
        view.transform = CGAffineTransformMakeRotation(M_PI/2);
        view.frame = footer.bounds;
        [footer addSubview:view];
        return footer;
    }else{
        return nil;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if ([self.dataSource respondsToSelector:@selector(widthForFooterInTabsView:)]) {
        return [self.dataSource widthForFooterInTabsView:self];
    }else{
        return 0;
    }
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if ([self.dataSource respondsToSelector:@selector(viewForHeaderInTabsView:)]) {
        UIView* view = [self.dataSource viewForHeaderInTabsView:self];
        UIView* header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, view.bounds.size.height, view.bounds.size.width)];
        view.transform = CGAffineTransformMakeRotation(M_PI/2);
        view.frame = header.bounds;
        [header addSubview:view];
        return header;
    }else{
        return nil;
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ([self.dataSource respondsToSelector:@selector(widthForHeaderInTabsView:)]) {
        return [self.dataSource widthForHeaderInTabsView:self];
    }else{
        return 0;
    }
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static  NSString* CellIdentity = @"cell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentity];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentity];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.frame = CGRectMake(0, 0, [self.dataSource tabsView:self widthForTabAtIndexPath:indexPath], self.bounds.size.height);
        cell.clipsToBounds = NO;
        
        UIView* contentView = [self.dataSource tabsView:self createTabForViewAtIndexPath:indexPath];
        contentView.tag = kContentViewTag;
        contentView.autoresizingMask = UIViewAutoresizingNone;
        contentView.transform = CGAffineTransformMakeRotation(M_PI/2);
        contentView.frame = CGRectMake(0, 0, cell.bounds.size.height, cell.bounds.size.width);
        [cell addSubview:contentView];
    }
    UIView* contentView = [cell viewWithTag:kContentViewTag];
    cell.frame = CGRectMake(0, 0, [self.dataSource tabsView:self widthForTabAtIndexPath:indexPath], self.bounds.size.height);
    contentView.frame = CGRectMake(0, 0, cell.bounds.size.height, cell.bounds.size.width);
    [self.dataSource tabsView:self configureTab:contentView forViewAtIndexPath:indexPath];
    return cell;
}



#pragma mark - UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(tabsView:didSelectTabAtIndexPath:)]) {
        [self.delegate tabsView:self didSelectTabAtIndexPath:indexPath];
    }
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(tabsView:didDeselectTabAtIndexPath:)]) {
        [self.delegate tabsView:self didDeselectTabAtIndexPath:indexPath];
    }
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(tabsView:willDisplayTab:atIndexPath:)]) {
        [self.delegate tabsView:self willDisplayTab:[cell viewWithTag:kContentViewTag] atIndexPath:indexPath];
    }
}




#pragma mark - UIScrollViewDelegate
//-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
//{
//    if ([self.delegate respondsToSelector:@selector(tabsViewDidEndScrollingAnimation:)]) {
//        [self.delegate tabsViewDidEndScrollingAnimation:self];
//    }
//}


@end
