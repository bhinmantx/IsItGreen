//
//  IsItGreenViewController.m
//  IsItGreen
//
//  Created by Brendan Hinman on 12/3/13.
//  Copyright (c) 2013 Brendan Hinman. All rights reserved.
//

#import "IsItGreenViewController.h"
#import "AVFoundation/AVCaptureOutput.h"
#import "ImageUtils.h"

@interface IsItGreenViewController ()

@end

@implementation IsItGreenViewController

@synthesize cameraFeed, subImage;
///For still image capture
@synthesize captureImage;

- (void)viewDidLoad
{
    [super viewDidLoad];
      processVideoFrame = false;
    [self prepVidCapture];
	// Do any additional setup after loading the view, typically from a nib.

  
}


///Creates all the preview layers, adds inputs/outputs, registers the queue
-(void)prepVidCapture{



///Below is all of my broken code.  Example code being pasted in until I can figure out what's going on.



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
    
    
	// create a preview layer to show the output from the camera
	//AVCaptureVideoPreviewLayer *previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:session];
	//previewLayer.frame = cameraFeed.frame;
	//[cameraFeed.layer addSublayer:previewLayer];
	
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






   /* AVCaptureSession *session = [[AVCaptureSession alloc] init];
    
    CALayer *viewLayer = self.cameraFeed.layer;
    AVCaptureVideoPreviewLayer *captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
    
    ///This should properly size and fill the preview layer
    CGRect bounds=self.cameraFeed.layer.bounds;
    captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    captureVideoPreviewLayer.bounds=bounds;
    captureVideoPreviewLayer.position=CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
    
    
    captureVideoPreviewLayer.frame = viewLayer.bounds;
    
    [self.cameraFeed.layer addSublayer:captureVideoPreviewLayer];
    
    
    
    // AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:@"AVMediaTypeVideo"];

    NSArray *devices = [AVCaptureDevice devices];
    AVCaptureDevice *frontCamera;
    AVCaptureDevice *backCamera;
    
    for (AVCaptureDevice *device in devices) {
        
        NSLog(@"Device name: %@", [device localizedName]);
        
        if ([device hasMediaType:AVMediaTypeVideo]) {
            
            if ([device position] == AVCaptureDevicePositionBack) {
                NSLog(@"Device position : back");
                backCamera = device;
            }
            else {
                NSLog(@"Device position : front");
                frontCamera = device;
            }
        }
    }

    
    NSError *error = nil;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:backCamera error:&error];

    session.sessionPreset = AVCaptureSessionPresetMedium;

    [session addInput:input];
    
    
    
    ///Trying to create outputs
    ///According to Apple this is how we go about grabbing a still image.
    */
    /*
     https://developer.apple.com/library/ios/documentation/AudioVideo/Conceptual/AVFoundationPG/AVFoundationPG.pdf
     */
     /*
    AVCaptureVideoDataOutput  *output = [[AVCaptureVideoDataOutput alloc]  init];
    
    output.videoSettings = @{ (NSString *)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA) };
    
    // output.minFrameDuration = CMTimeMake(1, 15);
    
    ///For our "Augemented Reality" aspects we need a Queue, whatever that is.
    ///TODO: LOOK UP QUEUES
    dispatch_queue_t captureQueue=dispatch_queue_create("MyQueue", NULL);

    
    [output setSampleBufferDelegate:self queue:captureQueue];
    
    
   // stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
  //  NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys: AVVideoCodecJPEG, AVVideoCodecKey, nil];
   // [stillImageOutput setOutputSettings:outputSettings];
    

   // [session addOutput:stillImageOutput];
    [session addOutput:output];
    
	[session startRunning];
    
    */
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
            
            
            
            
            CVImageBufferRef cvimgRef = CMSampleBufferGetImageBuffer(sampleBuffer);
            // Lock the image buffer
            CVPixelBufferLockBaseAddress(cvimgRef,0);
            // access the data
            int width=CVPixelBufferGetWidth(cvimgRef);
            int height=CVPixelBufferGetHeight(cvimgRef);
            // get the raw image bytes
            uint8_t *buf=(uint8_t *) CVPixelBufferGetBaseAddress(cvimgRef);
            size_t bprow=CVPixelBufferGetBytesPerRow(cvimgRef);
            // turn it into something useful
            thumbNail=createImage(buf, bprow, width, height);
    
            
            [self performSelectorOnMainThread:@selector(updateThumbnail) withObject:nil waitUntilDone:NO];
//        [self updateThumbnail];
            
        }
    }
	
}



//So the following func worked for a bit and then stopped. I don't know why. Typo?
/*
-(void)captureOutput:(AVCaptureOutput *)captureOutput didDropSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
   

    
    ////Again, from APPLE
    if(processVideoFrame) {
    /// They want you to implement this!
 ////    https://developer.apple.com/library/ios/documentation/AudioVideo/Conceptual/AVFoundationPG/AVFoundationPG.pdf
     ///
        processVideoFrame =false;
        NSLog(@"The process image system was called");
 UIImage *image = [self imageFromSampleBuffer:sampleBuffer];

        //processVideoFrame =false;
   // [self subImage].image = image;
    }
}
*/


- (IBAction)testTriggerButton:(id)sender {
    processVideoFrame = !processVideoFrame;
    NSLog(@"Button Press %x", processVideoFrame);
}



-(UIImage *)imageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer{
    // This example assumes the sample buffer came from an AVCaptureOutput,
    //so its image buffer is known to be  a pixel buffer.
    NSLog(@"Image from sample buffer");
/*
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    //Lock the base address of the pixel buffer.
    CVPixelBufferLockBaseAddress(imageBuffer,0);
    
    
    //Get the number of bytes per row for the pixel buffer.
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    //Get the pixel  buffer width and height.
    
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    //Create a device-dependent RGB color space.
  NSLog(@"Image size: width %zx height: %zx", width, height);
    static CGColorSpaceRef colorSpace = NULL;
    
    if (colorSpace == NULL) {
        colorSpace = CGColorSpaceCreateDeviceRGB();
        if (colorSpace == NULL){
            // Handle the error appropriately.
            
            return nil;
        }
    }
    */
    /* *//*
    Get the base address of the pixel buffer.
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    // Get the data size for contiguous planes of the pixel buffer.
    size_t bufferSize = CVPixelBufferGetDataSize(imageBuffer);
    
    // Create a Quartz direct-access data provider that uses data we supply.
    
    CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL,baseAddress, bufferSize, NULL);
    // Create a bitmap image from data supplied by the data provider.
    
    CGImageRef cgImage = CGImageCreate(width, height, 8, 32, bytesPerRow, colorSpace, kCGImageAlphaNoneSkipFirst | kCGBitmapByteOrder32Little, dataProvider, NULL, true, kCGRenderingIntentDefault);
    
    CGDataProviderRelease(dataProvider);
    // Create and return an image object to represent the Quartz image.
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    
    
    CGImageRelease(cgImage); 
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0); 
    return image;
    */
    
}

-(void)updateThumbnail{
    
    NSLog(@"thumbNail is %f wide", thumbNail.size.width);
    [self subImage].image = [self thumbNail];
    //[[self subImage] setNeedsDisplay];
//    subImage.image = [UIImage imageNamed:@"IsItGreen512.png"];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
