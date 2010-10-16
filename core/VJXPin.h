//
//  VJXConnector.h
//  VeeJay
//
//  Created by xant on 9/2/10.
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

#import <Cocoa/Cocoa.h>
#import "VJXSize.h"
#import "VJXPoint.h"
#import "VJXAudioBuffer.h"

@class VJXEntity;

typedef enum {
    kVJXVoidPin,
    kVJXStringPin,
    kVJXNumberPin,
    kVJXImagePin,
    kVJXAudioPin,
    kVJXPointPin,
    kVJXSizePin,
} VJXPinType;

typedef enum {
    kVJXInputPin,
    kVJXOutputPin,
    kVJXAnyPin
} VJXPinDirection;

@interface VJXPin : NSObject <NSCopying> {
@private
    VJXPinType          type;
    NSString            *name;
    NSMutableDictionary *receivers;
    NSMutableArray      *producers;
    NSMutableDictionary *properties;
    BOOL                multiple; // default NO
    BOOL                continuous; // default YES
    BOOL                retainData; // default YES
    BOOL                buffered; // default NO
    id                  currentData;
    id                  currentSender;
    VJXPinDirection     direction;
    id                  owner;
    id                  minValue;
    id                  maxValue;
    NSString            *ownerSignal;
    NSMutableArray      *allowedValues;
}

@property (readonly)  VJXPinType type;
@property (readonly)  NSString *name;
@property (readonly)  BOOL multiple;
@property (readonly)  VJXPinDirection direction;
@property (readonly)  NSArray *producers;
@property (readonly)  NSDictionary *receivers;
@property (readonly)  NSArray *allowedValues;
@property (readwrite) BOOL continuous;
@property (readwrite) BOOL retainData;
@property (readwrite) BOOL buffered;
@property (readonly) id owner;
@property (readonly) id minValue;
@property (readonly) id maxValue;

+ (id)pinWithName:(NSString *)name
          andType:(VJXPinType)pinType
     forDirection:(VJXPinDirection)pinDirection 
          ownedBy:(id)pinOwner 
       withSignal:(NSString *)pinSignal;

+ (id)pinWithName:(NSString *)name
          andType:(VJXPinType)pinType
     forDirection:(VJXPinDirection)pinDirection 
          ownedBy:(id)pinOwner 
       withSignal:(NSString *)pinSignal
    allowedValues:(NSArray *)allowedValues;

- (id)initWithName:(NSString *)pinName
           andType:(VJXPinType)pinType
      forDirection:(VJXPinDirection)pinDirection
           ownedBy:(id)pinOwner
        withSignal:(NSString *)pinSignal;

- (id)initWithName:(NSString *)pinName
           andType:(VJXPinType)pinType
      forDirection:(VJXPinDirection)pinDirection
           ownedBy:(id)pinOwner
        withSignal:(NSString *)pinSignal
     allowedValues:(NSArray *)pinValues;

- (BOOL)connectToPin:(VJXPin *)destinationPin;
- (void)disconnectFromPin:(VJXPin *)destinationPin;
- (void)disconnectAllPins;
- (void)deliverSignal:(id)data fromSender:(id)sender;
- (void)deliverSignal:(id)data;
- (void)allowMultipleConnections:(BOOL)choice;
- (NSArray *)producers;
- (NSArray *)readProducers;
- (id)readPinValue;
- (NSString *)typeName;
- (BOOL)moveProducerFromIndex:(NSUInteger)src toIndex:(NSUInteger)dst;
- (NSString *)description;
- (void)addAllowedValue:(id)value;
- (void)removeAllowedValue:(id)value;
- (void)addMinLimit:(id)minValue;
- (void)addMaxLimit:(id)maxValue;
@end
