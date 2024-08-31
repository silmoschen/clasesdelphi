unit CCobrosFoot;

interface

uses CAlumnosFoot, CBDT, SysUtils, DBTables, CUtiles, CListar, CIDBFM, Classes;

type

TTCobro = class
  cuotas: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  function    Buscar(xperiodo, xidalumno, xitems: String): Boolean;
  procedure   Registrar(xperiodo, xidalumno, xitems, xmes, xfechavto, xconcepto: String; xmonto: Real; xcantitems: Integer);
  function    setCuotas(xperiodo, xidalumno: String): TStringList;
  procedure   Borrar(xperiodo, xidalumno: String);

  procedure   RegistrarCobro(xperiodo, xidalumno, xitems, xfecha: String);
  procedure   BorrarCobro(xperiodo, xidalumno, xitems: String);

  procedure   ListarDetalleCuotas(xlista: TStringList; xperiodo: String; salida: char);
  procedure   ListarCupones(xlista: TStringList; xperiodo: String; salida: char);
  procedure   ListarDeudas(xlista: TStringList; xperiodo: String; salida: char);

  procedure   ListarTotalCobrado(xdesde, xhasta: String; salida: char);
  procedure   ListarTotalAdeudado(xdesde, xhasta: String; salida: char);

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  conexiones: shortint;
  pagos: array[1..12] of String;
  totales: array[1..5] of Real;
  idanter: String;
  procedure ListarLineaCuotas(idanter: String; salida: char);
end;

function cobro: TTCobro;

implementation

var
  xcobro: TTCobro = nil;

constructor TTCobro.Create;
begin
  cuotas := datosdb.openDB('cuotas', '');
end;

destructor TTCobro.Destroy;
begin
  inherited Destroy;
end;

function  TTCobro.Buscar(xperiodo, xidalumno, xitems: String): Boolean;
// Objetivo...: buscar instancia
begin
  Result := datosdb.Buscar(cuotas, 'periodo', 'idalumno', 'items', xperiodo, xidalumno, xitems);
end;

procedure TTCobro.Registrar(xperiodo, xidalumno, xitems, xmes, xfechavto, xconcepto: String; xmonto: Real; xcantitems: Integer);
// Objetivo...: registrar instancia
begin
  if Buscar(xperiodo, xidalumno, xitems) then cuotas.Edit else cuotas.Append;
  cuotas.FieldByName('periodo').AsString  := xperiodo;
  cuotas.FieldByName('idalumno').AsString := xidalumno;
  cuotas.FieldByName('items').AsString    := xitems;
  cuotas.FieldByName('mes').AsString      := xmes;
  cuotas.FieldByName('fechavto').AsString := utiles.sExprFecha2000(xfechavto);
  cuotas.FieldByName('concepto').AsString := xconcepto;
  cuotas.FieldByName('monto').AsFloat     := xmonto;
  cuotas.FieldByName('estado').AsString   := 'I';
  try
    cuotas.Post
   except
    cuotas.Cancel
  end;
  if xitems = utiles.sLlenarIzquierda(IntToStr(xcantitems), 2, '0') then Begin
    datosdb.tranSQL('delete from cuotas where periodo = ' + '''' + xperiodo + '''' + ' and idalumno = ' + '''' + xidalumno + '''' + ' and items > ' + '''' + xitems + '''');
    datosdb.closeDB(cuotas); cuotas.Open;
  end;
end;

function  TTCobro.setCuotas(xperiodo, xidalumno: String): TStringList;
// Objetivo...: devolver items
var
  l: TStringList;
begin
  l := TStringList.Create;
  if Buscar(xperiodo, xidalumno, '01') then Begin
    while not cuotas.Eof do Begin
      if (cuotas.FieldByName('periodo').AsString <> xperiodo) or (cuotas.FieldByName('idalumno').AsString <> xidalumno) then Break;
      l.Add(cuotas.FieldByName('items').AsString + cuotas.FieldByName('mes').AsString + utiles.sFormatoFecha(cuotas.FieldByName('fechavto').AsString) + cuotas.FieldByName('concepto').AsString + ';1' + cuotas.FieldByName('monto').AsString + ';2' + cuotas.FieldByName('estado').AsString + utiles.sFormatoFecha(cuotas.FieldByName('fepago').AsString));
      cuotas.Next;
    end;
  end;
  Result := l;
end;

procedure TTCobro.Borrar(xperiodo, xidalumno: String);
// Objetivo...: Borrar Cobro
begin
  datosdb.tranSQL('delete from cuotas where periodo = ' + '''' + xperiodo + '''' + ' and idalumno = ' + '''' + xidalumno + '''');
  datosdb.closeDB(cuotas); cuotas.Open;
end;

procedure TTCobro.RegistrarCobro(xperiodo, xidalumno, xitems, xfecha: String);
// Objetivo...: Registrar Cobro
begin
  if Buscar(xperiodo, xidalumno, xitems) then Begin
    cuotas.Edit;
    cuotas.FieldByName('estado').AsString := 'P';
    cuotas.FieldByName('fepago').AsString := utiles.sExprFecha2000(xfecha);
    try
      cuotas.Post
     except
      cuotas.Cancel
    end;
    datosdb.closeDB(cuotas); cuotas.Open;
  end;
end;

procedure TTCobro.BorrarCobro(xperiodo, xidalumno, xitems: String);
// Objetivo...: Borrar Cobro
begin
  if Buscar(xperiodo, xidalumno, xitems) then Begin
    cuotas.Edit;
    cuotas.FieldByName('estado').AsString := 'I';
    cuotas.FieldByName('fepago').AsString := '';
    try
      cuotas.Post
     except
      cuotas.Cancel
    end;
    datosdb.closeDB(cuotas); cuotas.Open;
  end;
end;

procedure TTCobro.ListarDetalleCuotas(xlista: TStringList; xperiodo: String; salida: char);
// Objetivo...: Listar Detalle de Cuotas
var
  i: Integer;
begin
  list.Setear(salida);
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Listado Estado de Cuotas', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Nombre del Alumno', 1, 'Arial, cursiva, 8');
  List.Titulo(40, List.lineactual, 'E', 2, 'Arial, cursiva, 8');
  List.Titulo(45, List.lineactual, 'F', 3, 'Arial, cursiva, 8');
  List.Titulo(50, List.lineactual, 'M', 4, 'Arial, cursiva, 8');
  List.Titulo(55, List.lineactual, 'A', 5, 'Arial, cursiva, 8');
  List.Titulo(60, List.lineactual, 'M', 6, 'Arial, cursiva, 8');
  List.Titulo(65, List.lineactual, 'J', 7, 'Arial, cursiva, 8');
  List.Titulo(70, List.lineactual, 'J', 8, 'Arial, cursiva, 8');
  List.Titulo(75, List.lineactual, 'A', 9, 'Arial, cursiva, 8');
  List.Titulo(80, List.lineactual, 'S', 10, 'Arial, cursiva, 8');
  List.Titulo(85, List.lineactual, 'O', 11, 'Arial, cursiva, 8');
  List.Titulo(90, List.lineactual, 'N', 12, 'Arial, cursiva, 8');
  List.Titulo(95, List.lineactual, 'D', 13, 'Arial, cursiva, 8');

  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  For i := 1 to 12 do pagos[i] := '';
  idanter := '';

  datosdb.Filtrar(cuotas, 'periodo = ' + '''' + xperiodo + '''');
  cuotas.First;
  while not cuotas.Eof do Begin
    if utiles.verificarItemsLista(xlista, cuotas.FieldByName('idalumno').AsString) then Begin
      if Length(Trim(idanter)) > 0 then
        if cuotas.FieldByName('idalumno').AsString <> idanter then ListarLineaCuotas(idanter, salida);
      if cuotas.FieldByName('estado').AsString = 'P' then pagos[cuotas.FieldByName('mes').AsInteger] := 'P';
      idanter := cuotas.FieldByName('idalumno').AsString;
    end;
    cuotas.Next;
  end;

  if Length(Trim(idanter)) > 0 then ListarLineaCuotas(idanter, salida);

  datosdb.QuitarFiltro(cuotas);

  list.FinList;
end;

procedure TTCobro.ListarCupones(xlista: TStringList; xperiodo: String; salida: char);
// Objetivo...: Listar Cupones
var
  i, j, k: Integer;
  const l = '..............................';
begin
  list.Setear(salida);
  list.NoImprimirPieDePagina;

  k := 0;
  For i := 1 to xlista.Count do Begin
    alumno.getDatos(xlista[i-1]);
    list.Linea(0, 0, 'Alumno: ' + alumno.nombre, 1, 'Arial, negrita, 12', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, negrita, 8', salida, 'S');

    For j := 10 to 12 do Begin
      if j = 10 then list.Linea(0, 0, 'Cuota Nº ' + utiles.sLlenarIzquierda(IntToStr(j), 2, '0'), 1, 'Arial, normal, 10', salida, 'N');
      if j = 10 then list.Linea(28, list.Lineactual, '|', 2, 'Arial, normal, 10', salida, 'N');
      if j = 11 then list.Linea(40, 0, 'Cuota Nº ' + utiles.sLlenarIzquierda(IntToStr(j), 2, '0'), 3, 'Arial, normal, 10', salida, 'N');
      if j = 11 then list.Linea(68, list.Lineactual, '|', 4, 'Arial, normal, 10', salida, 'N');
      if j = 12 then list.Linea(80, 0, 'Cuota Nº ' + utiles.sLlenarIzquierda(IntToStr(j), 2, '0'), 5, 'Arial, normal, 10', salida, 'S');
    end;
    list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
    For j := 10 to 12 do Begin
      if j = 10 then list.Linea(0, 0, utiles.setMes(j) + ' ' + xperiodo, 1, 'Arial, normal, 10', salida, 'N');
      if j = 10 then list.Linea(28, list.Lineactual, '|', 2, 'Arial, normal, 10', salida, 'N');
      if j = 11 then list.Linea(40, 0, utiles.setMes(j) + ' ' + xperiodo, 3, 'Arial, normal, 10', salida, 'N');
      if j = 11 then list.Linea(68, list.Lineactual, '|', 4, 'Arial, normal, 10', salida, 'N');
      if j = 12 then list.Linea(80, 0, utiles.setMes(j) + ' ' + xperiodo, 5, 'Arial, normal, 10', salida, 'S');
    end;
    list.Linea(0, 0, '', 1, 'Arial, normal, 20', salida, 'N');
    list.Linea(28, list.Lineactual, '|', 2, 'Arial, normal, 10', salida, 'N');
    list.Linea(68, list.Lineactual, '|', 3, 'Arial, normal, 10', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, normal, 20', salida, 'N');
    list.Linea(28, list.Lineactual, '|', 2, 'Arial, normal, 10', salida, 'N');
    list.Linea(68, list.Lineactual, '|', 3, 'Arial, normal, 10', salida, 'S');
    For j := 10 to 12 do Begin
      if j = 10 then list.Linea(0, 0, l, 1, 'Arial, normal, 10', salida, 'N');
      if j = 10 then list.Linea(28, list.Lineactual, '|', 2, 'Arial, normal, 10', salida, 'N');
      if j = 11 then list.Linea(40, 0, l, 3, 'Arial, normal, 10', salida, 'N');
      if j = 11 then list.Linea(68, list.Lineactual, '|', 4, 'Arial, normal, 10', salida, 'N');
      if j = 12 then list.Linea(80, 0, l, 5, 'Arial, normal, 10', salida, 'S');
    end;

    list.Linea(0, 0, list.Linealargopagina('..', salida), 1, 'Arial, normal, 11', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, normal, 10', salida, 'S');

    For j := 7 to 9 do Begin
      if j = 7 then list.Linea(0, 0, 'Cuota Nº ' + utiles.sLlenarIzquierda(IntToStr(j), 2, '0'), 1, 'Arial, normal, 10', salida, 'N');
      if j = 7 then list.Linea(28, list.Lineactual, '|', 2, 'Arial, normal, 10', salida, 'N');
      if j = 8 then list.Linea(40, 0, 'Cuota Nº ' + utiles.sLlenarIzquierda(IntToStr(j), 2, '0'), 3, 'Arial, normal, 10', salida, 'N');
      if j = 8 then list.Linea(68, list.Lineactual, '|', 4, 'Arial, normal, 10', salida, 'N');
      if j = 9 then list.Linea(80, 0, 'Cuota Nº ' + utiles.sLlenarIzquierda(IntToStr(j), 2, '0'), 5, 'Arial, normal, 10', salida, 'S');
    end;
    list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
    For j := 7 to 9 do Begin
      if j = 7 then list.Linea(0, 0, utiles.setMes(j) + ' ' + xperiodo, 1, 'Arial, normal, 10', salida, 'N');
      if j = 7 then list.Linea(28, list.Lineactual, '|', 2, 'Arial, normal, 10', salida, 'N');
      if j = 8 then list.Linea(40, 0, utiles.setMes(j) + ' ' + xperiodo, 3, 'Arial, normal, 10', salida, 'N');
      if j = 8 then list.Linea(68, list.Lineactual, '|', 4, 'Arial, normal, 10', salida, 'N');
      if j = 9 then list.Linea(80, 0, utiles.setMes(j) + ' ' + xperiodo, 5, 'Arial, normal, 10', salida, 'S');
    end;
    list.Linea(0, 0, '', 1, 'Arial, normal, 20', salida, 'N');
    list.Linea(28, list.Lineactual, '|', 2, 'Arial, normal, 10', salida, 'N');
    list.Linea(68, list.Lineactual, '|', 3, 'Arial, normal, 10', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, normal, 20', salida, 'N');
    list.Linea(28, list.Lineactual, '|', 2, 'Arial, normal, 10', salida, 'N');
    list.Linea(68, list.Lineactual, '|', 3, 'Arial, normal, 10', salida, 'S');
    For j := 7 to 9 do Begin
      if j = 7 then list.Linea(0, 0, l, 1, 'Arial, normal, 10', salida, 'N');
      if j = 7 then list.Linea(28, list.Lineactual, '|', 2, 'Arial, normal, 10', salida, 'N');
      if j = 8 then list.Linea(40, 0, l, 3, 'Arial, normal, 10', salida, 'N');
      if j = 8 then list.Linea(68, list.Lineactual, '|', 4, 'Arial, normal, 10', salida, 'N');
      if j = 9 then list.Linea(80, 0, l, 5, 'Arial, normal, 10', salida, 'S');
    end;

    list.Linea(0, 0, list.Linealargopagina('..', salida), 1, 'Arial, normal, 11', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, normal, 10', salida, 'S');

    For j := 4 to 6 do Begin
      if j = 4 then list.Linea(0, 0, 'Cuota Nº ' + utiles.sLlenarIzquierda(IntToStr(j), 2, '0'), 1, 'Arial, normal, 10', salida, 'N');
      if j = 4 then list.Linea(28, list.Lineactual, '|', 2, 'Arial, normal, 10', salida, 'N');
      if j = 5 then list.Linea(40, 0, 'Cuota Nº ' + utiles.sLlenarIzquierda(IntToStr(j), 2, '0'), 3, 'Arial, normal, 10', salida, 'N');
      if j = 5 then list.Linea(68, list.Lineactual, '|', 4, 'Arial, normal, 10', salida, 'N');
      if j = 6 then list.Linea(80, 0, 'Cuota Nº ' + utiles.sLlenarIzquierda(IntToStr(j), 2, '0'), 5, 'Arial, normal, 10', salida, 'S');
    end;
    list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
    For j := 4 to 6 do Begin
      if j = 4 then list.Linea(0, 0, utiles.setMes(j) + ' ' + xperiodo, 1, 'Arial, normal, 10', salida, 'N');
      if j = 4 then list.Linea(28, list.Lineactual, '|', 2, 'Arial, normal, 10', salida, 'N');
      if j = 5 then list.Linea(40, 0, utiles.setMes(j) + ' ' + xperiodo, 3, 'Arial, normal, 10', salida, 'N');
      if j = 5 then list.Linea(68, list.Lineactual, '|', 4, 'Arial, normal, 10', salida, 'N');
      if j = 6 then list.Linea(80, 0, utiles.setMes(j) + ' ' + xperiodo, 5, 'Arial, normal, 10', salida, 'S');
    end;
    list.Linea(0, 0, '', 1, 'Arial, normal, 20', salida, 'N');
    list.Linea(28, list.Lineactual, '|', 2, 'Arial, normal, 10', salida, 'N');
    list.Linea(68, list.Lineactual, '|', 3, 'Arial, normal, 10', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, normal, 20', salida, 'N');
    list.Linea(28, list.Lineactual, '|', 2, 'Arial, normal, 10', salida, 'N');
    list.Linea(68, list.Lineactual, '|', 3, 'Arial, normal, 10', salida, 'S');
    For j := 4 to 6 do Begin
      if j = 4 then list.Linea(0, 0, l, 1, 'Arial, normal, 10', salida, 'N');
      if j = 4 then list.Linea(28, list.Lineactual, '|', 2, 'Arial, normal, 10', salida, 'N');
      if j = 5 then list.Linea(40, 0, l, 3, 'Arial, normal, 10', salida, 'N');
      if j = 5 then list.Linea(68, list.Lineactual, '|', 4, 'Arial, normal, 10', salida, 'N');
      if j = 6 then list.Linea(80, 0, l, 5, 'Arial, normal, 10', salida, 'S');
    end;

    list.Linea(0, 0, list.Linealargopagina('..', salida), 1, 'Arial, normal, 11', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, normal, 10', salida, 'S');

    For j := 1 to 3 do Begin
      if j = 1 then list.Linea(0, 0, 'Cuota Nº ' + utiles.sLlenarIzquierda(IntToStr(j), 2, '0'), 1, 'Arial, normal, 10', salida, 'N');
      if j = 1 then list.Linea(28, list.Lineactual, '|', 2, 'Arial, normal, 10', salida, 'N');
      if j = 2 then list.Linea(40, 0, 'Cuota Nº ' + utiles.sLlenarIzquierda(IntToStr(j), 2, '0'), 3, 'Arial, normal, 10', salida, 'N');
      if j = 2 then list.Linea(68, list.Lineactual, '|', 4, 'Arial, normal, 10', salida, 'N');
      if j = 3 then list.Linea(80, 0, 'Cuota Nº ' + utiles.sLlenarIzquierda(IntToStr(j), 2, '0'), 5, 'Arial, normal, 10', salida, 'S');
    end;
    list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
    For j := 1 to 3 do Begin
      if j = 1 then list.Linea(0, 0, utiles.setMes(j) + ' ' + xperiodo, 1, 'Arial, normal, 10', salida, 'N');
      if j = 1 then list.Linea(28, list.Lineactual, '|', 2, 'Arial, normal, 10', salida, 'N');
      if j = 2 then list.Linea(40, 0, utiles.setMes(j) + ' ' + xperiodo, 3, 'Arial, normal, 10', salida, 'N');
      if j = 2 then list.Linea(68, list.Lineactual, '|', 4, 'Arial, normal, 10', salida, 'N');
      if j = 3 then list.Linea(80, 0, utiles.setMes(j) + ' ' + xperiodo, 5, 'Arial, normal, 10', salida, 'S');
    end;
    list.Linea(0, 0, '', 1, 'Arial, normal, 20', salida, 'N');
    list.Linea(28, list.Lineactual, '|', 2, 'Arial, normal, 10', salida, 'N');
    list.Linea(68, list.Lineactual, '|', 3, 'Arial, normal, 10', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, normal, 20', salida, 'N');
    list.Linea(28, list.Lineactual, '|', 2, 'Arial, normal, 10', salida, 'N');
    list.Linea(68, list.Lineactual, '|', 3, 'Arial, normal, 10', salida, 'S');
    For j := 1 to 3 do Begin
      if j = 1 then list.Linea(0, 0, l, 1, 'Arial, normal, 10', salida, 'N');
      if j = 1 then list.Linea(28, list.Lineactual, '|', 2, 'Arial, normal, 10', salida, 'N');
      if j = 2 then list.Linea(40, 0, l, 3, 'Arial, normal, 10', salida, 'N');
      if j = 2 then list.Linea(68, list.Lineactual, '|', 4, 'Arial, normal, 10', salida, 'N');
      if j = 3 then list.Linea(80, 0, l, 5, 'Arial, normal, 10', salida, 'S');
    end;

    list.Linea(0, 0, '', 1, 'Arial, normal, 16', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, normal, 16', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, normal, 16', salida, 'S');
    list.Linea(0, 0, list.Linealargopagina('..', salida), 1, 'Arial, normal, 11', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, normal, 16', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, normal, 16', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, normal, 16', salida, 'S');

    Inc(k);
    if k = 3 then Begin
      list.CompletarPagina;
      k := 0;
    end;

  end;

  list.FinList;
end;

procedure TTCobro.ListarDeudas(xlista: TStringList; xperiodo: String; salida: char);
// Objetivo...: Listar Deudas
var
  cant: Real;
  i: Integer;
  mes: String;
begin
  list.Setear(salida);
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Listado de Cuotas Adeudadas', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Nombre del Alumno', 1, 'Arial, cursiva, 8');
  List.Titulo(30, List.lineactual, 'E', 2, 'Arial, cursiva, 8');
  List.Titulo(35, List.lineactual, 'F', 3, 'Arial, cursiva, 8');
  List.Titulo(40, List.lineactual, 'M', 4, 'Arial, cursiva, 8');
  List.Titulo(45, List.lineactual, 'A', 5, 'Arial, cursiva, 8');
  List.Titulo(50, List.lineactual, 'M', 6, 'Arial, cursiva, 8');
  List.Titulo(55, List.lineactual, 'J', 7, 'Arial, cursiva, 8');
  List.Titulo(60, List.lineactual, 'J', 8, 'Arial, cursiva, 8');
  List.Titulo(65, List.lineactual, 'A', 9, 'Arial, cursiva, 8');
  List.Titulo(70, List.lineactual, 'S', 10, 'Arial, cursiva, 8');
  List.Titulo(75, List.lineactual, 'O', 11, 'Arial, cursiva, 8');
  List.Titulo(80, List.lineactual, 'N', 12, 'Arial, cursiva, 8');
  List.Titulo(85, List.lineactual, 'D', 13, 'Arial, cursiva, 8');
  List.Titulo(91, List.lineactual, 'Total', 14, 'Arial, cursiva, 8');

  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  For i := 1 to 12 do Begin
    if i <= 5 then totales[i] := 0;
    Pagos[i] := '';
  end;
  idanter := '';
  mes := Copy(utiles.setPeriodoActual, 1, 2);

  datosdb.Filtrar(cuotas, 'periodo = ' + '''' + xperiodo + '''');
  cuotas.First;
  while not cuotas.Eof do Begin
    if (utiles.verificarItemsLista(xlista, cuotas.FieldByName('idalumno').AsString)) and (cuotas.FieldByName('mes').AsString <= mes) then Begin
      if Length(Trim(idanter)) > 0 then
        if cuotas.FieldByName('idalumno').AsString <> idanter then ListarLineaCuotas(idanter, salida);
      if cuotas.FieldByName('estado').AsString = 'I' then Begin
        pagos[cuotas.FieldByName('mes').AsInteger] := 'D';
        cant := cant + 1;
        totales[1] := totales[1] + cuotas.FieldByName('monto').AsFloat;
      end;
      idanter := cuotas.FieldByName('idalumno').AsString;
    end;
    cuotas.Next;
  end;

  if Length(Trim(idanter)) > 0 then ListarLineaCuotas(idanter, salida);

  list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
  list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
  list.Linea(0, 0, 'Total a Cobrar Deuda:', 1, 'Arial, negrita, 8', salida, 'N');
  list.importe(95, list.Lineactual, '', totales[2], 2, 'Arial, negrita, 8');
  list.Linea(96, list.Lineactual, '', 3, 'Arial, negrita, 8', salida, 'S');
  totales[2] := 0;

  datosdb.QuitarFiltro(cuotas);

  list.FinList;
end;

procedure TTCobro.ListarLineaCuotas(idanter: String; salida: char);
// Objetivo...: Listar Cuotas
var
  i, j: Integer;
Begin
  alumno.getDatos(idanter);
  list.Linea(0, 0, alumno.nombre, 1, 'Arial, normal, 8', salida, 'N');
  j := 30;
  For i := 1 to 12 do Begin
    list.Linea(j, list.Lineactual, pagos[i], i+1, 'Arial, normal, 8', salida, 'N');
    j := j + 5;
  end;

  list.importe(j+5, list.Lineactual, '', totales[1], i+1, 'Arial, normal, 8');
  list.Linea(j+6, list.Lineactual, '', i+2, 'Arial, normal, 8', salida, 'S');

  For i := 1 to 12 do pagos[i] := '';
  totales[2] := totales[2] + totales[1];
  totales[1] := 0;
end;

procedure TTCobro.ListarTotalCobrado(xdesde, xhasta: String; salida: char);
// Objetivo...: Listar datos
begin
  list.Setear(salida);
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Total Cobrado en Lapso: ' + xdesde + ' - ' + xhasta, 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Fecha', 1, 'Arial, cursiva, 8');
  List.Titulo(10, List.lineactual, 'Mes', 2, 'Arial, cursiva, 8');
  List.Titulo(15, List.lineactual, 'Nombre del Alumno', 3, 'Arial, cursiva, 8');
  List.Titulo(90, List.lineactual, 'Monto', 4, 'Arial, cursiva, 8');

  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  totales[1] := 0;
  datosdb.Filtrar(cuotas, 'fepago >= ' + '''' + utiles.sExprFecha2000(xdesde) + '''' + ' and fepago <= ' + '''' + utiles.sExprFecha2000(xhasta) + '''');
  cuotas.First;
  while not cuotas.Eof do Begin
    alumno.getDatos(cuotas.FieldByName('idalumno').AsString);
    list.Linea(0, 0, utiles.sFormatoFecha(cuotas.FieldByName('fepago').AsString), 1, 'Arial, normal, 8', salida, 'N');
    list.Linea(10, list.Lineactual, cuotas.FieldByName('mes').AsString, 2, 'Arial, normal, 8', salida, 'N');
    list.Linea(15, list.Lineactual, alumno.nombre, 3, 'Arial, normal, 8', salida, 'N');
    list.importe(95, list.Lineactual, '', cuotas.FieldByName('monto').AsFloat, 4, 'Arial, normal, 8');
    list.Linea(96, list.Lineactual, '', 5, 'Arial, normal, 8', salida, 'S');
    totales[1] := totales[1] + cuotas.FieldByName('monto').AsFloat;
    cuotas.Next;
  end;

  list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
  list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
  list.Linea(0, 0, 'Total Cobrado:', 1, 'Arial, negrita, 8', salida, 'N');
  list.importe(95, list.Lineactual, '', totales[1], 2, 'Arial, negrita, 8');
  list.Linea(96, list.Lineactual, '', 3, 'Arial, negrita, 8', salida, 'S');
  totales[1] := 0;

  datosdb.QuitarFiltro(cuotas);

  list.FinList;
end;

procedure TTCobro.ListarTotalAdeudado(xdesde, xhasta: String; salida: char);
// Objetivo...: Listar datos
begin
  list.Setear(salida);
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Total Adeudado en Lapso: ' + xdesde + ' - ' + xhasta, 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Fecha', 1, 'Arial, cursiva, 8');
  List.Titulo(10, List.lineactual, 'Mes', 2, 'Arial, cursiva, 8');
  List.Titulo(15, List.lineactual, 'Nombre del Alumno', 3, 'Arial, cursiva, 8');
  List.Titulo(90, List.lineactual, 'Monto', 4, 'Arial, cursiva, 8');

  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  totales[1] := 0;
  datosdb.Filtrar(cuotas, 'fechavto >= ' + '''' + utiles.sExprFecha2000(xdesde) + '''' + ' and fechavto <= ' + '''' + utiles.sExprFecha2000(xhasta) + '''' + ' and estado = ' + '''' + 'I' + '''');
  cuotas.First;
  while not cuotas.Eof do Begin
    alumno.getDatos(cuotas.FieldByName('idalumno').AsString);
    list.Linea(0, 0, utiles.sFormatoFecha(cuotas.FieldByName('fechavto').AsString), 1, 'Arial, normal, 8', salida, 'N');
    list.Linea(10, list.Lineactual, cuotas.FieldByName('mes').AsString, 2, 'Arial, normal, 8', salida, 'N');
    list.Linea(15, list.Lineactual, alumno.nombre, 3, 'Arial, normal, 8', salida, 'N');
    list.importe(95, list.Lineactual, '', cuotas.FieldByName('monto').AsFloat, 4, 'Arial, normal, 8');
    list.Linea(96, list.Lineactual, '', 5, 'Arial, normal, 8', salida, 'S');
    totales[1] := totales[1] + cuotas.FieldByName('monto').AsFloat;
    cuotas.Next;
  end;

  list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
  list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
  list.Linea(0, 0, 'Total Cobrado:', 1, 'Arial, negrita, 8', salida, 'N');
  list.importe(95, list.Lineactual, '', totales[1], 2, 'Arial, negrita, 8');
  list.Linea(96, list.Lineactual, '', 3, 'Arial, negrita, 8', salida, 'S');
  totales[1] := 0;

  datosdb.QuitarFiltro(cuotas);

  list.FinList;
end;

procedure TTCobro.conectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones = 0 then Begin
    if not cuotas.Active then cuotas.Open;
  end;
  Inc(conexiones);
  alumno.conectar;
end;

procedure TTCobro.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  Dec(conexiones);
  if conexiones = 0 then Begin
     datosdb.closeDB(cuotas);
  end;
  alumno.desconectar;
end;

{===============================================================================}

function cobro: TTCobro;
begin
  if xcobro = nil then
    xcobro := TTCobro.Create;
  Result := xcobro;
end;

{===============================================================================}

initialization

finalization
  xcobro.Free;

end.
