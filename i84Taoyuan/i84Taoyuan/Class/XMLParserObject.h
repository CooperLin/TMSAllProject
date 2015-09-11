//
//  XMLParserObject.h
//  i84Taoyuan
//
//  Created by ＴＭＳ 景翊科技 on 2015/9/10.
//  Copyright (c) 2015年 TMS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XMLParserObject : NSObject

@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) NSString *str;
@property (nonatomic, strong) NSMutableArray *aryResult;

-(instancetype)initWithURL:(NSURL *)stringUrl andKeyType:(NSString *)str;

@end
