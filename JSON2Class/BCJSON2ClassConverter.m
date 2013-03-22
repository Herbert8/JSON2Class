//
//  BCJSON2ClassConverter.m
//  JSON2Class
//
//  Created by Mac  on 13-3-21 .
//  Copyright (c) 2013年 Mac . All rights reserved.
//

#import "BCJSON2ClassConverter.h"
#import "BCConfigReader.h"



@implementation VOCode
@end



@implementation FieldItem

@end

@interface BCJSON2ClassConverter () {
    
    BCConfigReader *cfgReader;
    
    NSMutableArray *fieldList;
}

@end

@implementation BCJSON2ClassConverter





#define PLACE_HOLDER_CLASS_LIST @"%CLASS_LIST%"
#define PLACE_HOLDER_PROPERTY_LIST @"%PROPERTY_LIST%"

#define PLACE_HOLDER_RELEASE_NAME @"%RELEASE_NAME%"
#define PLACE_HOLDER_RELEASE_LIST @"%RELEASE_LIST%"

#define PLACE_HOLDER_SETTER_LIST @"%SETTER_LIST%"

#define PLACE_HOLDER_IMPORT_LIST @"%IMPORT_LIST%"




- (id)init
{
    
    if (self = [super init]) {
        cfgReader = [[BCConfigReader alloc] init];
        fieldList = [NSMutableArray array];
    }
    
    return self;
}

- (void)clear
{
    [fieldList removeAllObjects];
}

- (void)saveString:(NSString *)str toFile:(NSString *)fileName
{
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    [data writeToFile:fileName atomically:YES];
}



- (VOCode *)saveCodeFromDictionary:(NSDictionary *)dict
                    toPath:(NSString *)path
                  withName:(NSString *)fileName
{

    [self clear];
    
    FieldItem *fieldItem = [FieldItem new];
    fieldItem.fieldName = fileName;
    fieldItem.fieldValue = dict;
    
//    [fieldList setValue:fieldItem.fieldValue forKey:fieldItem.fieldName];
    [fieldList addObject:fieldItem];

    
    VOCode *ret = nil;
    
    for (int nIdx = 0; nIdx < fieldList.count; nIdx++) {

        VOCode *code = [self codeFromDict:fieldList[nIdx]];
        
        NSString *sName = [cfgReader classNameByFieldName:code.codeName];
        NSString *headerFileName = [path stringByAppendingFormat:@"/%@.h", sName];
        NSString *implFileName = [path stringByAppendingFormat:@"/%@.m", sName];
        
        [self saveString:code.headerCode toFile:headerFileName];
        [self saveString:code.implCode toFile:implFileName];
        
        if (nIdx == 0) {
            ret = code;
        }
    }
    
    [self clear];
    
    return ret;
}

- (VOCode *)codeFromFieldItem:(FieldItem *)fieldItem
{
    
    [self clear];
    
    id ret = [self codeFromDict:fieldItem];
    
    [self clear];
    
    return ret;
}


- (VOCode *)codeFromDict:(FieldItem *)fieldItem
{
    
    
    NSString *propertyListStr = @"";
    NSString *classListStr = @"";
    NSString *setterListStr = @"";
    NSString *importListStr = @"";
    
    NSMutableArray *releaseList = [NSMutableArray array];
    
    NSArray *allKeys = [fieldItem.fieldValue allKeys];
    for (NSString *tmpFieldName in allKeys) {
        id obj = [fieldItem.fieldValue valueForKey:tmpFieldName];
        
        NSString *propertyTemplateStr = @"";
        //数字
        if ([obj isKindOfClass:[NSNumber class]]) {
            NSNumber *num = obj;
            //整数类型
            if (num.intValue == num.floatValue) {
                propertyTemplateStr = cfgReader.intPropertyTemplate;
            } else {
                //浮点数类型
                propertyTemplateStr = cfgReader.floatPropertyTemplate;
            }
        }
        //字符串类型
        if (obj == [NSNull null] || [obj isKindOfClass:[NSString class]]) {
            propertyTemplateStr = cfgReader.stringPropertyTemplate;
            [releaseList addObject:tmpFieldName];
        }
        //对象类型
        if ([obj isKindOfClass:[NSDictionary class]]) {
            propertyTemplateStr = cfgReader.objectPropertyTemplate;
            classListStr = [classListStr stringByAppendingFormat:@"\n@class %@;",
                            [cfgReader classNameByFieldName:tmpFieldName]];
            
            //如果是字典对象，则重新包装，放到列表中做后续处理
            FieldItem *newFieldItem = [FieldItem new];
            //为避免名称重复，采用 本Dict属性所属对象名+本Dict对应属性名 方式命名
            newFieldItem.fieldName = [NSString stringWithFormat:@"%@_%@",
                                      fieldItem.fieldName, tmpFieldName];
            newFieldItem.fieldValue = obj;
            
            //setter
            NSString *tmpSetter = [cfgReader commonReplace:cfgReader.dictionarySetterTemplate
                                             withFieldName:tmpFieldName];
            tmpSetter = [cfgReader commonReplace:tmpSetter
                        withOwnerObjectFieldName:fieldItem.fieldName];
            setterListStr = [setterListStr stringByAppendingString:tmpSetter];
            
            // import
            importListStr = [importListStr stringByAppendingFormat:@"\n#import \"%@.h\"",
                             [cfgReader classNameByFieldName:newFieldItem.fieldName]];
            

            [fieldList addObject:newFieldItem];
            [releaseList addObject:[cfgReader valueObjectNameByFieldName:tmpFieldName]];
        }
        //数组类型
        if ([obj isKindOfClass:[NSArray class]]) {
            
            NSArray *tmpArray = obj;
            if (tmpArray.count > 0 &&
                [[tmpArray objectAtIndex:0] isKindOfClass:[NSDictionary class]]) {
                
                propertyTemplateStr = cfgReader.objectArrayPropertyTemplate;
                FieldItem *newFieldItem = [FieldItem new];

                newFieldItem.fieldName = [cfgReader valueObjectItemInArrayFieldNameByFieldName:
                                          [NSString stringWithFormat:@"%@_%@",
                                           fieldItem.fieldName,
                                           tmpFieldName]];
                newFieldItem.fieldValue = [tmpArray objectAtIndex:0];
                
                // import
                importListStr = [importListStr stringByAppendingFormat:@"\n#import \"%@.h\"",
                                 [cfgReader classNameByFieldName:newFieldItem.fieldName]];
                [fieldList addObject:newFieldItem];
                
                //setter
                NSString *tmpSetter = [cfgReader commonReplace:cfgReader.arraySetterTemplate
                                                 withFieldName:tmpFieldName];
                tmpSetter = [cfgReader commonReplace:tmpSetter
                            withOwnerObjectFieldName:fieldItem.fieldName];
                setterListStr = [setterListStr stringByAppendingString:tmpSetter];
                
                [releaseList addObject:[cfgReader valueObjectArrayNameByFieldName:tmpFieldName]];
            } else {
                propertyTemplateStr = cfgReader.arrayPropertyTemplate;
            }
        }
        //布尔类型
        if ([@"__NSCFBoolean" isEqualToString:NSStringFromClass([obj class])]) {
            propertyTemplateStr = cfgReader.boolPropertyTemplate;
        }
        
        NSString *propertyStr = [cfgReader commonReplace:propertyTemplateStr
                                           withFieldName:tmpFieldName];

        propertyListStr = [propertyListStr stringByAppendingFormat:@"\n%@", propertyStr];
        
    }
    
    
    //替换类声明列表部分
    NSString *headerCodeStr = GetReplacedStr(cfgReader.headerTemplate,
                                             PLACE_HOLDER_CLASS_LIST,
                                             classListStr);
    
    //替换属性列表部分
    headerCodeStr = GetReplacedStr(headerCodeStr, PLACE_HOLDER_PROPERTY_LIST, propertyListStr);

    //通用替换，所有与 fieldName 相关的部分
    headerCodeStr = [cfgReader commonReplace:headerCodeStr withFieldName:fieldItem.fieldName];
    
    NSString *sReleaseCodeList = @"";
    for (NSString *sReleaseName in releaseList) {
        NSString *sReleaseCode = cfgReader.releaseTemplate;
        sReleaseCode = GetReplacedStr(sReleaseCode, PLACE_HOLDER_RELEASE_NAME, sReleaseName);
        sReleaseCodeList = [sReleaseCodeList stringByAppendingFormat:@"\n%@", sReleaseCode];
    }
    
    
    NSString *implCodeStr = [cfgReader commonReplace:cfgReader.implementationTemplate withFieldName:fieldItem.fieldName];
    implCodeStr = GetReplacedStr(implCodeStr, PLACE_HOLDER_RELEASE_LIST, sReleaseCodeList);
    implCodeStr = GetReplacedStr(implCodeStr, PLACE_HOLDER_SETTER_LIST, setterListStr);
    
    //import
    implCodeStr = GetReplacedStr(implCodeStr, PLACE_HOLDER_IMPORT_LIST, importListStr);
    
    
    VOCode *ret = [VOCode new];
    ret.codeName = fieldItem.fieldName;
    ret.headerCode = headerCodeStr;
    ret.implCode = implCodeStr;

    return ret;
}



@end
