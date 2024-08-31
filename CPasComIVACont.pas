unit CPasComIVACont;

interface

uses CPasCont, SysUtils, CRegCont, CLDiario, CCaja, CIdctas, DB, DBTables, CBDT, CUtiles, CIDBFM, CLDiaAuC, CLDiaAuV, CCNetos;

type

TTCompactarAsientosIVA = class(TTAsientosAutomaticos)
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  destroy; override;

  procedure ViasDeTrabajo(xviaiva, xviacont: string);
  procedure CompactarAsientosIVAC(xperiodo, xmes, xdia: string);
  procedure CompactarAsientosIVAV(xperiodo, xmes, xdia: string);
 private
  { Declaraciones Privadas }
  procedure RegMovCuenta;
  function  verifCuenta(xcodctaref: string): integer;
end;

function pascontiva: TTCompactarAsientosIVA;

implementation

var
  xpasescont: TTCompactarAsientosIVA = nil;

constructor TTCompactarAsientosIVA.Create;
begin
  inherited Create;
end;

destructor TTCompactarAsientosIVA.Destroy;
begin
  inherited Destroy;
end;

//******************************************************************************

procedure TTCompactarAsientosIVA.ViasDeTrabajo(xviaiva, xviacont: string);
begin
  path1 := xviaiva;
  path  := xviacont;
  inherited PrepararProceso;
  idctas.Via(path);
end;

procedure TTCompactarAsientosIVA.CompactarAsientosIVAC(xperiodo, xmes, xdia: string);
// Objetivo...: Compactar los Asientos Cargados a Partir de los movimientos ingresados en I.V.A. Compras
// Pase.......: Diario Auxiliar I.V.A. Compras -> al -> Diario
var
  r: TQuery;
begin
  PrepararProceso;
  claveas  := 'IC' + xmes; totdebe := 0; tothaber := 0; f := False;
  BajaAsiento(xperiodo, claveas);
  ldiarioauxc.path := dbs.dirSistema + path;
  r := ldiarioauxc.setItems(xperiodo, xmes);
  r.Open; r.First; idmov := r.FieldByName('codres').AsString;
  while not r.EOF do
    begin
      f := True;
      if (r.FieldByName('codres').AsString <> idmov) and (totdebe + tothaber <> 0) then
        begin
          RegMovCuenta;  // Cerramos el ultimo movimiento del asiento
          RegistrarAsiento(xperiodo, xmes , xdia); // Registramos el asiento
        end
      else   // Procesamiento normal
        if r.FieldByName('codcta').AsString <> idanterior then RegMovCuenta;

      if r.FieldByName('dh').AsString = '1' then totdebe := totdebe + r.FieldByName('importe').AsFloat else tothaber := tothaber + r.FieldByName('importe').AsFloat;
      idanterior := r.FieldByName('codcta').AsString; idanterior1 := r.FieldByName('dh').AsString; conc := r.FieldByName('concepto').AsString; idmov := r.FieldByName('codres').AsString;
      r.Next;
    end;
    RegMovCuenta;
    // Verificamos que existan movimientos
    if f then RegistrarAsiento(xperiodo, xmes , xdia);
end;

procedure TTCompactarAsientosIVA.CompactarAsientosIVAV(xperiodo, xmes, xdia: string);
// Objetivo...: Compactar los Asientos Cargados a Partir de los movimientos ingresados en I.V.A. Ventas
// Pase.......: Diario Auxiliar I.V.A. Ventas -> al -> Diario
var
  r: TQuery;
begin
  PrepararProceso;
  claveas  := 'IV' + xmes; totdebe := 0; tothaber := 0; f := False;
  BajaAsiento(xperiodo, claveas);
  ldiarioauxv.path := dbs.dirSistema + path;
  r := ldiarioauxv.setItems(xperiodo, xmes);
  r.Open; r.First; idmov := r.FieldByName('codres').AsString;
  while not r.EOF do
    begin
      f := True;
      if (r.FieldByName('codres').AsString <> idmov) and (totdebe + tothaber <> 0) then
        begin
          RegMovCuenta;  // Cerramos el ultimo movimiento del asiento
          RegistrarAsiento(xperiodo, xmes , xdia); // Registramos el asiento
        end
      else   // Procesamiento normal
        if r.FieldByName('codcta').AsString <> idanterior then RegMovCuenta;

      if r.FieldByName('dh').AsString = '1' then totdebe := totdebe + r.FieldByName('importe').AsFloat else tothaber := tothaber + r.FieldByName('importe').AsFloat;
      idanterior := r.FieldByName('codcta').AsString; idanterior1 := r.FieldByName('dh').AsString; conc := r.FieldByName('concepto').AsString; idmov := r.FieldByName('codres').AsString;
      r.Next;
    end;
    RegMovCuenta;
    // Verificamos que existan movimientos
    if f then RegistrarAsiento(xperiodo, xmes , xdia);
end;
//------------------------------------------------------------------------------
procedure TTCompactarAsientosIVA.RegMovCuenta;
// Objetivo...: registrar el movimiento de la cuenta
var
  p, j: integer;
begin
  j := verifCuenta(idanterior);
  if j = 0 then
    begin
      Inc(xindice);
      p := xindice;
    end
  else
    p := j;

  cuenta    [p] := idanterior;
  ttotdebe  [p] := ttotdebe  [p] + totdebe;   // Movimientos del Debe
  ttothaber [p] := ttothaber [p] + tothaber;  // Movimientos del Haber
  tmov      [p] := idanterior1;
  tcon      [p] := conc;
  totdebe := 0; tothaber := 0;
  if totdebe <> 0 then f := True;
end;

function TTCompactarAsientosIVA.verifCuenta(xcodctaref: string): integer;
// Objetivo...: Verificar la exisitencia de la cuenta en el array, devolviendo su posici'on - para actualizarla
var
  x: integer;
begin
  Result := 0;
  For x := 1 to xindice do
    if cuenta[x] = xcodctaref then
      begin
        Result := x;
        Break;
      end;
end;

{===============================================================================}

function pascontiva: TTCompactarAsientosIVA;
begin
  if xpasescont = nil then
    xpasescont := TTCompactarAsientosIVA.Create;
  Result := xpasescont;
end;

{===============================================================================}

initialization

finalization
  xpasescont.Free;

end.