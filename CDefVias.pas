unit CDefVias;

interface

uses SysUtils, DB, DBTables, CIDBFM, CVias;

type

TTDefvias = class(TObject)            // Superclase
  nomvia, descrip, estado, codemp: string;
  tdefvia: TTable;
 public
  { Declaraciones Públicas }
  constructor Create(xnomvia, xdescrip: string);
  destructor  Destroy; override;

  function    Buscar(xnomvia: string): boolean;
  procedure   Grabar(xnomvia, xDescrip: string);
  procedure   Borrar(xnomvia: string);
  procedure   getDatos(xnomvia: string);
  procedure   OcuparVia(xnomvia, xcodemp, xempresa: string);
  procedure   DesocuparVia(xnomvia: string);
  procedure   Preparar(xnomvia: string);
  procedure   ViasLibres(empresa: string);
  procedure   BuscarPorVia(expresion: string);

  procedure   conectar;
  procedure   desconectar;
private
  { Declaraciones Privadas }
  conexiones: shortint;
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

function TTDefvias.Buscar(xnomvia: string): boolean;
var
  f: boolean;
begin
  f := tdefvia.Filtered;
  tdefvia.Filtered := False;
  if not tdefvia.Active then conectar;
  if tdefvia.FindKey([xnomvia]) then Result := True else Result := False;
  tdefvia.Filtered := f;
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

procedure TTDefvias.Preparar(xnomvia: string);
// Objetivo...: marcar la Vía como Preparada - directorio creado y archivos copiados
begin
  if tdefvia.FindKey([xnomvia]) then
    begin
      tdefvia.Edit;
      tdefvia.FieldByName('estado').AsString  := 'P';
      try
        tdefvia.Post;
      except
        tdefvia.Cancel;
      end;
    end;
end;

procedure TTDefvias.Grabar(xnomvia, xdescrip: string);
var
  f: boolean;
begin
  f := tdefvia.Filtered;
  tdefvia.Filtered := False;
  if tdefvia.FindKey([xnomvia]) then tdefvia.Edit else tdefvia.Append;
  tdefvia.FieldByName('nomvia').AsString  := xnomvia;
  tdefvia.FieldByName('descrip').AsString := xdescrip;
  if tdefvia.FieldByName('estado').AsString <> 'O' then tdefvia.FieldByName('estado').AsString  := 'D';
  try
    tdefvia.Post;
  except
    tdefvia.Cancel
  end;
  tdefvia.Filtered := f;
  tdefvia.FindKey([xnomvia]);
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

procedure TTDefvias.BuscarPorVia(expresion: string);
begin
  if tdefvia.IndexFieldNames <> 'nomvia' then tdefvia.IndexFieldNames := 'nomvia';
  tdefvia.FindNearest([expresion]);
end;

procedure TTDefvias.conectar;
// Objetivo...: conectar tablas de persistencia
begin
  if conexiones = 0 then Begin
    via.conectar;
    if not tdefvia.Active then Begin
      tdefvia.Open;
      tdefvia.Filtered := False;
      tdefvia.FieldByName('nomvia').DisplayLabel := 'Vía'; tdefvia.FieldByName('descrip').DisplayLabel := 'Descripción';
      tdefvia.FieldByName('codemp').Visible := False;
    end;
  end;
  Inc(conexiones);
  tdefvia.Filtered := False;
end;

procedure TTDefvias.desconectar;
// Objetivo...: conectar tablas de persistencia
begin
  if conexiones > 0 then Dec(conexiones);
  if conexiones = 0 then Begin
    via.desconectar;
    datosdb.closeDB(tdefvia);
  end;
end;

procedure TTDefvias.DesocuparVia(xnomvia: string);
// Objetivo...: desocupar una vía de trabajo para ser ocupada por otra empresa
begin
  if Buscar(xnomvia) then
    begin
      tdefvia.Edit;
      tdefvia.FieldByName('estado').AsString := 'D';
      try
        tdefvia.Post;
      except
        tdefvia.Cancel;
      end;
    end;
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
