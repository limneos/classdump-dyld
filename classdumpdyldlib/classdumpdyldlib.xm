static BOOL inCycript=NO;
static BOOL inDebug=NO;
#define CDLog(...) if (inDebug)NSLog(@"libclassdump-dyld : %@", [NSString stringWithFormat:__VA_ARGS__] )

#include "../CommonDefines.m"

static NSString * parseImage(char *image,BOOL writeToDisk,NSString *outputDir,BOOL getSymbols,BOOL isRecursive,BOOL buildOriginalDirs,BOOL simpleHeader,BOOL skipAlreadyFound);


#include "../CommonFunctions.m"


#include "../ParsingFunctions.m"





static NSString *  parseImage(char *image,BOOL writeToDisk,NSString *outputDir,BOOL getSymbols,BOOL isRecursive,BOOL buildOriginalDirs,BOOL simpleHeader,BOOL skipAlreadyFound){


	dyld_all_image_infos = _dyld_get_all_image_infos();
    dyld_all_image_infos = _dyld_get_all_image_infos();
	for(int i=0; i<dyld_all_image_infos->infoArrayCount; i++) {
		if (dyld_all_image_infos->infoArray[i].imageLoadAddress!=NULL){
			char *currentImage=(char *)dyld_all_image_infos->infoArray[i].imageFilePath;
			if (strlen(currentImage)>0 && strstr(currentImage,image)){
				image=currentImage;
				break;
			}
		}
	}


	NSMutableString *returnString=[[NSMutableString alloc] init];

	
	BOOL isFramework=NO;
	NSMutableString *dumpString=[[NSMutableString alloc] initWithString:@""];
	unsigned int count;	
	CDLog(@"Getting class count for %s",image);
	const char **names = objc_copyClassNamesForImage(image,&count);
	CDLog(@"Did return class count %d",count);
	if (count){
		printf("  Dumping "BOLDWHITE"%s"RESET"...(%d classes) %s (injected with libclassdumpdyld.dylib) \n",image ,count,[print_free_memory() UTF8String]);
	}	

	 
	
	BOOL hasWrittenCopyright=NO;
	allStructsFound=nil;
	allStructsFound=[NSMutableArray array];
	classesInStructs=nil;
	classesInStructs=[NSMutableArray array];
	
	
	NSMutableArray *protocolsAdded=[NSMutableArray array];
	
	NSString *imageName=[[NSString stringWithCString:image encoding:NSUTF8StringEncoding] lastPathComponent];
	NSString *fullImageNameInNS=[NSString stringWithCString:image encoding:NSUTF8StringEncoding];

	
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

	[writeDir retain];
	
	[processedImages addObject:[NSString stringWithCString:image encoding:NSUTF8StringEncoding]];
	CDLog(@"Beginning class loop (%d classed) for %s",count,image);
	if (inCycript){
		NSLog(@"Beginning class loop (%d classed) for %s",count,image);
	}
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
		 
		
		NSString *comparestr=[[NSString alloc] initWithCString:names[i] encoding:NSUTF8StringEncoding];
		if ([comparestr rangeOfString:@"GMS"].location==0){
			[comparestr release];
			continue;
		}
		[comparestr release];
		
		
	
	 
	 

		
		if (writeToDisk){
			loadBar(i, count, 100, 50,names[i]);   
		}
		
		actuallyProcesssedCount++;
		
		CDLog(@"Processing Class %s (%d/%d)\n",names[i],i,count);
		if (inCycript){
			NSLog(@"Processing Class %s (%d/%d)\n",names[i],i,count);
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
			
			[currentClass class]; 
		}
		
		NSString *superclassString=canGetSuperclass ? ([[currentClass superclass] description] !=nil ? [NSString stringWithFormat:@" : %@",[[currentClass superclass] description]] : @"") : @" : _UKNOWN_SUPERCLASS_";
		
		
		unsigned int protocolCount;
		Protocol ** protocolArray=class_copyProtocolList(currentClass, &protocolCount);
		NSMutableString *inlineProtocolsString=[[NSMutableString alloc] init];
		for (unsigned t=0; t<protocolCount; t++){
			if (t==0){
				[inlineProtocolsString appendString:@" <"];
			}
			const char *protocolName=protocol_getName(protocolArray[t]);
			
			NSMutableString *addedProtocol=[[NSMutableString alloc] initWithCString:protocolName encoding:NSUTF8StringEncoding];
			if (t<protocolCount-1){
				[addedProtocol appendString:@", "];
			}
			[inlineProtocolsString appendString:addedProtocol];
			[addedProtocol release];
			if (t==protocolCount-1){
				[inlineProtocolsString appendString:@">"];
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
					
					NSString *targetSaveString=[NSString stringWithFormat:@"@@@@@%@/%s.h&&&&&",writeDir,protocolName];
					[returnString appendString:targetSaveString];
					[returnString appendString:protocolHeader];
				}
				else{
					[dumpString appendString:protocolHeader];
					
				}
			}
			
		}			
		free(protocolArray);
		
		
		[dumpString appendString:[NSString stringWithFormat:@"\n@interface %s%@%@",names[i],superclassString,inlineProtocolsString]];
		[inlineProtocolsString release];
		
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
		
		
		

		unsigned int propertiesCount;
		NSMutableString *propertiesString=[[NSMutableString alloc] init];
		objc_property_t *propertyList=class_copyPropertyList(currentClass,&propertiesCount);
		
		for (unsigned int b=0; b<propertiesCount; b++){
	
			const char *propname=property_getName(propertyList[b]);
			const char *attrs=property_getAttributes(propertyList[b]);
			
			NSString *newString=propertyLineGenerator([NSString stringWithCString:attrs encoding:NSUTF8StringEncoding],[NSString stringWithCString:propname encoding:NSUTF8StringEncoding]);
			if ([propertiesString rangeOfString:newString].location==NSNotFound){
				[propertiesString appendString:newString];
			}
			[newString release];
		}
		free(propertyList);
		
		
		
		
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
			propertiesString=[[[@"\n" stringByAppendingString:[newStrings componentsJoinedByString:@"\n"]] mutableCopy] retain];
		}
		
		
		[dumpString appendString:propertiesString];
		NSString *finalClassMethodLines=generateMethodLines(object_getClass(currentClass),NO,nil);
		[dumpString appendString:finalClassMethodLines];
		NSString *finalMethodLines=generateMethodLines(currentClass,YES,propertiesArrayFromString(propertiesString));
		[propertiesString release];
		[dumpString appendString:finalMethodLines];
		[finalClassMethodLines release];
		[finalMethodLines release];
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
		
		

		if (writeToDisk){
			

			NSString *fileToWrite=[NSString stringWithCString:names[i] encoding:NSUTF8StringEncoding];

			if ([[NSString stringWithCString:names[i] encoding:NSUTF8StringEncoding] isEqual:[[NSString stringWithCString:image encoding:NSUTF8StringEncoding] lastPathComponent]]){
				fileToWrite=[[NSString stringWithCString:names[i] encoding:NSUTF8StringEncoding] stringByAppendingString:@"-Class"];
			}
			
			NSString *targetSaveString=[NSString stringWithFormat:@"@@@@@%@/%@.h&&&&&",writeDir,fileToWrite];
			[returnString appendString:targetSaveString];
			[returnString appendString:dumpString];

		}
		else{
			if (!inCycript){
				printf("%s\n\n",[dumpString UTF8String]);
			}
			
		}
		if (writeToDisk){
			NSString *importStringFrmt=simpleHeader ? [NSString stringWithFormat:@"#import \"%s.h\"\n",names[i]] : [NSString stringWithFormat:@"#import <%@/%s.h>\n",imageName,names[i]];
			[classesToImport appendString:importStringFrmt];
		}

		objc_destructInstance(currentClass);
		if (inCycript  && onlyOneClass){
			return [dumpString autorelease];
		}
		[dumpString release];
		dumpString=[[NSMutableString alloc] init];
		[pool drain];

	} 
	
	
	if (actuallyProcesssedCount==0 && onlyOneClass){
		printf("\r\n"BOLDWHITE"\t\tlibclassdump-dyld:"RESET" Class \""BOLDWHITE"%s"RESET"\" not found"RESET" in %s\r\n\r\n",[onlyOneClass UTF8String],image);
	}
		
	if (writeToDisk && classesToImport.length>2){
			
			NSString *targetSaveString=[NSString stringWithFormat:@"@@@@@%@/%@.h&&&&&",writeDir,imageName];
			[returnString appendString:targetSaveString];
			[returnString appendString:classesToImport];

	}
	[classesToImport release];

	
	CDLog(@"Finished class loop for %s",image);
	
	
	

	
	if ([allStructsFound count]>0){
		CDLog(@"Found %lu structs, processing...",(unsigned long)[allStructsFound count]);
		NSMutableString *structsString=[[NSMutableString alloc] init];
		if (writeToDisk){
			NSString *copyrightString=copyrightMessage(image);
			[structsString appendString:copyrightString];
			[copyrightString release];
		}

		if ([classesInStructs count]>0){
			
			[structsString appendString:@"\n@class "];
			for (NSString *string in classesInStructs){
				[structsString appendString:[NSString stringWithFormat:@"%@, ",string]];
			}
			structsString=[[[structsString substringToIndex:structsString.length-2] mutableCopy] retain];
			[structsString appendString:@";\n\n"];
		}
		

		for (NSDictionary *dict in allStructsFound){
			[structsString appendString:[dict objectForKey:@"representation"]];
		}
		if (writeToDisk){

			NSString *targetSaveString=[NSString stringWithFormat:@"@@@@@%@/%@-Structs.h&&&&&",writeDir,imageName];
			[returnString appendString:targetSaveString];
			[returnString appendString:structsString];
		
		}
		else{
			printf("\n%s\n",[structsString UTF8String]);
		}
		CDLog(@"Finished processing structs...");
		[structsString release];
	}

 
	
	
	
	if (getSymbols){

		CDLog(@"In Symbols -> Fetching symbols for %s",image);
		
		struct mach_header * mh=nil;
		struct mach_header_64 * mh64=nil;
		
		
		BOOL is64BitImage=is64BitMachO(image);
		
		int vmaddrImage;
		dyld_all_image_infos = _dyld_get_all_image_infos();
		for(int i=0; i<dyld_all_image_infos->infoArrayCount; i++) {
			if (dyld_all_image_infos->infoArray[i].imageLoadAddress!=NULL){
				char *currentImage=(char *)dyld_all_image_infos->infoArray[i].imageFilePath;
				if (strlen(currentImage)>0 && !strcmp(currentImage,image)){
					
					if (is64BitImage){
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
	
		if ((is64BitImage && mh64==nil) | (!is64BitImage && mh==nil)){
			CDLog(@"Currently dlopened image %s not found in _dyld_image_count (?)",image);
		}
		else{
			
			unsigned int file_slide;
			NSMutableString *symbolsString=nil;
			
			
			if (!is64BitImage){
				CDLog(@"In Symbols -> Got mach header OK , filetype %d",mh->filetype);
				
				
				
				struct segment_command *seg_linkedit = NULL;
				struct segment_command *seg_text = NULL;
				struct symtab_command *symtab = NULL;			
				struct load_command *cmd =  (struct load_command*)((char*)mh + sizeof(struct mach_header));
				CDLog(@"In Symbols -> Iterating header commands for %s",image);
				for (uint32_t index = 0; index < mh->ncmds; index++, cmd = (struct load_command*)((char*)cmd + cmd->cmdsize))
				{
					
					switch(cmd->cmd)
					{
						case LC_SEGMENT:
						{
							
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
				
				CDLog(@"In Symbols -> Got mach header64 OK , filetype %d",mh64->filetype);

				struct segment_command_64 *seg_linkedit = NULL;
				struct segment_command_64 *seg_text = NULL;
				struct symtab_command *symtab = NULL;
				struct load_command *cmd = (struct load_command*)((char*)mh64 + sizeof(struct mach_header_64));
				CDLog(@"In Symbols -> Iterating header64 commands for %s",image);

				for (uint32_t index = 0; index < mh64->ncmds; index++, cmd = (struct load_command*)((char*)cmd + cmd->cmdsize))
				{
					
					switch(cmd->cmd)
					{
						case LC_SEGMENT_64:
						{	
							
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
				[symbolsString release];
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
			
		

			CDLog(@"Finished fetching symbols for %s\n: %@",image,symbolsString);
			if ([symbolsString length]>0){
				if (writeToDisk){
				
					NSString *targetSaveString=[NSString stringWithFormat:@"@@@@@%@/%@-Symbols.h&&&&&",writeDir,imageName];
					[returnString appendString:targetSaveString];
					[returnString appendString:symbolsString];

				}
				else{
					printf("\n%s\n",[symbolsString UTF8String]);
				}		
			}
			[symbolsString release];
		}
	}
	[writeDir release];

	
	free(names);

	return returnString;

	
}

@interface classdumpdyld : NSObject
@end

@implementation classdumpdyld
static NSString *parsedResult=nil;
+(id)printResult{
	return parsedResult;
}
@end

NSString *imagePathForClassName(NSString *className){

	NSString *imagePath=NULL;
	unsigned int count=0;
	dyld_all_image_infos = _dyld_get_all_image_infos();
	dyld_all_image_infos = _dyld_get_all_image_infos();
	for(int i=0; i<dyld_all_image_infos->infoArrayCount; i++) {
		if (dyld_all_image_infos->infoArray[i].imageLoadAddress!=NULL){
			char *currentImage=(char *)dyld_all_image_infos->infoArray[i].imageFilePath;
			const char **names = objc_copyClassNamesForImage((const char *)currentImage,&count);
			for (int i=0; i<count; i++){
				const char *clsname=names[i];
				if (!strcmp([className  UTF8String],clsname)){
					imagePath=[NSString stringWithCString:currentImage encoding:NSUTF8StringEncoding ];
					break;
				}
			}
		}
	}
	return imagePath;
}

extern "C" NSString * dumpClass(Class *aClass){  
	
	NSString *className=[(id)aClass description];
	if (objc_getClass([className  UTF8String])==NULL){
		return [NSString stringWithFormat:@"Can't find class '%@'",className];
	}

	generateForbiddenClassesArray(NO);
	NSString *imagePath=[[NSBundle bundleForClass:objc_getClass([className UTF8String])] executablePath];
	if (!imagePath){
		imagePath=imagePathForClassName(className);
		if (!imagePath){
			return [NSString stringWithFormat:@"Could not find bundle owning %@",className];
		}
	}
	// proceed
	
	onlyOneClass=[className retain];
	NSString *classDumpString=parseImage((char *)[imagePath UTF8String],NO,NULL,YES,NO,NO,NO,NO);
	NSString *savePath=[[NSFileManager defaultManager] isWritableFileAtPath:@"/tmp"] ? @"/tmp" : [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
	NSString *fileToWrite=[NSString stringWithFormat:@"%@/%@.h",savePath,className];
	
	NSError *error=NULL;
	[classDumpString writeToFile:fileToWrite atomically:YES encoding:NSUTF8StringEncoding error:&error];
	if (error){ 
		parsedResult=[classDumpString retain];
		return @"Could not write to disk, type "BOLDWHITE"[classdumpdyld printResult]"RESET" to print the dump in here.";		
	}
	else{
		return [NSString stringWithFormat:@"Wrote file %@",fileToWrite];
	}
	
}


extern "C" NSString * dumpBundleForClass(Class *aClass){ 

	onlyOneClass=nil;

	NSString *className=[(id)aClass description];
	if (objc_getClass([className  UTF8String])==NULL){
		return [NSString stringWithFormat:@"Can't find class '%@'",className];
	}
	 
	generateForbiddenClassesArray(NO);
	NSString *imagePath=imagePathForClassName(className);
	if (!imagePath){
		return [NSString stringWithFormat:@"Could not find image for class %@",className];
	}
	NSString *savePath=[[NSFileManager defaultManager] isWritableFileAtPath:@"/tmp"] ? @"/tmp" : [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
	NSString *outputDir=[NSString stringWithFormat:@"%@/%@",savePath,[[imagePath lastPathComponent] stringByDeletingPathExtension]];
	NSError *error=NULL;
	BOOL isDir=NO;
	[[NSFileManager defaultManager] fileExistsAtPath:outputDir isDirectory:&isDir];
	if (!isDir){
		[[NSFileManager defaultManager] createDirectoryAtPath:outputDir withIntermediateDirectories:NO attributes:nil error:&error];
		if (error){
			return [error description];
		}
	}

	NSString *result=parseImage((char *)[imagePath UTF8String],YES,outputDir,NO,NO,NO,NO,NO);
	 
	NSArray *things=[[result componentsSeparatedByString:@"@@@@@"] retain];
	[result release];

	int total=[things count];

	if (total>2){ 

		NSLog(@"libclassdumpdyld: Writing headers to disk...");

	}

	for (unsigned i=0; i<[things count]; i++){

		@autoreleasepool{
	
			NSString *thing=[things objectAtIndex:i]; 

			if (thing.length>0){
				NSError *createError=nil;
		
				NSString *filePath=[thing substringToIndex:[thing rangeOfString:@"&&&&&"].location];
				thing=[thing substringFromIndex:[thing rangeOfString:@"&&&&&"].location+5];
				NSString *dirtosave=[filePath stringByDeletingLastPathComponent];
				 
				
				[[NSFileManager defaultManager] createDirectoryAtPath:dirtosave withIntermediateDirectories:YES attributes:nil error:&createError];
				FILE * pFile;
				pFile = fopen ([filePath UTF8String],"w");
			
				if (pFile!=NULL){
					fputs ([thing UTF8String],pFile);
					fclose (pFile);
				}
				else{
				
				}
			}
		
		}
	
	}

	[things release];


	return [NSString stringWithFormat:@"Wrote all headers to %@",outputDir];
	
	
}


extern "C" NSString * dumpBundle(NSBundle *aBundle){ 

	onlyOneClass=nil;

	if (![aBundle isKindOfClass:objc_getClass("NSBundle")]){
		return [NSString stringWithFormat:@"Not a bundle '%@'",aBundle];
	}
	if (![aBundle isLoaded]){
		BOOL loaded=[aBundle load];
		if (!loaded){
			return [NSString stringWithFormat:@"Can't load bundle '%@'",[aBundle bundleIdentifier]];
		}
	}

	generateForbiddenClassesArray(NO);
	NSString *imagePath=[aBundle executablePath];
	NSString *savePath=[[NSFileManager defaultManager] isWritableFileAtPath:@"/tmp"] ? @"/tmp" : [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
	NSString *outputDir=[NSString stringWithFormat:@"%@/%@",savePath,[[[aBundle bundlePath] lastPathComponent] stringByDeletingPathExtension] ?: [aBundle principalClass]];
	NSError *error=NULL;
	BOOL isDir=NO;
	[[NSFileManager defaultManager] fileExistsAtPath:outputDir isDirectory:&isDir];
	if (!isDir){
		[[NSFileManager defaultManager] createDirectoryAtPath:outputDir withIntermediateDirectories:NO attributes:nil error:&error];
		if (error){
			return [error description];
		}
	}

	NSString *result=parseImage((char *)[imagePath UTF8String],YES,outputDir,NO,NO,NO,NO,NO);
	 
	NSArray *things=[[result componentsSeparatedByString:@"@@@@@"] retain];
	[result release];

	int total=[things count];

	if (total>2){ 

		NSLog(@"libclassdumpdyld: Writing headers to disk...");

	}

	for (unsigned i=0; i<[things count]; i++){

		@autoreleasepool{
	
			NSString *thing=[things objectAtIndex:i]; 

			if (thing.length>0){
				NSError *createError=nil;
		
				NSString *filePath=[thing substringToIndex:[thing rangeOfString:@"&&&&&"].location];
				thing=[thing substringFromIndex:[thing rangeOfString:@"&&&&&"].location+5];
				NSString *dirtosave=[filePath stringByDeletingLastPathComponent];
				 
				
				[[NSFileManager defaultManager] createDirectoryAtPath:dirtosave withIntermediateDirectories:YES attributes:nil error:&createError];
				FILE * pFile;
				pFile = fopen ([filePath UTF8String],"w");
			
				if (pFile!=NULL){
					fputs ([thing UTF8String],pFile);
					fclose (pFile);
				}
				else{
				
				}
			}
		
		}
	
	}

	[things release];


	return [NSString stringWithFormat:@"Wrote all headers to %@",outputDir];
	
	
}


static __attribute__((constructor)) void _logosLocalCtor_976e898d(){

	@autoreleasepool {

		char * image=nil;
		BOOL writeToDisk=NO;
		BOOL buildOriginalDirs=NO;
		BOOL skipAlreadyFound=NO;
		BOOL simpleHeader=NO;
		BOOL getSymbols=NO;
		BOOL isRecursive=NO;

		
		NSString *outputDir=nil;

		
		dyld_all_image_infos = _dyld_get_all_image_infos();
	    dyld_all_image_infos = _dyld_get_all_image_infos();
		for(int i=0; i<dyld_all_image_infos->infoArrayCount; i++) {
			if (dyld_all_image_infos->infoArray[i].imageLoadAddress!=NULL){
				char *currentImage=(char *)dyld_all_image_infos->infoArray[i].imageFilePath;
				if (strlen(currentImage)>0 && strstr(currentImage,"/usr/lib/libcycript.dylib")){
					inCycript=YES;
					break;
				}
			}
		}
 
		inCycript=inCycript && image==nil;
		
		
		NSString *currentDir=[[[NSProcessInfo processInfo] environment] objectForKey:@"PWD"];
	
		if (!inCycript){
		
			NSArray *arguments=[[NSProcessInfo processInfo] arguments];
		
			NSMutableArray *argumentsToUse=[arguments mutableCopy];
			
			int argCount=[arguments count];

			if (argCount<1){
				printHelp();
				exit(0);
			}
		
			for (NSString *arg in arguments){
			
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
			
			
				if ([arg isEqual:@"-b"]){
					buildOriginalDirs=YES;
					[argumentsToUse removeObject:arg];
				
				}
			
				if ([arg isEqual:@"-r"]){
					isRecursive=YES;
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
			 
				if ([arg isEqual:@"-h"]){
					addHeadersFolder=YES;
					[argumentsToUse removeObject:arg];				
				}
				if ([arg isEqual:@"-s"]){
					skipAlreadyFound=YES;
					[argumentsToUse removeObject:arg];				
				}
				if ([arg isEqual:@"-D"]){
					inDebug=YES;
					[argumentsToUse removeObject:arg];				
				}


			}
		
			if (addHeadersFolder && !outputDir){
				printHelp();
				exit(0);
			}
		

			if ([argumentsToUse count]>0){
				image=(char *)[[argumentsToUse objectAtIndex:0] UTF8String];			
			}
			else{
				printHelp();
				exit(0);
			}
		
		
		
		
			
		
			generateForbiddenClassesArray(isRecursive);
		
			if (image){
				
				NSError *error=nil;
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

					outputDir=[fileman currentDirectoryPath]!=nil ? [fileman currentDirectoryPath] : outputDir;
				
					if (![fileman currentDirectoryPath]){
						printf("  Error: Injected application cannot write to %s, please change your output directory (you can use your user directory, e.g. /var/root/%s )",[outputDir UTF8String],[[outputDir lastPathComponent] UTF8String]);
						exit(0); 
					}
					imageString=[NSString stringWithCString:image encoding:NSUTF8StringEncoding];
			
					if ([imageString rangeOfString:@"/"].location!=0){ 
						
						[fileman changeCurrentDirectoryPath:currentDir];
						NSString *append=[imageString lastPathComponent];
						NSString *source=[imageString stringByDeletingLastPathComponent];
						[fileman changeCurrentDirectoryPath:source];
						imageString=[[fileman currentDirectoryPath] stringByAppendingString:[NSString stringWithFormat:@"/%@",append]];
						image=(char *)[imageString UTF8String];
				
					}
				}

				NSString *result=parseImage(image,writeToDisk,outputDir,getSymbols,NO,buildOriginalDirs,simpleHeader,skipAlreadyFound);
			
			

				if (writeToDisk){
				

					NSArray *things=[[result componentsSeparatedByString:@"@@@@@"] retain];
					[result release];

					int total=[things count];
				
					if (total>2){ 

						printf("  Writing "BOLDWHITE"%s"RESET" headers to disk...\n",image);

					}
				
					for (unsigned i=0; i<[things count]; i++){
				
						@autoreleasepool{
					
							NSString *thing=[things objectAtIndex:i]; 

							if (thing.length>0){
								NSError *createError=nil;
						
								NSString *filePath=[thing substringToIndex:[thing rangeOfString:@"&&&&&"].location];
								thing=[thing substringFromIndex:[thing rangeOfString:@"&&&&&"].location+5];
								NSString *dirtosave=[filePath stringByDeletingLastPathComponent];

								loadBar(i,total, 100, 50,[[filePath lastPathComponent] UTF8String]);   
								[[NSFileManager defaultManager] createDirectoryAtPath:dirtosave withIntermediateDirectories:YES attributes:nil error:&createError];
								FILE * pFile;
								pFile = fopen ([filePath UTF8String],"w");
							
								if (pFile!=NULL){
									fputs ([thing UTF8String],pFile);
									fclose (pFile);
								}
								else{
								
								}
							}
						
						}
					
					}
			
					[things release];

				}
				printf("  All done for "BOLDWHITE"%s"RESET"\n",image);
		
				[fileman release];
			}

		} 
		

	}
	if (!inCycript){
		exit(0);
	}
	
	 
	
}

 
