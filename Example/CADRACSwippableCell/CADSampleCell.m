//
//  CADSampleCell.m
//  CADRACSwippableCell
//
//  Created by Joan Romano on 16/04/14.
//  Copyright (c) 2014 Crows And Dogs. All rights reserved.
//

#import "CADSampleCell.h"

@interface CADSampleCell ()

@property (nonatomic, weak) IBOutlet UILabel *textLabel;

@end

@implementation CADSampleCell

- (void)setText:(NSString *)text
{
    _text = [text copy];
    
    self.textLabel.text = _text;
}

@end
