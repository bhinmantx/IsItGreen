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
            /*
             ///His AR code
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
             */
            thumbNail = [self imageFromSampleBuffer:sampleBuffer];
            
          //  [self performSelectorOnMainThread:@selector(updateThumbnail) withObject:nil waitUntilDone:NO];
            
 /*
            
            dispatch_async(dispatch_get_main_queue(), ^{
                 NSLog(@"block async dispatch");
                [subImage setImage:thumbNail];
            
            });
  */
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
    ///Original line below
///        CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL,baseAddress, bufferSize, NULL);
        // Create a bitmap image from data supplied by the data provider.
        CGImageRef cgImage = CGImageCreate(width, height, 8, 32, bytesPerRow, colorSpace, kCGImageAlphaNoneSkipFirst | kCGBitmapByteOrder32Little, dataProvider, NULL, true, kCGRenderingIntentDefault);
        
        CGDataProviderRelease(dataProvider);
        // Create and return an image object to represent the Quartz image.
        UIImage *image = [UIImage imageWithCGImage:cgImage];
        
        
       CGImageRelease(cgImage);
        CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    
    NSLog(@"Width %zx height %zx", width, height);
    
    ////We need to run UI updates on the main thread. I still think this *might* be some kind of image
    ////size issue, there's just no good way to tell for me.
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"block async dispatch");
//
        
        UIImage* smallImage = [image scaleToSize:CGSizeMake(100.0f,100.0f)];
        [subImage setImage:smallImage];
    
    });

    
        return image;
    
    
    //return [UIImage imageNamed:@"IsItGreen512.png"];
}

    


-(void)updateThumbnail{
    
    NSLog(@"thumbNail is %f wide", thumbNail.size.width);
    
    CGSize newSize = CGSizeMake(384, 192);  //whatever size
    UIGraphicsBeginImageContext(newSize);
    //UIImage* image = thumbNail;
    [thumbNail drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
      [self subImage].image = newImage;
//    [self subImage].image = [self thumbNail];
    //[[self subImage] setNeedsDisplay];
//    subImage.image = [UIImage imageNamed:@"IsItGreen512.png"];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
