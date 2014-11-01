classdump-dyld
==============

Added 64bit executables dumping 

A class dumping command line tool that generates header files from app binaries, libraries, frameworks, bundles or the whole dyld_shared_cache.

Eliminates the need to extract files from the dyld_shared_cache in order to class-dump them or get symbols.

You can instantly classdump any compatible Mach-o file, either if it is physically stored on disk or it resides in the dyld_shared_cache.

Features and options:
	
   * Classdump files that appear malformed to the usual tools on device.
   * Classdump files or frameworks on runtime without extracting them from dyld_shared_cache.
   * Classdump files that reside on disk as usual
   * Recursively search for compatible files and dump them (e.g. whole directory of "/System/Library", "/Applications" or "/" )
   * Recursively dump all the images stored in dyld_shared_cache
   * Generate symbols list for files that are stored in dyld_shared_cache without extracting them.
   * Generation of all structs, symbols and necessary #imports to correctly fill up each header file. (I pray for that)


You can find a recursive sample output on this project under iphoneheaders. 
It also works on a Mac for dyld_shared_cache and some libraries


-------------------------------

	Usage: classdump-dyld [<options>] <filename|framework>
	
		   classdump-dyld [<options>] -r <sourcePath>
		   

	Options:
	
		Structure:
			-g   Do not generate symbol names 
			-h   Add a \"Headers\" directory to place headers in
			-b   Do not build original directory structure in output dir
			-u   Do not include framework when importing headers ("Header.h" instead of <frameworkName/Header.h>)

		Output:
			-o   <outputdir> Save generated headers to defined path
		
		Mass dumping: (requires -o)
			-c   Dump all images found in dyld_shared_cache 
			-r   <sourcepath> Recursively dump any compatible Mach-O file found in the given path (requires -o) 
			-s   In a recursive dump, skip header files already found in the same output directory 
		
		Debug: 
			-D   Print debug info for troubleshooting
		Examples:
    		Example 1: classdump-dyld -o outdir /System/Library/Frameworks/UIKit.framework
    		Example 2: classdump-dyld -o outdir /usr/libexec/backboardd
	    	Example 3 (recursive): classdump-dyld -o outdir -c  (Dumps all files residing in dyld_shared_cache)
    		Example 4 (recursive): classdump-dyld -o outdir -r /Applications
    		Example 5 (recursive): classdump-dyld -o outdir -r / -c  (Mass-dumps almost everything on device)


Usage limitations
----------------
classdump-dyld works with Mach-o files only.
Some files have protection against being dynamically loaded from a different process.
In those cases, you can use weak_classdump or other tools.
	

by Elias Limneos
----------------
web: limneos.net

email: iphone (at) limneos (dot) net

twitter: @limneos


Licence
-----------

classdump-dyld is Copyright (c) 2013 Elias Limneos, licensed under GPLv3.


Environment
-----------
classdump-dyld works in a command line shell on any iOS 5+ device and Mac OS X. Tested from iOS 5.x to iOS 7.x and Mac OSX 10.8+.



