//
//  DataManager+Route.m
//  i84-TaichungV2
//
//  Created by TMS_APPLE on 2014/9/28.
//  Copyright (c) 2014年 ＴＭＳ 景翊科技. All rights reserved.
//

#import "DataManager+Route.h"
#define KeyDatabaseRoutes @"Routes"
#define KeyTableRoutes @"Routes"

//departureZh,destinationZh,type,ddesc,ProviderId,gxcode,nameZh(route),ID(route)


#define sqlSelectData @"SELECT * FROM %@ WHERE %@='%@'"

@implementation DataManager (Route)
+(NSMutableArray *)routeGetData
{
    if ([DataManager routeCheckUpdatedToday])
    {
        return [DataManager getDataFromTable:KeyTableRoutes fromDataBase:KeyDatabaseRoutes];
    }
    return nil;
}
+(BOOL)routeCheckUpdatedToday
{
    BOOL boolCheckResult = NO;
    if ([DataManager checkTableExist])
    {
        NSDateFormatter * dateFormatter = [NSDateFormatter new];
        [dateFormatter setDateFormat:@"YYYYMMdd"];
        NSString * stringDate = [dateFormatter stringFromDate:[NSDate date]];
        boolCheckResult = [[[NSUserDefaults standardUserDefaults]objectForKey:KeyTableRoutes]isEqualToString:stringDate];
    }
    return boolCheckResult;
}
+(DataManagerResult)routeUpdateTableFromArray:(NSArray*)arrayData
{
    //將資料存入sqlite
    if ([DataManager routeCheckUpdatedToday])
    {
        return DataManagerResultExist;
    }
    [DataManager createTableByDictionary:[arrayData objectAtIndex:0] withName:KeyTableRoutes toDataBase:KeyDatabaseRoutes];

    for (id idDictionary in arrayData)
    {
        if([DataManager updateFromDictinary:(NSDictionary*)idDictionary intoTable:KeyTableRoutes inDataBase:KeyDatabaseRoutes] == DataManagerResultFail)
        {
            return DataManagerResultFail;
        }
    }
    NSDateFormatter * dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"YYYYMMdd"];
    NSString * stringDate = [dateFormatter stringFromDate:[NSDate date]];
    [[NSUserDefaults standardUserDefaults]setObject:stringDate forKey:KeyTableRoutes];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
    return DataManagerResultSuccess;
}


+(NSArray*)selectRouteDataKeyWord:(NSString*)stringKeyWord byColumnTitle:(RouteDataColumnType)routeDataColumnType
{
    NSString * stringColumn;
    switch (routeDataColumnType)
    {
        case RouteDataColumnTypeRouteID:
            stringColumn = KeyRouteID;
            break;
        case RouteDataColumnTypeRouteName:
            stringColumn = KeyRouteName;
            break;
            
        default:
            break;
    }
    NSMutableArray * arrayData = [[NSMutableArray alloc] init];
    sqlite3_stmt *statement = nil;
    sqlite3* database = nil;
    if (sqlite3_open([[SqlDocumentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"Routes.sqlite"]] UTF8String], &database) != SQLITE_OK)
    {
		sqlite3_close(database);
		NSAssert(0, @"Failed to open database");
	}
    if (sqlite3_prepare_v2(database, [[NSString stringWithFormat:sqlSelectData,KeyTableRoutes,stringColumn,stringKeyWord] UTF8String], -1, &statement, nil) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            NSMutableDictionary * dictionary = [NSMutableDictionary new];
            int intColumnCount = sqlite3_column_count(statement);
            
            for (int i = 0; i < intColumnCount; i++)
            {
                id idObject = nil;
                NSString * stringColumnTitle = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_name(statement, i)];
                switch (sqlite3_column_type(statement, i))
                {
                    case SQLITE3_TEXT:
                    {
                        idObject = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement, i)];
                        
                    }
                        break;
                    case SQLITE_INTEGER:
                    {
                        idObject = [[NSNumber alloc] initWithInt:sqlite3_column_int(statement, i)];
                        
                    }
                        break;
                    case SQLITE_FLOAT:
                    {
                        idObject = [[NSNumber alloc] initWithDouble:sqlite3_column_double(statement, i)];
                        
                    }
                        break;
                        
                    default:
                        break;
                }
                [dictionary setObject:idObject forKey:stringColumnTitle];
            }
            [arrayData addObject:dictionary];
        }
        
    }
    if(statement)
    {
        sqlite3_finalize(statement);
        statement = nil;
    }
    
    if(database)
    {
        sqlite3_close(database);
        database = nil;
    }
    
    if (arrayData.count>0)
    {
        return arrayData;
    }
    return nil;

}
+(BOOL)checkTableExist
{
    NSLog(@"Document Path \n%@",SqlDocumentsPath);
    return [DataManager checkTableName:KeyTableRoutes fromDataBase:KeyDatabaseRoutes];
}
@end
