unit CRemitos;

interface

uses SysUtils, DBTables, CIDBFM, CUtiles, CAdmNumCompr, CListar, CArtSim;

type

TTRemitos = class            // Superclase
   idc, tipo, sucursal, numero, fecha, codcli: string;
   nombre, cuit: String;
   detalle, cabecera, remitosfact: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  function    Buscar(xidc, xtipo, xsucursal, xnumero: string): boolean; overload;
  function    Buscar(xidc, xtipo, xsucursal, xnumero, xitems: string): boolean; overload;
  function    BuscarRemito(xidcf, xtipof, xsucursalf, xnumerof, xitems: string): boolean;
  procedure   Grabar(xidc, xtipo, xsucursal, xnumero, xfecha, xcodcli: string);
  procedure   GrabarItems(xitems, xcodart: string; xcantidad: real);
  procedure   GrabarRemitosFacturados(xidcf, xtipof, xsucursalf, xnumerof, xitems, xidcr, xtipor, xsucursalr, xnumeror: string);
  procedure   Borrar(xidc, xtipo, xsucursal, xnumero: string);
  procedure   BorrarRemitosFcaturados(xidc, xtipo, xsucursal, xnumero: string);
  procedure   getDatos(xidc, xtipo, xsucursal, xnumero: string);
  function    setItems: TQuery;
  procedure   ActualizarUltimoReciboImpreso(xnumero: string);
  procedure   FijarNumeroFacturacion(xidc, xtipo, xsucursal, xnumero, xidcf, xtipof, xsucursalf, xnumerof: string);
  function    setRemitos(xdesde, xhasta: string): TQuery;
  function    setDetalleRemitosClientes(xcodcli, xdf, xhf: string): TQuery;
  procedure   ListarRemitos(xdesde, xhasta, xcodcli: String; salida: Char);


  procedure   conectar;
  procedure   desconectar;
 protected
  procedure   getDatosCliente(xcodcli: String); virtual;
 private
  conexiones: shortint;
  procedure   BorrarDetalle(xidc, xtipo, xsucursal, xnumero: string);
  { Declaraciones Privadas }
end;

function remito: TTRemitos;

implementation

var
  xremito: TTRemitos = nil;

constructor TTRemitos.Create;
begin
  inherited Create;
end;

destructor TTRemitos.Destroy;
begin
  inherited Destroy;
end;

function  TTRemitos.Buscar(xidc, xtipo, xsucursal, xnumero: string): boolean;
begin
  Result := datosdb.Buscar(cabecera, 'idc', 'tipo', 'sucursal', 'numero', xidc, xtipo, xsucursal, xnumero);
end;

function  TTRemitos.Buscar(xidc, xtipo, xsucursal, xnumero, xitems: string): boolean;
begin
  Result := datosdb.Buscar(detalle, 'idc', 'tipo', 'sucursal', 'numero', 'items', xidc, xtipo, xsucursal, xnumero, xitems);
end;

function  TTRemitos.BuscarRemito(xidcf, xtipof, xsucursalf, xnumerof, xitems: string): boolean;
begin
  Result := datosdb.Buscar(remitosfact, 'idcf', 'tipof', 'sucursalf', 'numerof', 'items', xidcf, xtipof, xsucursalf, xnumerof, xitems);
end;

procedure TTRemitos.Grabar(xidc, xtipo, xsucursal, xnumero, xfecha, xcodcli: string);
begin
  if Buscar(xidc, xtipo, xsucursal, xnumero) then Begin
    BorrarDetalle(xidc, xtipo, xsucursal, xnumero);
    cabecera.Edit;
  end else cabecera.Append;
  cabecera.FieldByName('idc').AsString      := xidc;
  cabecera.FieldByName('tipo').AsString     := xtipo;
  cabecera.FieldByName('sucursal').AsString := xsucursal;
  cabecera.FieldByName('numero').AsString   := xnumero;
  cabecera.FieldByName('fecha').AsString    := utiles.sExprFecha2000(xfecha);
  cabecera.FieldByName('codcli').AsString   := xcodcli;
  try
    cabecera.Post
  except
    cabecera.Cancel
  end;
  idc := xidc; tipo := xtipo; sucursal := xsucursal; numero := xnumero;
end;

procedure TTRemitos.GrabarItems(xitems, xcodart: string; xcantidad: real);
begin
  if Buscar(idc, tipo, sucursal, numero, xitems) then detalle.Edit else detalle.Append;
  detalle.FieldByName('idc').AsString      := idc;
  detalle.FieldByName('tipo').AsString     := tipo;
  detalle.FieldByName('sucursal').AsString := sucursal;
  detalle.FieldByName('numero').AsString   := numero;
  detalle.FieldByName('items').AsString    := xitems;
  detalle.FieldByName('codart').AsString   := xcodart;
  detalle.FieldByName('cantidad').AsFloat  := xcantidad;
  try
    detalle.Post
  except
    detalle.Cancel
  end;
end;

procedure TTRemitos.Borrar(xidc, xtipo, xsucursal, xnumero: string);
begin
  if Buscar(xidc, xtipo, xsucursal, xnumero) then Begin
    cabecera.Delete;
    BorrarDetalle(xidc, xtipo, xsucursal, xnumero);
  end;
end;

procedure TTRemitos.getDatos(xidc, xtipo, xsucursal, xnumero: string);
begin
  if Buscar(xidc, xtipo, xsucursal, xnumero) then Begin
    idc      := cabecera.FieldByName('idc').AsString;
    tipo     := cabecera.FieldByName('tipo').AsString;
    sucursal := cabecera.FieldByName('sucursal').AsString;
    numero   := cabecera.FieldByName('numero').AsString;
    fecha    := utiles.sFormatoFecha(cabecera.FieldByName('fecha').AsString);
    codcli   := cabecera.FieldByName('codcli').AsString;
  end else Begin
    idc := ''; tipo := ''; sucursal := ''; numero := ''; fecha := ''; codcli := '';
  end;
end;

procedure TTRemitos.BorrarDetalle(xidc, xtipo, xsucursal, xnumero: string);
begin
  datosdb.tranSQL('DELETE FROM ' + detalle.TableName + ' WHERE idc = ' + '"' + xidc + '"' + ' AND tipo = ' + '"' + xtipo + '"' + ' AND sucursal = ' + '"' + xsucursal + '"' + ' AND numero = ' + '"' + xnumero + '"');
end;

function TTRemitos.setItems: TQuery;
// Objetivo...: devolver un set con los items del remito
begin
  Result := datosdb.tranSQL('SELECT * FROM ' + detalle.TableName + ' WHERE idc = ' + '"' + idc + '"' + ' AND tipo = ' + '"' + tipo + '"' + ' AND sucursal = ' + '"' + sucursal + '"' + ' AND numero = ' + '"' + numero + '"');
end;

procedure TTRemitos.getDatosCliente(xcodcli: String);
begin
end;

procedure TTRemitos.ActualizarUltimoReciboImpreso(xnumero: string);
// Objetivo...: Actualizar el número del último recibo impreso
begin
  administNum.ActNuemeroActualNF(xnumero);
end;

procedure TTRemitos.FijarNumeroFacturacion(xidc, xtipo, xsucursal, xnumero, xidcf, xtipof, xsucursalf, xnumerof: string);
// Objetivo...: Fijar en número de factura que le corresponde a este remito
begin
  if not datosdb.Buscar(remitosfact, 'idc', 'tipo', 'sucursal', 'numero', xidc, xtipo, xsucursal, xnumero) then Begin
    cabecera.Edit;
    cabecera.FieldByName('idcf').AsString      := xidcf;
    cabecera.FieldByName('tipof').AsString     := xtipof;
    cabecera.FieldByName('sucursalf').AsString := xsucursalf;
    cabecera.FieldByName('numerof').AsString   := xnumerof;
    try
      cabecera.Post
     except
      cabecera.Cancel
    end;
  end;
end;

function TTRemitos.setRemitos(xdesde, xhasta: string): TQuery;
// Objetivo...: Devolver un set con los remitos de ese período
begin
  Result := datosdb.tranSQL('SELECT ' + cabecera.TableName + '.codcli, ' + cabecera.TableName + '.fecha ' + ' FROM ' + cabecera.TableName + ' WHERE fecha >= ' + '"' + utiles.sExprFecha2000(xdesde) + '"' + ' AND fecha <= ' + '"' + utiles.sExprFecha2000(xhasta) + '"' + ' ORDER BY codcli, fecha');
end;

function TTRemitos.setDetalleRemitosClientes(xcodcli, xdf, xhf: string): TQuery;
// Objetivo...: Devolver un set con los remitos de ese período
begin
  Result := datosdb.tranSQL('SELECT ' + detalle.TableName + '.* , ' + cabecera.TableName + '.idc, ' + cabecera.TableName + '.tipo, ' + cabecera.TableName + '.sucursal, ' + cabecera.TableName + '.numero, ' + cabecera.TableName + '.codcli, ' + cabecera.TableName + '.fecha FROM ' + cabecera.TableName + ', ' + detalle.TableName +
                            ' WHERE ' + detalle.TableName + '.idc = ' + cabecera.TableName + '.idc ' + ' AND ' + detalle.TableName + '.tipo = ' + cabecera.TableName + '.tipo  AND ' + detalle.TableName + '.sucursal = ' + cabecera.TableName + '.sucursal AND ' + detalle.TableName + '.numero = ' + cabecera.TableName + '.numero ' +
                            ' AND codcli = ' + '"' + xcodcli + '"' + ' AND Fecha >= ' + '"' + utiles.sExprFecha2000(xdf) + '"' + ' AND Fecha <= ' + '"' + utiles.sExprFecha2000(xhf) + '"' +
                            ' ORDER BY ' + cabecera.TableName + '.numero' + ', ' + detalle.TableName + '.items');
end;

procedure TTRemitos.GrabarRemitosFacturados(xidcf, xtipof, xsucursalf, xnumerof, xitems, xidcr, xtipor, xsucursalr, xnumeror: string);
// Objetivo...: grabar detalle de remitos
begin
  if BuscarRemito(xidcf, xtipof, xsucursalf, xnumerof, xitems) then remitosfact.Edit else remitosfact.Append;
  remitosfact.FieldByName('idcf').AsString      := xidcf;
  remitosfact.FieldByName('tipof').AsString     := xtipof;
  remitosfact.FieldByName('sucursalf').AsString := xsucursalf;
  remitosfact.FieldByName('numerof').AsString   := xnumerof;
  remitosfact.FieldByName('items').AsString     := xitems;
  remitosfact.FieldByName('idcr').AsString      := xidcr;
  remitosfact.FieldByName('tipor').AsString     := xtipor;
  remitosfact.FieldByName('sucursalr').AsString := xsucursalr;
  remitosfact.FieldByName('numeror').AsString   := xnumeror;
  try
    remitosfact.Post
  except
    remitosfact.Cancel
  end;
end;

procedure TTRemitos.BorrarRemitosFcaturados(xidc, xtipo, xsucursal, xnumero: string);
begin
  datosdb.tranSQL('DELETE FROM ' + remitosfact.TableName + ' WHERE idcf = ' + '"' + xidc + '"' + ' AND tipof = ' + '"' + xtipo + '"' + ' AND sucursalf = ' + '"' + xsucursal + '"' + ' AND numerof = ' + '"' + xnumero + '"');
end;

procedure TTRemitos.ListarRemitos(xdesde, xhasta, xcodcli: String; salida: Char);
var
  idanter: String; cantidad: Integer; l: Boolean;
begin
  if salida <> 'T' then Begin
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 14');
    list.Titulo(0, 0, 'Detalle de Remitos Emitidos', 1, 'Arial, negrita, 14');
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 5');
    list.Titulo(0, 0, '      Cantidad', 1, 'Arial, cursiva, 8');
    list.Titulo(18, list.Lineactual, 'Cód. Art.              Descripción', 2, 'Arial, cursiva, 8');
    list.Titulo(0, 0, list.LineaLargoPagina(salida), 1, 'Arial, normal, 11');
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 5');
  end;

  detalle.First; cantidad := 0; idanter := '';
  while not detalle.EOF do Begin
   Buscar(detalle.FieldByName('idc').AsString, detalle.FieldByName('tipo').AsString, detalle.FieldByName('sucursal').AsString, detalle.FieldByName('numero').AsString);
   l := False;
   if Length(Trim(xcodcli)) = 0 then l := True else
     if cabecera.FieldByName('codcli').AsString = xcodcli then l := True;
   if l then Begin
    if (cabecera.FieldByName('fecha').AsString >= utiles.sExprFecha2000(xdesde)) and (cabecera.FieldByName('fecha').AsString <= utiles.sExprFecha2000(xhasta)) then Begin
      if detalle.FieldByName('numero').AsString <> idanter then Begin
        if salida <> 'T' then Begin
          if Length(Trim(idanter)) > 0 then list.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');
             getDatosCliente(cabecera.FieldByName('codcli').AsString);
             list.Linea(0, 0, 'Comprobante: ' + detalle.FieldByName('tipo').AsString + ' ' + detalle.FieldByName('sucursal').AsString + '-' + detalle.FieldByName('numero').AsString, 1, 'Arial, negrita, 8', salida, 'N');
             list.Linea(30, list.Lineactual, 'Cliente: ' + nombre + '   C.U.I.T. Nº: ' + cuit, 2, 'Arial, negrita, 8', salida, 'S');
             list.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');
             Inc(cantidad);
          end;
      end;
      art.getDatos(detalle.FieldByName('codart').AsString);
      if salida <> 'T' then Begin
        list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'N');
        list.importe(15, list.Lineactual, '', detalle.FieldByName('cantidad').AsFloat, 2, 'Arial, normal, 8');
        list.Linea(18, list.Lineactual, detalle.FieldByName('codart').AsString + '  ' + art.descrip, 3, 'Arial, normal, 8', salida, 'S');
      end;
    end;
    idanter := detalle.FieldByName('numero').AsString;
   end;
   detalle.Next;
  end;

  if salida <> 'T' then Begin
    list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'S');
    list.Linea(0, 0, 'Cantidad de Remitos Listados:    ' + IntToStr(cantidad), 1, 'Arial, negrita, 8', salida, 'N');
  end;

  list.FinList;
end;

procedure TTRemitos.conectar;
// Objetivo...: conectar tablas de persistencia
begin
  art.conectar;
  if conexiones = 0 then Begin
    if not detalle.Active  then detalle.Open;
    if not cabecera.Active then cabecera.Open;
    if not remitosfact.Active then remitosfact.Open;
  end;
  Inc(conexiones);
end;

procedure TTRemitos.desconectar;
// Objetivo...: conectar tablas de persistencia
begin
  art.desconectar;
  Dec(conexiones);
  if conexiones = 0 then Begin
    datosdb.closeDB(detalle);
    datosdb.closeDB(cabecera);
    datosdb.closeDB(remitosfact);
  end;
end;

{===============================================================================}

function remito: TTRemitos;
begin
  if xremito = nil then
    xremito := TTRemitos.Create;
  Result := xremito;
end;

{===============================================================================}

initialization

finalization
  xremito.Free;

end.
