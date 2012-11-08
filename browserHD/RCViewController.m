//
//  RCViewController.m
//  browserHD
//
//  Created by imac on 12-8-9.
//  Copyright (c) 2012年 2345. All rights reserved.
//

#import "RCViewController.h"
#import "EasyTableView.h"
#import "RCTab.h"
#import "RCUrlInputViewController.h"
#import "RCSearchInputViewController.h"
#import "RCSearchEngineSwitchViewController.h"
#import "RCConfigueNavIconsViewController.h"
#import "RCSettingViewController.h"
#import "RCUrlField.h"
#import "RCBookmarkView.h"
#import "RCBookmarkPopoverViewController.h"
#import "RCFolderEditingViewController.h"
#import "QuartzCore/QuartzCore.h"
#import "TLTabsView.h"
#import "RCRecordData.h"
#import "PopoverView.h"
#import "RCPopoverMenu.h"
#import "RNExpandingButtonBar.h"



#define TITLE_FOR_NEWTAB @"新建标签页"


#pragma mark - Declaration Section

@interface RCViewController ()<RCTabDelegate,UITextFieldDelegate,UIPopoverControllerDelegate,RCUrlInputViewControllerDelegate,RCHomePageDelegate,UIActionSheetDelegate,RCSearchEngineSwitchViewControllerDelegate,RCSearchInputViewControllerDelegate,TLTabsViewDataSource,TLTabsViewDelegate,UIWebViewDelegate,RCWebViewDelegate,PopoverViewDelegate,RCPopoverMenuDelegate>
@property (nonatomic,strong) EasyTableView *tabsView;
@property (nonatomic,strong) TLTabsView* browserTabView;
@property (nonatomic,strong) NSMutableArray *listURLs; //of tabs
@property (nonatomic,strong) NSMutableArray *listWebViews; //
@property (nonatomic,copy) NSString *JSToolCode;
@property (nonatomic,strong) NSMutableArray *webRestorePool; //for restore
@property (nonatomic,strong) RCWebView *preloadWeb;
@property (nonatomic,strong) UIButton* addNew;
@property (nonatomic,strong) UIImageView* restoreHint;
//dashBoard
@property (unsafe_unretained, nonatomic) IBOutlet UIView *DashBoard;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *DashBoardBack;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *DashBoardForward;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *DashBoardHome;
@property (unsafe_unretained, nonatomic) IBOutlet RCUrlField *DashBoardUrlField;
@property (unsafe_unretained, nonatomic) IBOutlet UITextField *DashBoardSearchField;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *DashBoardSetting;


@property (nonatomic,strong) UIButton *restoreTabButton;


@property (strong, nonatomic) IBOutlet UIView *urlInputKeyboardAccessory;

@property (nonatomic,strong) UIButton *reloadStopButton;

@property (nonatomic,unsafe_unretained) NSTimer *loadingTimer;

@property (nonatomic,strong) UIPopoverController *urlInputPopover;
@property (nonatomic,strong) UIPopoverController *searchInputPopover;
@property (nonatomic,strong) UIPopoverController *searchEnginePopover;
@property (nonatomic,strong) UIActionSheet *bookMarkActionSheet;
@property (nonatomic,strong) UIPopoverController* bookmarkPopover;
@property (nonatomic,strong) PopoverView* menuPopover;


@property (nonatomic,strong) RNExpandingButtonBar* shortcutButton;
///////////////////
///////////////////
@property (unsafe_unretained, nonatomic) IBOutlet UIView *browserView;

@property (nonatomic,strong) NSIndexPath* selectedIndexPath;
@property (nonatomic,unsafe_unretained) BOOL updating;

///////private method/////
-(void)homePageQuitEditingIfNeeded;

-(RCTab*)currentTab;

-(void)addNewTab;
-(void)addNewBackgroundTab;
-(void)resumeLastWeb;

//-(void)loadUrl:(NSURL*)url ForTab:(RCTab*)tab;

-(void)preloadWebView;

-(void)clearAllPopovers;
//-(void)updateLoadingState;

-(void)restoreHomePage;
//-(void)updateBackForwardButtonWithTab:(RCTab*)tab;

//-(void)updateSearchEngine;

//-(void)processLoadingProgressWithInfo:(NSMutableDictionary*)info;
-(void)searchFieldActive:(BOOL)active;


@end

@implementation RCViewController
//private
@synthesize browserView = _browserView;
@synthesize tabsView = _tabsView;
@synthesize DashBoard = _DashBoard;
@synthesize DashBoardBack = _DashBoardBack;
@synthesize DashBoardForward = _DashBoardForward;
@synthesize DashBoardHome = _DashBoardHome;
@synthesize DashBoardFav = _DashBoardFav;
@synthesize DashBoardUrlField = _DashBoardUrlField;
@synthesize DashBoardSearchField = _DashBoardSearchField;
@synthesize DashBoardSetting = _DashBoardSetting;
@synthesize urlInputKeyboardAccessory = _urlInputKeyboardAccessory;
@synthesize urlInputPopover = _urlInputPopover;
@synthesize searchInputPopover = _searchInputPopover;
@synthesize listWebViews = _listWebViews;
@synthesize homePage = _homePage;
@synthesize reloadStopButton = _reloadStopButton;
@synthesize searchEnginePopover = _searchEnginePopover;
@synthesize JSToolCode = _JSToolCode;
@synthesize bookMarkActionSheet = _bookMarkActionSheet;
@synthesize webRestorePool = _webRestorePool;
@synthesize preloadWeb = _preloadWeb;
@synthesize loadingTimer = _loadingTimer;
@synthesize restoreTabButton = _restoreTabButton;

@synthesize bookmarkPopover = _bookmarkPopover;
//public




#pragma mark - Lift Circle



- (void)viewDidLoad
{
    [super viewDidLoad];
    

//    self.selectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];

	// Do any additional setup after loading the view, typically from a nib.
    
    self.listWebViews = [NSMutableArray array];

    
    NSMutableArray* terminateList = [[NSUserDefaults standardUserDefaults] objectForKey:@"terminateList"];
    if (terminateList) {
        for (NSDictionary* dic in terminateList) {
            [self preloadWebView];
            self.preloadWeb.isWebPage = [[dic objectForKey:@"isWebPage"] boolValue];
            if (self.preloadWeb.isWebPage) {
                [self.preloadWeb loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[dic objectForKey:@"URL"]]]];
                self.preloadWeb.title = [dic objectForKey:@"title"];
//                self.preloadWeb.suspend = YES;
            }
            [self.listWebViews addObject:self.preloadWeb];
        }
    }else{
        [self preloadWebView];
        self.listWebViews = [NSMutableArray arrayWithObject:self.preloadWeb];
    }
    
    [self preloadWebView];
    [self.browserTabView.tableView reloadData];
    
//    NSLog(@"index: %d",[[NSUserDefaults standardUserDefaults] integerForKey:@"SelectedTab"]);
//    [self.browserTabView selectTabAtIndexPath:[NSIndexPath indexPathForRow:[[NSUserDefaults standardUserDefaults] integerForKey:@"SelectedTab"] inSection:0]];



    
    self.homePage = [[RCHomePage alloc] initWithFrame:self.browserView.bounds];
    self.homePage.delegate =self;
//
    
    NSString *jsCodePath = [[NSBundle mainBundle] pathForResource:@"JSTool" ofType:@"js"];
    NSString *jsCode = [NSString stringWithContentsOfFile:jsCodePath encoding:NSUTF8StringEncoding error:nil];
    self.JSToolCode = jsCode;
    
    
    
    CGRect frameRect	= CGRectMake(0, 0, 720, 38);
//	EasyTableView *view	= [[EasyTableView alloc] initWithFrame:frameRect numberOfColumns:12 ofWidth:201];
//    view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"tabViewBG"]];
//	self.tabsView = view;
//	view.delegate						= self;
//    view.tableView.contentInset = UIEdgeInsetsMake(10, 0, 0, 0);
//	view.tableView.backgroundColor	= [UIColor clearColor];//[UIColor colorWithPatternImage:[UIImage imageNamed:@"tabViewBG"]];
//	view.tableView.allowsSelection	= YES;
//    view.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//	view.autoresizingMask				= UIViewAutoresizingFlexibleWidth;
//	[self.view addSubview:view];
//    view.selectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    
    //////////////
    TLTabsView* browserTabView = [[TLTabsView alloc] initWithFrame:frameRect];
    browserTabView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"tabViewBG"]];
    browserTabView.tableView.contentInset = UIEdgeInsetsMake(10, 0, 0, 0);
    browserTabView.dataSource = self;
    browserTabView.delegate = self;
    browserTabView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.browserTabView = browserTabView;
    [self.view insertSubview:browserTabView aboveSubview:self.DashBoard];
//    [self.view addSubview:browserTabView];
    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:[[NSUserDefaults standardUserDefaults] integerForKey:@"SelectedTab"] inSection:0];
    [browserTabView.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
//damn bad idea
    int64_t delayInSeconds = 0.1;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self tabsView:browserTabView didSelectTabAtIndexPath:indexPath];
    });
    /////////////
    
    
    UIButton* restoreTabButton = [UIButton buttonWithType:UIButtonTypeCustom];
    restoreTabButton.backgroundColor = [UIColor clearColor];
    restoreTabButton.frame = CGRectMake(720, 0, 48, 38);
    [restoreTabButton setBackgroundImage:[UIImage imageNamed:@"tab_restore_normal"] forState:UIControlStateNormal];
    [restoreTabButton setBackgroundImage:[UIImage imageNamed:@"tab_restore_hite"] forState:UIControlStateHighlighted];
    [restoreTabButton setBackgroundImage:[UIImage imageNamed:@"tab_restore_disable"] forState:UIControlStateDisabled];
    
    restoreTabButton.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
    [restoreTabButton addTarget:self action:@selector(resumeLastWeb) forControlEvents:UIControlEventTouchUpInside];
    [restoreTabButton setEnabled:NO];
    [self.view insertSubview:restoreTabButton aboveSubview:self.DashBoard];
//    [self.view addSubview:restoreTabButton];
    self.restoreTabButton = restoreTabButton;
    
    self.DashBoard.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"dashboardBG"]];
    
    self.DashBoardUrlField.frame = CGRectMake(self.DashBoardUrlField.frame.origin.x, 6, 390, 31);
    self.DashBoardUrlField.progressImage = [UIImage imageNamed:@"urlField_PB_Portrait"];
    self.DashBoardSearchField.frame = CGRectMake(CGRectGetMaxX(self.DashBoardUrlField.frame)+15, 6, 126, 31);
    self.DashBoardSetting.frame = CGRectMake(CGRectGetMaxX(self.DashBoardSearchField.frame)+10, 0, 44, 44);
    

    UIView *keyboardAccessory = [[[NSBundle mainBundle] loadNibNamed:@"RCUrlInputKeyBoardAccessory" owner:self options:nil] objectAtIndex:0];
    keyboardAccessory.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"keyBoardAccessoryBG"]];
    self.DashBoardUrlField.inputAccessoryView = keyboardAccessory;
    self.urlInputKeyboardAccessory = keyboardAccessory;
//
    UIButton *stopReloadButton = [UIButton buttonWithType:UIButtonTypeCustom];
    stopReloadButton.bounds = CGRectMake(0, 0, 26, 30);
    [stopReloadButton setImage:[UIImage imageNamed:@"reload"] forState:UIControlStateNormal];
    [stopReloadButton setImage:[UIImage imageNamed:@"stopload"] forState:UIControlStateSelected];
    stopReloadButton.showsTouchWhenHighlighted = NO;
    [stopReloadButton addTarget:self action:@selector(reloadOrStop:) forControlEvents:UIControlEventTouchUpInside];
    self.DashBoardUrlField.rightView = stopReloadButton;
    self.DashBoardUrlField.rightViewMode = UITextFieldViewModeUnlessEditing;
    self.reloadStopButton = stopReloadButton;
//    
    UITextField *searchInput = self.DashBoardSearchField;
    UIButton *searchEngineButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [searchEngineButton addTarget:self action:@selector(handleSearchEngineButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    searchEngineButton.frame = CGRectMake(5, 5, 62, 28);
    searchInput.leftView = searchEngineButton;
    searchInput.leftViewMode = UITextFieldViewModeAlways;
    [self updateSearchEngine];
//    [self updateLoadingState];
    
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:defaultKeyForShortcut]) {
        [self ShortcutShouldShow:YES];
    }
    
    
    if (self.listWebViews.count<=1) {
        RCTab *lastTab = (RCTab *)[self.browserTabView tabAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        [lastTab setDisableClose:YES];
    }

    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willResignActive:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(DidEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
}


- (void)willResignActive:(NSNotification *)notification {
    NSLog(@"resign active");
    for (RCWebView* web in self.listWebViews) {
        if (web.loadingCount>0) {
            [web stopLoading];
            if (web.isWebPage) {
                web.suspend = YES;
            }
        }
    }
    
    if (self.menuPopover) {
        [self.menuPopover dismiss];
        self.menuPopover = nil;
    }
    
}

- (void)DidEnterBackground:(NSNotification *)notification {
    NSLog(@"Did Enter Background");
    NSMutableArray* terminateList = [NSMutableArray arrayWithCapacity:self.listWebViews.count];
    for (RCWebView* web in self.listWebViews) {
        NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithCapacity:3];
        [dic setObject:[NSNumber numberWithBool:web.isWebPage] forKey:@"isWebPage"];
        if (web.isWebPage) {
            if (web.request.URL.absoluteString.length) {
                [dic setObject:web.request.URL.absoluteString forKey:@"URL"];
            }else{
                [dic setObject:web.currentURL forKey:@"URL"];
            }
            [dic setObject:web.title forKey:@"title"];
        }

        [terminateList addObject:dic];
    }

    [[NSUserDefaults standardUserDefaults] setObject:terminateList forKey:@"terminateList"];
    [[NSUserDefaults standardUserDefaults] setInteger:[self.browserTabView indexPathForSelectedTab].row forKey:@"SelectedTab"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)viewDidUnload
{
    [self.listWebViews removeAllObjects];
    self.listWebViews = nil;
    self.tabsView = nil;
    self.browserTabView = nil;
    [self setBrowserView:nil];
    [self setUrlInputKeyboardAccessory:nil];
    [self setDashBoard:nil];
    [self setDashBoardBack:nil];
    [self setDashBoardForward:nil];
    [self setDashBoardHome:nil];
    [self setDashBoardFav:nil];
    [self setDashBoardUrlField:nil];
    [self setDashBoardSearchField:nil];
    [self setDashBoardSetting:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}


-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
//    for (int i=0; i<[self.browserView subviews].count-1; i++) {
//        UIView* view = [[self.browserView subviews] objectAtIndex:i];
//        [view removeFromSuperview];
//    }
    UIView* view = [[self.browserView subviews] lastObject];
    view.frame = self.browserView.bounds;

    [self.browserTabView.tableView scrollToNearestSelectedRowAtScrollPosition:UITableViewScrollPositionMiddle animated:NO];
    
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
        self.DashBoardUrlField.frame = CGRectMake(self.DashBoardUrlField.frame.origin.x, 6, 510, 31);
        self.DashBoardUrlField.progressImage = [UIImage imageNamed:@"urlField_PB_Landscape"];
        self.DashBoardSearchField.frame = CGRectMake(CGRectGetMaxX(self.DashBoardUrlField.frame)+15, 6, 255, 31);
        self.DashBoardSetting.frame = CGRectMake(CGRectGetMaxX(self.DashBoardSearchField.frame)+5, 0, 44, 44);
    }else{
        self.DashBoardUrlField.frame = CGRectMake(self.DashBoardUrlField.frame.origin.x, 6, 390, 31);
        self.DashBoardUrlField.progressImage = [UIImage imageNamed:@"urlField_PB_Portrait"];
        self.DashBoardSearchField.frame = CGRectMake(CGRectGetMaxX(self.DashBoardUrlField.frame)+15, 6, 124, 31);
        self.DashBoardSetting.frame = CGRectMake(CGRectGetMaxX(self.DashBoardSearchField.frame)+2, 0, 44, 44);
    }
    
    if (self.searchInputPopover) {
        [self searchFieldActive:YES];
        [self.searchInputPopover presentPopoverFromRect:self.DashBoardSearchField.frame inView:self.DashBoard permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    }
    
    if (self.urlInputPopover) {
        CGSize size = self.urlInputPopover.popoverContentSize;
        size.width = self.DashBoardUrlField.frame.size.width;
        self.urlInputPopover.popoverContentSize = size;
        
        [self.urlInputPopover presentPopoverFromRect:self.DashBoardUrlField.frame inView:self.DashBoard permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    }
    
    if (self.searchEnginePopover) {
        [self.searchEnginePopover presentPopoverFromRect:self.DashBoardSearchField.leftView.frame inView:self.DashBoardSearchField permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    }
    
    if (self.menuPopover) {
        [self.menuPopover showAtPoint:CGPointMake(self.DashBoardSetting.center.x+5, CGRectGetMaxY(self.DashBoardSetting.frame)-30) inView:self.DashBoard withContentView:self.menuPopover.contentView];
    }
    
    if (self.restoreHint) {
        if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
            self.restoreHint.frame = CGRectMake(800, 38, 230, 73);
        }else{
            self.restoreHint.frame = CGRectMake(545, 38, 230, 73);
        }
    }

    [self.homePage relayoutWithOrientation:toInterfaceOrientation];
}


-(void)didReceiveMemoryWarning
{
    void(^memoryClean)() = ^{
//        [self.webRestorePool removeAllObjects];
        [[NSURLCache sharedURLCache] removeAllCachedResponses];
    };
//    self.restoreTabButton.enabled = NO;
    RUN_BACK(memoryClean);

    [super didReceiveMemoryWarning];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return ![[NSUserDefaults standardUserDefaults] boolForKey:defaultKeyForRoationLock];
}

static int __i = 0;
-(BOOL)shouldAutorotate
{
    if (__i) {
        return ![[NSUserDefaults standardUserDefaults] boolForKey:defaultKeyForRoationLock];
    }else{
        __i++;
        return YES;
    }
}

-(void)reloadHomePage
{
    [self.homePage reloadData];
}

-(void)homePageQuitEditingIfNeeded
{
    [self.homePage quitEditng];
}

-(void)loadUrlforCurrentTab:(NSURL *)url
{
    if (!url) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"网址格式不正确" message:@"请使用右侧搜索框搜索" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        return;
    }
#ifdef PerformanceDebug
//    NSIndexPath* currentIndex = [self.browserTabView indexPathForSelectedTab];
    RCWebView* webview = [self.listWebViews objectAtIndex:[self.browserTabView indexPathForSelectedTab].row];
    if (!url.scheme.length) {
        url = [NSURL URLWithString:[@"http://" stringByAppendingString:url.absoluteString]];
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [webview loadRequest:[NSURLRequest requestWithURL:url]];
    });
    webview.currentURL = url.absoluteString;
    
    self.DashBoardUrlField.text = url.absoluteString;
    webview.isWebPage = YES;
    [self updateReloadWithWebview:webview];
    webview.frame = self.browserView.bounds;
    [self.homePage removeFromSuperview];
    [self.browserView addSubview:webview];
    
//    if (self.listWebViews.count<=1) {
//        RCTab *lastTab = (RCTab *)[self.browserTabView tabAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
//        [lastTab setDisableClose:NO];
//    }
    [self updateTabClosable];
#else
    RCTab *tab = [self currentTab];
    if (!tab.webView) {
        [self performSelector:@selector(loadUrlforCurrentTab:) withObject:url afterDelay:.1];
        return;
    }
    if (!url.scheme.length) {
        url = [NSURL URLWithString:[@"http://" stringByAppendingString:url.absoluteString]];
    }
    
    [tab.webView loadRequest:[NSURLRequest requestWithURL:url]];
    //    self.DashBoardUrlField.text = url.absoluteString;
    tab.webView.isWebPage = YES;
    [self.homePage removeFromSuperview];
    [self.browserView addSubview:tab.webView];
    tab.webView.frame = self.browserView.bounds;
#endif

}


//-(void)loadUrl:(NSURL *)url ForTab:(RCTab *)tab
//{
//    if (!tab.webView) {
//        return;
//    }
//    if (!url.scheme.length) {
//        url = [NSURL URLWithString:[@"http://" stringByAppendingString:url.absoluteString]];
//    }
//    [tab.webView loadRequest:[NSURLRequest requestWithURL:url]];
//    tab.webView.isWebPage = YES;
//    tab.webView.frame = self.browserView.bounds;
//}



-(void)clearAllPopovers
{
    if (self.urlInputPopover) {
        [self.urlInputPopover dismissPopoverAnimated:YES];
        self.urlInputPopover = nil;
    }
    if (self.searchInputPopover) {
        [self searchFieldActive:NO];
        [self.searchInputPopover dismissPopoverAnimated:YES];
        self.searchInputPopover = nil;
    }
    if (self.searchEnginePopover) {
        [self.searchEnginePopover dismissPopoverAnimated:YES];
        self.searchEnginePopover = nil;

    }
    if (self.bookMarkActionSheet) {
        [self.bookMarkActionSheet dismissWithClickedButtonIndex:0 animated:YES];
    }

}


-(RCTab *)currentTab
{
    return (RCTab *)[self.browserTabView tabAtIndexPath:[self.browserTabView indexPathForSelectedTab]];
}

-(RCWebView*)currentWeb
{
    return [self.listWebViews objectAtIndex:[self.browserTabView indexPathForSelectedTab].row];
}

-(void)resumeLastWeb
{
    [self homePageQuitEditingIfNeeded];

    if (self.webRestorePool.count>0) {
        NSURL* url = [self.webRestorePool lastObject];
        [self.webRestorePool removeObject:url];
        [self openlinkAtNewTab:url];

    }
    if (self.webRestorePool.count <=0) {
        self.restoreTabButton.enabled = NO;
    }
}




-(void)preloadWebView
{
    self.preloadWeb = nil;
    self.preloadWeb = [[RCWebView alloc] initWithFrame:self.browserView.bounds];
#ifdef PerformanceDebug
//    self.preloadWeb.autoresizingMask = RCViewAutoresizingALL;
    self.preloadWeb.delegate = self;
    self.preloadWeb.longPressDelegate = self;
    [self.preloadWeb addObserver:self forKeyPath:@"loadingProgress" options:NSKeyValueObservingOptionNew context:nil];
#else
    self.preloadWeb.autoresizingMask = RCViewAutoresizingALL;
#endif
}

//-(void)updateBackForwardButtonWithTab:(RCTab *)tab
//{
//    if (tab.webView.isWebPage) {
////        self.DashBoardHome.enabled = YES;
//        self.DashBoardBack.enabled = YES;
//        self.DashBoardForward.enabled = [tab.webView canGoForward];
//    }else{
////        self.DashBoardHome.enabled = NO;
//        self.DashBoardBack.enabled = NO;
//        if (tab.webView.request) {
//            self.DashBoardForward.enabled = YES;
//        }else{
//            self.DashBoardForward.enabled = NO;
//        }
//    }
//}

-(void)updateNetworkActive
{
    BOOL networkActive = NO;
    for (RCWebView* webView in self.listWebViews) {
        if (webView.loadingCount>0) {
            networkActive = YES;
            break;
        }
    }
    if (networkActive) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    }else{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }
}

-(void)updateBackForwardButtonWithWebview:(RCWebView*)webView
{
    if (webView.isWebPage) {
        self.DashBoardBack.enabled = YES;
        self.DashBoardForward.enabled = [webView canGoForward];
        if (self.shortcutButton) {
//            [[[self.shortcutButton buttons] objectAtIndex:3] setEnabled:YES]; // page down
//            [[[self.shortcutButton buttons] objectAtIndex:4] setEnabled:YES]; // page up
            [[[self.shortcutButton buttons] objectAtIndex:2] setEnabled:YES]; // back
        }
    }else{
        self.DashBoardBack.enabled = NO;
        if (webView.request.URL.absoluteString.length) {
            self.DashBoardForward.enabled = YES;
        }else{
            self.DashBoardForward.enabled = NO;
        }
        if (self.shortcutButton) {
//            [[[self.shortcutButton buttons] objectAtIndex:3] setEnabled:NO]; // page down
//            [[[self.shortcutButton buttons] objectAtIndex:4] setEnabled:NO]; // page up
            [[[self.shortcutButton buttons] objectAtIndex:2] setEnabled:NO]; // back
        }
    }
}

-(void)updateReloadWithWebview:(RCWebView*)webView
{
    self.reloadStopButton.hidden = !webView.isWebPage;
    if (webView.loadingCount >0) {
        [self.reloadStopButton setImage:[UIImage imageNamed:@"stopload"] forState:UIControlStateNormal];
    }else{
        [self.reloadStopButton setImage:[UIImage imageNamed:@"reload"] forState:UIControlStateNormal];
    }
}

-(void)updateTabClosable{
    RCTab *firstTab = (RCTab *)[self.browserTabView tabAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    if (self.listWebViews.count<=1 && ![(RCWebView*)[self.listWebViews lastObject] isWebPage]) {
        [firstTab setDisableClose:YES];
    }else{
        [firstTab setDisableClose:NO];
    }
    if (self.shortcutButton) {
        [[[self.shortcutButton buttons] objectAtIndex:1] setEnabled:!firstTab.closeTabButton.isHidden];
    }
}

-(void)searchFieldActive:(BOOL)active
{    
    
    [UIView animateWithDuration:.3 animations:^{
        if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
            if (active) {
                self.DashBoardUrlField.frame = CGRectMake(self.DashBoardUrlField.frame.origin.x, 6, 255, 31);
                self.DashBoardSearchField.frame = CGRectMake(CGRectGetMaxX(self.DashBoardUrlField.frame)+15, 6, 510, 31);
            }else{
                self.DashBoardUrlField.frame = CGRectMake(self.DashBoardUrlField.frame.origin.x, 6, 510, 31);
                self.DashBoardSearchField.frame = CGRectMake(CGRectGetMaxX(self.DashBoardUrlField.frame)+15, 6, 255, 31);
            }

        }else{
            if (active) {
                self.DashBoardUrlField.frame = CGRectMake(self.DashBoardUrlField.frame.origin.x, 6, 126, 31);
                self.DashBoardSearchField.frame = CGRectMake(CGRectGetMaxX(self.DashBoardUrlField.frame)+15, 6, 390, 31);
            }else{
                self.DashBoardUrlField.frame = CGRectMake(self.DashBoardUrlField.frame.origin.x, 6, 390, 31);
                self.DashBoardSearchField.frame = CGRectMake(CGRectGetMaxX(self.DashBoardUrlField.frame)+15, 6, 126, 31);
            }

        }
        
        CGSize size = self.searchInputPopover.popoverContentSize;
        size.width = self.DashBoardSearchField.frame.size.width;
        self.searchInputPopover.popoverContentSize = size;
    }];
}


-(NSIndexPath*)indexPathForWebview:(UIWebView*)webView
{
    NSInteger row = [self.listWebViews indexOfObject:webView];
    if (row!=NSNotFound) {
        return [NSIndexPath indexPathForRow:row inSection:0];
    }else{
        return nil;
    }
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    RCWebView* web = object;
    if (web == [self currentWeb]) {
//        NSLog(@"progress: %f",web.loadingProgress);
        self.DashBoardUrlField.loadingProgress = [NSNumber numberWithFloat:web.loadingProgress];
    }
}

#pragma mark -
#pragma mark ADD/REMOVE NEW TAB

-(void)addNewBackgroundTab
{
    if (self.listWebViews.count>=12) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"标签卡过多" message:@"打开太多标签影响性能，请关闭没用的标签！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        return;
    }
    NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:self.listWebViews.count inSection:0];

    [self.listWebViews addObject:self.preloadWeb];
    [self.listURLs addObject:@""];
    [self performSelector:@selector(preloadWebView) withObject:nil afterDelay:.5];
    
    [self.browserTabView insertTabAtIndexPath:newIndexPath];
    
    [self updateTabClosable];
//    RCTab *firstTab = (RCTab *)[self.browserTabView tabAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
//    if (self.listWebViews.count<=1) {
//        [firstTab setDisableClose:YES];
//    }else{
//        [firstTab setDisableClose:NO];
//    }
}
-(void)addNewTab
{
    self.updating = YES;
    if (self.listWebViews.count>=12) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"标签卡过多" message:@"打开太多标签影响性能，请关闭没用的标签！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    for (UIView* view in [self.browserView subviews]) {
        if ([view isKindOfClass:[RCBookmarkView class]]) {
            [view removeFromSuperview];
        }
    }
    
    NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:self.listWebViews.count inSection:0];

    
    [self.listWebViews addObject:self.preloadWeb];
    [self preloadWebView];
//    [self performSelector:@selector(preloadWebView) withObject:nil afterDelay:.5];
    
    [self.browserTabView insertTabAtIndexPath:newIndexPath];
    [self.browserTabView selectTabAtIndexPath:newIndexPath];

    [self updateTabClosable];

//    RCTab *firstTab = (RCTab *)[self.browserTabView tabAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
//    if (self.listWebViews.count<=1) {
//        [firstTab setDisableClose:YES];
//    }else{
//        [firstTab setDisableClose:NO];
//    }
}

-(void)handleAddNewTab:(UIButton *)sender
{
    [self addNewTab];
}

-(void)removeHint{
    [self.restoreHint removeFromSuperview];
    self.restoreHint = nil;
}
-(void)tabNeedsToBeClosed:(RCTab *)tab
{
#ifdef PerformanceDebug
    if (self.listWebViews.count<=1) {
        if ([(RCWebView*)[self.listWebViews lastObject] isWebPage]) {
            [self handleHomeButtonPress:nil];
            [self updateTabClosable];
            //            RCTab *lastTab = (RCTab *)[self.browserTabView tabAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
//            [lastTab setDisableClose:YES];
        }
        return;
    }
    NSIndexPath *indexPath = [self.browserTabView indexPathForTab:tab];
    NSIndexPath* selectedIndexPath = [self.browserTabView indexPathForSelectedTab];
    
    
    
    
    RCWebView* web = [self.listWebViews objectAtIndex:indexPath.row];
    
    //for restore
    if (!self.webRestorePool) {
        self.webRestorePool = [NSMutableArray arrayWithCapacity:1];
    }
    if (web.isWebPage && web.request.URL) {
        [self.webRestorePool addObject:web.request.URL];
        self.restoreTabButton.enabled = YES;
    }
    
    if (self.webRestorePool.count >= 12) {
        [self.webRestorePool removeObjectAtIndex:0];
    }
    //end of restore
    [web stringByEvaluatingJavaScriptFromString:@"stopVideo()"];
    
    
    [web cleanForDealloc];
    [web removeObserver:self forKeyPath:@"loadingProgress"];
    [self.listWebViews removeObjectAtIndex:indexPath.row];

    [self.browserTabView removeTabAtIndexPath:indexPath];
    if ([indexPath isEqual:selectedIndexPath]) {
        if (indexPath.row == 0) {
            [self.browserTabView selectTabAtIndexPath:indexPath];
        }else{
            [self.browserTabView selectTabAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row-1 inSection:0]];
        }
    }

    [self updateTabClosable];
//    if (self.listWebViews.count<=1) {
//        RCTab *lastTab = (RCTab *)[self.browserTabView tabAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
//        if ([(RCWebView*)[self.listWebViews lastObject] isWebPage]) {
//            [lastTab setDisableClose:NO];
//        }else{
//            [lastTab setDisableClose:YES];
//        }
//    }
    
#else
    if (self.listWebViews.count<=1) {
        return;
    }
    
    BOOL notFirstRestorTab = [[NSUserDefaults standardUserDefaults] boolForKey:@"notFirstRestorTab"];
    if (!notFirstRestorTab) {
        UIImageView* restoreHint = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"restoreHint"]];
        if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
            restoreHint.frame = CGRectMake(800, 38, 230, 73);
        }else{
            restoreHint.frame = CGRectMake(545, 38, 230, 73);
        }
        [self.view addSubview:restoreHint];
        [self performSelector:@selector(removeHint) withObject:nil afterDelay:3];
        self.restoreHint = restoreHint;
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"notFirstRestorTab"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    
    NSIndexPath *indexPath = [self.browserTabView indexPathForTab:tab];
    NSIndexPath* selectedIndexPath = [self.browserTabView indexPathForSelectedTab];

    if (!indexPath) {
        return;
    }
    
    tab.webView.delegate = nil;
    [tab.webView stopLoading];
    //for restore
    if (!self.webRestorePool) {
        self.webRestorePool = [NSMutableArray arrayWithCapacity:1];
    }
    if (tab.webView.isWebPage && tab.webView.request.URL) {
        [self.webRestorePool addObject:tab.webView.request.URL];
        self.restoreTabButton.enabled = YES;
    }
    
    if (self.webRestorePool.count >= 12) {
        [self.webRestorePool removeObjectAtIndex:0];
    }
    //end of restore
    [tab.webView stringByEvaluatingJavaScriptFromString:@"stopVideo()"];
    tab.webView = nil;
    
    [self.listContent removeObjectAtIndex:indexPath.row];
    [self.listWebViews removeObjectAtIndex:indexPath.row];
    
    [self.browserTabView removeTabAtIndexPath:indexPath];
    if ([indexPath isEqual:selectedIndexPath]) {
        if (indexPath.row == 0) {
            [self.browserTabView selectTabAtIndexPath:indexPath];
        }else{
            [self.browserTabView selectTabAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row-1 inSection:0]];
        }
    }

    if (self.listWebViews.count<=1) {
        RCTab *lastTab = (RCTab *)[self.browserTabView tabAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            [lastTab setDisableClose:YES];
    }
    
    [self updateNetworkActive];
    [self updateLoadingState];
#endif

}



#pragma mark -
#pragma mark - UIWebViewDelegate

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if ([request.URL.absoluteString isEqualToString:@"about:blank"]) {
        return NO;
    }
    NSLog(@"should: %@",request.URL);
    NSURL *url = [request URL];
    NSString *isBlankInBaseElement = [webView stringByEvaluatingJavaScriptFromString:@"MyIPhoneApp_isBlankInBaseElement()"];
    
    if ([[url scheme] isEqualToString:@"newtab"] || ([isBlankInBaseElement isEqualToString:@"yes"] && navigationType == UIWebViewNavigationTypeLinkClicked) ) {
        NSString *urlString = [[url resourceSpecifier] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        url = [NSURL URLWithString:urlString relativeToURL:webView.request.URL];
        [self openlinkAtNewTab:url];
        return NO;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSIndexPath *indexPath = [self indexPathForWebview:webView];
        if ([indexPath isEqual:[self.browserTabView indexPathForSelectedTab]]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self updateReloadWithWebview:(RCWebView*)webView];
                [self updateBackForwardButtonWithWebview:(RCWebView*)webView];
                if (request.mainDocumentURL.absoluteString.length) {
                    self.DashBoardUrlField.text = request.mainDocumentURL.absoluteString;
                }
            });
        }
    });
    
    return YES;
}

-(void)webViewDidStartLoad:(UIWebView *)webView
{    
    RCWebView* web = (RCWebView*)webView;
    if (web.loadingCount == 0) {
        [web startLoadingProgress];
    }
    web.loadingCount++;
    [self updateNetworkActive];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    RCWebView* web = (RCWebView*)webView;
    web.loadingCount--;
    web.currentURL = web.request.URL.absoluteString;
    
    if (web.loadingCount == 0) {
        [web stopLoadingProgress];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            BOOL update = NO;
            NSIndexPath *indexPath = [self indexPathForWebview:webView];
            RCTab *tab = (RCTab *)[self.browserTabView tabAtIndexPath:indexPath];
            if ([indexPath isEqual:[self.browserTabView indexPathForSelectedTab]]) {
                update = YES;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [webView stringByEvaluatingJavaScriptFromString: self.JSToolCode];
                [webView stringByEvaluatingJavaScriptFromString:@"MyIPhoneApp_ModifyLinkTargets()"];
                [webView stringByEvaluatingJavaScriptFromString:@"document.body.style.webkitTouchCallout='none';"];
                [webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.style.webkitTouchCallout='none';"];
                if (update) {
                    [self updateReloadWithWebview:web];
                    [self updateBackForwardButtonWithWebview:web];
                    self.DashBoardUrlField.text = webView.request.URL.absoluteString;
                }
                
                tab.titleLabel.text = [(RCWebView*)webView updateTitle];
                NSURL *url = [[NSURL alloc] initWithScheme:[webView.request.URL scheme] host:[webView.request.URL host] path:@"/favicon.ico"];
                [tab.favIcon setImageURL:url];
                
                [self updateNetworkActive];
                [self updateTabClosable];
                [[RCRecordData class] performSelector:@selector(saveImageForWeb:) withObject:webView afterDelay:.5];

                //update history
                void(^updateHistory)() = ^{
                    NSMutableArray *historyArray = [RCRecordData recordDataWithKey:RCRD_HISTORY];
                    BOOL saveURL = YES;
                    // Check that the URL is not already in the history list
                    NSString* urlString = webView.request.URL.absoluteString;
                    if ([urlString hasSuffix:@"/"]) {
                        urlString = [urlString substringToIndex:urlString.length-1];
                    }
                    for (BookmarkObject * history in historyArray) {
                        NSString* historyString = history.url.absoluteString;
                        if ([historyString hasSuffix:@"/"]) {
                            historyString = [historyString substringToIndex:historyString.length-1];
                        }
                        
                        if ([historyString isEqual:urlString]) {
                            history.date = [NSDate date];
                            history.count = [NSNumber numberWithInt: history.count.intValue+1];
                            saveURL = NO;
                            break;
                        }
                    }
                    // Add the new URL in the list
                    if (saveURL) {
                        BookmarkObject *history = [[BookmarkObject alloc] initWithName:tab.titleLabel.text andURL:webView.request.URL];
                        [historyArray addObject:history];
                    }
                    [RCRecordData updateRecord:historyArray ForKey:RCRD_HISTORY];
                    
                    NSArray *favArray = [historyArray sortedArrayUsingComparator:^NSComparisonResult(BookmarkObject *obj1, BookmarkObject *obj2) {
                        return [obj2.count compare:obj1.count];
                    }];
                    favArray = [favArray subarrayWithRange:NSMakeRange(0, MIN(favArray.count, MAX_FAV_COUNT))];
                    [RCRecordData updateRecord:favArray ForKey:RCRD_FAV];
                };
                if (![[NSUserDefaults standardUserDefaults] boolForKey:defaultKeyForTraceless]) {
                    RUN_BACK(updateHistory);
                }
                
                    
                
            });
        });
    }
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    RCWebView* web = (RCWebView*)webView;
    web.loadingCount--;
    NSLog(@"fail");
    switch ([error code]) {
        case kCFURLErrorCancelled :
        {
            // Do nothing in this case
            break;
        }
        case kCFURLTimeoutError:
        {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil message:@"网页加载超时" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alert show];
            break;
        }
        default:
        {
            NSLog(@"fail error: %@",error);
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil message:[error localizedDescription] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alert show];
            break;
        }
    }
    
    if (web.loadingCount == 0) {
        [web stopLoadingProgress];
        NSIndexPath *indexPath = [self indexPathForWebview:webView];
        if ([indexPath isEqual:[self.browserTabView indexPathForSelectedTab]]) {
            [self updateReloadWithWebview:web];
        }
    }
    
    [self updateNetworkActive];
}

#pragma mark -
#pragma mark - RCWebViewDelegate

-(void)openlink:(NSURL *)link
{
    [self loadUrlforCurrentTab:link];
}

-(void)openlinkAtNewTab:(NSURL *)link
{
    [self addNewTab];
    [self loadUrlforCurrentTab:link];
}

-(void)openlinkAtBackground:(NSURL *)link
{
    [self addNewBackgroundTab];
    RCWebView* web = [self.listWebViews lastObject];
    if (!link.scheme.length) {
        link = [NSURL URLWithString:[@"http://" stringByAppendingString:link.absoluteString]];
    }
    [web loadRequest:[NSURLRequest requestWithURL:link]];
    web.isWebPage = YES;
}
//#pragma mark -
//#pragma mark Updating loading state && RCTabDelegate
//-(void)updateLoadingState
//{
////    RCTab* tab = [self currentTab];
////    [self.reloadStopButton setHidden:!tab.webView.isWebPage];
////    [self.reloadStopButton setSelected:tab.webView.isLoading];
//}
//
//-(void)RCTab:(RCTab *)tab LoadingProgressChanged:(CGFloat)progress
//{
////    NSIndexPath *indexPath = [self.tabsView indexPathForView:tab];
////    if ([indexPath isEqual:self.tabsView.selectedIndexPath]) {
//    if (tab == [self currentTab]) {
//        if (tab.webView.isWebPage) {
//            [self updateBackForwardButtonWithTab:tab];
//            self.DashBoardUrlField.loadingProgress = [NSNumber numberWithFloat:progress];
//        }
//        return;
//    }
//}
//
//
//-(void)RCTab:(RCTab *)tab StartLoadingWebView:(RCWebView *)webView WithRequest:(NSURLRequest *)request
//{
//    if (webView == [self currentTab].webView && tab.webView.isWebPage) {
//        [self updateLoadingState];
//        [self updateBackForwardButtonWithTab:tab];
//        self.DashBoardUrlField.text = request.mainDocumentURL.absoluteString;//request.URL.absoluteString;
//
//    }
//    
//    [self updateNetworkActive];
//}
//
//-(void)RCTab:(RCTab *)tab FinishLoadingWebView:(RCWebView *)webView
//{
//    [webView stringByEvaluatingJavaScriptFromString: self.JSToolCode];    
//    [webView stringByEvaluatingJavaScriptFromString:@"MyIPhoneApp_ModifyLinkTargets()"];
//
////    NSIndexPath *indexPath = [self.browserTabView indexPathForTab:tab];
//    
////    if (indexPath) {
////        [self.listContent replaceObjectAtIndex:indexPath.row withObject:tab.titleLabel.text];
////    }
//    
//    if (webView == [self currentTab].webView && tab.webView.isWebPage) {
//        [self updateBackForwardButtonWithTab:tab];
//        
//        self.DashBoardUrlField.text = webView.request.URL.absoluteString;
//        [self updateLoadingState];
//    }
//    
//    [self updateNetworkActive];
//    
//}
//
//
//
//-(void)RCTab:(RCTab *)tab DidStartLoadingWebView:(RCWebView *)webView
//{
//    [webView stringByEvaluatingJavaScriptFromString: self.JSToolCode];
//
//    if (webView == [self currentTab].webView && tab.webView.isWebPage) {
//        [self updateLoadingState];
//    }
//    
//    [self updateNetworkActive];
//}
//
//-(void)RCTab:(RCTab *)tab DidFailLoadingWebView:(RCWebView *)webView WithErrorCode:(NSError *)error
//{
//    NSLog(@"fail");
//    switch ([error code]) {
//        case kCFURLErrorCancelled :
//        {
//            // Do nothing in this case
//            break;
//        }
//        default:
//        {
//            NSLog(@"fail error: %@",error);
//            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil message:[error localizedDescription] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
//            [alert show];
//            break;
//        }
//    }
//    if (webView == [self currentTab].webView && tab.webView.isWebPage) {
//        [self updateLoadingState];
//    }
//    [self updateNetworkActive];
//
//
//}

//-(void)RCTab:(RCTab *)tab OpenLink:(NSURL *)link
//{
//    [self loadUrlforCurrentTab:link];
//}
//-(void)RCTab:(RCTab *)tab OpenLinkAtNewTab:(NSURL *)link
//{
//    [self addNewTab];
//    [self loadUrlforCurrentTab:link];
//
////    [self loadUrlforCurrentTab:link];
//}
//-(void)RCTab:(RCTab *)tab OpenLinkAtBackground:(NSURL *)link
//{
//    [self addNewBackgroundTab];
//    RCTab *lastTab = (RCTab *)[self.browserTabView tabAtIndexPath:[NSIndexPath indexPathForRow:self.listWebViews.count-1 inSection:0]];
//
//    [self loadUrl:link ForTab:lastTab];
//}


#pragma mark -
#pragma mark TLTabsViewDataSource

-(UIView *)viewForFooterInTabsView:(TLTabsView *)tabsView
{
    UIButton* addNew = [UIButton buttonWithType:UIButtonTypeCustom];
    addNew.frame = CGRectMake(0, 0, 60, 36);
    [addNew setBackgroundImage:[UIImage imageNamed:@"tab_add_BG"] forState:UIControlStateNormal];
    [addNew setBackgroundImage:[UIImage imageNamed:@"tab_add_BG"] forState:UIControlStateHighlighted];
    [addNew setImage:[UIImage imageNamed:@"tab_add_normal"] forState:UIControlStateNormal];
    [addNew setImage:[UIImage imageNamed:@"tab_add_hite"] forState:UIControlStateHighlighted];
    [addNew addTarget:self action:@selector(handleAddNewTab:) forControlEvents:UIControlEventTouchUpInside];
    self.addNew = addNew;
    
    return addNew;
}

-(CGFloat)widthForFooterInTabsView:(TLTabsView *)tabsView
{
    return 60;
}

-(NSInteger)numberOfTabInTabsView:(TLTabsView *)tabsView
{
    return self.listWebViews.count;
}
-(CGFloat)tabsView:(TLTabsView *)tabsView widthForTabAtIndexPath:(NSIndexPath *)indexPath
{
    return 201;
}
-(UIView *)tabsView:(TLTabsView *)tabsView createTabForViewAtIndexPath:(NSIndexPath *)indexPath
{
    RCTab *tab = [[RCTab alloc]init];
    tab.delegate = self;
    tab.backgroundView.image = [UIImage imageNamed:@"tabBG_normal"];
    tab.selectedBackgroundView.image = [UIImage imageNamed:@"tabBG_hite"];
    return tab;
}

-(void)tabsView:(TLTabsView *)tabsView willDisplayTab:(UIView *)view atIndexPath:(NSIndexPath *)indexPath
{
    RCTab *tab = (RCTab*)view;
    if ([[tabsView indexPathForSelectedTab] isEqual: indexPath]) {
//        [tab setSelected:YES];
        [tabsView.tableView bringSubviewToFront:tab.superview];
        [tabsView.tableView bringSubviewToFront:self.addNew.superview];
    }else{
//        [tab setSelected:NO];
    }
}

-(void)tabsView:(TLTabsView *)tabsView configureTab:(UIView *)view forViewAtIndexPath:(NSIndexPath *)indexPath
{
#ifdef PerformanceDebug
    RCTab *tab = (RCTab*)view;
    if ([[tabsView indexPathForSelectedTab] isEqual: indexPath]) {
        [tab setSelected:YES];
//        [tabsView.tableView bringSubviewToFront:tab.superview];
//        [tabsView.tableView bringSubviewToFront:self.addNew.superview];
    }else{
        [tab setSelected:NO];
    }
    RCWebView* webview = [self.listWebViews objectAtIndex:indexPath.row];
    if (webview.isWebPage) {
        tab.titleLabel.text = [webview title];
        NSURL *url = [[NSURL alloc] initWithScheme:[webview.request.URL scheme] host:[webview.request.URL host] path:@"/favicon.ico"];
        [tab.favIcon setImageURL:url];
    }else{
        tab.titleLabel.text = TITLE_FOR_NEWTAB;
        [tab.favIcon setImageURL:nil];
    }
#else
    RCTab *tab = (RCTab*)view;
    
    if ([[tabsView indexPathForSelectedTab] isEqual: indexPath]) {
        [tab setSelected:YES];
    }else{
        [tab setSelected:NO];
    }
    
    tab.webView = [self.listWebViews objectAtIndex:indexPath.row];
    tab.webView.delegate = tab;
    if (tab.webView.isWebPage) {
        tab.titleLabel.text = [tab.webView title];
        NSURL *url = [[NSURL alloc] initWithScheme:[tab.webView.request.URL scheme] host:[tab.webView.request.URL host] path:@"/favicon.ico"];
        [tab.favIcon setImageURL:url];
    }else{
        tab.titleLabel.text = TITLE_FOR_NEWTAB;
        [tab.favIcon setImageURL:nil];
    }
#endif
}


-(void)tabsView:(TLTabsView *)tabsView didSelectTabAtIndexPath:(NSIndexPath *)indexPath
{
#ifdef PerformanceDebug
    [tabsView.tableView scrollToNearestSelectedRowAtScrollPosition:UITableViewScrollPositionNone animated:YES];
    
    RCTab *tab = (RCTab *)[tabsView tabAtIndexPath:indexPath];
    [tab setSelected:YES];
    
    [tabsView.tableView bringSubviewToFront:tab.superview];
    [tabsView.tableView bringSubviewToFront:self.addNew.superview];
    
    RCWebView* web = [self.listWebViews objectAtIndex:indexPath.row];
    if (web.isWebPage) {
        [self.homePage removeFromSuperview];
        web.frame = self.browserView.bounds;
        
        [self.browserView performSelector:@selector(addSubview:) withObject:web afterDelay:0];
        
        if (web.request.URL.absoluteString.length) {
            self.DashBoardUrlField.text = web.request.URL.absoluteString;
        }else{
            self.DashBoardUrlField.text = web.currentURL;
        }
        self.DashBoardUrlField.loadingProgress = [NSNumber numberWithFloat:web.loadingProgress];
        if (web.suspend) {
            [web reload];
            web.suspend = NO;
        }
        
    }else{
//        [self handleHomeButtonPress:nil];
        [self restoreHomePage];
    }
    [self updateReloadWithWebview:web];
    [self updateBackForwardButtonWithWebview:web];
#else
    RCTab *tab = (RCTab *)[tabsView tabAtIndexPath:indexPath];
    
    [tab setSelected:YES];
    
    [tabsView.tableView bringSubviewToFront:tab.superview];
    [tabsView.tableView bringSubviewToFront:self.addNew.superview];
    
    if (tab.webView.isWebPage) {
        [self.homePage removeFromSuperview];
        [self.browserView addSubview:tab.webView];
        tab.webView.frame = self.browserView.bounds;
    }else{
        [self restoreHomePage];
    }
    
    
    RCUrlField *urlInput = self.DashBoardUrlField;
    if (tab.webView.isWebPage) {
        urlInput.text = [tab.webView url].absoluteString;// tab.webView.request.URL.absoluteString;
        if (tab.loadingProgress <=0 || tab.loadingProgress>=1) {
            urlInput.loadingProgress = 0;
        }
    }else{
        urlInput.text = nil;
        urlInput.loadingProgress = 0;
    }
    
    [self updateBackForwardButtonWithTab:tab];
    [self updateLoadingState];
    [tabsView scrollToTabAtIndexPath:indexPath];
#endif
}

-(void)tabsView:(TLTabsView *)tabsView didDeselectTabAtIndexPath:(NSIndexPath *)indexPath
{
#ifdef PerformanceDebug
    RCTab *tab = (RCTab *)[tabsView tabAtIndexPath:indexPath];
    [tab setSelected:NO];
    
    RCWebView *web = [self.listWebViews objectAtIndex:indexPath.row];
//    [web performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:0];
    [web removeFromSuperview];
//    [web removeObserver:self forKeyPath:@"loadingProgress"];
#else
    RCTab *tab = (RCTab *)[tabsView tabAtIndexPath:indexPath];
    [tab setSelected:NO];
    [tab.webView removeFromSuperview];
#endif

}



//#pragma mark -
//#pragma mark EasyTableViewDelegate
//
//// These delegate methods support both example views - first delegate method creates the necessary views
//
//- (UIView*)easyTableView:(EasyTableView*)easyTableView viewForFooterInSection:(NSInteger)section;
//{
////    UIView *backgound = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 79, 28)];
////    backgound.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"tab_add_BG"]];
////    backgound.transform = CGAffineTransformMakeRotation(M_PI);
//    
//    UIButton* addNew = [UIButton buttonWithType:UIButtonTypeCustom];
//    addNew.frame = CGRectMake(0, 0, 60, 36);
//    [addNew setBackgroundImage:[UIImage imageNamed:@"tab_add_BG"] forState:UIControlStateNormal];
//    [addNew setBackgroundImage:[UIImage imageNamed:@"tab_add_BG"] forState:UIControlStateHighlighted];
//
////    addNew.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"tab_add_BG"]];
//    [addNew setImage:[UIImage imageNamed:@"tab_add_normal"] forState:UIControlStateNormal];
//    [addNew setImage:[UIImage imageNamed:@"tab_add_hite"] forState:UIControlStateHighlighted];
//    [addNew addTarget:self action:@selector(handleAddNewTab:) forControlEvents:UIControlEventTouchUpInside];
//    self.addNew = addNew;
////    [backgound addSubview:addNew];
//    
//    return addNew;
//}
//
//
//-(NSUInteger)numberOfCellsForEasyTableView:(EasyTableView *)view inSection:(NSInteger)section
//{
//    return self.listWebViews.count;
//}
//
//
//- (UIView *)easyTableView:(EasyTableView *)easyTableView viewForRect:(CGRect)rect {
//    RCTab *tab = [[RCTab alloc]init];
//    tab.delegate = self;
//    tab.backgroundView.image = [UIImage imageNamed:@"tabBG_normal"];
//    tab.selectedBackgroundView.image = [UIImage imageNamed:@"tabBG_hite"];
//    return tab;
//}
//
//// Second delegate populates the views with data from a data source
//- (void)easyTableView:(EasyTableView *)easyTableView setDataForView:(UIView *)view forIndexPath:(NSIndexPath *)indexPath {
//    RCTab *tab = (RCTab *)view;
//    if ([easyTableView.selectedIndexPath isEqual: indexPath]) {
//        [tab setSelected:YES];
//    }else{
//        [tab setSelected:NO];
//    }
//    
//    tab.webView = [self.listWebViews objectAtIndex:indexPath.row];
////    tab.webView.longPressDelegate = tab;
////    tab.webView.delegate = tab;
//    if (tab.webView.isWebPage) {
//        tab.titleLabel.text = [tab.webView title];
//        NSURL *url = [[NSURL alloc] initWithScheme:[tab.webView.request.URL scheme] host:[tab.webView.request.URL host] path:@"/favicon.ico"];
//        [tab.favIcon setImageURL:url];
//    }else{
//        tab.titleLabel.text = [self.listContent objectAtIndex:indexPath.row];
//        [tab.favIcon setImageURL:nil];
//    }
//}
//
//// Optional delegate to track the selection of a particular cell
//- (void)easyTableView:(EasyTableView *)easyTableView selectedView:(UIView *)selectedView atIndexPath:(NSIndexPath *)newIndex deselectedView:(UIView *)deselectedView AtIndexPath:(NSIndexPath *)oldIndex{
//    [self homePageQuitEditingIfNeeded];
//    
//    RCTab *dsbackgroundView = (RCTab *)deselectedView;
//    [dsbackgroundView setSelected:NO];
//    
//    RCTab *sbackgroundView = (RCTab *)selectedView;
//    [sbackgroundView setSelected:YES];
//
// 
//    [easyTableView.tableView bringSubviewToFront:[easyTableView.tableView cellForRowAtIndexPath:newIndex]];
//    [easyTableView.tableView bringSubviewToFront:easyTableView.sectionFooter];
//    
//    
//    [dsbackgroundView.webView removeFromSuperview];
//    
//    if (sbackgroundView.webView.isWebPage) {
//        [self.homePage removeFromSuperview];
//        sbackgroundView.webView.autoresizingMask = RCViewAutoresizingALL;
//        [self.browserView addSubview:sbackgroundView.webView];
//        sbackgroundView.webView.frame = self.browserView.bounds;
//    }else{
//        [self restoreHomePage];
//    }
//    
//    
//    RCUrlField *urlInput = self.DashBoardUrlField;
//    if (sbackgroundView.webView.isWebPage) {
//        urlInput.text = sbackgroundView.webView.request.URL.absoluteString;
//        if (sbackgroundView.loadingProgress <=0 || sbackgroundView.loadingProgress>=1) {
//            urlInput.loadingProgress = 0;
//        }
//    }else{
//        urlInput.text = nil;
//        urlInput.loadingProgress = 0;
//    }
//    
//    [self updateBackForwardButtonWithTab:sbackgroundView];
//    
//    [easyTableView.tableView scrollToRowAtIndexPath:newIndex atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
//}
//
//
//-(void)easyTableView:(EasyTableView *)easyTableView WillDisplayCell:(UITableViewCell *)cell AtIndex:(NSIndexPath *)indexPath
//{
//    RCTab *tab = (RCTab *)[cell viewWithTag:CELL_CONTENT_TAG];
//    tab.clipsToBounds = NO;
//    
//    if (self.listWebViews.count <=1 && indexPath.row == 0) {
//        [tab setDisableClose:YES];
//    }
//
//    if ([indexPath isEqual:easyTableView.selectedIndexPath]) {
//        [easyTableView.tableView bringSubviewToFront:cell];
//    }
//}


#pragma mark -
#pragma mark DashBoard Section


-(void)updateSearchEngine
{
    UIButton * searchEngineButton = (UIButton *)self.DashBoardSearchField.leftView;
    NSNumber *searchEngine = [[NSUserDefaults standardUserDefaults] objectForKey:@"searchEngine"];
    if (!searchEngine) {
        searchEngine = [NSNumber numberWithInt:0];
        [[NSUserDefaults standardUserDefaults] setObject:searchEngine forKey:@"searchEngine"];
    }
//    NSString *imgName = [NSString stringWithFormat:@"%@_full",searchEngine];
    [searchEngineButton setBackgroundImage:[RCSearchEngineSwitchViewController imageForSEtype:searchEngine.intValue isFull:YES] forState:UIControlStateNormal];
    if (self.searchEnginePopover) {
        [self.searchEnginePopover dismissPopoverAnimated:YES];
        self.searchEnginePopover = nil;
    }
}

-(void)reloadOrStop:(UIButton*)sender;
{
    [self homePageQuitEditingIfNeeded];
    
    RCWebView* web = [self currentWeb];
    if (web.isWebPage) {
        if (web.loadingCount >0) {
            [web stopLoading];
            [web stopLoadingProgress];
        }else{
            if (web.request.URL) {
                [web reload];
            }else{
                [self loadUrlforCurrentTab:[NSURL URLWithString:self.DashBoardUrlField.text]];
            }
        }
    }
}


-(void)handleSearchEngineButtonPress:(UIButton*)sender
{
    [self homePageQuitEditingIfNeeded];

    if (self.searchEnginePopover) {
        [self clearAllPopovers];
        return;
    }else{
//        [self clearAllPopovers];
//        [self.DashBoardUrlField resignFirstResponder];
//        [self.DashBoardSearchField resignFirstResponder];
        
        RCSearchEngineSwitchViewController *searchEngineSwitchViewController = [[RCSearchEngineSwitchViewController alloc] initWithStyle:UITableViewStylePlain];
        searchEngineSwitchViewController.engineDelegate = self;
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:searchEngineSwitchViewController];
        UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:nav];
        self.searchEnginePopover = popover;
        popover.delegate = self;
        [popover presentPopoverFromRect:sender.frame inView:self.DashBoardSearchField permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    }
    
}




- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    if (popoverController == self.urlInputPopover) {
        [self.DashBoardUrlField resignFirstResponder];
        self.urlInputPopover = nil;
    }else if (popoverController == self.searchInputPopover) {
        [self.DashBoardSearchField resignFirstResponder];
        [self searchFieldActive:NO];
        self.searchInputPopover = nil;
    }else if (popoverController == self.searchEnginePopover)
    {
        self.searchEnginePopover = nil;
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSURL *url = nil;
    if (textField == self.DashBoardUrlField) {
        url = [NSURL URLWithString:textField.text];
        [self loadUrlforCurrentTab:url];
    }else if (textField == self.DashBoardSearchField){
        NSString* searchWords = textField.text;
        NSNumber *searchEngine = [[NSUserDefaults standardUserDefaults] objectForKey:@"searchEngine"];
        [self loadSearchResult:[RCSearchEngineSwitchViewController searchUrlForSEtype:searchEngine.intValue keyWord:searchWords] keyWord:searchWords];
    }
    
    [textField resignFirstResponder];
    [self clearAllPopovers];
    return YES;
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [self homePageQuitEditingIfNeeded];

//    CGRect rect = textField.frame;
//    rect.size.width = 600;
//    textField.frame = rect;
//    return YES;
    
    [self clearAllPopovers];
    RCWebView* webView = [self currentWeb];
    if (webView.isLoading) {
        [webView stopLoading];
    }
    if (textField == self.DashBoardUrlField) {
        
        RCUrlInputViewController *urlInputViewController = [[RCUrlInputViewController alloc] initWithStyle:UITableViewStylePlain];
        urlInputViewController.delegate = self;
        UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:urlInputViewController];
        popover.delegate =self;
        CGSize size = popover.popoverContentSize;
        size.width = textField.frame.size.width;
        popover.popoverContentSize = size;
        popover.passthroughViews = @[textField];
        [popover presentPopoverFromRect:textField.frame inView:self.DashBoard permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
        [urlInputViewController loadURLSuggestionWithText:textField.text];
        self.urlInputPopover = popover;
        
        return YES;
    }else if (textField == self.DashBoardSearchField){

        RCSearchInputViewController *searchInputViewController = [[RCSearchInputViewController alloc] initWithStyle:UITableViewStylePlain];
        searchInputViewController.searchDelegate = self;
        UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:searchInputViewController];
        popover.delegate =self;
        popover.passthroughViews = @[textField];
        [searchInputViewController loadSearchSuggestionWithText:textField.text];
        self.searchInputPopover = popover;
        [self searchFieldActive:YES];
        [popover presentPopoverFromRect:textField.frame inView:self.DashBoard permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];

        return YES;
    }
    
    return NO;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (textField == self.DashBoardUrlField) {
        RCUrlInputViewController *VC = (RCUrlInputViewController *)self.urlInputPopover.contentViewController;
        [VC loadURLSuggestionWithText:newString];
    }else if (textField == self.DashBoardSearchField){
        RCSearchInputViewController *VC = (RCSearchInputViewController *)self.searchInputPopover.contentViewController;
        [VC loadSearchSuggestionWithText:newString];
    }
    return YES;
}



-(IBAction)handleKeyBoardAccessoryInput:(UIButton *)sender {
    UITextField *urlInput = self.DashBoardUrlField;
    RCUrlInputViewController *VC = (RCUrlInputViewController *)self.urlInputPopover.contentViewController;
    
    // Get a reference to the system pasteboard
    UIPasteboard* lPasteBoard = [UIPasteboard generalPasteboard];
    
    // Save the current pasteboard contents so we can restore them later
    NSArray* lPasteBoardItems = [lPasteBoard.items copy];
    
    // Update the system pasteboard with my string
    lPasteBoard.string = sender.titleLabel.text;
    
//    // Paste the pasteboard contents at current cursor location
    [urlInput paste:self];
//    [urlInput paste:sender.titleLabel.text];
    
    // Restore original pasteboard contents
    lPasteBoard.items = lPasteBoardItems;

    
    
//    if ([sender.titleLabel.text isEqualToString:@"www."] ||
//        [sender.titleLabel.text isEqualToString:@"hd."]) {
////        urlInput.text = [sender.titleLabel.text stringByAppendingString:urlInput.text];
//    }else if ([sender.titleLabel.text isEqualToString:@".com"]||
//              [sender.titleLabel.text isEqualToString:@".cn"]||
//              [sender.titleLabel.text isEqualToString:@".net"]){
//        urlInput.text = [urlInput.text stringByAppendingString:sender.titleLabel.text];
//    }else if ([sender.titleLabel.text isEqualToString:@"清空"]){
//        urlInput.text = nil;
//    }
    [VC loadURLSuggestionWithText:urlInput.text];
    
    
    

}



- (IBAction)handleBackButtonPress:(UIButton *)sender {
    [self homePageQuitEditingIfNeeded];
#ifdef PerformanceDebug
    RCWebView *webView = [self currentWeb];
    if ([webView canGoBack]) {
        [webView goBack];
    }else{
        [self handleHomeButtonPress:nil];
    }
#else
    RCTab *tab = [self currentTab];
    //    UITextField *urlInput = (UITextField *)self.dashBoardURLInput.customView;
    if ([tab.webView canGoBack]) {
        [tab.webView goBack];
    }else{
        [self handleHomeButtonPress:nil];
    }
#endif
}


- (IBAction)handleForwardButtonPress:(UIButton *)sender {
    [self homePageQuitEditingIfNeeded];
#ifdef PerformanceDebug
    RCWebView *webView = [self currentWeb];
    if (webView.isWebPage) {
        [webView goForward];
    }else{
        [self.homePage removeFromSuperview];
        [self.browserView addSubview:webView];
        webView.frame = self.browserView.bounds;
        webView.isWebPage = YES;
        [webView reload];
        
    }
#else
    RCTab *tab = [self currentTab];
    if (tab.webView.isWebPage) {
        [tab.webView goForward];
    }else{
        [self.homePage removeFromSuperview];
        [self.browserView addSubview:tab.webView];
        tab.webView.frame = self.browserView.bounds;
        tab.webView.isWebPage = YES;
        
        NSString* title = [tab.webView title];
//        [self.listContent replaceObjectAtIndex:[self.browserTabView indexPathForSelectedTab].row withObject:title];
        tab.titleLabel.text = title;
        
        self.DashBoardUrlField.text = tab.webView.request.URL.absoluteString;
        NSURL *url = [[NSURL alloc] initWithScheme:[tab.webView.request.URL scheme] host:[tab.webView.request.URL host] path:@"/favicon.ico"];
        [tab.favIcon setImageURL:url];
        [self updateBackForwardButtonWithTab:tab];
    }
#endif
}

- (IBAction)handleHomeButtonPress:(UIButton *)sender {

    for (UIView *view in self.browserView.subviews) {
        if ([view isKindOfClass:[RCBookmarkView class]]) {
            [view removeFromSuperview];
            return;
        }
    }
    
    if (self.homePage.superview) {
        [self.homePage scroll];
        return;
    }
    
    [self homePageQuitEditingIfNeeded];
#ifdef PerformanceDebug
    RCTab *tab = [self currentTab];
    RCWebView *webView = [self currentWeb];
    if (webView.isWebPage) {
        webView.isWebPage = NO;
        [webView stopLoading];
    }
    tab.titleLabel.text = TITLE_FOR_NEWTAB;
    [tab.favIcon setImageURL:nil];
    [self restoreHomePage];
    [self updateBackForwardButtonWithWebview:webView];
    [self updateNetworkActive];
    [self updateTabClosable];
#else
    RCTab *tab = [self currentTab];
    if (tab.webView.isWebPage) {
        [tab.webView removeFromSuperview];
        tab.webView.isWebPage = NO;
        if (tab.webView.isLoading) {
            [tab.webView stopLoading];
        }
    }
//    [self.listContent replaceObjectAtIndex:[self.browserTabView indexPathForSelectedTab].row withObject:TITLE_FOR_NEWTAB];
    tab.titleLabel.text = TITLE_FOR_NEWTAB;
    [tab.favIcon setImageURL:nil];
    
    [self restoreHomePage];
    [self updateBackForwardButtonWithTab:tab];
    [self updateNetworkActive];
#endif
}

- (IBAction)handleFavButtonPress:(UIButton *)sender {
    [self homePageQuitEditingIfNeeded];


    if (self.bookMarkActionSheet) {
        [self clearAllPopovers];
        self.bookMarkActionSheet = nil;
        return;
    }
    [self clearAllPopovers];
    
    UIActionSheet *FavButtonActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    if (!self.homePage.superview) {
        
        [FavButtonActionSheet addButtonWithTitle:@"添加到收藏夹"];
    }
    [FavButtonActionSheet addButtonWithTitle:@"打开收藏夹/历史"];
    [FavButtonActionSheet showFromRect:self.DashBoardFav.frame inView:self.DashBoard animated:YES];
    
    self.bookMarkActionSheet = FavButtonActionSheet;
}


-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex<0) {
        return;
    }
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"添加到收藏夹"]) {
        RCBookmarkPopoverViewController* bookmarkAdd = [[RCBookmarkPopoverViewController alloc] initWithNibName:@"RCBookmarkPopoverViewController" bundle:nil];
        UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:bookmarkAdd];
        self.bookmarkPopover = [[UIPopoverController alloc] initWithContentViewController:nav];
        [self.bookmarkPopover presentPopoverFromRect:self.DashBoardFav.frame inView:self.DashBoard permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
        bookmarkAdd.popover = self.bookmarkPopover;
        
        bookmarkAdd.bookmarkTitle.text = [[self currentWeb] title];
        bookmarkAdd.bookmarkUrl.text = [[self currentWeb] url].absoluteString;
    }else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"打开收藏夹/历史"]){
        RCBookmarkView *bookmarkView = [[RCBookmarkView alloc] init];
        bookmarkView.frame = self.browserView.bounds;
        bookmarkView.rootVC = self;
        [self.browserView addSubview:bookmarkView];
        RCWebView* webView = [self currentWeb];
        if (webView.isLoading) {
            [webView stopLoading];
        }
    
    }
}

-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    self.bookMarkActionSheet = nil;
}



- (IBAction)handleSettingButtonPress:(UIButton*)sender {
    [self homePageQuitEditingIfNeeded];
    
    
    RCPopoverMenu* popMenu = [[RCPopoverMenu alloc] initWithFrame:CGRectMake(0, 0, 287, 313)];
    popMenu.delegate = self;
    self.menuPopover = [PopoverView showPopoverAtPoint:CGPointMake(sender.center.x+5, CGRectGetMaxY(sender.frame)-30) inView:self.DashBoard withContentView:popMenu delegate:self];
}
- (void)popoverViewDidDismiss:(PopoverView *)popoverView;
{
    if (popoverView == self.menuPopover) {
        self.menuPopover = nil;
    }
}

-(void)SettingShouldShow
{
    [self.menuPopover dismiss];
    RCSettingViewController *settingViewController = [[RCSettingViewController alloc] initWithStyle:UITableViewStyleGrouped];
    settingViewController.mainVC = self;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:settingViewController];
    nav.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentModalViewController:nav animated:YES];
}


/////////////SHOTCUT////////////////////////
-(void)ShortcutShouldShow:(BOOL)show
{
    if (show) {
        CGRect buttonFrame = CGRectMake(0, 0, 55.0f, 55.0f);

        UIButton* pageUp = [UIButton buttonWithType:UIButtonTypeCustom];
        pageUp.frame = buttonFrame;
        [pageUp setImage:[UIImage imageNamed:@"shortcut_pageup_normal"] forState:UIControlStateNormal];
        [pageUp setImage:[UIImage imageNamed:@"shortcut_pageup_disable"] forState:UIControlStateDisabled];
        [pageUp setImage:[UIImage imageNamed:@"shortcut_pageup_hite"] forState:UIControlStateHighlighted];
        [pageUp addTarget:self action:@selector(handlePageUp:) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton* pageDown = [UIButton buttonWithType:UIButtonTypeCustom];
        pageDown.frame = buttonFrame;
        [pageDown setImage:[UIImage imageNamed:@"shortcut_pagedown_normal"] forState:UIControlStateNormal];
        [pageDown setImage:[UIImage imageNamed:@"shortcut_pagedown_disable"] forState:UIControlStateDisabled];
        [pageDown setImage:[UIImage imageNamed:@"shortcut_pagedown_hite"] forState:UIControlStateHighlighted];
        [pageDown addTarget:self action:@selector(handlePageDown:) forControlEvents:UIControlEventTouchUpInside];

        UIButton* back = [UIButton buttonWithType:UIButtonTypeCustom];
        back.frame = buttonFrame;
        [back setImage:[UIImage imageNamed:@"shortcut_back_normal"] forState:UIControlStateNormal];
        [back setImage:[UIImage imageNamed:@"shortcut_back_disable"] forState:UIControlStateDisabled];
        [back setImage:[UIImage imageNamed:@"shortcut_back_hite"] forState:UIControlStateHighlighted];
        [back addTarget:self action:@selector(handleBackButtonPress:) forControlEvents:UIControlEventTouchUpInside];

        UIButton* close = [UIButton buttonWithType:UIButtonTypeCustom];
        close.frame = buttonFrame;
        [close setImage:[UIImage imageNamed:@"shortcut_close_normal"] forState:UIControlStateNormal];
        [close setImage:[UIImage imageNamed:@"shortcut_close_disable"] forState:UIControlStateDisabled];
        [close setImage:[UIImage imageNamed:@"shortcut_close_hite"] forState:UIControlStateHighlighted];
        [close addTarget:self action:@selector(handleCloseTab:) forControlEvents:UIControlEventTouchUpInside];

        UIButton* fullScreen = [UIButton buttonWithType:UIButtonTypeCustom];
        fullScreen.frame = buttonFrame;
        [fullScreen setImage:[UIImage imageNamed:@"shortcut_fullscreen_normal"] forState:UIControlStateNormal];
        [fullScreen setImage:[UIImage imageNamed:@"shortcut_fullscreen_disable"] forState:UIControlStateDisabled];
        [fullScreen setImage:[UIImage imageNamed:@"shortcut_fullscreen_hite"] forState:UIControlStateHighlighted];
        [fullScreen setImage:[UIImage imageNamed:@"shortcut_fullscreen_hite"] forState:UIControlStateSelected];
        [fullScreen addTarget:self action:@selector(handleFullScreen:) forControlEvents:UIControlEventTouchUpInside];

        NSArray *buttons = [NSArray arrayWithObjects:pageUp, pageDown, back, close, fullScreen,nil];
        
        RNExpandingButtonBar* shortcut = [[RNExpandingButtonBar alloc] initWithImage:[UIImage imageNamed:@"shortcut_unexpand"] selectedImage:[UIImage imageNamed:@"shortcut_expand"] toggledImage:[UIImage imageNamed:@"shortcut_expand"] toggledSelectedImage:[UIImage imageNamed:@"shortcut_expand"] buttons:buttons center:CGPointMake(self.view.bounds.size.width-40, self.view.bounds.size.height-40)];
        shortcut.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin;
        [shortcut setAnimationTime:.3f];
        [shortcut setPadding:1];
        [shortcut setDelay:0.01];
        self.shortcutButton = shortcut;
        [shortcut showButtonsAnimated:YES];
        if (self.menuPopover) {
            [self.view insertSubview:self.shortcutButton belowSubview:self.menuPopover];
        }else{
            [self.view addSubview:self.shortcutButton];
        }

        [self updateTabClosable];
        [self updateBackForwardButtonWithWebview:[self currentWeb]];
    }else{
        [self.shortcutButton removeFromSuperview];
        self.shortcutButton = nil;
    }
}

-(void)handlePageUp:(UIButton*)sender{
    RCWebView* web = [self currentWeb];
    if (web.isWebPage) {
        [[web webScrollView] setContentOffset:CGPointMake([web webScrollView].contentOffset.x, MAX(0, [web webScrollView].contentOffset.y-web.bounds.size.height*0.9)) animated:YES];
    }else{
        if (self.homePage.navPage.superview) {
            UIScrollView* scroll = self.homePage.navPage.gridView.scrollView;
            [scroll setContentOffset:CGPointMake(scroll.contentOffset.x, MAX(0, scroll.contentOffset.y-scroll.bounds.size.height*0.9)) animated:YES];
        }
    }
}

-(void)handlePageDown:(UIButton*)sender{
    RCWebView* web = [self currentWeb];
    if (web.isWebPage) {
        [[web webScrollView] setContentOffset:CGPointMake([web webScrollView].contentOffset.x, MIN([web webScrollView].contentSize.height-web.bounds.size.height, [web webScrollView].contentOffset.y+web.bounds.size.height*0.9)) animated:YES];
    }else{
        if (self.homePage.navPage.superview) {
            UIScrollView* scroll = self.homePage.navPage.gridView.scrollView;
            [scroll setContentOffset:CGPointMake(scroll.contentOffset.x, MIN(scroll.contentSize.height-scroll.bounds.size.height, scroll.contentOffset.y+scroll.bounds.size.height*0.9)) animated:YES];
        }
    }

}
-(void)handleCloseTab:(UIButton*)sender{
    [self tabNeedsToBeClosed:[self currentTab]];
}

-(void)handleFullScreen:(UIButton*)sender{
//    CGAffineTransform scale = CGAffineTransformMakeScale(2.0f, 2.0f);
////    CGAffineTransform unScale = CGAffineTransformMakeScale(1.0f, 1.0f);
//    [UIView animateWithDuration:0.3 animations:^{
//        [self.browserView setTransform:scale];
//
//    } completion:^(BOOL finished){
//        [self.browserView setTransform:CGAffineTransformIdentity];
//        if (sender.selected) {
//            self.browserView.frame = CGRectMake(0, 80, self.view.bounds.size.width, self.view.bounds.size.height-80);
//            sender.selected = NO;
//        }else{
//            self.browserView.frame = self.view.bounds;
//            sender.selected = YES;
//        }
//    }];

    if (sender.selected) {
        self.browserView.frame = CGRectMake(0, 80, self.view.bounds.size.width, self.view.bounds.size.height-80);
        [(UIView*)[self.browserView.subviews lastObject] setFrame:self.browserView.bounds];
        sender.selected = NO;
    }else{
        self.browserView.frame = self.view.bounds;
        [(UIView*)[self.browserView.subviews lastObject] setFrame:self.browserView.bounds];
        sender.selected = YES;
    }
    
//    [UIView animateWithDuration:.2
//                     animations:^{
//                        if (sender.selected) {
//                            self.browserView.transform = CGAffineTransformIdentity;
////                            self.browserView.frame = CGRectMake(0, 80, self.view.bounds.size.width, self.view.bounds.size.height-80);
////                            sender.selected = NO;
//                        }else{
//                            self.browserView.transform = CGAffineTransformMakeTranslation(0, -80);
////                            self.browserView.frame = self.view.bounds;
////                            sender.selected = YES;
//                        }
//                    }
//                     completion:^(BOOL finished) {
////                         self.browserView.transform = CGAffineTransformIdentity;
//                         if (sender.selected) {
//                             self.browserView.frame = CGRectMake(0, 80, self.view.bounds.size.width, self.view.bounds.size.height-80);
//                             sender.selected = NO;
//                         }else{
//                             self.browserView.frame = self.view.bounds;
//                             sender.selected = YES;
//                         }
//    }];
}

//////URL popovers' delegates/////
-(void)urlSuggestionSelected:(NSURL *)url
{
    [self.urlInputPopover dismissPopoverAnimated:YES];
    self.urlInputPopover = nil;
    [self.DashBoardUrlField resignFirstResponder];
    [self loadUrlforCurrentTab:url];
}

-(void)loadSearchResult:(NSURL *)url keyWord:(NSString *)key
{
    [self.searchInputPopover dismissPopoverAnimated:YES];
    self.searchInputPopover = nil;
    [self.DashBoardSearchField resignFirstResponder];
    self.DashBoardSearchField.text = key;
    [self searchFieldActive:NO];
    [self loadUrlforCurrentTab:url];
}

#pragma mark -
#pragma mark HomePage Section
-(void)restoreHomePage
{
    [self.browserView addSubview:self.homePage];
    self.homePage.frame = self.browserView.bounds;
    
    for (UIView* view in [self.browserView subviews]) {
        if ([view isKindOfClass:[RCBookmarkView class]]) {
            [view removeFromSuperview];
        }
    }
    
    
    RCWebView* web = [self currentWeb];
    [web stringByEvaluatingJavaScriptFromString:@"stopVideo()"];

    self.DashBoardUrlField.loadingProgress = [NSNumber numberWithFloat:0];
    self.DashBoardUrlField.text = nil;
//    [self updateLoadingState];
}


-(void)homePage:(RCHomePage *)homePage lunchUrl:(NSURL *)url WithOption:(RCHomePageLunchOptions)option
{
    switch (option) {
        case RCHomePageLunchNewBackgroundTab:{
            [self openlinkAtBackground:url];
//            [self RCTab:nil OpenLinkAtBackground:url];
        }
            break;
        case RCHomePageLunchNewTab:{
            [self openlinkAtNewTab:url];
//            [self RCTab:nil OpenLinkAtNewTab:url];
        }
            break;
        case RCHomePageLunchNomal:
        default:
            [self openlink:url];
//            [self loadUrlforCurrentTab:url];
            break;
    }
}

-(void)homePageNeedsAddNewNavIcons:(RCHomePage *)homePage
{
    RCConfigueNavIconsViewController *configueNavIconsViewController = [[RCConfigueNavIconsViewController alloc] init];
    configueNavIconsViewController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentModalViewController:configueNavIconsViewController animated:YES];
    CGPoint center = configueNavIconsViewController.view.superview.center;
    configueNavIconsViewController.view.superview.frame = CGRectMake(0, 0, 701, 620);//it's important to do this after presentModalViewController
    configueNavIconsViewController.view.superview.center = center;
    configueNavIconsViewController.mainVC =self;
}



@end
