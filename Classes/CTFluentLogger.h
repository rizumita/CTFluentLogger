//
//  CTFluentLogger.h
//
//  Created by Ryoichi Izumita on 2014/04/26.
//  Copyright (c) 2014 CAPH. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GCDAsyncSocket;
@class GCDAsyncUdpSocket;

@interface CTFluentLogger : NSObject

@property (nonatomic, readonly) BOOL connected;

@property (nonatomic, strong) NSString * _Nullable tagPrefix;

@property (nonatomic) BOOL shouldAddBuildNumber;

#if TARGET_OS_IPHONE
@property (nonatomic) BOOL shouldAddPlatform;
#endif

@property (nonatomic) BOOL shouldAddSystemVersion;

+ (CTFluentLogger *_Nonnull)sharedLogger;

- (BOOL)connect;

- (void)disconnect;

- (void)startTLS:(nullable NSDictionary <NSString*,NSObject*>*)tlsSettings;

- (void)setHost:(nonnull NSString *)host port:(uint16_t)port tagPrefix:(nullable NSString *)tagPrefix;

- (void)sendLogWithTag:(nonnull NSString *)tag fields:(nonnull NSDictionary *)fields;

@end
