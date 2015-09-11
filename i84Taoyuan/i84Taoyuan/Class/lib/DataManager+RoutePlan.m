//
//  DataManager+RoutePlan.m
//  i84Taoyuan
//
//  Created by TMS on 2014/11/21.
//  Copyright (c) 2014年 TMS. All rights reserved.
//

#import "DataManager+RoutePlan.h"

#define KeyDatabaseRoutePlan @"RoutePlan"
#define KeyTableRoutePlan @"RoutePlan"

@implementation DataManager (RoutePlan)

+(DataManagerResult)CheckRoutePlanFromDictionary:(NSDictionary *) dictionaryOneInfo{
    return [DataManager checkFromDictionary:dictionaryOneInfo intoTable:KeyTableRoutePlan inDataBase:KeyDatabaseRoutePlan];
}

+(NSMutableArray *)getRoutePlanDataList
{
    return [DataManager getDataFromTable:KeyTableRoutePlan fromDataBase:KeyDatabaseRoutePlan];
}

+(NSDictionary *)getRoutePlanOneInfo:(NSString *) keyName
{
    NSDictionary * oneInfo = [NSDictionary new];
    NSMutableArray * arrayCollects = [NSMutableArray new];
    arrayCollects = [self getRoutePlanDataList];
    for(int i = 0;i < arrayCollects.count;i++) {
        if ([[[arrayCollects objectAtIndex:i] objectForKey:@"Name"] isEqualToString:keyName]) {
            oneInfo =[ arrayCollects objectAtIndex:i];
        }
    }
    
    return oneInfo;
}


+(DataManagerResult)addRoutePlanFromDictionary:(NSDictionary *)dictionaryOneInfo
{
    NSMutableArray * arrayCollects = [NSMutableArray new];
    
    DataManagerResult result = [DataManager CheckRoutePlanFromDictionary:dictionaryOneInfo];
    //    [self deleteRoutePlanFromDictionary:dictionaryOneInfo];
    if ( result == DataManagerResultFailOpenDB || result == DataManagerResultFailOpenTable || result == DataManagerResultNotExist )
    {
        arrayCollects = [self getRoutePlanDataList];
        for(int i = 0;i < arrayCollects.count;i++) {
            if ([[[arrayCollects objectAtIndex:i] objectForKey:@"Name"] isEqualToString:[dictionaryOneInfo objectForKey:@"Name"]]) {
                [self deleteRoutePlanFromDictionary:dictionaryOneInfo];
            }
        }
    }
    
    result = [DataManager addFromDictinary:dictionaryOneInfo intoTable:KeyTableRoutePlan inDataBase:KeyDatabaseRoutePlan];
    
    return result;
}

+(DataManagerResult)deleteRoutePlanFromDictionary:(NSDictionary *)dictionaryOneInfo
{
    return [DataManager deleteRoutePlanFromDictinary:dictionaryOneInfo intoTable:KeyTableRoutePlan inDataBase:KeyDatabaseRoutePlan];
}
@end
