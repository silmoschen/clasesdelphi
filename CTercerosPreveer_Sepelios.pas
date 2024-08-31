unit CTercerosPreveer_Sepelios;

interface

uses CPersonasPreveer_Sepelios, CPreverCostos, CBDT, SysUtils, DB, DBTables, CUtiles, CListar, CIDBFM, CCodPost;

type

TTTercerosSepelio = class(TTPersonasSepelio)
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;
 private
  { Declaraciones Privadas }
end;

function tercerossep: TTTercerosSepelio;

implementation

var
  xhijsep: TTTercerosSepelio = nil;

constructor TTTercerosSepelio.Create;
begin
  tperso := datosdb.openDB('terceros', 'Nrodoc', '', dbs.DirSistema + '\sepelio');
end;

destructor TTTercerosSepelio.Destroy;
begin
  inherited Destroy;
end;

{===============================================================================}

function tercerossep: TTTercerosSepelio;
begin
  if xhijsep = nil then
    xhijsep := TTTercerosSepelio.Create;
  Result := xhijsep;
end;

{===============================================================================}

initialization

finalization
  xhijsep.Free;

end.
