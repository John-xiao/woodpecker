//
//  WPHelpViewController.m
//  woodpecker
//
//  Created by QiWL on 2017/10/3.
//  Copyright © 2017年 goldsmith. All rights reserved.
//

#import "WPHelpViewController.h"

@interface WPHelpViewController ()<UIWebViewDelegate>
@property (nonatomic, strong) UIWebView* webView;

@end

@implementation WPHelpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = kColor_2;
    self.title = kLocalization(@"me_help");
    [self setupViews];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self setBackBarButton];
    [self showNavigationBar];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[XJFHUDManager defaultInstance]  hideLoading];
}

- (void)setupViews{
    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, kNavigationHeight + kStatusHeight, kScreen_Width, kScreen_Height - (kNavigationHeight + kStatusHeight))];
    _webView.backgroundColor = [UIColor clearColor];
    _webView.opaque = NO;
    _webView.delegate = self;
    _webView.scalesPageToFit = YES;
    _webView.multipleTouchEnabled=YES;
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"help" withExtension:@"html"];
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    [_webView loadRequest:request];
    [self.view addSubview:_webView];
}

- (void)webViewDidStartLoad:(UIWebView *)webView{
    [[XJFHUDManager defaultInstance] showLoadingHUDwithCallback:^{
        
    }];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [[XJFHUDManager defaultInstance]  hideLoading];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    [[XJFHUDManager defaultInstance]  hideLoading];
    [[XJFHUDManager defaultInstance]  showTextHUD:kLocalization(@"common_load_failure")];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
