//
//  BCJSON2ClassConverter.h
//  JSON2Class
//
//  Created by Mac  on 13-3-21 .
//  Copyright (c) 2013年 Mac . All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VOCode : NSObject

@property (nonatomic, strong) NSString *codeName;
@property (nonatomic, strong) NSString *headerCode;
@property (nonatomic, strong) NSString *implCode;

@end

@interface FieldItem : NSObject

@property (nonatomic, strong) NSString *fieldName;
@property (nonatomic, strong) NSDictionary *fieldValue;

@end


@interface BCJSON2ClassConverter : NSObject

- (VOCode *)codeFromFieldItem:(FieldItem *)fieldItem;

- (void)clear;

- (VOCode *)saveCodeFromDictionary:(NSDictionary *)dict
                            toPath:(NSString *)path
                          withName:(NSString *)fileName;

@end
