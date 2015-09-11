//
//  XMLParserObject.m
//  i84Taoyuan
//
//  Created by ＴＭＳ 景翊科技 on 2015/9/10.
//  Copyright (c) 2015年 TMS. All rights reserved.
//

#import "XMLParserObject.h"

@interface XMLParserObject()<NSXMLParserDelegate>{
    NSXMLParser *xmlParser;
}

@end

@implementation XMLParserObject

-(instancetype)initWithURL:(NSURL *)stringUrl andKeyType:(NSString *)str
{
    self = [super init];
    if(self){
        self.url = stringUrl;
        self.str = str;
        self.aryResult = [[NSMutableArray alloc] init];
        [self _startParseXMLFileFromURL];
    }
    return self;
}

-(void)_startParseXMLFileFromURL
{
    xmlParser = [[NSXMLParser alloc] initWithContentsOfURL:self.url];
    [xmlParser setDelegate:self];
    BOOL result = [xmlParser parse];
    
    NSLog(@"parse End and %ld data",(long)self.aryResult.count);
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
    if ( [elementName isEqualToString:@"Route"])
    {
        NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:attributeDict[@"ID"],@"ID",attributeDict[@"ProviderId"],@"ProviderId",attributeDict[@"nameZh"],@"nameZh",attributeDict[@"ddesc"],@"ddesc",attributeDict[@"departureZh"],@"departureZh",attributeDict[@"destinationZh"],@"destinationZh",attributeDict[@"gxcode"],@"gxcode",attributeDict[@"RouteType"],@"RouteType",attributeDict[@"MasterRouteName"],@"MasterRouteName",attributeDict[@"MasterRouteNo"],@"MasterRouteNo",attributeDict[@"MasterRouteDesc"],@"MasterRouteDesc", nil];
        
        if([@"CityRoute" isEqualToString:self.str]){
            if([@"免費巴士" isEqualToString:attributeDict[@"RouteType"]]){
                [self.aryResult addObject:dict];
            }
        }else if([@"RTYRoute" isEqualToString:self.str]){
            if([@"RTY" isEqualToString:attributeDict[@"RouteType"]]){
                [self.aryResult addObject:dict];
            }
        }else if([@"HighwayRoute" isEqualToString:self.str]){
            if([@"gz" isEqualToString:attributeDict[@"RouteType"]]){
                [self.aryResult addObject:dict];
            }
        }
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
//    NSString *tagName = @"column";
//    if([tagName isEqualToString:@"column"])
//    {
//        NSLog(@"Value %@",string);
//    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
//    NSLog(@"End elementName %@",elementName);
//    if ([elementName isEqualToString:@"Route"])
//    {
//      NSLog(@"rootelement end");
//    }
}

@end
