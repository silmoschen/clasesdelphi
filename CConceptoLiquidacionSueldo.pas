unit CConceptoLiquidacionSueldo;

interface

uses SysUtils, DB, DBTables, CUtiles, CListar, CFirebird, CUtilidadesArchivos,
     IBDatabase, IBCustomDataSet, IBTable, Variants, CBDT;

type

TTConceptoSueldo = class(TObject)
  Codigo, Concepto, Tipomov: string; Porcentaje: Real;
  tabla: TIBTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  function    Nuevo: string;
  procedure   Grabar(xcodigo, xconcepto, xtipomov: string; xporcentaje: Real);
  procedure   Borrar(xcodigo: string);
  function    Buscar(xcodigo: string): boolean;
  procedure   getDatos(xcodigo: string);
  function    BuscarPorDescrip(xexpr: string): Boolean;
  procedure   BuscarPorCodigo(xexpr: string);

  procedure   conectar;
  procedure   desconectar;
 private
  conexiones: shortint;
  { Declaraciones Privadas }
end;

function conceptoliq: TTConceptoSueldo;

implementation

var
  xconceptoliq: TTConceptoSueldo = nil;

constructor TTConceptoSueldo.Create;
begin
  inherited Create;
  firebird.getModulo('sueldos');
  firebird.Conectar(firebird.Host + '\arch\arch.gdb', firebird.Usuario, firebird.Password);
  tabla := firebird.InstanciarTabla('conceptos');
end;

destructor TTConceptoSueldo.Destroy;
begin
  inherited Destroy;
end;

function TTConceptoSueldo.Nuevo: string;
// Objetivo...: Generar un nuevo ID
begin
  tabla.IndexFieldNames := 'CODIGO';
  tabla.Last;
  if tabla.RecordCount = 0 then Result := '1' else Begin
    Result := IntToStr(StrToInt(tabla.FieldByName('CODIGO').AsString) + 1);
  end;
end;

procedure TTConceptoSueldo.Grabar(xcodigo, xconcepto, xtipomov: string; xporcentaje: Real);
// Objetivo...: Grabar Atributos del Objeto
begin
  if Buscar(xcodigo) then tabla.Edit else tabla.Append;
  tabla.FieldByName('codigo').AsString      := xcodigo;
  tabla.FieldByName('concepto').AsString    := xconcepto;
  tabla.FieldByName('tipomov').AsString     := xtipomov;
  tabla.FieldByName('porcentaje').AsFloat   := xporcentaje;
  try
    tabla.Post;
   except
    tabla.Cancel
  end;
  firebird.RegistrarTransaccion(tabla);
end;

procedure TTConceptoSueldo.Borrar(xcodigo: string);
// Objetivo...: Eliminar un Objeto
begin
  if Buscar(xcodigo) then Begin
    tabla.Delete;
    getDatos(tabla.FieldByName('codigo').AsString);  // Fijamos los Atributos Siguientes al Objeto Borrado
    firebird.RegistrarTransaccion(tabla);
  end;
end;

function TTConceptoSueldo.Buscar(xcodigo: string): boolean;
// Objetivo...: Buscar el Objeto solicitado
begin
  if tabla.IndexFieldNames <> 'CODIGO' then tabla.IndexFieldNames := 'CODIGO';
  Result := firebird.Buscar(tabla, 'codigo', xcodigo);
end;

procedure  TTConceptoSueldo.getDatos(xcodigo: string);
// Objetivo...: Retornar/Iniciar Atributos
begin
  if Buscar(xcodigo) then Begin
    codigo      := tabla.FieldByName('codigo').AsString;
    concepto    := tabla.FieldByName('concepto').AsString;
    tipomov     := tabla.FieldByName('tipomov').AsString;
    porcentaje  := tabla.FieldByName('porcentaje').AsFloat;
  end else Begin
    codigo := ''; concepto := ''; tipomov := ''; porcentaje := 0;
  end;
end;

function TTConceptoSueldo.BuscarPorDescrip(xexpr: string): Boolean;
// Objetivo...: Buscar Médico por nombre
begin
  if tabla.IndexFieldNames <> 'CONCEPTO' then tabla.IndexFieldNames := 'CONCEPTO';
  firebird.BuscarContextualmente(tabla, 'concepto', xexpr);
end;

procedure TTConceptoSueldo.BuscarPorCodigo(xexpr: string);
begin
  if tabla.IndexFieldNames <> 'CODIGO' then tabla.IndexFieldNames := 'CODIGO';
  firebird.BuscarContextualmente(tabla, 'codigo', xexpr);
end;

procedure TTConceptoSueldo.conectar;
// Objetivo...: Abrir tablas de persistencia
begin
  if conexiones = 0 then Begin
    if not tabla.Active then tabla.Open;
  end;
  //tabla.FieldByName('CODIGO').DisplayLabel := 'Cód.'; tabla.FieldByName('concepto').DisplayLabel := 'Concepto';
  //tabla.FieldByName('tipomov').DisplayLabel := 'T.Mov.'; tabla.FieldByName('porcentaje').DisplayLabel := 'Porcentaje';
  Inc(conexiones);
end;

procedure TTConceptoSueldo.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones > 0 then Dec(conexiones);
  if conexiones = 0 then firebird.closeDB(tabla);
end;

{===============================================================================}

function conceptoliq: TTConceptoSueldo;
begin
  if xconceptoliq = nil then
    xconceptoliq := TTConceptoSueldo.Create;
  Result := xconceptoliq;
end;

{===============================================================================}

initialization

finalization
  xconceptoliq.Free;

end.
