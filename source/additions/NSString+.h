#define kEllipsis @"\u2026"

@interface NSString (XML)
+ (BOOL)exists:(NSString *)string;
- (NSString *) stringByDecodingXMLEntities;
- (NSString *) condenseString;
@end
