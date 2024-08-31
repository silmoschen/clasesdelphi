unit CObrasSociales;

interface

uses CNomecla, SysUtils, DB, DBTables, CIDBFM, CListar, Classes, CUtiles, CBDT,
     CUtilidadesArchivos;

type

TTObraSocial = class
  codos, nombre, nombrec, direccion, codpos, tope, periodo, FactNBU: string; UB, UG, RIEUB, RIEUG, porcentaje, topemin, topemax, Retencioniva, ValorNBU: Real;
  tabla, apfijos, aranceles, texport: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  procedure   Grabar(xcodos, xnombre, xnombrec, xdireccion, xcodpos, xtope: string; xUB, xUG, xRIEUB, xRIEUG, xporcentaje, xtopemin, xtopemax, xretencioniva: real);
  procedure   Borrar(xcodos: string);
  function    Buscar(xcodos: string): boolean;
  function    Nuevo: string;
  procedure   getDatos(xcodos: string);
  function    setobsocials: TQuery;
  function    setobsocialsAlf: TQuery;
  procedure   BuscarPorCodigo(xexp: string);
  procedure   BuscarPorNombre(xexp: string);

  function    BuscarAnalisisMontoFijo(xcodos, xitems: string): boolean;
  procedure   GrabarAnalisisMontoFijo(xcodos, xitems, xcodanalisis, xperiodo: string; ximporte: real; xcantitems: Integer);
  procedure   BorrarAnalisisMontoFijo(xcodos, xitems: string);
  function    setAnalisisMontoFijo(xcodos: string): TQuery;
  function    VerifcarSiElAnalisisTieneMontoFijo(xcodos, xcodanalisis: string): Real;
  function    setMontoFijo(xcodos, xcodanalisis, xperiodo: String): Real;

  procedure   Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
  procedure   ListarAnalisisMontoFijo(orden, iniciar, finalizar, ent_excl: string; salida: char);
  procedure   ListarNomecladorValorizado(orden, iniciar, finalizar, ent_excl: String; salida: Char);

  { Manejo de Aranceles }
  function    BuscarArancel(xcodos, xperiodo: String): Boolean;
  procedure   GuardarArancel(xcodos, xperiodo, xtope: String; xub, xug, xrieub, xrieug: Real);
  procedure   BorrarArancel(xcodos, xperiodo: String);
  function    setAranceles(xcodos: String): TStringList;
  procedure   ObtenerUltimosAranceles(xcodos: String);
  procedure   SincronizarArancel(xcodos, xperiodo: String);

  procedure   ImportarObrasSocialesXML(xlista: TStringList);
  procedure   ImportarAnalisisMontoFijoXML(xlista: TStringList);
  procedure   ImportarArancelesXML(xlista: TStringList);

  function    setObrasSocialesImportadas: TQuery;
  procedure   DescompactarArchivosActualizaciones;

  function    setMontoFijoNBU(xcodos, xcodanalisis, xperiodo: String): Real;
  function    setUnidadNBU(xcodos, xcodanalisis, xperiodo: String): Real;

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  conexiones: shortint;
  idant: String;
  r: TQuery;
  lista, lista1, lista2, ltope: TStringList;
  procedure   ListLinea(salida: char);
  procedure   ListLineaMFijos(salida: char);
  procedure   ListDeterminaciones(salida: char);
  function    setValorAnalisis(xcodos, xcodanalisis: string; xOSUB, xNOUB, xOSUG, xNOUG: real): real;
  procedure   CargarListaApFijos;
  procedure   Enccol;
  procedure   CargarLista;
end;

function obsocial: TTObraSocial;

implementation

var
  xobsocial: TTObraSocial = nil;

constructor TTObraSocial.Create;
begin
  inherited create;
  tabla     := datosdb.openDB('obsocial', '', '', dbs.baseDat);
  apfijos   := datosdb.openDB('apfijos', '', '', dbs.baseDat);
  aranceles := datosdb.openDB('obsociales_aranceles', '', '', dbs.baseDat);
  if dbs.BaseClientServ = 'N' then Begin
    if not datosdb.verificarSiExisteCampo('obsociales_aranceles', 'tope', dbs.baseDat) then datosdb.tranSQL('alter table obsociales_aranceles add tope char(1)');
  end else Begin
    if not datosdb.verificarSiExisteCampo('obsociales_aranceles', 'tope', dbs.baseDat) then datosdb.tranSQL('alter table obsociales_aranceles add tope varchar(1)');
  end;
  factNBU := 'N';
  ValorNBU := 0;
end;

destructor TTObraSocial.Destroy;
begin
  inherited Destroy;
end;

procedure TTObraSocial.Grabar(xcodos, xnombre, xnombrec, xdireccion, xcodpos, xtope: string; xUB, xUG, xRIEUB, xRIEUG, xporcentaje, xtopemin, xtopemax, xretencioniva: real);
// Objetivo...: Grabar Atributos del Objeto
begin
  if Buscar(xcodos) then tabla.Edit else tabla.Append;
  tabla.FieldByName('codos').AsString       := xcodos;
  tabla.FieldByName('nombre').AsString      := TrimLeft(xnombre);
  tabla.FieldByName('tope').AsString        := xtope;
  tabla.FieldByName('nombrec').AsString     := TrimLeft(xnombrec);
  tabla.FieldByName('direccion').AsString   := TrimLeft(xdireccion);
  tabla.FieldByName('codpos').AsString      := TrimLeft(xcodpos);
  tabla.FieldByName('UB').AsFloat           := xUB;
  tabla.FieldByName('UG').AsFloat           := xUG;
  tabla.FieldByName('RIEUB').AsFloat        := xRIEUB;
  tabla.FieldByName('RIEUG').AsFloat        := xRIEUG;
  tabla.FieldByName('porcentaje').AsFloat   := xporcentaje;
  tabla.FieldByName('topemin').AsFloat      := xtopemin;
  tabla.FieldByName('topemax').AsFloat      := xtopemax;
  tabla.FieldByName('retencioniva').AsFloat := xretencioniva;
  try
    tabla.Post
   except
    tabla.Cancel
  end;
  datosdb.refrescar(tabla);
end;

procedure TTObraSocial.Borrar(xcodos: string);
// Objetivo...: Eliminar un Objeto
begin
  if Buscar(xcodos) then Begin
    tabla.Delete;
    datosdb.refrescar(tabla);
    getDatos(tabla.FieldByName('codos').AsString);  // Fijamos los Atributos Siguientes al Objeto Borrado
  end;
end;

function TTObraSocial.Buscar(xcodos: string): boolean;
// Objetivo...: Buscar el Objeto solicitado
begin
  if not tabla.Active then Begin
    tabla.Open;
    Enccol;
  end;
  if tabla.IndexFieldNames <> 'codos' then tabla.IndexFieldNames := 'codos';
  if tabla.FindKey([xcodos]) then Result := True else Result := False;
end;

procedure  TTObraSocial.getDatos(xcodos: string);
// Objetivo...: Retornar/Iniciar Atributos
begin
  if tabla.IndexFieldNames <> 'codos' then tabla.IndexFieldNames := 'codos';
  if Buscar(xcodos) then Begin
    codos        := tabla.FieldByName('codos').AsString;
    nombre       := tabla.FieldByName('nombre').AsString;
    nombrec      := tabla.FieldByName('nombrec').AsString;
    direccion    := tabla.FieldByName('direccion').AsString;
    codpos       := tabla.FieldByName('codpos').AsString;
    tope         := tabla.FieldByName('tope').AsString;
    UB           := tabla.FieldByName('UB').AsFloat;
    UG           := tabla.FieldByName('UG').AsFloat;
    RIEUB        := tabla.FieldByName('RIEUB').AsFloat;
    RIEUG        := tabla.FieldByName('RIEUG').AsFloat;
    topemax      := tabla.FieldByName('topemax').AsFloat;
    topemin      := tabla.FieldByName('topemin').AsFloat;
    porcentaje   := tabla.FieldByName('porcentaje').AsFloat;
    retencioniva := tabla.FieldByName('retencioniva').AsFloat;
    if porcentaje = 0 then porcentaje := 100;
    ObtenerUltimosAranceles(xcodos);
  end else Begin
    codos := ''; nombre := ''; nombrec := ''; tope := ''; direccion := ''; codpos := ''; UB := 0; UG := 0; RIEUB := 0; RIEUG := 0; porcentaje := 100; topemin := 0; topemax := 0; retencioniva := 0;
  end;
end;

function TTObraSocial.Nuevo: string;
// Objetivo...: Generar un Nuevo Atributo Código
begin
  if tabla.IndexFieldNames <> 'codos' then tabla.IndexFieldNames := 'codos';
  tabla.Last;
  if Length(Trim(tabla.FieldByName('codos').AsString)) > 0 then Result := utiles.sLLenarIzquierda(IntToStr(tabla.FieldByName('codos').AsInteger + 1), 4, '0') else Result := '0001';
end;

function TTObraSocial.setobsocials: TQuery;
// Objetivo...: retornar un set de obsocials
begin
  Result := datosdb.tranSQL('SELECT codos, nombre FROM obsocial');
end;

function TTObraSocial.setobsocialsAlf: TQuery;
// Objetivo...: retornar un set de obsocials
begin
  Result := datosdb.tranSQL('SELECT codos, nombre FROM obsocial ORDER BY nombre');
end;

procedure TTObraSocial.Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
// Objetivo...: Listar colección de objetos
begin
  if orden = 'A' then tabla.IndexFieldNames := 'Nombre';

  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Listado de Obras Sociales', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Código   Obra Social', 1, 'Arial, cursiva, 8');
  List.Titulo(40, list.Lineactual, 'Dirección', 2, 'Arial, cursiva, 8');
  List.Titulo(81, list.Lineactual, 'UB', 3, 'Arial, cursiva, 8');
  List.Titulo(86, list.Lineactual, 'UG', 4, 'Arial, cursiva, 8');
  List.Titulo(90, list.Lineactual, 'RIE UB', 5, 'Arial, cursiva, 8');
  List.Titulo(95, list.Lineactual, 'RIE UG', 6, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  tabla.First;
  while not tabla.EOF do
    begin
      // Ordenado por Código
      if (ent_excl = 'E') and (orden = 'C') then
        if (tabla.FieldByName('codos').AsString >= iniciar) and (tabla.FieldByName('codos').AsString <= finalizar) then ListLinea(salida);
      if (ent_excl = 'X') and (orden = 'C') then
        if (tabla.FieldByName('codos').AsString < iniciar) or (tabla.FieldByName('codos').AsString > finalizar) then ListLinea(salida);
      // Ordenado Alfabéticamente
      if (ent_excl = 'E') and (orden = 'A') then
        if (tabla.FieldByName('nombre').AsString >= iniciar) and (tabla.FieldByName('nombre').AsString <= finalizar) then ListLinea(salida);
      if (ent_excl = 'X') and (orden = 'A') then
        if (tabla.FieldByName('nombre').AsString < iniciar) or (tabla.FieldByName('nombre').AsString > finalizar) then ListLinea(salida);

      tabla.Next;
    end;
    List.FinList;

    tabla.IndexFieldNames := tabla.IndexFieldNames;
    tabla.First;
end;

procedure TTObraSocial.ListLinea(salida: char);
begin
  List.Linea(0, 0, tabla.FieldByName('codos').AsString + '  ' + Copy(tabla.FieldByName('nombre').AsString, 1, 35), 1, 'Arial, normal, 8', salida, 'N');
  List.Linea(40, list.Lineactual, Copy(tabla.FieldByName('nombrec').AsString, 1, 47), 2, 'Arial, normal, 8', salida, 'N');
  List.importe(84, list.Lineactual, '', tabla.FieldByName('UB').AsFloat, 3, 'Arial, normal, 8');
  List.importe(89, list.Lineactual, '', tabla.FieldByName('UG').AsFloat, 4, 'Arial, normal, 8');
  List.importe(94, list.Lineactual, '', tabla.FieldByName('RIEUB').AsFloat, 5, 'Arial, normal, 8');
  List.importe(99, list.Lineactual, '', tabla.FieldByName('RIEUG').AsFloat, 6, 'Arial, normal, 8');
  List.Linea(100, list.Lineactual, ' ', 7, 'Arial, normal, 8', salida, 'S');
end;

procedure TTObraSocial.ListarAnalisisMontoFijo(orden, iniciar, finalizar, ent_excl: string; salida: char);
Begin
  idant := '';
  if orden = 'C' then r := datosdb.tranSQL('SELECT apfijos.*, obsocial.Nombre FROM apfijos, obsocial WHERE apfijos.codos = obsocial.codos ORDER BY apfijos.codos, apfijos.codanalisis');
  if orden = 'A' then r := datosdb.tranSQL('SELECT apfijos.*, obsocial.Nombre FROM apfijos, obsocial WHERE apfijos.codos = obsocial.codos ORDER BY obsocial.nombre, apfijos.codanalisis');

  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Listado de Determinaciones con Monto Fijo', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Código  Detrminación', 1, 'Arial, cursiva, 8');
  List.Titulo(86, list.Lineactual, 'Importe', 2, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  r.Open; r.First;
  while not r.EOF do Begin
    // Ordenado por Código
    if (ent_excl = 'E') and (orden = 'C') then
      if (r.FieldByName('codos').AsString >= iniciar) and (r.FieldByName('codos').AsString <= finalizar) then ListLineaMFijos(salida);
    if (ent_excl = 'X') and (orden = 'C') then
      if (r.FieldByName('codos').AsString < iniciar) or (r.FieldByName('codos').AsString > finalizar) then ListLineaMFijos(salida);
    // Ordenado Alfabéticamente
    if (ent_excl = 'E') and (orden = 'A') then
      if (r.FieldByName('Nombre').AsString >= iniciar) and (r.FieldByName('Nombre').AsString <= finalizar) then ListLineaMFijos(salida);
    if (ent_excl = 'X') and (orden = 'A') then
      if (r.FieldByName('Nombre').AsString < iniciar) or (r.FieldByName('Nombre').AsString > finalizar) then ListLineaMFijos(salida);

    r.Next;
  end;
  r.Close; r.Free;
  List.FinList;
end;

procedure TTObraSocial.ListLineaMFijos(salida: char);
// Objetivo...: Listar Linea
begin
  if r.FieldByName('codos').AsString <> idant then Begin
    obsocial.getDatos(r.FieldByName('codos').AsString);
    List.Linea(0, 0, r.FieldByName('codos').AsString + '   ' + obsocial.Nombre, 1, 'Arial, normal, 8', salida, 'N');
    idant := r.FieldByName('codos').AsString;
  end else
    List.Linea(0, 0, '   ', 1, 'Arial, normal, 8', salida, 'N');
  nomeclatura.getDatos(r.FieldByName('codanalisis').AsString);
  List.Linea(45, list.Lineactual, r.FieldByName('codanalisis').AsString + '   ' + nomeclatura.descrip, 2, 'Arial, normal, 8', salida, 'N');
  List.Importe(91, list.Lineactual, '', r.FieldByName('importe').AsFloat, 3, 'Arial, normal, 8');
  List.Linea(93, list.Lineactual, '', 4, 'Arial, normal, 8', salida, 'S');
end;

procedure TTObraSocial.ListarNomecladorValorizado(orden, iniciar, finalizar, ent_excl: String; salida: Char);
// Objetivo...: Listar el nomeclador para una obra social
Begin
  idant := '';
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Nomeclador Nacional Normalizado', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Código  Determinación', 1, 'Arial, cursiva, 8');
  List.Titulo(67, list.Lineactual, 'U.G.', 2, 'Arial, cursiva, 8');
  List.Titulo(77, list.Lineactual, 'U.B.', 3, 'Arial, cursiva, 8');
  List.Titulo(81, list.Lineactual, 'C.Fact.', 4, 'Arial, cursiva, 8');
  List.Titulo(91, list.Lineactual, 'Importe', 5, 'Arial, cursiva, 8');
  List.Titulo(97, list.Lineactual, 'RIE', 6, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  tabla.Open; tabla.First;
  while not tabla.EOF do Begin
    // Ordenado por Código
    if (ent_excl = 'E') and (orden = 'C') then
      if (tabla.FieldByName('codos').AsString >= iniciar) and (tabla.FieldByName('codos').AsString <= finalizar) then ListDeterminaciones(salida);
    if (ent_excl = 'X') and (orden = 'C') then
      if (tabla.FieldByName('codos').AsString < iniciar) or (tabla.FieldByName('codos').AsString > finalizar) then ListDeterminaciones(salida);
    // Ordenado Alfabéticamente
    if (ent_excl = 'E') and (orden = 'A') then
      if (tabla.FieldByName('Nombre').AsString >= iniciar) and (tabla.FieldByName('Nombre').AsString <= finalizar) then ListDeterminaciones(salida);
    if (ent_excl = 'X') and (orden = 'A') then
      if (tabla.FieldByName('Nombre').AsString < iniciar) or (tabla.FieldByName('Nombre').AsString > finalizar) then ListDeterminaciones(salida);

    tabla.Next;
  end;
  List.FinList;
end;

procedure TTObraSocial.ListDeterminaciones(salida: char);
// Objetivo...: Listar una linea de detalle
var
  m: Real;
Begin
  List.Linea(0, 0, 'Obra Social: ' + tabla.FieldByName('codos').AsString + '    ' + tabla.FieldByName('nombre').AsString, 1, 'Arial, negrita, 9, clNavy', salida, 'S');
  List.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');
  r := nomeclatura.setNomeclatura;
  r.Open;
  while not r.Eof do Begin
    if r.FieldByName('RIE').AsString <> '*' then m := setValorAnalisis(tabla.FieldByName('codos').AsString, r.FieldByName('codigo').AsString, r.FieldByName('ub').AsFloat, tabla.FieldByName('UB').AsFloat, r.FieldByName('gastos').AsFloat, tabla.FieldByName('UG').AsFloat) else m := setValorAnalisis(tabla.FieldByName('codos').AsString, r.FieldByName('codigo').AsString, r.FieldByName('ub').AsFloat, tabla.FieldByName('RIEUB').AsFloat, r.FieldByName('gastos').AsFloat, tabla.FieldByName('RIEUG').AsFloat);  // Valor de cada analisis
    List.Linea(0, 0, r.FieldByName('codigo').AsString + '    ' + r.FieldByName('descrip').AsString, 1, 'Arial, normal, 8', salida, 'N');
    List.importe(70, list.lineactual, '', r.FieldByName('gastos').AsFloat, 2, 'Arial, normal, 8');
    List.importe(80, list.lineactual, '', r.FieldByName('ub').AsFloat, 3, 'Arial, normal, 8');
    List.Linea(81, list.lineactual, r.FieldByName('codfact').AsString, 4, 'Arial normal, 8', salida, 'N');
    List.importe(96, list.lineactual, '', m, 5, 'Arial, normal, 8');
    List.Linea(98, list.lineactual, r.FieldByName('RIE').AsString, 6, 'Arial, normal, 8', salida, 'S');
    r.Next;
  end;
  r.Close; r.Free;
  List.Linea(0, 0, ' ', 1, 'Arial, normal, 8', salida, 'N');
end;

function TTObraSocial.setValorAnalisis(xcodos, xcodanalisis: string; xOSUB, xNOUB, xOSUG, xNOUG: real): real;
var
  i, j, v, v9984, porcentOS: real; montoFijo: Boolean; codftoma: String;
begin
  // Verificamos el porcentaje que paga la Obra Social
  if obsocial.porcentaje > 0 then porcentOS := (obsocial.porcentaje * 0.01) else porcentOS := (100 * 0.01);

  i := 0; j := 0; v9984 := 0;
  // 1º Verificamos que el analisis no tenga monto Fijo
  i := obsocial.VerifcarSiElAnalisisTieneMontoFijo(xcodos, xcodanalisis);
  if i = 0 then Begin
    // Cálculamos el valor del análisis
    i := (xOSUB * xNOUB) + (xOSUG * xNOUG);

    montoFijo := False;
  end else montoFijo := True;
  // Calculamos el valor del codigo de toma y recepción
  if Length(Trim(nomeclatura.cftoma)) > 0 then Begin
    codftoma := nomeclatura.cftoma;  // Capturamos el código fijo de toma y recepcion
    nomeclatura.getDatos(codftoma);
    j := obsocial.VerifcarSiElAnalisisTieneMontoFijo(xcodos, codftoma);   // Verificamos si el 9984 tiene Monto Fijo

    if j = 0 then Begin      // Deducimos en Forma Normal
      v9984   := ((obsocial.UG * nomeclatura.ub) + (obsocial.UB * nomeclatura.gastos));

      if obsocial.tope = 'S' then Begin
        v := v9984;
        if v < obsocial.topemin then Begin
          v9984 := v * 2;   // Si monto menor a topemin entonces se multiplica por 2
        end;
        if (v > obsocial.topemin) and (v < obsocial.topemax) then v9984 := obsocial.topemax;  // Si esta comprendido entre los topes, toma el valor maximo
      end;
    end else Begin               // Monto Fijo del 9984
      v9984   := j;
    end;
  end;

  v := i;
  if not montoFijo then Begin          // Obras sociales que trabajan con topes
    if obsocial.tope = 'S' then Begin
      if v < obsocial.topemin then i := i * 2;   // Si monto menor a topemin entonces se multiplica por 2
      if (v > obsocial.topemin) and (v < obsocial.topemax) then i := obsocial.topemax;  // Si esta comprendido entre los topes, toma el valor maximo
    end;
  end;

  i := i * porcentOS;

  Result := i;
end;

procedure TTObraSocial.CargarListaApFijos;
// Objetivo...: Cargar una Lista con las referencias de los Aportes Fijos
Begin
  if lista2 = Nil then lista2 := TStringList.Create else lista2.Clear;
  apfijos.IndexFieldNames := 'codos;items';
  if not apfijos.Active then apfijos.Open;
  apfijos.First;
  while not apfijos.Eof do Begin
    lista2.Add(apfijos.FieldByName('codos').AsString + apfijos.FieldByName('items').AsString + apfijos.FieldByName('codanalisis').AsString + apfijos.FieldByName('importe').AsString + ';1' + apfijos.FieldByName('periodo').AsString);
    apfijos.Next;
  end;
end;

procedure TTObraSocial.BuscarPorCodigo(xexp: string);
begin
  tabla.IndexFieldNames := 'codos';
  tabla.FindNearest([xexp]);
end;

procedure TTObraSocial.BuscarPorNombre(xexp: string);
begin
  tabla.IndexFieldNames := 'Nombre';
  if Length(Trim(xexp)) > 0 then tabla.FindNearest([xexp]);
end;

function  TTObraSocial.BuscarAnalisisMontoFijo(xcodos, xitems: string): boolean;
begin
  if apfijos.IndexFieldNames <> 'codos;items' then apfijos.IndexFieldNames := 'codos;items';
  Result := datosdb.Buscar(apfijos, 'codos', 'items', xcodos, xitems);
end;

procedure TTObraSocial.GrabarAnalisisMontoFijo(xcodos, xitems, xcodanalisis, xperiodo: string; ximporte: real; xcantitems: integer);
begin
  if BuscarAnalisisMontoFijo(xcodos, xitems) then apfijos.Edit else apfijos.Append;
  apfijos.FieldByName('codos').AsString       := xcodos;
  apfijos.FieldByName('items').AsString       := xitems;
  apfijos.FieldByName('codanalisis').AsString := xcodanalisis;
  apfijos.FieldByName('periodo').AsString     := xperiodo;
  apfijos.FieldByName('importe').AsFloat      := ximporte;
  try
    apfijos.Post
  except
    apfijos.Cancel
  end;
  if xitems = utiles.sLlenarIzquierda(IntToStr(xcantitems), 3, '0') then Begin
    datosdb.tranSQL('delete from apfijos where codos = ' + '''' + xcodos + '''' + ' and items > ' + '''' + xitems + '''');
    datosdb.closeDB(apfijos); apfijos.Open;
    CargarListaApFijos;
  end;

end;

procedure TTObraSocial.BorrarAnalisisMontoFijo(xcodos, xitems: string);
begin
  if BuscarAnalisisMontoFijo(xcodos, xitems) then Begin
    datosdb.refrescar(apfijos);
    CargarListaApFijos;
    apfijos.Delete;
  end;
end;

function  TTObraSocial.setAnalisisMontoFijo(xcodos: string): TQuery;
begin
  Result := datosdb.tranSQL('SELECT * FROM apfijos WHERE codos = ' + '"' + xcodos + '"' + ' ORDER BY items');
end;

function  TTObraSocial.VerifcarSiElAnalisisTieneMontoFijo(xcodos, xcodanalisis: string): Real;
// Objetivo...: Verificar si el analisis tiene, para la obra social, monto fijo
begin
  if apfijos.IndexFieldNames <> 'codos;codanalisis' then apfijos.IndexFieldNames := 'codos;codanalisis';
  if BuscarAnalisisMontoFijo(xcodos, xcodanalisis) then Result := apfijos.FieldByName('importe').AsFloat else Result := 0;
end;

function TTObraSocial.setMontoFijo(xcodos, xcodanalisis, xperiodo: String): Real;
// Objetivo...: Recuperar Monto Fijo Análisis por Período
var
  i, p, p1, p2: Integer;
  r: Real;
  t: string;
Begin
  r := 0; t := '';
  For i := 1 to lista2.Count do Begin 
    p := Pos(';1', lista2.Strings[i-1]);
    if (xcodos = Copy(lista2.Strings[i-1], 1, 6)) and (xcodanalisis = Copy(lista2.Strings[i-1], 10, 4)) then Begin
      if Length(Trim(Copy(lista2.Strings[i-1], p+2, 7))) > 0 then Begin
        p1 := StrToInt(Copy(Copy(lista2.Strings[i-1], p+2, 7), 4, 4) + Copy(Copy(lista2.Strings[i-1], p+2, 7), 1, 2));
        p2 := StrToInt(Copy(xperiodo, 4, 4) + Copy(xperiodo, 1, 2));
        if  p1 >= p2 then Begin
          if p1 = p2 then t := (Copy(lista2.Strings[i-1], 14, p-14));
          Break;
        end;
        t := (Copy(lista2.Strings[i-1], 14, p-14));
      end;
    end;
  end;
  if Length(Trim(t)) = 0 then Result := r else Result := StrToFloat(t);
end;

function  TTObraSocial.BuscarArancel(xcodos, xperiodo: String): Boolean;
// Objetivo...: Buscar Arancel
Begin
  Result := datosdb.Buscar(aranceles, 'codos', 'periodo', xcodos, xperiodo);
end;

procedure TTObraSocial.GuardarArancel(xcodos, xperiodo, xtope: String; xub, xug, xrieub, xrieug: Real);
// Objetivo...: Guardar Arancel
Begin
  if BuscarArancel(xcodos, xperiodo) then aranceles.Edit else aranceles.Append;
  aranceles.FieldByName('codos').AsString   := xcodos;
  aranceles.FieldByName('periodo').AsString := xperiodo;
  aranceles.FieldByName('ub').AsFloat       := xub;
  aranceles.FieldByName('ug').AsFloat       := xug;
  aranceles.FieldByName('rieub').AsFloat    := xrieub;
  aranceles.FieldByName('rieug').AsFloat    := xrieug;
  aranceles.FieldByName('tope').AsString    := xtope;
  try
    aranceles.Post
   except
    aranceles.Cancel
  end;
  datosdb.closedb(aranceles); aranceles.Open;
  CargarLista;
end;

procedure TTObraSocial.BorrarArancel(xcodos, xperiodo: String);
// Objetivo...: Borrar Arancel
Begin
  if BuscarArancel(xcodos, xperiodo) then Begin
    aranceles.Delete;
    datosdb.refrescar(aranceles);
    CargarLista;
  end;
end;

function  TTObraSocial.setAranceles(xcodos: String): TStringList;
// Objetivo...: Recuperar Aranceles
var
  l, l1, l2: TStringList;
  i: Integer;
Begin
  l  := TStringList.Create;
  l1 := TStringList.Create;
  l2 := TStringList.Create;
  i  := 0;
  datosdb.Filtrar(aranceles, 'codos = ' + xcodos);
  while not aranceles.Eof do Begin
    l.Add(aranceles.FieldByName('periodo').AsString + ';1' + aranceles.FieldByName('ub').AsString + ';2' + aranceles.FieldByName('ug').AsString + ';3' + aranceles.FieldByName('rieub').AsString + ';4' + aranceles.FieldByName('rieug').AsString + ';5' + aranceles.FieldByName('tope').AsString);
    l1.Add(Copy(aranceles.FieldByName('periodo').AsString, 4, 4) + Copy(aranceles.FieldByName('periodo').AsString, 1, 2) + IntToStr(i));
    Inc(i);
    aranceles.Next;
  end;
  datosdb.QuitarFiltro(aranceles);
  l1.Sort;
  for i := 1 to l1.Count do
    l2.Add(l.Strings[StrToInt(Trim(Copy(l1.Strings[i-1], 7, 3)))]);
  l1.Destroy; l.Destroy;
  Result := l2;
end;

procedure TTObraSocial.ObtenerUltimosAranceles(xcodos: String);
// Objetivo...: Recuperar los Ultimos Aranceles Aranceles
var
  l: TStringList;
  i: Integer;
  j: array[1..5] of byte;
Begin
  l := setAranceles(xcodos);
  For i := 1 to l.Count do Begin
    j[1] := Pos(';1', l.Strings[i-1]);
    j[2] := Pos(';2', l.Strings[i-1]);
    j[3] := Pos(';3', l.Strings[i-1]);
    j[4] := Pos(';4', l.Strings[i-1]);
    j[5] := Pos(';5', l.Strings[i-1]);
    periodo := Copy(l.Strings[i-1], 1, 7);
    UB      := StrToFloat(utiles.FormatearNumero(Copy(l.Strings[i-1], j[1]+2, (j[2]-j[1]) - 2)));
    UG      := StrToFloat(utiles.FormatearNumero(Copy(l.Strings[i-1], j[2]+2, (j[3]-j[2]) - 2)));
    RIEUB   := StrToFloat(utiles.FormatearNumero(Copy(l.Strings[i-1], j[3]+2, (j[4]-j[3]) - 2)));
    RIEUG   := StrToFloat(utiles.FormatearNumero(Copy(l.Strings[i-1], j[4]+2, (j[5]-j[4]) - 2)));
  end;
end;

procedure TTObraSocial.SincronizarArancel(xcodos, xperiodo: String);
// Objetivo...: Sincronizar Aranceles
var
  i: Integer;
Begin
  if lista <> Nil then Begin
    For i := lista.Count downto 1 do Begin
      if (xcodos = Copy(lista.Strings[i-1], 1, 6)) and (Copy(lista.Strings[i-1], 7, 6) <=  Copy(xperiodo, 4, 4) + Copy(xperiodo, 1, 2)) then Begin
        if BuscarArancel(xcodos, Copy(lista.Strings[i-1], 11, 2) + '/' + Copy(lista.Strings[i-1], 7, 4)) then Begin
          UB      := aranceles.FieldByName('UB').AsFloat;
          UG      := aranceles.FieldByName('UG').AsFloat;
          RIEUB   := aranceles.FieldByName('RIEUB').AsFloat;
          RIEUG   := aranceles.FieldByName('RIEUG').AsFloat;
          tope    := aranceles.FieldByName('tope').AsString;
        end;
        Break;
      end;
    end;
  end;
end;

procedure TTObraSocial.CargarLista;
// Objetivo...: Cargar una Lista con las referencias de los aranceles de Obras Sociales
Begin
  if lista = Nil then lista := TStringList.Create else lista.Clear;
  if ltope = Nil then ltope := TStringList.Create else ltope.Clear;
  aranceles.First;
  while not aranceles.Eof do Begin
    lista.Add(aranceles.FieldByName('codos').AsString + Copy(aranceles.FieldByName('periodo').AsString, 4, 4) + Copy(aranceles.FieldByName('periodo').AsString, 1, 2));
    ltope.Add(aranceles.FieldByName('tope').AsString);
    aranceles.Next;
  end;

  lista.Sort;
end;

procedure TTObraSocial.ImportarObrasSocialesXML(xlista: TStringList);
// Objetivo...: Actualizar Datos a partir de una Fuente XML
Begin
  texport := datosdb.openDB('obsocial', '', '', dbs.DirSistema + '\actualizaciones_online\download\estructu');
  texport.Open;

  while not texport.Eof do Begin
    if utiles.verificarItemsLista(xlista, texport.FieldByName('codos').AsString) then Begin
      if Buscar(texport.FieldByName('codos').AsString) then tabla.Edit else tabla.Append;
      tabla.FieldByName('codos').AsString        := texport.FieldByName('codos').AsString;
      tabla.FieldByName('nombre').AsString       := texport.FieldByName('nombre').AsString;
      tabla.FieldByName('nombrec').AsString      := texport.FieldByName('nombrec').AsString;
      tabla.FieldByName('direccion').AsString    := texport.FieldByName('direccion').AsString;
      tabla.FieldByName('localidad').AsString    := texport.FieldByName('localidad').AsString;
      tabla.FieldByName('codpos').AsString       := texport.FieldByName('codpos').AsString;
      tabla.FieldByName('ub').AsString           := texport.FieldByName('ub').AsString;
      tabla.FieldByName('ug').AsString           := texport.FieldByName('ug').AsString;
      tabla.FieldByName('rieub').AsString        := texport.FieldByName('rieub').AsString;
      tabla.FieldByName('rieug').AsString        := texport.FieldByName('rieug').AsString;
      tabla.FieldByName('porcentaje').AsString   := texport.FieldByName('porcentaje').AsString;
      tabla.FieldByName('codpfis').AsString      := texport.FieldByName('codpfis').AsString;
      tabla.FieldByName('nrocuit').AsString      := texport.FieldByName('nrocuit').AsString;
      tabla.FieldByName('categoria').AsString    := texport.FieldByName('categoria').AsString;
      tabla.FieldByName('tope').AsString         := texport.FieldByName('tope').AsString;
      tabla.FieldByName('topemin').AsString      := texport.FieldByName('topemin').AsString;
      tabla.FieldByName('topemax').AsString      := texport.FieldByName('topemax').AsString;
      tabla.FieldByName('capitada').AsString     := texport.FieldByName('capitada').AsString;
      tabla.FieldByName('noimport').AsString     := texport.FieldByName('noimport').AsString;
      tabla.FieldByName('retencioniva').AsString := texport.FieldByName('retencioniva').AsString;
      tabla.FieldByName('retieneiva').AsString   := texport.FieldByName('retieneiva').AsString;
      tabla.FieldByName('factnbu').AsString      := texport.FieldByName('factnbu').AsString;
      tabla.FieldByName('pernbu').AsString       := texport.FieldByName('pernbu').AsString;
      try
        tabla.Post
       except
        tabla.Cancel
      end;
    end;
    texport.Next;
  end;

  datosdb.closedb(texport);
end;

procedure TTObraSocial.ImportarAnalisisMontoFijoXML;
// Objetivo...: Actualizar Datos a partir de una Fuente XML
Begin
  texport := datosdb.openDB('apfijos', '', '', dbs.DirSistema + '\actualizaciones_online\download\estructu');
  texport.Open;

  while not texport.Eof do Begin
    if Length(Trim(texport.FieldByName('codos').AsString)) = 6 then Begin
    if utiles.verificarItemsLista(xlista, texport.FieldByName('codos').AsString) then Begin
      if BuscarAnalisisMontoFijo(texport.FieldByName('codos').AsString, texport.FieldByName('items').AsString) then apfijos.Edit else apfijos.Append;
        apfijos.FieldByName('codos').AsString       := texport.FieldByName('codos').AsString;
        apfijos.FieldByName('items').AsString       := texport.FieldByName('items').AsString;
        apfijos.FieldByName('codanalisis').AsString := texport.FieldByName('codanalisis').AsString;
        apfijos.FieldByName('importe').AsString     := texport.FieldByName('importe').AsString;
        apfijos.FieldByName('periodo').AsString     := texport.FieldByName('periodo').AsString;
        apfijos.FieldByName('perhasta').AsString    := texport.FieldByName('perhasta').AsString;
        try
          apfijos.Post
         except
          apfijos.Cancel
        end;
      end;
    end;
    texport.Next;
  end;

  datosdb.closedb(texport);

  //domxml.Analizar(dbs.DirSistema + '\actualizaciones_online\download\apfijos.xml');
  //lista1 := domxml.setDOMXMLDatos;
  {if lista1 <> Nil then Begin
    k := 0;
    For i := 1 to lista1.Count do Begin
      Inc(k);
      if k = 1 then valores[1] := lista1.Strings[i-1];  // codos
      if k = 2 then valores[2] := lista1.Strings[i-1];  // items
      if k = 4 then valores[3] := lista1.Strings[i-1];  // codanalisis
      if k = 5 then valores[4] := lista1.Strings[i-1];  // monto
      if k = 6 then valores[5] := lista1.Strings[i-1];  // periodo
      if k = 6 then Begin                               // Lote completo, actualizamos
        if BuscarAnalisisMontoFijo(valores[1], valores[2]) then apfijos.Edit else apfijos.Append;
        apfijos.FieldByName('codos').AsString       := valores[1];
        apfijos.FieldByName('items').AsString       := valores[2];
        apfijos.FieldByName('codanalisis').AsString := valores[3];
        apfijos.FieldByName('importe').AsString     := utiles.FormatearNumero(valores[4]);
        if valores[5] <> 'null' then apfijos.FieldByName('periodo').AsString := valores[5] else apfijos.FieldByName('periodo').AsString := '';
        try
          apfijos.Post
         except
          apfijos.Cancel
        end;
        k := 0;
      end;
    end;
  end;
  datosdb.refrescar(apfijos);
  lista1.Destroy;}
end;

procedure TTObraSocial.ImportarArancelesXML;
// Objetivo...: Actualizar Datos a partir de una Fuente XML
Begin
  texport := datosdb.openDB('obsociales_aranceles', '', '', dbs.DirSistema + '\actualizaciones_online\download\estructu');
  texport.Open;

  while not texport.Eof do Begin
    if utiles.verificarItemsLista(xlista, texport.FieldByName('codos').AsString) then Begin
      if BuscarArancel(texport.FieldByName('codos').AsString, texport.FieldByName('periodo').AsString) then aranceles.Edit else aranceles.Append;
      aranceles.FieldByName('codos').AsString   := texport.FieldByName('codos').AsString;
      aranceles.FieldByName('periodo').AsString := texport.FieldByName('periodo').AsString;
      aranceles.FieldByName('ub').AsString      := texport.FieldByName('ub').AsString;
      aranceles.FieldByName('ug').AsString      := texport.FieldByName('ug').AsString;
      aranceles.FieldByName('rieub').AsString   := texport.FieldByName('rieub').AsString;
      aranceles.FieldByName('rieug').AsString   := texport.FieldByName('rieug').AsString;
      aranceles.FieldByName('tope').AsString    := texport.FieldByName('tope').AsString;
      try
        aranceles.Post
       except
        aranceles.Cancel
      end;
    end;
    texport.Next;
  end;

  datosdb.closedb(texport);
end;

procedure TTObraSocial.DescompactarArchivosActualizaciones;
// Objetivo...: Descompactar Archivos
Begin
  utilesarchivos.DescompactarArchivos(dbs.DirSistema + '\actualizaciones_online\download', dbs.DirSistema + '\actualizaciones_online\download\estructu');
end;

function TTObraSocial.setObrasSocialesImportadas: TQuery;
// Objetivo...: Retornar una Lista de Obras Sociales Importadas
Begin
  Result := datosdb.tranSQL(dbs.DirSistema + '\actualizaciones_online\download\estructu', 'select codos, nombre from obsocial order by nombre'); 
end;

procedure TTObraSocial.Enccol;
// Objetivo...: mostrar nombres de columnas
begin
  tabla.FieldByName('codos').DisplayLabel := 'Cód.'; tabla.FieldByName('nombre').DisplayLabel := 'Nombre de Pila'; tabla.FieldByName('nombrec').DisplayLabel := 'Nombre Completo'; tabla.FieldByName('codpos').DisplayLabel := 'Cód.Pos.';
  if datosdb.verificarSiExisteCampo(tabla, 'codpfis') then tabla.FieldByName('codpfis').DisplayLabel := 'C.Fisc.';
  if datosdb.verificarSiExisteCampo(tabla, 'nrocuit') then tabla.FieldByName('nrocuit').DisplayLabel := 'Nº C.U.I.T.';
  if datosdb.verificarSiExisteCampo(tabla, 'categoria') then  tabla.FieldByName('categoria').DisplayLabel := 'Cat.';
  if datosdb.verificarSiExisteCampo(tabla, 'topemin') then tabla.FieldByName('Topemin').DisplayLabel := 'Tope Min.';
  if datosdb.verificarSiExisteCampo(tabla, 'topemax') then tabla.FieldByName('topemax').DisplayLabel := 'Tope Max.';
end;

function TTObraSocial.setMontoFijoNBU(xcodos, xcodanalisis, xperiodo: String): Real;
// Objetivo...: funcion no implementada
begin
  result := 0;
end;

function TTObraSocial.setUnidadNBU(xcodos, xcodanalisis, xperiodo: String): Real;
// Objetivo...: funcion no implementada
begin
  result := 0;
end;

procedure TTObraSocial.conectar;
// Objetivo...: conectar tablas de persistencia
begin
  nomeclatura.conectar;
  if conexiones = 0 then Begin
    if not tabla.Active then tabla.Open;
    Enccol;
    if not apfijos.Active then apfijos.Open;
    if not aranceles.Active then aranceles.Open;
  end;
  Inc(conexiones);
  CargarListaApFijos;
end;

procedure TTObraSocial.desconectar;
// Objetivo...: desconectar tablas de persistencia
begin
  if conexiones > 0 then Dec(conexiones);
  if conexiones = 0 then Begin
    datosdb.closeDB(tabla);
    datosdb.closeDB(apfijos);
    datosdb.closeDB(aranceles);
  end;
  nomeclatura.desconectar;
end;

{===============================================================================}

function obsocial: TTObraSocial;
begin
  if xobsocial = nil then
    xobsocial := TTObraSocial.Create;
  Result := xobsocial;
end;

{===============================================================================}

initialization

finalization
  xobsocial.Free;

end.
