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
    
    AVCaptureSession *session;
    
    ///Has the previous video frame finished?
    BOOL processVideoFrame;

    ColorMatcher *_matcher;
    
    NSArray *_json;
    NSTimer *_feedBackTimer;

    NSString *_colorOfInterest;
    
    bool isPaused;
    
    /////changing count from a static in the timer callback to
    /////a global var. Nice and dangerous. 
    int count;

}


@property (strong, atomic) IBOutlet UIImageView *subImage;
@property (strong, atomic) ColorMatcher * matcher;
@property (strong, atomic) NSTimer * timer;


///image manipulation funcs
-(UIImage *)imageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer;
-(UIImage *)imageWithCVMat:(const cv::Mat&)cvMat;
-(cv::Mat)cvMatFromUIImage:(UIImage *)image;
-(UIImage*)crop:(UIImage *)image :(CGRect)rect;
-(void)TimerCallback;


///Setup funcs
-(void)prepVidCapture;
-(void)updateThumbnail;

///Utility funcs
-(bool)ShouldUpdateFeedback;
-(void)burnTextIntoImage:(NSString *)text :(UIImage *)srcimg;

@property (strong, nonatomic) IBOutlet UISlider *updateSpeedSlider;

@property (strong, nonatomic) IBOutlet UILabel *ColorNameLabel;
@property (strong, nonatomic) IBOutlet UIButton *pauseImageButton;
@property (strong, nonatomic) IBOutlet UIButton *captureButton;



@end
