unit CLibContAsociacion;

interface

uses CContabilidadAsociacion, CEmpresas, SysUtils, DB, DBTables, CBDT, CUtiles, CIDBFM, CListar;

type

TTLibrosCont = class(TTContabilidad)            // Superclase
  idanterior, idanterior1, path1: string;  // Atributos de usos comunes
  totdebe, tothaber, saldo, saldoanter, saldofinal, totingresos, totegresos: real;
  TSQL: TQuery;
  _existe: boolean;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;
 private
  { Declaraciones Privadas }
  inf_iniciado: boolean;
 protected
  { Declaraciones Protegidas }
  procedure IniciarInforme(salida: char); virtual;
  procedure IniciarListado;
end;

function lcont: TTLibrosCont;

implementation

var
  xlcont: TTLibrosCont = nil;

constructor TTLibrosCont.Create;
begin
  inherited Create;
  idanterior  := '';
  totdebe     := 0;
  tothaber    := 0;
  pag         := 0;
  cantcopias  := 1;
  espacios    := 10;
end;

destructor TTLibrosCont.Destroy;
begin
  inherited Destroy;
end;

procedure TTLibrosCont.IniciarListado;
// Objetivo...: Inicializar los atributos a utilizar en los informes
begin
  list.altopag := 0; pag := 0; list.m := 0;
  inf_iniciado := True;
end;

procedure TTLibrosCont.IniciarInforme(salida: char);
// Objetivo...: Desencadenar una secuencia de eventos para la Preparación de Informes
begin
  if salida = 'I' then list.CantidadDeCopias(cantcopias);
  list.Setear(salida);     // Iniciar Listado
  IniciarListado;          // Emisión Múltiple
  list.FijarSaltoManual;   // Controlamos el Salto de la Página
end;

{===============================================================================}

function lcont: TTLibrosCont;
begin
  if xlcont = nil then
    xlcont := TTLibrosCont.Create;
  Result := xlcont;
end;

{===============================================================================}

initialization

finalization
  xlcont.Free;

end.