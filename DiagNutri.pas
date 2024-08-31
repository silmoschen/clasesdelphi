unit DiagNutri;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Mask, Grids, ExtCtrls, ComCtrls, Editv, DBCtrls,
  ToolWin, DB;

type
  TfmDiagnosticoNutricional = class(TForm)
    StatusBar1: TStatusBar;
    Panel5: TPanel;
    ToolBar1: TToolBar;
    DBNavigator: TDBNavigator;
    Alta: TToolButton;
    Baja: TToolButton;
    Modificar: TToolButton;
    Buscar: TToolButton;
    Deshacer: TToolButton;
    Salir: TToolButton;
    DTS: TDataSource;
    Label5: TLabel;
    Label1: TLabel;
    descrip: TMaskEdit;
    items: TMaskEdit;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure descripKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure AltaClick(Sender: TObject);
    procedure Panel5Resize(Sender: TObject);
    procedure SalirClick(Sender: TObject);
    procedure DBNavigatorClick(Sender: TObject; Button: TNavigateBtn);
  private
    { Private declarations }
    redim: Boolean;
    procedure CargarDatos;
  public
    { Public declarations }
  end;

var
  fmDiagnosticoNutricional: TfmDiagnosticoNutricional;

implementation

uses
  CDiagnosticoNutricional_Vicentin, CUtiles, CConfigForms, ImgForms;

{$R *.dfm}

procedure TfmDiagnosticoNutricional.CargarDatos;
Begin
  diagnosticonut.getDatos(items.Text);
  descrip.Text := diagnosticonut.descrip;
end;

procedure TfmDiagnosticoNutricional.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  diagnosticonut.BuscarPorDescrip(descrip.Text); 
  configform.Guardar(fmDiagnosticoNutricional, redim);
end;

procedure TfmDiagnosticoNutricional.FormShow(Sender: TObject);
begin
  configform.Setear(fmDiagnosticoNutricional);
  CargarDatos;
  descrip.SetFocus;
  redim := False;
  DTS.DataSet := diagnosticonut.tabla;
end;

procedure TfmDiagnosticoNutricional.FormResize(Sender: TObject);
begin
  StatusBar1.Panels[0].Width := Width - 100;
end;

procedure TfmDiagnosticoNutricional.descripKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if (Key = VK_RETURN) or (Key = VK_DOWN) then
    if Length(Trim(descrip.Text)) > 0 then Begin
      if (length(Trim(items.Text)) = 3) and (Length(Trim(descrip.Text)) > 0) then Begin
        diagnosticonut.Registrar(items.Text, descrip.Text);
        Close;
      end;
    end;
end;

procedure TfmDiagnosticoNutricional.AltaClick(Sender: TObject);
begin
  items.Text := utiles.sLlenarIzquierda(diagnosticonut.Nuevo, 3, '0');
end;

procedure TfmDiagnosticoNutricional.Panel5Resize(Sender: TObject);
begin
  redim := True;
end;

procedure TfmDiagnosticoNutricional.SalirClick(Sender: TObject);
begin
  Close;
end;

procedure TfmDiagnosticoNutricional.DBNavigatorClick(Sender: TObject;
  Button: TNavigateBtn);
begin
  items.Text := diagnosticonut.tabla.FieldByname('items').AsString;
  CargarDatos;
end;

end.
