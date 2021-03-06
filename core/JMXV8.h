//
//  JMXV8.h
//  JMX
//
//  Created by xant on 11/14/10.
//  Copyright 2010 Dyne.org. All rights reserved.
//
/*!
 @header JMXV8.h
 @abstract Protocol for V8-aware classes
 */
#import <Cocoa/Cocoa.h>

/*!
 @protocol JMXV8
 @discussion Any native class exported to V8 must conform to this protocol.
             the JMXScript class (which manages bindings between javascript and native instances)
             will expect mapped classes to conform to this protocol.
 */
@protocol JMXV8

#ifdef __JMXV8__
#include <v8.h>

@required

/*!
 @method jsObjectTemplate
 @return a V8 Persistent<FunctionTemplate> which represents the prototype for the exported javascript class 
 */
+ (v8::Persistent<v8::FunctionTemplate>)jsObjectTemplate;

@optional

/*!
 @method jsObjectTemplateAddons:
 @param objectTemplate 
 @discussion If implemented, this message will be called when the object template is created.
             It is mainly intended for categories which could want to expose new methods to javascript
             (for instance the JMXEntity (Threaded) category which adds the start() and stop() methods
             to the basic JMXEntity functionalities
 */
+ (void)jsObjectTemplateAddons:(v8::Handle<v8::FunctionTemplate>)objectTemplate;

/*!
 @method jsRegisterClassMethods:
 @param constructor The constructor FunctionTemplate where to attach class methods
 @discussion If implemented, this message will be called when the constructor is registered
             into the javascript global context. 
 */
+ (void)jsRegisterClassMethods:(v8::Handle<v8::FunctionTemplate>)constructor;

/*!
 @method jsObj
 @return a javascript wrapper object instance
 */
- (v8::Handle<v8::Object>)jsObj;

/*!
 @method jsInit:
 @param argsValue arguments passed to the constructor
 @discussion This message is sent at construction time and can 
             be implemented to make use of possible arguments 
             passed to the constructor from javascript
 @return a javascript wrapper object instance
 */
- (void)jsInit:(NSValue *)argsValue;

#define JMXV8_EXPORT_BASE(__class) \
using namespace v8;\
static Persistent<FunctionTemplate> objectTemplate;\
\

#define JMXV8_EXPORT_PERSISTENT_CLASS(__class) \
JMXV8_EXPORT_BASE(__class)\
void __class##JSDestructor(Persistent<Value> object, void *parameter)\
{\
    NSLog(@"V8 WeakCallback called");\
    __class *obj = static_cast<__class *>(parameter);\
    Local<Context> currentContext  = v8::Context::GetCurrent();\
    JMXScript *ctx = [JMXScript getContext:currentContext];\
    if (ctx) {\
        /* this will destroy the javascript object as well */\
        [ctx removePersistentInstance:obj];\
    } else {\
        NSLog(@"Can't find context to attach persistent instance (just leaking)");\
    }\
}\
\
v8::Handle<Value> __class##JSConstructor(const Arguments& args)\
{\
    HandleScope handleScope;\
    Persistent<Object> jsInstance;\
    if (objectTemplate.IsEmpty())\
        objectTemplate = [__class jsObjectTemplate];\
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];\
    __class *instance = nil;\
    v8::Local<Context> currentContext = v8::Context::GetCalling();\
    JMXScript *ctx = [JMXScript getContext:currentContext];\
    if (ctx) {\
        instance = [[__class alloc] jmxInit];\
        /* connect the entity to our scriptEntity */\
        [ctx.scriptEntity addChild:instance];\
        if ([instance respondsToSelector:@selector(jsInit:)]) {\
            NSValue *argsValue = [NSValue valueWithPointer:(void *)&args];\
            [instance performSelector:@selector(jsInit:) withObject:argsValue];\
        }\
        jsInstance = Persistent<Object>::New(objectTemplate->InstanceTemplate()->NewInstance());\
        /* make the handle weak, with a callback */\
        jsInstance.MakeWeak(instance, &__class##JSDestructor);\
        /*instancesMap[instance] = jsInstance;*/\
        jsInstance->SetPointerInInternalField(0, instance);\
        [ctx addPersistentInstance:jsInstance obj:instance];\
        [instance release];\
    } else {\
        NSLog(@"Can't find context to attach persistent instance (just leaking)");\
    }\
    [pool drain];\
    if (!jsInstance.IsEmpty())\
        return handleScope.Close(jsInstance);\
    else\
        return handleScope.Close(Undefined());\
}

#define JMXV8_EXPORT_CLASS(__class) \
JMXV8_EXPORT_BASE(__class)\
void __class##JSDestructor(Persistent<Value> object, void *parameter)\
{\
    HandleScope handle_scope;\
    v8::Locker lock;\
    id obj = static_cast<id>(parameter);\
    /*NSLog(@"V8 WeakCallback called on %@", obj); */\
    [obj release];\
    if (!object.IsEmpty()) {\
        object.ClearWeak();\
        object.Dispose();\
        object.Clear();\
    }\
}\
\
v8::Handle<Value> __class##JSConstructor(const Arguments& args)\
{\
    HandleScope handleScope;\
    Persistent<Object> jsInstance;\
    if (objectTemplate.IsEmpty())\
        objectTemplate = [__class jsObjectTemplate];\
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];\
    __class *instance = [[__class alloc] jmxInit];\
    /* connect the entity to our scriptEntity */\
    if ([instance respondsToSelector:@selector(jsInit:)]) {\
        NSValue *argsValue = [NSValue valueWithPointer:(void *)&args];\
        [instance performSelector:@selector(jsInit:) withObject:argsValue];\
    }\
    jsInstance = Persistent<Object>::New(objectTemplate->InstanceTemplate()->NewInstance());\
    /* make the handle weak, with a callback */\
    jsInstance.MakeWeak(instance, &__class##JSDestructor);\
    /*instancesMap[instance] = jsInstance;*/\
    jsInstance->SetPointerInInternalField(0, instance);\
    [instance release];\
    [pool drain];\
    if (!jsInstance.IsEmpty())\
        return handleScope.Close(jsInstance);\
    else\
        return handleScope.Close(Undefined());\
}

#define JMXV8_DECLARE_CONSTRUCTOR(__class)\
v8::Handle<v8::Value> __class##JSConstructor(const v8::Arguments& args);

#else

/*!
 @define JMXV8_EXPORT_NODE_CLASS
 @abstract define both the constructor and the descructor for the mapped class
 @param __class
 */
#define JMXV8_EXPORT_CLASS(__class)
/*!
 @define JMXV8_DECLARE_NODE_CONSTRUCTOR
 @abstract define the constructor for the mapped class
 @param __class
 */
#define JMXV8_DECLARE_CONSTRUCTOR(__class)

#endif

@end