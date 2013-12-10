//
//  IsItGreenViewController.m
//  IsItGreen
//
//  Created by Brendan Hinman on 12/3/13.
//  Copyright (c) 2013 Brendan Hinman. All rights reserved.
//

#import "IsItGreenViewController.h"
#import "AVFoundation/AVCaptureOutput.h"
//#import "ImageUtils.h"

@interface IsItGreenViewController ()

@end

@implementation IsItGreenViewController

@synthesize cameraFeed, subImage, thumbNail;
///For still image capture


- (void)viewDidLoad
{
    [super viewDidLoad];
      processVideoFrame = false;
    [self prepVidCapture];
	// Do any additional setup after loading the view, typically from a nib.
///make sure ui elements are in the right position
    subImage.layer.zPosition = 10;
    cameraFeed.layer.zPosition = 1;
    
    ///Load up our color data
    [self processJSON];
  
}


///Creates all the preview layers, adds inputs/outputs, registers the queue
-(void)prepVidCapture{

    session = [[AVCaptureSession alloc] init];
	
    
    CALayer *viewLayer = self.cameraFeed.layer;
    AVCaptureVideoPreviewLayer *captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
    
    ///This should properly size and fill the preview layer
    CGRect bounds=self.cameraFeed.layer.bounds;
    captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    captureVideoPreviewLayer.bounds=bounds;
    captureVideoPreviewLayer.position=CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
    
    
    captureVideoPreviewLayer.frame = viewLayer.bounds;
    
    [self.cameraFeed.layer addSublayer:captureVideoPreviewLayer];

	// Get the default camera device
	AVCaptureDevice* camera = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
	
	// Create a AVCaptureInput with the camera device
	NSError *error=nil;
	AVCaptureInput* cameraInput = [[AVCaptureDeviceInput alloc] initWithDevice:camera error:&error];
	if (cameraInput == nil) {
		NSLog(@"Error to create camera capture:%@",error);
	}
	
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
	
	// Start the session
	[session startRunning];	


}






- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
	
    ////Again, from APPLE
    if(processVideoFrame) {
        /// They want you to implement this!
        ////    https://developer.apple.com/library/ios/documentation/AudioVideo/Conceptual/AVFoundationPG/AVFoundationPG.pdf
        ///
        if(processVideoFrame){
        NSLog(@"The process image system was called");
         //  thumbNail = [self imageFromSampleBuffer:sampleBuffer];
        
        processVideoFrame =false;
        thumbNail = [self imageFromSampleBuffer:sampleBuffer];
         //  [self performSelectorOnMainThread:@selector(updateThumbnail) withObject:nil waitUntilDone:NO];
            
            ////In order to reliably update the UI I have to run such updates from the main thread
                dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"block async dispatch");
                //
                
                UIImage* smallImage = [thumbNail scaleToSize:CGSizeMake(100.0f,100.0f)];
                [subImage setImage:smallImage];
                
            });

        }
    }
	
}






- (IBAction)testTriggerButton:(id)sender {
    processVideoFrame = !processVideoFrame;
    NSLog(@"Button Press %x", processVideoFrame);
}




-(UIImage*)imageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    
        // This example assumes the sample buffer came from an AVCaptureOutput,
        //so its image buffer is known to be  a pixel buffer.
        NSLog(@"Image from sample buffer");
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
        UIImage *image = [UIImage imageWithCGImage:cgImage];
        
        
        CGImageRelease(cgImage);
        CVPixelBufferUnlockBaseAddress(imageBuffer, 0);

        return image;

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
    
    ///We're going to see if the data loaded correctly.
    //   for(int i = 0; i< _json.count; i++){
    //       NSLog(@"%@ %@ %@ %@", [[_json objectAtIndex:i] objectForKey:@"name"],[[_json objectAtIndex:i] objectForKey:@"r"],[[_json objectAtIndex:i] objectForKey:@"g"],[[_json objectAtIndex:i] objectForKey:@"b"]);
    //    }
    
}



-(void)updateThumbnail{
  
    CGSize newSize = CGSizeMake(384, 192);  //whatever size
    UIGraphicsBeginImageContext(newSize);
    //UIImage* image = thumbNail;
    [thumbNail drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
      [self subImage].image = newImage;
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
