//
//  ImageUtils.h
//  IsItGreen
//
//  Created by Brendan Hinman on 12/19/13.
//  Copyright (c) 2013 Brendan Hinman. All rights reserved.
//





#import <UIKit/UIKit.h>



#import <UIKit/UIKit.h>
#import <AVFoundation/AVCaptureSession.h>
#import <AVFoundation/AVCaptureDevice.h>
#import <AVFoundation/AVCaptureInput.h>
#import <AVFoundation/AVCaptureOutput.h>
#import <AVFoundation/AVCaptureVideoPreviewLayer.h>
#import <AVFoundation/AVFoundation.h>
#import "ColorMatcher.h"
#import "UIImageResizing.h"


///image manipulation funcs

UIImage *imageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer;
UIImage *imageWithCVMat:(const cv::Mat&)cvMat;
cv::MatcvMatFromUIImage:(UIImage *)image;
UIImage*crop:(UIImage *)image :(CGRect)rect;
