//
//  Created by Björn Sållarp on 2010-03-13.
//  NO Copyright 2010 MightyLittle Industries. NO rights reserved.
// 
//  Use this code any way you like. If you do like it, please
//  link to my blog and/or write a friendly comment. Thank you!
//
//  Read my blog @ http://blog.sallarp.com
//


#import <Foundation/Foundation.h>
#import "EBGoogleV3PlacesPredictionParser.h"
#import "EBGoogleV3PlacesDetailParser.h"
#import "BSForwardGeocoder.h"
#import "EBKmlPlaceDetail.h"

typedef void (^EBForwardPlacesGeocoderSuccess) (NSArray* results);
typedef void (^EBForwardPlacesGeocoderFailed) (int status, NSString* errorMessage);

typedef void (^EBForwardPlacesDetailSuccess) (EBKmlPlaceDetail* result);
typedef void (^EBForwardPlacesDetailFailed) (int status, NSString* errorMessage);


@class EBForwardPlacesGeocoder;

@interface EBForwardPlacesGeocoder : NSObject <NSURLConnectionDataDelegate>

- (void)forwardGeocodeWithQuery:(NSString *)location inCountry:(NSString *)country success:(EBForwardPlacesGeocoderSuccess)success failure:(EBForwardPlacesGeocoderFailed)failure;

- (void)getDetailForPlaceRef:(NSString *)ref success:(EBForwardPlacesDetailSuccess)success failure:(EBForwardPlacesDetailFailed)failure;


@property (nonatomic, assign) BOOL useHTTP;

@end
