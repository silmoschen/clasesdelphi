unit OrdenDeSalida;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ExtCtrls, DB, DBTables, ComCtrls;

type
  TOrdenDeDatos = class(TForm)
    Aplicar: TBitBtn;
    Cancelar: TBitBtn;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    Image2: TImage;
    Image1: TImage;
    StatusBar1: TStatusBar;
    procedure CheckBox1Click(Sender: TObject);
    procedure CheckBox2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    idx_porcampos: boolean;
    ordenDatos   : string;
  end;

var
  OrdenDeDatos: TOrdenDeDatos;

implementation

{$R *.DFM}

procedure TOrdenDeDatos.CheckBox1Click(Sender: TObject);
begin
  if CheckBox1.Checked then CheckBox2.Checked:= False;
  ordenDatos := 'C';
end;

procedure TOrdenDeDatos.CheckBox2Click(Sender: TObject);
begin
  if CheckBox2.Checked then CheckBox1.Checked:= False;
  ordenDatos := 'A';
end;

procedure TOrdenDeDatos.FormCreate(Sender: TObject);
begin
  Left := StrToInt(FormatFloat('####', (Screen.DesktopWidth / 2) - (Width / 2)));
end;

end.
