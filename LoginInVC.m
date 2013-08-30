//
//  LoginInVC.m
//  VideoSharing
//
//  Created by Pradeep on 17/06/13.
//  Copyright (c) 2013 Pradeep. All rights reserved.
//

#import "LoginInVC.h"
#import "ForgotPasswordVC.h"
#import "HomeVC.h"

@interface LoginInVC ()

@end

@implementation LoginInVC

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
    [ super viewDidLoad];
    [self setTextOnUI];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload
{
    [self setTxtEmail:nil];
    [self setTxtPassword:nil];
    [super viewDidUnload];
}

#pragma mark IBAction Method

- (IBAction)loginBtnClicked:(id)sender
{
    [tempTextField resignFirstResponder];
    
    if ([self.txtEmail.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0) {
        
        [Utils showAlertView:APP_NAME message:PLEASE_ENTER_EMAIL delegate:nil cancelButtonTitle:ALERT_OK otherButtonTitles:nil];
    }
    else if ([self.txtPassword.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0)
    {
        [Utils showAlertView:APP_NAME message:PLEASE_ENTER_PASSWORD delegate:nil cancelButtonTitle:ALERT_OK otherButtonTitles:nil];
    }
    else
    {
        if([Utils emailValidate:self.txtEmail.text])
        {
            [Utils showAlertView:APP_NAME message:PLEASE_ENTER_VALID_EMAIL delegate:nil cancelButtonTitle:ALERT_OK otherButtonTitles:nil];
        }
        else
        {
            [Utils startActivityIndicatorInView:self.view withMessage:PLEASE_WAIT];
            [self performSelector:@selector(sendLoginRequestToServer) withObject:nil afterDelay:0.5];
        }
    }
}

- (IBAction)forgotBtnClicked:(id)sender
{    
    [tempTextField resignFirstResponder];
    
    NSString *nibName = nil;
    nibName = SharedAppDelegate.deviceType == kiPad?@"ForgotPasswordVC_iPad":(SharedAppDelegate.deviceType == kiPhone5 ?@"ForgotPasswordVC_iPhone5":@"ForgotPasswordVC");
    
    ForgotPasswordVC *objForgotPasswordVC = [[ForgotPasswordVC alloc]initWithNibName:nibName bundle:nil];
    [self.navigationController pushViewController:objForgotPasswordVC animated:YES];
    
}

- (IBAction)backBtnClicked:(id)sender
{
    [tempTextField resignFirstResponder];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - TextField Delegate Method

-(void)textFieldDidBeginEditing:(UITextField*)textField
{
    tempTextField = textField;
}

-(BOOL)textFieldShouldReturn:(UITextField*)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{

}

#pragma mark Network Method
-(void)sendLoginRequestToServer
{
    NSDictionary *dataToSendDic = [NSDictionary dictionaryWithObjectsAndKeys:self.txtEmail.text,kEmail,self.txtPassword.text,kPassword,nil];
    [Server serverSharedInstance].delegate = self;
    [[Server serverSharedInstance]sendRequestToServer:dataToSendDic requestType:kLoginRequest];
} 

- (void) requestFinished:(NSDictionary * )responseData
{
    if([responseData count]>0)
    {
        if([[responseData objectForKey:kResult]boolValue])
        {
            SharedAppDelegate.isAppLogin = YES;
            NSString *userId = [NSString stringWithFormat:@"%@",[[responseData objectForKey:kData] objectForKey:kUserId]];
            [[NSUserDefaults standardUserDefaults]setObject:userId forKey:kUserId];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
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
        [Utils stopActivityIndicatorInView:self.view];
    }
    [Utils stopActivityIndicatorInView:self.view];

}

-(void)requestError
{
    [Utils stopActivityIndicatorInView:self.view];
}
- (void) networkError
{
    [Utils stopActivityIndicatorInView:self.view];
}

#pragma mark Set Text Or Font On UI Method

-(void)setTextOnUI
{
    [self.txtEmail setValue:APP_COLOUR_DARK_GRAY
                     forKeyPath:@"_placeholderLabel.textColor"];
    [self.txtPassword setValue:APP_COLOUR_DARK_GRAY  forKeyPath:@"_placeholderLabel.textColor"];
}


@end
