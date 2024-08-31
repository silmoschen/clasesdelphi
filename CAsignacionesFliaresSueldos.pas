unit CAsignacionesFliaresSueldos;

interface

uses SysUtils, DB, DBTables, CUtiles, CListar, CFirebird, CUtilidadesArchivos,
     IBDatabase, IBCustomDataSet, IBTable, Variants, CBDT;

type

TTAsignaciones = class(TObject)
  Items, Periodo: string; Desde, Hasta, Monto: Real;
  tabla: TIBTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  function    Nuevo(xperiodo: String): string;
  procedure   Grabar(xperiodo, xitems: string; xdesde, xhasta, xmonto: Real);
  procedure   Borrar(xperiodo, xitems: string);
  function    Buscar(xperiodo, xitems: string): boolean;
  procedure   getDatos(xperiodo, xitems: string);

  function    setMonto(xmonto: Real): Real;

  procedure   conectar;
  procedure   desconectar;
 private
  conexiones: shortint;
  { Declaraciones Privadas }
end;

function asignaciones: TTAsignaciones;

implementation

var
  xasignaciones: TTAsignaciones = nil;

constructor TTAsignaciones.Create;
begin
  inherited Create;
  firebird.getModulo('sueldos');
  firebird.Conectar(firebird.Host + '\arch\arch.gdb', firebird.Usuario, firebird.Password);
  tabla := firebird.InstanciarTabla('montohijo');
end;

destructor TTAsignaciones.Destroy;
begin
  inherited Destroy;
end;

function TTAsignaciones.Nuevo(xperiodo: String): string;
// Objetivo...: Generar un nuevo ID
begin
  tabla.IndexFieldNames := 'PERIODO;ITEMS';
  firebird.Filtrar(tabla, 'PERIODO = ' + '''' + xperiodo + '''');
  if tabla.RecordCount = 0 then Result := '1' else Begin
    tabla.Last;
    Result := IntToStr(StrToInt(tabla.FieldByName('items').AsString) + 1);
  end;

  firebird.QuitarFiltro(tabla);
end;

procedure TTAsignaciones.Grabar(xperiodo, xitems: string; xdesde, xhasta, xmonto: Real);
// Objetivo...: Grabar Atributos del Objeto
begin
  if Buscar(xperiodo, xitems) then tabla.Edit else tabla.Append;
  tabla.FieldByName('periodo').AsString := xperiodo;
  tabla.FieldByName('items').AsString   := xitems;
  tabla.FieldByName('desde').AsFloat    := xdesde;
  tabla.FieldByName('hasta').AsFloat    := xhasta;
  tabla.FieldByName('monto').AsFloat    := xmonto;
  try
    tabla.Post;
   except
    tabla.Cancel
  end;
  firebird.RegistrarTransaccion(tabla);
end;

procedure TTAsignaciones.Borrar(xperiodo, xitems: string);
// Objetivo...: Eliminar un Objeto
begin
  if Buscar(xperiodo, xitems) then Begin
    tabla.Delete;
    getDatos(tabla.FieldByName('periodo').AsString, tabla.FieldByName('items').AsString);  // Fijamos los Atributos Siguientes al Objeto Borrado
    firebird.RegistrarTransaccion(tabla);
  end;
end;

function TTAsignaciones.Buscar(xperiodo, xitems: string): boolean;
// Objetivo...: Buscar el Objeto solicitado
begin
  if tabla.IndexFieldNames <> 'PERIODO;ITEMS' then tabla.IndexFieldNames := 'PERIODO;ITEMS';
  Result := firebird.Buscar(tabla, 'PERIODO;ITEMS', xperiodo, xitems);
end;

procedure  TTAsignaciones.getDatos(xperiodo, xitems: string);
// Objetivo...: Retornar/Iniciar Atributos
begin
  if Buscar(xperiodo, xitems) then Begin
    Periodo := tabla.FieldByName('PERIODO').AsString;
    Items   := tabla.FieldByName('ITEMS').AsString;
    Desde   := tabla.FieldByName('DESDE').AsFloat;
    Hasta   := tabla.FieldByName('HASTA').AsFloat;
    Monto   := tabla.FieldByName('MONTO').AsFloat;
  end else Begin
    desde := 0; hasta := 0; monto := 0; Periodo := '';
  end;
end;

function  TTAsignaciones.setMonto(xmonto: Real): Real;
// Objetivo...: Retornar Monto Asignaciones Familiares
Begin
  Result := 0;
  if not tabla.Active then tabla.Open;
  tabla.First;
  while not tabla.Eof do Begin
    if (xmonto >= tabla.FieldByName('desde').AsFloat) and (xmonto <= tabla.FieldByName('hasta').AsFloat) then Begin
      Result := tabla.FieldByName('monto').AsFloat;
      Break;
    end;
    tabla.Next;
  end;
end;

procedure TTAsignaciones.conectar;
// Objetivo...: Abrir tablas de persistencia
begin
  if conexiones = 0 then Begin
    if not tabla.Active then tabla.Open;
  end;
  tabla.FieldByName('PERIODO').DisplayLabel := 'Período'; tabla.FieldByName('ITEMS').DisplayLabel := 'Items'; tabla.FieldByName('DESDE').DisplayLabel := 'Desde';
  tabla.FieldByName('HASTA').DisplayLabel := 'Hasta'; tabla.FieldByName('MONTO').DisplayLabel := 'Monto';
  Inc(conexiones);
end;

procedure TTAsignaciones.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones > 0 then Dec(conexiones);
  if conexiones = 0 then firebird.closeDB(tabla);
end;

{===============================================================================}

function asignaciones: TTAsignaciones;
begin
  if xasignaciones = nil then
    xasignaciones := TTAsignaciones.Create;
  Result := xasignaciones;
end;

{===============================================================================}

initialization

finalization
  xasignaciones.Free;

end.
