//
//  CTViewController.m
//  CTFluentLoggerSample
//
//  Created by 和泉田 領一 on 2014/04/26.
//  Copyright (c) 2014年 CAPH. All rights reserved.
//

#import "CTViewController.h"
#import "CTFluentLogger.h"
#import "GCNetworkReachability.h"

@interface CTViewController ()

@property (nonatomic, strong) GCNetworkReachability *reachability;
@end

@implementation CTViewController

- (void)viewDidLoad
{
    [super viewDidLoad];


    NSString *host = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"FluentdHost"];

    self.reachability = [GCNetworkReachability reachabilityWithInternetAddressString:host];
    [self.reachability startMonitoringNetworkReachabilityWithHandler:^(GCNetworkReachabilityStatus status) {
        switch (status) {
            case GCNetworkReachabilityStatusNotReachable:
                [[CTFluentLogger sharedLogger] disconnect];
                break;

            case GCNetworkReachabilityStatusWWAN:
            case GCNetworkReachabilityStatusWiFi:
                if (![CTFluentLogger sharedLogger].connected) {
                    [[CTFluentLogger sharedLogger] connect];
                }
                break;
        }
    }];

    [[CTFluentLogger sharedLogger] setHost:host port:24224 tagPrefix:@"myapp.ios"];
    [CTFluentLogger sharedLogger].shouldAddBuildNumber = YES;
    [CTFluentLogger sharedLogger].shouldAddPlatform = YES;
    [CTFluentLogger sharedLogger].shouldAddSystemVersion = YES;
    [[CTFluentLogger sharedLogger] connect];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)logButtonTapped:(id)sender
{
    [[CTFluentLogger sharedLogger] sendLogWithTag:@"sample" fields:@{@"test_key" : @"test_string"}];
}

@end
