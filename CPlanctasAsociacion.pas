unit CPlanctasAsociacion;

interface

uses CContabilidadAsociacion, SysUtils, DB, DBTables, CBDT, CIDBFM, CListar, CUtiles,
     Contnrs;

const
  CHR18 = CHR(18);
  CHR15 = CHR(15);
  Caracter = '-';

type

TTPlanctas = class    { Atributos del Plan de cuentas }
  codcta, codrap, cuenta, sumariza, imputable, path: string;
  nivel: shortint;
  totaldebe, totalhaber, a_totaldebe, a_totalhaber: real;
  { Atributos Digitos manejadores de cuentas }
  activo, pasivo, patneto, ganancias, perdidas, ctaresulta, codarea, codref: string;
  { Atributos como Parámetros del Plan }
  nivelpr: shortint;
  descrip, nivelact, imput: string;
  sepa: string; nv, nb: shortint;

  planctas, tabla, tabpar, tpar: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  function    getCuenta(xcodcta: string): string;
  function    Buscar(xcodcta: string): boolean;
  function    BuscarCodigoRapido(xcodrap: string): boolean;
  procedure   Borrar(xcodcta: string);
  procedure   ctImputable(xcodcta: string);
  function    BuscarSumariza(xcodcta: string): boolean;
  procedure   Grabar(xcodcta, xcodrap, xcuenta, xsumariza, ximputable: string; xnivel: shortint); overload;
  procedure   IniciarSubtotales(opt: byte); overload;
  procedure   IniciarSubtotales; overload;
  procedure   Subtotales(xcodcta: string; xtotdebe, xtothaber: real);
  procedure   getDatos(xcodcta: string); overload;
  procedure   FiltrarNivel(n: string);
  procedure   FiltrarCuentasEgresos;
  procedure   FiltrarCuentasEgresos_Activo;
  procedure   Filtrar(filtro: string);
  procedure   FiltrarCtIngEgr;
  procedure   FiltrarCtPatrim;
  procedure   DesactivarFiltro;
  procedure   OrdenarPorCuenta;
  procedure   OrdenarAlfabeticamente;
  procedure   OrdenarPorSumatoria;
  function    setCuentas: TQuery;
  function    ctasPatrimoniales(digpat: string): TQuery;
  procedure   FiltrarCtasImputables;
  procedure   Listar(orden, iniciar, finalizar, ent_excl: string; salida, tl: char);
  procedure   ListarCodigosRapidos(salida: char);
  // Métodos manejadores de atributos de cuentas
  procedure   Grabar(xactivo, xpasivo, xpatneto, xganancias, xperdidas, xctaresulta, xcodarea, xcodref: string); overload;
  procedure   getDatos; overload;
  // Métodos de atributos manejadores de parámetros
  procedure   GrabarParam(xnivel: shortint; xdescrip, xactivo, ximputable: string);
  procedure   BorrarParam(xnivel: shortint);
  function    BuscarParam(xnivel: shortint): boolean;
  procedure   getDatosParam(xnivel: shortint);
  function    setParam: TQuery;
  procedure   BuscarPorCodigo(xexpresion: String);

  procedure   getDatosSep;
  procedure   GrabarSep(xsepa: string; xnv, xnb: shortint);

  function    setCuentasEgresos: TQuery;
  function    setCuentasEgresos_Activo: TQuery;

  function    setCuentasIngresosEgresos: TObjectList;
  function    setCuentasActivoPasivo: TObjectList;
  function    setCuentasActivoPasivoPatrimonio: TObjectList;

  procedure   TitCol;
  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  conexiones: shortint;
  lineas, pag: Integer;
  lin: String;
  procedure   titulo1(tl: char);
  procedure   titulo2;
  function    ControlarSalto: Boolean;
  procedure   RealizarSalto;
 public
  { Declaraciones Publicas }
  LineasPag, Lineas_blanco: Integer;
end;

function planctas: TTPlanctas;

implementation

var
  xplanctas: TTPlanctas = nil;

constructor TTPlanctas.Create;
begin
  inherited Create;
  planctas := datosdb.openDB('planctas', 'codcta', '', contabilidad.dbcc);
  tabla    := datosdb.openDB('pardigct', '', '', contabilidad.dbcc);
  tabpar   := datosdb.openDB('parplcta', '', '', contabilidad.dbcc);
  tpar     := datosdb.openDB('paradpl', '', '', contabilidad.dbcc);
  path     := contabilidad.dbcc;
end;

destructor TTPlanctas.Destroy;
begin
  inherited Destroy;
end;

function TTPlanctas.getCuenta(xcodcta: string): string;
// Objetivo...: retornar la descrip de una cuenta
begin
  if Buscar(xcodcta) then Result := planctas.FieldByName('codcta').AsString else Result := '';
end;

function TTplanctas.Buscar(xcodcta: string): boolean;
// Objetivo...: Buscar un código de cuenta
begin
  if not planctas.Active then conectar;
  if planctas.FindKey([xcodcta]) then Result := True else Result := False;
end;

function TTplanctas.BuscarCodigoRapido(xcodrap: string): boolean;
// Objetivo...: Buscar un código de cuenta
var
  _i: string;
begin
  _i := planctas.IndexFieldNames;
  if not planctas.Active then conectar;
  planctas.IndexFieldNames := 'codrap';
  if planctas.FindKey([xcodrap]) then
    begin
      codcta := planctas.FieldByName('codcta').AsString;
      Result := True;
    end
  else
    Result := False;
  planctas.IndexFieldNames := _i;
end;

procedure TTPlanctas.Borrar(xcodcta: string);
// Objetivo...: Borrar una cuenta del plan
begin
  if Buscar(xcodcta) then
    begin
      planctas.Delete;
      getDatos(planctas.FieldByName('codcta').AsString);
      datosdb.closedb(planctas); planctas.Open;
    end;
end;

procedure TTPlanctas.Grabar(xcodcta, xcodrap, xcuenta, xsumariza, ximputable: string; xnivel: shortint);
// Objetivo...: Grabar Atributos del Objeto
begin
  if Buscar(xcodcta) then planctas.Edit else planctas.Append;
  planctas.FieldByName('codcta').AsString    := xcodcta;
  planctas.FieldByName('codrap').AsString    := xcodrap;
  planctas.FieldByName('cuenta').AsString    := xcuenta;
  planctas.FieldByName('sumariza').AsString  := xsumariza;
  planctas.FieldByName('imputable').AsString := ximputable;
  planctas.FieldByName('nivel').AsInteger    := xnivel;
  try
    planctas.Post;
  except
    planctas.Cancel;
  end;
  datosdb.refrescar(planctas);

  if Buscar(xsumariza) then Begin
    planctas.Edit;
    planctas.FieldByName('imputable').AsString  := 'N';
    try
      planctas.Post
     except
      planctas.Cancel
    end;
    datosdb.refrescar(planctas);
    Buscar(xcodcta);
  end;

  datosdb.closedb(planctas); planctas.Open;
end;

procedure  TTPlanctas.getDatos(xcodcta: string);
// Objetivo...: Retornar/Iniciar Atributos
begin
  if Buscar(xcodcta) then
    begin
      codcta     := planctas.FieldByName('codcta').AsString;
      codrap     := planctas.FieldByName('codrap').AsString;
      cuenta     := planctas.FieldByName('cuenta').AsString;
      sumariza   := planctas.FieldByName('sumariza').AsString;
      imputable  := planctas.FieldByName('imputable').AsString;
      nivel      := planctas.FieldByName('nivel').AsInteger;
    end
  else
    begin
      codcta := ''; codrap := ''; cuenta := ''; sumariza := ''; imputable := ''; nivel := 0;
    end;
end;

procedure TTPlanctas.FiltrarNivel(n: string);
// Objetivo...: Filtrar tabla por Nivel
begin
  if Length(Trim(n)) = 0 then planctas.Filtered := False else datosdb.Filtrar(planctas, 'nivel = ' + '''' + n + '''');
end;

procedure TTPlanctas.FiltrarCuentasEgresos;
// Objetivo...: Filtrar tabla por Nivel
var
  dg: array[1..2] of String;
begin
  dg[1] := Perdidas + '.0.0.00.000'; dg[2] := Perdidas + '.9.9.99.999';
  datosdb.Filtrar(planctas, 'codcta >= ' + '''' + dg[1] + ''''  + ' and codcta <= ' + '''' + dg[2] + '''' + ' and imputable = ' + '''' + 'S' + '''');
end;

procedure TTPlanctas.FiltrarCuentasEgresos_Activo;
// Objetivo...: Filtrar tabla por Nivel
var
  dg: array[1..2] of String;
begin
  dg[1] := Perdidas + '.0.0.00.000'; dg[2] := Perdidas + '.9.9.99.999';
  datosdb.Filtrar(planctas, 'imputable = ' + '''' + 'S' + '''' +  ' and codcta >= ' + '''' + '1.0.0.00.000' + '''' + ' and codcta <= ' + '''' + '1.9.9.99.999' + '''' +
                            ' or codcta >= ' + '''' + dg[1] + ''''  + ' and codcta <= ' + '''' + dg[2] + '''' + ' and imputable = ' + '''' + 'S' + '''');
end;

procedure TTPlanctas.Filtrar(filtro: string);
// Objetivo...: Filtrar tabla por expresión
begin
  datosdb.Filtrar(planctas, filtro);
end;

procedure TTPlanctas.FiltrarCtIngEgr;
// Objetivos...: Filtrar cuentas Ingresos/Egresos
var
  di, de: string;
begin
  getDatos;
  if Ganancias > Perdidas then
    begin
      di := Perdidas  + '.0.0.00.000';
      de := Ganancias + '.9.9.99.999';
    end
  else
    begin
      di := Perdidas  + '.0.0.00.000';
      de := Ganancias + '.9.9.99.999';
    end;
  datosdb.Filtrar(planctas, 'codcta >= ' + '''' + di + ''''  + ' AND codcta <= ' + '''' + de + '''' + ' AND imputable = ' + '''' + 'S' + '''');
end;

function  TTPlanctas.setCuentasIngresosEgresos: TObjectList;
// Objetivo...: Devolver Movimientos del día
var
  l: TObjectList;
  objeto: TTPlanctas;
Begin
  l := TObjectList.Create;
  //FiltrarCtIngEgr;
  getDatos;
  planctas.First;
  while not planctas.Eof do Begin
    if (Copy(planctas.FieldByName('codcta').AsString, 1, 1) = Perdidas) or (Copy(planctas.FieldByName('codcta').AsString, 1, 1) = Ganancias) then Begin
      objeto := TTPlanctas.Create;
      objeto.codcta     := planctas.FieldByName('codcta').AsString;
      objeto.cuenta     := planctas.FieldByName('cuenta').AsString;
      objeto.imputable  := planctas.FieldByName('imputable').AsString;
      objeto.totaldebe  := planctas.FieldByName('totaldebe').AsFloat;
      objeto.totalhaber := planctas.FieldByName('totalhaber').AsFloat;
      l.Add(objeto);
    end;
    planctas.Next;
  end;
  DesactivarFiltro;
  Result := l;
end;

function  TTPlanctas.setCuentasActivoPasivo: TObjectList;
// Objetivo...: Devolver Movimientos del día
var
  l: TObjectList;
  objeto: TTPlanctas;
Begin
  l := TObjectList.Create;
  FiltrarCtPatrim;
  while not planctas.Eof do Begin
    if (Copy(planctas.FieldByName('codcta').AsString, 1, 1) = Activo) or (Copy(planctas.FieldByName('codcta').AsString, 1, 1) = Pasivo) then Begin
      objeto := TTPlanctas.Create;
      objeto.codcta     := planctas.FieldByName('codcta').AsString;
      objeto.cuenta     := planctas.FieldByName('cuenta').AsString;
      objeto.imputable  := planctas.FieldByName('imputable').AsString;
      objeto.totaldebe  := planctas.FieldByName('totaldebe').AsFloat;
      objeto.totalhaber := planctas.FieldByName('totalhaber').AsFloat;
      l.Add(objeto);
    end;
    planctas.Next;
  end;
  DesactivarFiltro;
  Result := l;
end;

function  TTPlanctas.setCuentasActivoPasivoPatrimonio: TObjectList;
// Objetivo...: Devolver Movimientos del día
var
  l: TObjectList;
  objeto: TTPlanctas;
Begin
  l := TObjectList.Create;
  getDatos;
  while not planctas.Eof do Begin
    if ((Copy(planctas.FieldByName('codcta').AsString, 1, 1) = Activo) or (Copy(planctas.FieldByName('codcta').AsString, 1, 1) = Pasivo) or (Copy(planctas.FieldByName('codcta').AsString, 1, 1) = Patneto))
      and (planctas.FieldByName('codcta').AsString <> patneto) and (planctas.FieldByName('codcta').AsString <> ctaresulta) and (planctas.FieldByName('codcta').AsString <> codarea) and (planctas.FieldByName('codcta').AsString <> codref) then Begin
      objeto := TTPlanctas.Create;
      objeto.codcta     := planctas.FieldByName('codcta').AsString;
      objeto.cuenta     := planctas.FieldByName('cuenta').AsString;
      objeto.imputable  := planctas.FieldByName('imputable').AsString;
      objeto.totaldebe  := planctas.FieldByName('totaldebe').AsFloat;
      objeto.totalhaber := planctas.FieldByName('totalhaber').AsFloat;
      l.Add(objeto);
    end;
    planctas.Next;
  end;
  DesactivarFiltro;
  Result := l;
end;

procedure TTPlanctas.FiltrarCtPatrim;
// Objetivos...: Filtrar cuentas Patrimoniales
var
  di: string;
begin
  getDatos;
  if Ganancias > Perdidas then di := Perdidas  + '.0.0.00.000' else di := Perdidas  + '.0.0.00.000';
  datosdb.Filtrar(planctas, 'codcta < ' + '''' + di + '''' + ' AND imputable = ' + '''' + 'S' + '''');
end;

function TTPlanctas.BuscarSumariza(xcodcta: string): boolean;
// Objetivo...: buscar cód. sumariza
begin
 if not planctas.Active then conectar;
 planctas.IndexFieldNames := 'Sumariza';
 if planctas.FindKey([xcodcta]) then Result := True else Result := False;
 planctas.IndexFieldNames := 'codcta';
end;

procedure TTPlanctas.ctImputable(xcodcta: string);
// Objetivo...: Marcar una cuenta como imputable
begin
  if Buscar(xcodcta) then begin
    planctas.Edit;
    planctas.FieldByName('imputable').AsString := 'S';
    planctas.Post;
  end;
  datosdb.refrescar(planctas);
end;

function TTPlanctas.ctasPatrimoniales(digpat: string): TQuery;
// Objetivo...: Devolver un set con las cuentas Patrimoniales
begin
  Result := datosdb.tranSQL(planctas.DatabaseName, 'select * from planctas where codcta >= ' + '''' + digpat + '.0.0.00.000' + '''' + ' and codcta <= ' + '''' + digpat + '.9.9.99.999' + '''' + ' and imputable = ' + '''' + 'S' + '''');
end;

procedure TTPlanctas.FiltrarCtasImputables;
// Objetivo...: Devolver un set con las cuentas Imputables
begin
  datosdb.Filtrar(planctas, 'imputable >= ' + '''' + 'S' + '''');
end;

procedure TTPlanctas.DesactivarFiltro;
// Objetivo...: desactivar Filtro
begin
  datosdb.QuitarFiltro(planctas);
end;

function TTPlanctas.setCuentasEgresos: TQuery;
// Objetivo...: Filtrar Cuentas de Egresos
var
  dg: array[1..2] of String;
begin
  dg[1] := Perdidas + '.0.0.00.000'; dg[2] := Perdidas + '.9.9.99.999';
  Result := datosdb.tranSQL(planctas.DatabaseName, 'select codcta, cuenta from ' + planctas.TableName + ' where codcta >= ' + '''' + dg[1] + ''''  + ' and codcta <= ' + '''' + dg[2] + '''' + ' and imputable = ' + '''' + 'S' + '''' + ' order by cuenta');
end;

function TTPlanctas.setCuentasEgresos_Activo: TQuery;
// Objetivo...: Filtrar Cuentas de Egresos
var
  dg: array[1..2] of String;
begin
  dg[1] := Perdidas + '.0.0.00.000'; dg[2] := Perdidas + '.9.9.99.999';
  Result := datosdb.tranSQL(planctas.DatabaseName, 'select codcta, cuenta from ' + planctas.TableName + ' where codcta >= ' + '''' + dg[1] + ''''  + ' and codcta <= ' + '''' + dg[2] + '''' + ' and imputable = ' + '''' + 'S' + '''' +
                                  ' or codcta >= ' + '''' + '1.0.00.000' + '''' + ' and codcta <= ' + '''' + '1.9.9.99.999' + '''' + ' and imputable = ' + '''' + 'S' + '''' + ' order by codcta');
end;

procedure TTPlanctas.Subtotales(xcodcta: string; xtotdebe, xtothaber: real);
// Objetivo...: Grabar los resultados parciales de cada cuenta
begin
  if Buscar(xcodcta) then begin
    planctas.Edit;
    planctas.FieldByName('totaldebe').AsFloat  := xtotdebe;
    planctas.FieldByName('totalhaber').AsFloat := xtothaber;
    try
      planctas.Post;
    except
      planctas.Cancel;
    end;
  end;
  datosdb.closedb(planctas); planctas.Open;
end;

procedure TTPlanctas.IniciarSubtotales(opt: byte);
// Objetivo...: Iniciar Subtotales en las cuentas del plan - ponerlas en estado inicial
begin
  planctas.Filtered := False; planctas.First;
  while not planctas.EOF do
    begin
      planctas.Edit;
      if opt < 2 then
        begin
          planctas.FieldByName('totaldebe').AsFloat  := 0;
          planctas.FieldByName('totalhaber').AsFloat := 0;
        end;
      if opt = 1 then
        begin
          planctas.FieldByName('a_totaldebe').AsFloat  := 0;
          planctas.FieldByName('a_totalhaber').AsFloat := 0;
        end;
      try
        planctas.Post;
      except
        planctas.Cancel;
      end;
      planctas.Next;
    end;
end;

procedure TTPlanctas.IniciarSubtotales;
// Objetivo...: Iniciar TODOS Subtotales en las cuentas del plan - ponerlas en estado inicial
begin
  planctas.Filtered := False; planctas.First;
  while not planctas.EOF do
    begin
      planctas.Edit;
      planctas.FieldByName('totaldebe').AsFloat  := 0;
      planctas.FieldByName('totalhaber').AsFloat := 0;
      planctas.FieldByName('a_totaldebe').AsFloat  := 0;
      planctas.FieldByName('a_totalhaber').AsFloat := 0;
      try
        planctas.Post;
      except
        planctas.Cancel;
      end;
      planctas.Next;
    end;
  datosdb.closedb(planctas); planctas.Open;
end;

procedure TTPlanctas.OrdenarAlfabeticamente;
// Objetivo...: Activar Inicie Alfabético
begin
  planctas.IndexFieldNames := 'cuenta';
end;

procedure TTPlanctas.OrdenarPorCuenta;
// Objetivo...: Activar Inicie Normal
begin
  planctas.IndexFieldNames := 'codcta';
end;

procedure TTPlanctas.OrdenarPorSumatoria;
// Objetivo...: Activar Inicie de Sumatoria
begin
  planctas.IndexName := 'sumariza';
end;

function TTPlanctas.setCuentas: TQuery;
// Objetivo...: Devolver un set de Cuentas
begin
  Result := datosdb.tranSQL(planctas.DatabaseName, 'SELECT * FROM planctas ORDER BY codcta');
end;

procedure TTPlanctas.titulo1(tl: char);
// Objetivo...: Gestionar Resportes
Begin
  Inc(pag);
  list.LineaTxt(CHR18 + '  ', true);
  List.LineaTxt(CHR15, True);
  List.LineaTxt(' Plan de Cuentas' + utiles.espacios(30) + 'Hoja Nro.: ' + IntToStr(pag), true);
  List.LineaTxt('Código    Cuenta', False);
  if tl = 'S' then List.LineaTxt(utiles.espacios(54) + 'Sumariza     Cód.Ráp. Im. N', False);
  List.LineaTxt(CHR18, True);
  list.LineaTxt(utiles.sLlenarIzquierda(lin, 80, Caracter) + CHR15, True);
  lineas := 5;
end;

procedure TTPlanctas.Listar(orden, iniciar, finalizar, ent_excl: string; salida, tl: char);
// Objetivo...: Gestionar Resportes
var
  cuenta: string;
begin
  if (salida = 'I') or (salida = 'P') then Begin
    list.Setear(salida);
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
    List.Titulo(0, 0, ' Plan de Cuentas', 1, 'Arial, negrita, 14');
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
    List.Titulo(0, 0, 'Código               Cuenta', 1, 'Arial, cursiva, 8');
    if tl = 'S' then Begin
      List.Titulo(65, list.lineactual, 'Sumariza', 2, 'Arial, cursiva, 8');
      List.Titulo(79, list.lineactual, 'Cód.Ráp.', 3, 'Arial, cursiva, 8');
      List.Titulo(87, list.lineactual, 'Imput.', 4, 'Arial, cursiva, 8');
      List.Titulo(93, list.lineactual, 'Nivel', 5, 'Arial, cursiva, 8');
    end;
    List.Titulo(0, 0, list.linealargopagina(salida), 1, 'Arial, normal, 11');
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');
  end else Begin
    pag := 0;
    list.IniciarImpresionModoTexto(LineasPag);
    titulo1(tl);
  end;

  planctas.First;
  while not planctas.EOF do Begin
    cuenta := utiles.espacios(planctas.FieldByName('nivel').AsInteger * 3) + planctas.FieldByName('cuenta').AsString;
    if (salida = 'P') or (salida = 'I') then
      List.Linea(0, 0, planctas.FieldByName('codcta').AsString + '  ' + cuenta, 1, 'Arial, normal, 8', salida, 'N')
    else
      List.LineaTxt(planctas.FieldByName('codcta').AsString + '  ' + utiles.StringLongitudFija(cuenta, 55), False);
    if tl = 'S' then Begin
      if (salida = 'P') or (salida = 'I') then Begin
        List.Linea(65, list.lineactual, planctas.FieldByName('sumariza').AsString, 2, 'Arial, normal, 8', salida, 'N');
        List.Linea(80, list.lineactual, planctas.FieldByName('codrap').AsString, 3, 'Arial, normal, 8', salida, 'N');
        List.Linea(89, list.lineactual, planctas.FieldByName('imputable').AsString, 4, 'Arial, normal, 8', salida, 'N');
        List.Linea(94, list.lineactual, planctas.FieldByName('nivel').AsString, 5, 'Arial, normal, 8', salida, 'S');
      end else Begin
        List.LineaTxt(planctas.FieldByName('sumariza').AsString + utiles.StringLongitudFija(planctas.FieldByName('codrap').AsString, 10) + ' ' + planctas.FieldByName('imputable').AsString + ' ' + planctas.FieldByName('nivel').AsString, False);
      end;
    end else
      if (salida = 'P') or (salida = 'I') then List.Linea(65, list.lineactual, ' ', 2, 'Arial, normal, 8', salida, 'S');

    if salida = 'T' then Begin
      List.LineaTxt('', True);
      Inc(lineas); if ControlarSalto then titulo1(tl);
    end;

    planctas.Next;
  end;
  if salida <> 'T' then list.FinList else list.FinalizarImpresionModoTexto(1);
end;

procedure TTPlanctas.titulo2;
// Objetivo...: Listar Cuentas de Código Rápido
Begin
  Inc(pag);
  list.LineaTxt(CHR18 + '  ', true);
  List.LineaTxt('', True);
  List.LineaTxt(' Cuentas de Códigos Abreviados' + utiles.espacios(30) + 'Hoja Nro.: ' + IntToStr(pag), true);
  List.LineaTxt('Código    Cuenta                                              Abrev.', False);
  List.LineaTxt('', True);
  list.LineaTxt(utiles.sLlenarIzquierda(lin, 80, Caracter), True);
  lineas := 5;
end;

procedure TTPlanctas.ListarCodigosRapidos(salida: char);
// Objetivo...: Listar Cuentas de Código Rápido
var
  l: Boolean;
Begin
  if (salida = 'I') or (salida = 'P') then Begin
    list.Setear(salida);
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
    List.Titulo(0, 0, ' Cuentas de Códigos Abreviados', 1, 'Arial, negrita, 14');
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
    List.Titulo(0, 0, 'Código               Cuenta', 1, 'Arial, cursiva, 8');
    List.Titulo(70, list.Lineactual, 'Abrev.', 2, 'Arial, cursiva, 8');
    list.Titulo(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11');
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  end else Begin
    pag := 0;
    list.IniciarImpresionModoTexto(LineasPag);
    titulo2;
  end;

  planctas.First; l := False;
  while not planctas.EOF do Begin
    cuenta := '     ' + planctas.FieldByName('cuenta').AsString;
    if Length(Trim(planctas.FieldByName('codrap').AsString)) > 0 then Begin
      if (salida = 'P') or (salida = 'I') then Begin
        List.Linea(0, 0, planctas.FieldByName('codcta').AsString + '  ' + cuenta, 1, 'Arial, normal, 8', salida, 'N');
        List.Linea(70, list.lineactual, planctas.FieldByName('codrap').AsString, 2, 'Arial, normal, 8', salida, 'S');
      end;
      if (salida = 'T') then Begin
        List.LineaTxt(planctas.FieldByName('codcta').AsString + '  ' + utiles.StringLongitudFija(cuenta, 45), False);
        List.LineaTxt(planctas.FieldByName('codrap').AsString, True);
        Inc(lineas); if ControlarSalto then titulo2;
      end;
      l := True;
    end;
    planctas.Next;
  end;

  if (salida = 'P') or (salida = 'I') then
    if not l then List.Linea(0, 0, 'Sin Movimientos ...!', 1, 'Arial, normal, 11', salida, 'S');
  if (salida = 'T') then
    if not l then List.LineaTxt('', True);

  if salida <> 'T' then list.FinList else list.FinalizarImpresionModoTexto(1);
end;

procedure TTPlanctas.Grabar(xactivo, xpasivo, xpatneto, xganancias, xperdidas, xctaresulta, xcodarea, xcodref: string);
// Objetivo...: Grabar Atributos del Objeto
begin
  if tabla.RecordCount > 0 then tabla.Edit else tabla.Append;
  tabla.FieldByName('activo').AsString     := xactivo;
  tabla.FieldByName('pasivo').AsString     := xpasivo;
  tabla.FieldByName('patneto').AsString    := xpatneto;
  tabla.FieldByName('ganancias').AsString  := xganancias;
  tabla.FieldByName('perdidas').AsString   := xperdidas;
  tabla.FieldByName('ctaresulta').AsString := xctaresulta;
  tabla.FieldByName('codarea').AsString    := xcodarea;
  tabla.FieldByName('codref').AsString     := xcodref;
  try
    tabla.Post
  except
    tabla.Cancel
  end;
end;

procedure  TTPlanctas.getDatos;
// Objetivo...: Retornar/Iniciar Atributos
begin
  activo     := tabla.FieldByName('activo').AsString;
  pasivo     := tabla.FieldByName('pasivo').AsString;
  patneto    := tabla.FieldByName('patneto').AsString;
  ganancias  := tabla.FieldByName('ganancias').AsString;
  perdidas   := tabla.FieldByName('perdidas').AsString;
  ctaresulta := tabla.FieldByName('ctaresulta').AsString;
  codarea    := tabla.FieldByName('codarea').AsString;
  codref     := tabla.FieldByName('codref').AsString;
end;

procedure TTPlanctas.GrabarParam(xnivel: shortint; xdescrip, xactivo, ximputable: string);
// Objetivo...: Grabar Atributos del Objeto
begin
  if BuscarParam(xnivel) then tabpar.Edit else tabpar.Append;
  tabpar.FieldByName('nivel').AsInteger := xnivel;
  tabpar.FieldByName('descrip').Value   := xdescrip;
  tabpar.FieldByName('activo').Value    := xactivo;
  tabpar.FieldByName('imputable').Value := ximputable;
  try
    tabpar.Post;
  except
    tabpar.Cancel;
  end;
end;

procedure TTPlanctas.BorrarParam(xnivel: shortint);
// Objetivo...: Eliminar un Objeto
begin
  if BuscarParam(xnivel) then
    begin
      tabpar.Delete;
      getDatosparam(tabpar.FieldByName('nivel').AsInteger);  // Fijamos los Atributos Siguientes al Objeto Borrado
    end
end;

function TTPlanctas.BuscarParam(xnivel: shortint): boolean;
// Objetivo...: Buscar el Objeto solicitado
begin
  if not tabpar.Active then conectar;
  if tabpar.FindKey([xnivel]) then Result := True else Result := False;
end;

procedure  TTPlanctas.getDatosParam(xnivel: shortint);
// Objetivo...: Retornar/Iniciar Atributos
begin
  if BuscarParam(xnivel) then
    begin
      nivelpr  := tabpar.FieldByName('nivel').AsInteger;
      descrip  := tabpar.FieldByName('descrip').AsString;
      nivelact := tabpar.FieldByName('activo').AsString;
      imput    := tabpar.FieldByName('imputable').AsString;
    end
   else
    begin
      nivelpr := 0; descrip := ''; nivelact := ''; imput := '';
    end;
end;

function  TTPlanctas.setParam: TQuery;
// Objetivo...: Retornar un set con los parámetros correspondientes
begin
  Result := datosdb.tranSQL(planctas.DatabaseName, 'SELECT * FROM ' + tabpar.TableName);
end;

procedure TTPlanctas.GrabarSep(xsepa: string; xnv, xnb: shortint);
// Objetivo...: Grabar Atributos del Objeto
begin
  if tpar.RecordCount > 0 then tpar.Edit else tpar.Append;
  tpar.FieldByName('sepa').AsString := xsepa;
  tpar.FieldByName('nv').AsInteger  := xnv;
  tpar.FieldByName('nb').AsInteger  := xnb;
  try
    tpar.Post;
  except
    tpar.Cancel;
  end;
end;

procedure  TTPlanctas.getDatosSep;
// Objetivo...: Retornar/Iniciar Atributos
begin
  sepa := tpar.FieldByName('sepa').AsString;
  nv   := tpar.FieldByName('nv').AsInteger;
  nb   := tpar.FieldByName('nb').AsInteger;
end;

procedure TTPlanctas.BuscarPorCodigo(xexpresion: String);
// Objetivo...: Busqueda rápida por código
Begin
  planctas.FindNearest([xexpresion]);
end;

procedure TTPlanctas.TitCol;
// Objetivo...: Titulo Columnas
begin
  planctas.FieldByName('codcta').DisplayLabel := 'Código'; planctas.FieldByName('cuenta').DisplayLabel := 'Cuenta'; planctas.FieldByName('codrap').DisplayLabel := 'C.Abr.';
  planctas.FieldByName('sumariza').DisplayLabel := 'Subtotaliza en'; planctas.FieldByName('imputable').DisplayLabel := 'R.As.';
  planctas.FieldByName('nivel').Visible := False; planctas.FieldByName('a_totaldebe').Visible := False; planctas.FieldByName('a_totalhaber').Visible := False; planctas.FieldByName('totaldebe').Visible := False;
  planctas.FieldByName('totalhaber').Visible := False; planctas.FieldByName('id').Visible := False; planctas.FieldByName('seleccion').Visible := False;
end;

function TTPlanctas.ControlarSalto: boolean;
// Objetivo...: salto de linea para las impresiones basadas en texto
var
  k: Integer;
begin
  Result := False;
  if lineas >= LineasPag then Begin
    //list.lineatxt(inttostr(lineas), True);
    if lineas_blanco = 0 then list.LineaTxt(CHR(12), True) else
      for k := 1 to lineas_blanco do list.LineaTxt('', True);
    Result := True;
  end;
end;

procedure TTPlanctas.RealizarSalto;
// Objetivo...: imprimir lineas en blanco hasta realizar salto de página
var
  k: Integer;
begin
  if lineas_blanco = 0 then list.LineaTxt(CHR(12), True) else Begin
    for k := lineas + 1 to LineasPag do list.LineaTxt('', True);
    lineas := LineasPag + 5;
    ControlarSalto;
  end;
end;

procedure TTPlanctas.conectar;
// Objetivo...: Abrir planctass de persistencia
begin
  if conexiones = 0 then Begin
    if not planctas.Active then planctas.Open;
    if not tabla.Active then tabla.Open;
    if not datosdb.verificarSiExisteCampo(tabla, 'codarea') then Begin
      tabpar.Close;
      datosdb.tranSQL(tabla.DatabaseName, 'alter table ' + tabla.TableName + ' add codarea varchar(12)');
      tabpar.Open;
    end;
    if not datosdb.verificarSiExisteCampo(tabla, 'codref') then Begin
      tabpar.Close;
      datosdb.tranSQL(tabla.DatabaseName, 'alter table ' + tabla.TableName + ' add codref varchar(12)');
      tabpar.Open;
    end;
    if not tabpar.Active then tabpar.Open;
    if not tpar.Active then tpar.Open;
    planctas.First;
  end;
  Inc(conexiones);
  TitCol;
end;

procedure TTPlanctas.desconectar;
// Objetivo...: cerrar planctass de persistencia
begin
  if conexiones > 0 then Dec(conexiones);
  if conexiones = 0 then Begin
    if not planctas.Active then conectar;
    getDatos(planctas.FieldByName('codcta').AsString);  // Retenemos los atributos de la última cuenta
    datosdb.closeDB(planctas);
    datosdb.closeDB(tabla);
    datosdb.closeDB(tabpar);
    datosdb.closeDB(tpar);
    if not tabla.Active then tabla.Open;
  end;
end;

{===============================================================================}

function planctas: TTPlanctas;
begin
  if xplanctas = nil then
    xplanctas := TTPlanctas.Create;
  Result := xplanctas;
end;

{===============================================================================}

initialization

finalization
  xplanctas.Free;

end.
