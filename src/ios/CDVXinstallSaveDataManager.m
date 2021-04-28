//
//  CDVXinstallSaveDataManager.m
//  HelloCordova
//
//  Created by huawenjie on 2020/12/25.
//

#import "CDVXinstallSaveDataManager.h"

@implementation CDVXinstallSaveDataManager

+ (instancetype)defaultManager {
    static CDVXinstallSaveDataManager * sdkManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sdkManager = [[super allocWithZone:NULL] init];
        //不是使用alloc方法，而是调用[[super allocWithZone:NULL] init]
        //已经重载allocWithZone基本的对象分配方法，所以要借用父类（NSObject）的功能来帮助出处理底层内存分配的杂物
    });
    return sdkManager;
}

///用alloc返回也是唯一实例
+ (instancetype) allocWithZone:(struct _NSZone *)zone {
    return [CDVXinstallSaveDataManager defaultManager] ;
}

/// 对对象使用copy也是返回唯一实例
- (instancetype)copyWithZone:(NSZone *)zone {
    return [CDVXinstallSaveDataManager defaultManager];
}

/// 对对象使用mutablecopy也是返回唯一实例
- (instancetype)mutableCopyWithZone:(NSZone *)zone {
    return [CDVXinstallSaveDataManager defaultManager] ;
}

@end
