unit CDefViasCont;

interface

uses CDefVias, SysUtils, DB, DBTables, CBDT, CIDBFM;

type

TTdefviascont = class(TTdefvias)            // Superclase
 public
  { Declaraciones Públicas }
  constructor Create(xnomvia, xdescrip: string);
  destructor  Destroy; override;

  procedure   OcuparVia(xvia: string);
  procedure   DesocuparVia(xvia: string);
  procedure   AislarVia(xvia: string);
  function    getViasDisponibles(xvia: string): TTable;
  function    setVias: TQuery;
  procedure   conectar;
  procedure   desconectar;
private
  { Declaraciones Privadas }
end;

function defviacont: TTDefviasCont;

implementation

var
  xdefviacont: TTDefviasCont = nil;

constructor TTDefviasCont.Create(xnomvia, xdescrip: string);
begin
  inherited Create(xnomvia, xdescrip);
  tdefvia := datosdb.openDB('viascont', 'nomvia');
end;

destructor TTDefviasCont.Destroy;
begin
  inherited Destroy;
end;

procedure TTDefViasCont.OcuparVia(xvia: string);
// Objetivo...: Ocupar Vía de trabajo (marcarla)
begin
  if Buscar(xvia) then
    begin
      tdefvia.Edit;
      tdefvia.FieldByName('estado').AsString := 'O';
      try
        tdefvia.Post;
      except
        tdefvia.Cancel;
      end;
    end;
end;

procedure TTDefViasCont.DesocuparVia(xvia: string);
// Objetivo...: Ocupar Vía de trabajo (marcarla)
begin
  if Buscar(xvia) then
    begin
      tdefvia.Edit;
      tdefvia.FieldByName('estado').AsString := ' ';
      try
        tdefvia.Post;
      except
        tdefvia.Cancel;
      end;
    end;
end;

function  TTDefviasCont.getViasDisponibles(xvia: string): TTable;
// Objetivo...: devolver un set con las vías disponibles
begin
  Result := datosdb.Filtrar(tdefvia, 'estado <> ' + '''' + 'O' + '''' + ' or nomvia = ' + '''' + xvia + '''');
end;

procedure TTDefviasCont.AislarVia(xvia: string);
begin
  datosdb.Filtrar(tdefvia, 'nomvia <> ' + '''' + xvia + '''');
end;

function TTDefviasCont.setVias: TQuery;
// Objetivo...: Devolver un set con las Vías disponibles
begin
  Result := datosdb.tranSQL('SELECT * FROM viascont');
end;

procedure TTDefviasCont.conectar;
begin
  if not tdefvia.Active then tdefvia.Open;
end;

procedure TTDefviasCont.desconectar;
begin
  datosdb.closeDB(tdefvia);
end;

{===============================================================================}

function defviacont: TTDefviasCont;
begin
  if xdefviacont = nil then
    xdefviacont := TTDefviasCont.Create('', '');
  Result := xdefviacont;
end;

{===============================================================================}

initialization

finalization
  xdefviacont.Free;

end.
