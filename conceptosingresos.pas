unit conceptosingresos;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, ExtCtrls, Buttons, DB, DBTables, Mask, DBCtrls,
  ComCtrls, ToolWin, Grids, DBGrids, Editv;

type
  TfmConceptoIngresos = class(TForm)
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
    Label6: TLabel;
    monto: TEditValid;

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
    procedure montoKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
    procedure CargarDatos;
  public
    { Public declarations }
    introSalir: boolean;
  end;

var
  fmConceptoIngresos: TfmConceptoIngresos;

implementation

uses CUtiles, ImgForms, CConceptosCobrosCIC;

{$R *.DFM}

procedure TfmConceptoIngresos.CargarDatos;
begin
  conceptoing.getDatos(codigo.Text);
  descrip.Text := conceptoing.descrip; // Edito
  monto.Text   := utiles.FormatearNumero(FloatToStr(conceptoing.Monto));
end;

procedure TfmConceptoIngresos.codigoKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then Close;
  if Key = VK_INSERT then AltaClick(Sender);
  if (Shift = [ssCtrl]) and (Key = Word('B')) then BajaClick(Sender);
  if (Key = VK_RETURN) or (Key = VK_DOWN) then                               {Edita y Da de Alta Registro ...}
    begin
      utiles.LlenarIzquierda(codigo, 4, '0');
      if conceptoing.Buscar(codigo.Text) then
        begin
          CargarDatos;
          StatusBar1.Panels[0].Text := '';
          ActiveControl := descrip;
        end
      else
        if utiles.DarDeAlta('Cód. Movimiento ' + codigo.Text) then
          begin
            CargarDatos;
            StatusBar1.Panels[0].Text := '';
            ActiveControl := descrip;
          end;
    end;
end;

procedure TfmConceptoIngresos.FormCreate(Sender: TObject);
begin
  Left := StrToInt(FormatFloat('####', (Screen.DesktopWidth / 2) - (Width / 2)));
  if not introSalir then conceptoing.conectar;
  DTS.DataSet := conceptoing.tabla;
end;

procedure TfmConceptoIngresos.descripKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_UP then ActiveControl := codigo;
  if (Key = VK_RETURN) or (Key = VK_DOWN) then
    if Length(Trim(descrip.Text)) > 0 then monto.SetFocus;
end;

procedure TfmConceptoIngresos.AltaClick(Sender: TObject);
begin
  codigo.Text := utiles.sLlenarIzquierda(conceptoing.Nuevo, 3, '0');
  ActiveControl := codigo;
end;

procedure TfmConceptoIngresos.BajaClick(Sender: TObject);
begin
  if utiles.BajaRegistro('Seguro que desea Código ' + codigo.Text + ' ?') then Begin
    conceptoing.Borrar(codigo.Text);
    codigo.Text := conceptoing.items;
    CargarDatos;
  end;
  ActiveControl := codigo;
end;

procedure TfmConceptoIngresos.ModificarClick(Sender: TObject);
begin
  ActiveControl := codigo;
end;

procedure TfmConceptoIngresos.DeshacerClick(Sender: TObject);
begin
  ActiveControl := codigo;
end;

procedure TfmConceptoIngresos.SalirClick(Sender: TObject);
begin
  Close;
end;

procedure TfmConceptoIngresos.DBNavigatorClick(Sender: TObject;
  Button: TNavigateBtn);
begin
  codigo.Text := conceptoing.tabla.FieldByName('idconcepto').AsString;
  CargarDatos;
end;

procedure TfmConceptoIngresos.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  DTS.DataSet := nil;
  conceptoing.BuscarPorNombre(descrip.Text);
end;

procedure TfmConceptoIngresos.FormActivate(Sender: TObject);
begin
  if Length(Trim(codigo.Text)) > 0 then Begin
    CargarDatos;
    ActiveControl := descrip;
  end;
end;

procedure TfmConceptoIngresos.montoKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_UP then ActiveControl := descrip;
  if (Key = VK_RETURN) or (Key = VK_DOWN) then Begin
    monto.Text := utiles.FormatearNumero(monto.Text); 
    if (Length(Trim(codigo.Text)) = 3) and (Length(Trim(descrip.Text)) > 0) and (StrToFloat(monto.Text) > 0) then Begin
      conceptoing.Grabar(codigo.Text, descrip.Text, StrToFloat(monto.Text));
      Close;
    end else
      utiles.msgError('Los Datos Ingresados son Incorrectos o están Incompletos ...!');
  end;

end;

end.
