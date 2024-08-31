unit CTablaEscalafonIS4DBExpress;

interface

uses SysUtils, DBClient, CdbExpressBase, CUtiles, CListar, Contnrs, Classes;

type

TTEscalafon = class
  Items, Descrip, Subitems, Concepto, Global, Abreviatura, ItemsEscala, SubitemsEscala,
  LineaEscala, EvaluacionEscala, Evaluacion, Requerido, Agrupa, Abreviat, DisAntiguedad, Orden: String;
  Puntaje, Maximo, MaximoEscala, MinimoEscala, PuntajeEscala, Validez: Real;

  tabla1, tabla2, tabla3: TClientDataSet;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  function    BuscarItems(xitems: String): Boolean;
  procedure   RegistrarItems(xitems, xdescrip, xrequerido, xabreviatura, xorden: String);
  procedure   BorrarItems(xitems: String);
  procedure   getDatosItems(xitems: String);

  function    BuscarConcepto(xitems, xsubitems: String): Boolean;
  procedure   RegistrarConcepto(xitems, xsubitems, xconcepto, xglobal, xabreviatura, xevaluacion, xagrupa: String; xpuntaje, xmaximo, xvalidez: Real);
  procedure   BorrarConcepto(xitems, xsubitems: String);
  procedure   getDatosConcepto(xitems, xsubitems: String);
  procedure   RegistrarDiscAntiguedad(xitems, xsubitems: String; xdiscrimina: Boolean);

  function    setConceptos(xitems: String): TObjectList;

  procedure   Listar(xitems: String; salida: char);

  function    BuscarEscala(xitems, xsubitems, xlinea: String): Boolean;
  procedure   RegistrarEscala(xitems, xsubitems, xlinea: String; xmaximo, xminimo, xpuntaje: Real; xeval: String; xcantitems: Integer);
  procedure   BorrarEscala(xitems, xsubitems: String);
  function    setItemsEscala(xitems, xsubitems: String): TObjectList;
  function    setPuntaje(xitems, xsubitems, xeval: String; xcantidad: Real): Real;

  function    setItemsRequeridosEscalafonPrincipal: TStringList;

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  conexiones: shortint;
end;

function tablaes: TTEscalafon;

implementation

var
  xtablaescalafon: TTEscalafon = nil;

constructor TTEscalafon.Create;
begin
  tabla1 := dbEx.conn.InstanciarTabla('escalafon');
  tabla2 := dbEx.conn.InstanciarTabla('itemsescalafon');
  tabla3 := dbEx.conn.InstanciarTabla('puntajeescala');
end;

destructor TTEscalafon.Destroy;
begin
  inherited Destroy;
end;

function  TTEscalafon.BuscarItems(xitems: String): Boolean;
// Objetivo...: recuperar una instancia
begin
  if tabla1.IndexFieldNames <> 'Items' then tabla1.IndexFieldNames := 'Items';
  Result := tabla1.FindKey([xitems]);
end;

procedure TTEscalafon.RegistrarItems(xitems, xdescrip, xrequerido, xabreviatura, xorden: String);
// Objetivo...: persistir una instancia
begin
  if BuscarItems(xitems) then tabla1.Edit else tabla1.Append;
  tabla1.FieldByName('items').AsString       := xitems;
  tabla1.FieldByName('descrip').AsString     := xdescrip;
  tabla1.FieldByName('requerido').AsString   := xrequerido;
  tabla1.FieldByName('abreviatura').AsString := xabreviatura;
  tabla1.FieldByName('orden').AsString       := xorden;
  try
    tabla1.Post
   except
    tabla1.Cancel
  end;
  tabla1.ApplyUpdates(-1);
end;

procedure TTEscalafon.BorrarItems(xitems: String);
// Objetivo...: borrar una instancia
begin
  if BuscarItems(xitems) then Begin
    tabla1.Delete;
    tabla1.ApplyUpdates(-1);
    dbEx.conn.tranSQL('delete from itemsescalafon where items = ' + '''' + xitems + '''');
    tabla2.ApplyUpdates(-1);
  end;
end;

procedure TTEscalafon.getDatosItems(xitems: String);
// Objetivo...: cargar una instancia
begin
  if BuscarItems(xitems) then Begin
    Items     := tabla1.FieldByName('items').AsString;
    Descrip   := tabla1.FieldByName('descrip').AsString;
    Requerido := tabla1.FieldByName('requerido').AsString;
    Abreviat  := tabla1.FieldByName('abreviatura').AsString;
    Orden     := tabla1.FieldByName('orden').AsString;
  end else Begin
    Items := ''; Descrip := ''; Requerido := 'N'; abreviat := ''; orden := xitems;
  end;
  if Length(Trim(requerido)) = 0 then Requerido := 'N';
end;

function  TTEscalafon.BuscarConcepto(xitems, xsubitems: String): Boolean;
// Objetivo...: recuperar una instancia
begin
  if tabla2.IndexFieldNames <> 'Items;Subitems' then tabla2.IndexFieldNames := 'Items;Subitems';
  Result := dbEx.conn.Buscar(tabla2, 'Items', 'Subitems', xitems, xsubitems);
end;

procedure TTEscalafon.RegistrarConcepto(xitems, xsubitems, xconcepto, xglobal, xabreviatura, xevaluacion, xagrupa: String; xpuntaje, xmaximo, xvalidez: Real);
// Objetivo...: persistir una instancia
begin
  if BuscarConcepto(xitems, xsubitems) then tabla2.Edit else tabla2.Append;
  tabla2.FieldByName('items').AsString       := xitems;
  tabla2.FieldByName('subitems').AsString    := xsubitems;
  tabla2.FieldByName('descrip').AsString     := xconcepto;
  tabla2.FieldByName('globalit').AsString      := xglobal;
  tabla2.FieldByName('abreviatura').AsString := xabreviatura;
  tabla2.FieldByName('eval').AsString        := xevaluacion;
  tabla2.FieldByName('agrupa').AsString      := xagrupa;
  tabla2.FieldByName('puntaje').AsFloat      := xpuntaje;
  tabla2.FieldByName('maximo').AsFloat       := xmaximo;
  tabla2.FieldByName('validez').AsFloat      := xvalidez;
  try
    tabla2.Post
   except
    tabla2.Cancel
  end;
  tabla2.ApplyUpdates(-1);
end;

procedure TTEscalafon.BorrarConcepto(xitems, xsubitems: String);
// Objetivo...: borrar una instancia
begin
  if BuscarConcepto(xitems, xsubitems) then Begin
    tabla2.Delete;
    tabla2.ApplyUpdates(-1);
  end;
end;

procedure TTEscalafon.getDatosConcepto(xitems, xsubitems: String);
// Objetivo...: cargar una instancia
begin
  if BuscarConcepto(xitems, xsubitems) then Begin
    Items         := tabla2.FieldByName('items').AsString;
    subitems      := tabla2.FieldByName('subitems').AsString;
    Concepto      := tabla2.FieldByName('descrip').AsString;
    Global        := tabla2.FieldByName('globalit').AsString;
    Abreviatura   := tabla2.FieldByName('abreviatura').AsString;
    Evaluacion    := tabla2.FieldByName('eval').AsString;
    Agrupa        := tabla2.FieldByName('agrupa').AsString;
    Puntaje       := tabla2.FieldByName('puntaje').AsFloat;
    Maximo        := tabla2.FieldByName('maximo').AsFloat;
    Validez       := tabla2.FieldByName('validez').AsFloat;
    Disantiguedad := tabla2.FieldByName('disantiguedad').AsString;
  end else Begin
    Items := ''; Subitems := ''; Concepto := ''; Puntaje := 0; Maximo := 0; Global := '';
    abreviatura := ''; Evaluacion := ''; Validez := 0; Agrupa := ''; Disantiguedad := 'N';
  end;
end;

procedure TTEscalafon.RegistrarDiscAntiguedad(xitems, xsubitems: String; xdiscrimina: Boolean);
// Objetivo...: Determinar si discrimina o no la antiguedad
Begin
  if BuscarConcepto(xitems, xsubitems) then Begin
    tabla2.Edit;
    if xdiscrimina then tabla2.FieldByName('disantiguedad').AsString := 'S' else tabla2.FieldByName('disantiguedad').AsString := 'N';
    try
      tabla2.Post
     except
      tabla2.Cancel
    end;
    tabla2.ApplyUpdates(-1);
  end;
end;

function  TTEscalafon.setConceptos(xitems: String): TObjectList;
// Objetivo...: devolver set de materias para una carrera
var
  l: TObjectList;
  objeto: TTEscalafon;
begin
  l := TObjectList.Create;
  if Length(Trim(xitems)) > 0 then Begin
    dbEx.conn.Filtrar(tabla2, 'items = ' + '''' + xitems + '''');
    tabla2.First;
    while not tabla2.Eof do Begin
      objeto               := TTEscalafon.Create;
      objeto.Items         := tabla2.FieldByName('items').AsString;
      objeto.Subitems      := tabla2.FieldByName('subitems').AsString;
      objeto.Concepto      := tabla2.FieldByName('descrip').AsString;
      objeto.Global        := tabla2.FieldByName('globalit').AsString;
      objeto.Abreviatura   := tabla2.FieldByName('abreviatura').AsString;
      objeto.Evaluacion    := tabla2.FieldByName('eval').AsString;
      objeto.Agrupa        := tabla2.FieldByName('agrupa').AsString;
      objeto.Puntaje       := tabla2.FieldByName('puntaje').AsFloat;
      objeto.Maximo        := tabla2.FieldByName('maximo').AsFloat;
      objeto.Validez       := tabla2.FieldByName('validez').AsFloat;
      objeto.DisAntiguedad := tabla2.FieldByName('disantiguedad').AsString;
      l.Add(objeto);
      tabla2.Next;
    end;
    dbEx.conn.QuitarFiltro(tabla2);
  end else Begin
    tabla1.IndexFieldNames := 'Orden';    // Devolvemos los Items ordenados por columna
    tabla1.First;
    while not tabla1.Eof do Begin
      dbEx.conn.Filtrar(tabla2, 'items = ' + '''' + tabla1.FieldByName('items').AsString + '''');
      tabla2.First;
      while not tabla2.Eof do Begin
        objeto               := TTEscalafon.Create;
        objeto.Items         := tabla2.FieldByName('items').AsString;
        objeto.Subitems      := tabla2.FieldByName('subitems').AsString;
        objeto.Concepto      := tabla2.FieldByName('descrip').AsString;
        objeto.Global        := tabla2.FieldByName('globalit').AsString;
        objeto.Abreviatura   := tabla2.FieldByName('abreviatura').AsString;
        objeto.Evaluacion    := tabla2.FieldByName('eval').AsString;
        objeto.Agrupa        := tabla2.FieldByName('agrupa').AsString;
        objeto.Puntaje       := tabla2.FieldByName('puntaje').AsFloat;
        objeto.Maximo        := tabla2.FieldByName('maximo').AsFloat;
        objeto.Validez       := tabla2.FieldByName('validez').AsFloat;
        objeto.DisAntiguedad := tabla2.FieldByName('disantiguedad').AsString;
        l.Add(objeto);
        tabla2.Next;
      end;
      dbEx.conn.QuitarFiltro(tabla2);
      tabla1.Next;
    end;
    tabla1.IndexFieldNames := 'Items';
  end;

  Result := l;
end;

procedure TTEscalafon.Listar(xitems: String; salida: char);
// Objetivo...: listar datos
var
  idanter: String;

  procedure ListarEscala(salida: char);
  var
    l: Boolean;
  Begin
    dbEx.conn.Filtrar(tabla3, 'items = ' + '''' + tabla2.FieldByName('items').AsString + '''' + ' and subitems = ' + '''' + tabla2.FieldByName('subitems').AsString + '''');
    tabla3.First; l := False;
    while not tabla3.Eof do Begin
      list.Linea(0, 0, '         Mín - Máx - Puntaje - Con Eval.:', 1, 'Arial, cursiva, 8', salida, 'N');
      list.importe(40, list.Lineactual, '', tabla3.FieldByName('minimo').AsFloat, 2, 'Arial, cursiva, 8');
      list.importe(50, list.Lineactual, '', tabla3.FieldByName('maximo').AsFloat, 3, 'Arial, cursiva, 8');
      list.importe(65, list.Lineactual, '', tabla3.FieldByName('puntaje').AsFloat, 4, 'Arial, cursiva, 8');
      list.Linea(70, list.Lineactual, tabla3.FieldByName('eval').AsString, 5, 'Arial, cursiva, 8', salida, 'S');
      l := True;
      tabla3.Next;
    end;
    dbEx.conn.QuitarFiltro(tabla3);

    if l then list.Linea(0, 0, '', 1, 'Arial, cursiva, 8', salida, 'S');
  end;

begin
  list.Setear(salida);
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Tabla de Escalafonamiento', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, '  Items' + utiles.espacios(3) +  'Concepto', 1, 'Arial, cursiva, 8');
  List.Titulo(40, list.Lineactual, 'Abreviatura', 2, 'Arial, cursiva, 8');
  List.Titulo(55, list.Lineactual, 'Puntaje', 3, 'Arial, cursiva, 8');
  List.Titulo(65, list.Lineactual, 'Máximo', 4, 'Arial, cursiva, 8');
  List.Titulo(74, list.Lineactual, 'Global', 5, 'Arial, cursiva, 8');
  List.Titulo(81, list.Lineactual, 'E/PA', 6, 'Arial, cursiva, 8');
  List.Titulo(86, list.Lineactual, 'Validez', 7, 'Arial, cursiva, 8');
  List.Titulo(93, list.Lineactual, 'Agr.', 8, 'Arial, cursiva, 8');

  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  tabla1.IndexFieldNames := 'items';
  tabla2.IndexFieldNames := 'items;subitems';
  if Length(Trim(xitems)) > 0 then dbEx.conn.Filtrar(tabla1, 'items = ' + '''' + xitems + '''');
  tabla1.First;
  while not tabla1.Eof do Begin
    if tabla1.FieldByName('items').AsString <> idanter then Begin
      if idanter <> '' then list.Linea(0, 0, '', 1, 'Arial, negrita, 9', salida, 'S');
      list.Linea(0, 0, 'Concepto: ' + tabla1.FieldByName('items').AsString + ' - ' + tabla1.FieldByName('descrip').AsString, 1, 'Arial, negrita, 9', salida, 'N');
      list.Linea(70, list.Lineactual, tabla1.FieldByName('abreviatura').AsString, 2, 'Arial, negrita, 9', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S');
      idanter := tabla1.FieldByName('items').AsString;
    end;

    dbEx.conn.Filtrar(tabla2, 'items = ' + '''' + tabla1.FieldByName('items').AsString + '''');
    tabla2.First;
    while not tabla2.Eof do Begin
      list.Linea(0, 0, '  ' + tabla2.FieldByName('subitems').AsString + '  ' + tabla2.FieldByName('descrip').AsString, 1, 'Arial, normal, 8', salida, 'N');
      list.Linea(40, list.Lineactual, tabla2.FieldByName('abreviatura').AsString, 2, 'Arial, normal, 8', salida, 'N');
      list.importe(60, list.Lineactual, '', tabla2.FieldByName('puntaje').AsFloat, 3, 'Arial, normal, 8');
      list.importe(70, list.Lineactual, '', tabla2.FieldByName('maximo').AsFloat, 4, 'Arial, normal, 8');
      list.Linea(78, list.Lineactual, tabla2.FieldByName('globalit').AsString, 5, 'Arial, normal, 8', salida, 'N');
      list.Linea(81, list.Lineactual, tabla2.FieldByName('eval').AsString, 6, 'Arial, normal, 8', salida, 'N');
      list.importe(89, list.Lineactual, '###.##', tabla2.FieldByName('validez').AsFloat, 7, 'Arial, normal, 8');
      list.Linea(93, list.Lineactual, tabla2.FieldByName('agrupa').AsString, 8, 'Arial, normal, 8', salida, 'S');

      ListarEscala(salida);
      tabla2.Next;
    end;
    dbEx.conn.QuitarFiltro(tabla2);

    tabla1.Next;
  end;

  dbEx.conn.QuitarFiltro(tabla1);

  list.FinList;
end;

function  TTEscalafon.BuscarEscala(xitems, xsubitems, xlinea: String): Boolean;
// Objetivo...: recuperar instancia
begin
  tabla3.IndexFieldNames := 'items;subitems;linea';
  Result := dbEx.conn.Buscar(tabla3, 'items', 'subitems', 'linea', xitems, xsubitems, xlinea);
end;

procedure TTEscalafon.RegistrarEscala(xitems, xsubitems, xlinea: String; xmaximo, xminimo, xpuntaje: Real; xeval: String; xcantitems: Integer);
// Objetivo...: registrar instancia
begin
  if BuscarEscala(xitems, xsubitems, xlinea) then tabla3.Edit else tabla3.Append;
  tabla3.FieldByName('items').AsString    := xitems;
  tabla3.FieldByName('subitems').AsString := xsubitems;
  tabla3.FieldByName('linea').AsString    := xlinea;
  tabla3.FieldByName('maximo').AsFloat    := xmaximo;
  tabla3.FieldByName('minimo').AsFloat    := xminimo;
  tabla3.FieldByName('puntaje').AsFloat   := xpuntaje;
  tabla3.FieldByName('eval').AsString     := xeval;
  try
    tabla3.Post
   except
    tabla3.Cancel
  end;
  tabla3.ApplyUpdates(-1);
  if xlinea = utiles.sLlenarIzquierda(IntToStr(xcantitems), 2, '0') then Begin
    dbEx.conn.tranSQL('delete from puntajeescala where items = ' + '''' + xitems + '''' + ' and  subitems = ' + '''' + xsubitems + '''' + ' and linea > ' + '''' + xlinea + '''');
    tabla3.ApplyUpdates(-1);
  end;
end;

procedure TTEscalafon.BorrarEscala(xitems, xsubitems: String);
// Objetivo...: borrar instancia
begin
  dbEx.conn.tranSQL('delete from puntajeescala where items = ' + '''' + xitems + '''' + ' and  subitems = ' + '''' + xsubitems + '''');
  tabla3.ApplyUpdates(-1);
end;

function  TTEscalafon.setItemsEscala(xitems, xsubitems: String): TObjectList;
// Objetivo...: devolver items instancia
var
  l: TObjectList;
  objeto: TTEscalafon;
begin
  l := TObjectList.Create;
  dbEx.conn.Filtrar(tabla3, 'items = ' + '''' + xitems + '''' + ' and subitems = ' + '''' + xsubitems + '''');
  tabla3.First;
  while not tabla3.Eof do Begin
    objeto                  := TTEscalafon.Create;
    objeto.ItemsEscala      := tabla3.FieldByName('items').AsString;
    objeto.SubitemsEscala   := tabla3.FieldByName('subitems').AsString;
    objeto.LineaEscala      := tabla3.FieldByName('linea').AsString;
    objeto.EvaluacionEscala := tabla3.FieldByName('eval').AsString;
    objeto.MaximoEscala     := tabla3.FieldByName('maximo').AsFloat;
    objeto.MinimoEscala     := tabla3.FieldByName('minimo').AsFloat;
    objeto.PuntajeEscala    := tabla3.FieldByName('puntaje').AsFloat;
    l.Add(objeto);
    tabla3.Next;
  end;
  dbEx.conn.QuitarFiltro(tabla3);

  Result := l;
end;

function  TTEscalafon.setPuntaje(xitems, xsubitems, xeval: String; xcantidad: Real): Real;
// Objetivo...: Prorratear Puntaje
var
  r: Real;
begin
  r := 0;
  dbEx.conn.Filtrar(tabla3, 'items = ' + '''' + xitems + '''' + ' and subitems = ' + '''' + xsubitems + '''');
  tabla3.First;
  while not tabla3.Eof do Begin
    if tabla3.FieldByName('eval').AsString = xeval then Begin
      if (xcantidad >= tabla3.FieldByName('minimo').AsFloat) and (xcantidad <= tabla3.FieldByName('maximo').AsFloat) then r := tabla3.FieldByName('puntaje').AsFloat;
    end;
    tabla3.Next;
  end;
  dbEx.conn.QuitarFiltro(tabla3);

  Result := r;
end;

function  TTEscalafon.setItemsRequeridosEscalafonPrincipal: TStringList;
// Objetivo...: Devolver Items Requeridos para Escalafon Principal
var
  l: TStringList;
Begin
  l := TStringList.Create;
  dbEx.conn.Filtrar(tabla1, 'requerido = ' + '''' + 'S' + '''');
  tabla1.First;
  while not tabla1.Eof do Begin
    l.Add(tabla1.FieldByName('items').AsString);
    tabla1.Next;
  end;
  dbEx.conn.QuitarFiltro(tabla1);

  Result := l;
end;

procedure TTEscalafon.conectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones = 0 then Begin
    if not tabla1.Active then tabla1.Open;
    if not tabla2.Active then tabla2.Open;
    if not tabla3.Active then tabla3.Open;
  end;
  Inc(conexiones);
end;

procedure TTEscalafon.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  Dec(conexiones);
  if conexiones = 0 then Begin
    dbEx.conn.closeDB(tabla1);
    dbEx.conn.closeDB(tabla2);
    dbEx.conn.closeDB(tabla3);
  end;
end;

{===============================================================================}

function tablaes: TTEscalafon;
begin
  if xtablaescalafon = nil then
    xtablaescalafon := TTEscalafon.Create;
  Result := xtablaescalafon;
end;

{===============================================================================}

initialization

finalization
  xtablaescalafon.Free;

end.
