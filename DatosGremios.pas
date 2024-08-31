unit DatosGremios;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, ExtCtrls, Buttons, DB, DBTables, Mask, DBCtrls,
  ComCtrls, ToolWin, Editv, Grids;

type
  TfmDatosGremio = class(TForm)
    StatusBar1: TStatusBar;
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
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    Panel2: TPanel;
    ScrollBox: TScrollBox;
    Label1: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    codigo: TMaskEdit;
    nombre: TMaskEdit;
    Panel3: TPanel;
    Label2: TLabel;
    Label5: TLabel;
    nombrec: TMaskEdit;
    Panel4: TPanel;
    Panel5: TPanel;
    Label6: TLabel;
    periodo: TMaskEdit;
    Label7: TLabel;
    porquincena1: TEditValid;
    Label8: TLabel;
    mfquincena1: TEditValid;
    Label9: TLabel;
    porquincena2: TEditValid;
    Label10: TLabel;
    mfquincena2: TEditValid;
    P: TStringGrid;
    nombrecap: TLabel;

    procedure codigoKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure BajaClick(Sender: TObject);
    procedure ModificarClick(Sender: TObject);
    procedure SalirClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure DBNavigatorBeforeAction(Sender: TObject;
      Button: TNavigateBtn);
    procedure FormShow(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure nombreKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure AltaClick(Sender: TObject);
    procedure nombrecKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure TabSheet2Show(Sender: TObject);
    procedure periodoKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure porquincena1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure mfquincena1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure porquincena2KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure mfquincena2KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure PDblClick(Sender: TObject);
    procedure PKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure TabSheet1Hide(Sender: TObject);
  private
    { Private declarations }
    redim: Boolean;
    procedure CargarDatos;
    procedure CargarMontos;
  public
    { Public declarations }
    NoCerrarFinal: boolean;
  end;

var
  fmDatosGremio: TfmDatosGremio;

implementation

uses CGremioSueldos, CUtiles, ImgForms, CConfigForms, CUtilidadesStringGrid;

{$R *.DFM}

procedure TfmDatosGremio.CargarDatos;
begin
  gremio.getDatos(codigo.Text);
  nombre.Text  := gremio.Gremio;
  nombrec.Text := gremio.Nombrec;
end;

procedure TfmDatosGremio.CargarMontos;
var
  l: TStringList;
  i, j, p1, p2, p3: Integer;
Begin
  Refresh;
  grid.IniciarGrilla(P);
  j := 0;
  l := gremio.setRetenciones(codigo.Text);
  For i := l.Count downto 1 do Begin
    Inc(j);
    p1 := Pos(';1', l.Strings[i-1]);
    p2 := Pos(';2', l.Strings[i-1]);
    p3 := Pos(';3', l.Strings[i-1]);
    P.Cells[0, j] := Copy(l.Strings[i-1], 1, 7);
    P.Cells[1, j] := Copy(l.Strings[i-1], 11, p1-11);
    P.Cells[2, j] := Copy(l.Strings[i-1], p1+2, p2-(p1 + 2));
    P.Cells[3, j] := Copy(l.Strings[i-1], p2+2, p3-(p2 + 2));
    P.Cells[4, j] := Copy(l.Strings[i-1], p3+2, 15);
  end;
end;

procedure TfmDatosGremio.codigoKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then Close;
  if (Key = VK_RETURN) or (Key = VK_DOWN) then Begin
    if gremio.Buscar(codigo.Text) then Begin
      CargarDatos;
      ActiveControl := nombre;
    end else
      if utiles.DarDeAlta('Seguro para Dara de Alta Gremio ' + codigo.Text + ' ?') then Begin
        CargarDatos;
        ActiveControl := nombre;
      end;
    end;
end;

procedure TfmDatosGremio.BajaClick(Sender: TObject);
begin
  if gremio.Buscar(codigo.Text) then Begin
    gremio.getDatos(codigo.Text);
    if utiles.BajaRegistro(' Seguro que desea Eliminar Gremio ' + codigo.Text + ' ?') then Begin
      gremio.Borrar(codigo.Text);
      codigo.Text := gremio.tabla.FieldByName('codigo').AsString;
      CargarDatos;
    end;
  end;
  ActiveControl := nombre;
end;

procedure TfmDatosGremio.ModificarClick(Sender: TObject);
begin
  ActiveControl := nombre;
end;

procedure TfmDatosGremio.SalirClick(Sender: TObject);
begin
  Close;
end;

procedure TfmDatosGremio.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  configform.Guardar(fmDatosGremio, redim);
  DBNavigator.DataSource := nil;
  gremio.BuscarPorDescrip(nombre.Text);
  Release; fmDatosGremio := nil;
end;

procedure TfmDatosGremio.DBNavigatorBeforeAction(Sender: TObject;
  Button: TNavigateBtn);
begin
  codigo.Text := gremio.tabla.FieldByName('codigo').AsString;
  CargarDatos;
end;

procedure TfmDatosGremio.FormShow(Sender: TObject);
begin
  configform.Setear(fmDatosGremio);
  DTS.DataSet := gremio.tabla;
  CargarDatos;
  P.Cells[0, 0] := 'Período'; P.Cells[1, 0] := '% Quin. 1'; P.Cells[2, 0] := 'M.F.Quin. 1'; P.Cells[3, 0] := '% Quin. 2'; P.Cells[4, 0] := 'M.F.Quin. 2';
  ActiveControl := nombre;
  redim := False;
end;

procedure TfmDatosGremio.FormResize(Sender: TObject);
begin
  redim := True;
end;

procedure TfmDatosGremio.nombreKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_UP then ActiveControl := codigo;
  if (Key = VK_RETURN) or (Key = VK_DOWN) then
    if Length(Trim(nombre.Text)) > 0 then nombrec.setFocus;
end;

procedure TfmDatosGremio.AltaClick(Sender: TObject);
begin
  codigo.Text := utiles.sLlenarIzquierda(gremio.Nuevo, 3, '0');
  if fmDatosGremio.Active then nombre.SetFocus;
end;

procedure TfmDatosGremio.nombrecKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_UP then ActiveControl := nombre;
  if (Key = VK_RETURN) or (Key = VK_DOWN) then
    if Length(Trim(nombre.Text)) > 0 then Begin
      if (Length(Trim(codigo.Text)) = 3) and (Length(Trim(nombre.Text)) > 0) and (Length(Trim(nombrec.Text)) >= 0) then Begin
        gremio.Grabar(codigo.Text, nombre.Text, nombrec.Text);
        Close;
      end else
        utiles.msgError('Faltan Datos o los Mismos son Incorrectos ...!');
    end;
end;

procedure TfmDatosGremio.TabSheet2Show(Sender: TObject);
begin
  nombrecap.Caption := nombre.Text;
  CargarMontos;
end;

procedure TfmDatosGremio.periodoKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then Close;
  if (Key = VK_RETURN) or (Key = VK_DOWN) then
    if utiles.verificarPeriodo(periodo.Text) then porquincena1.SetFocus;
end;

procedure TfmDatosGremio.porquincena1KeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if Key = VK_UP then periodo.SetFocus;
  if (Key = VK_RETURN) or (Key = VK_DOWN) then
    if Length(Trim(porquincena1.Text)) >= 0 then Begin
      porquincena1.Text := utiles.FormatearNumero(porquincena1.Text);
      mfquincena1.SetFocus;
    end;
end;

procedure TfmDatosGremio.mfquincena1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_UP then porquincena1.SetFocus;
  if (Key = VK_RETURN) or (Key = VK_DOWN) then
    if Length(Trim(mfquincena1.Text)) >= 0 then Begin
      mfquincena1.Text := utiles.FormatearNumero(mfquincena1.Text);
      porquincena2.SetFocus;
    end;
end;

procedure TfmDatosGremio.porquincena2KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_UP then mfquincena1.SetFocus;
  if (Key = VK_RETURN) or (Key = VK_DOWN) then
    if Length(Trim(porquincena2.Text)) >= 0 then Begin
      porquincena2.Text := utiles.FormatearNumero(porquincena2.Text);
      mfquincena2.SetFocus;
    end;
end;

procedure TfmDatosGremio.mfquincena2KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_UP then porquincena2.SetFocus;
  if (Key = VK_RETURN) or (Key = VK_DOWN) then
    if Length(Trim(mfquincena2.Text)) >= 0 then Begin
      mfquincena2.Text := utiles.FormatearNumero(mfquincena2.Text);

      if (utiles.verificarPeriodo(periodo.Text)) then Begin
        porquincena1.Text := utiles.FormatearNumero(porquincena1.Text);
        porquincena2.Text := utiles.FormatearNumero(porquincena2.Text);
        mfquincena1.Text  := utiles.FormatearNumero(mfquincena1.Text);
        mfquincena2.Text  := utiles.FormatearNumero(mfquincena2.Text);
        gremio.GuardarRetencion(codigo.Text, periodo.Text, StrToFloat(porquincena1.Text), StrToFloat(mfquincena1.Text), StrToFloat(porquincena2.Text), StrToFloat(mfquincena2.Text));
        CargarMontos;
        gremio.BuscarPorDescrip(nombre.Text);
        periodo.Text := ''; porquincena1.Text := ''; mfquincena1.Text := ''; porquincena2.Text := ''; mfquincena2.Text := '';
      end else
        utiles.msgError('Controle, Faltan Datos ...!');

      periodo.SetFocus;
    end;
end;

procedure TfmDatosGremio.PDblClick(Sender: TObject);
begin
  if Length(Trim(P.Cells[0, P.Row])) > 0 then Begin
    periodo.Text := P.Cells[0, P.Row];
    porquincena1.Text := P.Cells[1, P.Row];
    mfquincena1.Text  := P.Cells[2, P.Row];
    porquincena2.Text := P.Cells[3, P.Row];
    mfquincena2.Text  := P.Cells[4, P.Row];
    periodo.SetFocus;
  end else
    utiles.msgError('El Registro Seleccionado es Incorrecto ...!');
end;

procedure TfmDatosGremio.PKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_DELETE then Begin
    if Length(Trim(P.Cells[0, P.Row])) > 0 then
      if utiles.msgSiNo('Seguro para Eliminar Período ' + P.Cells[0, P.Row] + ' ?') then Begin
        gremio.BorrarRetencion(codigo.Text, P.Cells[0, P.Row]);
        CargarMontos;
        gremio.BuscarPorDescrip(nombre.Text);
      end;
    periodo.setFocus;
  end;
end;

procedure TfmDatosGremio.TabSheet1Hide(Sender: TObject);
begin
  if (Length(Trim(codigo.Text)) = 3) and (Length(Trim(nombre.Text)) > 0) and (Length(Trim(nombrec.Text)) >= 0) then
    gremio.Grabar(codigo.Text, nombre.Text, nombrec.Text);
end;

end.
