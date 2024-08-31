unit CAntiguedadSueldos;

interface

uses SysUtils, DB, DBTables, CUtiles, CListar, CFirebird,
     IBDatabase, IBCustomDataSet, IBTable, Variants, Classes;

type

TTjubilacionSueldos = class(TObject)
  Periodo: string; AFJP, Reparto: Real;
  tabla: TIBTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  procedure   Grabar(xperiodo: string; xafjp, xreparto: Real);
  procedure   Borrar(xperiodo: string);
  function    Buscar(xperiodo: string): boolean;
  procedure   getDatos(xperiodo: string);
  function    setPorcentajes: TStringList;
  function    setPorcentajeAFJP(xperiodo: String): Real;
  function    setPorcentajeReparto(xperiodo: String): Real;

  procedure   conectar;
  procedure   desconectar;
 private
  conexiones: shortint;
  { Declaraciones Privadas }
end;

function jubilacionsueldo: TTjubilacionsueldos;

implementation

var
  xjubilacionsueldo: TTjubilacionsueldos = nil;

constructor TTjubilacionsueldos.Create;
begin
  inherited Create;
  firebird.getModulo('sueldos');
  firebird.Conectar(firebird.Host + '\arch\arch.gdb', firebird.Usuario, firebird.Password);
  tabla := firebird.InstanciarTabla('jubilaciones');
end;

destructor TTjubilacionsueldos.Destroy;
begin
  inherited Destroy;
end;

procedure TTjubilacionsueldos.Grabar(xperiodo: string; xafjp, xreparto: Real);
// Objetivo...: Grabar Atributos del Objeto
begin
  if Buscar(xperiodo) then tabla.Edit else tabla.Append;
  tabla.FieldByName('PERIODO').AsString := xperiodo;
  tabla.FieldByName('AFJP').AsFloat     := xafjp;
  tabla.FieldByName('REPARTO').AsFloat  := xreparto;
  try
    tabla.Post;
   except
    tabla.Cancel
  end;
  firebird.RegistrarTransaccion(tabla);
end;

procedure TTjubilacionsueldos.Borrar(xperiodo: string);
// Objetivo...: Eliminar un Objeto
begin
  if Buscar(xperiodo) then Begin
    tabla.Delete;
    getDatos(tabla.FieldByName('periodo').AsString);  // Fijamos los Atributos Siguientes al Objeto Borrado
    firebird.RegistrarTransaccion(tabla);
  end;
end;

function TTjubilacionsueldos.Buscar(xperiodo: string): boolean;
// Objetivo...: Buscar el Objeto solicitado
begin
  if tabla.IndexFieldNames <> 'PERIODO' then tabla.IndexFieldNames := 'PERIODO';
  Result := firebird.Buscar(tabla, 'PERIODO', xperiodo);
end;

procedure  TTjubilacionsueldos.getDatos(xperiodo: string);
// Objetivo...: Retornar/Iniciar Atributos
begin
  if Buscar(xperiodo) then Begin
    periodo := tabla.FieldByName('periodo').AsString;
    afjp    := tabla.FieldByName('afjp').AsFloat;
    reparto := tabla.FieldByName('reparto').AsFloat;
  end else Begin
    periodo := ''; afjp := 0; reparto := 0;
  end;
end;

function TTjubilacionsueldos.setPorcentajes: TStringList;
// Objetivo...: Cargar una lista con porcentajes
var
  l1, l2: TStringList;
  i: Integer;
Begin
  l1 := TStringList.Create;
  l2 := TStringList.Create;

  tabla.First;
  while not tabla.Eof do Begin
    l1.Add(Copy(tabla.FieldByName('periodo').AsString, 4, 4) + Copy(tabla.FieldByName('periodo').AsString, 1, 2) + utiles.FormatearNumero(tabla.FieldByName('afjp').AsString) + ';1' + utiles.FormatearNumero(tabla.FieldByName('reparto').AsString));
    tabla.Next;
  end;

  l1.Sort;
  For i := 1 to l1.Count do
    l2.Add(Copy(l1.Strings[i-1], 5, 2) + '/' + Copy(l1.Strings[i-1], 1, 4) + Copy(l1.Strings[i-1], 7, 100));

  Result := l2;
end;

function TTjubilacionsueldos.setPorcentajeAFJP(xperiodo: String): Real;
Begin
  Result := 0;

  tabla.First;
  while not tabla.Eof do Begin
    Result := (tabla.FieldByName('afjp').AsFloat) * 0.01;
    if (Copy(tabla.FieldByName('periodo').AsString, 4, 4) + Copy(tabla.FieldByName('periodo').AsString, 1, 2)) >= (Copy(xperiodo, 4, 4) + Copy(xperiodo, 1, 2)) then Break;
    tabla.Next;
  end;
end;

function TTjubilacionsueldos.setPorcentajeReparto(xperiodo: String): Real;
Begin
  Result := 0;
  if not tabla.Active then tabla.Open;
  tabla.First;
  while not tabla.Eof do Begin
    Result := (tabla.FieldByName('reparto').AsFloat) * 0.01;
    if (Copy(tabla.FieldByName('periodo').AsString, 4, 4) + Copy(tabla.FieldByName('periodo').AsString, 1, 2)) >= (Copy(xperiodo, 4, 4) + Copy(xperiodo, 1, 2)) then Break;
    tabla.Next;
  end;
end;

procedure TTjubilacionsueldos.conectar;
// Objetivo...: Abrir tablas de persistencia
begin
  if conexiones = 0 then Begin
    if not tabla.Active then tabla.Open;
  end;
  Inc(conexiones);
end;

procedure TTjubilacionsueldos.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones > 0 then Dec(conexiones);
  if conexiones = 0 then firebird.closeDB(tabla);
end;

{===============================================================================}

function jubilacionsueldo: TTjubilacionsueldos;
begin
  if xjubilacionsueldo = nil then
    xjubilacionsueldo := TTjubilacionsueldos.Create;
  Result := xjubilacionsueldo;
end;

{===============================================================================}

initialization

finalization
  xjubilacionsueldo.Free;

end.
