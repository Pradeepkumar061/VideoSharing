//
//  SignInVC.m
//  VideoSharing
//
//  Created by Pradeep on 17/06/13.
//  Copyright (c) 2013 Pradeep. All rights reserved.
//

#import "SignInVC.h"
#import "RegistrationVC.h"
#import "LoginInVC.h"
#import "HomeVC.h"
#import "FacebookFriendsVC.h"

#define FACEBOOK_REGISTRATION_REQUEST 1
#define TWITTER_REGISTRATION_REQUEST 2

@interface SignInVC ()

@end

@implementation SignInVC


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark View Life Cycle Method

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark IBAction Method

- (IBAction)loginBtnClicked:(id)sender
{
    SharedAppDelegate.isGuestUser = NO;
    NSString *nibName = nil;
    nibName = SharedAppDelegate.deviceType == kiPad?@"LoginInVC_iPad":(SharedAppDelegate.deviceType== kiPhone5?@"LoginInVC_iPhone5": @"LoginInVC");
    LoginInVC *objLoginInVC = [[LoginInVC alloc]initWithNibName:nibName bundle:nil];
    [self.navigationController pushViewController:objLoginInVC animated:YES];
}

- (IBAction)registerBtnClicked:(id)sender
{
    SharedAppDelegate.isGuestUser = NO;
    NSString *nibName = nil;
    nibName = SharedAppDelegate.deviceType == kiPad?@"RegistrationVC_iPad":(SharedAppDelegate.deviceType== kiPhone5?@"RegistrationVC_iPhone5": @"RegistrationVC");
    RegistrationVC *objRegistrationVC = [[RegistrationVC alloc]initWithNibName:nibName bundle:nil];
    [self.navigationController pushViewController:objRegistrationVC animated:YES];
}

- (IBAction)loginFbBtnClicked:(id)sender
{
    SharedAppDelegate.isGuestUser = NO;
    currrentRequest = FACEBOOK_REGISTRATION_REQUEST;
    [[FacebookHandler sharedInstance] checkSessionAndStartIfNeedediOS6:^(BOOL success, ACAccount *account)
     {
        if (success)
        {
            [Utils startActivityIndicatorInView:self.view withMessage:PLEASE_WAIT];
            [self performSelector:@selector(getPersonalInfo) withObject:nil afterDelay:0.0];
        }
        else
        {
            [self performSelectorOnMainThread:@selector(shareFBBeloeiOS6) withObject:nil waitUntilDone:NO];
        }
    }];
}

- (IBAction)loginTwitterBtnClicked:(id)sender
{
    SharedAppDelegate.isGuestUser = NO;
    currrentRequest = TWITTER_REGISTRATION_REQUEST;
    [TwitterHandler sharedInstance].delegate = self;
    [[TwitterHandler sharedInstance]getTwitterPersonalInfo];
}

- (IBAction)guestUserBtnClicked:(id)sender
{
    SharedAppDelegate.isGuestUser = YES;
    NSString *nibName = nil;
    nibName = SharedAppDelegate.deviceType == kiPad?@"HomeVC_iPad":(SharedAppDelegate.deviceType == kiPhone5 ?@"HomeVC_iPhone5":@"HomeVC");
    HomeVC *objHomeVC = [[HomeVC alloc]initWithNibName:nibName bundle:nil];
    [self.navigationController pushViewController:objHomeVC animated:YES];
}

#pragma mark Facebook Share Method

//Checking Facebook below iOS 6.0 Version
- (void)shareFBBeloeiOS6
{
    [[FacebookHandler sharedInstance] checkSessionAndStartIfNeeded:^(BOOL success)
     {
        if (success)
        {
            [Utils startActivityIndicatorInView:self.view withMessage:PLEASE_WAIT];
            [self performSelector:@selector(getPersonalInfo) withObject:nil afterDelay:0.0];
        }
       
    }];
}

// Method used for fetching the personal information from the facebook 
- (void)getPersonalInfo
{
    [FacebookHandler sharedInstance].delegate = self;
     [[FacebookHandler sharedInstance] getPersonalInfo];
}

#pragma mark Facebook Delegate Method

- (void)fbResultFail
{
    [Utils stopActivityIndicatorInView:self.view];
    [Utils showAlertView:APP_NAME message:LOGIN_WITH_FB_FAIL delegate:nil cancelButtonTitle:ALERT_OK otherButtonTitles:nil];
}

- (void)fbResultSuccess:(NSDictionary *)resultDic
{
    // Send to the registration request 
    [self performSelector:@selector(sendRegistrationRequestToServer:) withObject:resultDic afterDelay:0.5];
}

#pragma mark Twitter Delegate Method

-(void)twitterResultSuccess:(NSDictionary *)resultDic
{
    // Send to the registration request
    [self performSelectorOnMainThread:@selector(sendRegistrationRequestToServer:)  withObject:resultDic waitUntilDone:NO];
}

-(void)twitterResultFail
{
    [Utils stopActivityIndicatorInView:self.view];
    [Utils showAlertView:APP_NAME message:LOGIN_WITH_TWITTER_FAIL delegate:nil cancelButtonTitle:ALERT_OK otherButtonTitles:nil];
}

#pragma mark Network Method

// Method is used for sending the data to the server

-(void)sendRegistrationRequestToServer:(NSDictionary*)resultDic
{
    NSDictionary *dataToSendDic = nil;
    
    if(currrentRequest == FACEBOOK_REGISTRATION_REQUEST)
    {
        NSString *imageURL = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large",[resultDic objectForKey:@"id"]];
        //Dictionary containing the informtaion that send to the server 
        dataToSendDic = [NSDictionary dictionaryWithObjectsAndKeys:@"",kEmail,@"iphone",kDeviceType,[UIDevice currentDevice].model,kDeviceModel,[resultDic objectForKey:@"id"],kFBTwitterToken,@"facebook",kLoginType,imageURL,kUserPhoto,[resultDic objectForKey:@"name"],kFullName,[resultDic objectForKey:@"first_name"],KFirstName,[resultDic objectForKey:@"last_name"],kLastName,[resultDic objectForKey:@"name"],kUsername,nil];
    }
    else if(currrentRequest == TWITTER_REGISTRATION_REQUEST)
    {
        //Dictionary containing the informtaion that send to the server
        dataToSendDic = [NSDictionary dictionaryWithObjectsAndKeys:[resultDic objectForKey:@"profile_image_url"],kUserPhoto,[resultDic objectForKey:@"name"],KFirstName,@"",kLastName,[resultDic objectForKey:@"screen_name"],kUsername,@"",kEmail,@"iphone",kDeviceType,[UIDevice currentDevice].model,kDeviceModel,[resultDic objectForKey:@"id"],kFBTwitterToken,@"twitter",kLoginType,[resultDic objectForKey:@"name"],kFullName,nil];
    }
    [Server serverSharedInstance].delegate = self;
    [[Server serverSharedInstance]sendRequestToServer:dataToSendDic requestType:kRegistrationRequest];
}

// Delegate method called when data  comes from the server

- (void) requestFinished:(NSDictionary * )responseData
{
    if([responseData count]>0)
    {
        if([[responseData objectForKey:kResult]boolValue])
        {
            SharedAppDelegate.isAppLogin = NO;
            NSString *userId = [NSString stringWithFormat:@"%@",[[responseData objectForKey:kData] objectForKey:kUserId]];
            [[NSUserDefaults standardUserDefaults]setObject:userId forKey:kUserId];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            if (currrentRequest == FACEBOOK_REGISTRATION_REQUEST)
            {
               if ([[[responseData objectForKey:kData]objectForKey:@"isLoggedInFirstTime"]boolValue])
                {
                   //Moving to the Facebook Friends Screen that have joined the app
                    NSString *nibName = nil;
                    nibName = SharedAppDelegate.deviceType == kiPad?@"FacebookFriendsVC_iPad":(SharedAppDelegate.deviceType== kiPhone5?@"FacebookFriendsVC_iPhone5": @"FacebookFriendsVC");
                    FacebookFriendsVC *objFollowVC = [[FacebookFriendsVC alloc]initWithNibName:nibName bundle:nil];
                    [self.navigationController pushViewController:objFollowVC animated:YES];
                    [Utils stopActivityIndicatorInView:self.view];
                    return;
                }
            }
            //Moving to the Home Screen
            NSString *nibName = nil;
            nibName = SharedAppDelegate.deviceType == kiPad?@"HomeVC_iPad":(SharedAppDelegate.deviceType == kiPhone5 ?@"HomeVC_iPhone5":@"HomeVC");
            HomeVC *objHomeVC = [[HomeVC alloc]initWithNibName:nibName bundle:nil];
            [self.navigationController pushViewController:objHomeVC animated:YES];
        }
        else
        {
            [Utils showAlertView:APP_NAME message:[responseData objectForKey:kMsg] delegate:nil cancelButtonTitle:ALERT_OK otherButtonTitles:nil];
        }
    }
    else
    {
        [Utils showAlertView:APP_NAME message:SERVER_NOT_RESPOND delegate:nil cancelButtonTitle:ALERT_OK otherButtonTitles:nil];
    }
    [Utils stopActivityIndicatorInView:self.view];

}

- (void)requestError
{
    [Utils stopActivityIndicatorInView:self.view];
}

- (void)networkError

{
    [Utils stopActivityIndicatorInView:self.view];
}

@end
