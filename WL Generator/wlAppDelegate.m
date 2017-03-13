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
            for (NSMutableDictionary *element in arrayOfStegs) {
                if ([[element valueForKey:@"rbl"] isEqualToString:rbl]) {
                    addMe = NO;
                    
                    // instead, append line here to related lines or maybe this is bloedsinn.
                    NSArray *linesThatAreInAlready = [[element valueForKey:@"line"] componentsSeparatedByString:@"|"];
                    if (![linesThatAreInAlready containsObject:[_currentLine valueForKey:@"line"]]) {
                        NSString *newLine = [(NSString *)[element valueForKey:@"line"] stringByAppendingString:[NSString stringWithFormat:@"|%@", [_currentLine valueForKey:@"line"] ] ];
                        [element setValue: newLine forKey:@"line"];
                    }

                    break;
                }
            }
            if (addMe) {
                [_currentLine setValue:rbl forKey:@"rbl"]; 
                [arrayOfStegs addObject:_currentLine];
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
@property (retain) NSMutableSet *allLines;

@end

@implementation StationDelegate {
    
    
    NSMutableArray *_array;
    //NSString *stationid;
    NSMutableDictionary *_currentLine;
    BOOL firstLineDone;
    NSRegularExpression *numberFinder;

}

- (void)parserDidBeginDocument:(CHCSVParser *)parser {
    _array = [[NSMutableArray alloc] init];
    self.allLines = [[NSMutableSet alloc] init];
    if (!numberFinder) {
        numberFinder = [[NSRegularExpression alloc] initWithPattern:@"[0-9]+" options:0 error:nil];
    }
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

- (NSString *)prependForSort:(NSString *)a
{
    
    // undetermined order for 11A and 11B
    NSString *preAppend= @"";
    NSTextCheckingResult *temp = [numberFinder firstMatchInString:a options:0 range:NSMakeRange(0, [a length])];
    NSInteger extractedNumber = 0;
    if (temp) {
        extractedNumber = [[a substringWithRange:temp.range] integerValue];
    }
    if ([a rangeOfString:@"U"].length > 0) {
        preAppend = @"A"; //UBAHN
    } else if ([a rangeOfString:@"N"].length > 0) {
        preAppend = @"F"; //night line
    } else if (([a rangeOfString:@"A"].length < 1 && [a rangeOfString:@"B"].length < 1) && a.length < 3) {
        preAppend = @"C"; //BIM
    } else if ([a rangeOfString:@"WLB"].length > 0) {
        preAppend = @"D"; //BADNERBAHN
    } else if ([a rangeOfString:@"A"].length > 0 || [a rangeOfString:@"B"].length > 0) {
        preAppend = @"E"; //BUS
    } else {
        preAppend = @"G";
    }
    return [NSString stringWithFormat:@"%@%05ld", preAppend, (long)extractedNumber];
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
        NSMutableSet *relatedLinesSet = [NSMutableSet setWithCapacity:2];
        for (NSMutableDictionary *element in platforms) {
            NSArray *array = [[element valueForKey:@"line"] componentsSeparatedByString:@"|"];
            [relatedLinesSet addObjectsFromArray:array];
            [self.allLines addObjectsFromArray:array];
        }
        
        NSArray *orderedLines = [[relatedLinesSet allObjects] sortedArrayUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
            return [[self prependForSort:obj1] compare:[self prependForSort:obj2]];
        }];
        NSString *relatedLines = [orderedLines componentsJoinedByString:@"|"];
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

- (NSString *) cleanName: (NSString *) name {
    if ([name containsString:@", "]) {
        name = [name componentsSeparatedByString:@", "][1];
    }
    return [[[name stringByReplacingOccurrencesOfString:@"str." withString:@"strasse"] stringByReplacingOccurrencesOfString:@"Str." withString:@"Strasse"] stringByReplacingOccurrencesOfString:@"g." withString:@"gasse"];
}
- (NSDictionary *) generateStationsWitDictionaryFrom: (NSArray *) arrayOfStations {
    
    NSMutableArray *values = [NSMutableArray array];
    // we need to split stations and fix names first
    
    NSMutableSet *actualStations = [NSMutableSet set];
    
    [arrayOfStations enumerateObjectsUsingBlock:^(NSDictionary *station, NSUInteger idx, BOOL *stop) {
        NSArray *arrayOfStations = [station[@"name"] componentsSeparatedByString:@"/"];
        for (NSString *station in arrayOfStations) {
            [actualStations addObject:[self cleanName: station]];
        }
    }];
    
    [actualStations enumerateObjectsUsingBlock:^(NSString *obj, BOOL *stop) {
        [values addObject:@{@"value":obj, @"expressions":@[obj]}];

    }];/*
    [actualStations enumerateObjectsUsingBlock:^(NSDictionary *station, NSUInteger idx, BOOL *stop) {
        [values addObject:@{@"value":station[@"name"], @"expressions":@[station[@"name"]]}];
    }];
    */
    return @{@"values": values};
}

- (NSDictionary *) generateLinesWitDictionaryFrom: (NSArray *) arrayOfLines {
    
    NSMutableArray *values = [NSMutableArray array];
    [arrayOfLines enumerateObjectsUsingBlock:^(NSString *line, NSUInteger idx, BOOL *stop) {
        [values addObject:@{@"value":line, @"expressions":@[line]}];
    }];
    
    return @{@"values": values};
}



- (IBAction)buttonPushed:(id)sender {
    
    //open linien file and generate dict
    
    NSOpenPanel *linienPanel = [NSOpenPanel openPanel];
    linienPanel.title = @"Please open the lines/linien CSV file...";
    
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
        stegPanel.title = @"Please open the platform/steig CSV file...";
        
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
            stationPanel.title = @"Please open the station/haltestellen CSV file...";
            
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
                self.textView.string = @"Done. Check your desktop for wl.json";
                
                NSDictionary *testDict = [self generateLinesWitDictionaryFrom:[stationDelegate.allLines allObjects]];
                //NSLog(@"all lines: %@", testDict);
                
                NSData *dataWitLines = [NSJSONSerialization dataWithJSONObject:testDict
                                                                       options:kNilOptions
                                                                         error:nil];
                [dataWitLines writeToFile:[@"~/Desktop/witWLLines.json" stringByExpandingTildeInPath] atomically:YES];
                
                NSDictionary *stationsWitDict = [self generateStationsWitDictionaryFrom:stationDelegate.array];
                
                NSData *dataWitStations = [NSJSONSerialization dataWithJSONObject:stationsWitDict
                                                                       options:kNilOptions
                                                                         error:nil];
                [dataWitStations writeToFile:[@"~/Desktop/witWLStations.json" stringByExpandingTildeInPath] atomically:YES];
                
            }
            
        }
        
        

    }
    
    //open steg file and generate dict
    
    //open station file and generate array
}

@end
