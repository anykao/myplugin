#import "MypluginPlugin.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

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
  } else if ([@"mergeAndSave" isEqualToString:call.method]) {
    NSString *script = call.arguments;
    JSContext *context = [[JSContext alloc] init];
    NSString *signature = [[context evaluateScript:script] toString];
    result(signature);
  } else {
    result(FlutterMethodNotImplemented);
  }
}

-(void)mergeAndSave:(NSString*)audio_path with:(NSString*)video_path {
    //Create AVMutableComposition Object which will hold our multiple AVMutableCompositionTrack or we can say it will hold our video and audio files.
    AVMutableComposition* mixComposition = [AVMutableComposition composition];
    
    //Now first load your audio file using AVURLAsset. Make sure you give the correct path of your videos.
    NSURL *audio_url = [NSURL fileURLWithPath:audio_path];
    audioAsset = [[AVURLAsset alloc]initWithURL:audio_url options:nil];
    CMTimeRange audio_timeRange = CMTimeRangeMake(kCMTimeZero, audioAsset.duration);
    
    //Now we are creating the first AVMutableCompositionTrack containing our audio and add it to our AVMutableComposition object.
    AVMutableCompositionTrack *b_compositionAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    [b_compositionAudioTrack insertTimeRange:audio_timeRange ofTrack:[[audioAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime:kCMTimeZero error:nil];
    
    //Now we will load video file.
    NSURL *video_url = [NSURL fileURLWithPath:video_path];
    videoAsset = [[AVURLAsset alloc]initWithURL:video_url options:nil];
    CMTimeRange video_timeRange = CMTimeRangeMake(kCMTimeZero,audioAsset.duration);
    
    //Now we are creating the second AVMutableCompositionTrack containing our video and add it to our AVMutableComposition object.
    AVMutableCompositionTrack *a_compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    [a_compositionVideoTrack insertTimeRange:video_timeRange ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:kCMTimeZero error:nil];
    
    //decide the path where you want to store the final video created with audio and video merge.
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsDir = [dirPaths objectAtIndex:0];
    NSString *outputFilePath = [docsDir stringByAppendingPathComponent:[NSString stringWithFormat:@"FinalVideo.mp4"]];
    NSURL *outputFileUrl = [NSURL fileURLWithPath:outputFilePath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:outputFilePath])
        [[NSFileManager defaultManager] removeItemAtPath:outputFilePath error:nil];
    
    //Now create an AVAssetExportSession object that will save your final video at specified path.
    AVAssetExportSession* _assetExport = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetHighestQuality];
    _assetExport.outputFileType = AVFileTypeMPEG4;
    _assetExport.outputURL = outputFileUrl;
    
    [_assetExport exportAsynchronouslyWithCompletionHandler:
     ^(void ) {
         dispatch_async(dispatch_get_main_queue(), ^{
             [self exportDidFinish:_assetExport];
         });
     }
     ];
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
