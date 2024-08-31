unit CConceptoSueldo;

interface

uses SysUtils, DB, DBTables, CUtiles, CListar, CFirebird, CUtilidadesArchivos,
     IBDatabase, IBCustomDataSet, IBTable, Variants, CBDT, Classes;

type

TTConceptoSueldo = class(TObject)
  Codigo, Concepto, Tipomov, Formula, Tipocarga, Perdesde, Perhasta, Nroliq: string; Porcentaje, MontoFijo: Real; Aplicable: ShortInt;
  tabla: TIBTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  function    Nuevo: string;
  procedure   Grabar(xcodigo, xconcepto, xtipomov, xformula, xtipocarga, xperdesde, xperhasta, xnroliq: string; xporcentaje, xmontofijo: Real; xaplicable: ShortInt);
  procedure   Borrar(xcodigo: string);
  function    Buscar(xcodigo: string): boolean;
  procedure   getDatos(xcodigo: string);
  function    BuscarPorDescrip(xexpr: string): Boolean;
  procedure   BuscarPorCodigo(xexpr: string);
  function    setConceptos: TStringList;
  function    setMontoFijo(xperiodo, xnroliq, xcodigo: String): Real;

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

procedure TTConceptoSueldo.Grabar(xcodigo, xconcepto, xtipomov, xformula, xtipocarga, xperdesde, xperhasta, xnroliq: string; xporcentaje, xmontofijo: Real; xaplicable: ShortInt);
// Objetivo...: Grabar Atributos del Objeto
begin
  if Buscar(xcodigo) then tabla.Edit else tabla.Append;
  tabla.FieldByName('codigo').AsString      := xcodigo;
  tabla.FieldByName('concepto').AsString    := xconcepto;
  tabla.FieldByName('tipomov').AsString     := xtipomov;
  tabla.FieldByName('formula').AsString     := xformula;
  tabla.FieldByName('tipocarga').AsString   := xtipocarga;
  tabla.FieldByName('porcentaje').AsFloat   := xporcentaje;
  tabla.FieldByName('montofijo').AsFloat    := xmontofijo;
  tabla.FieldByName('aplicable').AsInteger  := xaplicable;
  tabla.FieldByName('perdesde').AsString    := xperdesde;
  tabla.FieldByName('perhasta').AsString    := xperhasta;
  tabla.FieldByName('nroliq').AsString      := xnroliq;
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
    formula     := tabla.FieldByName('formula').AsString;
    tipocarga   := tabla.FieldByName('tipocarga').AsString;
    tipomov     := tabla.FieldByName('tipomov').AsString;
    porcentaje  := tabla.FieldByName('porcentaje').AsFloat;
    montofijo   := tabla.FieldByName('montofijo').AsFloat;
    Aplicable   := tabla.FieldByName('aplicable').AsInteger;
    perdesde    := tabla.FieldByName('perdesde').AsString;
    perhasta    := tabla.FieldByName('perhasta').AsString;
    nroliq      := tabla.FieldByName('nroliq').AsString;
  end else Begin
    codigo := ''; concepto := ''; tipomov := ''; porcentaje := 0; Aplicable := 0; montofijo := 0; tipocarga := '';
    perdesde := ''; perhasta := ''; nroliq := '';
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

function  TTConceptoSueldo.setConceptos: TStringList;
var
  l: TStringList;
Begin
  l := TStringList.Create;
  if not tabla.Active then tabla.Open;
  if tabla.IndexFieldNames <> 'CODIGO' then tabla.IndexFieldNames := 'CODIGO';
  tabla.First;
  while not tabla.Eof do Begin
    l.Add(tabla.FieldByName('codigo').AsString + tabla.FieldByName('tipomov').AsString + tabla.FieldByName('concepto').AsString + ';1' + utiles.FormatearNumero(tabla.FieldByName('porcentaje').AsString) + ';2' + tabla.FieldByName('formula').AsString);
    tabla.Next;
  end;
  Result := l;
end;

function  TTConceptoSueldo.setMontoFijo(xperiodo, xnroliq, xcodigo: String): Real;
// Objetivo...: Recuperar Monto Fijo
Begin
  Result := 0;
  if Buscar(xcodigo) then Begin
    if ((Copy(tabla.FieldByName('perdesde').AsString, 4, 4) + Copy(tabla.FieldByName('perdesde').AsString, 1, 2)) >= (Copy(xperiodo, 4, 4) + Copy(xperiodo, 1, 2))) and
       ((Copy(tabla.FieldByName('perhasta').AsString, 4, 4) + Copy(tabla.FieldByName('perhasta').AsString, 1, 2)) <= (Copy(xperiodo, 4, 4) + Copy(xperiodo, 1, 2))) and
       (tabla.FieldByName('nroliq').AsString = xnroliq) then Begin
         Result := tabla.FieldByName('montofijo').AsFloat;
    end;
    if (Length(Trim(tabla.FieldByName('perdesde').AsString)) < 7) and (Length(Trim(tabla.FieldByName('perhasta').AsString)) < 7) and (tabla.FieldByName('nroliq').AsString = xnroliq) then Begin
      Result := tabla.FieldByName('montofijo').AsFloat;
    end;
  end;
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
