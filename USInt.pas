unit USInt;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, ExtCtrls, Buttons, DB, DBTables, Mask, DBCtrls,
  ComCtrls, ToolWin, Grids, DBGrids;

type
  TfmUsuariosInt = class(TForm)
    Panel2: TPanel;
    ScrollBox: TScrollBox;
    Label1: TLabel;
    Label2: TLabel;
    codigo: TMaskEdit;
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
    Label3: TLabel;
    email: TMaskEdit;
    Label4: TLabel;
    idcategoria: TMaskEdit;

    procedure codigoKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
    procedure descripKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure AltaClick(Sender: TObject);
    procedure BajaClick(Sender: TObject);
    procedure ModificarClick(Sender: TObject);
    procedure DeshacerClick(Sender: TObject);
    procedure SalirClick(Sender: TObject);
    procedure DBNavigatorClick(Sender: TObject; Button: TNavigateBtn);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
    procedure CargarDatos;
  public
    { Public declarations }
    introSalir: boolean;
  end;

var
  fmUsuariosInt: TfmUsuariosInt;

implementation

uses CUtiles, ImgForms, CCatUsuariosInt;

{$R *.DFM}

procedure TfmUsuariosInt.CargarDatos;
begin
  catusuariosint.getDatos(codigo.Text);
  descrip.Text  := catusuariosint.categoria; // Edito
end;

procedure TfmUsuariosInt.codigoKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then Close;
  if Key = VK_INSERT then AltaClick(Sender);
  if (Shift = [ssCtrl]) and (Key = Word('B')) then BajaClick(Sender);
  if (Key = VK_RETURN) or (Key = VK_DOWN) then                               {Edita y Da de Alta Registro ...}
    begin
      utiles.LlenarIzquierda(codigo, 3, '0');
      if catusuariosint.Buscar(codigo.Text) then
        begin
          CargarDatos;
          StatusBar1.Panels[0].Text := '';
          ActiveControl := descrip;
        end
      else
        if utiles.DarDeAlta('Cód. Banco ' + codigo.Text) then
          begin
            CargarDatos;
            StatusBar1.Panels[0].Text := '';
            ActiveControl := descrip;
          end;
    end;
end;

procedure TfmUsuariosInt.FormCreate(Sender: TObject);
begin
  Left := StrToInt(FormatFloat('####', (Screen.DesktopWidth / 2) - (Width / 2)));
  if not introSalir then catusuariosint.conectar;
  DTS.DataSet := catusuariosint.tabla;
end;

procedure TfmUsuariosInt.descripKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_UP then ActiveControl := codigo;
  if (Key = VK_RETURN) or (Key = VK_DOWN) then Begin
    catusuariosint.Grabar(codigo.Text, descrip.Text);
    if introSalir then Close else ActiveControl := codigo;
  end;
end;

procedure TfmUsuariosInt.AltaClick(Sender: TObject);
begin
  codigo.Text := utiles.sLlenarIzquierda(catusuariosint.Nuevo, 3, '0');
  ActiveControl := codigo;
end;

procedure TfmUsuariosInt.BajaClick(Sender: TObject);
begin
  if utiles.BajaRegistro('Seguro que desea Eliminar Código de Banco ' + codigo.Text + ' ?') then Begin
    catusuariosint.Borrar(codigo.Text);
    codigo.Text := catusuariosint.idcategoria;
    CargarDatos;
  end;
  ActiveControl := codigo;
end;

procedure TfmUsuariosInt.ModificarClick(Sender: TObject);
begin
  if catusuariosint.Buscar(codigo.Text) then catusuariosint.Grabar(codigo.Text, descrip.Text);
  ActiveControl := codigo;
end;

procedure TfmUsuariosInt.DeshacerClick(Sender: TObject);
begin
  ActiveControl := codigo;
end;

procedure TfmUsuariosInt.SalirClick(Sender: TObject);
begin
  Close;
end;

procedure TfmUsuariosInt.DBNavigatorClick(Sender: TObject;
  Button: TNavigateBtn);
begin
  codigo.Text := catusuariosint.tabla.FieldByName('codbanco').AsString;
  CargarDatos;
end;

procedure TfmUsuariosInt.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  DTS.DataSet := nil;
  if not introSalir then Begin
    catusuariosint.desconectar;
    Release; fmUsuariosInt := nil;
  end;
  catusuariosint.BuscarPorNombre(descrip.Text); 
end;

procedure TfmUsuariosInt.FormActivate(Sender: TObject);
begin
  if Length(Trim(codigo.Text)) > 0 then Begin
    CargarDatos;
    ActiveControl := descrip;
  end;
end;

end.
