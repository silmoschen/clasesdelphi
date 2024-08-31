unit CEmpresasSueldos;

interface

uses SysUtils, DB, DBTables, CUtiles, CListar, CFirebird,
     IBDatabase, IBCustomDataSet, IBTable, Variants, CViasSueldo;

type

TTDatosEmpresas = class(TObject)
  codigo, Nombre, CUIT, Domicilio, Actividad, Nomvia, Clave: string;
  tabla, eleempr: TIBTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  function    Nuevo: string;
  function    Buscar(xcodigo: string): boolean;
  procedure   Grabar(xcodigo, xnombre, xcuit, xdomicilio, xactividad, xnomvia: string);
  procedure   Borrar(xcodigo: string);
  procedure   getDatos(xcodigo: string);
  procedure   BuscarPorDescrip(xexpr: string);
  procedure   BuscarPorCodigo(xexpr: string);
  procedure   Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);

  procedure   SeleccionarEmpresa(xcodemp, xperiodo: String);
  function    setEmpresaSeleccionada: String;
  function    setViaSeleccionada: String;

  procedure   conectar;
  procedure   desconectar;
 private
  conexiones: shortint;
  { Declaraciones Privadas }
  procedure ListLinea(salida: char);
end;

function empresa: TTDatosEmpresas;

implementation

var
  xempresa: TTDatosEmpresas = nil;

constructor TTDatosEmpresas.Create;
begin
  inherited Create;
  firebird.getModulo('sueldos');
  firebird.Conectar(firebird.Host + '\arch\arch.gdb', firebird.Usuario, firebird.Password);
  tabla   := firebird.InstanciarTabla('empresas');
  eleempr := firebird.InstanciarTabla('eleempr');
end;

destructor TTDatosEmpresas.Destroy;
begin
  inherited Destroy;
end;

function TTDatosEmpresas.Nuevo: string;
// Objetivo...: Generar un nuevo ID
begin
  tabla.IndexFieldNames := 'CODIGO';
  tabla.Last;
  if tabla.RecordCount = 0 then Result := '1' else Begin
    Result := IntToStr(StrToInt(tabla.FieldByName('codigo').AsString) + 1);
  end;
end;

function TTDatosEmpresas.Buscar(xcodigo: string): boolean;
// Objetivo...: Buscar el Objeto solicitado
begin
  Result := firebird.Buscar(tabla, 'codigo', xcodigo);
end;

procedure TTDatosEmpresas.Grabar(xcodigo, xnombre, xcuit, xdomicilio, xactividad, xnomvia: string);
// Objetivo...: Grabar Atributos del Objeto
begin
  if Buscar(xcodigo) then tabla.Edit else tabla.Append;
  tabla.FieldByName('codigo').AsString    := xcodigo;
  tabla.FieldByName('nombre').AsString    := xnombre;
  tabla.FieldByName('cuit').AsString      := xcuit;
  tabla.FieldByName('domicilio').AsString := xdomicilio;
  tabla.FieldByName('actividad').AsString := xactividad;
  tabla.FieldByName('nomvia').AsString    := xnomvia;
  try
    tabla.Post;
   except
    tabla.Cancel
  end;
  firebird.RegistrarTransaccion(tabla);
end;

procedure TTDatosEmpresas.Borrar(xcodigo: string);
// Objetivo...: Eliminar un Objeto
begin
  if Buscar(xcodigo) then Begin
    tabla.Delete;
    getDatos(tabla.FieldByName('codigo').AsString);  // Fijamos los Atributos Siguientes al Objeto Borrado
    firebird.RegistrarTransaccion(tabla);
  end;
end;

procedure  TTDatosEmpresas.getDatos(xcodigo: string);
// Objetivo...: Retornar/Iniciar Atributos
begin
  if Buscar(xcodigo) then Begin
    codigo      := tabla.FieldByName('codigo').AsString;
    nombre      := tabla.FieldByName('nombre').AsString;
    cuit        := tabla.FieldByName('cuit').AsString;
    domicilio   := tabla.FieldByName('domicilio').AsString;
    actividad   := tabla.FieldByName('actividad').AsString;
    nomvia      := tabla.FieldByName('nomvia').AsString;
  end else Begin
    codigo := ''; nombre := ''; cuit := ''; actividad := ''; nomvia := ''; domicilio := '';
  end;
end;

procedure TTDatosEmpresas.BuscarPorDescrip(xexpr: string);
// Objetivo...: Busqueda contextual
begin
  firebird.BuscarContextualmente(tabla, 'nombre', xexpr);
end;

procedure TTDatosEmpresas.BuscarPorCodigo(xexpr: string);
// Objetivo...: Busqueda contextual
begin
  firebird.BuscarContextualmente(tabla, 'codigo', xexpr);
end;

procedure TTDatosEmpresas.Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
// Objetivo...: Listar colección de objetos
begin
  if orden = 'A' then tabla.IndexName := tabla.IndexDefs.Items[1].Name;

  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Listado de Empresas', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Cód.', 1, 'Arial, cursiva, 8');
  List.Titulo(5, list.Lineactual, 'Razón Social', 2, 'Arial, cursiva, 8');
  List.Titulo(40, list.Lineactual, 'Dirección', 3, 'Arial, cursiva, 8');
  List.Titulo(60, list.Lineactual, 'C.U.I.T.', 4, 'Arial, cursiva, 8');
  List.Titulo(75, list.Lineactual, 'Vía de Trabajo', 5, 'Arial, cursiva, 8');
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
      if (tabla.FieldByName('NOMBRE').AsString >= iniciar) and (tabla.FieldByName('NOMBRE').AsString <= finalizar) then ListLinea(salida);
    if (ent_excl = 'X') and (orden = 'A') then
      if (tabla.FieldByName('NOMBRE').AsString < iniciar) or (tabla.FieldByName('NOMBRE').AsString > finalizar) then ListLinea(salida);

    tabla.Next;
  end;
  List.FinList;

  tabla.IndexFieldNames := tabla.IndexFieldNames;
  tabla.First;
end;

procedure TTDatosEmpresas.ListLinea(salida: char);
begin
  List.Linea(0, 0, tabla.FieldByName('codigo').AsString, 1, 'Arial, normal, 8', salida, 'N');
  List.Linea(5, list.Lineactual, tabla.FieldByName('nombre').AsString, 2, 'Arial, normal, 8', salida, 'N');
  List.Linea(40, list.Lineactual, tabla.FieldByName('domicilio').AsString, 3, 'Arial, normal, 8', salida, 'N');
  List.Linea(60, list.Lineactual, tabla.FieldByName('cuit').AsString, 4, 'Arial, normal, 8', salida, 'N');
  List.Linea(75, list.Lineactual, tabla.FieldByName('nomvia').AsString, 5, 'Arial, normal, 8', salida, 'S');
end;

procedure TTDatosEmpresas.SeleccionarEmpresa(xcodemp, xperiodo: String);
// Objetivo...: Seleccionar Empresa
begin
  eleempr.Open;
  if eleempr.RecordCount = 0 then eleempr.Append else eleempr.Edit;
  eleempr.FieldByName('codigo').AsString  := xcodemp;
  eleempr.FieldByName('periodo').AsString := xperiodo;
  try
    eleempr.Post
   except
    eleempr.Cancel
  end;
  firebird.RegistrarTransaccion(eleempr);
  firebird.closeDB(eleempr);
end;

function  TTDatosEmpresas.setEmpresaSeleccionada: String;
// Objetivo...: Devolver empresa seleccionada
begin
  Result := '';
  eleempr.Open;
  if eleempr.RecordCount > 0 then Begin
    eleempr.First;
    Result := eleempr.FieldByName('codigo').AsString;
  end;
  firebird.closeDB(eleempr);
end;

function TTDatosEmpresas.setViaSeleccionada: String;
// Objetivo...: Recuperar Vía Seleccionada
Begin
  codigo := setEmpresaSeleccionada;
  getDatos(codigo);
  Result := nomvia;
end;

procedure TTDatosEmpresas.conectar;
// Objetivo...: Abrir tablas de persistencia
begin
  if conexiones = 0 then Begin
    if not tabla.Active then tabla.Open;
  end;
  tabla.FieldByName('codigo').DisplayLabel := 'Código'; tabla.FieldByName('nombre').DisplayLabel := 'Razón Social';
  tabla.FieldByName('cuit').DisplayLabel := 'C.U.I.T.'; tabla.FieldByName('actividad').DisplayLabel := 'Actividad';
  tabla.FieldByName('nomvia').DisplayLabel := 'Vía de Trabajo'; tabla.FieldByName('domicilio').DisplayLabel := 'Dirección';
  firebird.RegistrarTransaccion(tabla);
  via.conectar;
  Inc(conexiones);
end;

procedure TTDatosEmpresas.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones > 0 then Dec(conexiones);
  if conexiones = 0 then firebird.closeDB(tabla);
  via.desconectar;
end;

{===============================================================================}

function empresa: TTDatosEmpresas;
begin
  if xempresa = nil then
    xempresa := TTDatosEmpresas.Create;
  Result := xempresa;
end;

{===============================================================================}

initialization

finalization
  xempresa.Free;

end.
