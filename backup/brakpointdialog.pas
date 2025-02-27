unit BrakPointDialog;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls;

type

  { TBreakPointDialogForm }

  TBreakPointDialogForm = class(TForm)
    Bevel1: TBevel;
    Button1: TButton;
    Button2: TButton;
    leAddres: TLabeledEdit;
    leRem: TLabeledEdit;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    fResult:boolean;
  public
    function Execute(): boolean;
  end;

var
  BreakPointDialogForm: TBreakPointDialogForm;

implementation

{$R *.lfm}

{ TBreakPointDialogForm }

procedure TBreakPointDialogForm.FormShow(Sender: TObject);
begin
  fResult := False;
end;

procedure TBreakPointDialogForm.Button1Click(Sender: TObject);
begin
  fresult:=true;
  close;
end;

procedure TBreakPointDialogForm.Button2Click(Sender: TObject);
begin
  close;
end;

function TBreakPointDialogForm.Execute: boolean;
begin
  fResult := False;
  showmodal;
  Result := fResult;
end;

end.
