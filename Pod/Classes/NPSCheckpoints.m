//
//  NPSCheckpoints.m
//  Pods
//
//  Created by Jordy van Kuijk on 07/04/15.
//
//

#import "NPSCheckpoints.h"
#import "Constants.h"

@implementation NPSCheckpoints

@synthesize username = _username, password = _password;
@synthesize accessToken = _accessToken;
@synthesize adapter = _adapter;
@synthesize project = _project;
@synthesize session = _session;
@synthesize url = _url;
@synthesize checkpointQueue = _checkpointQueue;
@synthesize checkpointRepo = _checkpointRepo;

// singleton pattern
+ (id)SDK {
    static NPSCheckpoints *sdk = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sdk = [[self alloc] init];
    });
    return sdk;
}

- (id) init {
    if(self = [super init]) {
        _url = @"http://localhost:8081/api";
        _checkpointQueue = [[NSMutableArray alloc] initWithCapacity:10];
        [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(batchSendCheckpoints) userInfo:nil repeats:YES];
    }
    return self;
}

- (void) initWithUsername: (NSString *) username andPassword: (NSString *) password andProjectId: (NSString *) projectId andSessionIdentifier:(NSString *)sessionIdentifier {
    
    [self initWithUsername:username andPassword:password andProjectId:projectId andSessionIdentifier:sessionIdentifier andUrl:_url];
}

- (void) initWithUsername:(NSString *)username andPassword:(NSString *)password andProjectId:(NSString *)projectId andSessionIdentifier:(NSString *)sessionIdentifier andUrl:(NSString *)url {
    [self initWithUsername:username andPassword:password andProjectId:projectId andSessionIdentifier:sessionIdentifier andUrl:url withSuccess:nil andFailure:nil];
}

- (void) initWithUsername:(NSString *)username andPassword:(NSString *)password andProjectId:(NSString *)projectId andSessionIdentifier:(NSString *)sessionIdentifier andUrl:(NSString *)url withSuccess:(LoginCallback)success andFailure:(LoginCallback)fail {

    // init
    _project = [[LBModel alloc] init];
    _username = username;
    _password = password;
    _url = url;
    [_project setValue:projectId forKey:@"_id"];
    
    _adapter = [LBRESTAdapter adapterWithURL:[NSURL URLWithString:_url]];
    _checkpointRepo = [_adapter repositoryWithModelName:@"SessionCheckPoints"];
    
    LBUserRepository *userRepo = [LBUserRepository repositoryWithClassName:@"Developers"];
    userRepo.adapter = _adapter;
    
    [userRepo loginWithEmail:username password:password success:^(LBAccessToken *token) {
        _accessToken = token;
        LBModelRepository *projectRepo = [_adapter repositoryWithModelName:@"Projects"];
        [projectRepo findById:_project._id success:^(LBModel *model) {
            _project = model;
            [self startSessionWithIdentifier:sessionIdentifier withSuccess:^{
                if(success != nil)
                    success();
            } andFail:^{
                if(fail != nil)
                    fail();
            }];
        } failure:^(NSError *error) {
            if(fail != nil)
                fail();
            NSLog(@"%@", project_not_found);
        }];
    } failure:^(NSError *error) {
        if(fail != nil)
            fail();
        NSLog(@"%@", login_incorrect);
    }];
}

- (void) startSessionWithIdentifier:(NSString *)identifier {
    [self startSessionWithIdentifier:identifier withSuccess:nil andFail:nil];
}

- (void) startSessionWithIdentifier:(NSString *)identifier withSuccess:(Callback)success andFail:(Callback)fail {
    LBModelRepository *sessionRepo = [_adapter repositoryWithModelName:@"Sessions"];
    LBModel *session = [sessionRepo modelWithDictionary:@{
                                                          @"identifier": identifier,
                                                          @"projectId": _project._id
                                                          }];
    [session saveWithSuccess:^{
        _session = session;
        if(success != nil)
            success();
    } failure:^(NSError *error) {
        NSLog(@"%@", session_could_not_start);
        if(fail != nil)
            fail();
    }];
}

- (void)checkPoint:(NSString *)identifier {
    if(_checkpointQueue != nil) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
        [dateFormatter setTimeZone: [NSTimeZone timeZoneWithName:@"UTC"]];
        NSString *sqlDate = [dateFormatter stringFromDate: [NSDate date]];
        NSString *millis = [NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970]];
        [_checkpointQueue addObject:@{
                                      @"identifier": identifier,
                                      @"created": sqlDate,
                                      @"millis": millis
                                      }];
    }
}

- (void) batchSendCheckpoints {
    
    if(_project == nil || _username == nil || _password == nil || _checkpointQueue == nil || _checkpointRepo == nil) {
        return;
    }
    
    for (int i = 0; i < 10 && i < _checkpointQueue.count; i++) {
        NSDictionary *checkPoint = [_checkpointQueue objectAtIndex:i];
        NSString *identifier = [checkPoint valueForKey:@"identifier"];
        NSString *created = [checkPoint valueForKey:@"created"];
        NSString *millis = [checkPoint valueForKey:@"millis"];
        if(_checkpointRepo != nil && _project != nil && checkPoint != nil && identifier != nil && created != nil && _session != nil && _session._id != nil) {
            LBModel *checkPoint = [_checkpointRepo modelWithDictionary:@{
                                                                        @"sessionId" : _session._id,
                                                                        @"checkPointId": identifier,    @"created": created,
                                                                        @"millis": millis
                                                                        }];
            [_checkpointQueue removeObject:[_checkpointQueue objectAtIndex:i]];
            [checkPoint saveWithSuccess:^{
            } failure:^(NSError *error) {
                NSLog(@"%@", checkpoint_not_found);
            }];
        }
    }
}



@end
