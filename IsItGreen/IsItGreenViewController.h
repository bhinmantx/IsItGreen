//
//  IsItGreenViewController.h
//  IsItGreen
//
//  Created by Brendan Hinman on 12/3/13.
//  Copyright (c) 2013 Brendan Hinman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVCaptureSession.h>
#import <AVFoundation/AVCaptureDevice.h>
#import <AVFoundation/AVCaptureInput.h>
#import <AVFoundation/AVCaptureOutput.h>
#import <AVFoundation/AVCaptureVideoPreviewLayer.h>
#import <AVFoundation/AVFoundation.h>
#import "ColorMatcher.h"
#import "UIImageResizing.h"


@interface IsItGreenViewController : UIViewController <AVCaptureVideoDataOutputSampleBufferDelegate>
{
    IBOutlet UIView *cameraFeed;
    
    AVCaptureSession *session;
    
    BOOL processVideoFrame;

    UIImage *thumbNail;
    ColorMatcher *_matcher;
    
    NSArray *_json;

}


@property(nonatomic, retain) IBOutlet UIView *cameraFeed;

/////below is for still image capture


@property (strong, nonatomic) IBOutlet UIImageView *subImage;
@property (strong, nonatomic) UIImage *thumbNail;
@property (strong, nonatomic) ColorMatcher * matcher;



///image manipulation funcs
-(UIImage *)imageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer;
-(UIImage *)imageWithCVMat:(const cv::Mat&)cvMat;
-(cv::Mat)cvMatFromUIImage:(UIImage *)image;
-(UIImage*)crop:(UIImage *)image :(CGRect)rect;


-(void)prepVidCapture;
-(void)updateThumbnail;


@property (strong, nonatomic) IBOutlet UIButton *TriggerButton;

@end
