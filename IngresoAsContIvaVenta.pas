unit IngresoAsContIvaVenta;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, ExtCtrls, DBCtrls, ToolWin, ImgForms, Grids, StdCtrls, Mask,
  Editv, Buttons, DB, DBTables;

type
  TfmIngresoContIvaV = class(TForm)
    ToolBar1: TToolBar;
    DBNavigator: TDBNavigator;
    Alta: TToolButton;
    Baja: TToolButton;
    Modificar: TToolButton;
    Buscar: TToolButton;
    Deshacer: TToolButton;
    Salir: TToolButton;
    Panel2: TPanel;
    ScrollBox: TScrollBox;
    StatusBar1: TStatusBar;
    GroupBox1: TGroupBox;
    Label4: TLabel;
    hcta: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    D: TStringGrid;
    hcodcta: TMaskEdit;
    himporte: TEditValid;
    hconcepto: TMaskEdit;
    tdebe: TLabel;
    thaber: TLabel;
    nroasien: TMaskEdit;
    Label11: TLabel;
    concepto: TMaskEdit;
    Label12: TLabel;
    aceptar: TBitBtn;
    cerrar: TBitBtn;
    viacont: TLabel;
    Label5: TLabel;
    total: TLabel;
    selmov1: TBitBtn;
    fecha: TMaskEdit;
    DTS: TDataSource;
    GroupBox2: TGroupBox;
    Label1: TLabel;
    dcta: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    cta: TLabel;
    ctaiva: TLabel;
    ivan: TLabel;
    ctaivar: TLabel;
    divar: TLabel;
    ivar: TLabel;
    H: TStringGrid;
    dcodcta: TMaskEdit;
    dimporte: TEditValid;
    dconcepto: TMaskEdit;
    selmov: TBitBtn;
    debitos: TCheckBox;
    creditos: TCheckBox;
    Codres: TMaskEdit;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    dif: TLabel;
    procedure debitosClick(Sender: TObject);
    procedure creditosClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure nroasienKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure AltaClick(Sender: TObject);
    procedure BajaClick(Sender: TObject);
    procedure ModificarClick(Sender: TObject);
    procedure SalirClick(Sender: TObject);
    procedure conceptoKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure dcodctaKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure dimporteKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure dconceptoKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure HDblClick(Sender: TObject);
    procedure hcodctaKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure himporteKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure hconceptoKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure selmovClick(Sender: TObject);
    procedure selmov1Click(Sender: TObject);
    procedure HKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure aceptarClick(Sender: TObject);
    procedure fechaKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure debitosKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure DDblClick(Sender: TObject);
    procedure DKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ConectarDatos;
    procedure BajaAsiento;
    procedure DBNavigatorClick(Sender: TObject; Button: TNavigateBtn);
    procedure CodresKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
    modifica: boolean; i: integer;
    function  asientoOk: boolean;
    function  ctrlcta(xcodcta: string): boolean;
    procedure NuevoDebito;
    procedure NuevoCredito;
    procedure Subtotal;
    procedure CargarDatos;
    procedure IniciarGrillas;
  public
    { Public declarations }
    _c, _t, _s, _n, _p, _r: string;
  end;

var
  fmIngresoContIvaV: TfmIngresoContIvaV;

implementation

uses CCInstViaCont, CUtiles, CLDiaAuV, CPlanctas, CPeriodo, CIntCoiva, CRegContV;

{$R *.DFM}

procedure TfmIngresoContIvaV.ConectarDatos;
// Objetivo...: Verificar el estado del Asiento Contable
begin
  DTS.DataSet := ldiarioauxv.cabasien;
  StatusBar1.Panels[1].Text := per.Periodo;
end;

function TfmIngresoContIvaV.asientoOk: boolean;
// Objetivo...: Verificar el estado del Asiento Contable
begin
  Result := False;
  planctas.conectar;
  conregv.getDatos(_c, _t, _s, _n, _p);   // Buscamos, si existe, el asiento que corresponde

  if ldiarioauxv.Buscar(StatusBar1.Panels[1].Text, nroasien.Text) then
    begin
      ldiarioauxv.getDatos(StatusBar1.Panels[1].Text, nroasien.Text);
      if Length(Trim(ldiarioauxv.Clave)) < 8 then
        begin
          utiles.msgError('El Nro. ' + nroasien.Text + ' corresponde a otra Categoría ...!');
          Result := False;
        end
      else
        Result := True;
    end
  else
    Result := True;

  CargarDatos;
end;

procedure TfmIngresoContIvaV.IniciarGrillas;
// Objetivo...: Verificar el estado del Asiento Contable
var
  i, j: integer;
begin
  For i := 1 to D.RowCount do  // Inicializamos las grillas
    begin
      For j := 1 to D.ColCount do D.cells[j-1, i] := '';
      For j := 1 to D.ColCount do H.cells[j-1, i] := '';
    end;
  D.row := 1; H.row := 1;
end;

procedure TfmIngresoContIvaV.CargarDatos;
// Objetivo...: Verificar el estado del Asiento Contable
var
  r: TQuery; i, j: integer;
begin
  conregv.getDatos(_c, _t, _s, _n, _p);    // Verifico si existe el asiento
  if Length(Trim(conregv.Nroasien)) > 0 then ldiarioauxv.getDatos(StatusBar1.Panels[1].Text, conregv.Nroasien) else ldiarioauxv.getDatos(StatusBar1.Panels[1].Text, nroasien.Text);
  if ldiarioauxv.Buscar(StatusBar1.Panels[1].Text, conregv.Nroasien) then nroasien.Text := conregv.Nroasien;
  if Length(Trim(fecha.Text)) < 8 then fecha.Text    := ldiarioauxv.Fecha;
  concepto.Text := ldiarioauxv.Observac;
  if Length(Trim(ldiarioauxv.Codres)) > 0 then codres.Text := ldiarioauxv.Codres else codres.Text := _r;

  IniciarGrillas;

  r := ldiarioauxv.setItems(StatusBar1.Panels[1].Text, conregv.Nroasien, _c+_t+_s+_n+_p);
  r.Open; r.First; i := 0; j := 0;
  while not r.EOF do
    begin
      if (r.FieldByName('codcta').AsString <> ctaiva.Caption) and (r.FieldByName('codcta').AsString <> ctaivar.Caption) then
       begin
         planctas.getDatos(r.FieldByName('codcta').AsString);
         if r.FieldByName('dh').AsString = '1' then
           begin
             Inc(i);
             D.cells[0, i] := r.FieldByName('codcta').AsString;
             D.cells[1, i] := planctas.getCuenta;
             D.cells[2, i] := utiles.FormatearNumero(r.FieldByName('importe').AsString);
             D.cells[3, i] := r.FieldByName('concepto').AsString;
           end
         else
           begin
             Inc(j);
             H.cells[0, j] := r.FieldByName('codcta').AsString;
             H.cells[1, j] := planctas.getCuenta;
             H.cells[2, j] := utiles.FormatearNumero(r.FieldByName('importe').AsString);
             H.cells[3, j] := r.FieldByName('concepto').AsString;
           end;
       end;
      r.Next;
    end;
    r.Close; r.Free;
end;

function TfmIngresoContIvaV.ctrlcta(xcodcta: string): boolean;
// Objetivo...: Verificar el estado de la cuenta ingresada
begin
  if not planctas.Buscar(xcodcta) then Result := False
  else
    begin
      planctas.getDatos(xcodcta);
      Result := True;
    end;
end;

procedure TfmIngresoContIvaV.NuevoDebito;
var
  j: integer;
begin
  if not modifica then Inc(i);
  if not modifica then j := i else j := D.row;

  D.cells[0, j] := hcodcta.Text;
  D.cells[1, j] := planctas.getCuenta;
  D.cells[2, j] := himporte.Text;
  D.cells[3, j] := hconcepto.Text;

  modifica := False;
  hcodcta.Text := ''; himporte.Text := '0.00'; hconcepto.Text := '';
end;

procedure TfmIngresoContIvaV.NuevoCredito;
var
  j: integer;
begin
  if not modifica then Inc(i);
  if not modifica then j := i else j := H.row;

  H.cells[0, j] := dcodcta.Text;
  H.cells[1, j] := planctas.getCuenta;
  H.cells[2, j] := dimporte.Text;
  H.cells[3, j] := dconcepto.Text;

  modifica := False;
  dcodcta.Text := ''; dimporte.Text := '0.00'; dconcepto.Text := '';
end;

procedure TfmIngresoContIvaV.Subtotal;
// Objetivo...: subtotalizar datos
var
  j: integer; td, th: real;
begin
  td := 0; th := 0;
  For j := 1 to D.RowCount do
    begin
      if Length(trim(D.cells[2, j])) > 0 then td := td + StrToFloat(D.cells[2, j]);
      if Length(trim(H.cells[2, j])) > 0 then th := th + StrToFloat(H.cells[2, j]);
    end;
  th             := th + StrToFloat(ivan.Caption) + StrToFloat(ivar.Caption);
  tdebe.Caption  := utiles.FormatearNumero(FloatToStr(td));
  thaber.Caption := utiles.FormatearNumero(FloatToStr(th));
  dif.Caption    := utiles.FormatearNumero(FloatToStr(td - th));

  if tdebe.Caption = thaber.Caption then
    if tdebe.Caption = total.Caption then aceptar.Enabled := True else aceptar.Enabled := False;

end;

procedure TfmIngresoContIvaV.debitosClick(Sender: TObject);
begin
  if debitos.Checked then GroupBox1.Enabled := True else GroupBox1.Enabled := False;
  if GroupBox1.Enabled then
    begin
      i := 0; modifica := False;
      ActiveControl := hcodcta;
    end;
end;

procedure TfmIngresoContIvaV.creditosClick(Sender: TObject);
begin
  if creditos.Checked then GroupBox2.Enabled := True else GroupBox2.Enabled := False;
  if GroupBox2.Enabled then
      begin
      i := 0; modifica := False;
      ActiveControl := dcodcta;
    end;
end;

procedure TfmIngresoContIvaV.FormCreate(Sender: TObject);
begin
  Left := StrToInt(FormatFloat('####', (Screen.DesktopWidth / 2) - (Width / 2)));
end;

procedure TfmIngresoContIvaV.FormActivate(Sender: TObject);
begin
  nroasien.Text := ''; fecha.Text := ''; concepto.Text := ''; debitos.Checked := False; creditos.Checked := False;
  ConectarDatos;
  IniciarGrillas;
  ActiveControl := nroasien;
  D.cells[0, 0] := 'Cód. Cta.'; D.cells[1, 0] := 'Cuenta'; D.cells[2, 0] := 'Importe'; D.cells[3, 0] := 'Concepto';
  H.cells[0, 0] := 'Cód. Cta.'; H.cells[1, 0] := 'Cuenta'; H.cells[2, 0] := 'Importe'; H.cells[3, 0] := 'Concepto';
  CargarDatos;
  Subtotal;
end;

procedure TfmIngresoContIvaV.nroasienKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then Close;
  if (Key = VK_RETURN) or (Key = VK_DOWN) then
    begin
      nroasien.Text := utiles.sLLenarIzquierda(nroasien.Text, 4, '0');
      if asientoOk then
        begin
          Subtotal;
          ActiveControl := fecha;
        end;
    end;
end;

procedure TfmIngresoContIvaV.AltaClick(Sender: TObject);
begin
  nroasien.Text := ldiarioauxv.NuevoAsiento;
  ActiveControl := nroasien;
end;

procedure TfmIngresoContIvaV.BajaAsiento;
begin
  conregv.getDatos(_c, _t, _s, _n, _p);   // Buscamos, si existe, el asiento que corresponde
  ConectarDatos;
  ldiarioauxv.Borrar(StatusBar1.Panels[1].Text, conregv.Nroasien, _c+_t+_s+_n);
  conregv.Borrar(_c, _t, _s, _n, _p);   // Borramos puente entre registros
end;

procedure TfmIngresoContIvaV.BajaClick(Sender: TObject);
begin
  if utiles.BajaRegistro('Asiento Nº ' + nroasien.Text) then BajaAsiento;
  ActiveControl := nroasien;
end;

procedure TfmIngresoContIvaV.ModificarClick(Sender: TObject);
begin
  ActiveControl := nroasien;
end;

procedure TfmIngresoContIvaV.SalirClick(Sender: TObject);
begin
  Close;
end;

procedure TfmIngresoContIvaV.conceptoKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_UP then ActiveControl := nroasien;
  if (Key = VK_DOWN) or (Key = VK_RETURN) then ActiveControl := debitos;
end;

procedure TfmIngresoContIvaV.dcodctaKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then ActiveControl := creditos;
  if Key = VK_UP then ActiveControl := creditos;
  if (Key = VK_DOWN) or (Key = VK_RETURN) then
    begin
      if not ctrlcta(dcodcta.Text) then selmovClick(Sender) else 
        begin
          dcta.Caption := planctas.getCuenta;
          ActiveControl   := dimporte;
        end;
    end;
end;

procedure TfmIngresoContIvaV.dimporteKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_UP then ActiveControl := dcodcta;
  if (Key = VK_RETURN) or (Key = VK_RETURN) then
    if StrToFloat(dimporte.Text) > 0 then
      begin
        dimporte.Text := utiles.FormatearNumero(dimporte.Text);
        ActiveControl := dconcepto;
      end;
end;

procedure TfmIngresoContIvaV.dconceptoKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if Key = VK_UP then ActiveControl := dimporte;
  if (Key = VK_RETURN) or (Key = VK_RETURN) then
    begin
      NuevoCredito;
      Subtotal;
      ActiveControl := dcodcta;
    end;
end;

procedure TfmIngresoContIvaV.HDblClick(Sender: TObject);
begin
  if Length(trim(H.cells[0, H.row])) > 0 then
    begin
      dcodcta.Text    := H.Cells[0, H.row];
      dcta.Caption    := H.cells[1, H.row];
      dimporte.Text   := H.cells[2, H.row];
      dconcepto.Text  := H.cells[3, H.row];
      modifica        := True;
      ActiveControl   := dcodcta;
    end;
end;

procedure TfmIngresoContIvaV.hcodctaKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then ActiveControl := debitos;
  if Key = VK_UP then ActiveControl := debitos;
  if (Key = VK_DOWN) or (Key = VK_RETURN) then
    begin
      if not ctrlcta(hcodcta.Text) then selmov1Click(Sender) else
        begin
          hcta.Caption := planctas.getCuenta;
          ActiveControl:= himporte;
        end;
    end;
end;

procedure TfmIngresoContIvaV.himporteKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_UP then ActiveControl := hcodcta;
  if (Key = VK_RETURN) or (Key = VK_RETURN) then
    if StrToFloat(himporte.Text) > 0 then
      begin
        himporte.Text := utiles.FormatearNumero(himporte.Text);
        ActiveControl := hconcepto;
      end;
end;

procedure TfmIngresoContIvaV.hconceptoKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if Key = VK_UP then ActiveControl := himporte;
  if (Key = VK_RETURN) or (Key = VK_RETURN) then
    begin
      NuevoDebito;
      Subtotal;
      ActiveControl := hcodcta;
    end;
end;

procedure TfmIngresoContIvaV.selmovClick(Sender: TObject);
begin
  utiles.Hojear(planctas.planctas, planctas.planctas.IndexDefs.Items[2].Name, '', planctas.planctas.IndexDefs.Items[2].Name, nil, 'XX00');
  dcodcta.Text  := planctas.planctas.FieldByName('codcta').AsString;
  dcta.Caption  := planctas.planctas.FieldByName('cuenta').AsString;
  ActiveControl := dcodcta;
end;

procedure TfmIngresoContIvaV.selmov1Click(Sender: TObject);
begin
  utiles.Hojear(planctas.planctas, planctas.planctas.IndexDefs.Items[2].Name, '', planctas.planctas.IndexDefs.Items[2].Name, nil, 'XX00');
  hcodcta.Text  := planctas.planctas.FieldByName('codcta').AsString;
  hcta.Caption  := planctas.planctas.FieldByName('cuenta').AsString;
  ActiveControl := hcodcta;
end;

procedure TfmIngresoContIvaV.HKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  i, x: integer;
begin
  if Key = VK_RETURN then DDblClick(Sender);
  if Key = VK_DELETE then
    if utiles.BajaRegistro('Cuenta ' + D.cells[0, D.row]) then
      begin
        For i := H.row to H.RowCount do
        //Subimos un Renglon para Recortar el Eliminado
           if Length(Trim(H.cells[0, i])) > 0 then For x := 1 to H.Colcount do H.cells[x - 1, i] := H.cells[x - 1, i + 1];
        if H.row > 1 then H.row := H.Row - 1;
        Subtotal;
      end;
end;

procedure TfmIngresoContIvaV.aceptarClick(Sender: TObject);
var
  i, t: integer;
begin
  t := 0;
  // Registro relacionado
  conregv.Grabar(_c, _t, _s, _n, _p, nroasien.Text);
  // Cabecera del asiento
  ldiarioauxv.Grabar(StatusBar1.Panels[1].Text, nroasien.Text, fecha.Text, concepto.Text, _c+_t+_s+_n+_p);
  // Operaciones del Debe
  For i := 1 to D.RowCount do
   if Length(trim(D.cells[0, i])) = 0 then Break else
    begin
       Inc(t);
       ldiarioauxv.Grabar(StatusBar1.Panels[1].Text, nroasien.Text, fecha.Text, D.cells[0, i], _c+_t+_s+_n+_p + utiles.sLlenarIzquierda(IntToStr(t), 3, '0'), D.cells[3, i], '1', _c+_t+_s+_n+_p, codres.Text, StrToFloat(D.cells[2, i]));
    end;
  // Operaciones del Haber
  t := 0;
  For i := 1 to H.RowCount do
   if Length(trim(H.cells[0, i])) = 0 then Break else
    begin
       Inc(t);
       ldiarioauxv.Grabar(StatusBar1.Panels[1].Text, nroasien.Text, fecha.Text, H.cells[0, i], _c+_t+_s+_n+_p + utiles.sLlenarIzquierda(IntToStr(t), 3, '0'), H.cells[3, i], '2', _c+_t+_s+_n+_p, codres.Text, StrToFloat(H.cells[2, i]));
    end;
  // Cuentas de I.V.A.
  Inc(t);
  ldiarioauxv.Grabar(StatusBar1.Panels[1].Text, nroasien.Text, fecha.Text, ctaiva.Caption, _c+_t+_s+_n+_p + utiles.sLlenarIzquierda(IntToStr(t), 3, '0'), cta.Caption, '2', _c+_t+_s+_n+_p, codres.Text, StrToFloat(ivan.Caption));
  if StrToFloat(ivar.Caption) > 0 then   // Si I.V.A. Recargo tiene valor
    begin
      Inc(t);
      ldiarioauxv.Grabar(StatusBar1.Panels[1].Text, nroasien.Text, fecha.Text, ctaivar.Caption, _c+_t+_s+_n+_p + utiles.sLlenarIzquierda(IntToStr(t), 3, '0'), ctaivar.Caption, '2', _c+_t+_s+_n+_p, codres.Text, StrToFloat(ivar.Caption));
    end;
  aceptar.Enabled := False;
  ActiveControl   := cerrar;
end;

procedure TfmIngresoContIvaV.fechaKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_UP then ActiveControl := nroasien;
  if (Key = VK_RETURN) or (Key = VK_DOWN) then
    if utiles.ctrlFecha(fecha) then ActiveControl := concepto;
end;

procedure TfmIngresoContIvaV.debitosKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
    if aceptar.Enabled then ActiveControl := aceptar;
end;

procedure TfmIngresoContIvaV.DDblClick(Sender: TObject);
begin
  if Length(trim(D.cells[0, D.row])) > 0 then
    begin
      hcodcta.Text    := D.Cells[0, D.row];
      hcta.Caption    := D.cells[1, D.row];
      himporte.Text   := D.cells[2, D.row];
      hconcepto.Text  := D.cells[3, D.row];
      modifica        := True;
      ActiveControl   := hcodcta;
    end;
end;

procedure TfmIngresoContIvaV.DKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  i, x: integer;
begin
  if Key = VK_RETURN then HDblClick(Sender);
  if Key = VK_DELETE then
    if utiles.BajaRegistro('Cuenta ' + H.cells[0, D.row]) then
      begin
        For i := D.row to D.RowCount do
        //Subimos un Renglon para Recortar el Eliminado
           if Length(Trim(D.cells[0, i])) > 0 then For x := 1 to D.Colcount do D.Cells[x - 1, i] := D.cells[x - 1, i + 1];
        if D.row > 1 then D.row := D.Row - 1;
        Subtotal;
      end;
end;

procedure TfmIngresoContIvaV.DBNavigatorClick(Sender: TObject;
  Button: TNavigateBtn);
begin
  nroasien.Text := ldiarioauxv.cabasien.FieldByName('nroasien').AsString;
  CargarDatos;
end;

procedure TfmIngresoContIvaV.CodresKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_UP then ActiveControl := concepto;
  if (Key = VK_RETURN) or (Key = VK_DOWN) then ActiveControl := debitos;
end;

end.
