//
//  DataManager+Location.m
//  i84Taoyuan
//
//  Created by TMS_APPLE on 2014/9/21.
//  Copyright (c) 2014年 TMS. All rights reserved.
//

#import "DataManager+Location.h"

#define KeyDatabaseName @"Location"
#define KeyTableName @"Location"

@implementation DataManager (Location)
+(NSMutableArray *)locationGetData
{
    return [DataManager getDataFromTable:KeyTableName fromDataBase:KeyDatabaseName];
}
//+(DataManagerResult)locationCheckFromDictionary:(NSDictionary *)dictionaryLocation
//{
//    NSMutableDictionary * dictionaryOne = [NSMutableDictionary new];
//    [dictionaryOne setObject:[dictionaryLocation objectForKey:KeyToward] forKey:KeyToward];
//    [dictionaryOne setObject:[dictionaryLocation objectForKey:KeyRouteID] forKey:KeyRouteID];
//    [dictionaryOne setObject:[dictionaryLocation objectForKey:KeyStopID] forKey:KeyStopID];
//    
//    return [DataManager checkFromDictionary:dictionaryOne intoTable:KeyTableName inDataBase:KeyDatabaseName];
//}
+(DataManagerResult)locationAddFromDictionary:(NSDictionary *)dictionaryLocation
{
//    NSMutableDictionary * dictionaryOne = [NSMutableDictionary new];

//        [dictionaryOne setObject:[dictionaryLocation objectForKey:KeyLocationName] forKey:KeyLocationName];
//        [dictionaryOne setObject:[dictionaryLocation objectForKey:KeyLocationLatitude] forKey:KeyLocationLatitude];
//        [dictionaryOne setObject:[dictionaryLocation objectForKey:KeyLocationLongitude] forKey:KeyLocationLongitude];
    
       DataManagerResult  result = [DataManager addFromDictinary:dictionaryLocation intoTable:KeyTableName inDataBase:KeyDatabaseName];
    return result;
}
+(DataManagerResult)locationDeleteFromDictionary:(NSDictionary *)dictionaryLocation
{
//    NSMutableDictionary * dictionaryOne = [NSMutableDictionary new];
//    [dictionaryOne setObject:[dictionaryLocation objectForKey:KeyLocationName] forKey:KeyLocationName];
//    [dictionaryOne setObject:[dictionaryLocation objectForKey:KeyLocationLatitude] forKey:KeyLocationLatitude];
//    [dictionaryOne setObject:[dictionaryLocation objectForKey:KeyLocationLongitude] forKey:KeyLocationLongitude];
    
    return [DataManager deleteFromDictinary:dictionaryLocation intoTable:KeyTableName inDataBase:KeyDatabaseName];
}

@end
