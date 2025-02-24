unit asm2rom;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, lazUTF8, proc, Pdp11dis, Generics.Collections;

const
  cOUTBUFSIZE = 16384; // Выходной буфер, байт
  cREMCHARFORCOMMENT = '*'; // Символ разделителя для многострочечного примечания


type
  rASMLine = record
    Addr: word;
    LineNumber: string;
    Memonic: string;
    Param: string;
    Rem: string;
  end;


type
  TRemDictionary = specialize TDictionary<word, string>; {Таблица примечаний к адресам}
  TLineNumberDictionary = specialize TDictionary<string, word>;  {Таблица адресов меток}
  TLineNumberForLabel = specialize TList<rASMLine>; {список строк для последующей обработки адресов}
  TMemUsed = specialize TDictionary<word, boolean>; {память, которая уже использована}




type
  {
   TASM2ROM класс для преобразования Ассемблер программы в дамп ПЗУ (RОМ) микрокомпьютера "Электроника МК85".
   Головейко Александр, 01.03.2025 г.
  }

  TASM2ROM = class
  private
    {Примечание к адресам}
    fRem: TRemDictionary;
    {Адреса меток}
    fLineNumber: TLineNumberDictionary;
    {Список строк для постобработки месток}
    fLineNumberForLabel: TLineNumberForLabel;
    {Буфер преобразованной бейсик программы.}
    output_buf: array[0..cOUTBUFSIZE] of byte;
    fTMemUsed: TMemUsed;
    {Признак того, что требуется проверять занятую память}
    fCheckMemUsed: boolean;

    function AddLineNumber(const v_asmline: rASMLine; const v_line, v_global_rem: string; var v_output_ptr: word): rResult;
    function AddRem(const v_asmline: rASMLine; const v_line, v_global_rem: string; var v_output_ptr: word): rResult;
    function isLineNumberLabel(const v_s: string): integer;
    function isMemoryUsed(const v_addres: word; const v_line: string): rResult;
    {Строка это регистр?}
    function isReg(v_s: string): boolean;
    {Выполнение инструкции ORG}
    function ORG_CMD(const v_param: string; const v_line: string; const v_addzeroend: boolean; var v_output_ptr: word): rResult;
    {Выполнение инструкции ANSI, ANSIZ}
    function ANSI_CMD(const v_param: string; const v_line: string; const v_addzeroend: boolean; var v_output_ptr: word): rResult;
    {Парсинг Ассемюлер строки}
    function ASSEMBLE_CMD(const v_asmline: rASMLine; const v_line: string; const v_create_label_list: boolean; var v_output_ptr: word): rResult;
    {Проверка параметра}
    function CheckParam(const v_asmtab: Tab; const v_asmline: rASMLine; const v_line: string): rResult;
    {Очищает переменную типа rASMLine}
    procedure ClearASMLine(var v_v: rASMLine);
    {Очистка буфера}
    procedure ClearOutputBuf();
    {Очищает переменную типа tab}
    procedure ClearTab(var v_tab: tab);
    {Обрабатывает команду .DW и .DB}
    function DWDB_CMD(const v_param: string; const v_line: string; const v_min, v_max: integer; var v_output_ptr: word): rResult;
    {Пропуск пробелов в строке}
    procedure FreeSpace(const v_s: string; var v_input_ptr: word);
    {Получить формальную информацио о мемонике}
    function GetTabMemonic(v_memonic: string): tab;
    {Получить формальный тип параметра для параметра}
    function ParamType(const v_param: string): kinds;
    {Собственно разбор одной Ассемблер строки и вывод результата в буфер}
    function ParseAction(const v_asmtab: Tab; const v_asmline: rASMLine; const v_line, v_global_rem: string; var v_output_ptr: word): rResult;
    {Разбор строки ассемблера на метку, мемонику параметр}
    function ParseAsmLine(const v_s: string): rASMLine;
    function ParseLineNumber: rResult;
    function PrefAddr(const v_d: rASMLine): string;
    function ReplaceLebelRealAddr(const v_d: rASMLine): rResult;
    {Сохранить буфер в файл v_fn.}
    function SaveBufToFile(const v_fn: tfilename): rResult;
    {Разбор одной Ассемблер строки v_s. Результат помещается в выходной буфер по в позицию v_output_ptr}
    function Parse(const v_s, v_global_rem: string; var v_output_ptr: word): rResult;
    {Поместить в выходной буфер байт v_x в позицию v_addres}
    function PutByte(const v_x: byte; const v_line: string; var v_addres: word): rResult;
    {Поместить в выходной буфер слово v_x в позицию v_addres}
    function PutWord(const v_x: word; const v_line: string; var v_addres: word): rResult;
    {Признак того, что строка это блочное примечание.}
    function StringIsBeginRem(const v_s: string): boolean;
    {Признак того, что строка это признак завершения блочного примечания.}
    function StringIsEndRem(const v_s: string): boolean;
    {Признак того, что строка v_s это примечание.}
    function StringIsRem(const v_s: string): boolean;
    {Преобразование строки с числом в формате Ассемблера в число}
    function StrASMToInt(const v_s: string; const v_line: string): rResult;
    {Преоюразоватие строки с примечанием в формат для отобрадения в дебугере}
    function StringRemAsString(const v_rem_str: string): string;

  public
    {Примечание к адресам}
    property Rem: TRemDictionary read fRem write fRem;
    {Выполнить обработку Ассемблера программы из Tstringlist v_bas.}
    function Execute(v_asm: TStringList): rResult; overload;
    {Выполнить обработку Ассемблера из файла v_filenamebas, результат сохранить в v_filenameresult.}
    function Execute(const v_filenameasm, v_filenameresult: string): rResult; overload;
    constructor Create();
    destructor Destroy(); override;
  end;

implementation

{ TASM2ROM }

function TASM2ROM.ParamType(const v_param: string): kinds;
var
  t: TStringList;
  r: integer;
begin
  Result := NONE;
  t := TStringList.Create;
  explode(t, v_param, ',');
  r := 0;
  while r <> t.Count do
  begin
    Inc(r);
  end;
  FreeAndNil(t);
end;

procedure TASM2ROM.ClearASMLine(var v_v: rASMLine);
begin

  // ZeroMemory(@v_v,sizeof(v_v));


  v_v.LineNumber := '';
  v_v.Memonic := '';
  v_v.Param := '';
  v_v.Rem := '';
  v_v.Addr := 0;

end;

procedure TASM2ROM.ClearOutputBuf;
var
  i: word;
begin
  for i := 0 to cOUTBUFSIZE do
    output_buf[i] := 0;
end;

function TASM2ROM.SaveBufToFile(const v_fn: tfilename): rResult;
var
  fsOut: TFileStream;
begin
  fsOut := TFileStream.Create(v_fn, fmCreate or fmOpenReadWrite);
  fsOut.Write(output_buf, cOUTBUFSIZE);
  fsOut.Free;
  ClearResult(Result);
end;


// Пропустим пробелы
procedure TASM2ROM.FreeSpace(const v_s: string; var v_input_ptr: word);
var
  c: string;
begin
  while (v_input_ptr <= UTF8Length(v_s)) do
  begin
    c := GetChar(v_s, v_input_ptr);
    if not isSpace(c) then exit;
    Inc(v_input_ptr);
  end;
end;


function TASM2ROM.ParseAsmLine(const v_s: string): rASMLine;
var
  ekran_symb: string;
  input_ptr: word;
  c, s: string;
  w_linenumber, w_memonic, w_param, w_rem: boolean;
begin
  ClearASMLine(Result);
  input_ptr := 1;
  ekran_symb := '';
  s := '';
  w_linenumber := False;
  w_memonic := False;
  w_param := False;
  w_rem := False;


  FreeSpace(v_s, input_ptr);// Пропустим пробелы

  // определим метку
  while (input_ptr <= UTF8Length(v_s)) do
  begin
    c := GetChar(v_s, input_ptr);

    // работа с экранирующим символом
    // строка будет собираться как есть
    if isAsmParamEkran(c) then
    begin
      if ekran_symb = '' then
        ekran_symb := c
      else
      if ekran_symb = c then
        ekran_symb := '';
    end;

    if (ekran_symb = '') then
    begin
      if isAsmLabelSeparator(c) and (Result.linenumber = '') then
      begin
        w_linenumber := True;
        Result.linenumber := s;
        Inc(input_ptr);
        FreeSpace(v_s, input_ptr);
        s := '';
      end
      else
      if isAsmMemonicSeparator(c) and (Result.memonic = '') then
      begin
        w_memonic := True;
        Result.memonic := s;
        Inc(input_ptr);
        FreeSpace(v_s, input_ptr);
        s := '';
      end
      else
      if isAsmParamSeparator(c) and (Result.param = '') then
      begin
        w_param := True;
        Result.param := s;
        Inc(input_ptr);
        FreeSpace(v_s, input_ptr);
        s := '';
      end
      else
      begin
        s := s + c;
        Inc(input_ptr);
      end;
    end
    else
    begin
      // собираем символы в экране
      s := s + c;
      Inc(input_ptr);
    end;
  end;

  if (Result.memonic = '') and not w_memonic then Result.memonic := s
  else if (Result.param = '') and not w_param then Result.param := s
  else if (Result.rem = '') and not w_rem then Result.rem := s;

end;


procedure TASM2ROM.ClearTab(var v_tab: tab);
begin
  v_tab.mask := 0;
  v_tab.op := 0;
  v_tab.str := '';
  v_tab.kind := NONE;
end;



function TASM2ROM.GetTabMemonic(v_memonic: string): tab;
var
  r: integer;
begin
  v_memonic := UTF8LowerCase(v_memonic);
  r := 0;
  while r <= NTAB do
  begin
    Result := mnem[r];
    if Result.str = v_memonic then exit;
    Inc(r);
  end;
  ClearTab(Result);
end;

function TASM2ROM.StrASMToInt(const v_s: string; const v_line: string): rResult;
var
  w: integer;
  u: string;
begin
  ClearResult(Result);
  if v_s <> '' then
  begin
    // по умолчанию система исчисления шестнадцатиричная
    if trystrtoint('$' + v_s, w) then
    begin
      Result.ExitInt := w;
      exit;
    end
    else
    // попробуем получить число в чистом виде
    // в 8-ричной системе (если задано так &4324)
    if (GetChar(v_s, 1) = '&') and (TryOctToInt(UTF8StringReplace(v_s, '&', '', []), w)) then
    begin
      Result.ExitInt := w;
      exit;
    end
    else
    // в 10-ричной (если задано так 4324)
    if trystrtoint(v_s, w) then
    begin
      Result.ExitInt := w;
      exit;
    end
    else
    begin
      // мжет это char
      u := GetChar(v_s, 1);
      if isAsmParamEkran(u) then
      begin
        u := UTF8StringReplace(v_s, u, '', [rfReplaceAll]);
        w := UTF8StrToANSICode(u);
        Result.ExitInt := w;
        exit;
      end;
    end;
    Result.ExitCode := 1;
    Result.ExitText := 'Ошибка преобразования "' + v_s + '" в число в строке:' + #13#10#13#10 + v_line;

  end;
end;


function TASM2ROM.CheckParam(const v_asmtab: Tab; const v_asmline: rASMLine; const v_line: string): rResult;
begin
  ClearResult(Result);
  if v_asmtab.kind <> ParamType(v_asmline.param) then
  begin
    Result.ExitCode := 5;
    Result.ExitText := 'Недопустимый параметр "' + v_asmline.Param + '".';
  end;
end;

function TASM2ROM.DWDB_CMD(const v_param: string; const v_line: string; const v_min, v_max: integer; var v_output_ptr: word): rResult;
var
  t: TStringList;
  r: integer;
  s: string;
begin
  ClearResult(Result);
  t := TStringList.Create;
  explode(t, v_param, ',');
  r := 0;
  while (r <> t.Count) and (Result.ExitCode = 0) do
  begin
    s := t[r];
    Result := StrASMToInt(s, v_line);
    if Result.ExitCode = 0 then
    begin
      if (Result.ExitInt >= v_min) and (Result.ExitInt <= v_max) then
      begin
        if v_max = 65535 then
          Result := PutWord(Result.ExitInt, v_line, v_output_ptr);
        if v_max = 255 then
          Result := PutByte(Result.ExitInt, v_line, v_output_ptr);
      end
      else
      begin
        Result.ExitCode := 5;
        Result.ExitText := 'Недопустимый значение переменной "' + t[r] + '" (должно быть ' + IntToStr(v_min) + '-' + IntToStr(v_max) + ') в строке:' + #13#10#13#10 + v_line;
      end;
    end;
    Inc(r);
  end;
  FreeAndNil(t);
end;


function TASM2ROM.ANSI_CMD(const v_param: string; const v_line: string; const v_addzeroend: boolean; var v_output_ptr: word): rResult;
var
  ekran: string;
  r: integer;
  b: byte;
begin
  ClearResult(Result);
  ekran := GetChar(v_param, 1);
  if isAsmParamEkran(ekran) then
  begin
    r := 2;
    while (r <= UTF8Length(v_param)) and (getchar(v_param, r) <> ekran) and (Result.ExitCode = 0) do
    begin
      b := UTF8StrToMKCode(GetChar(v_param, r));
      Result := PutByte(b, v_line, v_output_ptr);
      Inc(r);
    end;
    if v_addzeroend then
      Result := PutByte(0, v_line, v_output_ptr);
  end
  else
  begin
    Result.ExitCode := 5;
    Result.ExitText := 'Переменная должна начинаться с кавычек в строке:' + #13#10#13#10 + v_line;
  end;
end;


function TASM2ROM.ASSEMBLE_CMD(const v_asmline: rASMLine; const v_line: string; const v_create_label_list: boolean; var v_output_ptr: word): rResult;
var
  i: integer;
begin
  ClearResult(Result);

  SetLoc(v_output_ptr);
  InBuf := v_asmline.Memonic + ' ' + v_asmline.Param;

  if pos('cmp #3D49,r0', InBuf) <> 0 then
  begin
    InBuf := InBuf;
  end;

  Assemble;
  if InIndex = 0 then
  begin
    i := 0;
    while (i < OutIndex) and (Result.ExitCode = 0) do
    begin
      Result := PutWord(OutBuf[i], v_line, v_output_ptr);
      Inc(i);
    end {while};
    // в строке есть метка, сохраним строку для последуюзей обработки
    if (Result.ExitCode = 0) and v_create_label_list and isLineNumber then
      fLineNumberForLabel.Add(v_asmline);
  end
  else
  begin
    Result.ExitCode := 5;
    Result.ExitText := 'Немогу ассемблировать. Проблема в строке:' + #13#10#13#10 + v_line;
  end;
end;

function TASM2ROM.AddRem(const v_asmline: rASMLine; const v_line, v_global_rem: string; var v_output_ptr: word): rResult;
var
  s: string;
begin
  ClearResult(Result);
  if v_asmline.Rem <> '' then
  begin
    s := v_asmline.Rem;
    if v_global_rem <> '' then s := '*' + v_global_rem + '* ' + s;
    fRem.AddOrSetValue(v_output_ptr, s);
  end;
end;

function TASM2ROM.ORG_CMD(const v_param: string; const v_line: string; const v_addzeroend: boolean; var v_output_ptr: word): rResult;
begin
  ClearResult(Result);
  Result := StrASMToInt(v_param, v_line);
  if Result.ExitCode = 0 then
  begin
    v_output_ptr := Result.ExitInt;
  end;
end;

function TASM2ROM.AddLineNumber(const v_asmline: rASMLine; const v_line, v_global_rem: string; var v_output_ptr: word): rResult;
var
  s: string;
  ln: string;
begin
  ClearResult(Result);
  if v_asmline.LineNumber <> '' then
  begin
    ln := UTF8UpperCase(v_asmline.LineNumber);
    if not fLineNumber.ContainsKey(ln) then
    begin
      fLineNumber.Add(ln, v_output_ptr);
    end
    else
    begin
      Result.ExitCode := 10;
      Result.ExitText := 'Метка "' + ln + '" уже существует. Проблема в строке:' + #13#10#13#10 + v_line;
    end;
  end;
end;


function TASM2ROM.ParseAction(const v_asmtab: Tab; const v_asmline: rASMLine; const v_line, v_global_rem: string; var v_output_ptr: word): rResult;
begin
  ClearResult(Result);

  // если задан адрес инструкции
  // получим его
  if v_asmline.LineNumber <> '' then
  begin
    Result := StrAsmToInt(v_asmline.LineNumber, v_line);
    if Result.ExitCode = 0 then
      v_output_ptr := Result.ExitInt // LineNumber - это адрес, скорректируем указатель
    else
      Result := AddLineNumber(v_asmline, v_line, v_global_rem, v_output_ptr); // строка - это маетка - добавим в таблицу
  end;

  if Result.ExitCode = 0 then
  begin
    Result := AddRem(v_asmline, v_line, v_global_rem, v_output_ptr); // Добавим примечание

    if Result.ExitCode = 0 then
    begin
      // Обработаем команды
      if v_asmtab.str = '.dw' then
        Result := DWDB_CMD(v_asmline.Param, v_line, 0, 65535, v_output_ptr)
      else
      if v_asmtab.str = '.db' then
        Result := DWDB_CMD(v_asmline.Param, v_line, 0, 255, v_output_ptr)
      else
      if v_asmtab.str = '.asciz' then
        Result := ANSI_CMD(v_asmline.Param, v_line, True, v_output_ptr)
      else
      if v_asmtab.str = '.asci' then
        Result := ANSI_CMD(v_asmline.Param, v_line, False, v_output_ptr)
      else
      if v_asmtab.str = '.even' then
      begin
        // неизвестная команда, ничего не делаем
      end
      else
      if v_asmtab.str = '.org' then
      begin
        Result := ORG_CMD(v_asmline.Param, v_line, True, v_output_ptr);
      end
      else
      begin
        Result := ASSEMBLE_CMD(v_asmline, v_line, True, v_output_ptr);
      end;
    end;
  end;

end;


function TASM2ROM.Parse(const v_s, v_global_rem: string; var v_output_ptr: word): rResult;
var
  asmline: rASMLine;
  asmtab: Tab;
begin
  ClearResult(Result);
  asmline := ParseAsmLine(v_s);
  asmline.Addr := v_output_ptr;
  asmtab := GetTabMemonic(asmline.Memonic);
  if asmtab.str <> '' then
  begin
    Result := ParseAction(asmtab, asmline, v_s, v_global_rem, v_output_ptr);
  end
  else
  begin
    Result.ExitCode := 5;
    Result.ExitText := 'Неизвестная мемоника "' + asmline.Memonic + '" в строке ' + #13#10#13#10 + v_s;
  end;
end;


function TASM2ROM.isReg(v_s: string): boolean;
var
  r: integer;
  tr: tab;
begin
  Result := True;
  v_s := UTF8LowerCase(v_s);
  r := 0;
  while r <> NREG do
  begin
    tr := treg[r];
    if tr.str = v_s then exit;
    Inc(r);
  end;
  Result := False;
end;

//Строка - это метка
function TASM2ROM.isLineNumberLabel(const v_s: string): integer;
var
  z: string;
begin
  Result := 1;// строка - это регистр
  if isReg(v_s) then exit;
  z := getChar(v_s, 1);
  Result := 0; // строка - это метка
  if ((z >= 'A') and (z <= 'Z')) or ((z >= 'a') and (z <= 'z')) then exit;
  Result := 2;// строка - это что то другое
end;

function TASM2ROM.PrefAddr(const v_d: rASMLine): string;
var
  t: tab;
begin
  Result := '#';
  t := GetTabMemonic(v_d.Memonic);
  if (t.kind = single) or (t.kind = JSR) or (t.kind = BR) or (t.kind = SOB) then Result := '';
end;

function TASM2ROM.ReplaceLebelRealAddr(const v_d: rASMLine): rResult;
var
  t: TStringList;
  r: integer;
  s, lab: string;
  pref: string;
begin
  ClearResult(Result);
  t := TStringList.Create;
  explode(t, v_d.param, ',');
  r := 0;
  while (r <> t.Count) and (Result.ExitCode = 0) do
  begin
    s := t[r];
    // Строка - это метка
    if isLineNumberLabel(s) = 0 then
    begin
      // Ишем в таблице адресов реальный адрес
      lab := UTF8UpperCase(s);
      if fLineNumber.ContainsKey(lab) then
      begin
        // и собираем троку заново для последуюзей обработки
        pref := PrefAddr(v_d);  // какой следует использовать префикс - для переходов, например он не нужен
        Result.ExitText := Result.ExitText + pref + InttoHex(fLineNumber[lab], 4);
      end
      else
      begin
        Result.ExitCode := 11;
        Result.ExitText := 'Метка "' + s + '" отсутствует в таблице адресов.';
        break;
      end;

    end
    else
      Result.ExitText := Result.ExitText + s;
    if r < t.Count - 1 then  Result.ExitText := Result.ExitText + ',';
    Inc(r);
  end;
  FreeAndNil(t);
end;


function TASM2ROM.ParseLineNumber(): rResult;
var
  r: integer;
  d: rASMLine;
  addr: word;
begin
  ClearResult(Result);
  // обрабатываем список строк с сетками
  r := 0;
  while (r <> fLineNumberForLabel.Count) and (Result.ExitCode = 0) do
  begin
    d := fLineNumberForLabel[r];
    Result := ReplaceLebelRealAddr(d);
    if Result.ExitCode = 0 then
    begin
      // все прошло успешно, обработаем строку
      d.Param := Result.ExitText;
      addr := d.Addr;
      Result := ASSEMBLE_CMD(d, d.Memonic + ' ' + d.Param, False, addr);
    end;

    Inc(r);
  end;
end;


// Признак того, что строка начинается с примечания
function TASM2ROM.StringIsRem(const v_s: string): boolean;
begin
  Result := (UTF8pos(';', AnsiUpperCase(v_s)) = 1);
end;

// Признак того, что строка начинается с примечания
function TASM2ROM.StringIsBeginRem(const v_s: string): boolean;
begin
  Result := (UTF8pos('COMMENT' + cREMCHARFORCOMMENT, AnsiUpperCase(UTF8StringReplace(v_s, ' ', '', [rfReplaceAll]))) = 1);
end;

// Признак того, что строка начинается с примечания
function TASM2ROM.StringIsEndRem(const v_s: string): boolean;
begin
  Result := (UTF8pos(cREMCHARFORCOMMENT, AnsiUpperCase(v_s)) = 1);
end;


function TASM2ROM.isMemoryUsed(const v_addres: word; const v_line: string): rResult;
begin
  ClearResult(Result);
  // признак того, что требуется проверять на уже используетую память
  if fCheckMemUsed then
  begin
    if fTMemUsed.ContainsKey(v_addres) then
    begin
      Result.ExitCode := 11;
      Result.ExitText := 'Адрес "' + inttohex(v_addres, 4) + '" уже используется. Ошибка в строке:' + #13#10#13#10 + v_line;
    end;
  end;
end;



function TASM2ROM.PutWord(const v_x: word; const v_line: string; var v_addres: word): rResult;
begin
  Result := isMemoryUsed(v_addres, v_line);
  if Result.ExitCode = 0 then
  begin
    fTMemUsed.AddOrSetValue(v_addres, True);
    output_buf[v_addres] := (v_x mod 256);
    Inc(v_addres);
  end;
  if Result.ExitCode = 0 then
  begin
    Result := isMemoryUsed(v_addres, v_line);
    if Result.ExitCode = 0 then
    begin
      fTMemUsed.AddOrSetValue(v_addres, True);
      output_buf[v_addres] := (v_x div 256);
      Inc(v_addres);
    end;
  end;
end;

function TASM2ROM.PutByte(const v_x: byte; const v_line: string; var v_addres: word): rResult;
begin
  Result := isMemoryUsed(v_addres, v_line);
  if Result.ExitCode = 0 then
  begin
    fTMemUsed.AddOrSetValue(v_addres, True);
    output_buf[v_addres] := v_x;
    Inc(v_addres);
  end;
end;

function TASM2ROM.StringRemAsString(const v_rem_str: string): string;
begin
  Result := UTF8UpperCase(UTF8Trim(UTF8Copy(v_rem_str, 2, utf8length(v_rem_str))));
end;

function TASM2ROM.Execute(v_asm: TStringList): rResult;
var
  r: word;
  s: string;
  output_ptr: word;
  isremblock, isremstring: boolean;  // это старт блочного комментария?
  globalrem: string;
begin

  fRem.Clear;
  fLineNumber.Clear;
  fTMemUsed.Clear;

  ClearResult(Result);
  ClearOutputBuf();  // clear the output_buf
  output_ptr := 0; // process the BASIC programs
  isremblock := False;
  globalrem := '';
  fCheckMemUsed := True; // признак того, что требуется проверять на уже используетую память

  // Построчная обработка Бейсик программы
  r := 0;
  while (r <> v_asm.Count) and (Result.ExitCode = 0) do
  begin
    s := NormalizeLine(v_asm[r]);
    if (s <> '') then
    begin
      isremstring := StringIsRem(s);

      if not isremblock then
      begin
        isremblock := StringIsBeginRem(s);
        if isremstring then
          globalrem := globalrem + StringRemAsString(s) + ' ';
      end;

      if not isremblock and not isremstring then
      begin
        globalrem := UTF8Trim(globalrem);
        Result := Parse(s, globalrem, output_ptr);
        globalrem := '';
      end;

      if isremblock and StringIsEndRem(s) then isremblock := False;
    end;
    Inc(r);
  end;

  // Разобрали все и все хорошо
  // обработаем метки
  fCheckMemUsed := False;// признак того, что требуется проверять на уже используетую память
  if Result.ExitCode = 0 then
    Result := ParseLineNumber();

end;

function TASM2ROM.Execute(const v_filenameasm, v_filenameresult: string): rResult;
var
  bas: TStringList;
begin
  if fileexists(v_filenameasm) then
  begin
    bas := TStringList.Create;
    bas.LoadFromFile(v_filenameasm);
    Result := Execute(bas);
    if Result.ExitCode = 0 then Result := SaveBufToFile(v_filenameresult);
    FreeAndNil(bas);
  end
  else
  begin
    Result.ExitCode := 1; // файл отсутствует
    Result.ExitText := 'Файл "' + v_filenameasm + '" отсутствует.';
  end;
end;

constructor TASM2ROM.Create;
begin
  frem := TRemDictionary.Create;
  fLineNumber := TLineNumberDictionary.Create;
  fLineNumberForLabel := TLineNumberForLabel.Create;
  fTMemUsed := TMemUsed.Create;
end;

destructor TASM2ROM.Destroy;
begin
  inherited Destroy;
  FreeAndNil(frem);
  FreeAndNil(fLineNumber);
  FreeAndNil(fLineNumberForLabel);
  FreeAndNil(fTMemUsed);
end;

end.
