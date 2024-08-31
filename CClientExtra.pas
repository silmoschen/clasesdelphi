unit CClientExtra;

interface

uses CBDT, CCliente, CTPFiscal, CCodpost, SysUtils, DB, DBTables, CUtiles, CListar, CIDBFM;

type

TTClienteExtra = class(TTCliente)          // Clase TVendedor Heredada de Persona
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  function    BuscarNroCuit(xnrocuit: string): boolean;
 private
  { Declaraciones Privadas }
end;

function clienteextra: TTClienteExtra;

implementation

var
  xclienteextra: TTClienteExtra = nil;

constructor TTClienteExtra.Create;
// Vendedor - Heredada de Persona
begin
  inherited Create;

  tperso := datosdb.openDB('clientesext', 'codcli');
  tabla2 := datosdb.openDB('clientehext', 'codcli');
end;

destructor TTClienteExtra.Destroy;
begin
  inherited Destroy;
end;

function TTClienteExtra.BuscarNroCuit(xnrocuit: string): boolean;
// Objetivo...: Verificar la existencia de un número de C.U.I.T.
begin
  tabla2.IndexName := 'Nrocuit';
  if tabla2.FindKey([xnrocuit]) then Begin
    codigo := tabla2.FieldByName('codcli').AsString;
    Result := True;
  end
  else
    Result := False;
  tabla2.IndexFieldNames := 'Codcli';
end;

{===============================================================================}

function clienteextra: TTClienteExtra;
begin
  if xclienteextra = nil then
    xclienteextra := TTClienteExtra.Create;
  Result := xclienteextra;
end;

{===============================================================================}

initialization

finalization
  xclienteextra.Free;

end.
