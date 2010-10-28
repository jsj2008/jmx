//
//  VJXTextRenderer.h
//  VeeJay
//
//  Created by xant on 10/26/10.
//  Copyright 2010 Dyne.org. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <OpenGL/CGLContext.h>
#include <QuartzCore/CVPixelBuffer.h>

@interface VJXTextRenderer : NSObject {
    CGLContextObj cgl_ctx; // current context at time of texture creation
    GLuint texName;
    NSSize texSize;
    
    NSAttributedString * string;
    NSColor * textColor; // default is opaque white
    NSColor * boxColor; // default transparent or none
    NSColor * borderColor; // default transparent or none
    BOOL staticFrame; // default in NO
    BOOL antialias;	// default to YES
    NSSize marginSize; // offset or frame size, default is 4 width 2 height
    NSSize frameSize; // offset or frame size, default is 4 width 2 height
    float	cRadius; // Corner radius, if 0 just a rectangle. Defaults to 4.0f
    NSImage * image;
    NSBitmapImageRep * bitmap;
    BOOL requiresUpdate;
}

// this API requires a current rendering context and all operations will be performed in regards to thar context
// the same context should be current for all method calls for a particular object instance

// designated initializer
- (id) initWithAttributedString:(NSAttributedString *)attributedString;

- (id) initWithString:(NSString *)aString withFont:font withTextColor:(NSColor *)text BoxColor:(NSColor *)box BorderColor:(NSColor *)border;
- (id) initWithString:(NSString *)aString withAttributes:(NSDictionary *)attribs;

- (void) dealloc;

- (GLuint) texName; // 0 if no texture allocated
- (NSSize) texSize; // actually size of texture generated in texels, (0, 0) if no texture allocated

- (NSColor *) textColor; // get the pre-multiplied default text color (includes alpha) string attributes could override this
- (NSColor *) boxColor; // get the pre-multiplied box color (includes alpha) alpha of 0.0 means no background box
- (NSColor *) borderColor; // get the pre-multiplied border color (includes alpha) alpha of 0.0 means no border
- (BOOL) staticFrame; // returns whether or not a static frame will be used

- (NSSize) frameSize; // returns either dynamc frame (text size + margins) or static frame size (switch with staticFrame)

- (NSSize) marginSize; // current margins for text offset and pads for dynamic frame

// these will force the texture to be regenerated at the next draw
- (void) setMargins:(NSSize)size; // set offset size and size to fit with offset
- (void) useStaticFrame:(NSSize)size; // set static frame size and size to frame
- (void) useDynamicFrame; // set static frame size and size to frame

- (void) setString:(NSAttributedString *)attributedString; // set string after initial creation
- (void) setString:(NSString *)aString withAttributes:(NSDictionary *)attribs; // set string after initial creation

- (void) setTextColor:(NSColor *)color; // set default text color
- (void) setBoxColor:(NSColor *)color; // set default text color
- (void) setBorderColor:(NSColor *)color; // set default text color

- (BOOL) antialias;
- (void) setAntialias:(bool)request;

- (CVPixelBufferRef) drawOnBuffer:(CVPixelBufferRef)pixelBuffer;
        
@end
