unit CLibCont;

interface

uses CContabilidad, CEmpresas, SysUtils, DB, DBTables, CBDT, CUtiles, CIDBFM, CListar;

type

TTLibrosCont = class(TTContabilidad)            // Superclase
  idanterior, idanterior1, path1: string;  // Atributos de usos comunes
  totdebe, tothaber, saldo, saldoanter, saldofinal, totingresos, totegresos: real;
  pag, i, r, cantcopias, espacios: integer;
  TSQL: TQuery;
  _existe: boolean;
  EmpresaRsocial, EmpresaRsocial2, EmpresaCuit, EmpresaDireccion: String;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;
 private
  { Declaraciones Privadas }
  inf_iniciado: boolean;
 protected
  { Declaraciones Protegidas }
  procedure ListDatosEmpresa(salida: char);
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

procedure TTLibrosCont.ListDatosEmpresa(salida: char);
// Objetivo...: Listar el encabezado de Página con los datos de la empresa
begin
  if Length(Trim(empresa.nombre))    > 0 then empresaRsocial   := empresa.nombre;
  if Length(Trim(empresa.rsocial2))  > 0 then empresaRsocial2  := empresa.rsocial2;
  if Length(Trim(empresa.nrocuit))   > 0 then empresaCuit      := empresa.nrocuit;
  if Length(Trim(empresa.domicilio)) > 0 then empresaDireccion := empresa.domicilio;
  if salida <> 'X' then list.IniciarTitulos;
  pag := pag + 1;
  if (salida = 'P') or (salida = 'I') then Begin
    list.Titulo(0, 0, ' ', 1, 'Arial, negrita, 10');
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 8'); list.Titulo(espacios, list.Lineactual, empresaRsocial, 2, 'Arial, normal, 8');
    if empresa.Rsocial2 <> '' then Begin
      list.Titulo(0, 0, ' ', 1, 'Arial, normal, 7');
      list.Titulo(espacios, list.Lineactual, empresaRsocial2, 2, 'Arial, normal, 7');
    end;
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 7'); list.Titulo(espacios, list.Lineactual, empresaCuit, 2, 'Arial, normal, 7');
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 7'); list.Titulo(espacios, list.Lineactual, empresaDireccion, 2, 'Arial, normal, 7');
    list.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');
  end;
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