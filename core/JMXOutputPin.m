//
//  JMXOutputPin.m
//  JMX
//
//  Created by xant on 10/18/10.
//  Copyright 2010 Dyne.org. All rights reserved.
//
//  This file is part of JMX
//
//  JMX is free software: you can redistribute it and/or modify
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
//  along with JMX.  If not, see <http://www.gnu.org/licenses/>.
//

#import "JMXOutputPin.h"
#import "JMXInputPin.h"
#import "JMXContext.h"
#import "JMXEntity.h"
#import "JMXAttribute.h"
//#import "JMXProxyPin.h"

@interface JMXPin (Private)
- (void)sendData:(id)data toReceiver:(id)receiver withSelector:(NSString *)selectorName fromSender:(id)sender;
@end

@implementation JMXOutputPin
@synthesize receivers;

- (id)initWithLabel:(NSString *)pinLabel
            andType:(JMXPinType)pinType
            ownedBy:(id)pinOwner
         withSignal:(NSString *)pinSignal
           userData:(id)userData
      allowedValues:(NSArray *)pinValues
       initialValue:(id)value
{
    self = [super initWithLabel:pinLabel
                        andType:pinType
                        ownedBy:pinOwner
                     withSignal:pinSignal
                       userData:userData
                  allowedValues:pinValues
                   initialValue:value];
    if (self) {
        receivers = [[NSMutableDictionary alloc] init];
        direction = kJMXOutputPin;
        [self addAttribute:[NSXMLNode attributeWithName:@"direction" stringValue:@"output"]];
    }
    return self;
}

- (void)dealloc
{
    [receivers release];
    [super dealloc];
}

- (void)performSignal:(JMXPinSignal *)signal
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    [super performSignal:signal];
    // and then propagate it to all receivers
    @synchronized (receivers) {
        for (id receiver in [receivers allKeys]) {
            signal.receiver = receiver;
            [self sendData:signal.data toReceiver:receiver withSelector:[receivers objectForKey:receiver] fromSender:signal.sender];
        }
    }
    [pool drain];
}

- (BOOL)attachObject:(id)pinReceiver withSelector:(NSString *)pinSignal
{
    BOOL rv = NO;

    if ([pinReceiver isKindOfClass:[JMXPin class]]) {
        JMXPin *destinationPin = (JMXPin *)pinReceiver;
        // XXX - for some unknown reason connections element must be added before doing the actual connection
        //       probably this is due to some race condition since signals start to be delivered by external threads
        //       as soon as the connection happens
        JMXElement *newConnection = [JMXElement elementWithName:destinationPin.name];
        [newConnection addAttribute:[JMXAttribute attributeWithName:@"uid" stringValue:destinationPin.uid]];
        if (destinationPin.owner && [destinationPin.owner isKindOfClass:[JMXEntity class]])
            [newConnection addAttribute:[JMXAttribute attributeWithName:@"entity" stringValue:[destinationPin.owner uid]]];
        [self.connections addChild:newConnection];

        newConnection = [JMXElement elementWithName:self.name];
        [newConnection addAttribute:[JMXAttribute attributeWithName:@"uid" stringValue:self.uid]];
        if (self.owner && [self.owner isKindOfClass:[JMXEntity class]])
            [newConnection addAttribute:[JMXAttribute attributeWithName:@"entity" stringValue:[self.owner uid]]];
        [destinationPin.connections addChild:newConnection];
    }
    @synchronized(receivers) {
        /*if ([pinReceiver isProxy]) {
            [receivers setObject:pinSignal forKey:((JMXProxyPin *)pinReceiver).realPin];
        } else {*/
            [receivers setObject:pinSignal forKey:pinReceiver];
        //}
    }
    rv = YES;
    // deliver the signal to the just connected receiver
    if (rv == YES) {
        connected = YES;
        NSXMLNode *connectedAttribute = [self attributeForName:@"connected"];
        [connectedAttribute setStringValue:@"YES"];
        JMXPinSignal *signal = nil;
        signal = [JMXPinSignal signalFromSender:currentSender receiver:pinReceiver data:[self readData]];
        if (signal) // send the signal on-connect
            [self sendData:signal.data toReceiver:signal.receiver withSelector:pinSignal fromSender:currentSender];
    }
    return rv;
}

- (BOOL)connectToPin:(JMXInputPin *)destinationPin
{
    if ((JMXPin *)destinationPin != (JMXPin *)self && destinationPin.direction == kJMXInputPin)
        return [destinationPin connectToPin:self];
    return NO;
}

- (void)detachObject:(id)pinReceiver
{
    @synchronized(receivers) {
        /*if ([pinReceiver isProxy]) {
            [receivers removeObjectForKey:((JMXProxyPin *)pinReceiver).realPin];
        } else {*/
            [receivers removeObjectForKey:pinReceiver];
        //}
        if ([receivers count] == 0) {
            connected = NO;
            NSXMLNode *connectedAttribute = [self attributeForName:@"connected"];
            [connectedAttribute setStringValue:@"NO"];
        }
    }
}

// disconnection (as well as connection) happens always from the input pin to the output one 
- (void)disconnectFromPin:(JMXInputPin *)destinationPin
{
    [destinationPin disconnectFromPin:self];
    if (destinationPin.owner) {
        NSArray *children = [connections elementsForName:[destinationPin.owner description]];
        for (NSXMLElement *element in children) {
            if ([element.stringValue isEqualTo:destinationPin.label])
                [element detach];
        }
    }
}

- (void)disconnectAllPins
{
    NSArray *receiverObjects;
    @synchronized(receivers) {
        receiverObjects = [receivers allKeys];
        for (JMXPin *receiver in receiverObjects)
            [receiver disconnectFromPin:self];
    }
}

@end
