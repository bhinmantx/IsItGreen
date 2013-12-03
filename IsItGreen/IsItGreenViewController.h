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


@interface IsItGreenViewController : UIViewController
{
    IBOutlet UIView *cameraFeed;
    
    
  
}


@property(nonatomic, retain) IBOutlet UIView *cameraFeed;

/////below is for still image capture
@property(nonatomic, retain) AVCaptureStillImageOutput *stillImageOutput;
@property (weak, nonatomic) IBOutlet UIImageView *captureImage;

@end
