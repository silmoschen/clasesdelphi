unit CCategoriaSueldos;

interface

uses SysUtils, DB, DBTables, CUtiles, CListar, CFirebird,
     IBDatabase, IBCustomDataSet, IBTable, Variants, Classes,
     CEmpresasSueldos;

type

TTCategorias = class(TObject)
  Codigo, Categoria, Observac: string;
  tabla, montos: TIBTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  function    Nuevo: string;
  function    Buscar(xcodigo: string): boolean;
  procedure   Grabar(xcodigo, xcategoria, xobservac: string);
  procedure   Borrar(xcodigo: string);
  procedure   getDatos(xcodigo: string);
  procedure   BuscarPorDescrip(xexpr: string);
  procedure   BuscarPorCodigo(xexpr: string);
  procedure   Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);

  function    BuscarMonto(xcodigo, xperiodo: String): Boolean;
  procedure   GuardarMonto(xcodigo, xperiodo: String; xmes, xhora: Real);
  procedure   BorrarMonto(xcodigo, xperiodo: String);
  function    setMontos(xcodigo: String): TStringList;

  procedure   conectar;
  procedure   desconectar;
 private
  conexiones: shortint;
  objfirebird: TTFirebird;
  { Declaraciones Privadas }
  procedure ListLinea(salida: char);
end;

function categoria: TTCategorias;

implementation

var
  xcategoria: TTCategorias = nil;

constructor TTCategorias.Create;
begin
  inherited Create;
  objfirebird := TTFirebird.Create;
  firebird.getModulo('sueldos');
  objfirebird.Conectar(firebird.Host + '\' + empresa.setViaSeleccionada + '\datosempr.gdb', firebird.Usuario, firebird.Password);
  tabla  := objfirebird.InstanciarTabla('categorias');
  montos := objfirebird.InstanciarTabla('montos_categorias');
end;

destructor TTCategorias.Destroy;
begin
  inherited Destroy;
end;

function TTCategorias.Nuevo: string;
// Objetivo...: Generar un nuevo ID
begin
  tabla.IndexFieldNames := 'CODIGO';
  tabla.Last;
  if tabla.RecordCount = 0 then Result := '1' else Begin
    Result := IntToStr(StrToInt(tabla.FieldByName('codigo').AsString) + 1);
  end;
end;

function TTCategorias.Buscar(xcodigo: string): boolean;
// Objetivo...: Buscar el Objeto solicitado
begin
  Result := objfirebird.Buscar(tabla, 'codigo', xcodigo);
end;

procedure TTCategorias.Grabar(xcodigo, xcategoria, xobservac: string);
// Objetivo...: Grabar Atributos del Objeto
begin
  if Buscar(xcodigo) then tabla.Edit else tabla.Append;
  tabla.FieldByName('codigo').AsString    := xcodigo;
  tabla.FieldByName('categoria').AsString := xcategoria;
  tabla.FieldByName('observac').AsString  := xobservac;
  try
    tabla.Post;
   except
    tabla.Cancel
  end;
  objfirebird.RegistrarTransaccion(tabla);
end;

procedure TTCategorias.Borrar(xcodigo: string);
// Objetivo...: Eliminar un Objeto
begin
  if Buscar(xcodigo) then Begin
    tabla.Delete;
    getDatos(tabla.FieldByName('codigo').AsString);  // Fijamos los Atributos Siguientes al Objeto Borrado
    objfirebird.RegistrarTransaccion(tabla);
  end;
end;

procedure  TTCategorias.getDatos(xcodigo: string);
// Objetivo...: Retornar/Iniciar Atributos
begin
  if Buscar(xcodigo) then Begin
    codigo      := tabla.FieldByName('codigo').AsString;
    categoria   := tabla.FieldByName('categoria').AsString;
    observac    := tabla.FieldByName('observac').AsString;
  end else Begin
    codigo := ''; categoria := ''; observac := '';
  end;
end;

procedure TTCategorias.BuscarPorDescrip(xexpr: string);
// Objetivo...: Busqueda contextual
begin
  objfirebird.BuscarContextualmente(tabla, 'categoria', xexpr);
end;

procedure TTCategorias.BuscarPorCodigo(xexpr: string);
// Objetivo...: Busqueda contextual
begin
  objfirebird.BuscarContextualmente(tabla, 'codigo', xexpr);
end;

procedure TTCategorias.Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
// Objetivo...: Listar colección de objetos
begin
  if orden = 'A' then tabla.IndexName := tabla.IndexDefs.Items[1].Name;

  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Listado de Categorias', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Cód.', 1, 'Arial, cursiva, 8');
  List.Titulo(5, list.Lineactual, 'Categoría', 2, 'Arial, cursiva, 8');
  List.Titulo(65, list.Lineactual, 'Observaciones', 3, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  tabla.First;
  while not tabla.EOF do Begin
    // Ordenado por Código
    if (ent_excl = 'E') and (orden = 'C') then
      if (tabla.FieldByName('codigo').AsString >= iniciar) and (tabla.FieldByName('codigo').AsString <= finalizar) then ListLinea(salida);
    if (ent_excl = 'X') and (orden = 'C') then
      if (tabla.FieldByName('codigo').AsString < iniciar) or (tabla.FieldByName('codigo').AsString > finalizar) then ListLinea(salida);
    // Ordenado Alfabéticamente
    if (ent_excl = 'E') and (orden = 'A') then
      if (tabla.FieldByName('categoria').AsString >= iniciar) and (tabla.FieldByName('categoria').AsString <= finalizar) then ListLinea(salida);
    if (ent_excl = 'X') and (orden = 'A') then
      if (tabla.FieldByName('categoria').AsString < iniciar) or (tabla.FieldByName('cagegoria').AsString > finalizar) then ListLinea(salida);

    tabla.Next;
  end;
  List.FinList;

  tabla.IndexFieldNames := tabla.IndexFieldNames;
  tabla.First;
end;

procedure TTCategorias.ListLinea(salida: char);
begin
  List.Linea(0, 0, tabla.FieldByName('codigo').AsString, 1, 'Arial, normal, 8', salida, 'N');
  List.Linea(5, list.Lineactual, tabla.FieldByName('categoria').AsString, 2, 'Arial, normal, 8', salida, 'N');
  List.Linea(65, list.Lineactual, tabla.FieldByName('observac').AsString, 3, 'Arial, normal, 8', salida, 'S');
end;

function TTCategorias.BuscarMonto(xcodigo, xperiodo: String): Boolean;
// Objetivo...: Buscar Instancia
begin
  Result := objfirebird.Buscar(montos, 'codigo;periodo', xcodigo, xperiodo);
end;

procedure TTCategorias.GuardarMonto(xcodigo, xperiodo: String; xmes, xhora: Real);
// Objetivo...: Guardar Retencion
begin
  if BuscarMonto(xcodigo, xperiodo) then montos.Edit else montos.Append;
  montos.FieldByName('codigo').AsString  := xcodigo;
  montos.FieldByName('periodo').AsString := xperiodo;
  montos.FieldByName('mensual').AsFloat  := xmes;
  montos.FieldByName('hora').AsFloat     := xhora;
  try
    montos.Post
   except
    montos.Cancel
  end;
  objfirebird.RegistrarTransaccion(montos);
end;

procedure TTCategorias.BorrarMonto(xcodigo, xperiodo: String);
// Objetivo...: Borrar Retencion
begin
  if BuscarMonto(xcodigo, xperiodo) then montos.Delete;
  objfirebird.RegistrarTransaccion(montos);
end;

function  TTCategorias.setMontos(xcodigo: String): TStringList;
// Objetivo...: Lista de Retenciones
var
  l, l1, l2: TStringList;
  i: Integer;
Begin
  l  := TStringList.Create;
  l1 := TStringList.Create;
  l2 := TStringList.Create;
  i  := 0;
  objfirebird.Filtrar(montos, 'CODIGO = ' + xcodigo);
  montos.First;
  while not montos.Eof do Begin
    l.Add(montos.FieldByName('periodo').AsString + montos.FieldByName('codigo').AsString + utiles.FormatearNumero(montos.FieldByName('mensual').AsString) + ';1' + utiles.FormatearNumero(montos.FieldByName('hora').AsString));
    l1.Add(Copy(montos.FieldByName('periodo').AsString, 4, 4) + Copy(montos.FieldByName('periodo').AsString, 1, 2) + IntToStr(i));
    Inc(i);
    montos.Next;
  end;
  objfirebird.QuitarFiltro(montos);
  l1.Sort;
  for i := 1 to l1.Count do
    l2.Add(l.Strings[StrToInt(Trim(Copy(l1.Strings[i-1], 7, 3)))]);
  l1.Destroy; l.Destroy;
  Result := l2;
end;

procedure TTCategorias.conectar;
// Objetivo...: Abrir tablas de persistencia
begin
  if conexiones = 0 then Begin
    if not tabla.Active then tabla.Open;
    if not montos.Active then montos.Open;
  end;
  tabla.FieldByName('codigo').DisplayLabel := 'Código'; tabla.FieldByName('categoria').DisplayLabel := 'Categoría';
  objfirebird.RegistrarTransaccion(tabla);
  Inc(conexiones);
end;

procedure TTCategorias.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones > 0 then Dec(conexiones);
  if conexiones = 0 then Begin
    objfirebird.closeDB(tabla);
    objfirebird.closeDB(montos);
  end;
end;

{===============================================================================}

function categoria: TTCategorias;
begin
  if xcategoria = nil then
    xcategoria := TTCategorias.Create;
  Result := xcategoria;
end;

{===============================================================================}

initialization

finalization
  xcategoria.Free;

end.
