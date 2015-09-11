//
//  DataManager+Location.h
//  i84Taoyuan
//
//  Created by TMS_APPLE on 2014/9/21.
//  Copyright (c) 2014年 TMS. All rights reserved.
//

#import "DataManager.h"

//#define KeyLocationName @"Name"
//#define KeyLocationLatitude @"Lat"
//#define KeyLocationLongitude @"Lon"

@interface DataManager (Location)
+(NSMutableArray*)locationGetData;

//新增
+(DataManagerResult)locationAddFromDictionary:(NSDictionary*)dictionary;

//刪除
+(DataManagerResult)locationDeleteFromDictionary:(NSDictionary*)dictionary;

////確認是否存在
//+(DataManagerResult)favoriteCheckFromDictionary:(NSDictionary*)dictionary;

@end
