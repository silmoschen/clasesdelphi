unit CHijosPreveer_Sepelios;

interface

uses CPersonasPreveer_Sepelios, CBDT, SysUtils, DB, DBTables, CUtiles, CListar, CIDBFM, CCodPost;

type

THijosSepelio = class(TTPersonasSepelio)
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;
 private
  { Declaraciones Privadas }
end;

function hijossep: THijosSepelio;

implementation

var
  xhijsep: THijosSepelio = nil;

constructor THijosSepelio.Create;
begin
  tperso := datosdb.openDB('hijos', 'Nrodoc', '', dbs.DirSistema + '\sepelio');
end;

destructor THijosSepelio.Destroy;
begin
  inherited Destroy;
end;

{===============================================================================}

function hijossep: THijosSepelio;
begin
  if xhijsep = nil then
    xhijsep := THijosSepelio.Create;
  Result := xhijsep;
end;

{===============================================================================}

initialization

finalization
  xhijsep.Free;

end.
