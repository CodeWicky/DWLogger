//
//  DWFileManager.m
//  video
//
//  Created by Wicky on 2017/4/12.
//  Copyright © 2017年 Wicky. All rights reserved.
//

#import "DWFileManager.h"

#define DefaultFileManager [NSFileManager defaultManager]

@implementation DWFileManager

+(NSString *)homeDir {
    return NSHomeDirectory();
}

+(NSString *)documentsDir {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
}

+(NSString *)libraryDir {
    return [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject];
}

+(NSString *)preferencesDir {
    return [[self libraryDir] stringByAppendingPathComponent:@"Preferences"];
}

+(NSString *)cachesDir {
    return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
}

+(NSString *)tmpDir {
    return NSTemporaryDirectory();
}

+(NSDictionary *)attributesOfItemAtPath:(NSString *)path error:(NSError *__autoreleasing *)error {
    return [DefaultFileManager attributesOfItemAtPath:path error:error];
}

+(NSDictionary *)attributesOfItemAtPath:(NSString *)path {
    return [self attributesOfItemAtPath:path error:nil];
}

+(id)attributeOfItemAtPath:(NSString *)path forKey:(NSString *)key error:(NSError *__autoreleasing *)error {
    return [[self attributesOfItemAtPath:path error:error] objectForKey:key];
}

+(id)attributeOfItemAtPath:(NSString *)path forKey:(NSString *)key {
    return [self attributeOfItemAtPath:path forKey:key error:nil];
}

+(BOOL)isDirectoryAtPath:(NSString *)path {
    BOOL isDir = NO;
    BOOL exist = [DefaultFileManager fileExistsAtPath:path isDirectory:&isDir];
    return (exist && isDir);
}

+(BOOL)isFileAtPath:(NSString *)path {
    BOOL isDir = NO;
    BOOL exist = [DefaultFileManager fileExistsAtPath:path isDirectory:&isDir];
    return (exist && !isDir);
}

+(NSArray<DWFileManagerFile *> *)listFilesInDirectoryAtPath:(NSString *)path deep:(BOOL)deep {
    if (deep) {///深遍历
        return [self listFilesInDirectoryAtPath:path depth:1];
    } else {///浅遍历
        NSMutableArray * arr = [NSMutableArray array];
        NSArray * files = [DefaultFileManager contentsOfDirectoryAtPath:path error:nil];
        for (NSString * file in files) {
            NSString * fullName = [path stringByAppendingPathComponent:file];
            DWFileManagerFile * fileIns = [DWFileManagerFile new];
            fileIns.fileName = file;
            fileIns.path = path;
            if ([self isDirectoryAtPath:fullName]) {
                fileIns.isFolder = YES;
            }
            [arr addObject:fileIns];
        }
        return arr;
    }
}

///递归调用，深层遍历
+(NSArray<DWFileManagerFile *> *)listFilesInDirectoryAtPath:(NSString *)path depth:(NSUInteger)depth {
    NSMutableArray * arr = [NSMutableArray array];
    NSArray * files = [DefaultFileManager contentsOfDirectoryAtPath:path error:nil];
    for (NSString * file in files) {
        NSString * fullName = [path stringByAppendingPathComponent:file];
        DWFileManagerFile * fileIns = [DWFileManagerFile new];
        fileIns.fileName = file;
        fileIns.path = path;
        fileIns.depth = depth;
        if ([self isDirectoryAtPath:fullName]) {
            fileIns.isFolder = YES;
            fileIns.showContent = YES;
            fileIns.files = [self listFilesInDirectoryAtPath:fullName depth:depth + 1];
        }
        [arr addObject:fileIns];
    }
    return arr;
}

+(BOOL)createDirectoryAtPath:(NSString *)path {
    return [self createDirectoryAtPath:path error:nil];
}

+(BOOL)createDirectoryAtPath:(NSString *)path error:(NSError *__autoreleasing *)error {
    return [DefaultFileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:error];
}

+(BOOL)isDirectoryIsEmptyAtPath:(NSString *)path {
    if (![self isDirectoryAtPath:path]) {
        return NO;
    }
    return ([self listFilesInDirectoryAtPath:path deep:NO].count == 0);
}

+(BOOL)removeItemAtPath:(NSString *)path {
    return [DefaultFileManager removeItemAtPath:path error:nil];
}

+(BOOL)clearDirectoryAtPath:(NSString *)path {
    NSArray *subFiles = [self listFilesInDirectoryAtPath:path deep:NO];
    BOOL isSuccess = YES;
    for (DWFileManagerFile *file in subFiles) {
        NSString *absolutePath = [path stringByAppendingPathComponent:file.fileName];
        isSuccess &= [self removeItemAtPath:absolutePath];
    }
    return isSuccess;
}

+(BOOL)clearCache {
    return [self clearDirectoryAtPath:[self cachesDir]];
}

+(BOOL)clearTmp {
    return [self clearDirectoryAtPath:[self tmpDir]];
}

+(BOOL)createFileAtPath:(NSString *)path content:(NSObject *)content overwrite:(BOOL)overwrite error:(NSError *__autoreleasing *)error {
    if ([self isFileAtPath:path] && !overwrite) {
        safeLinkError(error, [NSError errorWithDomain:@"Write File Error!" code:10001 userInfo:@{@"reason":@"attemp to write a file which is already exist."}]);
        return NO;
    }
    
    if (![self createDirectoryAtPath:[self directoryPathAtPath:path] error:error]) {
        return NO;
    }
    BOOL isSuccess = [DefaultFileManager createFileAtPath:path contents:nil attributes:nil];
    if (content) {
        [self writeFileAtPath:path content:content error:error];
    }
    return isSuccess;
}

+(BOOL)createFileAtPath:(NSString *)path {
    return [self createFileAtPath:path content:nil overwrite:NO error:nil];
}

+(BOOL)writeFileAtPath:(NSString *)path content:(NSObject *)content error:(NSError *__autoreleasing *)error {
    if (!content) {
        [NSException raise:@"非法的文件内容" format:@"文件内容不能为nil"];
        return NO;
    }
    if ([self isFileAtPath:path]) {
        if ([content isKindOfClass:[NSMutableArray class]]) {
            [(NSMutableArray *)content writeToFile:path atomically:YES];
        }else if ([content isKindOfClass:[NSArray class]]) {
            [(NSArray *)content writeToFile:path atomically:YES];
        }else if ([content isKindOfClass:[NSMutableData class]]) {
            [(NSMutableData *)content writeToFile:path atomically:YES];
        }else if ([content isKindOfClass:[NSData class]]) {
            [(NSData *)content writeToFile:path atomically:YES];
        }else if ([content isKindOfClass:[NSMutableDictionary class]]) {
            [(NSMutableDictionary *)content writeToFile:path atomically:YES];
        }else if ([content isKindOfClass:[NSDictionary class]]) {
            [(NSDictionary *)content writeToFile:path atomically:YES];
        }else if ([content isKindOfClass:[NSJSONSerialization class]]) {
            [(NSDictionary *)content writeToFile:path atomically:YES];
        }else if ([content isKindOfClass:[NSMutableString class]]) {
            [[((NSString *)content) dataUsingEncoding:NSUTF8StringEncoding] writeToFile:path atomically:YES];
        }else if ([content isKindOfClass:[NSString class]]) {
            [[((NSString *)content) dataUsingEncoding:NSUTF8StringEncoding] writeToFile:path atomically:YES];
        }else if ([content isKindOfClass:[UIImage class]]) {
            [UIImagePNGRepresentation((UIImage *)content) writeToFile:path atomically:YES];
        }else if ([content conformsToProtocol:@protocol(NSCoding)]) {
            [NSKeyedArchiver archiveRootObject:content toFile:path];
        }else {
            [NSException raise:@"非法的文件内容" format:@"文件类型%@异常，无法被处理。", NSStringFromClass([content class])];
            
            return NO;
        }
    }else {
        return NO;
    }
    return YES;
}

+(BOOL)copyItemAtPath:(NSString *)path toPath:(NSString *)toPath overwrite:(BOOL)overwrite error:(NSError *__autoreleasing *)error {
    
    if (![DefaultFileManager fileExistsAtPath:path isDirectory:nil]) {
        safeLinkError(error, [NSError errorWithDomain:@"Read File Error!" code:10002 userInfo:@{@"reason":[NSString stringWithFormat:@"file not exist at %@.",path]}]);
        return NO;
    }
    
    if ([DefaultFileManager fileExistsAtPath:toPath isDirectory:nil] && !overwrite) {
        safeLinkError(error, [NSError errorWithDomain:@"Write File Error!" code:10001 userInfo:@{@"reason":@"attemp to write a file which is already exist."}]);
        return NO;
    }
    if (![self createDirectoryAtPath:[toPath stringByDeletingLastPathComponent]]) {
        safeLinkError(error, [NSError errorWithDomain:@"Write File Error!" code:10001 userInfo:@{@"reason":[NSString stringWithFormat:@"can not create folder at %@.",toPath]}]);
        return NO;
    }
    return [DefaultFileManager copyItemAtPath:path toPath:toPath error:error];
}

+(BOOL)moveItemAtPath:(NSString *)path toPath:(NSString *)toPath overwrite:(BOOL)overwrite error:(NSError *__autoreleasing *)error {
    
    if (![DefaultFileManager fileExistsAtPath:path isDirectory:nil]) {
        safeLinkError(error, [NSError errorWithDomain:@"Read File Error!" code:10002 userInfo:@{@"reason":[NSString stringWithFormat:@"file not exist at %@.",path]}]);
        return NO;
    }
    
    if ([DefaultFileManager fileExistsAtPath:toPath isDirectory:nil] && !overwrite) {
        safeLinkError(error, [NSError errorWithDomain:@"Write File Error!" code:10001 userInfo:@{@"reason":@"attemp to write a file which is already exist."}]);
        return NO;
    }
    
    if (![self createDirectoryAtPath:[toPath stringByDeletingLastPathComponent]]) {
        safeLinkError(error, [NSError errorWithDomain:@"Write File Error!" code:10001 userInfo:@{@"reason":[NSString stringWithFormat:@"can not create folder at %@.",toPath]}]);
        return NO;
    }
    
    return [DefaultFileManager moveItemAtPath:path toPath:toPath error:error];
}

+(NSString *)fileNameAtPath:(NSString *)path extention:(BOOL)extention {
    path = [path lastPathComponent];
    if (!extention) {
        path = [path stringByDeletingPathExtension];
    }
    return path;
}

+(NSString *)directoryPathAtPath:(NSString *)path {
    return [path stringByDeletingLastPathComponent];
}

+(NSString *)extentionAtPath:(NSString *)path {
    return [path pathExtension];
}

+ (NSNumber *)sizeOfDirectoryAtPath:(NSString *)path {
    if ([self isDirectoryAtPath:path]) {
        NSArray *subPaths = [self listFilesInDirectoryAtPath:path deep:YES];
        NSEnumerator *contentsEnumurator = [subPaths objectEnumerator];
        NSString *file;
        unsigned long long int folderSize = 0;
        while (file = [contentsEnumurator nextObject]) {
            NSDictionary *fileAttributes = [DefaultFileManager attributesOfItemAtPath:[path stringByAppendingPathComponent:file] error:nil];
            folderSize += [[fileAttributes objectForKey:NSFileSize] intValue];
        }
        return [NSNumber numberWithUnsignedLongLong:folderSize];
    }
    return nil;
}

+(NSNumber *)sizeOfFileAtPath:(NSString *)path {
    if (![self isFileAtPath:path]) {
        return nil;
    }
    return (NSNumber *)[self attributeOfItemAtPath:path forKey:NSFileSize];
}

+(NSDate *)creationDateOfItemAtPath:(NSString *)path {
    if (![self isFileAtPath:path] && ![self isDirectoryAtPath:path]) {
        return nil;
    }
    return (NSDate *)[self attributeOfItemAtPath:path forKey:NSFileCreationDate error:nil];
}

+(NSDate *)modificationDateOfItemAtPath:(NSString *)path {
    if (![self isFileAtPath:path] && ![self isDirectoryAtPath:path]) {
        return nil;
    }
    return (NSDate *)[self attributeOfItemAtPath:path forKey:NSFileModificationDate error:nil];
}

+(BOOL)isExecutableItemAtPath:(NSString *)path {
    return [DefaultFileManager isExecutableFileAtPath:path];
}

+(BOOL)isReadableItemAtPath:(NSString *)path {
    return [DefaultFileManager isReadableFileAtPath:path];
}

+(BOOL)isWritableItemAtPath:(NSString *)path {
    return [DefaultFileManager isWritableFileAtPath:path];
}

#pragma mark --- tool method & function ---
NS_INLINE void safeLinkError(NSError * __autoreleasing * error ,NSError * error2Link) {
    if (error != NULL) {
        *error = error2Link;
    }
}

@end

@implementation DWFileManagerFile

-(NSArray *)files {
    if (!_files) {
        _files = [NSArray array];
    }
    return _files;
}

-(NSString *)description {
    if (!self.isFolder) {
        return self.fileName;
    }
    if (self.showContent) {
        NSString * fileStr = @"(";
        NSString * blankStr = @"";
        for (int i = 0; i < self.depth; i ++) {
            blankStr = [blankStr stringByAppendingString:@"    "];
        }
        for (DWFileManagerFile * file in self.files) {
            fileStr = [fileStr stringByAppendingString:[NSString stringWithFormat:@"\r%@%@",[blankStr stringByAppendingString:@"    "],file]];
            if ([file isEqual:self.files.lastObject]) {
                fileStr = [fileStr stringByAppendingString:[NSString stringWithFormat:@"\r%@",blankStr]];
            }
        }
        fileStr = [fileStr stringByAppendingString:[NSString stringWithFormat:@")"]];
        return [NSString stringWithFormat:@"[%@]->%@",self.fileName,fileStr];
    }
    return [NSString stringWithFormat:@"[%@]",self.fileName];
}

@end
