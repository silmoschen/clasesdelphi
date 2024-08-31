unit CRefInos;

interface

uses CBDT, SysUtils, DBTables, CUtiles, CListar, CIDBFM, Forms;

type

TTRefInos = class
  Codnbu, Codigo, Exporta: String;
  tabla: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  function    Buscar(xcodnbu: String): Boolean;
  procedure   Registrar(xcodnbu, xcodigo, xexporta: String);
  procedure   Borrar(xcodnbu: String);
  procedure   getDatos(xcodnbu: String);
  function    getCodigoExporta(xcodigo: string): string;

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  conexiones: shortint;
end;

function refinos: TTRefInos;

implementation

var
  xrefinos: TTRefInos = nil;

constructor TTRefInos.Create;
begin
  if (LowerCase(ExtractFileName(Application.ExeName)) = 'shmsoftlabinter.exe') then tabla := datosdb.openDB('refinos', '') else Begin
    if (dbs.BaseClientServ = 'S') and (LowerCase(ExtractFileName(Application.ExeName)) = 'shmsoft.exe') then Begin
      tabla := datosdb.openDB('refinos', '', '', dbs.baseDat_N);
    End else
      tabla := datosdb.openDB('refinos', '');
  End;
end;

destructor TTRefInos.Destroy;
begin
  inherited Destroy;
end;

function  TTRefInos.Buscar(xcodnbu: String): Boolean;
// Objetivo...: buscar instancia
begin
  tabla.IndexFieldNames := 'codnbu';
  result := tabla.FindKey([xcodnbu]);
end;

procedure TTRefInos.Registrar(xcodnbu, xcodigo, xexporta: String);
// Objetivo...: registrar instancia
begin
  if Buscar(xcodnbu) then tabla.Edit else tabla.Append;
  tabla.FieldByName('codnbu').AsString  := xcodnbu;
  tabla.FieldByName('codigo').AsString  := xcodigo;
  tabla.FieldByName('exporta').AsString := xexporta;
  try
    tabla.Post
   except
    tabla.Cancel
  end;
  datosdb.closeDB(tabla); tabla.Open;
end;

procedure TTRefInos.Borrar(xcodnbu: String);
// Objetivo...: borrar instancia
begin
  if Buscar(xcodnbu) then Begin
    tabla.Delete;
    datosdb.closeDB(tabla); tabla.Open;
  End;
end;

procedure TTRefInos.getDatos(xcodnbu: String);
// Objetivo...: recuperar instancia
begin
  if Buscar(xcodnbu) then Begin
    codnbu  := tabla.FieldByName('codnbu').AsString;
    codigo  := tabla.FieldByName('codigo').AsString;
    exporta := tabla.FieldByName('exporta').AsString;
  end else Begin
    codnbu := ''; codigo := ''; exporta := '';
  End;
end;

function TTRefInos.getCodigoExporta(xcodigo: string): string;
// Objetivo...: devolver el codigo de exportacion
var
  cod: string;
begin
  cod := '';
  if (length(trim(xcodigo)) = 4) then begin
    tabla.IndexFieldNames := 'CODIGO';
    if (tabla.FindKey([xcodigo])) then cod := tabla.FieldByName('exporta').AsString;
  end;
  if (length(trim(xcodigo)) = 6) then begin
    tabla.IndexFieldNames := 'CODNBU';
    if (tabla.FindKey([xcodigo])) then cod := tabla.FieldByName('exporta').AsString;
  end;
  tabla.IndexFieldNames := 'CODNBU';
  result := cod;
end;

procedure TTRefInos.conectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones = 0 then Begin
    if not tabla.Active then tabla.Open;
  end;
  Inc(conexiones);
end;

procedure TTRefInos.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  Dec(conexiones);
  if conexiones = 0 then Begin
    datosdb.closeDB(tabla);
  end;
end;

{===============================================================================}

function refinos: TTRefInos;
begin
  if xrefinos = nil then
    xrefinos := TTRefInos.Create;
  Result := xrefinos;
end;

{===============================================================================}

initialization

finalization
  xrefinos.Free;

end.
