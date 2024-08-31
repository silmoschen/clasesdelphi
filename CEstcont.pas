unit CEstcont;

interface

uses SysUtils, DB, DBTables, CIDBFM;

type

TTDefvias = class(TObject)            // Superclase
  nomvia, descrip, estado, codemp: string;
  tdefvia: TTable;
 public
  { Declaraciones Públicas }
  constructor Create(xnomvia, xdescrip: string);
  destructor  Destroy; override;

  function    getNomvia: string;
  function    getDescrip: string;
  function    getEstado: string;
  function    getCodemp: string;
  function    Buscar(xnomvia: string): boolean;
  procedure   Grabar(xnomvia, xDescrip: string);
  procedure   Borrar(xnomvia: string);
  procedure   getDatos(xnomvia: string);
  procedure   OcuparVia(xnomvia, xcodemp, xempresa: string);
  procedure   ViasLibres(empresa: string);

  procedure   conectar;
  procedure   desconectar;
private
  { Declaraciones Privadas }
end;

function defvia: TTDefvias;

implementation

var
  xdefvia: TTDefvias = nil;

constructor TTDefvias.Create(xnomvia, xdescrip: string);
begin
  inherited Create;
end;

destructor TTDefvias.Destroy;
begin
  inherited Destroy;
end;

//------------------------------------------------------------------------------

function TTDefvias.getNomvia: string;
begin
  Result := nomvia;
end;

function TTDefvias.getDescrip: string;
begin
  Result := descrip;
end;

function TTDefvias.getEstado: string;
begin
  Result := estado;
end;

function TTDefvias.getCodemp: string;
begin
  Result := codemp;
end;

function TTDefvias.Buscar(xnomvia: string): boolean;
begin
  tdefvia.Filtered := False;
  if not tdefvia.Active then conectar;
  if tdefvia.FindKey([xnomvia]) then Result := True else Result := False;
end;

procedure TTDefvias.getDatos(xnomvia: string);
// Objetivo...: Actualizar/Inicializar los atributos
begin
  if tdefvia.FindKey([xnomvia]) then
    begin
      nomvia  := tdefvia.FieldByName('nomvia').AsString;
      descrip := tdefvia.FieldByName('descrip').AsString;
      estado  := tdefvia.FieldByName('estado').AsString;
      codemp  := tdefvia.FieldByName('codemp').AsString;
    end
  else
    begin
      nomvia := ''; descrip := ''; estado := ''; codemp := '';
    end;
end;

procedure TTDefvias.OcuparVia(xnomvia, xcodemp, xempresa: string);
// Objetivo...: marcar la Vía como ocupada
begin
  if tdefvia.FindKey([xnomvia]) then
    begin
      tdefvia.Edit;
      tdefvia.FieldByName('estado').AsString  := 'O';
      tdefvia.FieldByName('codemp').AsString  := xcodemp;
      tdefvia.FieldByName('descrip').AsString := xempresa;
      try
        tdefvia.Post;
      except
        tdefvia.Cancel;
      end;
    end;
end;

procedure TTDefvias.Grabar(xnomvia, xdescrip: string);
begin
  if tdefvia.FindKey([xnomvia]) then tdefvia.Edit else tdefvia.Append;
  tdefvia.FieldByName('nomvia').AsString  := xnomvia;
  tdefvia.FieldByName('descrip').AsString := xdescrip;
  tdefvia.FieldByName('estado').AsString  := 'D';
  try
    tdefvia.Post;
  except
    tdefvia.Cancel
  end;
end;

procedure TTDefvias.Borrar(xnomvia: string);
begin
  if tdefvia.FindKey([xnomvia]) then
    begin
      tdefvia.Delete;
      getDatos(tdefvia.FieldByName('nomvia').AsString);
    end;
end;

procedure TTDefvias.ViasLibres(empresa: string);
// Objetivo...: Aislar las Vías disponibles
begin
  datosdb.Filtrar(tdefvia, 'estado <> ' + '''' + 'O' + '''' + ' or codemp = ' + '''' + empresa + '''');
end;

procedure TTDefvias.conectar;
// Objetivo...: conectar tablas de persistencia
begin
  if not tdefvia.Active then
    begin
      tdefvia.Open;
      tdefvia.Filtered := False;
      tdefvia.FieldByName('nomvia').DisplayLabel := 'Vía'; tdefvia.FieldByName('descrip').DisplayLabel := 'Descripción';
      tdefvia.FieldByName('codemp').Visible := False;
    end;
end;

procedure TTDefvias.desconectar;
// Objetivo...: conectar tablas de persistencia
begin
  datosdb.closeDB(tdefvia);
end;

{===============================================================================}

function defvia: TTDefvias;
begin
  if xdefvia = nil then
    xdefvia := TTDefvias.Create('', '');
  Result := xdefvia;
end;

{===============================================================================}

initialization

finalization
  xdefvia.Free;

end.
