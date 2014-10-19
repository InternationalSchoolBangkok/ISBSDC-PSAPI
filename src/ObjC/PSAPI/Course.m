//
//  Course.m
//  PSAPI
//
//  Created by Kolatat Thangkasemvathana on 17/9/14.
//  Copyright (c) 2014 ISB Software Development Club. All rights reserved.
//

static BOOL is_numeric(NSString* var){
    NSCharacterSet* notDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    return [var rangeOfCharacterFromSet:notDigits].location == NSNotFound;
}
static NSString* strip_tags(NSString* str){
    NSRange r;
    while((r=[str rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location!=NSNotFound){
        str = [str stringByReplacingCharactersInRange:r withString:@""];
    }
    return str;
}

@implementation PSCourse
-(id)init:(PSCore *)core courseHTML:(NSString *)html{
    _core=core;
    _html=html;
    
    _teacher=[NSMutableDictionary dictionary];
    _scores=[NSMutableDictionary dictionary];
    _attendance=[NSMutableDictionary dictionary];
    _comments=[NSMutableDictionary dictionary];
    
    [self populateCourse];
    return self;
}
-(NSDictionary*)splitA:(NSString *)strip{
    if([[strip substringToIndex:MIN(2, [strip length])] isEqual:@"<a"]){
        NSArray* stripped = [Utils regexExtract:strip
                   regexPatternWithCaptureGroup:@"<a href=\"(.*?)\">(.*?)</a>"];
        return [NSDictionary dictionaryWithObjectsAndKeys:stripped[0][2], @"title",
                stripped[0][1],@"url",nil];
    } else {
        return [NSDictionary dictionaryWithObjectsAndKeys:strip, @"title",nil];
    }
}
-(void)populateCourse{
    NSArray* classData = [Utils regexExtract:_html
                regexPatternWithCaptureGroup:@"<td align=\"left\">(.*?)(&nbsp;|&bbsp;)<br>(.*?)<a href=\"mailto:(.*?)\">(.*?)</a>(.*?)</td>"][0];
    _name=classData[1];
    [_teacher setObject:classData[5] forKey:@"name"];
    [_teacher setObject:classData[4] forKey:@"email"];
    NSArray* databits = [Utils regexExtract:_html
               regexPatternWithCaptureGroup:@"<td>(.*?)</td>"];
    _period = databits[0][1];
    NSDictionary* absences = [self splitA:databits[[databits count]-2][1]];
    if([absences objectForKey:@"url"]==NULL){
        [_attendance setObject:[NSDictionary dictionaryWithObject:[absences objectForKey:@"title"] forKey:@"count"] forKey:@"absences"];
    } else {
        [_attendance setObject:[NSDictionary dictionaryWithObjectsAndKeys:[absences objectForKey:@"title" ],@"count",[absences objectForKey:@"url" ],@"url", nil] forKey:@"absences"];
    }
    NSDictionary* tardies = [self splitA:databits[[databits count]-1][1]];
    if([tardies objectForKey:@"url"]==NULL){
        [_attendance setObject:[NSDictionary dictionaryWithObject:[tardies objectForKey:@"title"] forKey:@"count"] forKey:@"tardies"];
    } else {
        [_attendance setObject:[NSDictionary dictionaryWithObjectsAndKeys:[tardies objectForKey:@"title" ],@"count",[tardies objectForKey:@"url" ],@"url", nil] forKey:@"absences"];
    }
    NSArray* scores = [Utils regexExtract:_html
             regexPatternWithCaptureGroup:@"<a href=\"scores.html\?(.*?)\">(.*?)</a>"];
    for (NSArray* score in scores) {
        NSArray* urlBits = [Utils regexExtract:score[1]
                  regexPatternWithCaptureGroup:@"frn=(.*?)&fg=(.*)"][0];
        NSArray* scoreT = [score[2] componentsSeparatedByString:@"<br>"];
        if(![score[2] isEqual:@"--"] && !is_numeric(scoreT[0])){
            [_scores setObject:[NSDictionary dictionaryWithObjectsAndKeys:scoreT[1],@"score",
                                [NSString stringWithFormat:@"scores.html?%@",score[1]],@"url", nil]
                        forKey:urlBits[2]];
        } else if (![score[2] isEqual:@"--"]){
            [_scores setObject:[NSDictionary dictionaryWithObjectsAndKeys:scoreT[0],@"score",
                                [NSString stringWithFormat:@"scores.html?%@",score[1]],@"url", nil]
                        forKey:urlBits[2]];
        }
    }
}
-(void)fetchTerm:(NSString *)term{
    NSString* result =  [_core request:[NSString stringWithFormat:@"guardian/%@",[[_scores objectForKey:term] objectForKey:@"url"]]];
    NSArray* assignments=[Utils regexExtract:result
                regexPatternWithCaptureGroup:@"<table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" align=\"center\" width=\"99%\">(.*?)</table>"][0];
    assignments=[Utils regexExtract:assignments[1]
       regexPatternWithCaptureGroup:@"<tr bgcolor=\"(.*?)\">(.*?)</tr>"];
    NSMutableArray* data = [NSMutableArray array];
    for (NSArray* assignmentHTML in assignments) {
        NSArray* assignmentData = [Utils regexExtract:assignmentHTML[2]
                         regexPatternWithCaptureGroup:@"<td(.*?)?>(.*?)</td>"];
        NSMutableDictionary* assignment = [NSMutableDictionary dictionary];
        [assignment setObject:assignmentData[0][2] forKey:@"due"];
        [assignment setObject:assignmentData[1][2] forKey:@"category"];
        [assignment setObject:assignmentData[2][2] forKey:@"assignment"];
        
        NSMutableDictionary* codes = [NSMutableDictionary dictionary];
        [codes setObject:[NSNumber numberWithBool:![assignmentData[3][2] isEqualToString:@""]] forKey:@"collected"];
        [codes setObject:[NSNumber numberWithBool:![assignmentData[4][2] isEqualToString:@""]]
                  forKey:@"collected"];
        [codes setObject:[NSNumber numberWithBool:![assignmentData[5][2] isEqualToString:@""]]
                  forKey:@"missing"];
        [codes setObject:[NSNumber numberWithBool:![assignmentData[6][2] isEqualToString:@""]]
                  forKey:@"exempt"];
        [codes setObject:[NSNumber numberWithBool:![assignmentData[7][2] isEqualToString:@""]]
                  forKey:@"excluded"];
        
        [assignment setObject:codes forKey:@"codes"];
        [assignment setObject:strip_tags(assignmentData[8][2]) forKey:@"score"];
        [assignment setObject:assignmentData[9][2] forKey:@"percent"];
        [assignment setObject:assignmentData[10][2] forKey:@"grade"];
        
        [data addObject:assignment];
    }
    [[_scores valueForKey:term] setValue:data forKey:@"assignments"];
    NSArray* comments = [Utils regexExtract:result
               regexPatternWithCaptureGroup:@"<div class=\"comment\">.*?<pre>(.*?)</pre>.*?</div>"];
    [_comments setValue:[NSDictionary dictionaryWithObjectsAndKeys:comments[0][1],@"teacher",
                         comments[1][1],@"section", nil] forKey:term];
}
-(NSDictionary*)getComments:(NSString *)term{
    term=[term uppercaseString];
    if([_scores valueForKey:term]==NULL) return NULL;
    if([_comments valueForKey:term]==NULL) [self fetchTerm:term];
    return [_comments valueForKey:term];
}
-(NSArray*)getAssignments:(NSString *)term{
    term=[term uppercaseString];
    if([_scores valueForKey:term]==NULL) return NULL;
    if([[_scores valueForKey:term] valueForKey:@"assignments"]==NULL) [self fetchTerm:term];
    return [[_scores valueForKey:term] valueForKey:@"assignments"];
}
-(NSNumber*)getLatestScore{
    NSDictionary * latestScore = [_scores objectForKey:@"S2"];
    if(latestScore==nil){
        latestScore=[_scores objectForKey:@"S1"];
        if(latestScore==nil){
            return nil;
        }
    }
    
    NSString* strScore=[latestScore objectForKey:@"score"];
    NSNumberFormatter * nf = [[NSNumberFormatter alloc] init];
    [nf setNumberStyle:NSNumberFormatterDecimalStyle];
    return [nf numberFromString:strScore];
}
@end


