//
//  VJXEntity+Threaded.m
//  VeeJay
//
//  Created by xant on 9/7/10.
//  Copyright 2010 Dyne.org. All rights reserved.
//
//  This file is part of VeeJay
//
//  VeeJay is free software: you can redistribute it and/or modify
//  it under the terms of the GNU Lesser General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  Foobar is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with VeeJay.  If not, see <http://www.gnu.org/licenses/>.
//

#import "VJXThreadedEntity.h"
#import <QuartzCore/QuartzCore.h>

@implementation VJXThreadedEntity

- (id)init
{
    if (self == [super init])
        worker = nil;
    return self;
}

- (void)dealloc
{
    [self stop];
    [super dealloc];
}

- (void)start
{
    if (!worker) {
        worker = [[NSThread alloc] initWithTarget:self selector:@selector(run) object:nil];
        [worker start];
    }
}

- (void)stop {
    if (worker)
        [worker cancel];
}

- (void)run
{
    uint64_t maxDelta = 1e9 / [frequency doubleValue];
    
    NSThread *currentThread = [NSThread currentThread];
    
    active = YES;
    while (![currentThread isCancelled]) {
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        uint64_t timeStamp = CVGetCurrentHostTime();
        if ([self respondsToSelector:@selector(tick:)])
            [self tick:timeStamp];
        [self outputDefaultSignals:timeStamp]; // ensure sending all default signals
        previousTimeStamp = timeStamp;
        uint64_t now = CVGetCurrentHostTime();
        // Check if tick() has returned earlier and we still have time before next tick. 
        // If the current delta is smaller than our frequency, we will wait the difference
        // between maxDelta and delta to honor the configured frequency.
        // Otherwise, since we would be already late, we just skip the sleep time and 
        // go for the next frame.
        uint64_t delta = now - timeStamp;
        uint64_t sleepTime = (delta && delta < maxDelta) ? maxDelta - delta : 0;
        
        if (sleepTime) {
#if 0
            // using nanosleep is a good portable way, but since we are running 
            // on OSX only, we should try relying on the NSThread API.
            // We will switch back to nanosleep if we notice that 'sleepForTimeInterval'
            // is not precise enough.
            struct timespec time = { 0, 0 };
            struct timespec remainder = { 0, sleepTime };
            do {
                time.tv_sec = remainder.tv_sec;
                time.tv_nsec = remainder.tv_nsec;
                remainder.tv_nsec = 0;
                nanosleep(&time, &remainder);
            } while (remainder.tv_sec || remainder.tv_nsec);
#else
            // let's try if NSThread facilities are reliable (in terms of time precision)
            [NSThread sleepForTimeInterval:sleepTime/1e9];
#endif
        } else {
            // mmm ... no sleep time ... perhaps we are out of resources and slowing down mixing
            // TODO - produce a warning in this case
        }
        [pool drain];
    }
    active = NO;
}

- (void)tick:(uint64_t)timeStamp
{
    // do nothing for now
}

@end