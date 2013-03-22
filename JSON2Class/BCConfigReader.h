//
//  BCConfigReader.h
//  JSON2Class
//
//  Created by Mac  on 13-3-21 .
//  Copyright (c) 2013年 Mac . All rights reserved.
//

#import <Foundation/Foundation.h>

#define GetReplacedStr(str, toBeReplacedStr, withNewStr) \
[str stringByReplacingOccurrencesOfString:toBeReplacedStr withString:withNewStr]

@interface BCConfigReader : NSObject

@property (readonly) NSString *classNamePrefix;
@property (readonly) NSString *classNamePostfix;

@property (readonly) NSString *headerTemplate;
@property (readonly) NSString *implementationTemplate;
@property (readonly) NSString *dictionarySetterTemplate;
@property (readonly) NSString *arraySetterTemplate;
@property (readonly) NSString *releaseTemplate;

@property (readonly) NSString *intPropertyTemplate;
@property (readonly) NSString *floatPropertyTemplate;
@property (readonly) NSString *stringPropertyTemplate;
@property (readonly) NSString *boolPropertyTemplate;
@property (readonly) NSString *objectPropertyTemplate;
@property (readonly) NSString *arrayPropertyTemplate;
@property (readonly) NSString *objectArrayPropertyTemplate;

- (NSString *)capitalizedFieldName:(NSString *)fieldName;
- (NSString *)classNameByFieldName:(NSString *)fieldName;
- (NSString *)valueObjectNameByFieldName:(NSString *)fieldName;
- (NSString *)valueObjectArrayNameByFieldName:(NSString *)fieldName;
- (NSString *)commonReplace:(NSString *)str withFieldName:(NSString *)fieldName;

@end
