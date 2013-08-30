//
//  LoginInVC.h
//  VideoSharing
//
//  Created by Pradeep on 17/06/13.
//  Copyright (c) 2013 Pradeep. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginInVC : UIViewController<ServerProtocol>
{
    UITextField *tempTextField;
}

@property (weak, nonatomic) IBOutlet UITextField *txtEmail;
@property (weak, nonatomic) IBOutlet UITextField *txtPassword;

- (IBAction)loginBtnClicked:(id)sender;
- (IBAction)forgotBtnClicked:(id)sender;
- (IBAction)backBtnClicked:(id)sender;

@end
