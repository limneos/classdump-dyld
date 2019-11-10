static NSMutableArray *forbiddenClasses=nil;
NSMutableArray *forbiddenPaths=nil;




struct cache_header {
        char version[16];
        uint32_t baseaddroff;
        uint32_t unk2;
        uint32_t startaddr;
        uint32_t numlibs;
        uint64_t dyldaddr;
};


BOOL isMachOExecutable(const char *image){

	FILE *machoFile = fopen (image, "rb");
	if (machoFile == 0){
		return NO;
	}
	//#ifdef __LP64__
	mach_header_64 machHeader;
	//#else
	//mach_header machHeader;
	//#endif
  
	int n = fread (&machHeader, sizeof (machHeader), 1, machoFile);
	if (n != 1 ){
		fclose(machoFile);
		return NO;
	}
	BOOL isExec = machHeader.filetype == MH_EXECUTE;
	
	fclose(machoFile);
  	return isExec;

}

BOOL is64BitMachO(const char *image){
	
	FILE *machoFile = fopen (image, "rb");
	if (machoFile == 0){
		fclose(machoFile);
	 	return NO;
	}
	mach_header_64 machHeader;
	int n = fread (&machHeader, sizeof (machHeader), 1, machoFile);
  	if (n != 1){

	  	fclose(machoFile);
  		return NO;
  	}
  	BOOL is64=machHeader.magic!=MH_MAGIC; // instead of ==MH_MAGIC_64
  	fclose(machoFile);
	return is64;

}

BOOL fileExistsOnDisk(const char *image){
	
	FILE *aFile = fopen (image, "r");
	BOOL exists=aFile != 0;
	fclose(aFile);
	return exists;

}
 
BOOL arch64(){
	
	//size_t size;
	//sysctlbyname("hw.cpu64bit_capable", NULL, &size, NULL, 0);
	//BOOL cpu64bit; 
	//sysctlbyname("hw.cpu64bit_capable", &cpu64bit, &size, NULL, 0);
	//return cpu64bit;

	#ifdef __LP64__
	return YES;
	#endif
	return NO;

}



static BOOL priorToiOS7(){
	
	return ![objc_getClass("NSProcessInfo") instancesRespondToSelector:@selector(endActivity:)];

}


NSMutableArray * generateForbiddenClassesArray(BOOL isRecursive){
	
	BOOL IOS11=[[[NSProcessInfo processInfo] operatingSystemVersionString] rangeOfString:@"Version 11"].location==0;
	BOOL IOS12=[[[NSProcessInfo processInfo] operatingSystemVersionString] rangeOfString:@"Version 12"].location==0;
	
	forbiddenClasses=[[NSMutableArray alloc] init];

	if (priorToiOS7()){
		[forbiddenClasses addObject:@"VKRoadGroup"];
		[forbiddenClasses addObject:@"SBApplication"];
		[forbiddenClasses addObject:@"SBSMSApplication"];
		[forbiddenClasses addObject:@"SBFakeNewsstandApplication"];
		[forbiddenClasses addObject:@"SBWebApplication"];
		[forbiddenClasses addObject:@"SBNewsstandApplication"];
	}

	if (isRecursive){
		[forbiddenClasses addObject:@"UIScreen"];
		[forbiddenClasses addObject:@"UICollectionViewData"];
	}

	//iWork related crashing classes
	[forbiddenClasses addObject:@"KNSlideStyle"];
	[forbiddenClasses addObject:@"TSWPListStyle"];
	[forbiddenClasses addObject:@"TSWPColumnStyle"];
	[forbiddenClasses addObject:@"TSWPCharacterStyle"];
	[forbiddenClasses addObject:@"TSWPParagraphStyle"];
	[forbiddenClasses addObject:@"TSTTableStyle"];
	[forbiddenClasses addObject:@"TSTCellStyle"];
	[forbiddenClasses addObject:@"TSDMediaStyle"];
	[forbiddenClasses addObject:@"TSDShapeStyle"];
	[forbiddenClasses addObject:@"TSCHStylePasteboardData"];
	[forbiddenClasses addObject:@"OABShapeBaseManager"];
	[forbiddenClasses addObject:@"TSCH3DGLRenderProcessor"];
	[forbiddenClasses addObject:@"TSCH3DAnimationTimeSlice"];
	[forbiddenClasses addObject:@"TSCH3DBarChartDefaultAppearance"];
	[forbiddenClasses addObject:@"TSCH3DGenericAxisLabelPositioner"];
	[forbiddenClasses addObject:@"TSCHChartSeriesNonStyle"];
	[forbiddenClasses addObject:@"TSCHChartAxisNonStyle"];
	[forbiddenClasses addObject:@"TSCHLegendNonStyle"];
	[forbiddenClasses addObject:@"TSCHChartNonStyle"];
	[forbiddenClasses addObject:@"TSCHChartSeriesStyle"];
	[forbiddenClasses addObject:@"TSCHChartAxisStyle"];
	[forbiddenClasses addObject:@"TSCHLegendStyle"];
	[forbiddenClasses addObject:@"TSCHChartStyle"];
	[forbiddenClasses addObject:@"TSCHBaseStyle"];

	//other classes that crash on opening outside their process
	[forbiddenClasses addObject:@"LineServiceManager"];
	[forbiddenClasses addObject:@"GKBubbleFlowBubbleControl"];
	[forbiddenClasses addObject:@"AXBackBoardGlue"];
	[forbiddenClasses addObject:@"TMBackgroundTaskAgent"];
	[forbiddenClasses addObject:@"PLWallpaperAssetAccessibility"];
	[forbiddenClasses addObject:@"MPMusicPlayerController"];
	[forbiddenClasses addObject:@"PUAlbumListCellContentView"];
	[forbiddenClasses addObject:@"SBAXItemChooserTableViewCell"];
	[forbiddenClasses addObject:@"WebPreferences"];
	[forbiddenClasses addObject:@"WebFrameView"];
	[forbiddenClasses addObject:@"VMServiceClient"];
	[forbiddenClasses addObject:@"VKClassicGlobeCanvas"];
	[forbiddenClasses addObject:@"VKLabelModel"];
	[forbiddenClasses addObject:@"UICTFont"];
	[forbiddenClasses addObject:@"UIFont"];
	[forbiddenClasses addObject:@"NSFont"];
	[forbiddenClasses addObject:@"PLImageView"];
	[forbiddenClasses addObject:@"PLPolaroidImageView"];
	[forbiddenClasses addObject:@"MFSMTPConnection"];
	[forbiddenClasses addObject:@"MFConnection"];
	[forbiddenClasses addObject:@"AXSpringBoardSettingsLoader"];
	[forbiddenClasses addObject:@"AXUIActiveWindow"];
	[forbiddenClasses addObject:@"VolumeListener"];
	[forbiddenClasses addObject:@"VKTransitLineMarker"];
	[forbiddenClasses addObject:@"VKLabelMarkerShield"];
	[forbiddenClasses addObject:@"VKImageSourceKey"];
	[forbiddenClasses addObject:@"MMSDK"];
	[forbiddenClasses addObject:@"MDLAsset"];
	[forbiddenClasses addObject:@"MDLCamera"];
	[forbiddenClasses addObject:@"SCNMetalResourceManager"];
	[forbiddenClasses addObject:@"SCNRenderContextImp"];
	[forbiddenClasses addObject:@"SUICFlamesView"];
	[forbiddenClasses addObject:@"WAMediaPickerAsset"];
	[forbiddenClasses addObject:@"FBSDKAppLinkResolver"];
	[forbiddenClasses addObject:@"BFTaskCompletionSource"];
	[forbiddenClasses addObject:@"FilterContext"];
	[forbiddenClasses addObject:@"GMSZoomTable"];
	[forbiddenClasses addObject:@"CardIOCardScanner"];
	[forbiddenClasses addObject:@"LineServiceManager"];
	[forbiddenClasses addObject:@"WAServerProperties"];
	[forbiddenClasses addObject:@"FBGroupPendingStream"];
	[forbiddenClasses addObject:@"FBConsoleGetTagStatuses_result"];
	[forbiddenClasses addObject:@"CLLocationProviderAdapter"];
	[forbiddenClasses addObject:@"AXBackBoardGlue"];
	[forbiddenClasses addObject:@"TMBackgroundTaskAgent"];
	[forbiddenClasses addObject:@"TSCHReferenceLineNonStyle"];
	[forbiddenClasses addObject:@"TSTTableInfo"];
	[forbiddenClasses addObject:@"TSCHReferenceLineStyle"];
	[forbiddenClasses addObject:@"AZSharedUserDefaults"];
	[forbiddenClasses addObject:@"NSLeafProxy"];
	[forbiddenClasses addObject:@"FigIrisAutoTrimmerMotionSampleExport"];
	[forbiddenClasses addObject:@"RCDebugRecordingController"];
	[forbiddenClasses addObject:@"CoreKnowledge.CKInMemoryKnowledgeStorage"];
	[forbiddenClasses addObject:@"CoreKnowledge.CKUserDefaultsKnowledgeStorage"];
	[forbiddenClasses addObject:@"CoreKnowledge.CKSQLKnowledgeStorage"];
	[forbiddenClasses addObject:@"CoreKnowledge.CKEntity"];
	[forbiddenClasses addObject:@"CoreKnowledge.CKKnowledgeStore"];
	[forbiddenClasses addObject:@"JSExport"];
	[forbiddenClasses addObject:@"SBClockApplicationIconImageView"];
	if (IOS11 || IOS12){
		[forbiddenClasses addObject:@"SKTransformNode"];
		[forbiddenClasses addObject:@"OZFxPlugParameterHandler"];
		[forbiddenClasses addObject:@"OZFxPlugParameterHandler_v4"];
		[forbiddenClasses addObject:@"PAETransitionDefaultBase"];
		[forbiddenClasses addObject:@"PAEGeneratorDefaultBase"];
		[forbiddenClasses addObject:@"PAEFilterDefaultBase"];
		[forbiddenClasses addObject:@"MTLToolsDevice"];
		[forbiddenClasses addObject:@"CMMTLDevice"];
		[forbiddenClasses addObject:@"SBReachabilityManager"];
		[forbiddenClasses addObject:@"IGRTCBroadcastSession"];
		[forbiddenClasses addObject:@"FBVideoBroadcastSwitchableSession"];
		[forbiddenClasses addObject:@"FBVideoBroadcastSessionBase"];
		[forbiddenClasses addObject:@"NFSecureElementWrapper"];

		[forbiddenClasses addObject:@"JTImageView"];
		[forbiddenClasses addObject:@"PNPWizardScratchpadInkView"];
		[forbiddenClasses addObject:@"PFMulticasterDistributionMethods"];
		[forbiddenClasses addObject:@"PFEmbeddedMulticasterImplementation"];
		[forbiddenClasses addObject:@"AAJSON"];
		    
	}
	[forbiddenClasses addObject:@"_UISearchBarVisualProviderIOS"];
	[forbiddenClasses addObject:@"_UISearchBarVisualProviderLegacy"];
	[forbiddenClasses addObject:@"VNFaceObservation"];	
	[forbiddenClasses addObject:@"CMMTLDevice"];	
	[forbiddenClasses addObject:@"SKTransformNode"];
	[forbiddenClasses addObject:@"AASession"];
	[forbiddenClasses addObject:@"TeaFoundation.DynamicLocale"];
	[forbiddenClasses addObject:@"CoreKnowledge.SRIngestor"];
	[forbiddenClasses addObject:@"CKHistoricEvent"];
	[forbiddenClasses addObject:@"SUICFlamesViewLegacy"];
	[forbiddenClasses addObject:@"SUICFlamesViewMetal"];
	[forbiddenClasses addObject:@"JTImageView"];
	[forbiddenClasses addObject:@"MTLToolsDevice"];
	[forbiddenClasses addObject:@"PNPWizardScratchpadInkView"];
	[forbiddenClasses addObject:@"OZFxPlugParameterHandler"];
	[forbiddenClasses addObject:@"OZFxPlugParameterHandler_v4"];
	[forbiddenClasses addObject:@"PAETransitionDefaultBase"];
	[forbiddenClasses addObject:@"PAEGeneratorDefaultBase"];
	[forbiddenClasses addObject:@"PAEFilterDefaultBase"];
	[forbiddenClasses addObject:@"USKData"];
	[forbiddenClasses addObject:@"USKProperty"];
	[forbiddenClasses addObject:@"NTKPrideLinearQuad"];
	[forbiddenClasses addObject:@"NTKPrideCircularQuad"];
	[forbiddenClasses addObject:@"NTKPrideSplinesQuad"];
	[forbiddenClasses addObject:@"Highlights.FallbackHighlightViewModel"];
	[forbiddenClasses addObject:@"HighlightsHeavy.FallbackHighlightViewModel"];
	
	
	return forbiddenClasses;
}

static NSString * copyrightMessage(char *image){

	NSAutoreleasePool *pool =[[NSAutoreleasePool  alloc] init];
	NSString *version = [NSProcessInfo processInfo ].operatingSystemVersionString;
    NSLocale *loc=[NSLocale localeWithLocaleIdentifier: @"en-us"];
    NSString *date=[NSDate.date descriptionWithLocale: loc];

	NSString *message=[[NSString alloc] initWithFormat:@"/*\n\
* This header is generated by classdump-dyld 1.0\n\
* on %@\n\
* Operating System: %@\n\
* Image Source: %s\n\
* classdump-dyld is licensed under GPLv3, Copyright \u00A9 2013-2016 by Elias Limneos.\n\
*/\n\n",date,version,image];

	[pool drain];
	
	return message;

}


void printHelp(){

	printf("\nclassdump-dyld v1.0. Licensed under GPLv3, Copyright \u00A9 2013-2014 by Elias Limneos.\n\n");
	printf("Usage: classdump-dyld [<options>] <filename|framework>\n");
	printf("       or\n");
	printf("       classdump-dyld [<options>] -r <sourcePath>\n\n");

	printf("Options:\n\n");

	
	printf("    Structure:\n");
	printf("        -g   Generate symbol names file\n"); 
	printf("        -b   Build original directory structure in output dir\n");
	printf("        -h   Add a \"Headers\" directory to place headers in\n");
	printf("        -u   Do not include framework when importing headers (\"Header.h\" instead of <frameworkName/Header.h>)\n\n");

	printf("    Output:\n");
	printf("        -o   <outputdir> Save generated headers to defined path\n\n");

	printf("    Mass dumping: (requires -o)\n");
	printf("        -c   Dump all images found in dyld_shared_cache\n");
	printf("        -r   <sourcepath> Recursively dump any compatible Mach-O file found in the given path\n");
	printf("        -s   In a recursive dump, skip header files already found in the same output directory\n\n");

	printf("    Single Class:\n");
	printf("        -j   <className> Dump only the specified class name. (Does not work with -c or -r )\n"); 
	printf("                         This might also dump additional imported or required headers.\n\n"); 

	printf("    Miscellaneous\n");
	printf("        -D   Enable debug printing for troubleshooting errors\n");
	printf("        -e   dpopen 32Bit executables instead of injecting them (iOS 5+, use if defaults fail.This will skip any 64bit executable) \n"); 
	printf("        -a   In a recursive dump, include 'Applications' directories (skipped by default) \n\n"); 

	printf("    Examples:\n");
	printf("        Example 1: classdump-dyld -o outdir /System/Library/Frameworks/UIKit.framework\n");
	printf("        Example 2: classdump-dyld -o outdir /usr/libexec/backboardd\n");
	printf("        Example 3 (recursive): classdump-dyld -o outdir -c  (Dumps all files residing in dyld_shared_cache)\n");
	printf("        Example 4 (recursive): classdump-dyld -o outdir -r /System/Library/\n");
	printf("        Example 5 (recursive): classdump-dyld -o outdir -r / -c  (Mass-dumps almost everything on device)\n\n");

}


static NSString * print_free_memory () {
   
    mach_port_t host_port;
    mach_msg_type_number_t host_size;
    vm_size_t pagesize;
    
    host_port = mach_host_self();
    host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    host_page_size(host_port, &pagesize);        
 
    vm_statistics_data_t vm_stat;
              
    if (host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size) != KERN_SUCCESS){
        //Failed to fetch vm stats
	}
    natural_t mem_free = vm_stat.free_count * pagesize;

	if (mem_free<10000000){ // break if less than 10MB of RAM
		printf("Error: Out of memory. You can repeat with -s option to continue from where left.\n\n");
		exit(0);
	}
	if (mem_free<20000000){ // warn if less than 20MB of RAM
		return [NSString stringWithFormat:@"Low Memory: %u MB free. Might exit to prevent system hang",(mem_free/1024/1024)] ;
	}
	else{
		return [NSString stringWithCString:"" encoding:NSASCIIStringEncoding];
		//return [NSString stringWithFormat:@"Memory: %u MB free",(mem_free/1024/1024)] ;
	}
	
}


// A nice loading bar. Credits: http://www.rosshemsley.co.uk/2011/02/creating-a-progress-bar-in-c-or-any-other-console-app/
static inline void loadBar(int x, int n, int r, int w,const char *className)
{
//	return;
    // Only update r times.
    if ((n/r)<1){
    	return;
    }
    if ( x % (n/r) != 0 ) return;
 
    // Calculuate the ratio of complete-to-incomplete.
    float ratio = x/(float)n;
    int   c     = ratio * w;
 
    // Show the percentage complete.
    printf("%3d%% [", (int)(ratio*100) );
 
    // Show the load bar.
    for (int x=0; x<c; x++)
       printf("=");
 
    for (int x=c; x<w; x++)
       printf(" ");
 
    // ANSI Control codes to go back to the
    // previous line and clear it.
    printf("] %s %d/%d <%s>\n\033[F\033[J",[print_free_memory() UTF8String],x,n,className);
}



NSMutableArray * generateForbiddenPathsArray(BOOL isRecursive){
	
	forbiddenPaths=[[NSMutableArray alloc] init];
	// The following paths are skipped for known issues that arise when their symbols are added to the flat namespace
	
	[forbiddenPaths addObject:@"/usr/bin"];
	[forbiddenPaths addObject:@"/Developer"];
	[forbiddenPaths addObject:@"/Library/Switches"];
	[forbiddenPaths addObject:@"SBSettings"];
	[forbiddenPaths addObject:@"Activator"];
	[forbiddenPaths addObject:@"launchd"];
	if (priorToiOS7()){
		[forbiddenPaths addObject:@"/System/Library/Frameworks/PassKit.framework/passd"];
	}
	[forbiddenPaths addObject:@"AGXMetal"];
	[forbiddenPaths addObject:@"PhotosUI"];
	[forbiddenPaths addObject:@"AccessibilityUIService"];
	[forbiddenPaths addObject:@"CoreSuggestionsInternals"];
	[forbiddenPaths addObject:@"GameCenterPrivateUI"];
	[forbiddenPaths addObject:@"GameCenterUI"];
	[forbiddenPaths addObject:@"LegacyGameKit"];
	[forbiddenPaths addObject:@"IMAP.framework"];
	[forbiddenPaths addObject:@"POP.framework"];
	[forbiddenPaths addObject:@"Parsec"];
	[forbiddenPaths addObject:@"ZoomTouch"];
	[forbiddenPaths addObject:@"VisualVoicemailUsage"];
	if (isRecursive){
		[forbiddenPaths addObject:@"braille"];
		[forbiddenPaths addObject:@"QuickSpeak"];
		[forbiddenPaths addObject:@"HearingAidUIServer"];
		[forbiddenPaths addObject:@"Mail.siriUIBundle"];
		[forbiddenPaths addObject:@"TTSPlugins"];
	}
	[forbiddenPaths addObject:@"AppAnalytics"];
	[forbiddenPaths addObject:@"CoreKnowledge"];
	
	
	return forbiddenPaths;
}


int locationOfString(const char *haystack, const char *needle){
	const char * found = strstr( haystack, needle );
	int anIndex=-1;
	if (found != NULL){
	  anIndex = found - haystack;
	}
	return anIndex;
}