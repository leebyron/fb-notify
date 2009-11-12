
#import "NSString+.h"

@implementation NSString (XML)

+ (BOOL)exists:(id)string
{
  return string != nil &&
         [string isKindOfClass:[NSString class]] &&
         [string respondsToSelector:@selector(length)] &&
         [string length] > 0;
}

- (NSString*)trim {
  return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (NSString*)stringByDecodingXMLEntities {
  if (![NSString exists:self]) {
    return [NSString stringWithString:@""];
  }
  NSUInteger myLength = [self length];
  NSUInteger ampIndex = [self rangeOfString:@"&" options:NSLiteralSearch].location;

  // Short-circuit if there are no ampersands.
  if (ampIndex == NSNotFound) {
    return self;
  }
  // Make result string with some extra capacity.
  NSMutableString *result = [NSMutableString stringWithCapacity:(myLength * 1.25)];

  // First iteration doesn't need to scan to & since we did that already, but for code simplicity's sake we'll do it again with the scanner.
  NSScanner *scanner = [NSScanner scannerWithString:self];
  [scanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@""]];
  do {
    // Scan up to the next entity or the end of the string.
    NSString *nonEntityString;
    if ([scanner scanUpToString:@"&" intoString:&nonEntityString]) {
      [result appendString:nonEntityString];
    }
    if ([scanner isAtEnd]) {
      goto finish;
    }
    // Scan either a HTML or numeric character entity reference.
    if ([scanner scanString:@"&amp;" intoString:NULL])
      [result appendString:@"&"];
    else if ([scanner scanString:@"&apos;" intoString:NULL])
      [result appendString:@"'"];
    else if ([scanner scanString:@"&quot;" intoString:NULL])
      [result appendString:@"\""];
    else if ([scanner scanString:@"&lt;" intoString:NULL])
      [result appendString:@"<"];
    else if ([scanner scanString:@"&gt;" intoString:NULL])
      [result appendString:@">"];
    else if ([scanner scanString:@"&#" intoString:NULL]) {
      BOOL gotNumber;
      unsigned charCode;
      NSString *xForHex = @"";

      // Is it hex or decimal?
      if ([scanner scanString:@"x" intoString:&xForHex]) {
        gotNumber = [scanner scanHexInt:&charCode];
      }
      else {
        gotNumber = [scanner scanInt:(int*)&charCode];
      }
      if (gotNumber) {
        [result appendFormat:@"%C", charCode];
      }
      else {
        NSString *unknownEntity = @"";
        [scanner scanUpToCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@";& "] intoString:&unknownEntity];
        [result appendFormat:@"&#%@%@;", xForHex, unknownEntity];
        //NSLog(@"Expected numeric character entity but got &#%@%@;", xForHex, unknownEntity);
      }
      [scanner scanString:@";" intoString:NULL];
    }
    else {
      [scanner scanString:@"&" intoString:NULL];
      NSString *unknownEntity = @"";
      [scanner scanUpToCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@";& "] intoString:&unknownEntity];
      NSString *semicolon = @"";
      [scanner scanString:@";" intoString:&semicolon];
      [result appendFormat:@"&%@%@", unknownEntity, semicolon];
      //NSLog(@"Unsupported XML character entity &%@%@", unknownEntity, semicolon);
    }
  }
  while (![scanner isAtEnd]);

finish:
  return result;
}

- (NSString*)condenseString
{
  return [[[self stringByReplacingOccurrencesOfString:@" ..." withString:kEllipsis]
                 stringByReplacingOccurrencesOfString:@"..." withString:kEllipsis]
                 stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
}

- (NSString*)stringByRemovingStrings:(NSArray*)list
{
  NSString* trimmed = self;
  for (NSString* item in list) {
    trimmed = [trimmed stringByReplacingOccurrencesOfString:item withString:@""];
  }
  return trimmed;
}

@end
