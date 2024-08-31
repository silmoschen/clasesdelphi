unit TablaManzanas;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, ExtCtrls, Buttons, DB, DBTables, Mask, DBCtrls,
  ComCtrls, ToolWin, Editv;

type
  TfmManzanas = class(TForm)
    Panel2: TPanel;
    ScrollBox: TScrollBox;
    Label1: TLabel;
    Label2: TLabel;
    idgasto: TMaskEdit;
    StatusBar1: TStatusBar;
    ToolBar1: TToolBar;
    Alta: TToolButton;
    Baja: TToolButton;
    Modificar: TToolButton;
    Buscar: TToolButton;
    Deshacer: TToolButton;
    Salir: TToolButton;
    DBNavigator: TDBNavigator;
    descrip: TMaskEdit;
    DTS: TDataSource;

    procedure idgastoKeyDown(Sender: TObject; var Key: Word;
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
  private
    { Private declarations }
    procedure CargarDatos;
  public
    { Public declarations }
  end;

var
  fmManzanas: TfmManzanas;

implementation

uses CLotes_CCSRural, CUtiles, ImgForms, CConfigForms;

{$R *.DFM}

procedure TfmManzanas.CargarDatos;
begin
  lote.getDatosManzana(idgasto.Text);
  descrip.Text := lote.Descrip;
end;

procedure TfmManzanas.idgastoKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then Close;
  if Key = VK_INSERT then AltaClick(Sender);
  if (Key = VK_RETURN) or (Key = VK_DOWN) then Begin
    if lote.BuscarManzana(idgasto.Text) then Begin
      CargarDatos;
      descrip.SetFocus;
    end else
      if utiles.DarDeAlta('Id. Manzana ' + idgasto.Text) then Begin
        CargarDatos;
        descrip.setFocus;
      end;
    end;
end;

procedure TfmManzanas.descripKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_UP then idgasto.SetFocus;
  if (Key = VK_RETURN) or (Key = VK_DOWN) then
    if Length(Trim(descrip.Text)) > 0 then
      if Length(Trim(idgasto.Text)) > 0 then Begin
        lote.GrabarManzana(idgasto.Text, descrip.Text);
        Close;
      end;
end;

procedure TfmManzanas.AltaClick(Sender: TObject);
begin
  ActiveControl := idgasto;
end;

procedure TfmManzanas.BajaClick(Sender: TObject);
begin
  if lote.BuscarManzana(idgasto.Text) then
   if utiles.BajaRegistro('Seguro para Borrar Gasto ' + idgasto.Text + ' ?') then Begin
      lote.BorrarManzana(idgasto.Text);
      idgasto.Text := lote.Id;
      CargarDatos;
    end;
end;

procedure TfmManzanas.ModificarClick(Sender: TObject);
begin
  idgasto.SetFocus;
end;

procedure TfmManzanas.DeshacerClick(Sender: TObject);
begin
  ActiveControl := idgasto;
end;

procedure TfmManzanas.SalirClick(Sender: TObject);
begin
  Close;
end;

procedure TfmManzanas.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  lote.BuscarPorDescrip(descrip.text);
  DBNavigator.DataSource := nil;
  configform.Guardar(fmManzanas);
  Release; fmManzanas := nil;
end;

procedure TfmManzanas.FormShow(Sender: TObject);
begin
  Left:=(Screen.Width - Width) div 2;
  configform.Setear(fmManzanas);
  DTS.DataSet := lote.tabla;
  if Length(Trim(idgasto.Text)) > 0 then Begin
    CargarDatos;
    descrip.SetFocus;
  end;
end;

end.
