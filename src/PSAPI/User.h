//
//  User.h
//  PSAPI
//
//  Created by Kolatat Thangkasemvathana on 17/9/14.
//  Copyright (c) 2014 ISB Software Development Club. All rights reserved.
//

@class PSCore;

/*!
 * @abstract Represents an authenticated user A.K.A. a student.
 */
@interface PSUser : NSObject

/*!
 * @brief The PSCore in which the student belongs to.
 */
@property (readonly) PSCore* core;

/*!
 * @brief The raw HTML representation obtained from the server about this student. Naughty naughty.
 */
@property (readonly) NSString* homeContents;

/*!
 * @brief An array of courses taken by this student.
 */
@property (readonly) NSArray* courses;

/*!
 * @discussion Initializes the student with a given raw HTML representation.
 * @param core The PSCore in which the student belongs.
 * @param homeContents The raw HTML representation obtained from the server.
 * @return The student PSUser object.
 */
-(id)init:(PSCore*)core htmlHomeContents:(NSString*)homeContents;

/*!
 * @discussion Fetches the student's transcript, Ohohohooo dammn.
 * @return The student's transcript.
 */
-(NSString*) fetchTranscript;

/*!
 * @discussion Gets the school name.
 * @return The name of the school.
 */
-(NSString*) getSchoolName;

/*!
 * @discussion Gets the student's full name (or username depending on school's implementation I think).
 * @return The name.
 */
-(NSString*) getUserName;

/*!
 * @discussion Gets the student's GPA.
 * @return The GPA.
 */
-(NSNumber*) getGPA;
@end
