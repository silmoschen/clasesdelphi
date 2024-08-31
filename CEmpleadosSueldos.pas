unit CEmpleadosSueldos;

interface

uses SysUtils, DB, DBTables, CUtiles, CListar, CFirebird, CEmpresasSueldos, CCategoriaSueldos,
     IBDatabase, IBCustomDataSet, IBTable, Variants, CGremioSueldos, Classes, CAsignacionesFliaresSueldos;
type

TTDatosEmpleado = class(TObject)
  Nrolegajo, Nombre, Domicilio, DNI, CUIL, FechaIng, Fechanac, Catlab, TipoCobro, Ctabcaria, codgremio, Fecharecon,
  Estcivil, Liqasig, Conyuge, TipoLiq, Codcat, Jubilacion, Seccion, Contratacion, Calificacion: String;
  Sueldo: Real;
  tabla, hijos: TIBTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  function    Nuevo: string;
  function    Buscar(xnrolegajo: string): boolean;
  procedure   Grabar(xnrolegajo, xnombre, xdomicilio, xDNI, xCUIL, xFechaIng, xFechanac, xCatlab, xTipoCobro, xCtabcaria, xgremio, xFecharecon, xEstcivil, xLiqasig, xConyuge, xcodcat, xtipoliq, xjubilacion, xseccion, xcontratacion, xcalificacion: string; xsueldo: Real);
  procedure   Borrar(xnrolegajo: string);
  procedure   getDatos(xnrolegajo: string);
  procedure   BuscarPorDescrip(xexpr: string);
  procedure   BuscarPorCodigo(xexpr: string);
  procedure   Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
  function    setEmpleados: TStringList;

  function    BuscarHijo(xnrolegajo, xitems: String): Boolean;
  procedure   GrabarHijo(xnrolegajo, xitems, xnombre, xdni, xfechanac: String; xcantitems: Integer);
  procedure   BorrarHijo(xnrolegajo, xitems: String); overload;
  procedure   BorrarHijo(xnrolegajo: String); overload;
  function    setHijos(xnrolegajo: String): TStringList;

  function    setAntiguedad(xnrolegajo: String): String;
  function    setCategoria(xnrolegajo: String): String;

  function    setMontoAsignacionesHijo(xnrolegajo: String): Real;

  procedure   conectar;
  procedure   desconectar;
 private
  conexiones: shortint;
  objfirebird: TTFirebird;
  { Declaraciones Privadas }
  procedure ListLinea(salida: char);
end;

function empleado: TTDatosEmpleado;

implementation

var
  xempleado: TTDatosEmpleado = nil;

constructor TTDatosEmpleado.Create;
begin
  inherited Create;
  objfirebird := TTFirebird.Create;
  firebird.getModulo('sueldos');
  objfirebird.Conectar(firebird.Host + '\' + empresa.setViaSeleccionada + '\datosempr.gdb', firebird.Usuario, firebird.Password);
  tabla := objfirebird.InstanciarTabla('empleados');
  hijos := objfirebird.InstanciarTabla('hijos');
end;

destructor TTDatosEmpleado.Destroy;
begin
  inherited Destroy;
end;

function TTDatosEmpleado.Nuevo: string;
// Objetivo...: Generar un nuevo ID
begin
  tabla.IndexFieldNames := 'NROLEGAJO';
  tabla.Last;
  if tabla.RecordCount = 0 then Result := '1' else Begin
    Result := IntToStr(StrToInt(tabla.FieldByName('nrolegajo').AsString) + 1);
  end;
end;

function TTDatosEmpleado.Buscar(xnrolegajo: string): boolean;
// Objetivo...: Buscar el Objeto solicitado
begin
  Result := objfirebird.Buscar(tabla, 'nrolegajo', xnrolegajo);
end;

procedure TTDatosEmpleado.Grabar(xnrolegajo, xnombre, xdomicilio, xDNI, xCUIL, xFechaIng, xFechanac, xCatlab, xTipoCobro, xCtabcaria, xgremio, xFecharecon, xEstcivil, xLiqasig, xConyuge, xcodcat, xtipoliq, xjubilacion, xseccion, xcontratacion, xcalificacion: string; xsueldo: Real);
// Objetivo...: Grabar Atributos del Objeto
begin
  if Buscar(xnrolegajo) then tabla.Edit else tabla.Append;
  tabla.FieldByName('nrolegajo').AsString    := xnrolegajo;
  tabla.FieldByName('nombre').AsString       := xnombre;
  tabla.FieldByName('domicilio').AsString    := xdomicilio;
  tabla.FieldByName('DNI').AsString          := xdni;
  tabla.FieldByName('cuil').AsString         := xcuil;
  tabla.FieldByName('fechaing').AsString     := utiles.sExprFecha2000(xfechaing);
  tabla.FieldByName('fechanac').AsString     := utiles.sExprFecha2000(xfechanac);
  tabla.FieldByName('catlab').AsString       := xcatlab;
  tabla.FieldByName('tipocobro').AsString    := xtipocobro;
  tabla.FieldByName('ctabcaria').AsString    := xctabcaria;
  tabla.FieldByName('codgremio').AsString    := xgremio;
  tabla.FieldByName('fecharecon').AsString   := utiles.sExprFecha2000(xfecharecon);
  tabla.FieldByName('estcivil').AsString     := xestcivil;
  tabla.FieldByName('liqasig').AsString      := xliqasig;
  tabla.FieldByName('conyuge').AsString      := xconyuge;
  tabla.FieldByName('codcat').AsString       := xcodcat;
  tabla.FieldByName('tipoliq').AsString      := xtipoliq;
  tabla.FieldByName('sueldo').AsFloat        := xsueldo;
  tabla.FieldByName('jubilacion').AsString   := xjubilacion;
  tabla.FieldByName('seccion').AsString      := xseccion;
  tabla.FieldByName('contratacion').AsString := xcontratacion;
  tabla.FieldByName('calificacion').AsString := xcalificacion;
  try
    tabla.Post;
   except
    tabla.Cancel
  end;
  objfirebird.RegistrarTransaccion(tabla);
end;

procedure TTDatosEmpleado.Borrar(xnrolegajo: string);
// Objetivo...: Eliminar un Objeto
begin
  if Buscar(xnrolegajo) then Begin
    tabla.Delete;
    getDatos(tabla.FieldByName('nrolegajo').AsString);  // Fijamos los Atributos Siguientes al Objeto Borrado
    objfirebird.RegistrarTransaccion(tabla);
  end;
end;

procedure  TTDatosEmpleado.getDatos(xnrolegajo: string);
// Objetivo...: Retornar/Iniciar Atributos
begin
  if Buscar(xnrolegajo) then Begin
    nombre       := tabla.FieldByName('nombre').AsString;
    domicilio    := tabla.FieldByName('domicilio').AsString;
    dni          := tabla.FieldByName('dni').AsString;
    cuil         := tabla.FieldByName('cuil').AsString;
    fechaing     := utiles.sFormatoFecha(tabla.FieldByName('fechaing').AsString);
    fechanac     := utiles.sFormatoFecha(tabla.FieldByName('fechanac').AsString);
    catlab       := tabla.FieldByName('catlab').AsString;
    tipocobro    := tabla.FieldByName('tipocobro').AsString;
    ctabcaria    := tabla.FieldByName('ctabcaria').AsString;
    codgremio    := tabla.FieldByName('codgremio').AsString;
    fecharecon   := utiles.sFormatoFecha(tabla.FieldByName('fecharecon').AsString);
    estcivil     := tabla.FieldByName('estcivil').AsString;
    liqasig      := tabla.FieldByName('liqasig').AsString;
    conyuge      := tabla.FieldByName('conyuge').AsString;
    tipoliq      := tabla.FieldByName('tipoliq').AsString;
    codcat       := tabla.FieldByName('codcat').AsString;
    sueldo       := tabla.FieldByName('sueldo').AsFloat;
    jubilacion   := tabla.FieldByName('jubilacion').AsString;
    seccion      := tabla.FieldByName('seccion').AsString;
    contratacion := tabla.FieldByName('contratacion').AsString;
    calificacion := tabla.FieldByName('calificacion').AsString;
  end else Begin
    nombre := ''; domicilio := ''; dni := ''; cuil := ''; fechaing := ''; fechanac := ''; catlab := ''; tipocobro := ''; ctabcaria := ''; codgremio := ''; fecharecon := ''; estcivil := ''; liqasig := ''; conyuge := ''; jubilacion := '';
    tipoliq := ''; codcat := ''; sueldo := 0; seccion := ''; contratacion := ''; calificacion := '';
  end;
end;

procedure TTDatosEmpleado.BuscarPorDescrip(xexpr: string);
// Objetivo...: Busqueda contextual
begin
  objfirebird.BuscarContextualmente(tabla, 'nombre', xexpr);
end;

procedure TTDatosEmpleado.BuscarPorCodigo(xexpr: string);
// Objetivo...: Busqueda contextual
begin
  objfirebird.BuscarContextualmente(tabla, 'nrolegajo', xexpr);
end;

procedure TTDatosEmpleado.Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
// Objetivo...: Listar colección de objetos
begin
  if orden = 'A' then tabla.IndexName := tabla.IndexDefs.Items[1].Name;

  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Listado de Empleados', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Cód.', 1, 'Arial, cursiva, 8');
  List.Titulo(5, list.Lineactual, 'Nombre', 2, 'Arial, cursiva, 8');
  List.Titulo(35, list.Lineactual, 'Domicilio', 3, 'Arial, cursiva, 8');
  List.Titulo(55, list.Lineactual, 'Ingreso', 4, 'Arial, cursiva, 8');
  List.Titulo(65, list.Lineactual, 'C.U.I.L.', 5, 'Arial, cursiva, 8');
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

procedure TTDatosEmpleado.ListLinea(salida: char);
begin
  List.Linea(0, 0, tabla.FieldByName('codigo').AsString, 1, 'Arial, normal, 8', salida, 'N');
  List.Linea(5, list.Lineactual, tabla.FieldByName('nombre').AsString, 2, 'Arial, normal, 8', salida, 'N');
  List.Linea(35, list.Lineactual, tabla.FieldByName('domicilio').AsString, 3, 'Arial, normal, 8', salida, 'N');
  List.Linea(55, list.Lineactual, utiles.sFormatoFecha(tabla.FieldByName('ingreso').AsString), 4, 'Arial, normal, 8', salida, 'N');
  List.Linea(65, list.Lineactual, tabla.FieldByName('cuil').AsString, 5, 'Arial, normal, 8', salida, 'S');
end;

function  TTDatosEmpleado.setEmpleados: TStringList;
// Objetivo...: Devolver Lista de Empleados
var
  l: TStringList;
  i: Integer;
begin
  l := TStringList.Create;
  tabla.IndexFieldNames := 'NOMBRE';
  tabla.First;
  while not tabla.Eof do Begin
    l.Add(tabla.FieldByName('nrolegajo').AsString + tabla.FieldByName('nombre').AsString);
    tabla.Next;
  end;
  tabla.IndexFieldNames := 'NROLEGAJO';
  Result := l;
end;

function  TTDatosEmpleado.BuscarHijo(xnrolegajo, xitems: String): Boolean;
// Objetivo...: Buscar Instancia
begin
  Result := objfirebird.Buscar(hijos, 'nrolegajo;items', xnrolegajo, xitems);
end;

procedure TTDatosEmpleado.GrabarHijo(xnrolegajo, xitems, xnombre, xdni, xfechanac: String; xcantitems: Integer);
// Objetivo...: Abrir tablas de persistencia
begin
  if BuscarHijo(xnrolegajo, xitems) then hijos.Edit else hijos.Append;
  hijos.FieldByName('nrolegajo').AsString := xnrolegajo;
  hijos.FieldByName('items').AsString     := xitems;
  hijos.FieldByName('nombre').AsString    := xnombre;
  hijos.FieldByName('fechanac').AsString  := utiles.sExprFecha2000(xfechanac);
  hijos.FieldByName('dni').AsString       := xdni;
  try
    hijos.Post
   except
    hijos.Cancel
  end;
  objfirebird.RegistrarTransaccion(hijos);

  if xitems = utiles.sLlenarIzquierda(IntToStr(xcantitems), 2, '0') then Begin
    objfirebird.TransacSQL('delete from hijos where nrolegajo = ' + '''' + xnrolegajo + '''' + ' and items > ' + '''' + xitems + '''');
    objfirebird.RegistrarTransaccion(hijos);
  end;
end;

procedure  TTDatosEmpleado.BorrarHijo(xnrolegajo, xitems: String);
// Objetivo...: Abrir tablas de persistencia
begin
  if BuscarHijo(xnrolegajo, xitems) then Begin
    hijos.Delete;
    objfirebird.RegistrarTransaccion(hijos);
  end;
end;

procedure  TTDatosEmpleado.BorrarHijo(xnrolegajo: String);
// Objetivo...: Abrir tablas de persistencia
begin
  objfirebird.TransacSQL('delete from hijos where nrolegajo = ' + '''' + xnrolegajo + '''');
  objfirebird.RegistrarTransaccion(hijos);
end;

function  TTDatosEmpleado.setHijos(xnrolegajo: String): TStringList;
// Objetivo...: Abrir tablas de persistencia
var
  l: TStringList;
begin
  l := TStringList.Create;
  objfirebird.Filtrar(hijos, 'nrolegajo = ' + '''' + xnrolegajo + '''');
  hijos.First;
  while not hijos.Eof do Begin
    l.Add(hijos.FieldByName('items').AsString + utiles.sFormatoFecha(hijos.FieldByName('fechanac').AsString) + hijos.FieldByName('dni').AsString + ';1' + hijos.FieldByName('nombre').AsString);
    hijos.Next;
  end;
  objfirebird.QuitarFiltro(hijos);

  Result := l;
end;

function  TTDatosEmpleado.setAntiguedad(xnrolegajo: String): String;
// Objetivo...: Calcular la Antiguedad del Empleado
Begin
  Result := '0';
  if Buscar(xnrolegajo) then Begin
    utiles.calc_antiguedad(tabla.FieldByName('fechaing').AsString, utiles.sExprFecha2000(utiles.setFechaActual));
    Result := IntToStr(utiles.getAnios);
  end;
end;

function  TTDatosEmpleado.setMontoAsignacionesHijo(xnrolegajo: String): Real;
// Objetivo...: Recuperar Monto Asignaciones Hijos
var
  cantidad: Real;
begin
  cantidad := 0;
  objfirebird.Filtrar(hijos, 'nrolegajo = ' + '''' + xnrolegajo + '''');
  hijos.First;
  while not hijos.Eof do Begin
    cantidad := cantidad + 1;
    hijos.Next;
  end;
  objfirebird.QuitarFiltro(hijos);

  if cantidad = 0 then Result := 0 else Begin
    getDatos(xnrolegajo);
    Result := cantidad * asignaciones.setMonto(sueldo);
  end;
end;

function TTDatosEmpleado.setCategoria(xnrolegajo: String): String;
// Objetivo...: Devolver Categoria
begin
  getDatos(xnrolegajo);
  categoria.getDatos(codcat);
  Result := categoria.Categoria; 
end;

procedure TTDatosEmpleado.conectar;
// Objetivo...: Abrir tablas de persistencia
begin
  if conexiones = 0 then Begin
    if not tabla.Active then tabla.Open;
    if not hijos.Active then hijos.Open;
  end;
  {tabla.FieldByName('codigo').DisplayLabel := 'Código'; tabla.FieldByName('nombre').DisplayLabel := 'Razón Social';
  tabla.FieldByName('cuit').DisplayLabel := 'C.U.I.T.'; tabla.FieldByName('actividad').DisplayLabel := 'Actividad';
  tabla.FieldByName('nomvia').DisplayLabel := 'Vía de Trabajo'; tabla.FieldByName('domicilio').DisplayLabel := 'Dirección';
  objfirebird.RegistrarTransaccion(tabla);}
  gremio.conectar;
  categoria.conectar;
  asignaciones.conectar;
  Inc(conexiones);
end;

procedure TTDatosEmpleado.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones > 0 then Dec(conexiones);
  if conexiones = 0 then Begin
    objfirebird.closeDB(tabla);
    objfirebird.closeDB(hijos);
  end;
  gremio.desconectar;
  categoria.desconectar;
  asignaciones.desconectar;
end;

{===============================================================================}

function empleado: TTDatosEmpleado;
begin
  if xempleado = nil then
    xempleado := TTDatosEmpleado.Create;
  Result := xempleado;
end;

{===============================================================================}

initialization

finalization
  xempleado.Free;

end.
