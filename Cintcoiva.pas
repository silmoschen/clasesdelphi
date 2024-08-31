unit Cintcoiva;

interface

uses CEmprCont, CEmpresas, SysUtils, DB, DBTables, CBDT, CUtiles, CIDBFM;

type

TTIntContIva = class(TObject)            // Superclase
  empriva, emprcont: string;
  tabla: TTable;
 public
  { Declaraciones Públicas }
  constructor Create(xempriva, xemprcont: string);
  destructor  Destroy; override;

  procedure   Grabar(xempriva, xemprcont: string);
  procedure   Borrar(xempriva: string);
  function    Buscar(xempriva: string): boolean;
  function    BuscarEC(xempresa: string): boolean;
  procedure   getDatos(xempriva: string);

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  conexiones: shortint;
end;

function intcoiva: TTIntContIva;

implementation

var
  xintcoiva: TTIntContIva = nil;

constructor TTIntContIva.Create(xempriva, xemprcont: string);
begin
  inherited Create;
  empriva  := xempriva;
  emprcont := xemprcont;
  tabla := datosdb.openDB('intcoiva', 'empriva');
end;

destructor TTIntContIva.Destroy;
begin
  inherited Destroy;
end;

procedure TTIntContIva.Grabar(xempriva, xemprcont: string);
// Objetivo...: Grabar Atributos del Objeto
begin
  if Buscar(xempriva) then tabla.Edit else tabla.Append;
  tabla.FieldByName('empriva').AsString  := xempriva;
  tabla.FieldByName('emprcont').AsString := xemprcont;
  try
    tabla.Post;
  except
    tabla.Cancel;
  end;
end;

procedure TTIntContIva.Borrar(xempriva: string);
// Objetivo...: Eliminar un Objeto
begin
  if Buscar(xempriva) then
    begin
      tabla.Delete;
      getDatos(tabla.FieldByName('empriva').AsString);  // Fijamos los Atributos Siguientes al Objeto Borrado
    end;
end;

function TTIntContIva.Buscar(xempriva: string): boolean;
// Objetivo...: Buscar el Objeto solicitado
begin
  tabla.Filtered := False;
  if tabla.FindKey([xempriva]) then Result := True else Result := False;
end;

function TTIntContIva.BuscarEC(xempresa: string): boolean;
// Objetivo...: Verificar la existencia de una empresa contable
begin
  Result := False;
  tabla.First;
  while not tabla.EOF do Begin
    if tabla.FieldByName('emprcont').AsString = xempresa then Begin
      Result := True;
      Break;
    end;
    tabla.Next;
  end;
end;

procedure  TTIntContIva.getDatos(xempriva: string);
// Objetivo...: Retornar/Iniciar Atributos
begin
  if Buscar(xempriva) then
    begin
      empriva  := tabla.FieldByName('empriva').AsString;
      emprcont := tabla.FieldByName('emprcont').AsString;
     end
   else
    begin
      empriva := ''; emprcont := '';
    end;
end;

procedure TTIntContIva.conectar;
// Objetivo...: conectar tablas de persistencia
begin
  if conexiones = 0 then Begin
    if not tabla.Active then tabla.Open;
    tabla.FieldByName('empriva').DisplayLabel := 'Contribuyente I.V.A.'; tabla.FieldByName('emprcont').DisplayLabel := 'Empresa Contabilidad';
  end;
  empresa.conectar;
  defemprcont.conectar;
  Inc(conexiones);
end;

procedure TTIntContIva.desconectar;
// Objetivo...: desconectar tablas de persistencia
begin
  if conexiones > 0 then Dec(conexiones);
  if conexiones = 0 then datosdb.closeDB(tabla);
  empresa.desconectar;
  defemprcont.desconectar;
end;

{===============================================================================}

function intcoiva: TTIntContIva;
begin
  if xintcoiva = nil then
    xintcoiva := TTIntContIva.Create('', '');
  Result := xintcoiva;
end;

{===============================================================================}

initialization

finalization
  xintcoiva.Free;

end.