//
//  RequestManager.h
//  i84Taoyuan
//
//  Created by TMS_APPLE on 2014/9/30.
//  Copyright (c) 2014年 Joe. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "ASINetworkQueue.h"
#import "ASIHTTPRequest.h"
#import "ShareTools.h"
#import "GDataXMLNode.h"

@protocol RequestManagerDelegate<NSObject>
@optional
-(void)requestManagerStartActivityIndicator;
-(void)requestManagerStopActivityIndicator;
-(void)requestManager:(id)requestManager fileDownloadedPath:(NSString*)path withKey:(NSString*)key;
//全部伺服器回應的error都接回來處理(不使用預設)
-(void)requestManager:(id)requestManager responseError:(NSString*)error withKey:(NSString*)key;
//除了err01,err02,err03以外伺服器回應的error
-(void)requestManager:(id)requestManager responseOtherError:(NSString*)error withKey:(NSString*)key;

-(void)requestManager:(id)requestManager returnXmlDoc:(GDataXMLDocument*)gdataXmlDoc withKey:(NSString*)key;
-(void)requestManager:(id)requestManager returnJSONSerialization:(NSJSONSerialization*)jsonSerialization withKey:(NSString*)key;
-(void)requestManager:(id)requestManager returnString:(NSString*)stringResponse withKey:(NSString*)key;

@required
@end

typedef enum _RequestDataType
{
    RequestDataTypeXML = 1,
    RequestDataTypeJson = 2,
    RequestDataTypeString = 3,
}
RequestDataType;

@interface RequestManager : NSObject
@property (strong, nonatomic) id<RequestManagerDelegate>delegate;
-(instancetype)initWithMaxRequestsQuantity:(NSUInteger)quantity;
-(instancetype)initWithRequestTimeout:(NSUInteger)timeout;

- (void) addRequestWithKey:(NSString*)key andUrl:(NSString*)url byType:(RequestDataType)type;
- (void) addFileRequestWithKey:(NSString*)key andUrl:(NSString*)url savedFileName:(NSString*)fileName;

@end
