CTFluentLogger
==============

CTFluentLogger is a library to send log to Fluentd for iOS 6.0+ and OSX 10.9+.

Install
----------

Using CocoaPods, in Podfile
```
pod 'CTFluentLogger', :podspec => 'https://raw.githubusercontent.com/rizumita/CTFluentLogger/master/CTFluentLogger.podspec'
```


Usage
----------

Set up CTFluentLogger shared instance.

```Objective-C
    [[CTFluentLogger sharedLogger] setHost:host port:24224 tagPrefix:@"myapp.ios"];
    [CTFluentLogger sharedLogger].shouldAddBuildNumber = YES;	// Optional
    [CTFluentLogger sharedLogger].shouldAddPlatform = YES;	// Optional, only for iOS
    [CTFluentLogger sharedLogger].shouldAddSystemVersion = YES;	// Optional
    [[CTFluentLogger sharedLogger] connect];
```

Send log.

```Objective-C
    [[CTFluentLogger sharedLogger] sendLogWithTag:@"sample" fields:@{@"test_key" : @"test_string"}];
```

You may have to detect network reachability to reconnect and disconnect the logger.

Sample
----------

If you want Fluentd and elasticsearch + Kibana3 running on Vagrant, install Vagrant and VirtualBox and run the following command.

```Bash
   cd sandbox
   bundle install --path vendor/bundle
   cd sandbox/chef-sandbox
   bundle exec berks vendor
   vagrant up
```

Open Kibana3 page at 'http://localhost:8080/index.html#/dashboard/file/logstash.json' on your browser. And set every 5s auto-refresh.

Move CTFluentLoggerSample directory, and run 'pod install'.

Open CTFluentLoggerSample.xcworkspace, and run sample app.

Finally, tap log button, then Kibana3 will show log.

License
----------

MIT license
