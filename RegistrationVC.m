//
//  RegistrationVC.m
//  VideoSharing
//
//  Created by Pradeep on 17/06/13.
//  Copyright (c) 2013 Pradeep. All rights reserved.
//

#import "RegistrationVC.h"
#import "HomeVC.h"
#import "UIImage+fixOrientation.h"

#define REGISTRATION_REQUEST 1
#define LOGIN_REQUEST 2

@interface RegistrationVC ()

@end

@implementation RegistrationVC
@synthesize popoverController;

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
    [self setTextOnUI];
    // Do any additional setup after loading the view from its nib.
}


#pragma mark IBAction Method
//Called when SignUp button is Clicked on the UI
- (IBAction)signUpBtnClicked:(id)sender
{
    [tempTextField resignFirstResponder];
    
    if([self.txtFirstName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0)
    {
        [Utils showAlertView:APP_NAME message:PLEASE_ENTER_FIRSTNAME delegate:nil cancelButtonTitle:ALERT_OK otherButtonTitles:nil];
    }
    else if([self.txtLastName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0)
    {
        [Utils showAlertView:APP_NAME message:PLEASE_ENTER_LASTNAME delegate:nil cancelButtonTitle:ALERT_OK otherButtonTitles:nil];
    }
    else if([self.txtUsername.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0)
    {
        [Utils showAlertView:APP_NAME message:PLEASE_ENTER_USERNAME delegate:nil cancelButtonTitle:ALERT_OK otherButtonTitles:nil];
    }
    else if([self.txtEmail.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0)
    {
        [Utils showAlertView:APP_NAME message:PLEASE_ENTER_EMAIL delegate:nil cancelButtonTitle:ALERT_OK otherButtonTitles:nil];
    }
    else if([self.txtPassword.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0)
    {
        [Utils showAlertView:APP_NAME message:PLEASE_ENTER_PASSWORD delegate:nil cancelButtonTitle:ALERT_OK otherButtonTitles:nil];
    }
    else if([self.txtRePassword.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0)
    {
        [Utils showAlertView:APP_NAME message:PLEASE_ENTER_RE_PASSWORD delegate:nil cancelButtonTitle:ALERT_OK otherButtonTitles:nil];
    }
    else if(![self.txtPassword.text isEqualToString:self.txtRePassword.text])
    {
        [Utils showAlertView:APP_NAME message:PLEASE_RE_ENTER_SAME_PASSWORD delegate:nil cancelButtonTitle:ALERT_OK otherButtonTitles:nil];
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
            [self performSelector:@selector(sendRegistrationRequestToServer) withObject:nil afterDelay:0.5];
        }
    }
}

- (IBAction)uploadPicBtnClicked:(id)sender
{
    [tempTextField resignFirstResponder];
    [self showActionSheet];
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
    [self scrollUIAccordingToTextField:tempTextField];
}

-(BOOL)textFieldShouldReturn:(UITextField*)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self updateUI];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    if (textField == self.txtEmail) {
     return YES;
    }
    
    return (newLength > 24) ? NO : YES;
}
#pragma mark Network Method

//Sending the Registration Information to the server 
-(void)sendRegistrationRequestToServer
{
    NSString *fullName = [NSString stringWithFormat:@"%@ %@",self.txtFirstName.text,self.txtLastName.text];
    
    currentRequest = REGISTRATION_REQUEST;
    NSDictionary *dataToSendDic = [NSDictionary dictionaryWithObjectsAndKeys:@"",kUserPhoto,self.txtFirstName.text,KFirstName,self.txtLastName.text,kLastName,self.txtUsername.text,kUsername,self.txtEmail.text,kEmail,self.txtPassword.text,kPassword,@"iphone",kDeviceType,[UIDevice currentDevice].model,kDeviceModel,@"",kFBTwitterToken,@"app",kLoginType,fullName,kFullName,nil];
    
    [Server serverSharedInstance].delegate = self;
    UIImage * img = [Utils resizeImage:self.profilePic.image width:300 height:300];
    [[Server serverSharedInstance]sendRequestToServerForMultipartData:UIImagePNGRepresentation(img) requestType:kRegistrationRequest userInfo:dataToSendDic postDataKey:kImage fileName:@"test.png"];
}

//Sending the Login request to the server 
-(void)sendLoginRequestToServer
{
    currentRequest = LOGIN_REQUEST;
    NSDictionary *dataToSendDic = [NSDictionary dictionaryWithObjectsAndKeys:self.txtEmail.text,kEmail,self.txtPassword.text,kPassword,nil];
    [Server serverSharedInstance].delegate = self;
    [[Server serverSharedInstance]sendRequestToServer:dataToSendDic requestType:kLoginRequest];
}


- (void) requestFinished:(NSDictionary * )responseData
{
    if([responseData count]>0)
    {
        switch (currentRequest)
        {
            case REGISTRATION_REQUEST:
            {
                if([[responseData objectForKey:kResult]boolValue])
                {
                    SharedAppDelegate.isAppLogin = YES;
                    [self sendLoginRequestToServer];
                }
                else
                {
                    [Utils showAlertView:APP_NAME message:[responseData objectForKey:kMsg] delegate:nil cancelButtonTitle:ALERT_OK otherButtonTitles:nil];
                    [Utils stopActivityIndicatorInView:self.view];
                }
            }
                break;
            case LOGIN_REQUEST:
            {
                if([[responseData objectForKey:kResult]boolValue])
                {
                    NSString *userId = [NSString stringWithFormat:@"%@",[[responseData objectForKey:kData] objectForKey:kUserId]];
                    [[NSUserDefaults standardUserDefaults]setObject:userId forKey:kUserId];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    NSString *nibName = nil;
                    nibName = SharedAppDelegate.deviceType == kiPad?@"HomeVC_iPad":(SharedAppDelegate.deviceType == kiPhone5 ?@"HomeVC_iPhone5":@"HomeVC");
                    
                    HomeVC *objHomeVC = [[HomeVC alloc]initWithNibName:nibName bundle:nil];
                    [self.navigationController pushViewController:objHomeVC animated:YES];
                    [Utils stopActivityIndicatorInView:self.view];
                }
                else
                {
                    [Utils showAlertView:APP_NAME message:[responseData objectForKey:kMsg] delegate:nil cancelButtonTitle:ALERT_OK otherButtonTitles:nil];
                }
                [Utils stopActivityIndicatorInView:self.view];
            }
                break;
                
            default:
                break;
        }
    }
    else
    {
        [Utils showAlertView:APP_NAME message:SERVER_NOT_RESPOND delegate:nil cancelButtonTitle:ALERT_OK otherButtonTitles:nil];
        [Utils stopActivityIndicatorInView:self.view];
    }
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
    [self.txtFirstName setValue:APP_COLOUR_DARK_GRAY
                     forKeyPath:@"_placeholderLabel.textColor"];
    [self.txtLastName setValue:APP_COLOUR_DARK_GRAY
                    forKeyPath:@"_placeholderLabel.textColor"];
    [self.txtUsername setValue:APP_COLOUR_DARK_GRAY
                    forKeyPath:@"_placeholderLabel.textColor"];
    [self.txtEmail setValue:APP_COLOUR_DARK_GRAY
                    forKeyPath:@"_placeholderLabel.textColor"];
    [self.txtPassword setValue:APP_COLOUR_DARK_GRAY forKeyPath:@"_placeholderLabel.textColor"];
    [self.txtRePassword setValue:APP_COLOUR_DARK_GRAY forKeyPath:@"_placeholderLabel.textColor"];
}

#pragma mark Scroll UI When TextField Clicked Method

-(void)scrollUIAccordingToTextField:(UITextField*)txtField
{
     CGRect txtFrame = txtField.frame;
    if(SharedAppDelegate.deviceType == kiPhone)
    {
        self.scrollView.frame = CGRectMake(0,44,320,210);
        self.scrollView.contentSize = CGSizeMake(320,420);
        [self.scrollView scrollRectToVisible:CGRectMake(txtFrame.origin.x, txtFrame.origin.y+40,txtFrame.size.width,txtFrame.size.height) animated:NO];
    }
    else if(SharedAppDelegate.deviceType == kiPhone5)
    {
        self.scrollView.frame = CGRectMake(0,44,320,300);
        self.scrollView.contentSize = CGSizeMake(320,480);
        [self.scrollView scrollRectToVisible:CGRectMake(txtFrame.origin.x, txtFrame.origin.y+40,txtFrame.size.width,txtFrame.size.height) animated:NO];
    }
    else if(SharedAppDelegate.deviceType==kiPad)
    {
        self.scrollView.frame = CGRectMake(0,50,768,710);
        self.scrollView.contentSize = CGSizeMake(768,950);
        [self.scrollView scrollRectToVisible:CGRectMake(txtFrame.origin.x, txtFrame.origin.y+60,txtFrame.size.width,txtFrame.size.height) animated:NO];
    }
    
}

#pragma mark Update UI To Original Position Method

-(void)updateUI
{
    if(SharedAppDelegate.deviceType == kiPhone)
    {
        self.scrollView.frame = CGRectMake(0,44,320,416);
          self.scrollView.contentSize = CGSizeMake(320,400);
    }
    else if(SharedAppDelegate.deviceType == kiPhone5)
    {
        self.scrollView.frame = CGRectMake(0,44,320,504);
        self.scrollView.contentSize = CGSizeMake(320,450);
    
    }else if(SharedAppDelegate.deviceType==kiPad)
    {
        self.scrollView.frame = CGRectMake(0,50,768,956);
        self.scrollView.contentSize = CGSizeMake(768,950);
        
        
        
    }
  
}

#pragma mark - Show ActionSheet Method
-(void)showActionSheet
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"" delegate:self cancelButtonTitle:nil destructiveButtonTitle:ALERT_CANCEL otherButtonTitles:CAPTURE_IMAGE,TAKE_FROM_GALLERY,nil];
    [actionSheet showInView:self.view];
}

#pragma mark ActionSheet Delegate

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex)
    {
        case 1:
        {
            BOOL cameraAvailableFlag = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
            if (cameraAvailableFlag)
            {
                if(SharedAppDelegate.deviceType == kiPad)
               {
                  [self getImageForUserIpad:UIImagePickerControllerSourceTypeCamera];
               }
                else{
                [self getImageForUser:UIImagePickerControllerSourceTypeCamera];
               }
            }
            else
            {
                [Utils showAlertView:APP_NAME message:CAMERA_NOT_AVAILABLE delegate:nil cancelButtonTitle:ALERT_OK otherButtonTitles:nil];
            }
        }
            break;
        case 2:
            
            [self getImageForUser:UIImagePickerControllerSourceTypePhotoLibrary];
            break;
        default:
            break;
    }
}

#pragma mark ImagePicker Method

-(void)getImageForUser:(UIImagePickerControllerSourceType)sourceType
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc]init];
    imagePicker.delegate = self;
    imagePicker.sourceType = sourceType;
    if(SharedAppDelegate.deviceType == kiPad)
        
    {
         // Popover
            self.popoverController = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
            self.popoverController.delegate = self;
            [self.popoverController presentPopoverFromRect:CGRectMake(90,-60, 579, 390) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
        
    }else
    {
        [self presentModalViewController:imagePicker animated:YES];
        }
   }
-(void)getImageForUserIpad:(UIImagePickerControllerSourceType)sourceType
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc]init];
    imagePicker.delegate = self;
    imagePicker.sourceType = sourceType;
    [self presentModalViewController:imagePicker animated:YES];
    
}


#pragma mark - UIPopoverController Delegate

- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController
{
    return YES;
}
#pragma mark ImagePickerDelegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *selectedImage = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    [picker dismissModalViewControllerAnimated:YES];
    [self.popoverController dismissPopoverAnimated:YES];
    self.profilePic.image = selectedImage ;
    self.profilePic.image = [self.profilePic.image fixOrientation];
    self.profilePic.image = [self.profilePic.image squareImageWithImage:self.profilePic.image scaledToSize:CGSizeMake(150,150)];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissModalViewControllerAnimated:YES];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload
{
    [self setProfilePic:nil];
    [self setTxtFirstName:nil];
    [self setTxtLastName:nil];
    [self setTxtUsername:nil];
    [self setTxtEmail:nil];
    [self setTxtPassword:nil];
    [self setTxtRePassword:nil];
    [self setScrollView:nil];
    [super viewDidUnload];
}


@end
