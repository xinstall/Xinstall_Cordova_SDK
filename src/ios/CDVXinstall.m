//
//  CDVXinstall.m
//  HelloCordova
//
//  Created by huawenjie on 2020/12/24.
//

#import "CDVXinstall.h"

NSString * const XinstallThirdVersion = @"XINSTALL_THIRDSDKVERSION_1.5.5_THIRDSDKVERSION_XINSTALL";
NSString * const XinstallThirdPlatform = @"XINSTALL_THIRDPLATFORM_CORDOVA_THIRDPLATFORM_XINSTALL";

@interface CDVXinstall()

@property (nonatomic, strong) NSMutableArray *marrWakeUpCallbackId;

@property (nonatomic, strong) NSMutableArray *marrWakeUpDetailCallbackId;

@property (nonatomic, strong) NSDictionary *dicWakeUp;

@property (nonatomic, strong) NSDictionary *dicWakeUpDetail;

@end

@implementation CDVXinstall
+ (BOOL)isEmptyData:(XinstallData *)data {
    if (data == nil) {
        return YES;
    }
    
    if (data.channelCode.length > 0) {
        return NO;
    }
    
    if (data.timeSpan > 0) {
        return NO;
    }
    
    if ([data.data isKindOfClass:[NSDictionary class]]) {
        id objUo = [((NSDictionary *)data.data) objectForKey:@"uo"];
        if ([objUo isKindOfClass:[NSDictionary class]]) {
            if (((NSDictionary *)objUo).count > 0) {
                return NO;
            }
        } else if ([objUo isKindOfClass:[NSString class]]) {
            if (((NSString *)objUo).length > 0) {
                return NO;
            }
        }
    }
    
    if ([data.data isKindOfClass:[NSDictionary class]]) {
        id objCo = [((NSDictionary *)data.data) objectForKey:@"co"];
        if ([objCo isKindOfClass:[NSDictionary class]]) {
            if (((NSDictionary *)objCo).count > 0) {
                return NO;
            }
        } else if ([objCo isKindOfClass:[NSString class]]) {
            if (((NSString *)objCo).length > 0) {
                return NO;
            }
        }
    }
    
    return YES;
}

#pragma mark - init

- (void)pluginInitialize {
    NSString* appKey = [[self.commandDelegate settings] objectForKey:@"com.xinstall.app_key"];
    [XinstallSDK defaultManager];
    if (appKey){
        //暂时没有使用 传入的appKey
        self.appKey = appKey;
        NSLog(@"%@",XinstallThirdVersion);
        NSLog(@"%@",XinstallThirdPlatform);
    }
}
#pragma mark - public methods
- (BOOL)continueUserActivity:(NSUserActivity *)userActivity {
    return [XinstallSDK continueUserActivity:userActivity];
}

#pragma mark - CDVPlugin methods
- (void)handleOpenURL:(NSNotification *)notification {
    NSURL *url = [notification object];
    if ([url isKindOfClass:[NSURL class]]) {
        [XinstallSDK handleSchemeURL:url];
    }
}


- (void)setLog:(CDVInvokedUrlCommand *)command {
    if (command.arguments.count != 0) {
        // 有参数
        BOOL isOpen = [command.arguments objectAtIndex:0];
        [XinstallSDK setShowLog:isOpen];
    }
}

- (void)initNoAd:(CDVInvokedUrlCommand *)command {
    [XinstallSDK initWithDelegate:self];
}

- (void)initWithAd:(CDVInvokedUrlCommand *)command {
    if (command.arguments.count >= 6) {
        // 有idfa参数
        NSString *idfa = [command.arguments objectAtIndex:4];
        NSString *asaToken = [command.arguments objectAtIndex:5];
        
        [XinstallSDK initWithDelegate:self idfa:idfa asaToken:asaToken];
                
        CDVPluginResult *commandResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:@{}];
        [self.commandDelegate sendPluginResult:commandResult callbackId:command.callbackId];
    }
}

- (void)getInstallParams:(CDVInvokedUrlCommand *)command {
    __weak __typeof(self) weakSelf = self;
    [[XinstallSDK defaultManager] getInstallParamsWithCompletion:^(XinstallData * _Nullable installData, XinstallError * _Nullable error) {
        __strong __typeof(weakSelf) self = weakSelf;
        NSDictionary *installMsgDic = @{};
        if (![CDVXinstall isEmptyData:installData]) {
            NSString *channelCode = @"";
            NSString * timeSpan = @"0";
            
            NSDictionary *uo;
            NSDictionary *co;
            NSMutableDictionary *dataDic = [NSMutableDictionary dictionary];
            if ([installData.data isKindOfClass:[NSDictionary class]]) {
                uo = [installData.data objectForKey:@"uo"];
                co = [installData.data objectForKey:@"co"];
            }
            
            if (uo) {
                id uoJson;
                if ([uo isKindOfClass:[NSDictionary class]]) {
                    uoJson = uo;
                } else if ([uo isKindOfClass:[NSString class]]) {
                    uoJson = uo;
                }
            
                [dataDic setValue:uoJson?:@{} forKey:@"uo"];
            }
            
            if (co) {
                id coJson;
                if ([co isKindOfClass:[NSDictionary class]]) {
                    coJson = co;
                } else if ([uo isKindOfClass:[NSString class]]) {
                    coJson = co;
                }
            
                [dataDic setValue:coJson?:@{} forKey:@"co"];
            }
            
            if (installData.channelCode) {
                channelCode = installData.channelCode;
            }
            
            if (installData.timeSpan > 0) {
                timeSpan = [NSString stringWithFormat:@"%zd",installData.timeSpan];
            }
            installMsgDic = @{@"channelCode": channelCode,@"timeSpan":timeSpan, @"data": dataDic,@"isFirstFetch":@(installData.isFirstFetch)};
             
        }
        CDVPluginResult *commandResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:[installMsgDic copy]];
        [commandResult setKeepCallbackAsBool:YES];
        [self.commandDelegate sendPluginResult:commandResult callbackId:command.callbackId];
    }];
}



- (void)registerWakeUpHandler:(CDVInvokedUrlCommand *)command {
    if (self.dicWakeUp) {
        // 调起已执行，并有数据
        [self.marrWakeUpCallbackId addObject:command.callbackId];
        CDVPluginResult *commandResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:[self.dicWakeUp copy]];
        [commandResult setKeepCallbackAsBool:YES];
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
            effectEvent = (NSString *)point;
        }
        id val = [command.arguments objectAtIndex:1];
        if ([val isKindOfClass:[NSNumber class]] || [val isKindOfClass:[NSString class]]){
            effectValue = (long)[val longLongValue];
        }
        [[XinstallSDK defaultManager] reportEventPoint:effectEvent eventValue:effectValue];
    }
}

- (void)registerWakeUpDetailHandler:(CDVInvokedUrlCommand *)command {
    if (self.dicWakeUpDetail) {
        // 调起已执行，并有数据
        [self.marrWakeUpDetailCallbackId addObject:command.callbackId];
        CDVPluginResult *commandResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:[self.dicWakeUpDetail copy]];
        [commandResult setKeepCallbackAsBool:YES];
        [self.commandDelegate sendPluginResult:commandResult callbackId:command.callbackId];
        self.dicWakeUpDetail = nil;
    } else {
        [self.marrWakeUpDetailCallbackId addObject:command.callbackId];
    }
    
}
- (void)reportShareByXinShareId:(CDVInvokedUrlCommand *)command {
    NSString *shareId = @"";
    if (command.arguments.count != 0) {
        id userId = [command.arguments objectAtIndex:0];
        if ([userId isKindOfClass:[NSString class]]) {
            shareId = userId;
        }
        [[XinstallSDK defaultManager] reportShareByXinShareId:shareId];
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
- (void)xinstall_getWakeUpParams:(XinstallData *)appData error:(XinstallError *)error {
    NSDictionary *wakeMsgDic = @{};
    
    if (![CDVXinstall isEmptyData:appData]) {
        NSString *channelCode = @"";
        NSString * timeSpan = @"0";
        
        NSDictionary *uo;
        NSDictionary *co;
        NSMutableDictionary *dataDic = [NSMutableDictionary dictionary];
        if ([appData.data isKindOfClass:[NSDictionary class]]) {
            uo = [appData.data objectForKey:@"uo"];
            co = [appData.data objectForKey:@"co"];
        }
        
        if (uo) {
            id uoJson;
            if ([uo isKindOfClass:[NSDictionary class]]) {
                uoJson = uo;
            } else if ([uo isKindOfClass:[NSString class]]) {
                uoJson = uo;
            }
        
            [dataDic setValue:uoJson?:@{} forKey:@"uo"];
        }
        
        if (co) {
            id coJson;
            if ([co isKindOfClass:[NSDictionary class]]) {
                coJson = co;
            } else if ([uo isKindOfClass:[NSString class]]) {
                coJson = co;
            }
        
            [dataDic setValue:coJson?:@{} forKey:@"co"];
        }
        
        if (appData.channelCode) {
            channelCode = appData.channelCode;
        }
        
        if (appData.timeSpan > 0) {
            timeSpan = [NSString stringWithFormat:@"%zd",appData.timeSpan];
        }

        wakeMsgDic = @{@"channelCode": channelCode,@"timeSpan":timeSpan, @"data": dataDic};
        
        if (self.marrWakeUpCallbackId.count > 0) {
            self.dicWakeUp = nil;
            for (int i = 0; i < self.marrWakeUpCallbackId.count; i++) {
                NSString *callBackId = [self.marrWakeUpCallbackId objectAtIndex:i];
                CDVPluginResult *commandResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:[wakeMsgDic copy]];
                [commandResult setKeepCallbackAsBool:YES];
                [self.commandDelegate sendPluginResult:commandResult callbackId:callBackId];
            }
        } else {
            @synchronized (self) {
                self.dicWakeUp = wakeMsgDic;
            }
        }
    }
    NSDictionary *mdicError = @{};
    if (error != nil) {
        mdicError = @{@"errorType":@(error.type),@"errorMsg":error.errorMsg};
    }
    
    NSDictionary *dicWakeupDetail = @{@"wakeUpData":wakeMsgDic,@"error":mdicError};
    
    if (self.marrWakeUpDetailCallbackId.count > 0) {
        self.dicWakeUpDetail = nil;
        for (int i = 0; i < self.marrWakeUpDetailCallbackId.count ; i++) {
            NSString *callBackId = [self.marrWakeUpDetailCallbackId objectAtIndex:i];
            CDVPluginResult *commandResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:[dicWakeupDetail copy]];
            [commandResult setKeepCallbackAsBool:YES];
            [self.commandDelegate sendPluginResult:commandResult callbackId:callBackId];
        }
    } else {
        @synchronized (self) {
            self.dicWakeUpDetail = dicWakeupDetail;
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

- (NSMutableArray *)marrWakeUpDetailCallbackId {
    if (_marrWakeUpDetailCallbackId == nil) {
        _marrWakeUpDetailCallbackId = [[NSMutableArray alloc] init];
    }
    return _marrWakeUpDetailCallbackId;
}

#pragma mark - version methods
- (NSString *)xiSdkThirdVersion {
    return @"1.5.5";
}

- (NSInteger)xiSdkType {
    return 10;
}

@end
