// Copyright (c) 2014-present, Facebook, Inc. All rights reserved.
//
// You are hereby granted a non-exclusive, worldwide, royalty-free license to use,
// copy, modify, and distribute this software in source code or binary form for use
// in connection with the web services and APIs provided by Facebook.
//
// As with any software that integrates with the Facebook platform, your use of
// this software is subject to the Facebook Developer Principles and Policies
// [http://developers.facebook.com/policy/]. This copyright notice shall be
// included in all copies or substantial portions of the software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
// FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
// IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "FBSDKWebDialogView.h"
#import "FBSDKError.h"
#import "FBSDKTypeUtility.h"
#import "FBSDKUtility.h"

#define FBSDK_WEB_DIALOG_VIEW_BORDER_WIDTH 10.0

@interface FBSDKWebDialogView () <WebUIDelegate,WebResourceLoadDelegate>
@end

@implementation FBSDKWebDialogView
{
  NSButton *_closeButton;
  NSProgressIndicator *_loadingView;
  WebView *_webView;
}

#pragma mark - Object Lifecycle

- (instancetype)initWithFrame:(CGRect)frame
{
  if ((self = [super initWithFrame:frame])) {
//    self.backgroundColor = [UIColor clearColor];
//    self.opaque = NO;

    _webView = [[WebView alloc] initWithFrame:CGRectZero];
    _webView.UIDelegate = self;
    _webView.resourceLoadDelegate = self;
    [self addSubview:_webView];

    _closeButton = [NSButton buttonWithTitle:@"X" target:self action:@selector(close:)];
//    UIImage *closeImage = [[[FBSDKCloseIcon alloc] init] imageWithSize:CGSizeMake(29.0, 29.0)];
//    [_closeButton setImage:closeImage forState:UIControlStateNormal];
//    [_closeButton setTitleColor:[UIColor colorWithRed:167.0/255.0
//                                                green:184.0/255.0
//                                                 blue:216.0/255.0
//                                                alpha:1.0] forState:UIControlStateNormal];
//    [_closeButton setTitleColor:[NSColor whiteColor] forState:UIControlStateHighlighted];
//    _closeButton.showsTouchWhenHighlighted = YES;
    [_closeButton sizeToFit];
    [self addSubview:_closeButton];

    _loadingView = [[NSProgressIndicator alloc] init];
//    _loadingView.color = [UIColor grayColor];
    [_webView addSubview:_loadingView];
  }
  return self;
}

- (void)dealloc
{
  _webView.UIDelegate = nil;
  [super dealloc];
}

#pragma mark - Public Methods

- (void)loadURL:(NSURL *)URL
{
  [_loadingView startAnimation:nil];
  
  [_webView.mainFrame loadRequest:[NSURLRequest requestWithURL:URL]];
}

- (void)stopLoading
{
  [_webView stopLoading:nil];
}

#pragma mark - Layout

- (void)drawRect:(CGRect)rect
{
  CGContextRef context = [NSGraphicsContext currentContext].CGContext;
  CGContextSaveGState(context);
//  [self.backgroundFilters setFill];
  CGContextFillRect(context, self.bounds);
  [[NSColor blackColor] setStroke];
  CGContextSetLineWidth(context, 1.0 / self.layer.contentsScale);
  CGContextStrokeRect(context, _webView.frame);
  CGContextRestoreGState(context);
  [super drawRect:rect];
}

//- (void)layoutSubviews
//{
//  [super layoutSubtreeIfNeeded];
//
//  CGRect bounds = self.bounds;
////  if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
////    CGFloat horizontalInset = CGRectGetWidth(bounds) * 0.2;
////    CGFloat verticalInset = CGRectGetHeight(bounds) * 0.2;
////    UIEdgeInsets iPadInsets = UIEdgeInsetsMake(verticalInset, horizontalInset, verticalInset, horizontalInset);
////    bounds = UIEdgeInsetsInsetRect(bounds, iPadInsets);
////  }
//  NSEdgeInsets webViewInsets = NSEdgeInsetsMake(FBSDK_WEB_DIALOG_VIEW_BORDER_WIDTH,
//                                                FBSDK_WEB_DIALOG_VIEW_BORDER_WIDTH,
//                                                FBSDK_WEB_DIALOG_VIEW_BORDER_WIDTH,
//                                                FBSDK_WEB_DIALOG_VIEW_BORDER_WIDTH);
//  _webView.frame = CGRectIntegral(NSEdgeInsetsInsetRect(bounds, webViewInsets));
//
//  CGRect webViewBounds = _webView.bounds;
//  _loadingView.center = CGPointMake(CGRectGetMidX(webViewBounds), CGRectGetMidY(webViewBounds));
//
//  CGRect closeButtonFrame = _closeButton.bounds;
//  closeButtonFrame.origin = bounds.origin;
//  _closeButton.frame = CGRectIntegral(closeButtonFrame);
//}

#pragma mark - Actions

- (void)_close:(id)sender
{
  [_delegate webDialogViewDidCancel:self];
}

#pragma mark - UIWebViewDelegate

- (void)webView:(WebView *)sender resource:(id)identifier didFinishLoadingFromDataSource:(WebDataSource *)dataSource;
{
  [_loadingView stopAnimation:nil];
  [_delegate webDialogViewDidFinishLoad:self];
}
- (void)webView:(WebView *)sender resource:(id)identifier didFailLoadingWithError:(NSError *)error fromDataSource:(WebDataSource *)dataSource{
  [_loadingView startAnimation:nil];
  
  // 102 == WebKitErrorFrameLoadInterruptedByPolicyChange
  // NSURLErrorCancelled == "Operation could not be completed", note NSURLErrorCancelled occurs when the user clicks
  // away before the page has completely loaded, if we find cases where we want this to result in dialog failure
  // (usually this just means quick-user), then we should add something more robust here to account for differences in
  // application needs
  if (!(([error.domain isEqualToString:NSURLErrorDomain] && error.code == NSURLErrorCancelled) ||
        ([error.domain isEqualToString:@"WebKitErrorDomain"] && error.code == 102))) {
    [_delegate webDialogView:self didFailWithError:error];
  }
}



//- (BOOL)webView:(UIWebView *)webView
//shouldStartLoadWithRequest:(NSURLRequest *)request
// navigationType:(UIWebViewNavigationType)navigationType
//{
//  NSURL *URL = request.URL;
//
//  if ([URL.scheme isEqualToString:@"fbconnect"]) {
//    NSMutableDictionary *parameters = [[FBSDKUtility dictionaryWithQueryString:URL.query] mutableCopy];
//    [parameters addEntriesFromDictionary:[FBSDKUtility dictionaryWithQueryString:URL.fragment]];
//    if ([URL.resourceSpecifier hasPrefix:@"//cancel"]) {
//      NSInteger errorCode = [FBSDKTypeUtility integerValue:parameters[@"error_code"]];
//      if (errorCode) {
//        NSString *errorMessage = [FBSDKTypeUtility stringValue:parameters[@"error_msg"]];
//        NSError *error = [FBSDKError errorWithCode:errorCode message:errorMessage];
//        [_delegate webDialogView:self didFailWithError:error];
//      } else {
//        [_delegate webDialogViewDidCancel:self];
//      }
//    } else {
//      [_delegate webDialogView:self didCompleteWithResults:parameters];
//    }
//    return NO;
//  } else if (navigationType == UIWebViewNavigationTypeLinkClicked) {
//    [[UIApplication sharedApplication] openURL:request.URL];
//    return NO;
//  } else {
//    return YES;
//  }
//}

@end
