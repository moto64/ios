//
//  MTDetailViewController.m
//  Moto64
//
//  Created by AseR on 03.03.14.
//  Copyright (c) 2014 AseR. All rights reserved.
//

#import "MTDetailViewController.h"

@interface MTDetailViewController ()

@property (strong, nonatomic) IBOutlet UIWebView *webView;
- (void)configureView;

@end

@implementation MTDetailViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }
}

- (void)configureView
{
    // Update the user interface for the detail item.

    if (self.detailItem) {
        self.navigationItem.title = [[self.detailItem valueForKey:@"title"] description];
        NSURL *url = [NSURL URLWithString:[[self.detailItem valueForKey:@"url"] description]];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [self.webView setScalesPageToFit:YES];
        [[self.webView scrollView] setScrollEnabled:YES];
        [self.webView loadRequest:request];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
