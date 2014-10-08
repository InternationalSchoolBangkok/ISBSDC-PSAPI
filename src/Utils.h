//
//  Utils.h
//  PSAPI
//
//  Created by Kolatat Thangkasemvathana on 17/9/14.
//  Copyright (c) 2014 ISB Software Development Club. All rights reserved.
//

/*!
 * Contains utilitative (if that's a word) functions.
 */
@interface Utils : NSObject

/*!
 * @discussion Encodes a dictionary into a URL acceptable string. "I bet you wanna encode a dic ;)".
 * @param dict The dictionary to be encoded.
 * @return A URL encoded string containing the contents of the dictionary.
 */
+(NSString*)urlEncodeDict:(NSDictionary*)dict;

/*!
 * @discussion Returns an array containing the matches of a regex pattern on a string.
 * @param string The string to search.
 * @param pattern The regex pattern.
 * @return An array containing NSString matches.
 */
+(NSArray*)regexExtract:(NSString*)string regexPatternWithCaptureGroup:(NSString*)pattern;

@end

@interface NSString (NSString_CrypoExtension)

/*!
 * @discussion Returns the hashed crypted version of the string using the HMAC MD5 algorithm.
 * @param secret The cryptographic key or secret.
 * @return The hashed string.
 */
-(NSString*) HMACMD5:(NSString*)secret;

/*!
 * @discussion Returns the raw md5 hash of the string.
 * @return The raw md5 hash data.
 */
-(NSData*) md5Raw;

/*!
 * @discussion Returns the md5 hash of the string.
 * @return The md5 hash.
 */
-(NSString*) md5;

@end