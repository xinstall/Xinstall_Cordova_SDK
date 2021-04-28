//
//  AppDelegate+Xinstall.m
//  HelloCordova
//
//  Created by huawenjie on 2020/12/25.
//

#import "AppDelegate.h"
#import "CDVXinstall.h"
#import <objc/runtime.h>


@interface AppDelegate (Xinstall)

@end

static BOOL systemMethodExist = NO;

@implementation AppDelegate (Xinstall)

+ (void)load {
    NSString *version = [UIDevice currentDevice].systemVersion;
    if (version.doubleValue >= 9.0) {
        // universal link 9.0后才支持
        Method systemMethod = class_getInstanceMethod(self, @selector(application:continueUserActivity:restorationHandler:));
        Method xinstallFunc = class_getInstanceMethod(self, @selector(xinstall_funcApplication:continueUserActivity:restorationHandler:));
        if (systemMethod) {
            method_exchangeImplementations(systemMethod, xinstallFunc);
            systemMethodExist = YES;
        } else {
            const char *typeEncoding = method_getTypeEncoding(xinstallFunc);
            class_addMethod(self, @selector(application:continueUserActivity:restorationHandler:), method_getImplementation(xinstallFunc), typeEncoding);
        }
    }
}


- (BOOL)xinstall_funcApplication:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void(^)(NSArray<id<UIUserActivityRestoring>> * __nullable restorableObjects))restorationHandler{
    if (systemMethodExist) {
        [self xinstall_funcApplication:application continueUserActivity:userActivity restorationHandler:restorationHandler];
    }
    CDVXinstall *plugin = [self.viewController getCommandInstance:@"xinstallplugin"];
    if (plugin==nil) {
        return NO;
    }
    return [plugin continueUserActivity:userActivity];
}

@end
