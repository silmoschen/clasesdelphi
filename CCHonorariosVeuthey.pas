unit CCHonorariosVeuthey;

interface

uses CBDT, SysUtils, DBTables, CUtiles, CListar, CIDBFM, CUtilidadesArchivos,
     Classes, CEmpresas;

type

TTHonorarios = class
  Encabezado, Pie, Observaciones: String;
  tabla, modelo: TTable;
 public
  { Declaraciones P�blicas }
  constructor Create;
  destructor  Destroy; override;

  procedure   SeleccionarEmpresa(xvia: String);
  function    Buscar(xidc, xtipo, xsucursal, xnumero, xitems: String): Boolean;
  procedure   Registrar(xidc, xtipo, xsucursal, xnumero, xitems, xfecha, xconcepto, xtipomov: String; xmonto, xsaldo: Real);
  procedure   RegistrarObservacion(xidc, xtipo, xsucursal, xnumero, xitems, xobservac: String);
  function    getObservacion(xidc, xtipo, xsucursal, xnumero, xitems: String): String;
  procedure   ActualizarSaldo(xidc, xtipo, xsucursal, xnumero, xitems: String; xsaldo: Real);
  function    Borrar(xidc, xtipo, xsucursal, xnumero, xitems: String): Boolean;

  procedure   RegistrarModelo(xencabezado, xpie: String);
  procedure   getModelo;

  function    setMovimientos: TStringList;

  procedure   RecalcularSaldo;

  procedure   ListarHonorarios(xcodemp: String; xlista, xlistacomp: TStringList; xomitirsaldoinicial: Boolean; salida: char);
  procedure   ListarSaldos(xlista: TStringList; xexcluirsaldocero: Boolean; salida: char);

  procedure   conectar(xvia: String);
  procedure   desconectar;
 private
  idanter: String;
  procedure   RegenerarItems;
  function    verificarSiExisteVia(xvia: String): Boolean;
  function    getSaldoActual(xvia: String): Real;
  { Declaraciones Privadas }
end;

function honorario: TTHonorarios;

implementation

var
  xhonorario: TTHonorarios = nil;

constructor TTHonorarios.Create;
begin
  modelo := datosdb.openDB('modelohonorarios', '');
end;

destructor TTHonorarios.Destroy;
begin
  inherited Destroy;
end;

procedure TTHonorarios.SeleccionarEmpresa(xvia: String);
// Objetivo...: Seleccionar Empresa
begin
  if xvia <> idanter then Begin
    desconectar;
    if not DirectoryExists(dbs.DirSistema + '\' + xvia) then utilesarchivos.CrearDirectorio(dbs.DirSistema + '\' + xvia);
    if not FileExists(dbs.DirSistema + '\' + xvia + '\honorariosprof.db') then utilesarchivos.CopiarArchivos(dbs.DirSistema + '\estructu\honorariosprof',
         '*.*', dbs.DirSistema + '\' + xvia);
    idanter := xvia;
  end;
  conectar(dbs.DirSistema + '\' + xvia);
end;

function  TTHonorarios.verificarSiExisteVia(xvia: String): Boolean;
// Objetivo...: Verificar si Existe V�a
begin
  if FileExists(dbs.DirSistema + '\' + xvia + '\honorariosprof.db') then Result := True else Result := False;
end;

function TTHonorarios.getSaldoActual(xvia: String): Real;
// Objetivo...: Recuperar el Saldo Actual
Begin
  SeleccionarEmpresa(xvia);
  tabla.Last;
  Result := tabla.FieldByName('saldo').AsFloat;
  desconectar;
end;

function  TTHonorarios.Buscar(xidc, xtipo, xsucursal, xnumero, xitems: String): Boolean;
// Objetivo...: Buscar Instancia
begin
  if tabla.IndexFieldNames <> 'idc;tipo;sucursal;numero;items' then tabla.IndexFieldNames := 'idc;tipo;sucursal;numero;items';
  Result := datosdb.Buscar(tabla, 'idc', 'tipo', 'sucursal', 'numero', 'items', xidc, xtipo, xsucursal, xnumero, xitems);
end;

procedure TTHonorarios.Registrar(xidc, xtipo, xsucursal, xnumero, xitems, xfecha, xconcepto, xtipomov: String; xmonto, xsaldo: Real);
// Objetivo...: Registrar Instancia
begin
  if Buscar(xidc, xtipo, xsucursal, xnumero, xitems) then tabla.Edit else tabla.Append;
  tabla.FieldByName('idc').AsString      := xidc;
  tabla.FieldByName('tipo').AsString     := xtipo;
  tabla.FieldByName('sucursal').AsString := xsucursal;
  tabla.FieldByName('numero').AsString   := xnumero;
  tabla.FieldByName('items').AsString    := xitems;
  tabla.FieldByName('fecha').AsString    := utiles.sExprFecha2000(xfecha);
  tabla.FieldByName('concepto').AsString := xconcepto;
  tabla.FieldByName('tipomov').AsString  := xtipomov;
  tabla.FieldByName('monto').AsFloat     := xmonto;
  tabla.FieldByName('saldo').AsFloat     := xsaldo;
  try
    tabla.Post
   except
    tabla.Cancel
  end;
  datosdb.closeDB(tabla); tabla.Open;
end;

procedure TTHonorarios.RegistrarObservacion(xidc, xtipo, xsucursal, xnumero, xitems, xobservac: String);
// Objetivo...: Registrar Observacion en Instancia
begin
  if Buscar(xidc, xtipo, xsucursal, xnumero, xitems) then Begin
    tabla.Edit;
    tabla.FieldByName('observac').AsString := xobservac;
    try
      tabla.Post
     except
      tabla.Cancel
    end;
    datosdb.closeDB(tabla); tabla.Open;
  end;
end;

function  TTHonorarios.getObservacion(xidc, xtipo, xsucursal, xnumero, xitems: String): String;
// Objetivo...: Recuperar Observacion en Instancia
begin
  if Buscar(xidc, xtipo, xsucursal, xnumero, xitems) then Result := tabla.FieldByName('observac').AsString else Result := ''; 
end;

procedure   TTHonorarios.ActualizarSaldo(xidc, xtipo, xsucursal, xnumero, xitems: String; xsaldo: Real);
// Objetivo...: Actualizar el Atributo Saldo
begin
  if Buscar(xidc, xtipo, xsucursal, xnumero, xitems) then Begin
    tabla.Edit;
    tabla.FieldByName('saldo').AsFloat := xsaldo;
    try
      tabla.Post
     except
      tabla.Cancel
    end;
    datosdb.closeDB(tabla); tabla.Open;
  end;
end;

function  TTHonorarios.Borrar(xidc, xtipo, xsucursal, xnumero, xitems: String): Boolean;
// Objetivo...: Borrar Instancia
begin
  if Buscar(xidc, xtipo, xsucursal, xnumero, xitems) then Begin
    tabla.Delete;
    datosdb.closeDB(tabla); tabla.Open;
    RegenerarItems;
    RecalcularSaldo;
  end;
end;

procedure TTHonorarios.RegistrarModelo(xencabezado, xpie: String);
// Objetivo...: Registrar Instancia
begin
  modelo.Open;
  if modelo.FindKey(['01']) then modelo.Edit else modelo.Append;
  modelo.FieldByName('id').AsString         := '01';
  modelo.FieldByName('encabezado').AsString := xencabezado;
  modelo.FieldByName('pie').AsString        := xpie;
  try
    modelo.Post
   except
    modelo.Cancel
  end;
  modelo.Close;
end;

procedure TTHonorarios.getModelo;
// Objetivo...: Recuperar Instancia
begin
  modelo.Open;
  if modelo.FindKey(['01']) then Begin
    encabezado := modelo.FieldByName('encabezado').AsString;
    pie        := modelo.FieldByName('pie').AsString;
  end else Begin
    encabezado := '';
    pie        := '';
  end;
  modelo.Close;
end;

function  TTHonorarios.setMovimientos: TStringList;
// Objetivo...: devolver una lista
var
  l: TStringList;
begin
  l := TStringList.Create;
  tabla.IndexFieldNames := 'Fecha';
  tabla.First;
  while not tabla.Eof do Begin
    l.Add(tabla.FieldByName('idc').AsString + ';1' + tabla.FieldByName('tipo').AsString + tabla.FieldByName('sucursal').AsString +
          tabla.FieldByName('numero').AsString + tabla.FieldByName('items').AsString + utiles.sFormatoFecha(tabla.FieldByName('fecha').AsString) +
          tabla.FieldByName('concepto').AsString + ';2' + tabla.FieldByName('tipomov').AsString +
          utiles.FormatearNumero(tabla.FieldByName('monto').AsString) + ';3' + utiles.FormatearNumero(tabla.FieldByName('saldo').AsString));
    tabla.Next;
  end;
  tabla.IndexFieldNames := 'idc;tipo;sucursal;numero;items';
  Result := l;
end;

procedure TTHonorarios.RecalcularSaldo;
// Objetivo...: recalcular saldos
var
  saldo: Real;
begin
  saldo := 0;
  tabla.IndexFieldNames := 'Fecha';
  tabla.First;
  while not tabla.Eof do Begin
    if tabla.FieldByName('tipomov').AsString = '1' then saldo := saldo + tabla.FieldByName('monto').AsFloat;
    if tabla.FieldByName('tipomov').AsString = '2' then saldo := saldo - tabla.FieldByName('monto').AsFloat;
    if tabla.FieldByName('saldo').AsFloat <> saldo then Begin
      tabla.Edit;
      tabla.FieldByName('saldo').AsFloat := saldo;
      try
        tabla.Edit
       except
        tabla.Post
      end;
    end;
    tabla.Next;
  end;
  datosdb.closeDB(tabla); tabla.Open;
  tabla.IndexFieldNames := 'idc;tipo;sucursal;numero;items';
end;

procedure TTHonorarios.RegenerarItems;
// Objetivo...: recalcular saldos
var
  items: Integer;
begin
  items := 0;
  tabla.First;
  while not tabla.Eof do Begin
    Inc(items);
    tabla.Edit;
    tabla.FieldByName('items').AsString := utiles.sLlenarIzquierda(IntToStr(items), 3, '0');
    try
      tabla.Edit
     except
      tabla.Post
    end;
    tabla.Next;
  end;
  datosdb.closeDB(tabla); tabla.Open;
end;

procedure TTHonorarios.ListarHonorarios(xcodemp: String; xlista, xlistacomp: TStringList; xomitirsaldoinicial: Boolean; salida: char);
// Objetivo...: Listar Honorarios
var
  l, t: TStringList;
  i, j, p1, p2, p3, k: Integer;
  saldo, saldoanter, total: Real;
  lista, j1, ldat: Boolean;
Begin
  list.Setear(salida);
  list.NoImprimirPieDePagina;

  list.Titulo(0, 0, '', 1, 'Arial, negrita, 14');

  // Cabecera ------------------------------------------------------------------
  modelo.Open;
  modelo.FindKey(['01']);
  list.IniciarMemoImpresiones(modelo, 'encabezado', 500);
  if (xlistacomp.Count > 0) then
    list.RemplazarEtiquetasEnMemo('#comprobante', xlistacomp.Strings[xlistacomp.Count -1])
  else
    list.RemplazarEtiquetasEnMemo('#comprobante', '');

  l := list.setContenidoMemo;
  For i := 1 to l.Count do
  list.Linea(0, 0, l.Strings[i-1], 1, 'Courier New, Normal, 9', salida, 'S');

  list.LiberarMemoImpresiones;
  //----------------------------------------------------------------------------

  empresa.getDatos(xcodemp);
  list.Linea(0, 0, '', 1, 'Courier new, normal, 14', salida, 'S');
  list.Linea(0, 0, 'Se�or: ' + empresa.nombre, 1, 'Courier new, normal, 12', salida, 'S');
  list.Linea(0, 0, 'Domicilio: ' + empresa.domicilio, 1, 'Courier new, normal, 12', salida, 'S');
  list.Linea(0, 0, 'Localidad: ' + empresa.localidad, 1, 'Courier new, normal, 12', salida, 'S');
  list.Linea(0, 0, '', 1, 'Courier new, normal, 14', salida, 'S');

  ldat := False; total := 0;
  l    := setMovimientos;
  For i := 1 to l.Count do Begin

    p1 := Pos(';1', l.Strings[i-1]);
    p2 := Pos(';2', l.Strings[i-1]);
    p3 := Pos(';3', l.Strings[i-1]);

    lista := False;   // Determina que items Lista y que Items No Lista
    for j := 1 to xlista.Count do Begin
     //if Copy(l.Strings[i-1], p1+15, 3) = xlista.Strings[j-1] then Begin
     if IntToStr(i) = xlista.Strings[j-1] then Begin
       lista := True;
       Break;
     end;
    end;

    if lista then Begin

      if not j1 then Begin
        if Copy(l.Strings[i-1], p2+2, 1) = '1' then saldoanter := StrToFloat(Copy(l.Strings[i-1], p3+2, 20)) - StrToFloat(Copy(l.Strings[i-1], p2+3, p3-(p2+3)));
        if Copy(l.Strings[i-1], p2+2, 1) = '2' then saldoanter := StrToFloat(Copy(l.Strings[i-1], p3+2, 20)) + StrToFloat(Copy(l.Strings[i-1], p2+3, p3-(p2+3)));
        if not xomitirsaldoinicial then Begin
          list.Linea(0, 0, '', 1, 'Arial, negrita, 8', salida, 'N');
          list.Linea(4, list.Lineactual, 'Saldo Anterior:', 2, 'Arial, negrita, 8', salida, 'N');
          list.importe(90, list.Lineactual, '#######0.00', saldoanter, 3, 'Arial, negrita, 8');
          list.Linea(95, list.Lineactual, '', 4, 'Arial, negrita, 8', salida, 'S');
          list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S');
          j1 := True;
        end else
          saldoanter := 0;
      end;

      if xomitirsaldoinicial then Begin
        if Copy(l.Strings[i-1], p2+2, 1) = '1' then total := total + StrToFloat(Copy(l.Strings[i-1], p2+3, p3-(p2+3)));
      end;

      list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'N');
      list.Linea(4, list.Lineactual, Copy(l.Strings[i-1], p1+18, 8), 2, 'Arial, normal, 8', salida, 'N');
      list.Linea(11, list.Lineactual, Copy(l.Strings[i-1], p1+26, p2-(p1+26)), 3, 'Arial, normal, 8', salida, 'N');

      if Copy(l.Strings[i-1], p2+2, 1) = '1' then
        list.importe(70, list.Lineactual, '#######0.00', StrToFloat(Copy(l.Strings[i-1], p2+3, p3-(p2+3))), 4, 'Arial, normal, 8')
      else
        list.importe(70, list.Lineactual, '##', 0, 4, 'Arial, normal, 8');

      if Copy(l.Strings[i-1], p2+2, 1) = '2' then
        list.importe(80, list.Lineactual, '#######0.00', StrToFloat(Copy(l.Strings[i-1], p2+3, p3-(p2+3))), 5, 'Arial, normal, 8')
      else
        list.importe(80, list.Lineactual, '##', 0, 5, 'Arial, normal, 8');


      if not xomitirsaldoinicial then list.importe(90, list.Lineactual, '#######0.00', StrToFloat(Copy(l.Strings[i-1], p3+2, 20)), 6, 'Arial, normal, 8');
      if xomitirsaldoinicial then list.importe(90, list.Lineactual, '#######0.00', total, 6, 'Arial, normal, 8');

      list.Linea(95, list.Lineactual, '', 7, 'Arial, normal, 8', salida, 'S');

      if Buscar(Copy(l.Strings[i-1], 1, p1-1), Copy(l.Strings[i-1], p1+2, 1), Copy(l.Strings[i-1], p1+3, 4), Copy(l.Strings[i-1], p1+7, 8), Copy(l.Strings[i-1], p1+15, 3)) then Begin
        list.IniciarMemoImpresiones(tabla, 'Observac', 500);
        t := list.setContenidoMemo;
        For k := 1 to t.Count do
          list.Linea(0, 0, '              ' + t.Strings[k-1], 1, 'Arial, Normal, 8', salida, 'S');
        list.LiberarMemoImpresiones;
        t.Destroy;
      end;

      saldo := StrToFloat(Copy(l.Strings[i-1], p3+2, 20));
      ldat  := True;

    end;
  end;

  if ldat then Begin
    list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'N');
    list.Derecha(90, list.Lineactual, '', '--------------------------------------------------', 2, 'Arial, normal, 8');
    list.Linea(95, list.Lineactual, '', 3, 'Arial, normal, 8', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, negrita, 8', salida, 'N');
    list.Linea(4, list.Lineactual, 'Saldo Actual:', 2, 'Arial, negrita, 8', salida, 'N');
    if not xomitirsaldoinicial then list.importe(90, list.Lineactual, '#######0.00', saldo, 3, 'Arial, negrita, 8') else
      list.importe(90, list.Lineactual, '#######0.00', total, 3, 'Arial, negrita, 8');
    list.Linea(95, list.Lineactual, '', 4, 'Arial, negrita, 8', salida, 'S');
  end else
    list.Linea(0, 0, 'No Existen Datos para Listar ...!', 1, 'Arial, normal, 11', salida, 'S');

  l.Destroy;

  // Pie ------------------------------------------------------------------
  list.Linea(0, 0, '', 1, 'Courier new, normal, 14', salida, 'S');
  l := list.setContenidoMemo(modelo, 'pie', 500);
  For i := 1 to l.Count do
    list.Linea(0, 0, l.Strings[i-1], 1, 'Courier New, Normal, 9', salida, 'S');
  modelo.Close;

  //----------------------------------------------------------------------------

  list.FinList;
end;

procedure TTHonorarios.ListarSaldos(xlista: TStringList; xexcluirsaldocero: Boolean; salida: char);
// Objetivo...: Listar Saldos
var
  i: Integer;
  saldo, total: Real;
  l, ldat: Boolean;
Begin
  list.Setear(salida);
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Listado de Saldos Actuales de Contribuyentes', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'C�d.' + utiles.espacios(3) +  'Raz�n Social', 1, 'Arial, cursiva, 8');
  List.Titulo(85, list.Lineactual, 'Saldo Actual', 4, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  total := 0; saldo := 0; ldat := False;
  For i := 1 to xlista.Count do Begin
    empresa.getDatos(Copy(xlista.Strings[i-1], 4, 4));
    if verificarSiExisteVia(empresa.nomvia) then Begin
      saldo := getSaldoActual(empresa.nomvia);
      l := False;
      if not xexcluirsaldocero then l := True else
        if saldo <> 0 then l := True;
      if l then Begin
        total := total + saldo;
        list.Linea(0, 0, empresa.codigo + '   ' + empresa.nombre, 1, 'Arial, normal, 8', salida, 'N');
        list.importe(95, list.Lineactual,  '', saldo, 2, 'Arial, normal, 8');
        list.Linea(96, list.Lineactual, '', 3, 'Arial, normal, 8', salida, 'S');
        ldat := True;
      end;
    end;
  end;

  if ldat then Begin
    list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
    list.Linea(0, 0, 'Subtotal a Cobrar: ', 1, 'Arial, negrita, 8', salida, 'N');
    list.importe(95, list.Lineactual,  '', total, 2, 'Arial, negrita, 8');
    list.Linea(96, list.Lineactual, '', 3, 'Arial, negrita, 8', salida, 'S');
  end else
    list.Linea(0, 0, 'No Existen Datos para Listar ...!', 1, 'Arial, normal, 11', salida, 'S');

  list.FinList;
end;

procedure TTHonorarios.conectar(xvia: String);
// Objetivo...: cerrar tablas de persistencia
begin
  tabla := Nil;
  tabla := datosdb.openDB('honorariosprof', '', '', xvia);
  tabla.Open;
end;

procedure TTHonorarios.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if tabla <> Nil then datosdb.closeDB(tabla);
end;

{===============================================================================}

function honorario: TTHonorarios;
begin
  if xhonorario = nil then
    xhonorario := TTHonorarios.Create;
  Result := xhonorario;
end;

{===============================================================================}

initialization

finalization
  xhonorario.Free;

end.
