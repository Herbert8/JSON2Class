//
//  BCEditViewController.m
//  JSON2Class
//
//  Created by Mac  on 13-3-15 .
//  Copyright (c) 2013年 Mac . All rights reserved.
//

#import "BCEditViewController.h"
#import "BCJSON2ClassConverter.h"


@interface BCEditViewController () <NSTextDelegate, NSTextViewDelegate>
@end

@implementation BCEditViewController
{
    BCJSON2ClassConverter *converter;
}





- (void)awakeFromNib
{


    _tfJSON.delegate = self;

    _tfJSON.string = @" ";
    _tfCode.string = @" ";
    
    converter = [[BCJSON2ClassConverter alloc] init];
    
}

- (FieldItem *)objectFromJSONTextView
{
    
    id ret = nil;
    id obj = [self objectFromJsonStr:_tfJSON.string];
    
    if ([obj isKindOfClass:[NSDictionary class]]) {
        
        FieldItem *fieldItem = [FieldItem new];
        fieldItem.fieldName = @"testData";
        fieldItem.fieldValue = obj;
        
        ret = fieldItem;
    }
    
    return ret;
}


- (void)textDidChange:(NSNotification *)notification
{
    
    FieldItem *fieldItem = [self objectFromJSONTextView];
    
    if (fieldItem) {
        _tfCode.string = [converter codeFromFieldItem:fieldItem].headerCode;
    } else {
        _tfCode.string = @" ";
    }
    
}



- (id)objectFromJsonStr:(NSString *)jsonStr
{
    
    NSData *data = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError *err;
    id obj = [NSJSONSerialization JSONObjectWithData:data
                                             options:NSJSONReadingAllowFragments
                                               error:&err];
    if (err) obj = nil;
    
    return obj;
}



- (void)openJSONFile:(NSString *)fileName
{
    NSError *err;
    NSString *jsonStr = [NSString stringWithContentsOfFile:fileName
                                                encoding:NSUTF8StringEncoding
                                                   error:&err];
    if (!err) {
        _tfJSON.string = jsonStr;
        [self textDidChange:nil];
    }
    
}

- (void)saveCodesToPath:(NSString *)path withName:(NSString *)fileName
{
    FieldItem *fieldItem = [self objectFromJSONTextView];
    if (fieldItem) {
        VOCode *code = [converter saveCodeFromDictionary:fieldItem.fieldValue
                                                  toPath:path
                                                withName:fileName];
        _tfCode.string = code.headerCode;
    } else {
        _tfCode.string = @" ";
    }
}

@end
