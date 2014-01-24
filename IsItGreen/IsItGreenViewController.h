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
    ///same for labelfeedback
    NSString *_FeedbackLabelString;
    NSString *_FeedbackLabelString2;
}


@property (strong, atomic) IBOutlet UIImageView *subImage;
@property (strong, atomic) ColorMatcher * matcher;
@property (strong, atomic) NSTimer * timer;


///image manipulation funcs
-(UIImage *)imageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer;
-(UIImage *)imageWithCVMat:(const cv::Mat&)cvMat;
-(cv::Mat)cvMatFromUIImage:(UIImage *)image;
-(UIImage*)crop:(UIImage *)image :(CGRect)rect;


///Setup funcs
-(void)prepVidCapture;
-(void)updateThumbnail;

///Utility funcs

///Called everytime our current timer iterates
-(void)TimerCallback;

-(bool)ShouldUpdateFeedback;
//Saves the current image to the camera roll along with
//feedback labelling
-(void)labelImage:(NSString *)text :(NSString *)text2 :(UIImage *)srcimg;
-(void)fadeNotification:(UILabel*)targetLabel;

@property (strong, nonatomic) IBOutlet UISlider *updateSpeedSlider;

@property (strong, nonatomic) IBOutlet UILabel *ColorNameLabel;
@property (strong, nonatomic) IBOutlet UIButton *pauseImageButton;
@property (strong, nonatomic) IBOutlet UIButton *captureButton;
@property (strong, nonatomic) IBOutlet UILabel *savedLabel;



@end
