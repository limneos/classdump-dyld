//
//  TSSCategories.h
//  TSSAgent
//
//  Created by Kevin Bradley on 6/22/13.
//  Copyright 2013 nito. All rights reserved.
//


@interface NSDictionary (strings) 

- (NSString *)stringFromDictionary;

@end

@interface NSArray (strings)

- (NSString *)stringFromArray;

@end



@interface NSString (TSSAdditions)

- (id)dictionaryFromString;

@end
