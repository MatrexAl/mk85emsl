unit Keyboard;

interface

type

  keyblock = record
    L: integer;		{ left }
    T: integer;		{ top }
    W: integer;		{ width of the key }
    H: integer;		{ height of the key }
    SX: integer;	{ horizontal spacing }
    SY: integer;	{ vertical spacing }
    col: integer;	{ number of columns }
    cnt: integer;	{ number of keys in a block }
    OX: integer;	{ left in the Keys.bmp }
    OY: integer;	{ top in the Keys.bmp }
  end;

  function KeyRead : pointer;

const

  KEYPADS = 4;		{index of the last item in the 'keypad' array}
  LASTKEYCODE = 55;

  keypad: array[0..KEYPADS] of keyblock = (
{ power switch, code:1 }
    (	L:83;	T:149;	W:29;	H:31;	SX:52;	SY:42;	col:1;	cnt:1;	OX:159;	OY:0	),
{ first row of white keys, code:2..6 }
    (	L:283;	T:158;	W:36;	H:21;	SX:52;	SY:42;	col:5;	cnt:5;	OX:123;	OY:0	),
{ next three rows of white keys, code: 7..36 }
    (	L:23;	T:200;	W:36;	H:21;	SX:52;	SY:42;	col:10;	cnt:30;	OX:123;	OY:0	),
{ dark keys except EXE, code: 37..54 }
    (	L:545;	T:83;	W:36;	H:28;	SX:51;	SY:49;	col:4;	cnt:18;	OX:87;	OY:0	),
{ EXE key, code: 55 }
    (	L:647;	T:279;	W:87;	H:28;	SX:102;	SY:49;	col:1;	cnt:1;	OX:0;	OY:0	)
  );


implementation

uses Def;

{ tables convert KeyCode1 and KeyCode2 to the keyboard columns state }
const

{ keyboard row 1 }
  KeyTab1: array[0..LASTKEYCODE+1] of word = (
	$0000,					{ no key pressed }
	$0000,					{ power switch }
	$0000, $0000, $0000, $0000, $0000,	{ MODE <- -> [S] [F] }
	$0000, $0000, $0000, $0000, $0000,	{ Q W E R T }
	$0000, $0000, $0000, $0000, $0000,	{ Y U I O P }
	$0000, $0000, $0000, $0000, $0000,	{ A S D F G }
	$0000, $0000, $0000, $0000, $0000,	{ H J K L ANS }
	$0000, $0000, $0000, $0000, $0000,	{ Z X C V B }
	$0000, $0000, $0000, $0000, $0000,	{ N M spc = EE }
	$000C, $0014, $0000, $0024,		{ AC DEL STOP / }
	$0028, $0030, $0044, $0048,		{ 7 8 9 * }
	$0050, $0060, $0084, $0088,		{ 4 5 6 - }
	$0090, $00A0, $00C0, $0104,		{ 1 2 3 + }
	$0108, $0110, $0120,			{ 0 . EXE }
	$0018 );				{ INIT }

{ keyboard row 2 }
  KeyTab2: array[0..LASTKEYCODE+1] of word = (
	$0000,					{ no key pressed }
	$0000,					{ power switch }
	$000C, $0014, $0018, $0024, $0028,	{ MODE <- -> [S] [F] }
	$0000, $0000, $0000, $0000, $0000,	{ Q W E R T }
	$0030, $0044, $0048, $0050, $0060,	{ Y U I O P }
	$0000, $0000, $0000, $0000, $0000,	{ A S D F G }
	$0084, $0088, $0090, $00A0, $00C0,	{ H J K L ANS }
	$0000, $0000, $0000, $0000, $0000,	{ Z X C V B }
	$0108, $0104, $0110, $0120, $0140,	{ N M spc = EE }
	$0000, $0000, $0000, $0000,		{ AC DEL STOP / }
	$0000, $0000, $0000, $0000,		{ 7 8 9 * }
	$0000, $0000, $0000, $0000,		{ 4 5 6 - }
	$0000, $0000, $0000, $0000,		{ 1 2 3 + }
	$0000, $0000, $0000,			{ 0 . EXE }
	$0000 );				{ INIT }

{ keyboard row 3 }
  KeyTab3: array[0..LASTKEYCODE+1] of word = (
	$0000,					{ no key pressed }
	$0000,					{ power switch }
	$0000, $0000, $0000, $0000, $0000,	{ MODE <- -> [S] [F] }
	$0044, $000C, $0018, $0090, $00A0,	{ Q W E R T }
	$0000, $0000, $0000, $0000, $0000,	{ Y U I O P }
	$0088, $0014, $0050, $0024, $0028,	{ A S D F G }
	$0000, $0000, $0000, $0000, $0000,	{ H J K L ANS }
	$0030, $0048, $0084, $00C0, $0060,	{ Z X C V B }
	$0000, $0000, $0000, $0000, $0000,	{ N M spc = EE }
	$0000, $0000, $0000, $0000,		{ AC DEL STOP / }
	$0000, $0000, $0000, $0000,		{ 7 8 9 * }
	$0000, $0000, $0000, $0000,		{ 4 5 6 - }
	$0000, $0000, $0000, $0000,		{ 1 2 3 + }
	$0000, $0000, $0000,			{ 0 . EXE }
	$0000 );				{ INIT }

{ the STOP key is selected by row 1 }

{ the INIT key has code 56, but is unassigned yet }


  function KeyRead : pointer;
  var
    k: integer;
  begin
    if KeyCode2 <> 0 then k := KeyCode2 else k := KeyCode1;
    kbdcols := 0;
    if (kbdrows and $0002) <> 0 then kbdcols := kbdcols or KeyTab1[k];
    if (kbdrows and $0004) <> 0 then kbdcols := kbdcols or KeyTab2[k];
    if (kbdrows and $0008) <> 0 then kbdcols := kbdcols or KeyTab3[k];
    KeyRead := @kbdcols;
  end {KeyRead};

end.
