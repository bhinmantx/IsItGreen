//
//  IsItGreenViewController.m
//  IsItGreen
//
//  Created by Brendan Hinman on 12/3/13.
//  Copyright (c) 2013 Brendan Hinman. All rights reserved.
//

#import "IsItGreenViewController.h"


@interface IsItGreenViewController ()

@end

@implementation IsItGreenViewController

@synthesize cameraFeed;

///For still image capture
@synthesize stillImageOutput, captureImage;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    
  CALayer *viewLayer = self.cameraFeed.layer;
    AVCaptureVideoPreviewLayer *captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
    
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
    /*
    if (!frontCamera) {
        NSError *error = nil;
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:backCamera error:&error];
        if (!input) {
            NSLog(@"ERROR: trying to open front camera: %@", error);
        }
        [session addInput:input];
    }
    
    if (frontCamera) {
        NSError *error = nil;
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:frontCamera error:&error];
        if (!input) {
            NSLog(@"ERROR: trying to open rear camera: %@", error);
        }
        [session addInput:input];
    }
    */
    
    NSError *error = nil;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:backCamera error:&error];
    [session addInput:input];
    
   // NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys: AVVideoCodecJPEG, AVVideoCodecKey, nil];

    
    //[session addOutput:stillImageOutput];
    
    
    
    stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys: AVVideoCodecJPEG, AVVideoCodecKey, nil];
    [stillImageOutput setOutputSettings:outputSettings];
    
    [session addOutput:stillImageOutput];
    
    
    
	[session startRunning];

    

    
    
    /*
    NSError *error = nil;
    
	AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
	if (!input) {
		// Handle the error appropriately.
		NSLog(@"ERROR: trying to open camera: %@", error);
	}
    
    [session startRunning];
	
    [session addInput:input];
*/
///Let's see about that cross hair image
    [self CrossHairAndResult].layer.zPosition = 5;
    [self cameraFeed].layer.zPosition = 0;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
