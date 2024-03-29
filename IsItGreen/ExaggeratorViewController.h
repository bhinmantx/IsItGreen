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
#import "IsItGreenColorSelectionViewController.h"


@interface ExaggeratorViewController : UIViewController <AVCaptureVideoDataOutputSampleBufferDelegate,ColorSelectionViewControllerDelegate> {
    AVCaptureSession *session;
    
  //  IBOutlet UIView *exaggeratorFeed;
    
    BOOL processVideoFrame;
    
    NSTimer *_frameLimiterTimer;
    
    NSString *_colorOfInterest;
    
    ////REDUNDANT AGAIN
    ColorMatcher *_matcher;
    
    NSArray *_json;
    
     bool greenbuttonispressed;
    bool colorcheckiscomplete;
    std::map<NSString*,NSString*> friendlyNameToName;
    std::map<NSString*,NSString*> nameToFriendlyName;
}

@property (strong, nonatomic) IBOutlet UIImageView *ExaggeratorImageView;
@property (strong, atomic) NSTimer * frameLimiterTimer;

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *imageProcessActivityIndicator;
@property (strong, nonatomic) IBOutlet UIButton *IsItGreenButtonOutlet;

///REDUDANT CODE
-(UIImage *)imageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer;
-(UIImage *)imageWithCVMat:(const cv::Mat&)cvMat;
-(cv::Mat)cvMatFromUIImage:(UIImage *)image;
-(UIImage*)crop:(UIImage *)image :(CGRect)rect;

-(void)TimerCallback;

///Initialization helpers
-(void)prepVidCapture;
-(void)populateMaps;


//-(void)updateThumbnail;
-(IBAction)IsItGreenButton;


@end
