unit CCBloqueos;

interface

uses CBDT, SysUtils, DBTables, CUtiles, CListar, CIDBFM;

type

TTBloqueo = class
  bloqueos: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  function    Bloquear(xproceso: String): Boolean;
  procedure   QuitarBloqueo(xproceso: String);
 private
  { Declaraciones Privadas }
  conexiones: shortint;
end;

function bloqueo: TTBloqueo;

implementation

var
  xbloqueo: TTBloqueo = nil;

constructor TTBloqueo.Create;
begin
  bloqueos := datosdb.openDB('bloqueos', '');
end;

destructor TTBloqueo.Destroy;
begin
  inherited Destroy;
end;

function  TTBloqueo.Bloquear(xproceso: String): Boolean;
// Objetivo...: bloquear proceso
var
  er: Boolean;
begin
  bloqueos.Open;
  er := bloqueos.FindKey([xproceso]);
  if not er then Begin
    bloqueos.Append;
    bloqueos.FieldByName('proceso').AsString := xproceso;
    bloqueos.FieldByName('bloqueo').AsString := 'S';
    try
      bloqueos.Post
    except
      bloqueos.Cancel
    end;
    datosdb.closeDB(bloqueos); bloqueos.Open;
    Result := True;    // Se bloquea por primera vez
  end else Begin
    if bloqueos.FieldByName('bloqueo').AsString = 'S' then Result := False else Begin // El Proceso está bloqueado
      bloqueos.Edit;
      bloqueos.FieldByName('bloqueo').AsString  := 'S';
      try
        bloqueos.Post
      except
        bloqueos.Cancel
      end;
      datosdb.closeDB(bloqueos); bloqueos.Open;
      Result := True;    // Se bloquea por primera vez
    end;
  end;
  bloqueos.Close;
end;

procedure TTBloqueo.QuitarBloqueo(xproceso: String);
// Objetivo...: Quitar Bloqueo
begin
  bloqueos.Open;
  if bloqueos.FindKey([xproceso]) then Begin
    bloqueos.Edit;
    bloqueos.FieldByName('bloqueo').AsString  := 'N';
    try
      bloqueos.Post
    except
      bloqueos.Cancel
    end;
    datosdb.closeDB(bloqueos); bloqueos.Open;
  end;
  bloqueos.Close;
end;

{===============================================================================}

function bloqueo: TTBloqueo;
begin
  if xbloqueo = nil then
    xbloqueo := TTBloqueo.Create;
  Result := xbloqueo;
end;

{===============================================================================}

initialization

finalization
  xbloqueo.Free;

end.
