//
//  SSTask.m
//
//  Copyright (c) 2013 Sidney San Martín. Released under the MIT license.
//

#import "SSTask.h"

@implementation SSTask

- (id) initWithLaunchPath: (NSString*)path arguments: (NSArray*)arguments
				  timeout: (NSTimeInterval)timeout
				 delegate: (id<SSTaskDelegate>) delegate
				 userInfo:(NSDictionary *)userInfo
{
	if (!(self = [super init])) return self;
	
	_userInfo = [userInfo retain];
	_delegate = delegate;
	
	_task = [NSTask new];
	[_task setLaunchPath:path];
	[_task setArguments:arguments];
	[_task setStandardInput:(_stdin = [NSPipe new])];
	[_task setStandardOutput:(_stdout = [NSPipe new])];
	[_task setStandardError:(_stderr = [NSPipe new])];
	
	@try { [_task launch]; }
	@catch (NSException *exception) {
		_exitStatus = 127;
		[[_stdout fileHandleForWriting] closeFile];
		[[_stderr fileHandleForWriting] closeFile];
		[delegate performSelector:@selector(taskFinished:) withObject:self afterDelay:0];
		return self;
	}
	
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(handleTermination:)
												 name:NSTaskDidTerminateNotification
											   object:_task];
	
	if (timeout) {
		NSInvocation *timeoutInvocation = [NSInvocation invocationWithMethodSignature:[NSTask instanceMethodSignatureForSelector:@selector(terminate)]];
		[timeoutInvocation setTarget:_task];
		[timeoutInvocation setSelector:@selector(terminate)];
		_timeout = [NSTimer scheduledTimerWithTimeInterval:timeout invocation:timeoutInvocation repeats:NO];
	}
	
	return self;
}

- (void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[_task release];
	[_timeout invalidate];
	[_userInfo release];
	[_stdin release];
	[_stdout release];
	[_stderr release];
	[super dealloc];
}

- (NSFileHandle*) stdin { return [_stdin fileHandleForWriting]; }
- (NSFileHandle*) stdout { return [_stdout fileHandleForReading]; }
- (NSFileHandle*) stderr { return [_stderr fileHandleForReading]; }
- (int) exitStatus { return _exitStatus; }
- (NSDictionary*) userInfo { return _userInfo; }

- (void)handleTermination: (NSTask*)task
{
	_exitStatus = [_task terminationStatus];
	[_delegate taskFinished:self];
}

@end
