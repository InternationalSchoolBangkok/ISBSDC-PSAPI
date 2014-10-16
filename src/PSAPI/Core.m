//
//  Core.m
//  PSAPI
//
//  Created by Kolatat Thangkasemvathana on 16/9/14.
//  Copyright (c) 2014 ISB Software Development Club. All rights reserved.
//

@implementation PSCore
-(id)init:(NSURL*)url{
    _url = url;
    _cookieJar = [NSHTTPCookieStorage new];
    return self;
}
-(NSString*)request:(NSString*)path{
    return [self request:path postFieldsData:NULL];
}
-(NSString*)request:(NSString*)path postFieldsData:(NSDictionary *)postData{
    NSURL * fullPath = [_url URLByAppendingPathComponent:path];
    
    NSMutableURLRequest * request = [NSMutableURLRequest
                                     requestWithURL:fullPath
                                     cachePolicy:NSURLRequestUseProtocolCachePolicy
                                     timeoutInterval:10.0];
    if (postData!=NULL){
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:[[Utils urlEncodeDict:postData] dataUsingEncoding:NSUTF8StringEncoding]];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    }
    
    NSDictionary * headers = [NSHTTPCookie requestHeaderFieldsWithCookies:[_cookieJar cookies]];
    [request setAllHTTPHeaderFields:headers];
    
    NSHTTPURLResponse * response = nil;
    NSError * error = nil;
    
    NSData * result = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if(error!=nil){
        NSLog(@"%@",error);
        return nil;
    }
    
    return [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
}
-(NSDictionary*)getAuthData{
    BOOL ldap;
    
    NSString * html = [self request:@""];
    
    if(html==nil){
        NSLog(@"Unable to retrieve authentication tokens from PowerSchool server.");
    }
    
    NSString * pstoken = [Utils regexExtract:html
                regexPatternWithCaptureGroup:@"<input type=\"hidden\" name=\"pstoken\" value=\"(.*?)\" />"][0][1];
    NSString * contextData = [Utils regexExtract:html
                    regexPatternWithCaptureGroup:@"<input type=\"hidden\" name=\"contextData\" id=\"contextData\" value=\"(.*?)\" />"][0][1];
    
    ldap = [html rangeOfString:@"<input type=hidden name=ldappassword value=''>"].location!=NSNotFound;
    
    return [NSDictionary dictionaryWithObjectsAndKeys:
            pstoken,@"pstoken",
            contextData,@"contextData",
            ldap,@"ldap", nil];
}
-(PSUser*)auth:(NSString *)username password:(NSString *)password{
    NSMutableDictionary* authData = [NSMutableDictionary dictionaryWithDictionary:[self getAuthData]];
    
    [authData setValue:username forKey:@"account"];
    [authData setValue:[[password lowercaseString] HMACMD5:[authData objectForKey:@"contextData"]] forKey:@"dbpw"];
    [authData setValue:@"PS Parent Portal" forKey:@"serviceName"];
    [authData setValue:@"/" forKey:@"pcasServerUrl"];
    [authData setValue:@"User Id and Password Credential" forKey:@"credentialType"];
    [authData setValue:[[[[password md5Raw]
                          base64EncodedStringWithOptions:0]
                         stringByReplacingOccurrencesOfString:@"="
                         withString:@""]
                        HMACMD5:[authData objectForKey:@"contextData"]]
                forKey:@"pw"];
    
    [authData setValue:@"" forKey:@"translator_username"];
    [authData setValue:@"" forKey:@"translator_password"];
    [authData setValue:@"" forKey:@"translator_ldappassword"];
    [authData setValue:@"" forKey:@"translator_username"];
    [authData setValue:@"" forKey:@"returnUrl"];
    [authData setValue:@"" forKey:@"serviceTicket"];
    [authData setValue:@"" forKey:@"translatorpw"];
    
    if((BOOL)[authData valueForKey:@"ldap"]==true){
        [authData setValue:password forKey:@"ldappassword"];
        [authData removeObjectForKey:@"ldap"];
    }
    
    NSString* result = [self request:@"guardian/home.html" postFieldsData:authData];
    result = [self request:@"guardian/home.html"];
    
    if([result rangeOfString:@"Grades and Attendance"].location==NSNotFound){
        NSArray* error = [Utils regexExtract:result regexPatternWithCaptureGroup:@"<div class=\"feedback-alert\">(.*?)</div>"];
        NSString* errorString;
        if([error count]>0) errorString=error[0][1];
        else errorString=@"No error provided.";
        NSMutableDictionary* errorDetails = [NSMutableDictionary dictionary];
        [errorDetails setValue:errorString forKey:NSLocalizedDescriptionKey];
        _error=[NSError errorWithDomain:[[NSBundle mainBundle] bundleIdentifier] code:NSNotFound userInfo:errorDetails];
        NSLog(@"%@",_error);
        return nil;
    }
    
    return [[PSUser alloc] init:self];
}

@end
