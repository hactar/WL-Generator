//
//  wlAppDelegate.h
//  WL Generator
//
//  Created by patrick on 29/08/2013.
//  Copyright (c) 2013 patrick. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface wlAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (unsafe_unretained) IBOutlet NSTextView *textView;

@end
