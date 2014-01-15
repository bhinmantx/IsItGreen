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
    
    ///By default we're looking for green
    _colorOfInterest = @"g";
    
      ///And set up our timer
    _frameLimiterTimer = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(TimerCallback) userInfo:nil repeats:YES];
    processVideoFrame = true;
    _feedBackModeIsOn = false;

    
    [self prepVidCapture];
    [self populateMaps];

    
    //whitebalancereference = [[CIColor alloc] initWithCGColor:[UIColor colorWithRed:255.0 green:255.0 blue:255.0 alpha:255.0]];
    whitebalancereference =  [CIColor colorWithRed:255.0 green:255.0 blue:255.0 alpha:255.0];

    
    
    ////Change button name to reflect our default color search
    NSString *newButtonName = [NSString stringWithFormat:@"What Is %@%@", friendlyNameToName[_colorOfInterest],@"?"];
    [_IsItGreenButtonOutlet setTitle:newButtonName forState:normal];

    
    //TODO break this into its own initialization func.
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
	

    ///
    if(processVideoFrame){

        processVideoFrame =false;
        //thumbNail = [self imageFromSampleBuffer:sampleBuffer];

        ////Previous line
       UIImage * newThumbNail = [self imageFromSampleBuffer:sampleBuffer];

        dispatch_async(dispatch_get_main_queue(), ^{

            //                NSLog(@"block async dispatch");
            ////Previously working
           // [[self ExaggeratorImageView] setImage:smallImage];
            
            [[self ExaggeratorImageView] setImage:newThumbNail];
            [_imageProcessActivityIndicator stopAnimating];
        
            [self ExaggeratorImageView].hidden = false;
            // [subImage setImage:thumbNail];
 
        });
       // processVideoFrame = true;
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
    ////This should also be its own function. We should see about changing this image from buffer func
    ////to also accept a function pointer or selector
    

    if(greenbuttonispressed){
       
        processVideoFrame = false;
        
    unsigned char *pixel = (unsigned char *)CVPixelBufferGetBaseAddress(imageBuffer);
        colorcheckiscomplete = false;
         NSLog(@"Checking for %@", _colorOfInterest);
    for( int row = 0; row < height; row++ ) {
        
        for( int column = 0; column < width; column++ ) {
            
            ///HA HA. IT'S IN REVERSE ORDER
            int r,g,b;
            b = pixel[0];
            g = pixel[1];
            r = pixel[2];
            
            
         //   if([_matcher checkNearestFromRGB:pixel[2] :pixel[1] :pixel[0] :@"g"]){
               if([_matcher checkNearestFromRGB:pixel[2] :pixel[1] :pixel[0] :_colorOfInterest]){
                ///TODO make a function that's a switch statement or something for this
                   if ([_colorOfInterest isEqualToString:@"r"]) {
                       pixel[1] = 0; //Setting it to only red
                       pixel[0] = 0;
                   }
                   else{
                pixel[2] = 0; // Total-green (second pixel in BGRA is green)
                pixel[0] = 0;
                   }
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
       
        _feedBackModeIsOn = true;
        colorcheckiscomplete = true;
        
        greenbuttonispressed = false;
    }
    
    
    // Get the base address of the pixel buffer.
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    // Get the data size for contiguous planes of the pixel buffer.
    size_t bufferSize = CVPixelBufferGetDataSize(imageBuffer);
    //  NSLog(@"Got Pixel Buffer Data");
    // Create a Quartz direct-access data provider that uses data we supply.
    //a solution to that bad access from
    //// http://stackoverflow.com/questions/10774392/cgcontextdrawimage-crashes
    

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
    ////Since we changed the white balance code
    //image = [self tryWhiteBalancing:image];
    
  // CIFilter* filter  = [CIFilter filterWithName:@"CIWhitePointAdjust"]
  //  print_free_memory();

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

-(void)populateMaps{
    //	"r = Red, o = Orange, y = Yellow, g = Green, w = white"  "b = Blue, v = violet or purple, e = grey, k = black"
    
    friendlyNameToName[@"r"] = @"Red";
    friendlyNameToName[@"o"] = @"Orange";
    friendlyNameToName[@"y"] = @"Yellow";
    friendlyNameToName[@"g"] = @"Green";
    friendlyNameToName[@"w"] = @"White";
    friendlyNameToName[@"b"] = @"Blue";
    friendlyNameToName[@"v"] = @"Violet Or Purple";
    friendlyNameToName[@"e"] = @"Gray";
    friendlyNameToName[@"k"] = @"Black";
    
    nameToFriendlyName[@"Red"] = @"r";
    nameToFriendlyName[@"Orange"] = @"o";
    nameToFriendlyName[@"Yellow"] = @"y";
    nameToFriendlyName[@"Green"] = @"g";
    nameToFriendlyName[@"White"] = @"w";
    nameToFriendlyName[@"Blue"] = @"b";
    nameToFriendlyName[@"Violet"] = @"v";
    nameToFriendlyName[@"Gray"] = @"e";
    nameToFriendlyName[@"Black"] = @"k";
    
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

      //  else if(count >300){
        //    greenbuttonispressed = false;
         //   count=0;
          //  processVideoFrame = true;
        //}
        ///originally the color check is complete feedback stuff was right here.
    }
    /*
    else if((count > 5)&& _shouldWhiteBalance){
        count = 0;
        processVideoFrame = true;
    }
    else if((count > 1)&& !_shouldWhiteBalance){
        count = 0;
        processVideoFrame = true;
    }
*/
    else if (_feedBackModeIsOn && (count > 300)){
        count = 0;
        greenbuttonispressed = false;
        processVideoFrame = true;
        _feedBackModeIsOn = 0;
        
    }
    
    
    else if((count > 2) && !(greenbuttonispressed) && !(_feedBackModeIsOn)){
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
    ///Is it the color of interest selector button?
    if([segue.identifier isEqualToString:@"ColorOfInterestPicker"]){
        
        IsItGreenColorSelectionViewController *pickerController = segue.destinationViewController;
        pickerController.delegate = self;
        pickerController.originalColorOfInterest = _colorOfInterest;
        pickerController.nameToFriendlyName = nameToFriendlyName;
        pickerController.friendlyNameToName = friendlyNameToName;
    }
    
}

-(void)didDismissPresentedViewController:(NSString *)color{
    _colorOfInterest = color;
    
    ///Need to update the name of the button
    
    NSString *newButtonName = [NSString stringWithFormat:@"What Is %@%@", friendlyNameToName[color],@"?"];

    [_IsItGreenButtonOutlet setTitle:newButtonName forState:normal];
    NSLog(@"Color of interest is now %@", _colorOfInterest);
    [self dismissViewControllerAnimated:YES completion:NULL];
}
- (IBAction)WhiteBalanceTest:(id)sender {
    
    _shouldWhiteBalance = !_shouldWhiteBalance;
     //whitebalancereference =  [CIColor colorWithRed:55.0 green:100.0 blue:255.0 alpha:255.0];
    NSLog(@"White balance Changed");
}

-(CGImage*)tryWhiteBalancing:(CGImage*)sourceImage{
  
    
    
    
    
    /*
 
    if(_shouldWhiteBalance){
   

  
        CIContext *context = [CIContext contextWithOptions:nil];
        
        ///When this took a UIImage
        ///CIImage *inputImage = [CIImage imageWithCGImage:[sourceImage CGImage]];
        CIImage *inputImage = [CIImage imageWithCGImage:sourceImage];
        
        
        CIFilter *hueFilter = [CIFilter filterWithName:@"CITemperatureAndTint"];
        //[hueFilter setValue:inputImage forKey:kCIInputImageKey];
        [hueFilter setValue:inputImage forKey:@"InputImage"];

       [hueFilter setValue:[CIVector vectorWithX:2000.0 Y:0] forKey:@"inputNeutral"];
      [hueFilter setValue:[CIVector vectorWithX:100.0 Y:0] forKey:@"inputTargetNeutral"];

        CIImage *result = [hueFilter outputImage];
        
        
        ///Originally creating then releasing. We just want an assignment I think.
//        CGImageRef cgImage = [context createCGImage:result fromRect:[result extent]];
           
       // UIImage *imageResult = [UIImage imageWithCGImage:cgImage];
//        CGImageRelease(cgImage);
        //////////////////////////LOOKOUT FOR A MEMORY LEAK
        //return imageResult;
         
        // CGImageRelease(sourceImage);
  CGImageRef newImage = [context createCGImage:result fromRect:[result extent]];
           
           return newImage;
    }
  
       else{
           
           
           return sourceImage;
           
           
       }
    */
    /*
  
    if(!_shouldWhiteBalance){
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *inputImage = [CIImage imageWithCGImage:[sourceImage CGImage]];
    CIFilter *hueFilter = [CIFilter filterWithName:@"CIHueAdjust"];
    [hueFilter setValue:inputImage forKey:kCIInputImageKey];
    [hueFilter setValue:[NSNumber numberWithDouble:-2*M_PI/8] forKey:@"inputAngle"];
    CIImage *result = [hueFilter outputImage];
    CGImageRef cgImage = [context createCGImage:result fromRect:[result extent]];
    UIImage *imageResult = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    return imageResult;
   
    
    }
     */

    

  

    //We create a simple context without any option
    CIContext *context = [CIContext contextWithOptions:nil];
    
    ////We'll turn our incoming UIIMage into something we can filter.
CIImage *inputImage = [CIImage imageWithCGImage:sourceImage];
    CIFilter *filter = [CIFilter filterWithName:@"CIWhitePointAdjust"];
   [filter setValue:inputImage forKey:kCIInputImageKey];
    [filter setValue:[CIColor colorWithRed:1.0 green:.5 blue:.8 alpha:1.0] forKey:@"InputColor"];

    CIImage *result = [filter outputImage];
    CGImageRef cgImage = [context createCGImage:result fromRect:[result extent]];

        return cgImage;
   
    

}


////White balance test




-(UIImage*)processImage:(CMSampleBufferRef)sampleBuffer{
  
    ////Right now this is doing all the work. We want to break this into functions.
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
   // char* pixel = (char *)[data bytes];
    // NSLog(@"DATA CREATED");
    
    CGDataProviderRef dataProvider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    /*
    for(int i = 0; i < [data length]; i += 4)
    {
        int r = i;
        int g = i+1;
        int b = i+2;
        int a = i+3;
        
        pixel[r]   = 0; // eg. remove red
        pixel[g]   = pixel[g];
        pixel[b]   = pixel[b];
        pixel[a]   = pixel[a];
    }
    */
    
    // Create a bitmap image from data supplied by the data provider.
    CGImageRef cgImage = CGImageCreate(width, height, 8, 32, bytesPerRow, colorSpace, kCGImageAlphaNoneSkipFirst | kCGBitmapByteOrder32Little, dataProvider, NULL, true, kCGRenderingIntentDefault);
   
    CGImageRef cgWhiteBalanced;
    if(_shouldWhiteBalance){
    cgWhiteBalanced = [self tryWhiteBalancing:cgImage];
    
   // if(_shouldWhiteBalance)
   CGImageRelease(cgImage);
    }
    else {
        cgWhiteBalanced = cgImage;
        //CGImageRelease(cgImage);
    }
    
    ///Let's see if we can hit the buffer again directly.
    //data = (__bridge NSData *)CGDataProviderCopyData(CGImageGetDataProvider(cgImage));
    
    
   // data = (NSData*) CFBridgingRelease(CGDataProviderCopyData(CGImageGetDataProvider(cgImage)));
    
    
    ////How ccould this be our memory leak?
    data = [NSData dataWithBytes:[data bytes] length:data.length];
    
    CGDataProviderRelease(dataProvider);
        CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    
    dataProvider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    ///////////////////////////////////////////////////TURNING THIS OFF IN CASE ANYONE WANTS TO SEE APP
    
   // void *baseAddress1 = (char *)[data bytes];
    /*
    char *pixels        = (char *)[data bytes];

    for(int i = 0; i < [data length]; i += 4)
    {
        int r = i;
        int g = i+1;
        int b = i+2;
        int a = i+3;
        
        pixels[r]   = 0; // eg. remove red
        pixels[g]   = pixels[g];
        pixels[b]   = pixels[b];
        pixels[a]   = pixels[a];
    }
    
    
    
    */
    CGBitmapInfo bitmapInfo  = CGImageGetBitmapInfo(cgWhiteBalanced);
  

    CGImageRef cgOutputImage = CGImageCreate(width, height, 8, 32, bytesPerRow, colorSpace, bitmapInfo, dataProvider, NULL, true, kCGRenderingIntentDefault);
    CGImageRelease(cgWhiteBalanced);
    CGDataProviderRelease(dataProvider);
   //CGColorSpaceRelease(colorSpace);
   // free(pixels);
  
    
    ////Modification of this solution:
    /// http://stackoverflow.com/questions/1281210/can-i-edit-the-pixels-of-the-uiimages-property-cgimage
    ///Now we have a cgImage.
    
    
    
    //CGImageRef imageRef = cgImage;
    
/*
    ///Check here for issues because ownership doesn't change
    NSData *tdata        = (__bridge NSData *)CGDataProviderCopyData(CGImageGetDataProvider(cgImage));
    char *pixels        = (char *)[tdata bytes];

    // this is where you manipulate the individual pixels
    // assumes a 4 byte pixel consisting of rgb and alpha
    // for PNGs without transparency use i+=3 and remove int a
    for(int i = 0; i < [tdata length]; i += 4)
    {
        int r = i;
        int g = i+1;
        int b = i+2;
        int a = i+3;
        
        pixels[r]   = 0; // eg. remove red
        pixels[g]   = pixels[g];
        pixels[b]   = pixels[b];
        pixels[a]   = pixels[a];
    }
    
    // create a new image from the modified pixel data
    ///Originally all of these had imageRef not cgImage
    size_t twidth                    = CGImageGetWidth(cgImage);
    size_t theight                   = CGImageGetHeight(cgImage);
    size_t bitsPerComponent         = CGImageGetBitsPerComponent(cgImage);
    size_t bitsPerPixel             = CGImageGetBitsPerPixel(cgImage);
    size_t tbytesPerRow              = CGImageGetBytesPerRow(cgImage);
    
    CGColorSpaceRef colorspace      = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo         = CGImageGetBitmapInfo(cgImage);
    CGDataProviderRef provider      = CGDataProviderCreateWithData(NULL, pixels, [tdata length], NULL);
    
    CGImageRef newImageRef = CGImageCreate (
                                           twidth,
                                            theight,
                                            bitsPerComponent,
                                            bitsPerPixel,
                                            tbytesPerRow,
                                            colorspace,
                                            bitmapInfo,
                                            provider,
                                            NULL,
                                            false,
                                            kCGRenderingIntentDefault
                                            );
    // the modified image
    UIImage *image   = [UIImage imageWithCGImage:newImageRef];
    
    // cleanup
    free(pixels);
   // CGImageRelease(imageRef);
    CGColorSpaceRelease(colorspace);
    CGDataProviderRelease(provider);
    CGImageRelease(newImageRef);
 
   */
    // Create and return an image object to represent the Quartz image.
    //  NSLog(@"About to create the image");
    ///Our original output
    
   // UIImage *image   = [UIImage imageWithCGImage:newImageRef];
    
    
    UIImage *image = [UIImage imageWithCGImage:cgOutputImage];
    
    //UIImage *image = [self tryWhiteBalancing:cgImage];
    
    ///My cleanup (By my cleanup I mean from the first half of this code)
    CGImageRelease(cgOutputImage);
   
  //  CGImageRelease(newImageRef);
    
    


    

    
    // CIFilter* filter  = [CIFilter filterWithName:@"CIWhitePointAdjust"]
    //  print_free_memory();
    //NSLog(@"RETURNING IMAGE");
    return image;
  
    
    
}






@end
