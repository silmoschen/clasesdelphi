unit CLDiaAuxiliar;

interface

uses CLDiario, CPlanctas, SysUtils, CListar, DB, DBTables, CBDT, CUtiles, CIDBFM, CPeriodo;

type

TTLDiarioAuxiliar = class(TTLDiario)
  idc, tipo, sucursal, numero, cuit, codreferen, descrip: string;
  existe_asiento: boolean;
  trefconex, refercompact: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  function    setItems(xperiodo, xnroasien, xclave: string): TQuery; overload;
  function    setItems(xperiodo, xmes: string): TQuery; overload;
  procedure   Grabar(xperiodo, xnroasien, xfecha, xcodcta, xnromovi, xconcepto, xdh, xclave, xcodres: string; ximporte: real); overload;
  function    setAsientosAuditoria(xfecha: string): TQuery; override;
  procedure   GrabarRef(xidc, xtipo, xsucursal, xnumero, xcuit, xnroasiento: string);
  procedure   BorrarRef(xidc, xtipo, xsucursal, xnumero, xcuit: string);
  procedure   getDatosRef(xidc, xtipo, xsucursal, xnumero, xcuit: string);
  function    setItemsCompactacion: TQuery;
  procedure   conectarRef;
  procedure   desconectarRef;

  function    BuscarRefCompactacion(xcodreferen: string): boolean;
  procedure   GrabarRefCompactacion(xcodreferen, xdescrip: string);
  procedure   getDatosRefCompactacion(xcodreferen: string);
  procedure   BorrarRefCompactacion(xcodreferen: string);

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  conexionesref, conexiones: shortint;
 protected
  { Declaraciones Protegidas }
end;

function ldiarioauxc: TTLDiarioAuxiliar;

implementation

var
  xldiarioauxc: TTLDiarioAuxiliar = nil;

constructor TTLDiarioAuxiliar.Create;
begin
  inherited Create;
  conexionesref := 0;
end;

destructor TTLDiarioAuxiliar.Destroy;
begin
  inherited Destroy;
end;

function TTLDiarioAuxiliar.setItems(xperiodo, xnroasien, xclave: string): TQuery;
// Objetivo...: devolver un set con los registros del asiento
begin
  Result := datosdb.tranSQL(path, 'SELECT * FROM ' + asientos.TableName + ' WHERE periodo = ' + '''' + xperiodo + '''' + ' AND nroasien = ' + '''' + xnroasien + '''' + ' AND clave = ' + '''' + xclave + '''');
end;

function  TTLDiarioAuxiliar.setItems(xperiodo, xmes: string): TQuery;
// Objetivo...: devolver un set con las operaciones del mes solicitado - tanto para compras como ventas
var
  ultdia: string;
begin
  ultdia := xperiodo + xmes + utiles.ultFechaMes(xmes, xperiodo);
  Result := datosdb.tranSQL(path, 'SELECT nroasien, fecha, codcta, dh, importe, concepto, codres FROM ' + asientos.TableName + ' WHERE fecha >= ' + '"' + xperiodo + xmes + '01' + '"' + ' AND fecha <= ' + '"' + ultdia + '"' + ' ORDER BY codres, dh');
end;

procedure  TTLDiarioAuxiliar.Grabar(xperiodo, xnroasien, xfecha, xcodcta, xnromovi, xconcepto, xdh, xclave, xcodres: string; ximporte: real);
// Objetivo...: Grabar atributos relacionados al movimiento de una cuenta - incluyendo clave de asientos generados automáticamente + cód. de asiento para resumen
begin
  inherited Grabar(xperiodo, xnroasien, xfecha, xcodcta, xnromovi, xconcepto, xdh, xclave, ximporte);
  asientos.Edit;
  asientos.FieldByName('codres').AsString := xcodres;
  try
    asientos.Post;
  except
    asientos.Cancel;
  end;
end;

procedure TTLDiarioAuxiliar.GrabarRef(xidc, xtipo, xsucursal, xnumero, xcuit, xnroasiento: string);
// Objetivo...: Persistir objetos
begin
  if datosdb.Buscar(trefconex, 'idc', 'tipo', 'sucursal', 'numero', 'cuit', xidc, xtipo, xsucursal, xnumero, xcuit) then trefconex.Edit else trefconex.Append;
  trefconex.FieldByName('idc').AsString      := xidc;
  trefconex.FieldByName('tipo').AsString     := xtipo;
  trefconex.FieldByName('sucursal').AsString := xsucursal;
  trefconex.FieldByName('numero').AsString   := xnumero;
  trefconex.FieldByName('cuit').AsString     := xcuit;
  trefconex.FieldByName('nroasien').AsString := xnroasiento;
  try
    trefconex.Post;
  except
    trefconex.Cancel;
  end;
end;

procedure TTLDiarioAuxiliar.BorrarRef(xidc, xtipo, xsucursal, xnumero, xcuit: string);
// Objetivo...: Persistir objetos
begin
  if datosdb.Buscar(trefconex, 'idc', 'tipo', 'sucursal', 'numero', 'cuit', xidc, xtipo, xsucursal, xnumero, xcuit) then trefconex.Delete;
end;

procedure TTLDiarioAuxiliar.getDatosRef(xidc, xtipo, xsucursal, xnumero, xcuit: string);
// Objetivo...: Persistir objetos
begin
  if datosdb.Buscar(trefconex, 'idc', 'tipo', 'sucursal', 'numero', 'cuit', xidc, xtipo, xsucursal, xnumero, xcuit) then Begin
    nroasien       := trefconex.FieldByName('nroasien').AsString;
    existe_asiento := True;
   end
  else Begin
    nroasien       := '';
    existe_asiento := False;
  end;
end;

//------------------------------------------------------------------------------
procedure   TTLDiarioAuxiliar.GrabarRefCompactacion(xcodreferen, xdescrip: string);
// Objetivo...: Persistir la referecnia de los códigos de compactación
begin
  if refercompact.FindKey([xcodreferen]) then refercompact.Edit else refercompact.Append;
  refercompact.FieldByName('codcompact').AsString := xcodreferen;
  refercompact.FieldByName('descrip').AsString    := xdescrip;
  try
    refercompact.Post
  except
    refercompact.Cancel
  end;
end;

function   TTLDiarioAuxiliar.BuscarRefCompactacion(xcodreferen: string): boolean;
// Objetivo...: Buscar una instancia de referencias
begin
  if refercompact.FindKey([xcodreferen]) then Result := True else Result := False;
end;

procedure   TTLDiarioAuxiliar.getDatosRefCompactacion(xcodreferen: string);
// Objetivo...: Cargar los atributos
begin
  if refercompact.FindKey([xcodreferen]) then descrip := refercompact.FieldByName('descrip').AsString else descrip := '';
end;

procedure   TTLDiarioAuxiliar.BorrarRefCompactacion(xcodreferen: string);
// Objetivo...: Borrar una instancia de referencias
begin
  if refercompact.FindKey([xcodreferen]) then Begin
    refercompact.Delete;
    getDatosRefCompactacion(refercompact.FieldByName('codcompact').AsString);
  end;
end;

function    TTLDiarioAuxiliar.setAsientosAuditoria(xfecha: string): TQuery;
// Objetivo...: devolver un set con los registros del asiento
begin
  Result := datosdb.tranSQL(path, 'SELECT * FROM ' + cabasien.TableName + ', '  + trefconex.TableName + ' WHERE ' + trefconex.TableName + '.nroasien = ' + cabasien.TableName + '.nroasien AND fecha = ' + '"' + xfecha + '"');
end;

function    TTLDiarioAuxiliar.setItemsCompactacion: TQuery;
// Objetivo...: devolver un set con los registros del asiento
begin
  Result := datosdb.tranSQL(path, 'SELECT * FROM ' + refercompact.TableName);
end;

procedure   TTLDiarioAuxiliar.conectarRef;
// Objetivo...: conectar tablas de persistencia
begin
  if conexionesref = 0 then
    if not refercompact.Active then refercompact.Open;
  Inc(conexionesref);
  // Tomamos el 1º código como referencia
  codreferen := refercompact.FieldByName('codcompact').AsString;
end;

procedure   TTLDiarioAuxiliar.desconectarRef;
// Objetivo...: desconectar tablas de persistencia
begin
  if conexionesref > 0 then Dec(conexionesref);
  if conexionesref = 0 then refercompact.Close;
  ///inherited desconectar;
end;

procedure   TTLDiarioAuxiliar.conectar;
// Objetivo...: conectar tablas de persistencia
begin
  conexionesref := 0;
  if conexiones = 0 then
    if not trefconex.Active then trefconex.Open;
  inherited conectar;
  conectarRef;
  Inc(conexiones);
end;

procedure   TTLDiarioAuxiliar.desconectar;
// Objetivo...: conectar tablas de persistencia
begin
  if conexiones > 0 then Dec(conexiones);
  if conexiones = 0 then
    if trefconex.Active then trefconex.Close;
  inherited desconectar;
  desconectarRef;
end;

{===============================================================================}

function ldiarioauxc: TTLDiarioAuxiliar;
begin
  if xldiarioauxc = nil then
    xldiarioauxc := TTLDiarioAuxiliar.Create;
  Result := xldiarioauxc;
end;

{===============================================================================}

initialization

finalization
  xldiarioauxc.Free;

end.