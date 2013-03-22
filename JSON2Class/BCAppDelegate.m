//
//  BCAppDelegate.m
//  JSON2Class
//
//  Created by Mac  on 13-3-15 .
//  Copyright (c) 2013年 Mac . All rights reserved.
//

#import "BCAppDelegate.h"
#import "BCEditViewController.h"

@interface BCAppDelegate () {
    BCEditViewController *editViewCtrl;
}

@end

@implementation BCAppDelegate



- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{

    self.window.title = @"JSON2Class";
    
    editViewCtrl = [[BCEditViewController alloc] initWithNibName:@"BCEditViewController"
                                                          bundle:nil];
    self.window.contentView = editViewCtrl.view;
    
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return YES;
}

- (IBAction)openDocument:(id)sender
{
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    [openPanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
        
        switch (result) {
            case NSFileHandlingPanelOKButton:
                [editViewCtrl openJSONFile:openPanel.URL.path];
                break;
                
            case NSFileHandlingPanelCancelButton:
                break;
                
            default:
                break;
        }
    }];

}

- (IBAction)saveDocument:(id)sender
{
    NSSavePanel *savePanel = [NSSavePanel savePanel];
    [savePanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
        
        switch (result) {
            case NSFileHandlingPanelOKButton:
                [editViewCtrl saveCodesToPath:savePanel.directoryURL.path
                                     withName:[savePanel.nameFieldStringValue stringByDeletingPathExtension]];
                break;
                
            case NSFileHandlingPanelCancelButton:
                break;
                
            default:
                break;
        }
    }];
}

@end
