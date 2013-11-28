-[AttributeKey index]
-[AttributeKey key]
-[AttributeKey initFromPlist:]
+[AttributeKey instanceFromPlist:]
-[AttributeKey initWithIndex:attributeName:]
-[AttributeKey dealloc]
-[Cell isBlank]
-[Cell hasContent]
-[Cell initFromPlist:]
+[Cell instanceFromPlist:]
+[Cell cellWithCell:]
-[Cell overlayedOn:]
-[Cell init]
+[Cell cell]
-[Cell initAsWildcard]
+[Cell wildcard]
-[Cell initAsBlank]
+[Cell blank]
-[Cell initWithContentString:]
+[Cell cellWithContentString:]
-[Cell setContent:]
-[Cell content]
-[Cell setPre:]
-[Cell pre]
-[Cell setPost:]
-[Cell post]
-[Cell attributeForKey:]
-[Cell setAttribute:forKey:]
-[Cell matches:]
-[Cell dealloc]
-[Cell flattened]
-[Cell initWithAttributesDictionary:]
-[Cell copyWithZone:]
+[Cell literalCellWithCell:]
-[Cell literalCell]
-[Cell description]
-[Cell type]
-[Cell attributes]
-[Cell setAttributes:]
-[CompoundSlot initFromPlist:]
-[CompoundSlot initWithArray:]
-[CompoundSlot matches:]
-[CompoundSlot description]
-[CompoundSlot reversed]
-[CompoundSlot dealloc]
-[CompoundSlot slots]
-[ConditionalProduction initFromPlist:]
-[ConditionalProduction dealloc]
-[ConditionalProduction description]
-[ConditionalProduction signature]
-[ConditionalProduction delimiter]
-[ConditionalProduction expansions]
-[Decomposer initWithDirectory:bundle:]
-[Decomposer optimalDecompositionOf:]
-[Decomposer optimalDecompositionOf:isSubsetOfWhole:]
-[Decomposer dealloc]
-[Decomposer delegate]
-[Decomposer setDelegate:]
-[Directory initFromPlist:]
+[Directory instanceFromPlist:]
-[Directory dealloc]
-[Directory description]
-[Directory appliedTo:]
-[Directory orderedSubparts]
+[DisjunctionSlot instanceFromPlist:]
+[DisjunctionSlot disjunctionSlotWithArray:]
-[DisjunctionSlot matches:]
-[DisjunctionSlot description]
-[DisjunctionSlot reversed]
-[GenericProduction initFromPlist:]
+[GenericProduction instanceFromPlist:]
-[GrammarPart orderComparedTo:]
-[GrammarPart genericSetUpFromPlist:]
+[GrammarPart instanceFromPlist:]
-[GrammarPart dealloc]
-[GrammarPart description]
-[GrammarPart appliedTo:]
-[GrammarPart order]
-[GrammarPart depth]
-[GrammarPart name]
+[KleeneSlot instanceFromPlist:]
+[KleeneSlot kleeneSlotWithArray:]
-[KleeneSlot matches:]
-[KleeneSlot description]
-[KleeneSlot reversed]
-[NewProduction initFromPlist:]
+[NewProduction instanceFromPlist:]
-[NewProduction initWithSimpleSlotSequence:]
+[NewProduction productionWithSimpleSlotSequence:]
-[NewProduction initWithOverlays:indices:]
-[NewProduction dealloc]
-[NewProduction description]
-[NewProduction indices]
-[NewProduction setIndices:]
-[NewProduction overlays]
-[NewProduction setOverlays:]
-[NSArray(Helpers) _withoutEmptyStrings]
-[NSArray(Helpers) repeatedNTimes:]
-[NSArray(Helpers) _containsSubArray:]
-[NSArray(Helpers) _subsequenceFrom:to:]
-[NSArray(Helpers) _subsequenceToIndex:]
-[NSArray(Helpers) _subsequenceFromIndex:]
-[NSArray(Splice) _spliceAt:amount:andOverlay:]
-[NSArray(Splice) _spliceAt:amount:andInsert:]
-[Parser initWithPlistAtPath:grammar:]
+[Parser loadGrammarsFromPlistAtPath:]
___38+[Parser loadGrammarsFromPlistAtPath:]_block_invoke
-[Parser setGrammar:]
+[Parser insertStatementsFromOriginal:intoBranch:]
+[Parser retrievePlistForStringInDotNotation:from:]
+[Parser retrievePlistForPathArray:from:]
-[Parser resultOfRulesAppliedToStrings:]
-[Parser resultOfRulesAppliedTo:]
-[Parser dealloc]
-[Parser productionRules]
+[Player initialize]
+[Player __initializeAudioSession]
-[Player _playerItemForFileNamed:]
+[Player __sharedPlayQueue]
+[Player __clearSharedPlayQueue]
+[Player __deactivateAudioSession]
+[Player __nts_indicateEndOfQueuePlayback:]
+[Player __nts_queuePlayerStatusChanged:]
+[Player observeValueForKeyPath:ofObject:change:context:]
-[Player initWithDirectory:bundle:]
-[Player dealloc]
-[Player isPlaying]
-[Player _addFileToQueue:]
-[Player playSoundFilesInSequence:]
-[Player stopAllSounds]
+[Player _setAudioSessionActive:]
+[Rule test]
-[Rule initFromPlist:]
+[Rule instanceFromPlist:]
-[Rule initWithLeftHandSide:rightHandSideOverlays:rightHandSideBaseIndices:]
-[Rule initWithLeftHandSide:rightHandSide:]
+[Rule ruleWithLeftHandSide:rightHandSide:]
-[Rule dealloc]
-[Rule appliedTo:]
-[Rule description]
+[SimpleSlot blank]
-[SimpleSlot content]
-[SimpleSlot initFromPlist:]
+[SimpleSlot instanceFromPlist:]
+[SimpleSlot empty]
-[SimpleSlot initWithCell:]
-[SimpleSlot dealloc]
-[SimpleSlot reversed]
-[SimpleSlot overlayedOn:]
+[SimpleSlot simpleSlotWithCell:]
-[SimpleSlot attributeForKey:]
-[SimpleSlot matches:]
-[SimpleSlot description]
-[SimpleSlot cell]
-[SimpleSlot setCell:]
-[SimpleSlotSequence sequenceByReplacingOccurencesOfSequence:withSequence:]
-[SimpleSlotSequence sequenceByReplacingOccurencesOfSlotsInContext:withProduction:]
-[SimpleSlotSequence pad]
-[SimpleSlotSequence stringArray]
-[SimpleSlotSequence initWithArray:]
+[SimpleSlotSequence slotArrayWithStrings:]
+[SimpleSlotSequence slotSequenceWithStrings:]
+[SimpleSlotSequence blankBufferedSlotSequenceWithStrings:]
+[SimpleSlotSequence slotSequenceWithArray:]
-[SimpleSlotSequence valueForAttributeKey:]
-[SimpleSlotSequence overlayedOn:]
-[SimpleSlotSequence first]
-[SimpleSlotSequence rest]
-[Slot matches:]
-[Slot initFromPlist:]
+[Slot instanceFromPlist:]
+[SlotSequence emptySlotSequence]
-[SlotSequence initFromPlist:]
-[SlotSequence initWithArray:]
+[SlotSequence slotSequenceWithArray:]
-[SlotSequence first]
-[SlotSequence portionPrecedingOccurrenceOfSequence:atIndex:]
-[SlotSequence portionFollowingOccurrenceOfSequence:atIndex:]
-[SlotSequence occurrenceOfSequence:atIndex:]
-[SlotSequence reversed]
-[SlotSequence subsequenceFromIndex:]
-[SlotSequence slotSubsequenceFromIndex:]
-[SlotSequence rest]
-[SlotSequence count]
-[SlotSequence empty]
-[SlotSequence matches:]
-[SlotSequence description]
-[SlotSequence dealloc]
-[SlotSequence indicesOfOccurrencesInTarget:]
-[SlotSequence overlayedOn:]
-[SlotSequence slots]
-[SlotSequence setSlots:]
+[SlotsInContext test]
-[SlotsInContext initFromPlist:]
+[SlotsInContext slotsInContextWithSignificantSlotSequence:]
+[SlotsInContext instanceFromPlist:]
-[SlotsInContext initWithArraysForSignificantSlots:preContext:postContext:]
-[SlotsInContext dealloc]
-[SlotsInContext indicesOfOccurrencesInTarget:]
-[SlotsInContext description]
-[SlotsInContext significantSlots]
+[SpecialCharacters wildcardSymbol]
+[SpecialCharacters blankSymbol]
+[SpecialCharacters defaultAttribute]
+[SpecialCharacters kleeneMarker]
+[SpecialCharacters disjunctionMarker]
+[SpecialCharacters negationMarker]
+[SpecialCharacters orderKey]
+[SpecialCharacters insertDirective]
+[SpecialCharacters depthKey]
+[SpecialCharacters partNameKey]
+[SpecialCharacters indexKey]
+[SpecialCharacters attributeNameKey]
+[SpecialCharacters signatureKey]
+[SpecialCharacters delimiterKey]
+[SpecialCharacters expansionsKey]
+[SpecialCharacters preContextKey]
+[SpecialCharacters postContextKey]
+[SpecialCharacters significantSlotsKey]
+[SpecialCharacters lhsKey]
+[SpecialCharacters rhsKey]
+[SpecialCharacters contentKey]
+[SpecialCharacters repeatKey]
+[SpecialCharacters suppressPronunciationKey]
+[SpecialCharacters yesString]
+[SpecialCharacters noString]
+[SpecialCharacters defaultSignatureDelimiter]
+[SpecialCharacters suppressPronunciationSuffix]
-[DecomposerDelegate initWithWholeOverrides:partOverrides:]
-[DecomposerDelegate decomposer:decompositionOf:isSubsetOfWhole:]
-[DecomposerDelegate dealloc]
-[NSString(TextParsingHelpers) _isWhitespace]
-[NSString(TextParsingHelpers) _firstWord]
-[NSString(TextParsingHelpers) _withoutExtraWhitespace]
-[NSString(Eliminate_Brackets) _withoutBracketedWords]
+[NegationSlot instanceFromPlist:]
+[NegationSlot negationSlotWithArray:]
-[NegationSlot matches:]
-[NegationSlot description]
-[NegationSlot reversed]
+[SWUtils __dateStringForDate:]
___31+[SWUtils __dateStringForDate:]_block_invoke
+[SWUtils setShouldLogToFilesInDirectory:]
+[SWUtils setShouldUseNikeAppPreferenceKeyForLogging:]
+[SWUtils log:]
+[SWUtils forDefault:log:]
+[SWUtils __logToFileForMessageType:message:arguments:]
+[SWUtils resetLogs]
+[SWUtils nikeUserDefaultsBoolForKey:]
+[SWUtils nikeUserDefaultsStringForKey:]
+[SWUtils nikeUserDefaultsNumberForKey:]
+[SWUtils nikeUserDefaultsSetString:forKey:]
+[SWUtils nikeUserDefaultsRemoveObjectForKey:]
+[SWUtils ensureDirectoryExists:]
_objc_msgSend$shim
_objc_getProperty$shim
_objc_setProperty_atomic$shim
_CFPreferencesAppSynchronize$shim
 stub helpers
___block_descriptor_tmp
___block_literal_global
___block_descriptor_tmp
___block_literal_global
___shouldUseNikeAppPreferenceKeyForLogging
__MergedGlobals
___sharedPlayQueue
___addingItemsNow
__MergedGlobals
_OBJC_CLASS_$_AttributeKey
_OBJC_CLASS_$_Cell
_OBJC_CLASS_$_CompoundSlot
_OBJC_CLASS_$_ConditionalProduction
_OBJC_CLASS_$_Decomposer
_OBJC_CLASS_$_DecomposerDelegate
_OBJC_CLASS_$_Directory
_OBJC_CLASS_$_DisjunctionSlot
_OBJC_CLASS_$_GenericProduction
_OBJC_CLASS_$_GrammarPart
_OBJC_CLASS_$_KleeneSlot
_OBJC_CLASS_$_NegationSlot
_OBJC_CLASS_$_NewProduction
_OBJC_CLASS_$_Parser
_OBJC_CLASS_$_Player
_OBJC_CLASS_$_Rule
_OBJC_CLASS_$_SWUtils
_OBJC_CLASS_$_SimpleSlot
_OBJC_CLASS_$_SimpleSlotSequence
_OBJC_CLASS_$_Slot
_OBJC_CLASS_$_SlotSequence
_OBJC_CLASS_$_SlotsInContext
_OBJC_CLASS_$_SpecialCharacters
_OBJC_IVAR_$_AttributeKey._index
_OBJC_IVAR_$_AttributeKey._key
_OBJC_IVAR_$_Cell._attributes
_OBJC_IVAR_$_Cell._type
_OBJC_IVAR_$_CompoundSlot._slots
_OBJC_IVAR_$_ConditionalProduction._delimiter
_OBJC_IVAR_$_ConditionalProduction._expansions
_OBJC_IVAR_$_ConditionalProduction._signature
_OBJC_IVAR_$_Decomposer._availableSoundFiles
_OBJC_IVAR_$_Decomposer._bundle
_OBJC_IVAR_$_Decomposer._cache
_OBJC_IVAR_$_Decomposer._debugging
_OBJC_IVAR_$_Decomposer._delegate
_OBJC_IVAR_$_Decomposer._iterations
_OBJC_IVAR_$_DecomposerDelegate._overridesForParts
_OBJC_IVAR_$_DecomposerDelegate._overridesForWhole
_OBJC_IVAR_$_Directory._orderedSubparts
_OBJC_IVAR_$_Directory._subparts
_OBJC_IVAR_$_GrammarPart._depth
_OBJC_IVAR_$_GrammarPart._name
_OBJC_IVAR_$_GrammarPart._order
_OBJC_IVAR_$_NewProduction._indices
_OBJC_IVAR_$_NewProduction._overlays
_OBJC_IVAR_$_Parser._debugging
_OBJC_IVAR_$_Parser._grammarsPlist
_OBJC_IVAR_$_Parser._productionRules
_OBJC_IVAR_$_Parser._theGrammar
_OBJC_IVAR_$_Player._bundle
_OBJC_IVAR_$_Player._directory
_OBJC_IVAR_$_Rule._leftHandSide
_OBJC_IVAR_$_Rule._repeat
_OBJC_IVAR_$_Rule._rightHandSide
_OBJC_IVAR_$_SimpleSlot._cell
_OBJC_IVAR_$_SlotSequence._slots
_OBJC_IVAR_$_SlotsInContext._postContext
_OBJC_IVAR_$_SlotsInContext._preContext
_OBJC_IVAR_$_SlotsInContext._preContextReversed
_OBJC_IVAR_$_SlotsInContext._significantSlots
_OBJC_METACLASS_$_AttributeKey
_OBJC_METACLASS_$_Cell
_OBJC_METACLASS_$_CompoundSlot
_OBJC_METACLASS_$_ConditionalProduction
_OBJC_METACLASS_$_Decomposer
_OBJC_METACLASS_$_DecomposerDelegate
_OBJC_METACLASS_$_Directory
_OBJC_METACLASS_$_DisjunctionSlot
_OBJC_METACLASS_$_GenericProduction
_OBJC_METACLASS_$_GrammarPart
_OBJC_METACLASS_$_KleeneSlot
_OBJC_METACLASS_$_NegationSlot
_OBJC_METACLASS_$_NewProduction
_OBJC_METACLASS_$_Parser
_OBJC_METACLASS_$_Player
_OBJC_METACLASS_$_Rule
_OBJC_METACLASS_$_SWUtils
_OBJC_METACLASS_$_SimpleSlot
_OBJC_METACLASS_$_SimpleSlotSequence
_OBJC_METACLASS_$_Slot
_OBJC_METACLASS_$_SlotSequence
_OBJC_METACLASS_$_SlotsInContext
_OBJC_METACLASS_$_SpecialCharacters
_SVPlistErrorDefault
_SVPlistNotificationDefault
_SVSnODetailDefault
_SVSnOMilestoneDefault
_SVSpeakWordsNotificationDefault
_SWUtilsApplicationTraceDefault
_SWUtilsBluetoothTraceDefault
_SWUtilsPacketTraceDefault
_AVAudioSessionCategoryPlayback
_CFGetTypeID
_CFPreferencesAppSynchronize
_CFPreferencesCopyAppValue
_CFPreferencesGetAppBooleanValue
_CFPreferencesGetAppIntegerValue
_CFPreferencesSetAppValue
_CFRelease
_CFStringGetTypeID
_NSLog
_NSLogv
_OBJC_CLASS_$_AVAudioSession
_OBJC_CLASS_$_AVPlayerItem
_OBJC_CLASS_$_AVQueuePlayer
_OBJC_CLASS_$_NSArray
_OBJC_CLASS_$_NSBundle
_OBJC_CLASS_$_NSDate
_OBJC_CLASS_$_NSDateFormatter
_OBJC_CLASS_$_NSDictionary
_OBJC_CLASS_$_NSFileHandle
_OBJC_CLASS_$_NSFileManager
_OBJC_CLASS_$_NSMutableArray
_OBJC_CLASS_$_NSMutableDictionary
_OBJC_CLASS_$_NSMutableString
_OBJC_CLASS_$_NSNumber
_OBJC_CLASS_$_NSObject
_OBJC_CLASS_$_NSPropertyListSerialization
_OBJC_CLASS_$_NSString
_OBJC_CLASS_$_NSURL
_OBJC_CLASS_$_NSUserDefaults
_OBJC_METACLASS_$_NSObject
__NSConcreteGlobalBlock
___CFConstantStringClassReference
___stack_chk_fail
___stack_chk_guard
__objc_empty_cache
__objc_empty_vtable
_dispatch_once
_objc_enumerationMutation
_objc_getProperty
_objc_msgSend
_objc_msgSendSuper2
_objc_setProperty_atomic
_open
dyld_stub_binder
