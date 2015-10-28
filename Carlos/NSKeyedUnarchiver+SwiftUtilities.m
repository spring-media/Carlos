//
//  NSKeyedUnarchiver+SwiftUtilities.m
//  Carlos
//
//  Created by Monaco, Vittorio on 03/09/15.
//  Copyright (c) 2015 WeltN24. All rights reserved.
//

#import "NSKeyedUnarchiver+SwiftUtilities.h"

@implementation NSKeyedUnarchiver (SwiftUtilities)

+ (id) su_unarchiveObjectWithFilePath:(NSString *)filePath {
  id object = nil;
  
  @try {
    object = [self unarchiveObjectWithFile:filePath];
  } @catch (NSException *exception) {
    object = nil;
  }
  
  return object;
}

+ (id) su_unarchiveObjectWithData:(NSData *)data {
  id object = nil;
  
  @try {
    object = [self unarchiveObjectWithData:data];
  } @catch (NSException *exception) {
    object = nil;
  }
  
  return object;
}

@end
