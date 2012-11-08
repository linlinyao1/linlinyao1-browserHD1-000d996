//
//  RCWebView.m
//  browserHD
//
//  Created by imac on 12-8-15.
//  Copyright (c) 2012年 2345. All rights reserved.
//

#import "RCWebView.h"
#import "UnpreventableUILongPressGestureRecognizer.h"

#define ButtonTitleImageSave @"保存图片到相册"
#define ButtonTitleLinkCopy @"复制链接"
#define ButtonTitleLinkOpenNew @"新标签页打开"
#define ButtonTitleLinkOpen @"打开"
#define ButtonTitleLinkOpenBackground @"后台打开"



@interface RCWebView ()<UIActionSheetDelegate>
@property (nonatomic,strong) UIView * goBackIndicate;
@property (nonatomic,assign) NSInteger openLinkIndex;
@property (nonatomic,assign) NSInteger openLinkAtNewTabIndex;
@property (nonatomic,assign) NSInteger openLinkAtBackgroundIndex;
@property (nonatomic,assign) NSInteger copyLinkIndex;
@property (nonatomic,strong) NSURL * urlToHandle;

@property (nonatomic,strong) NSTimer* loadingTimer;
@end


@implementation RCWebView
@synthesize isWebPage = _isWebPage;
@synthesize goBackIndicate;
@synthesize openLinkIndex = _openLinkIndex;
@synthesize openLinkAtNewTabIndex = _openLinkAtNewTabIndex;
@synthesize openLinkAtBackgroundIndex = _openLinkAtBackgroundIndex;
@synthesize copyLinkIndex = _copyLinkIndex;
@synthesize urlToHandle = _urlToHandle;
@synthesize longPressDelegate = _longPressDelegate;


-(UIScrollView *)webScrollView
{
    UIScrollView* scroll = nil;
    
    if ([self respondsToSelector:@selector(scrollView)]) {
        scroll = [self scrollView];
    }else{
        for (UIView* view in [self subviews]) {
            if ([view isKindOfClass:[UIScrollView class]]) {
                scroll = (UIScrollView*)view;
                break;
            }
        }
    }
    return scroll;
}


- (CGSize)windowSize {
    CGSize size;
    size.width = [[self stringByEvaluatingJavaScriptFromString:@"window.innerWidth"] integerValue];
    size.height = [[self stringByEvaluatingJavaScriptFromString:@"window.innerHeight"] integerValue];
    return size;
}

- (CGPoint)scrollOffset {
    CGPoint pt;
    pt.x = [[self stringByEvaluatingJavaScriptFromString:@"window.pageXOffset"] integerValue];
    pt.y = [[self stringByEvaluatingJavaScriptFromString:@"window.pageYOffset"] integerValue];
    return pt;
}

- (NSURL*)url
{
    NSString *urlString = [self stringByEvaluatingJavaScriptFromString:@"location.href"];
    if (urlString) {
        return [NSURL URLWithString:urlString];
    } else {
        return nil;
    }
}

//- (NSString*)title
//{
//    return [self stringByEvaluatingJavaScriptFromString:@"document.title"];
//}

-(NSString *)updateTitle
{
    self.title = [self stringByEvaluatingJavaScriptFromString:@"document.title"];
    return self.title;
}


-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.scalesPageToFit = YES;
        
        UnpreventableUILongPressGestureRecognizer *longPressRecognizer = [[UnpreventableUILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressRecognized:)];
        longPressRecognizer.allowableMovement = 20;
        longPressRecognizer.minimumPressDuration = 1.0f;
        [self addGestureRecognizer:longPressRecognizer];
        
//        self.goBackIndicate = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 50)];
//        self.goBackIndicate.center = CGPointMake(0, self.bounds.size.height/2);
//        self.goBackIndicate.backgroundColor = [UIColor yellowColor];        
//        [self addSubview:self.goBackIndicate];
//        
//        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleGoBackPan:)];
//        [self.goBackIndicate addGestureRecognizer:pan];
    }
    return self;
}

- (void)longPressRecognized:(UILongPressGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        
        CGPoint point = [gestureRecognizer locationInView:self];
        
        // convert point from view to HTML coordinate system
        CGSize viewSize = [self frame].size;
        CGSize windowSize = [self windowSize];
        
        CGFloat f = windowSize.width / viewSize.width;
        if ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 5.) {
            point.x = point.x * f;
            point.y = point.y * f;
        } else {
            // On iOS 4 and previous, document.elementFromPoint is not taking
            // offset into account, we have to handle it
            CGPoint offset = [self scrollOffset];
            point.x = point.x * f + offset.x;
            point.y = point.y * f + offset.y;
        }
//        NSString *jsCodePath = [[NSBundle mainBundle] pathForResource:@"JSTool" ofType:@"js"];
//        NSString *jsCode = [NSString stringWithContentsOfFile:jsCodePath encoding:NSUTF8StringEncoding error:nil];
//        [self stringByEvaluatingJavaScriptFromString: jsCode];
        
        NSString *tags = [self stringByEvaluatingJavaScriptFromString:
                          [NSString stringWithFormat:@"MyAppGetHTMLElementsAtPoint(%i,%i);",(NSInteger)point.x,(NSInteger)point.y]];
        
        NSString *tagsHREF = [self stringByEvaluatingJavaScriptFromString:
                              [NSString stringWithFormat:@"MyAppGetLinkHREFAtPoint(%i,%i);",(NSInteger)point.x,(NSInteger)point.y]];
        
        NSString *tagsSRC = [self stringByEvaluatingJavaScriptFromString:
                             [NSString stringWithFormat:@"MyAppGetLinkSRCAtPoint(%i,%i);",(NSInteger)point.x,(NSInteger)point.y]];
        
        NSLog(@"tags : %@",tags);
        NSLog(@"href : %@",tagsHREF);
        NSLog(@"src : %@",tagsSRC);

        NSString *url = nil;
        if ([tags rangeOfString:@",IMG,"].location != NSNotFound) {
            url = tagsSRC;
//            if ((url != nil) && ([url length] != 0)){
//            UIActionSheet * longPressActionSheet = [[UIActionSheet alloc] initWithTitle:[url stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
//                                                                               delegate:self
//                                                                      cancelButtonTitle:nil
//                                                                 destructiveButtonTitle:nil
//                                                                      otherButtonTitles:nil];
//            longPressActionSheet.actionSheetStyle = UIActionSheetStyleDefault;
//            [longPressActionSheet addButtonWithTitle:ButtonTitleImageSave];
//            [longPressActionSheet addButtonWithTitle:ButtonTitleLinkCopy];
//            CGPoint touchPosition = [gestureRecognizer locationInView:self];
//            [longPressActionSheet showFromRect:CGRectMake(touchPosition.x, touchPosition.y, 1, 1)
//                                        inView:self
//                                      animated:YES];
//            }
//            return;
        }
        if ([tags rangeOfString:@",A,"].location != NSNotFound) {
            url = tagsHREF;

        }
        
        //        NSLog(@"url : %@",url);
        
        //        NSArray *urlArray = [[url lowercaseString] componentsSeparatedByString:@"/"];
        //        NSString *urlBase = nil;
        //        if ([urlArray count] > 2) {
        //            urlBase = [urlArray objectAtIndex:2];
        //        }
        //        NSLog(@"urlBase : %@",urlBase);
        
        if ((url != nil) && ([url length] != 0)) {
            
            self.urlToHandle = [NSURL URLWithString:url];
            if ([[self.urlToHandle scheme] isEqualToString:@"newtab"]) {
                NSString *urlString = [[self.urlToHandle resourceSpecifier] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                self.urlToHandle = [NSURL URLWithString:urlString relativeToURL:[self url]];
            }
            
            UIActionSheet * longPressActionSheet = [[UIActionSheet alloc] initWithTitle:[url stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                                                                               delegate:self
                                                                      cancelButtonTitle:nil
                                                                 destructiveButtonTitle:nil
                                                                      otherButtonTitles:nil];
            longPressActionSheet.actionSheetStyle = UIActionSheetStyleDefault;
            
            self.openLinkAtNewTabIndex = [longPressActionSheet addButtonWithTitle:ButtonTitleLinkOpenNew];
            self.openLinkIndex = [longPressActionSheet addButtonWithTitle:ButtonTitleLinkOpen];
            self.openLinkAtBackgroundIndex = [longPressActionSheet addButtonWithTitle:ButtonTitleLinkOpenBackground];
            self.copyLinkIndex = [longPressActionSheet addButtonWithTitle:ButtonTitleLinkCopy];
            
            CGPoint touchPosition = [gestureRecognizer locationInView:self];
            [longPressActionSheet showFromRect:CGRectMake(touchPosition.x, touchPosition.y, 1, 1)
                                        inView:self
                                      animated:YES];
        }

        
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

#pragma mark -
#pragma mark UIActionSheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {    
    if (buttonIndex == self.copyLinkIndex) {
        UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
        [pasteBoard setValue:self.urlToHandle.absoluteString forPasteboardType:@"public.utf8-plain-text"];
    }else if (buttonIndex == self.openLinkIndex){
        [self.longPressDelegate openlink:self.urlToHandle];
    }else if (buttonIndex == self.openLinkAtNewTabIndex){
        [self.longPressDelegate openlinkAtNewTab:self.urlToHandle];
    }else if (buttonIndex == self.openLinkAtBackgroundIndex){
        [self.longPressDelegate openlinkAtBackground:self.urlToHandle];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{

}

-(void)dealloc
{
    self.delegate = nil;
}

//-(void)handleGoBackPan:(UIPanGestureRecognizer*)gesture
//{
//    CGPoint point = [gesture translationInView:self];
//    switch (gesture.state) {
//        case UIGestureRecognizerStateChanged:
//        {
//            self.goBackIndicate.transform = CGAffineTransformMakeTranslation(point.x, 0);
//        }
//            break;
//        case UIGestureRecognizerStateEnded:
//        case UIGestureRecognizerStateCancelled:
//        case UIGestureRecognizerStateFailed:
//        {
//            self.goBackIndicate.transform = CGAffineTransformIdentity;
//        }
//            break;
//        default:
//            break;
//    }
//
//}


///////////testing//////////////
- (void) cleanForDealloc
{
    /*
     
     There are several theories and rumors about UIWebView memory leaks, and how
     to properly handle cleaning a UIWebView instance up before deallocation. This
     method implements several of those recommendations.
     
     #1: Various developers believe UIWebView may not properly throw away child
     objects & views without forcing the UIWebView to load empty content before
     dealloc.
     
     Source: http://stackoverflow.com/questions/648396/does-uiwebview-leak-memory
     
     */
    [self loadHTMLString:@"" baseURL:nil];
    
    /*
     
     #2: Others claim that UIWebView's will leak if they are loading content
     during dealloc.
     
     Source: http://stackoverflow.com/questions/6124020/uiwebview-leaking
     
     */
    [self stopLoading];
    
    /*
     
     #3: Apple recommends setting the delegate to nil before deallocation:
     "Important: Before releasing an instance of UIWebView for which you have set
     a delegate, you must first set the UIWebView delegate property to nil before
     disposing of the UIWebView instance. This can be done, for example, in the
     dealloc method where you dispose of the UIWebView."
     
     Source: UIWebViewDelegate class reference
     
     */
    self.delegate = nil;
    
    
    /*
     
     #4: If you're creating multiple child views for any given view, and you're
     trying to deallocate an old child, that child is pointed to by the parent
     view, and won't actually deallocate until that parent view dissapears. This
     call below ensures that you are not creating many child views that will hang
     around until the parent view is deallocated.
     */
    
    [self removeFromSuperview];
    
    /*
     
     Further Help with UIWebView leak problems:
     
     #1: Consider implementing the following in your UIWebViewDelegate:
     
     - (void) webViewDidFinishLoad:(UIWebView *)webView
     {
     //source: http://blog.techno-barje.fr/post/2010/10/04/UIWebView-secrets-part1-memory-leaks-on-xmlhttprequest/
     [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"WebKitCacheModelPreferenceKey"];
     }
     
     #2: If you can, avoid returning NO in your UIWebViewDelegate here:
     
     - (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
     {
     //this source says don't do this: http://stackoverflow.com/questions/6421813/lots-of-uiwebview-memory-leaks
     //return NO;
     return YES;
     }
     
     #3: Some leaks appear to be fixed in IOS 4.1
     Source: http://stackoverflow.com/questions/3857519/memory-leak-while-using-uiwebview-load-request-in-ios4-0
     
     #4: When you create your UIWebImageView, disable link detection if possible:
     
     webView.dataDetectorTypes = UIDataDetectorTypeNone;
     
     (This is also the "Detect Links" checkbox on a UIWebView in Interfacte Builder.)
     
     Sources:
     http://www.iphonedevsdk.com/forum/iphone-sdk-development/46260-how-free-memory-after-uiwebview.html
     http://www.iphonedevsdk.com/forum/iphone-sdk-development/29795-uiwebview-how-do-i-stop-detecting-links.html
     http://blog.techno-barje.fr/post/2010/10/04/UIWebView-secrets-part2-leaks-on-release/
     
     #5: Consider cleaning the NSURLCache every so often:
     
     [[NSURLCache sharedURLCache] removeAllCachedResponses];
     [[NSURLCache sharedURLCache] setDiskCapacity:0];
     [[NSURLCache sharedURLCache] setMemoryCapacity:0];
     
     Source: http://blog.techno-barje.fr/post/2010/10/04/UIWebView-secrets-part2-leaks-on-release/
     
     Be careful with this, as it may kill cache objects for currently executing URL
     requests for your application, if you can't cleanly clear the whole cache in
     your app in some place where you expect zero URLRequest to be executing, use
     the following instead after you are done with each request (note that you won't
     be able to do this w/ UIWebView's internal request objects..):
     
     [[NSURLCache sharedURLCache] removeCachedResponseForRequest:request];
     
     Source: http://stackoverflow.com/questions/6542114/clearing-a-webviews-cache-for-local-files
     
     */
}



-(void)handleLoadingTimer:(NSTimer*)sender
{
    self.loadingProgress += 0.01;
//    NSLog(@"loadingProgress: %f",self.loadingProgress);
    if (self.loadingProgress>=0.8) {
        [sender invalidate];
    }
}

-(void)startLoadingProgress
{
//    int interval = 2;
//    int leeway = 0;
//    
//    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
//    if (timer) {
//        dispatch_source_set_timer(timer, dispatch_walltime(DISPATCH_TIME_NOW, NSEC_PER_SEC * interval), interval * NSEC_PER_SEC, leeway);
//        dispatch_source_set_event_handler(timer, ^{
//            NSLog(@"timer running");
//        });
//        dispatch_resume(timer);
//    }
    if ([self.loadingTimer isValid]) {
        [self.loadingTimer invalidate];
    }
    self.loadingTimer = [NSTimer scheduledTimerWithTimeInterval:.1 target:self selector:@selector(handleLoadingTimer:) userInfo:nil repeats:YES];
}

-(void)stopLoadingProgress
{
    [self.loadingTimer invalidate];
    self.loadingTimer = nil;
    self.loadingProgress = 0;
}

@end
