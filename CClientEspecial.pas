unit CClientEspecial;

interface

uses CBDT, CCliente, CTPFiscal, CCodpost, SysUtils, DB, DBTables, CUtiles, CListar, CIDBFM;

type

TTClienteEspecial = class(TTCliente)          // Clase TVendedor Heredada de Persona
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  function    BuscarNroCuit(xnrocuit: string): boolean;
  procedure   conectar;
 private
  { Declaraciones Privadas }
end;

function clientespecial: TTClienteEspecial;

implementation

var
  xcliente: TTClienteEspecial = nil;

constructor TTClienteEspecial.Create;
// Vendedor - Heredada de Persona
begin
  inherited Create;
  tperso := datosdb.openDB('clientesesp', 'codcli');
  tabla2 := datosdb.openDB('clientehesp', 'codcli');
end;

destructor TTClienteEspecial.Destroy;
begin
  inherited Destroy;
end;

function TTClienteEspecial.BuscarNroCuit(xnrocuit: string): boolean;
// Objetivo...: Verificar la existencia de un número de C.U.I.T.
begin
  tabla2.IndexName := 'Nrocuit';
  if tabla2.FindKey([xnrocuit]) then Begin
    codigo := tabla2.FieldByName('codcli').AsString;
    getDatos(codigo);
    Result := True;
  end
  else
    Result := False;
  tabla2.IndexFieldNames := 'Codcli';
end;

procedure TTClienteEspecial.conectar;
begin
  inherited conectar;
  tperso.FieldByName('domicilio').DisplayLabel := 'Dirección';
end;

{===============================================================================}

function clientespecial: TTClienteEspecial;
begin
  if xcliente = nil then
    xcliente := TTClienteEspecial.Create;
  Result := xcliente;
end;

{===============================================================================}

initialization

finalization
  xcliente.Free;

end.
