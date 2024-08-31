unit CPlanctas;

interface

uses SysUtils, DB, DBTables, CBDT, CIDBFM, CListar, CUtiles;

type

TTPlanctas = class(TObject)    { Atributos del Plan de cuentas }
  codcta, codrap, cuenta, sumariza, imputable, path: string;
  nivel: shortint;
  totaldebe, totalhaber, a_totaldebe, a_totalhaber: real;
  { Atributos Digitos manejadores de cuentas }
  activo, pasivo, patneto, ganancias, perdidas, ctaresulta: string;
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
  function    setCodigoRapido(xcodrap: string): String;
  procedure   Borrar(xcodcta: string);
  procedure   ctImputable(xcodcta: string);
  function    BuscarSumariza(xcodcta: string): boolean;
  procedure   Grabar(xcodcta, xcodrap, xcuenta, xsumariza, ximputable: string; xnivel: shortint); overload;
  procedure   IniciarSubtotales(opt: byte);
  procedure   Subtotales(xcodcta: string; xtotdebe, xtothaber: real);
  procedure   getDatos(xcodcta: string); overload;
  procedure   FiltrarNivel(n: string);
  procedure   Filtrar(filtro: string);
  procedure   FiltrarCtIngEgr;
  procedure   FiltrarCtPatrim;
  procedure   DesactivarFiltro;
  procedure   OrdenarPorCuenta;
  procedure   OrdenarAlfabeticamente;
  procedure   OrdenarPorSumatoria;
  function    setCuentas: TQuery;
  function    ctasPatrimoniales(digpat: string): TTable;
  procedure   FiltrarCtasImputables;
  procedure   Listar(orden, iniciar, finalizar, ent_excl: string; salida, tl: char);
  // Métodos manejadores de atributos de cuentas
  procedure   Grabar(xactivo, xpasivo, xpatneto, xganancias, xperdidas, xctaresulta: string); overload;
  procedure   getDatos; overload;
  // Métodos de atributos manejadores de parámetros
  procedure   GrabarParam(xnivel: shortint; xdescrip, xactivo, ximputable: string);
  procedure   BorrarParam(xnivel: shortint);
  function    BuscarParam(xnivel: shortint): boolean;
  procedure   getDatosParam(xnivel: shortint);
  function    setParam: TQuery;

  procedure   getDatosSep;
  procedure   GrabarSep(xsepa: string; xnv, xnb: shortint);

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  conexiones: shortint;
end;

function planctas: TTPlanctas;

implementation

var
  xplanctas: TTPlanctas = nil;

constructor TTPlanctas.Create;
begin
  inherited Create;
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

function TTplanctas.setCodigoRapido(xcodrap: string): String;
// Objetivo...: Extraer el código de una cuenta por su codigo rápido
Begin
  if BuscarCodigoRapido(xcodrap) then Result := codcta else Result := '';
end;

procedure TTPlanctas.Borrar(xcodcta: string);
// Objetivo...: Borrar una cuenta del plan
begin
  if Buscar(xcodcta) then
    begin
      planctas.Delete;
      getDatos(planctas.FieldByName('codcta').AsString);
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
      de := Perdidas  + '.0.0.00.000';
      di := Ganancias + '.9.9.99.999';
    end;
  datosdb.Filtrar(planctas, 'codcta >= ' + '''' + di + ''''  + ' AND codcta <= ' + '''' + de + '''' + ' AND imputable = ' + '''' + 'S' + '''');
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
 planctas.IndexName := 'Sumariza';
 if planctas.FindKey([xcodcta]) then Result := True else Result := False;
 planctas.IndexFieldNames := 'codcta';
end;

procedure TTPlanctas.ctImputable(xcodcta: string);
// Objetivo...: Marcar una cuenta como imputable
begin
  if Buscar(xcodcta) then
    begin
      planctas.Edit;
      planctas.FieldByName('imputable').AsString := 'S';
      planctas.Post;
    end;
end;

function TTPlanctas.ctasPatrimoniales(digpat: string): TTable;
// Objetivo...: Devolver un set con las cuentas Patrimoniales
begin
  datosdb.Filtrar(planctas, 'codcta >= ' + '''' + digpat + '.0.0.00.000' + '''' + ' and codcta <= ' + '''' + digpat + '.9.9.99.999' + '''' + ' and imputable = ' + '''' + 'S' + '''');
  Result := planctas;
end;

procedure TTPlanctas.FiltrarCtasImputables;
// Objetivo...: Devolver un set con las cuentas Imputables
begin
  datosdb.Filtrar(planctas, 'imputable >= ' + '''' + 'S' + '''');
end;

procedure TTPlanctas.DesactivarFiltro;
// Objetivo...: desactivar Filtro
begin
  planctas.Filtered := False;
  planctas.Filter   := '';
end;

procedure TTPlanctas.Subtotales(xcodcta: string; xtotdebe, xtothaber: real);
// Objetivo...: Grabar los resultados parciales de cada cuenta
begin
  if Buscar(xcodcta) then
    begin
      planctas.Edit;
      planctas.FieldByName('totaldebe').AsFloat  := xtotdebe;
      planctas.FieldByName('totalhaber').AsFloat := xtothaber;
      try
        planctas.Post;
      except
        planctas.Cancel;
      end;
    end;
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
  Result := datosdb.tranSQL(path, 'SELECT * FROM planctas');
end;

procedure TTPlanctas.Listar(orden, iniciar, finalizar, ent_excl: string; salida, tl: char);
// Objetivo...: Gestionar Resportes
var
  cuenta: string;
begin
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Listado Plan de Cuentas', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Código               Cuenta', 1, 'Courier New, cursiva, 8');
  if tl = 'S' then
    begin
      List.Titulo(65, list.lineactual, 'Sumariza', 2, 'Courier New, cursiva, 8');
      List.Titulo(79, list.lineactual, 'Cód.Ráp.', 3, 'Courier New, cursiva, 8');
      List.Titulo(89, list.lineactual, 'Nivel', 4, 'Courier New, cursiva, 8');
    end;
  List.Titulo(0, 0, list.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  planctas.First;
  while not planctas.EOF do
    begin
      cuenta := utiles.espacios(planctas.FieldByName('nivel').AsInteger) + planctas.FieldByName('cuenta').AsString;
      List.Linea(0, 0, planctas.FieldByName('codcta').AsString + '  ' + cuenta, 1, 'Courier New, normal, 8', salida, 'N');
      if tl = 'S' then
        begin
          List.Linea(65, list.lineactual, planctas.FieldByName('sumariza').AsString, 2, 'Courier New, normal, 8', salida, 'N');
          List.Linea(80, list.lineactual, planctas.FieldByName('codrap').AsString, 3, 'Courier New, normal, 8', salida, 'N');
          List.Linea(90, list.lineactual, planctas.FieldByName('nivel').AsString, 4, 'Courier New, normal, 8', salida, 'S');
        end
      else
        List.Linea(65, list.lineactual, ' ', 2, 'Courier New, normal, 8', salida, 'S');
      planctas.Next;
    end;
  List.FinList;
end;

procedure TTPlanctas.Grabar(xactivo, xpasivo, xpatneto, xganancias, xperdidas, xctaresulta: string);
// Objetivo...: Grabar Atributos del Objeto
begin
  if tabla.RecordCount > 0 then tabla.Edit else tabla.Append;
  tabla.FieldByName('activo').AsString     := xactivo;
  tabla.FieldByName('pasivo').AsString     := xpasivo;
  tabla.FieldByName('patneto').AsString    := xpatneto;
  tabla.FieldByName('ganancias').AsString  := xganancias;
  tabla.FieldByName('perdidas').AsString   := xperdidas;
  tabla.FieldByName('ctaresulta').AsString := xctaresulta;
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
  Result := datosdb.tranSQL(path, 'SELECT * FROM ' + tabpar.TableName);
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

procedure TTPlanctas.conectar;
// Objetivo...: Abrir planctass de persistencia
begin
  if conexiones = 0 then Begin
    if not planctas.Active then planctas.Open;
    planctas.FieldByName('codcta').DisplayLabel := 'Código';
    if not tabla.Active then tabla.Open;
    if not tabpar.Active then tabpar.Open;
    if not tpar.Active then tpar.Open;
  end;
  Inc(conexiones);
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
