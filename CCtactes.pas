unit CCtactes;

interface

uses CLibCont, CComprob, SysUtils, DB, DBTables, CUtiles, CIDBFM, CBDT, CListar;

type

TTCtacte = class(TTLibrosCont)
  clavecta, idtitular, clave, titular, direcciontitular, idc, tipo, sucursal, numero, tm, fecha, fealta, obs, concepto, items: string;
  importe, entrega: real;
  intervalorefresco: integer;
  habilitado, ModoHistorico: Boolean;
  tabla1, tabla2, tabla3, tablapsw: TTable;    // tabla1 - Cuentas / tabla2 - Movimientos (Fact, recibos) / tabla3 - Registro de Facturas
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  function    getObs(xid, xcl: string): string;
  function    getTotdebe: real;
  function    getTothaber: real;

  procedure   Grabar(xclavecta, xidtitular, xclave, xnombre, xfealta, xobs: string); overload;
  procedure   Grabar(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, xfecha, xtm, xconcepto: string; ximporte: real); overload;
  procedure   Borrar(xclavecta, xidtitular: string); overload;
  procedure   Borrar(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero: string); overload;
  function    Buscar(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, xitems: string): boolean; overload;
  function    Buscar(xclavecta, xidtitular: string): boolean; overload;
  function    BuscarFR(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero: string): boolean;
  procedure   BuscarNombre(xnombre: string);
  procedure   FiltrarCtasctes(xtitular: string);
  procedure   QuitarFiltro;
  procedure   getDatos(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, xitems: string);
  procedure   getMovimiento(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, xitems: string);
  procedure   getDatosDef(xclavecta, xidtitular: string);
  procedure   getDatosDefHist(xclavecta, xidtitular: string);
  function    getPlan(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero: string): TQuery;
  procedure   getDatosFactReci(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero: string);
  function    verificarTitular(idtitular: string): boolean;
  function    verificarMovimientoFicha(xidtitular, xclavecta: string): boolean;
  procedure   AnularFichasVacias;
  procedure   totales(xidtitular, xclavecta: string); overload;
  procedure   totales(xidtitular: string); overload;
  procedure   habilitarSel;
  procedure   verificarCancelacion(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, xestado: string);
  function    setCtasCtes: TQuery; virtual;
  function    setFacturas: TQuery; overload;
  function    setFacturas(xidtitular: String): TQuery; overload;
  function    setCtasCtesHistorico: TQuery;
  function    setFacturasHistorico: TQuery; overload;
  function    setFacturasHistorico(xidtitular: String): TQuery; overload;
  function    verificarEstadoCuenta(xidcompr, xtipo, xsucursal, xnumero: string): boolean;
  function    NuevaFicha(xidtitular: string): string;
  procedure   GenerarHistorico(xfecha: string);
  procedure   Transferir_al_Historico(xidc, xtipo, xsucursal, xnumero, xidtitular, xclavecta, xfecha: string);
  function    tranferirHistorico: boolean;
  procedure   EstadoHistorico(estado: shortint);
  procedure   getDatosFactHistorico(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero: string);
  procedure   transferirHistorico_Original(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero: string);
  procedure   PresentarListado;
  procedure   BuscarPorCodigo(xexpr: string);

  procedure   refrescar;
  procedure   vaciarBuffer;
 protected
  { Declaraciones Protegidas }
  htabla1, htabla2, htabla3: TTable;   // Set de tablas para el manejo de históricos
  iss, existenMov, listiniciado: boolean;
  idant, clant, indice: string;
  saldoanter, td, th, total, recar: real;
  tipototal: string; tipodispositivo: char;
  procedure   TransferirDatos(existe_instancia: boolean);
  procedure   IniciarTablasObj; virtual;
  procedure   CerrarTablasObj;
  procedure   totalPS(salida: char); virtual;
 private
  { Declaraciones Privadas }
  procedure   TransferirDatosHistoricos(r: TQuery; xfecha: string);
  procedure   TransferirDatosHistOriginal(r: TQuery);
  procedure   ExtraerMovimientosHistorico(xidc, xtipo, xsucursal, xnumero, xidtitular, xclavecta, xfecha: string);
end;

function ctacte: TTCtacte;

implementation

var
  xctacte: TTCtacte = nil;

constructor TTCtacte.Create;
begin
  inherited Create;
  tablapsw := TTable.Create(nil);
  tablapsw.TableName := 'Habpass';
  intervalorefresco := datosdb.intervalorefresco;
end;

destructor TTCtacte.Destroy;
begin
  inherited Destroy;
end;

function TTCtacte.getObs(xid, xcl: string): string;
var
  ot: boolean;
begin
  ot := tabla1.Active;
  if not ot then tabla1.Open;
  getDatosDef(xcl, xid);
  Result := obs;
  if ot then datosdb.closeDB(tabla1);
end;

function TTCtacte.BuscarFR(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero: string): boolean;
// Objetivo...: Buscar una factura o recibo
var
  i: string;
begin
  if tabla3.Filtered then tabla3.Filtered := False;
  i := tabla3.IndexFieldNames;
  tabla3.IndexFieldNames := 'idtitular;clavecta;idcompr;tipo;sucursal;numero';
  Result := datosdb.Buscar(tabla3, 'idtitular', 'clavecta', 'idcompr', 'tipo', 'sucursal', 'numero', xidtitular, xclavecta, xidc, xtipo, xsucursal, xnumero);
  tabla3.IndexFieldNames := i;
end;

procedure TTCtacte.Grabar(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, xfecha, xtm, xconcepto: string; ximporte: real);
// Objetivo...: Grabar una Operación de cuenta corriente simple, recibo o factura
begin
  if BuscarFR(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero) then tabla3.Edit else tabla3.Append;
  tabla3.FieldByName('clavecta').AsString  := xclavecta;
  tabla3.FieldByName('idtitular').AsString := xidtitular;
  tabla3.FieldByName('idcompr').AsString   := xidc;
  tabla3.FieldByName('tipo').AsString      := xtipo;
  tabla3.FieldByName('sucursal').AsString  := xsucursal;
  tabla3.FieldByName('numero').AsString    := xnumero;
  tabla3.FieldByName('DC').AsString        := xtm;
  tabla3.FieldByName('fecha').AsString     := utiles.sExprFecha2000(xfecha);
  tabla3.FieldByName('importe').AsFloat    := ximporte;
  tabla3.FieldByName('concepto').AsString  := xconcepto;
  try
    tabla3.Post;
  except
    tabla3.Cancel;
  end;
end;

procedure TTCtacte.getMovimiento(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, xitems: string);
// Objetivo...: Retornar los datos de un movimiento dado
begin
  if Buscar(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, xitems) then TransferirDatos(True) else TransferirDatos(False);
end;

procedure TTCtacte.getDatosFactReci(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero: string);
// Objetivo...: Retornar los datos de la Operación seleccionada
begin
  if BuscarFR(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero) then Begin
    importe  := tabla3.FieldByName('importe').AsFloat;
    concepto := tabla3.FieldByName('concepto').AsString;
    fecha    := utiles.sFormatoFecha(tabla3.FieldByName('fecha').AsString);
  end else Begin
    importe := 0; concepto := ''; fecha := '';
  end;
end;

procedure TTCtacte.BuscarNombre(xnombre: string);
// Objetivo...: Buscar Nombre por aproximación
begin
  tabla1.IndexFieldNames := 'Nombre';
  tabla1.FindNearest([xnombre]);
end;

function TTCtacte.Buscar(xclavecta, xidtitular: string): boolean;
// Objetivo...: Grabar la Definición de una Cuenta Corriente
begin
  if tabla1.IndexFieldNames <> 'Idtitular;Clavecta' then tabla1.IndexFieldNames := 'Idtitular;Clavecta';
  Result := datosdb.Buscar(tabla1, 'clavecta', 'idtitular', xclavecta, xidtitular);
end;

procedure TTCtacte.Borrar(xclavecta, xidtitular: string);
// Objetivo...: Eliminar un Objeto (definición de cuenta corriente)
begin
  if Buscar(xclavecta, xidtitular) then Begin
    tabla1.Delete; tabla1.Refresh;
    getDatosDef(tabla1.FieldByName('clavecta').AsString, tabla1.FieldByName('idtitular').AsString);  // Fijamos los Atributos Siguientes al Objeto Borrado
  end;
end;

procedure TTCtacte.Grabar(xclavecta, xidtitular, xclave, xnombre, xfealta, xobs: string);
// Objetivo...: Grabar la Definición de una Cuenta Corriente]
begin
  if Buscar(xclavecta, xidtitular) then tabla1.Edit else tabla1.Append;
  tabla1.FieldByName('clavecta').AsString  := xclavecta;
  tabla1.FieldByName('idtitular').AsString := xidtitular;
  tabla1.FieldByName('nombre').AsString    := xnombre;
  tabla1.FieldByName('clave').AsString     := xclave;
  tabla1.FieldByName('fealta').AsString    := utiles.sExprFecha2000(xfealta);
  tabla1.FieldByName('obs').AsString       := xobs;
  try
    tabla1.Post
  except
    tabla1.Cancel
  end;
end;

procedure TTCtacte.Borrar(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero: string);
// Objetivo...: Eliminar un comprobante - detalle y relaciones
begin
  if BuscarFR(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero) then Begin
    tabla3.Delete; tabla3.Refresh;
    TransferirDatos(true);
  end;
end;

function TTCtacte.Buscar(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, xitems: string): boolean;
// Objetivo...: Buscar un Movimiento en la tabla donde se registran los planes y cobros
begin
  if tabla3.Filtered then tabla3.Filtered := False;
  Result := datosdb.Buscar(tabla3, 'idtitular', 'clavecta', 'idcompr', 'tipo', 'sucursal', 'numero', 'items', xidtitular, xclavecta, xidc, xtipo, xsucursal, xnumero, xitems);
end;

procedure  TTCtacte.getDatosDef(xclavecta, xidtitular: string);
// Objetivo...: Retornar/Iniciar Atributos
begin
  if Buscar(xclavecta, xidtitular) then Begin
    fealta  := utiles.sFormatoFecha(tabla1.FieldByName('fealta').AsString);
    clave   := tabla1.FieldByName('clave').AsString;
    titular := tabla1.FieldByName('nombre').AsString;
    obs     := tabla1.FieldByName('obs').AsString;
  end else begin
    fealta := ''; obs := ''; clave := ''; titular := '';
  end;
end;

procedure  TTCtacte.getDatos(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, xitems: string);
// Objetivo...: Retornar/Iniciar Atributos
begin
  if Buscar(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, xitems) then TransferirDatos(True) else TransferirDatos(False);
end;

procedure TTCtacte.TransferirDatos(existe_instancia: boolean);
// Objetivo...: Transferir los atributos o inicializarlos
begin
  if existe_instancia then Begin
    idc      := tabla3.FieldByName('idcompr').AsString;
    tipo     := tabla3.FieldByName('tipo').AsString;
    items    := tabla3.FieldByName('items').AsString;
    sucursal := tabla3.FieldByName('sucursal').AsString;
    numero   := tabla3.FieldByName('numero').AsString;
    idtitular:= tabla3.FieldByName('idtitular').AsString;
    clavecta := tabla3.FieldByName('clavecta').AsString;
    fecha    := utiles.sFormatoFecha(tabla3.FieldByName('fecha').AsString);
    tm       := tabla3.FieldByName('DC').AsString;
    importe  := tabla3.FieldByName('importe').AsFloat;
    entrega  := tabla3.FieldByName('entrega').AsFloat;
    concepto := tabla3.FieldByName('concepto').AsString;
  end else Begin
    idtitular := ''; clavecta := ''; items := ''; fecha := ''; concepto := ''; importe := 0; entrega := 0; tm := '';
  end;
end;

procedure TTCtacte.FiltrarCtasctes(xtitular: string);
// Objetivo...: Filtrar las Cuentas Corrientes Disponibles para un titular
begin
  datosdb.Filtrar(tabla1, 'Idtitular = ' + '"' + xtitular + '"');
end;

procedure TTCtacte.QuitarFiltro;
// Objetivo...: Filtrar las Cuentas Corrientes Disponibles para un titular
begin
  tabla1.Filtered := False;
end;

function TTCtacte.getPlan(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero: string): TQuery;
// Objetivo...: Devolver un Set de las Cuentas Corrientes Disponibles para un titular
begin
  Result := datosdb.tranSQL('SELECT * FROM ' + tabla3.TableName + ' WHERE clavecta = ' + '''' + xclavecta + '''' + '  and idtitular = ' + '''' + xidtitular + '''' + ' and idcompr = ' + '''' + xidc + '''' + ' and sucursal = ' + '''' + xsucursal + '''' + ' and numero = ' + '''' + xnumero + '''' +
                            ' and sucursal = ' + '''' + xsucursal + '''' + ' and numero = ' + '''' + xnumero + '''');
end;

function TTCtacte.verificarTitular(idtitular: string): boolean;
// Objetivo...: Verificar si existe el titular para una cuenta dada
begin
  Result := False;
  if not tabla1.Active then tabla1.Open;
  tabla1.First;
  while not tabla1.EOF do Begin
    if tabla1.FieldByName('Idtitular').AsString = idtitular then Begin
      Result := True;
      Break;
    end;
    tabla1.Next;
  end;
end;

procedure TTCtacte.totales(xidtitular, xclavecta: string);
// Objetivo...: subtotalizar debe y haber por titular/cuenta
begin
  totdebe := 0; tothaber := 0;
  tabla3.First;
  while not tabla3.EOF do Begin
    if (tabla3.FieldByName('idtitular').AsString = xidtitular) and (tabla3.FieldByName('clavecta').AsString = xclavecta) then Begin
      if ((tabla3.FieldByName('DC').AsString = '1') and (tabla3.FieldByName('items').AsString <= '000')) then totdebe  := totdebe + tabla3.FieldByName('importe').AsFloat;
      if tabla3.FieldByName('DC').AsString = '2' then tothaber := tothaber + tabla3.FieldByName('importe').AsFloat;
    end;
    tabla3.Next;
  end;
end;

procedure TTCtacte.totales(xidtitular: string);
// Objetivo...: subtotalizar debe y haber por titular
begin
  totdebe := 0; tothaber := 0;
  tabla3.First;
  while not tabla3.EOF do
    begin
      if tabla3.FieldByName('idtitular').AsString = xidtitular then
        begin
          if (tabla3.FieldByName('DC').AsString = '1') and (tabla3.FieldByName('items').AsString > '-1') then totdebe  := totdebe + tabla3.FieldByName('importe').AsFloat;
          if tabla3.FieldByName('DC').AsString = '2' then tothaber := tothaber + tabla3.FieldByName('importe').AsFloat;
        end;
      tabla3.Next;
    end;
end;

function TTCtacte.getTotdebe: real;
begin
  Result := totdebe;
end;

function TTCtacte.getTothaber: real;
begin
  Result := tothaber;
end;

procedure TTCtacte.habilitarSel;
begin
  tabla1.FieldByName('sel').Visible := True;
end;

procedure TTCtacte.verificarCancelacion(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, xestado: string);
// Objetivo...: Cancelar/Habilitar Factura
begin
  if Buscar(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, '-1') then Begin
    tabla3.Edit;
    tabla3.FieldByName('estado').AsString := xestado;
    try
      tabla3.Post
    except
      tabla3.Cancel
    end;
  end;
end;

function TTCtacte.setCtasCtes: TQuery;
// Objetivo...: Devolver un Set con las Cuentas Corrientes
begin
  Result := datosdb.tranSQL('SELECT * FROM ' + tabla1.TableName + ' ORDER BY nombre, clavecta');
end;

function TTCtacte.setFacturas: TQuery;
// Objetivo...: Devolver un Set con las Facturas Reg. en Cuentas Corrientes
begin
  Result := datosdb.tranSQL('SELECT * FROM ' + tabla3.TableName + ' WHERE items = ' + '"' + '-1' + '"');
end;

function TTCtacte.setFacturas(xidtitular: String): TQuery;
// Objetivo...: Devolver un Set con las Facturas Reg. en Cuentas Corrientes
begin
  Result := datosdb.tranSQL('SELECT * FROM ' + tabla3.TableName + ' WHERE items = ' + '"' + '-1' + '"' + ' AND idtitular = ' + '"' + xidtitular + '"' + ' ORDER BY fecha');
end;

{*******************************************************************************}

procedure TTCtacte.IniciarTablasObj;
// Objetivo...: Instanciamos las tablas
begin
  htabla1.Open; htabla2.Open; htabla3.Open;
end;

procedure TTCtacte.CerrarTablasObj;
// Objetivo...: Desconectamos las tablas
begin
  datosdb.closeDB(htabla1); datosdb.closeDB(htabla2); datosdb.closeDB(htabla3);
end;

{ Tratamiento de históricos }
function TTCtacte.setCtasCtesHistorico: TQuery;
// Objetivo...: Devolver un Set con las Cuentas Corrientes
begin
  IniciarTablasObj;
  Result := datosdb.tranSQL(dbs.BDhistorico, 'SELECT * FROM ' + htabla1.TableName + ' ORDER BY nombre');
  datosdb.closeDB(htabla1); datosdb.closeDB(htabla2); datosdb.closeDB(htabla3);
end;

function TTCtacte.setFacturasHistorico: TQuery;
// Objetivo...: Devolver un Set con las Facturas Reg. en Cuentas Corrientes desde el historico
begin
  IniciarTablasObj;
  Result := datosdb.tranSQL(dbs.BDhistorico, 'SELECT * FROM ' + htabla3.TableName + ' WHERE items = ' + '"' + '-1' + '"');
  datosdb.closeDB(htabla1); datosdb.closeDB(htabla2); datosdb.closeDB(htabla3);
end;

function TTCtacte.setFacturasHistorico(xidtitular: String): TQuery;
// Objetivo...: Devolver un Set con las Facturas Reg. en Cuentas Corrientes desde el historico
begin
  IniciarTablasObj;
  Result := datosdb.tranSQL(dbs.bdhistorico, 'SELECT * FROM ' + htabla3.TableName + ' WHERE items = ' + '"' + '-1' + '"' + ' AND idtitular = ' + '"' + xidtitular + '"' + ' ORDER BY fecha');
  datosdb.closeDB(htabla1); datosdb.closeDB(htabla2); datosdb.closeDB(htabla3);
end;

function TTCtacte.verificarEstadoCuenta(xidcompr, xtipo, xsucursal, xnumero: string): boolean;
// Objetivo...: verificar si una Factura tiene Recibos Imputados
begin
  Result := False;
  tabla3.First;
  while not tabla3.EOF do Begin
    if (tabla3.FieldByName('XC').AsString = xidcompr) and (tabla3.FieldByName('XT').AsString = xtipo) and (tabla3.FieldByName('XS').AsString = xsucursal) and (tabla3.FieldByName('XN').AsString = xnumero) and (tabla3.FieldByName('items').AsString >= '001') then Begin
      Result := True;
      Break;
    end;
    tabla3.Next;
  end;
end;

function TTCtacte.verificarMovimientoFicha(xidtitular, xclavecta: string): boolean;
// Objetivo...: Verificar la ficha de la cuenta dada tiene movimientos
var
  r: TQuery;
begin
  r := datosdb.tranSQL('SELECT Idtitular, Clavecta FROM ' + tabla2.TableName + ' WHERE ' + tabla2.TableName + '.Idtitular = ' + '"' + xidtitular + '"' + ' AND ' + tabla2.TableName + '.Clavecta = ' + '"' + xclavecta + '"');
  r.Open;
  if r.RecordCount = 0 then Result := False else Result := True;
  r.Close; r.Free;
end;

procedure TTCtacte.AnularFichasVacias;
// Objetivo...: Borrar todas aquellas fichas que no tengan movimientos
var
  r: TQuery;
begin
  r := setCtasCtes;
  r.Open; r.First;
  while not r.EOF do Begin
    if not verificarMovimientoFicha(r.FieldByName('idtitular').AsString, r.FieldByName('clavecta').AsString) then
      if Buscar(r.FieldByName('clavecta').AsString, r.FieldByName('idtitular').AsString) then Begin
        tabla1.Delete;
        tabla1.Refresh;
      end;
    r.Next;
  end;
  r.Close; r.Free;
end;

function TTCtacte.NuevaFicha(xidtitular: string): string;
// Objetivo...: Definir una Ficha Nueva
var
  i: integer; f: boolean;
  c: string;
begin
  i := 0; f := false; c := '';
  while not f do Begin
    c := utiles.sLlenarIzquierda(IntToStr(i), 3, '0');
    if not (Buscar(c, xidtitular)) {or not (verificarMovimientoFicha(xidtitular, c))} then Begin
      Result := c;
      Break;
    end else
      Inc(i);
  end;
end;

procedure TTCtacte.GenerarHistorico(xfecha: string);
// Objetivo...: Generar un historico con las Fichas de c/c canceladas
var
  q: TQuery;
begin
  // Extraemos las c/c saldadas
  IniciarTablasObj;

  q := datosdb.tranSQL('SELECT * FROM ' + tabla3.TableName + ' WHERE estado = ' + '''' + 'P' + '''' + ' AND fecha < ' + '"' + utiles.sExprFecha2000(xfecha) + '"' + ' AND XN = ' + '"' + 'FACT.ORI' + '"');
  q.Open; q.First;
  while not q.EOF do Begin  // Transferencia de datos - facturas y recibo
    ExtraerMovimientosHistorico(q.FieldByName('idcompr').AsString, q.FieldByName('tipo').AsString, q.FieldByName('sucursal').AsString, q.FieldByName('numero').AsString, q.FieldByName('idtitular').AsString, q.FieldByName('clavecta').AsString, xfecha);
    q.Next;
  end;
  q.Close; q.Free;

  datosdb.closeDB(htabla1); datosdb.closeDB(htabla2); datosdb.closeDB(htabla3);
end;

procedure TTCtacte.Transferir_al_Historico(xidc, xtipo, xsucursal, xnumero, xidtitular, xclavecta, xfecha: string);
// Objetivo...: Transferir al historico una ficha cancelada
begin
  IniciarTablasObj;
  ExtraerMovimientosHistorico(xidc, xtipo, xsucursal, xnumero, xidtitular, xclavecta, xfecha);
  CerrarTablasObj;
end;

procedure TTCtacte.ExtraerMovimientosHistorico(xidc, xtipo, xsucursal, xnumero, xidtitular, xclavecta, xfecha: string);
// Objetivo...: Extraer los movimientos a transferir desde la c/c
var
  t: TQuery;
begin
  // Paso 1 - Transferimos Fact. y Entrega inicial
  t := datosdb.tranSQL('SELECT * FROM ' + tabla3.TableName + ' WHERE idcompr = ' + '"' + xidc + '"' + ' AND tipo = ' + '"' + xtipo + '"' +
                                                             ' AND sucursal = ' + '"' + xsucursal + '"' + ' AND numero = ' + '"' + xnumero + '"');
  TransferirDatosHistoricos(t, xfecha);
  t.Close; t.Free;
  // Paso 2 - Transferimos los recibos
  t := datosdb.tranSQL('SELECT * FROM ' + tabla3.TableName + ' WHERE XC = ' + '"' + xidc + '"' + ' AND XT = ' + '"' + xtipo + '"' +
                                                             ' AND XS = ' + '"' + xsucursal + '"' + ' AND XN = ' + '"' + xnumero + '"');
  TransferirDatosHistoricos(t, xfecha);
  t.Close; t.Free;
  // Transferimos la definición de la Ficha
  getDatosDef(xclavecta, xidtitular);
  if datosdb.Buscar(htabla1, 'idtitular', 'clavecta', xidtitular, xclavecta) then htabla1.Edit else htabla1.Append;
  htabla1.FieldByName('idtitular').AsString := xidtitular;
  htabla1.FieldByName('clavecta').AsString  := xclavecta;
  htabla1.FieldByName('fechaid').AsString   := utiles.sExprFecha2000(xfecha);
  htabla1.FieldByName('nombre').AsString    := titular;
  htabla1.FieldByName('clave').AsString     := clave;
  htabla1.FieldByName('obs').AsString       := obs;
  htabla1.FieldByName('fealta').AsString    := utiles.sExprFecha2000(fealta);
  try
    htabla1.Post
  except
    htabla1.Cancel
  end;
  // Transferimos la cabecera de la Factura
  if datosdb.Buscar(tabla2, 'idcompr', 'tipo', 'sucursal', 'numero', xidc, xtipo, xsucursal, xnumero) then Begin
    if datosdb.Buscar(htabla2, 'idcompr', 'tipo', 'sucursal', 'numero', xidc, xtipo, xsucursal, xnumero) then htabla2.Edit else htabla2.Append;
    htabla2.FieldByName('idcompr').AsString := tabla2.FieldByName('idcompr').AsString;
    htabla2.FieldByName('tipo').AsString := tabla2.FieldByName('tipo').AsString;
    htabla2.FieldByName('sucursal').AsString := tabla2.FieldByName('sucursal').AsString;
    htabla2.FieldByName('numero').AsString := tabla2.FieldByName('numero').AsString;
    htabla2.FieldByName('fechaid').AsString := utiles.sExprFecha2000(xfecha);
    htabla2.FieldByName('idtitular').AsString := tabla2.FieldByName('idtitular').AsString;
    htabla2.FieldByName('clavecta').AsString := tabla2.FieldByName('clavecta').AsString;
    htabla2.FieldByName('dc').AsString := tabla2.FieldByName('dc').AsString;
    htabla2.FieldByName('fecha').AsString := tabla2.FieldByName('fecha').AsString;
    htabla2.FieldByName('importe').AsFloat := tabla2.FieldByName('importe').AsFloat;
    htabla2.FieldByName('entrega').AsFloat := tabla2.FieldByName('entrega').AsFloat;
    htabla2.FieldByName('impent').AsFloat := tabla2.FieldByName('impent').AsFloat;
    try
      htabla2.Post
    except
      htabla2.Cancel
    end;
  end;
end;

procedure TTCtacte.TransferirDatosHistoricos(r: TQuery; xfecha: string);
// Objetivo...: transferir datos historicos desde la Query que obtuvo los resultados a la tabla de historicos
begin
  r.Open; r.First;
  while not r.EOF do Begin  // Transferencia de datos - facturas y recibo
    if datosdb.Buscar(htabla3, 'idtitular', 'clavecta', 'idcompr', 'tipo', 'sucursal', 'numero', 'items', r.FieldByName('idtitular').AsString, r.FieldByName('clavecta').AsString, r.FieldByName('idcompr').AsString, r.FieldByName('tipo').AsString, r.FieldByName('sucursal').AsString, r.FieldByName('numero').AsString, r.FieldByName('items').AsString) then htabla3.Edit else htabla3.Append;
    htabla3.FieldByName('idtitular').AsString := r.FieldByName('idtitular').AsString;
    htabla3.FieldByName('clavecta').AsString := r.FieldByName('clavecta').AsString;
    htabla3.FieldByName('idcompr').AsString := r.FieldByName('idcompr').AsString;
    htabla3.FieldByName('tipo').AsString := r.FieldByName('tipo').AsString;
    htabla3.FieldByName('sucursal').AsString := r.FieldByName('sucursal').AsString;
    htabla3.FieldByName('numero').AsString := r.FieldByName('numero').AsString;
    htabla3.FieldByName('items').AsString := r.FieldByName('items').AsString;
    htabla3.FieldByName('fechaid').AsString := utiles.sExprFecha2000(xfecha);
    htabla3.FieldByName('concepto').AsString := r.FieldByName('concepto').AsString;
    htabla3.FieldByName('fecha').AsString := r.FieldByName('fecha').AsString;
    htabla3.FieldByName('DC').AsString := r.FieldByName('DC').AsString;
    htabla3.FieldByName('importe').AsFloat := r.FieldByName('importe').AsFloat;
    htabla3.FieldByName('recargo').AsFloat := r.FieldByName('recargo').AsFloat;
    htabla3.FieldByName('entrega').AsFloat := r.FieldByName('entrega').AsFloat;
    htabla3.FieldByName('estado').AsString := r.FieldByName('estado').AsString;
    htabla3.FieldByName('XC').AsString := r.FieldByName('XC').AsString;
    htabla3.FieldByName('XT').AsString := r.FieldByName('XT').AsString;
    htabla3.FieldByName('XS').AsString := r.FieldByName('XS').AsString;
    htabla3.FieldByName('XN').AsString := r.FieldByName('XN').AsString;
    try
      htabla3.Post
    except
      htabla3.Cancel
    end;
    r.Next;
   end;
   r.Close;
end;

procedure TTCtacte.transferirHistorico_Original(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero: string);
// Objetivo...: Transferir una factura desde el historico al registro original
var
  t: TQuery;
begin
  IniciarTablasObj;
  // Paso 1 - Transferimos Fact. y Entrega inicial
  t := datosdb.tranSQL(htabla3.DatabaseName, 'SELECT * FROM ' + htabla3.TableName + ' WHERE idcompr = ' + '"' + xidc + '"' + ' AND tipo = ' + '"' + xtipo + '"' +
                                                                 ' AND sucursal = ' + '"' + xsucursal + '"' + ' AND numero = ' + '"' + xnumero + '"');
  TransferirDatosHistOriginal(t);
  t.Close; t.Free;
  // Paso 2 - Transferimos los recibos
  t := datosdb.tranSQL(htabla3.DatabaseName, 'SELECT * FROM ' + htabla3.TableName + ' WHERE XC = ' + '"' + xidc + '"' + ' AND XT = ' + '"' + xtipo + '"' +
                                                                 ' AND XS = ' + '"' + xsucursal + '"' + ' AND XN = ' + '"' + xnumero + '"');
  TransferirDatosHistOriginal(t);
  t.Close; t.Free;

  // Transferimos la definición de la Ficha
  getDatosDefHist(xclavecta, xidtitular);
  if datosdb.Buscar(tabla1, 'idtitular', 'clavecta', xidtitular, xclavecta) then tabla1.Edit else tabla1.Append;
  tabla1.FieldByName('idtitular').AsString := xidtitular;
  tabla1.FieldByName('clavecta').AsString  := xclavecta;
  tabla1.FieldByName('nombre').AsString    := titular;
  tabla1.FieldByName('clave').AsString     := clave;
  tabla1.FieldByName('obs').AsString       := obs;
  tabla1.FieldByName('fealta').AsString    := utiles.sExprFecha2000(fealta);
  try
    tabla1.Post
  except
    tabla1.Cancel
  end;
  // Transferimos la cabecera de la Factura
  if datosdb.Buscar(htabla2, 'idcompr', 'tipo', 'sucursal', 'numero', xidc, xtipo, xsucursal, xnumero) then Begin
    if datosdb.Buscar(tabla2, 'idcompr', 'tipo', 'sucursal', 'numero', xidc, xtipo, xsucursal, xnumero) then tabla2.Edit else tabla2.Append;
    tabla2.FieldByName('idcompr').AsString   := htabla2.FieldByName('idcompr').AsString;
    tabla2.FieldByName('tipo').AsString      := htabla2.FieldByName('tipo').AsString;
    tabla2.FieldByName('sucursal').AsString  := htabla2.FieldByName('sucursal').AsString;
    tabla2.FieldByName('numero').AsString    := htabla2.FieldByName('numero').AsString;
    tabla2.FieldByName('idtitular').AsString := htabla2.FieldByName('idtitular').AsString;
    tabla2.FieldByName('clavecta').AsString  := htabla2.FieldByName('clavecta').AsString;
    tabla2.FieldByName('dc').AsString        := htabla2.FieldByName('dc').AsString;
    tabla2.FieldByName('fecha').AsString     := htabla2.FieldByName('fecha').AsString;
    tabla2.FieldByName('importe').AsFloat    := htabla2.FieldByName('importe').AsFloat;
    tabla2.FieldByName('entrega').AsFloat    := htabla2.FieldByName('entrega').AsFloat;
    tabla2.FieldByName('impent').AsFloat     := htabla2.FieldByName('impent').AsFloat;
    try
      tabla2.Post
    except
      tabla2.Cancel
    end;
  end;

  // Quitamos los datos transferidos del historico
  if datosdb.Buscar(htabla2, 'idcompr', 'tipo', 'sucursal', 'numero', xidc, xtipo, xsucursal, xnumero) then htabla2.Delete;
  if datosdb.Buscar(htabla1, 'idtitular', 'clavecta', xidtitular, xclavecta) then htabla1.Delete;
  datosdb.tranSQL(htabla3.DatabaseName, 'DELETE FROM ' + htabla3.TableName + ' WHERE idcompr = ' + '"' + xidc + '"' + ' AND tipo = ' + '"' + xtipo + '"' + ' AND sucursal = ' + '"' + xsucursal + '"' + ' AND numero = ' + '"' + xnumero + '"');
  datosdb.tranSQL(htabla3.DatabaseName, 'DELETE FROM ' + htabla3.TableName + ' WHERE XC = ' + '"' + xidc + '"' + ' AND XT = ' + '"' + xtipo + '"' + ' AND XS = ' + '"' + xsucursal + '"' + ' AND XN = ' + '"' + xnumero + '"');

  CerrarTablasObj;
end;

procedure TTCtacte.TransferirDatosHistOriginal(r: TQuery);
// Objetivo...: transferir datos historicos desde la Query que obtuvo los resultados a la tabla de historicos
begin
  r.Open; r.First;
  while not r.EOF do Begin  // Transferencia de datos - facturas y recibo
    if datosdb.Buscar(tabla3, 'idtitular', 'clavecta', 'idcompr', 'tipo', 'sucursal', 'numero', 'items', r.FieldByName('idtitular').AsString, r.FieldByName('clavecta').AsString, r.FieldByName('idcompr').AsString, r.FieldByName('tipo').AsString, r.FieldByName('sucursal').AsString, r.FieldByName('numero').AsString, r.FieldByName('items').AsString) then tabla3.Edit else tabla3.Append;
    tabla3.FieldByName('idtitular').AsString := r.FieldByName('idtitular').AsString;
    tabla3.FieldByName('clavecta').AsString := r.FieldByName('clavecta').AsString;
    tabla3.FieldByName('idcompr').AsString := r.FieldByName('idcompr').AsString;
    tabla3.FieldByName('tipo').AsString := r.FieldByName('tipo').AsString;
    tabla3.FieldByName('sucursal').AsString := r.FieldByName('sucursal').AsString;
    tabla3.FieldByName('numero').AsString := r.FieldByName('numero').AsString;
    tabla3.FieldByName('items').AsString := r.FieldByName('items').AsString;
    tabla3.FieldByName('concepto').AsString := r.FieldByName('concepto').AsString;
    tabla3.FieldByName('fecha').AsString := r.FieldByName('fecha').AsString;
    tabla3.FieldByName('DC').AsString := r.FieldByName('DC').AsString;
    tabla3.FieldByName('importe').AsFloat := r.FieldByName('importe').AsFloat;
    tabla3.FieldByName('recargo').AsFloat := r.FieldByName('recargo').AsFloat;
    tabla3.FieldByName('entrega').AsFloat := r.FieldByName('entrega').AsFloat;
    tabla3.FieldByName('estado').AsString := r.FieldByName('estado').AsString;
    tabla3.FieldByName('XC').AsString := r.FieldByName('XC').AsString;
    tabla3.FieldByName('XT').AsString := r.FieldByName('XT').AsString;
    tabla3.FieldByName('XS').AsString := r.FieldByName('XS').AsString;
    tabla3.FieldByName('XN').AsString := r.FieldByName('XN').AsString;
    try
      tabla3.Post
    except
      tabla3.Cancel
    end;
    r.Next;
   end;
   r.Close;
end;

procedure  TTCtacte.getDatosDefHist(xclavecta, xidtitular: string);
// Objetivo...: Retornar/Iniciar Atributos
begin
  IniciarTablasObj;
  if datosdb.Buscar(htabla1, 'idtitular', 'clavecta', xidtitular, xclavecta) then Begin
    fealta  := utiles.sFormatoFecha(htabla1.FieldByName('fealta').AsString);
    clave   := htabla1.FieldByName('clave').AsString;
    titular := htabla1.FieldByName('nombre').AsString;
    obs     := htabla1.FieldByName('obs').AsString;
  end
  else Begin
    fealta := ''; obs := ''; clave := ''; titular := '';
  end;
  CerrarTablasObj;
end;

function TTCtacte.tranferirHistorico: boolean;
// Objetivo...: Devuelve si se transfiere o no al historico
begin
  tablapsw.Open; tablapsw.First;
  Result := False;
  if tablapsw.FieldByName('transhist').AsInteger = 1 then Result := True;
  tablapsw.Close;
end;

procedure TTCtacte.EstadoHistorico(estado: shortint);
// Objetivo...: Fijar el estado (transfiere/no transfiere al historico)
begin
  tablapsw.Open;
  if tablapsw.RecordCount > 0 then Begin
    tablapsw.Edit;
    tablapsw.FieldByName('transhist').AsInteger := estado;
    try
      tablapsw.Post
    except
      tablapsw.Cancel
    end;
  end;
  tablapsw.Close;
end;

procedure TTCtacte.getDatosFactHistorico(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero: string);
// Objetivo...: Cargar atributos comprobante histórico
begin
  if datosdb.Buscar(htabla3, 'idtitular', 'clavecta', 'idcompr', 'tipo', 'sucursal', 'numero', 'items', xidtitular, xclavecta, xidc, xtipo, xsucursal, xnumero, '-1') then
    concepto := htabla3.FieldByName('concepto').AsString
  else
    concepto := ''
end;

procedure TTCtacte.totalPS(salida: char);
begin
end;

procedure TTCtacte.PresentarListado;
// Objetivo...: presentar listado de datos
begin
  if tipototal = 'planilla_saldos' then totalPS(tipodispositivo);
  if (tipototal = 'total_vtos') and (recar > 0) then List.Linea(0, 0, 'Monto total de vencimientos .....:    ' +  utiles.FormatearNumero(FloatToStr(recar)), 1, 'Arial, normal, 12', tipodispositivo, 'S');
  list.FinList;
  tipototal := '';         // Indicador de subtotales
  listiniciado := False;   // Flag para re-iniciar otro informe
end;

procedure TTCtacte.BuscarPorCodigo(xexpr: string);
// Objetivo...: buscar por código
begin
  if tabla1.IndexFieldNames <> 'Idtitular;Clavecta' then tabla1.IndexFieldNames := 'Idtitular;Clavecta';
  tabla1.SetKey;
  tabla1.FieldByName('Idtitular').AsString := Copy(xexpr, 1, 4);
  tabla1.FieldByName('Clavecta').AsString  := Copy(xexpr, 6, 3);
  tabla1.GotoNearest;
end;

procedure TTCtacte.refrescar;
// Objetivo...: refrescar los datos de las tablas
begin
  if tabla1.Active then datosdb.refrescar(tabla1);
  if tabla2.Active then datosdb.refrescar(tabla2);
  if tabla3.Active then datosdb.refrescar(tabla3);
end;

procedure TTCtacte.vaciarBuffer;
// Objetivo...: vaciar el buffer de las tablas al disco
begin
  if tabla1.Active then datosdb.vaciarbuffer(tabla1);
  if tabla2.Active then datosdb.vaciarbuffer(tabla2);
  if tabla3.Active then datosdb.vaciarbuffer(tabla3);
end;

{===============================================================================}

function ctacte: TTCtacte;
begin
  if xctacte = nil then
    xctacte := TTCtacte.Create;
  Result := xctacte;
end;

{===============================================================================}

initialization

finalization
  xctacte.Free;

end.
