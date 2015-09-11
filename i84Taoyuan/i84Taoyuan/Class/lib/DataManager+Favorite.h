//
//  DataManager+Favorite.h
//  i84Taoyuan
//
//  Created by TMS_APPLE on 2014/8/6.
//  Copyright (c) 2014年 TMS. All rights reserved.
//

#import "DataManager.h"

//依API內的名稱定義
#define KeyRouteID @"PathId"
#define KeyRouteName @"PathName"
#define KeyToward @"GoBack"
#define KeyStopID @"StopId"
#define KeyStopName @"StopName"
#define KeyDestination @"Dest"
#define KeyDeparture @"Dept"
//#define KeyLatitude @"Lat"
//#define KeyLongitude @"Lon"

@interface DataManager (Favorite)
//取得List
+(NSMutableArray*)favoriteGetData;

//arrayData structure
//[{id:key,id2:key2,...},{},...]
//+(DataManagerResult)favoriteUpdateTableFromArray:(NSArray*)arrayData;

//新增我的最愛
+(DataManagerResult)favoriteAddFromDictionary:(NSDictionary*)dictionaryFavorite;

//刪除我的最愛
+(DataManagerResult)favoriteDeleteFromDictionary:(NSDictionary*)dictionaryFavorite;

//確認我的最愛是否存在
+(DataManagerResult)favoriteCheckFromDictionary:(NSDictionary*)dictionaryFavorite;

@end
