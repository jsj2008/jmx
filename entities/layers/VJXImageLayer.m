//
//  VJXImageLayer.m
//  VeeJay
//
//  Created by Igor Sutton on 8/25/10.
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

#import "VJXImageLayer.h"
#import <QTKit/QTKit.h>


@implementation VJXImageLayer

@synthesize imagePath, image;

- (id)init
{
    if (self = [super init]) {
        self.image = nil;
        self.frequency = [NSNumber numberWithDouble:1]; // override frequency
    }
    return self;
}

- (BOOL)open:(NSString *)file
{
    if (file) {
        @synchronized(self) {
            self.imagePath = file;
            NSData *imageData = [[NSData alloc] initWithContentsOfFile:self.imagePath];
            if (imageData) {
                self.image = [CIImage imageWithData:imageData];
                NSArray *path = [file componentsSeparatedByString:@"/"];
                self.name = [path lastObject];
                return YES;
            }
        }
    }
    return NO;
}

- (void)tick:(uint64_t)timeStamp
{
    if (self.image) {
        @synchronized(self) {
            // XXX - it's useless to render the image each time ... 
            //       it should be done only if image parameters have changed
            if (self.image) {
                CIImage *frame = self.image;
                CGRect imageRect = [frame extent];
                // scale the image to fit the layer size, if necessary
                if (size.width != imageRect.size.width || size.height != imageRect.size.height) {
                    CIFilter *scaleFilter = [CIFilter filterWithName:@"CIAffineTransform"];
                    float xScale = size.width / imageRect.size.width;
                    float yScale = size.height / imageRect.size.height;
                    // TODO - take scaleRatio into account for further scaling requested by the user
                    NSAffineTransform *transform = [NSAffineTransform transform];
                    [transform scaleXBy:xScale yBy:yScale];
                    [scaleFilter setDefaults];
                    [scaleFilter setValue:transform forKey:@"inputTransform"];
                    [scaleFilter setValue:frame forKey:@"inputImage"];
                    frame = [scaleFilter valueForKey:@"outputImage"];
                }
                if (currentFrame)
                    [currentFrame release];
                currentFrame = [frame retain];
            }
        }
    }
    [super tick:timeStamp];
}

#pragma mark -

- (NSString *)displayName
{
    return [NSString stringWithFormat:@"%@", self.imagePath];
}

#pragma mark -
#pragma mark NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:imagePath forKey:@"VJXImageLayerImagePath"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [self init];
    [self open:[aDecoder decodeObjectForKey:@"VJXImageLayerImagePath"]];
    return self;
}

@end
