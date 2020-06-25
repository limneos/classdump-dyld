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

dlopen("/usr/lib/libclassdumpdyld.dylib",RTLD_NOW);

extern "C" NSString *dumpBundle(NSBundle *bundle);
extern "C" NSString *dumpClass(Class klass);
extern "C" NSString *dumpBundleForClass(Class klass);

module.exports = {
	dumpBundle: dumpBundle,
	dumpClass: dumpClass,
	dumpBundleForClass: dumpBundleForClass
};
