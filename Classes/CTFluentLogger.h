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

@property (nonatomic, strong) NSString *tagPrefix;

@property (nonatomic) BOOL shouldAddBuildNumber;

#if TARGET_OS_IPHONE
@property (nonatomic) BOOL shouldAddPlatform;
#endif

@property (nonatomic) BOOL shouldAddSystemVersion;

+ (CTFluentLogger *)sharedLogger;

- (BOOL)connect;

- (void)disconnect;

- (void)setHost:(NSString *)host port:(uint16_t)port tagPrefix:(NSString *)tagPrefix;

- (void)sendLogWithTag:(NSString *)tag fields:(NSDictionary *)fields;

@end
