unit tabladecategorias;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, ExtCtrls, Buttons, DB, DBTables, Mask, DBCtrls,
  ComCtrls, ToolWin, Editv;

type
  TfmTablaIndices = class(TForm)
    Panel2: TPanel;
    ScrollBox: TScrollBox;
    Label1: TLabel;
    Label2: TLabel;
    items: TMaskEdit;
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

    procedure itemsKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
    procedure descripKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure AltaClick(Sender: TObject);
    procedure BajaClick(Sender: TObject);
    procedure ModificarClick(Sender: TObject);
    procedure SalirClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure DBNavigatorBeforeAction(Sender: TObject;
      Button: TNavigateBtn);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    f: boolean;
    procedure CargarDatos;
  public
    { Public declarations }
    NoCerrarFinal: boolean;
  end;

var
  fmTablaIndices: TfmTablaIndices;

implementation

uses CIndices_Asociacion, CUtiles, ImgForms;

{$R *.DFM}

procedure TfmTablaIndices.CargarDatos;
begin
  indice.getDatos(items.Text);
  descrip.Text  := indice.Descrip;
end;

procedure TfmTablaIndices.itemsKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then Close;
  if Key = VK_INSERT then AltaClick(Sender);
  if (Key = VK_RETURN) or (Key = VK_DOWN) then Begin
    if indice.Buscar(items.Text) then Begin
      CargarDatos;
      ActiveControl := descrip;
    end else
      if utiles.DarDeAlta('Seguro para Dara de Alta Items ' + items.Text) then Begin
        CargarDatos;
        ActiveControl := descrip;
      end;
    end;
end;

procedure TfmTablaIndices.FormCreate(Sender: TObject);
begin
  Left:=(Screen.Width - Width) div 2;
end;

procedure TfmTablaIndices.descripKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_UP then ActiveControl := items;
  if (Key = VK_RETURN) or (Key = VK_DOWN) then
    if (Length(Trim(descrip.Text)) > 0) and (Length(Trim(items.Text)) > 0) then Begin
      indice.Grabar(items.Text, descrip.Text);
      Close;
    end;
end;

procedure TfmTablaIndices.AltaClick(Sender: TObject);
begin
  items.Text := utiles.sLlenarIzquierda(indice.Nuevo, 3, '0'); 
end;

procedure TfmTablaIndices.BajaClick(Sender: TObject);
begin
  if indice.Buscar(items.Text) then
   //if pedido.verifSabor(idindice.Text) then utiles.msgError('El Sabor está afectado a Pedidos, Baja Rechazada ...!') else
   if utiles.BajaRegistro(' Seguro que desea Eliminar Categoría ' + items.Text + ' ?') then Begin
     indice.Borrar(items.Text);
     items.Text := indice.Items;
     CargarDatos;
   end;
  ActiveControl := items;
end;

procedure TfmTablaIndices.ModificarClick(Sender: TObject);
begin
  ActiveControl := items;
end;

procedure TfmTablaIndices.SalirClick(Sender: TObject);
begin
  Close;
end;

procedure TfmTablaIndices.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  if f then Begin
    indice.desconectar;
    DBNavigator.DataSource := nil;
    if not NoCerrarFinal then Begin
      Release; fmTablaIndices := nil;
    end;
  end;
end;

procedure TfmTablaIndices.DBNavigatorBeforeAction(Sender: TObject;
  Button: TNavigateBtn);
begin
  items.Text := indice.tabla.FieldByName('items').AsString;
  CargarDatos;
end;

procedure TfmTablaIndices.FormShow(Sender: TObject);
begin
  DTS.DataSet := indice.tabla;
  CargarDatos;
  ActiveControl := descrip;
end;

end.
