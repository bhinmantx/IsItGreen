


#include "ImageUtils.h"

/*
UIImage *imageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer;
UIImage *imageWithCVMat:(const cv::Mat&)cvMat;
cv::MatcvMatFromUIImage:(UIImage *)image;
UIImage*crop:(UIImage *)image :(CGRect)rect;
*/

UIImage* imageFromSampleBuffer(CMSampleBufferRef sampleBuffer) {
    
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
    
    
    ///alright let's try the rosy writer code here.
    //   unsigned char *pixel = (unsigned char *)CVPixelBufferGetBaseAddress(imageBuffer);
    
    /*
     for( int row = 0; row < height; row++ ) {
     
     for( int column = 0; column < width; column++ ) {
     
     pixel[1] = 0; // De-green (second pixel in BGRA is green)
     
     pixel += BYTES_PER_PIXEL;
     
     }
     
     }
     */
    
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
    
    print_free_memory();
    //NSLog(@"RETURNING IMAGE");
    return image;
    
}

