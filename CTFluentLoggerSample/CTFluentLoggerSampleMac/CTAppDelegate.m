//
//  CTAppDelegate.m
//  CTFluentLoggerSampleMac
//
//  Created by 和泉田 領一 on 2014/04/26.
//  Copyright (c) 2014年 CAPH. All rights reserved.
//

#import "CTAppDelegate.h"
#import "CTFluentLogger.h"

@implementation CTAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [[CTFluentLogger sharedLogger] setHost:@"192.168.3.2" port:24224 tagPrefix:@"myapp.mac"];
    [CTFluentLogger sharedLogger].shouldAddBuildNumber = YES;
    [CTFluentLogger sharedLogger].shouldAddSystemVersion = YES;
    [[CTFluentLogger sharedLogger] connect];
}

- (IBAction)logButtonTapped:(id)sender
{
    [[CTFluentLogger sharedLogger] sendLogWithTag:@"sample" fields:@{@"test_key" : @"test_string"}];
}

@end
