unit CPasContKinesiologos;

interface

uses CPascont, SysUtils, CRegCont, CLDiario, CCaja, CIdctas, DB, DBTables, CBDT, CUtiles, CIDBFM, CPlanctas;

type

TTPasesCajaContabilidad = class(TTAsientosAutomaticos)            // Supascontcajaclase
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  destroy; override;

  procedure AsientosFactObraSocial(xperiodo, xmes, xdia: string);
  procedure AsientosKinesilogos(xperiodo, xmes, xdia: string);
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
procedure TTPasesCajaContabilidad.AsientosFactObraSocial(xperiodo, xmes, xdia: string);
// Objetivo...: Generar Asiento con la Facturacion de las obras sociales
var
  r: TQuery; j: integer;
begin
  PrepararProceso;
  claveas  := 'KI' + xmes;
  BajaAsiento(xperiodo, claveas);
  r := datosdb.tranSQL('\ckin', 'select * from kibafap where fecha >= ' + '''' + xmes + '/' + '01/' + Copy(xperiodo, 3, 2) + '''' + ' and fecha <= ' + '''' + xmes + '/' + xdia + '/' + Copy(xperiodo, 3, 2) + '''' + ' order by codosa, fecha'); ///////////// 'SELECT * FROM kibafap WHERE fecha >= ' + '''' + '01/' + xmes + '/' + Copy(xperiodo, 3, 2) + '''' + ' AND fecha <= ' + '''' + xdia + '/' + xmes + '/' + Copy(xperiodo, 3, 2) + '''' + ' ORDER BY codosa, fecha';
  r.Open; r.First; idanterior := r.FieldByName('codosa').AsString; xindice := 0; totdebe := 0; tothaber := 0;
  while not r.EOF do
    begin
      if (r.FieldByName('codosa').AsString <> idanterior) and (totdebe <> 0) then
        begin
          planctas.getDatos(idanterior); 
          Inc(xindice);
          cuenta   [xindice] := planctas.cuenta; //planctas.getCodcta('S' + idanterior);
          ttotdebe [xindice] := totdebe;  // Movimientos del debe
          totdebe            := 0;
        end;
      totdebe  := totdebe  + (r.FieldByName('importe').AsFloat + r.FieldByName('comaran').AsFloat);
      tothaber := tothaber + (r.FieldByName('importe').AsFloat + r.FieldByName('comaran').AsFloat);
      idanterior := r.FieldByName('codosa').AsString;
      r.Next;
    end;
  r.Close; r.Free;

  if (totdebe + tothaber) <> 0 then   // Si hay operaciones registradas
    begin
      if totdebe <> 0 then
        begin
          Inc(xindice);
          cuenta    [xindice] := planctas.setCodigoRapido('S' + idanterior);  //planctas.getCodcta('S' + idanterior);
          ttotdebe  [xindice] := totdebe;  // Movimientos del debe
        end;
      // Grabamos Cabecera del asiento
      idctas.getDatos('KI1');
      numeroas := ldiario.NuevoAsiento;
      ldiario.Grabar(xperiodo, numeroas, xdia + '/' + xmes + '/' + Copy(xperiodo, 3, 2), idctas.getConcepto + ' ' + xmes + '/' + xperiodo, claveas);
      // Grabamos los movimientos del debe - desde el array
      For j := 1 to xindice do
        ldiario.Grabar(xperiodo, numeroas, xdia + '/' + xmes + '/' + Copy(xperiodo, 3, 2), cuenta[j], utiles.sLlenarIzquierda(IntToStr(j + 1), 3, '0'), idctas.getConcepto, '1', claveas, ttotdebe[j]);
      // Grabamos los movimientos del haber - desde el array
      ldiario.Grabar(xperiodo, numeroas, xdia + '/' + xmes + '/' + Copy(xperiodo, 3, 2), idctas.getCodcta('KI1'), '999', idctas.getConcepto, '2', claveas, tothaber);
    end;
end;

procedure TTPasesCajaContabilidad.AsientosKinesilogos(xperiodo, xmes, xdia: string);
// Objetivo...: Generar Asiento con los pagos a efectuar a Kinesiólogos
var
  r: TQuery; j: integer;
begin
  PrepararProceso;
  claveas  := 'KJ' + xmes;
  BajaAsiento(xperiodo, claveas);
  r := datosdb.tranSQL('\ckin', 'select * from kibafap where fecha >= ' + '''' + xmes + '/' + '01/' + Copy(xperiodo, 3, 2) + '''' + ' and fecha <= ' + '''' + xmes + '/' + xdia + '/' + Copy(xperiodo, 3, 2) + '''' + ' order by codigo, fecha');
  r.Open; r.First; idanterior := r.FieldByName('codigo').AsString; xindice := 0; totdebe := 0; tothaber := 0;
  while not r.EOF do
    begin
      if (r.FieldByName('codigo').AsString <> idanterior) and (tothaber <> 0) then
        begin
          Inc(xindice);
          cuenta   [xindice] := planctas.setCodigoRapido('K' + idanterior); //planctas.getCodcta('K' + idanterior);
          ttothaber[xindice] := tothaber;  // Movimientos del haber
          tothaber           := 0;
        end;
      totdebe  := totdebe  + r.FieldByName('galenos').AsFloat; /////+ r.FieldByName('comaran').AsFloat);
      tothaber := tothaber + r.FieldByName('galenos').AsFloat; /////+ r.FieldByName('comaran').AsFloat);
      idanterior := r.FieldByName('codigo').AsString;
      r.Next;
    end;
  r.Close; r.Free;

  if (totdebe + tothaber) <> 0 then   // Si hay operaciones registradas
    begin
      if totdebe <> 0 then
        begin
          Inc(xindice);
          cuenta     [xindice] := planctas.setCodigoRapido('K' + idanterior); //planctas.getCodcta('K' + idanterior);
          ttothaber  [xindice] := tothaber;  // Movimientos del debe
        end;
      idctas.getDatos('KI2');
      // Grabamos Cabecera del asiento
      numeroas := ldiario.NuevoAsiento;
      ldiario.Grabar(xperiodo, numeroas, xdia + '/' + xmes + '/' + Copy(xperiodo, 3, 2), idctas.getConcepto + ' ' + xmes + '/' + xperiodo, claveas);
      // Grabamos los movimientos del debe - desde el array
      ldiario.Grabar(xperiodo, numeroas, xdia + '/' + xmes + '/' + Copy(xperiodo, 3, 2), idctas.getCodcta('KI2'), '000', idctas.getConcepto, '1', claveas, totdebe);
      // Grabamos los movimientos del haber - desde el array
      For j := 1 to xindice do
        ldiario.Grabar(xperiodo, numeroas, xdia + '/' + xmes + '/' + Copy(xperiodo, 3, 2), cuenta[j], utiles.sLlenarIzquierda(IntToStr(j + 1), 3, '0'), idctas.getConcepto, '2', claveas, ttothaber[j]);
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