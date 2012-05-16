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
#import "EBKmlPlaceDetail.h"
#import "BSAddressComponent.h"
#import "BSForwardGeocoder.h"

@interface EBGoogleV3PlacesDetailParser : NSObject<NSXMLParserDelegate> {
  NSMutableString *contentsOfCurrentProperty;
	int statusCode;
	NSMutableArray *addressComponents;
	NSMutableArray *typesArray;
	BSAddressComponent *currentAddressComponent;
	BOOL ignoreAddressComponents;
	BOOL isLocation;
	BOOL isViewPort;
	BOOL isBounds;
	BOOL isSouthWest;
}

@property (nonatomic, readonly) int statusCode;
@property (nonatomic, readonly) EBKmlPlaceDetail *result;

- (BOOL)parseXMLData:(NSData *)URL 
          parseError:(NSError **)error 
ignoreAddressComponents:(BOOL)ignore;



@end
