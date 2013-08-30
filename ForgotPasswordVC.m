//
//  ForgotPasswordVC.m
//  VideoSharing
//
//  Created by Pradeep on 25/06/13.
//  Copyright (c) 2013 Pradeep. All rights reserved.
//

#import "ForgotPasswordVC.h"

@interface ForgotPasswordVC ()

@end

@implementation ForgotPasswordVC

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
    [self setTextOnUI];
}


#pragma mark IBAction Method

- (IBAction)submitBtnClicked:(id)sender
{
    [tempTextField resignFirstResponder];
    
    if ([self.txtEmail.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0) {
        
        [Utils showAlertView:APP_NAME message:PLEASE_ENTER_EMAIL delegate:nil cancelButtonTitle:ALERT_OK otherButtonTitles:nil];
    }
    else
    {
        if([Utils emailValidate:self.txtEmail.text])
        {
            [Utils showAlertView:APP_NAME message:PLEASE_ENTER_VALID_EMAIL delegate:nil cancelButtonTitle:ALERT_OK otherButtonTitles:nil];
        }
        else
        {
            //Sending request to the server in case of Forget Password 
            [Utils startActivityIndicatorInView:self.view withMessage:PLEASE_WAIT];
            [self performSelector:@selector(sendForgetPasswordRequestToServer) withObject:nil afterDelay:0.5];
        }
    }
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

//Sending Request to the server in case of forget password 
-(void)sendForgetPasswordRequestToServer
{
    NSDictionary *dataToSendDic = [NSDictionary dictionaryWithObjectsAndKeys:self.txtEmail.text,kEmail,nil];
    [Server serverSharedInstance].delegate = self;
    [[Server serverSharedInstance]sendRequestToServer:dataToSendDic requestType:kForgetPassword];
}

- (void) requestFinished:(NSDictionary * )responseData
{
    if([responseData count]>0)
    {
        if([[responseData objectForKey:kResult]boolValue])
        {
            [Utils showAlertView:APP_NAME message:PASSWORD_SEND_TO_EMAIL delegate:nil cancelButtonTitle:ALERT_OK otherButtonTitles:nil];
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload
{
    [self setTxtEmail:nil];
    [super viewDidUnload];
}


@end
