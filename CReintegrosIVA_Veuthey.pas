unit CReintegrosIVA_Veuthey;

interface

uses CIvaVenta_Veuthey, CBDT, SysUtils, DBTables, CUtiles, CListar, CIDBFM, Classes, CEmpresas, CUtilidadesArchivos;

type

TTLiquidacionesIVA = class
  Fecha, Comprobante, NoReintegra: String;
  Monto, Porcentaje: Real;
  ExisteReintegro: Boolean;
  comprobantes, tabla: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  { Afectar Comprobantes Sujetos a Reintegros }
  procedure   RegistrarComprobantesAfectados(xitems, xidcompr, xcodigo: String; xcantitems: Integer);
  function    setComprobantesAfectados: TStringList;

  function    Buscar(xidc, xtipo, xsucursal, xnumero, xclipro: String): Boolean;
  procedure   Registrar(xidc, xtipo, xsucursal, xnumero, xclipro, xfecha, xcpago: String; xmonto, xporcentaje: Real);
  procedure   getDatos(xidc, xtipo, xsucursal, xnumero, xclipro: String);
  procedure   Borrar(xidc, xtipo, xsucursal, xnumero, xclipro: String);
  function    setMonto(xidc, xtipo, xsucursal, xnumero, xclipro: String): Real;
  procedure   MarcarComoNoReintegrable(xidc, xtipo, xsucursal, xnumero, xclipro, xreintegro: String);

  procedure   ListarReintegros(xdesde, xhasta, xtipofecha: String; salida: char);
  function    setMontoReintegros(xperiodo, xvia: String): TStringList;

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  conexiones: shortint;
  directorio: String;
  totales: array[1..5] of Real;
  procedure IniciarArreglos;
end;

function reintegros: TTLiquidacionesIVA;

implementation

var
  xreintegros: TTLiquidacionesIVA = nil;

constructor TTLiquidacionesIVA.Create;
begin
  comprobantes := datosdb.openDB('comprobantes_ret', '');
end;

destructor TTLiquidacionesIVA.Destroy;
begin
  inherited Destroy;
end;

function  TTLiquidacionesIVA.Buscar(xidc, xtipo, xsucursal, xnumero, xclipro: String): Boolean;
Begin
  tabla.IndexFieldNames := 'idcompr;tipo;sucursal;numero;clipro';
  ExisteReintegro := datosdb.Buscar(tabla, 'idcompr', 'tipo', 'sucursal', 'numero', 'clipro', xidc, xtipo, xsucursal, xnumero, xclipro);
  Result := ExisteReintegro;
end;

procedure TTLiquidacionesIVA.Registrar(xidc, xtipo, xsucursal, xnumero, xclipro, xfecha, xcpago: String; xmonto, xporcentaje: Real);
Begin
  if Buscar(xidc, xtipo, xsucursal, xnumero, xclipro) then tabla.Edit else tabla.Append;
  tabla.FieldByName('idcompr').AsString     := xidc;
  tabla.FieldByName('tipo').AsString        := xtipo;
  tabla.FieldByName('sucursal').AsString    := xsucursal;
  tabla.FieldByName('numero').AsString      := xnumero;
  tabla.FieldByName('clipro').AsString      := xclipro;
  tabla.FieldByName('cpago').AsString       := xcpago;
  if Length(Trim(xfecha)) = 8 then  tabla.FieldByName('fecha').AsString := utiles.sExprFecha2000(xfecha) else tabla.FieldByName('fecha').AsString := '';
  tabla.FieldByName('monto').AsFloat        := xmonto;
  tabla.FieldByName('porcentaje').AsFloat   := xporcentaje;
  try
    tabla.Post
   except
    tabla.Cancel
  end;
  datosdb.refrescar(tabla);
end;

procedure TTLiquidacionesIVA.MarcarComoNoReintegrable(xidc, xtipo, xsucursal, xnumero, xclipro, xreintegro: String);
Begin
  if Buscar(xidc, xtipo, xsucursal, xnumero, xclipro) then Begin
    tabla.Edit;
    tabla.FieldByName('noreintegra').AsString := xreintegro;
    try
      tabla.Post
     except
      tabla.Cancel
    end;
  end;
end;

procedure TTLiquidacionesIVA.getDatos(xidc, xtipo, xsucursal, xnumero, xclipro: String);
// Objetivo...: Cargar un movimiento
Begin
  if Buscar(xidc, xtipo, xsucursal, xnumero, xclipro) then Begin
    if Length(Trim(tabla.FieldByName('fecha').AsString)) > 0 then Fecha := utiles.sFormatoFecha(tabla.FieldByName('fecha').AsString) else Fecha := '';
    Comprobante := tabla.FieldByName('cpago').AsString;
    Monto       := tabla.FieldByName('monto').AsFloat;
    Porcentaje  := tabla.FieldByName('porcentaje').AsFloat;
    NoReintegra := tabla.FieldByName('noreintegra').AsString;
  end else Begin
    Fecha := ''; Comprobante := ''; Monto := 0; Porcentaje := 0; NoReintegra := '';
  end;
end;

procedure TTLiquidacionesIVA.Borrar(xidc, xtipo, xsucursal, xnumero, xclipro: String);
// Objetivo...: Borrar un movimiento
Begin
  if Buscar(xidc, xtipo, xsucursal, xnumero, xclipro) then tabla.Delete;
  datosdb.refrescar(tabla);
end;

function TTLiquidacionesIVA.setMonto(xidc, xtipo, xsucursal, xnumero, xclipro: String): Real;
// Objetivo...: devolver monto
Begin
  if Buscar(xidc, xtipo, xsucursal, xnumero, xclipro) then Begin
    Result      := tabla.FieldByName('monto').AsFloat;
    Fecha       := utiles.sFormatoFecha(tabla.FieldByName('fecha').AsString);
    NoReintegra := tabla.FieldByName('noreintegra').AsString;
    Porcentaje  := tabla.FieldByName('porcentaje').AsFloat;
  end else Begin
    Result := 0;
    Fecha  := ''; Porcentaje := 0; NoReintegra := '';
  end;
end;

procedure TTLiquidacionesIVA.RegistrarComprobantesAfectados(xitems, xidcompr, xcodigo: String; xcantitems: Integer);
// Objetivo...: Definir los comprobantes afectados por retenciones
Begin
  if comprobantes.FindKey([xitems]) then comprobantes.Edit else comprobantes.Append;
  comprobantes.FieldByName('items').AsString   := xitems;
  comprobantes.FieldByName('idcompr').AsString := xidcompr;
  comprobantes.FieldByName('codigo').AsString  := xcodigo;
  try
    comprobantes.Post
   except
    comprobantes.Cancel
  end;
  if xitems = utiles.sLlenarIzquierda(IntToStr(xcantitems), 2, '0') then datosdb.tranSQL('delete from comprobantes_ret where items > ' + '"' + xitems + '"');
  if xitems = '00' then datosdb.tranSQL('delete from comprobantes_ret');
  datosdb.refrescar(comprobantes);
end;

function  TTLiquidacionesIVA.setComprobantesAfectados: TStringList;
// Objetivo...: Devolver una Lista con los Comprobantes Afectados
var
  l: TStringList;
Begin
  l := TStringList.Create;
  comprobantes.First;
  while not comprobantes.Eof do Begin
    l.Add(comprobantes.FieldByName('codigo').AsString + '-' + comprobantes.FieldByName('idcompr').AsString);
    comprobantes.Next;
  end;
  Result := l;
end;

procedure TTLiquidacionesIVA.IniciarArreglos;
var
  i: Integer;
Begin
  for i := 1 to 5 do totales[i] := 0;
end;

procedure TTLiquidacionesIVA.ListarReintegros(xdesde, xhasta, xtipofecha: String; salida: char);
// Objetivo...: Presentar Informe de Reintegros
var
  r: TQuery;
  reint, monto_reint: Real;
Begin
  list.ImprimirHorizontal;

  list.Titulo(0, 0, '', 1, 'Arial, normal, 16');
  list.Titulo(0, 0, empresa.nombre, 1, 'Arial, normal, 8');
  list.Titulo(0, 0, empresa.nrocuit, 1, 'Arial, normal, 8');
  list.Titulo(0, 0, '', 1, 'Arial, normal, 14');
  list.Titulo(0, 0, 'Reintegros A.F.I.P. - Período: ' + xdesde + '-' + xhasta, 1, 'Arial, negrita, 12');
  list.Titulo(0, 0, '', 1, 'Arial, normal, 5');
  list.Titulo(0, 0, 'Fecha', 1, 'Arial, cursiva, 8');
  list.Titulo(8, list.Lineactual, 'Comprobante', 2, 'Arial, cursiva, 8');
  list.Titulo(22, list.Lineactual, 'Nombre del Cliente', 3, 'Arial, cursiva, 8');
  list.Titulo(61, list.Lineactual, 'Neto', 4, 'Arial, cursiva, 8');
  list.Titulo(76, list.Lineactual, 'I.V.A.', 5, 'Arial, cursiva, 8');
  list.Titulo(87, list.Lineactual, 'Reintegro', 6, 'Arial, cursiva, 8');
  list.Titulo(98, list.Lineactual, 'F.Pago', 7, 'Arial, cursiva, 8');
  list.Titulo(112, list.Lineactual, 'Pago AFIP', 8, 'Arial, cursiva, 8');
  list.Titulo(127, list.Lineactual, 'Diferencia', 9, 'Arial, cursiva, 8');
  list.Titulo(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11');
  list.Titulo(0, 0, '', 1, 'Arial, normal, 11');

  IniciarArreglos;
  if xtipoFecha = 'R' then r := ivav.setIvaFechaRecepcion(utiles.sExprFecha2000(xdesde), utiles.sExprFecha2000(xhasta)) else r := ivav.setIva(utiles.sExprFecha2000(xdesde), utiles.sExprFecha2000(xhasta));
  r.Open;

  while not r.Eof do Begin
    reint := setMonto(r.FieldByName('idcompr').AsString, r.FieldByName('tipo').AsString, r.FieldByName('sucursal').AsString, r.FieldByName('numero').AsString, r.FieldByName('clipro').AsString);
    list.Linea(0, 0, utiles.sFormatoFecha(r.FieldByName('fecha').AsString), 1, 'Arial, normal, 8', salida, 'N');
    list.Linea(8, list.Lineactual, r.FieldByName('tipo').AsString + '  ' + r.FieldByName('sucursal').AsString + '-' + r.FieldByName('numero').AsString, 2, 'Arial, normal, 8', salida, 'N');
    list.Linea(22, list.Lineactual, r.FieldByName('rsocial').AsString, 3, 'Arial, normal, 8', salida, 'N');
    list.importe(65, list.Lineactual, '', r.FieldByName('nettot').AsFloat, 4, 'Arial, normal, 8');
    list.importe(80, list.Lineactual, '', r.FieldByName('iva').AsFloat, 5, 'Arial, normal, 8');
    if r.FieldByName('percep1').AsFloat <> 0 then monto_reint := (r.FieldByName('nettot').AsFloat * (porcentaje * 0.01)) else monto_reint := 0;
    list.importe(95, list.Lineactual, '', monto_reint, 6, 'Arial, normal, 8');
    list.Linea(98, list.Lineactual, Fecha, 7, 'Arial, normal, 8', salida, 'N');
    list.importe(120, list.Lineactual, '', Reint, 8, 'Arial, normal, 8');
    list.importe(135, list.Lineactual, '', monto_reint - reint, 9, 'Arial, normal, 8');
    if Length(Trim(reintegros.NoReintegra)) > 0 then list.Linea(136, list.Lineactual, '*', 10, 'Arial, normal, 8', salida, 'S') else list.Linea(136, list.Lineactual, '', 10, 'Arial, normal, 8', salida, 'S');
    totales[1] := totales[1] + r.FieldByName('nettot').AsFloat;
    totales[2] := totales[2] + r.FieldByName('iva').AsFloat;
    totales[3] := totales[3] + monto_reint;
    totales[4] := totales[4] + Reint;
    if Length(Trim(reintegros.NoReintegra)) = 0 then totales[5] := totales[5] + (monto_reint - reint);
    r.Next;
  end;

  r.Close; r.Free;

  list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
  list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
  list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
  list.Linea(0, 0, 'TOTAL GENERAL:', 1, 'Arial, negrita, 8', salida, 'S');
  list.importe(65, list.Lineactual, '', totales[1], 2, 'Arial, negrita, 8');
  list.importe(80, list.Lineactual, '', totales[2], 3, 'Arial, negrita, 8');
  list.importe(95, list.Lineactual, '', totales[3], 4, 'Arial, negrita, 8');
  list.importe(120, list.Lineactual, '', totales[4], 5, 'Arial, negrita, 8');
  list.importe(135, list.Lineactual, '', totales[5], 6, 'Arial, negrita, 8');
  list.Linea(136, list.Lineactual, '', 7, 'Arial, negrita, 8', salida, 'S');

  list.FinList;
  list.ImprimirVetical;
end;

function TTLiquidacionesIVA.setMontoReintegros(xperiodo, xvia: String): TStringList;
// Objetivo...: devolver el total de reintegros
var
  r: TQuery;
  l: TStringList;
  i: Integer;
  tot: array[1..12] of real;
Begin
  l := TStringList.Create;
  if FileExists(dbs.DirSistema + '\' + xvia + '\reintegrosafip.db') then Begin
    r := datosdb.tranSQL(dbs.DirSistema + '\' + xvia, 'select fecha, monto from reintegrosafip where fecha >= ' + '"' + xperiodo + '0101' + '"' + ' and fecha <= ' + '"' + xperiodo + '1231' + '"' + ' order by fecha');
    r.Open;
    while not r.Eof do Begin
      i := StrToInt(copy(r.FieldByName('fecha').AsString, 5, 2));
      tot[i]  := tot[i] + r.FieldByName('monto').AsFloat;
      r.Next;
    end;

    for i := 1 to 12 do l.Add(FloatToStr(tot[i]));

    r.Close; r.Free;

    Result := l;
  end else
    Result := Nil;
end;

procedure TTLiquidacionesIVA.conectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones = 0 then Begin
    if not comprobantes.Active then comprobantes.Open;
    if not FileExists(dbs.DirSistema + '\' + empresa.nomvia + '\reintegrosAFIP.db') then utilesarchivos.CopiarArchivos(dbs.DirSistema + '\estructu', 'reintegrosafip.*', dbs.DirSistema + '\' + empresa.nomvia);
    directorio := dbs.DirSistema + '\' + empresa.nomvia;
    tabla := datosdb.openDB('reintegrosafip', '', '', directorio);
    tabla.Open;
  end;
  Inc(conexiones);
end;

procedure TTLiquidacionesIVA.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  Dec(conexiones);
  if conexiones = 0 then Begin
    datosdb.closeDB(comprobantes);
    datosdb.closeDB(tabla);
  end;
end;

{===============================================================================}

function reintegros: TTLiquidacionesIVA;
begin
  if xreintegros = nil then
    xreintegros := TTLiquidacionesIVA.Create;
  Result := xreintegros;
end;

{===============================================================================}

initialization

finalization
  xreintegros.Free;

end.
