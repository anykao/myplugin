#import "MypluginPlugin.h"
#import <JavaScriptCore/JavaScriptCore.h>

@implementation MypluginPlugin {
  FlutterResult _flutterResult;
}

#pragma mark - LazyLoad

- (WKWebView *)webView
{
    if (!_webView) {
        WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc]init];
        _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, 10, 10) configuration:config];
        _webView.navigationDelegate = self;
    }
    return _webView;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"myplugin"
            binaryMessenger:[registrar messenger]];
  MypluginPlugin* instance = [[MypluginPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"getStreamurl" isEqualToString:call.method]) {
    _flutterResult = result;
    NSString* url = call.arguments;
    [self getStreamurl:url];
  } else if ([@"decipher" isEqualToString:call.method]) {
    NSString *script = call.arguments;
    JSContext *context = [[JSContext alloc] init];
    NSString *signature = [[context evaluateScript:script] toString];
    result(signature);
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (void)getStreamurl:(NSString*)url {
  NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
  [self.webView loadRequest:request];
}

- (void)webView:(WKWebView*)webView didFinishNavigation:(WKNavigation*)navigation {
  NSString *script = [NSString stringWithFormat:@"document.body.innerHTML"];
  [self.webView evaluateJavaScript:script completionHandler:^(NSString *html, NSError *error){
      self->_flutterResult(html);
  }];
}

@end
