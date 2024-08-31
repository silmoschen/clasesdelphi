unit CVias;

interface

uses SysUtils, DB, DBTables, CBDT, CIDBFM, CUtiles;

type

TTVias = class(TObject)            // Superclase
  via1, via2: string;
  tvias: TTable;
 public
  { Declaraciones Públicas }
  constructor Create(xvia1, xvia2: string);
  destructor  Destroy; override;

  function    getVia1: string;
  function    getVia2: string;
  function    DefinirVia(n_via: string): string;

  procedure   Grabar(xvia1, xvia2: string);
  function    ConectarVia(xvia1: string): string;
  procedure   conectar;
  procedure   desconectar;
private
  { Declaraciones Privadas }
end;

function via: TTVias;

implementation

var
  xvia: TTVias = nil;

constructor TTVias.Create(xvia1, xvia2: string);
begin
  inherited Create;
  if tvias = nil then
    begin
      tvias := TTable.Create(nil);
      tvias.TableName := '19891811';
    end;
end;

destructor TTVias.Destroy;
begin
  inherited Destroy;
end;

//------------------------------------------------------------------------------

function TTVias.getVia1: string;
// Objetivo....: Vía 1
var
  x: boolean;
begin
  x := tvias.Active;
  if not x then tvias.Open;
  Result  := tvias.FieldByName('via_sistem').AsString;
  tvias.Active := x;
end;

function TTVias.getVia2: string;
// Objetivo...: Vía 2
begin
  Result := tvias.FieldByName('via_sistem').AsString;
end;

function TTVias.DefinirVia(n_via: string): string;
// Objetivo....: Generar un Path para una Vía en un sistema multiempresa
begin
  Result := tvias.FieldByName('via').AsString + '\' + n_via;
end;

procedure TTVias.Grabar(xvia1, xvia2: string);
// Objetivo...: Grabar Atributos del Objeto
begin
  if Length(Trim(xvia1)) > 0 then Begin
    if tvias.RecordCount > 0 then tvias.Edit else tvias.Append;
    tvias.FieldByName('via').AsString       := xvia1;
    tvias.FieldByName('via_sistem').AsString := xvia2;
    try
      tvias.Post;
    except
      tvias.Cancel
    end;
  end;
end;

function TTVias.ConectarVia(xvia1: string): string;
// Objetivo...: Conectar una base de datos
begin
  if not tvias.Active then conectar;
  Result := getVia1 + '\' + xvia1;
end;

procedure TTVias.conectar;
// Objetivo...: conectar tablas
begin
  if not tvias.Active then tvias.Open;
end;

procedure TTVias.desconectar;
// Objetivo...: conectar tablas
begin
  datosdb.closeDB(tvias);
end;
        
{===============================================================================}

function via: TTVias;
begin
  if xvia = nil then
    xvia := TTVias.Create('', '');
  Result := xvia;
end;

{===============================================================================}

initialization

finalization
  xvia.Free;

end.
