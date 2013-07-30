//
//  Place.h
//  Miller
//
//  Created by laudmankimo on 2/6/10.
//  Copyright 2010 laudmankimo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Place : NSObject

@property (nonatomic, copy) NSString  *name;
@property (nonatomic, copy) NSString  *description;
@property (nonatomic, strong) NSNumber  *latitude;
@property (nonatomic, strong) NSNumber  *longitude;
@end
