//
//  User.m
//  PSAPI
//
//  Created by Kolatat Thangkasemvathana on 17/9/14.
//  Copyright (c) 2014 ISB Software Development Club. All rights reserved.
//

@implementation PSUser
-(id)init:(PSCore *)core htmlHomeContents:(NSString *)homeContents{
    _core=core;
    _homeContents=homeContents;
    _courses=[self createCourses];
    return self;
}
-(NSString*)fetchTranscript{
    return [_core request:@"guardian/studentdata.xml?ac=download"];
}
-(NSArray*)createCourses{
    NSMutableArray* terms = [NSMutableArray arrayWithArray:[Utils regexExtract:_homeContents
                                                  regexPatternWithCaptureGroup:@"<tr class=\"center th2\">(.*?)</tr>"]];
    terms = [NSMutableArray arrayWithArray:[Utils regexExtract:terms[0][0]
                                  regexPatternWithCaptureGroup:@"<th rowspan=\"2\">(.*?)</th>"]];
    
    [terms removeObjectAtIndex:0];
    [terms removeObjectAtIndex:0];
    [terms removeLastObject];
    [terms removeLastObject];
    
    NSMutableArray* classes = [NSMutableArray arrayWithArray:[Utils regexExtract:_homeContents
                                                    regexPatternWithCaptureGroup:@"<tr class=\"center\" bgcolor=\"(.*?)\">(.*?)</tr>"]];
    NSMutableArray* allClasses = [NSMutableArray array];
    for(NSArray* class in classes){
        if([[Utils regexExtract:class[2]
   regexPatternWithCaptureGroup:@"<td align=\"left\">(.*?)(&nbsp;|&bbsp;)<br>(.*?)<a href=\"mailto:(.*?)\">(.*?)</a>(.*?)</td>"] count]==1){
            [allClasses addObject:[[PSCourse alloc] init:_core courseHTML:class[2]]];
        }
    }
    return allClasses;
}
-(NSString*)getSchoolName{
    NSString* name = [Utils regexExtract:_homeContents
            regexPatternWithCaptureGroup:@"<div id=\"print-school\">(.*?)<br>"][0][1];
    return [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}
-(NSString*)getUserName{
    NSString* username = [Utils regexExtract:_homeContents
                regexPatternWithCaptureGroup:@"<li id=\"userName\" .*?<span>(.*?)<span>"][0][1];
    return [username stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}
-(NSNumber*)getGPA{
    NSString* strGPA = [Utils regexExtract:_homeContents
              regexPatternWithCaptureGroup:@"<td align=\"center\">Current Grade to Date GPA \\((.*?)\\): ([^ ]*?)</td>"][0][2];
    NSNumberFormatter * nf = [[NSNumberFormatter alloc] init];
    [nf setNumberStyle:NSNumberFormatterDecimalStyle];
    return [nf numberFromString:strGPA];
}
@end
