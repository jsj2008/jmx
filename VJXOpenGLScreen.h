//
//  VJXOpenGLScreen.h
//  VeeJay
//
//  Created by xant on 9/2/10.
//  Copyright 2010 Dyne.org. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "VJXScreen.h"
#import "VJXOpenGLView.h"

@interface VJXOpenGLScreen : VJXScreen {
@private
    NSWindow *window;
    VJXOpenGLView *view;
}

@property (readonly) NSWindow *window;
@property (readonly) VJXOpenGLView *view;

@end
