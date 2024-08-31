unit CAnexoPrendaRegistro;

interface

uses CForm, CBDT, SysUtils, DB, DBTables, CUtiles, CIDBFM;

type

TTAnexoPrendaRegistro = class(TTForms)
  aMes, aAnio, aAcreedor, aDeudor: string;
  bDia1, bDia2, bMes, bAnio: string;
  cForma: shortint; cCuotas, cDia, cMes, cAnio, cMes1, cAnio1: string;
  dPeriodo: shortint; dInteres, dEfectivo: real;
  eEfectiva: real; ePeriodo: shortint;
  fConyuge, fDocid, fNrodoc, fNupcias: string;
  gCodeudor: string;
  hTitular, hDocid, hNrodoc: string;
  iTribunales, iDomAcr, iDomDeudor: string;

  anexopr, cLapso: TTable;
 public
  { Declaraciones Públicas }
  constructor Create(xnroform, xfeoper, xdominio, xdnrocuit, xdpersoneria, xdinscripcion, xdinscricrea, xdfecha, xgmarca, xgtipo, xgmodelo, xgmotor, xgnromotor, xgmarcachasis, xgnrochasis, xecuit, xicgrado: string; xesoltipo, xicclausula, xicconcepto: shortint; xmonto: real);
  destructor  Destroy; override;

  function    Buscar(xnroform: string): boolean;
  procedure   Grabar(xnroform, xFecha, xaMes, xaAnio, xaAcreedor, xaDeudor, xbDia1, xbDia2, xbMes, xbAnio: string; xcForma: shortint; xcCuotas, xcDia, xcMes, xcAnio, xcMes1, xcAnio1: string; xdPeriodo: shortint; xdInteres, xdEfectivo: real;
                     xeEfectiva: real; xePeriodo: shortint; xfNupcias: string; xgCodeudor: string);
  procedure   Borrar(xnroform: string);
  procedure   getDatos(xnroform: string);

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
end;

function anexopreg: TTAnexoPrendaRegistro;

implementation

var
  xanexopreg: TTAnexoPrendaRegistro = nil;

constructor TTAnexoPrendaRegistro.Create;
// Vendedor - Heredada de Persona
begin
  inherited Create('', '', '', 0);

  tform        := datosdb.openDB('anexopr', 'nroform');
  anexopr      := datosdb.openDB('anexoprh', 'nroform');
end;

destructor TTAnexoPrendaRegistro.Destroy;
begin
  inherited Destroy;
end;

function TTAnexoPrendaRegistro.Buscar(xnroform: string): boolean;
// Objetivo...: buscar una instancia
begin
  if anexopr.FindKey([xnroform]) then Result := True else Result := False;
end;

  procedure TTAnexoPrendaRegistro.Grabar(xnroform, xFecha, xaMes, xaAnio, xaAcreedor, xaDeudor, xbDia1, xbDia2, xbMes, xbAnio: string; xcForma: shortint; xcCuotas, xcDia, xcMes, xcAnio, xcMes1, xcAnio1: string; xdPeriodo: shortint; xdInteres, xdEfectivo: real;
                     xeEfectiva: real; xePeriodo: shortint; xfNupcias: string; xgCodeudor: string);
// Objetivo...: Grabar una instacia
begin
  inherited Grabar(xnroform, xfecha, '', 0);
  if Buscar(xnroform) then anexopr.Edit else anexopr.Append;
  anexopr.FieldByName('nroform').AsString      := xnroform;
  anexopr.FieldByName('ames').AsString         := xAmes;
  anexopr.FieldByName('aanio').AsString        := xAanio;
  anexopr.FieldByName('aacreedor').AsString    := xAacreedor;
  anexopr.FieldByName('adeudor').AsString      := xAdeudor;
  anexopr.FieldByName('bdia1').AsString        := xBdia1;
  anexopr.FieldByName('bdia2').AsString        := xBdia2;
  anexopr.FieldByName('bmes').AsString         := xBmes;
  anexopr.FieldByName('banio').AsString        := xBanio;
  anexopr.FieldByName('cforma').AsInteger      := xCforma;
  anexopr.FieldByName('ccuotas').AsString      := xCcuotas;
  anexopr.FieldByName('cdia').AsString         := xCdia;
  anexopr.FieldByName('cmes').AsString         := xCanio;
  anexopr.FieldByName('cmes1').AsString        := xCmes1;
  anexopr.FieldByName('canio1').AsString       := xCanio1;
  anexopr.FieldByName('dperiodo').AsInteger    := xdperiodo;
  anexopr.FieldByName('dinteres').AsFloat      := xDinteres;
  anexopr.FieldByName('defectivo').AsFloat     := xDefectivo;
  anexopr.FieldByName('fnupcias').AsString     := xfNupcias;
  anexopr.FieldByName('fcodeudor').AsString    := xGcodeudor;
  try
    anexopr.Post;
  except
    anexopr.Cancel;
  end;
end;

procedure TTAnexoPrendaRegistro.Borrar(xnroform: string);
// Objetivo...: Borrar una instancia de la clase
begin
  if Buscar(xnroform) then
    begin
      inherited Borrar(xnroform);
      anexopr.Delete;
      getDatos(anexopr.FieldByName('nroform').AsString);
    end;
end;

procedure TTAnexoPrendaRegistro.getDatos(xnroform: string);
// Objetivo...: Cargar los atributos de una instacia
begin
  inherited getDatos(xnroform);
  if Buscar(xnroform) then
    begin
      xnroform     := anexopr.FieldByName('nroform').AsString;
      {dnrocuit     := tform31.FieldByName('dnrocuit').AsString;
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
      icconcepto   := tform31.FieldByName('icconcepto').AsInteger;}
    end
  else
    begin
//      nroform := ''; dnrocuit := ''; dpersoneria := ''; dinscripcion := ''; dinscricrea := ''; dfecha := ''; gmarca := ''; gtipo := ''; gmodelo := ''; gmotor := ''; gnromotor := ''; gnrochasis := ''; gmarcachasis := ''; ecuit := ''; icgrado := ''; esoltipo := 0; icclausula := 0; icconcepto := 0;
    end;
end;

procedure TTAnexoPrendaRegistro.conectar;
// Objetivo...: conectar tablas de persistencia
begin
  {if not tform.Active then tform.Open;
  if not tform31.Active then tform31.Open;}
end;

procedure TTAnexoPrendaRegistro.desconectar;
// Objetivo...: desconectar tablas de persistencia
begin
  datosdb.closeDB(tform);
  //datosdb.closeDB(tform31);
end;

{===============================================================================}

function anexopreg: TTAnexoPrendaRegistro;
begin
  if xanexopreg = nil then
    xanexopreg := TTAnexoPrendaRegistro.Create('', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', 0, 0, 0, 0);
  Result := xanexopreg;
end;

{===============================================================================}

initialization

finalization
  xanexopreg.Free;

end.
