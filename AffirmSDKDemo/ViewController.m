//
//  ViewController.m
//  AffirmSDKDemo
//
//  Created by md143rbh7f on 6/10/15.
//  Copyright (c) 2015 Affirm. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (weak) IBOutlet UILabel *label;
@property (weak) IBOutlet UITextField *textField;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UIToolbar *toolBar = [UIToolbar new];

    UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self.textField action:@selector(resignFirstResponder)];

    toolBar.items = @[ flexibleItem, doneItem ];
    [toolBar sizeToFit];

    self.textField.inputAccessoryView = toolBar;

    [self _updateLabel];
}

- (void)showAlert:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Affirm Checkout" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {}];
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - IBAction Methods

- (IBAction)startCheckout:(id)sender {
    // Create the Affirm configuration.
    AffirmConfiguration *configuration = [AffirmConfiguration configurationWithAffirmDomain:@"sandbox.affirm.com" publicAPIKey:@"Y8CQXFF044903JC0"];
    
    // Create the checkout object.
    NSDecimalNumber *price = [NSDecimalNumber decimalNumberWithString:self.textField.text];
    AffirmItem *item = [AffirmItem itemWithName:@"Affirm Test Item" SKU:@"test_item" unitPrice:price quantity:1 URL:[NSURL URLWithString:@"http://sandbox.affirm.com/item"] imageURL:[NSURL URLWithString:@"http://sandbox.affirm.com/image.png"]];
    AffirmAddress *address = [AffirmAddress addressWithLine1:@"325 Pacific Ave." line2:@"" city:@"San Francisco" state:@"CA" zipCode:@"94111" countryCode:@"USA"];
    AffirmContact *contact = [AffirmContact contactWithName:@"Test Tester" address:address];
    AffirmCheckout *checkout = [AffirmCheckout checkoutWithItems:@[item] shipping:contact taxAmount:[NSDecimalNumber zero] shippingAmount:[NSDecimalNumber zero]];
    
    // Initialize the view controller, which creates the checkout on Affirm and starts the user checkout flow.
    AffirmCheckoutViewController *vc = [AffirmCheckoutViewController checkoutControllerWithDelegate:self configuration:configuration checkout:checkout];
    [self presentViewController:vc animated:YES completion:nil];
}

- (IBAction)presentSiteModal:(id)sender {
    AffirmConfiguration *configuration = [AffirmConfiguration configurationWithAffirmDomain:@"sandbox.affirm.com" publicAPIKey:@"Y8CQXFF044903JC0" ];

    AffirmSiteModalViewController *vc = [AffirmSiteModalViewController siteModalControllerWithModalId:@"5LNMQ33SEUYHLNUC" configuration:configuration];
    [self presentViewController:vc animated:YES completion:nil];
}

- (IBAction)presentProductModal:(id)sender {
    AffirmConfiguration *configuration = [AffirmConfiguration configurationWithAffirmDomain:@"sandbox.affirm.com" publicAPIKey:@"Y8CQXFF044903JC0" ];

    NSDecimalNumber *price = [NSDecimalNumber decimalNumberWithString:self.textField.text];
    AffirmProductModalViewController *vc = [AffirmProductModalViewController productModalControllerWithModalId:@"0Q97G0Z4Y4TLGHGB" amount:price configuration:configuration];
    [self presentViewController:vc animated:YES completion:nil];
}

#pragma mark - Private Methods

- (void)_updateLabel {
    AffirmConfiguration *configuration = [AffirmConfiguration configurationWithAffirmDomain:@"cdn1-sandbox.affirm.com" publicAPIKey:@"Y8CQXFF044903JC0"];

    NSDecimalNumber *price = [NSDecimalNumber decimalNumberWithString:self.textField.text];
    [AffirmAsLowAs writeAffirmAsLowAsToLabel:self.label amount:price promoId:@"SFCRL4VYS0C78607" affirmType:AffirmDisplayTypeLogo affirmColor:AffirmColorTypeBlack configuration:configuration callback:^(NSError * _Nonnull error, BOOL success) {
        NSLog(@"%@", error);
    }];
}

#pragma mark - UITextFieldDelegate Methods

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self _updateLabel];
}

#pragma mark - AffirmCheckoutDelegate Methods

- (void)checkoutCompleteWithToken:(NSString *)checkoutToken {
    // The user has completed the checkout and created a checkout token.
    // This token should be forwarded to your server, which should then authorize it with Affirm and create a charge.
    // For more information about the server integration, see https://docs.affirm.com/v2/api/charges
    [self dismissViewControllerAnimated:true completion:nil];
    [self showAlert:@"Checkout completed."];
}

- (void)checkoutCancelled {
    // The user has cancelled the checkout.
    [self dismissViewControllerAnimated:true completion:nil];
    [self showAlert:@"Checkout cancelled."];
}

- (void)checkoutCreationFailedWithError:(NSError *)error {
    // Checkout creation has failed for some reason.
    [self dismissViewControllerAnimated:true completion:nil];
    NSString *message = error.userInfo ? [NSString stringWithFormat:@"There was an error creating the checkout: %@", error.userInfo] : @"There was an unknown error creating the checkout.";
    [self showAlert:message];
}

@end
