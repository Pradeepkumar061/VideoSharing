//
//  SignInVC.h
//  VideoSharing
//
//  Created by Pradeep on 17/06/13.
//  Copyright (c) 2013 Pradeep. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FacebookHandler.h"
#import "TwitterHandler.h"


@interface SignInVC : UIViewController <FBProtocol,TwitterProtocol>
{
    int currrentRequest;
}

- (IBAction)loginBtnClicked:(id)sender;
- (IBAction)registerBtnClicked:(id)sender;
- (IBAction)loginFbBtnClicked:(id)sender;
- (IBAction)loginTwitterBtnClicked:(id)sender;
- (IBAction)guestUserBtnClicked:(id)sender;

@end
