//
//  Course.h
//  PSAPI
//
//  Created by Kolatat Thangkasemvathana on 17/9/14.
//  Copyright (c) 2014 ISB Software Development Club. All rights reserved.
//

@class PSCore;

/*!
 * @abstract Represents a course or a class taught at school.
 */
@interface PSCourse : NSObject

/*!
 * @brief The PSCore this course belongs to.
 */
@property (readonly) PSCore* core;

/*!
 * @brief The raw HTML obtained from the server of this class.
 */
@property (readonly) NSString* html;

/*!
 * @brief The name of the course.
 */
@property (readonly) NSString* name;

/*!
 * @brief The dictionary of teacher(s) teaching this course.
 */
@property (readonly) NSMutableDictionary* teacher;

/*!
 * @brief The dictionary of score(s) the student is getting in this course.
 */
@property (readonly) NSMutableDictionary* scores;

/*!
 * @brief The period of this course.
 */
@property (readonly) NSString* period;

/*!
 * @brief The dictionary of attendance markings of the student in this course.
 */
@property (readonly) NSMutableDictionary* attendance;

/*!
 * @brief <#description#>
 */
@property (readonly) NSMutableDictionary* comments;

/*!
 * @discussion Initializes the course.
 * @param core The PSCore that this course belongs to.
 * @param html The raw HTML obtained from the server about this course.
 * @return The course object.
 */
-(id)init:(PSCore*)core courseHTML:(NSString*)html;

/*!
 * @discussion Splits and extracts text from a potential &lt;a&gt; html tag.
 * @param strip The string with the potential tag to be splitted.
 * @return The string that is extracted.
 */
-(NSDictionary*)splitA:(NSString*)strip;

/*!
 * @discussion Starts population of fields and properties of this course from the given HTML description.
 */
-(void)populateCourse;

/*!
 * @discussion Fetches information about a term and store it in the course properties.
 * @discussion (at least that's what I think it does)
 * @param term The term.
 */
-(void)fetchTerm:(NSString*)term;

/*!
 * @discussion Gets the teacher comments for this course.
 * @param term The term the comment(s) belong(s) to.
 * @return The dictionary of comment(s).
 */
-(NSDictionary*)getComments:(NSString*)term;

/*!
 * @discussion Gets the assignments for this course.
 * @param term The term of the assignments.
 * @return An array of assignments.
 */
-(NSArray*)getAssignments:(NSString*)term;

/*!
 * @discussion Gets the score percentage for the most current term.
 * @return The percentage (on scale of 0 to 100).
 */
-(NSNumber*)getLatestScore;
@end