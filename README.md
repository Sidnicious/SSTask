# SSTask

This is little wrapper around [`NSTask`][1] that makes it more friendly (for certain uses).

  [1]: https://developer.apple.com/library/mac/documentation/Cocoa/Reference/Foundation/Classes/NSTask_Class/Reference/Reference.html

- The task runs asynchronously and a delegate method is called when it finishes.

- An exception is never thrown if the task fails to launch (say, if the executable path is bad). Instead, the task completes with status 127 (as shells handle failed execs).

- Standard input, output, and error are connected to pipes.

- You can provide a timeout after which the task is sent SIGTERM.

- You can attach a `userInfo` dictionary to the task.

## Usage

See `example.m` for a working example, but basic usage looks like this:


    [[SSTask alloc] initWithLaunchPath:@"/bin/ls"
                             arguments:@[ @"/" ]
                               timeout:10
                              delegate:self
                              userInfo:@{ @"name": @"foo"}];

Pulls and complaints welcome (my Objective-C is a bit rusty!).
