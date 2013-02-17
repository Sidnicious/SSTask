//
//  SSTask.h
//
//  Copyright (c) 2013 Sidney San Martín. Released under the MIT license.
//

#import <Foundation/Foundation.h>

@protocol SSTaskDelegate;

@interface SSTask : NSObject {
	NSTask *_task;
	NSTimer *_timeout;
	id<SSTaskDelegate> _delegate;
	NSDictionary *_userInfo;
	int _exitStatus;
	NSPipe *_stdin;
	NSPipe *_stdout;
	NSPipe *_stderr;
}

- (id) initWithLaunchPath: (NSString*)path arguments: (NSArray*)arguments
				  timeout: (NSTimeInterval)timeout
				 delegate: (id<SSTaskDelegate>) delegate
				 userInfo: (NSDictionary*)userInfo;

- (NSFileHandle*) stdin;
- (NSFileHandle*) stdout;
- (NSFileHandle*) stderr;
- (int) exitStatus;
- (NSDictionary*) userInfo;

@end

@protocol SSTaskDelegate <NSObject>

- (void) taskFinished: (SSTask*) task;

@end
