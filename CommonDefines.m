#define RESET   "\033[0m"
#define BOLDWHITE   "\033[1m\033[37m"  
#define CLEARSCREEN "\e[1;1H\e[2J"

#include <stdio.h>
#include <dlfcn.h>
#include <dirent.h>
#include <limits.h>
#include <sys/stat.h>
#include <sys/mman.h>
#include <sys/sysctl.h>
#include <mach-o/dyld.h>
#include <objc/runtime.h>
#include <mach-o/nlist.h>
#include <mach-o/dyld_images.h>

static BOOL addHeadersFolder=NO;
static BOOL shouldImportStructs=0;
static NSMutableArray *allStructsFound=nil;
static NSMutableArray *classesInStructs=nil;
static NSMutableArray *classesInClass=nil;
static NSMutableArray *processedImages=nil;
NSString *classID=nil;
NSString *onlyOneClass=nil;

@interface NSArray (extras)
-(id)reversedArray;
@end


const struct dyld_all_image_infos *dyld_all_image_infos;
//extern "C" struct dyld_all_image_infos* _dyld_get_all_image_infos();
NSString * propertyLineGenerator(NSString *attributes,NSString *name);
NSString * commonTypes(NSString *atype,NSString **inName,BOOL inIvarList);


