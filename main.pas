{ user interface for the MK85 emulator based on unfinished project written
  by Aleksei Akatov (Arigato Software) }
unit Main;

interface

uses
{$IFDEF MSWINDOWS}
  Windows, Messages,
{$ELSE}
  LCLType,
{$ENDIF}
  SysUtils, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls,
  StdCtrls, IniFiles, Buttons, bas2ram,asm2rom, proc;

type

  { TMainForm }

  TMainForm = class(TForm)
    lbClose: TLabel;
    RefreshTimer: TTimer;
    CursorTimer: TTimer;
    RunTimer: TTimer;
    LcdImage: TImage;
    FaceImage: TImage;
    AutoRunTimer: TTimer;
    TeleTypeTimer: TTimer;
    procedure AutoRunTimerTimer(Sender: TObject);
    procedure lbCloseClick(Sender: TObject);
    procedure OnRefreshTimer(Sender: TObject);
    procedure OnCursorTimer(Sender: TObject);
    procedure OnRunTimer(Sender: TObject);
    procedure FaceMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: integer);
    procedure FaceMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: integer);
    procedure FaceMouseMove(Sender: TObject; Shift: TShiftState; X, Y: integer);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormKeyPress(Sender: TObject; var Key: char);
    procedure FormKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
    procedure FormKeyUp(Sender: TObject; var Key: word; Shift: TShiftState);
    procedure FormPaint(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure ApplicationDeactivate(Sender: TObject);
    procedure TeleTypeTimerTimer(Sender: TObject);
  private
    b2r: tbas2ram;
    b2rParse: rResult;
    a2r: tasm2rom;
    a2rParse: rResult;
    procedure ClearLcdArea;
    procedure ClearLcdMemory;
    procedure ContrasBitmap(b: TBitMap);
    procedure DrawKey(const index, x, y: integer; const pressed: boolean);
    function ExistsParamFromCommandLine(v_val: string; const v_cs: boolean = True): boolean;
    function GetBasNameFromCommandLine: string;
    function GetAsmNameFromCommandLine: string;
    function GetCloseModeFromCommandLine: integer;
    function GetContrastFromCommandLine: integer;
    function GetCpuSpeedFromCommandLine: integer;
    function GetAutoRunFromCommandLine: integer;
    function GetGraySegmentColor: tColor;
    function GetParamFromCommandLine(v_val, v_def: string; const v_cs: boolean = True): string;
    function GetRamName: string;
    function GetRamNameFromCommandLine: string;
    function GetRomNameFromCommandLine: string;
    function GetRamSizeFromCommandLine: word;
    function GetRomName: string;
    function GetVarSizeFromCommandLine: word;
    procedure IniLoad;
    procedure MemLoad;  { load the ROM and RAM images }
    procedure MemSave;
    procedure MessageHelpDialog;
    procedure OverlayFlip;
    procedure PowerOff; { Выключить питание }
    procedure PowerOn; { Включить питание }
    procedure put_word(const x: word; var addres: word);
    procedure ReleaseKey1(X, Y: integer);
    procedure SetVariableSizeInRam(const vars: word);
    function ShowHelpDialog: boolean;
    procedure TypeChar(c: char);
    procedure UploadResource;
    procedure View;
    procedure View7seg(const x1: integer; const y1: integer; const x2: integer; const y2: integer; const what: byte);
    procedure ViewHlp(const x1: integer; const y1: integer; const x2: integer; const y2: integer; const w: integer; const vis: byte; const image: byte);
    procedure _ReleaseKey1(X, Y: integer);
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

uses
  Def, Cpu, Keyboard, Debug;

const
  FaceName: string = 'face.bmp';
  KeysName: string = 'keys.bmp';
  OverlayName: string = 'overlay.bmp';
  RomName: string = 'rom.bin';
  RamName: string = 'ram.bin';
  LoadMsg: string = 'Failed to load the file ';
  SaveMsg: string = 'Failed to save the file ';
  BasicMsg: string = 'Параметр -basfn без параметра -ramfn.';
  AsmMsg: string = 'Параметр -asmfn без параметра -romfn.';
  BasicTranslateError: string = 'Ошибка конвертации Бейсик программы.';
  AsmTranslateError: string = 'Ошибка компиляции Ассемблер программы.';

var
  BitMap, FaceBmp, LcdBmp, KeyBmp, KeyBmpH, OverlayBmp: TBitMap;
  RedrawReq: boolean;    { true if the LcdBmp image has changed and needs to be redrawn }

  { mouse }
{$IFNDEF MSWINDOWS}
  MD: boolean;    { True when the left mouse button was pressed
          while it didn't point at any clickable
          object (key, power switch). Intended action:
          dragging the face image to another place. }
  XPos, YPos: integer;  { mouse coordinates when left button pressed }
{$ENDIF}

  { LCD }
  CurVis: boolean = False;
  Scr: array[0..95] of byte;  { LCD shadow memory }

  { CPU }
  CpuSpeed: integer;    { how many instructions executes the emulated
          CPU at each RunTimer event call }


{ draws the image of a key from the KeyBmp }
procedure TMainForm.DrawKey(const index, x, y: integer; const pressed: boolean);
var
  offset: word;
begin
  BitMap.ReleaseMaskHandle;
  with keypad[index] do
  begin
    BitMap.Width := W;
    BitMap.Height := H;
    if (pressed) then offset := 0
    else
      offset := H;
    BitMap.Canvas.Draw(-OX, -OY - offset, KeyBmp);
  end {with};
  BitMap.TransparentColor := $0000FF00;
  BitMap.Transparent := True;
  FaceBmp.Canvas.Draw(x, y, BitMap);
  BitMap.Transparent := False;
  MainForm.FaceImage.Picture.Bitmap := FaceBmp;
end {DrawKey};



procedure TMainForm.ContrasBitmap(b: TBitMap);
var
  x, y: integer;
  tc: tcolor;
begin
  tc := b.TransparentColor;
  for x := 0 to b.Width do
  begin
    for y := 0 to b.Height do
    begin
      if b.Canvas.Pixels[x, y] = tc then
        b.Canvas.Pixels[x, y] := GetGraySegmentColor;
    end;
  end;
end;



{ display a status sign }
procedure TMainForm.ViewHlp(const x1: integer; const y1: integer;  { destination coordinates of the upper-left corner }
  const x2: integer; const y2: integer;  { source coordinates of the upper-left corner }
  const w: integer;  { image width, height is always 7 pixels }
  const vis: byte;   { draw image if not zero, clear if zero }
  const image: byte);   { индекс картинки }
begin
  if vis <> 0 then
  begin    { copy a selection from the KeyBmp }
    with BitMap do
    begin
      Transparent := False;
      Width := w;
      Height := 7;
      Canvas.Draw(-x2, -y2, KeyBmp);
    end {with};
    LcdBmp.Canvas.Draw(x1, y1, BitMap);
  end
  else
  begin    { clear the area }
    with BitMap do
    begin
      Transparent := False;
      Width := w;
      Height := 7;
      Canvas.Draw(-x2, -y2, KeyBmpH);
    end {with};
    ContrasBitmap(KeyBmpH);
    LcdBmp.Canvas.Draw(x1, y1, BitMap);
  end {if};
  RedrawReq := True;
end {ViewHlp};



{ display a segment of the 7-segm. area }
procedure TMainForm.View7seg(const x1: integer; const y1: integer;  { coordinates of the begin of the line }
  const x2: integer; const y2: integer;  { coordinates of the end of the line }
  const what: byte);  { show segment if not zero, clear if zero }
begin
  with LcdBmp.Canvas do
  begin
    Brush.Style := bsSolid;
    if what <> 0 then Brush.Color := clBlack
    else
      Brush.Color := GetGraySegmentColor;
    FillRect(Rect(x1, y1, x2, y2));
  end {with};
  RedrawReq := True;
end {View7seg};


function TMainForm.GetGraySegmentColor: tColor;
begin
  Result := $00ffffff;
  case Contrast of
    0: Result := $00ffffff;
    1: Result := $00f5f5f5;
    2: Result := $00ebebeb;
    3: Result := $00e1e1e1;
    4: Result := $00d7d7d7;
    5: Result := $00cdcdcd;
    6: Result := $00c3c3c3;
    7: Result := $00b9b9b9;
    8: Result := $00afafaf;
    9: Result := $00a5a5a5;
  end;
end;

{ draw the LCD contents }
procedure TMainForm.View;
var
  Pos, Row, Col, Index, ZX, ZY: integer;
  B: byte;
begin

  { draw the matrix }
  Index := 0;
  ZX := 2;  { pixel coordinates }
  ZY := 24;

  with LcdBmp.Canvas do
  begin
    Brush.Style := bsSolid;
    for Pos := 0 to 11 do
    begin
      Inc(Index);
      for Row := 1 to 7 do
      begin
        B := lcd[Index];

        { handle the cursor }
        if CurVis and (Pos = (lcd[96] and $0F)) then
          if (Row = 7) or ((lcd[96] and $10) = 0) then B := $1F
          else
            B := 0;

        if Scr[Index] <> B then
        begin
          RedrawReq := True;
          Scr[Index] := B;
          for Col := 0 to 4 do
          begin
            if (B and 1) <> 0 then Brush.Color := clBlack
            else
              Brush.Color := GetGraySegmentColor;
            B := B shr 1;
            FillRect(Rect(ZX, ZY, ZX + 2, ZY + 3));
            Inc(ZX, 3);
          end {for Col};
          Dec(ZX, 15);
        end {if};
        Inc(Index);
        Inc(ZY, 4);
      end {for Row};
      Inc(ZX, 19);
      Dec(ZY, 4 * 7);
    end {for Pos};
  end {with};

  { draw the 7-segm. characters and the status signs }
  if Scr[$00] <> lcd[$00] then
  begin
    Scr[$00] := lcd[$00];
    ViewHlp(0, 5, 0, 56, 16, lcd[$00] and $01, $01);  { EXT }
    ViewHlp(19, 0, 17, 56, 5, lcd[$00] and $02, $02);  { S }
    ViewHlp(19, 9, 41, 56, 5, lcd[$00] and $04, $04);  { F }
  end {if};

  if Scr[$08] <> lcd[$08] then
  begin
    Scr[$08] := lcd[$08];
    ViewHlp(27, 0, 23, 56, 17, lcd[$08] and $01, $01);  { RUN }
    ViewHlp(26, 9, 47, 56, 19, lcd[$08] and $02, $02);  { WRT }
    ViewHlp(49, 5, 67, 56, 16, lcd[$08] and $10, $10);  { DEG }
  end {if};

  if Scr[$18] <> lcd[$18] then
  begin
    Scr[$18] := lcd[$18];
    ViewHlp(71, 5, 84, 56, 17, lcd[$18] and $01, $01);  { RAD }
  end {if};

  if Scr[$20] <> lcd[$20] then
  begin
    Scr[$20] := lcd[$20];
    ViewHlp(93, 5, 102, 56, 17, lcd[$20] and $01, $01);  { GRA }
  end {if};

  if Scr[$28] <> lcd[$28] then
  begin
    Scr[$28] := lcd[$28];
    ViewHlp(116, 5, 120, 56, 11, lcd[$28] and $01, $01);   { TR }
  end {if};

  if Scr[$30] <> lcd[$30] then
  begin
    Scr[$30] := lcd[$30];
    View7seg(142, 3, 144, 8, lcd[$30] and $01);  { 1f }
    View7seg(143, 8, 148, 10, lcd[$30] and $02);  { 1g }
    View7seg(141, 9, 143, 14, lcd[$30] and $04);  { 1e }
    View7seg(142, 14, 147, 16, lcd[$30] and $08);  { 1d }
    View7seg(147, 10, 149, 15, lcd[$30] and $10);  { 1c }
  end {if};

  if Scr[$38] <> lcd[$38] then
  begin
    Scr[$38] := lcd[$38];
    View7seg(148, 4, 150, 9, lcd[$38] and $01);  { 1b }
    View7seg(144, 2, 149, 4, lcd[$38] and $02);  { 1a }
    View7seg(158, 3, 160, 8, lcd[$38] and $04);  { 2f }
    View7seg(159, 8, 164, 10, lcd[$38] and $08);  { 2g }
    View7seg(157, 9, 159, 14, lcd[$38] and $10);  { 2e }
  end {if};

  if Scr[$40] <> lcd[$40] then
  begin
    Scr[$40] := lcd[$40];
    View7seg(158, 14, 163, 16, lcd[$40] and $01);  { 2d }
    View7seg(163, 10, 165, 15, lcd[$40] and $02);  { 2c }
    View7seg(164, 4, 166, 9, lcd[$40] and $04);  { 2b }
    View7seg(160, 2, 165, 4, lcd[$40] and $08);  { 2a }
    View7seg(174, 3, 176, 8, lcd[$40] and $10);  { 3f }
  end {if};

  if Scr[$48] <> lcd[$48] then
  begin
    Scr[$48] := lcd[$48];
    View7seg(175, 8, 180, 10, lcd[$48] and $01);  { 3g }
    View7seg(173, 9, 175, 14, lcd[$48] and $02);  { 3e }
    View7seg(174, 14, 179, 16, lcd[$48] and $04);  { 3d }
    View7seg(179, 10, 181, 15, lcd[$48] and $08);  { 3c }
    View7seg(180, 4, 182, 9, lcd[$48] and $10);  { 3b }
  end {if};

  if Scr[$50] <> lcd[$50] then
  begin
    Scr[$50] := lcd[$50];
    View7seg(176, 2, 181, 4, lcd[$50] and $01);  { 3a }
    View7seg(190, 3, 192, 8, lcd[$50] and $02);  { 4f }
    View7seg(191, 8, 196, 10, lcd[$50] and $04);  { 4g }
    View7seg(189, 9, 191, 14, lcd[$50] and $08);  { 4e }
    View7seg(190, 14, 195, 16, lcd[$50] and $10);  { 4d }
  end {if};

  if Scr[$58] <> lcd[$58] then
  begin
    Scr[$58] := lcd[$58];
    View7seg(195, 10, 197, 15, lcd[$58] and $01);  { 4c }
    View7seg(196, 4, 198, 9, lcd[$58] and $02);  { 4b }
    View7seg(192, 2, 197, 4, lcd[$58] and $04);  { 4a }
    ViewHlp(204, 5, 132, 56, 23, lcd[$58] and $08, $08);  { STOP }
  end {if};

end; {proc View}


{ In order to avoid display flickers all drawing is done off-screen
  on LcdBmp.Canvas, then periodically transferred to LcdImage }
procedure TMainForm.OnRefreshTimer(Sender: TObject);
begin
  View;
  if RedrawReq = True then LcdImage.Picture.Bitmap := LcdBmp;
  RedrawReq := False;
end;

procedure TMainForm.lbCloseClick(Sender: TObject);
begin
  Close;
end;


procedure TMainForm.TeleTypeTimerTimer(Sender: TObject);
var
  w: word;
begin
  TeleTypeTimer.Enabled := False;
  w := 0;
  FormKeyUp(Sender, w, []);
end;

procedure TMainForm.TypeChar(c: char);
var
  k: word;
begin
  if c = chr(VK_RETURN) then
  begin
    k := VK_RETURN;
    FormKeyDown(nil, k, []);
  end
  else
    FormKeyPress(nil, c);
  TeleTypeTimer.Enabled := True;
  while KeyCode2 <> 0 do application.ProcessMessages;
end;

procedure TMainForm.AutoRunTimerTimer(Sender: TObject);
var
  c: char;
  w: word;
begin
  AutoRunTimer.Enabled := False;
  if Autorun <> -1 then
  begin
    Autorun := -1; // Автозапуск выполняется только один раз
    TypeChar('R');
    TypeChar('U');
    TypeChar('N');
    TypeChar(#13); // EXE
  end;
end;

{ release a pressed key if it's placed outside the coordinates X,Y }
procedure TMainForm.ReleaseKey1(X, Y: integer);
begin
  if (KeyCode1 = 0) or (KeyCode1 = 1) then Exit;

  // организовываем удержание клавиши в случае автодебага
  // Иначе опрос клавиатур работать не будет
  if (DebugForm.Visible) and (DebugForm.Autorun) then
  begin
    if (DelayResetKey = 0) then
    begin
      _ReleaseKey1(-1, -1);
      exit;
    end;
    if KeyCode1 <> 0 then
      exit;
  end;

  _ReleaseKey1(x, y);
end;

{ release a pressed key if it's placed outside the coordinates X,Y }
procedure TMainForm._ReleaseKey1(X, Y: integer);
var
  i, r, c, k: integer;
begin
  { locate the "keyblock" the key "KeyCode1" belongs to }
  i := 0;  { "keyblock" index }
  k := 1;  { first key code in the "keyblock" }
  while (KeyCode1 >= k + keypad[i].cnt) and (i < KEYPADS) do
  begin
    Inc(k, keypad[i].cnt);
    Inc(i);
  end {while};

  with keypad[i] do
  begin
    k := KeyCode1 - k;    { offset of the key in the "keyblock" }
    c := L + SX * (k mod col);  { X coordinate of the key image }
    r := T + SY * (k div col);  { Y coordinate of the key image }
    if (X < c) or (X >= c + W) or (Y < r) or (Y >= r + H) then
    begin
      { shift the key label up-left to get an impression of a released key }
      if KeyCode1 >= 2 then  { power switch excluded }
      begin
        BitMap.Width := W - 9;
        if KeyCode1 >= 37 then BitMap.Height := H - 9
        else
          BitMap.Height := H - 8;
        BitMap.Transparent := False;
        BitMap.Canvas.Draw(-c - 5, -r - 5, FaceBmp);
        FaceBmp.Canvas.Draw(c + 4, r + 4, BitMap);
      end {if};
      DrawKey(i, c, r, False);
      KeyCode1 := 0;
    end {if};
  end {with};
end {ReleaseKey1};


{ called when mouse button pressed }
procedure TMainForm.FaceMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: integer);
var
  i, r, c, k: integer;
begin
  { proceed only when left mouse button pressed }
  if Button <> mbLeft then Exit;

  ReleaseKey1(-1, -1);
  KeyCode1 := 1;
  for i := 0 to KEYPADS do
  begin
    with keypad[i] do
    begin
      if (X >= L) and (X < L + SX * col) and (((X - L) mod SX) < W) and (Y >= T) and (((Y - T) mod SY) < H) then
      begin
        c := (X - L) div SX;
        r := (Y - T) div SY;
        k := col * r + c;
        if k < cnt then
        begin
          Inc(KeyCode1, k);
          c := L + c * SX;
          r := T + r * SY;
          { shift the key label down-right to get an impression of a pressed key }
          if KeyCode1 >= 2 then    { power switch excluded }
          begin
            BitMap.Width := W - 9;
            if KeyCode1 >= 37 then BitMap.Height := H - 9
            else
              BitMap.Height := H - 8;
            BitMap.Transparent := False;
            BitMap.Canvas.Draw(-c - 4, -r - 4, FaceBmp);
            FaceBmp.Canvas.Draw(c + 5, r + 5, BitMap);
          end {if};
          DrawKey(i, c, r, True);
          DelayResetKey := 50;
          break;
        end {if};
      end {if};
      Inc(KeyCode1, cnt);
    end {with};
  end {for};

  if KeyCode1 > LASTKEYCODE then  { no valid key pressed }
  begin
    KeyCode1 := 0;
{ dragging a captionless form by clicking anywhere on the client area outside
  the controls }
{$IFDEF MSWINDOWS}
    if BorderStyle = bsNone then
    begin
      ReleaseCapture;
      SendMessage(Handle, WM_NCLBUTTONDOWN, HTCAPTION, 0);
    end {if};
{$ELSE}
    XPos := X;
    YPos := Y;
    MD := BorderStyle = bsNone;
{$ENDIF}
  end {if};
end {proc};



{ save the RAM image to the file Ram.bin }
procedure TMainForm.MemSave;
var
  f: file;
begin
  {$I-}
  AssignFile(f, GetRamName);
  Rewrite(f, 1);
  BlockWrite(f, ram, RamSize);
  CloseFile(f);
  {$I+}
  if IOResult <> 0 then MessageDlg(SaveMsg + RamName, mtWarning, [mbOK], 0);
end {MemSave};

{ Включить питание }
procedure TMainForm.PowerOn();
begin
  FormShow(nil);
end;

{ Выключить питание }
procedure TMainForm.PowerOff();
begin
  PowerState := False;
  CpuStop := True;
  RunTimer.Enabled := False;
  RefreshTimer.Enabled := False;
  CursorTimer.Enabled := False;
  ClearLcdArea();
  ClearLcdMemory();
  LcdImage.Picture.Bitmap := LcdBmp;
  MemSave;
end;


{ called when mouse button released }
procedure TMainForm.FaceMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: integer);
var
  K: integer;
begin
  { proceed only when left mouse button was pressed }
  if Button <> mbLeft then Exit;

{$IFNDEF MSWINDOWS}
  MD := False;
{$ENDIF}

  K := KeyCode1;
  { release a pressed key }
  ReleaseKey1(-1, -1);

  { what to do if the mouse button was released over a pressed ... }
  case K of
    1: begin
      if CloseMode = 0 then Close;        { ...power switch }
      if CloseMode = 1 then
      begin
        if PowerState then
          PowerOff()
        else
          PowerOn();
      end;
    end;
    39: if (kbdrows and 2) <> 0 then  { ...STOP key when row 1 selected }
        HALT_i := True;
  end {case};
end;


{ called when moving the mouse while the button pressed }
procedure TMainForm.FaceMouseMove(Sender: TObject; Shift: TShiftState; X, Y: integer);
begin
{$IFNDEF MSWINDOWS}
  if MD then  { drag the face image }
    Invalidate
  else    { release a pressed key if mouse was moved from it }
{$ENDIF}
    ReleaseKey1(X, Y);
end;


procedure TMainForm.ClearLcdArea();
begin
  with LcdBmp.Canvas do
  begin
    Brush.Style := bsSolid;
    Brush.Color := clWhite;
    FillRect(Rect(0, 0, 227, 51));
  end;
end;

procedure TMainForm.ClearLcdMemory();
var
  X: integer;
begin
  for X := 0 to 95 do
  begin
    Scr[X] := $FF;
    lcd[X] := $00;
  end;
end;


procedure TMainForm.MessageHelpDialog;
var
  s: string;
begin
  s := 'Справка по параметрам коммандной строки:' + #13#10;
  s := s + '-basfn <имя_файла>: имя файла бейсик программы для загрузки в RAM память. Параметр -ramfn должен быть обязательно заполнен.' + #13#10;
  s := s + '-ramfn <имя_файла>: имя файла для загрузки RAM памяти' + #13#10;
  s := s + '-ramfs <число>: размера RAM памяти в байтах (корректное значение кратно 2048 байт)' + #13#10;
  s := s + '-asmfn <имя_файла>: имя файла ассемблер программы для загрузки в ROM память. Параметр -romfn должен быть обязательно заполнен.' + #13#10;
  s := s + '-romfn <имя_файла>: имя файла для загрузки ROM памяти' + #13#10;
  s := s + '-ar <0>: автозапуск программы после включения.' + #13#10;
  s := s + '-cs <число>: скорость процессора, чем менше, тем медленнее (нормальное значение 250).' + #13#10;
  s := s + '-cm <0, 1, 2>: метод закрытия программы (0 - выключатель, 1 - кнопка закрыть, 2 - сразу закрыть, бывает полезно для компиляции программ).' + #13#10;
  s := s + '-ct <0..9>: контрастность дисплея (0 - самая светлая).' + #13#10;
  s := s + '-help, -h: эта справка' + #13#10;
  MessageDlg(s, mtInformation, [mbClose], 0);
end;


procedure TMainForm.UploadResource;
begin
  { load the Keys.bmp image }
  if FileExists(KeysName) then
  begin
    KeyBmp.LoadFromFile(KeysName);
    KeyBmpH.LoadFromFile(KeysName);
  end
  else
  begin
    MessageDlg(LoadMsg + KeysName, mtError, [mbOK], 0);
    Close;
    exit;
  end;
  KeyBmp.Transparent := False;
  { load the Overlay.bmp image }
  if FileExists(OverlayName) then
    OverlayBmp.LoadFromFile(OverlayName)
  else
  begin
    MessageDlg(LoadMsg + OverlayName, mtError, [mbOK], 0);
    Close;
    exit;
  end;
  OverlayBmp.Transparent := False;
  { background image }
  if FileExists(FaceName) then
  begin
    BitMap.LoadFromFile(FaceName);
    BitMap.Transparent := False;
    FaceBmp.Canvas.Draw(0, 0, BitMap);
    { select the calculator name MK85/MK85M depending on the RAM size }
    if RamSize <= MINRAMSIZE then  { shift the MK85 emblem right }
    begin
      BitMap.Width := 100;
      BitMap.Height := 15;
      BitMap.Canvas.Draw(-616, -50, FaceBmp);
      FaceBmp.Canvas.Draw(639, 50, BitMap);
    end {if};
    FaceImage.Picture.Bitmap := FaceBmp;
  end
  else
  begin
    MessageDlg(LoadMsg + FaceName, mtError, [mbOK], 0);
    Close;
    exit;
  end;
  FaceBmp.Transparent := False;
end;

procedure TMainForm.FormShow(Sender: TObject);
var
  IniMK: TIniFile;
  ShowDebug: integer;
begin

  // Покажем справку
  if ShowHelpDialog then
  begin
    MessageHelpDialog;
    Close;
    exit;
  end;

  // Загрузим позицию окна
  IniMK := TIniFile.Create(ExpandFileName(IniName));
  with IniMK do
  begin
    left := ReadInteger('Settings', 'Left', 0);
    top := ReadInteger('Settings', 'Top', 0);
    ShowDebug := ReadInteger('Settings', 'ShowDebug', 0);
  end {with};
  freeandnil(IniMK);

  PowerState := True; // Питание включено
  KeyCode1 := 0;
  KeyCode2 := 0;
  CpuStop := False;
  CpuDelay := 0;
  CpuSteps := -1;

  DebugForm.Rem:=a2r.Rem; // К дебагеру подключим табице примечаний

  UploadResource(); // Загрузим ресурсы

  // Файл не найден, ошибка загрузки Rom
  if MemLoadResult = 1 then
  begin
    MessageDlg(LoadMsg + GetRomName, mtError, [mbOK], 0);
    Close;
    exit;
  end;

  // Ошибка в параметрах загрузки Бейсик программы
  if MemLoadResult = 2 then
  begin
    MessageDlg(BasicMsg, mtError, [mbOK], 0);
    Close;
    exit;
  end;


  // Ошибка в параметрах загрузки Бейсик программы
  if MemLoadResult = 3 then
  begin
    MessageDlg(AsmMsg, mtError, [mbOK], 0);
    Close;
    exit;
  end;

  // Ошибка преобразования Ассемблер программы
  if a2rParse.ExitCode <> 0 then
  begin
    MessageDlg(AsmTranslateError + ' ' + a2rParse.ExitText, mtError, [mbOK], 0);
    Close;
    exit;
  end;

  // Ошибка преобразования Бейсик программы
  if b2rParse.ExitCode <> 0 then
  begin
    MessageDlg(BasicTranslateError + ' ' + b2rParse.ExitText, mtError, [mbOK], 0);
    Close;
    exit;
  end;

  if CloseMode=2 then
  begin
    close;
    exit;
  end;



  ClearLcdArea();{ clear the LCD area }
  ClearLcdMemory(); { clear the display memory }
  CpuReset;

  // Запуск дебагира на старте
  if ShowDebug <> 0 then
    DebugForm.Show;

  RunTimer.Enabled := True;
  RefreshTimer.Enabled := True;
  CursorTimer.Enabled := True;
  AutoRunTimer.Enabled := True;
  RedrawReq := True;

end;


function TMainForm.ExistsParamFromCommandLine(v_val: string; const v_cs: boolean = True): boolean;
var
  r: integer;
  p: string;
begin
  v_val := trim(v_val);
  if not (v_cs) then
    v_val := AnsiUpperCase(v_val);
  r := 0;
  while (r <> 20) do
  begin
    p := trim(ParamStr(r));
    if not (v_cs) then
      p := AnsiUpperCase(p);
    if (p = v_val) then
    begin
      Result := True;
      exit;
    end;
    Inc(r);
  end;
  Result := False;
end;



function TMainForm.GetParamFromCommandLine(v_val, v_def: string; const v_cs: boolean = True): string;
var
  r: integer;
  p: string;
begin
  v_val := trim(v_val);
  v_def := trim(v_def);
  if not (v_cs) then
    v_val := AnsiUpperCase(v_val);
  r := 0;
  while (r <> 20) do
  begin
    p := trim(ParamStr(r));
    if not (v_cs) then
      p := AnsiUpperCase(p);
    if (p = v_val) then
    begin
      Result := trim(ParamStr(r + 1));
      exit;
    end;
    Inc(r);
  end;
  Result := v_def;
end;


function TMainForm.GetRamSizeFromCommandLine: word;
begin
  Result := StrToIntDef(GetParamFromCommandLine('-ramfs', '65535', False), 65535);
end;

function TMainForm.GetVarSizeFromCommandLine: word;
begin
  Result := StrToIntDef(GetParamFromCommandLine('-vars', '65535', False), 65535);
end;

function TMainForm.GetCloseModeFromCommandLine: integer;
begin
  Result := StrToIntDef(GetParamFromCommandLine('-cm', '-1', False), -1);
end;

function TMainForm.GetCpuSpeedFromCommandLine: integer;
begin
  Result := StrToIntDef(GetParamFromCommandLine('-cs', '-1', False), -1);
end;

function TMainForm.GetAutoRunFromCommandLine: integer;
begin
  Result := StrToIntDef(GetParamFromCommandLine('-ar', '-1', False), -1);
end;

{ Имя файла бэейсик программы из командной строки }
function TMainForm.GetBasNameFromCommandLine: string;
begin
  Result := GetParamFromCommandLine('-basfn', '', False);
end;

function TMainForm.GetAsmNameFromCommandLine: string;
begin
  Result := GetParamFromCommandLine('-asmfn', '', False);
end;

function TMainForm.GetRomNameFromCommandLine: string;
begin
  Result := GetParamFromCommandLine('-romfn', '', False);
end;


function TMainForm.GetRamNameFromCommandLine: string;
begin
  Result := GetParamFromCommandLine('-ramfn', '', False);
end;

function TMainForm.ShowHelpDialog: boolean;
begin
  Result := ExistsParamFromCommandLine('-help', False) or ExistsParamFromCommandLine('-h', False);
end;


function TMainForm.GetContrastFromCommandLine: integer;
begin
  Result := StrToIntDef(GetParamFromCommandLine('-ct', '-1', False), -1);
end;

function TMainForm.GetRamName: string;
begin
  Result := GetRamNameFromCommandLine;
  if Result = '' then
    Result := RamName;
end;




function TMainForm.GetRomName: string;
begin
  Result := GetRomNameFromCommandLine;
  if Result = '' then
    Result := RomName;
end;



procedure TMainForm.put_word(const x: word; var addres: word);
begin
  ram[addres] := (x mod 256);
  Inc(addres);
  ram[addres] := (x div 256);
  Inc(addres);
end;

procedure TMainForm.SetVariableSizeInRam(const vars: word);
var
  i: word;
  output_ptr: word;
begin
  // determine the required RAM size */
  if (RamSize <= 2048) then
    i := $0800      //* MK-85 */
  else
    i := $1800;      //* MK-85M */
  output_ptr := $0250;
  put_word(VARS, output_ptr);    //* number of variables */
  put_word(i, output_ptr);  //* top of the RAM */
end;

{ load the ROM and RAM images }
procedure TMainForm.MemLoad;
var
  f: file;
  transferred: integer;

begin
  MemLoadResult := 0;


  if (GetAsmNameFromCommandLine <> '') and (GetRomNameFromCommandLine = '') then
  begin
    MemLoadResult := 3; // Файл не найден, ошибка загрузки Rom
    exit;
  end;

  { Загрузим ассемблер программу, если указано в командной строке }
  if GetAsmNameFromCommandLine <> '' then
  begin
    a2rParse := a2r.Execute(GetAsmNameFromCommandLine, GetRomNameFromCommandLine);
    if a2rParse.ExitCode <> 0 then
    begin
      MemLoadResult := 250; // Ошибка преобразования бейсик программы
      exit;
    end;
  end;


  { load the ROM image }
  if FileExists(GetRomName) then
  begin
    AssignFile(f, GetRomName);
    Reset(f, 1);
    BlockRead(f, rom, ROMSIZE, transferred);
    CloseFile(f);
  end
  else
    MemLoadResult := 1; // Файл не найден, ошибка загрузки Rom


  if (GetBasNameFromCommandLine <> '') and (GetRamNameFromCommandLine = '') then
  begin
    MemLoadResult := 2; // Файл не найден, ошибка загрузки Ram
    exit;
  end;

  { Загрузим бейсик программу, если указано в командной строке }
  if GetBasNameFromCommandLine <> '' then
  begin
    b2rParse := b2r.Execute(GetBasNameFromCommandLine, GetRamNameFromCommandLine);
    if b2rParse.ExitCode <> 0 then
    begin
      MemLoadResult := 255; // Ошибка преобразования бейсик программы
      exit;
    end;
  end;

  { load the RAM image }
  if FileExists(GetRamName) then
  begin
    AssignFile(f, GetRamName);
    Reset(f, 1);
    BlockRead(f, ram, RamSize, transferred);
    CloseFile(f);
  end
  else
  begin
    SetVariableSizeInRam(VarSize);
  end;

end {MemLoad};


procedure TMainForm.IniLoad;
var
  IniMK: TIniFile;
begin
  IniMK := TIniFile.Create(ExpandFileName(IniName));
  with IniMK do
  begin

    CpuSpeed := GetCpuSpeedFromCommandLine;
    if CpuSpeed = -1 then
      CpuSpeed := ReadInteger('Settings', 'CpuSpeed', 250);

    RamSize := GetRamSizeFromCommandLine;
    if RamSize = 65535 then
      RamSize := ReadInteger('Settings', 'RamSize', 6144);

    CloseMode := GetCloseModeFromCommandLine;
    if CloseMode = -1 then
      CloseMode := ReadInteger('Settings', 'CloseMode', 0);

    Contrast := GetContrastFromCommandLine;
    if Contrast = -1 then
      Contrast := ReadInteger('Settings', 'Contrast', 3);

    Autorun := GetAutoRunFromCommandLine;
    if Autorun = -1 then
      Autorun := ReadInteger('Settings', 'Autorun', -1);

    VarSize := GetVarSizeFromCommandLine;
    if VarSize = 65535 then
      VarSize := ReadInteger('Settings', 'VarSize', 26);

  end {with};
  freeandnil(IniMK);
end {IniLoad};


{ initialise the application }
procedure TMainForm.FormCreate(Sender: TObject);
begin

  DelayResetKey := 0;

  b2r := tbas2ram.Create();
  a2r := tasm2rom.Create();

  BitMap := TBitMap.Create;
  FaceBmp := TBitMap.Create;
  FaceBmp.Width := 760;
  FaceBmp.Height := 330;
  LcdBmp := TBitMap.Create;
  LcdBmp.Width := 227;
  LcdBmp.Height := 51;

  KeyBmp := TBitMap.Create;
  KeyBmp.Width := 188;
  KeyBmp.Height := 63;

  KeyBmpH := TBitMap.Create;
  KeyBmpH.Width := 188;
  KeyBmpH.Height := 63;

  OverlayBmp := TBitMap.Create;
  OverlayBmp.Width := 505;
  OverlayBmp.Height := 24;
  IniLoad;
  lbClose.Visible := (CloseMode = 1);
  if RamSize < MINRAMSIZE then RamSize := MINRAMSIZE;
  if RamSize > MAXRAMSIZE then RamSize := MAXRAMSIZE;
  RamSize := (RamSize + 15) and $FFF0;
  RamEnd := RAMSTART + RamSize - 1;
  MemLoad;
end;



{ terminate the application }
procedure TMainForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
var
  IniMK: TIniFile;
begin
  CpuStop := True;
  RunTimer.Enabled := False;
  RefreshTimer.Enabled := False;
  CursorTimer.Enabled := False;

  // Сохраним позицию окна
  IniMK := TIniFile.Create(ExpandFileName(IniName));
  with IniMK do
  begin
    WriteInteger('Settings', 'Left', left);
    WriteInteger('Settings', 'Top', top);
    if DebugForm.Visible then
      WriteInteger('Settings', 'ShowDebug', 1)
    else
      WriteInteger('Settings', 'ShowDebug', 0);
  end {with};
  FreeAndNil(IniMK);

  MemSave;

  FreeAndNil(BitMap);
  FreeAndNil(FaceBmp);
  FreeAndNil(LcdBmp);
  FreeAndNil(KeyBmp);
  FreeAndNil(KeyBmpH);
  FreeAndNil(OverlayBmp);
  FreeAndNil(b2r);
  FreeAndNil(a2r);
end;


procedure TMainForm.OnCursorTimer(Sender: TObject);
begin
  CurVis := not CurVis;
end;


{ show/hide the keyboard overlay }
procedure TMainForm.OverlayFlip;
var
  Temp: TBitMap;
  i, y, r: integer;
begin
  Temp := TBitMap.Create;
  Temp.Width := 505;
  Temp.Height := 8;
  Temp.Transparent := False;
  BitMap.Width := 505;
  BitMap.Height := 8;
  BitMap.Transparent := False;
  y := 0;
  r := 190;
  for i := 0 to 2 do
  begin
    Temp.Canvas.Draw(-5, -r, FaceBmp);
    { Lazarus: without this statement the bitmap preserves the old transparency mask }
    BitMap.ReleaseMaskHandle;
    BitMap.Canvas.Draw(0, -y, OverlayBmp);
    OverlayBmp.Canvas.Draw(0, y, Temp);
    BitMap.TransparentColor := $0000FF00;
    BitMap.Transparent := True;
    FaceBmp.Canvas.Draw(5, r, BitMap);
    MainForm.Canvas.Draw(5, r, BitMap);
    BitMap.Transparent := False;
    Inc(y, 8);
    Inc(r, 42);
  end {for};
  Temp.Free;
end {OverlayFlip};


procedure TMainForm.FormKeyPress(Sender: TObject; var Key: char);
const
  { key codes 7 to 54 }
  Letters: string[48] = 'QWERTYUIOPASDFGHJKLaZXCVBNM =aaaa/789*456-123+0.';
var
  i: integer;
begin
  i := 1;
  Key := UpCase(Key);
  while (i <= 48) and (Key <> Letters[i]) do Inc(i);
  if i <= 48 then KeyCode2 := i + 6;
end;


procedure TMainForm.FormKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
begin
  case Key of
    VK_INSERT: KeyCode2 := 2;  { MODE }
    VK_LEFT: KeyCode2 := 3;  { <- }
    VK_RIGHT: KeyCode2 := 4;  { -> }
    VK_HOME: KeyCode2 := 5;  { [S] }
    VK_END: KeyCode2 := 6;  { [F] }
    VK_ESCAPE: KeyCode2 := 37;  { AC }
    VK_DELETE: KeyCode2 := 38;  { DEL }
    VK_RETURN: KeyCode2 := 55;  { EXE }
    VK_F2: OverlayFlip;
    VK_F3: DebugForm.Show;
    VK_F8: KeyCode2 := 56;  { Init }
  end {case};
end;


procedure TMainForm.FormKeyUp(Sender: TObject; var Key: word; Shift: TShiftState);
begin
  KeyCode2 := 0;
end;


procedure TMainForm.FormPaint(Sender: TObject);
begin
{$IFNDEF MSWINDOWS}
  if MD then with Mouse.CursorPos do SetBounds(X - XPos, Y - YPos, Width, Height);
{$ENDIF}
end;


{ execute a bunch of machine code instructions }
procedure TMainForm.OnRunTimer(Sender: TObject);
var
  i: integer;
begin
  if (DelayResetKey <> 0) then
    Dec(DelayResetKey);


  if CpuDelay > 0 then
  begin
    Dec(CpuDelay);
    Exit;
  end {if};

  i := 0;
  while i < CpuSpeed do
  begin
    if CpuStop then exit;
    Inc(i, CpuRun);
    if CpuSteps > 0 then
    begin
      Dec(CpuSteps);
      if CpuSteps = 0 then
      begin
        DebugForm.Show;
        break;
      end {if};
    end {if};
    if  DebugForm.InBreakPoint(ptrw(@reg[R7])^)  then
    begin
      DebugForm.Show;
      break;
    end {if};
  end {while};
end;


procedure TMainForm.FormDeactivate(Sender: TObject);
begin
  ReleaseKey1(-1, -1);
  KeyCode2 := 0;
end;


procedure TMainForm.ApplicationDeactivate(Sender: TObject);
begin
  ReleaseKey1(-1, -1);
  KeyCode2 := 0;
end;



end.
