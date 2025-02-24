REM 01.03.2025 Головейко Александр
REM
REM Это пример программы для загрузки ее в калькулятор из командной строки
REM Для запуска используйте следующую конструкцию
REM mk85m.exe -basfn "runner.bas" -ramfn "runner.ram" -ar 0 -cm 0
REM где
REM -basfn "runner.bas" имя бейсик программы
REM -ramfn "runner.ram" имя блока памяти, куда будет загружена бейсик программа
REM -ar 0 автозапуск Бейсик программы после запуска приложения
REM -cm 0 режим выхода из программы
REM
REM Для получения дополнительной справки выполни mk85m.exe -help
REM
REM Версию эмулятора микрокомпьтера "Электроника МК85" для работы с коммандной строкой ищи на
REM https://github.com/MatrexAl/mk85emsl

REM  MK85 MEGA Runner v1.9.0.2(2) 2025.02.11 (c)2024 DISSEMBILL software by Nick Korn
REM 
REM  Игра MEGA MK85 Runner для микрокомпьютера МК-85.
REM  Автор Николай Корнейчук.
REM 
REM  Источник: https://pikabu.ru/story/prodolzhenie_posta_mk85_runner_igra_dlya_mikrokompyutera_yelektronika_mk85_12375386#comments
REM 
REM  В игре 240 уровней, по 7 кладов в каждом.
REM  Ходить влево и вправо: 4 и 6;
REM  Лезть по лестнице вверх и вниз: 8 и 2;
REM  Прожигать блоки слева и справа: 1 и 3.




1 VAC:O$="":GOTO 86
2 CSR P:PRINT CHR 96;
3 $="63761C6DA1OEOMG":RETURN
4 $="KFSI2LF6AA5U798":A=FRAC (Y/5)*60+P+7:RETURN
5 $="COSCG6CMAG3E3D1":RETURN
6 Z=B(P):$="VVVV000EAE0000099F9999F9900009":S$=MID (5-SGN Z,1)
7 R$="":IF Z<=1 THEN 4:R$="F9":IF Z>3;R$="VV"
8 S$=MID (36-Z*5,5)+R$:GOTO 4+V
9 $="МЛМУЕЧЛЙЛитМБфцфцМыиБикфуЛуЯйН":RETURN
10 $="ВЕНГЕГЁьПувёУяиЕМуЕМитффжМиБии":RETURN
11 $="ФМЩЛОМтюПБфюБфитиПтюПБфюЙииуЛМ":RETURN
12 $="ЩГВВЭЛЛуМНКШКЧЧЩЙКкЛЛХПкЙБйЯий":RETURN
13 $="ЕФГВГВёёщгёВщуямтМялЧЧШЛЯйММЛЙ":RETURN
14 $="ЕОВВЕЕтмммтякОВЧШицгЁУШфРлМиЙи":RETURN
15 $="ВЕЧЧЧЭЕуЛМЛЙщИйфбкёЬЧЧЬБтИИИИя":RETURN
16 $="ЕМГЕМГтиуьЬжцфюьПфккМтиАБРиРюж":RETURN
17 $="ВЕФГЕГЁёёчьёВчёупёЁьёьПтМпжуМБ":RETURN
18 $="ЛЧЁВВФБЁВЕМётЧЁьПёШЁЁьютБММяий":RETURN
80 IF LEN O$=7;W=W+5:O$="":IF Y=W-1;Z=4:FOR P=T TO T:GOTO 93
81 U=-1:LETC "05U798":Q=ASCI KEY-50:IF Q>=2;IF Q<=4;V=Q-3
82 IF ABS Q*SGN Y=1;IF B(X+Q)=5;FOR P=X+Q TO P:Z=U:GOTO 93
83 IF Z>0;U=U+SGN INT (ABS Q+Z/4):IF ABS (Q*Z-21)=3;U=1:LETC "7E910"+R$
84 IF U=0;IF B(X+V)>6*ABS V THEN 81:LETC S$:GOSUB 2:X=X+V:GOTO 94
85 GOSUB 2:IF Y*U+U=W;IF O$="";PRINT W/5;N;:IF Y>=1199;END
86 Y=Y+U:FOR P=0 TO 11:V=P/2:A=Y/50:IF FRAC V<>0 THEN 89:GOSUB 9+FRAC A*10
87 R=A/12:R=FRAC (INT (INT V*(1+INT R)+INT (P/6)*INT R+A)/6)*6+1
88 Q=ASCI GETC ($,FRAC (Y/5)*30+R)/8-16
89 Z=INT Q:IF P<>INT V*2+SGN FRAC(INT (A/6)/2);Z=FRAC Q*8
90 IF B(P)+U+9=Z;Z=5
91 GOSUB 4:FOR R=1 TO LEN O$:IF Z=6;Z=5:IF ASCI GETC (O$,R)<>A;IF Y>=W;Z=6
92 NEXT R:IF Z=4;T=P:IF Y=W+4;Z=5
93 CSR P:PRINT ".";:B(P)=Z:V=0:GOSUB 6:LETC S$:GOSUB 2:NEXT P
94 P=X:FOR U=1 TO 11 STEP 5:GOSUB 6:IF Z=6;GOSUB 4:O$=O$+CHR A:B(P)=5
95 LETC MID (U,5)+R$:GOSUB 2:NEXT U:N=N+1:GOTO 80
