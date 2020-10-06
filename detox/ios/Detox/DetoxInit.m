//
//  DetoxInit.m
//  Detox
//
//  Created by Leo Natan (Wix) on 5/22/20.
//  Copyright © 2020 Wix. All rights reserved.
//

#import <Detox/Detox-Swift.h>
#import "DetoxCrashHandler.h"

@import EarlGrey.GREYConfiguration;

__attribute__((constructor))
static void detoxConditionalInit()
{
	__DTXInstallCrashHandlersIfNeeded();
	
	//This forces accessibility support in the application.
	[[[NSUserDefaults alloc] initWithSuiteName:@"com.apple.Accessibility"] setBool:YES forKey:@"ApplicationAccessibilityEnabled"];
	
	//Timeout will be regulated by mochaJS. Perhaps it would be best to somehow pass the timeout value from JS to here. For now, this will do.
	[[GREYConfiguration sharedInstance] setDefaultValue:@(DBL_MAX) forConfigKey:kGREYConfigKeyInteractionTimeoutDuration];
	
	NSUserDefaults* options = [NSUserDefaults standardUserDefaults];
	
	NSMutableDictionary* settings = [NSMutableDictionary new];
	
	NSString* syncEnabled = [options objectForKey:@"detoxEnableSynchronization"];
	if(syncEnabled)
	{
		settings[@"enabled"] = @([syncEnabled boolValue]);
	}
	
	NSArray *blacklistRegex = [options arrayForKey:@"detoxURLBlacklistRegex"];
	if (blacklistRegex)
	{
		settings[@"blacklistURLs"] = blacklistRegex;
	}
	
	NSNumber* waitForDebugger = [options objectForKey:@"detoxWaitForDebugger"];
	if(waitForDebugger)
	{
		settings[@"waitForDebugger"] = @((NSUInteger)[waitForDebugger integerValue]);
	}
	
	//Wrokaround: wait for launch screen
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(120 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		[DTXDetoxManager.sharedManager startWithSynchronizationSettings:settings];
	});
}

