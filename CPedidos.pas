unit CPedidos;

interface

uses SysUtils, CListar, DB, DBTables, CUtiles, CIDBFM, CClienteDamevin, CCEmpleadosDamevin, CTablaSabores, Forms;

const
  lineasImp = 14;

type

TTPedidos = class(TObject)            // Superclase
  nropedido, nrotel, otros, idpreparo, fecha, hora, idvendedor, ultimoped, limite, FechaPed, HoraPed, nota: string;
  cantidad, importe, vuelto: real;
  ExistePedido: boolean;
  tabla, detpedido, ultpedido: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  procedure   Grabar(xnropedido, xnrotel, xotros, xidpreparo, xfecha, xhora, xidvendedor, xfechaped, xhoraped: string; ximporte, xvuelto: real); overload;
  procedure   Grabar(xnropedido, xnota: string); overload;
  procedure   Grabar(xnropedido, xitems, xdescrip, xcodigo, xcategoria: string; xcantidad, ximporte: real); overload;
  procedure   Borrar(xnropedido: string);
  function    Buscar(xnropedido: string): boolean;
  function    Nuevo: string;
  procedure   getDatos(xnropedido: string);
  procedure   Depurar(xperiodo: string);
  procedure   ListarPedido(xnropedido: string; salida: char);
  procedure   ListarPedidosFecha(xdesde, xhasta: string; salida: char);
  procedure   ListarPedidosPedido(xdesde, xhasta: string; salida: char);
  function    setPedidos: TQuery;
  function    setDetallePedido: TQuery;
  function    setSaboresPedido: TQuery;
  function    setPedidosAuditoria(xfecha: string): TQuery;
  function    setEstadisticaPedidos(xfecha1, xfecha2: string): TQuery;
  function    setEstadisticaPedidosCli(xfecha1, xfecha2: string): TQuery;
  function    setEstadisticaSabores(xfecha1, xfecha2: string): TQuery;
  procedure   PresentarInforme;
  procedure   RegistrarUltimoPedido(xnropedido, xlimite: string);
  function    verifCliente(xnrotel: string): boolean;
  function    verifEmpleado(xnrolegajo: string): boolean;
  function    verifSabor(xcodsabor: string): boolean;

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  conexiones: shortint; est: boolean;
  procedure   GuardarUltimoPedido(xnropedido: string);
  procedure   ListPedido(xnropedido: string; salida: char);
  procedure   ListEncPedido(xnropedido: string; salida: char);
end;

function pedido: TTPedidos;

implementation

var
  xpedido: TTPedidos = nil;

constructor TTPedidos.Create;
begin
  inherited Create;
  tabla        := datosdb.openDB('pedidos', 'nropedido');
  detpedido    := datosdb.openDB('detpedido', 'nropedido;items');
  ultpedido    := datosdb.openDB('ultpedido', 'Nropedido');
end;

destructor TTPedidos.Destroy;
begin
  inherited Destroy;
end;

procedure TTPedidos.Grabar(xnropedido, xnrotel, xotros, xidpreparo, xfecha, xhora, xidvendedor, xfechaped, xhoraped: string; ximporte, xvuelto: real);
// Objetivo...: Grabar Atributos del Objeto
begin
  if Buscar(xnropedido) then Begin
    datosdb.tranSQL('DELETE FROM ' + detpedido.TableName + ' WHERE nropedido = ' + '"' + xnropedido + '"');     detpedido.Refresh;
    tabla.Edit;
  end
   else tabla.Append;
  tabla.FieldByName('nropedido').AsString  := xnropedido;
  tabla.FieldByName('nrotel').AsString     := xnrotel;
  tabla.FieldByName('otros').AsString      := xotros;
  tabla.FieldByName('idpreparo').AsString  := xidpreparo;
  tabla.FieldByName('fecha').AsString      := utiles.sExprFecha(xfecha);
  tabla.FieldByName('hora').AsString       := xhora;
  tabla.FieldByName('idvendedor').AsString := xidvendedor;
  tabla.FieldByName('importe').AsFloat     := ximporte;
  tabla.FieldByName('vuelto').AsFloat      := xvuelto;
  tabla.FieldByName('fechaped').AsString   := utiles.sExprFecha(xfechaped);
  tabla.FieldByName('horaped').AsString    := xhoraped;
  try
    tabla.Post;
  except
    tabla.Cancel;
  end;

  cliente.NuevoCliente(xnrotel);

  GuardarUltimoPedido(xnropedido);
  ExistePedido := True;
end;

procedure TTPedidos.Grabar(xnropedido, xitems, xdescrip, xcodigo, xcategoria: string; xcantidad, ximporte: real);
// Objetivo...: Guardar el detalle de un pedido
begin
  if not datosdb.Buscar(detpedido, 'nropedido', 'items', xnropedido, xitems) then detpedido.Append else detpedido.Edit;
  detpedido.FieldByName('nropedido').AsString := xnropedido;
  detpedido.FieldByName('items').AsString     := xitems;
  detpedido.FieldByName('cantidad').AsFloat   := xcantidad;
  detpedido.FieldByName('descrip').AsString   := xdescrip;
  detpedido.FieldByName('codigo').AsString    := xcodigo;
  detpedido.FieldByName('categoria').AsString := xcategoria;
  detpedido.FieldByName('precio').AsFloat     := ximporte;
  try
    detpedido.Post
  except
    detpedido.Cancel
  end;
end;

procedure TTPedidos.Grabar(xnropedido, xnota: string);
begin
  if Buscar(xnropedido) then Begin
    tabla.Edit;
    tabla.FieldByName('nota').AsString := xnota;
    try
      tabla.Post
    except
      tabla.Cancel
    end;
  end;
end;

procedure TTPedidos.GuardarUltimoPedido(xnropedido: string);
begin
  if ultpedido.RecordCount = 0 then ultpedido.Append else ultpedido.Edit;
  if StrToInt(xnropedido) > ultpedido.FieldByName('nropedido').AsInteger then ultpedido.FieldByName('nropedido').AsInteger := StrToInt(xnropedido);
  try
    ultpedido.Post
   except
    ultpedido.Cancel
  end;
end;

procedure TTPedidos.Borrar(xnropedido: string);
// Objetivo...: Eliminar un Objeto
begin
  if Buscar(xnropedido) then
    begin
      tabla.Delete;
      nropedido := tabla.FieldByName('nropedido').AsString;
      datosdb.tranSQL('DELETE FROM ' + detpedido.TableName + ' WHERE nropedido = ' + '"' + xnropedido + '"');
    end;
end;

function TTPedidos.Buscar(xnropedido: string): boolean;
// Objetivo...: Buscar el Objeto solicitado
begin
  tabla.Refresh;
  if tabla.FindKey([xnropedido]) then ExistePedido := True else ExistePedido := False;
  Result := ExistePedido;
end;

procedure  TTPedidos.getDatos(xnropedido: string);
// Objetivo...: Retornar/Iniciar Atributos
begin
  if Buscar(xnropedido) then
    begin
      nropedido  := xnropedido;
      otros      := tabla.FieldByName('otros').AsString;
      nrotel     := tabla.FieldByName('nrotel').AsString;
      idpreparo  := tabla.FieldByName('idpreparo').AsString;
      idvendedor := tabla.FieldByName('idvendedor').AsString;
      fecha      := utiles.sFormatoFecha(tabla.FieldByName('fecha').AsString);
      hora       := tabla.FieldByName('hora').AsString;
      fechaped   := utiles.SFormatoFecha(tabla.FieldByName('fechaped').AsString);
      horaped    := tabla.FieldByName('horaped').AsString;
      importe    := tabla.FieldByName('importe').AsFloat;
      vuelto     := tabla.FieldByName('vuelto').AsFloat;
      nota       := tabla.FieldByName('nota').AsString;
    end
   else
    begin
      nropedido := ''; otros := ''; nrotel := ''; idpreparo := ''; fecha := ''; hora := ''; idvendedor := ''; importe := 0; vuelto := 0; fechaped := ''; horaped := ''; nota := ''; idvendedor := '';
    end;
end;

procedure TTPedidos.Depurar(xperiodo: string);
// Objetivo...: depurar datos, anteriores al período especidicado
var
  r: TQuery;
begin
  conectar;
  r := datosdb.tranSQL('SELECT * FROM ' + tabla.TableName + ' WHERE fecha <= ' + '"' + utiles.sExprFecha(xperiodo) + '"');
  r.Open; r.First;
  while not r.EOF do Begin
    if tabla.FindKey([r.FieldByName('nropedido').AsString]) then tabla.Delete;
    datosdb.tranSQL('DELETE FROM ' + detpedido.TableName + ' WHERE nropedido = ' + '"' + r.FieldByName('nropedido').AsString + '"');
    r.Next;
  end;
  r.Close; r.Free;
  desconectar;
end;

function TTPedidos.Nuevo: string;
// Objetivo...: Generar un Nuevo Atributo Código
begin
  ultpedido.Refresh;
  if ultpedido.RecordCount > 0 then Result := IntToStr(StrToInt(ultpedido.FieldByName('nropedido').AsString) + 1) else Result := '1';
end;

function TTPedidos.setPedidos: TQuery;
// Objetivo...: devolver un set con los pedidos existentes
begin
  Result := datosdb.tranSQL('SELECT * FROM ' + tabla.TableName + ' ORDER BY nropedido');
end;

function TTPedidos.setDetallePedido: TQuery;
// Objetivo...: devolver un set con el detalle del pedido actual
begin
  Result := datosdb.tranSQL('SELECT * FROM ' + detpedido.TableName + ' WHERE nropedido = ' + '"' + nropedido + '"' + ' ORDER BY Nropedido, Items');
end;

function TTPedidos.setSaboresPedido: TQuery;
// Objetivo...: devolver los sabores seleccionados para un determinado pedido
begin
  Result := datosdb.tranSQL('SELECT * FROM ' + detpedido.TableName + ' WHERE nropedido = ' + '"' + nropedido + '"');
end;

function TTPedidos.setPedidosAuditoria(xfecha: string): TQuery;
// Objetivo...: devolver los pedidos de una fecha determinada - auditoria
begin
  Result := datosdb.tranSQL('SELECT * FROM ' + tabla.TableName + ' WHERE fecha = ' + '"' + xfecha + '"');
end;

function TTPedidos.setEstadisticaPedidos(xfecha1, xfecha2: string): TQuery;
// Objetivo...: devolver un set de registros para confeccionar estadísticas
begin
  Result := datosdb.tranSQL('SELECT * FROM ' + tabla.TableName + ' WHERE fecha >= ' + '"' + xfecha1 + '"' + ' AND fecha <= ' + '"' + xfecha2 + '"');
end;

function TTPedidos.setEstadisticaPedidosCli(xfecha1, xfecha2: string): TQuery;
// Objetivo...: devolver un set de registros para confeccionar estadísticas
begin
  Result := datosdb.tranSQL('SELECT * FROM ' + tabla.TableName + ' WHERE Fecha >= ' + '"' + xfecha1 + '"' + ' AND Fecha <= ' + '"' + xfecha2 + '"' + ' ORDER BY Nrotel');
end;

function TTPedidos.setEstadisticaSabores(xfecha1, xfecha2: string): TQuery;
// Objetivo...: devolver un set de registros para confeccionar estadísticas - sabores
begin
  Result := datosdb.tranSQL('SELECT pedidos.fecha, detpedido.items FROM pedidos, detpedido WHERE pedidos.nropedido = detpedido.nropedido AND fecha >= ' + '"' + xfecha1 + '"' + ' AND fecha <= ' + '"' + xfecha2 + '"' + ' ORDER BY items');
end;

procedure TTPedidos.ListarPedido(xnropedido: string; salida: char);
// Objetivo...: Listar Datos del Pedido
const
  lineas = 14;
begin
  list.NoImprimirPieDePagina;
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');

  tabla.FindKey([xnropedido]); nropedido := xnropedido;

  ListEncPedido(xnropedido, salida);
  ListPedido(xnropedido, salida);

  List.Linea(0, 0, ' ', 1, 'Arial, negrita, 5', salida, 'S');
  List.Linea(0, 0, 'Importe: $ ' + utiles.FormatearNumero(tabla.FieldByName('importe').AsString), 1, 'Arial, negrita, 12', salida, 'S');
  List.Linea(0, 0, ' ', 1, 'Arial, negrita, 8', salida, 'S');
  List.Linea(0, 0, 'Otros: ' + tabla.FieldByName('otros').AsString, 1, 'Arial, normal, 10', salida, 'S');
  List.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');
  if Length(Trim(tabla.FieldByName('idpreparo').AsString)) > 0 then Begin
    empleado.getDatos(tabla.FieldByName('idpreparo').AsString);
    List.Linea(0, 0, ' ', 1, 'Arial, negrita, 8', salida, 'S');
   end
  else
    List.Linea(0, 0, ' ', 1, 'Arial, negrita, 8', salida, 'S');
    if Length(Trim(idpreparo)) = 0 then List.Linea(0, 0, 'Preparó: ' + '......................................................................................', 1, 'Arial, normal, 10', salida, 'N') else List.Linea(0, 0, 'Preparó: ' + idpreparo, 1, 'Arial, normal, 10', salida, 'N');
    List.Linea(50, list.Lineactual, 'Atendió:..................................................................', 2, 'Arial, normal, 10', salida, 'S');

  List.Linea(0, 0, ' ', 1, 'Arial, normal, 6', salida, 'S');
  List.Linea(0, 0, '           Registrado día: ' + utiles.sFormatoFecha(tabla.FieldByName('fecha').AsString), 1, 'Arial, normal, 8', salida, 'N');
  List.Linea(40, List.Lineactual, 'Hora: ' + tabla.FieldByName('hora').AsString, 2, 'Arial, normal, 8', salida, 'S');

  empleado.getDatos(tabla.FieldByName('idvendedor').AsString);
  List.Linea(0, 0, ' ', 1, 'Arial, normal, 8', salida, 'S');
  if tabla.FieldByName('vuelto').AsFloat > 0 then Begin
    List.Linea(0, 0, 'EL REPARTIDOR LLEVA VUELTO DE: ', 1, 'Arial, normal, 8', salida, 'N');
    List.importe(38, List.Lineactual, '', tabla.FieldByName('vuelto').AsFloat, 2, 'Arial, negrita, 9');
  end else List.Linea(0, 0, 'EL REPARTIDOR LLEVA VUELTO DE: ----------', 1, 'Arial, normal, 8', salida, 'N');

  List.Linea(0, 0, ' ', 1, 'Arial, normal, 16', salida, 'S');

  List.Linea(0, 0, '[  ] Efectivo      [   ] Ticket      [  ] Tarjeta   ...............................................................', 1, 'Arial, normal, 10', salida, 'S');

  List.Linea(0, 0, ' ', 1, 'Arial, normal, 9', salida, 'S');
  List.Linea(0, 0, 'Preparar para el : ' + utiles.sFormatoFecha(tabla.FieldByName('fechaPed').AsString), 1, 'Ms Sans Serif, normal, 11', salida, 'N');
  List.Linea(40, List.Lineactual, 'a la Hora: ' + tabla.FieldByName('horaPed').AsString, 2, 'Ms Sans Serif, normal, 11', salida, 'S');

  List.Linea(0, 0, ' ', 1, 'Arial, normal, 6', salida, 'S');

  list.ListMemo('nota', 'Arial, cursiva, 8', 0, salida, tabla, 650);

  List.Linea(0, 0, ' ', 1, 'Arial, normal, 16', salida, 'S');
  List.Linea(0, 0, ' ', 1, 'Arial, normal, 16', salida, 'S');
end;

procedure TTPedidos.ListEncPedido(xnropedido: string; salida: char);
begin
  List.Titulo(0, 0, 'Heladería DAMEVÍN', 1, 'Arial, negrita, 11');
  List.Titulo(60, List.Lineactual, 'Télefono: 4-22222', 2,'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');

  List.Linea(0, 0, 'Pedido Nº:  ' + xnropedido, 1, 'Arial, normal, 11', salida, 'N');
  List.Linea(45, list.Lineactual, 'Comprobante no válido como factura', 2, 'Arial, normal, 11', salida, 'S');
  List.Linea(0, 0, ' ', 1, 'Arial, negrita, 5', salida, 'S');
  cliente.getDatos(tabla.FieldByName('nrotel').AsString);
  List.Linea(0, 0, 'Señor: ' + cliente.nombre, 1, 'Arial, negrita, 10', salida, 'N');
  List.Linea(60, list.Lineactual, 'Tél: ' + cliente.codigo, 2, 'Arial, negrita, 10', salida, 'N');
  List.Linea(75, list.Lineactual, 'Nº Cliente: ' + cliente.codcli, 3, 'Arial, negrita, 10', salida, 'S');

  List.Linea(0, 0, 'Calle: ' + cliente.domicilio, 1, 'Arial, negrita, 10', salida, 'N');
  List.Linea(60, List.Lineactual, 'Barrio: ' + cliente.barrio, 2, 'Arial, negrita, 10', salida, 'S');

  List.Linea(0, 0, ' ', 1, 'Arial, normal, 8', salida, 'S');
  List.Linea(0, 0, 'Pedido: ', 1, 'Arial, negrita, 12', salida, 'S');
end;

procedure TTPedidos.ListPedido(xnropedido: string; salida: char);
var
  r: TQuery; lista: string; items: byte;
begin
  r := setDetallePedido;
  r.Open; items := 0;
  while not r.EOF do Begin
    if Copy(r.FieldByName('categoria').AsString, 4, 2) = '00' then Begin
      if items > 0 then Begin
        List.Linea(0, 0, '                ' + lista, 1, 'Arial, cursiva, 8', salida, 'S');
        List.Linea(0, 0, '  ', 1, 'Arial, cursiva, 8', salida, 'S');
        items := 0; lista := '';
      end;
      List.Linea(0, 0, '  ', 1, 'Arial, negrita, 9', salida, 'N');
      if r.FieldByName('cantidad').AsFloat > 1 then List.derecha(6, list.Lineactual, '', r.FieldByName('cantidad').AsString, 2, 'Arial, negrita, 9') else List.Linea(5, List.Lineactual, '  ', 2, 'Arial, negrita, 9', salida, 'N');
      List.Linea(8, list.Lineactual, r.FieldByName('descrip').AsString, 3, 'Arial, negrita, 9', salida, 'N');
      List.Importe(95, list.Lineactual, '', r.FieldByName('precio').AsFloat, 4, 'Arial, negrita, 9');
      List.Linea(96, list.Lineactual, ' ', 5, 'Arial, negrita, 9', salida, 'S');
    end else Begin
    if items = 0 then lista := lista + r.FieldByName('descrip').AsString else lista := lista + ' - ' + r.FieldByName('descrip').AsString;
    Inc(items);
    end;
    if items > 5 then Begin
      List.Linea(0, 0, '                ' + lista, 1, 'Arial, cursiva, 8', salida, 'S');
      items := 0; lista := '';
    end;
    r.Next;
  end;
  r.Close; r.Free;

  if items > 0 then Begin
    List.Linea(0, 0, '                ' + lista, 1, 'Arial, cursiva, 8', salida, 'S');
    List.Linea(0, 0, '  ', 1, 'Arial, cursiva, 8', salida, 'S');
  end;

end;

procedure TTPedidos.ListarPedidosFecha(xdesde, xhasta: string; salida: char);
// Objetivo...: Listar Pedidos por Fecha
begin
  tabla.First;
  while not tabla.EOF do Begin
    if (tabla.FieldByName('fecha').AsString >= utiles.sExprFecha(xdesde)) and (tabla.FieldByName('fecha').AsString <= utiles.sExprFecha(xhasta)) then ListarPedido(tabla.FieldByName('nropedido').AsString, salida);
    tabla.Next;
  end;
end;

procedure TTPedidos.ListarPedidosPedido(xdesde, xhasta: string; salida: char);
// Objetivo...: Listar Pedidos por Pedido
var
  t: TQuery;
begin
  t := datosdb.tranSQL('SELECT pedidos.Nropedido FROM pedidos WHERE nropedido > ' + '"' + xdesde + '"' + ' AND nropedido <= ' + '"' + xhasta + '"' + ' ORDER BY nropedido');
  t.Open; t.First;
  while not t.EOF do Begin
    if Buscar(t.FieldByName('nropedido').AsString) then ListarPedido(t.FieldByName('nropedido').AsString, salida);
    t.Next;
  end;
  t.Close; t.Free;
  PresentarInforme;
end;

procedure TTPedidos.PresentarInforme;
begin
  List.FinList;
end;

procedure TTPedidos.RegistrarUltimoPedido(xnropedido, xlimite: string);
// Objetivo...: Ajustar los Nros. de pedido
begin
  if ultpedido.RecordCount = 0 then ultpedido.Append else ultpedido.Edit;
  ultpedido.FieldByName('nropedido').AsString := xnropedido;
  ultpedido.FieldByName('limite').AsString    := xlimite;
  try
    ultpedido.Post
   except
    ultpedido.Cancel
  end;
end;

function TTPedidos.verifCliente(xnrotel: string): boolean;
// Obhetivo...: verificar si el cliente tiene pedidos
begin
  est    := tabla.Active;
  if not tabla.Active then tabla.Open;
  Result := False;
  tabla.First;
  while not tabla.EOF do Begin
    if tabla.FieldByName('nrotel').AsString = xnrotel then Begin
      Result := True;
      Break;
    end;
    tabla.Next;
  end;
  if not est then tabla.Close;
end;

function TTPedidos.verifEmpleado(xnrolegajo: string): boolean;
begin
  est    := tabla.Active;
  if not tabla.Active then tabla.Open;
  Result := False;
  tabla.First;
  while not tabla.EOF do Begin
    if (tabla.FieldByName('idpreparo').AsString = xnrolegajo) or (tabla.FieldByName('idvendedor').AsString = xnrolegajo) then Begin
      Result := True;
      Break;
    end;
    tabla.Next;
  end;
  if not est then tabla.Close;
end;

function TTPedidos.verifSabor(xcodsabor: string): boolean;
begin
  est    := detpedido.Active;
  if not detpedido.Active then detpedido.Open;
  Result := False;
  detpedido.First;
  while not detpedido.EOF do Begin
    if detpedido.FieldByName('items').AsString = xcodsabor then Begin
      Result := True;
      Break;
    end;
    detpedido.Next;
  end;
  if not est then detpedido.Close;
end;

procedure TTPedidos.conectar;
// Objetivo...: conectar tablas de persistencia
begin
  if conexiones = 0 then Begin
    if not tabla.Active         then tabla.Open;
    if not detpedido.Active     then detpedido.Open;
    if not ultpedido.Active     then ultpedido.Open;
    cliente.conectar;
    empleado.conectar;
    sabor.conectar;
  end;
  Inc(conexiones);
  ultimoped := ultpedido.FieldByName('nropedido').AsString;
  limite    := ultpedido.FieldByName('limite').AsString;
end;

procedure TTPedidos.desconectar;
// Objetivo...: desconectar tablas de persistencia
begin
  if conexiones > 0 then Dec(conexiones);
  if conexiones = 0 then Begin
    datosdb.closeDB(tabla);
    datosdb.closeDB(detpedido);
    datosdb.closeDB(ultpedido);
    cliente.desconectar;
    empleado.desconectar;
    sabor.desconectar;
  end;
end;

{===============================================================================}

function pedido: TTPedidos;
begin
  if xpedido = nil then
    xpedido := TTPedidos.Create;
  Result := xpedido;
end;

{===============================================================================}

initialization

finalization
  xpedido.Free;

end.
