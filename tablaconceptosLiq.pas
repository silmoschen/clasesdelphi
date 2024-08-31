unit tablaconceptosLiq;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, ExtCtrls, Buttons, DB, DBTables, Mask, DBCtrls,
  ComCtrls, ToolWin, Editv;

type
  TfmTablaLiqSueldos = class(TForm)
    Panel2: TPanel;
    ScrollBox: TScrollBox;
    Label1: TLabel;
    Label2: TLabel;
    codigo: TMaskEdit;
    StatusBar1: TStatusBar;
    concepto: TMaskEdit;
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
    tipomov: TMaskEdit;
    Label4: TLabel;
    Label5: TLabel;
    porcentaje: TEditValid;
    Label7: TLabel;
    Label8: TLabel;
    aplicable: TComboBox;
    Label6: TLabel;
    formula: TMaskEdit;
    Label9: TLabel;
    montofijo: TEditValid;
    Label10: TLabel;
    Label11: TLabel;
    tipocarga: TMaskEdit;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    perdesde: TMaskEdit;
    Label15: TLabel;
    Label16: TLabel;
    perhasta: TMaskEdit;
    Label17: TLabel;
    Label18: TLabel;
    nroliq: TMaskEdit;

    procedure codigoKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure conceptoKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure BajaClick(Sender: TObject);
    procedure ModificarClick(Sender: TObject);
    procedure SalirClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure DBNavigatorBeforeAction(Sender: TObject;
      Button: TNavigateBtn);
    procedure FormShow(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure AltaClick(Sender: TObject);
    procedure tipomovKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure porcentajeKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure Panel2Resize(Sender: TObject);
    procedure aplicableKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure tipocargaKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure formulaKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure montofijoKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure perhastaKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure perdesdeKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure nroliqKeyDown(Sender: TObject; var Key: Word;
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
  fmTablaLiqSueldos: TfmTablaLiqSueldos;

implementation

uses CConceptoSueldo, CUtiles, ImgForms, CConfigForms;

{$R *.DFM}

procedure TfmTablaLiqSueldos.CargarDatos;
begin
  conceptoliq.getDatos(codigo.Text);
  concepto.Text       := conceptoliq.Concepto;
  tipomov.Text        := conceptoliq.Tipomov;
  aplicable.ItemIndex := conceptoliq.Aplicable;
  porcentaje.Text     := utiles.FormatearNumero(floattostr(conceptoliq.Porcentaje));
  formula.Text        := conceptoliq.Formula;
  tipocarga.Text      := conceptoliq.Tipocarga;
  montofijo.Text      := utiles.FormatearNumero(floattostr(conceptoliq.MontoFijo));
  perdesde.Text       := conceptoliq.Perdesde;
  perhasta.Text       := conceptoliq.Perhasta;
  nroliq.Text         := conceptoliq.Nroliq;
end;

procedure TfmTablaLiqSueldos.codigoKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then Close;
  if (Key = VK_RETURN) or (Key = VK_DOWN) then Begin
    if conceptoliq.Buscar(codigo.Text) then Begin
      CargarDatos;
      ActiveControl := concepto;
    end else
      if utiles.DarDeAlta('Seguro para Dara de Alta Concepto ' + codigo.Text) then Begin
        CargarDatos;
        ActiveControl := concepto;
      end;
    end;
end;

procedure TfmTablaLiqSueldos.conceptoKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_UP then ActiveControl := codigo;
  if (Key = VK_RETURN) or (Key = VK_DOWN) then
    if Length(Trim(concepto.Text)) > 0 then aplicable.SetFocus;
end;

procedure TfmTablaLiqSueldos.BajaClick(Sender: TObject);
begin
  if conceptoliq.Buscar(codigo.Text) then Begin
    conceptoliq.getDatos(codigo.Text);
    if utiles.BajaRegistro(' Seguro que desea Eliminar Código ' + codigo.Text) then Begin
      conceptoliq.Borrar(codigo.Text);
      codigo.Text := conceptoliq.codigo;
      CargarDatos;
    end;
  end;
  ActiveControl := concepto;
end;

procedure TfmTablaLiqSueldos.ModificarClick(Sender: TObject);
begin
  ActiveControl := concepto;
end;

procedure TfmTablaLiqSueldos.SalirClick(Sender: TObject);
begin
  Close;
end;

procedure TfmTablaLiqSueldos.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  configform.Guardar(fmTablaLiqSueldos, redim);
  DBNavigator.DataSource := nil;
  conceptoliq.BuscarPorCodigo(codigo.Text);
  Release; fmTablaLiqSueldos := nil;
end;

procedure TfmTablaLiqSueldos.DBNavigatorBeforeAction(Sender: TObject;
  Button: TNavigateBtn);
begin
  codigo.Text := conceptoliq.tabla.FieldByName('CODIGO').AsString;
  CargarDatos;
end;

procedure TfmTablaLiqSueldos.FormShow(Sender: TObject);
begin
  configform.Setear(fmTablaLiqSueldos);
  DTS.DataSet := conceptoliq.tabla;
  CargarDatos;
  if Length(Trim(concepto.Text)) > 0 then ActiveControl := concepto else ActiveControl := concepto;
  redim := False;
end;

procedure TfmTablaLiqSueldos.FormResize(Sender: TObject);
begin
  redim := True;
end;

procedure TfmTablaLiqSueldos.AltaClick(Sender: TObject);
begin
  codigo.Text := utiles.sLlenarIzquierda(conceptoliq.Nuevo, 3, '0');
  if fmTablaLiqSueldos.Active then concepto.Text;
end;

procedure TfmTablaLiqSueldos.tipomovKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_UP then aplicable.SetFocus;
  if (Key = VK_RETURN) or (Key = VK_DOWN) then
    if utiles.Sionoct(tipomov.Text, 'RTE', 'Las Opciones son: R - Concepto Sujeto a Retención / T - Descuentos / E - Remuneraciones Exentas ...!') then porcentaje.setFocus;
end;

procedure TfmTablaLiqSueldos.porcentajeKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if Key = VK_UP then concepto.SetFocus;
  if (Key = VK_RETURN) or (Key = VK_DOWN) then Begin
    porcentaje.Text := utiles.FormatearNumero(porcentaje.Text);
    formula.setFocus;
  end;
end;

procedure TfmTablaLiqSueldos.Panel2Resize(Sender: TObject);
begin
  redim := True;
end;

procedure TfmTablaLiqSueldos.aplicableKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if Key = VK_RETURN then
    if Length(Trim(concepto.Text)) > 0 then tipomov.SetFocus;
end;

procedure TfmTablaLiqSueldos.tipocargaKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if Key = VK_UP then concepto.SetFocus;
  if (Key = VK_RETURN) or (Key = VK_DOWN) then
    if utiles.Sionoct(tipocarga.Text, 'MCN', 'Las Opciones son C - Cantidad / M - Ingreso Manual / N - Ninguna ...!') then perdesde.SetFocus;
end;

procedure TfmTablaLiqSueldos.formulaKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_UP then porcentaje.SetFocus;
  if (Key = VK_RETURN) or (Key = VK_DOWN) then montofijo.setFocus;
end;

procedure TfmTablaLiqSueldos.montofijoKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_UP then formula.SetFocus;
  if (Key = VK_RETURN) or (Key = VK_DOWN) then Begin
    montofijo.Text := utiles.FormatearNumero(montofijo.Text);
    tipocarga.setFocus;
  end;
end;

procedure TfmTablaLiqSueldos.perhastaKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if Key = VK_UP then tipocarga.setFocus;
  if (Key = VK_RETURN) or (Key = VK_DOWN) then Begin
    if Length(Trim(perhasta.Text)) < 7 then nroliq.SetFocus else
      if utiles.verificarPeriodo(perhasta.Text) then nroliq.setFocus;
  end;
end;

procedure TfmTablaLiqSueldos.perdesdeKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if Key = VK_UP then tipocarga.setFocus;
  if (Key = VK_RETURN) or (Key = VK_DOWN) then
    if Length(Trim(perdesde.Text)) < 7 then Begin
      perdesde.Text := '';
      perhasta.SetFocus;
    end else
      if utiles.verificarPeriodo(perdesde.Text) then perhasta.SetFocus;
end;

procedure TfmTablaLiqSueldos.nroliqKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  l, k: Boolean;
begin
  if Key = VK_UP then perhasta.setFocus;
  if (Key = VK_RETURN) or (Key = VK_DOWN) then Begin
    nroliq.Text := utiles.sLlenarIzquierda(nroliq.Text, 2, '0');
    if Length(Trim(perhasta.Text)) < 7 then Begin
      perhasta.Text := '';
      l := True;
    end else
      if utiles.verificarPeriodo(perhasta.Text) then l := True;

    if l then Begin
      k := False;
      if Length(Trim(perdesde.Text)) < 7 then k := true else
        if utiles.verificarPeriodo(perdesde.Text) then k := True;
      if Length(Trim(perhasta.Text)) < 7 then k := true else
        if utiles.verificarPeriodo(perhasta.Text) then k := True;


      if (Length(Trim(codigo.Text)) > 0) and (Length(Trim(concepto.Text)) > 0) and (utiles.Sionoct(tipomov.Text, 'RTE', '')) and
      (Length(Trim(montofijo.Text)) > 0) and (utiles.Sionoct(tipocarga.Text, 'MCN', '')) and (k) then Begin
        conceptoLiq.Grabar(codigo.Text, concepto.Text, tipomov.Text, formula.Text, tipocarga.Text, perdesde.Text, perhasta.Text, nroliq.Text, StrToFloat(porcentaje.Text), StrToFloat(montofijo.Text), aplicable.ItemIndex);
        Close;
      end else
        utiles.msgError('Controle, hay Datos Incompletos ...!');
    end;
  end;
end;

end.
