//
//  BCConfigReader.m
//  JSON2Class
//
//  Created by Mac  on 13-3-21 .
//  Copyright (c) 2013年 Mac . All rights reserved.
//

#import "BCConfigReader.h"

@interface BCConfigReader () {
    NSDictionary *codeTemplateDict;
}

@end

@implementation BCConfigReader

#define KEY_INT_TEMPLATE @"KEY_INT_TEMPLATE"
#define KEY_FLOAT_TEMPLATE @"KEY_FLOAT_TEMPLATE"
#define KEY_STRING_TEMPLATE @"KEY_STRING_TEMPLATE"
#define KEY_BOOL_TEMPLATE @"KEY_BOOL_TEMPLATE"
#define KEY_OBJECT_TEMPLATE @"KEY_OBJECT_TEMPLATE"
#define KEY_ARRAY_TEMPLATE @"KEY_ARRAY_TEMPLATE"
#define KEY_OBJECT_ARRAY_TEMPLATE @"KEY_OBJECT_ARRAY_TEMPLATE"



#define KEY_CLASS_NAME @"KEY_CLASS_NAME"
#define KEY_OBJECT_VO_NAME @"KEY_OBJECT_VO_NAME"
#define KEY_RELEASE_CODE_TEMPLATE @"KEY_RELEASE_CODE_TEMPLATE"
#define KEY_CLASS_NAME_PREFIX @"KEY_CLASS_NAME_PREFIX"
#define KEY_CLASS_NAME_POSTFIX @"KEY_CLASS_NAME_POSTFIX"
#define KEY_OBJECT_ARRAY_NAME @"KEY_OBJECT_ARRAY_NAME"

#define PLACE_HOLDER_FIELD_NAME @"%FIELD_NAME%"
#define PLACE_HOLDER_CAPITALIZED_FIELD_NAME @"%CAPITALIZED_FIELD_NAME%"
#define PLACE_HOLDER_CLASS_NAME_PREFIX @"%CLASS_NAME_PREFIX%"
#define PLACE_HOLDER_CLASS_NAME_POSTFIX @"%CLASS_NAME_POSTFIX%"
#define PLACE_HOLDER_CLASS_NAME @"%CLASS_NAME%"

#define GetResPath(name, type) [[NSBundle mainBundle] \
                                pathForResource:name \
                                ofType:type]

#define GetStringFromFile(name, type) [self stringFromFile:GetResPath(name, type)]



- (NSString *)stringFromFile:(NSString *)fileName
{
    NSError *err;
    NSString *ret = [NSString stringWithContentsOfFile:fileName
                                     encoding:NSUTF8StringEncoding
                                        error:&err];
    return ret;
}

- (id)init
{

    if (self = [super init]) {
        NSString *propertyTemplateFileName = GetResPath(@"code_template", @"json");
        codeTemplateDict = [self objectFromJsonFile:propertyTemplateFileName];
        
        _headerTemplate = GetStringFromFile(@"header_template", @"txt");
        
        _implementationTemplate = GetStringFromFile(@"impl_template", @"txt");
        
        _dictionarySetterTemplate = GetStringFromFile(@"dict_setter_template", @"txt");
        
        _arraySetterTemplate = GetStringFromFile(@"array_setter_template", @"txt");

    }
    
    return self;
    
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

- (NSString *)intPropertyTemplate
{
	return [codeTemplateDict valueForKey:KEY_INT_TEMPLATE];
}

- (NSString *)floatPropertyTemplate
{
	return [codeTemplateDict valueForKey:KEY_FLOAT_TEMPLATE];
}

- (NSString *)stringPropertyTemplate
{
	return [codeTemplateDict valueForKey:KEY_STRING_TEMPLATE];
}

- (NSString *)boolPropertyTemplate
{
	return [codeTemplateDict valueForKey:KEY_BOOL_TEMPLATE];
}

- (NSString *)objectPropertyTemplate
{
	return [codeTemplateDict valueForKey:KEY_OBJECT_TEMPLATE];
}

- (NSString *)classNamePrefix
{
    return [codeTemplateDict valueForKey:KEY_CLASS_NAME_PREFIX];
}

- (NSString *)classNamePostfix
{
    return [codeTemplateDict valueForKey:KEY_CLASS_NAME_POSTFIX];
}

- (NSString *)releaseTemplate
{
    return [codeTemplateDict valueForKey:KEY_RELEASE_CODE_TEMPLATE];
}

- (NSString *)arrayPropertyTemplate
{
    return [codeTemplateDict valueForKey:KEY_ARRAY_TEMPLATE];
}

- (NSString *)objectArrayPropertyTemplate
{
    return [codeTemplateDict valueForKey:KEY_OBJECT_ARRAY_TEMPLATE];
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

- (NSString *)capitalizedFieldName:(NSString *)fieldName
{
    return [self capitalizedFirstCharStr:fieldName];
}

- (NSString *)classNameByFieldName:(NSString *)fieldName
{
    NSString *ret = codeTemplateDict[KEY_CLASS_NAME];

    ret = [self commonReplace:ret withFieldName:fieldName];
    
    return ret;

}

- (NSString *)commonReplace:(NSString *)str withFieldName:(NSString *)fieldName
{
    str = GetReplacedStr(str, PLACE_HOLDER_FIELD_NAME, fieldName);
    str = GetReplacedStr(str, PLACE_HOLDER_CAPITALIZED_FIELD_NAME,
                         [self capitalizedFieldName:fieldName]);
    str = GetReplacedStr(str, PLACE_HOLDER_CLASS_NAME_PREFIX, self.classNamePrefix);
    str = GetReplacedStr(str, PLACE_HOLDER_CLASS_NAME_POSTFIX, self.classNamePostfix);
    
    return str;
}

- (NSString *)valueObjectNameByFieldName:(NSString *)fieldName
{
    NSString *ret = codeTemplateDict[KEY_OBJECT_VO_NAME];
    
    ret = [self commonReplace:ret withFieldName:fieldName];
    
    return ret;
}

- (NSString *)valueObjectArrayNameByFieldName:(NSString *)fieldName
{
    NSString *ret = codeTemplateDict[KEY_OBJECT_ARRAY_NAME];

    ret = [self commonReplace:ret withFieldName:fieldName];
    
    return ret;
}



@end
