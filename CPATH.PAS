unit CPATH;

interface
uses StdCtrls, FileCtrl, DB, DBTables;

type

TTPath = class(TObject)            // SuPathclase
  D: TDirectoryListBox;
  t: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  destroy; override;

  function    getPath: string;
  function    getPathSist: string;
  procedure   verificarPath;
 private
  { Declaraciones Privadas }
end;

function Path: TTPath;

implementation

var
  xPath: TTPath = nil;

constructor TTPath.Create;
begin
  inherited Create;
  D := TDirectoryListBox.Create(nil);
  if t = nil then
    begin
      t := TTable.Create(nil);
      t.TableName := '19891811.db';
    end;
end;

destructor TTPath.Destroy;
begin
  inherited Destroy;
end;

function TTPath.getPath: string;
// Objetivo...: Devolver el Path Actual
begin
  Result := D.Directory;
end;

procedure TTPath.verificarPath;
// Objetivo...: si no existe una via predeterminada; iniciar el path
begin
  t.Open;  // path por defecto
  if t.RecordCount = 0 then
    begin
      t.Append;
      t.FieldByName('VIA').AsString := path.getPath;
      t.FieldByName('VIA_SISTEM').AsString := path.getPath;
      try
        t.Post;
      except
        t.Cancel;
      end;
    end;
  t.Close;
end;

function TTPath.getPathSist: string;
// Objetivo...: retornar path de sistema
begin
  verificarPath;
  t.Open;
  Result := t.FieldByName('VIA').AsString;
  t.Close;
end;

{===============================================================================}

function Path: TTPath;
begin
  if xPath = nil then
    xPath := TTPath.Create;
  Result := xPath;
end;

{===============================================================================}

initialization

finalization
  xPath.Free;

end.
