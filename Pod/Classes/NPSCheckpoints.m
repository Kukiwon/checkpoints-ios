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
        _url = @"http://localhost:3030/api";
        _checkpointQueue = [[NSMutableArray alloc] initWithCapacity:10];
        [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(batchSendCheckpoints) userInfo:nil repeats:YES];
    }
    return self;
}

- (void) initWithUsername: (NSString *) username andPassword: (NSString *) password andProjectId: (NSString *) projectId andSessionIdentifier:(NSString *)sessionIdentifier {
    
    // init
    _project = [[LBModel alloc] init];
    _username = username;
    _password = password;
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
            [self startSessionWithIdentifier:sessionIdentifier];
        } failure:^(NSError *error) {
            NSLog(@"%@", project_not_found);
        }];
    } failure:^(NSError *error) {
        NSLog(@"%@", login_incorrect);
    }];
}

- (void) initWithUsername:(NSString *)username andPassword:(NSString *)password andProjectId:(NSString *)projectId andSessionIdentifier:(NSString *)sessionIdentifier andUrl:(NSString *)url {
    _url = url;
    [self initWithUsername:username andPassword:password andProjectId:projectId andSessionIdentifier:sessionIdentifier];
}

- (void) startSessionWithIdentifier:(NSString *)identifier {
    LBModelRepository *sessionRepo = [_adapter repositoryWithModelName:@"Sessions"];
    LBModel *session = [sessionRepo modelWithDictionary:@{
                                                           @"identifier": identifier,
                                                           @"projectId": _project._id
                                                           }];
    [session saveWithSuccess:^{
        _session = session;
    } failure:^(NSError *error) {
        NSLog(@"%@", session_could_not_start);
    }];
}

- (void)checkPoint:(NSString *)identifier {
    [_checkpointQueue addObject:identifier];
}

- (void) batchSendCheckpoints {
    
    if(_project == nil || _username == nil || _password == nil || _checkpointQueue == nil || _checkpointRepo == nil) {
        return;
    }
    
    for (int i = 0; i < 10 && i < _checkpointQueue.count; i++) {
        NSString *identifier = [_checkpointQueue objectAtIndex:i];
        if(_checkpointRepo != nil && _project != nil && identifier != nil && ![identifier isEqualToString:@""]) {
            LBModel *checkPoint = [_checkpointRepo modelWithDictionary:@{
                                                                        @"sessionId" : _session._id,
                                                                        @"checkPointId": identifier
                                                                        }];
            [checkPoint saveWithSuccess:^{
                [_checkpointQueue removeObjectAtIndex: [_checkpointQueue indexOfObject:identifier]];
            } failure:^(NSError *error) {
                NSLog(@"%@", checkpoint_not_found);
                [_checkpointQueue removeObjectAtIndex: [_checkpointQueue indexOfObject:identifier]];
            }];
        }
    }
}



@end
