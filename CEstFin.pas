{ Objetivo....: Gestionar los cálculos para la Emisión de los Informes Contables
  Fianales - Estado de Resultados, Balances, entre otros}

unit CEstFin;

interface

uses CRegCont, CPlanctas, SysUtils, DB, DBTables, CBDT, CUtiles, CIDBFM;

type

TTEstadosContables = class(TTRegCont)
  totsaldodeudor, totsaldoacreedor: real;
  plctas: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  procedure TotalDiario(periodo, df, hf: string; tipopase: char);
  procedure PasesDiario_PlanDeCuentas(todaslascuentas: char; periodo: string);
  procedure PasesDiario_PlanDeCuentasFecha(todaslascuentas: char; periodo, df: string);
  procedure CalcPatNeto(acttodaslasctas: char);

  procedure Via(xvia: string);
  procedure conectar;
  procedure desconectar;
 private
  { Declaraciones Privadas }
  procedure FiltrarAsientos(periodo, df, hf: string);
  procedure IniciarProceso(todaslascuentas: char);
  procedure RecMovImputables;
  procedure ActualizarSubtotales;
  procedure GrabarCalculos;
  procedure t_saldosanteriores;
  procedure ActualizarNivel(Nivel: integer);
  procedure RecMovSuperior;
 protected
  { Declaraciones Protegidas }
  dbconexion: String;
end;

function estcont: TTEstadosContables;

implementation

var
  xestcont: TTEstadosContables = nil;

constructor TTEstadosContables.Create;
begin
  inherited Create;
end;

destructor TTEstadosContables.Destroy;
begin
  inherited Destroy;
end;

procedure TTEstadosContables.FiltrarAsientos(periodo, df, hf: string);
// Objetivos...: Filtrar las Operaciones del Diario
begin
  datosdb.Filtrar(asientos, 'periodo = ' + '''' + periodo + '''' + ' and fecha >= ' + '''' + utiles.sExprFecha(df) + '''' + ' and fecha <= ' + '''' + utiles.sExprFecha(hf) + '''');
end;

procedure TTEstadosContables.TotalDiario(periodo, df, hf: string; tipopase: char);
// Objetivos...: Subtotalizar las cuentas registradas en el diario y persistir los resultados
var
  indice: string;
begin
  FiltrarAsientos(periodo, df, hf);
  {Inicializamos variables ...}
  totdebe  := 0; tothaber := 0;
  idanterior := '';
  {Ponemos los importes del Plan de Cuentas en cero}
  planctas.IniciarSubtotales(1);

  indice := asientos.IndexName;
  asientos.IndexName := 'Sumatoria';
  // Filtramos solo los datos de la campania Activa
  datosdb.Filtrar(asientos, 'periodo = ' + '''' + periodo + '''');

  asientos.First;
  while not asientos.EOF do
    begin
      {Separamos los movimientos NO actualizados}
      if asientos.FieldByName('codcta').AsString <> idanterior then
        begin
          totdebe  := 0; tothaber := 0;
        end;

      if asientos.FieldByName('Dh').AsString = '1' then totdebe := totdebe + asientos.FieldByName('importe').AsFloat else tothaber := tothaber + asientos.FieldByName('importe').AsFloat;
      if tipopase = 'T' then     //Pasamos los importes de todos los asientos, inclusive los de cierre y apertura
        planctas.Subtotales(asientos.FieldByName('codcta').AsString, totdebe, tothaber);

      if tipopase = 'P' then     //Pasamos los importes de todos los asientos, exepto los de los asientos de refundición sw cuentas
        if not (Copy(asientos.FieldByName('clave').AsString, 1, 2) = 'AR') or (Copy(asientos.FieldByName('clave').AsString, 1, 2) = 'AP') then
          planctas.Subtotales(asientos.FieldByName('codcta').AsString, totdebe, tothaber);

      idanterior := asientos.FieldByName('codcta').AsString;
      asientos.Next;
    end;
    asientos.IndexName := indice;
end;

//------------------------------------------------------------------------------

procedure TTEstadosContables.PasesDiario_PlanDeCuentas(todaslascuentas: char; periodo: string);
begin
{*********************************************************************************}
{Paso 1 - Sumarizamos desde Asientos a las Cuentas Imputables de asientos planctas}
{*********************************************************************************}
  {Filtramos los asientos del Periodo Actual}
  planctas.IniciarSubtotales(1);
  IniciarProceso(todaslascuentas);
end;

procedure TTEstadosContables.PasesDiario_PlanDeCuentasFecha(todaslascuentas: char; periodo, df: string);
begin
{*********************************************************************************}
{Paso 1 - Sumarizamos desde Asientos a las Cuentas Imputables de asientos planctas}
{*********************************************************************************}
  {Filtramos los asientos de la campania en Actual}
  datosdb.Filtrar(asientos, 'periodo = ' + '''' + periodo + '''' + ' and fecha < ' + '''' + df + '''');
  planctas.IniciarSubtotales(1); planctas.IniciarSubtotales(2);
  IniciarProceso(todaslascuentas);
  t_saldosanteriores;   // Paso de saldos
end;

procedure TTEstadosContables.IniciarProceso(todaslascuentas: char);
// Objetivo...: Proceso de Actualización de Saldos
begin
  //Desactivemos Filtros
  planctas.DesactivarFiltro;
  {Activamos los Indices correspondientes}
  asientos.IndexName := 'Sumatoria';
  planctas.OrdenarPorCuenta;

  {Comenzamos la recorrida desde el primer registro}
  asientos.First;
  idanterior := asientos.FieldByName('codcta').AsString;
  totdebe := 0; tothaber := 0; i := 0; r := 0;
  while not asientos.EOF do
    begin
      {Cuando se produce un cambio de cuenta, actualizamos}
      if asientos.FieldByName('codcta').AsString <> idanterior then RecMovImputables;
      if asientos.FieldByName('dh').AsString = '1' then totdebe := totdebe + asientos.FieldByName('importe').AsFloat else tothaber := tothaber + asientos.FieldByName('importe').AsFloat;
      r := r + 1;
      asientos.Next;
    end;
  {Grabamos los Importes Generados}
  RecMovImputables;
  ActualizarSubtotales;

  {*********************************************************************************}
  {Paso 2 - Sumarizar en las Cuentas por Niveles                                    }
  {Nota   - Solo se calculará en caso de Preparación de Balance, caso contrario solo}
  {         se actualizan las cuentas Imputables                                    }
  {*********************************************************************************}

  if todaslascuentas = 'S' then
    begin
      ActualizarNivel(5);  {Nivel 5}
      ActualizarNivel(4);  {Nivel 4}
      ActualizarNivel(3);  {Nivel 3}
      ActualizarNivel(2);  {Nivel 2}
      ActualizarNivel(1);  {Nivel 1}
    end;

  asientos.IndexFieldNames := 'Periodo;Nroasien;Nromovi';
end;

{procedure TTEstadosContables.IniciarTotales(opt: byte);
{Colocamos el TOTALDEBE y TOTALHABER de cada cuenta en }
{begin
  planctas.IniciarSubtotales(opt);
  IniciarArray;
end;}

{*********************************************************************************}
{GENRAL - Actualización por Niveles de Ruptura}
{*********************************************************************************}
procedure TTEstadosContables.ActualizarNivel(Nivel: integer);
begin
  plctas.IndexName := 'Sumariza';
  datosdb.Filtrar(plctas, 'nivel = ' + IntToStr(Nivel));
  plctas.First;
  idanterior := plctas.FieldByName('sumariza').AsString;
  i := 0; totdebe := 0; tothaber := 0; r := 0;
  while not plctas.EOF do
    begin
      if plctas.FieldByName('sumariza').AsString <> idanterior then RecMovSuperior;
      totdebe  := totdebe  + plctas.FieldByName('totaldebe').AsFloat;
      tothaber := tothaber + plctas.FieldByName('totalhaber').AsFloat;
      r := r + 1;
      plctas.Next;
    end;
   {Grabamos los Importes Generados}
    RecMovSuperior;
    GrabarCalculos;
    plctas.Filtered := False;
end;

{*********************************************************************************}
{Procedimientos Auxiliares}
{*********************************************************************************}
{Grabación de los movimientos Detoper a TablaItems}
procedure TTEstadosContables.RecMovImputables;
begin
  {Buscamos la cuenta subtotalizada para grabarla}
  i := i + 1;
  cuenta   [i] := idanterior;
  ttotdebe [i] := totdebe;
  ttothaber[i] := tothaber;
  idanterior   := asientos.FieldByName('codcta').AsString;
  totdebe  := 0; tothaber := 0;
end;

{Grabación de los movimientos Detoper a TablaItems}
procedure TTEstadosContables.ActualizarSubtotales;
var
  x: integer;
begin
  plctas.IndexFieldNames := 'Codcta';
  For x := 1 to i do
    begin
      if plctas.FindKey([cuenta[x]]) then
        begin
          plctas.Edit;
          plctas.FieldByName('totaldebe').AsFloat  := ttotdebe[x];
          plctas.FieldByName('totalhaber').AsFloat := ttothaber[x];
          try
            plctas.Post;
          except
            plctas.Cancel;
          end;
        end;
    end;
end;

{Grabación de los movimientos Detoper a TablaItems}
procedure TTEstadosContables.RecMovSuperior;
begin
  i := i + 1;
  cuenta   [i] := idanterior;
  ttotdebe [i] := totdebe;
  ttothaber[i] := tothaber;
  idanterior   := plctas.FieldByName('sumariza').AsString;
  totdebe := 0; tothaber := 0;
end;

{Recorro los movimientos del array volcándolos a las cuentas correspondientes}
procedure TTEstadosContables.GrabarCalculos;
var
  x: integer;
begin
  plctas.Filtered  := False;
  plctas.IndexFieldNames := 'Codcta';
  for x := 1 to i do
    begin
      plctas.FindKey([cuenta[x]]);
      plctas.Edit;
      plctas.FieldByName('totaldebe').AsFloat  := ttotdebe[x];
      plctas.FieldByName('totalhaber').AsFloat := ttothaber[x];
      try
        plctas.Post;
      except
        plctas.Cancel;
      end;
    end;
end;

procedure TTEstadosContables.CalcPatNeto(acttodaslasctas: char);
var
  dpt, hpt: real;
begin
  planctas.getDatos;
  dpt := 0; hpt := 0;
  plctas.Filtered := False;
  plctas.First;
  while not plctas.EOF do
    begin
      //Verificamos que las cuentas sean las correctas
      if ((Copy(plctas.FieldByName('codcta').AsString, 1,1) = planctas.Ganancias) or (Copy(plctas.FieldByName('codcta').AsString, 1,1) = planctas.Perdidas) or (Copy(plctas.FieldByName('codcta').AsString, 1,1) = planctas.Patneto)) and (plctas.FieldByName('imputable').AsString = 'S') then
        begin
          dpt := dpt + plctas.FieldByName('totaldebe').AsFloat;
          hpt := hpt + plctas.FieldByName('totalhaber').AsFloat;
        end;
      plctas.Next;
    end;

  //Grabamos la cuenta correspondiente
  if (plctas.FindKey([planctas.Ctaresulta])) and (dpt + hpt <> 0) then
    begin
      plctas.Edit;
      plctas.FieldByName('totaldebe').AsFloat  := dpt;
      plctas.FieldByName('totalhaber').AsFloat := hpt;
      try
        plctas.Post;
      except
        plctas.Cancel;
      end;
    end;
    //Determina si actualiza las cuentas de Nivel Superior
    if (acttodaslasctas = 'S') or (acttodaslasctas = 'X') then
      begin
        ActualizarNivel(5);  {Nivel 5}
        ActualizarNivel(4);  {Nivel 4}
        ActualizarNivel(3);  {Nivel 3}
        ActualizarNivel(2);  {Nivel 2}
        ActualizarNivel(1);  {Nivel 1}
      end;

      // Retenemos los Saldos Anteriores
      if acttodaslasctas = 'X' then t_saldosanteriores;
end;

procedure TTEstadosContables.t_saldosanteriores;
// Objetivo...: Guardar los saldos del Periodo Anterior
begin
  plctas.Open; plctas.First;
  while not plctas.EOF do
    begin
      plctas.Edit;
      plctas.FieldByName('a_totaldebe').AsFloat  := plctas.FieldByName('totaldebe').AsFloat;
      plctas.FieldByName('a_totalhaber').AsFloat := plctas.FieldByName('totalhaber').AsFloat;
      try
        plctas.Post;
      except
        plctas.Cancel;
      end;
      plctas.Next;
    end;
end;

//------------------------------------------------------------------------------

procedure TTEstadosContables.Via(xvia: string);
// Objetivo...: Determinar características multiempresa
begin
//  inherited Via(xvia);
  plctas := planctas.planctas;
  asientos.IndexName := 'Mayor';
end;

procedure TTEstadosContables.conectar;
// Objetivo...: Abrir tablas de persistencia
begin
  inherited conectar;
  plctas := planctas.planctas;
  asientos.IndexName := 'Mayor';
end;

procedure TTEstadosContables.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  inherited desconectar;
end;

{===============================================================================}

function estcont: TTEstadosContables;
begin
  if xestcont = nil then
    xestcont := TTEstadosContables.Create;
  Result := xestcont;
end;

{===============================================================================}

initialization

finalization
  xestcont.Free;

end.
