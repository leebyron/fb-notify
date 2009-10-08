#define kEllipsis @"\u2026"

@interface NSString (XML)
+ (BOOL)exists:(id)string;
- (NSString *) stringByDecodingXMLEntities;
- (NSString *) condenseString;
@end
