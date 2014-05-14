//
//  Person.h
//  DemoAddressBook
//
//  Created by 周玉 on 14-5-14.
//  Copyright (c) 2014年 huoli. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Person : NSObject
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) int sectionNumber;
- (NSString *)firstLetter;
@end
