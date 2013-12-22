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
#import "IsItGreenColorSelectionViewController.h"

@interface IsItGreenViewController : UIViewController <AVCaptureVideoDataOutputSampleBufferDelegate>
{
    IBOutlet UIView *cameraFeed;
    
    AVCaptureSession *session;
    
    BOOL processVideoFrame;

 //  UIImage *thumbNail;
    ColorMatcher *_matcher;
    
    NSArray *_json;
    NSTimer *_feedBackTimer;

    NSString *_colorOfInterest; 
    
    //bool greenbuttonispressed;
}


@property(nonatomic, strong) IBOutlet UIView *cameraFeed;

/////below is for still image capture


@property (strong, atomic) IBOutlet UIImageView *subImage;
//@property (strong, atomic) UIImage *thumbNail;
@property (strong, atomic) ColorMatcher * matcher;
@property (strong, atomic) NSTimer * timer;


///image manipulation funcs
-(UIImage *)imageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer;
-(UIImage *)imageWithCVMat:(const cv::Mat&)cvMat;
-(cv::Mat)cvMatFromUIImage:(UIImage *)image;
-(UIImage*)crop:(UIImage *)image :(CGRect)rect;
-(void)TimerCallback;


-(void)prepVidCapture;
-(void)updateThumbnail;

@property (strong, nonatomic) IBOutlet UILabel *ColorNameLabel;

@property (strong, nonatomic) IBOutlet UIButton *TriggerButton;

@end
