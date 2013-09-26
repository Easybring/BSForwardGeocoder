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

@property (nonatomic, assign) BOOL useHTTP;

/**
 *	Initializes an allocated EBForwardPlacesGeocoder with an APIKey. NOTE: init is no longer supported and will throw an exception.
 *
 *	@param apiKey	The API key provided by Google. This may not be nil or empty.
 *
 *	@return Initialized EBForwardPlacesGeocoder object with the specified API key.
 */
- (instancetype)initWithAPIKey:(NSString *)apiKey;

- (void)forwardGeocodeWithQuery:(NSString *)location inCountry:(NSString *)country success:(EBForwardPlacesGeocoderSuccess)success failure:(EBForwardPlacesGeocoderFailed)failure;

- (void)forwardGeocodeWithQuery:(NSString *)location language:(NSString *)language inCountry:(NSString *)country success:(EBForwardPlacesGeocoderSuccess)success failure:(EBForwardPlacesGeocoderFailed)failure;

- (void)getDetailForPlaceRef:(NSString *)ref success:(EBForwardPlacesDetailSuccess)success failure:(EBForwardPlacesDetailFailed)failure;

- (void)getDetailForPlaceRef:(NSString *)ref language:(NSString *)language success:(EBForwardPlacesDetailSuccess)success failure:(EBForwardPlacesDetailFailed)failure;

@end
