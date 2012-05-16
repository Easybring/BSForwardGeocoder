//
//  Created by Björn Sållarp on 2010-03-13.
//  NO Copyright 2010 MightyLittle Industries. NO rights reserved.
// 
//  Use this code any way you like. If you do like it, please
//  link to my blog and/or write a friendly comment. Thank you!
//
//  Read my blog @ http://blog.sallarp.com
//

#import "EBForwardPlacesGeocoder.h"

@interface EBForwardPlacesGeocoder ()
@property (nonatomic, retain) NSURLConnection *geocodeConnection;
@property (nonatomic, retain) NSMutableData *geocodeConnectionData;

@property (nonatomic, retain) NSURLConnection *detailConnection;
@property (nonatomic, retain) NSMutableData *detailConnectionData;

@property (nonatomic, copy) EBForwardPlacesGeocoderSuccess successBlock;
@property (nonatomic, copy) EBForwardPlacesGeocoderFailed failureBlock;

@property (nonatomic, copy) EBForwardPlacesDetailSuccess detailSuccessBlock;
@property (nonatomic, copy) EBForwardPlacesDetailFailed detailFailureBlock;

@end

@implementation EBForwardPlacesGeocoder
@synthesize geocodeConnection = _geocodeConnection;
@synthesize geocodeConnectionData = _geocodeConnectionData;
@synthesize detailConnection = _detailConnection;
@synthesize detailConnectionData = _detailConnectionData;
@synthesize useHTTP = _useHTTP;

@synthesize successBlock = _successBlock;
@synthesize failureBlock = _failureBlock;
@synthesize detailFailureBlock = _detailFailureBlock;
@synthesize detailSuccessBlock = _detailSuccessBlock;



// Use Core Foundation method to URL-encode strings, since -stringByAddingPercentEscapesUsingEncoding:
// doesn't do a complete job. For details, see:
//   http://simonwoodside.com/weblog/2009/4/22/how_to_really_url_encode/
//   http://stackoverflow.com/questions/730101/how-do-i-encode-in-a-url-in-an-html-attribute-value/730427#730427
- (NSString *)URLEncodedString:(NSString *)string
{
  NSString *encodedString = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                (__bridge CFStringRef)string,
                                                                                NULL,
                                                                                (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                kCFStringEncodingUTF8);
  return encodedString;
}

#pragma mark Detail methods

-(void)getDetailForPlaceRef:(NSString*)ref
{
  if (self.detailConnection) {
    [self.detailConnection cancel];
  }
  
  // Create the url object for our request. It's important to escape the 
  // search string to support spaces and international characters
  
  NSString *detailUrl = [NSString stringWithFormat:@"%@://maps.googleapis.com/maps/api/place/details/xml?reference=%@&sensor=false&language=no&key=AIzaSyC3ptijPpS788i8TMLHpCOQm6pbTO0K30w", self.useHTTP ? @"http" : @"https", ref];
  
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:detailUrl] cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:10.0];
  self.detailConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (void)getDetailForPlaceRef:(NSString *)ref success:(EBForwardPlacesDetailSuccess)success failure:(EBForwardPlacesDetailFailed)failure
{
  self.detailSuccessBlock = success;
  self.detailFailureBlock = failure;
  [self getDetailForPlaceRef:ref];
}



- (void)parseDetailResponseWithData:(NSData *)responseData
{
	NSError *parseError = nil;
	
  // Run the KML parser
  EBGoogleV3PlacesDetailParser *parser = [[EBGoogleV3PlacesDetailParser alloc] init];
  [parser parseXMLData:responseData parseError:&parseError ignoreAddressComponents:NO];
	  
  if (self.detailSuccessBlock && parser.statusCode == G_GEO_SUCCESS) {
    self.detailSuccessBlock(parser.result);
  }
  else if (self.detailFailureBlock) {
    self.detailFailureBlock(parser.statusCode, [parseError localizedDescription]);
  }
  
  parser = nil;
}


- (void)forwardGeocodeWithQuery:(NSString *)searchQuery inCountry:(NSString *)country
{
  if (self.geocodeConnection) {
    [self.geocodeConnection cancel];
  }
  
  // Create the url object for our request. It's important to escape the 
  // search string to support spaces and international characters
  
  NSString *geocodeUrl = [NSString stringWithFormat:@"%@://maps.googleapis.com/maps/api/place/autocomplete/xml?input=%@&types=establishment&language=no&sensor=false&key=AIzaSyC3ptijPpS788i8TMLHpCOQm6pbTO0K30w", self.useHTTP ? @"http" : @"https", [self URLEncodedString:searchQuery]];
  
  if (country && ![country isEqualToString:@""]) {
    geocodeUrl = [geocodeUrl stringByAppendingFormat:@"&components=country:%@", country];
  }
  
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:geocodeUrl] cachePolicy:NSURLCacheStorageAllowed timeoutInterval:10.0];
  self.geocodeConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (void)forwardGeocodeWithQuery:(NSString *)location inCountry:(NSString *)country success:(EBForwardPlacesGeocoderSuccess)success failure:(EBForwardPlacesGeocoderFailed)failure
{
  self.successBlock = success;
  self.failureBlock = failure;
  [self forwardGeocodeWithQuery:location inCountry:country];
}

- (void)parseGeocodeResponseWithData:(NSData *)responseData
{
	NSError *parseError = nil;
	
  // Run the KML parser
  EBGoogleV3PlacesPredictionParser *parser = [[EBGoogleV3PlacesPredictionParser alloc] init];
  [parser parseXMLData:responseData parseError:&parseError];
	  
  if (self.successBlock && parser.statusCode == G_GEO_SUCCESS) {
    self.successBlock(parser.results);
  }
  else if (self.failureBlock) {
    self.failureBlock(parser.statusCode, [parseError localizedDescription]);
  }
  
  parser = nil;
}

- (void)geocoderConnectionFailedWithErrorMessage:(NSString *)errorMessage
{  
  if (self.failureBlock) {
    self.failureBlock(G_GEO_NETWORK_ERROR, errorMessage);
  }
  
  self.geocodeConnectionData = nil;
  self.geocodeConnection = nil;
}

#pragma mark - NSURLConnection delegate methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response
{
  if (connection == self.geocodeConnection) 
  {
    if (response.statusCode != 200) {
      [self.geocodeConnection cancel];
      [self geocoderConnectionFailedWithErrorMessage:@"Google returned an invalid status code"];
    }
    else {
      self.geocodeConnectionData = [NSMutableData data];
    }
  } else if(connection == self.detailConnection)
  {
    if (response.statusCode != 200) {
      [self.detailConnection cancel];
      [self geocoderConnectionFailedWithErrorMessage:@"Google returned an invalid status code"];
    }
    else {
      self.detailConnectionData = [NSMutableData data];
    }
  }
  
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
  if(connection == self.geocodeConnection) {
    [self.geocodeConnectionData appendData:data];
  } else if(connection == self.detailConnection)
  {
    [self.detailConnectionData appendData:data];
  }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
  [self geocoderConnectionFailedWithErrorMessage:[error localizedDescription]];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
  if(connection == self.geocodeConnection) 
  {
    self.geocodeConnection = nil;    
    [self parseGeocodeResponseWithData:self.geocodeConnectionData];
    self.geocodeConnectionData = nil;
  } else if(connection == self.detailConnection)
  {
    self.geocodeConnection = nil;    
    [self parseDetailResponseWithData:self.detailConnectionData];
    self.geocodeConnectionData = nil;
  }
}

@end
