//
//  RegistrationVC.h
//  VideoSharing
//
//  Created by Pradeep on 17/06/13.
//  Copyright (c) 2013 Pradeep. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RegistrationVC : UIViewController <UIActionSheetDelegate,UIImagePickerControllerDelegate,UITextFieldDelegate,UINavigationControllerDelegate,ServerProtocol>
{
    UITextField *tempTextField;
    int currentRequest;
}

@property (weak, nonatomic) IBOutlet UIImageView *profilePic;
@property (weak, nonatomic) IBOutlet UITextField *txtFirstName;
@property (weak, nonatomic) IBOutlet UITextField *txtLastName;
@property (weak, nonatomic) IBOutlet UITextField *txtUsername;
@property (weak, nonatomic) IBOutlet UITextField *txtEmail;
@property (weak, nonatomic) IBOutlet UITextField *txtPassword;
@property (weak, nonatomic) IBOutlet UITextField *txtRePassword;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (retain, nonatomic) UIActionSheet *actionSheetPhoto;
@property (strong, nonatomic) UIPopoverController *popoverController;

- (IBAction)backBtnClicked:(id)sender;
- (IBAction)signUpBtnClicked:(id)sender;
- (IBAction)uploadPicBtnClicked:(id)sender;

@end