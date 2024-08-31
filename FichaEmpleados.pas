unit FichaEmpleados;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, ExtCtrls, Buttons, DB, DBTables, Mask, DBCtrls,
  ComCtrls, ToolWin, Editv;

type
  TfmEmpleados = class(TForm)
    Panel2: TPanel;
    ScrollBox: TScrollBox;
    Label1: TLabel;
    Label2: TLabel;
    nrolegajo: TMaskEdit;
    StatusBar1: TStatusBar;
    ToolBar1: TToolBar;
    Alta: TToolButton;
    Baja: TToolButton;
    Modificar: TToolButton;
    Buscar: TToolButton;
    Deshacer: TToolButton;
    Salir: TToolButton;
    DBNavigator: TDBNavigator;
    nombre: TMaskEdit;
    DTS: TDataSource;
    Label3: TLabel;
    domicilio: TMaskEdit;

    procedure nrolegajoKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure nombreKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure AltaClick(Sender: TObject);
    procedure BajaClick(Sender: TObject);
    procedure ModificarClick(Sender: TObject);
    procedure DeshacerClick(Sender: TObject);
    procedure SalirClick(Sender: TObject);
    procedure DBNavigatorClick(Sender: TObject; Button: TNavigateBtn);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure Panel2Resize(Sender: TObject);
    procedure domicilioKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
    redim: Boolean;
    procedure CargarDatos;
  public
    { Public declarations }
    NoCerrarFinal: boolean;
  end;

var
  fmEmpleados: TfmEmpleados;

implementation

uses CUtiles, ImgForms, CEmpleados_Gross, CConfigForms;

{$R *.DFM}

procedure TfmEmpleados.CargarDatos;
begin
  empleado.getDatos(nrolegajo.Text);
  nombre.Text    := empleado.nombre;
  domicilio.Text := empleado.domicilio;
end;

procedure TfmEmpleados.nrolegajoKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then Close;
  if Key = VK_INSERT then AltaClick(Sender);
  if (Key = VK_RETURN) or (Key = VK_DOWN) then                               {Edita y Da de Alta Registro ...}
    begin
      utiles.LlenarIzquierda(nrolegajo, 4, '0');
      if empleado.Buscar(nrolegajo.Text) then
        begin
          CargarDatos;
          StatusBar1.Panels[0].Text := '';
          ActiveControl := nombre;
        end
      else
        if utiles.DarDeAlta('Número de Legajo ' + nombre.Text) then
          begin
            CargarDatos;
            StatusBar1.Panels[0].Text := '';
            ActiveControl := nombre;
          end;
    end;
end;

procedure TfmEmpleados.nombreKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_UP then ActiveControl := nrolegajo;
  if (Key = VK_RETURN) or (Key = VK_DOWN) then
    if Length(Trim(nombre.Text)) > 0 then domicilio.SetFocus;
end;

procedure TfmEmpleados.AltaClick(Sender: TObject);
begin
  nrolegajo.Text := empleado.Nuevo;
  ActiveControl := nombre;
end;

procedure TfmEmpleados.BajaClick(Sender: TObject);
begin
  if utiles.BajaRegistro(' Seguro para Eliminar Legajo ' + nrolegajo.Text + ' ?') then Begin
    empleado.Borrar(nrolegajo.Text);
    nrolegajo.Text := empleado.codigo;
    CargarDatos;
  end;
  ActiveControl := nombre;
end;

procedure TfmEmpleados.ModificarClick(Sender: TObject);
begin
  if empleado.Buscar(nrolegajo.Text) then empleado.Grabar(nrolegajo.Text, nombre.Text, domicilio.Text, '0000', '000');
  ActiveControl := nrolegajo;
end;

procedure TfmEmpleados.DeshacerClick(Sender: TObject);
begin
  ActiveControl := nrolegajo;
end;

procedure TfmEmpleados.SalirClick(Sender: TObject);
begin
  Close;
end;

procedure TfmEmpleados.DBNavigatorClick(Sender: TObject;
  Button: TNavigateBtn);
begin
  nrolegajo.Text := empleado.tperso.FieldByName('nrolegajo').AsString;
  CargarDatos;
end;

procedure TfmEmpleados.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  configform.Guardar(fmEmpleados, redim);
  if Not NoCerrarFinal then Begin
    empleado.desconectar;
    Release; fmEmpleados := nil;
  end;
end;

procedure TfmEmpleados.FormShow(Sender: TObject);
begin
  if Not NoCerrarFinal then empleado.conectar;
  DTS.DataSet := empleado.tperso;
  if Length(Trim(nrolegajo.Text)) > 0 then Begin
    CargarDatos;
    ActiveControl := nombre;
  end;
  configform.Setear(fmEmpleados);
  redim := False;
end;

procedure TfmEmpleados.Panel2Resize(Sender: TObject);
begin
  redim := True;
end;

procedure TfmEmpleados.domicilioKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_UP then ActiveControl := nombre;
  if (Key = VK_RETURN) or (Key = VK_DOWN) then Begin
    empleado.Grabar(nrolegajo.Text, nombre.Text, domicilio.Text, '0000', '000');
    Close;
  end;
end;

end.
