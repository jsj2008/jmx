//
//  JMXBoardLayer.m
//  JMX
//
//  Created by Igor Sutton on 10/21/10.
//  Copyright 2010 Dyne.org. All rights reserved.
//

#import "JMXBoardLayer.h"


@implementation JMXBoardLayer

- (id)init
{
    self = [super init];
    if (self) {
        self.geometryFlipped = NO;
        [self setupBoard];
        [self setNeedsDisplay];
    }
    return self;
}

- (void)addSublayer:(CALayer *)layer
{
    [super addSublayer:layer];
    [layer setNeedsDisplay];
}

- (void)setupBoard
{
    CGColorRef backgroundColor = CGColorCreateGenericRGB(1.0f, 1.0f, 1.0f, 1.0f);
    self.backgroundColor = backgroundColor;
    CFRelease(backgroundColor);
}

@end
