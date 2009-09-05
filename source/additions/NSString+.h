#define kEllipsis @"\u2026"

@interface NSString (XML)
- (NSString *) stringByDecodingXMLEntities;
- (NSString *) condenseString;
@end
