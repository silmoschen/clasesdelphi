unit Ccomprobantes;

interface

uses SysUtils, CUtiles, DB, DBTables, CIDBFM, CListar, CLibCont, CComregi, CTablaiva;

const
  toper: array[1..2] of string = ('Contado', 'Cuenta Corriente');

type

TTcomprobantereg = class(TTLibrosCont)            // Superclase
  idcompr, tipo, sucursal, numero, idtitular, fecha, observacion: string; // Atributos Generales
  ctcc: integer;
  remito, nroitems, codart, idart, items, descrip: string;          // Atributos de Facturas
  cantidad, precio, descuento: real;
  subtotal, bonif, impuestos, ivari, ivarni, sobretasa, destogeneral, entrega: real;
  tcabecera, tdetalle: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  procedure Listar;

  procedure getDatos(xidcompr, xtipo, xsucursal, xnumero, xidtitular: string); overload;
  procedure getDatos(xidcompr, xtipo, xsucursal, xnumero: string); overload;
  procedure TransferirDatos(c_ex: boolean);
  function  BuscarCab(xidcompr, xtipo, xsucursal, xnumero, xidtitular: string): boolean; overload;
  function  BuscarCab(xidcompr, xtipo, xsucursal, xnumero: string): boolean; overload;
  function  BuscarItems(xidcompr, xtipo, xsucursal, xnumero, xidtitular, xitems: string): boolean; overload;
  function  BuscarItems(xidcompr, xtipo, xsucursal, xnumero, xitems: string): boolean; overload;
  function  getFacturas: TQuery;
  function  getRsocial(xcodcli: string): string; virtual;
  procedure Depurar(xfecha: string);

  procedure conectar;
  procedure desconectar;
 private
  { Declaraciones Privadas }
  conexiones: shortint;
  procedure Titulos(xtit: string; salida: char);
  procedure Subtotales(salida: char);
 protected
  t_operacion: string; s_inicio: boolean;
  procedure verifListado(xtit: string; salida: char);
  procedure GrabarCab(xidcompr, xtipo, xsucursal, xnumero, xidtitular, xfecha, xremito: string; xctcc: integer; xsubtotal, xbonificacion, ximpuestos, xivari, xivarni, xsobretasa, xdestogeneral, xentrega: real; xobservacion: string);
  procedure GrabarItems(xidcompr, xtipo, xsucursal, xnumero, xidtitular, xitems, xcodart, xdescrip, xidart, xfecha, xremito: string; xcantidad, xprecio, xdescuento: real);
  procedure llistFechas(df, hf, xtitulo: string; salida: char);
  procedure llistCliProv(df, hf, xtitulo: string; salida: char);
  procedure llistCFIVA(df, hf, xtitulo: string; salida: char);
  procedure llistCTADOCC(df, hf, xtitulo: string; salida: char);
  procedure BorrarLineas(xidcompr, xtipo, xsucursal, xnumero, xidtitular: string);
 end;

function comprobantereg: TTcomprobantereg;

implementation

var
  xcomprobantereg: TTcomprobantereg = nil;

constructor TTcomprobantereg.Create;
begin
  inherited Create;
end;

destructor TTcomprobantereg.Destroy;
begin
  inherited Destroy;
end;

function TTcomprobantereg.BuscarCab(xidcompr, xtipo, xsucursal, xnumero, xidtitular: string): boolean;
// Objetivo...: Buscar un comprobante - Compras
begin
  if datosdb.Buscar(tcabecera, 'idcompr', 'tipo', 'sucursal', 'numero', 'idtitular', xidcompr, xtipo, xsucursal, xnumero, xidtitular) then
  begin
    _existe := True;
    Result   := True;
  end
 else
  begin
    _existe := False;
    Result   := False;
  end;
end;

function TTcomprobantereg.BuscarCab(xidcompr, xtipo, xsucursal, xnumero: string): boolean;
// Objetivo...: Buscar un comprobante - Ventas
begin
  _existe := datosdb.Buscar(tcabecera, 'idcompr', 'tipo', 'sucursal', 'numero', xidcompr, xtipo, xsucursal, xnumero);
  Result := _existe;
  idcompr := xidcompr; tipo := xtipo; sucursal := xsucursal; numero := xnumero;
end;

function TTcomprobantereg.BuscarItems(xidcompr, xtipo, xsucursal, xnumero, xidtitular, xitems: string): boolean;
// Objetivo...: Buscar un comprobantereg
begin
  if tdetalle.Filtered then tdetalle.Filtered := False;
  Result := datosdb.Buscar(tdetalle, 'idcompr', 'tipo', 'sucursal', 'numero', 'idtitular', 'items', xidcompr, xtipo, xsucursal, xnumero, xidtitular, xitems);
end;

function TTcomprobantereg.BuscarItems(xidcompr, xtipo, xsucursal, xnumero, xitems: string): boolean;
// Objetivo...: Buscar un comprobantereg
begin
  if tdetalle.Filtered then tdetalle.Filtered := False;
  Result := datosdb.Buscar(tdetalle, 'idcompr', 'tipo', 'sucursal', 'numero', 'items', xidcompr, xtipo, xsucursal, xnumero, xitems);
end;

procedure TTcomprobantereg.BorrarLineas(xidcompr, xtipo, xsucursal, xnumero, xidtitular: string);
// Objetivo...: Eliminar los renglones asociados a una Factura
begin
  datosdb.tranSQL('DELETE FROM ' + tdetalle.TableName + ' WHERE idcompr = ' + '''' + xidcompr + '''' + ' and tipo = ' + '''' + xtipo + '''' + ' and sucursal = ' + '''' + xsucursal + '''' + ' and numero = ' + '''' + xnumero + '''' + ' and idtitular = ' + '''' + xidtitular + '''');
  tdetalle.Refresh;
end;

procedure TTcomprobantereg.GrabarCab(xidcompr, xtipo, xsucursal, xnumero, xidtitular, xfecha, xremito: string; xctcc: integer; xsubtotal, xbonificacion, ximpuestos, xivari, xivarni, xsobretasa, xdestogeneral, xentrega: real; xobservacion: string);
// Objetivo...: Grabar un comprobantereg
begin
  // 1º identificio el tipo de búsqueda mediante el índice
  if t_operacion = 'ventas' then
    if BuscarCab(xidcompr, xtipo, xsucursal, xnumero) then tcabecera.Edit else tcabecera.Append
  else
    if BuscarCab(xidcompr, xtipo, xsucursal, xnumero, xidtitular) then tcabecera.Edit else tcabecera.Append;
  tcabecera.FieldByName('idcompr').AsString     := xidcompr;
  tcabecera.FieldByName('tipo').AsString        := xtipo;
  tcabecera.FieldByName('sucursal').AsString    := xsucursal;
  tcabecera.FieldByName('numero').AsString      := xnumero;
  tcabecera.FieldByName('idtitular').AsString   := xidtitular;
  tcabecera.FieldByName('fecha').AsString       := utiles.sExprFecha2000(xfecha);
  tcabecera.FieldByName('remito').AsString      := xremito;
  tcabecera.FieldByName('cc').AsInteger         := xctcc;
  tcabecera.FieldByName('subtotal').AsFloat     := xsubtotal;
  tcabecera.FieldByName('bonif').AsFloat        := xbonificacion;
  tcabecera.FieldByName('ivari').AsFloat        := xIvari;
  tcabecera.FieldByName('ivarni').AsFloat       := xIvarni;
  tcabecera.FieldByName('impuestos').AsFloat    := xImpuestos;
  tcabecera.FieldByName('sobretasa').AsFloat    := xSobretasa;
  tcabecera.FieldByName('destogeneral').AsFloat := xDestogeneral;
  tcabecera.FieldByName('entrega').AsFloat      := xEntrega;
  tcabecera.FieldByName('observacion').AsString := xObservacion;
  try
    tcabecera.Post;
  except
    tcabecera.Cancel;
  end;
  _existe := True;

  datosdb.refrescar(tcabecera);
  getDatos(xidcompr, xtipo, xsucursal, xnumero); 
end;

procedure TTcomprobantereg.GrabarItems(xidcompr, xtipo, xsucursal, xnumero, xidtitular, xitems, xcodart, xdescrip, xidart, xfecha, xremito: string; xcantidad, xprecio, xdescuento: real);
// Objetivo...: Grabar un Items en una Factura
begin
  if t_operacion = 'ventas' then
    if BuscarItems(xidcompr, xtipo, xsucursal, xnumero, xitems) then tdetalle.Edit else tdetalle.Append
  else
    if BuscarItems(xidcompr, xtipo, xsucursal, xnumero, xidtitular, xitems) then tdetalle.Edit else tdetalle.Append;
  tdetalle.FieldByName('idcompr').AsString   := xidcompr;
  tdetalle.FieldByName('tipo').AsString      := xtipo;
  tdetalle.FieldByName('sucursal').AsString  := xsucursal;
  tdetalle.FieldByName('numero').AsString    := xnumero;
  tdetalle.FieldByName('idtitular').AsString := xidtitular;
  tdetalle.FieldByName('items').AsString     := xitems;
  tdetalle.FieldByName('codart').AsString    := xcodart;
  tdetalle.FieldByName('descrip').AsString   := xdescrip;
  tdetalle.FieldByName('remito').AsString    := xremito;
  tdetalle.FieldByName('idart').AsString     := xidart;
  tdetalle.FieldByName('fecha').AsString     := utiles.sExprFecha2000(xfecha);
  tdetalle.FieldByName('cantidad').AsFloat   := xcantidad;
  tdetalle.FieldByName('precio').AsFloat     := xprecio;
  tdetalle.FieldByName('descuento').AsFloat  := xdescuento;
  try
    tdetalle.Post;
  except
    tdetalle.Cancel;
  end;
end;

procedure TTcomprobantereg.getDatos(xidcompr, xtipo, xsucursal, xnumero, xidtitular: string);
// Objetivo...: Actualizar los atributos - Compras
begin
  if BuscarCab(xidcompr, xtipo, xsucursal, xnumero, xidtitular) then TransferirDatos(True) else TransferirDatos(False);
end;

procedure TTcomprobantereg.getDatos(xidcompr, xtipo, xsucursal, xnumero: string);
// Objetivo...: Actualizar los atributos - Ventas
begin
  if BuscarCab(xidcompr, xtipo, xsucursal, xnumero) then TransferirDatos(True) else TransferirDatos(False);
end;

procedure TTComprobantereg.TransferirDatos(c_ex: boolean);
// Objetivo...: Actualizar los atributos
begin
  if c_ex then Begin
    idcompr      := tcabecera.FieldByName('idcompr').AsString;
    tipo         := tcabecera.FieldByName('tipo').AsString;
    sucursal     := tcabecera.FieldByName('sucursal').AsString;
    numero       := tcabecera.FieldByName('numero').AsString;
    idtitular    := tcabecera.FieldByName('idtitular').AsString;
    fecha        := utiles.sFormatoFecha(tcabecera.FieldByName('fecha').AsString);
    remito       := tcabecera.FieldByName('remito').AsString;
    ctcc         := tcabecera.FieldByName('cc').AsInteger;
    subtotal     := tcabecera.FieldByName('subtotal').AsFloat;
    bonif        := tcabecera.FieldByName('bonif').AsFloat;
    ivari        := tcabecera.FieldByName('ivari').AsFloat;
    ivarni       := tcabecera.FieldByName('ivarni').AsFloat;
    impuestos    := tcabecera.FieldByName('impuestos').AsFloat;
    sobretasa    := tcabecera.FieldByName('sobretasa').AsFloat;
    destogeneral := tcabecera.FieldByName('destogeneral').AsFloat;
    entrega      := tcabecera.FieldByName('entrega').AsFloat;
    observacion  := tcabecera.FieldByName('observacion').AsString;
  end else begin
    idtitular := ''; fecha := ''; remito := ''; observacion := ''; ctcc := 0; subtotal := 0; bonif := 0; ivari := 0; ivarni := 0; impuestos := 0; sobretasa := 0; destogeneral := 0; entrega := 0;
    _existe := False;
  end;
end;

procedure TTComprobantereg.verifListado(xtit: string; salida: char);
// Objetivo...: Verificar emisión del Listado
begin
  if not s_inicio then Titulos(xtit, salida) else  // Sio no se listo nada, tiramos los titulos
    begin
      list.CompletarPagina;    // Llenamos la Página
      List.printLn(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
      list.IniciarNuevaPagina;
      Titulos(xtit, salida);
    end;
end;

procedure TTComprobantereg.Listar;
// Objetivo...: Emitir el informe
begin
  List.FinList;
  s_inicio := False;
end;

procedure TTComprobantereg.Titulos(xtit: string; salida: char);
// Objetivo...: Listar Datos de Provincias
begin
  list.IniciarTitulos;
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, xtit, 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Comprobante', 1, 'Arial, cursiva, 8');
  List.Titulo(16, list.lineactual, 'Comprado/Vendido', 2, 'Arial, cursiva, 8');
  List.Titulo(36, list.lineactual, 'Subtotal', 3, 'Arial, cursiva, 8');
  List.Titulo(46, list.lineactual, 'Bonific.', 4, 'Arial, cursiva, 8');
  List.Titulo(53, list.lineactual, 'Impuestos', 5, 'Arial, cursiva, 8');
  List.Titulo(63, list.lineactual, 'I.V.A. RI', 6, 'Arial, cursiva, 8');
  List.Titulo(71, list.lineactual, 'I.V.A. RNI', 7, 'Arial, cursiva, 8');
  List.Titulo(80, list.lineactual, 'Sobretasa', 8, 'Arial, cursiva, 8');
  List.Titulo(90, list.lineactual, 'Total Op.', 9, 'Arial, cursiva, 8');

  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');
end;

procedure TTComprobantereg.llistFechas(df, hf, xtitulo: string; salida: char);
// Objetivo...: A partir de un recordset de registros generar informe de operaciones - Nivel de ruptura por fecha
begin
  verifListado(xtitulo, salida);

  subtotal := 0; bonif := 0; impuestos := 0; ivari := 0; ivarni := 0; sobretasa := 0;
  TSQL.Open; TSQL.First;
  while not TSQL.EOF do
    begin
      if TSQL.FieldByName('fecha').AsString <> idanterior then
        begin
          if subtotal <> 0 then Subtotales(salida);
          List.Linea  (0, 0, 'Fecha : ' +  utiles.sFormatoFecha(TSQL.FieldByName('fecha').AsString), 1, 'Arial, negrita, 9', salida, 'S');
          List.Linea  (0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');
        end;
      List.Linea  (0, 0, TSQL.FieldByName('tipo').AsString + ' ' + TSQL.FieldByName('sucursal').AsString + '-' + TSQL.FieldByName('numero').AsString + '  ' + TSQL.FieldByName('rsocial').AsString, 1, 'Arial, normal, 8', salida, 'N');
      List.importe(42, list.lineactual, '', TSQL.FieldByName('subtotal').AsFloat, 2, 'Arial, normal, 8');
      List.importe(51, list.lineactual, '', TSQL.FieldByName('bonif').AsFloat, 3, 'Arial, normal, 8');
      List.importe(60, list.lineactual, '', TSQL.FieldByName('impuestos').AsFloat, 4, 'Arial, normal, 8');
      List.importe(69, list.lineactual, '', TSQL.FieldByName('ivari').AsFloat, 5, 'Arial, normal, 8');
      List.importe(78, list.lineactual, '', TSQL.FieldByName('ivarni').AsFloat, 6, 'Arial, normal, 8');
      List.importe(87, list.lineactual, '', TSQL.FieldByName('sobretasa').AsFloat, 7, 'Arial, normal, 8');
      List.importe(96, list.lineactual, '', TSQL.FieldByName('subtotal').AsFloat - TSQL.FieldByName('bonif').AsFloat - TSQL.FieldByName('impuestos').AsFloat + TSQL.FieldByName('ivari').AsFloat + TSQL.FieldByName('ivarni').AsFloat + TSQL.FieldByName('sobretasa').AsFloat, 8, 'Arial, normal, 8');
      List.Linea  (98, list.lineactual, ' ', 9, 'Arial, normal, 8', salida, 'S');
      subtotal  := subtotal  + TSQL.FieldByName('subtotal').AsFloat;
      bonif     := bonif     + TSQL.FieldByName('bonif').AsFloat;
      impuestos := impuestos + TSQL.FieldByName('impuestos').AsFloat;
      ivari     := ivarni    + TSQL.FieldByName('ivari').AsFloat;
      ivarni    := ivarni    + TSQL.FieldByName('ivarni').AsFloat;
      sobretasa := sobretasa + TSQL.FieldByName('sobretasa').AsFloat;

      idanterior := TSQL.FieldByName('fecha').AsString;
      TSQL.Next;
    end;
  TSQL.Close;
  Subtotales(salida);
  s_inicio := True;
end;

procedure TTComprobantereg.llistCliProv(df, hf, xtitulo: string; salida: char);
// Objetivo...: A partir de un recordset de registros generar informe de operaciones - Nivel de ruptura por cliente o Proveedor
begin
  List.CambiarLeyendaTitulo(xtitulo, 2);
  List.CambiarLeyendaTitulo('  ', 5);  // Sobreescribo, en ese lugar no debe haber nada
  verifListado(xtitulo, salida);

  subtotal := 0; bonif := 0; impuestos := 0; ivari := 0; ivarni := 0; sobretasa := 0;
  TSQL.Open; TSQL.First;
  while not TSQL.EOF do
    begin
      if TSQL.FieldByName('Idtitular').AsString <> idanterior then
        begin
          if subtotal <> 0 then Subtotales(salida);
          List.Linea  (0, 0, 'Cliente : ' +  TSQL.FieldByName('idtitular').AsString + ' - ' + getRsocial(TSQL.FieldByName('idtitular').AsString), 1, 'Arial, negrita, 9', salida, 'S');
          List.Linea  (0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');
        end;
      List.Linea  (0, 0, TSQL.FieldByName('tipo').AsString + ' ' + TSQL.FieldByName('sucursal').AsString + '-' + TSQL.FieldByName('numero').AsString, 1, 'Arial, normal, 8', salida, 'N');
      List.importe(42, list.lineactual, '', TSQL.FieldByName('subtotal').AsFloat, 2, 'Arial, normal, 8');
      List.importe(51, list.lineactual, '', TSQL.FieldByName('bonif').AsFloat, 3, 'Arial, normal, 8');
      List.importe(60, list.lineactual, '', TSQL.FieldByName('impuestos').AsFloat, 4, 'Arial, normal, 8');
      List.importe(69, list.lineactual, '', TSQL.FieldByName('ivari').AsFloat, 5, 'Arial, normal, 8');
      List.importe(78, list.lineactual, '', TSQL.FieldByName('ivarni').AsFloat, 6, 'Arial, normal, 8');
      List.importe(87, list.lineactual, '', TSQL.FieldByName('sobretasa').AsFloat, 7, 'Arial, normal, 8');
      List.importe(96, list.lineactual, '', TSQL.FieldByName('subtotal').AsFloat - TSQL.FieldByName('bonif').AsFloat - TSQL.FieldByName('impuestos').AsFloat + TSQL.FieldByName('ivari').AsFloat + TSQL.FieldByName('ivarni').AsFloat + TSQL.FieldByName('sobretasa').AsFloat, 8, 'Arial, normal, 8');
      List.Linea  (98, list.lineactual, ' ', 9, 'Arial, normal, 8', salida, 'S');
      subtotal  := subtotal  + TSQL.FieldByName('subtotal').AsFloat;
      bonif     := bonif     + TSQL.FieldByName('bonif').AsFloat;
      impuestos := impuestos + TSQL.FieldByName('impuestos').AsFloat;
      ivari     := ivarni    + TSQL.FieldByName('ivari').AsFloat;
      ivarni    := ivarni    + TSQL.FieldByName('ivarni').AsFloat;
      sobretasa := sobretasa + TSQL.FieldByName('sobretasa').AsFloat;

      idanterior := TSQL.FieldByName('idtitular').AsString;
      TSQL.Next;
    end;
  TSQL.Close;
  Subtotales(salida);
  s_inicio := True;
end;

procedure TTComprobantereg.llistCFIVA(df, hf, xtitulo: string; salida: char);
// Objetivo...: A partir de un recordset de registros generar informe de operaciones - Nivel de ruptura por fecha
begin
  List.CambiarLeyendaTitulo(xtitulo, 2);
  verifListado(xtitulo, salida);

  subtotal := 0; bonif := 0; impuestos := 0; ivari := 0; ivarni := 0; sobretasa := 0;
  TSQL.Open; TSQL.First;
  while not TSQL.EOF do
    begin
      if TSQL.FieldByName('codpfis').AsString <> idanterior then
        begin
          if subtotal <> 0 then Subtotales(salida);
          List.Linea  (0, 0, 'Condición Fiscal : ' +  TSQL.FieldByName('codpfis').AsString, 1, 'Arial, negrita, 9', salida, 'S');
          List.Linea  (0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');
        end;
      List.Linea  (0, 0, TSQL.FieldByName('tipo').AsString + ' ' + TSQL.FieldByName('sucursal').AsString + '-' + TSQL.FieldByName('numero').AsString + '  ' + getRsocial( TSQL.FieldByName('idtitular').AsString), 1, 'Arial, normal, 8', salida, 'N');
      List.importe(42, list.lineactual, '', TSQL.FieldByName('subtotal').AsFloat, 2, 'Arial, normal, 8');
      List.importe(51, list.lineactual, '', TSQL.FieldByName('bonif').AsFloat, 3, 'Arial, normal, 8');
      List.importe(60, list.lineactual, '', TSQL.FieldByName('impuestos').AsFloat, 4, 'Arial, normal, 8');
      List.importe(69, list.lineactual, '', TSQL.FieldByName('ivari').AsFloat, 5, 'Arial, normal, 8');
      List.importe(78, list.lineactual, '', TSQL.FieldByName('ivarni').AsFloat, 6, 'Arial, normal, 8');
      List.importe(87, list.lineactual, '', TSQL.FieldByName('sobretasa').AsFloat, 7, 'Arial, normal, 8');
      List.importe(96, list.lineactual, '', TSQL.FieldByName('subtotal').AsFloat - TSQL.FieldByName('bonif').AsFloat - TSQL.FieldByName('impuestos').AsFloat + TSQL.FieldByName('ivari').AsFloat + TSQL.FieldByName('ivarni').AsFloat + TSQL.FieldByName('sobretasa').AsFloat, 8, 'Arial, normal, 8');
      List.Linea  (98, list.lineactual, ' ', 9, 'Arial, normal, 8', salida, 'S');
      subtotal  := subtotal  + TSQL.FieldByName('subtotal').AsFloat;
      bonif     := bonif     + TSQL.FieldByName('bonif').AsFloat;
      impuestos := impuestos + TSQL.FieldByName('impuestos').AsFloat;
      ivari     := ivarni    + TSQL.FieldByName('ivari').AsFloat;
      ivarni    := ivarni    + TSQL.FieldByName('ivarni').AsFloat;
      sobretasa := sobretasa + TSQL.FieldByName('sobretasa').AsFloat;

      idanterior := TSQL.FieldByName('codpfis').AsString;
      TSQL.Next;
    end;
  TSQL.Close;
  Subtotales(salida);
  s_inicio := True;
end;

procedure TTComprobantereg.llistCTADOCC(df, hf, xtitulo: string; salida: char);
// Objetivo...: A partir de un recordset de registros generar informe de operaciones - Nivel de ruptura por tipo de operación
begin
  List.CambiarLeyendaTitulo(xtitulo, 2);
  verifListado(xtitulo, salida);

  subtotal := 0; bonif := 0; impuestos := 0; ivari := 0; ivarni := 0; sobretasa := 0;
  TSQL.Open; TSQL.First;
  while not TSQL.EOF do
    begin
      if TSQL.FieldByName('cc').AsString <> idanterior then
        begin
          if subtotal <> 0 then Subtotales(salida);
          List.Linea  (0, 0, 'Operación : ' +  TSQL.FieldByName('cc').AsString + ' - ' + toper[TSQL.FieldByName('cc').AsInteger], 1, 'Arial, negrita, 9', salida, 'S');
          List.Linea  (0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');
        end;
      List.Linea  (0, 0, TSQL.FieldByName('tipo').AsString + ' ' + TSQL.FieldByName('sucursal').AsString + '-' + TSQL.FieldByName('numero').AsString + '  ' + getRsocial(TSQL.FieldByName('idtitular').AsString), 1, 'Arial, normal, 8', salida, 'N');
      List.importe(42, list.lineactual, '', TSQL.FieldByName('subtotal').AsFloat, 2, 'Arial, normal, 8');
      List.importe(51, list.lineactual, '', TSQL.FieldByName('bonif').AsFloat, 3, 'Arial, normal, 8');
      List.importe(60, list.lineactual, '', TSQL.FieldByName('impuestos').AsFloat, 4, 'Arial, normal, 8');
      List.importe(69, list.lineactual, '', TSQL.FieldByName('ivari').AsFloat, 5, 'Arial, normal, 8');
      List.importe(78, list.lineactual, '', TSQL.FieldByName('ivarni').AsFloat, 6, 'Arial, normal, 8');
      List.importe(87, list.lineactual, '', TSQL.FieldByName('sobretasa').AsFloat, 7, 'Arial, normal, 8');
      List.importe(96, list.lineactual, '', TSQL.FieldByName('subtotal').AsFloat - TSQL.FieldByName('bonif').AsFloat - TSQL.FieldByName('impuestos').AsFloat + TSQL.FieldByName('ivari').AsFloat + TSQL.FieldByName('ivarni').AsFloat + TSQL.FieldByName('sobretasa').AsFloat, 8, 'Arial, normal, 8');
      List.Linea  (98, list.lineactual, ' ', 9, 'Arial, normal, 8', salida, 'S');
      subtotal  := subtotal  + TSQL.FieldByName('subtotal').AsFloat;
      bonif     := bonif     + TSQL.FieldByName('bonif').AsFloat;
      impuestos := impuestos + TSQL.FieldByName('impuestos').AsFloat;
      ivari     := ivarni    + TSQL.FieldByName('ivari').AsFloat;
      ivarni    := ivarni    + TSQL.FieldByName('ivarni').AsFloat;
      sobretasa := sobretasa + TSQL.FieldByName('sobretasa').AsFloat;

      idanterior := TSQL.FieldByName('cc').AsString;
      TSQL.Next;
    end;
  TSQL.Close;
  Subtotales(salida);
  s_inicio := True;
end;

procedure TTComprobantereg.Subtotales(salida: char);
// Objetivo...: A partir de un recordset de registros generar informe de operaciones - Nivel de ruptura por fecha
begin
  List.Linea  (0, 0, ' ', 1, 'Arial, normal, 8', salida, 'N');
  List.derecha(42, list.lineactual, '', '--------------', 2, 'Arial, normal, 8');
  List.derecha(51, list.lineactual, '', '--------------', 3, 'Arial, normal, 8');
  List.derecha(60, list.lineactual, '', '--------------', 4, 'Arial, normal, 8');
  List.derecha(69, list.lineactual, '', '--------------', 5, 'Arial, normal, 8');
  List.derecha(78, list.lineactual, '', '--------------', 6, 'Arial, normal, 8');
  List.derecha(87, list.lineactual, '', '--------------', 7, 'Arial, normal, 8');
  List.derecha(96, list.lineactual, '', '--------------', 8, 'Arial, normal, 8');
  List.Linea  (98, list.lineactual, ' ', 9, 'Arial, normal, 8', salida, 'S');
  List.Linea  (0, 0, 'Subtotal ........: ', 1, 'Arial, cursiva, 8', salida, 'N');
  List.importe(42, list.lineactual, '', subtotal, 2, 'Arial, cursiva, 8');
  List.importe(51, list.lineactual, '', bonif, 3, 'Arial, cursiva, 8');
  List.importe(60, list.lineactual, '', impuestos, 4, 'Arial, cursiva, 8');
  List.importe(69, list.lineactual, '', ivari, 5, 'Arial, cursiva, 8');
  List.importe(78, list.lineactual, '', ivarni, 6, 'Arial, cursiva, 8');
  List.importe(87, list.lineactual, '', sobretasa, 7, 'Arial, cursiva, 8');
  List.importe(96, list.lineactual, '', subtotal + bonif - impuestos + ivari + ivarni + sobretasa, 8, 'Arial, cursiva, 8');
  List.Linea  (0, 0, ' ', 1, 'Arial, cursiva, 5', salida, 'S');
  subtotal := 0; bonif := 0; impuestos := 0; ivari := 0; ivarni := 0; sobretasa := 0;
end;

function TTComprobantereg.getRsocial(xcodcli: string): string;
begin
  Result := '';
end;

procedure TTComprobantereg.Depurar(xfecha: string);
// Objetivo...: Depurar comprobantes
begin
  datosdb.tranSQL('DELETE FROM ' + tcabecera.TableName + ' WHERE fecha <= ' + '''' + utiles.sExprFecha2000(xfecha) + '''');
  datosdb.tranSQL('DELETE FROM ' + tdetalle.TableName + ' WHERE fecha <= ' + '''' + utiles.sExprFecha2000(xfecha) + '''');
end;

function TTComprobantereg.getFacturas: TQuery;
// Objetivo...: retornar un subset de registros con las facturas de compra
begin
  Result := datosdb.tranSQL('SELECT idcompr, tipo, sucursal, numero, idtitular, fecha FROM ' +  tcabecera.TableName + ' ORDER BY fecha');
end;

procedure TTComprobantereg.conectar;
// Objetivo...: conectar tablas de persistencia
begin
  if conexiones = 0 then Begin
//    stock.conectar;
  end;
  Inc(conexiones);
end;

procedure TTComprobantereg.desconectar;
// Objetivo...: desconectar tablas de persistencia
begin
  Dec(conexiones);
  if conexiones = 0 then Begin
    datosdb.closeDB(tcabecera);
    datosdb.closeDB(tdetalle);
//    stock.desconectar;
  end;
end;

{===============================================================================}

function comprobantereg: TTcomprobantereg;
begin
  if xcomprobantereg = nil then
    xcomprobantereg := TTcomprobantereg.Create;
  Result := xcomprobantereg;
end;

{===============================================================================}

initialization

finalization
  xcomprobantereg.Free;

end.
