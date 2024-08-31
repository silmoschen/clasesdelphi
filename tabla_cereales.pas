unit tabla_cereales;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, ExtCtrls, Buttons, DB, DBTables, Mask, DBCtrls,
  ComCtrls, ToolWin, Editv;

type
  TfmTablaCereales = class(TForm)
    Panel2: TPanel;
    ScrollBox: TScrollBox;
    Label1: TLabel;
    Label2: TLabel;
    id: TMaskEdit;
    StatusBar1: TStatusBar;
    descrip: TMaskEdit;
    DTS: TDataSource;
    Panel1: TPanel;
    ToolBar1: TToolBar;
    DBNavigator: TDBNavigator;
    Alta: TToolButton;
    Baja: TToolButton;
    Modificar: TToolButton;
    Buscar: TToolButton;
    Deshacer: TToolButton;
    Salir: TToolButton;

    procedure idKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure descripKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure AltaClick(Sender: TObject);
    procedure BajaClick(Sender: TObject);
    procedure ModificarClick(Sender: TObject);
    procedure DeshacerClick(Sender: TObject);
    procedure SalirClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure Panel2Resize(Sender: TObject);
  private
    { Private declarations }
    redim: Boolean;
    procedure CargarDatos;
  public
    { Public declarations }
  end;

var
  fmTablaCereales: TfmTablaCereales;

implementation

uses CCereales_Espiga, CUtiles, ImgForms, CConfigForms;

{$R *.DFM}

procedure TfmTablaCereales.CargarDatos;
begin
  cereales.getDatos(id.Text);
  descrip.Text := cereales.Descrip;
end;

procedure TfmTablaCereales.idKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then Close;
  if Key = VK_INSERT then AltaClick(Sender);
  if (Key = VK_RETURN) or (Key = VK_DOWN) then Begin
    id.Text := utiles.sLlenarIzquierda(id.Text, 3, '0');
    if cereales.Buscar(id.Text) then Begin
      CargarDatos;
      descrip.SetFocus;
    end else
      if utiles.DarDeAlta('Código de Cereal ' + id.Text) then Begin
        CargarDatos;
        descrip.setFocus;
      end;
    end;
end;

procedure TfmTablaCereales.descripKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_UP then id.SetFocus;
  if (Key = VK_RETURN) or (Key = VK_DOWN) then
    if Length(Trim(descrip.Text)) > 0 then
      if Length(Trim(id.Text)) > 0 then Begin
        cereales.Grabar(id.Text, descrip.Text);
        Close;
      end;
end;

procedure TfmTablaCereales.AltaClick(Sender: TObject);
begin
  id.Text  := utiles.sLlenarIzquierda(cereales.Nuevo, 3, '0');
  ActiveControl := id;
end;

procedure TfmTablaCereales.BajaClick(Sender: TObject);
begin
  if cereales.Buscar(id.Text) then
    //if cereales.VerificarSiElItemsTieneMovimientos(id.Text) then utiles.msgError('El Items tiene Operaciones Registradas, Eliminación Rechazada ...!') else
     if utiles.BajaRegistro('Seguro para Borrar Cereal ' + cereales.tabla.FieldByName('descrip').AsString + ' ?') then Begin
       cereales.Borrar(id.Text);
       id.Text := cereales.Id;
       CargarDatos;
    end;
end;

procedure TfmTablaCereales.ModificarClick(Sender: TObject);
begin
  id.SetFocus;
end;

procedure TfmTablaCereales.DeshacerClick(Sender: TObject);
begin
  ActiveControl := id;
end;

procedure TfmTablaCereales.SalirClick(Sender: TObject);
begin
  Close;
end;

procedure TfmTablaCereales.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  cereales.BuscarPorDescrip(descrip.text);
  DBNavigator.DataSource := nil;
  configform.Guardar(fmTablacereales, redim);
  Release; fmTablacereales := nil;
end;

procedure TfmTablaCereales.FormShow(Sender: TObject);
begin
  Left:=(Screen.Width - Width) div 2;
  configform.Setear(fmTablacereales);
  DTS.DataSet := cereales.tabla;
  if Length(Trim(id.Text)) > 0 then Begin
    CargarDatos;
    descrip.SetFocus;
  end;
  redim := False;
end;

procedure TfmTablaCereales.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then Close;
end;

procedure TfmTablaCereales.Panel2Resize(Sender: TObject);
begin
  redim := True;
end;

end.
