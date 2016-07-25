//
//  Catagory.h
//  GaoDeMapDemo
//
//  Created by zibin on 16/7/25.
//  Copyright © 2016年 zibin. All rights reserved.
//

#ifndef Catagory_h
#define Catagory_h

// NSArray  NSDictionary 分类 打印日志为汉字 转UTF-8码
@implementation NSArray (decription)

- (NSString *)descriptionWithLocale:(id)locale
{
    NSMutableString *str = [NSMutableString stringWithFormat:@"%lu (\n", (unsigned long)self.count];
    
    for (id obj in self) {
        [str appendFormat:@"\t%@, \n", obj];
    }
    
    [str appendString:@")"];
    
    return str;
}
@end

@implementation NSDictionary (decription)
- (NSString *)descriptionWithLocale:(id)locale
{
    NSArray *allKeys = [self allKeys];
    NSMutableString *str = [[NSMutableString alloc] initWithFormat:@"{\t\n "];
    for (NSString *key in allKeys) {
        id value= self[key];
        [str appendFormat:@"\t \"%@\" = %@,\n",key, value];
    }
    [str appendString:@"}"];
    
    return str;
}
@end

#endif /* Catagory_h */
