//
//  DataManager+RoutePlan.h
//  i84Taoyuan
//
//  Created by TMS on 2014/11/21.
//  Copyright (c) 2014年 TMS. All rights reserved.
//

#import "DataManager.h"

@interface DataManager (RoutePlan)

//抓到所有我的收藏資料
+(NSMutableArray *)getRoutePlanDataList;
//抓取一個收藏點資料
+(NSDictionary *)getRoutePlanOneInfo:(NSString *) keyName;
//新增我的收藏
+(DataManagerResult)addRoutePlanFromDictionary:(NSDictionary*)dictionaryFavorite;
//刪除我的收藏
+(DataManagerResult)deleteRoutePlanFromDictionary:(NSDictionary*)dictionaryFavorite;

@end
