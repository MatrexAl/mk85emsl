unit bas2ram;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, lazutf8, proc;

const
  cRAMSTART = $8000;  // address of the RAM
  cVARS = 26;         // Количество переменных
  cOUTBUFSIZE = 2048; // Выходной буфер, байт
  cMAXOUTBUF = (cOUTBUFSIZE - cVARS * 8); // Максимальный размер программы
  cCOUNTTREE = 55; // Количество токенов
  {Список токенов.}
  cTreeStr: array[0..cCOUNTTREE] of string = (
    '<=',
    '<>',
    '=<',
    '=>',
    '>=',
    'ABS',
    'ACS',
    'ASCI',
    'ASN',
    'ATN',
    'AUTO',
    'CHR',
    'CLEAR',
    'COS',
    'CSR',
    'DEFM',
    'DRAWC',
    'DRAW',
    'END',
    'EXP',
    'FOR',
    'FRAC',
    'GETC',
    'GOSUB',
    'GOTO',
    'IF',
    'INPUT',
    'INT',
    'KEY',
    'LEN',
    'LETC',
    'LIST',
    'LN',
    'LOG',
    'MID',
    'MODE',
    'NEXT',
    'PI',
    'PRINT',
    'RAN#',
    'RETURN',
    'RND',
    'RUN',
    'SET',
    'SGN',
    'SIN',
    'SQR',
    'STEP',
    'STOP',
    'TAN',
    'TEST',
    'THEN',
    'TO',
    'VAC',
    'VAL',
    'WHO'
    );

  {Коды токенов}
  cTreeVal: array[0..cCOUNTTREE] of byte = (
    &137,            //     '<=',
    &134,            //     '<>',
    &137,            //     '=<',
    &176,            //     '=>',
    &176,            //     '>=',
    &312,            //     'ABS',
    &304,            //     'ACS',
    &321,            //     'ASCI',
    &303,            //     'ASN',
    &305,            //     'ATN',
    &356,            //     'AUTO',
    &320,            //     'CHR',
    &357,            //     'CLEAR',
    &301,            //     'COS',
    &327,            //     'CSR',
    &346,            //     'DEFM',
    &352,            //     'DRAWC',
    &353,            //     'DRAW',
    &344,            //     'END',
    &310,            //     'EXP',
    &335,            //     'FOR',
    &315,            //     'FRAC',
    &324,            //     'GETC',
    &332,            //     'GOSUB',
    &331,            //     'GOTO',
    &334,            //     'IF',
    &337,            //     'INPUT',
    &313,            //     'INT',
    &326,            //     'KEY',
    &317,            //     'LEN',
    &345,            //     'LETC',
    &355,            //     'LIST',
    &307,            //     'LN',
    &306,            //     'LOG',
    &323,            //     'MID',
    &350,            //     'MODE',
    &330,            //     'NEXT',
    &174,            //     'PI',
    &336,            //     'PRINT',
    &325,            //     'RAN#',
    &333,            //     'RETURN'
    &322,            //     'RND',
    &354,            //     'RUN',
    &351,            //     'SET',
    &314,            //     'SGN',
    &300,            //     'SIN',
    &311,            //     'SQR',
    &342,            //     'STEP',
    &343,            //     'STOP',
    &302,            //     'TAN',
    &360,            //     'TEST',
    &340,            //     'THEN',
    &341,            //     'TO',
    &347,            //     'VAC',
    &316,            //     'VAL',
    &361             //     'WHO'
    );


{Информация о токене.}
type
  rTreeStr = record
    str: string; // Сам токен
    val: byte; // и его код
  end;


type
  {
   TBAS2RAM класс для преобразования Бейсик программы в RAM микрокалькулятора Электроника МК85.
   За основу взят модуль BAS2RAM.C с сайта https://calculators.pdp-11.ru/mk85emue.htm
   Головейко Александр, 01.03.2025 г.
  }
  TBAS2RAM = class
  private
    {Буфер преобразованной бейсик программы.}
    output_buf: array[0..cOUTBUFSIZE] of byte;
    {Очистка буфера}
    procedure ClearOutputBuf();
    {Подчистка переменной типа rTreeStr.}
    procedure ClearTreeStr(var v_v: rTreeStr);
    {Поиск строки v_cfc в v_s начиная с позиции v_pos.}
    function CompareString(const v_cfc: string; const v_s: string; v_pos: word): boolean;
    {Поиск токена в строке v_s начиная с позиции v_input_ptr.}
    function find_tree(const v_s: string; const v_input_ptr: word): rTreeStr;
    {Инициализация адресной таблицы для Бейсик программы}
    procedure InitProgramAdressTable();
    {Разбор одной Бейсик строки v_s. Результат помещается в выходной буфер по в позицию v_output_ptr}
    function Parse(const v_s: string; var v_output_ptr: word): rResult;
    {Поместить в выходной буфер байт v_x в позицию v_addres}
    procedure PutByte(const v_x: byte; var v_addres: word);
    {Поместить в выходной буфер слово v_x в позицию v_addres}
    procedure PutWord(const v_x: word; var v_addres: word);
    {Сохранить буфер в файл v_fn.}
    function SaveBufToFile(const v_fn: tfilename): rResult;
    {Признак того, что строка v_s это примечание.}
    function StringIsRem(const v_s: string): boolean;
    {Обновление адресного пространства программы с индексом v_program по результатам обработки Бейсик программы.}
    procedure UpdateProgramAdressTable(const v_program: byte; const v_output_ptr: word);
    {Инициализация Бейсик переменных}
    procedure UpdateVariableTable(const v_output_ptr: word; const v_var_count: word);
  public
    {Выполнить обработку Бейсик программы из Tstringlist v_bas.}
    function Execute(v_bas: TStringList): rResult; overload;
    {Выполнить обработку Бейсик программы из файла v_filenamebas, результат сохранить в v_filenameresult.}
    function Execute(const v_filenamebas, v_filenameresult: string): rResult; overload;
    constructor Create();
    destructor Destroy(); override;
  end;

implementation


{ TBAS2RAM }

// Признак того, что строка начинается с примечания
function TBAS2RAM.StringIsRem(const v_s: string): boolean;
begin
  Result := (UTF8pos('REM', UTF8UpperCase(v_s)) = 1);
end;

procedure TBAS2RAM.PutWord(const v_x: word; var v_addres: word);
begin
  output_buf[v_addres] := (v_x mod 256);
  Inc(v_addres);
  output_buf[v_addres] := (v_x div 256);
  Inc(v_addres);
end;

procedure TBAS2RAM.PutByte(const v_x: byte; var v_addres: word);
begin
  output_buf[v_addres] := v_x;
  Inc(v_addres);
end;



function TBAS2RAM.CompareString(const v_cfc: string; const v_s: string; v_pos: word): boolean;
var
  r: integer;
begin
  Result := False;
  for r := 1 to UTF8Length(v_cfc) do
  begin
    if UTF8UpperCase(GetChar(v_cfc, r)) <> UTF8UpperCase(GetChar(v_s, v_pos - 1 + r)) then exit;
  end;
  Result := True;
end;


function TBAS2RAM.find_tree(const v_s: string; const v_input_ptr: word): rTreeStr;
var
  r: word;
begin
  ClearTreeStr(Result);
  r := 0;
  while (r <> cCOUNTTREE) and (Result.val = 0) do
  begin
    if CompareString(cTreeStr[r], v_s, v_input_ptr) then
    begin
      Result.str := cTreeStr[r];
      Result.val := cTreeVal[r];
      exit;
    end;
    Inc(r);
  end;
end;



// Разбор Бейсик строки s с записью результата по адресу  output_ptr
function TBAS2RAM.Parse(const v_s: string; var v_output_ptr: word): rResult;
var
  input_ptr: word;
  linenumber: string;
  max_out_ptr: word;
  comment, quotes, digit: boolean;
  treeptr1: rTreeStr;
begin
  ClearResult(Result);

  max_out_ptr := v_output_ptr + 63;
  comment := False;
  quotes := False;
  digit := False;
  input_ptr := 1;
  linenumber := '';

  // определяем номер строки
  while (input_ptr <= UTF8Length(v_s)) and isDigit(GetChar(v_s, input_ptr)) do
  begin
    linenumber := linenumber + GetChar(v_s, input_ptr);
    Inc(input_ptr);
  end;

  // номер строки не определен либо >60000
  if (linenumber = '') or (StrToInt(linenumber) > 60000) then
  begin
    Result.ExitCode := 4;
    Result.ExitText := 'Строка должна начинаться с номера строки, или номер строки слишком большой:' + #13#10#13#10 + v_s;
    exit;
  end;

  // сохраним номер строки
  PutWord(StrToInt(linenumber), v_output_ptr);

  while (input_ptr <= UTF8Length(v_s)) and (v_output_ptr <= max_out_ptr) do
  begin

    // Это двойная кавычка
    if isQuotes(GetChar(v_s, input_ptr)) then quotes := not (quotes);

    // Символы после двойных кавычек идут как есть
    if (quotes or comment) then
    begin
      if not (isCntrl(GetChar(v_s, input_ptr))) then PutByte(UTF8StrToMKCode(GetChar(v_s, input_ptr)), v_output_ptr);
      Inc(input_ptr);
      digit := False;
    end
    else
    begin
      // Может быть дальше идет ключевой слово?
      treeptr1 := find_tree(v_s, input_ptr);
      if (treeptr1.val <> 0) then
      begin
        PutByte(treeptr1.val, v_output_ptr);
        input_ptr := input_ptr + length(treeptr1.str);
        digit := False;
      end
      // Это восклицательный знак (т.е. комментарий)?
      else if (isExclamation(GetChar(v_s, input_ptr))) then
      begin
        PutByte(Ord(GetChar(v_s, input_ptr)[1]), v_output_ptr);
        Inc(input_ptr);
        comment := True;
        digit := False;
      end
      // Это число с экспонентой?
      else if (digit and isExponenta(GetChar(v_s, input_ptr))) then
      begin
        Inc(input_ptr);
        // Отрицательной
        if (GetChar(v_s, input_ptr) = '-') then
        begin
          PutByte(&175, v_output_ptr);
          Inc(input_ptr);
        end
        else
        begin
          // Положительной
          PutByte(&173, v_output_ptr);
          Inc(input_ptr);
        end;
        digit := False;
      end
      // Это пробел?
      else if (isSpace(GetChar(v_s, input_ptr))) then
        Inc(input_ptr)
      // Остальные символы копируем как есть
      else
      begin
        PutByte(UTF8StrToMKCode(GetChar(v_s, input_ptr)), v_output_ptr);
        digit := isdigit(GetChar(v_s, input_ptr));
        Inc(input_ptr);
      end;
    end;
  end;

  // Конец строки
  PutByte(0, v_output_ptr);

  if (v_output_ptr > max_out_ptr) then
  begin
    Result.ExitCode := 4;
    Result.ExitText := 'Слишком длинная строка:' + #13#10#13#10 + v_s;
  end;

end;


procedure TBAS2RAM.ClearTreeStr(var v_v: rTreeStr);
begin
  v_v.str := '';
  v_v.val := 0;
end;


procedure TBAS2RAM.ClearOutputBuf();
var
  i: word;
begin
  for i := 0 to cOUTBUFSIZE do
    output_buf[i] := 0;
end;


procedure TBAS2RAM.InitProgramAdressTable();
var
  output_ptr: word;
  i: word;
begin
  output_ptr := $022C;
  for i := 0 to 10 do
    PutWord($826B, output_ptr);
end;

procedure TBAS2RAM.UpdateProgramAdressTable(const v_program: byte; const v_output_ptr: word);
var
  save_ptr: word;
  i: integer;
begin
  // update the program address table
  save_ptr := $022C + 2 * v_program;
  for i := v_program to 9 do
    PutWord(v_output_ptr + cRAMSTART, save_ptr);
end;


procedure TBAS2RAM.UpdateVariableTable(const v_output_ptr: word; const v_var_count: word);
var
  i: word;
  output_ptr: word;
begin
  i := $0800; // MK-85

  // determine the required RAM size
  if (v_output_ptr > $0800 - v_var_count * 8) then
    i := $1800; // MK-85M

  // initialise important system variables */
  output_ptr := $0250;
  PutWord(cVARS, output_ptr); //* number of variables
  PutWord(cRAMSTART + i, output_ptr);  // top of the RAM
end;


function TBAS2RAM.Execute(v_bas: TStringList): rResult;
var
  r: word;
  s: string;
  prog: byte;
  output_ptr: word;
begin
  prog := 0; // запись в нулевую программу

  ClearResult(Result);
  ClearOutputBuf();  // clear the output_buf
  InitProgramAdressTable(); // initialise the program address table
  output_ptr := $026B; // process the BASIC programs

  // Построчная обработка Бейсик программы
  r := 0;
  while (r <> v_bas.Count) and (Result.ExitCode = 0) do
  begin
    s := NormalizeLine(v_bas[r]);
    if (s <> '') and not StringIsRem(s) then
    begin
      Result := parse(s, output_ptr);
    end;
    Inc(r);
  end;

  UpdateProgramAdressTable(prog, output_ptr); // update the program address table
  UpdateVariableTable(output_ptr, cVARS); // initialise important system variables;
end;


function TBAS2RAM.SaveBufToFile(const v_fn: tfilename): rResult;
var
  fsOut: TFileStream;
begin
  fsOut := TFileStream.Create(v_fn, fmCreate or fmOpenReadWrite);
  fsOut.Write(output_buf, cOUTBUFSIZE);
  fsOut.Free;
  ClearResult(Result);
end;



function TBAS2RAM.Execute(const v_filenamebas, v_filenameresult: string): rResult;
var
  bas: TStringList;
begin
  if fileexists(v_filenamebas) then
  begin
    bas := TStringList.Create;
    bas.LoadFromFile(v_filenamebas);
    Result := Execute(bas);
    if Result.ExitCode = 0 then Result := SaveBufToFile(v_filenameresult);
    FreeAndNil(bas);
  end
  else
  begin
    Result.ExitCode := 1; // файл отсутствует
    Result.ExitText := 'Файл "' + v_filenamebas + '" отсутствует.';
  end;
end;

constructor TBAS2RAM.Create;
begin

end;

destructor TBAS2RAM.Destroy;
begin
  inherited Destroy;
end;



end.
