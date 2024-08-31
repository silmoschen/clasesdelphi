// Clase......: CFactChe
// Objetivo...: Retener los cheques librados para una Factura de Compras

unit CFactChe;

interface

uses CLibroBcos, SysUtils, DB, DBTables, CUtiles, CIDBFM;

type

TTChequesFact = class(TObject)            // Superclase
  idc, tipo, sucursal, numero, cuit, clavecta, nrocheque: string;
  tabla: TTable;
 public
  { Declaraciones Públicas }
  constructor Create(xidc, xtipo, xsucursal, xnumero, xcuit, xclavecta, xnrocheque: string);
  destructor  Destroy; override;

  procedure   Grabar(xidc, xtipo, xsucursal, xnumero, xcuit, xclavecta, xnrocheque: string);
  procedure   Borrar(xidc, xtipo, xsucursal, xnumero, xcuit: string); virtual;
  function    Buscar(xidc, xtipo, xsucursal, xnumero, xcuit, xclavecta, xnrocheque: string): boolean;
  function    setCheques(xidc, xtipo, xsucursal, xnumero, xcuit: string): TQuery;

  procedure   vaciarBuffer;
  procedure   conectar;
  procedure   desconectar;
 private
  conexiones: shortint;
  { Declaraciones Privadas }
end;

function refercf: TTChequesFact;

implementation

var
  xrefercf: TTChequesFact = nil;

constructor TTChequesFact.Create(xidc, xtipo, xsucursal, xnumero, xcuit, xclavecta, xnrocheque: string);
begin
  inherited Create;
  idc       := xidc;
  tipo      := xtipo;
  sucursal  := xsucursal;
  numero    := xnumero;
  cuit      := xcuit;
  clavecta  := xclavecta;
  nrocheque := xnrocheque;
end;

destructor TTChequesFact.Destroy;
begin
  inherited Destroy;
end;

procedure TTChequesFact.Grabar(xidc, xtipo, xsucursal, xnumero, xcuit, xclavecta, xnrocheque: string);
// Objetivo...: Grabar Atributos del Objeto
begin
  if Buscar(xidc, xtipo, xsucursal, xnumero, xcuit, xclavecta, xnrocheque) then tabla.Edit else tabla.Append;
  tabla.FieldByName('idc').AsString       := xidc;
  tabla.FieldByName('tipo').AsString      := xtipo;
  tabla.FieldByName('sucursal').AsString  := xsucursal;
  tabla.FieldByName('numero').AsString    := xnumero;
  tabla.FieldByName('cuit').AsString      := xcuit;
  tabla.FieldByName('clavecta').AsString  := xclavecta;
  tabla.FieldByName('nrocheque').AsString := xnrocheque;
  try
    tabla.Post;
  except
    tabla.Cancel;
  end;
end;

procedure TTChequesFact.Borrar(xidc, xtipo, xsucursal, xnumero, xcuit: string);
// Objetivo...: Eliminar un Objeto
var
  r: TQuery;
begin
  // Paso 1 - Extraemos y Eliminamos los cheques asociados
  r := setCheques(xidc, xtipo, xsucursal, xnumero, xcuit);
  r.Open; r.First;
  while not r.EOF do
    begin
      banco.Borrar(r.FieldByName('clavecta').AsString, r.FieldByName('nrocheque').AsString, '2');
      r.Next;
    end;
  r.Close; r.Free;
  // Paso 2 - Eliminamos la referencia
  datosdb.tranSQL('DELETE FROM ' + tabla.TableName + ' WHERE idc = ' + '''' + xidc + '''' + '  AND tipo = ' + '''' + xtipo + '''' + ' AND sucursal = ' + '''' + xsucursal + '''' + ' AND numero = ' + '''' + xnumero + '''' + ' AND cuit = ' + '''' + xcuit + '''');
end;

function TTChequesFact.Buscar(xidc, xtipo, xsucursal, xnumero, xcuit, xclavecta, xnrocheque: string): boolean;
// Objetivo...: Buscar el Objeto solicitado
begin
  Result := datosdb.Buscar(tabla, 'idc', 'tipo', 'sucursal', 'numero', 'cuit', 'clavecta', 'nrocheque', xidc, xtipo, xsucursal, xnumero, xcuit, xclavecta, xnrocheque);
end;

function TTChequesFact.setCheques(xidc, xtipo, xsucursal, xnumero, xcuit: string): TQuery;
// Objetivo...: devolver un set con los cheques asociados a un comprobante
begin
  Result := datosdb.tranSQL('SELECT * FROM ' + tabla.TableName + ' WHERE idc = ' + '''' + xidc + '''' + ' AND tipo = ' + '''' + xtipo + '''' + ' AND sucursal = ' + '''' + xsucursal + '''' + ' AND numero = ' + '''' + xnumero + '''' + ' AND cuit = ' + '''' + xcuit + '''');
end;

procedure TTChequesFact.vaciarBuffer;
// Objetivo...: vaciar buffers de tablas al disco
begin
  datosdb.vaciarBuffer(tabla);
end;

procedure TTChequesFact.conectar;
// Objetivo...: conectar tablas de persistencia
begin
  if conexiones = 0 then
    if not tabla.Active then tabla.Open;
  Inc(conexiones);
end;

procedure TTChequesFact.desconectar;
// Objetivo...: desconectar tablas de persistencia
begin
  Dec(conexiones);
  if conexiones = 0 then datosdb.closeDB(tabla);
end;

{===============================================================================}

function refercf: TTChequesFact;
begin
  if xrefercf = nil then
    xrefercf := TTChequesFact.Create('', '', '', '', '', '', '');
  Result := xrefercf;
end;

{===============================================================================}

initialization

finalization
  xrefercf.Free;

end.