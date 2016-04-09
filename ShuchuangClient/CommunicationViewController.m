//
//  CommunicationViewController.m
//  ShuchuangClient
//
//  Created by 黄建 on 4/7/16.
//  Copyright © 2016 Shuchuang Tech. All rights reserved.
//

#import "CommunicationViewController.h"
#import "SCUtil.h"
#import "Bmob.h"
#import "MyActivityIndicatorView.h"
@interface CommunicationViewController () <UITextFieldDelegate, UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UITextField *connactTextField;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (weak, nonatomic) IBOutlet UITextView *contentTextView;
@property (weak, nonatomic) IBOutlet UINavigationBar *naviBar;
@property (weak, nonatomic) IBOutlet UILabel *contentPlaceholder;
@property (strong, nonatomic) MyActivityIndicatorView *acFrame;


- (void)onSubmitButton;
- (void)onLeftButton;
@end

@implementation CommunicationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //navigation bar
    UINavigationItem *naviItem = [[UINavigationItem alloc] initWithTitle:@"意见反馈"];
    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(onLeftButton)];
    [leftBarButton setTintColor:[UIColor colorWithRed:1.0 green:129.0/255.0 blue:0.0 alpha:1.0]];
    naviItem.leftBarButtonItem = leftBarButton;
    [self.naviBar pushNavigationItem:naviItem animated:NO];
    
    //text field
    self.titleTextField.delegate = self;
    self.connactTextField.delegate = self;
    
    //text view
    self.contentTextView.delegate = self;
    self.contentTextView.layer.borderColor = [[UIColor colorWithRed:215.0 / 255.0 green:215.0 / 255.0 blue:215.0 / 255.0 alpha:1] CGColor];
    self.contentTextView.layer.borderWidth = 0.6f;
    self.contentTextView.layer.cornerRadius = 6.0f;
    
    [self.submitButton setBackgroundColor:[UIColor colorWithRed:0.0 green:162.0 / 255.0 blue:232.0 / 255.0 alpha:1]];
    [self.submitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.submitButton setTitle:@"提交" forState:UIControlStateNormal];
    self.submitButton.layer.cornerRadius = 5.0;
    [self.submitButton addTarget:self action:@selector(onSubmitButton) forControlEvents:UIControlEventTouchUpInside];
    
    self.acFrame = [[MyActivityIndicatorView alloc] initWithFrameInView:self.view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)onLeftButton {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)onSubmitButton {
    if (self.titleTextField.text.length == 0 || self.contentTextView.text.length == 0 || self.connactTextField.text.length == 0) {
        [SCUtil viewController:self showAlertTitle:@"提示" message:@"请输入完整的信息" action:nil];
    }
    else {
        BmobObject *communication = [BmobObject objectWithClassName:@"Communication"];
        [communication setObject:self.titleTextField.text forKey:@"title"];
        [communication setObject:self.contentTextView.text forKey:@"comment"];
        [communication setObject:self.connactTextField.text forKey:@"connaction"];
        BmobUser *user = [BmobUser getCurrentUser];
        [communication setObject:user forKey:@"user"];
        [self.acFrame startAc];
        [communication saveInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
            [self.acFrame stopAc];
            if (isSuccessful) {
                [SCUtil viewController:self showAlertTitle:@"提示" message:@"信息提交成功，我们会第一时间处理" action:^(UIAlertAction *action) {
                    [self dismissViewControllerAnimated:YES completion:nil];
                }];
            }
            else {
                [SCUtil viewController:self showAlertTitle:@"提示" message:@"提交出错啦，请稍后再试" action:^(UIAlertAction *action) {
                    [self dismissViewControllerAnimated:YES completion:nil];
                }];
            }
        }];
    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if (range.length == 0 && range.location == 0) {
        self.contentPlaceholder.hidden = YES;
    }
    else if (range.length == 1 && range.location == 0){
        self.contentPlaceholder.hidden = NO;
    }
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    else {
        if (range.location == 140) {
            return NO;
        }
        else {
            return YES;
        }
    }
}

@end
