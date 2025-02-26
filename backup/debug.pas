unit Debug;

interface

uses
  SysUtils, Classes, Graphics, Controls, Forms, Dialogs, StdCtrls, ExtCtrls,
  IniFiles, LCLType, Buttons, Clipbrd, ActnList, ComCtrls, Menus, asm2Rom;

type

  { TDebugForm }

  TDebugForm = class(TForm)
    aCopyAddr: TAction;
    aAnimate: TAction;
    aBreakPoint: TAction;
    aByteWordToogle: TAction;
    aNumberOfStep: TAction;
    aStep: TAction;
    alActionList: TActionList;
    Bevel1: TBevel;
    Bevel2: TBevel;
    cbDisassemply: TGroupBox;
    cbRegisters: TGroupBox;
    gbBinEditor: TGroupBox;
    ilEnabledButtonIcon: TImageList;
    ListPanel: TPanel;
    ListPaintBox: TPaintBox;
    ListScrollBar: TScrollBar;
    ListEdit: TEdit;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    Separator3: TMenuItem;
    Separator2: TMenuItem;
    Separator1: TMenuItem;
    Panel1: TPanel;
    ppPopupMenu: TPopupMenu;

    RegPanel: TPanel;
    RegPaintBox: TPaintBox;
    RegScrollBar: TScrollBar;
    RegEdit: TEdit;

    BinPanel: TPanel;
    BinPaintBox: TPaintBox;
    BinScrollBar: TScrollBar;
    BinEdit: TEdit;

    AutoRunTimer: TTimer;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;


    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    ToolButton7: TToolButton;
    ToolButton8: TToolButton;
    ToolButton9: TToolButton;

    { DISASSEMBLY BOX EVENTS }
    procedure aAnimateExecute(Sender: TObject);
    procedure aBreakPointExecute(Sender: TObject);
    procedure aByteWordToogleExecute(Sender: TObject);
    procedure aCopyAddrExecute(Sender: TObject);
    procedure aNumberOfStepExecute(Sender: TObject);
    procedure aStepExecute(Sender: TObject);
    procedure btAutoRunMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: integer);
    procedure ListPanelClick(Sender: TObject);
    procedure ListBoxScroll(Sender: TObject; ScrollCode: TScrollCode; var ScrollPos: integer);
    procedure ListPaintBoxMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: integer);
    procedure ListEditKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
    procedure ListEditChange(Sender: TObject);
    procedure ListPaintBoxPaint(Sender: TObject);


    { REGISTER BOX EVENTS }
    procedure RegPanelClick(Sender: TObject);
    procedure RegBoxScroll(Sender: TObject; ScrollCode: TScrollCode; var ScrollPos: integer);
    procedure RegPaintBoxMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: integer);
    procedure RegEditKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
    procedure RegEditChange(Sender: TObject);
    procedure RegPaintBoxPaint(Sender: TObject);

    { BINARY EDITOR BOX EVENTS }
    procedure BinPanelClick(Sender: TObject);
    procedure BinBoxScroll(Sender: TObject; ScrollCode: TScrollCode; var ScrollPos: integer);
    procedure BinPaintBoxMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: integer);
    procedure BinEditKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
    procedure BinEditChange(Sender: TObject);
    procedure BinPaintBoxPaint(Sender: TObject);
    procedure BinRadioButtonClick(Sender: TObject);

    { MACHINE CODE EXECUTION CONTROL EVENTS }
    procedure StepPanelClick(Sender: TObject);
    procedure StepButtonClick(Sender: TObject);
    procedure AutoRunTimerTimer(Sender: TObject);
    procedure TracePanelClick(Sender: TObject);
    procedure BpPanelClick(Sender: TObject);
    procedure BpButtonClick(Sender: TObject);
    procedure BpEditChange(Sender: TObject);

    { GENERAL FORM EVENTS }
    procedure DebugCreate(Sender: TObject);
    procedure DebugShow(Sender: TObject);
    procedure DebugHide(Sender: TObject);

  private
    aOldFlag: array [0..4] of string;
    aOldReg: array [0..8] of string;
    function GetRem(const addr: integer): string;
    function LoadBreakPoint: string;
    function LoadNumnerOfSteps: integer;
    procedure SaveBreakPoint(const i: string);
    procedure SaveNumnerOfSteps(const i: integer);
    { Private declarations }
  public
    Autorun: boolean;
    Rem: TRemDictionary;
    { Public declarations }
  end;


var
  DebugForm: TDebugForm;
  RomChanged: boolean = False;

implementation

{$R *.dfm}

uses Def, Numbers, Pdp11dis, Cpu;

const
  SELECTED = clBlue;

var
  BinAddr: word;
  ListAddr: word;
  ListStartAddr: word;
  ListEndAddr: word;
  RegAddr: word;

  EditState: (NoEditSt, ListAddrEditSt, ListInstrEditSt, RegEditSt, PSWEditSt, BinAddrEditSt, BinDataEditSt, BinCharEditSt);
  EditAddr: word;  {address of the edited object - memory location, register}

  BinDataSize: integer = 1;

{ set the font color of all TGrupBox controls to default }
procedure Unselect;
begin
  with DebugForm do
  begin
    cbDisassemply.Font.Color := clWindowText;
    cbRegisters.Font.Color := clWindowText;
    gbBinEditor.Font.Color := clWindowText;
  end {with};
end {Unselect};


procedure BoxEdit(box: TPaintBox; ed: TEdit; Col, Row, W: integer);
var
  cx, cy, L, T: integer;
begin
  with box do
  begin
    cx := Canvas.TextWidth('0');
    cy := Canvas.TextHeight('0');
    L := Left;
    T := Top;
  end {with};
  with ed do
  begin
    Left := L + Col * cx;
    Top := T + Row * cy;
    Width := cx * W;
    Height := cy;
    MaxLength := W;
    Text := '';
  end {with};
end {BoxEdit};


{ remove digits out of specified range from the edited string }
procedure CheckEdit(ed: TEdit; limit: integer);
var
  i: integer;
  s: string;
begin
  with ed do
  begin
    if Modified then
    begin
      s := Text;
      i := 1;
      while i <= Length(s) do
      begin
        if GetDigit(s[i]) >= limit then Delete(s, i, 1)
        else
          Inc(i);
      end {while};
      Text := s;
    end {if};
  end {with};
end {CheckEdit};


procedure CloseEdit;
begin
  EditState := NoEditSt;
  with DebugForm do
  begin
    with ListEdit do
    begin
      Text := '';
      Width := 0;
      Left := 0;
      Top := 0;
    end {with};
    with RegEdit do
    begin
      Text := '';
      Width := 0;
      Left := 0;
      Top := 0;
    end {with};
    with BinEdit do
    begin
      Text := '';
      Width := 0;
      Left := 0;
      Top := 0;
    end {with};
    ListPaintBox.Invalidate;
    RegPaintBox.Invalidate;
    BinPaintBox.Invalidate;
  end {with};
end {CloseEdit};


{ expects the new disassembly address,
  sets new values of ListAddr, ListStartAddr, ListEndAddr }
procedure SetListBoundaries(addr: word);
begin
  ListAddr := addr and $FFFE;
  if IsInRom(ListAddr) then
  begin
    ListStartAddr := ROMSTART;
    ListEndAddr := ROMEND;
  end
  else if IsInRam(ListAddr) then
  begin
    ListStartAddr := RAMSTART;
    ListEndAddr := RamEnd;
  end
  else {out of allowed address space}
  begin
    ListAddr := ROMSTART;
    ListStartAddr := ROMSTART;
    ListEndAddr := ROMEND;
  end {if};
end {SetListBoundaries};


{ scrolling with the arrow keys,
  returns new value for Position or -1 when Position hasn't changed }
function ArrowKeys(Key: word; sb: TScrollBar): integer;
begin
  with sb do
  begin
    Result := Position;
    case Key of
      VK_HOME: Result := Min;
      VK_PRIOR: Dec(Result, LargeChange);
      VK_UP: Dec(Result, SmallChange);
      VK_DOWN: Inc(Result, SmallChange);
      VK_NEXT: Inc(Result, LargeChange);
      VK_END: Result := Max;
    end {case};
    if Result < Min then Result := Min
    else if Result > Max then Result := Max;
    if Result = Position then Result := -1;
  end {with};
end;


{ DISASSEMBLY BOX EVENTS }

procedure TDebugForm.ListPanelClick(Sender: TObject);
begin
  ListEdit.SetFocus;
  Unselect;
  cbDisassemply.Font.Color := SELECTED;
  CloseEdit;
end;



procedure TDebugForm.btAutoRunMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: integer);
begin

end;

procedure TDebugForm.aCopyAddrExecute(Sender: TObject);
begin
  Clipboard.AsText := OctStr(ListAddr, 6);
end;


function TDebugForm.LoadNumnerOfSteps: integer;
var
  IniMK: TIniFile;
begin
  IniMK := TIniFile.Create(ExpandFileName(IniName));
  Result := IniMK.ReadInteger('Debugger', 'NumberOfStep', 1);
  FreeAndNil(IniMK);
end;

procedure TDebugForm.SaveNumnerOfSteps(const i: integer);
var
  IniMK: TIniFile;
begin
  IniMK := TIniFile.Create(ExpandFileName(IniName));
  IniMK.WriteInteger('Debugger', 'NumberOfStep', i);
  FreeAndNil(IniMK);
end;



function TDebugForm.LoadBreakPoint: string;
var
  IniMK: TIniFile;
begin
  IniMK := TIniFile.Create(ExpandFileName(IniName));
  Result := IniMK.ReadString('Debugger', 'BreakPoint', '0000');
  FreeAndNil(IniMK);
end;

procedure TDebugForm.SaveBreakPoint(const i: string);
var
  IniMK: TIniFile;
begin
  IniMK := TIniFile.Create(ExpandFileName(IniName));
  IniMK.WriteString('Debugger', 'BreakPoint', i);
  FreeAndNil(IniMK);
end;


procedure TDebugForm.aNumberOfStepExecute(Sender: TObject);
var
  i: integer;
  UserString: string;
begin
  UserString := IntToStr(LoadNumnerOfSteps);
  if InputQuery('Number of step', '', False, UserString) then
  begin
    i := GetValue(UserString, 10);
    SaveNumnerOfSteps(i);
    Unselect;
    CloseEdit;
    if i > 0 then
    begin
      BreakPoint := -1;
      CpuSteps := i;
      Hide;
    end {if};
  end;
end;

procedure TDebugForm.aAnimateExecute(Sender: TObject);
begin
  autorun := not autorun;
  aAnimate.Checked := autorun;
  AutoRunTimerTimer(Sender);
end;

procedure TDebugForm.aBreakPointExecute(Sender: TObject);
var
  i: integer;
  UserString: string;
begin
  UserString := LoadBreakPoint;
  if InputQuery('Breakpoint address', '', False, UserString) then
  begin
    i := GetValue(UserString, radix);
    SaveBreakPoint(UserString);
    Unselect;
    CloseEdit;
    BreakPoint := i;
    CpuSteps := -1;
    Hide;
  end;
end;



procedure TDebugForm.aByteWordToogleExecute(Sender: TObject);
var
  t: integer;
begin
  aByteWordToogle.Checked := not (aByteWordToogle.Checked);
  if aByteWordToogle.Checked then t := 2
  else
    t := 1;
  BinDataSize := t;
  BinEdit.SetFocus;
  Unselect;
  gbBinEditor.Font.Color := SELECTED;
  CloseEdit;
end;

procedure TDebugForm.aStepExecute(Sender: TObject);
begin
  CpuRun;
  SetListBoundaries(ptrw(@reg[R7])^);
  Unselect;
  CloseEdit;
end;




procedure TDebugForm.ListBoxScroll(Sender: TObject; ScrollCode: TScrollCode; var ScrollPos: integer);
var
  x: word;
begin
  { Lazarus: the value of ScrollPos may be outside the Min..Max range }
  with ListScrollBar do
    if ScrollPos > Max then x := word(Max)
    else
      x := word(ScrollPos);
  if IsInRam(ListAddr) then
    ListAddr := 2 * x + RAMSTART
  else
    ListAddr := 2 * x + ROMSTART;
  ListEdit.SetFocus;
  Unselect;
  cbDisassemply.Font.Color := SELECTED;
  CloseEdit;
end;


procedure TDebugForm.ListPaintBoxMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: integer);
var
  Col, Row, cols, rows, i, w: integer;
  opcode: word;
  cx, cy: integer;  { font size in pixels }
begin
  ListEdit.SetFocus;
  Unselect;
  cbDisassemply.Font.Color := SELECTED;
  CloseEdit;
  with ListPaintBox do
  begin
    cx := Canvas.TextWidth('0');
    cy := Canvas.TextHeight('0');
    cols := Width div cx;
    rows := Height div cy;
    Col := X div cx;
    Row := Y div cy;
  end {with};
  if Row >= rows then Exit;
  if (Col < wordwidth) and (Row = 0) then
  begin
    EditState := ListAddrEditSt;
    EditAddr := ListAddr;
    Col := 0;
    w := wordwidth;
    ListEdit.CharCase := ecUpperCase;
  end

  else if (Col >= wordwidth + 2) and (Col < cols) then
  begin
    loc := ListAddr;
    i := 0;
    while i < Row do
    begin
{ move the 'loc' to the next instruction, i.e. disassemble a single
  instruction without generating any output }
      opcode := FetchWord;
      Arguments(ScanMnemTab(opcode), opcode);
      if (loc > ListEndAddr) or ((not loc and ListAddr) >= $8000) {wrapped?} then Exit;
      Inc(i);
    end {while};
    EditAddr := loc;
    EditState := ListInstrEditSt;
    Col := wordwidth + 2+8;
    w := cols - wordwidth - 2;
    ListEdit.CharCase := ecNormal;
  end
  else
  begin
    Exit;
  end {if};
  BoxEdit(ListPaintBox, ListEdit, Col, Row, w);
end;


procedure TDebugForm.ListEditKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
var
  i: integer;
begin
  i := ArrowKeys(Key, ListScrollBar);
  if (i >= 0) and (EditState = NoEditSt) then
  begin
    if IsInRam(ListAddr) then
      ListAddr := 2 * word(i) + RAMSTART
    else
      ListAddr := 2 * word(i) + ROMSTART;
    ListPaintBox.Invalidate;
  end

  else if Key = VK_RETURN then
  begin
    if EditState = ListAddrEditSt then
    begin
      SetListBoundaries(GetValue(ListEdit.Text, radix));
      CloseEdit;
    end
    else if EditState = ListInstrEditSt then
    begin
      loc := EditAddr;
      InBuf := ListEdit.Text;
      Assemble;
      if InIndex = 0 then
      begin
        i := 0;
        while i < OutIndex do
        begin
          StoreWord(OutBuf[i]);
          Inc(i);
        end {while};
        RomChanged := True;
        CloseEdit;
      end
      else
      begin
        { position the cursor just before the first offending character }
        ListEdit.SelStart := InIndex - 1;
      end {if};
    end {if};
  end

  else if key = VK_ESCAPE then CloseEdit;
end;


procedure TDebugForm.ListEditChange(Sender: TObject);
begin
  if EditState = ListAddrEditSt then CheckEdit(ListEdit, radix);
end;

function TDebugForm.GetRem(const addr: integer): string;
begin
  Result := '';
  if Rem.ContainsKey(addr) then
    Result := Rem[addr];
end;


procedure TDebugForm.ListPaintBoxPaint(Sender: TObject);
var
  i, rows, index: integer;
  opcode: word;
  c: char;
  cx, cy: integer;  { font size in pixels }
  rm: string;
begin

  loc := ListAddr;

  with ListPaintBox do
  begin
    Canvas.Brush.Style := bsSolid;
    Canvas.Brush.Color := Color;
    cx := Canvas.TextWidth('0');
    cy := Canvas.TextHeight('0');
    rows := Height div cy;
  end {with};
  with ListPaintBox.Canvas do
  begin
    for i := 0 to rows - 1 do
    begin
      if (loc > ListEndAddr) or ((not loc and ListAddr) >= $8000) {wrapped?} then break;
      TextOut(0, i * cy, WordToStr(loc, '0') + ':');
      TextOut(6 * cx, i * cy, OctStr(loc, 6) + ':');

      rm := GetRem(loc);
      opcode := FetchWord;
      index := ScanMnemTab(opcode);
      if (opcode and $8000) = 0 then c := ' '
      else
        c := 'b';
      TextOut(14 * cx, i * cy, Mnemonic(index, c));
      TextOut(22 * cx, i * cy, Arguments(index, opcode));
      TextOut(40 * cx, i * cy, rm);

    end {for};
  end {with};
  { set the scroll bar }
  with ListScrollBar do
  begin
    SetParams((ListAddr - ListStartAddr) div 2, 0,
      (ListEndAddr - ListStartAddr) div 2);
    if loc < ListEndAddr then
      LargeChange := (loc - ListAddr) div 2;
  end {with};
end;



{ REGISTER BOX EVENTS }

const
  REGROWS = 9;
  regname: array[0..REGROWS - 1] of string[4] =
    ('R0:', 'R1:', 'R2:', 'R3:', 'R4:', 'R5:', 'SP:', 'PC:', 'PSW:');
  flagname: array[0..4] of char =
    ('T', 'N', 'Z', 'V', 'C');
  flagmask: array[0..4] of word =
    (T_bit, N_bit, Z_bit, V_bit, C_bit);


procedure TDebugForm.RegPanelClick(Sender: TObject);
begin
  RegEdit.SetFocus;
  Unselect;
  cbRegisters.Font.Color := SELECTED;
  CloseEdit;
end;


procedure TDebugForm.RegBoxScroll(Sender: TObject; ScrollCode: TScrollCode; var ScrollPos: integer);
begin
  { Lazarus: the value of ScrollPos may be outside the Min..Max range }
  with RegScrollBar do
    if ScrollPos > Max then RegAddr := word(Max)
    else
      RegAddr := word(ScrollPos);
  RegEdit.SetFocus;
  Unselect;
  cbRegisters.Font.Color := SELECTED;
  CloseEdit;
end;


procedure TDebugForm.RegPaintBoxMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: integer);
var
  Col, Row, rows: integer;
  cx, cy: integer;  { font size in pixels }
begin
  RegEdit.SetFocus;
  Unselect;
  cbRegisters.Font.Color := SELECTED;
  CloseEdit;
  with RegPaintBox do
  begin
    cx := Canvas.TextWidth('0');
    cy := Canvas.TextHeight('0');
    rows := Height div cy;
    Col := X div cx;
    Row := Y div cy;
  end {with};
  if rows > REGROWS + 1 then rows := REGROWS + 1;
  if (Col >= 4) and (Col < 4 + wordwidth) and (Row < rows - 1) then
  begin
    EditState := RegEditSt;
    EditAddr := word(Row) + RegAddr;
    BoxEdit(RegPaintBox, RegEdit, 4, Row, wordwidth);
  end {if};
end;


procedure TDebugForm.RegEditKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
var
  i: integer;
  x: word;
begin
  i := ArrowKeys(Key, RegScrollBar);
  if (i >= 0) and (EditState = NoEditSt) then
  begin
    RegAddr := word(i);
    RegPaintBox.Invalidate;
  end

  else if Key = VK_RETURN then
  begin
    if EditState = RegEditSt then
    begin
      x := GetValue(RegEdit.Text, radix);
      if EditAddr < 6 then ptrw(@reg[2 * EditAddr])^ := x
      else if EditAddr < 8 then ptrw(@reg[2 * EditAddr])^ := x and $FFFE
      else
        psw := x;
      CloseEdit;
    end {if};
  end

  else if Key = VK_ESCAPE then CloseEdit;
end;


procedure TDebugForm.RegEditChange(Sender: TObject);
begin
  CheckEdit(RegEdit, radix);
end;


procedure TDebugForm.RegPaintBoxPaint(Sender: TObject);
var
  i, rows: integer;
  c: char;
  x: word;
  cx, cy: integer;  { font size in pixels }
  o, w: string;
begin
  with RegPaintBox do
  begin
    Canvas.Brush.Style := bsSolid;
    Canvas.Brush.Color := Color;
    cx := Canvas.TextWidth('0');
    cy := Canvas.TextHeight('0');
    rows := Height div cy;
  end {with};
  if rows > REGROWS + 1 then rows := REGROWS + 1;
  with RegPaintBox.Canvas do
  begin
    // Рисуем флаги
    RegPaintBox.Canvas.Font.Color := clBlack;
    { unscrollable Flags register bits }
    for i := 0 to 4 do
    begin
      if (psw and flagmask[i]) = 0 then c := '-'
      else
        c := flagname[i];
      RegPaintBox.Canvas.Font.Color := clBlack;
      if c <> aOldFlag[i] then RegPaintBox.Canvas.Font.Color := clRed;
      TextOut(i * cx, (rows - 1) * cy, c);
      aOldFlag[i] := c;
    end {for};


    // Рисуем регистры
    { other cbRegisters, scrollable }
    for i := 0 to rows - 2 do
    begin

      if i + RegAddr = 8 then x := psw
      else
        x := ptrw(@reg[(i + RegAddr) * 2])^;
      w := WordToStr(x, '0');
      o := OctStr(x, 6);

      RegPaintBox.Canvas.Font.Color := clBlack;
      if w <> aOldreg[i] then RegPaintBox.Canvas.Font.Color := clRed;
      TextOut(0, i * cy, regname[i + RegAddr]);
      TextOut(4 * cx, i * cy, w);
      TextOut(9 * cx, i * cy, o);
      aOldreg[i] := w;

    end {for};
  end {with};
  { set the scroll bar }
  with RegScrollBar do
  begin
    SetParams(RegAddr, 0, REGROWS + 1 - rows);
    LargeChange := rows - 1;
  end {with};
end;



{ BINARY EDITOR BOX EVENTS }

procedure TDebugForm.BinPanelClick(Sender: TObject);
begin
  BinEdit.SetFocus;
  Unselect;
  gbBinEditor.Font.Color := SELECTED;
  CloseEdit;
end;


procedure TDebugForm.BinBoxScroll(Sender: TObject; ScrollCode: TScrollCode; var ScrollPos: integer);
begin
  { Lazarus: the value of ScrollPos may be outside the Min..Max range }
  with BinScrollBar do
    if ScrollPos > Max then BinAddr := word(Max)
    else
      BinAddr := word(ScrollPos);
  BinAddr := BinAddr * 16 + RAMSTART;
  BinEdit.SetFocus;
  Unselect;
  gbBinEditor.Font.Color := SELECTED;
  CloseEdit;
end;


procedure TDebugForm.BinPaintBoxMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: integer);
var
  Col, Row, rows, j, w, z: integer;
  cx, cy: integer;  { font size in pixels }
begin
  BinEdit.SetFocus;
  Unselect;
  gbBinEditor.Font.Color := SELECTED;
  CloseEdit;
  with BinPaintBox do
  begin
    cx := Canvas.TextWidth('0');
    cy := Canvas.TextHeight('0');
    rows := Height div cy;
    Col := X div cx;
    Row := Y div cy;
  end {with};
  j := wordwidth + 16 * bytewidth + 18;    { column of characters }
  if BinDataSize = 2 then w := wordwidth
  else
    w := bytewidth;
  z := BinDataSize * (bytewidth + 1);    { raster of binary data }
  if Row >= rows then Exit;
  if (Row = 0) and (Col < wordwidth) then
  begin        {select BinAddr edition}
    EditState := BinAddrEditSt;
    EditAddr := 0;
    Col := 0;
    w := wordwidth;
    BinEdit.CharCase := ecUpperCase;
  end
  else if (Col >= wordwidth + 2) and (Col < j) and (((Col - wordwidth - 2) mod z) < w) then
  begin        {select binary data edition in the BinBox}
    Col := (Col - wordwidth - 2) div z;
    EditAddr := BinAddr + word(16 * Row + BinDataSize * Col);
    if not IsInRam(EditAddr) then Exit;
    Col := Col * z + wordwidth + 2;
    EditState := BinDataEditSt;
    BinEdit.CharCase := ecUpperCase;
  end
  else if (Col >= j) and (Col < j + 16) then
  begin        {select character edition in the BinBox}
    EditAddr := BinAddr + word(16 * Row + Col - j);
    if not IsInRam(EditAddr) then Exit;
    EditState := BinCharEditSt;
    w := 1;
    BinEdit.CharCase := ecNormal;
  end
  else
  begin
    Exit;
  end {if};
  BoxEdit(BinPaintBox, BinEdit, Col, Row, w);
end;


procedure TDebugForm.BinEditKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
var
  i: integer;
  x, rows: word;
begin
  with BinPaintBox do
  begin
    rows := word(Height div Canvas.TextHeight('0'));
  end {with};

  i := ArrowKeys(Key, BinScrollBar);
  if (i >= 0) and (EditState = NoEditSt) then
  begin
    BinAddr := 16 * word(i) + RAMSTART;
    BinPaintBox.Invalidate;
  end

  else if Key = VK_RETURN then
  begin
    if EditState = BinAddrEditSt then
    begin
      x := GetValue(BinEdit.Text, radix) and $FFF0;
      if IsInRam(x) and IsInRam(x + 16 * rows) then BinAddr := x;
      CloseEdit;
    end
    else if EditState = BinDataEditSt then
    begin
      if BinDataSize = 2 then
        ptrw(@ram[EditAddr - RAMSTART])^ := word(GetValue(BinEdit.Text, radix))
      else
        ram[EditAddr - RAMSTART] := byte(GetValue(BinEdit.Text, radix));
      CloseEdit;
    end
    else if EditState = BinCharEditSt then
    begin
      ram[EditAddr - RAMSTART] := byte(Ord(BinEdit.Text[1]));
      CloseEdit;
    end {if};
  end

  else if Key = VK_ESCAPE then CloseEdit;
end;


procedure TDebugForm.BinEditChange(Sender: TObject);
begin
  if (EditState = BinAddrEditSt) or (EditState = BinDataEditSt) then
    CheckEdit(BinEdit, radix);
end;


procedure TDebugForm.BinPaintBoxPaint(Sender: TObject);
var
  i, j, rows, cc: integer;
  a: word;
  x: byte;
  cx, cy: integer;  { font size in pixels }
begin
  a := BinAddr;
  cc := wordwidth + 16 * bytewidth + 18;  { column of characters }
  with BinPaintBox do
  begin
    Canvas.Brush.Style := bsSolid;
    Canvas.Brush.Color := Color;
    cx := Canvas.TextWidth('0');
    cy := Canvas.TextHeight('0');
    rows := Height div cy;
  end {with};
  with BinPaintBox.Canvas do
  begin
    for i := 0 to rows - 1 do
    begin
      if not IsInRam(a) then break;
      { address }
      TextOut(0, i * cy, WordToStr(a, '0') + ':');
      { bytes }
      j := 0;
      while j < 16 do
      begin
        if BinDataSize = 2 then
        begin
          TextOut((wordwidth + 2 + (bytewidth + 1) * j) * cx, i * cy,
            WordToStr(ptrw(@ram[a + word(j) - RAMSTART])^, '0'));
        end
        else
        begin
          TextOut((wordwidth + 2 + (bytewidth + 1) * j) * cx, i * cy,
            ByteToStr(ram[a + word(j) - RAMSTART], '0'));
        end {if};
        Inc(j, BinDataSize);
      end {while};
      { characters }
      for j := 0 to 15 do
      begin
        x := ram[a + word(j) - RAMSTART];
        if (x < $20) or (x > $7E) then x := byte(Ord('.'));
        TextOut((cc + j) * cx, i * cy, Chr(x));
      end {for};
      Inc(a, 16);
    end {for};
  end {with};
  { set the scroll bar }
  with BinScrollBar do
  begin
    SetParams((BinAddr - RAMSTART) div 16, 0, RamSize div 16 - rows);
    LargeChange := rows;
  end {with};
end;


procedure TDebugForm.BinRadioButtonClick(Sender: TObject);
begin

end;



{ MACHINE CODE EXECUTION CONTROL }

procedure TDebugForm.StepPanelClick(Sender: TObject);
begin
  Unselect;
  CloseEdit;
end;


procedure TDebugForm.StepButtonClick(Sender: TObject);
begin
end;

procedure TDebugForm.AutoRunTimerTimer(Sender: TObject);
begin
  if autorun then
  begin
    AutoRunTimer.Enabled := False;
    aStepExecute(Sender);
  end;
  AutoRunTimer.Enabled := autorun;
end;


procedure TDebugForm.TracePanelClick(Sender: TObject);
begin
  Unselect;
  CloseEdit;
end;




procedure TDebugForm.BpPanelClick(Sender: TObject);
begin
  Unselect;
  CloseEdit;
end;


procedure TDebugForm.BpButtonClick(Sender: TObject);

begin

end;


procedure TDebugForm.BpEditChange(Sender: TObject);
begin

end;



{ GENERAL FORM EVENTS }

procedure TDebugForm.DebugCreate(Sender: TObject);
begin
  aOldFlag[0] := '';
  aOldFlag[1] := '';
  aOldFlag[2] := '';
  aOldFlag[3] := '';
  aOldFlag[4] := '';

  aOldReg[0] := '';
  aOldReg[1] := '';
  aOldReg[2] := '';
  aOldReg[3] := '';
  aOldReg[4] := '';
  aOldReg[5] := '';
  aOldReg[6] := '';
  aOldReg[7] := '';
  aOldReg[8] := '';


  Rem := nil;
  autorun := False;
  CloseEdit;
  RegAddr := 0;
  BinAddr := RAMSTART;
  SetListBoundaries(ROMSTART);
  radix := 16; // Только шестнадцатиричная система
  if (radix < 8) or (radix > 16) then radix := 16;

  bytewidth := Length(TrimLeft(CardToStr($FF, cardinal(radix), ' ')));
  wordwidth := Length(TrimLeft(CardToStr($FFFF, cardinal(radix), ' ')));
end;


procedure TDebugForm.DebugShow(Sender: TObject);

var
  IniMK: TIniFile;
begin

  // Загрузим позицию окна
  IniMK := TIniFile.Create(ExpandFileName(IniName));
  with IniMK do
  begin
    left := ReadInteger('Debugger', 'Left', 0);
    top := ReadInteger('Debugger', 'Top', 0);
    Width := ReadInteger('Debugger', 'Width', Width);
    Height := ReadInteger('Debugger', 'Height', Height);
  end {with};
  IniMK.Free;

  autorun := False;
  AutoRunTimerTimer(Sender);

  CpuStop := True;
  CpuSteps := -1;
  BreakPoint := -1;
  SetListBoundaries(ptrw(@reg[R7])^);
  ListEdit.SetFocus;
  Unselect;
  cbDisassemply.Font.Color := SELECTED;
end;


procedure TDebugForm.DebugHide(Sender: TObject);
var
  IniMK: TIniFile;
begin
  // СОхраним настройки
  IniMK := TIniFile.Create(ExpandFileName(IniName));
  with IniMK do
  begin
    WriteInteger('Debugger', 'Left', left);
    WriteInteger('Debugger', 'Top', top);
    WriteInteger('Debugger', 'Width', Width);
    WriteInteger('Debugger', 'Height', Height);
  end {with};
  IniMK.Free;

  AutoRunTimer.Enabled := False;
  CloseEdit;
  Hide;
  CpuDelay := 30;
  CpuStop := False;
end;


end.
