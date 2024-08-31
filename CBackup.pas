unit CBackup;

interface

uses CBDT, SysUtils, CUtiles, Classes;

type

TTBackup = class
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  procedure   RegistrarModulos(xlista: TStringList);
  function    setModulos: TStringList;
 private
  { Declaraciones Privadas }
  archivo: TextFile;
end;

function backup: TTBackup;

implementation

var
  xbackup: TTBackup = nil;

constructor TTBackup.Create;
begin
end;

destructor TTBackup.Destroy;
begin
  inherited Destroy;
end;

procedure TTBackup.RegistrarModulos(xlista: TStringList);
var
  i: Integer;
Begin
  AssignFile(archivo, dbs.DirSistema + '\backups.ini');
  Rewrite(archivo);
  For i := 1 to xlista.Count do
    WriteLn(archivo, xlista.Strings[i-1]);
  closeFile(archivo);
end;

function  TTBackup.setModulos: TStringList;
var
  s: String;
  l: TStringList;
Begin
  l := TStringList.Create;
  if FileExists(dbs.DirSistema + '\backups.ini') then Begin
    AssignFile(archivo, dbs.DirSistema + '\backups.ini');
    Reset(archivo);
    while not eof(archivo) do Begin
      ReadLn(archivo, s);
      l.Add(s);
    end;
    closeFile(archivo);
  end;
  Result := l;
end;

{===============================================================================}

function backup: TTBackup;
begin
  if xbackup = nil then
    xbackup := TTBackup.Create;
  Result := xbackup;
end;

{===============================================================================}

initialization

finalization
  xbackup.Free;

end.
