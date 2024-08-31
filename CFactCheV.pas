// Clase......: CFactChe
// Objetivo...: Retener los cheques librados para una Factura de Compras

unit CFactCheV;

interface

uses  CLibChequesRec, CFactChe, SysUtils, DB, DBTables, CUtiles, CIDBFM;

type

TTChequesFactVentas = class(TTChequesFact)
 public
  { Declaraciones Públicas }
  constructor Create(xidc, xtipo, xsucursal, xnumero, xcuit, xclavecta, xnrocheque: string);
  destructor  Destroy; override;

  procedure Borrar(xidc, xtipo, xsucursal, xnumero, xcuit: string); override;
 private
  { Declaraciones Privadas }
end;

function refercfv: TTChequesFactVentas;

implementation

var
  xrefercf: TTChequesFactVentas = nil;

constructor TTChequesFactVentas.Create(xidc, xtipo, xsucursal, xnumero, xcuit, xclavecta, xnrocheque: string);
begin
  inherited Create(xidc, xtipo, xsucursal, xnumero, xcuit, xclavecta, xnrocheque);
  tabla     := datosdb.openDB('refercfv', 'idc;tipo;sucursal;numero;cuit');
end;

destructor TTChequesFactVentas.Destroy;
begin
  inherited Destroy;
end;

procedure TTChequesFactVentas.Borrar(xidc, xtipo, xsucursal, xnumero, xcuit: string);
// Objetivo...: Eliminar un Objeto
var
  r: TQuery;
begin
  // Paso 1 - Extraemos y Eliminamos los cheques asociados
  r := setCheques(xidc, xtipo, xsucursal, xnumero, xcuit);
  r.Open; r.First;
  while not r.EOF do
    begin
      cheqrec.Borrar(r.FieldByName('clavecta').AsString, r.FieldByName('nrocheque').AsString, '2');
      r.Next;
    end;
  r.Close; r.Free;
  // Paso 2 - Eliminamos la referencia
  datosdb.tranSQL('DELETE FROM ' + tabla.TableName + ' WHERE idc = ' + '''' + xidc + '''' + '  AND tipo = ' + '''' + xtipo + '''' + ' AND sucursal = ' + '''' + xsucursal + '''' + ' AND numero = ' + '''' + xnumero + '''' + ' AND cuit = ' + '''' + xcuit + '''');
end;

{===============================================================================}

function refercfv: TTChequesFactVentas;
begin
  if xrefercf = nil then
    xrefercf := TTChequesFactVentas.Create('', '', '', '', '', '', '');
  Result := xrefercf;
end;

{===============================================================================}

initialization

finalization
  xrefercf.Free;

end.