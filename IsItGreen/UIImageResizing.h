
////// from http://stackoverflow.com/questions/2658738/the-simplest-way-to-resize-an-uiimage

@interface UIImage (Resize)
- (UIImage*)scaleToSize:(CGSize)size;
@end