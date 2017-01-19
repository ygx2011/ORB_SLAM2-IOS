//
//  ViewController.h
//  orbslamios
//
//  Created by Ying Gaoxuan on 16/11/1.
//  Copyright © 2016年 Ying Gaoxuan. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <opencv2/highgui/cap_ios.h>

@interface ViewController : UIViewController<CvVideoCameraDelegate>

- (IBAction)startButtonPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *start;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) CvVideoCamera* videoCamera;

@end
