//
//  ViewController.m
//  orbslamios
//
//  Created by Ying Gaoxuan on 16/11/1.
//  Copyright © 2016年 Ying Gaoxuan. All rights reserved.
//

#import "ViewController.h"

#include<iostream>
#include<algorithm>
#include<fstream>
#include<chrono>

#include<opencv2/opencv.hpp>

#include "System.h"
#include "MapPoint.h"

#include <unistd.h>

using namespace cv;
using namespace std;

const char *ORBvoc = [[[NSBundle mainBundle]pathForResource:@"ORBvoc" ofType:@"bin"] cStringUsingEncoding:[NSString defaultCStringEncoding]];
const char *settings = [[[NSBundle mainBundle]pathForResource:@"Settings" ofType:@"yaml"] cStringUsingEncoding:[NSString defaultCStringEncoding]];

ORB_SLAM2::System SLAM(ORBvoc,settings,ORB_SLAM2::System::MONOCULAR,false);

@interface ViewController ()
{
    CvVideoCamera* videoCamera;
}

@end

@implementation ViewController

@synthesize videoCamera = _videoCamera;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView.image = [UIImage imageNamed:@"icon.jpg"];
    
    self.videoCamera = [[CvVideoCamera alloc] initWithParentView:self.imageView];
    self.videoCamera.delegate = self;
    self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
    self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset640x480;
    self.videoCamera.defaultFPS = 30;
    self.videoCamera.grayscaleMode = NO;
}

- (IBAction)startButtonPressed:(id)sender
{
    [self.videoCamera start];
}

- (void)processImage:(cv::Mat &)image
{
    cv::Mat pose = SLAM.TrackMonocular(image,0);
    
    if(!pose.empty())
    {
        cv::Mat rVec;
        cv::Rodrigues(pose.colRange(0, 3).rowRange(0, 3), rVec);
        cv::Mat tVec = pose.col(3).rowRange(0, 3);
        const vector<ORB_SLAM2::MapPoint*> vpMPs = SLAM.mpTracker->mpMap->GetAllMapPoints();
        if (vpMPs.size() > 0) {
            std::vector<cv::Point3f> allmappoints;
            for (size_t i = 0; i < vpMPs.size(); i++) {
                if (vpMPs[i] && !vpMPs[i]->isBad())
                {
                    cv::Point3f pos = cv::Point3f(vpMPs[i]->GetWorldPos());
                    allmappoints.push_back(pos);
                }
            }
            std::vector<cv::Point2f> projectedPoints;
            cv::projectPoints(allmappoints, rVec, tVec, SLAM.mpTracker->mK, SLAM.mpTracker->mDistCoef, projectedPoints);
            for (size_t j = 0; j < projectedPoints.size(); ++j) {
                cv::Point2f r1 = projectedPoints[j];
                cv::circle(image, cv::Point(r1.x, r1.y), 2, cv::Scalar(0, 255, 0, 255), 1, 8);
            }
        }
        
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
