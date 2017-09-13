
#import "RNNaverLogin.h"


// 네이버 관련 세팅
#import "AppDelegate.h"
#import "NaverThirdPartyConstantsForApp.h"
#import "NaverThirdPartyLoginConnection.h"
#import "NLoginThirdPartyOAuth20InAppBrowserViewController.h"

////////////////////////////////////////////////////     _//////////_  // Private Members
@interface RNNaverLogin() {
  NaverThirdPartyLoginConnection *naverConn;
  RCTResponseSenderBlock naverTokenSend;
}
@end


////////////////////////////////////////////////////     _//////////_  // Implementation
@implementation RNNaverLogin

- (dispatch_queue_t)methodQueue
{
  return dispatch_get_main_queue();
}

////////////////////////////////////////////////////     _//////////_  // 네이버 관련 세팅
-(void)oauth20Connection:(NaverThirdPartyLoginConnection *)oauthConnection didFailWithError:(NSError *)error {
  NSLog(@"\n\n\n  Nearo oauth20Connection \n\n\n");
  naverTokenSend = nil;
}

-(void)oauth20ConnectionDidFinishRequestACTokenWithAuthCode {
  NSLog(@"\n\n\n  Nearo oauth20ConnectionDidFinishRequestACTokenWithAuthCode");
  NSString *token = [naverConn accessToken];
  NSLog(@"\n\n\n  Nearo Token ::  %@", token);
  if (naverTokenSend != nil) {
    NSLog(@" Nearo :: rctCallback != nil  JS 로 보냄.. .. \n");
    naverTokenSend(@[[NSNull null], token]);
    naverTokenSend = nil;
  }
}
-(void)oauth20ConnectionDidFinishRequestACTokenWithRefreshToken {
  NSString *token = [naverConn accessToken];
  NSLog(@" \n\n\n Nearo oauth20ConnectionDidFinishRequestACTokenWithRefreshToken \n\n\n  %@ \n\n .", token);
  if (naverTokenSend != nil) {
    naverTokenSend(@[[NSNull null], token]);
  }
}

-(void)oauth20ConnectionDidOpenInAppBrowserForOAuth:(NSURLRequest *)request {
  NSLog(@"\n\n\n Nearo oauth20ConnectionDidOpenInAppBrowserForOAuth \n\n\n xx");
  
  dispatch_async(dispatch_get_main_queue(), ^{
    NLoginThirdPartyOAuth20InAppBrowserViewController *inappAuthBrowser =
    [[NLoginThirdPartyOAuth20InAppBrowserViewController alloc] initWithRequest:request];
    
    UIViewController *vc = UIApplication.sharedApplication.delegate.window.rootViewController;
    [vc presentViewController:inappAuthBrowser animated:NO completion:nil];
  });
}

-(void)oauth20ConnectionDidFinishDeleteToken {
  NSLog(@" \n\n\n Nearo oauth20ConnectionDidFinishDeleteToken \n\n\n");
}

////////////////////////////////////////////////////     _//////////_//      EXPORT_MODULE
RCT_EXPORT_MODULE();

////////////////////////////////////////////////////     _//////////_// 네이버 관련 세팅
RCT_EXPORT_METHOD(startNaverAuth:(RCTResponseSenderBlock)callback) {
  RCTLogInfo(@"\n\n\n\n Obj c >> Nearo ReactIosAuth :: startNaverAuth \n\n\n\n .");
  NSLog(@" Nearo  log this ???");
  // [naverConn requestThirdPartyLogin];
  NSString *token = [naverConn accessToken];
  naverTokenSend = callback;
  NSLog(@"\n\n\n Nearo Token ::  %@", token);
  
  if ([naverConn isValidAccessTokenExpireTimeNow]) {
    NSLog(@"\n\n\n Nearo Token  ::   >>>>>>>>  VALID");
    naverTokenSend(@[[NSNull null], token]);
  } else {
    NSLog(@"\n\n\n Nearo Token  ::   >>>>>>>>  IN VALID  >>>>>");
    [naverConn requestThirdPartyLogin];
  }
}

RCT_EXPORT_METHOD(resetNaverAuth:(RCTResponseSenderBlock)callback) {
  RCTLogInfo(@"\n\n\n\n Obj c >> Nearo ReactIosAuth :: reset \n\n\n\n .");
  [naverConn resetToken];
  naverTokenSend = nil;
  callback(@[[NSNull null], @"reset called"]);
}

RCT_EXPORT_METHOD(isNaverValidToken:(RCTResponseSenderBlock)getToken) {
  RCTLogInfo(@"\n\n\n\n Obj c >> Nearo ReactIosAuth :: isNaverValidToken \n\n\n\n .");
  naverTokenSend = getToken;
  if ([naverConn isValidAccessTokenExpireTimeNow]) {
    NSString *token = [naverConn accessToken];
    naverTokenSend(@[[NSNull null], token]);
  } else {
    //naverTokenSend(@[[NSNull null], @"Token is invalid ..."]);
    RCTLogInfo(@"\n\n\n\n Obj c >> Nearo isNaverValidToken :: Token is In Valid  Reqest New One \n\n\n\n .");
    [naverConn requestThirdPartyLogin];
    //[naverConn requestAccessTokenWithRefreshToken];
  }
}

RCT_EXPORT_METHOD(getNaverToken:(RCTResponseSenderBlock)getNaverToken) {
  RCTLogInfo(@"\n\n\n\n Obj c >> Nearo ReactIosAuth :: startNaverAuth \n\n\n\n .");
  NSString *token = [naverConn accessToken];
  RCTLogInfo(@"\n\n\n  Nearo Token ::  %@", token);
  
  if (token != NULL) {
    getNaverToken(@[[NSNull null], token]);
  }
}

@end
