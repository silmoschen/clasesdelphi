unit CMySQL;

interface

uses CBDT, SysUtils, DBTables, CUtiles, CListar, CIDBFM,
     MemDS, DBAccess, MyAccess;

type

TmySQL = class
 public
  { Declaraciones Públicas }
  conexion: TMyConnection;
  tabla: TMyTable;

  constructor Create;
  destructor  Destroy; override;

  function    openDB(xtabla, xindice: String): TMyTable;

 private
  { Declaraciones Privadas }
end;

function mySQL: TmySQL;

implementation

var
  xmySQL: TmySQL = nil;

constructor TmySQL.Create;
var
  t: TTable;
begin
  t           := TTable.Create(Nil);
  t.TableName := 'drvconectMySQL';
  t.Open;

  conexion             := TMyConnection.Create(Nil);
  conexion.LoginPrompt := False;
  conexion.Database    := t.FieldByName('odbcdrv').AsString;
  conexion.Server      := t.FieldByName('server').AsString;
  conexion.Username    := t.FieldByName('usuario').AsString;
  conexion.Password    := t.FieldByName('password').AsString;
  conexion.Connected   := True;

  t.Close; t.Destroy;
end;

destructor TmySQL.Destroy;
begin
  inherited Destroy;
  conexion.Close;
  conexion.Destroy;
end;

function  TmySQL.openDB(xtabla, xindice: String): TMyTable;
Begin
  tabla            := TMyTable.Create(Nil);
  tabla.Connection := conexion;
  tabla.TableName  := xtabla;
  Result           := tabla;
end;


{===============================================================================}

function mySQL: TmySQL;
begin
  if xmySQL = nil then
    xmySQL := TmySQL.Create;
  Result := xmySQL;
end;

{===============================================================================}

initialization

finalization
  xmySQL.Free;

end.
