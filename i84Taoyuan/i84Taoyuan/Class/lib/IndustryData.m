//
//  IndustryData.m
//  i84Taoyuan
//
//  Created by TMS on 2014/11/25.
//  Copyright (c) 2014年 TMS. All rights reserved.
//

#import "IndustryData.h"
#import "SearchBusViewController2.h";

#define APIIndustry @"http://117.56.151.239/xmlbus3/StaticData/GetProvider.xml"

@interface IndustryData ()

@end

@implementation IndustryData

#pragma mark notification

+(void)getIndustryData
{
    NSURL * url = [NSURL URLWithString:APIIndustry];
    // 網路請求位置
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    // 請求方法默認Get
    [request setHTTPMethod:@"GET"];
    // 2.連接服務器
    // Response对象，用来得到返回后的数据，比如，用statusCode==200 来判断返回正常
    NSHTTPURLResponse *response;
    NSError * error = nil;
    // 3. 返回数据
    NSData * data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSXMLParser* xmlRead = [[NSXMLParser alloc] initWithData:data];//初始化NSXMLParser对象
    [xmlRead setDelegate:self];//设置NSXMLParser对象的解析方法代理
    [xmlRead parse];
    
    //    NSString *urlString=@"sfdsfhttp://www.baidu.com";
    //    //NSRegularExpression类里面调用表达的方法需要传递一个NSError的参数。下面定义一个
    //
    //    NSError * error;
    //http+:[^\\s]* 这个表达式是检测一个网址的。
    //    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"http+:[^\\s]*" options:0 error:&error];
    
    //    if (regex != nil) {
    //
    //         NSTextCheckingResult *firstMatch=[regex firstMatchInString:urlString options:0 range:NSMakeRange(0, [urlString length])];
    //
    //        if (firstMatch) {
    //            NSRange resultRange = [firstMatch rangeAtIndex:0]; //等同于 firstMatch.range --- 相匹配的范围
    //            //从urlString当中截取数据
    //
    //            NSString *result=[urlString substringWithRange:resultRange];
    //
    //            //输出结果
    //
    //            NSLog(@"這是我要看的%@",result);
    //
    //        }
    //    }
    
}

+(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    NSMutableDictionary * oneInfo = [NSMutableDictionary new];
    if([elementName isEqualToString: @"Provider"])
    {
        [oneInfo setObject:[attributeDict valueForKey:@"ID"] forKey:@"ID"];
        [oneInfo setObject:[attributeDict valueForKey:@"nameZh"] forKey:@"nameZh"];
        [oneInfo setObject:[attributeDict valueForKey:@"type"] forKey:@"type"];
    }
}

+(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    //    NSLog(@"結尾%@",elementName);
}

+(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    //    NSLog(@"解析______%@",string);
}

@end
