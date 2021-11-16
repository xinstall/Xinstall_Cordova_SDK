//
//  CDVXinstall.h
//  HelloCordova
//
//  Created by huawenjie on 2020/12/24.
//

#import <Cordova/CDVPlugin.h>
#import "XinstallSDK.h"
NS_ASSUME_NONNULL_BEGIN

@interface CDVXinstall : CDVPlugin<XinstallDelegate,UIApplicationDelegate>

@property (nonatomic, strong) NSString *appKey;

// 给Cordova调用的方法

- (void)getInstallParams:(CDVInvokedUrlCommand *)command;
- (void)registerWakeUpHandler:(CDVInvokedUrlCommand *)command;
- (void)reportRegister:(CDVInvokedUrlCommand *)command;
- (void)reportEffectEvent:(CDVInvokedUrlCommand *)command;

- (void)setLog:(CDVInvokedUrlCommand *)command;
- (void)initNoAd:(CDVInvokedUrlCommand *)command;
- (void)initWithAd:(CDVInvokedUrlCommand *)command;

- (void)registerWakeUpDetailHandler:(CDVInvokedUrlCommand *)command;
- (void)reportShareByXinShareId:(CDVInvokedUrlCommand *)command;

// AppDelegate+Xinstall 中会调用
- (BOOL)continueUserActivity:(NSUserActivity *_Nullable)userActivity;

@end

NS_ASSUME_NONNULL_END
