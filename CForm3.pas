unit CForm3;

interface

uses CForm, CBDT, SysUtils, DB, DBTables, CUtiles, CIDBFM;

type

TTForm3 = class(TTForms)
  dnrocuit, dpersoneria, dinscripcion, dinscricrea, dfecha, gmarca, gtipo, gmodelo, gmotor, gnromotor, gmarcachasis, gnrochasis, ecuit, icgrado: string;
  esoltipo, icclausula, icconcepto: shortint;
  tform31: TTable;
 public
  { Declaraciones Públicas }
  constructor Create(xnroform, xfeoper, xdominio, xdnrocuit, xdpersoneria, xdinscripcion, xdinscricrea, xdfecha, xgmarca, xgtipo, xgmodelo, xgmotor, xgnromotor, xgmarcachasis, xgnrochasis, xecuit, xicgrado: string; xesoltipo, xicclausula, xicconcepto: shortint; xmonto: real);
  destructor  Destroy; override;

  function    Buscar(xnroform: string): boolean;
  procedure   Grabar(xnroform, xfeoper, xdominio, xdnrocuit, xdpersoneria, xdinscripcion, xdinscricrea, xdfecha, xgmarca, xgtipo, xgmodelo, xgmotor, xgnromotor, xgmarcachasis, xgnrochasis, xecuit, xicgrado: string; xesoltipo, xicclausula, xicconcepto: shortint; xmonto: real);
  procedure   Borrar(xnroform: string);
  procedure   getDatos(xnroform: string);

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
end;

function form03: TTForm3;

implementation

var
  xform03: TTForm3 = nil;

constructor TTForm3.Create(xnroform, xfeoper, xdominio, xdnrocuit, xdpersoneria, xdinscripcion, xdinscricrea, xdfecha, xgmarca, xgtipo, xgmodelo, xgmotor, xgnromotor, xgmarcachasis, xgnrochasis, xecuit, xicgrado: string; xesoltipo, xicclausula, xicconcepto: shortint; xmonto: real);
// Vendedor - Heredada de Persona
begin
  inherited Create(xnroform, xfeoper, xdominio, xmonto);
  dnrocuit     := xdnrocuit;
  dpersoneria  := xdpersoneria;
  dinscripcion := dinscripcion;
  dinscricrea  := xdinscricrea;
  dfecha       := xdfecha;
  gmarca       := xgmarca;
  gtipo        := xgtipo;
  gmodelo      := xgmodelo;
  gmotor       := xgmotor;
  gnromotor    := xgnromotor;
  gmarcachasis := xgmarcachasis;
  gnrochasis   := xgnrochasis;
  ecuit        := xecuit;
  icgrado      := xicgrado;
  esoltipo     := xesoltipo;
  icclausula   := xicclausula;
  icconcepto   := xicconcepto;

  tform        := datosdb.openDB('form3.DB', 'nroform');
  tform31      := datosdb.openDB('Form3h.DB', 'nroform');
end;

destructor TTForm3.Destroy;
begin
  inherited Destroy;
end;

function TTForm3.Buscar(xnroform: string): boolean;
// Objetivo...: buscar una instancia
begin
  if tform31.FindKey([xnroform]) then Result := True else Result := False;
end;

procedure TTForm3.Grabar(xnroform, xfeoper, xdominio, xdnrocuit, xdpersoneria, xdinscripcion, xdinscricrea, xdfecha, xgmarca, xgtipo, xgmodelo, xgmotor, xgnromotor, xgmarcachasis, xgnrochasis, xecuit, xicgrado: string; xesoltipo, xicclausula, xicconcepto: shortint; xmonto: real);
// Objetivo...: Grabar una instacia
begin
  inherited Grabar(xnroform, xfeoper, xdominio, xmonto);
  if Buscar(xnroform) then tform31.Edit else tform31.Append;
  tform31.FieldByName('nroform').AsString      := xnroform;
  tform31.FieldByName('dnrocuit').AsString     := xdnrocuit;
  tform31.FieldByName('dpersoneria').AsString  := xdpersoneria;
  tform31.FieldByName('dinscripcion').AsString := xdinscripcion;
  tform31.FieldByName('dinscricrea').AsString  := xdinscricrea;
  tform31.FieldByName('dfecha').AsString       := utiles.sExprFecha(xdfecha);
  tform31.FieldByName('gmarca').AsString       := xgmarca;
  tform31.FieldByName('gtipo').AsString        := xgtipo;
  tform31.FieldByName('gmodelo').AsString      := xgmodelo;
  tform31.FieldByName('gmotor').AsString       := xgmotor;
  tform31.FieldByName('gnromotor').AsString    := xgnromotor;
  tform31.FieldByName('gmarcachasis').AsString := xgmarcachasis;
  tform31.FieldByName('gnrochasis').AsString   := xgnrochasis;
  tform31.FieldByName('ecuit').AsString        := xecuit;
  tform31.FieldByName('icgrado').AsString      := xicgrado;
  tform31.FieldByName('esoltipo').AsInteger    := xesoltipo;
  tform31.FieldByName('icclausula').AsInteger  := xicclausula;
  tform31.FieldByName('icconcepto').AsInteger  := xicconcepto;
  try
    tform31.Post;
  except
    tform31.Cancel;
  end;
end;

procedure TTForm3.Borrar(xnroform: string);
// Objetivo...: Borrar una instancia de la clase
begin
  if Buscar(xnroform) then
    begin
      inherited Borrar(xnroform);
      tform31.Delete;
      getDatos(tform31.FieldByName('nroform').AsString);
    end;
end;

procedure TTForm3.getDatos(xnroform: string);
// Objetivo...: Cargar los atributos de una instacia
begin
  inherited getDatos(xnroform);
  if Buscar(xnroform) then
    begin
      xnroform     := tform31.FieldByName('nroform').AsString;
      dnrocuit     := tform31.FieldByName('dnrocuit').AsString;
      dpersoneria  := tform31.FieldByName('dpersoneria').AsString;
      dinscripcion := tform31.FieldByName('dinscripcion').AsString;
      dinscricrea  := tform31.FieldByName('dinscricrea').AsString;
      dfecha       := utiles.sFormatoFecha(tform31.FieldByName('dfecha').AsString);
      gmarca       := tform31.FieldByName('gmarca').AsString;
      gtipo        := tform31.FieldByName('gtipo').AsString;
      gmodelo      := tform31.FieldByName('gmodelo').AsString;
      gmotor       := tform31.FieldByName('gmotor').AsString;
      gnromotor    := tform31.FieldByName('gnromotor').AsString;
      gnrochasis   := tform31.FieldByName('gnrochasis').AsString;
      gmarcachasis := tform31.FieldByName('gmarcachasis').AsString;
      ecuit        := tform31.FieldByName('ecuit').AsString;
      icgrado      := tform31.FieldByName('icgrado').AsString;
      esoltipo     := tform31.FieldByName('esoltipo').AsInteger;
      icclausula   := tform31.FieldByName('icclausula').AsInteger;
      icconcepto   := tform31.FieldByName('icconcepto').AsInteger;
    end
  else
    begin
      nroform := ''; dnrocuit := ''; dpersoneria := ''; dinscripcion := ''; dinscricrea := ''; dfecha := ''; gmarca := ''; gtipo := ''; gmodelo := ''; gmotor := ''; gnromotor := ''; gnrochasis := ''; gmarcachasis := ''; ecuit := ''; icgrado := ''; esoltipo := 0; icclausula := 0; icconcepto := 0;
    end;
end;

procedure TTForm3.conectar;
// Objetivo...: conectar tablas de persistencia
begin
  if not tform.Active then tform.Open;
  if not tform31.Active then tform31.Open;
end;

procedure TTForm3.desconectar;
// Objetivo...: desconectar tablas de persistencia
begin
  datosdb.closeDB(tform);
  datosdb.closeDB(tform31);
end;

{===============================================================================}

function form03: TTForm3;
begin
  if xform03 = nil then
    xform03 := TTForm3.Create('', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', 0, 0, 0, 0);
  Result := xform03;
end;

{===============================================================================}

initialization

finalization
  xform03.Free;

end.
