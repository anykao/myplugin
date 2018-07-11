#import <Flutter/Flutter.h>
#import <WebKit/WebKit.h>

@interface MypluginPlugin : NSObject<FlutterPlugin, WKNavigationDelegate> 
@property (strong, nonatomic) WKWebView *webView;
@end
