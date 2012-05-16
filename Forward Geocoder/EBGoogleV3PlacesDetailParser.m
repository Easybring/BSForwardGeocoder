//
//  Created by Björn Sållarp on 2010-03-14.
//  NO Copyright 2010 MightyLittle Industries. NO rights reserved.
// 
//  Use this code any way you like. If you do like it, please
//  link to my blog and/or write a friendly comment. Thank you!
//
//  Read my blog @ http://blog.sallarp.com
//

/**
 
 Kml Parser for Googles geocoding service version 3. Find out more @ Google:
 http://code.google.com/apis/maps/documentation/geocoding/index.html
 
 **/

#import "EBGoogleV3PlacesDetailParser.h"


@implementation EBGoogleV3PlacesDetailParser

@synthesize statusCode, result;

- (BOOL)parseXMLData:(NSData *)data parseError:(NSError **)error ignoreAddressComponents:(BOOL)ignore
{
	BOOL successfull = TRUE;
	
	ignoreAddressComponents = ignore;
	
  // Load the data trough NSData, NSXMLParser leaks when loading data
  NSData *xmlData = [[NSData alloc] initWithData:data];
  
	// Create XML parser
  NSXMLParser *parser = [[NSXMLParser alloc] initWithData:xmlData];
  
	// Set self as the delegate of the parser so that it will receive the parser delegate methods callbacks.
  [parser setDelegate:self];
	
  [parser setShouldProcessNamespaces:NO];
  [parser setShouldReportNamespacePrefixes:NO];
  [parser setShouldResolveExternalEntities:NO];
	
  // Start parsing
  [parser parse];
  
  NSError *parseError = [parser parserError];
  if (parseError && error) {
    *error = parseError;
		
		successfull = FALSE;
  }
  
	
	return successfull;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI 
 qualifiedName:(NSString *)qName 
    attributes:(NSDictionary *)attributeDict
{
	if (qName) {
    elementName = qName;
  }
	
	// The response could contain multiple placemarks
	if([elementName isEqualToString:@"result"])
	{

    result = [[EBKmlPlaceDetail alloc] init];

		// Create a new placemark object to fill with information
		
		isLocation = NO;
		isViewPort = NO;
		isBounds = NO;
		isSouthWest = NO;
	}
	else if(ignoreAddressComponents == FALSE && [elementName isEqualToString:@"address_component"])
	{
		// Set up an array to hold address components 
		if(addressComponents == nil)
		{
			addressComponents = [[NSMutableArray alloc] init];
		}
		
		currentAddressComponent = [[BSAddressComponent alloc] init];
		typesArray = [[NSMutableArray alloc] init];
	}
	else if([elementName isEqualToString:@"location"]) {
		isLocation = YES;
	}
	else if([elementName isEqualToString:@"viewport"]) {
		isViewPort = YES;
	}
	else if([elementName isEqualToString:@"bounds"]) {
		isBounds = YES;
	}
	else if([elementName isEqualToString:@"southwest"]) {
		isSouthWest = YES;
	}
	
	
	
	// These are the elements we read information from.
	if(([elementName isEqualToString:@"status"] || [elementName isEqualToString:@"formatted_address"] || 
      [elementName isEqualToString:@"lat"] || [elementName isEqualToString:@"lng"]) ||
     [elementName isEqualToString:@"name"] ||
     (ignoreAddressComponents == FALSE && ([elementName isEqualToString:@"type"] || 
                                           [elementName isEqualToString:@"long_name"] ||
                                           [elementName isEqualToString:@"short_name"] )
      )
	   )
	{
		// Create a mutable string to hold the contents of the elements.
    // The content is collected in parser:foundCharacters:.
    if(contentsOfCurrentProperty == nil)
		{
			contentsOfCurrentProperty = [NSMutableString string];
		}
		else 
		{
			[contentsOfCurrentProperty setString:@""];
		}
	}
	else if (contentsOfCurrentProperty != nil)
	{
		// If we're not interested in the element we set the variable used 
		// to collect information to nil.
		contentsOfCurrentProperty = nil;
	}
	
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI 
 qualifiedName:(NSString *)qName
{ 
	if (qName) {
    elementName = qName;
  }
	
	// If we reach the end of a placemark element we add it to our array
	if([elementName isEqualToString:@"result"])
	{
			result.addressComponents = addressComponents;
			addressComponents = nil;
	}
	else if ([elementName isEqualToString:@"address_component"]) {
		if(currentAddressComponent != nil)
		{
			currentAddressComponent.types = typesArray;
			typesArray = nil;
			
			[addressComponents addObject:currentAddressComponent];
			currentAddressComponent = nil;
		}
	}
	else if ([elementName isEqualToString:@"location"]) {
		isLocation = NO;
	}
	else if ([elementName isEqualToString:@"viewport"]) {
		isViewPort = NO;
	}
	else if ([elementName isEqualToString:@"southwest"]) {
		isSouthWest = NO;
	}
	
	// If contentsOfCurrentProperty is nil we're not interested in the
	// collected data 
	if(contentsOfCurrentProperty == nil)
		return;
	
	NSString* elementValue = [[NSString alloc] initWithString:contentsOfCurrentProperty];
	
	if ([elementName isEqualToString:@"status"]) {
		if([elementValue isEqualToString:@"OK"])
		{
			statusCode = G_GEO_SUCCESS;
		}
		else if([elementValue isEqualToString:@"ZERO_RESULTS"])
		{
			statusCode = G_GEO_UNKNOWN_ADDRESS;
		}
		else if([elementValue isEqualToString:@"OVER_QUERY_LIMIT"])
		{
			statusCode = G_GEO_TOO_MANY_QUERIES;
		}
		else if([elementValue isEqualToString:@"REQUEST_DENIED"])
		{
			statusCode = G_GEO_SERVER_ERROR;
		}
		else if([elementValue isEqualToString:@"INVALID_REQUEST"])
		{
			statusCode = G_GEO_BAD_REQUEST;
		}
		
  }
	else if ([elementName isEqualToString:@"long_name"] && currentAddressComponent != nil) {
		currentAddressComponent.longName = elementValue;
  }
	else if ([elementName isEqualToString:@"short_name"] && currentAddressComponent != nil) {
		currentAddressComponent.shortName = elementValue;
  }
	else if ([elementName isEqualToString:@"type"]) {
		[typesArray addObject:elementValue];
  }
	else if ([elementName isEqualToString:@"formatted_address"]) {
		result.address = elementValue;
		
	} else if([elementName isEqualToString:@"name"]) {
    result.name = elementValue;
  }
	else if ([elementName isEqualToString:@"lat"]) {
		if(isLocation) {
			result.latitude = [elementValue floatValue];
		}
		else if(isViewPort)
		{
			if(isSouthWest) {
				result.viewportSouthWestLat = [elementValue floatValue];
			}
			else {
				result.viewportNorthEastLat = [elementValue floatValue];
			}
      
		}
		else if(isBounds)
		{
			if(isSouthWest) {
				result.boundsSouthWestLat = [elementValue floatValue];
			}
			else {
				result.boundsNorthEastLat = [elementValue floatValue];
			}
		}
	}
	else if ([elementName isEqualToString:@"lng"]) {
		if(isLocation) {
			result.longitude = [elementValue floatValue];
		}
		else if(isViewPort)
		{
			if(isSouthWest) {
				result.viewportSouthWestLon = [elementValue floatValue];
			}
			else {
				result.viewportNorthEastLon = [elementValue floatValue];
			}
			
		}
		else if(isBounds)
		{
			if(isSouthWest) {
				result.boundsSouthWestLon = [elementValue floatValue];
			}
			else {
				result.boundsNorthEastLon = [elementValue floatValue];
			}
		}
	}
  
	contentsOfCurrentProperty = nil;
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
  if (contentsOfCurrentProperty) {
    // If the current element is one whose content we care about, append 'string'
    // to the property that holds the content of the current element.
    [contentsOfCurrentProperty appendString:string];
  }
}



@end