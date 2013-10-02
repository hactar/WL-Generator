//
//  wlAppDelegate.m
//  WL Generator
//
//  Created by patrick on 29/08/2013.
//  Copyright (c) 2013 patrick. All rights reserved.
//

#import "wlAppDelegate.h"
#import "CHCSVParser.h"

@interface LinienDelegate : NSObject <CHCSVParserDelegate>

//expects id to be in column 0 and name to be in column 1

@property (readonly)  NSMutableDictionary *dictionary;

@end

@implementation LinienDelegate {
    
    
    NSMutableDictionary *_dictionary;
    NSString *tempKey;
    BOOL firstLineDone;
}

- (void)parserDidBeginDocument:(CHCSVParser *)parser {
    _dictionary = [[NSMutableDictionary alloc] init];
}
- (void)parser:(CHCSVParser *)parser didBeginLine:(NSUInteger)recordNumber {
    
}
- (void)parser:(CHCSVParser *)parser didReadField:(NSString *)field atIndex:(NSInteger)fieldIndex {
    if (!firstLineDone) {
        return;
    }
    switch (fieldIndex) {
        case 0:
            tempKey = field;
            break;
        case 1:
            if (tempKey) {
                [_dictionary setValue:field forKey:tempKey];
            }
            
            
        default:
            break;
    }
}
- (void)parser:(CHCSVParser *)parser didEndLine:(NSUInteger)recordNumber {
    tempKey = nil;
    firstLineDone = YES;
}
- (void)parserDidEndDocument:(CHCSVParser *)parser {
}
- (void)parser:(CHCSVParser *)parser didFailWithError:(NSError *)error {
	NSLog(@"ERROR: %@", error);
}
@end


@interface StegDelegate : NSObject <CHCSVParserDelegate>

//expects id to be in column 0 and name to be in column 1

@property (readonly)  NSMutableDictionary *dictionary;
@property () NSMutableDictionary *linienDictionary;

@end

@implementation StegDelegate {
    
    
    NSMutableDictionary *_dictionary;
    NSString *stationid;
    NSMutableDictionary *_currentLine;
    BOOL firstLineDone;
}

- (void)parserDidBeginDocument:(CHCSVParser *)parser {
    _dictionary = [[NSMutableDictionary alloc] init];
}
- (void)parser:(CHCSVParser *)parser didBeginLine:(NSUInteger)recordNumber {
    if (firstLineDone) {
        _currentLine = [[NSMutableDictionary alloc] initWithCapacity:4];
    }
    
}
- (void)parser:(CHCSVParser *)parser didReadField:(NSString *)field atIndex:(NSInteger)fieldIndex {
    if (!firstLineDone) {
        return;
    }
    switch (fieldIndex) {
        case 1:
            [_currentLine setValue:[self.linienDictionary objectForKey:field] forKey:@"line"];
            break;
        case 2:
            stationid = field;
            break;
        case 5:
            [_currentLine setValue: field forKey:@"rbl"];
            if ([field isEqualToString:@""] && [[_currentLine valueForKey:@"line"] rangeOfString:@"S"].location == NSNotFound) {
                NSLog(@"StationID %@: No RBL for line %@", stationid, [_currentLine valueForKey:@"line"]);
            }
            break;
        case 8:
            [_currentLine setValue: field forKey:@"latitude"];
            break;
        case 9:
            [_currentLine setValue: field forKey:@"longitude"];
            break;
            
            
        default:
            break;
    }
}
- (void)parser:(CHCSVParser *)parser didEndLine:(NSUInteger)recordNumber {
    if (firstLineDone && stationid && [(NSString *)[_currentLine valueForKey:@"rbl"] length] > 0) {
        NSMutableArray *arrayOfStegs = [_dictionary valueForKey:stationid];
        if (!arrayOfStegs) {
            arrayOfStegs = [NSMutableArray array];
            [_dictionary setValue:arrayOfStegs forKey:stationid];
        }
        // Some rbls are in one line and are seperated by ":". This takes care of this.
        NSArray *rbls = [[_currentLine valueForKey:@"rbl"] componentsSeparatedByString:@":"];
        for (NSString *rbl in rbls) {
            BOOL addMe = YES;
            for (NSDictionary *element in arrayOfStegs) {
                if ([[element valueForKey:@"rbl"] isEqualToString:rbl]) {
                    addMe = NO;
                    break;
                }
            }
            if (addMe) {
                [_currentLine setValue:rbl forKey:@"rbl"]; 
                [arrayOfStegs addObject:[_currentLine copy]];
            }
        }

        
    }
    firstLineDone = YES;
    stationid = nil;
    
    // add finished dictionary to station ids array
}
- (void)parserDidEndDocument:(CHCSVParser *)parser {
}
- (void)parser:(CHCSVParser *)parser didFailWithError:(NSError *)error {
	NSLog(@"ERROR: %@", error);
}
@end

@interface StationDelegate : NSObject <CHCSVParserDelegate>

//expects id to be in column 0 and name to be in column 1

@property (readonly)  NSMutableArray *array;
@property () NSMutableDictionary *stegDictionary;

@end

@implementation StationDelegate {
    
    
    NSMutableArray *_array;
    //NSString *stationid;
    NSMutableDictionary *_currentLine;
    BOOL firstLineDone;
}

- (void)parserDidBeginDocument:(CHCSVParser *)parser {
    _array = [[NSMutableArray alloc] init];
}
- (void)parser:(CHCSVParser *)parser didBeginLine:(NSUInteger)recordNumber {
    if (firstLineDone) {
        _currentLine = [[NSMutableDictionary alloc] initWithCapacity:4];
    }
    
}
- (void)parser:(CHCSVParser *)parser didReadField:(NSString *)field atIndex:(NSInteger)fieldIndex {
    if (!firstLineDone) {
        return;
    }
    switch (fieldIndex) {
        case 0:
            [_currentLine setValue:field forKey:@"stationID"];
            break;
        case 3:
            [_currentLine setValue:field forKey:@"name"];
            break;
        case 6:
            [_currentLine setValue: field forKey:@"latitude"];
            break;
        case 7:
            [_currentLine setValue: field forKey:@"longitude"];
            break;
            
            
        default:
            break;
    }
}
- (void)parser:(CHCSVParser *)parser didEndLine:(NSUInteger)recordNumber {
    if (firstLineDone) {
        if ([(NSString *)[_currentLine valueForKey:@"stationID"] length] == 0) {
            return;
        }
   
        NSArray *platforms = [self.stegDictionary valueForKey:[_currentLine valueForKey:@"stationID"]];
        if (!platforms) {
            NSLog(@"No platforms for stationID %@", _currentLine);
            return;
        }
        NSMutableString *relatedLines = [NSMutableString stringWithString:@""];
        NSMutableSet *relatedLinesSet = [NSMutableSet setWithCapacity:2];
        for (NSDictionary *element in platforms) {
            [relatedLinesSet addObject:[element valueForKey:@"line"]];
        }
        int i = 0;
        for (NSString *line in relatedLinesSet) {
            if (i > 0) {
                [relatedLines appendFormat:@"|%@",line];
            } else {
                [relatedLines appendString:line];
            }
            i++;
        }
        [_currentLine setValue:relatedLines forKey:@"relatedLines"];
        [_currentLine setValue:platforms forKey:@"platforms"];
        [_array addObject:_currentLine];
    }
    firstLineDone = YES;
    
    // add finished dictionary to station ids array
}
- (void)parserDidEndDocument:(CHCSVParser *)parser {
}
- (void)parser:(CHCSVParser *)parser didFailWithError:(NSError *)error {
	NSLog(@"ERROR: %@", error);
}
@end





@implementation wlAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
}
- (IBAction)buttonPushed:(id)sender {
    
    //open linien file and generate dict
    
    NSOpenPanel *linienPanel = [NSOpenPanel openPanel];
    linienPanel.title = @"Please open the linien CSV file...";
    
    //[saver runModal];
    if ([linienPanel runModal] == NSOKButton){
        
        NSLog(@"Loading in lines file...");
        NSStringEncoding encoding = 0;
        NSInputStream *stream = [NSInputStream inputStreamWithURL:linienPanel.URL];
        CHCSVParser * p = [[CHCSVParser alloc] initWithInputStream:stream usedEncoding:&encoding delimiter:';'];
        [p setRecognizesBackslashesAsEscapes:YES];
        [p setSanitizesFields:YES];
        
        NSLog(@"encoding: %@", CFStringGetNameOfEncoding(CFStringConvertNSStringEncodingToEncoding(encoding)));
        
       	LinienDelegate * lines = [[LinienDelegate alloc] init];
        [p setDelegate:lines];
        
        [p parse];
    
        
        NSOpenPanel *stegPanel = [NSOpenPanel openPanel];
        stegPanel.title = @"Please open the steg CSV file...";
        
        if ([stegPanel runModal] == NSOKButton){
            
            NSLog(@"Loading in platforms...");
            NSStringEncoding stegEncoding = 0;
            NSInputStream *stegStream = [NSInputStream inputStreamWithURL:stegPanel.URL];
            CHCSVParser * stegParser = [[CHCSVParser alloc] initWithInputStream:stegStream usedEncoding:&stegEncoding delimiter:';'];
            [stegParser setRecognizesBackslashesAsEscapes:YES];
            [stegParser setSanitizesFields:YES];
            
            NSLog(@"encoding: %@", CFStringGetNameOfEncoding(CFStringConvertNSStringEncodingToEncoding(stegEncoding)));
            
            StegDelegate *stegDelegate = [[StegDelegate alloc] init];
            stegDelegate.linienDictionary = lines.dictionary;
            [stegParser setDelegate:stegDelegate];
            
            [stegParser parse];
            
            
            NSOpenPanel *stationPanel = [NSOpenPanel openPanel];
            stationPanel.title = @"Please open the station CSV file...";
            
            if ([stationPanel runModal] == NSOKButton){
                NSLog(@"Loading in stations...");
                NSTimeInterval start = [NSDate timeIntervalSinceReferenceDate];
                NSStringEncoding stationEncoding = 0;
                NSInputStream *stationStream = [NSInputStream inputStreamWithURL:stationPanel.URL];
                CHCSVParser * stationParser = [[CHCSVParser alloc] initWithInputStream:stationStream usedEncoding:&stationEncoding delimiter:';'];
                [stationParser setRecognizesBackslashesAsEscapes:YES];
                [stationParser setSanitizesFields:YES];
                
                NSLog(@"encoding: %@", CFStringGetNameOfEncoding(CFStringConvertNSStringEncodingToEncoding(stationEncoding)));
                
                StationDelegate *stationDelegate = [[StationDelegate alloc] init];
                stationDelegate.stegDictionary = stegDelegate.dictionary;
                [stationParser setDelegate:stationDelegate];
                
                
                [stationParser parse];
                
                //[NSKeyedArchiver archiveRootObject:stationDelegate.array toFile:[@"~/Desktop/wl.plist" stringByExpandingTildeInPath]];
                NSTimeInterval end = [NSDate timeIntervalSinceReferenceDate];
                
                NSLog(@"raw difference: %f", (end-start));
                
                NSData *data = [NSJSONSerialization dataWithJSONObject:stationDelegate.array
                                                               options:kNilOptions
                                                                 error:nil];
                [data writeToFile:[@"~/Desktop/wl.json" stringByExpandingTildeInPath] atomically:YES];
                
            }
            
        }
        
        

    }
    
    //open steg file and generate dict
    
    //open station file and generate array
}

@end
