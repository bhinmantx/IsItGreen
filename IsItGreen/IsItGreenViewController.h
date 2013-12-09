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


@interface IsItGreenViewController : UIViewController <AVCaptureVideoDataOutputSampleBufferDelegate>
{
    IBOutlet UIView *cameraFeed;
    
    ////Image utility. Very expensive!
    
    
    AVCaptureSession *session;
    
    BOOL processVideoFrame;
   // dispatch_queue_t captureQueue;
    UIImage *thumbNail;
    //Image *thumbNail;
  
}


@property(nonatomic, retain) IBOutlet UIView *cameraFeed;

/////below is for still image capture
//@property(nonatomic, retain) AVCaptureStillImageOutput *stillImageOutput;
@property (weak, nonatomic) IBOutlet UIImageView *captureImage;
@property (strong, nonatomic) IBOutlet UIImageView *subImage;
@property (strong, nonatomic) UIImage *thumbNail;

//@property (strong,nonatomic)dispatch_queue_t captureQueue;

-(UIImage *)imageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer;
-(void)prepVidCapture;
-(void)updateThumbnail;


@property (strong, nonatomic) IBOutlet UIButton *TriggerButton;

@end
