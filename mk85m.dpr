program mk85m;

uses
  Forms, Interfaces,
  Main in 'main.pas' {MainForm},
  Def in 'def.pas',
  Cpu in 'cpu.pas',
  Decoder in 'decoder.pas',
  Exec in 'exec.pas',
  Srcdst in 'srcdst.pas',
  Numbers in 'numbers.pas',
  Debug in 'debug.pas' {DebugForm},
  Pdp11dis in 'pdp11dis.pas',
  Keyboard in 'keyboard.pas', bas2ram, proc, asm2rom, BrakPointDialog;

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TDebugForm, DebugForm);
  Application.CreateForm(TBreakPointDialogForm, BreakPointDialogForm);
  Application.Run;
end.
