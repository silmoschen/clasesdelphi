unit CCategoriasCreditosAsociacion;

interface

uses SysUtils, DB, DBTables, CBDT, CIDBFM, CUtiles, CListar, Classes;

type

TTCategoriasCreditos = class(TObject)
  Items, Descrip, Expendio, UltimoNro, IdLinea, DescripLinea, TipoCalculo, Nivel: String;
  tabla, lineas, indice, indicestc: TTable;
 public
  { Declaraciones P�blicas }
  constructor Create;
  destructor  Destroy; override;

  procedure   Grabar(xItems, xDescrip, xidlinea: string);
  procedure   Borrar(xItems: string);
  function    Buscar(xItems: string): Boolean;
  procedure   getDatos(xItems: string);
  function    setCategorias: TQuery;
  function    setCategoriasPorLinea: TQuery;
  function    Nuevo: string;
  procedure   Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
  procedure   ListarIndices(orden, iniciar, finalizar, ent_excl: string; salida: char);
  procedure   BuscarPorDescrip(xexpr: string);
  procedure   BuscarPorId(xexpr: string);

  procedure   FijarUltimoNumeroDeComprobante(xItems, xNumero: String);
  function    GenerarNuevoNumeroComprobante(xitems: String): String;

  { Lineas de Cr�dito }
  function    BuscarLinea(xidlinea: String): Boolean;
  procedure   GuardarLinea(xidlinea, xdescrip, xexpendio, xtipocalculo, xNivel: String);
  procedure   BorrarLinea(xidlinea: String);
  procedure   getDatosLinea(xidlinea: String);
  procedure   BuscarLineaPorDescrip(xexpr: string);
  procedure   BuscarLineaPorId(xexpr: string);
  procedure   ListarLineas(orden, iniciar, finalizar, ent_excl: string; salida: char);
  function    NuevaLinea: string;
  function    VerificarSiLaLineaTieneCreditos: Boolean;
  function    setLineas: TQuery;

  { Indices de Cr�ditos }
  function    BuscarIndice(xitems, xperiodo: String): Boolean;
  procedure   RegistrarIndice(xitems, xperiodo: String; xindice: real);
  procedure   BorrarIndice(xitems, xperiodo: String);
  function    setIndice(xitems: String): TStringList; overload;
  function    setIndice(xitems, xfecha: String): Real; overload;

  { Indices de Cr�ditos por Tipo de Calculo }
  function    BuscarIndiceTC(xitems, xperiodo: String): Boolean;
  procedure   RegistrarIndiceTC(xitems, xperiodo: String; xindice: real);
  procedure   BorrarIndiceTC(xitems, xperiodo: String);
  function    setIndiceTC(xitems: String): TStringList; overload;
  function    setIndiceTC(xitems, xfecha: String): Real; overload;

  procedure   conectar;
  procedure   desconectar;
 private
  conexiones: shortint;
  lista, listatc: TStringList;
  procedure   ListLinea(salida: char);
  procedure   ListLineas(salida: char);
  procedure   ListLineaIndice(salida: char);
  procedure   CargarLista;
  procedure   CargarListaTC;
  { Declaraciones Privadas }
end;

function categoria: TTCategoriasCreditos;

implementation

var
  xcatcred: TTCategoriasCreditos = nil;

constructor TTCategoriasCreditos.Create;
begin
  inherited Create;
  tabla     := datosdb.openDB('creditos', 'Items');
  lineas    := datosdb.openDB('lineas_creditos', '');
  indice    := datosdb.openDB('indice_credito', '');
  indicestc := datosdb.openDB('indices_tipoc', '');
  lista     := TStringList.Create;
  listatc   := TStringList.Create;
end;

destructor TTCategoriasCreditos.Destroy;
begin
  inherited Destroy;
end;

procedure TTCategoriasCreditos.Grabar(xItems, xDescrip, xidlinea: string);
// Objetivo...: Grabar Atributos del Objeto
begin
  if Buscar(xItems) then tabla.Edit else tabla.Append;
  tabla.FieldByName('Items').AsString       := xItems;
  tabla.FieldByName('Descrip').AsString     := xDescrip;
  tabla.FieldByName('Ultimo_comp').AsString := '00000000';
  tabla.FieldByName('idlinea').AsString     := xidlinea;
  try
    tabla.Post
  except
    tabla.Cancel
  end;
end;

procedure TTCategoriasCreditos.Borrar(xItems: string);
// Objetivo...: Eliminar un Objeto
begin
  if Buscar(xItems) then Begin
    tabla.Delete;
    getDatos(tabla.FieldByName('Items').AsString);  // Fijamos los Atributos Siguientes al Objeto Borrado
  end;
end;

function TTCategoriasCreditos.Buscar(xItems: string): Boolean;
// Objetivo...: Buscar el Objeto solicitado
begin
  if tabla.IndexFieldNames <> 'Items' then tabla.IndexFieldNames := 'Items';
  if tabla.FindKey([xItems]) then Result := True else Result := False;
end;

procedure  TTCategoriasCreditos.getDatos(xItems: string);
// Objetivo...: Retornar/Iniciar Atributos
begin
  tabla.Refresh;
  if Buscar(xItems) then Begin
    Items       := tabla.FieldByName('Items').AsString;
    Descrip     := tabla.FieldByName('Descrip').AsString;
    UltimoNro   := tabla.FieldByName('Ultimo_comp').AsString;
    Idlinea     := tabla.FieldByName('idlinea').AsString;
    getDatosLinea(idlinea);
  end else Begin
    Items := ''; Descrip := ''; UltimoNro := ''; DescripLinea := ''; IdLinea := '';
  end;
end;

function TTCategoriasCreditos.setCategorias: TQuery;
// Objetivo...: devolver un set con los categoriaes disponibles
begin
  Result := datosdb.tranSQL('SELECT * FROM ' + tabla.TableName + ' ORDER BY descrip');
end;

function TTCategoriasCreditos.setCategoriasPorLinea: TQuery;
// Objetivo...: devolver un set con los categoriaes disponibles
begin
  Result := datosdb.tranSQL('SELECT creditos.*, lineas_creditos.Nivel FROM creditos, lineas_creditos WHERE creditos.idLinea = lineas_creditos.idLinea ORDER BY nivel, idlinea, items');
end;

function TTCategoriasCreditos.Nuevo: string;
// Objetivo...: Abrir tablas de persistencia
begin
  if tabla.IndexFieldNames <> 'Items' then tabla.IndexFieldNames := 'Items';
  tabla.Last;
  if tabla.RecordCount = 0 then Result := '1' else Result := IntToStr(StrToInt(tabla.FieldByName('Items').AsString) + 1);
end;

procedure TTCategoriasCreditos.Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
// Objetivo...: Listar colecci�n de objetos
begin
  if orden = 'A' then tabla.IndexFieldNames := 'Descrip';

  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Listado de Categorias de Cr�ditos', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'C�d. Descripci�n', 1, 'Arial, cursiva, 8');
  List.Titulo(50, list.lineactual, 'Categor�a', 2, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  tabla.First;
  while not tabla.EOF do
    begin
      // Ordenado por C�digo
      if (ent_excl = 'E') and (orden = 'C') then
        if (tabla.FieldByName('Items').AsString >= iniciar) and (tabla.FieldByName('Items').AsString <= finalizar) then ListLinea(salida);
      if (ent_excl = 'X') and (orden = 'C') then
        if (tabla.FieldByName('Items').AsString < iniciar) or (tabla.FieldByName('Items').AsString > finalizar) then ListLinea(salida);
      // Ordenado Alfab�ticamente
      if (ent_excl = 'E') and (orden = 'A') then
        if (tabla.FieldByName('categoria').AsString >= iniciar) and (tabla.FieldByName('categoria').AsString <= finalizar) then ListLinea(salida);
      if (ent_excl = 'X') and (orden = 'A') then
        if (tabla.FieldByName('categoria').AsString < iniciar) or (tabla.FieldByName('categoria').AsString > finalizar) then ListLinea(salida);

      tabla.Next;
    end;
    List.FinList;

    tabla.IndexFieldNames := tabla.IndexFieldNames;
    tabla.First;
end;

procedure TTCategoriasCreditos.ListarIndices(orden, iniciar, finalizar, ent_excl: string; salida: char);
// Objetivo...: Listar colecci�n de objetos
begin
  if orden = 'A' then tabla.IndexFieldNames := 'Descrip';

  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Listado Indices de Cr�ditos por Categor�a', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'C�d. Descripci�n', 1, 'Arial, cursiva, 8');
  List.Titulo(30, list.Lineactual, 'Per�odo   /   Indice', 2, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  tabla.First;
  while not tabla.EOF do
    begin
      // Ordenado por C�digo
      if (ent_excl = 'E') and (orden = 'C') then
        if (tabla.FieldByName('Items').AsString >= iniciar) and (tabla.FieldByName('Items').AsString <= finalizar) then ListLineaIndice(salida);
      if (ent_excl = 'X') and (orden = 'C') then
        if (tabla.FieldByName('Items').AsString < iniciar) or (tabla.FieldByName('Items').AsString > finalizar) then ListLineaIndice(salida);
      // Ordenado Alfab�ticamente
      if (ent_excl = 'E') and (orden = 'A') then
        if (tabla.FieldByName('categoria').AsString >= iniciar) and (tabla.FieldByName('categoria').AsString <= finalizar) then ListLineaIndice(salida);
      if (ent_excl = 'X') and (orden = 'A') then
        if (tabla.FieldByName('categoria').AsString < iniciar) or (tabla.FieldByName('categoria').AsString > finalizar) then ListLineaIndice(salida);

      tabla.Next;
    end;
    List.FinList;

    tabla.IndexFieldNames := tabla.IndexFieldNames;
    tabla.First;
end;

procedure TTCategoriasCreditos.ListLinea(salida: char);
begin
  getDatosLinea(tabla.FieldByName('idlinea').AsString);
  List.Linea(0, 0, tabla.FieldByName('Items').AsString + '   ' + tabla.FieldByName('descrip').AsString, 1, 'Arial, normal, 8', salida, 'N');
  List.Linea(50, list.lineactual, descripLinea, 2, 'Arial, normal, 8', salida, 'S');
end;

procedure TTCategoriasCreditos.ListLineaIndice(salida: char);
begin
  List.Linea(0, 0, tabla.FieldByName('Items').AsString + '   ' + tabla.FieldByName('descrip').AsString, 1, 'Arial, normal, 8', salida, 'S');
  datosdb.Filtrar(indice, 'items = ' + '''' + tabla.FieldByName('Items').AsString + '''');
  indice.First;
  while not indice.Eof do Begin
    list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'N');
    list.Linea(30, list.Lineactual, indice.FieldByName('periodo').AsString + '       ' + utiles.FormatearNumero(indice.FieldByName('indice').AsString, '###0.0000'), 2, 'Arial, normal, 8', salida, 'S');
    indice.Next;
  end;
  datosdb.QuitarFiltro(indice);
end;

procedure TTCategoriasCreditos.BuscarPorDescrip(xexpr: string);
begin
  tabla.IndexFieldNames := 'Descrip';
  tabla.FindNearest([xexpr]);
end;

procedure TTCategoriasCreditos.BuscarPorId(xexpr: string);
begin
  tabla.IndexFieldNames := 'Items';
  tabla.FindNearest([xexpr]);
end;

procedure TTCategoriasCreditos.FijarUltimoNumeroDeComprobante(xItems, xNumero: String);
// Objetivo...: Fijar ultimo n�mero de comprobante
Begin
  if Buscar(xitems) then tabla.Edit else tabla.Append;
  tabla.FieldByName('ultimo_comp').AsString := xNumero;
  try
    tabla.Post
   except
    tabla.Cancel
  end;
end;

function  TTCategoriasCreditos.GenerarNuevoNumeroComprobante(xitems: String): String;
// Objetivo...: Obtener el proximo n�mero de comprobante
Begin
  if not Buscar(xitems) then Result := '00000001' else Result := utiles.sLlenarIzquierda(IntToStr(tabla.FieldByName('ultimo_comp').AsInteger + 1), 8, '0');
end;

function  TTCategoriasCreditos.BuscarLinea(xidlinea: String): Boolean;
// Objetivo...: Buscar Linea de Cr�dito
Begin
  if not lineas.Active then lineas.Open;
  if lineas.IndexFieldNames <> 'Idlinea' then lineas.IndexFieldNames := 'Idlinea';
  Result := lineas.FindKey([xidlinea]);
end;

procedure TTCategoriasCreditos.GuardarLinea(xidlinea, xdescrip, xexpendio, xtipocalculo, xNivel: String);
// Objetivo...: Guardar Linea de Cr�dito
Begin
  if BuscarLinea(xidlinea) then lineas.Edit else lineas.Append;
  lineas.FieldByName('idlinea').AsString     := xidlinea;
  lineas.FieldByName('descrip').AsString     := xdescrip;
  if Length(Trim(xexpendio)) > 0 then lineas.FieldByName('expendio').AsString := xexpendio else lineas.FieldByName('expendio').AsString := '0000';
  lineas.FieldByName('tipocalculo').AsString := xtipocalculo;
  lineas.FieldByName('nivel').AsString       := xnivel;
  try
    lineas.Post
   except
    lineas.Cancel
  end;
end;

procedure TTCategoriasCreditos.BorrarLinea(xidlinea: String);
// Objetivo...: Borrar una L�ne a de Cr�ditos
Begin
  if BuscarLinea(xidlinea) then Begin
    lineas.Delete;
    idlinea := lineas.FieldByName('idlinea').AsString;
    getDatosLinea(idlinea);
  end;
end;

procedure TTCategoriasCreditos.getDatosLinea(xidlinea: String);
// Objetivo...: getDatos Lineas Creditos
Begin
  if BuscarLinea(xidlinea) then Begin
    IdLinea      := xidlinea;
    DescripLinea := lineas.FieldByName('descrip').AsString;
    Expendio     := lineas.FieldByName('expendio').AsString;
    tipoCalculo  := lineas.FieldByName('tipocalculo').AsString;
    Nivel        := lineas.FieldByName('nivel').AsString;
  end else Begin
    DescripLinea := ''; idlinea := ''; Expendio := ''; tipocalculo := ''; Nivel := '';
  end;
end;

procedure TTCategoriasCreditos.BuscarLineaPorDescrip(xexpr: string);
begin
  lineas.IndexFieldNames := 'Descrip';
  lineas.FindNearest([xexpr]);
end;

procedure TTCategoriasCreditos.BuscarLineaPorId(xexpr: string);
begin
  tabla.IndexFieldNames := 'Idlinea';
  lineas.FindNearest([xexpr]);
end;

procedure TTCategoriasCreditos.ListarLineas(orden, iniciar, finalizar, ent_excl: string; salida: char);
// Objetivo...: Listar colecci�n de objetos
begin
  if orden = 'A' then tabla.IndexFieldNames := 'Descrip';

  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Listado de Lineas de Cr�ditos', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Id.      Descripci�n', 1, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  lineas.First;
  while not lineas.EOF do Begin
    // Ordenado por C�digo
    if (ent_excl = 'E') and (orden = 'C') then
      if (lineas.FieldByName('Idlinea').AsString >= iniciar) and (lineas.FieldByName('Idlinea').AsString <= finalizar) then ListLineas(salida);
    if (ent_excl = 'X') and (orden = 'C') then
      if (lineas.FieldByName('Idlinea').AsString < iniciar) or (lineas.FieldByName('Idlinea').AsString > finalizar) then ListLineas(salida);
    // Ordenado Alfab�ticamente
    if (ent_excl = 'E') and (orden = 'A') then
      if (lineas.FieldByName('descrip').AsString >= iniciar) and (lineas.FieldByName('descrip').AsString <= finalizar) then ListLineas(salida);
    if (ent_excl = 'X') and (orden = 'A') then
      if (lineas.FieldByName('descrip').AsString < iniciar) or (lineas.FieldByName('descrip').AsString > finalizar) then ListLineas(salida);

    lineas.Next;
  end;
  List.FinList;

  lineas.IndexFieldNames := 'IdLinea';
  lineas.First;
end;

procedure TTCategoriasCreditos.ListLineas(salida: char);
begin
  List.Linea(0, 0, lineas.FieldByName('Idlinea').AsString + '    ' + lineas.FieldByName('descrip').AsString, 1, 'Arial, normal, 8', salida, 'S');
end;

function TTCategoriasCreditos.NuevaLinea: string;
// Objetivo...: Generar Id
begin
  if tabla.IndexFieldNames <> 'Idlinea' then tabla.IndexFieldNames := 'Idlinea';
  lineas.Last;
  if lineas.RecordCount = 0 then Result := '1' else Result := IntToStr(StrToInt(lineas.FieldByName('Idlinea').AsString) + 1);
end;

function  TTCategoriasCreditos.VerificarSiLaLineaTieneCreditos: Boolean;
// Objetivo...: verificar si la linea tiene nuevos cr�ditos
var
  r: TQuery;
Begin
  r := datosdb.tranSQL('SELECT * FROM ' + tabla.TableName + ' WHERE idlinea = ' + '"' + lineas.FieldByName('IdLinea').AsString + '"');
  r.Open;
  if r.RecordCount > 0 then Result := True else Result := False;
  r.Close; r.Free;
end;

function  TTCategoriasCreditos.setLineas: TQuery;
Begin
  datosdb.tranSQL('select * from ' + lineas.TableName + ' order by descrip');
end;

function  TTCategoriasCreditos.BuscarIndice(xitems, xperiodo: String): Boolean;
// Objetivo...: Buscar Indice
begin
  Result := datosdb.Buscar(indice, 'items', 'periodo', xitems, xperiodo);
end;

procedure TTCategoriasCreditos.RegistrarIndice(xitems, xperiodo: String; xindice: real);
// Objetivo...: Registrar Indice
begin
  if BuscarIndice(xitems, xperiodo) then indice.Edit else indice.Append;
  indice.FieldByName('items').AsString   := xitems;
  indice.FieldByName('periodo').AsString := xperiodo;
  indice.FieldByName('indice').AsFloat   := xindice;
  try
    indice.Post
   except
    indice.Cancel
  end;
  datosdb.closeDB(indice); indice.Open;
  CargarLista;
end;

procedure  TTCategoriasCreditos.BorrarIndice(xitems, xperiodo: String);
// Objetivo...: Buscar Indice
begin
  if BuscarIndice(xitems, xperiodo) then Begin
    indice.Delete;
    datosdb.closeDB(indice); indice.Open;
    CargarLista;
  end;
end;

function  TTCategoriasCreditos.setIndice(xitems: String): TStringList;
// Objetivo...: Devolver Indice
var
  l: TStringList;
begin
  l := TStringList.Create;
  datosdb.Filtrar(indice, 'items = ' + '''' + xitems + '''');
  indice.First;
  while not indice.Eof do Begin
    l.Add(Copy(indice.FieldByName('periodo').AsString, 4, 4) + Copy(indice.FieldByName('periodo').AsString, 1, 2) + indice.FieldByName('indice').AsString);
    indice.Next;
  end;
  datosdb.QuitarFiltro(indice);
  l.Sort;
  Result := l;
end;

function  TTCategoriasCreditos.setIndice(xitems, xfecha: String): Real;
// Objetivo...: Devolver Indice
var
  ind: Real;
  i: Integer;
  per: String;
begin
  ind := 0;
  per := Copy(xfecha, 4, 2) + '/' + Copy(utiles.sExprFecha2000(xfecha), 1, 4);

  For i := 1 to lista.Count do Begin
    if Copy(lista.Strings[i-1], 1, 3) = xitems then Begin
      if ((Copy(lista.Strings[i-1], 7, 4) + Copy(lista.Strings[i-1], 4, 2))) <= (Copy(per, 4, 4) + Copy(per, 1, 2)) then
        ind := StrToFloat(utiles.FormatearNumero(Copy(Trim(lista.Strings[i-1]), 11, 20), '###0.0000'));
    end;
  end;

  Result := ind;
end;

procedure TTCategoriasCreditos.CargarLista;
Begin
  lista.Clear;
  indice.First;
  while not indice.Eof do Begin
    lista.Add(indice.FieldByName('items').AsString + indice.FieldByName('periodo').AsString + utiles.FormatearNumero(indice.FieldByName('indice').AsString, '#####0.0000'));
    indice.Next;
  end;
end;

function  TTCategoriasCreditos.BuscarIndiceTC(xitems, xperiodo: String): Boolean;
// Objetivo...: Buscar Indice
begin
  Result := datosdb.Buscar(indicestc, 'items', 'periodo', xitems, xperiodo);
end;

procedure TTCategoriasCreditos.RegistrarIndiceTC(xitems, xperiodo: String; xindice: real);
// Objetivo...: Registrar Indice
begin
  if BuscarIndiceTC(xitems, xperiodo) then indicestc.Edit else indicestc.Append;
  indicestc.FieldByName('items').AsString   := xitems;
  indicestc.FieldByName('periodo').AsString := xperiodo;
  indicestc.FieldByName('indice').AsFloat   := xindice;
  try
    indicestc.Post
   except
    indicestc.Cancel
  end;
  datosdb.closeDB(indicestc); indicestc.Open;
  CargarListaTC;
end;

procedure  TTCategoriasCreditos.BorrarIndiceTC(xitems, xperiodo: String);
// Objetivo...: Buscar Indice
begin
  if BuscarIndice(xitems, xperiodo) then Begin
    indicestc.Delete;
    datosdb.closeDB(indicestc); indicestc.Open;
    CargarListaTC;
  end;
end;

function  TTCategoriasCreditos.setIndiceTC(xitems: String): TStringList;
// Objetivo...: Devolver Indice
var
  l: TStringList;
begin
  l := TStringList.Create;
  datosdb.Filtrar(indicestc, 'items = ' + '''' + xitems + '''');
  indicestc.First;
  while not indicestc.Eof do Begin
    l.Add(Copy(indicestc.FieldByName('periodo').AsString, 4, 4) + Copy(indicestc.FieldByName('periodo').AsString, 1, 2) + indicestc.FieldByName('indice').AsString);
    indicestc.Next;
  end;
  datosdb.QuitarFiltro(indicestc);
  l.Sort;
  Result := l;
end;

function  TTCategoriasCreditos.setIndiceTC(xitems, xfecha: String): Real;
// Objetivo...: Devolver Indice
var
  ind: Real;
  i: Integer;
  per: String;
begin
  ind := 0;
  per := Copy(xfecha, 4, 2) + '/' + Copy(utiles.sExprFecha2000(xfecha), 1, 4);

  For i := 1 to listatc.Count do Begin
    if Copy(listatc.Strings[i-1], 1, 1) = xitems then Begin
      if ((Copy(listatc.Strings[i-1], 5, 4) + Copy(listatc.Strings[i-1], 3, 2))) <= (Copy(per, 4, 4) + Copy(per, 1, 2)) then
        ind := StrToFloat(utiles.FormatearNumero(Copy(Trim(listatc.Strings[i-1]), 9, 20), '###0.0000'));
    end;
  end;

  Result := ind;
end;

procedure TTCategoriasCreditos.CargarListaTC;
Begin
  listatc.Clear;
  indicestc.First;
  while not indicestc.Eof do Begin
    listatc.Add(indicestc.FieldByName('items').AsString + indicestc.FieldByName('periodo').AsString + utiles.FormatearNumero(indicestc.FieldByName('indice').AsString, '#####0.0000'));
    indicestc.Next;
  end;
end;

procedure TTCategoriasCreditos.conectar;
// Objetivo...: Abrir tablas de persistencia
begin
  if conexiones = 0 then Begin
    if not tabla.Active then tabla.Open;
    tabla.FieldByName('Items').DisplayLabel := 'Items'; tabla.FieldByName('descrip').DisplayLabel := 'Descripci�n'; tabla.FieldByName('Ultimo_comp').Visible := False; tabla.FieldByName('IdLinea').Visible := False;
    if not lineas.Active then lineas.Open;
    lineas.FieldByName('idlinea').DisplayLabel := 'Id.'; lineas.FieldByName('descrip').DisplayLabel := 'Descripci�n Linea'; lineas.FieldByName('expendio').DisplayLabel := 'E.Recibo'; lineas.FieldByName('Nivel').DisplayLabel := 'N'; lineas.FieldByName('tipocalculo').DisplayLabel := 'Tipo C�lculo';
    if not indice.Active then indice.Open;
    if not indicestc.Active then indicestc.Open;
  end;
  Inc(conexiones);
  CargarLista;
  CargarListaTC;
end;

procedure TTCategoriasCreditos.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones > 0 then Dec(conexiones);
  if conexiones = 0 then Begin
    datosdb.closeDB(tabla);
    datosdb.closeDB(lineas);
    datosdb.closeDB(indice);
    datosdb.closeDB(indicestc);
  end;
end;

{===============================================================================}

function categoria: TTCategoriasCreditos;
begin
  if xcatcred = nil then
    xcatcred := TTCategoriasCreditos.Create;
  Result := xcatcred;
end;

{===============================================================================}

initialization

finalization
  xcatcred.Free;

end.
