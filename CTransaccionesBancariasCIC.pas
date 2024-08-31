unit CTransaccionesBancariasCIC;

interface

uses CBDT, SysUtils, DBTables, CUtiles, CListar, CIDBFM, Classes, Contnrs, CBancos;

type

TTransaccionBancaria = class
  Idregistro, Transac, Fecha, Cuenta, Entidad, Concepto, Tipomov, Ajuste: String;
  Monto, Saldo: Real;
  tabla: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  function    Buscar(xidregistro: String): Boolean;
  procedure   Registrar(xidregistro, xtransac, xfecha, xcuenta, xentidad, xconcepto, xtipomov, xajuste: String; xmonto: Real);
  procedure   Borrar(xidregistro, xcuenta: String);
  procedure   getDatos(xidregistro: String);

  function    setMovimientos(xcuenta, xperiodo: String): TObjectList;

  procedure   RecalcularSaldo(xfecha, xcuenta: String); overload;
  procedure   RecalcularSaldo(xcuenta: String); overload;

  function    setEntidad(xidentidad: String): String; Virtual;
  function    setCuenta(xcuenta: String): String; Virtual;

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  conexiones: shortint;
 protected
  { Declaraciones Protegidas }
  procedure   ListarTransacciones(xdesde, xhasta, xcuenta, xbanco, xtitulo: String; salida: char);
end;

implementation

constructor TTransaccionBancaria.Create;
begin
end;

destructor TTransaccionBancaria.Destroy;
begin
  inherited Destroy;
end;

function  TTransaccionBancaria.Buscar(xidregistro: String): Boolean;
// Objetivo...: Recuperar una Instancia
Begin
  if tabla.IndexFieldNames <> 'idregistro' then tabla.IndexFieldNames := 'idregistro';
  Result := tabla.FindKey([xidregistro]);
end;

procedure TTransaccionBancaria.Registrar(xidregistro, xtransac, xfecha, xcuenta, xentidad, xconcepto, xtipomov, xajuste: String; xmonto: Real);
// Objetivo...: Registrar una Instancia
Begin
  if Buscar(xidregistro) then tabla.Edit else tabla.Append;
  tabla.FieldByName('idregistro').AsString := xidregistro;
  tabla.FieldByName('transac').AsString    := xtransac;
  tabla.FieldByName('fecha').AsString      := utiles.sExprFecha2000(xfecha);
  tabla.FieldByName('cuenta').AsString     := xcuenta;
  tabla.FieldByName('entidad').AsString    := xentidad;
  tabla.FieldByName('concepto').AsString   := xconcepto;
  tabla.FieldByName('tipomov').AsString    := xtipomov;
  tabla.FieldByName('ajuste').AsString     := xajuste;
  tabla.FieldByName('monto').AsFloat       := xmonto;
  try
    tabla.Post
   except
    tabla.Cancel
  end;
  Idregistro := xidregistro;
  RecalcularSaldo(xfecha, xcuenta);
  datosdb.closedb(tabla); tabla.Open;
end;

procedure TTransaccionBancaria.Borrar(xidregistro, xcuenta: String);
// Objetivo...: Recuperar una Instancia
Begin
  if Buscar(xidregistro) then Begin
    tabla.Delete;
    RecalcularSaldo(xcuenta);
    datosdb.closedb(tabla); tabla.Open;
  end;
end;

procedure TTransaccionBancaria.getDatos(xidregistro: String);
// Objetivo...: Recuperar una Instancia
Begin
  if Buscar(xidregistro) then Begin
    idregistro := tabla.FieldByName('idregistro').AsString;
    transac    := tabla.FieldByName('transac').AsString;
    fecha      := utiles.sFormatoFecha(tabla.FieldByName('fecha').AsString);
    cuenta     := tabla.FieldByName('cuenta').AsString;
    entidad    := tabla.FieldByName('entidad').AsString;
    concepto   := tabla.FieldByName('concepto').AsString;
    tipomov    := tabla.FieldByName('tipomov').AsString;
    ajuste     := tabla.FieldByName('ajuste').AsString;
    monto      := tabla.FieldByName('monto').AsFloat;
  end else Begin
    idregistro := ''; transac := ''; cuenta := ''; fecha := ''; entidad := ''; concepto := ''; tipomov := ''; monto := 0; ajuste := '';
  end;
end;

function  TTransaccionBancaria.setMovimientos(xcuenta, xperiodo: String): TObjectList;
// Objetivo...: devolver una lista con las transacciones
var
  l: TObjectList;
  objeto: TTransaccionBancaria;
begin
  l := TObjectList.Create;
  tabla.IndexFieldNames := 'Fecha';
  datosdb.Filtrar(tabla, 'cuenta = ' + '''' + xcuenta + '''' + ' and fecha >= ' + '''' + Copy(xperiodo, 4, 4) + Copy(xperiodo, 1, 2) + '01' + '''' + ' and fecha <= ' + '''' + Copy(xperiodo, 4, 4) + Copy(xperiodo, 1, 2) + '31' + '''');
  tabla.First;
  while not tabla.Eof do Begin
    //if tabla.FieldByName('ajuste').AsString = 'C' then Begin
      objeto := TTransaccionBancaria.Create;
      objeto.Idregistro  := tabla.FieldByName('idregistro').AsString;
      objeto.Transac     := tabla.FieldByName('transac').AsString;
      objeto.Fecha       := utiles.sFormatoFecha(tabla.FieldByName('fecha').AsString);
      objeto.concepto    := tabla.FieldByName('concepto').AsString;
      objeto.entidad     := tabla.FieldByName('entidad').AsString;
      objeto.Tipomov     := tabla.FieldByName('tipomov').AsString;
      objeto.monto       := tabla.FieldByName('monto').AsFloat;
      objeto.Cuenta      := tabla.FieldByName('cuenta').AsString;
      objeto.Ajuste      := tabla.FieldByName('ajuste').AsString;
      objeto.Saldo       := tabla.FieldByName('saldo').AsFloat;
      l.Add(objeto);
    //end;
    tabla.Next;
  end;
  datosdb.QuitarFiltro(tabla);  datosdb.closeDB(tabla); tabla.Open;
  tabla.IndexFieldNames := 'Idregistro';

  Result := l;
end;

procedure TTransaccionBancaria.RecalcularSaldo(xfecha, xcuenta: String);
// Objetivo...: recalcular saldo
var
  saldo: Real;
  l1, l2: TStringList;
  i: Integer;
begin
  l1 := TStringList.Create; l2 := TStringList.Create;
  tabla.IndexFieldNames := 'Fecha';
  datosdb.Filtrar(tabla, 'cuenta = ' + '''' + xcuenta + '''');
  if tabla.FindKey([utiles.sExprFecha2000(xfecha)]) then Begin
    if tabla.RecordCount > 1 then Begin
      tabla.Prior;
      saldo := tabla.FieldByName('saldo').AsFloat;
    end;
    tabla.FindKey([utiles.sExprFecha2000(xfecha)]);
    while not tabla.Eof do Begin
      if tabla.FieldByName('tipomov').AsString = '1' then saldo := saldo + tabla.FieldByName('monto').AsFloat;
      if tabla.FieldByName('tipomov').AsString = '2' then saldo := saldo - tabla.FieldByName('monto').AsFloat;
      if tabla.FieldByName('saldo').AsFloat <> saldo then Begin
        l1.Add(tabla.FieldByName('idregistro').AsString);
        l2.Add(FloatToStr(saldo));
      end;
      tabla.Next;
    end;
  end;

  datosdb.QuitarFiltro(tabla);  datosdb.closeDB(tabla); tabla.Open;
  tabla.IndexFieldNames := 'Idregistro';

  For i := 1 to l1.Count do Begin
    if Buscar(l1.Strings[i-1]) then Begin
      tabla.Edit;
      tabla.FieldByName('saldo').AsFloat := StrToFloat(l2.Strings[i-1]);
      try
        tabla.Post
       except
        tabla.Cancel
      end;
    end;
  end;

  l1.Destroy; l2.Destroy;
end;

procedure TTransaccionBancaria.RecalcularSaldo(xcuenta: String);
// Objetivo...: recalcular saldo
var
  saldo: Real;
  l1, l2: TStringList;
  i: Integer;
begin
  l1 := TStringList.Create; l2 := TStringList.Create;
  tabla.IndexFieldNames := 'Fecha';
  datosdb.Filtrar(tabla, 'cuenta = ' + '''' + xcuenta + '''');
  tabla.First;
  while not tabla.Eof do Begin
    if tabla.FieldByName('tipomov').AsString = '1' then saldo := saldo + tabla.FieldByName('monto').AsFloat;
    if tabla.FieldByName('tipomov').AsString = '2' then saldo := saldo - tabla.FieldByName('monto').AsFloat;
    if tabla.FieldByName('saldo').AsFloat <> saldo then Begin
      l1.Add(tabla.FieldByName('idregistro').AsString);
      l2.Add(FloatToStr(saldo));
    end;
    tabla.Next;
  end;

  datosdb.QuitarFiltro(tabla);  datosdb.closeDB(tabla); tabla.Open;
  tabla.IndexFieldNames := 'Idregistro';

  For i := 1 to l1.Count do Begin
    if Buscar(l1.Strings[i-1]) then Begin
      tabla.Edit;
      tabla.FieldByName('saldo').AsFloat := StrToFloat(l2.Strings[i-1]);
      try
        tabla.Post
       except
        tabla.Cancel
      end;
    end;
  end;

  l1.Destroy; l2.Destroy;
end;

procedure TTransaccionBancaria.ListarTransacciones(xdesde, xhasta, xcuenta, xbanco, xtitulo: String; salida: char);
// Objetivo...: Generar Informe
var
  t1, t2, t3: Real;
begin
  list.Setear(salida);
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, xtitulo + ' - Lapso: ' + xdesde + '-' + xhasta, 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Fecha', 1, 'Arial, cursiva, 8');
  List.Titulo(8, list.Lineactual, 'Transacción', 2, 'Arial, cursiva, 8');
  List.Titulo(18, list.Lineactual, 'Concepto', 3, 'Arial, cursiva, 8');
  List.Titulo(70, list.Lineactual, 'Ingresos', 4, 'Arial, cursiva, 8');
  List.Titulo(79, list.Lineactual, 'Egresos', 5, 'Arial, cursiva, 8');
  List.Titulo(90, list.Lineactual, 'Saldo', 6, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  t1 := 0; t2 := 0; t3 := 0;
  if tabla.FieldByName('tipomov').AsString = '1' then t3 := tabla.FieldByName('saldo').AsFloat - tabla.FieldByName('monto').AsFloat;
  if tabla.FieldByName('tipomov').AsString = '2' then t3 := tabla.FieldByName('saldo').AsFloat + tabla.FieldByName('monto').AsFloat;

  tabla.IndexFieldNames := 'Fecha';
  datosdb.Filtrar(tabla, 'fecha >= ' + '''' + utiles.sExprFecha2000(xdesde) + '''' + ' and fecha <= ' + '''' + utiles.sExprFecha2000(xhasta) + '''' + 'and cuenta = ' + '''' + xcuenta + '''' + ' and entidad = ' + '''' + xbanco + '''');
  tabla.First;

  entbcos.conectar;
  entbcos.getDatos(tabla.FieldByName('entidad').AsString);
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');
  List.Titulo(0, 0, 'Cuenta: ' + tabla.FieldByName('cuenta').AsString + ' - ' + entbcos.descrip, 1, 'Arial, negrita, 8');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  entbcos.desconectar;

  while not tabla.Eof do Begin
    if t1 + t2 = 0 then Begin
      list.Linea(0, 0, 'Saldo Anterior:', 1, 'Arial, negrita, 8', salida, 'N');
      list.importe(95, list.Lineactual, '', t3, 2, 'Arial, negrita, 8');
      list.Linea(95, list.Lineactual, '', 3, 'Arial, negrita, 8', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, negrita, 8', salida, 'S');
    end;
    list.Linea(0, 0, utiles.sFormatoFecha(tabla.FieldByName('fecha').AsString), 1, 'Arial, normal, 8', salida, 'N');
    list.Linea(8, list.Lineactual, tabla.FieldByName('transac').AsString, 2, 'Arial, normal, 8', salida, 'N');
    list.Linea(18, list.Lineactual, tabla.FieldByName('concepto').AsString, 3, 'Arial, normal, 8', salida, 'N');
    if tabla.FieldByName('tipomov').AsString = '1' then Begin
      list.importe(75, list.Lineactual, '', tabla.FieldByName('monto').AsFloat, 4, 'Arial, normal, 8');
      t1 := t1 + tabla.FieldByName('monto').AsFloat;
    end;
    if tabla.FieldByName('tipomov').AsString = '2' then Begin
      list.importe(85, list.Lineactual, '', tabla.FieldByName('monto').AsFloat, 4, 'Arial, normal, 8');
      t2 := t2 + tabla.FieldByName('monto').AsFloat;
    end;
    list.importe(95, list.Lineactual, '', tabla.FieldByName('saldo').AsFloat, 5, 'Arial, normal, 8');
    list.Linea(95, list.Lineactual, '', 6, 'Arial, normal, 8', salida, 'S');
    t3 := tabla.FieldByName('saldo').AsFloat;
    tabla.Next;
  end;

  if t1 + t2 > 0 then Begin
    list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S');
    list.Linea(0, 0, 'Subtotales:', 1, 'Arial, negrita, 8', salida, 'N');
    list.importe(75, list.Lineactual, '', t1, 2, 'Arial, negrita, 8');
    list.importe(85, list.Lineactual, '', t2, 3, 'Arial, negrita, 8');
    list.importe(95, list.Lineactual, '', t3, 4, 'Arial, negrita, 8');
    list.Linea(95, list.Lineactual, '', 5, 'Arial, negrita, 8', salida, 'S');
  end else
    list.Linea(0, 0, 'No Existen Datos para Listar ...!', 1, 'Arial, normal, 12', salida, 'S');

  datosdb.QuitarFiltro(tabla);
  tabla.IndexFieldNames := 'Idregistro';

  list.FinList;
end;

function  TTransaccionBancaria.setEntidad(xidentidad: String): String;
// Objetivo...: devolver la entidad
begin
  Result := '';
end;

function  TTransaccionBancaria.setCuenta(xcuenta: String): String;
// Objetivo...: devolver la cuenta
begin
  Result := '';
end;

procedure TTransaccionBancaria.conectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones = 0 then Begin
    if not tabla.Active then tabla.Open;
  end;
  Inc(conexiones);
end;

procedure TTransaccionBancaria.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  Dec(conexiones);
  if conexiones = 0 then Begin
    datosdb.closedb(tabla); tabla.Open;
  end;
end;

end.
