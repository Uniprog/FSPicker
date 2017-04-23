//
//  FSContentItem.m
//  FSPicker
//
//  Created by Łukasz Cichecki on 15/03/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSContentItem.h"

@implementation FSContentItem

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        _fileName = dictionary[@"filename"];
        _linkPath = dictionary[@"link_path"];
        _mimeType = dictionary[@"mimetype"];
        _modified = dictionary[@"modified"];
        _size = dictionary[@"size"];
        _thumbnailURL = dictionary[@"thumbnail"];
        _isDirectory = [dictionary[@"is_dir"] boolValue];
        _itemCount = [self dictionaryToItemCount:dictionary];
        _thumbExists = [dictionary[@"thumb_exists"] boolValue];
    }

    return self;
}

- (instancetype)initWithGTLRDriveFile:(GTLRDrive_File *)file {
    if (self = [super init]) {
        
        NSDictionary* dictionary = file.JSON;
        
        _fileName = dictionary[@"name"];
        _linkPath = dictionary[@"id"];
        _mimeType = dictionary[@"mimeType"];
        _modified = dictionary[@"modifiedTime"];
        NSArray* dateComponents = [_modified componentsSeparatedByString:@"T"];
        if (dateComponents.count == 2) {
            _modified = dateComponents.firstObject;
        }
        
        _size = dictionary[@"size"];
        
        _thumbnailURL = dictionary[@"thumbnailLink"];
        _isDirectory = [_mimeType isEqualToString:@"application/vnd.google-apps.folder"];
        _itemCount = [self dictionaryToItemCount:dictionary];
        _thumbExists = [dictionary[@"hasThumbnail"] boolValue];
        
        _fileExtension = dictionary[@"fileExtension"];
        _fullFileExtension = dictionary[@"fullFileExtension"];

    }
    
    return self;
}

+ (NSArray<FSContentItem *> *)itemsFromResponseJSON:(NSDictionary *)json {
    NSArray<NSDictionary *> *content = [[NSArray alloc] initWithArray:json[@"contents"]];
    NSMutableArray<FSContentItem *> *items = [[NSMutableArray alloc] init];
    
    for (NSDictionary *item in content) {
        FSContentItem *contentItem = [[FSContentItem alloc] initWithDictionary:item];
        [items addObject:contentItem];
    }
    
    return items;
}

+ (NSArray<FSContentItem *> *)itemsFromGTLRDriveFileList:(GTLRDrive_FileList *)fileList {
    //NSArray<NSDictionary *> *content = [[NSArray alloc] initWithArray:json[@"contents"]];
    NSMutableArray<FSContentItem *> *items = [[NSMutableArray alloc] init];
    
    for (GTLRDrive_File* file in fileList.files) {
        FSContentItem *contentItem = [[FSContentItem alloc] initWithGTLRDriveFile:file];
        [items addObject:contentItem];
    }
    
    return items;
}


- (NSNumber *)dictionaryToItemCount:(NSDictionary *)dictionary {
    if (dictionary[@"count"]) {
        if (![dictionary[@"count"] isMemberOfClass:[NSNull class]]) {
            return dictionary[@"count"];
        }
    }

    return nil;
}

- (NSString *)detailDescription {
    NSMutableArray *description = [[NSMutableArray alloc] init];
    NSString *detailText;

    if (self.isDirectory) {
        [description addObject:@"Folder"];

        if (self.itemCount) {
            [description addObject:[NSString stringWithFormat:@"%ld %@",
                                    (long)self.itemCount.integerValue,
                                    self.itemCount.integerValue == 1 ? @"file" : @"files"]];
        }
    } else {
        if (self.modified) {
            [description addObject:[NSString stringWithFormat:@"Modified %@", self.modified]];
        }

        if (self.size) {
            [description addObject:self.size];
        }
    }

    detailText = [description componentsJoinedByString:@" | "];

    return detailText;
}

@end
