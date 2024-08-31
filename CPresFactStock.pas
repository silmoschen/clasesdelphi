unit CPresFactStock;

interface

uses CBDT, SysUtils, DBTables, CUtiles, CListar, CIDBFM, CClienteGross,
     CArticulosGross, CLPSimpl_Gross, Classes;

type

TPrestFactStock = class
  Nropres, Fecha, Codcli, Entregar, Plazo, Orden: String;
  lintit1, lintit2, lintit3: String;
  cabpres, detpres: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  function    Buscar(xnropres: String): Boolean;
  procedure   Registrar(xnropres, xfecha, xcodcli, xentregar, xplazo, xorden, xitems, xcodart: String; xcantidad, xprecio: Real; xcantitems: Integer);
  procedure   Borrar(xnropres: String);
  procedure   getDatos(xnropres: String);
  function    Nuevo: String;
  function    setItems(xnropres: String): TStringList;

  procedure   Listar(xnropres: String; salida: char);

  function    setPresupuestos(xcodcli: String): TStringList;

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  conexiones: shortint;
  function    BuscarDet(xnropres, xitems: String): Boolean;
end;

function presupuesto: TPrestFactStock;

implementation

var
  xpresupuesto: TPrestFactStock = nil;

constructor TPrestFactStock.Create;
begin
  cabpres := datosdb.openDB('cabpres', '');
  detpres := datosdb.openDB('detpres', '');
end;

destructor TPrestFactStock.Destroy;
begin
  inherited Destroy;
end;

function  TPrestFactStock.Buscar(xnropres: String): Boolean;
// Objetivo...: Buscar una instancia
begin
  if cabpres.IndexFieldNames <> 'nropres' then cabpres.IndexFieldNames := 'nropres';
  Result := cabpres.FindKey([xnropres]);
end;

procedure TPrestFactStock.Registrar(xnropres, xfecha, xcodcli, xentregar, xplazo, xorden, xitems, xcodart: String; xcantidad, xprecio: Real; xcantitems: Integer);
// Objetivo...: Registrar Atributos
begin
  if xitems = '001' then Begin
    if Buscar(xnropres) then cabpres.Edit else cabpres.Append;
    cabpres.FieldByName('nropres').AsString  := xnropres;
    cabpres.FieldByName('fecha').AsString    := utiles.sExprFecha2000(xfecha);
    cabpres.FieldByName('codcli').AsString   := xcodcli;
    cabpres.FieldByName('entregar').AsString := xentregar;
    cabpres.FieldByName('plazo').AsString    := xplazo;
    cabpres.FieldByName('orden').AsString    := xorden;
    try
      cabpres.Post
     except
      cabpres.Cancel
    end;
  end;
  if BuscarDet(xnropres, xitems) then detpres.Edit else detpres.Append;
  detpres.FieldByName('nropres').AsString  := xnropres;
  detpres.FieldByName('items').AsString    := xitems;
  detpres.FieldByName('codart').AsString   := xcodart;
  detpres.FieldByName('cantidad').AsFloat  := xcantidad;
  detpres.FieldByName('precio').AsFloat    := xprecio;
  try
    detpres.Post
   except
    detpres.Cancel
  end;

  if xitems = utiles.sLlenarIzquierda(IntToStr(xcantitems), 3, '0') then Begin
    datosdb.tranSQL('delete from detpres where nropres = ' + '''' + xnropres + '''' + ' and items > ' + '''' + xitems + '''');
    datosdb.closeDB(cabpres); cabpres.Open;
    datosdb.closeDB(detpres); detpres.Open;
  end;
end;

procedure TPrestFactStock.Borrar(xnropres: String);
// Objetivo...: Borrar una instancia del objeto
begin
  if Buscar(xnropres) then cabpres.Delete;
  datosdb.tranSQL('delete from detpres where nropres = ' + '''' + xnropres + '''');
  datosdb.closeDB(cabpres); cabpres.Open;
  datosdb.closeDB(detpres); detpres.Open;
end;

function  TPrestFactStock.BuscarDet(xnropres, xitems: String): Boolean;
// Objetivo...: buscar atributos del detalle
begin
  if detpres.IndexFieldNames <> 'nropres;items' then detpres.IndexFieldNames := 'nropres;items';
  Result := datosdb.Buscar(detpres, 'nropres', 'items', xnropres, xitems);
end;

procedure TPrestFactStock.getDatos(xnropres: String);
// Objetivo...: recuperar una instancia del objeto
begin
  if Buscar(xnropres) then Begin
    nropres  := cabpres.FieldByName('nropres').AsString;
    fecha    := utiles.sFormatoFecha(cabpres.FieldByName('fecha').AsString);
    codcli   := cabpres.FieldByName('codcli').AsString;
    entregar := cabpres.FieldByName('entregar').AsString;
    plazo    := cabpres.FieldByName('plazo').AsString;
    orden    := cabpres.FieldByName('orden').AsString;
  end else Begin
    nropres := ''; fecha := utiles.setFechaActual; plazo := ''; entregar := ''; orden := '';
  end;
end;

function  TPrestFactStock.Nuevo: String;
// Objetivo...: Nuevo Presupuesto
begin
  if cabpres.IndexFieldNames <> 'nropres' then cabpres.IndexFieldNames := 'nropres';
  cabpres.Last;
  if Length(Trim(cabpres.FieldByName('nropres').AsString)) = 0 then Result := '1' else Begin
    cabpres.Last;
    Result := IntToStr(cabpres.FieldByName('nropres').AsInteger + 1);
  end;
end;

function  TPrestFactStock.setItems(xnropres: String): TStringList;
// Objetivo...: retornar items presupuesto
var
  l: TStringList;
begin
  l := TStringList.Create;
  if BuscarDet(xnropres, '001') then Begin
    while not detpres.Eof do Begin
      if detpres.FieldByName('nropres').AsString <> xnropres then Break;
      l.Add(detpres.FieldByName('items').AsString + detpres.FieldByName('codart').AsString + detpres.FieldByName('cantidad').AsString + ';1' + detpres.FieldByName('precio').AsString);
      detpres.Next;
    end;
  end;
  Result := l;
end;

procedure TPrestFactStock.Listar(xnropres: String; salida: char);
// Objetivo...: Imprimir presupuesto
var
  t: Real;
begin
  if Buscar(xnropres) then getDatos(xnropres) else Begin
    cabpres.Last;
    getDatos(cabpres.FieldByName('nropres').AsString);
  end;

  list.Setear(salida);
  list.NoImprimirPieDePagina;
  list.Titulo(0, 0, '', 1, 'Arial, negrita, 14');
  list.Titulo(0, 0, lintit1, 1, 'Arial, negrita, 9');
  list.Titulo(0, 0, lintit2, 1, 'Arial, normal, 9');
  list.Titulo(0, 0, lintit3, 1, 'Arial, normal, 9');
  list.Titulo(0, 0, '', 1, 'Arial, normal, 10');

  list.Linea(0, 0, 'Presupuesto: ' + nropres, 1, 'Arial, normal, 9', salida, 'N');
  list.Linea(40, list.Lineactual, 'Fecha: ' + fecha, 2, 'Arial, normal, 9', salida, 'S');
  list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');

  cliente.getDatos(codcli);
  list.Linea(0, 0, 'Cliente: ' + codcli + ' - ' + cliente.nombre, 1, 'Arial, normal, 9', salida, 'N');
  list.Linea(40, list.Lineactual, 'Dirección: ' + cliente.domicilio, 2, 'Arial, normal, 9', salida, 'N');
  list.Linea(70, list.Lineactual, 'C.U.I.T./I.V.A.: ' + cliente.nrocuit + '  ' + cliente.codpfis, 3, 'Arial, normal, 9', salida, 'S');
  list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');

  list.Linea(0, 0, 'Entregar en: ' + entregar, 1, 'Arial, normal, 9', salida, 'S');
  list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');

  list.Linea(0, 0, 'Plazo: ' + plazo, 1, 'Arial, normal, 9', salida, 'N');
  list.Linea(50, list.Lineactual, 'Orden de Compra: ' + orden, 2, 'Arial, normal, 9', salida, 'S');
  list.Linea(0, 0, '', 1, 'Arial, normal, 10', salida, 'S');

  if BuscarDet(nropres, '001') then Begin
    t := 0;
    while not detpres.Eof do Begin
      if detpres.FieldByName('nropres').AsString <> nropres then Break;
      presimples.getDatos(detpres.FieldByName('codart').AsString);
      list.Linea(0, 0, detpres.FieldByName('items').AsString, 1, 'Arial, normal, 8', salida, 'N');
      list.importe(12, list.Lineactual, '', detpres.FieldByName('cantidad').AsFloat, 2, 'Arial, normal, 8');
      list.Linea(14, list.Lineactual, detpres.FieldByName('codart').AsString, 3, 'Arial, normal, 8', salida, 'N');
      list.Linea(27, list.Lineactual, presimples.descrip, 4, 'Arial, normal, 8', salida, 'N');
      list.importe(77, list.Lineactual, '', detpres.FieldByName('precio').AsFloat, 5, 'Arial, normal, 8');
      list.importe(95, list.Lineactual, '', detpres.FieldByName('cantidad').AsFloat * detpres.FieldByName('precio').AsFloat, 6, 'Arial, normal, 8');
      list.Linea(95, list.Lineactual, '', 7, 'Arial, normal, 8', salida, 'S');
      t := t + (detpres.FieldByName('cantidad').AsFloat * detpres.FieldByName('precio').AsFloat);
      detpres.Next;
    end;
  end;

  list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'N');
  list.derecha(95, list.Lineactual, '', '-------------------', 2, 'Arial, normal, 8');
  list.Linea(95, list.Lineactual, '', 3, 'Arial, normal, 8', salida, 'S');

  list.Linea(0, 0, 'Total Presupuesto:', 1, 'Arial, negrita, 8', salida, 'N');
  list.importe(95, list.Lineactual, '', t, 2, 'Arial, negrita, 8');
  list.Linea(95, list.Lineactual, '', 3, 'Arial, negrita, 8', salida, 'S');

  list.Linea(0, 0, '', 1, 'Arial, negrita, 10', salida, 'S');
  list.Linea(0, 0, 'Pesos: ' +  utiles.xIntToLletras(StrToInt(Copy(utiles.FormatearNumero(FloatToStr(t)), 1, Length(utiles.FormatearNumero(FloatToStr(t))) - 3))) + ' con ' + Copy(utiles.FormatearNumero(FloatToStr(t)), Length(utiles.FormatearNumero(FloatToStr(t))) - 1,  2) + ' ctvos.', 1, 'Arial, negrita, 8', salida, 'S');

  list.FinList;
end;

function  TPrestFactStock.setPresupuestos(xcodcli: String): TStringList;
// Objetivo...: obtener presupuestos cliente
var
  l: TStringList;
begin
  l := TStringList.Create;
  datosdb.Filtrar(cabpres, 'codcli = ' + '''' + xcodcli + '''');
  cabpres.First;
  while not cabpres.Eof do Begin
    l.Add(cabpres.FieldByName('nropres').AsString + cabpres.FieldByName('codcli').AsString + utiles.sFormatoFecha(cabpres.FieldByName('fecha').AsString));
    cabpres.Next;
  end;
  datosdb.QuitarFiltro(cabpres);
  Result := l;
end;

procedure TPrestFactStock.conectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones = 0 then Begin
    if not cabpres.Active then cabpres.Open;
    if not detpres.Active then detpres.Open;
  end;
  Inc(conexiones);
  cliente.conectar;
  presimples.conectar;
  art.conectar;
end;

procedure TPrestFactStock.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  Dec(conexiones);
  if conexiones = 0 then Begin
    datosdb.closeDB(cabpres);
    datosdb.closeDB(detpres);
  end;
  cliente.desconectar;
  presimples.desconectar;
  art.desconectar;
end;

{===============================================================================}

function presupuesto: TPrestFactStock;
begin
  if xpresupuesto = nil then
    xpresupuesto := TPrestFactStock.Create;
  Result := xpresupuesto;
end;

{===============================================================================}

initialization

finalization
  xpresupuesto.Free;

end.
