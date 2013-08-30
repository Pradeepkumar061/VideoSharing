//
//  ForgotPasswordVC.h
//  VideoSharing
//
//  Created by Pradeep on 25/06/13.
//  Copyright (c) 2013 Pradeep. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ForgotPasswordVC : UIViewController<ServerProtocol>
{
   UITextField *tempTextField; 
}

@property (weak, nonatomic) IBOutlet UITextField *txtEmail;

- (IBAction)backBtnClicked:(id)sender;
- (IBAction)submitBtnClicked:(id)sender;

@end
