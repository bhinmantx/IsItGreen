//
//  IsItGreenViewController.m
//  IsItGreen
//
//  Created by Brendan Hinman on 12/3/13.
//  Copyright (c) 2013 Brendan Hinman. All rights reserved.
//

#import "IsItGreenViewController.h"
#import "AVFoundation/AVCaptureOutput.h"
#import "ColorMatcher.h"



@interface IsItGreenViewController ()

@end

@implementation IsItGreenViewController

//@synthesize cameraFeed, subImage, thumbNail;
//////REMEMBER TO CHANGE THIS BACK
@synthesize subImage;
@synthesize matcher = _matcher;
@synthesize timer = _timer;
@synthesize ColorNameLabel;
///For still image capture

////From the rosy writer code
#define BYTES_PER_PIXEL 4

- (void)viewDidLoad
{
    [super viewDidLoad];
    processVideoFrame = true;
    isPaused = false;
    
    [self prepVidCapture];
	// Do any additional setup after loading the view, typically from a nib.
    ///make sure ui elements are in the right position
    subImage.layer.zPosition = 10;
    ColorNameLabel.layer.zPosition = 15;
    [self pauseImageButton].layer.zPosition = 15;
    [self captureButton].layer.zPosition = 15;
    [self savedLabel].layer.zPosition = 15;
//    [self WhiteBalancer].layer.zPosition = 15;
    [self torchButton].layer.zPosition = 15; 
    
    ///Setup our timer
      _timer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(TimerCallback) userInfo:nil repeats:YES];
    
    ///Load up our color data
    [self processJSON];
    ///create our matcher
    _matcher = [[ColorMatcher alloc]initWithJSON:_json];
   // updateSpeedSlider.value

    ////Let's take care of the torch
    if(camera.torchAvailable)
    {
        _torchButton.hidden = false;
    }
}
-(void)viewWillDisappear:(BOOL)animated{

    NSError * error = nil;
    
    ///make sure the lamp is off
    if([camera lockForConfiguration:&error])
    {
        camera.torchMode = AVCaptureTorchModeOff;
        [camera unlockForConfiguration];
    }
    
    [session stopRunning];
    
}

-(void)viewWillAppear:(BOOL)animated{
    
    ////Take care of the pause button sometimes not changing
    [[self pauseImageButton] setImage:[UIImage imageNamed:@"pause_circle_w_back.png"] forState:UIControlStateNormal];
    isPaused = false;
    
    
    if(camera.torchAvailable)
    {
        _torchButton.hidden = false;
    }
    
    
    processVideoFrame = true;
    [session startRunning];
}


///Creates all the preview layers, adds inputs/outputs, registers the queue
-(void)prepVidCapture{

    session = [[AVCaptureSession alloc] init];
	//session.sessionPreset = AVCaptureSessionPreset640x480;
    session.sessionPreset = AVCaptureSessionPreset352x288;


	// Get the default camera device
	camera = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
	
	// Create a AVCaptureInput with the camera device
	NSError *error=nil;
	AVCaptureInput* cameraInput = [[AVCaptureDeviceInput alloc] initWithDevice:camera error:&error];
	if (cameraInput == nil) {
		NSLog(@"Error to create camera capture:%@",error);
	}
	
    ///We need to set the orientation:
    
    
	// Set the output
	AVCaptureVideoDataOutput* videoOutput = [[AVCaptureVideoDataOutput alloc] init];
	
	// create a queue to run the capture on
	dispatch_queue_t captureQueue=dispatch_queue_create("myQueue", NULL);
	
	// setup our delegate
	[videoOutput setSampleBufferDelegate:self queue:captureQueue];

	// configure the pixel format
	videoOutput.videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA], (id)kCVPixelBufferPixelFormatTypeKey,
									 nil];

	// and the size of the frames we want
	//[session setSessionPreset:AVCaptureSessionPresetMedium];

	// Add the input and output
	[session addInput:cameraInput];
	[session addOutput:videoOutput];
	
    ///Set the orientation here?
    [videoOutput.connections[0] setVideoOrientation:AVCaptureVideoOrientationPortrait];
    
	// Start the session
	[session startRunning];	

}






- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
	
    ////Again, from APPLE
    
        /// They want you to implement this!
        ////    https://developer.apple.com/library/ios/documentation/AudioVideo/Conceptual/AVFoundationPG/AVFoundationPG.pdf
        ///
        if(processVideoFrame){
            //////////////////////////REMEMBER TO CHANGE THIS BACK ////////////////////
        processVideoFrame =false;
        //thumbNail = [self imageFromSampleBuffer:sampleBuffer];
          UIImage * newThumbNail = [self imageFromSampleBuffer:sampleBuffer];
            
            ////In order to reliably update the UI I have to run such updates from the main thread
                dispatch_async(dispatch_get_main_queue(), ^{
                [self subImage].hidden = false;
                [subImage setImage:newThumbNail];
                
        });
    }

}

/*
- (IBAction)AttemptWhiteBalance:(id)sender {
    NSLog(@"Attempting White Balance");
    //NSError * error = [[NSError alloc]init];
    NSError *error=nil;
    if([camera lockForConfiguration:&error]){
        camera.whiteBalanceMode = AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance;
                NSLog(@"Is camera white balancing now? %hhd", camera.adjustingWhiteBalance);
        NSLog(@"Is white balance locked mode supported %hhd", [camera isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeLocked]);
        NSLog(@"Is white balance auto mode supported %hhd", [camera isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeAutoWhiteBalance]);
        NSLog(@"Is white balance continuous mode supported %hhd", [camera isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance]);
//        camera.whiteBalanceMode = AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance;
       // camera.whiteBalanceMode = AVCaptureWhiteBalanceModeAutoWhiteBalance;
        camera.whiteBalanceMode = AVCaptureWhiteBalanceModeLocked;
        
        NSLog(@"Howabout now? %hhd", camera.adjustingWhiteBalance);
        
        [camera unlockForConfiguration];
    }
    else
        NSLog(@"%@", error);
    
 
}
*/

- (IBAction)switchTorch:(id)sender {
    
    NSError * error;
    if([camera lockForConfiguration:&error])
    {
        NSLog(@"Is torch auto mode supported? %hhd", [camera isTorchModeSupported:AVCaptureTorchModeAuto]);
        NSLog(@"Is torch on supported? %hhd", [camera isTorchModeSupported:AVCaptureTorchModeOn]);
        
        if (camera.torchMode == AVCaptureTorchModeOff)
        {
            if([camera isTorchModeSupported:(AVCaptureTorchModeAuto)]){
                camera.torchMode = AVCaptureTorchModeOn;
            }
        else
            camera.torchMode = AVCaptureTorchModeOff;
        
            [camera unlockForConfiguration];
        }
        
    }
    
}


- (IBAction)captureButton:(id)sender {

    //probably a bad way to do this
    processVideoFrame = false;
    
    
    [self labelImage:_FeedbackLabelString :_FeedbackLabelString2 :[self subImage].image];
    
  //  UIImageWriteToSavedPhotosAlbum([self subImage].image, Nil, nil, nil);

    processVideoFrame = true;
    
    ////To get reliable UI updates I have to do this from the main thread.
    

    [self savedLabel].hidden = false;
    [self fadeNotification:[self savedLabel]];


}



- (IBAction)pauseButton:(id)sender {

    if(isPaused){
        processVideoFrame = true;
       // [self pauseImageButton].imageView.image = [UIImage imageNamed:@"pause circle.png"];
        [[self pauseImageButton] setImage:[UIImage imageNamed:@"pause_circle_w_back.png"] forState:UIControlStateNormal];
        isPaused = !isPaused;
    }
    else if(!isPaused)
    {
        processVideoFrame = false;
//        [self pauseImageButton].imageView.image = [UIImage imageNamed:@"playicon.png"];
        [[self pauseImageButton] setImage:[UIImage imageNamed:@"play_circle_w_back_no_circle.png"] forState:UIControlStateNormal];
        isPaused = !isPaused;
    }
}


-(void)TimerCallback{
  //  static int count = 0;
    
    count++;
/*
    if(count>3){
        count = 0;
      	//processVideoFrame = true;
//        [self subImage].hidden = true;
    }
 */
}

-(bool)ShouldUpdateFeedback{
    
    if(count > ((-1*[self updateSpeedSlider].value))){
        count = 0;
        return true;
    }
    
    return false;
}


-(UIImage*)imageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    
        // This example assumes the sample buffer came from an AVCaptureOutput,
        //so its image buffer is known to be  a pixel buffer.
     //   NSLog(@"Image from sample buffer");
        CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        //Lock the base address of the pixel buffer.
        CVPixelBufferLockBaseAddress(imageBuffer,0);
        //Get the number of bytes per row for the pixel buffer.
        size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
        //Get the pixel  buffer width and height.
        size_t width = CVPixelBufferGetWidth(imageBuffer);
        size_t height = CVPixelBufferGetHeight(imageBuffer);
        //Create a device-dependent RGB color space.

        static CGColorSpaceRef colorSpace = NULL;
        
        if (colorSpace == NULL) {
            colorSpace = CGColorSpaceCreateDeviceRGB();
            if (colorSpace == NULL){
                // Handle the error appropriately.
                
                return nil;
            }
        }
    
    
    ///alright let's try the processing code here
   unsigned char *pixel = (unsigned char *)CVPixelBufferGetBaseAddress(imageBuffer);
    
    
    int originx = (int)width;
    int originy = (int)height;
    int fwidth = (int)width;
    
    ///Set our actual starting positions as the center with a 5 pixel offset
    int x = (originx/2) - 5;
    int y = (originy/2) - 5;

    size_t r = 0;
    size_t g = 0;
    size_t b = 0;
    for(int i = 0; i<=9; i++){
        
        
        for(int j = 0; j<=9; j++){
            ///Get our position in the buffer
            int pixnumber = ((y+j)*(fwidth) + (x+i));
            


            unsigned char* pixptr = (pixel + ((BYTES_PER_PIXEL)*(pixnumber)));

            b += pixptr[0];
            g += pixptr[1];
            r += pixptr[2];
            
            ///Draw our box
            if ((i == 0) || (j == 0) || (i == 9) || (j == 9)) {
            pixptr[0] = 0;
            pixptr[1] = 0;
            pixptr[2] = 0;
            }

            
        }
    
    }
   
    int R = (r/100);
    int G = (g/100);
    int B = (b/100);

    
    static bool firstTime = true;
    
    if([self ShouldUpdateFeedback] || firstTime){
        NSString* result = [_matcher getNameFromRGB:R:G:B];
        firstTime = false;
        
        NSString *feedback = [NSString stringWithFormat:@"%@ R %i G %i B %i", result, R,G,B];
        _FeedbackLabelString = result;
        _FeedbackLabelString2 = [NSString stringWithFormat:@"Raw Values: Red: %i Green: %i Blue: %i", R,G,B];
    
    ////In order to reliably update the UI I have to run such updates from the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
        [self ColorNameLabel].text = feedback;
        [[self ColorNameLabel] setNeedsDisplay];
        });
    
    }
      
        // Get the base address of the pixel buffer.
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
        // Get the data size for contiguous planes of the pixel buffer.
    size_t bufferSize = CVPixelBufferGetDataSize(imageBuffer);

        // Create a Quartz direct-access data provider that uses data we supply.
        //a solution to that bad access from
        //// http://stackoverflow.com/questions/10774392/cgcontextdrawimage-crashes
    

    NSData *data = [NSData dataWithBytes:baseAddress length:bufferSize];

    CGDataProviderRef dataProvider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
        // Create a bitmap image from data supplied by the data provider.
    CGImageRef cgImage = CGImageCreate(width, height, 8, 32, bytesPerRow, colorSpace, kCGImageAlphaNoneSkipFirst | kCGBitmapByteOrder32Little, dataProvider, NULL, true, kCGRenderingIntentDefault);
        
    CGDataProviderRelease(dataProvider);
        // Create and return an image object to represent the Quartz image.
  //  NSLog(@"About to create the image");
    UIImage *image = [UIImage imageWithCGImage:cgImage];
        
        
    CGImageRelease(cgImage);
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);

    processVideoFrame = true;
    return image;

}

////For labelling the image we're saving

//- (UIImage *)burnTextIntoImage:(NSString *)text :(UIImage *)srcimg {
- (void)labelImage:(NSString *)text :(NSString *)text2 :(UIImage *)srcimg {
    
    UIImage * img = srcimg;
    
    
    ///To support retina
    if (UIGraphicsBeginImageContextWithOptions != NULL)
        UIGraphicsBeginImageContextWithOptions(img.size,NO,0.0);
    else
        UIGraphicsBeginImageContext(img.size);
    
    CGRect aRectangle = CGRectMake(0,0, img.size.width, img.size.height);
    CGRect fontRect = CGRectMake(0,((img.size.height/2) + 30), img.size.width, 18);
    CGRect fontRect2 = CGRectMake(0,((img.size.height/2) + 48), img.size.width, 14);
    
    ///Draw original image with our crosshair
    [img drawInRect:aRectangle];
    
    [[UIColor colorWithWhite:0.0 alpha:0.4] setFill];
//    [[UIColor blackColor] setFill];

    CGContextRef context = UIGraphicsGetCurrentContext();
    
   // CGContextSetFillColorWithColor(context, [UIColor blueColor].CGColor);
     CGContextFillRect(context, fontRect);
         CGContextFillRect(context, fontRect2);
//    UIRectFillUsingBlendMode(fontRect, kCGBlendModeNormal);

  
    [[UIColor whiteColor] set];           // set text color
    NSInteger fontSize = 14;
    if ( [text length] > 200 ) {
        fontSize = 10;
    }
    UIFont *font = [UIFont boldSystemFontOfSize: fontSize];     // set text font
    UIFont *font2 = [UIFont boldSystemFontOfSize: 10];
    
    //[text drawInRect:fontRect withFont:font alignment:NSTextAlignmentCenter];
    [text drawInRect:fontRect withFont:font lineBreakMode:NSLineBreakByTruncatingTail alignment:NSTextAlignmentCenter];
    ///We're trying to make a sub caption
    [text2 drawInRect:fontRect2 withFont:font2 lineBreakMode:NSLineBreakByTruncatingTail alignment:NSTextAlignmentCenter];

     
    UIImage *theImage=UIGraphicsGetImageFromCurrentImageContext();   // extract the image
    UIGraphicsEndImageContext();     // clean  up the context.
    UIImageWriteToSavedPhotosAlbum(theImage, Nil, nil, nil);
    //return theImage;
}


/**
 For conversion of foundation images to OpenCV mats
 */
- (cv::Mat)cvMatFromUIImage:(UIImage *)image
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels
    
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to  data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    CGColorSpaceRelease(colorSpace);
    
    return cvMat;
}


/**
 Convert mat to uiimage
 */
- (UIImage *)imageWithCVMat:(const cv::Mat&)cvMat
{
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize() * cvMat.total()];
    
    CGColorSpaceRef colorSpace;
    
    if (cvMat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    CGImageRef imageRef = CGImageCreate(cvMat.cols,                                     // Width
                                        cvMat.rows,                                     // Height
                                        8,                                              // Bits per component
                                        8 * cvMat.elemSize(),                           // Bits per pixel
                                        cvMat.step[0],                                  // Bytes per row
                                        colorSpace,                                     // Colorspace
                                        kCGImageAlphaNone | kCGBitmapByteOrderDefault,  // Bitmap info flags
                                        provider,                                       // CGDataProviderRef
                                        NULL,                                           // Decode
                                        false,                                          // Should interpolate
                                        kCGRenderingIntentDefault);                     // Intent
    
    UIImage *image = [[UIImage alloc] initWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return image;
}

-(void)processJSON{
    
    ///First we pull the data from the file
    
    NSError* noError;
    
    NSData *jsFile = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"colordata2" ofType:@"js"]];
    
    _json = [NSJSONSerialization JSONObjectWithData:jsFile options:0 error:&noError];
    
    NSLog(@"JSON count: %i", _json.count);
    
}



-(void)updateThumbnail{
  /*
    CGSize newSize = CGSizeMake(384, 192);  //whatever size
    UIGraphicsBeginImageContext(newSize);
    //UIImage* image = thumbNail;
    [thumbNail drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
      [self subImage].image = newImage;
   */
}


///Takes a label and then makes sure it's visible
///then fades it out. 
-(void)fadeNotification:(UILabel*)targetLabel
{


  
    targetLabel.hidden = false;
    targetLabel.alpha = 1.0;

    [UIView animateWithDuration:0.5 delay:0.2 options:UIViewAnimationCurveEaseInOut animations:^{
            targetLabel.alpha = 0.0;

        }
                     completion:^(BOOL finished){
                            targetLabel.hidden = true;

                     }];

}


-(UIImage*) crop:(UIImage *)image :(CGRect)rect {
    UIGraphicsBeginImageContextWithOptions([image size], false, [image scale]);
//    [image drawAtPoint:CGPointMake(-rect.origin.x, -rect.origin.y))];
    [image drawAtPoint:CGPointMake(-rect.origin.x, -rect.origin.y)];
    UIImage* cropped_image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return cropped_image;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}






@end
