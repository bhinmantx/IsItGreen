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
//#import "ImageUtils.h"
#import "UIImageResizing.h"


@interface IsItGreenViewController : UIViewController <AVCaptureVideoDataOutputSampleBufferDelegate>
{
    IBOutlet UIView *cameraFeed;
    

    
    
    AVCaptureSession *session;
    
    BOOL processVideoFrame;

    UIImage *thumbNail;

    
    NSArray *_json;
    
  
}


@property(nonatomic, retain) IBOutlet UIView *cameraFeed;

/////below is for still image capture
//@property(nonatomic, retain) AVCaptureStillImageOutput *stillImageOutput;

@property (strong, nonatomic) IBOutlet UIImageView *subImage;
@property (strong, nonatomic) UIImage *thumbNail;

//@property (strong,nonatomic)dispatch_queue_t captureQueue;

///image manipulation funcs
-(UIImage *)imageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer;
-(UIImage *)imageWithCVMat:(const cv::Mat&)cvMat;
-(cv::Mat)cvMatFromUIImage:(UIImage *)image;

-(void)prepVidCapture;
-(void)updateThumbnail;


@property (strong, nonatomic) IBOutlet UIButton *TriggerButton;

@end
