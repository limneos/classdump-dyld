/*	
	classdump-dyld is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    any later version.

    classdump-dyld is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.
*/

static BOOL inDebug=NO;
#define CDLog(...) if (inDebug)NSLog(@"classdump-dyld : %@", [NSString stringWithFormat:__VA_ARGS__] )

#include "CommonDefines.m"

extern "C" int parseImage(char *image,BOOL writeToDisk,NSString *outputDir,BOOL getSymbols,BOOL isRecursive,BOOL buildOriginalDirs,BOOL simpleHeader,BOOL skipAlreadyFound,BOOL skipApplications);

static void list_dir(const char *dir_name,BOOL writeToDisk,NSString *outputDir,BOOL getSymbols,BOOL recursive,BOOL simpleHeader,BOOL skipAlreadyFound,BOOL skipApplications);
static NSMutableArray *allImagesProcessed;
static uint8_t *_cacheData;
static struct cache_header *_cacheHead;
static BOOL shouldDLopen32BitExecutables=NO;

 
/****** Helper Functions ******/
#include "CommonFunctions.m"

/****** Parsing Functions ******/
#include "ParsingFunctions.m"


/****** Recursive file search ******/

static void list_dir(const char *dir_name,BOOL writeToDisk,NSString *outputDir,BOOL getSymbols,BOOL recursive,BOOL simpleHeader,BOOL skipAlreadyFound,BOOL skipApplications){
	
	DIR * d;
	d = opendir (dir_name);

	if (! d) {
		return;
	}
	
	while (1) {
		
		struct dirent * entry;
		const char * d_name;

		entry = readdir (d);
		if (! entry) {
			break;
		}
		while (entry && entry->d_type == DT_LNK){
			entry = readdir (d);
		
		}
		if (! entry) {
				break;
		}
		
		printf("  Scanning dir: %s...",dir_name); 
    	printf("\n\033[F\033[J");
    
		while  (entry && (entry->d_type & DT_DIR) && ( locationOfString(dir_name,[outputDir UTF8String])==0 ||  ((locationOfString(dir_name,"/private/var")==0  || locationOfString(dir_name,"/var")==0 || locationOfString(dir_name,"//var")==0 || locationOfString(dir_name,"//private/var")==0) && (skipApplications || (!skipApplications && !strstr(dir_name,"Application")))) || locationOfString(dir_name,"//dev")==0 || locationOfString(dir_name,"//bin")==0 ||  locationOfString(dir_name,"/dev")==0 || locationOfString(dir_name,"/bin")==0 )) {
			entry = readdir (d);
		}

		
		if (! entry) {
			break;
		}
		d_name = entry->d_name;
		
		if (strcmp(d_name,".") && strcmp(d_name,"..")){
		
			NSAutoreleasePool *p=[[NSAutoreleasePool alloc] init];
			NSString *currentPath=[NSString stringWithCString:dir_name encoding:NSUTF8StringEncoding];
			currentPath=[currentPath stringByReplacingOccurrencesOfString:@"//" withString:@"/"];
			NSString *currentFile=[NSString stringWithCString:d_name encoding:NSUTF8StringEncoding];
			NSString *imageToPass=[NSString stringWithFormat:@"%@/%@",currentPath,currentFile];
			
			if ([imageToPass rangeOfString:@"classdump-dyld"].location==NSNotFound && [imageToPass rangeOfString:@"/dev"].location!=0 && [imageToPass rangeOfString:@"/bin"].location!=0){
			
				NSString *imageWithoutLastPart=[imageToPass stringByDeletingLastPathComponent];
			
				if ([[imageWithoutLastPart lastPathComponent] rangeOfString:@".app"].location!=NSNotFound  || [[imageWithoutLastPart lastPathComponent] rangeOfString:@".framework"].location!=NSNotFound || [[imageWithoutLastPart lastPathComponent] rangeOfString:@".bundle"].location!=NSNotFound){
					NSString *skipString=[imageWithoutLastPart lastPathComponent]; 
					//skipString=[skipString stringByDeletingPathExtension];
					skipString=[skipString stringByReplacingOccurrencesOfString:@".framework" withString:@""];
					skipString=[skipString stringByReplacingOccurrencesOfString:@".bundle" withString:@""];
					skipString=[skipString stringByReplacingOccurrencesOfString:@".app" withString:@""];
					
					if ([skipString isEqualToString:[imageToPass lastPathComponent]]){
						parseImage((char *)[imageToPass UTF8String ],writeToDisk,outputDir,getSymbols,recursive,YES,simpleHeader,skipAlreadyFound,skipApplications);

					}
			
				}
			
				else{

					parseImage((char *)[imageToPass UTF8String ],writeToDisk,outputDir,getSymbols,recursive,YES,simpleHeader,skipAlreadyFound,skipApplications);	
				}
			}
			
			[p drain];
		}

		if (entry->d_type & DT_DIR ) {

			if (strcmp(d_name, "..")!= 0 && strcmp(d_name, ".")!=0) {

				int path_length;
				char path[PATH_MAX];

				path_length = snprintf (path, PATH_MAX,"%s/%s", dir_name, d_name);

				if (path_length >= PATH_MAX) {
					//Path length has gotten too long
					exit (EXIT_FAILURE);
				}

				list_dir (path,writeToDisk,outputDir,getSymbols,recursive,simpleHeader,skipAlreadyFound,skipApplications);
			}
		}
	}

	closedir (d);

}



/****** The actual job ******/

extern "C" int parseImage(char *image,BOOL writeToDisk,NSString *outputDir,BOOL getSymbols,BOOL isRecursive,BOOL buildOriginalDirs,BOOL simpleHeader, BOOL skipAlreadyFound,BOOL skipApplications){


	if (!image){
		return 3;
	}
	
	// applications are skipped by default in a recursive, you can use -a to force-dump them recursively
	if (skipApplications){
		if (isRecursive && strstr(image,"/var/stash/Applications/")){ //skip Applications dir
			return 4;
		}

		if (isRecursive && strstr(image,"/var/mobile/Applications/")){ //skip Applications dir
			return 4;
		}
		if (isRecursive && strstr(image,"/var/mobile/Containers/Bundle/Application/")){ //skip Applications dir
			return 4;
		}
	}

	
	NSString *imageAsNSString=[[NSString alloc] initWithCString:image encoding:NSUTF8StringEncoding];
	for (NSString *forbiddenPath in forbiddenPaths){
		if ([imageAsNSString rangeOfString:forbiddenPath].location!=NSNotFound){
			NSLog(@"Image %@ cannot be parsed due to know crashing issues.",imageAsNSString);
			[imageAsNSString release];
			return 4;
		}
	}
		
	[imageAsNSString release];
	
	
	
	NSAutoreleasePool *xd=[[NSAutoreleasePool alloc] init];
	if (isRecursive && ([[NSString stringWithCString:image encoding:NSUTF8StringEncoding] rangeOfString:@"/dev"].location==0 || [[NSString stringWithCString:image encoding:NSUTF8StringEncoding] rangeOfString:@"/bin"].location==0 || (skipApplications && [[NSString stringWithCString:image encoding:NSUTF8StringEncoding] rangeOfString:@"/var"].location==0))){
		[xd drain];
		return 4;
	}
	[xd drain];
	
	
	NSAutoreleasePool *xdd=[[NSAutoreleasePool alloc] init];
	
	
	if ([allImagesProcessed containsObject:[NSString stringWithCString:image encoding:NSUTF8StringEncoding]]){
		[xdd drain];
		return 5;
	}

	NSString *imageEnd=[[NSString stringWithCString:image encoding:NSUTF8StringEncoding] lastPathComponent];
	imageEnd=[imageEnd stringByReplacingOccurrencesOfString:@".framework/" withString:@""];
	imageEnd=[imageEnd stringByReplacingOccurrencesOfString:@".framework" withString:@""];
	imageEnd=[imageEnd stringByReplacingOccurrencesOfString:@".bundle/" withString:@""];
	imageEnd=[imageEnd stringByReplacingOccurrencesOfString:@".bundle" withString:@""];
	imageEnd=[imageEnd stringByReplacingOccurrencesOfString:@".app/" withString:@""];
	imageEnd=[imageEnd stringByReplacingOccurrencesOfString:@".app" withString:@""];
	NSString *containedImage=[[NSString stringWithCString:image encoding:NSUTF8StringEncoding] stringByAppendingString:[NSString stringWithFormat:@"/%@",imageEnd]];

	if ([allImagesProcessed containsObject:containedImage]){
		[xdd drain];
		return 5;
	}
	[xdd drain];


	// check if image is executable
	dlopen_preflight(image);
	BOOL isExec=NO;
	if (dlerror()){
		if (fileExistsOnDisk(image)){
			 isExec=isMachOExecutable(image);
		}
	}
	
	
	void * ref=nil;
	BOOL opened=dlopen_preflight(image);
	const char *dlopenError=dlerror();
	if (opened){
		CDLog(@"Will dlopen %s",image);
		ref=dlopen(image,  RTLD_LAZY );
		CDLog(@"Did dlopen %s",image);
	}
	else{

		if (!isExec || shouldDLopen32BitExecutables){

			if (!dlopenError || (dlopenError && !strstr(dlopenError,"no matching architecture in universal wrapper") && !strstr(dlopenError,"out of address space") && !strstr(dlopenError,"mach-o, but wrong architecture"))){
				NSAutoreleasePool *pool=[[NSAutoreleasePool alloc] init];
				NSString *imageString=[[NSString alloc] initWithCString:image encoding:NSUTF8StringEncoding];
				NSString *lastComponent=[imageString lastPathComponent];

				if ([lastComponent rangeOfString:@".framework"].location==NSNotFound && [lastComponent rangeOfString:@".bundle"].location==NSNotFound && [lastComponent rangeOfString:@".app"].location==NSNotFound){
					if (!isRecursive){	
						dlopen_preflight(image);
						printf("\nNot a suitable image: %s\n(%s)\n",image,dlerror());
					}
					return 3;		
				}
				NSBundle *loadedBundle=[NSBundle bundleWithPath:imageString];
				[imageString release];
				[pool drain];
				char *exec=(char *)[[loadedBundle executablePath] UTF8String];
				image=(char *)exec;
				if (image){

					if (!dlopen_preflight(image)){
						// cleanup dlerror:
						dlerror();
						isExec=isMachOExecutable(image);
					}
					//opened=dlopen_preflight(image);
					opened=dlopen_preflight([[loadedBundle executablePath] UTF8String]);
					dlopenError=dlerror();
				}
				else{
					opened=NO;
				}
				if (opened && (!isExec || shouldDLopen32BitExecutables)){
					ref=dlopen(image,  RTLD_LAZY);
				}
			}
		
		}
	}

	if (image!=nil && ![allImagesProcessed containsObject:[NSString stringWithCString:image encoding:2]] && ((dlopenError && (strstr(dlopenError,"no matching architecture in universal wrapper") || strstr(dlopenError,"out of address space") || strstr(dlopenError,"mach-o, but wrong architecture"))) || (isExec && !shouldDLopen32BitExecutables))){
		@autoreleasepool{

			/*if (fileExistsOnDisk(image) && isExec){
				NSString *exec=[NSString stringWithFormat:@"/usr/bin/ldid -e %s > /tmp/entitlements/%@",image,[[NSString stringWithCString:image encoding:NSUTF8StringEncoding] lastPathComponent]];
				system([exec UTF8String]);
			}*/

			#if defined (__x86_64__) || defined (__i386__)
				NSString *tryWithLib=[NSString stringWithFormat:@"DYLD_INSERT_LIBRARIES=/usr/local/lib/libclassdumpdyld.dylib %s",image];
			#else
				NSString *tryWithLib=[NSString stringWithFormat:@"DYLD_INSERT_LIBRARIES=/usr/lib/libclassdumpdyld.dylib %s",image];
			#endif			
			

			if (writeToDisk){
				tryWithLib=[tryWithLib stringByAppendingString:[NSString stringWithFormat:@" -o %@",outputDir]];
			}
			if (buildOriginalDirs){
				tryWithLib=[tryWithLib stringByAppendingString:@" -b"];
			}
			if (getSymbols){
				tryWithLib=[tryWithLib stringByAppendingString:@" -g"];
			}
			if (simpleHeader){
				tryWithLib=[tryWithLib stringByAppendingString:@" -u"];
			}
			if (addHeadersFolder){
				tryWithLib=[tryWithLib stringByAppendingString:@" -h"];
			}
			if (inDebug){
				tryWithLib=[tryWithLib stringByAppendingString:@" -D"];
			}
			if (isRecursive){
				tryWithLib=[tryWithLib stringByAppendingString:@" -r"];
			}
			if (onlyOneClass){
				tryWithLib=[tryWithLib stringByAppendingString:[NSString stringWithFormat:@" -j %@",onlyOneClass]];
			}

			[allImagesProcessed addObject:[NSString stringWithCString:image encoding:2]];
			system([tryWithLib UTF8String]);
		}
		if (!isRecursive){
			return 1;
		}
	}

	if (!opened || ref==nil || image==NULL){
		if (!isRecursive){
			printf("\nCould not open: %s\n",image);
		}
		return 3;
	}
 	
 	if (image!=nil && [allImagesProcessed containsObject:[NSString stringWithCString:image encoding:2]]){
		return 5;
	}
	
	
	
	CDLog(@"Dlopen complete, proceeding with class info for %s",image);
	// PROCEED
	BOOL isFramework=NO;
	NSMutableString *dumpString=[[NSMutableString alloc] initWithString:@""];
	unsigned int count;	
	CDLog(@"Getting class count for %s",image);
	const char **names = objc_copyClassNamesForImage(image,&count);
	CDLog(@"Did return class count %d",count);
	if (count){
		printf("  Dumping "BOLDWHITE"%s"RESET"...(%d classes) %s \n",image ,count,[print_free_memory() UTF8String]);
	}	

	while ([outputDir rangeOfString:@"/" options:NSBackwardsSearch].location==outputDir.length-1){
		outputDir=[outputDir substringToIndex:outputDir.length-1];
	}
	
	BOOL hasWrittenCopyright=NO;
	allStructsFound=nil;
	allStructsFound=[NSMutableArray array];
	classesInStructs=nil;
	classesInStructs=[NSMutableArray array];
	
	
	NSMutableArray *protocolsAdded=[NSMutableArray array];
	
	NSString *imageName=[[NSString stringWithCString:image encoding:NSUTF8StringEncoding] lastPathComponent];
	NSString *fullImageNameInNS=[NSString stringWithCString:image encoding:NSUTF8StringEncoding];
	[allImagesProcessed addObject:fullImageNameInNS];
	
	NSString *seeIfIsBundleType=[fullImageNameInNS stringByDeletingLastPathComponent]; 
	NSString *lastComponent=[seeIfIsBundleType lastPathComponent];
	NSString *targetDir=nil;
	if ([lastComponent rangeOfString:@"."].location==NSNotFound){
		targetDir=fullImageNameInNS;
		
	}
	else{
		targetDir=[fullImageNameInNS stringByDeletingLastPathComponent];
		isFramework=YES;		
	}
	NSString *headersFolder=addHeadersFolder ? @"/Headers" : @"";
	NSString *writeDir=buildOriginalDirs ? (isFramework ? [NSString stringWithFormat:@"%@/%@%@",outputDir,targetDir,headersFolder] : [NSString stringWithFormat:@"%@/%@",outputDir,targetDir])  : outputDir;
	writeDir=[writeDir stringByReplacingOccurrencesOfString:@"///" withString:@"/"];
	writeDir=[writeDir stringByReplacingOccurrencesOfString:@"//" withString:@"/"];
	
	[processedImages addObject:[NSString stringWithCString:image encoding:NSUTF8StringEncoding]];
	CDLog(@"Beginning class loop (%d classed) for %s",count,image);
	NSMutableString *classesToImport=[[NSMutableString alloc] init];
	
	int actuallyProcesssedCount=0;
	
	for (unsigned i=0; i<count; i++){

		NSAutoreleasePool *pool=[[NSAutoreleasePool alloc] init];
		
		classesInClass=nil;
		classesInClass=[NSMutableArray array];
		NSMutableArray *inlineProtocols=[NSMutableArray array];
		shouldImportStructs=0;
		if (skipAlreadyFound && [[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@/%s.h",writeDir,names[i]]]){
			continue;
		}

		BOOL canGetSuperclass=YES;
		NSString *classNameNSToRelease=[[NSString alloc] initWithCString:names[i] encoding:NSUTF8StringEncoding];

		if ([forbiddenClasses indexOfObject:classNameNSToRelease]!=NSNotFound){
			[classNameNSToRelease release];
			continue;
		}
		
		if (onlyOneClass && ![classNameNSToRelease isEqual:onlyOneClass]){
			[classNameNSToRelease release];
			continue;
		}
		
		[classNameNSToRelease release];
		
		actuallyProcesssedCount++;
		
		CDLog(@"Processing Class %s\n",names[i]);
		
		if (writeToDisk){
			loadBar(i, count, 100, 50,names[i]);   
		}
			
		
		NSString *classNameNS=[NSString stringWithCString:names[i] encoding:NSUTF8StringEncoding];
		while ([classNameNS rangeOfString:@"_"].location==0){

			classNameNS=[classNameNS substringFromIndex:1];
		}
		classID=[classNameNS substringToIndex:2];
		Class currentClass=nil;
	
		currentClass=objc_getClass(names[i]);
		
		if ( ! class_getClassMethod(currentClass,NSSelectorFromString(@"doesNotRecognizeSelector:") )){
			canGetSuperclass=NO;
		}
		
		if ( ! class_getClassMethod(currentClass,NSSelectorFromString(@"methodSignatureForSelector:") )){
			canGetSuperclass=NO;
		}
		

				
		if (strcmp((char *)image,(char *)"/System/Library/CoreServices/SpringBoard.app/SpringBoard")==0){
			
			[currentClass class]; //init a class instance to prevent crashes, specifically needed for some SpringBoard classes
		}
		
		NSString *superclassString=canGetSuperclass ? ([[currentClass superclass] description] !=nil ? [NSString stringWithFormat:@" : %@",[[currentClass superclass] description]] : @"") : @" : _UKNOWN_SUPERCLASS_";
		
		
		unsigned int protocolCount;
		Protocol ** protocolArray=class_copyProtocolList(currentClass, &protocolCount);
		NSString *inlineProtocolsString=@"";
		for (unsigned t=0; t<protocolCount; t++){
			if (t==0){
				inlineProtocolsString=@" <";
			}
			const char *protocolName=protocol_getName(protocolArray[t]);
			
			NSString *addedProtocol=[[NSString stringWithCString:protocolName encoding:NSUTF8StringEncoding] retain];
			if (t<protocolCount-1){
				addedProtocol=[[[addedProtocol autorelease] stringByAppendingString:@", "] retain];
			}
			inlineProtocolsString=[[[inlineProtocolsString autorelease]  stringByAppendingString:addedProtocol] retain];
			if (t==protocolCount-1){
				inlineProtocolsString=[[[inlineProtocolsString autorelease] stringByAppendingString:@">"] retain] ;
			}
		}
		
		
		if ( writeToDisk || (!writeToDisk && !hasWrittenCopyright )){
			NSString *copyrightString=copyrightMessage(image);
			[dumpString appendString:copyrightString];
			[copyrightString release];
			hasWrittenCopyright=YES;
		}
		
		
		if (writeToDisk && superclassString.length>0 && ![superclassString isEqual:@" : NSObject"]){
			NSString *fixedSuperclass=[superclassString stringByReplacingOccurrencesOfString:@" : " withString:@""];
			NSString *importSuper=@"";
			if (!simpleHeader){
				NSString *imagePrefix=[imageName substringToIndex:2];

				NSString *superclassPrefix=[superclassString rangeOfString:@"_"].location==0 ? [[superclassString substringFromIndex:1] substringToIndex:2] : [superclassString substringToIndex:2];
				const char *imageNameOfSuper=[imagePrefix isEqual:superclassPrefix] ? [imagePrefix UTF8String] : class_getImageName(objc_getClass([fixedSuperclass UTF8String]));
				if (imageNameOfSuper){
					NSString *imageOfSuper=[NSString stringWithCString:imageNameOfSuper encoding:NSUTF8StringEncoding];
					imageOfSuper=[imageOfSuper lastPathComponent];	
					importSuper=[NSString stringWithFormat:@"#import <%@/%@.h>\n",imageOfSuper,fixedSuperclass];
				}
				
			}
			else{
				importSuper=[NSString stringWithFormat:@"#import \"%@.h\"\n",fixedSuperclass];
			}
			[dumpString appendString:importSuper];
		}
		
		
		for (unsigned d=0; d<protocolCount; d++){
			
			Protocol *protocol=protocolArray[d];
			const char *protocolName=protocol_getName(protocol);
			
			NSString *protocolNSString=[NSString stringWithCString:protocolName encoding:NSUTF8StringEncoding];
			if (writeToDisk){
				if (simpleHeader){
					[dumpString appendString:[NSString stringWithFormat:@"#import \"%@.h\"\n",protocolNSString]];
				}
				else{
					NSString *imagePrefix=[imageName substringToIndex:2];
					NSString *protocolPrefix=nil;
					NSString *imageOfProtocol=nil;

					protocolPrefix=[protocolNSString rangeOfString:@"_"].location==0 ? [[protocolNSString substringFromIndex:1] substringToIndex:2] : [protocolNSString substringToIndex:2];
					imageOfProtocol=([imagePrefix isEqual:protocolPrefix] || !class_getImageName(protocol) ) ? imageName : [NSString stringWithCString:class_getImageName(protocol) encoding:NSUTF8StringEncoding];
					imageOfProtocol=[imageOfProtocol lastPathComponent];
					
					if ([protocolNSString rangeOfString:@"UI"].location==0){
						imageOfProtocol=@"UIKit";
					}
					[dumpString appendString:[NSString stringWithFormat:@"#import <%@/%@.h>\n",imageOfProtocol,protocolNSString]];
				}

			}
			if ([protocolsAdded containsObject:protocolNSString]){
				continue;
			}
			[protocolsAdded addObject:protocolNSString];
			NSString *protocolHeader=buildProtocolFile(protocol);
			if (strcmp(names[i],protocolName)==0){
				[dumpString appendString:protocolHeader];

			}
			else{
				if (writeToDisk){
					NSString *copyrightString=copyrightMessage(image);
					protocolHeader=[copyrightString stringByAppendingString:protocolHeader] ;
					[copyrightString release];

					[[NSFileManager defaultManager] createDirectoryAtPath:writeDir withIntermediateDirectories:YES attributes:nil error:nil];
					
					
					if ( ![protocolHeader writeToFile:[NSString stringWithFormat:@"%@/%s.h",writeDir,protocolName] atomically:YES encoding:NSUTF8StringEncoding error:nil]){	
						printf("  Failed to save protocol header to directory \"%s\"\n",[writeDir UTF8String]);
					}
				}
				else{
					[dumpString appendString:protocolHeader];
					
				}
			}
			
		}			
		free(protocolArray);
		
		
		[dumpString appendString:[NSString stringWithFormat:@"\n@interface %s%@%@",names[i],superclassString,inlineProtocolsString]];
		// Get Ivars
		unsigned int ivarOutCount;
		Ivar * ivarArray=class_copyIvarList(currentClass, &ivarOutCount);
		if (ivarOutCount>0){	
			[dumpString appendString:@" {\n"];
			for (unsigned x=0;x<ivarOutCount;x++){
				Ivar currentIvar=ivarArray[x];
				const char * ivarName=ivar_getName(currentIvar);

				NSString *ivarNameNS=[NSString stringWithCString:ivarName encoding:NSUTF8StringEncoding];
				const char * ivarType=ivar_getTypeEncoding(currentIvar);

				NSString *ivarTypeString=commonTypes([NSString stringWithCString:ivarType encoding:NSUTF8StringEncoding],&ivarNameNS,YES);
			
				if ([ivarTypeString rangeOfString:@"@\""].location!=NSNotFound){
					ivarTypeString=[ivarTypeString stringByReplacingOccurrencesOfString:@"@\"" withString:@""];
					ivarTypeString=[ivarTypeString stringByReplacingOccurrencesOfString:@"\"" withString:@"*"];
					NSString *classFoundInIvars=[ivarTypeString stringByReplacingOccurrencesOfString:@"*" withString:@""];
					if (![classesInClass containsObject:classFoundInIvars]){
						

						if ([classFoundInIvars rangeOfString:@"<"].location!=NSNotFound ){

								int firstOpening=[classFoundInIvars rangeOfString:@"<"].location;
								if (firstOpening!=0){
									NSString *classToAdd=[classFoundInIvars substringToIndex:firstOpening];
									if (![classesInClass containsObject:classToAdd]){
										[classesInClass addObject:classToAdd];				
									}
								}

								NSString *protocolToAdd=[classFoundInIvars substringFromIndex:firstOpening];
								protocolToAdd=[protocolToAdd stringByReplacingOccurrencesOfString:@"<" withString:@""];
								protocolToAdd=[protocolToAdd stringByReplacingOccurrencesOfString:@">" withString:@""];
								protocolToAdd=[protocolToAdd stringByReplacingOccurrencesOfString:@"*" withString:@""];
								if (![inlineProtocols containsObject:protocolToAdd]){	
									[inlineProtocols addObject:protocolToAdd];
								}
							
						}
						else{
							[classesInClass addObject:classFoundInIvars];
						}
					}
					if ([ivarTypeString rangeOfString:@"<"].location!=NSNotFound){
						ivarTypeString=[ivarTypeString stringByReplacingOccurrencesOfString:@">*" withString:@">"];
						if ([ivarTypeString rangeOfString:@"<"].location==0){
							ivarTypeString=[@"id" stringByAppendingString:ivarTypeString];
						}
						else{
							ivarTypeString=[ivarTypeString stringByReplacingOccurrencesOfString:@"<" withString:@"*<"];			
						}
					}
				}

				NSString *formatted=[NSString stringWithFormat:@"\n\t%@ %@;",ivarTypeString,ivarNameNS];
				[dumpString appendString:formatted];
				
			}
			[dumpString appendString:@"\n\n}"];
			
		}
		free(ivarArray);
		
		if ([inlineProtocols count]>0){
			
			NSMutableString *inlineProtocolsString=[[NSMutableString alloc] init];
			[inlineProtocolsString appendString:@"@protocol "];
			for (int g=0; g<inlineProtocols.count; g++){
				if (g<inlineProtocols.count-1){
					[inlineProtocolsString appendString:[NSString stringWithFormat:@"%@, ",[inlineProtocols objectAtIndex:g]]];
				}
				else{
					[inlineProtocolsString appendString:[NSString stringWithFormat:@"%@;\n",[inlineProtocols objectAtIndex:g]]];
				}
			}
			int interfaceLocation=[dumpString rangeOfString:@"@interface"].location;
			[dumpString insertString:inlineProtocolsString atIndex:interfaceLocation];
			[inlineProtocolsString release];
		}
		
		
		// Get Properties
		unsigned int propertiesCount;
		NSString *propertiesString=@"";
		objc_property_t *propertyList=class_copyPropertyList(currentClass,&propertiesCount);
		
		for (unsigned int b=0; b<propertiesCount; b++){
	
			const char *propname=property_getName(propertyList[b]);
			const char *attrs=property_getAttributes(propertyList[b]);
			
			NSString *newString=propertyLineGenerator([NSString stringWithCString:attrs encoding:NSUTF8StringEncoding],[NSString stringWithCString:propname encoding:NSUTF8StringEncoding]);
			if ([propertiesString rangeOfString:newString].location==NSNotFound){
				propertiesString= [[[propertiesString autorelease] stringByAppendingString:newString] retain];
			}
			[[newString autorelease] retain];
		}
		free(propertyList);
		
		
		
		// Fix synthesize locations
		int propLenght=[propertiesString length];
		NSMutableArray *synthesized=[[propertiesString componentsSeparatedByString:@"\n"] mutableCopy];
		int longestLocation=0;
		for (NSString *string in synthesized){
		
			string=[string stringByReplacingOccurrencesOfString:@"\t" withString:@""];
			string=[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
			int location=[string rangeOfString:@";"].location;
			if ([string rangeOfString:@";"].location==NSNotFound){
				continue;
			}
			if (location>longestLocation){
				longestLocation=location;
			}
		
		}
		
		NSMutableArray *newStrings=[NSMutableArray array];
		for (NSString *string in synthesized){
			int synthesizeLocation=[string rangeOfString:@"//@synth"].location;
			if ([string rangeOfString:@"//@synth"].location==NSNotFound){
				[newStrings addObject:string];
				continue;
			}

			NSString *copyString=[string substringFromIndex:synthesizeLocation];
			int location=[string rangeOfString:@";"].location;
			string=[string substringToIndex:location+1];
			string=[string stringByPaddingToLength:longestLocation+15 withString:@" " startingAtIndex:0];
			string=[string stringByAppendingString:copyString];
			[newStrings addObject:string];
		}
		if (propLenght>0){
			propertiesString=[@"\n" stringByAppendingString:[newStrings componentsJoinedByString:@"\n"]];
		}
		
		// Gather All Strings
		[dumpString appendString:propertiesString];
		[dumpString appendString:[generateMethodLines(object_getClass(currentClass),NO,nil) autorelease]];		
		[dumpString appendString:[generateMethodLines(currentClass,YES,propertiesArrayFromString(propertiesString)) autorelease]];
		[dumpString appendString:@"\n@end\n\n"];
		
		
		
		

		if (shouldImportStructs && writeToDisk){
			int firstImport=[dumpString rangeOfString:@"#import"].location!=NSNotFound ? [dumpString rangeOfString:@"#import"].location : [dumpString rangeOfString:@"@interface"].location;
			NSString *structImport=simpleHeader ? [NSString stringWithFormat:@"#import \"%@-Structs.h\"\n",imageName] : [NSString stringWithFormat:@"#import <%@/%@-Structs.h>\n",imageName,imageName];
			[dumpString insertString:structImport atIndex:firstImport];
			
		}
		
		if (writeToDisk && [classesInClass count]>0){
			
			[classesInClass removeObject:[NSString stringWithCString:names[i] encoding:NSUTF8StringEncoding]];
			if ([classesInClass count]>0){
				int firstInteface=[dumpString rangeOfString:@"@interface"].location;
				NSMutableString *classesFoundToAdd=[[NSMutableString alloc] init];
				[classesFoundToAdd appendString:@"@class "];
				for (int f=0; f<classesInClass.count; f++){
					NSString *classFound=[classesInClass objectAtIndex:f];
					if (f<classesInClass.count-1){
						[classesFoundToAdd appendString:[NSString stringWithFormat:@"%@, ",classFound]];
					}
					else{
						[classesFoundToAdd appendString:[NSString stringWithFormat:@"%@;",classFound]];
					}
				}
				[classesFoundToAdd appendString:@"\n\n"];
				[dumpString insertString:classesFoundToAdd atIndex:firstInteface];	
				[classesFoundToAdd release];		
			}
		}
		
		// Write strings to disk or print out
		NSError *writeError;
		if (writeToDisk){
			
			[[NSFileManager defaultManager] createDirectoryAtPath:writeDir withIntermediateDirectories:YES attributes:nil error:nil];
			NSString *fileToWrite=[NSString stringWithCString:names[i] encoding:NSUTF8StringEncoding];

			if ([[NSString stringWithCString:names[i] encoding:NSUTF8StringEncoding] isEqual:[[NSString stringWithCString:image encoding:NSUTF8StringEncoding] lastPathComponent]]){
				fileToWrite=[[NSString stringWithCString:names[i] encoding:NSUTF8StringEncoding] stringByAppendingString:@"-Class"];
			}

			if ( ![dumpString writeToFile:[NSString stringWithFormat:@"%@/%@.h",writeDir,fileToWrite] atomically:YES encoding:NSUTF8StringEncoding error:&writeError]){	
				printf("  Failed to save to directory \"%s\"\n",[writeDir UTF8String]);
				exit(1);
				if (writeError!=nil){
					printf("  %s\n",[[writeError description] UTF8String]);
				}
				break;
			}
		}
		else{
			printf("%s\n\n",[dumpString UTF8String]);
			
		}
		if (writeToDisk){
			NSString *importStringFrmt=simpleHeader ? [NSString stringWithFormat:@"#import \"%s.h\"\n",names[i]] : [NSString stringWithFormat:@"#import <%@/%s.h>\n",imageName,names[i]];
			[classesToImport appendString:importStringFrmt];
		}

		objc_destructInstance(currentClass);

		[dumpString release];
		dumpString=[[NSMutableString alloc] init];
		[pool drain];

	} 
	// END OF PER-CLASS LOOP
	
	if (actuallyProcesssedCount==0 && onlyOneClass){
		printf("\r\n"BOLDWHITE"\t\tlibclassdump-dyld:"RESET" Class \""BOLDWHITE"%s"RESET"\" not found"RESET" in %s\r\n\r\n",[onlyOneClass UTF8String],image);
	}

	if (writeToDisk && classesToImport.length>2){
			[[NSFileManager defaultManager] createDirectoryAtPath:writeDir withIntermediateDirectories:YES attributes:nil error:nil];		
			if (![classesToImport writeToFile:[NSString stringWithFormat:@"%@/%@.h",writeDir,imageName] atomically:YES encoding:NSUTF8StringEncoding error:nil]){	
				printf("  Failed to save header list to directory \"%s\"\n",[writeDir UTF8String]);

			}
	}
	[classesToImport release];

	
	CDLog(@"Finished class loop for %s",image);
	
	// Compose FrameworkName-Structs.h file
	
	NSAutoreleasePool *pool=[[NSAutoreleasePool alloc] init];
	
	if ([allStructsFound count]>0){
		
		NSString *structsString=@"";
		if (writeToDisk){
			NSString *copyrightString=copyrightMessage(image);
			structsString=[[[structsString autorelease] stringByAppendingString:copyrightString] retain];
			[copyrightString release];
		}
		NSError *writeError;
		if ([classesInStructs count]>0){
			
			structsString=[[[structsString autorelease] stringByAppendingString:@"\n@class "] retain];
			for (NSString *string in classesInStructs){
				structsString=[[[structsString autorelease] stringByAppendingString:[NSString stringWithFormat:@"%@, ",string]] retain];
			}
			structsString=[[[structsString autorelease] substringToIndex:structsString.length-2] retain];
			structsString=[[[structsString autorelease] stringByAppendingString:@";\n\n"] retain];
		}
		

		for (NSDictionary *dict in allStructsFound){
			structsString=[[[structsString autorelease] stringByAppendingString:[dict objectForKey:@"representation"]] retain];
		}
		if (writeToDisk){
			[[NSFileManager defaultManager] createDirectoryAtPath:writeDir withIntermediateDirectories:YES attributes:nil error:nil];
		
			if (![structsString writeToFile:[NSString stringWithFormat:@"%@/%@-Structs.h",writeDir,imageName] atomically:YES encoding:NSUTF8StringEncoding error:&writeError]){	
				printf("  Failed to save structs to directory \"%s\"\n",[writeDir UTF8String]);
				if (writeError!=nil){
					printf("  %s\n",[[writeError description] UTF8String]);
				}
			}
		}
		else{
			printf("\n%s\n",[structsString UTF8String]);
		}

	}
	
	[pool drain];
	
	
	// Compose FrameworkName-Symbols.h file (more like nm command's output not an actual header anyway)
	if (getSymbols){

		CDLog(@"In Symbols -> Fetching symbols for %s",image);
		
		struct mach_header * mh=nil;
		struct mach_header_64 * mh64=nil;
		int vmaddrImage;
		dyld_all_image_infos = _dyld_get_all_image_infos();
		for(int i=0; i<dyld_all_image_infos->infoArrayCount; i++) {
			if (dyld_all_image_infos->infoArray[i].imageLoadAddress!=NULL){
				char *currentImage=(char *)dyld_all_image_infos->infoArray[i].imageFilePath;
				if (strlen(currentImage)>0 && !strcmp(currentImage,image)){
					
					if (arch64()){
						mh64 = (struct mach_header_64 *)dyld_all_image_infos->infoArray[i].imageLoadAddress;
					}
					else{
						mh = (struct mach_header *)dyld_all_image_infos->infoArray[i].imageLoadAddress;
					}
					vmaddrImage=i;
					break;
				}
			}
		}
	
		if ((arch64() && mh64==nil) | (!arch64() && mh==nil)){
			CDLog(@"Currently dlopened image %s not found in _dyld_image_count (?)",image);
		}
		else{
			
			unsigned int file_slide;
			NSMutableString *symbolsString=nil;
			
			
			if (!arch64()){
				CDLog(@"In Symbols -> Got mach header OK , filetype %d",mh->filetype);
				
				// Thanks to FilippoBiga for the code snippet below 
				
				struct segment_command *seg_linkedit = NULL;
				struct segment_command *seg_text = NULL;
				struct symtab_command *symtab = NULL;			
				struct load_command *cmd =  (struct load_command*)((char*)mh + sizeof(struct mach_header));
				CDLog(@"In Symbols -> Iterating header commands for %s",image);
				for (uint32_t index = 0; index < mh->ncmds; index++, cmd = (struct load_command*)((char*)cmd + cmd->cmdsize))
				{
					//CDLog(@"I=%d",index);
					switch(cmd->cmd)
					{
						case LC_SEGMENT:
						{
							//CDLog(@"FOUND LC_SEGMENT");
							struct segment_command *segmentCommand = (struct segment_command*)(cmd);
							if (strncmp(segmentCommand->segname, "__TEXT", sizeof(segmentCommand->segname)) == 0)
							{	                
								seg_text = segmentCommand;
				
							} else if (strncmp(segmentCommand->segname, "__LINKEDIT", sizeof(segmentCommand->segname)) == 0)
							{	
								seg_linkedit = segmentCommand;
							}
							break;
						}
			
						case LC_SYMTAB:
						{	
							//CDLog(@"FOUND SYMTAB");
							symtab = (struct symtab_command*)(cmd);
							break;
						}
			
						default:
						{
							break;
						}
			
					}
				}
				
				
				if (mh->filetype==MH_DYLIB){
					file_slide = ((unsigned long)seg_linkedit->vmaddr - (unsigned long)seg_text->vmaddr) - seg_linkedit->fileoff;
				}
				else{
					file_slide = 0;
				}
				CDLog(@"In Symbols -> Got symtab for %s",image);
				struct nlist *symbase = (struct nlist*)((unsigned long)mh + (symtab->symoff + file_slide));
				char *strings = (char*)((unsigned long)mh + (symtab->stroff + file_slide));
				struct nlist *sym;
				sym = symbase;
		
				symbolsString=[[NSMutableString alloc] init];
				NSAutoreleasePool *pp = [[NSAutoreleasePool alloc] init];
	
				CDLog(@"In Symbols -> Iteraring symtab");
				for (uint32_t index = 0; index < symtab->nsyms; index += 1, sym += 1)
				{	
			
					if ((uint32_t)sym->n_un.n_strx > symtab->strsize)
					{   	
						break;
		
					} else {
				
						const char *strFound = (char*) (strings + sym->n_un.n_strx);
						char *str= strdup(strFound);
						if (strcmp(str,"<redacted>") && strlen(str)>0){
							if (!symbolsString){
								NSString *copyrightString=copyrightMessage(image);
								[symbolsString appendString:[copyrightString stringByReplacingOccurrencesOfString:@"This header" withString:@"This output"]];
								[copyrightString release];	
								
								[symbolsString appendString :[NSString stringWithFormat:@"\nSymbols found in %s:\n%@\n",image,[NSString stringWithCString:str encoding:NSUTF8StringEncoding]]] ;
							}
							else{
								[symbolsString appendString : [NSString stringWithFormat:@"%s\n",str]] ;
							}

						}
						free (str);
				
					}
			
				}
				[pp drain];
			}	
			
			else{
				
				CDLog(@"In Symbols -> Got mach header OK , filetype %d",mh64->filetype);

				struct segment_command_64 *seg_linkedit = NULL;
				struct segment_command_64 *seg_text = NULL;
				struct symtab_command *symtab = NULL;
				struct load_command *cmd = (struct load_command*)((char*)mh64 + sizeof(struct mach_header_64));
				CDLog(@"In Symbols -> Iterating header commands for %s",image);

				for (uint32_t index = 0; index < mh64->ncmds; index++, cmd = (struct load_command*)((char*)cmd + cmd->cmdsize))
				{
					//CDLog(@"I=%d",index);
					switch(cmd->cmd)
					{
						case LC_SEGMENT_64:
						{	
							//CDLog(@"FOUND LC_SEGMENT_64");
							struct segment_command_64 *segmentCommand = (struct segment_command_64*)(cmd);
							if (strncmp(segmentCommand->segname, "__TEXT", sizeof(segmentCommand->segname)) == 0)
							{	                
								seg_text = segmentCommand;
				
							} else if (strncmp(segmentCommand->segname, "__LINKEDIT", sizeof(segmentCommand->segname)) == 0)
							{	
								seg_linkedit = segmentCommand;
							}
							break;
						}
			
						case LC_SYMTAB:
						{	
							//CDLog(@"FOUND SYMTAB");
							symtab = (struct symtab_command*)(cmd);
							break;
						}
			
						default:
						{
							break;
						}
			
					}
				}
				
				if (mh64->filetype==MH_DYLIB){
					file_slide = ((unsigned long)seg_linkedit->vmaddr - (unsigned long)seg_text->vmaddr) - seg_linkedit->fileoff;
				}
				else{
					file_slide = 0;
				}
				CDLog(@"In Symbols -> Got symtab for %s",image);
				struct nlist_64 *symbase = (struct nlist_64*)((unsigned long)mh64 + (symtab->symoff + file_slide));
				char *strings = (char*)((unsigned long)mh64 + (symtab->stroff + file_slide));
				struct nlist_64 *sym;
				sym = symbase;
		
			 	symbolsString=[[NSMutableString alloc] init];
				NSAutoreleasePool *pp = [[NSAutoreleasePool alloc] init];
	
				CDLog(@"In Symbols -> Iteraring symtab");
				for (uint32_t index = 0; index < symtab->nsyms; index += 1, sym += 1)
				{	
			
					if ((uint32_t)sym->n_un.n_strx > symtab->strsize)
					{   	
						break;
		
					} else {
				
						const char *strFound = (char*) (strings + sym->n_un.n_strx);
						char *str= strdup(strFound);
						if (strcmp(str,"<redacted>") && strlen(str)>0){
							if (!symbolsString){
								NSString *copyrightString=copyrightMessage(image);
								[symbolsString appendString:[copyrightString stringByReplacingOccurrencesOfString:@"This header" withString:@"This output"]];
								[copyrightString release];						
								
								[symbolsString appendString :[NSString stringWithFormat:@"\nSymbols found in %s:\n%@\n",image,[NSString stringWithCString:str encoding:NSUTF8StringEncoding]]] ;
							}
							else{
								[symbolsString appendString : [NSString stringWithFormat:@"%s\n",str]] ;
							}

						}
						free (str);
				
					}
			
				}
				[pp drain];
			}
			
		
			NSError *error2;
			CDLog(@"Finished fetching symbols for %s\n",image);
			if ([symbolsString length]>0){
				if (writeToDisk){
					[[NSFileManager defaultManager] createDirectoryAtPath:writeDir withIntermediateDirectories:YES attributes:nil error:&error2];
					if (![symbolsString writeToFile:[NSString stringWithFormat:@"%@/%@-Symbols.h",writeDir,imageName] atomically:YES encoding:NSUTF8StringEncoding error:&error2]){	
						printf("  Failed to save symbols to directory \"%s\"\n",[writeDir UTF8String]);
						if (error2!=nil){
							printf("  %s\n",[[error2 description] UTF8String]);
						}
					}
				}
				else{
					printf("\n%s\n",[symbolsString UTF8String]);
				}		
			}
			[symbolsString release];
		}
	}
	
	
	free(names);

	return 1;
	
}



/****** main ******/

int main(int argc, char **argv, char **envp) {
	
	
	@autoreleasepool {
	
		
		char * image=nil;
		BOOL writeToDisk=NO;
		BOOL buildOriginalDirs=NO;
		BOOL recursive=NO;
		BOOL simpleHeader=NO;
		BOOL getSymbols=NO;
		BOOL skipAlreadyFound=NO;
		BOOL isSharedCacheRecursive=NO;
		BOOL skipApplications=YES;
		 
		
		NSString *outputDir=nil;
		NSString *sourceDir=nil;
		
		// Check and apply arguments
		
		NSString *currentDir=[[[NSProcessInfo processInfo] environment] objectForKey:@"PWD"];
		NSArray *arguments=[[NSProcessInfo processInfo] arguments];
		NSMutableArray *argumentsToUse=[arguments mutableCopy];
		[argumentsToUse removeObjectAtIndex:0];

		int argCount=[arguments count];

		if (argCount<2){
			printHelp();
			exit(0);
		}
		
		for (NSString *arg in arguments){
		
			if ([arg isEqual:@"-D"]){
				inDebug=1;
				[argumentsToUse removeObject:arg];
			}
			
			if ([arg isEqual:@"-o"]){

				int argIndex=[arguments indexOfObject:arg]; 

				if (argIndex==argCount-1){
					printHelp();
					exit(0);
				}

				outputDir=[arguments objectAtIndex:argIndex+1];

				if ([outputDir rangeOfString:@"-"].location==0){
					printHelp();
					exit(0);
				}
				writeToDisk=YES;
				[argumentsToUse removeObject:arg];
				[argumentsToUse removeObject:outputDir];
				
				
			}
			
			if ([arg isEqual:@"-j"]){

				int argIndex=[arguments indexOfObject:arg]; 

				if (argIndex==argCount-1){
					printHelp();
					exit(0);
				}

				onlyOneClass=[[arguments objectAtIndex:argIndex+1] retain];

				if ([onlyOneClass rangeOfString:@"-"].location==0){
					printHelp();
					exit(0);
				}

				[argumentsToUse removeObject:arg];
				[argumentsToUse removeObject:onlyOneClass];
				
				
			}
			
			
			
			if ([arg isEqual:@"-r"]){

				int argIndex=[arguments indexOfObject:arg]; 

				if (argIndex==argCount-1){
					printHelp();
					exit(0);
				}
				
				sourceDir=[arguments objectAtIndex:argIndex+1];
				BOOL isDir;
				if ([sourceDir rangeOfString:@"-"].location==0 || ![[NSFileManager defaultManager] fileExistsAtPath:sourceDir] || ([[NSFileManager defaultManager] fileExistsAtPath:sourceDir isDirectory:&isDir] && !isDir)){
					printf("classdump-dyld: error: Directory %s does not exist\n",[sourceDir UTF8String]);
					exit(0);
				}
				recursive=YES;
				[argumentsToUse removeObject:arg];
				[argumentsToUse removeObject:sourceDir];
				
			}
			
			if ([arg isEqual:@"-a"]){
				skipApplications=NO;
				[argumentsToUse removeObject:arg];
			}
			
			if ([arg isEqual:@"-e"]){
				shouldDLopen32BitExecutables=YES;
				[argumentsToUse removeObject:arg];
			}
			
			
			if ([arg isEqual:@"-s"]){
				skipAlreadyFound=YES;
				[argumentsToUse removeObject:arg];
				
			}
			
			if ([arg isEqual:@"-b"]){
				buildOriginalDirs=YES;
				[argumentsToUse removeObject:arg];
				
			}
			
			if ([arg isEqual:@"-g"]){
				getSymbols=YES;
				[argumentsToUse removeObject:arg];
				
			}
			
			if ([arg isEqual:@"-u"]){
				simpleHeader=YES;
				[argumentsToUse removeObject:arg];				
			}
			if ([arg isEqual:@"-c"]){
				isSharedCacheRecursive=YES;
				[argumentsToUse removeObject:arg];				
			}
			if ([arg isEqual:@"-h"]){
				addHeadersFolder=YES;
				[argumentsToUse removeObject:arg];				
			}


		}
		
		if (onlyOneClass && (recursive || isSharedCacheRecursive)){
			printHelp();
			exit(0);		
		}
		
		if (addHeadersFolder && !outputDir){
			printHelp();
			exit(0);
		}
		
		if ((recursive || isSharedCacheRecursive) && !outputDir){
			printHelp();
			exit(0);
		}
		if ((recursive || isSharedCacheRecursive) && [argumentsToUse count]>0){
			printHelp();
			exit(0);
		}
		if ([argumentsToUse count]>2){
			printHelp();
			exit(0);
		}
		if (!recursive && !isSharedCacheRecursive){
			if ([argumentsToUse count]>1){
				printHelp();
				exit(0);			
			}
			else{
				if ([argumentsToUse count]>0){
					image=(char *)[[argumentsToUse objectAtIndex:0] UTF8String];			
				}
				else{
					printHelp();
					exit(0);
				}
			}
		}
		
		
		// Begin
		
		int RESULT=1;
		
		allImagesProcessed=[NSMutableArray array];
		
		generateForbiddenClassesArray(recursive);
		generateForbiddenPathsArray(recursive);

		NSString *inoutputDir=outputDir;
		
		if (isSharedCacheRecursive){
			const char *filename="/System/Library/Caches/com.apple.dyld/dyld_shared_cache_armv6";
			FILE* fp=fopen(filename,"r");
			if (fp==NULL){
				if ([[NSFileManager defaultManager] fileExistsAtPath:@"/private/var/db/dyld/dyld_shared_cache_x86_64"]){
					filename="/private/var/db/dyld/dyld_shared_cache_x86_64";
				}
				else if ([[NSFileManager defaultManager] fileExistsAtPath:@"/private/var/db/dyld/dyld_shared_cache_i386"]){
					filename="/private/var/db/dyld/dyld_shared_cache_i386";
				}
				else if ([[NSFileManager defaultManager] fileExistsAtPath:@"/System/Library/Caches/com.apple.dyld/dyld_shared_cache_arm64"]){
					filename="/System/Library/Caches/com.apple.dyld/dyld_shared_cache_arm64";
				}
				else if([[NSFileManager defaultManager] fileExistsAtPath:@"/System/Library/Caches/com.apple.dyld/dyld_shared_cache_armv7s"]){
					filename="/System/Library/Caches/com.apple.dyld/dyld_shared_cache_armv7s";
				}
				else{
					filename="/System/Library/Caches/com.apple.dyld/dyld_shared_cache_armv7";
				}
			}
			fclose(fp);
			printf("\n   Now dumping "BOLDWHITE"%s..."RESET"\n\n",filename);
			// Thanks to DHowett & KennyTM~ for dyld_shared_cache listing codes
			struct stat filebuffer;
			stat(filename, &filebuffer);
			unsigned long long filesize = filebuffer.st_size;
			int fd = open(filename, O_RDONLY);
			_cacheData = (uint8_t *)mmap(NULL, filesize, PROT_READ, MAP_PRIVATE, fd, 0);
			_cacheHead = (struct cache_header *)_cacheData;
			uint64_t curoffset = _cacheHead->startaddr;
			for (unsigned i = 0; i < _cacheHead->numlibs; ++ i) {
				uint64_t fo = *(uint64_t *)(_cacheData + curoffset + 24);
				curoffset += 32;
				char *imageInCache=(char*)_cacheData + fo;
				
				// a few blacklisted frameworks that crash
				if (strstr(imageInCache,"WebKitLegacy") || strstr(imageInCache,"VisualVoicemail") || strstr(imageInCache,"/System/Library/Frameworks/CoreGraphics.framework/Resources/") || strstr(imageInCache,"JavaScriptCore.framework") || strstr(imageInCache,"GameKitServices.framework") || strstr(imageInCache,"VectorKit")){
					continue;
				}
				
				NSMutableString *imageToNSString=[[NSMutableString alloc] initWithCString:imageInCache encoding:NSUTF8StringEncoding];
				[imageToNSString replaceOccurrencesOfString:@"///" withString:@"/" options:nil range:NSMakeRange(0, [imageToNSString length])];
				[imageToNSString replaceOccurrencesOfString:@"//" withString:@"/" options:nil range:NSMakeRange(0, [imageToNSString length])];
				CDLog(@"Current Image %@",imageToNSString);
				parseImage((char *)[imageToNSString UTF8String],writeToDisk,outputDir,getSymbols,YES,YES,simpleHeader,skipAlreadyFound,skipApplications);
				[imageToNSString release];
				
			}
			munmap(_cacheData, filesize);
			close(fd);	
			printf("\n   Finished dumping "BOLDWHITE"%s..."RESET"\n\n",filename);	
		}
		if (recursive){
			
			NSFileManager *fileman=[[NSFileManager alloc ] init];
			NSError *error;
			[fileman createDirectoryAtPath:outputDir withIntermediateDirectories:YES attributes:nil error:&error];
			if (error){
				NSLog(@"Could not create directory %@. Check permissions.",outputDir);
				exit(EXIT_FAILURE);
			}
			[fileman changeCurrentDirectoryPath:currentDir];
			[fileman changeCurrentDirectoryPath:outputDir];
			outputDir=[fileman currentDirectoryPath];
			[fileman changeCurrentDirectoryPath:currentDir];
			[fileman changeCurrentDirectoryPath:sourceDir];
			sourceDir=[fileman currentDirectoryPath];
			[fileman release];
			const char* dir_name=[sourceDir UTF8String];
			list_dir(dir_name,writeToDisk,outputDir,getSymbols,recursive,simpleHeader,skipAlreadyFound,skipApplications);


		}
		else{
			if (image){
				
				NSError *error;
				NSFileManager *fileman=[[NSFileManager alloc ] init];	
				NSString *imageString=nil;	
				if (outputDir){
					[fileman createDirectoryAtPath:outputDir withIntermediateDirectories:YES attributes:nil error:&error];
					if (error){
						NSLog(@"Could not create directory %@. Check permissions.",outputDir);
						exit(EXIT_FAILURE);
					}
					[fileman changeCurrentDirectoryPath:currentDir];
					[fileman changeCurrentDirectoryPath:outputDir];
					outputDir=[fileman currentDirectoryPath];
					
					imageString=[NSString stringWithCString:image encoding:NSUTF8StringEncoding];
				
					if ([imageString rangeOfString:@"/"].location!=0){ // not an absolute path
							
						[fileman changeCurrentDirectoryPath:currentDir];
						NSString *append=[imageString lastPathComponent];
						NSString *source=[imageString stringByDeletingLastPathComponent];
						[fileman changeCurrentDirectoryPath:source];
						imageString=[[fileman currentDirectoryPath] stringByAppendingString:[NSString stringWithFormat:@"/%@",append]];
						image=(char *)[imageString UTF8String];
					
					}
				}
				RESULT = parseImage(image,writeToDisk,outputDir,getSymbols,NO,buildOriginalDirs,simpleHeader,NO,skipApplications);
				[fileman release];
			}
		}
		
		if (RESULT){
			if (RESULT==4){
				printf("  %s cannot be dumped with classdump-dyld.\n",image);
				exit(1);
			}
			else if (RESULT==2){
				printf("  %s does not implement any classes.\n",image);
				exit(1);
			}
			else if (RESULT==3){
				exit(1);
			}
			else{
				if (writeToDisk){
					printf("  Done. Check \"%s\" directory.\n",[inoutputDir UTF8String]);
				}
			}
		}

	}
	
	exit(0);
	
}

 