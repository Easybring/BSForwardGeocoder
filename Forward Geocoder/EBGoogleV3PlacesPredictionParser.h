//
//  Created by Björn Sållarp on 2010-03-14.
//  NO Copyright 2010 MightyLittle Industries. NO rights reserved.
// 
//  Use this code any way you like. If you do like it, please
//  link to my blog and/or write a friendly comment. Thank you!
//
//  Read my blog @ http://blog.sallarp.com
//

#import <Foundation/Foundation.h>
#import "EBKmlPlacePrediction.h"
#import "EBForwardPlacesGeocoder.h"

@interface EBGoogleV3PlacesPredictionParser : NSObject<NSXMLParserDelegate> {
	NSMutableString *contentsOfCurrentProperty;
	int statusCode;
	NSMutableArray *results;
	EBKmlPlacePrediction *currentResult;
}

@property (nonatomic, readonly) int statusCode;
@property (nonatomic, readonly) NSMutableArray *results;

- (BOOL)parseXMLData:(NSData *)URL 
          parseError:(NSError **)error;


@end
