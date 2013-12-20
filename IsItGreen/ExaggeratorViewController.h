//
//  ExaggeratorViewController.h
//  IsItGreen
//
//  Created by Brendan Hinman on 12/19/13.
//  Copyright (c) 2013 Brendan Hinman. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import <opencv2/highgui/cap_ios.h>
#import <AVFoundation/AVCaptureSession.h>
#import <AVFoundation/AVCaptureDevice.h>
#import <AVFoundation/AVCaptureInput.h>
#import <AVFoundation/AVCaptureOutput.h>
#import <AVFoundation/AVCaptureVideoPreviewLayer.h>
#import <AVFoundation/AVFoundation.h>
#import "ColorMatcher.h"
#import "UIImageResizing.h"


@interface ExaggeratorViewController : UIViewController <AVCaptureVideoDataOutputSampleBufferDelegate> {
    AVCaptureSession *session;
    
  //  IBOutlet UIView *exaggeratorFeed;
    
    BOOL processVideoFrame;
    
    NSTimer *_frameLimiterTimer;
    
    
    ////REDUNDANT AGAIN
    ColorMatcher *_matcher;
    
    NSArray *_json;
    
     bool greenbuttonispressed;
    bool colorcheckiscomplete;
}

@property (strong, nonatomic) IBOutlet UIImageView *ExaggeratorImageView;
@property (strong, atomic) NSTimer * frameLimiterTimer;
@property (strong, nonatomic) IBOutlet UILabel *ProcessLabel;

///REDUDANT CODE
-(UIImage *)imageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer;
-(UIImage *)imageWithCVMat:(const cv::Mat&)cvMat;
-(cv::Mat)cvMatFromUIImage:(UIImage *)image;
-(UIImage*)crop:(UIImage *)image :(CGRect)rect;

-(void)TimerCallback;

-(void)prepVidCapture;
//-(void)updateThumbnail;
-(IBAction)IsItGreenButton;


@end
