//
//  WelcomeViewController.m
//  ShuchuangClient
//
//  Created by 黄建 on 1/4/16.
//  Copyright © 2016 Shuchuang Tech. All rights reserved.
//

#import "WelcomeViewController.h"
#import "UIButton+FillBackgroundImage.h"
#import "Bmob.h"
@interface WelcomeViewController ()
@property (weak, nonatomic) IBOutlet UIButton *btnReg;
@property (weak, nonatomic) IBOutlet UIButton *btnLogin;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundView;

- (IBAction)onBtnReg:(id)sender;
- (IBAction)onBtnLogin:(id)sender;

@end

@implementation WelcomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.btnReg setBackgroundImage:[UIButton imageWithColor:[UIButton getColorFromHex:0xffd573 Alpha:0.4]] forState:UIControlStateNormal];
    [self.btnLogin setBackgroundImage:[UIButton imageWithColor:[UIButton getColorFromHex:0xffba73 Alpha:0.4]] forState:UIControlStateNormal];
    [self.btnReg setBackgroundImage:[UIButton imageWithColor:[UIButton getColorFromHex:0xffb300 Alpha:0.4]] forState:UIControlStateHighlighted];
    [self.btnLogin setBackgroundImage:[UIButton imageWithColor:[UIButton getColorFromHex:0xff8100 Alpha:0.4]] forState:UIControlStateHighlighted];
    [self.btnReg.layer setBorderWidth:1.0];
    [self.btnReg.layer setBorderColor:[[UIColor colorWithWhite:1.0 alpha:0.9] CGColor]];
    [self.btnLogin.layer setBorderWidth:1.0];
    [self.btnLogin.layer setBorderColor:[[UIColor colorWithWhite:1.0 alpha:0.9] CGColor]];
    self.btnReg.layer.cornerRadius = 5.0;
    self.btnReg.layer.opaque = NO;
    self.btnReg.layer.masksToBounds = YES;
    self.btnLogin.layer.cornerRadius = 5.0;
    self.btnLogin.layer.opaque = NO;
    self.btnLogin.layer.masksToBounds = YES;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"welcomeToRegister"]) {
        id desVC = segue.destinationViewController;
        [desVC setValue:@YES forKey:@"registerNewUser"];
    }
}


- (IBAction)onBtnReg:(id)sender {
    [self performSegueWithIdentifier:@"welcomeToRegister" sender:self];
}

- (IBAction)onBtnLogin:(id)sender {
    [self performSegueWithIdentifier:@"welcomeToLogin" sender:self];
}
@end
