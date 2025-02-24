unit proc;

{$mode ObjFPC}{$H+}

interface

{
Процедуры и функции для
}


uses
  Classes, SysUtils, lazUTF8;

const
  {ANSI таблица для преобразования UTF8 символа в код}
  cANSITABLE = ' !"#$%&''()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~?' +
    'ЂЃ‚ѓ„…†‡€‰Љ‹ЊЌЋЏђ‘’“”•–—?™љ›њќћџ?ЎўЋ¤Ґ¦§Ё©Є«¬­®Ї°±Ііґµ¶·ё№є»јЅѕїАБВГДЕЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯабвгдежзийклмнопрстуфхцчшщъыьэюя';


  // Cyrillic character conversion table Windows-1251 -> MK85, codes 0xC0-0xFF.
  // Characters "jo" aren't included and have to be handled separately. */
  cCHARTAB: array [0..63] of byte = (
    &241, &242, &267, &247, &244, &245, &266, &272,
    &251, &252, &253, &254, &255, &256, &257, &260,
    &262, &263, &264, &265, &266, &250, &243, &276,
    &273, &275, &036, &271, &270, &274, &240, &261,
    &201, &202, &227, &207, &204, &205, &226, &232,
    &211, &212, &213, &214, &215, &216, &217, &220,
    &222, &223, &224, &225, &206, &210, &203, &236,
    &233, &235, &037, &231, &230, &234, &200, &221
    );

{Результат выполнения функции}
type
  rResult = record
    ExitCode: integer;
    ExitText: string;
    ExitInt: integer;
  end;

{Возвращает один символ из UTF8 строки v_s в позиции v_pos.}
function GetChar(const v_s: string; const v_pos: word): string;
{Символ является управляющим.}
function isCntrl(const v_s: string): boolean;
{Символ - это число.}
function isDigit(const v_s: string): boolean;
{Символ - это восклицательный знак.}
function isExclamation(const v_s: string): boolean;
{Символ - это знак экспоненты.}
function isExponenta(const v_s: string): boolean;
{Символ - это кавычка}
function isQuotes(const v_s: string): boolean;
{Символ - это пробел}
function isSpace(const v_s: string): boolean;
{Возвращает ANSI код для UTF8 символа.}
function UTF8StrToANSICode(const v_s: string): byte;
{Очищает переменную типа rResult}
procedure ClearResult(var v_v: rResult);
{Из строки v_s убирает управляющие символы и делает строку пригодной для последующего разбора}
function NormalizeLine(const v_s: string): string;

{Символ - это разделитель метки ассемблера и мемоники}
function isAsmLabelSeparator(const v_s: string): boolean;
{Символ - это разделитель мемоники и данныз}
function isAsmMemonicSeparator(const v_s: string): boolean;
{Символ - это разделитель данными и примечанием}
function isAsmParamSeparator(const v_s: string): boolean;
{Символ - это экран данных}
function isAsmParamEkran(const v_s: string): boolean;
{Разбить строку v_s по сепаратору v_sep, результат в v_t. }
procedure Explode(v_t: TStrings; const v_s: string; v_sep: string);
{Восьмиричное число в строку}
function OctToInt(v_value: string): integer;
{Восьмиричное число в строку}
function TryOctToInt(v_value: string; var v_res: integer): boolean;
{Преобразование UTF8 символа v_s к коды символов калькулятора.}
function UTF8StrToMKCode(const v_s: string): byte;


implementation


function UTF8StrToMKCode(const v_s: string): byte;
begin
  Result := UTF8StrToANSICode(v_s);
  if (Result = &250) then  //* JO */
    Result := &277;
  if (Result = &270) then  //* jo */
    Result := &237;
  if (Result >= &300) then
    Result := cCHARTAB[Result - &300];
end;

function OctToInt(v_value: string): integer;
var
  i, int: integer;
begin
  int := 0;
  for i := 1 to UTF8Length(v_value) do
    int := int * 8 + StrToInt(GetChar(v_value, i));
  Result := int;
end;


function TryOctToInt(v_value: string; var v_res: integer): boolean;
begin
  try
    v_res := 0;
    v_res := OctToInt(v_value);
    Result := True;
  except
    Result := False;
  end;
end;


procedure Explode(v_t: TStrings; const v_s: string; v_sep: string);
var
  r: integer;
  s, line: string;
  ecran: string;
begin
  v_t.Clear;
  ecran := '';
  line := '';
  for r := 1 to utf8length(v_s) do
  begin
    s := getchar(v_s, r);
    if isAsmParamEkran(s) then
    begin
      if (ecran = '') then ecran := s
      else
      if (ecran <> '') and (ecran = s) then ecran := '';
    end;
    if (v_sep = s) and (ecran = '') then
    begin
      v_t.Add(UTF8trim(line));
      line := '';
    end
    else
      line := line + s;
  end;
  if line <> '' then v_t.Add(UTF8trim(line));
//  v_t.savetofile('lines.txt');
end;


function NormalizeLine(const v_s: string): string;
var
  r: byte;
begin
  Result := UTF8trim(v_s);
  for r := 1 to 31 do
    Result := UTF8StringReplace(Result, chr(r), ' ', [rfReplaceAll]);
end;

procedure ClearResult(var v_v: rResult);
begin
  v_v.ExitCode := 0;
  v_v.ExitText := '';
  v_v.ExitInt := 0;
end;

function isDigit(const v_s: string): boolean;
begin
  Result := (v_s >= '0') and (v_s <= '9');
end;

function isQuotes(const v_s: string): boolean;
begin
  Result := (v_s = '"');
end;


function isAsmLabelSeparator(const v_s: string): boolean;
begin
  Result := (v_s = ':');
end;

function isAsmMemonicSeparator(const v_s: string): boolean;
begin
  Result := (v_s = ' ');
end;

function isAsmParamSeparator(const v_s: string): boolean;
begin
  Result := (v_s = ';');
end;


{Символ - это экран данных}
function isAsmParamEkran(const v_s: string): boolean;
begin
  Result := (v_s = '''') or (v_s = '"');
end;

function isSpace(const v_s: string): boolean;
begin
  Result := (v_s = ' ');
end;

function isExclamation(const v_s: string): boolean;
begin
  Result := (v_s = '!');
end;

function isCntrl(const v_s: string): boolean;
begin
  Result := (UTF8StrToANSICode(v_s) <= 31);
end;

function isExponenta(const v_s: string): boolean;
begin
  Result := (UTF8UpperCase(v_s) = 'E');
end;


function UTF8StrToANSICode(const v_s: string): byte;
var
  i: word;
begin
  Result := 32;
  for i := 1 to UTF8Length(cANSITABLE) do
  begin
    if v_s = GetChar(cANSITABLE, i) then exit;
    Inc(Result);
  end;
  Result := 31;
end;


function GetChar(const v_s: string; const v_pos: word): string;
begin
  Result := UTF8Copy(v_s, v_pos, 1);
end;


end.
