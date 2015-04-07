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
    }
    return self;
}

- (void) initWithUsername: (NSString *) username andPassword: (NSString *) password andProjectId: (NSString *) projectId andSessionIdentifier:(NSString *)sessionIdentifier {
    
    // init
    _project = [[Project alloc] init];
    _username = username;
    _password = password;
    [_project setValue:projectId forKey:@"_id"];
    
    _adapter = [LBRESTAdapter adapterWithURL:[NSURL URLWithString:_url]];
    
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
        NSLog(@"%@", checkpoint_not_found);
    }];
}

- (void)checkPoint:(NSString *)identifier {
    LBModelRepository *checkPointRepo = [_adapter repositoryWithModelName:@"SessionCheckPoints"];
    LBModel *checkPoint = [checkPointRepo modelWithDictionary:@{
                                                                @"sessionId" : _session._id,
                                                                @"checkPointId": identifier
                                                                }];
    [checkPoint saveWithSuccess:^{
        NSLog(@"saved checkPoint");
    } failure:^(NSError *error) {
        NSLog(@"failed to save checkpoint");
    }];
}



@end
