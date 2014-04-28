//
//  CTFluentLogger.m
//
//  Created by Ryoichi Izumita on 2014/04/26.
//  Copyright (c) 2014 CAPH. All rights reserved.
//

#import "CTFluentLogger.h"
#import "GCDAsyncSocket.h"
#import "MessagePackPacker.h"
#include <sys/sysctl.h>

static const int CTFluentLoggerTimeout = 15;

@interface CTFluentLogger () <GCDAsyncSocketDelegate>
@property (nonatomic, strong) dispatch_queue_t delegateQueue;
@property (nonatomic, strong) GCDAsyncSocket *asyncSocket;
@property (nonatomic, copy) NSString *host;
@property (nonatomic) uint16_t port;
@end

@implementation CTFluentLogger
{
    BOOL _connected;
}

+ (CTFluentLogger *)sharedLogger
{
    static CTFluentLogger *instance = nil;
    static dispatch_once_t predicate;

    dispatch_once(&predicate, ^{
        instance = [[self alloc] init];
    });

    return instance;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.delegateQueue = dispatch_queue_create("jp.caph.CTFluentLogger.delegateQueue", NULL);
        self.asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:self.delegateQueue];
    }
    return self;
}

- (BOOL)connect
{
    NSError *error;
    self.asyncSocket.delegate = self;
    BOOL success = [self.asyncSocket connectToHost:self.host onPort:self.port error:&error];
    if (error) {
        NSLog(@"Error connecting: %@", error);
    }

    return success;
}

- (void)disconnect
{
    self.asyncSocket.delegate = nil;
    [self.asyncSocket disconnectAfterWriting];

    [self willChangeValueForKey:@"connected"];
    _connected = NO;
    [self didChangeValueForKey:@"connected"];
}

- (void)setHost:(NSString *)host port:(uint16_t)port tagPrefix:(NSString *)tagPrefix
{
    self.host = host;
    self.port = port;
    self.tagPrefix = tagPrefix;
}

- (void)sendLogWithTag:(NSString *)tag fields:(NSDictionary *)fields
{
    NSMutableDictionary *workingFields = fields.mutableCopy;

    if (self.shouldAddBuildNumber) {
        [workingFields setObject:[[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey] forKey:@"build"];
    }

#if TARGET_OS_IPHONE
    if (self.shouldAddPlatform) {
        [workingFields setObject:self.platformString forKey:@"platform"];
    }
#endif

    if (self.shouldAddSystemVersion) {
        [workingFields setObject:self.systemVersion forKey:@"system_version"];
    }

    NSNumber *timestamp = @([[NSDate date] timeIntervalSince1970]);
    NSData *message = [MessagePackPacker pack:@[[self joinTag:tag], timestamp, workingFields]];

    [self.asyncSocket writeData:message withTimeout:CTFluentLoggerTimeout tag:0];
}

- (NSString *)joinTag:(NSString *)tag
{
    if (self.tagPrefix) {
        return [self.tagPrefix stringByAppendingFormat:@".%@", tag];
    } else {
        return tag;
    }
}

- (BOOL)connected
{
    return _connected;
}

#if TARGET_OS_IPHONE

- (NSString *)platform
{
    int mib[2];
    size_t len;
    char *machine;

    mib[0] = CTL_HW;
    mib[1] = HW_MACHINE;
    sysctl(mib, 2, NULL, &len, NULL, 0);
    machine = malloc(len);
    sysctl(mib, 2, machine, &len, NULL, 0);

    NSString *platform = [NSString stringWithCString:machine encoding:NSASCIIStringEncoding];
    free(machine);
    return platform;
}

// http://theiphonewiki.com/wiki/Models
- (NSString *)platformString
{
    NSString *platform = [self platform];

    if ([platform isEqualToString:@"iPhone1,1"]) return @"iPhone 1G";
    if ([platform isEqualToString:@"iPhone1,2"]) return @"iPhone 3G";
    if ([platform isEqualToString:@"iPhone2,1"]) return @"iPhone 3GS";
    if ([platform isEqualToString:@"iPhone3,1"]) return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,3"]) return @"Verizon iPhone 4";
    if ([platform isEqualToString:@"iPhone4,1"]) return @"iPhone 4S";
    if ([platform isEqualToString:@"iPhone5,1"]) return @"iPhone 5 (GSM)";
    if ([platform isEqualToString:@"iPhone5,2"]) return @"iPhone 5 (GSM+CDMA)";
    if ([platform isEqualToString:@"iPhone5,3"]) return @"iPhone 5c (GSM)";
    if ([platform isEqualToString:@"iPhone5,4"]) return @"iPhone 5c (Global)";
    if ([platform isEqualToString:@"iPhone6,1"]) return @"iPhone 5s (GSM)";
    if ([platform isEqualToString:@"iPhone6,2"]) return @"iPhone 5s (Global)";

    if ([platform isEqualToString:@"iPod1,1"]) return @"iPod Touch 1G";
    if ([platform isEqualToString:@"iPod2,1"]) return @"iPod Touch 2G";
    if ([platform isEqualToString:@"iPod3,1"]) return @"iPod Touch 3G";
    if ([platform isEqualToString:@"iPod4,1"]) return @"iPod Touch 4G";
    if ([platform isEqualToString:@"iPod5,1"]) return @"iPod Touch 5G";

    if ([platform isEqualToString:@"iPad1,1"]) return @"iPad";
    if ([platform isEqualToString:@"iPad2,1"]) return @"iPad 2 (WiFi)";
    if ([platform isEqualToString:@"iPad2,2"]) return @"iPad 2 (GSM)";
    if ([platform isEqualToString:@"iPad2,3"]) return @"iPad 2 (CDMA)";
    if ([platform isEqualToString:@"iPad2,4"]) return @"iPad 2";
    if ([platform isEqualToString:@"iPad3,1"]) return @"iPad-3G (WiFi)";
    if ([platform isEqualToString:@"iPad3,2"]) return @"iPad-3G (4G)";
    if ([platform isEqualToString:@"iPad3,3"]) return @"iPad-3G (4G)";
    if ([platform isEqualToString:@"iPad3,4"]) return @"iPad-4G (WiFi)";
    if ([platform isEqualToString:@"iPad3,5"]) return @"iPad-4G (GSM)";
    if ([platform isEqualToString:@"iPad3,6"]) return @"iPad-4G (GSM+CDMA)";
    if ([platform isEqualToString:@"iPad4,1"]) return @"iPad Air (WiFi)";
    if ([platform isEqualToString:@"iPad4,2"]) return @"iPad Air (Cellular)";
    if ([platform isEqualToString:@"iPad2,5"]) return @"iPad mini-1G (WiFi)";
    if ([platform isEqualToString:@"iPad2,6"]) return @"iPad mini-1G (GSM)";
    if ([platform isEqualToString:@"iPad2,7"]) return @"iPad mini-1G (GSM+CDMA)";
    if ([platform isEqualToString:@"iPad4,4"]) return @"iPad mini-2G (WiFi)";
    if ([platform isEqualToString:@"iPad4,5"]) return @"iPad mini-2G (Cellular)";

    if ([platform isEqualToString:@"i386"]) return @"Simulator";
    if ([platform isEqualToString:@"x86_64"]) return @"Simulator";

    return platform;
}

#endif

- (NSString *)systemVersion
{
#if TARGET_OS_IPHONE
    return [UIDevice currentDevice].systemVersion;
#else
    return [[NSProcessInfo processInfo] operatingSystemVersionString];
#endif
}

#pragma mark - GCDAsyncSocketDelegate

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    [self willChangeValueForKey:@"connected"];
    _connected = YES;
    [self didChangeValueForKey:@"connected"];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    [self willChangeValueForKey:@"connected"];
    _connected = NO;
    [self didChangeValueForKey:@"connected"];
}

@end
