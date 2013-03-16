//
//  BCEditViewController.h
//  JSON2Class
//
//  Created by Mac  on 13-3-15 .
//  Copyright (c) 2013年 Mac . All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface BCEditViewController : NSViewController

@property (unsafe_unretained) IBOutlet NSTextView *tfJSON;
@property (unsafe_unretained) IBOutlet NSTextView *tfCode;

- (void)openJSONFile:(NSString *)fileName;
- (void)saveCodesToPath:(NSString *)path withName:(NSString *)fileName;

@end
