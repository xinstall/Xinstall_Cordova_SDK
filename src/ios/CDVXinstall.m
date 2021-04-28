//
//  CDVXinstall.m
//  HelloCordova
//
//  Created by huawenjie on 2020/12/24.
//

#import "CDVXinstall.h"

@interface CDVXinstall()

@property (nonatomic, strong) NSMutableArray *marrWakeUpCallbackId;

@property (nonatomic, strong) NSDictionary *dicWakeUp;

@end

@implementation CDVXinstall
- (void)pluginInitialize {
    NSString* appKey = [[self.commandDelegate settings] objectForKey:@"com.xinstall.app_key"];
    [XinstallSDK defaultManager];
    if (appKey){
        //暂时没有使用 传入的appKey
        self.appKey = appKey;
        [XinstallSDK initWithDelegate:self];
    }
}
#pragma mark - public methods
- (BOOL)continueUserActivity:(NSUserActivity *)userActivity {
    return [XinstallSDK continueUserActivity:userActivity];
}

#pragma mark - CDVPlugin methods
- (void)getInstallParams:(CDVInvokedUrlCommand *)command {
    __weak __typeof(self) weakSelf = self;
    [[XinstallSDK defaultManager] getInstallParamsWithCompletion:^(XinstallData * _Nullable installData, XinstallError * _Nullable error) {
        __strong __typeof(weakSelf) self = weakSelf;
        NSDictionary *installMsgDic = @{};
        if (error == nil) {
            NSString *channelCode = @"";
            NSDictionary *datas = @{};
            NSString * timeSpan = @"0";
            
            if (installData.data) {
                datas = installData.data;
            }
            
            if (installData.channelCode) {
                channelCode = installData.channelCode;
            }
            
            if (installData.timeSpan > 0) {
                timeSpan = [NSString stringWithFormat:@"%zd",installData.timeSpan];
            }
            installMsgDic = @{@"channelCode": channelCode,@"timeSpan":timeSpan, @"data": datas};
             
        }
        CDVPluginResult *commandResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:[installMsgDic copy]];
        [self.commandDelegate sendPluginResult:commandResult callbackId:command.callbackId];
    }];
}

- (void)registerWakeUpHandler:(CDVInvokedUrlCommand *)command {
    if (self.dicWakeUp) {
        // 调起已执行，并有数据
        [self.marrWakeUpCallbackId addObject:command.callbackId];
        CDVPluginResult *commandResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:[self.dicWakeUp copy]];
        [self.commandDelegate sendPluginResult:commandResult callbackId:command.callbackId];
        self.dicWakeUp = nil;
    } else {
        [self.marrWakeUpCallbackId addObject:command.callbackId];
    }
}

- (void)reportRegister:(CDVInvokedUrlCommand *)command {
    [XinstallSDK reportRegister];
}

- (void)reportEffectEvent:(CDVInvokedUrlCommand *)command {
    NSString *effectEvent = @"";
    long effectValue = 0;
    if (command.arguments.count != 0) {
        // 有参数
        id point = [command.arguments objectAtIndex:0];
        if ([point isKindOfClass:[NSString class]]) {
            effectValue = (long)point;
        }
        id val = [command.arguments objectAtIndex:1];
        if ([val isKindOfClass:[NSNumber class]]){
            NSNumber *valResult = (NSNumber *)val;
            effectValue = [valResult longValue];
        }
        [[XinstallSDK defaultManager] reportEventPoint:effectEvent eventValue:effectValue];
    }
}

#pragma mark - Tools methods
- (NSString *)jsonStringWithObject:(id)jsonObject{
    
    id arguments = (jsonObject == nil ? [NSNull null] : jsonObject);
    
    NSArray* argumentsWrappedInArr = [NSArray arrayWithObject:arguments];
    
    NSString* argumentsJSON = [self cp_JSONString:argumentsWrappedInArr];
    
    argumentsJSON = [argumentsJSON substringWithRange:NSMakeRange(1, [argumentsJSON length] - 2)];
    
    return argumentsJSON;
}
- (NSString *)cp_JSONString:(NSArray *)array{
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:array
                                                       options:0
                                                         error:&error];
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData
                                                 encoding:NSUTF8StringEncoding];
    
    if ([jsonString length] > 0 && error == nil){
        return jsonString;
    }else{
        return @"";
    }
}

#pragma mark - XinstallDelegate methods
- (void)xinstall_getWakeUpParams:(XinstallData *)appData {
    NSString *channelCode = @"";
    NSDictionary *datas = @{};
    NSString * timeSpan = @"0";
    
    if (appData.data) {
        datas = appData.data;
    }
    
    if (appData.channelCode) {
        channelCode = appData.channelCode;
    }
    
    if (appData.timeSpan > 0) {
        timeSpan = [NSString stringWithFormat:@"%zd",appData.timeSpan];
    }
    
    NSDictionary *wakeMsgDic = @{@"channelCode": channelCode,@"timeSpan":timeSpan, @"data": datas};
    
    if (self.marrWakeUpCallbackId.count > 0) {
        for (int i = 0; i < self.marrWakeUpCallbackId.count; i++) {
            NSString *callBackId = [self.marrWakeUpCallbackId objectAtIndex:i];
            CDVPluginResult *commandResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:[wakeMsgDic copy]];
            [self.commandDelegate sendPluginResult:commandResult callbackId:callBackId];
        }
    } else {
        @synchronized (self) {
            self.dicWakeUp = wakeMsgDic;
        }
    }
}

#pragma mark - setter and getter methods
- (NSMutableArray *)marrWakeUpCallbackId {
    if (_marrWakeUpCallbackId == nil) {
        _marrWakeUpCallbackId = [[NSMutableArray alloc] init];
    }
    return _marrWakeUpCallbackId;
}

@end
