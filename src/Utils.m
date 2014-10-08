//
//  Utils.m
//  PSAPI
//
//  Created by Kolatat Thangkasemvathana on 17/9/14.
//  Copyright (c) 2014 ISB Software Development Club. All rights reserved.
//

#import "Utils.h"

#import <CommonCrypto/CommonHMAC.h>

static NSString* toString(id object){
    return [NSString stringWithFormat:@"%@", object];
}
static NSString* urlEncode(id object){
    NSMutableString* output=[NSMutableString string];
    const unsigned char *source = (const unsigned char *)[toString(object) UTF8String];
    int sourceLen = strlen((const char *) source);
    for(int i=0;i<sourceLen;++i){
        const unsigned char thisChar = source[i];
        if(thisChar==' '){
            [output appendString:@"+"];
        } else if(thisChar=='.' ||thisChar=='-'||thisChar=='_'||thisChar=='~'||
                  (thisChar>='a'&&thisChar<='z')||
                  (thisChar>='A'&&thisChar<='Z')||
                  (thisChar>='0'&&thisChar<='9')){
            [output appendFormat:@"%c",thisChar];
        } else {
            [output appendFormat:@"%%%02X",thisChar];
        }
    }
    return output;
}

@implementation Utils

+(NSString*)urlEncodeDict:(NSDictionary *)dict{
    NSMutableArray* parts = [NSMutableArray array];
    for(id key in dict){
        id value = [dict objectForKey:key];
        NSString* part = [NSString stringWithFormat:@"%@=%@",urlEncode(key),urlEncode(value)];
        [parts addObject:part];
    }
    return [parts componentsJoinedByString:@"&"];
}

+(NSArray*)regexExtract:(NSString *)string regexPatternWithCaptureGroup:(NSString *)pattern{
    NSRange searchRange = NSMakeRange(0, [string length]);
    NSRegularExpression * regex = [NSRegularExpression
                                   regularExpressionWithPattern:pattern
                                   options:NSRegularExpressionDotMatchesLineSeparators
                                   error:NULL];
    NSArray* matches = [regex
                        matchesInString:string
                        options:0
                        range:searchRange];
    NSMutableArray * matchStrings = [NSMutableArray array];
    for (NSTextCheckingResult* match in matches) {
        NSMutableArray* matchString = [NSMutableArray array];
        for(int i=0;i<[match numberOfRanges];++i){
            [matchString addObject:[string substringWithRange:[match rangeAtIndex:i]]];
        }
        [matchStrings addObject:matchString];
    }
    return matchStrings;
}
@end

@implementation NSString (NSString_CrypoExtension)

-(NSString*)HMACMD5:(NSString *)secret{
    CCHmacContext ctx;
    const char * key = [secret UTF8String];
    const char * str = [self UTF8String];
    unsigned char mac[CC_MD5_DIGEST_LENGTH];
    char hexmac[2*CC_MD5_DIGEST_LENGTH+1];
    char *p;
    
    CCHmacInit(&ctx, kCCHmacAlgMD5, key, strlen(key));
    CCHmacUpdate(&ctx, str, strlen(str));
    CCHmacFinal(&ctx, mac);
    
    p=hexmac;
    for(int i=0;i<CC_MD5_DIGEST_LENGTH; ++i){
        snprintf(p, 3, "%02x", mac[i]);
        p+=2;
    }
    return [NSString stringWithUTF8String:hexmac];
}
-(NSData *) md5Raw{
    const char * cStr=[self UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, strlen(cStr), result);
    return [NSData dataWithBytes:result length:CC_MD5_DIGEST_LENGTH];
}
-(NSString*) md5{
    unsigned char *result = [[self md5Raw] bytes];
    NSMutableString * output = [NSMutableString string];
    for (int i=0;i<16;++i){
        [output appendFormat:@"%02x",result[i]];
    }
    return output;
}

@end
