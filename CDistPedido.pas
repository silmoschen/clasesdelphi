unit CDistPedido;

interface

uses SysUtils, CUtiles, CArtsim, CArtComp, CIDBFM, CBDT, DBTables, Cliengar, CFactVentaNormal, CListar;

type
TTDistPedidos = class(TObject)
  idc, tipo, sucursal, numero, codcli, fecha, hora, direccion, telefono: string;
  tabla: TTable;
 public
  { Declaraciones Públicas }
  constructor Create(xidc, xtipo, xsucursal, xnumero, xcodcli, xfecha, xhora, xdireccion, xtelefono: string);
  destructor  Destroy; override;

  function    Buscar(xidc, xtipo, xsucursal, xnumero: string): boolean;
  procedure   getDatos(xidc, xtipo, xsucursal, xnumero: string);
  procedure   Grabar(xidc, xtipo, xsucursal, xnumero, xcodcli, xfecha, xhora, xdireccion, xtelefono: string);
  procedure   Borrar(xidc, xtipo, xsucursal, xnumero: string);
  procedure   MarcarPedido(xidc, xtipo, xsucursal, xnumero, xtm: string);
  function    setPedidos: TQuery;
  procedure   Listar(xdf, xhf: string; salida, xtd, xdet: char);

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  conexiones: shortint;
  procedure   ListDetPedido(xidc, xtipo, xsucursal, xnumero: string; salida: char);
end;

function distpedido: TTDistPedidos;

var
  xdistpedido: TTDistPedidos;

implementation

constructor TTDistPedidos.Create(xidc, xtipo, xsucursal, xnumero, xcodcli, xfecha, xhora, xdireccion, xtelefono: string);
begin
  inherited create;
  idc       := xidc;
  tipo      := xtipo;
  sucursal  := xsucursal;
  numero    := xnumero;
  codcli    := xcodcli;
  fecha     := xfecha;
  hora      := xhora;
  direccion := xdireccion;
  telefono  := xtelefono;

  tabla     := datosdb.openDB('distpedi', 'Idc;Tipo;Sucursal;Numero');
end;

destructor  TTDistPedidos.Destroy;
begin
  inherited destroy;
end;

function    TTDistPedidos.Buscar(xidc, xtipo, xsucursal, xnumero: string): boolean;
// Objetivo...: Buscar una instancia
begin
  if datosdb.Buscar(tabla, 'idc', 'tipo', 'sucursal', 'numero', xidc, xtipo, xsucursal, xnumero) then Result := True else Result := False;
end;

procedure   TTDistPedidos.getDatos(xidc, xtipo, xsucursal, xnumero: string);
// Objetivo...: Cargar los atributos de una instancia
begin
  tabla.Refresh;
  if Buscar(xidc, xtipo, xsucursal, xnumero) then
    begin
      idc       := tabla.FieldByName('idc').AsString;
      tipo      := tabla.FieldByName('tipo').AsString;
      sucursal  := tabla.FieldByName('sucursal').AsString;
      numero    := tabla.FieldByName('numero').AsString;
      codcli    := tabla.FieldByName('codcli').AsString;
      fecha     := utiles.sFormatoFecha(tabla.FieldByName('fecha').AsString);
      hora      := tabla.FieldByName('hora').AsString;
      direccion := tabla.FieldByName('direccion').AsString;
      telefono  := tabla.FieldByName('telefono').AsString;
    end
  else
    begin
      idc := ''; tipo := ''; sucursal := ''; numero := ''; codcli := ''; fecha := ''; hora := ''; direccion := ''; telefono := '';
    end;
end;

procedure   TTDistPedidos.Grabar(xidc, xtipo, xsucursal, xnumero, xcodcli, xfecha, xhora, xdireccion, xtelefono: string);
// Objetivo...: Grabar una instancia en el objeto
begin
  if Buscar(xidc, xtipo, xsucursal, xnumero) then tabla.Edit else tabla.Append;
  tabla.FieldByName('idc').AsString       := xidc;
  tabla.FieldByName('tipo').AsString      := xtipo;
  tabla.FieldByName('sucursal').AsString  := xsucursal;
  tabla.FieldByName('numero').AsString    := xnumero;
  tabla.FieldByName('codcli').AsString    := xcodcli;
  tabla.FieldByName('fecha').AsString     := utiles.sExprFecha(xfecha);
  tabla.FieldByName('hora').AsString      := xhora;
  tabla.FieldByName('direccion').AsString := xdireccion;
  tabla.FieldByName('telefono').AsString  := xtelefono;
  try
    tabla.Post;
  except
    tabla.Cancel;
  end;
end;

procedure   TTDistPedidos.Borrar(xidc, xtipo, xsucursal, xnumero: string);
// Objetivo...: Borrar una instancia en el objeto
begin
  if Buscar(xidc, xtipo, xsucursal, xnumero) then
    begin
      tabla.Delete;
      getDatos(tabla.FieldByName('idc').AsString, tabla.FieldByName('tipo').AsString, tabla.FieldByName('sucursal').AsString, tabla.FieldByName('numero').AsString);
    end;
end;

function TTDistPedidos.setPedidos: TQuery;
// Objetivo...: devolver un set con los pedidos
begin
  Result := datosdb.tranSQL('SELECT distpedi.idc, distpedi.tipo, distpedi.sucursal, distpedi.numero, distpedi.fecha, distpedi.hora, distpedi.direccion, distpedi.telefono, distpedi.codcli, clientes.nombre, distpedi.estado ' +
                            ' FROM distpedi, clientes WHERE distpedi.codcli = clientes.codcli ORDER BY fecha');
end;

procedure   TTDistPedidos.MarcarPedido(xidc, xtipo, xsucursal, xnumero, xtm: string);
// Objetivo...: Marcar/Desmarcar Pedido despachado
begin
  if Buscar(xidc, xtipo, xsucursal, xnumero) then
    begin
      tabla.Edit;
      tabla.FieldByName('estado').AsString := xtm;
      try
        tabla.Post;
      except
        tabla.Cancel;
      end;
    end;
end;

procedure TTDistPedidos.Listar(xdf, xhf: string; salida, xtd, xdet: char);
// Objetivo...: Listar Pedidos
var
  c: string; t: boolean;
begin
  clientegar.conectar; c:= '';
  if xdet = 'S' then factventa.conectar;

  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Informe de Despacho de Pedidos', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Fecha/Hora', 1, 'Arial, cursiva, 8');
  List.Titulo(14, list.Lineactual, 'Comprobante', 2, 'Arial, cursiva, 8');
  List.Titulo(31, list.Lineactual, 'Cliente', 3, 'Arial, cursiva, 8');
  List.Titulo(57, list.Lineactual, 'Dirección', 4, 'Arial, cursiva, 8');
  List.Titulo(85, list.Lineactual, 'Teléfono', 5, 'Arial, cursiva, 8');
  List.Titulo(98, list.Lineactual, 'Est.', 6, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  tabla.First;
  while not tabla.EOF do
    begin
      t := False;
      if xtd = 'T' then
        if tabla.FieldByName('estado').AsString <> 'D' then t := True;
      if xtd = 'D' then
       if tabla.FieldByName('estado').AsString = 'D' then t := True;
        if ((tabla.FieldByName('fecha').AsString >= utiles.sExprFecha(xdf)) and (tabla.FieldByName('fecha').AsString <= utiles.sExprFecha(xhf))) and (t) then
          begin
            clientegar.getDatos(tabla.FieldByName('codcli').AsString);
            c := clientegar.Nombre;
            list.Linea(0, 0, utiles.sFormatoFecha(tabla.FieldByName('fecha').AsString) + '  ' + tabla.FieldByName('hora').AsString, 1, 'Arial, normal, 8', salida, 'N');
            list.Linea(14, list.lineactual, tabla.FieldByName('idc').AsString, 2, 'Arial, normal, 8', salida, 'N');
            list.Linea(17, list.lineactual, tabla.FieldByName('tipo').AsString + '  ' + tabla.FieldByName('sucursal').AsString + ' ' + tabla.FieldByName('numero').AsString, 3, 'Arial, normal, 8', salida, 'N');
            list.Linea(31, list.lineactual, c, 4, 'Arial, normal, 8', salida, 'N');
            list.Linea(57, list.lineactual, tabla.FieldByName('direccion').AsString, 5, 'Arial, normal, 8', salida, 'N');
            list.Linea(85, list.lineactual, tabla.FieldByName('telefono').AsString, 6, 'Arial, normal, 8', salida, 'N');
            list.Linea(98, list.lineactual, tabla.FieldByName('estado').AsString, 7, 'Arial, normal, 8', salida, 'S');
            if xdet = 'S' then ListDetPedido(tabla.FieldByName('idc').AsString, tabla.FieldByName('tipo').AsString, tabla.FieldByName('sucursal').AsString, tabla.FieldByName('numero').AsString, salida);          end;
      tabla.Next;
    end;
  clientegar.desconectar;
  if xdet = 'S' then factventa.desconectar;

  List.FinList;
end;

procedure   TTDistPedidos.ListDetPedido(xidc, xtipo, xsucursal, xnumero: string; salida: char);
// Objetivo...: desconectar tabla de persistencia
var
  r: TQuery;
  a: string;
begin
  List.Linea(0, 0, ' ', 1, 'Arial, negrita, 8', salida, 'S');
  r := factventa.setDetalle(xidc, xtipo, xsucursal, xnumero);
  r.Open;
  while not r.EOF do
    begin
      if r.FieldByName('idart').AsString = 'S' then
        begin
          art.getDatos(r.FieldByName('codart').AsString);
          a := art.Descrip;
        end;
      if r.FieldByName('idart').AsString = 'C' then
        begin
          artcomp.getDatos(r.FieldByName('codart').AsString);
          a := artcomp.getDescrip;
        end;

      List.Linea(0, list.lineactual, '   ', 1, 'Arial, negrita, 8', salida, 'N');
      List.importe(15, list.lineactual, '', r.FieldByName('cantidad').AsFloat, 2, 'Arial, negrita, 8');
      List.Linea(30, list.lineactual, a, 3, 'Arial, negrita, 8', salida, 'S');

      r.Next;
    end;
  r.Close;
  List.Linea(0, 0, '   ', 1, 'Arial, cursiva, 8', salida, 'S');
end;

procedure   TTDistPedidos.conectar;
// Objetivo...: conectar tabla de persistencia
begin
  if conexiones = 0 then
    if not tabla.Active then tabla.Open;
  Inc(conexiones);
end;

procedure   TTDistPedidos.desconectar;
// Objetivo...: desconectar tabla de persistencia
begin
  Dec(conexiones);
  if conexiones = 0 then datosdb.closeDB(tabla);
end;

{===============================================================================}

function distpedido: TTDistPedidos;
begin
  if xdistpedido = nil then
    xdistpedido := TTDistPedidos.Create('', '', '', '' , '', '', '', '', '');
  Result := xdistpedido;
end;

{===============================================================================}

initialization

finalization
  xdistpedido.Free;

end.
