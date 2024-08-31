unit Afectados;

interface

uses
  SysUtils, Windows, Messages, Classes, Graphics, Controls,
  StdCtrls, Forms, DBCtrls, DB, ComCtrls, Mask, ExtCtrls, ToolWin, Buttons,
  Editv;

type
  TfmAfectado = class(TForm)
    StatusBar1: TStatusBar;
    DTS: TDataSource;
    Panel2: TPanel;
    ScrollBox: TScrollBox;
    Label1: TLabel;
    Label4: TLabel;
    iva: TLabel;
    Label15: TLabel;
    Label17: TLabel;
    nrodoc: TMaskEdit;
    nombre: TMaskEdit;
    domicilio: TMaskEdit;
    telefono: TMaskEdit;
    Panel1: TPanel;
    ToolBar1: TToolBar;
    DBNavigator: TDBNavigator;
    Alta: TToolButton;
    Baja: TToolButton;
    Modificar: TToolButton;
    Buscar: TToolButton;
    Deshacer: TToolButton;
    Salir: TToolButton;
    cat: TLabel;
    Label2: TLabel;
    domlaboral: TMaskEdit;
    procedure nrodocKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure nombreKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure domicilioKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure BajaC(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure AltaClick(Sender: TObject);
    procedure ModificarClick(Sender: TObject);
    procedure SalirClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure DBNavigatorClick(Sender: TObject; Button: TNavigateBtn);
    procedure telefonoKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure nombreChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure domlaboralKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { private declarations }
    modif: boolean;
    procedure CargarDatos;
    procedure Guardar;
  public
    { public declarations }
    NoCerrarFinal: boolean;
  end;

var
  fmAfectado: TfmAfectado;

implementation

uses CAfectadosCIC, CUtiles;

{$R *.DFM}

procedure TfmAfectado.CargarDatos;
begin
  afectado.getDatos(nrodoc.Text);
  nombre.Text       := afectado.nombre;
  domicilio.Text    := afectado.domicilio;
  domlaboral.Text   := afectado.Domlaboral;
  telefono.Text     := afectado.Telefono;
end;

procedure TfmAfectado.Guardar;
// Objetivo...: Guardar datos de socios
begin
  if (Length(Trim(nombre.Text)) > 0) and (Length(Trim(nrodoc.Text)) > 0) and (Length(Trim(domicilio.Text)) > 0) and (Length(Trim(domlaboral.Text)) > 0) and (Length(Trim(telefono.Text)) > 0) then Begin
    afectado.Grabar(nrodoc.Text, nombre.Text, domicilio.Text, '', '', domlaboral.Text, telefono.Text);
    modif := False;
    Close;
  end else
    utiles.msgError('Controle, hay Datos Incorrectos o Incompletos ...!');
end;

procedure TfmAfectado.BajaC(Sender: TObject);
begin
  if afectado.Buscar(nrodoc.Text) then
    if utiles.BajaRegistro('Seguro para Borrar Afectado ' + nrodoc.Text) then Begin
      afectado.Borrar(nrodoc.Text);
      CargarDatos;
    end;
    ActiveControl := nrodoc;
end;

//FIN PROCEDIMIENTOS PERSONALIZADOS
procedure TfmAfectado.nrodocKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then Close;
  if Key = VK_INSERT then AltaClick(Sender);
   if (Key = VK_RETURN) or (Key = VK_DOWN) then
    begin
      if afectado.Buscar(nrodoc.Text) then
        begin
          CargarDatos;      // Edito
          ActiveControl := nombre;
          StatusBar1.Panels[0].Text := '';
        end
      else
        if utiles.DarDeAlta('Nro. de Documento ' + nrodoc.Text) then
          begin
            CargarDatos;  // Inicio - si no existe
            ActiveControl := nombre;
            StatusBar1.Panels[0].Text := '';
          end;
    end;
end;

procedure TfmAfectado.nombreKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_UP then ActiveControl := nrodoc;
  if (Key = VK_RETURN) or (Key = VK_DOWN) then
    if Length(Trim(nombre.Text)) > 0 then ActiveControl := domicilio;
end;

procedure TfmAfectado.domicilioKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_UP then ActiveControl := nombre;
  if (Key = VK_RETURN) or (Key = VK_DOWN) then
    if Length(Trim(domicilio.Text)) > 0 then ActiveControl := domlaboral;
end;

procedure TfmAfectado.FormCreate(Sender: TObject);
begin
  Left:=(Screen.Width - Width) div 2; Top:=(Screen.Height - Height) div 2;
end;

procedure TfmAfectado.AltaClick(Sender: TObject);
begin
  ActiveControl := nrodoc;
end;

procedure TfmAfectado.ModificarClick(Sender: TObject);
begin
  ActiveControl := nrodoc;
end;

procedure TfmAfectado.SalirClick(Sender: TObject);
begin
  Close;
end;

procedure TfmAfectado.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  if modif then
    if utiles.msgSiNo('Guardar los Cambios Efectuados ?') then Guardar;
  DBNavigator.DataSource := nil;
  if not NoCerrarFinal then Begin
    afectado.desconectar;
    Release; fmAfectado := nil;
  end;
end;

procedure TfmAfectado.DBNavigatorClick(Sender: TObject;
  Button: TNavigateBtn);
begin
  nrodoc.Text := afectado.tperso.FieldByName('nrodoc').AsString;
  CargarDatos;
end;

procedure TfmAfectado.telefonoKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_UP then ActiveControl := domlaboral;
  if (Key = VK_RETURN) or (Key = VK_DOWN) then
    if Length(Trim(telefono.Text)) > 0 then Begin
      Guardar;
    end;
end;

procedure TfmAfectado.nombreChange(Sender: TObject);
begin
  modif := True;
end;

procedure TfmAfectado.FormShow(Sender: TObject);
begin
  if not NoCerrarFinal then afectado.conectar;
  DTS.DataSet := afectado.tperso;
  ActiveControl := nrodoc;
  if Length(Trim(nrodoc.Text)) > 0 then Begin
    CargarDatos;
    modif         := False;
    ActiveControl := nombre;
  end;
end;

procedure TfmAfectado.domlaboralKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_UP then ActiveControl := domicilio;
  if (Key = VK_RETURN) or (Key = VK_DOWN) then
    if Length(Trim(domlaboral.Text)) > 0 then ActiveControl := telefono;
end;

end.
