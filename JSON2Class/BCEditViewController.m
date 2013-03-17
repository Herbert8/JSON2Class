//
//  BCEditViewController.m
//  JSON2Class
//
//  Created by Mac  on 13-3-15 .
//  Copyright (c) 2013年 Mac . All rights reserved.
//

#import "BCEditViewController.h"

@interface VOCode : NSObject

@property (nonatomic, strong) NSString *codeName;
@property (nonatomic, strong) NSString *headerCode;
@property (nonatomic, strong) NSString *implCode;

@end

@implementation VOCode
@end


@interface DictItem : NSObject

@property (nonatomic, strong) NSString *sKey;
@property (nonatomic, strong) NSDictionary *dict;

@end

@implementation DictItem

@end

@interface BCEditViewController () <NSTextDelegate, NSTextViewDelegate> {
    NSDictionary *codeTemplateDict;
    NSString *headerTemplate, *implTemplate;
    
    NSMutableArray *dictArray;
}

@end

@implementation BCEditViewController


#define KEY_INT_VALUE @"intValue"
#define KEY_FLOAT_VALUE @"floatValue"
#define KEY_STRING_VALUE @"stringValue"
#define KEY_BOOL_VALUE @"boolValue"
#define KEY_OBJECT_VALUE @"objectValue"
#define KEY_ARRAY_VALUE @"arrayValue"
#define KEY_CLASS_NAME @"className"
#define KEY_RELEASE_CODE @"releaseCode"

#define PLACE_HOLDER_DATA_NAME @"%DATA_NAME%"
#define PLACE_HOLDER_CLASS_NAME @"%CLASS_NAME%"

#define PLACE_HOLDER_CLASS_LIST @"%CLASS_LIST%"
#define PLACE_HOLDER_PROPERTY_LIST @"%PROPERTY_LIST%"

#define PLACE_HOLDER_RELEASE_NAME @"%RELEASE_NAME%"
#define PLACE_HOLDER_RELEASE_LIST @"%RELEASE_LIST%"

- (void)awakeFromNib
{

    dictArray = [NSMutableArray array];

    _tfJSON.delegate = self;

    _tfJSON.string = @" ";
    _tfCode.string = @" ";
    

    
    NSString *headerTemplateFileName = [[NSBundle mainBundle] pathForResource:@"header_template"
                                                                       ofType:@"txt"];
    NSString *implTemplateFileName = [[NSBundle mainBundle] pathForResource:@"impl_template"
                                                                     ofType:@"txt"];
    NSString *propertyTemplateFileName = [[NSBundle mainBundle] pathForResource:@"code_template"
                                                                        ofType:@"json"];
    
    NSError *err;
    codeTemplateDict = [self objectFromJsonFile:propertyTemplateFileName];
    headerTemplate = [NSString stringWithContentsOfFile:headerTemplateFileName
                                               encoding:NSUTF8StringEncoding
                                                  error:&err];
    implTemplate = [NSString stringWithContentsOfFile:implTemplateFileName
                                             encoding:NSUTF8StringEncoding
                                                error:&err];


}

- (NSString *)capitalizedFirstCharStr:(NSString *)str
{
    
    NSMutableString *newStr = [NSMutableString stringWithString:str];
    
    if (newStr.length > 0) {
        [newStr replaceCharactersInRange:NSMakeRange(0, 1)
                              withString:[[newStr substringToIndex:1] uppercaseString]];
    }
    
    return newStr;
}


- (void)textDidChange:(NSNotification *)notification
{
    
    id obj = [self objectFromJsonStr:_tfJSON.string];
    
    if ([obj isKindOfClass:[NSDictionary class]]) {
        [dictArray removeAllObjects];
        
        DictItem *dictItem = [DictItem new];
        dictItem.sKey = @"testData";
        dictItem.dict = obj;
        
        _tfCode.string = [self codeFromDict:dictItem].headerCode;
    } else {
        _tfCode.string = @" ";
    }
    
}

- (void)saveString:(NSString *)str toFile:(NSString *)fileName
{
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    [data writeToFile:fileName atomically:YES];
}

- (void)saveCodesToPath:(NSString *)path withName:(NSString *)fileName
{
    
    [dictArray removeAllObjects];
    
    DictItem *dictItem = [DictItem new];
    dictItem.sKey = fileName;
    dictItem.dict = [self objectFromJsonStr:_tfJSON.string];

    [dictArray addObject:dictItem];
    
    //    NSMutableArray *codeArray = [NSMutableArray array];
    
    int nIdx = 0;
    
    while (nIdx < dictArray.count) {
        //        [codeArray addObject:[self codeFromDict:((DictItem *)dictArray[nIdx]).dict]];
        VOCode *code = [self codeFromDict:dictArray[nIdx]];
        
        NSString *headerFileName = [path stringByAppendingFormat:@"/%@.h", [self getClassName:code.codeName]];
        NSString *implFileName = [path stringByAppendingFormat:@"/%@.m", [self getClassName:code.codeName]];
        
        [self saveString:code.headerCode toFile:headerFileName];
        [self saveString:code.implCode toFile:implFileName];

        if (nIdx == 0) {
            _tfCode.string = code.headerCode;
        }
        
        nIdx++;
    }
}

- (NSString *)getClassName:(NSString *)dataName
{
    NSString *ret = [codeTemplateDict valueForKey:KEY_CLASS_NAME];
    ret = [ret stringByReplacingOccurrencesOfString:PLACE_HOLDER_DATA_NAME
                                         withString:[self capitalizedFirstCharStr:dataName]];
    return ret;
}

- (VOCode *)codeFromDict:(DictItem *)dictItem
{

    
    NSString *propertyListStr = @"";
    NSString *classListStr = @"";

    NSMutableArray *releaseList = [NSMutableArray array];
    
    NSArray *allKeys = [dictItem.dict allKeys];
    for (NSString *sKey in allKeys) {
        id obj = [dictItem.dict valueForKey:sKey];
        
        NSString *propertyTemplateStr = @"";
        //数字
        if ([obj isKindOfClass:[NSNumber class]]) {
            NSNumber *num = obj;
            //整数类型
            if (num.intValue == num.floatValue) {
                propertyTemplateStr = [codeTemplateDict valueForKey:KEY_INT_VALUE];
            } else {
                //浮点数类型
                propertyTemplateStr = [codeTemplateDict valueForKey:KEY_FLOAT_VALUE];
            }
        }
        //字符串类型
        if ([obj isKindOfClass:[NSString class]]) {
            propertyTemplateStr = [codeTemplateDict valueForKey:KEY_STRING_VALUE];
            [releaseList addObject:sKey];
        }
        //对象类型
        if ([obj isKindOfClass:[NSDictionary class]]) {
            propertyTemplateStr = [codeTemplateDict valueForKey:KEY_OBJECT_VALUE];
            classListStr = [classListStr stringByAppendingFormat:@"\n@class %@;",
                            [self getClassName:sKey]];
            DictItem *dictItem = [DictItem new];
            dictItem.sKey = sKey;
            dictItem.dict = obj;
            
            [dictArray addObject:dictItem];
            [releaseList addObject:sKey];
        }
        //数组类型
        if ([obj isKindOfClass:[NSArray class]]) {
            propertyTemplateStr = [codeTemplateDict valueForKey:KEY_ARRAY_VALUE];
            [releaseList addObject:sKey];
        }
        //布尔类型
        if ([@"__NSCFBoolean" isEqualToString:NSStringFromClass([obj class])]) {
            propertyTemplateStr = [codeTemplateDict valueForKey:KEY_BOOL_VALUE];
        }
        
        propertyTemplateStr = [propertyTemplateStr stringByReplacingOccurrencesOfString:PLACE_HOLDER_DATA_NAME
                                                                             withString:sKey];
        
        propertyListStr = [propertyListStr stringByAppendingFormat:@"\n%@", propertyTemplateStr];
        
    }

    
    NSString *headerCodeStr = [headerTemplate stringByReplacingOccurrencesOfString:PLACE_HOLDER_CLASS_LIST
                                                               withString:classListStr];
    headerCodeStr = [headerCodeStr stringByReplacingOccurrencesOfString:PLACE_HOLDER_PROPERTY_LIST
                                                               withString:propertyListStr];
    headerCodeStr = [headerCodeStr stringByReplacingOccurrencesOfString:PLACE_HOLDER_DATA_NAME
                                                             withString:dictItem.sKey];
    headerCodeStr = [headerCodeStr stringByReplacingOccurrencesOfString:PLACE_HOLDER_CLASS_NAME
                                                             withString:[self getClassName:dictItem.sKey]];
    
    

    
    NSString *sReleaseCodeList = @"";
    for (NSString *sReleaseName in releaseList) {
        NSString *sReleaseCode = [codeTemplateDict valueForKey:KEY_RELEASE_CODE];
        sReleaseCode = [sReleaseCode stringByReplacingOccurrencesOfString:PLACE_HOLDER_RELEASE_NAME
                                                               withString:sReleaseName];
        sReleaseCodeList = [sReleaseCodeList stringByAppendingFormat:@"\n%@", sReleaseCode];
    }
    
    NSString *implCodeStr = [implTemplate stringByReplacingOccurrencesOfString:PLACE_HOLDER_CLASS_NAME
                                                                    withString:[self getClassName:dictItem.sKey]];
    implCodeStr = [implCodeStr stringByReplacingOccurrencesOfString:PLACE_HOLDER_RELEASE_LIST
                                                          withString:sReleaseCodeList];
    
    VOCode *ret = [VOCode new];
    ret.codeName = dictItem.sKey;
    ret.headerCode = headerCodeStr;
    ret.implCode = implCodeStr;
    
    return ret;
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

- (id)objectFromJsonFile:(NSString *)jsonFile
{
    
    NSData *data = [NSData dataWithContentsOfFile:jsonFile];
    
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

@end
