//
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
//  VJXDocument.m by Igor Sutton on 9/15/10.
//

#import "VJXDocument.h"
#import "VJXQtVideoLayer.h"
#import "VJXQtVideoCaptureLayer.h"
#import "VJXVideoMixer.h"
#import "VJXImageLayer.h"
#import "VJXOpenGLScreen.h"
#import "VJXBoard.h"
#import <QTKit/QTMovie.h>


@implementation VJXDocument

@synthesize board;
@synthesize entities;
@synthesize entitiesFromFile;
@synthesize entitiesPosition;

- (id)init
{
    if ((self = [super init]) != nil) {
        entities = [[NSMutableArray alloc] init];
        entitiesFromFile = [[NSMutableArray alloc] init];
        entitiesPosition = [[NSMutableDictionary alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(anEntityWasRemoved:) name:@"VJXEntityWasRemoved" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(anEntityWasMoved:) name:@"VJXEntityWasMoved" object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [board release];
    [entities release];
    [entitiesPosition release];
    [super dealloc];
}

#pragma mark -
#pragma mark NSDocument

- (NSString *)windowNibName
{
    return @"VJXDocument";
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    NSXMLElement *root = (NSXMLElement *)[NSXMLNode elementWithName:@"entities"];

    for (VJXEntity *entity in entities) {
        NSXMLElement *e = [NSXMLElement elementWithName:[entity className]];
        NSString *originString = [entitiesPosition objectForKey:entity];
        NSXMLElement *origin = [NSXMLElement elementWithName:@"origin"];
        [origin setStringValue:originString];
        [e addChild:origin];
        [root addChild:e];
    }
    
    NSXMLDocument *xmlDoc = [[NSXMLDocument alloc] initWithRootElement:root];
    [xmlDoc setVersion:@"1.0"];
    [xmlDoc setCharacterEncoding:@"UTF-8"];
    
    NSData *data = [xmlDoc XMLDataWithOptions:NSXMLDocumentXMLKind];

    [xmlDoc release];
    
    return data;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
    NSError *error = nil;
    NSXMLDocument *xmlDoc = [[NSXMLDocument alloc] initWithData:data options:NSXMLDocumentTidyXML error:&error];

    NSXMLNode *aNode = [[xmlDoc rootElement] nextNode];

    if (aNode) {
        while (1) {
            NSString *className = [aNode name];
            Class aClass = NSClassFromString(className);
            VJXEntity *entity = [[aClass alloc] init];
            NSXMLNode *origin = [aNode childAtIndex:0];
            [entitiesPosition setObject:[origin stringValue] forKey:entity];
            [entities addObject:entity];
            [entity release];
            if ((aNode = [aNode nextSibling]) == nil)
                break;
        }
    }

    [xmlDoc release];
    
    return YES;
}

- (void)windowControllerDidLoadNib:(NSWindowController *)windowController
{
    NSMutableDictionary *userInfo = nil;
    for (id e in entities) {
        userInfo = [NSMutableDictionary dictionary];
        [userInfo setObject:[entitiesPosition objectForKey:e] forKey:@"origin"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"VJXEntityWasCreated" object:e userInfo:userInfo];
    }
}

#pragma mark -
#pragma mark Interface Builder actions

- (IBAction)addQTVideoLayer:(id)sender
{
    NSArray *types = [QTMovie movieTypesWithOptions:QTIncludeCommonTypes];
    VJXQtVideoLayer *entity = [[VJXQtVideoLayer alloc] init];
    [self openFileWithTypes:types forEntity:entity];
}

- (IBAction)addVideoMixer:(id)sender
{
    VJXVideoMixer *entity = [[VJXVideoMixer alloc] init];
    [entities addObject:entity];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"VJXEntityWasCreated" object:entity];
    [entity release];
}

- (IBAction)addImageLayer:(id)sender
{
    NSArray *types = [NSImage imageTypes];
    VJXImageLayer *entity = [[VJXImageLayer alloc] init];
    [entities addObject:entity];
    [self openFileWithTypes:types forEntity:entity];
}

- (IBAction)addOpenGLScreen:(id)sender
{
    VJXOpenGLScreen *entity = [[VJXOpenGLScreen alloc] init];
    [entities addObject:entity];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"VJXEntityWasCreated" object:entity];
    [entity release];
}

- (IBAction)addQtCaptureLayer:(id)sender
{
    VJXQtVideoCaptureLayer *entity = [[VJXQtVideoCaptureLayer alloc] init];
    [entities addObject:entity];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"VJXEntityWasCreated" object:entity];
    [entity release];
}

- (IBAction)removeSelected:(id)sender
{
    [board removeSelected:sender];
}

#pragma mark -
#pragma mark Open file

- (void)openFileWithTypes:(NSArray *)types forEntity:(VJXEntity *)entity
{
    
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel beginSheetForDirectory:nil
                             file:nil
                            types:types
                   modalForWindow:[self windowForSheet]
                    modalDelegate:self
                   didEndSelector:@selector(openPanelDidEnd:returnCode:entity:)
                      contextInfo:entity];
    [panel setCanChooseFiles:YES];
}

- (void)openPanelDidEnd:(NSOpenPanel *)panel returnCode:(int)returnCode entity:(VJXEntity *)entity
{
    if (returnCode == NSCancelButton) {
        [entity release];
        return;
    }
    
    NSString *filename = [panel filename];
    
    if (filename && [entity respondsToSelector:@selector(open:)]) {
        [entity performSelector:@selector(open:) withObject:filename];
    }
    
    [entities addObject:entity];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"VJXEntityWasCreated" object:entity];
    
    [entity release];
}

#pragma mark -
#pragma mark Notifications

- (void)anEntityWasRemoved:(NSNotification *)aNotification
{
    VJXEntity *entity = [aNotification object];
    [entities removeObject:entity];
    [entitiesPosition removeObjectForKey:entity];
}

- (void)anEntityWasMoved:(NSNotification *)aNotification
{
    VJXBoardEntity *entity = [aNotification object];
    NSString *origin = [[aNotification userInfo] objectForKey:@"origin"];
    [entitiesPosition setObject:origin forKey:entity.entity];
}

@end