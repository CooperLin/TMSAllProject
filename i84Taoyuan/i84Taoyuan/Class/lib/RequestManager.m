//
//  RequestManager.m
//  i84Taoyuan
//
//  Created by TMS_APPLE on 2014/9/30.
//  Copyright (c) 2014年 Joe. All rights reserved.
//

#import "RequestManager.h"
typedef enum _RequestDataTypePrivate
{
    RequestDataTypePrivateXML = 1,
    RequestDataTypePrivateJson = 2,
    RequestDataTypePrivateString = 3,
    RequestDataTypePrivateFile = 9
}
RequestDataTypePrivate;

//save the request data
@interface RequestData : NSObject
@property (strong, nonatomic) NSString * url;
@property (strong, nonatomic) NSString * key;
@property (assign) NSUInteger tag;
@property (assign) RequestDataTypePrivate type;
@property (strong, nonatomic) NSString * fileName;
@property (assign) NSUInteger failCount;
@property (assign) id delegate;
@end

@implementation RequestData

@end

@implementation RequestManager
{
    ASINetworkQueue * queueASIRequests;
    NSMutableDictionary * dictionaryHistory;
    NSUInteger integerArrayIndex;
    NSUInteger integerQueryFail;
    NSUInteger integerTimeout;
    UIAlertView * alertView;
}
-(id)init
{
    self = [super init];
    
    if (self)
    {
        queueASIRequests = [[ASINetworkQueue alloc] init];
        [queueASIRequests setShouldCancelAllRequestsOnFailure:NO];
    }
    return self;
}
-(instancetype)initWithMaxRequestsQuantity:(NSUInteger)quantity
{
    self = [self init];
    if (self)
    {
        queueASIRequests.maxConcurrentOperationCount = (NSInteger)quantity;
    }
    return self;
}
-(instancetype)initWithRequestTimeout:(NSUInteger)timeout
{
    self = [self init];
    if (self)
    {
        integerTimeout = timeout;
    }
    return self;
}
#pragma mark - poblic method
- (void) addFileRequestWithKey:(NSString*)stringKey andUrl:(NSString*)stringUrl savedFileName:(NSString*)fileName
{
    RequestData * requestData = [RequestData new];
    requestData.type = RequestDataTypePrivateFile;
    requestData.key = stringKey;
    requestData.url = stringUrl;
    requestData.fileName = fileName;
    requestData.delegate = self.delegate;
    
    [self sendRequestWithData:requestData];
}
- (void) addRequestWithKey:(NSString*)stringKey andUrl:(NSString*)stringUrl byType:(RequestDataType)type
{
    RequestData * requestData = [RequestData new];
    requestData.type = (RequestDataTypePrivate)type;
    requestData.key = stringKey;
    requestData.url = stringUrl;
    requestData.delegate = self.delegate;
    
    [self sendRequestWithData:requestData];
}

#pragma mark - Private method
- (void)sendRequestWithData:(RequestData*)requestData
{
    if ( ![ShareTools connectedToNetwork] )
    {
		return;
	}
    
    //queue裡面確認,避免重複送request
    if (queueASIRequests.operationCount)
    {
        for (ASIHTTPRequest * requestTmp in queueASIRequests.operations)
        {
            if ([requestTmp.identifyKey isEqualToString:requestData.key])
            {
                return;
            }
        }
    }
    
    if([queueASIRequests isSuspended])
    {
        [queueASIRequests go];
    }

    //    [NSThread detachNewThreadSelector:@selector(startActivityIndicator) toTarget:self withObject:nil];
    NSURL *url = [NSURL URLWithString:[requestData.url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
	ASIHTTPRequest * QueryRequest = [ASIHTTPRequest requestWithURL:url];
    [QueryRequest setDelegate:self];
    switch (requestData.type)
    {
        case RequestDataTypePrivateFile:
        {
            //取得document path
            NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString * stringDocumentsDirectory = [paths objectAtIndex:0];
            
            //若fileName不存在 則使用File.tmp
            NSString * stringFileNameWithPath;
            NSString * stringFileName = requestData.fileName;
            NSError * errorFileManager;
            if (!stringFileName)
            {
                int index = 1;
                do
                {
                    stringFileNameWithPath =[NSString stringWithFormat:@"%@/%@",stringDocumentsDirectory,[NSString stringWithFormat:@"%@%1d.tmp",@"File",index++]];
                    if (index >= 10)
                    {
                        index = 1;
                    }
                    NSString * stringFileNameWithPathTmp =[NSString stringWithFormat:@"%@/%@",stringDocumentsDirectory,[NSString stringWithFormat:@"%@%1d.tmp",@"tmpFile",index]];
                    [[NSFileManager defaultManager]removeItemAtPath:stringFileNameWithPathTmp error:&errorFileManager];
//#ifdef debug
                    NSLog(@"remove file error%@",errorFileManager);
//#endif
                }
                //判斷檔案是否存在
                while ([[NSFileManager defaultManager]fileExistsAtPath:stringFileNameWithPath]&&index<10);
            }
            NSString * stringPath = [stringDocumentsDirectory stringByAppendingPathComponent:stringFileName];
            [QueryRequest setDownloadDestinationPath:stringPath];
        }
            break;
            
        default:
            break;
    }
    [QueryRequest setDidFinishSelector:@selector(QueryRequestFinish:)];
    [QueryRequest setDidFailSelector:@selector(QueryRequestFail:)];
    
    //timeout預設30
    if (!integerTimeout)
    {
        integerTimeout = 30;
    }
    [QueryRequest setTimeOutSeconds:(float)integerTimeout];
    
    //queue裡面確認,避免重複送request
    QueryRequest.identifyKey = requestData.key;
    
    if (self.delegate)
    {
        if ([self.delegate respondsToSelector:@selector(requestManagerStartActivityIndicator)])
        {
            [self.delegate requestManagerStartActivityIndicator];
        }
    }
    
    [queueASIRequests addOperation:QueryRequest];
    
    if (!dictionaryHistory)
    {
        dictionaryHistory = [NSMutableDictionary new];
    }
    [dictionaryHistory setObject:requestData forKey:requestData.key];
    
//#ifdef LogOut
    NSLog(@"RequestStr:%@",url);
//#endif
}

-(void) QueryRequestFinish :(ASIHTTPRequest *)request
{
    RequestData * requestData = [dictionaryHistory objectForKey:request.identifyKey];
//    [dictionaryHistory removeObjectForKey:request.identifyKey];
    
    NSString * stringResponse = [request responseString];
    
    if([stringResponse hasPrefix:@"err"])
    {
        //若delegate有接這個錯誤則不自動處理
        //err03查無資料,err01參數錯誤,err02無參數
        if (self.delegate && [self.delegate respondsToSelector:@selector(requestManager:responseError:withKey:)])
        {
            [self.delegate requestManager:self responseError:stringResponse withKey:request.identifyKey];
        }
        else if ([stringResponse hasPrefix:@"err01"]||[stringResponse hasPrefix:@"err02"])
        {
            NSString * stringMessage = [NSString stringWithFormat:@"參數錯誤"];
            [alertView dismissWithClickedButtonIndex:0 animated:NO];
            alertView = [[UIAlertView alloc]initWithTitle:stringMessage message:stringMessage delegate:nil cancelButtonTitle:@"確認" otherButtonTitles:nil];
            [alertView show];
        }
        else if ([stringResponse hasPrefix:@"err03"])
        {
            NSString * stringMessage = [NSString stringWithFormat:@"查無資料"];
            [alertView dismissWithClickedButtonIndex:0 animated:NO];
            alertView = [[UIAlertView alloc]initWithTitle:stringMessage message:stringMessage delegate:nil cancelButtonTitle:@"確認" otherButtonTitles:nil];
            [alertView show];
        }
        else if ([stringResponse hasPrefix:@"err04"])
        {
            [alertView dismissWithClickedButtonIndex:0 animated:NO];
            alertView = [[UIAlertView alloc]initWithTitle:@"提醒" message:@"資料已存在" delegate:nil cancelButtonTitle:@"確認" otherButtonTitles:nil];
            [alertView show];
        }
        else
        {
            if (self.delegate && [self.delegate respondsToSelector:@selector(requestManager:responseOtherError:withKey:)])
            {
                [self.delegate requestManager:self responseOtherError:stringResponse withKey:request.identifyKey];
            }
            else
            {
                [self QueryRequestFail:request];
                return;
            }
        }
    }
    else
    {
        NSError * error;
        id idRecieved;
        switch (requestData.type)
        {
            case RequestDataTypePrivateJson:
            {
                idRecieved = [NSJSONSerialization JSONObjectWithData:[request responseData] options:NSJSONReadingMutableLeaves error:&error];
                
                if (idRecieved != nil)
                {
                    if (requestData.delegate)
                    {
                        if ([requestData.delegate respondsToSelector:@selector(requestManager:returnJSONSerialization:withKey:)])
                        {
                            [requestData.delegate requestManager:self returnJSONSerialization:idRecieved withKey:request.identifyKey];
                        }
                    }
                }
            }
                break;
            case RequestDataTypePrivateXML:
            {
                if([stringResponse hasPrefix:@"<?xml"])
                {
                    idRecieved = [[GDataXMLDocument alloc] initWithData:request.responseData options:0 error:&error];
                    if(idRecieved == nil)
                    {
                        [self QueryRequestFail:request];
                        return;
                    }
                    else
                    {
                        if (requestData.delegate)
                        {
                            if ([requestData.delegate respondsToSelector:@selector(requestManager:returnXmlDoc:withKey:)])
                            {
                                [requestData.delegate requestManager:self returnXmlDoc:idRecieved withKey:request.identifyKey];
                            }
                        }
                    }
                }
                else
                {
                    [self QueryRequestFail:request];
                }

            }
                break;
            case RequestDataTypePrivateString:
            {
                if (![stringResponse hasPrefix:@"<html"])
                {
                    if (requestData.delegate && [requestData.delegate respondsToSelector:@selector(requestManager:returnString:withKey:)])
                    {
                        [requestData.delegate requestManager:self returnString:stringResponse withKey:request.identifyKey];
                    }
                }
            }
                break;
            case RequestDataTypePrivateFile:
            {
                NSString * stringFilePath = request.downloadDestinationPath;

                if (self.delegate)
                {
                    if ([requestData.delegate respondsToSelector:@selector(requestManager:fileDownloadedPath:withKey:)])
                    {
                        
                        [requestData.delegate requestManager:self fileDownloadedPath:stringFilePath withKey:requestData.key];
                    }
                }
            }
                break;
                
            default:
                break;
        }
        if (error)
        {
            NSLog(@"error msg %@",error);
//            [self QueryRequestFail:request];
//            return;
        }

    }
    
    if (queueASIRequests.operationCount==0)
    {
        [queueASIRequests setSuspended:YES];
        //        [NSThread detachNewThreadSelector:@selector(stopActivityIndicator) toTarget:self withObject:nil];
        if (self.delegate && [self.delegate respondsToSelector:@selector(requestManagerStopActivityIndicator)])
            {
                [self.delegate requestManagerStopActivityIndicator];
            }
    }
}
-(void)QueryRequestFail:(ASIHTTPRequest *)request
{
    RequestData * requestData =[dictionaryHistory objectForKey:request.identifyKey];
    
    if (requestData.failCount < 5)
    {
        requestData.failCount++;
        [self sendRequestWithData:[dictionaryHistory objectForKey:request.identifyKey]];
        return;
    }
    else
    {
//#ifdef LogOut
        NSLog(@"Query fail %ld",(long)request.tag);
        NSLog(@"Query fail url:%@",request.url);
//#endif
        requestData.failCount = 0;
        if (queueASIRequests.operationCount==0)
        {
            [queueASIRequests setSuspended:YES];
        }
        [alertView dismissWithClickedButtonIndex:0 animated:NO];
        alertView = [[UIAlertView alloc]initWithTitle:@"無法連接伺服器" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        if (self.delegate)
        {
            if ([self.delegate respondsToSelector:@selector(requestManagerStopActivityIndicator)])
            {
                [self.delegate requestManagerStopActivityIndicator];
            }
        }
    }
}
@end

