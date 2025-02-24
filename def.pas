{ global scope definitions, memory, constants, variables, common procedures }

unit Def;

interface

  type
    ptrb = ^byte;		{ unsigned 8-bit }
    ptrw = ^word;		{ unsigned 16-bit }
    ptrshort = ^shortint;	{ signed 8-bit }
    ptrsmall = ^smallint;	{ unsigned 16-bit }

  const
    IniName: string = 'mk85m.ini';

{ indexes to the 'reg' table }
    R0		= 0*2;
    R1		= 1*2;
    R2		= 2*2;
    R3		= 3*2;
    R4		= 4*2;
    R5		= 5*2;
    R6		= 6*2;
    R7		= 7*2;

{ status bits }
    H_bit	= $100;	{ HALT/USER mode }
    I_bit	= $80;	{ interrupt priority }
    T_bit	= $10;
    N_bit	= $08;
    Z_bit	= $04;
    V_bit	= $02;
    C_bit	= $01;
    NZ_bit	= $0C;	{ N+Z }
    VC_bit	= $03;	{ V+C }
    NZV_bit	= $0E;	{ N+Z+V }
    NZVC_bit	= $0F;	{ N+Z+V+C }

{ ROM address space }
    ROMSTART	= $0000;
    ROMSIZE	= $8000;
    ROMEND	= ROMSTART + ROMSIZE - 1;
{ RAM address space }
    RAMSTART	= $8000;
    MINRAMSIZE	= $0800;
    MAXRAMSIZE	= $8000;
{ LCD memory address space }
    LCDSTART    = $0080;
    LCDSIZE     = $0080;
    LCDEND      = LCDSTART + LCDSIZE - 1;

{ HALT mode register }
    SEL		= $0000;

    HALT_VECTOR	= $0078;

    dummysrc: array[0..2] of byte	{ free adress space }
	= ($00, $00, $00);

  var
    dummydst: array[0..2] of byte;	{ free address space }
    rom: array[0..ROMSIZE-1] of byte;
    ram: array[0..MAXRAMSIZE-1] of byte;
    RamSize: word;
    RamEnd: word;			{ = RAMSTART + RamSize - 1 }
    CloseMode: integer;                 { Режим закрытия программы 0 - Выключатель, 1 - Выключатель - это сброс, закрытие через отдельную кнопку "X"}
    Contrast:integer;                   { Контрасность скрытых элементов LCD }
    Autorun:integer;                    { Автозапуск программы }
    VarSize:word;                       { Количество зарезервированных переменных при создании нового RAM}
    DelayResetKey:word;                 { Для эмуляции удержания клавиши в автодебаге }
    reg: array[0..15] of byte;
    lcd: array[0..LCDSIZE-1] of byte;	{ LCD controller port }
    kbdcols: word;              	{ keyboard input port $0100 }
    kbdrows: word;			{ keyboard output port $0102 }
    cpuctrl: word;			{ CPU control register $0104 }
    psw: word;
    code: word;
    cpc: word;				{ HALT-mode register storing the PC }
    cps: word;				{ HALT-mode register storing the PSW }
    RTT_flag: boolean;			{ true when RTT instruction executed }
    WAIT_flag: boolean;			{ true when WAIT instruction executed }
    STEP_flag: boolean;			{ true when STEP instruction executed }
    RESET_flag: boolean;		{ true when RESET instruction executed,
					  no function in the MK-85 }
    HALT_i, EVNT_i: boolean;		{ hardware interrupt request flags }
    PowerState:boolean;            { Питание включено (true), выключено (false) }
    MemLoadResult:integer;         { Результат загрузки RomName }
    KeyCode1: integer;		{ from the mouse }
    KeyCode2: integer;		{ from the keyboard }
    CpuStop: boolean;		{ True stops the CPU }
    CpuDelay: integer;		{ delay after hiding the Debug Window,
				  prevents the program from crashing when the
				  Debug Window was made visible too early }
    CpuSteps: integer;		{ ignored when < 0 }
    BreakPoint: integer;	{ ignored when < 0 }
    loc: word; 			{ address of the resource }


  function IsInRom (address: word) : boolean;
  function IsInRam (address: word) : boolean;
  function SrcPtr : pointer;
  function DstPtr : pointer;


implementation

  uses Keyboard;


{ test if the given address is within the ROM address space }
function IsInRom (address: word) : boolean;
begin
  IsInRom := address <= ROMEND;
end {IsInRom};


{ test if the given address is within the RAM address space }
function IsInRam (address: word) : boolean;
begin
  IsInRam := (address >= RAMSTART) and (address <= RamEnd);
end {IsInRam};


{ function returns the pointer to the 'read' type resource at address 'loc' }
  function SrcPtr : pointer;
  begin
    if IsInRam (loc) then
	SrcPtr := @ram[loc-RAMSTART]
    else if (loc<$0100) or ((loc>=$0108) and (loc<=ROMEND)) then
	SrcPtr := @rom[loc]
    else if loc=$0100 then SrcPtr := KeyRead
    else if loc=$0104 then SrcPtr := @cpuctrl
    else SrcPtr := @dummysrc;
  end {SrcPtr};


{ function returns the pointer to the 'write' type resource at address 'loc' }
  function DstPtr : pointer;
  begin
    if IsInRam (loc) then
	DstPtr := @ram[loc-RAMSTART]
    else if (loc>=LCDSTART) and (loc<=LCDEND) then
      DstPtr := @lcd[loc-LCDSTART]
    else if loc=$0102 then DstPtr := @kbdrows
    else if loc=$0104 then DstPtr := @cpuctrl
    else DstPtr := @dummydst;
  end {DstPtr};


end.
