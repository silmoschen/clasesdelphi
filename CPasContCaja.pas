unit CPasContCaja;

interface

uses CPascont, SysUtils, CRegCont, CLDiario, CCaja, CIdctas, DB, DBTables, CBDT, CUtiles, CIDBFM, CPardigct, CLDiaAuC, CLDiaAuV, CCNetos;

type

TTPasesCajaContabilidad = class(TTAsientosAutomaticos)            // Supascontcajaclase
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  destroy; override;

  procedure AsientosCajaIngresos(xperiodo, xmes, xdia: string);
  procedure AsientosCajaEgresos(xperiodo, xmes, xdia: string);
end;

function pascontcaja: TTPasesCajaContabilidad;

implementation

var
  xpasescont: TTPasesCajaContabilidad = nil;

constructor TTPasesCajaContabilidad.Create;
begin
  inherited Create;
end;

destructor TTPasesCajaContabilidad.Destroy;
begin
  inherited Destroy;
end;

//******************************************************************************
procedure TTPasesCajaContabilidad.AsientosCajaIngresos(xperiodo, xmes, xdia: string);
// Objetivo...: Generar Asiento Contable a partir de los Ingresos de Caja
// Pase.......: Caja -> al -> Diario
var
  r: TQuery; j: integer;
begin
  PrepararProceso;
  claveas  := 'CI' + xmes;
  BajaAsiento(xperiodo, claveas);
  r := caja.setIngresos(xperiodo, xmes);
  r.Open; r.First; idanterior := r.FieldByName('codcta').AsString; xindice := 0; totdebe := 0; tothaber := 0;
  while not r.EOF do
    begin
      if r.FieldByName('codcta').AsString <> idanterior then
        begin
          Inc(xindice);
          cuenta    [xindice] := idanterior;
          ttothaber [xindice] := tothaber;  // Movimientos del haber
          tothaber            := 0;
        end;
      totdebe  := totdebe  + r.FieldByName('importe').AsFloat;
      tothaber := tothaber + r.FieldByName('importe').AsFloat;
      idanterior := r.FieldByName('codcta').AsString;
      r.Next;
    end;
  r.Close; r.Free;
  if (totdebe + tothaber) <> 0 then   // Si hay operaciones registradas
    begin
      Inc(xindice);
      cuenta    [xindice] := idanterior;
      ttothaber [xindice] := tothaber;  // Movimientos del haber
      // Grabamos Cabecera del asiento
      numeroas := ldiario.NuevoAsiento;
      ldiario.Grabar(xperiodo, numeroas, xdia + '/' + xmes + '/' + Copy(xperiodo, 3, 2), 'Ingresos Caja ' + xmes + '/' + xperiodo, claveas);
      // Grabamos los movimientos del debe - desde el array
      ldiario.Grabar(xperiodo, numeroas, xdia + '/' + xmes + '/' + Copy(xperiodo, 3, 2), idctas.getCodcta('C01'), '001', 'Ingresos de Efectivo', '1', claveas, totdebe);
      // Grabamos los movimientos del haber - desde el array
      For j := 1 to xindice do
        ldiario.Grabar(xperiodo, numeroas, xdia + '/' + xmes + '/' + Copy(xperiodo, 3, 2), cuenta[j], utiles.sLlenarIzquierda(IntToStr(j + 1), 3, '0'), 'Ingresos de Efectivo', '2', claveas, ttothaber[j]);
    end;
end;

procedure TTPasesCajaContabilidad.AsientosCajaEgresos(xperiodo, xmes, xdia: string);
// Objetivo...: Generar Asiento Contable a partir de los Egresos de Caja
// Pase.......: Caja -> al -> Diario
var
  r: TQuery; j: integer; n: integer;
begin
  PrepararProceso;
  claveas  := 'CE' + xmes; n := 0;
  BajaAsiento(xperiodo, claveas);
  r := caja.setEgresos(xperiodo, xmes);
  r.Open; r.First; idanterior := r.FieldByName('codcta').AsString; xindice := 0; totdebe := 0; tothaber := 0;
  while not r.EOF do
    begin
      if r.FieldByName('codcta').AsString <> idanterior then
        begin
          Inc(xindice);
          cuenta    [xindice] := idanterior;
          ttotdebe [xindice]  := totdebe;  // Movimientos del Debe
          totdebe             := 0;
        end;
      totdebe  := totdebe  + r.FieldByName('importe').AsFloat;
      tothaber := tothaber + r.FieldByName('importe').AsFloat;
      idanterior := r.FieldByName('codcta').AsString;
      r.Next;
    end;
  r.Close; r.Free;
  if (totdebe + tothaber) <> 0 then   // Si hay operaciones registradas
    begin
      Inc(xindice);
      cuenta    [xindice] := idanterior;
      ttotdebe  [xindice] := totdebe;  // Movimientos del haber
      // Grabamos Cabecera del asiento
      numeroas := ldiario.NuevoAsiento;
      ldiario.Grabar(xperiodo, numeroas, xdia + '/' + xmes + '/' + Copy(xperiodo, 3, 2), 'Ingresos Caja ' + xmes + '/' + xperiodo, claveas);
      // Grabamos los movimientos del haber - desde el array
      For j := 1 to xindice do
        begin
          ldiario.Grabar(xperiodo, numeroas, xdia + '/' + xmes + '/' + Copy(xperiodo, 3, 2), cuenta[j], utiles.sLlenarIzquierda(IntToStr(j + 1), 3, '0'), 'Egresos de Efectivo', '1', claveas, ttotdebe[j]);
          n := j + 1;
        end;
      // Grabamos los movimientos del haber - desde el array
      ldiario.Grabar(xperiodo, numeroas, xdia + '/' + xmes + '/' + Copy(xperiodo, 3, 2), idctas.getCodcta('C01'), utiles.sLlenarIzquierda(IntToStr(n + 1), 3, '0'), 'Egresos de Efectivo', '2', claveas, tothaber);
    end;
end;

{===============================================================================}

function pascontcaja: TTPasesCajaContabilidad;
begin
  if xpasescont = nil then
    xpasescont := TTPasesCajaContabilidad.Create;
  Result := xpasescont;
end;

{===============================================================================}

initialization

finalization
  xpasescont.Free;

end.