//
//  NSKeyedUnarchiver+SwiftUtilities.h
//  Carlos
//
//  Created by Monaco, Vittorio on 03/09/15.
//  Copyright (c) 2015 WeltN24. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSKeyedUnarchiver (SwiftUtilities)

/**
 Safely unarchives an object at a given file path through NSKeyedUnarchiver
 
 :param: filePath The path to the file to unarchive
 
 :returns: The unarchived object if the unarchive operation was successful, or nil if the unarchiver threw an exception
 */
+ (id) su_unarchiveObjectWithFilePath:(NSString *)filePath;

/**
 Safely unarchives an object from an NSData instance through NSKeyedUnarchiver
 
 :param: data The data containing the object to unarchive
 
 :returns: The unarchived object if the unarchive operation was successful, or nil if the unarchiver threw an exception
 */
+ (id) su_unarchiveObjectWithData:(NSData *)data;

@end
