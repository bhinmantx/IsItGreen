//
//  ExaggeratorViewController.m
//  IsItGreen
//
//  Created by Brendan Hinman on 12/19/13.
//  Copyright (c) 2013 Brendan Hinman. All rights reserved.
//

#import "ExaggeratorViewController.h"
#import "AVFoundation/AVCaptureOutput.h"
#define BYTES_PER_PIXEL 4

@interface ExaggeratorViewController ()

@end

@implementation ExaggeratorViewController


@synthesize ExaggeratorImageView;
@synthesize frameLimiterTimer = _frameLimiterTimer;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    [super viewDidLoad];
    [self processJSON];
    _matcher = [[ColorMatcher alloc]initWithJSON:_json];
      ///And set up our timer
    _frameLimiterTimer = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(TimerCallback) userInfo:nil repeats:YES];
    processVideoFrame = true;
    [self prepVidCapture];
  
    _imageProcessActivityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];

    _imageProcessActivityIndicator.center = CGPointMake(160, 160);
    [self.view addSubview:_imageProcessActivityIndicator];
    _imageProcessActivityIndicator.layer.zPosition = 10;

    _imageProcessActivityIndicator.hidesWhenStopped = YES;
    


}
-(void)viewWillDisappear:(BOOL)animated{
    
    [session stopRunning];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [session startRunning];
    greenbuttonispressed = false;
    colorcheckiscomplete = false;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

////Redundant Code!

///Creates all the preview layers, adds inputs/outputs, registers the queue
-(void)prepVidCapture{
    
    session = [[AVCaptureSession alloc] init];
//	session.sessionPreset = AVCaptureSessionPreset640x480;
    session.sessionPreset = AVCaptureSessionPreset352x288;
    
    
	// Get the default camera device
	AVCaptureDevice* camera = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
	
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
	dispatch_queue_t captureQueue=dispatch_queue_create("ExaggeratorQueue", NULL);
	
	// setup our delegate
	[videoOutput setSampleBufferDelegate:self queue:captureQueue];
    
	// configure the pixel format
	videoOutput.videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA], (id)kCVPixelBufferPixelFormatTypeKey,
                                 nil];
   
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
        //     NSLog(@"The process image system was called");
        //  thumbNail = [self imageFromSampleBuffer:sampleBuffer];

        
        //////////////////////////REMEMBER TO CHANGE THIS BACK ////////////////////
        processVideoFrame =false;
        //thumbNail = [self imageFromSampleBuffer:sampleBuffer];
        UIImage * newThumbNail = [self imageFromSampleBuffer:sampleBuffer];
       // NSLog(@"Image Finished Being Created with width %f and height %f", newThumbNail.size.width, newThumbNail.size.height);
        ///Crop the image to the center and 50 by 50
        
   ///Wait a minute this isn't right
        ///eset352x288;
      //  int overLayX = (newThumbNail.size.width / 2) - 160;
     //   int overLayY = (newThumbNail.size.height /2) - 120;
        
        //   CGImageRef imageRef = CGImageCreateWithImageInRect([thumbNail CGImage], CGRectMake(thumbNail.size.width  , thumbNail.size.height / 2 , 320, 240));
        
        ///Original
//        CGImageRef  imageRef = CGImageCreateWithImageInRect([newThumbNail CGImage], CGRectMake(overLayX  , overLayY , 320, 240));
    //     CGImageRef  imageRef = CGImageCreateWithImageInRect([newThumbNail CGImage], CGRectMake(overLayX  , overLayY , 352, 288));
        //  NSLog(@"JUST CROPPED");
        
    //    UIImage * smallImage = [UIImage imageWithCGImage:imageRef scale:newThumbNail.scale /2 orientation:newThumbNail.imageOrientation];
    //    CGImageRelease(imageRef);
     
        ////In order to reliably update the UI I have to run such updates from the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            //                NSLog(@"block async dispatch");
            ////Previously working
           // [[self ExaggeratorImageView] setImage:smallImage];
            
            [[self ExaggeratorImageView] setImage:newThumbNail];
            [_imageProcessActivityIndicator stopAnimating];
        
            [self ExaggeratorImageView].hidden = false;
            // [subImage setImage:thumbNail];
 
        });

    }
    
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
    //        NSLog(@"Height and width");
    static CGColorSpaceRef colorSpace = NULL;
    
    if (colorSpace == NULL) {
        colorSpace = CGColorSpaceCreateDeviceRGB();
        if (colorSpace == NULL){
            // Handle the error appropriately.
            
            return nil;
        }
    }

    ////Now let's try the color matcher
    

    if(greenbuttonispressed){
        processVideoFrame = false;
    unsigned char *pixel = (unsigned char *)CVPixelBufferGetBaseAddress(imageBuffer);
        colorcheckiscomplete = false;
    
    for( int row = 0; row < height; row++ ) {
        
        for( int column = 0; column < width; column++ ) {
            
            ///HA HA. IT'S IN REVERSE ORDER
            int r,g,b;
            b = pixel[0];
            g = pixel[1];
            r = pixel[2];
            
            
            if([_matcher checkNearestFromRGB:pixel[2] :pixel[1] :pixel[0] :@"g"]){
                pixel[2] = 0; // Total-green (second pixel in BGRA is green)
                pixel[0] = 0;
            }
            ///if it's not green, it's grayscale
            else{
                int average = (r + g + b)/3.0;
                pixel[0] = average;
                pixel[1] = average;
                pixel[2] = average;
            }
            
                
            
            pixel += BYTES_PER_PIXEL;
            
        }
       // NSLog(@"checking");

    }
        NSLog(@"Check is complete");
       
        colorcheckiscomplete = true;
    }
    
    
    // Get the base address of the pixel buffer.
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    // Get the data size for contiguous planes of the pixel buffer.
    size_t bufferSize = CVPixelBufferGetDataSize(imageBuffer);
    //  NSLog(@"Got Pixel Buffer Data");
    // Create a Quartz direct-access data provider that uses data we supply.
    //a solution to that bad access from
    //// http://stackoverflow.com/questions/10774392/cgcontextdrawimage-crashes
    
    ///We have a memory leak somewhere. But we've got ARC!?
    NSData *data = [NSData dataWithBytes:baseAddress length:bufferSize];
    // NSLog(@"DATA CREATED");
    CGDataProviderRef dataProvider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    // Create a bitmap image from data supplied by the data provider.
    CGImageRef cgImage = CGImageCreate(width, height, 8, 32, bytesPerRow, colorSpace, kCGImageAlphaNoneSkipFirst | kCGBitmapByteOrder32Little, dataProvider, NULL, true, kCGRenderingIntentDefault);
    
    CGDataProviderRelease(dataProvider);
    // Create and return an image object to represent the Quartz image.
    //  NSLog(@"About to create the image");
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    
    
    CGImageRelease(cgImage);
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    
  //  print_free_memory();
    //NSLog(@"RETURNING IMAGE");
    return image;
    
}
-(UIImage*) crop:(UIImage *)image :(CGRect)rect {
    UIGraphicsBeginImageContextWithOptions([image size], false, [image scale]);
    //    [image drawAtPoint:CGPointMake(-rect.origin.x, -rect.origin.y))];
    [image drawAtPoint:CGPointMake(-rect.origin.x, -rect.origin.y)];
    UIImage* cropped_image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return cropped_image;
}


-(void)processJSON{
    
    ///First we pull the data from the file
    
    NSError* noError;
    
    NSData *jsFile = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"colordata2" ofType:@"js"]];
    
    _json = [NSJSONSerialization JSONObjectWithData:jsFile options:0 error:&noError];
    
    NSLog(@"JSON count: %i", _json.count);
    
}


-(void)TimerCallback{
    static int count = 0;
    
    count++;
    ////If

    ///If the button was pressed and the video frame isn't finished being processed
    ////reset the count to zero
    if(greenbuttonispressed){
        if(!colorcheckiscomplete){
            ////colorcheck is still in process
            count = 0;
        }

        else if(count >300){
            greenbuttonispressed = false;
            count=0;
            processVideoFrame = true;          
        }
        ///originally the color check is complete feedback stuff was right here.
        count++;
    }
    else if(count > 1){
        count = 0;
        processVideoFrame = true;
    }

    
}

///TODO: Break this into functions
-(IBAction)IsItGreenButton{
    processVideoFrame = true;
    greenbuttonispressed = true;

    ///We should put this into its own fuction
//  _imageProcessActivityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
 
    ///To get a reliable UI update.
    dispatch_async(dispatch_get_main_queue(), ^{
        [_imageProcessActivityIndicator startAnimating];
    });
    
    
}


///Modal View stuff


///Modal View Business
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"PrepForSegue");
    if([segue.identifier isEqualToString:@"ColorOfInterestPicker"]){
           NSLog(@"Inside If");
        IsItGreenColorSelectionViewController *pickerController = segue.destinationViewController;
        pickerController.delegate = self;
    }
    
}

-(void)didDismissPresentedViewController:(NSString *)color{
    _colorOfInterest = color;
}



@end
