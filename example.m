//
//  main.m
//  taskqueue
//
//  Created by Sidney San Martín on 2/16/13.
//  Copyright (c) 2013 Sidney San Martín. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSTask.h"

@interface TaskDelegate : NSObject<SSTaskDelegate>
@end

@implementation TaskDelegate

- (void)taskFinished:(SSTask *)task
{
	printf("Task finished with code %d, output: %s, error: %s, description: %s\n",
		[task exitStatus],
		[[[[NSString alloc] initWithData:[[task stdout] readDataToEndOfFile] encoding:NSUTF8StringEncoding] autorelease] UTF8String],
		[[[[NSString alloc] initWithData:[[task stderr] readDataToEndOfFile] encoding:NSUTF8StringEncoding] autorelease] UTF8String],
	   [[[task userInfo] objectForKey:@"id"] UTF8String]
	);
	[task release];
}

@end

int main(int argc, const char * argv[])
{

	@autoreleasepool {
	    
		TaskDelegate *thing = [TaskDelegate new];
		
		[[SSTask alloc] initWithLaunchPath:@"/bin/ls" arguments:@[] timeout:10 delegate:thing userInfo:@{ @"id": @"A simple ls"}];
		[[SSTask alloc] initWithLaunchPath:@"ls" arguments:@[] timeout:10 delegate:thing userInfo:@{ @"id": @"Should exit with 127 due to a bad launch path"}];
		[[SSTask alloc] initWithLaunchPath:@"/bin/cat" arguments:@[] timeout:10 delegate:thing userInfo:@{ @"id": @"Should time out"}];

		SSTask *catTask = [[SSTask alloc] initWithLaunchPath:@"/bin/cat" arguments:@[] timeout:10 delegate:thing userInfo:@{ @"id": @"Input and output"}];
		[[catTask stdin] writeData:[@"Hello, world!" dataUsingEncoding:NSUTF8StringEncoding]];
		[[catTask stdin] closeFile];

		[[SSTask alloc] initWithLaunchPath:@"/bin/ls" arguments:@[@"/nothing_here"] timeout:10 delegate:thing userInfo:@{ @"id": @"Stderr output" }];
	
		[[NSRunLoop mainRunLoop] run];
	    
	}
    return 0;
}
