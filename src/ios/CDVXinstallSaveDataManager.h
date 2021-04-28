//
//  CDVXinstallSaveDataManager.h
//  HelloCordova
//
//  Created by huawenjie on 2020/12/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CDVXinstallSaveDataManager : NSObject

@property (nonatomic, strong) NSUserActivity *_Nullable userActivity;

+ (CDVXinstallSaveDataManager *)defaultManager;

@end

NS_ASSUME_NONNULL_END
