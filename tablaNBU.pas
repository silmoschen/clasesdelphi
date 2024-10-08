unit tablaNBU;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, ExtCtrls, Buttons, DB, DBTables, Mask, DBCtrls,
  ComCtrls, ToolWin, Editv, Grids;

type
  TfmTablaNBU = class(TForm)
    Panel2: TPanel;
    ScrollBox: TScrollBox;
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
    Panel3: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label6: TLabel;
    des: TLabel;
    Label4: TLabel;
    codigo: TMaskEdit;
    descrip: TMaskEdit;
    unidad: TEditValid;
    codanalisis: TMaskEdit;
    BuscarCodigo: TBitBtn;
    Panel4: TPanel;
    S: TStringGrid;

    procedure codigoKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
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
    procedure Panel2Resize(Sender: TObject);
    procedure unidadKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure codanalisisKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure BuscarCodigoClick(Sender: TObject);
    procedure SKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure SDblClick(Sender: TObject);
  private
    { Private declarations }
    redim: Boolean;
    items: Integer;
    procedure CargarDatos;
    procedure CargarDatosAnalisis;
    procedure CargarCodigos;
  public
    { Public declarations }
    NoCerrarFinal: boolean;
  end;

var
  fmTablaNBU: TfmTablaNBU;

implementation

uses CNBU, CUtiles, ImgForms, CConfigForms, CNomeclaCCB, NominaNomeclador,
     CUtilidadesStringGrid;

{$R *.DFM}

procedure TfmTablaNBU.CargarDatos;
begin
  nbu.getDatos(codigo.Text);
  descrip.Text     := nbu.Descrip;
  unidad.Text      := utiles.FormatearNumero(FloatToStr(nbu.unidad));
  codanalisis.Text := nbu.CodNNN;
  if fmTablaNBU.Active then Begin
    CargarDatosAnalisis;
    descrip.SetFocus;
  end;
end;

procedure TfmTablaNBU.CargarDatosAnalisis;
Begin
  nomeclatura.getDatos(codanalisis.Text);
  des.Caption := nomeclatura.descrip;
  codanalisis.SetFocus;
end;

procedure TfmTablaNBU.CargarCodigos;
// Objetivo...: Cargar Códigos
var
  i: Integer;
  l: TStringList;
Begin
  items := 0; S.Row := 1;
  grid.IniciarGrilla(S);
  l := nbu.setCodigosNNN(codigo.Text);
  For i := 1 to l.Count do Begin
    if (length(trim(l.Strings[i-1])) > 0) then begin
      Inc(items);
      nomeclatura.getDatos(l.Strings[i-1]);
      S.Cells[0, items] := l.Strings[i-1];
      S.Cells[1, items] := nomeclatura.descrip;
      S.Row := items;
    end;
  end;
  l.Destroy; l := Nil;
end;

procedure TfmTablaNBU.codigoKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then Close;
  if Key = VK_INSERT then AltaClick(Sender);
  if (Key = VK_RETURN) or (Key = VK_DOWN) then Begin
    if nbu.Buscar(codigo.Text) then Begin
      CargarDatos;
      ActiveControl := descrip;
    end else
      if utiles.DarDeAlta('Seguro para Dar de Alta Código ' + codigo.Text + ' ?') then Begin
        CargarDatos;
        descrip.SetFocus;
      end;
    end;
end;

procedure TfmTablaNBU.descripKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_UP then ActiveControl := codigo;
  if (Key = VK_RETURN) or (Key = VK_DOWN) then
    if (Length(Trim(descrip.Text)) > 0) then unidad.setFocus;
end;

procedure TfmTablaNBU.AltaClick(Sender: TObject);
begin
  codigo.Text := utiles.sLlenarIzquierda(nbu.Nuevo, 4, '0');
end;

procedure TfmTablaNBU.BajaClick(Sender: TObject);
begin
  if nbu.Buscar(codigo.Text) then
   if utiles.BajaRegistro(' Seguro que desea Eliminar Determinación ' + descrip.Text + ' ?') then Begin
     nbu.Borrar(codigo.Text);
     codigo.Text := nbu.Codigo;
     CargarDatos;
   end;
  ActiveControl := codigo;
end;

procedure TfmTablaNBU.ModificarClick(Sender: TObject);
begin
  ActiveControl := codigo;
end;

procedure TfmTablaNBU.SalirClick(Sender: TObject);
begin
  Close;
end;

procedure TfmTablaNBU.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  configform.Guardar(fmTablaNBU, redim);
  DBNavigator.DataSource := nil;
  nbu.BuscarPorDescrip(descrip.Text);
  Release; fmTablaNBU := nil;
end;

procedure TfmTablaNBU.DBNavigatorBeforeAction(Sender: TObject;
  Button: TNavigateBtn);
begin
  codigo.Text := nbu.tabla.FieldByName('codigo').AsString;
  CargarDatos;
end;

procedure TfmTablaNBU.FormShow(Sender: TObject);
begin
  configform.Setear(fmTablaNBU);
  S.Cells[0, 0] := 'Código'; S.Cells[1, 0] := 'Determinación';
  DTS.DataSet := nbu.tabla;
  CargarDatos;
  CargarCodigos;
  ActiveControl := codigo;
  redim := False;
end;

procedure TfmTablaNBU.Panel2Resize(Sender: TObject);
begin
  redim := True;
end;

procedure TfmTablaNBU.unidadKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_UP then ActiveControl := descrip;
  if (Key = VK_RETURN) or (Key = VK_DOWN) then
    if Length(Trim(unidad.Text)) > 0 then Begin
      unidad.Text := utiles.FormatearNumero(unidad.Text);
      codanalisis.SetFocus;
    end;
end;

procedure TfmTablaNBU.codanalisisKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then Close;
  if Key = VK_UP then ActiveControl := unidad;
  if (Key = VK_RETURN) or (Key = VK_DOWN) then Begin
    if Length(Trim(codanalisis.Text)) > 0 then Begin
      if nomeclatura.Buscar(codanalisis.Text) then Begin
        CargarDatosAnalisis;
        nbu.Grabar(codigo.Text, descrip.Text, codanalisis.Text, StrToFloat(unidad.Text), 0);
        CargarCodigos;
        codanalisis.Text := ''; des.Caption := ''; unidad.Text := '';
      end else BuscarCodigoClick(Self);
    end else Begin
      nbu.Grabar(codigo.Text, descrip.Text, codanalisis.Text, StrToFloat(unidad.Text), 0);
      Close;
    End;
  end;
end;

procedure TfmTablaNBU.BuscarCodigoClick(Sender: TObject);
begin
  Application.CreateForm(TfmListNomeclador, fmListNomeclador);
  fmListNomeclador.introSalir := True;
  fmListNomeclador.NoCerrarFinal := True;
  fmListNomeclador.ShowModal;
  if fmListNomeclador.seleccionOK then codanalisis.Text := nomeclatura.tabla.FieldByName('codigo').AsString;
  fmListNomeclador.Release; fmListNomeclador := nil;
  CargarDatosAnalisis;
end;

procedure TfmTablaNBU.SKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_DELETE then
    if Length(Trim(S.Cells[0, S.Row])) > 0 then Begin
      if utiles.msgSiNo('Seguro para Borrar Determinación ' + S.Cells[0, S.Row] + ' ?') then Begin
        nbu.BorrarCodigoNNN(codigo.Text, S.Cells[0, S.Row]);
        codanalisis.SetFocus;
        CargarCodigos;
      end;
    end else
      utiles.msgError('El Registro Seleccionado es Incorrecto ...!');
end;

procedure TfmTablaNBU.SDblClick(Sender: TObject);
begin
  if Length(Trim(S.Cells[0, S.Row])) > 0 then Begin
    codanalisis.Text := S.Cells[0, S.Row];
    des.Caption      := S.Cells[1, S.Row];
    codanalisis.SetFocus;
  end else
    utiles.msgError('El Registro Seleccionado es Incorrecto ...!');
end;

end.
