//
//  ColorMatcher.h
//  IsItGreen2
//
//  Created by Brendan Hinman on 10/18/13.
//  Copyright (c) 2013 Brendan Hinman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <opencv2/highgui/cap_ios.h>

@interface ColorMatcher : NSObject{

NSArray *_colors;
    cv::Mat _colorCoords;
    cv::Mat _replacementColors;
    
  cv::flann::Index *_kdtree;
}

@property (strong,nonatomic) NSArray * colors;
@property (nonatomic) cv::Mat  colorCoords;
@property (nonatomic) cv::flann::Index *kdtree;
@property (atomic) cv::Mat replacementColors; 


-(id)initWithColorFileName:(NSString*)colorCoordsFileName;
-(BOOL)matchColorFromMat:(cv::Mat)sampleMat :(NSString*)targColor;
-(NSString*)findDistance:(NSArray*)sample;
-(id)initWithJSON:(NSArray*)colorJson;
-(NSString*)flannFinder:(cv::Mat)sampleMat :(NSString*)color;
-(cv::Mat)ColorReplacer:(cv::Mat)sampleMat :(NSString*)color :(UIImageView*)targetImage;
-(cv::Mat)ColorReplacer2:(cv::Mat)sampleMat :(NSString*)color :(UIImageView*)targetImage;
-(int)exaggerateVal:(int)value;

@end
