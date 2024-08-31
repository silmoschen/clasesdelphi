unit CTransferenciasBancariasPendientesCCE;

interface

uses CBDT, SysUtils, DBTables, CUtiles, CListar, CIDBFM, CTransferenciasCCE,
     CCuentasBancariasCCE, Classes, CBancos, Contnrs, CCProveedoresCCE, CClienteCCE;

type

TTransferenciasBancariasPendientes = class(TTransferencias)
  Estado, Transferido: String;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  procedure   getDatos(xidregistro: String);

  procedure   Listar(xcuentas: TStringList; xdesde, xhasta: String; salida: char);

  function    setMovimientos(xcuenta, xdesde, xhasta: String): TObjectList;
  function    setMovimientosTransferidos(xcuenta, xdesde, xhasta: String): TObjectList;

  procedure   MarcarTransaccionComoTransferida(xidregistro, xfecha: String);
  procedure   AnularTransferencia(xidregistro: String);

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  conexiones: shortint;
end;

function transferenciabancariapendiente: TTransferenciasBancariasPendientes;

implementation

var
  xtransferenciabancariapendiente: TTransferenciasBancariasPendientes = nil;

constructor TTransferenciasBancariasPendientes.Create;
begin
  inherited Create;
  tabla := datosdb.openDB('transbancariaspen', '');
end;

destructor TTransferenciasBancariasPendientes.Destroy;
begin
  inherited Destroy;
end;

procedure TTransferenciasBancariasPendientes.getDatos(xidregistro: String);
// Objetivo...: Recuperar una Instancia
begin
  if Buscar(xidregistro) then Begin
    Estado      := tabla.FieldByName('estado').AsString;
    Transferido := tabla.FieldByName('transferido').AsString;
  end else Begin
    Estado := ''; Transferido := '';
  end;
  inherited getDatos(xidregistro);
end;

procedure TTransferenciasBancariasPendientes.Listar(xcuentas: TStringList; xdesde, xhasta: String; salida: char);
// Objetivo...: Generar Informe de Transferencia
var
  i, l, k: Integer;
  total1, total2: Real;
Begin
  list.Setear(salida);
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Transferencia a Cuentas Bancarias Pendientes - Lapso: ' + xdesde + '-' + xhasta, 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Fecha', 1, 'Arial, cursiva, 8');
  List.Titulo(9, list.Lineactual, 'Transacción', 2, 'Arial, cursiva, 8');
  List.Titulo(20, list.Lineactual, 'Concepto', 3, 'Arial, cursiva, 8');
  List.Titulo(64, list.Lineactual, 'Débitos', 4, 'Arial, cursiva, 8');
  List.Titulo(75, list.Lineactual, 'Créditos', 5, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  proveedor.conectar;
  cliente.conectar;
  k := 0; total1 := 0; total2 := 0;
  For i := 1 to xcuentas.Count do Begin
    tabla.IndexFieldNames := 'Fecha';
    datosdb.Filtrar(tabla, 'fecha >= ' + '''' + utiles.sExprFecha2000(xdesde) + '''' + ' and fecha <= ' + '''' + utiles.sExprFecha2000(xhasta) + '''' + ' and cuenta = ' + '''' + xcuentas.Strings[i-1] + '''');
    tabla.First;

    l := 0;
    while not tabla.Eof do Begin
      if l = 0 then Begin
        entbcos.getDatos(tabla.FieldByName('entidad').AsString);
        list.Linea(0, 0, 'Cuenta: ' + tabla.FieldByName('cuenta').AsString + ' - ' + entbcos.descrip, 1, 'Arial, negrita, 9', salida, 'N');
        list.Linea(0, 0, ' ', 1, 'Arial, negrita, 5', salida, 'S');
        l := 1;
        list.Linea(0, 0, ' ', 1, 'Arial, negrita, 5', salida, 'S');
      end;

      list.Linea(0, 0, utiles.sFormatoFecha(tabla.FieldByName('fecha').AsString), 1, 'Arial, normal, 8', salida, 'N');
      list.Linea(9, list.Lineactual, tabla.FieldByName('transaccion').AsString, 2, 'Arial, normal, 8', salida, 'N');
      list.Linea(20, list.Lineactual, tabla.FieldByName('concepto').AsString, 3, 'Arial, normal, 8', salida, 'N');
      if tabla.FieldByName('tipomov').AsString = '1' then Begin
        list.importe(70, list.Lineactual, '', tabla.FieldByName('monto').AsFloat, 4, 'Arial, normal, 8');
        total1 := total1 + tabla.FieldByName('monto').AsFloat;
      end else Begin
        list.importe(80, list.Lineactual, '', tabla.FieldByName('monto').AsFloat, 4, 'Arial, normal, 8');
        total2 := total2 + tabla.FieldByName('monto').AsFloat;
      end;
      list.Linea(95, list.Lineactual, '', 5, 'Arial, normal, 8', salida, 'S');
      {if (Length(Trim(tabla.FieldByName('entidadtran').AsString)) > 0) and (tabla.FieldByName('tipomov').AsString = '2') then Begin
        list.Linea(0, 0, '   Transferido a: ', 1, 'Arial, cursiva, 8', salida, 'N');
        list.Linea(20, list.Lineactual, tabla.FieldByName('cuentatran').AsString, 2, 'Arial, cursiva, 8', salida, 'N');
        proveedor.getDatos(tabla.FieldByName('entidadtran').AsString);
        list.Linea(45, list.Lineactual, proveedor.nombre, 3, 'Arial, cursiva, 8', salida, 'S');
        list.Linea(0, 0, '   Neto a Transf.: ', 1, 'Arial, normal, 7', salida, 'N');
        list.importe(25, list.Lineactual, '', tabla.FieldByName('netotran').AsFloat, 2, 'Arial, normal, 7');
        list.Linea(26, list.Lineactual, 'Comisiones: ', 3, 'Arial, normal, 7', salida, 'N');
        list.importe(50, list.Lineactual, '', tabla.FieldByName('comisionestran').AsFloat, 4, 'Arial, normal, 7');
        list.Linea(52, list.Lineactual, 'Imp. Deb.: ', 5, 'Arial, normal, 7', salida, 'N');
        list.importe(75, list.Lineactual, '', tabla.FieldByName('impdebtran').AsFloat, 6, 'Arial, normal, 7');
        list.Linea(95, list.Lineactual, '', 7, 'Arial, normal, 7', salida, 'N');

        list.Linea(0, 0, '    Imp. Sellos: ', 1, 'Arial, normal, 7', salida, 'N');
        list.importe(25, list.Lineactual, '', tabla.FieldByName('sellostran').AsFloat, 2, 'Arial, normal, 7');
        list.Linea(26, list.Lineactual, 'Impuestos: ', 3, 'Arial, normal, 7', salida, 'N');
        list.importe(50, list.Lineactual, '', tabla.FieldByName('impuestostran').AsFloat, 4, 'Arial, normal, 7');
        list.Linea(52, list.Lineactual, 'Telex/Tel.: ', 5, 'Arial, normal, 7', salida, 'N');
        list.importe(75, list.Lineactual, '', tabla.FieldByName('telextran').AsFloat, 6, 'Arial, normal, 7');
        list.Linea(95, list.Lineactual, '', 7, 'Arial, normal, 7', salida, 'S');
        list.Linea(0, 0, ' ', 1, 'Arial, negrita, 5', salida, 'S');
      end;}

      {if (Length(Trim(tabla.FieldByName('entidadtran').AsString)) > 0) and (tabla.FieldByName('tipomov').AsString = '1') then Begin
        list.Linea(0, 0, '   Transferencia de: ', 1, 'Arial, cursiva, 8', salida, 'N');
        list.Linea(20, list.Lineactual, tabla.FieldByName('cuentatran').AsString, 2, 'Arial, cursiva, 8', salida, 'N');
        cliente.getDatos(tabla.FieldByName('entidadtran').AsString);
        list.Linea(45, list.Lineactual, cliente.nombre, 3, 'Arial, cursiva, 8', salida, 'S');
        list.Linea(0, 0, '   Monto Transf.: ', 1, 'Arial, normal, 7', salida, 'N');
        list.importe(25, list.Lineactual, '', tabla.FieldByName('monto').AsFloat, 2, 'Arial, normal, 7');
        list.Linea(95, list.Lineactual, '', 3, 'Arial, normal, 7', salida, 'S');
      end;}

      k := 1;
      tabla.Next;
    end;
    datosdb.QuitarFiltro(tabla);
  end;

  if (total1 + total2) > 0 then Begin
    list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
    list.Linea(0, 0, 'Subtotal:', 1, 'Arial, negrita, 8', salida, 'N');
    list.importe(70, list.Lineactual, '', total1, 2, 'Arial, negrita, 8');
    list.importe(80, list.Lineactual, '', total2, 3, 'Arial, negrita, 8');
    list.Linea(95, list.Lineactual, '', 4, 'Arial, negrita, 8', salida, 'S');
  end;

  if k = 0 then list.Linea(0, 0, 'No Existen Datos para Listar ...!', 1, 'Arial, normal, 11', salida, 'S');

  proveedor.desconectar;

  list.FinList;
end;

function  TTransferenciasBancariasPendientes.setMovimientos(xcuenta, xdesde, xhasta: String): TObjectList;
// Objetivo...: devolver una lista con las transacciones
var
  l: TObjectList;
  objeto: TTransferenciasBancariasPendientes;
begin
  l := TObjectList.Create;
  tabla.IndexFieldNames := 'Fecha';
  datosdb.Filtrar(tabla, 'cuenta = ' + '''' + xcuenta + '''' + ' and fecha >= ' + '''' + utiles.sExprFecha2000(xdesde) + '''' + ' and fecha <= ' + '''' + utiles.sExprFecha2000(xhasta) + '''');
  tabla.First;
  while not tabla.Eof do Begin
    if Length(Trim(tabla.FieldByName('transferido').AsString)) = 0 then Begin
      objeto := TTransferenciasBancariasPendientes.Create;
      objeto.Idregistro  := tabla.FieldByName('idregistro').AsString;
      objeto.Transaccion := tabla.FieldByName('transaccion').AsString;
      objeto.Fecha       := utiles.sFormatoFecha(tabla.FieldByName('fecha').AsString);
      objeto.concepto    := tabla.FieldByName('concepto').AsString;
      objeto.entidad     := tabla.FieldByName('entidad').AsString;
      objeto.Tipomov     := tabla.FieldByName('tipomov').AsString;
      objeto.monto       := tabla.FieldByName('monto').AsFloat;
      objeto.Cuenta      := tabla.FieldByName('cuenta').AsString;
      objeto.Saldo       := tabla.FieldByName('saldo').AsFloat;
      l.Add(objeto);
    end;
    tabla.Next;
  end;
  datosdb.QuitarFiltro(tabla);  datosdb.closeDB(tabla); tabla.Open;
  tabla.IndexFieldNames := 'Idregistro';

  Result := l;
end;

function  TTransferenciasBancariasPendientes.setMovimientosTransferidos(xcuenta, xdesde, xhasta: String): TObjectList;
// Objetivo...: devolver una lista con las transacciones
var
  l: TObjectList;
  objeto: TTransferenciasBancariasPendientes;
begin
  l := TObjectList.Create;
  tabla.IndexFieldNames := 'Fecha';
  datosdb.Filtrar(tabla, 'cuenta = ' + '''' + xcuenta + '''' + ' and fecha >= ' + '''' + utiles.sExprFecha2000(xdesde) + '''' + ' and fecha <= ' + '''' + utiles.sExprFecha2000(xhasta) + '''');
  tabla.First;
  while not tabla.Eof do Begin
    if Length(Trim(tabla.FieldByName('transferido').AsString)) > 0 then Begin
      objeto := TTransferenciasBancariasPendientes.Create;
      objeto.Idregistro  := tabla.FieldByName('idregistro').AsString;
      objeto.Transaccion := tabla.FieldByName('transaccion').AsString;
      objeto.Fecha       := utiles.sFormatoFecha(tabla.FieldByName('fecha').AsString);
      objeto.concepto    := tabla.FieldByName('concepto').AsString;
      objeto.entidad     := tabla.FieldByName('entidad').AsString;
      objeto.Tipomov     := tabla.FieldByName('tipomov').AsString;
      objeto.monto       := tabla.FieldByName('monto').AsFloat;
      objeto.Cuenta      := tabla.FieldByName('cuenta').AsString;
      objeto.Saldo       := tabla.FieldByName('saldo').AsFloat;
      l.Add(objeto);
    end;
    tabla.Next;
  end;
  datosdb.QuitarFiltro(tabla);  datosdb.closeDB(tabla); tabla.Open;
  tabla.IndexFieldNames := 'Idregistro';

  Result := l;
end;

procedure TTransferenciasBancariasPendientes.MarcarTransaccionComoTransferida(xidregistro, xfecha: String);
// Objetivo...: cerrar tablas de persistencia
begin
  if Buscar(xidregistro) then Begin
    tabla.Edit;
    tabla.FieldByName('transferido').AsString := utiles.sExprFecha2000(xfecha);
    try
      tabla.Post
     except
      tabla.Cancel
    end;
    datosdb.refrescar(tabla);
  end;
end;

procedure TTransferenciasBancariasPendientes.AnularTransferencia(xidregistro: String);
// Objetivo...: cerrar tablas de persistencia
begin
  if Buscar(xidregistro) then Begin
    tabla.Edit;
    tabla.FieldByName('transferido').AsString := '';
    try
      tabla.Post
     except
      tabla.Cancel
    end;
    datosdb.refrescar(tabla);
  end;
end;

procedure TTransferenciasBancariasPendientes.conectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones = 0 then Begin
    if not tabla.Active then tabla.Open;
  end;
  Inc(conexiones);
end;

procedure TTransferenciasBancariasPendientes.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  Dec(conexiones);
  if conexiones = 0 then Begin
    datosdb.closeDB(tabla);
  end;
end;

{===============================================================================}

function transferenciabancariapendiente: TTransferenciasBancariasPendientes;
begin
  if xtransferenciabancariapendiente = nil then
    xtransferenciabancariapendiente := TTransferenciasBancariasPendientes.Create;
  Result := xtransferenciabancariapendiente;
end;

{===============================================================================}

initialization

finalization
  xtransferenciabancariapendiente.Free;

end.
