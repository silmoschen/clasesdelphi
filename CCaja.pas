unit CCaja;

interface

uses SysUtils, CLibCont, CListar, DB, DBTables, CUtiles, CIDBFM;

type

TTCaja = class(TTLibrosCont)            // Superclase
  periodo, nroplanilla, nroitems, tipomov, fecha, concepto, pagado, conceptogral, fechacab: string;
  importe: real;
  tcabcaja, tcaja  : TTable;
 public
  { Declaraciones Públicas }
  constructor Create(xperiodo, xnroplanilla, xnroitems, xtipomov, xfecha, xconcepto, xpagado, xconceptogral: string; ximporte: real);
  destructor  Destroy; override;

  procedure   selItems(xperiodo, xnroplanilla, xtm: string);
  function    setItems: TTable;
  function    getTotingresos: real;
  function    getTotegresos: real;
  procedure   TotIngresosEgresos(xfecha: string);

  procedure   Grabar(xperiodo, xnroplanilla, xcodcta, xnroitems, xtipomov, xfecha, xconcepto, xpagado: string; ximporte: real); overload;
  procedure   Grabar(xperiodo, xnroplanilla, xfecha, xconceptogral: string); overload;
  procedure   Borrar(xperiodo, xnroplanilla, xcodcta, xnroitems, xtipomov: string); overload;
  procedure   Borrar(xperiodo, xnroplanilla: string); overload;
  function    Buscar(xperiodo,xnroplanilla, xcodcta, xnroitems, xtipomov: string): boolean; overload;
  function    Buscar(xperiodo, xnroplanilla: string): boolean; overload;
  function    NuevoItems: string; overload;
  function    NuevoItems(xperiodo: string): string; overload;
  function    Nuevanroplanilla: string;
  function    setPlanillas(xperiodo: string): TQuery;
  function    setIngresos(xperiodo, xmes: string): TQuery;
  function    setEgresos(xperiodo, xmes: string): TQuery;
  procedure   FiltrarCuenta(xperiodo, xnroplanilla, xcodcta, xtipomov: string);
  procedure   DesactivarFiltro;
  function    verifCuenta(xcodcta: string): boolean;
  procedure   Depurar(xfecha: string);

  procedure   getDatos(xperiodo, xnroplanilla, xcodcta, xnroitems, xtipomov: string); overload;
  procedure   getDatos(xperiodo, xnroplanilla: string); overload;
  procedure   Listar(salida: char; valor1, valor2, nroplanilla, acti, tl, tit, xperiodo: string);

  procedure   vaciarBuffer;
  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  conexiones: shortint;
  np, ttl, path: string; emsaldo: boolean;
  function    PPeriodo(xf: string): string;
  procedure   getDatos(t: byte); overload;
  procedure   Subtotales(salida: char);
  procedure   ListarLinea(salida: char);
  procedure   Listar_cuenta(salida: char; valor1, valor2, nroplanilla, acti, tl, tit: string);
end;

function caja: TTCaja;

implementation

var
  xcaja: TTCaja = nil;

constructor TTCaja.Create(xperiodo, xnroplanilla, xnroitems, xtipomov, xfecha, xconcepto, xpagado, xconceptogral: string; ximporte: real);
begin
  inherited Create;
  periodo      := xperiodo;
  nroplanilla  := xnroplanilla;
  nroitems     := xnroitems;
  tipomov      := xtipomov;
  fecha        := xfecha;
  concepto     := xconcepto;
  pagado       := xpagado;
  conceptogral := xconceptogral;
  fechacab     := '';
  importe      := ximporte;

  tcabcaja := datosdb.openDB('cabcaja', 'Periodo;Nroplanilla');
  tcaja    := datosdb.openDB('cajamov', 'Periodo;Nroplanilla;Codcta;Nroitems;Tipomov');
end;

destructor TTCaja.Destroy;
begin
  inherited Destroy;
end;

function TTCaja.getTotIngresos: real;
begin
  Result := totingresos;
end;

function TTCaja.getTotegresos: real;
begin
  Result := totegresos;
end;

procedure TTCaja.Grabar(xperiodo, xnroplanilla, xcodcta, xnroitems, xtipomov, xfecha, xconcepto, xpagado: string; ximporte: real);
// Objetivo...: Grabar Atributos del Objeto
begin
  if Buscar(xperiodo, xnroplanilla, xcodcta, xnroitems, xtipomov) then tcaja.Edit else tcaja.Append;
  tcaja.FieldByName('periodo').AsString     := xperiodo;
  tcaja.FieldByName('nroplanilla').AsString := xnroplanilla;
  tcaja.FieldByName('codcta').AsString      := xcodcta;
  tcaja.FieldByName('nroitems').AsString    := xnroitems;
  tcaja.FieldByName('tipomov').AsString     := xtipomov;
  tcaja.FieldByName('fecha').AsString       := utiles.sExprFecha(xfecha);
  tcaja.FieldByName('concepto').AsString    := xconcepto;
  tcaja.FieldByName('pagado').AsString      := xpagado;
  tcaja.FieldByName('importe').AsFloat      := ximporte;
  try
    tcaja.Post;
  except
    tcaja.Cancel
  end;
end;

procedure TTCaja.Grabar(xperiodo, xnroplanilla, xfecha, xconceptogral: string);
// Objetivo...: Grabar Atributos del Objeto - cabecera de la nroplanilla
begin
  if Buscar(xperiodo, xnroplanilla) then tcabcaja.Edit else tcabcaja.Append;
  tcabcaja.FieldByName('periodo').AsString     := xperiodo;
  tcabcaja.FieldByName('nroplanilla').AsString := xnroplanilla;
  tcabcaja.FieldByName('fecha').AsString       := utiles.sExprFecha(xfecha);
  tcabcaja.FieldByName('concepto').AsString    := xconceptogral;
  try
    tcabcaja.Post;
  except
    tcabcaja.Cancel;
  end;
end;

procedure TTCaja.Borrar(xperiodo, xnroplanilla, xcodcta, xnroitems, xtipomov: string);
// Objetivo...: Eliminar un Objeto - movimiento de caja
begin
  if Buscar(xperiodo, xnroplanilla, xcodcta, xnroitems, xtipomov) then
    begin
      tcaja.Delete;
      getDatos(tcaja.FieldByName('periodo').AsString, tcaja.FieldByName('nroplanilla').AsString, tcaja.FieldByName('codcta').AsString, tcaja.FieldByName('nroitems').AsString, xtipomov);  // Fijamos los Atributos Siguientes al Objeto Borrado
    end;
end;

procedure TTCaja.Borrar(xperiodo, xnroplanilla: string);
// Objetivo...: Borrar una nroplanilla con sus movimientos
begin
  datosdb.tranSQL('DELETE FROM cabcaja WHERE periodo = ' + '''' + periodo + '''' + ' AND nroplanilla = ' + '''' + xnroplanilla + '''');
  datosdb.tranSQL('DELETE FROM cajamov WHERE periodo = ' + '''' + periodo + '''' + ' AND nroplanilla = ' + '''' + xnroplanilla + '''');
  getDatos(tcabcaja.FieldByName('periodo').AsString, tcabcaja.FieldByName('nroplanilla').AsString);
end;

function TTCaja.Buscar(xperiodo,xnroplanilla, xcodcta, xnroitems, xtipomov: string): boolean;
// Objetivo...: Buscar el objeto solicitado
begin
  if not tcaja.Active then conectar;
  Result := datosdb.Buscar(tcaja, 'periodo', 'nroplanilla', 'codcta', 'nroitems', 'tipomov', xperiodo, xnroplanilla, xcodcta, xnroitems, xtipomov);
end;

function TTCaja.Buscar(xperiodo, xnroplanilla: string): boolean;
// Objetivo...: Buscar el Objeto solicitado
begin
  if not tcabcaja.Active then conectar;
  Result := datosdb.Buscar(tcabcaja, 'periodo', 'nroplanilla', xperiodo, xnroplanilla);
end;

procedure  TTCaja.getDatos(xperiodo, xnroplanilla: string);
// Objetivo...: Retornar/Iniciar Atributos de cabecera
begin
  tcabcaja.Refresh; tcaja.Refresh;
  if Buscar(xperiodo, xnroplanilla) then
    begin
      periodo      := tcabcaja.FieldByName('periodo').AsString;
      nroplanilla  := tcabcaja.FieldByName('nroplanilla').AsString;
      fechacab     := utiles.sFormatoFecha(tcabcaja.FieldByName('fecha').AsString);
      conceptogral := tcabcaja.FieldByName('concepto').AsString;
    end
  else
    begin
      periodo := ''; nroplanilla := ''; fechacab := ''; conceptogral := '';
    end;
end;

procedure  TTCaja.getDatos(xperiodo, xnroplanilla, xcodcta, xnroitems, xtipomov: string);
// Objetivo...: Retornar/Iniciar Atributos terniendo en cuenta Código Plan de Cuentas
begin
  if Buscar(xperiodo, xnroplanilla, xcodcta, xnroitems, xtipomov) then getDatos(1) else getDatos(0);
end;

procedure  TTCaja.getDatos(t: byte);
// Objetivo...: Actualizar los atributos de la clase con el registro de la tabla de persistencia
begin
  tcabcaja.Refresh; tcaja.Refresh;
  if t = 1 then
   begin
    periodo     := tcaja.FieldByName('periodo').AsString;
    nroplanilla := tcaja.FieldByName('nroplanilla').AsString;
    nroitems    := tcaja.FieldByName('nroitems').AsString;
    fecha       := utiles.sFormatoFecha(tcaja.FieldByName('fecha').AsString);
    tipomov     := tcaja.FieldByName('tipomov').AsString;
    concepto    := tcaja.FieldByName('concepto').AsString;
    pagado      := tcaja.FieldByName('pagado').AsString;
    importe     := tcaja.FieldByName('importe').AsFloat;
   end
  else
   begin
    periodo := ''; nroplanilla := ''; nroitems := ''; fecha := ''; tipomov := ''; concepto := ''; pagado := ''; importe := 0;
   end;
end;

function TTCaja.NuevoItems: string;
// Objetivo...: Generar un Nuevo Atributo Código
var
  items: string; filtro: boolean;
begin
  filtro := False;
  if tcaja.Filtered then Begin
    tcaja.Filtered := False;
    filtro         := True;
  end;
  nroplanilla := '0001'; items := '1';
  tcaja.Refresh; tcaja.Last;
  if Length(trim(tcaja.FieldByName('nroitems').AsString)) > 0 then
    begin
      nroplanilla := tcaja.FieldByName('nroplanilla').AsString;
      items    := IntToStr(tcaja.FieldByName('nroitems').AsInteger + 1);
    end;
  tcaja.Filtered := filtro;
  Result := items;
end;

function TTCaja.NuevoItems(xperiodo: string): string;
// Objetivo...: Generar un Nuevo Atributo Código
var
  items: string; filtro: boolean;
begin
  filtro := False;
  if tcaja.Filtered then Begin
    tcaja.Filtered := False;
    filtro         := True;
  end;
  tcaja.Refresh;
  datosdb.Filtrar(tcaja, 'Periodo = ' + '''' + xperiodo + '''');
  nroplanilla := '0001'; items := '1';
  tcaja.Last;
  if Length(trim(tcaja.FieldByName('nroitems').AsString)) > 0 then
    begin
      nroplanilla := tcaja.FieldByName('nroplanilla').AsString;
      items    := IntToStr(tcaja.FieldByName('nroitems').AsInteger + 1);
    end;
  tcaja.Filtered := filtro;
  Result := items;
end;

function TTCaja.Nuevanroplanilla: string;
// Objetivo...: Generar una Nueva nroplanilla
begin
  tcabcaja.Refresh; tcabcaja.Last;
  Result := utiles.sLlenarIzquierda(IntToStr((tcabcaja.FieldByName('nroplanilla').AsInteger + 1)), 4, '0');
end;

function TTCaja.PPeriodo(xf: string): string;
// Objetivo...: Determinar Periodo para Grabar
var
  t: string;
begin
  if Length(Trim(xf)) = 0 then t := utiles.sExprFecha(FormatDateTime('dd/mm/yy', (date))) else t := utiles.sExprFecha(xf);
  Result := Copy(t, 1, 4);
end;

procedure  TTCaja.selItems(xperiodo, xnroplanilla, xtm: string);
// Objetivo...: Individualizar los movimientos de Caja
begin
  if Length(Trim(xperiodo)) = 0 then periodo := PPeriodo('') else periodo := xperiodo;
  tcaja.Filtered := False;
  tcaja.Filter   := 'Periodo = ' + '"' + periodo + '"' + ' and Nroplanilla = ' + '"' + xnroplanilla + '"' + ' and tipomov = ' + '"' + xtm + '"';
  tcaja.Filtered := True;
end;

function TTCaja.setItems: TTable;
// Objetivo...: retornar un Set con los Movimientos individualizados
begin
  tcaja.FieldByName('periodo').Visible := False; tcaja.FieldByName('nroplanilla').Visible := False; tcaja.FieldByName('tipomov').Visible := False; tcaja.FieldByName('fecha').Visible := False;
  Result := tcaja;
end;

procedure TTCaja.TotIngresosEgresos(xfecha: string);
// Objetivo...: Obtener el total de Ingresos y Egresos
var
  f: string;
begin
  f := tcaja.Filter;
  tcaja.Filtered := False;
  totingresos := 0; totegresos := 0;
  tcaja.First;
  while not tcaja.EOF do
    begin
      if tcaja.FieldByName('fecha').AsString = utiles.sExprFecha(xfecha) then
        begin
          if tcaja.FieldByName('tipomov').AsString = '1' then totingresos := totingresos + tcaja.FieldByName('importe').AsFloat;
          if tcaja.FieldByName('tipomov').AsString = '2' then totegresos  := totegresos + tcaja.FieldByName('importe').AsFloat;
        end;
      tcaja.Next;
    end;
  if Length(Trim(f)) > 0 then tcaja.Filtered := True;
end;

function  TTCaja.setPlanillas(xperiodo: string): TQuery;
// Objetivo...: devolver un set con las nroplanillas generadas en un período
begin
  Result := datosdb.tranSQL('SELECT * FROM cabcaja WHERE periodo = ' + '''' + xperiodo + '''');
end;

function  TTCaja.setIngresos(xperiodo, xmes: string): TQuery;
// Objetivo...: devolver un set con las ingresos del periodo solicitado
var
  ultdia: string;
begin
  ultdia := xperiodo + xmes + utiles.ultFechaMes(xmes, xperiodo);
  Result := datosdb.tranSQL('SELECT * FROM cajamov WHERE fecha >= ' + '''' + xperiodo + xmes + '01' + '''' + ' AND fecha <= ' + '''' + ultdia + '''' + ' AND tipomov = ' + '''' + '1' + '''' + ' ORDER BY codcta');
end;

function  TTCaja.setEgresos(xperiodo, xmes: string): TQuery;
// Objetivo...: devolver un set con las egresos del periodo solicitado
var
  ultdia: string;
begin
  ultdia := xperiodo + xmes + utiles.ultFechaMes(xmes, xperiodo);
  Result := datosdb.tranSQL('SELECT * FROM cajamov WHERE fecha >= ' + '''' + xperiodo + xmes + '01' + '''' + ' AND fecha <= ' + '''' + ultdia + '''' + ' AND tipomov = ' + '''' + '2' + '''' + ' ORDER BY codcta');
end;

procedure TTCaja.FiltrarCuenta(xperiodo, xnroplanilla, xcodcta, xtipomov: string);
// Objetivo...: Extraer los movimientos de una cuenta dada
begin
  datosdb.Filtrar(tcaja, 'Periodo = ' + '''' + xperiodo + ''''  + ' AND Nroplanilla = ' + '''' + xnroplanilla + '''' + ' AND Codcta = ' + '''' + xcodcta + '''' + ' AND tipomov = ' + '''' + xtipomov + '''');
end;

procedure TTCaja.DesactivarFiltro;
// Objetivo...: Desactivar Filtros
begin
  tcaja.Filtered := False;
end;

procedure TTCaja.Depurar(xfecha: string);
// Objetivo...: Depurar Movimientos de caja
var
  f: string; tm: string;
begin
  conectar;
  // Paso Nº 1 - Calculamos el saldo que queda
  f := tcaja.Filter;
  tcaja.Filtered := False;
  totingresos := 0; totegresos := 0;
  tcaja.First;
  while not tcaja.EOF do
    begin
      if tcaja.FieldByName('fecha').AsString <= utiles.sExprFecha(xfecha) then
        begin
          if tcaja.FieldByName('tipomov').AsString = '1' then totingresos := totingresos + tcaja.FieldByName('importe').AsFloat;
          if tcaja.FieldByName('tipomov').AsString = '2' then totegresos  := totegresos + tcaja.FieldByName('importe').AsFloat;
        end;
      tcaja.Next;
    end;
  if Length(Trim(f)) > 0 then tcaja.Filtered := True;
  // Paso Nº 2 - Eliminamos....
  datosdb.tranSQL('DELETE FROM ' + tcabcaja.TableName + ' WHERE fecha <= ' + '"' + utiles.sExprFecha(xfecha) + '"');
  datosdb.tranSQL('DELETE FROM ' + tcaja.TableName + ' WHERE fecha <= ' + '"' + utiles.sExprFecha(xfecha) + '"');
  if (totingresos - totegresos) >= 0 then tm := '1' else tm := '2';

  Grabar(Copy(xfecha, 4, 2) + '/' + Copy(utiles.sExprFecha(xfecha), 1, 4), '0001', '', '00001', tm, xfecha, 'Saldo inicial', 'Saldo inicial', totingresos - totegresos);
  desconectar;
end;

function TTCaja.verifCuenta(xcodcta: string): boolean;
// Objetivo...: Verificar si una cuenta se encuentra el alguno de los asientos
begin
  TSQL := datosdb.tranSQL(path, 'SELECT * FROM cajamov WHERE codcta = ' + '''' + xcodcta + '''');
  TSQL.Open;
  if TSQL.RecordCount > 0 then Result := True else Result := False;
  TSQL.Close;
end;

procedure TTCaja.Listar(salida: char; valor1, valor2, nroplanilla, acti, tl, tit, xperiodo: string);
begin
  emsaldo        := False;
  np  := valor1;
  ttl := tl;
  totingresos := 0; totegresos := 0; saldo := 0;
  IniciarInforme(salida);

  list.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  list.Titulo(0, 0, tit, 1, 'Arial, negrita, 14');
  list.Titulo(0, 0, ' ', 1, 'Times New Roman, ninguno, 4');
  list.Titulo(0, 0, utiles.espacios(400) + 'Hoja Nº: ' + utiles.sLlenarIzquierda((IntToStr(list.nroPagina)), 4, '0'), 1, 'Times New Roman, ninguno, 8');
  list.Titulo(0, 0, ' ', 1, 'Times New Roman, ninguno, 4');
  list.Titulo(0, 0, utiles.espacios(50) + 'Ingresos' + utiles.espacios(100) + 'Egresos', 1, 'Times New Roman, negrita, 14');
  list.Titulo(0, 0, list.linealargopagina(salida), 1, 'Arial, normal, 11');

  list.Titulo(0, 0, '       Fecha    Concepto ', 1, 'Arial, cursiva, 8');
  list.Titulo(36, list.lineactual, 'Cobrado a', 3, 'Arial, cursiva, 8');
  list.Titulo(65, list.lineactual, 'Importe', 4, 'Arial, cursiva, 8');

  list.Titulo(80, list.lineactual, 'Fecha       Concepto', 5, 'Arial, cursiva, 8');
  list.Titulo(113, list.lineactual, 'Pagado a', 6, 'Arial, cursiva, 8');
  list.Titulo(140, list.lineactual, 'Importe', 7, 'Arial, cursiva, 8');
  list.Titulo(157, list.lineactual, 'Saldo', 8, 'Arial, cursiva, 8');
  list.Titulo(164, list.lineactual, 'Act.', 9, 'Arial, cursiva, 8');
  list.Titulo(0, 0, list.linealargopagina(salida), 1, 'Arial, normal, 11');
  list.Titulo(0, 0, '  ', 1, 'Arial, negrita, 8');
  if ttl = '2' then list.Titulo(0, 0, 'Planilla Nº: ' + np + utiles.espacios(5) + 'Fecha: ' + utiles.sFormatoFecha(tcabcaja.FieldByName('fecha').AsString) + utiles.espacios(5) + 'Concepto: ' + tcabcaja.FieldByName('concepto').AsString, 1, 'Times New Roman, negrita, 12');
  list.Titulo(0, 0, '  ', 1, 'Arial, negrita, 8');

  tcaja.IndexName := 'Emitir';

  tcaja.First;
  while not tcaja.EOF do
    begin
     if list.SaltoPagina then
       begin
         Subtotales(salida);
         list.IniciarNuevaPagina;
       end;

       // Calculamos el Saldo de Caja
       if tl <> '3' then  // No calculamos el saldo cuando se trata de Actividades Individuales
         begin
           saldoanter := saldo;
           if (tcaja.FieldByName('tipomov').AsString = '1') or (tcaja.FieldByName('tipomov').AsString = '6') or (tcaja.FieldByName('tipomov').AsString = '7') then saldo := saldo + tcaja.FieldByName('importe').AsFloat;
           if (tcaja.FieldByName('tipomov').AsString = '2') or (tcaja.FieldByName('tipomov').AsString = '5') then saldo := saldo - tcaja.FieldByName('importe').AsFloat;
         end;

       if (tcaja.FieldByName('fecha').AsString >= utiles.sExprFecha(valor1)) and (tcaja.FieldByName('fecha').AsString <= utiles.sExprFecha(valor2)) then
         begin
           if tl = '1' then  // Filtro por Fecha
             ListarLinea(salida);

             if tl = '2' then  // Filtro por Nro. de Planilla
               if (tcaja.FieldByName('nroplanilla').AsString = valor1) and (tcaja.FieldByName('periodo').AsString = xperiodo) then ListarLinea(salida);

             if tl = '3' then Listar_cuenta(salida, valor1, valor2, nroplanilla, acti, tl, tit);

             if tl = '4' then
               if (tcaja.FieldByName('tipomov').AsString = '1') or (tcaja.FieldByName('tipomov').AsString = '6') or (tcaja.FieldByName('tipomov').AsString = '7') then ListarLinea(salida);

             if tl = '5' then
               if (tcaja.FieldByName('tipomov').AsString = '2') or (tcaja.FieldByName('tipomov').AsString = '5') then ListarLinea(salida);
         end;

       tcaja.Next;
    end;

    list.CompletarPagina;
    Subtotales(salida);
    list.FinList;

    tcaja.IndexFieldNames := 'Periodo;Nroplanilla;Codcta;Nroitems;Tipomov';
end;

procedure TTCaja.ListarLinea;
//Objetivo...: Listar una Línea
begin
  if not emsaldo then
    begin
      list.Linea(0, 0, utiles.espacios(200) + 'Saldo Anterior .............: ', 1, 'Arial, normal, 10', salida, 'N');
      list.importe(150, list.lineactual, '', saldoanter, 2, 'Arial, normal, 10');
      list.Linea(160, list.lineactual, '  ', 3, 'Arial, normal, 10', salida, 'S');
      list.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');
      emsaldo := true;
    end;
    if (tcaja.FieldByName('tipomov').AsString = '1') or (tcaja.FieldByName('tipomov').AsString = '6') or (tcaja.FieldByName('tipomov').AsString = '7') then
      begin  // Ingresos
        list.Linea(0, 0, utiles.espacios(5) + utiles.sFormatoFecha(tcaja.FieldByName('fecha').AsString) + '  ' + tcaja.FieldByName('pagado').AsString, 1, 'Arial, normal, 8', salida, 'N');
        list.Linea(36, list.lineactual, tcaja.FieldByName('concepto').AsString, 2, 'Arial, normal, 8', salida, 'N');
        list.importe(70, list.lineactual, '', tcaja.FieldByName('importe').AsFloat, 3, 'Arial, normal, 8');
        list.Linea(80, list.lineactual, '  ', 4, 'Arial, normal, 8', salida, 'N');
        totingresos := totingresos + tcaja.FieldByName('importe').AsFloat;
      end;
   if (tcaja.FieldByName('tipomov').AsString = '2') or (tcaja.FieldByName('tipomov').AsString = '5') then
      begin  // Egresos
        list.Linea(0, 0, '  ', 1, 'Arial, normal, 8', salida, 'N');
        list.Linea(80, list.lineactual, utiles.sFormatoFecha(tcaja.FieldByName('fecha').AsString) + '  ' + tcaja.FieldByName('pagado').AsString, 2, 'Arial, normal, 8', salida, 'N');
        list.Linea(113, list.lineactual, tcaja.FieldByName('concepto').AsString, 3, 'Arial, normal, 8', salida, 'N');
        list.importe(145, list.lineactual, '', tcaja.FieldByName('importe').AsFloat, 4, 'Arial, normal, 8');
        totegresos := totegresos + tcaja.FieldByName('importe').AsFloat;
      end;

  idanterior := tcaja.FieldByName('codcta').AsString;
  // Emisión del Saldo
  list.importe(161, list.lineactual, '', saldo, 5, 'Arial, normal, 8');
  saldofinal := saldo;

  list.Linea(164, list.lineactual, tcaja.FieldByName('codactivi').AsString, 6, 'Arial, normal, 8', salida, 'S');
end;

procedure TTCaja.Listar_cuenta(salida: char; valor1, valor2, nroplanilla, acti, tl, tit: string);
//Objetivo...: Listar una Cuenta Específica
begin
  // Filtramos por Código de Actividad y por Fecha
  if (tcaja.FieldByName('codactivi').AsString = valor1) and (tcaja.FieldByName('fecha').AsString >= utiles.sExprFecha(valor1)) and (tcaja.FieldByName('fecha').AsString <= utiles.sExprFecha(valor2)) then
     begin
       saldoanter := saldo;
       if tcaja.FieldByName('tipomovi').AsString = '1' then saldo := saldo + tcaja.FieldByName('importe').AsFloat else saldo := saldo - tcaja.FieldByName('importe').AsFloat;
       ListarLinea(salida);
     end;
end;

procedure TTCaja.Subtotales(salida: char);
//Objetivo....: Emitir Subtotales
begin
  list.PrintLn(0, 0, list.linealargopagina(salida), 1, 'Arial, normal, 11');
  list.Linea(0, 0, utiles.espacios(40) + 'Total Ingresos Caja ........:', 1, 'Arial, negrita, 8', salida, 'N');
  list.importe(70, list.lineactual, '', totingresos, 2, 'Arial, negrita, 8');
  list.importe(145, list.lineactual, '', totegresos, 3, 'Arial, negrita, 8');
  list.importe(161, list.lineactual, '', saldofinal, 4, 'Arial, normal, 8');
end;

procedure  TTCaja.vaciarBuffer;
// Objetivo...: vaciar Buffers de tablas al disco
begin
  datosdb.vaciarBuffer(tcaja);
  datosdb.vaciarBuffer(tcabcaja);
end;

procedure  TTCaja.conectar;
// Objetivo...: conectar tablas de persistencia
begin
  if conexiones = 0 then Begin
    if not tcaja.Active then tcaja.Open;
    if not tcabcaja.Active then tcabcaja.Open;
    tcabcaja.FieldByName('nroplanilla').DisplayLabel := 'Nº Planilla'; tcabcaja.FieldByName('periodo').DisplayLabel := 'Período';
    tcaja.FieldByName('periodo').Visible := False; tcaja.FieldByName('nroplanilla').Visible := False; tcaja.FieldByName('codcta').Visible := False; tcaja.FieldByName('tipomov').Visible := False; tcaja.FieldByName('codactivi').Visible := False; tcaja.FieldByName('fecha').Visible := False;
    tcaja.FieldByName('nroitems').DisplayLabel := 'Nº Items'; tcaja.FieldByName('pagado').DisplayLabel := 'Cobrado / Pagado a'; tcabcaja.FieldByName('fecha').Visible := False;
  end;
  Inc(conexiones);
end;

procedure  TTCaja.desconectar;
// Objetivo...: desconectar tablas de persistencia
begin
  if conexiones > 0 then Dec(conexiones);
  if conexiones = 0 then Begin
    datosdb.closeDB(tcaja);
    datosdb.closeDB(tcabcaja);
  end;
end;

{===============================================================================}

function caja: TTCaja;
begin
  if xcaja = nil then
    xcaja := TTCaja.Create('', '', '', '', '', '', '', '', 0);
  Result := xcaja;
end;

{===============================================================================}

initialization

finalization
  xcaja.Free;

end.
