#import "ViewController.h"
#import <UIKit/UIKit.h>

/* iOS 7 uses UIWebView; WKWebView arrived in iOS 8. */
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

/* ── Change this URL to wherever index.html is hosted ── */
static NSString * const kAppURL = @"https://tiny-moon-f4a4.eeop117.workers.dev";

/* ────────────────────────────────────────────────────── */

@interface ViewController () <UIWebViewDelegate>
@property (nonatomic, strong) UIWebView  *webView;
@property (nonatomic, strong) UIView     *errorView;
@property (nonatomic, strong) UILabel    *errorLabel;
@property (nonatomic, strong) UIButton   *retryButton;
@property (nonatomic, strong) UIView     *loadingView;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;
@end

@implementation ViewController

/* ── Life-cycle ───────────────────────────────────────── */

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0.039 green:0.039 blue:0.059 alpha:1.0];
    [self buildWebView];
    [self buildLoadingView];
    [self buildErrorView];
    [self loadApp];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

/* ── Layout ───────────────────────────────────────────── */

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGRect b = self.view.bounds;
    self.webView.frame    = b;
    self.loadingView.frame = b;
    self.errorView.frame  = b;

    /* centre spinner */
    self.spinner.center = CGPointMake(b.size.width / 2.0, b.size.height / 2.0);

    /* centre error stack */
    CGFloat midX = b.size.width  / 2.0;
    CGFloat midY = b.size.height / 2.0;
    self.errorLabel.frame  = CGRectMake(20, midY - 80, b.size.width - 40, 60);
    self.retryButton.frame = CGRectMake(midX - 80, midY + 10, 160, 44);
}

/* ── Build UI ─────────────────────────────────────────── */

- (void)buildWebView {
    self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    self.webView.delegate = self;
    self.webView.scalesPageToFit = YES;
    self.webView.backgroundColor = [UIColor colorWithRed:0.039 green:0.039 blue:0.059 alpha:1.0];
    self.webView.opaque = NO;

    /* Suppress rubber-band scroll so the web app feels native */
    self.webView.scrollView.bounces = NO;
    self.webView.scrollView.scrollsToTop = NO;

    [self.view addSubview:self.webView];
}

- (void)buildLoadingView {
    self.loadingView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.loadingView.backgroundColor = [UIColor colorWithRed:0.039 green:0.039 blue:0.059 alpha:1.0];

    self.spinner = [[UIActivityIndicatorView alloc]
                    initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.spinner.color = [UIColor colorWithRed:0.486 green:0.361 blue:0.988 alpha:1.0];
    [self.loadingView addSubview:self.spinner];
    [self.spinner startAnimating];

    [self.view addSubview:self.loadingView];
}

- (void)buildErrorView {
    self.errorView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.errorView.backgroundColor = [UIColor colorWithRed:0.039 green:0.039 blue:0.059 alpha:1.0];
    self.errorView.hidden = YES;

    self.errorLabel = [[UILabel alloc] init];
    self.errorLabel.textColor = [UIColor colorWithRed:0.565 green:0.565 blue:0.627 alpha:1.0];
    self.errorLabel.textAlignment = NSTextAlignmentCenter;
    self.errorLabel.numberOfLines = 3;
    self.errorLabel.font = [UIFont systemFontOfSize:15];
    [self.errorView addSubview:self.errorLabel];

    self.retryButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.retryButton setTitle:@"Повторить" forState:UIControlStateNormal];
    [self.retryButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.retryButton.backgroundColor = [UIColor colorWithRed:0.486 green:0.361 blue:0.988 alpha:1.0];
    self.retryButton.layer.cornerRadius = 10;
    self.retryButton.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    [self.retryButton addTarget:self
                         action:@selector(retryTapped)
               forControlEvents:UIControlEventTouchUpInside];
    [self.errorView addSubview:self.retryButton];

    [self.view addSubview:self.errorView];
}

/* ── Load ─────────────────────────────────────────────── */

- (void)loadApp {
    self.loadingView.hidden = NO;
    self.errorView.hidden   = YES;
    NSURL    *url     = [NSURL URLWithString:kAppURL];
    NSURLRequest *req = [NSURLRequest requestWithURL:url
                                         cachePolicy:NSURLRequestUseProtocolCachePolicy
                                     timeoutInterval:20.0];
    [self.webView loadRequest:req];
}

- (void)retryTapped {
    [self loadApp];
}

/* ── UIWebViewDelegate ────────────────────────────────── */

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [UIView animateWithDuration:0.25 animations:^{
        self.loadingView.alpha = 0;
    } completion:^(BOOL done) {
        self.loadingView.hidden = YES;
        self.loadingView.alpha  = 1;
    }];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    /* -999 = cancelled (navigation, ignore) */
    if (error.code == NSURLErrorCancelled) return;
    self.loadingView.hidden = YES;
    self.errorView.hidden   = NO;
    self.errorLabel.text = [NSString stringWithFormat:
        @"Нет соединения\n%@", error.localizedDescription];
}

- (BOOL)webView:(UIWebView *)webView
    shouldStartLoadWithRequest:(NSURLRequest *)request
                navigationType:(UIWebViewNavigationType)navType {
    /* Allow all URLs that belong to the app origin; open externals in Safari */
    NSString *host = request.URL.host;
    if (host && ![host containsString:@"eeop117.workers.dev"]
             && ![host containsString:@"supabase.co"]
             && ![host containsString:@"zegocloud"]
             && ![host containsString:@"unpkg.com"]
             && ![host containsString:@"jsdelivr.net"]
             && navType == UIWebViewNavigationTypeLinkClicked) {
        [[UIApplication sharedApplication] openURL:request.URL];
        return NO;
    }
    return YES;
}

@end

#pragma clang diagnostic pop
