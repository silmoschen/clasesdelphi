unit CRegGastos_CCSR;

interface

uses CLotes_CCSRural, CBDT, SysUtils, DBTables, CUtiles, CListar, CIDBFM, Classes, ToolWin;

type

TTRegistracionGastos = class
   Periodo, Idpropiet, Idgasto, Items, Fecha, Comprobante, Concepto, FormatoImpresion, Fuente, Nroliq: String;
   Importe: Real;
   Tamanio: Integer;
   registro, formatosImpr: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  function    Buscar(xperiodo, xidpropiet, xidgasto, xitems, xnroliq: String): Boolean;
  procedure   Registar(xperiodo, xidpropiet, xidgasto, xitems, xnroliq, xfecha, xcomprob, xconcepto: String; ximporte: Real; xcantitems: Integer; mfijo: string); overload;
  procedure   RegistarMF(xperiodo, xidpropiet, xidgasto, xitems, xnroliq, xfecha, xcomprob, xconcepto: String; ximporte: Real); overload;
  procedure   BorrarItems(xperiodo, xidpropiet, xidgasto, xitems, xnroliq: String);
  function    setItems(xperiodo, xidpropiet, xidgasto, xnroliq: String): TQuery; overload;
  function    setItems(xperiodo, xidpropiet, xnroliq: String): TQuery; overload;
  function    setItems(xperiodo, xnroliq: String): TQuery; overload;

  procedure   GuardarFormatoImpresion(xid, xFormato, xFuente: String; xtamanio: Integer);
  procedure   getFormatoImpresion(xid: String);

  function    VerificarSiElItemsTieneMovimientos(xidgasto: String): Boolean;

  procedure   Depurar(xperiodo: String);

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  conexiones: shortint;
  procedure AjustarNumeroDeItems(xperiodo, xidpropiet, xidgasto, xnroliq: String; xcantitems: Integer);
end;

function reggastos: TTRegistracionGastos;

implementation

var
  xreggastos: TTRegistracionGastos = nil;

constructor TTRegistracionGastos.Create;
begin
  formatosImpr := datosdb.openDB('titinf', '');
end;

destructor TTRegistracionGastos.Destroy;
begin
  inherited Destroy;
end;

function TTRegistracionGastos.Buscar(xperiodo, xidpropiet, xidgasto, xitems, xnroliq: String): Boolean;
// Objetivo...: Verificar la existencia de una instancia
Begin
  Result := datosdb.Buscar(registro, 'Periodo', 'Idpropiet', 'Idgasto', 'Items', 'Nroliq', xperiodo, xidpropiet, xidgasto, xitems, xnroliq);
end;

procedure TTRegistracionGastos.Registar(xperiodo, xidpropiet, xidgasto, xitems, xnroliq, xfecha, xcomprob, xconcepto: String; ximporte: Real; xcantitems: Integer; mfijo: string);
// Objetivo...: Registrar una operación
Begin
  if Buscar(xperiodo, xidpropiet, xidgasto, xitems, xnroliq) then registro.Edit else registro.Append;
  registro.FieldByName('periodo').AsString   := xperiodo;
  registro.FieldByName('idpropiet').AsString := xidpropiet;
  registro.FieldByName('idgasto').AsString   := xidgasto;
  registro.FieldByName('items').AsString     := xitems;
  registro.FieldByName('nroliq').AsString    := xnroliq;
  registro.FieldByName('fecha').AsString     := utiles.sExprFecha2000(xfecha);
  registro.FieldByName('comprob').AsString   := xcomprob;
  registro.FieldByName('concepto').AsString  := xconcepto;
  registro.FieldByName('importe').AsFloat    := ximporte;
  registro.FieldByName('mfijo').AsString     := mfijo;
  try
    registro.Post
   except
    registro.Cancel
  end;
  AjustarNumeroDeItems(xperiodo, xidpropiet, xidgasto, xnroliq, xcantitems);
  datosdb.refrescar(registro);
end;

procedure TTRegistracionGastos.RegistarMF(xperiodo, xidpropiet, xidgasto, xitems, xnroliq, xfecha, xcomprob, xconcepto: String; ximporte: Real);
// Objetivo...: Registrar una operación
Begin
  if Buscar(xperiodo, xidpropiet, xidgasto, xitems, xnroliq) then registro.Edit else registro.Append;
  registro.FieldByName('periodo').AsString   := xperiodo;
  registro.FieldByName('idpropiet').AsString := xidpropiet;
  registro.FieldByName('idgasto').AsString   := xidgasto;
  registro.FieldByName('items').AsString     := xitems;
  registro.FieldByName('nroliq').AsString    := xnroliq;
  registro.FieldByName('fecha').AsString     := utiles.sExprFecha2000(xfecha);
  registro.FieldByName('comprob').AsString   := xcomprob;
  registro.FieldByName('concepto').AsString  := xconcepto;
  registro.FieldByName('importe').AsFloat    := ximporte;
  registro.FieldByName('mfijo').AsString     := '';
  try
    registro.Post
   except
    registro.Cancel
  end;
  datosdb.refrescar(registro);
end;

procedure TTRegistracionGastos.BorrarItems(xperiodo, xidpropiet, xidgasto, xitems, xnroliq: String);
// Objetivo...: Borrar Items
Begin
  if Buscar(xperiodo, xidpropiet, xidgasto, xitems, xnroliq) then registro.Delete;
end;

function TTRegistracionGastos.setItems(xperiodo, xidpropiet, xidgasto, xnroliq: String): TQuery;
// Objetivo...: Devolver un set de aplicaciones
Begin
  Result := datosdb.tranSQL('SELECT * FROM ' + registro.TableName + ' WHERE periodo = ' + '''' + xperiodo + '''' + ' AND idpropiet = ' + '''' + xidpropiet + '''' + ' AND idgasto = ' + '''' + xidgasto + '''' + ' AND nroliq = ' + '''' + xnroliq + '''' + ' ORDER BY fecha');
end;

function TTRegistracionGastos.setItems(xperiodo, xidpropiet, xnroliq: String): TQuery;
// Objetivo...: Devolver un set de aplicaciones
Begin
  Result := datosdb.tranSQL('SELECT * FROM ' + registro.TableName + ' WHERE periodo = ' + '''' + xperiodo + '''' + ' AND idpropiet = ' + '''' + xidpropiet + '''' + ' AND nroliq = ' + '''' + xnroliq + '''' + ' ORDER BY idgasto, fecha');
end;

function TTRegistracionGastos.setItems(xperiodo, xnroliq: String): TQuery;
// Objetivo...: Devolver un set de aplicaciones
var
  f1, f2: String;
Begin
  f1 := utiles.sExprFecha2000('01/' + Copy(xperiodo, 1, 2) + '/' + Copy(xperiodo, 6, 2));
  f2 := utiles.sExprFecha2000(utiles.ultimodiames(Copy(xperiodo, 1, 2), Copy(xperiodo, 4, 4)) + '/'  + Copy(xperiodo, 1, 2) + '/' + Copy(xperiodo, 6, 2));
  Result := datosdb.tranSQL('SELECT * FROM ' + registro.TableName + ' WHERE periodo = ' + '"' + xperiodo + '"' + ' and fecha >= ' + '"' + f1 + '"' + ' and fecha <= ' + '"' + f2 + '"' + ' AND nroliq = ' + '''' + xnroliq + '''' + ' ORDER BY idgasto, fecha');
end;

procedure TTRegistracionGastos.AjustarNumeroDeItems(xperiodo, xidpropiet, xidgasto, xnroliq: String; xcantitems: Integer);
// Objetivo...: Ajustar el nro. de items
Begin
  datosdb.tranSQL('DELETE FROM ' + registro.TableName + ' WHERE periodo = ' + '''' + xperiodo + '''' + ' AND idpropiet = ' + '''' + xidpropiet + '''' + ' AND idgasto = ' + '''' + xidgasto + '''' + ' AND items > ' + '''' + utiles.sLlenarIzquierda(IntToStr(xcantitems), 3, '0') + '''' + ' AND items < ' + '''' + '500' + '''' + ' AND nroliq = ' + '''' + xnroliq + '''');
end;

procedure TTRegistracionGastos.GuardarFormatoImpresion(xid, xFormato, xFuente: String; xtamanio: Integer);
// Objetivo...: Guardar Formatos de Impresión
Begin
  if formatosimpr.FindKey([xid]) then formatosimpr.Edit else formatosimpr.Append;
  formatosimpr.FieldByName('id').AsString       := xid;
  formatosimpr.FieldByName('modelo').AsString   := xformato;
  formatosimpr.FieldByName('fuente').AsString   := xfuente;
  formatosimpr.FieldByName('tamanio').AsInteger := xtamanio;
  try
    formatosimpr.Post
   except
    formatosimpr.Cancel
  end;
  datosdb.refrescar(formatosimpr);
end;

procedure TTRegistracionGastos.getFormatoImpresion(xid: String);
// Objetivo...: Cargar Formato de Impresión
Begin
  if formatosimpr.FindKey([xid]) then Begin
    FormatoImpresion := formatosimpr.FieldByName('modelo').AsString;
    Tamanio          := formatosimpr.FieldByName('tamanio').AsInteger;
    Fuente           := formatosimpr.FieldByName('fuente').AsString;
  end else Begin
    FormatoImpresion := '';  Tamanio := 500; Fuente := 'Arial, normal, 9';
  end;
end;

function TTRegistracionGastos.VerificarSiElItemsTieneMovimientos(xidgasto: String): Boolean;
// Objetivo...: Verificar si el Items tiene Movimientos
var
  r: TQuery;
Begin
  r := datosdb.tranSQL('SELECT * FROM ' + registro.TableName + ' WHERE idgasto = ' + '"' + xidgasto + '"');
  r.Open;
  if r.RecordCount > 0 then Result := True else Result := False;
  r.Close; r.Free;
end;

procedure TTRegistracionGastos.Depurar(xperiodo: String);
// Objetivo...: Borrar Operaciones
Begin
  datosdb.tranSQL('DELETE FROM ' + registro.TableName + ' WHERE periodo = ' + '''' + xperiodo + '''');
end;

procedure TTRegistracionGastos.conectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones = 0 then Begin
    if not registro.Active then registro.Open;
    if not formatosimpr.Active then formatosimpr.Open;
  end;
  Inc(conexiones);
  lote.conectar;
end;

procedure TTRegistracionGastos.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  Dec(conexiones);
  if conexiones = 0 then Begin
    datosdb.closeDB(registro);
    datosdb.closeDB(formatosimpr);
  end;
  lote.desconectar;
end;

{===============================================================================}

function reggastos: TTRegistracionGastos;
begin
  if xreggastos = nil then
    xreggastos := TTRegistracionGastos.Create;
  Result := xreggastos;
end;

{===============================================================================}

initialization

finalization
  xreggastos.Free;

end.
