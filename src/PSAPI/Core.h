//
//  Core.h
//  PSAPI
//
//  Created by Kolatat Thangkasemvathana on 16/9/14.
//  Copyright (c) 2014 ISB Software Development Club. All rights reserved.
//

@class PSUser;

/*!
 * @abstract Core of the PowerSchool API. Contains basic connection interface.
 */
@interface PSCore : NSObject

/*!
 * @brief The URL of the PowerSchool server.
 */
@property (readonly) NSURL * url;

/*!
 * @brief The user agent string to report to the PowerSchool server.
 */
@property NSString * userAgent;

/*!
 * @brief The jar of cookies! (as in browser cookies for communication with the PowerSchool server)
 */
@property (readonly) NSHTTPCookieStorage * cookieJar;

/*!
 * @brief Any error that occurs during connection will be stored here.
 */
@property (readonly) NSError* error;

/*!
 * @discussion Initializes a PSCore connection object with a PowerSchool server.
 * @param url The URL of the PowerSchool server.
 * @return The PSCore connection object.
 */
-(id)init:(NSURL*) url;

/*!
 * @discussion Requests a page on the server.
 * @param path The path to the page.
 * @return The contents of the page.
 */
-(NSString*)request:(NSString*)path;

/*!
 * @discussion Requests a page on the server by posting data to it.
 * @param path The path to the page.
 * @param postData The dictionary of data to post to the page.
 * @return The contents of the page.
 */
-(NSString*)request:(NSString*)path postFieldsData:(NSDictionary*)postData;

/*!
 * @discussion Fetches the authentication requirements from the server.
 * @return A dictionary of authentication requirements.
 */
-(NSDictionary*)getAuthData;

/*!
 * @discussion Authenticates with the server using a username and password.
 * @param username The username of the PowerSchool account.
 * @param password The password of the account.
 * @return The PowerSchool object of the authenticated user.
 */
-(PSUser*)auth:(NSString*)username password:(NSString*)password;

@end