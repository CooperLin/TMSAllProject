//
//  DataManager+Favorite.m
//  i84Taoyuan
//
//  Created by TMS_APPLE on 2014/8/6.
//  Copyright (c) 2014年 TMS. All rights reserved.
//

#import "DataManager+Favorite.h"

#define KeyDatabaseFavorites @"Favorites"
#define KeyTableFavorites @"Favorites"



@implementation DataManager (Favorite)
+(NSMutableArray *)favoriteGetData
{
    return [DataManager getDataFromTable:KeyTableFavorites fromDataBase:KeyDatabaseFavorites];
}
+(DataManagerResult)favoriteCheckFromDictionary:(NSDictionary *)dictionaryFavorite
{
    NSMutableDictionary * dictionaryOne = [NSMutableDictionary new];
    [dictionaryOne setObject:[dictionaryFavorite objectForKey:KeyToward] forKey:KeyToward];
    [dictionaryOne setObject:[dictionaryFavorite objectForKey:KeyRouteID] forKey:KeyRouteID];
    [dictionaryOne setObject:[dictionaryFavorite objectForKey:KeyStopID] forKey:KeyStopID];
    
    return [DataManager checkFromDictionary:dictionaryOne intoTable:KeyTableFavorites inDataBase:KeyDatabaseFavorites];
}
+(DataManagerResult)favoriteAddFromDictionary:(NSDictionary *)dictionaryFavorite
{
    NSMutableDictionary * dictionaryOne = [NSMutableDictionary new];
    [dictionaryOne setObject:[dictionaryFavorite objectForKey:KeyToward] forKey:KeyToward];
    [dictionaryOne setObject:[dictionaryFavorite objectForKey:KeyRouteID] forKey:KeyRouteID];
    [dictionaryOne setObject:[dictionaryFavorite objectForKey:KeyStopID] forKey:KeyStopID];
    
    DataManagerResult result = [DataManager favoriteCheckFromDictionary:dictionaryOne];
    
    if ( result == DataManagerResultFailOpenDB || result == DataManagerResultFailOpenTable || result == DataManagerResultNotExist )
    {
        [dictionaryOne setObject:[dictionaryFavorite objectForKey:KeyStopName] forKey:KeyStopName];
        [dictionaryOne setObject:[dictionaryFavorite objectForKey:KeyRouteName] forKey:KeyRouteName];
        [dictionaryOne setObject:[dictionaryFavorite objectForKey:KeyDeparture] forKey:KeyDeparture];
        [dictionaryOne setObject:[dictionaryFavorite objectForKey:KeyDestination] forKey:KeyDestination];
//        [dictionaryOne setObject:[dictionaryFavorite objectForKey:KeyLongitude] forKey:KeyLongitude];
//        [dictionaryOne setObject:[dictionaryFavorite objectForKey:KeyLatitude] forKey:KeyLatitude];
        
        result = [DataManager addFromDictinary:dictionaryOne intoTable:KeyTableFavorites inDataBase:KeyDatabaseFavorites];
    }
    return result;
}
+(DataManagerResult)favoriteDeleteFromDictionary:(NSDictionary *)dictionaryFavorite
{
    NSMutableDictionary * dictionaryOne = [NSMutableDictionary new];
    [dictionaryOne setObject:[dictionaryFavorite objectForKey:KeyToward] forKey:KeyToward];
    [dictionaryOne setObject:[dictionaryFavorite objectForKey:KeyRouteID] forKey:KeyRouteID];
    [dictionaryOne setObject:[dictionaryFavorite objectForKey:KeyStopID] forKey:KeyStopID];
    
    return [DataManager deleteFromDictinary:dictionaryOne intoTable:KeyTableFavorites inDataBase:KeyDatabaseFavorites];
}
@end
