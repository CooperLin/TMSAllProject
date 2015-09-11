//
//  DataManager.h
//  i84-TaichungV2
//
//  Created by TMS_APPLE on 2014/9/22.
//  Copyright (c) 2014年 ＴＭＳ 景翊科技. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "sqlite3.h"


//若要增加請依下列原則
//0 初始值
//<-50 操作DB或Table失敗
typedef enum _DataManagerResult
{
    DataManagerResultNull = 0
    ,DataManagerResultSuccess = 1
    ,DataManagerResultFail = -1
    ,DataManagerResultFailOpenDB = -91
    ,DataManagerResultFailOpenTable = -92
    ,DataManagerResultExist = 51
    ,DataManagerResultNotExist = 50
    ,DataManagerResultError = -50
} DataManagerResult;
#define SqlDocumentsPath [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]


@interface DataManager : NSObject
//依傳入的dictionary的第一筆資料, Key當各欄位名稱
+ (DataManagerResult) createTableByDictionary:(NSDictionary*)dictionarySource withName:(NSString*)tableName toDataBase:(NSString*)dataBaseName;
//取得所有指定database指定table的所有資料
+ (NSMutableArray *)getDataFromTable:(NSString*)tableName fromDataBase:(NSString*)dataBaseName;
//刪除Dictionary資料(單筆)
+(DataManagerResult)deleteFromDictinary:(NSDictionary*)dictionaryDelete intoTable:(NSString*)tableName inDataBase:(NSString*)dataBaseName;
//新增Dictionary資料(單筆)
+(DataManagerResult)addFromDictinary:(NSDictionary*)dictionaryAdd intoTable:(NSString*)tableName inDataBase:(NSString*)dataBaseName;
//更新Dictionary資料(單筆)
+(DataManagerResult)updateFromDictinary:(NSDictionary*)dictionaryUpdate intoTable:(NSString*)tableName inDataBase:(NSString*)dataBaseName;
//確認Database中的Table是否存在
+(DataManagerResult)checkTableName:(NSString*)tableName fromDataBase:(NSString*)dataBaseName;
//確認單個item存在
+(DataManagerResult)checkFromDictionary:(NSDictionary*)dictionaryCheck intoTable:(NSString*)tableName inDataBase:(NSString*)dataBaseName;

//以上joe寫的,以下我寫的
+(DataManagerResult)deleteRoutePlanFromDictinary:(NSDictionary*)dictionaryDelete intoTable:(NSString*)tableName inDataBase:(NSString*)dataBaseName;



@end
