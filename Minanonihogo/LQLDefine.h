//
//  LQLDefine.h
//  Minanonihogo
//
//  Created by Le Quang Long on 5/14/15.
//  Copyright (c) 2015 Kakaruchi. All rights reserved.
//

#ifndef Minanonihogo_LQLDefine_h
#define Minanonihogo_LQLDefine_h

#define INTERFACE_IS_PAD     ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
#define INTERFACE_IS_PHONE   ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

#define LZ_MNLocalString(key) NSLocalizedString(key, nil)


///LOCALIZABLE STRING
#define LZ_HIRAGANA_TABNAME LZ_MNLocalString(@"LZ_HIRAGANA_TABNAME")
#define LZ_KATAKANA_TABNAME LZ_MNLocalString(@"LZ_KATAKANA_TABNAME")
#define LZ_LESSON_TEXT      LZ_MNLocalString(@"LZ_LESSON")
#endif
