unit CLibrobcos;

interface

uses CLibCont, CBancos, SysUtils, CListar, DB, DBTables, CUtiles, CIDBFM;

type

TTLBancos = class(TTLibrosCont)
  clavecta, clave, observac, entbcaria, fealta: string;
  codbanco, tcomprob, tipomov, fecha, fecobro, pagado, concepto, tipoper: string;
  tipocheque: byte; monto: real;
  tlbco, tabla: TTable;
 public
  { Declaraciones Públicas }
  constructor Create(xcodbanco, xtcomprob, xtipomov, xfecha, xfecobro, xpagado, xconcepto, xtipoper: string; xmonto: real; xtipocheque: byte);
  destructor  Destroy; override;

  procedure   Grabar(xcodbanco, xclavecta, xclave, xbanco, xobservac, xfealta: string); overload;
  procedure   Borrar(xclavecta: string); overload;
  function    Buscar(xclavecta: string): boolean; overload;
  procedure   getDatos(xclavecta: string); overload;
  function    setCuentas: TQuery;
  procedure   BuscarPorCuenta(xexp: string);
  procedure   BuscarPorDescrip(xexp: string);

  function    verificarMovimiento(xclavecta: string): boolean;
  procedure   Grabar(xclavecta, xtcomprob, xtipomov, xfecha, xfecobro, xpagado, xconcepto, xtipoper: string; xmonto: real; xtipocheque: byte); overload;
  function    Buscar(xclavecta, xtcomprob, xtipomov: string): boolean; overload;
  procedure   Borrar(xclavecta, xtcomprob, xtipomov: string); overload;
  procedure   getDatos(xclavecta, xtcomprob, xtipomov: string); overload;
  procedure   Listar(xclavecta, xdf, xhf: string; salida, tls, tipofecha: char);
  procedure   ListarCtasDef(orden, iniciar, finalizar, ent_excl: string; salida: char);
  function    setTransacciones: TQuery;

  procedure   refrescar;
  procedure   vaciarBuffer;
  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  conexiones: shortint;
  procedure LineaLibro(salida: char);
  procedure List_linea(salida: char);
  procedure subtotal(salida: char);
end;

function banco: TTLBancos;

implementation

var
  xbanco: TTLBancos = nil;

constructor TTLBancos.Create(xCodbanco, xTcomprob, xTipomov, xFecha, xFecobro, xPagado, xConcepto, xtipoper: string; xMonto: real; xtipocheque: byte);
begin
  inherited Create;
  codbanco   := xcodbanco;
  tcomprob   := xtcomprob;
  tipomov    := xtipomov;
  fecha      := xfecha;
  fecobro    := xfecobro;
  pagado     := xpagado;
  concepto   := xconcepto;
  monto      := xmonto;
  tipoper    := xtipoper;
  tipocheque := xtipocheque;

  tlbco      := datosdb.openDB('bancos', 'Clavecta;Tcomprob;Tipomov');
  tabla      := datosdb.openDB('cctbcos', 'clavecta');
end;

destructor TTLBancos.Destroy;
begin
  inherited Destroy;
end;

//==============================================================================
// Métodos de definición de cuentas
function TTLBancos.Buscar(xclavecta: string): boolean;
begin
  if tabla.IndexFieldNames <> 'clavecta' then tabla.IndexFieldNames := 'clavecta';
  if tabla.FindKey([xclavecta]) then Result := True else Result := False;
end;

procedure TTLBancos.Grabar(xcodbanco, xclavecta, xclave, xbanco, xobservac, xfealta: string);
// Objetivo...: Definir los atributos de una cuenta corriente Bancaria
begin
  if Buscar(xclavecta) then tabla.Edit else tabla.Append;
  tabla.FieldByName('codbanco').AsString := xcodbanco;
  tabla.FieldByName('clavecta').AsString := xclavecta;
  tabla.FieldByName('clave').AsString    := xclave;
  tabla.FieldByName('banco').AsString    := xbanco;
  tabla.FieldByName('obs').AsString      := xobservac;
  tabla.FieldByName('fealta').AsString   := utiles.sExprFecha(xfealta);
  try
    tabla.Post;
  except
    tabla.Cancel;
  end;
end;

procedure TTLBancos.getDatos(xclavecta: string);
// Objetivo...: Actualizar los atributos de una cuenta
begin
  if Buscar(xclavecta) then
    begin
      codbanco   := tabla.FieldByName('codbanco').AsString;
      clavecta   := tabla.FieldByName('clavecta').AsString;
      clave      := tabla.FieldByName('clave').AsString;
      entbcaria  := tabla.FieldByName('banco').AsString;
      fealta     := utiles.sFormatoFecha(tabla.FieldByName('fealta').AsString);
      observac   := tabla.FieldByName('obs').AsString;
      entbcos.getDatos(codbanco);
    end
  else
    begin
      codbanco := ''; clavecta := ''; clave := ''; fealta := ''; observac := ''; entbcaria := '';
    end;
end;

procedure TTLBancos.Borrar(xclavecta: string);
// Objetivo...: Actualizar los atributos de una cuenta
begin
  if Buscar(xclavecta) then
    begin
      tabla.Delete;
      getDatos(tabla.FieldByName('clavecta').AsString);
    end;
end;

//==============================================================================
// Métodos de gestión de libros de bancos
procedure TTLBancos.Grabar(xclavecta, xtcomprob, xtipomov, xfecha, xfecobro, xpagado, xconcepto, xtipoper: string; xmonto: real; xtipocheque: byte);
// Objetivo...: Grabar Atributos del Objeto
begin
  if Buscar(xclavecta, xtcomprob, xtipomov) then tlbco.Edit else tlbco.Append;
  tlbco.FieldByName('clavecta').AsString    := xclavecta;
  tlbco.FieldByName('tcomprob').AsString    := xtcomprob;
  tlbco.FieldByName('tipomov').AsString     := xtipomov;
  tlbco.FieldByName('fecha').AsString       := utiles.sExprFecha(xfecha);
  tlbco.FieldByName('fecobro').AsString     := utiles.sExprFecha(xfecobro);
  tlbco.FieldByName('concepto').AsString    := xconcepto;
  tlbco.FieldByName('pagado').AsString      := xpagado;
  tlbco.FieldByName('tipoper').AsString     := xtipoper;
  tlbco.FieldByName('monto').AsFloat        := xmonto;
  tlbco.FieldByName('tipocheque').AsInteger := xtipocheque;
  try
    tlbco.Post;
  except
    tlbco.Cancel;
  end;
end;

procedure TTLBancos.Borrar(xclavecta, xtcomprob, xtipomov: string);
// Objetivo...: Eliminar un Objeto
begin
  if Buscar(xclavecta, xtcomprob, xtipomov) then
    begin
      tlbco.Delete;
      getDatos(tlbco.FieldByName('clavecta').AsString, tlbco.FieldByName('tcomprob').AsString, tlbco.FieldByName('tipomov').AsString);  // Fijamos los Atributos Siguientes al Objeto Borrado
    end;
end;

function TTLBancos.Buscar(xclavecta, xtcomprob, xtipomov: string): boolean;
// Objetivo...: Buscar el Objeto solicitado
begin
  Result := datosdb.Buscar(tlbco, 'clavecta', 'tcomprob', 'tipomov', xclavecta, xtcomprob, xtipomov);
end;

procedure  TTLBancos.getDatos(xclavecta, xtcomprob, xtipomov: string);
// Objetivo...: Retornar/Iniciar Atributos
begin
  if Buscar(xclavecta, xtcomprob, xtipomov) then
    begin
      clavecta   := tlbco.FieldByName('clavecta').AsString;
      tcomprob   := tlbco.FieldByName('tcomprob').AsString;
      tipomov    := tlbco.FieldByName('tipomov').AsString;
      fecha      := utiles.sFormatoFecha(tlbco.FieldByName('fecha').AsString);
      fecobro    := utiles.sFormatoFecha(tlbco.FieldByName('fecobro').AsString);
      pagado     := tlbco.FieldByName('pagado').AsString;
      concepto   := tlbco.FieldByName('concepto').AsString;
      monto      := tlbco.FieldByName('monto').AsFloat;
      tipoper    := tlbco.FieldByName('tipoper').AsString;
      tipocheque := tlbco.FieldByName('tipocheque').AsInteger;
      entbcos.getDatos(tlbco.FieldByName('clavecta').AsString);
      codbanco := entbcos.Descrip;
    end
   else
    begin
      codbanco := ''; tcomprob := ''; tipomov := ''; fecha := ''; fecobro := ''; pagado := ''; concepto := ''; monto := 0;  tipoper := ''; tipocheque := 10;
    end;
end;

function TTLBancos.verificarMovimiento(xclavecta: string): boolean;
// Objetivo...: verificar la existencia de algun movimiento
begin
  Result := False;
  tlbco.First;
  while not tlbco.EOF do
    begin
      if tlbco.FieldByName('clavecta').AsString = xclavecta then
        begin
          Result := True;
          Break;
        end;
      tlbco.Next;
    end;
end;

function  TTLBancos.setCuentas: TQuery;
// Ojetivo...: retornar un set con las cuentas definidas
begin
  Result := datosdb.tranSQL('SELECT clavecta, banco FROM cctbcos ORDER BY banco');
end;

procedure TTLBancos.BuscarPorCuenta(xexp: string);
// Objetivo...: Buscar por codigo
begin
  if tabla.IndexFieldNames <> 'clavecta' then tabla.IndexFieldNames := 'clavecta';
  tabla.FindNearest([xexp]);
end;

procedure TTLBancos.BuscarPorDescrip(xexp: string);
begin
  if tabla.IndexName <> 'Banco' then tabla.IndexName := 'Banco';
  tabla.FindNearest([xexp]);
end;

procedure TTLBancos.List_linea(salida: char);
// Objetivo...: Listar una Línea
var
  pr: string;
begin
  entbcos.getDatos(tabla.FieldByName('codbanco').AsString);
  if tabla.FieldByName('clavecta').AsString <> idanterior then pr := entbcos.Descrip else pr := ' ';
  List.Linea(0, 0, tabla.FieldByName('clavecta').AsString, 1, 'Courier New, normal, 8', salida, 'N');
  List.Linea(17, list.lineactual, pr, 2, 'Courier New, normal, 8', salida, 'N');
  List.Linea(57, List.lineactual, tabla.FieldByName('obs').AsString, 3, 'Courier New, normal, 8', salida, 'N');
  List.Linea(90, List.lineactual, utiles.sFormatoFecha(tabla.FieldByName('fealta').AsString), 4, 'Courier New, normal, 8', salida, 'S');
  idanterior := tabla.FieldByName('clavecta').AsString;
end;

procedure TTLBancos.ListarCtasDef(orden, iniciar, finalizar, ent_excl: string; salida: char);
// Objetivo...: Listar Cuentas Bancarias Definidas
begin
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, 'Listado de Cuentas Corrientes Bancarias', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Cuenta', 1, 'Courier New, cursiva, 8');
  List.Titulo(17, list.lineactual, 'Cuenta', 2, 'Courier New, cursiva, 8');
  List.Titulo(57, List.lineactual, 'Observaciones', 3, 'Courier New, cursiva, 8');
  List.Titulo(90, List.lineactual, 'Fe. Alta', 4, 'Courier New, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  tabla.First;
  while not tabla.EOF do
    begin
      // Ordenado por Código
      if (ent_excl = 'E') and (orden = 'C') then
        if (tabla.FieldByName('clavecta').AsString >= iniciar) and (tabla.FieldByName('clavecta').AsString <= finalizar) then List_linea(salida);
      if (ent_excl = 'X') and (orden = 'C') then
        if (tabla.FieldByName('clavecta').AsString < iniciar) or (tabla.FieldByName('clavecta').AsString > finalizar) then List_linea(salida);

      tabla.Next;
    end;
    List.FinList;

    tabla.First;
end;

procedure TTLBancos.Listar(xclavecta, xdf, xhf: string; salida, tls, tipofecha: char);
// Objetivo...: Emitir Libro de Bancos
var
  l: boolean;
begin
  IniciarInforme(salida);

  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Libro de Bancos', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Fecha   NºChe./Dep.', 1, 'Arial, cursiva, 8');
  List.Titulo(20, list.Lineactual, 'Concepto', 2, 'Arial, cursiva, 8');
  List.Titulo(59, list.Lineactual, 'Depósitos', 3, 'Arial, cursiva, 8');
  List.Titulo(74, list.Lineactual, 'Cheques', 4, 'Arial, cursiva, 8');
  List.Titulo(90, list.Lineactual, 'Saldo', 5, 'Arial, cursiva, 8');

  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  tlbco.IndexName := 'Listado';
  tlbco.First; saldo := 0; totdebe := 0; tothaber := 0;
  while not tlbco.EOF do
    begin
      l := False;
      if tls = 'L' then l := True;    // Libro ...
      if tls = 'D' then
        if tlbco.FieldByName('tipoper').AsString = 'DE' then l := True;    // Libro ...
      if tls = 'C' then
        if tlbco.FieldByName('tipoper').AsString = 'CH' then l := True;    // Libro ...

      if tlbco.FieldByName('clavecta').AsString = xclavecta then
       if l then    // Si la instacia cumple con el Filtro especificado
        begin
          if tlbco.FieldByName('tipomov').AsString = '1' then saldo := saldo + tlbco.FieldByName('monto').AsFloat else saldo := saldo - tlbco.FieldByName('monto').AsFloat;
          if tipofecha = 'O' then  // Fecha de Operación
            if (tlbco.FieldByName('fecha').AsString >= utiles.sExprFecha(xdf)) and (tlbco.FieldByName('fecha').AsString <= utiles.sExprFecha(xhf)) then LineaLibro(salida);
          if tipofecha = 'P' then  // Fecha de Vencimiento/Cobro
            if (tlbco.FieldByName('fecobro').AsString >= utiles.sExprFecha(xdf)) and (tlbco.FieldByName('fecobro').AsString <= utiles.sExprFecha(xhf)) then LineaLibro(salida);
        end;
      tlbco.Next;
     end;

  subtotal(salida);
  tlbco.IndexFieldNames := 'Clavecta;Tcomprob;Tipomov';

  List.FinList;
end;

procedure TTLBancos.LineaLibro(salida: char);
// Objetivo...: Listar Línea de detalle
begin
  list.Linea(0, 0, utiles.sFormatoFecha(tlbco.FieldByName('fecha').AsString) + '  ' + tlbco.FieldByName('tcomprob').AsString + '   ' + tlbco.FieldByName('concepto').AsString, 1, 'Arial, normal, 8', salida, 'N');
  if tlbco.FieldByName('tipomov').AsString = '1' then
    begin
      list.importe(67, list.lineactual, '', tlbco.FieldByName('monto').AsFloat, 2, 'Arial, norlam, 8');
      totdebe := totdebe + tlbco.FieldByName('monto').AsFloat;
    end;
  if tlbco.FieldByName('tipomov').AsString = '2' then
    begin
      list.importe(79, list.lineactual, '', tlbco.FieldByName('monto').AsFloat, 2, 'Arial, norlam, 8');
      tothaber := tothaber + tlbco.FieldByName('monto').AsFloat;
    end;
  list.importe(95, list.lineactual, '', saldo, 3, 'Arial, norlam, 8');
  list.Linea(95, list.lineactual, ' ', 4, 'Arial, normal, 8', salida, 'S');
end;

procedure TTLBancos.subtotal(salida: char);
// Objetivo...: Listar el subtotal del libro
begin
  List.CompletarPagina;
  List.Linea(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
  List.Linea(0, 0, 'Subtotales ............: ', 1, 'Arial, normal, 8', salida, 'S');
  list.importe(67, list.lineactual, '', totdebe, 2, 'Arial, normal, 8');
  list.importe(79, list.lineactual, '', tothaber, 3, 'Arial, normal, 8');
  list.importe(95, list.lineactual, '', saldo, 4, 'Arial, norlam, 8');
end;

function TTLBancos.setTransacciones: TQuery;
// Objetivo...: devolver un set de registros con las operaciones bancarias
begin
  Result := datosdb.tranSQL('SELECT * FROM bancos ORDER BY fecha');
end;

procedure TTLBancos.refrescar;
// Objetivo...: refrescar datos en tabla de persistencia
begin
  datosdb.refrescar(tabla);
  datosdb.refrescar(tlbco);
end;

procedure TTLBancos.vaciarBuffer;
// Objetivo...: vaciar el buffer de datos de las tabla de persistencia
begin
  datosdb.vaciarBuffer(tabla);
  datosdb.vaciarBuffer(tlbco);
end;

procedure TTLBancos.conectar;
// Objetivo...: conectar tabla de persistencia
begin
  if conexiones = 0 then Begin
    entbcos.conectar;
    if not tabla.Active then tabla.Open;
    tabla.FieldByName('clavecta').DisplayLabel := 'Nº Cuenta'; tabla.FieldByName('obs').DisplayLabel := 'Observaciones';
    tabla.FieldByName('clave').Visible := False; tabla.FieldByName('fealta').Visible := False; tabla.FieldByName('sel').Visible := False; tabla.FieldByName('codbanco').Visible := False;
    if not tlbco.Active then tlbco.Open;
  end;
  Inc(conexiones);
end;

procedure TTLBancos.desconectar;
// Objetivo...: desconectar tabla de persistencia
begin
  if conexiones > 0 then Dec(conexiones);
  if conexiones = 0 then Begin
    entbcos.desconectar;
    datosdb.closeDB(tlbco);
    datosdb.closeDB(tabla);
  end;
end;

{===============================================================================}

function banco: TTLBancos;
begin
  if xbanco = nil then
    xbanco := TTLBancos.Create('', '', '', '', '', '', '', '', 0, 0);
  Result := xbanco;
end;

{===============================================================================}

initialization

finalization
  xbanco.Free;

end.
