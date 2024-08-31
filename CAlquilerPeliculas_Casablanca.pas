unit CAlquilerPeliculas_Casablanca;

interface

uses CGeneros_Casablanca, CClienteCasaBlanca, CCPeliculasCasablanca, CBDT, SysUtils, DBTables, CUtiles, CListar, CIDBFM, Classes;

type

TTAlquilerPeliculas = class
  Nroalquiler, Fecha, Hora, Codcli, Devuelto: String;
  Total, Pago: Real;
  Recargo: Real; Intervalo1, Intervalo2, Diasdev, HoraFact: String;
  detInf: Boolean;
  cabalquiler, detalquiler, parametros: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  { Alquileres }
  function    Nuevo: String;
  function    Buscar(xnroalquiler: String): Boolean;
  function    BuscarItems(xnroalquiler, xitems: String): Boolean;
  procedure   Guardar(xnroalquiler, xfecha, xhora, xcodcli, xitems, xcodigo: String; xmonto, xabona, xtotal: Real; xcantidadItems: Integer);
  procedure   Borrar(xnroalquiler: String);
  procedure   getDatos(xnroalquiler: String);
  function    setPeliculasAlquiladas: TStringList;
  function    setPeliculasAdeudadas(xcodcli: String): TStringList;
  function    setRecargos: TStringList;
  function    setListaPeliculasAdeudadas(xcodcli: String): TStringList;
  function    setListaPeliculasDevueltas(xcodcli: String): TStringList;
  function    setListaPeliculas(xnroalquiler: String): TStringList;

  { Devoluciones }
  procedure   RegistrarDevolucion(xnroalquiler, xfechadev, xdevuelto: String; xrecargo, xpago: Real);
  procedure   AnularDevolucion(xnroalquiler: String);
  procedure   RegistrarPeliculaDevuelta(xnroalquiler, xitems, xdevuelta: String);

  { Canjes }
  procedure   RegistrarCanje(xnroalquiler, xitems, xcodigo, xfechacanje: String);
  function    setCodigoCanje(xnroalquiler, xitems: String): String;

  { Informes }
  procedure   ListarPeliculasAlquiladas(xdesde, xhasta: String; salida: char);
  procedure   ListarPeliculasDevueltas(xdesde, xhasta: String; salida: char);

  { Parámetros }
  procedure   EstablecerParametros(xrecargo: Real; xintervalo1, xintervalo2, xdiasdev, xhorafact: String);
  procedure   getParametros;

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  conexiones: shortint;
  lista: TStringList;
  totales: array[1..5] of Real;
  idanter: String;
  procedure   ListarLinea(xnroalquiler: String; salida: char);
end;

function alquilerpelicula: TTAlquilerPeliculas;

implementation

var
  xalquilerpelicula: TTAlquilerPeliculas = nil;

constructor TTAlquilerPeliculas.Create;
begin
  cabalquiler := datosdb.openDB('pedidos_cab', '');
  detalquiler := datosdb.openDB('pedidos_det', '');
  parametros  := datosdb.openDB('parametros_video', '');
end;

destructor TTAlquilerPeliculas.Destroy;
begin
  inherited Destroy;
end;

function   TTAlquilerPeliculas.Nuevo: String;
// Objetivo...: Crear Nuevo Número de alquiler
Begin
  if cabalquiler.IndexFieldNames <> 'nroalquiler' then cabalquiler.IndexFieldNames := 'nroalquiler';
  cabalquiler.Last;
  if cabalquiler.RecordCount = 0 then Result := '1' else Result := IntToStr(cabalquiler.FieldByName('nroalquiler').AsInteger + 1);
end;

function   TTAlquilerPeliculas.Buscar(xnroalquiler: String): Boolean;
// Objetivo...: Buscar un numero
Begin
  if cabalquiler.IndexFieldNames <> 'nroalquiler' then cabalquiler.IndexFieldNames := 'nroalquiler';
  Result := cabalquiler.FindKey([xnroalquiler]);
end;

function   TTAlquilerPeliculas.BuscarItems(xnroalquiler, xitems: String): Boolean;
// Objetivo...: Buscar un numero
Begin
  if detalquiler.IndexFieldNames <> 'nroalquiler;items' then detalquiler.IndexFieldNames := 'nroalquiler;items';
  Result := datosdb.Buscar(detalquiler, 'nroalquiler', 'items', xnroalquiler, xitems);
end;

procedure  TTAlquilerPeliculas.Guardar(xnroalquiler, xfecha, xhora, xcodcli, xitems, xcodigo: String; xmonto, xabona, xtotal: Real; xcantidadItems: Integer);
// Objetivo...: Registrar una Alquiler
Begin
  if xitems = '001' then Begin
    if Buscar(xnroalquiler) then cabalquiler.Edit else cabalquiler.Append;
    cabalquiler.FieldByName('nroalquiler').AsString := xnroalquiler;
    cabalquiler.FieldByName('fecha').AsString       := utiles.sExprFecha2000(xfecha);
    cabalquiler.FieldByName('hora').AsString        := xhora;
    cabalquiler.FieldByName('codcli').AsString      := xcodcli;
    cabalquiler.FieldByName('abona').AsFloat        := xabona;
    cabalquiler.FieldByName('total').AsFloat        := xtotal;
    cabalquiler.FieldByName('pago').AsFloat         := xtotal;
    cabalquiler.FieldByName('devuelto').AsString    := 'N';
    try
      cabalquiler.Post
     except
      cabalquiler.Cancel
    end;
    datosdb.refrescar(cabalquiler);
  end;

  if BuscarItems(xnroalquiler, xitems) then detalquiler.Edit else detalquiler.Append;
  detalquiler.FieldByName('nroalquiler').AsString := xnroalquiler;
  detalquiler.FieldByName('items').AsString       := xitems;
  detalquiler.FieldByName('codigo').AsString      := xcodigo;
  detalquiler.FieldByName('devuelta').AsString    := 'N';
  detalquiler.FieldByName('monto').AsFloat        := xmonto;
  try
    detalquiler.Post
   except
    detalquiler.Cancel
  end;
  pelicula.AlquilarPelicula(xcodigo, 'S');
  if xitems = utiles.sLlenarIzquierda(IntToStr(xcantidadItems), 3, '0') then datosdb.tranSQL('delete from ' + detalquiler.TableName + ' where nroalquiler = ' + '"' + xnroalquiler + '"' + ' and items > ' + '"' + xitems + '"');
  datosdb.refrescar(detalquiler);
end;

procedure  TTAlquilerPeliculas.Borrar(xnroalquiler: String);
// Objetivo...: Borrar un Alquiler
Begin
  if BuscarItems(xnroalquiler, '001') then Begin
    while not detalquiler.Eof do Begin
      if detalquiler.FieldByName('nroalquiler').AsString <> xnroalquiler then Break;
      pelicula.AlquilarPelicula(detalquiler.FieldByName('codigo').AsString, 'N');
      detalquiler.Next;
    end;
  end;
  if Buscar(xnroalquiler) then Begin
    cabalquiler.Delete;
    datosdb.tranSQL('delete from ' + detalquiler.TableName + ' where nroalquiler = ' + '"' + xnroalquiler + '"');
    datosdb.refrescar(cabalquiler);
    datosdb.refrescar(detalquiler);
  end;
end;

procedure  TTAlquilerPeliculas.getDatos(xnroalquiler: String);
// Obketivo...: cargar una instancia
Begin
  if Buscar(xnroalquiler) then Begin
    Nroalquiler := cabalquiler.FieldByName('nroalquiler').AsString;
    Fecha       := utiles.sFormatoFecha(cabalquiler.FieldByName('fecha').AsString);
    Hora        := cabalquiler.FieldByName('hora').AsString;
    Codcli      := cabalquiler.FieldByName('codcli').AsString;
    Devuelto    := cabalquiler.FieldByName('devuelto').AsString;
    total       := cabalquiler.FieldByName('total').AsFloat;
    Pago        := cabalquiler.FieldByName('pago').AsFloat;
  end else Begin
    Nroalquiler := ''; Fecha := ''; Hora := ''; Codcli := ''; total := 0; Pago := 0; Devuelto := 'N';
  end;
end;

function TTAlquilerPeliculas.setPeliculasAlquiladas: TStringList;
// Objetivo...: Obtener un set de peliculas alquiladas
var
  l: TStringList;
Begin
  l := TStringList.Create;
  if Length(Trim(nroalquiler)) > 0 then Begin
    if BuscarItems(nroalquiler, '001') then Begin
      while not detalquiler.Eof do Begin
        if detalquiler.FieldByName('nroalquiler').AsString <> nroalquiler then Break;
        l.Add(detalquiler.FieldByName('items').AsString + detalquiler.FieldByName('codigo').AsString + detalquiler.FieldByName('monto').AsString);
        detalquiler.Next;
      end;
    end;
  end;
  Result := l;
end;

function TTAlquilerPeliculas.setPeliculasAdeudadas(xcodcli: String): TStringList;
// Objetivo...: Obtener un set de peliculas adeudadas
var
  l: TStringList;
Begin
  idanter := cabalquiler.FieldByName('nroalquiler').AsString;
  l := TStringList.Create; lista := TStringList.Create;
  datosdb.Filtrar(cabalquiler, 'codcli = ' + '''' + xcodcli + ''''+ ' and devuelto <> ' + '''' + 'S' + '''');
  while not cabalquiler.Eof do Begin
    if (cabalquiler.FieldByName('devuelto').AsString = 'N') or (cabalquiler.FieldByName('devuelto').AsString = 'P') then Begin
      l.Add('Nº Alq.: ' + cabalquiler.FieldByName('nroalquiler').AsString + ' - Fecha: ' + utiles.sFormatoFecha(cabalquiler.FieldByName('fecha').AsString) + ' - Hora: ' + cabalquiler.FieldByName('hora').AsString + ' - Monto: ' + utiles.FormatearNumero(cabalquiler.FieldByName('total').AsString));
      if cabalquiler.FieldByName('recargo').AsFloat > 0 then   // Aislamos los recargos
        lista.Add(utiles.sFormatoFecha(cabalquiler.FieldByName('fecha').AsString) + utiles.sFormatoFecha(cabalquiler.FieldByName('fechadev').AsString) + cabalquiler.FieldByName('nroalquiler').AsString + cabalquiler.FieldByName('recargo').AsString);

      if BuscarItems(cabalquiler.FieldByName('nroalquiler').AsString, '001') then Begin
        while not detalquiler.Eof do Begin
          if detalquiler.FieldByName('nroalquiler').AsString <> cabalquiler.FieldByName('nroalquiler').AsString then Break;
          pelicula.getDatos(detalquiler.FieldByName('codigo').AsString);
          l.Add('   ' + detalquiler.FieldByName('items').AsString + '  ' + detalquiler.FieldByName('codigo').AsString + '-' + pelicula.Descrip);
          detalquiler.Next;
        end;
      end;
    end;
    cabalquiler.Next;
  end;
  datosdb.QuitarFiltro(cabalquiler);
  Buscar(idanter);

  Result := l;
end;

function TTAlquilerPeliculas.setListaPeliculasAdeudadas(xcodcli: String): TStringList;
// Objetivo...: Obtener un set de peliculas adeudadas
var
  l: TStringList;
Begin
  l := TStringList.Create;
  datosdb.Filtrar(cabalquiler, 'codcli = ' + '''' + xcodcli + '''' + ' and devuelto <> ' + '''' + 'S' + '''');
  while not cabalquiler.Eof do Begin
    l.Add(cabalquiler.FieldByName('nroalquiler').AsString + utiles.sFormatoFecha(cabalquiler.FieldByName('fecha').AsString) + cabalquiler.FieldByName('hora').AsString + utiles.FormatearNumero(cabalquiler.FieldByName('total').AsString));
    cabalquiler.Next;
  end;
  datosdb.QuitarFiltro(cabalquiler);

  Result := l;
end;

function TTAlquilerPeliculas.setListaPeliculasDevueltas(xcodcli: String): TStringList;
// Objetivo...: Obtener un set de peliculas adeudadas
var
  l: TStringList;
Begin
  l := TStringList.Create;
  datosdb.Filtrar(cabalquiler, 'codcli = ' + '''' + xcodcli + '''' + ' and devuelto = ' + '''' + 'S' + '''');
  while not cabalquiler.Eof do Begin
    l.Add(cabalquiler.FieldByName('nroalquiler').AsString + utiles.sFormatoFecha(cabalquiler.FieldByName('fecha').AsString) + cabalquiler.FieldByName('hora').AsString + utiles.FormatearNumero(cabalquiler.FieldByName('total').AsString));
    cabalquiler.Next;
  end;
  datosdb.QuitarFiltro(cabalquiler);

  Result := l;
end;

function  TTAlquilerPeliculas.setListaPeliculas(xnroalquiler: String): TStringList;
// Objetivo...: devolver recragos
var
  l: TStringList;
Begin
  l := TStringList.Create;
  if BuscarItems(cabalquiler.FieldByName('nroalquiler').AsString, '001') then Begin
    while not detalquiler.Eof do Begin
      if detalquiler.FieldByName('nroalquiler').AsString <> cabalquiler.FieldByName('nroalquiler').AsString then Break;
      pelicula.getDatos(detalquiler.FieldByName('codigo').AsString);
      l.Add(detalquiler.FieldByName('items').AsString + detalquiler.FieldByName('codigo').AsString + detalquiler.FieldByName('devuelta').AsString + detalquiler.FieldByName('monto').AsString + ';1' + detalquiler.FieldByName('codcanje').AsString);
      detalquiler.Next;
    end;
  end;
  Result := l;
end;

function  TTAlquilerPeliculas.setRecargos: TStringList;
// Objetivo...: devolver recragos
Begin
  Result := lista;
end;

procedure TTAlquilerPeliculas.RegistrarDevolucion(xnroalquiler, xfechadev, xdevuelto: String; xrecargo, xpago: Real);
// Objetivo...: estabelcer parámetros
begin
  if Buscar(xnroalquiler) then Begin
    cabalquiler.Edit;
    cabalquiler.FieldByName('fechadev').AsString     := utiles.sExprFecha2000(xfechadev);
    cabalquiler.FieldByName('abonarecargo').AsFloat  := xpago;
    cabalquiler.FieldByName('recargo').AsFloat       := xrecargo;
    cabalquiler.FieldByName('devuelto').AsString     := xdevuelto;
    try
      cabalquiler.Post
     except
      cabalquiler.Cancel
    end;
    datosdb.refrescar(cabalquiler);
  end;
end;

procedure TTAlquilerPeliculas.AnularDevolucion(xnroalquiler: String);
// Objetivo...: Anular Devolución
begin
  if Buscar(xnroalquiler) then Begin
    cabalquiler.Edit;
    cabalquiler.FieldByName('fechadev').AsString     := '';
    cabalquiler.FieldByName('abonarecargo').AsFloat  := 0;
    cabalquiler.FieldByName('recargo').AsFloat       := 0;
    cabalquiler.FieldByName('devuelto').AsString     := 'N';
    try
      cabalquiler.Post
     except
      cabalquiler.Cancel
    end;
    datosdb.refrescar(cabalquiler);

    if BuscarItems(xnroalquiler, '001') then Begin
      while not detalquiler.Eof do Begin
        if detalquiler.FieldByName('nroalquiler').AsString <> xnroalquiler then Break;
        detalquiler.Edit;
        detalquiler.FieldByName('devuelta').AsString := 'N';
        try
          detalquiler.Post
         except
          detalquiler.Cancel
        end;
        datosdb.refrescar(detalquiler);
        pelicula.AlquilarPelicula(detalquiler.FieldByName('codigo').AsString, 'S');
        detalquiler.Next;
      end;
    end;
  end;
end;

procedure TTAlquilerPeliculas.RegistrarPeliculaDevuelta(xnroalquiler, xitems, xdevuelta: String);
// Objetivo...: estabelcer parámetros
begin
  if BuscarItems(xnroalquiler, xitems) then Begin
    detalquiler.Edit;
    detalquiler.FieldByName('devuelta').AsString     := xdevuelta;
    try
      detalquiler.Post
     except
      detalquiler.Cancel
    end;
    pelicula.AlquilarPelicula(detalquiler.FieldByName('codigo').AsString, 'N');
    datosdb.refrescar(detalquiler);
  end;
end;

procedure TTAlquilerPeliculas.RegistrarCanje(xnroalquiler, xitems, xcodigo, xfechacanje: String);
// Objetivo...: Registrar Peliculas en Canje
var
  xcod: String;
Begin
  if Buscar(xnroalquiler) then Begin
    xcod := detalquiler.FieldByName('codcanje').AsString;
    cabalquiler.Edit;
    cabalquiler.FieldByName('fechacanje').AsString := utiles.sExprFecha2000(xfechacanje);
    try
      cabalquiler.Post
     except
      cabalquiler.Cancel
    end;
    datosdb.refrescar(cabalquiler);
  end;
  if BuscarItems(xnroalquiler, xitems) then Begin
    detalquiler.Edit;
    detalquiler.FieldByName('codcanje').AsString := xcodigo;
    if Length(Trim(xfechacanje)) = 8 then detalquiler.FieldByName('fechadev').AsString := utiles.sExprFecha2000(xfechacanje);
    try
      detalquiler.Post
     except
      detalquiler.Cancel
    end;
    pelicula.AlquilarPelicula(detalquiler.FieldByName('codigo').AsString, 'N');  // Quitamos la que cambia
    if Length(Trim(xcodigo)) > 0 then pelicula.AlquilarPelicula(detalquiler.FieldByName('codcanje').AsString, 'S') else pelicula.AlquilarPelicula(xcod, 'N');  // Aplicamos a la de canje
    datosdb.refrescar(detalquiler);
  end;
end;

function  TTAlquilerPeliculas.setCodigoCanje(xnroalquiler, xitems: String): String;
// Objetivo...: devolver codigo de canje
Begin
  if BuscarItems(xnroalquiler, xitems) then Result := detalquiler.FieldByName('codcanje').AsString else Result := '';
end;

procedure TTAlquilerPeliculas.ListarPeliculasAlquiladas(xdesde, xhasta: String; salida: char);
// Objetivo...: Listar Peliculas Alquiladas
Begin
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Películas Alquiladas - Período: ' + xdesde + '-' + xhasta, 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, '       Código', 1, 'Arial, cursiva, 8');
  List.Titulo(10, List.lineactual, 'Nombre  de la Película', 2, 'Arial, cursiva, 8');
  List.Titulo(65, List.lineactual, 'Monto', 3, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  totales[1] := 0; totales[2] := 0;
  datosdb.Filtrar(cabalquiler, 'fecha >= ' + '''' + utiles.sExprFecha2000(xdesde) + '''' + ' and fecha <= ' + '''' + utiles.sExprFecha2000(xhasta) + '''');
  cabalquiler.First;
  while not cabalquiler.Eof do Begin
    if cabalquiler.FieldByName('devuelto').AsString = 'N' then Begin
      cliente.getDatos(cabalquiler.FieldByName('codcli').AsString);
      list.Linea(0, 0, 'Nº Alquiler:  ' + cabalquiler.FieldByName('nroalquiler').AsString, 1, 'Arial, negrita, 8', salida, 'N');
      list.Linea(20, list.Lineactual, 'Fecha:  ' + utiles.sFormatoFecha(cabalquiler.FieldByName('fecha').AsString), 2, 'Arial, negrita, 8', salida, 'N');
      list.Linea(35, list.Lineactual, 'Cliente:  ' + cliente.Nombre, 3, 'Arial, normal, 9', salida, 'N');
      list.Linea(85, list.Lineactual, 'Monto:  $  ' + utiles.FormatearNumero(cabalquiler.FieldByName('total').AsString), 4, 'Arial, negrita, 8', salida, 'S');

      ListarLinea(cabalquiler.FieldByName('nroalquiler').AsString, salida);
      totales[1] := totales[1] + 1;
      totales[2] := totales[2] + cabalquiler.FieldByName('total').AsFloat;
    end;
    cabalquiler.Next;
  end;
  datosdb.QuitarFiltro(cabalquiler);

  if totales[1] > 0 then Begin
    list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
    list.Linea(0, 0, 'Cantidad de Alquileres:   ' + utiles.FormatearNumero(FloatToStr(totales[1]), '####'), 1, 'Arial, negrita, 8', salida, 'S');
    list.Linea(0, 0, 'Monto Total Alquileres:   $  ' + utiles.FormatearNumero(FloatToStr(totales[2])), 1, 'Arial, negrita, 8', salida, 'S');
  end;

  list.FinList;
end;

procedure TTAlquilerPeliculas.ListarLinea(xnroalquiler: String; salida: char);
// Objetivo...: Listar Linea de Pedido
Begin
  if detInf then Begin
    if BuscarItems(xnroalquiler, '001') then Begin
      while not detalquiler.Eof do Begin
        if detalquiler.FieldByName('nroalquiler').AsString <> xnroalquiler then Break;
        pelicula.getDatos(detalquiler.FieldByName('codigo').AsString);
        list.Linea(0, 0, '       ' + detalquiler.FieldByName('codigo').AsString + '   ' + pelicula.Descrip, 1, 'Arial, normal, 8', salida, 'N');
        list.importe(70, list.Lineactual, '', detalquiler.FieldByName('monto').AsFloat, 2, 'Arial, normal, 8');
        list.Linea(72, list.Lineactual, ' ', 3, 'Arial, normal, 8', salida, 'S');
        detalquiler.Next;
      end;
    end;
    list.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');
  end;
end;

procedure TTAlquilerPeliculas.ListarPeliculasDevueltas(xdesde, xhasta: String; salida: char);
// Objetivo...: Listar Peliculas Alquiladas
Begin
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Películas Devueltas - Período: ' + xdesde + '-' + xhasta, 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, '       Código', 1, 'Arial, cursiva, 8');
  List.Titulo(10, List.lineactual, 'Nombre  de la Película', 2, 'Arial, cursiva, 8');
  List.Titulo(65, List.lineactual, 'Monto', 3, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  totales[1] := 0; totales[2] := 0;
  datosdb.Filtrar(cabalquiler, 'fecha >= ' + '''' + utiles.sExprFecha2000(xdesde) + '''' + ' and fecha <= ' + '''' + utiles.sExprFecha2000(xhasta) + '''');
  cabalquiler.First;
  while not cabalquiler.Eof do Begin
    if cabalquiler.FieldByName('devuelto').AsString = 'S' then Begin
      cliente.getDatos(cabalquiler.FieldByName('codcli').AsString);
      list.Linea(0, 0, 'Nº Alquiler:  ' + cabalquiler.FieldByName('nroalquiler').AsString, 1, 'Arial, negrita, 8', salida, 'N');
      list.Linea(20, list.Lineactual, 'Fecha:  ' + utiles.sFormatoFecha(cabalquiler.FieldByName('fecha').AsString), 2, 'Arial, negrita, 8', salida, 'N');
      list.Linea(35, list.Lineactual, 'Cliente:  ' + cliente.Nombre, 3, 'Arial, normal, 9', salida, 'N');
      list.Linea(85, list.Lineactual, 'Monto:  $  ' + utiles.FormatearNumero(cabalquiler.FieldByName('total').AsString), 4, 'Arial, negrita, 8', salida, 'S');

      ListarLinea(cabalquiler.FieldByName('nroalquiler').AsString, salida);
      totales[1] := totales[1] + 1;
      totales[2] := totales[2] + cabalquiler.FieldByName('total').AsFloat;
    end;
    cabalquiler.Next;
  end;
  datosdb.QuitarFiltro(cabalquiler);

  if totales[1] > 0 then Begin
    list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
    list.Linea(0, 0, 'Cantidad de Alquileres:   ' + utiles.FormatearNumero(FloatToStr(totales[1]), '####'), 1, 'Arial, negrita, 8', salida, 'S');
    list.Linea(0, 0, 'Monto Total Alquileres:   $  ' + utiles.FormatearNumero(FloatToStr(totales[2])), 1, 'Arial, negrita, 8', salida, 'S');
  end;

  list.FinList;
end;

procedure TTAlquilerPeliculas.EstablecerParametros(xrecargo: Real; xintervalo1, xintervalo2, xdiasdev, xhorafact: String);
// Objetivo...: estabelcer parámetros
begin
  parametros.Open;
  if parametros.FindKey(['01']) then parametros.Edit else parametros.Append;
  parametros.FieldByName('id').AsString        := '01';
  parametros.FieldByName('recargo').AsFloat    := xrecargo;
  parametros.FieldByName('horadev').AsString   := xintervalo1;
  parametros.FieldByName('horadevsc').AsString := xintervalo2;
  parametros.FieldByName('diasdev').AsString   := xdiasdev;
  parametros.FieldByName('horafact').AsString  := xhorafact;
  try
    parametros.Post
   except
    parametros.Cancel
  end;
  datosdb.closeDB(parametros);
end;

procedure TTAlquilerPeliculas.getParametros;
// Objetivo...: establecer parámetros
begin
  parametros.Open;
  if parametros.FindKey(['01']) then Begin
    recargo    := parametros.FieldByName('recargo').AsFloat;
    intervalo1 := parametros.FieldByName('horadev').AsString;
    intervalo2 := parametros.FieldByName('horadevsc').AsString;
    diasdev    := parametros.FieldByName('diasdev').AsString;
    horaFact   := parametros.FieldByName('horafact').AsString;
  end else Begin
    recargo    := 3.50;
    intervalo1 := '19:30';
    intervalo2 := '13:00';
    diasdev    := '1';
    horafact   := '05:00';
  end;
  datosdb.closeDB(parametros);
end;

procedure TTAlquilerPeliculas.conectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones = 0 then Begin
    if not cabalquiler.Active then cabalquiler.Open;
    if not detalquiler.Active then detalquiler.Open;
  end;
  Inc(conexiones);
  pelicula.conectar;
  cliente.conectar;
  getParametros;
end;

procedure TTAlquilerPeliculas.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  Dec(conexiones);
  if conexiones = 0 then Begin
    if cabalquiler.Active then cabalquiler.Close;
    if detalquiler.Active then detalquiler.Close;
  end;
  pelicula.desconectar;
  cliente.desconectar;
end;

{===============================================================================}

function alquilerpelicula: TTAlquilerPeliculas;
begin
  if xalquilerpelicula = nil then
    xalquilerpelicula := TTAlquilerPeliculas.Create;
  Result := xalquilerpelicula;
end;

{===============================================================================}

initialization

finalization
  xalquilerpelicula.Free;

end.
