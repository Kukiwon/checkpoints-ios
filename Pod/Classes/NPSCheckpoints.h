//
//  NPSCheckpoints.h
//  Pods
//
//  Created by Jordy van Kuijk on 07/04/15.
//
//

#import <Foundation/Foundation.h>
#import <LoopBack/LoopBack.h>

typedef void (^LoginCallback)();
typedef void (^Callback)();

@interface NPSCheckpoints : NSObject

@property (nonatomic, retain) NSString* username;
@property (nonatomic, retain) NSString* password;
@property (nonatomic, strong) NSString* url;

@property (nonatomic, strong) LBAccessToken* accessToken;
@property (nonatomic, strong) LBRESTAdapter* adapter;
@property (nonatomic, strong) LBModel* project;
@property (nonatomic, strong) LBModel* session;
@property (nonatomic, strong) NSMutableArray *checkpointQueue;
@property (nonatomic, retain) LBModelRepository *checkpointRepo;


+ (id) SDK;
- (void) initWithUsername: (NSString *) username andPassword: (NSString *) password andProjectId: (NSString *) projectId andSessionIdentifier: (NSString *) sessionIdentifier;
- (void) initWithUsername:(NSString *)username andPassword:(NSString *)password andProjectId:(NSString *)projectId andSessionIdentifier:(NSString *)sessionIdentifier andUrl: (NSString *) url;
- (void) initWithUsername:(NSString *)username andPassword:(NSString *)password andProjectId:(NSString *)projectId andSessionIdentifier:(NSString *)sessionIdentifier andUrl: (NSString *) url withSuccess: (LoginCallback) success andFailure: (LoginCallback) fail;

- (void) startSessionWithIdentifier: (NSString *) identifier;
- (void) startSessionWithIdentifier: (NSString *) identifier withSuccess: (Callback) success andFail: (Callback) fail;
- (void) checkPoint: (NSString *) identifier;
- (void) batchSendCheckpoints;

@end
