unit CEstadiaMagni;

interface

uses CPasajerosMagni, CHabitacionesMagni, CBDT, SysUtils, DBTables, CUtiles, CListar,
     CItemsFacturacionMagni, CCNetos, CComregi, CIDBFM, Classes, CTarjetasCredito_Gross,
     CBancos, CTarifasMagni, CUsuario;

type

TTEstadia = class
   Nroregistro, Idpasajero, FechaIngreso, FechaEgreso, Procedencia, Destino, Profesion, VehiculoMarca, VehiculoPatente, Observaciones, Acompaniante, HoraIngreso, HoraEgreso: String;
   Efectivo, Cheque, TCredito, Descuento, Precio: Real;
   ExisteRegistro: Boolean;
   cabestadia, detfact, cheques, tarjetas, distribucion, acompaniantes, dettarifas: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  function    Buscar(xnroregistro: String): Boolean;
  procedure   Registrar(xnroregistro, xidpasajero, xfechaingreso, xprocedencia, xdestino, xprofesion, xvehiculomarca, xvehiculopatente, xobservaciones, xacompaniante, xhoraIngreso, xusuario: String; xprecio: Real);
  procedure   getDatos(xnroregistro: String);
  procedure   Borrar(xnroregistro: String);
  function    Nuevo: String;
  function    verificarSiSeRetiro(xnroregistro: String): Boolean;

  function    BuscarItemsFact(xnroregistro, xorden: String): Boolean;
  procedure   RegistrarItemsFact(xnroregistro, xorden, xitems, xdescrip, xfecha, xhora: String; xcantidad, xmonto: Real; xcantitems: Integer);
  function    setItemsFact(xnroregistro: String): TStringList;
  procedure   BorrarItemsFact(xnroregistro: String);

  function    setIngresos(xfecha: String): TStringList;
  function    setPasajerosEnEstadia: TStringList;

  procedure   RegistrarEgreso(xnroregistro, xfecha, xhoraegreso: String);
  procedure   AnularEgreso(xnroregistro: String);

  { Informes }
  procedure   ListarTransacciones(xdfecha, xhfecha, xusuario: String; salida: char);
  procedure   ListarDetalleMovimientoPasajeros(xdfecha, xhfecha: String; salida: char);
  procedure   ListarDetalleCobros(xdfecha, xhfecha: String; salida: char);
  procedure   ListarDetalleEstadiaPasajero(xnroregistro: String; salida: char);

  { Distribución de Montos }
  function    BuscarDistribucion(xnroregistro: String): Boolean;
  procedure   RegistrarDistribucion(xnroregistro, xfecha: String; xefectivo, xcheque, xtarjeta, xdescuento: Real);
  procedure   BorrarDistribucion(xnroregistro: String);

  { Control de Cheques }
  function    BuscarCheque(xnroregistro, xitems: String): Boolean;
  procedure   RegistrarCheques(xnroregistro, xitems, xnrocheque, xfecha, xcodbco, xsucursal, xfecobro: String; xmonto: Real; xcantitems: Integer);
  procedure   BorrarCheques(xnroregistro: String);
  function    setCheques(xnroregistro: String): TStringList;

  { Control de Tarjetas }
  function    BuscarTarjeta(xnroregistro, xitems: String): Boolean;
  procedure   RegistrarTarjeta(xnroregistro, xitems, xnrotarjeta, xfecha, xidtarjeta: String; xmonto: Real; xcantitems: Integer);
  procedure   BorrarTarjetas(xnroregistro: String);

  { Acompaniantes }
  function    BuscarAcompaniante(xnroregistro, xidpasajero, xitems: String): Boolean;
  procedure   RegistrarAcompaniante(xnroregistro, xidpasajero, xitems, xnrodoc, xnombre: String; xcantitems: Integer);
  procedure   BorrarAcompaniantes(xnroregistro, xidpasajero: String);
  function    setAcompaniantes(xnroregistro, xidpasajero: String): TStringList;

  { Detalle de Tarifas }
  function    BuscarTarifa(xnroregistro, xtipoitems, xitems: String): Boolean;
  procedure   RegistrarTarifa(xnroregistro, xtipoitems, xitems, xiditems: String; xmonto: Real);
  procedure   BorrarTarifa(xnroregistro: String);
  procedure   AjustarItems(xnroregistro, xtipoitems: String; xcantitems: Integer);
  function    setTarifas(xnroregistro: String): TStringList;
  function    setNroHabitacion(xnroregistro: String): String;
  function    setHabitacion(xnroregistro: String): String;
  function    setTarifasPasajeroDiarias(xnroregistro: String): Real;
  function    setTarifasPasajeroIndividuales(xnroregistro: String): Real;

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  conexiones: shortint;
  totales: array[1..6] of Real;
  idanter: String;
  procedure   ListDetalleCheques(xnroregistro: String; salida: char);
  procedure   ListDetalleTarjetas(xnroregistro: String; salida: char);
  procedure   ListarDetalleEstadia(xnroregistro: String; salida: char);
  procedure   LineaDetalleCobros(xidanter: String; salida: char);
end;

function estadia: TTEstadia;

implementation

var
  xestadia: TTEstadia = nil;

constructor TTEstadia.Create;
begin
  cabestadia    := datosdb.openDB('cabestadia', '');
  detfact       := datosdb.openDB('detfact', '');
  cheques       := datosdb.openDB('distribucion_cheques', '');
  tarjetas      := datosdb.openDB('distribucion_tarjetas', '');
  distribucion  := datosdb.openDB('distribucion_montos', '');
  acompaniantes := datosdb.openDB('acompaniantes', '');
  dettarifas    := datosdb.openDB('detalle_tarifas', '');
end;

destructor TTEstadia.Destroy;
begin
  inherited Destroy;
end;

function  TTEstadia.Buscar(xnroregistro: String): Boolean;
// Objetivo...: Buscar una instancia del objeto
Begin
  if cabestadia.IndexFieldNames <> 'nroregistro' then cabestadia.IndexFieldNames := 'nroregistro';
  ExisteRegistro := cabestadia.FindKey([xnroregistro]);
  Result         := ExisteRegistro;
end;

procedure TTEstadia.Registrar(xnroregistro, xidpasajero, xfechaingreso, xprocedencia, xdestino, xprofesion, xvehiculomarca, xvehiculopatente, xobservaciones, xacompaniante, xhoraingreso, xusuario: String; xprecio: Real);
// Objetivo...: Buscar una instancia del objeto
Begin
  if Buscar(xnroregistro) then cabestadia.Edit else cabestadia.Append;
  cabestadia.FieldByName('nroregistro').AsString     := xnroregistro;
  cabestadia.FieldByName('idpasajero').AsString      := xidpasajero;
  cabestadia.FieldByName('fechaingreso').AsString    := utiles.sExprFecha2000(xfechaingreso);
  cabestadia.FieldByName('procedencia').AsString     := xprocedencia;
  cabestadia.FieldByName('destino').AsString         := xdestino;
  cabestadia.FieldByName('profesion').AsString       := xprofesion;
  cabestadia.FieldByName('vehiculomarca').AsString   := xvehiculomarca;
  cabestadia.FieldByName('vehiculopatente').AsString := xvehiculopatente;
  cabestadia.FieldByName('observaciones').AsString   := xobservaciones;
  cabestadia.FieldByName('acompaniante').AsString    := xacompaniante;
  cabestadia.FieldByName('horaingreso').AsString     := xhoraingreso;
  cabestadia.FieldByName('usuario').AsString         := xusuario;
  cabestadia.FieldByName('precio').AsFloat           := xprecio;
  try
    cabestadia.Post
   except
    cabestadia.Cancel
  end;
  datosdb.closeDB(cabestadia); cabestadia.Open;
end;

procedure TTEstadia.getDatos(xnroregistro: String);
// Objetivo...: Recuperar una instancia del objeto
Begin
  if Buscar(xnroregistro) then Begin
    nroregistro     := cabestadia.FieldByName('nroregistro').AsString;
    idpasajero      := cabestadia.FieldByName('idpasajero').AsString;
    fechaingreso    := utiles.sFormatoFecha(cabestadia.FieldByName('fechaingreso').AsString);
    fechaegreso     := utiles.sFormatoFecha(cabestadia.FieldByName('fechaegreso').AsString);
    procedencia     := cabestadia.FieldByName('procedencia').AsString;
    destino         := cabestadia.FieldByName('destino').AsString;
    profesion       := cabestadia.FieldByName('profesion').AsString;
    vehiculomarca   := cabestadia.FieldByName('vehiculomarca').AsString;
    vehiculopatente := cabestadia.FieldByName('vehiculopatente').AsString;
    observaciones   := cabestadia.FieldByName('observaciones').AsString;
    acompaniante    := cabestadia.FieldByName('acompaniante').AsString;
    Precio          := cabestadia.FieldByName('precio').AsFloat;
  end else Begin
    nroregistro := ''; idpasajero := ''; fechaingreso := ''; procedencia := ''; destino := ''; profesion := ''; vehiculomarca := ''; vehiculopatente := ''; observaciones := ''; acompaniante := ''; Precio := 0; fechaegreso := '';
  end;
end;

procedure TTEstadia.Borrar(xnroregistro: String);
// Objetivo...: Borrar una instancia del objeto
Begin
  if Buscar(xnroregistro) then Begin
    BorrarItemsFact(xnroregistro);
    BorrarAcompaniantes(xnroregistro, cabestadia.FieldByName('idpasajero').AsString);
    BorrarTarifa(xnroregistro);
    cabestadia.Delete;
    datosdb.closeDB(cabestadia); cabestadia.Open;
  end;
end;

function  TTEstadia.Nuevo: String;
// Objetivo...: Recuperar una instancia del objeto
Begin
  cabestadia.Last;
  if Length(Trim(cabestadia.FieldByName('nroregistro').AsString)) = 0 then Result := '1' else Result := IntToStr(cabestadia.FieldByName('nroregistro').AsInteger + 1);
end;

function  TTEstadia.verificarSiSeRetiro(xnroregistro: String): Boolean;
// Objetivo...: Averiguar el estado del Pasajero
Begin
  Result := False;
  if Buscar(xnroregistro) then
    if Length(Trim(cabestadia.FieldByName('fechaegreso').AsString)) = 8 then Result := True else Result := False;
end;

function  TTEstadia.setIngresos(xfecha: String): TStringList;
// Objetivo...: devolver una lista
var
  l: TStringList;
Begin
  l := TStringList.Create;
  cabestadia.IndexFieldNames := 'FechaIngreso';
  if cabestadia.FindKey([utiles.sExprFecha2000(xfecha)]) then Begin
    while not cabestadia.Eof do Begin
      if cabestadia.FieldByName('fechaingreso').AsString <> utiles.sExprFecha2000(xfecha) then Break;
      l.Add(cabestadia.FieldByName('nroregistro').AsString + utiles.sFormatoFecha(cabestadia.FieldByName('fechaingreso').AsString) + cabestadia.FieldByName('idpasajero').AsString + cabestadia.FieldByName('procedencia').AsString + ';1' + cabestadia.FieldByName('destino').AsString);
      cabestadia.Next;
    end;
  end;
  Result := l;
end;

function  TTEstadia.setPasajerosEnEstadia: TStringList;
// Objetivo...: devolver una lista
var
  l: TStringList;
Begin
  l := TStringList.Create;
  cabestadia.IndexFieldNames := 'FechaIngreso';
  datosdb.Filtrar(cabestadia, 'fechaegreso = ' + '''' + '''');
  while not cabestadia.Eof do Begin
    l.Add(cabestadia.FieldByName('nroregistro').AsString + utiles.sFormatoFecha(cabestadia.FieldByName('fechaingreso').AsString) + cabestadia.FieldByName('idpasajero').AsString);
    cabestadia.Next;
  end;
  datosdb.QuitarFiltro(cabestadia);
  Result := l;
end;

function TTEstadia.BuscarItemsFact(xnroregistro, xorden: String): Boolean;
// Objetivo...: Listar Items Facturado
Begin
  detfact.IndexFieldNames := 'Nroregistro;Orden';
  Result := datosdb.Buscar(detfact, 'Nroregistro', 'Orden', xnroregistro, xorden);
end;


procedure TTEstadia.RegistrarItemsFact(xnroregistro, xorden, xitems, xdescrip, xfecha, xhora: String; xcantidad, xmonto: Real; xcantitems: Integer);
// Objetivo...: registrar items facturado
Begin
  if BuscarItemsFact(xnroregistro, xorden) then detfact.Edit else detfact.Append;
  detfact.FieldByName('nroregistro').AsString := xnroregistro;
  detfact.FieldByName('orden').AsString       := xorden;
  detfact.FieldByName('items').AsString       := xitems;
  detfact.FieldByName('descrip').AsString     := xdescrip;
  detfact.FieldByName('fecha').AsString       := utiles.sExprFecha2000(xfecha);
  detfact.FieldByName('hora').AsString        := xhora;
  detfact.FieldByName('cantidad').AsFloat     := xcantidad;
  detfact.FieldByName('monto').AsFloat        := xmonto;
  try
    detfact.Post
   except
    detfact.Cancel
  end;
  if xorden = utiles.sLlenarIzquierda(IntToStr(xcantitems), 3, '0') then Begin
    datosdb.tranSQL('delete from detfact where nroregistro = ' + '''' + xnroregistro + '''' + ' and orden > ' + '''' + xorden + '''');
    datosdb.refrescar(detfact); detfact.Open;
  end;
end;

function  TTEstadia.setItemsFact(xnroregistro: String): TStringList;
// Objetivo...: recuperar los items Facturados
var
  l: TStringList;
begin
  l := TStringList.Create;
  if BuscarItemsFact(xnroregistro, '001') then Begin
    while not detfact.Eof do Begin
      if detfact.FieldByName('nroregistro').AsString <> xnroregistro then Break;
      l.Add(detfact.FieldByName('orden').AsString + detfact.FieldByName('items').AsString + utiles.sFormatoFecha(detfact.FieldByName('fecha').AsString) + detfact.FieldByName('hora').AsString + detfact.FieldByName('descrip').AsString + ';1' + detfact.FieldByName('cantidad').AsString + ';2' + detfact.FieldByName('monto').AsString);
      detfact.Next;
    end;
  end;
  Result := l;
end;

procedure TTEstadia.BorrarItemsFact(xnroregistro: String);
// Objetivo...: Borrar Items Facturados
Begin
  datosdb.tranSQL('delete from detfact where nroregistro = ' + '''' + xnroregistro + '''');
  datosdb.refrescar(detfact); detfact.Open;
end;

procedure TTEstadia.RegistrarEgreso(xnroregistro, xfecha, xhoraegreso: String);
// Objetivo...: Registrar Egreso
Begin
  if Buscar(xnroregistro) then Begin
    cabestadia.Edit;
    cabestadia.FieldByName('fechaegreso').AsString := utiles.sExprFecha2000(xfecha);
    cabestadia.FieldByName('horaegreso').AsString  := xhoraegreso;
    try
      cabestadia.Post
     except
      cabestadia.Cancel
    end;
    datosdb.closeDB(cabestadia); cabestadia.Open;

    if BuscarTarifa(xnroregistro, 'H', '001') then habitacion.DesocuparHabitacion(dettarifas.FieldByName('iditems').AsString);
  end;
end;

procedure TTEstadia.AnularEgreso(xnroregistro: String);
// Objetivo...: Registrar Egreso
Begin
  if Buscar(xnroregistro) then Begin
    cabestadia.Edit;
    cabestadia.FieldByName('fechaegreso').AsString := '';
    try
      cabestadia.Post
     except
      cabestadia.Cancel
    end;
    datosdb.closeDB(cabestadia); cabestadia.Open;

    datosdb.Filtrar(dettarifas, 'nroregistro = ' + '''' + xnroregistro + '''');
    dettarifas.First;
    while not dettarifas.Eof do Begin
      if dettarifas.FieldByName('tipoitems').AsString = 'H' then
        habitacion.OcuparHabitacion(dettarifas.FieldByName('iditems').AsString, xnroregistro);
      dettarifas.Next;
    end;
    datosdb.QuitarFiltro(dettarifas);
    BorrarDistribucion(xnroregistro);
    BorrarTarjetas(xnroregistro);
    BorrarCheques(xnroregistro);
  end;
end;

procedure TTEstadia.ListarTransacciones(xdfecha, xhfecha, xusuario: String; salida: char);
// Objetivo...: Listar Nómina de Ingresos
var
  l: Boolean;
  i: Integer;
  lista: TStringList;
begin
  lista := TStringList.Create;
  list.setear(salida);
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Control de Transacciones - Lapso: ' + xdfecha + ' - ' + xhfecha, 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Fecha / Hora', 1, 'Arial, cursiva, 8');
  List.Titulo(17, List.lineactual, 'Nombre del Pasajero', 2, 'Arial, cursiva, 8');
  List.Titulo(45, List.lineactual, 'Dirección', 3, 'Arial, cursiva, 8');
  List.Titulo(65, List.lineactual, 'Procedencia', 4, 'Arial, cursiva, 8');
  List.Titulo(85, List.lineactual, 'Destino', 5, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  if xusuario <> '' then List.Titulo(0, 0, 'Usuario: ' + xusuario, 1, 'Arial, normal, 9') else
    List.Titulo(0, 0, 'Usuario: Administrador', 1, 'Arial, normal, 9');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  list.Linea(0, 0, '***  Ingreso de Pasajeros  ***', 1, 'Arial, negrita, 9', salida, 'S');
  list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');

  datosdb.Filtrar(cabestadia, 'fechaingreso >= ' + '''' + utiles.sExprFecha2000(xdfecha) + '''' + ' and fechaingreso <= ' + '''' + utiles.sExprFecha2000(xhfecha) + '''');
  cabestadia.First; l := False; totales[1] := 0; totales[2] := 0; totales [3] := 0; totales[4] := 0; totales[5] := 0; totales[6] := 0;
  while not cabestadia.Eof do Begin
    if (cabestadia.FieldByName('usuario').AsString = xusuario) or (xusuario = '') then Begin
      pasajero.getDatos(cabestadia.FieldByName('idpasajero').AsString);
      list.Linea(0, 0, utiles.sFormatoFecha(cabestadia.FieldByName('fechaingreso').AsString) + ' - ' + cabestadia.FieldByName('horaingreso').AsString, 1, 'Arial, normal, 8', salida, 'N');
      list.Linea(17, list.Lineactual, pasajero.Nombre, 2, 'Arial, normal, 8', salida, 'N');
      list.Linea(45, list.Lineactual, pasajero.domicilio, 3, 'Arial, normal, 8', salida, 'N');
      list.Linea(65, list.Lineactual, cabestadia.FieldByName('procedencia').AsString, 4, 'Arial, normal, 8', salida, 'N');
      list.Linea(85, list.Lineactual, cabestadia.FieldByName('destino').AsString, 5, 'Arial, normal, 8', salida, 'S');
      totales[1] := totales[1] + 1;
      l := True;
    end;
    cabestadia.Next;
  end;
  datosdb.QuitarFiltro(cabestadia);

  if not l then Begin
    list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
    list.Linea(0, 0, 'No se Registraron Operaciones', 1, 'Arial, normal, 9', salida, 'S');
  end;

  list.Linea(0, 0, '', 1, 'Arial, negrita, 10', salida, 'S');
  list.Linea(0, 0, '***  Egreso de Pasajeros  ***', 1, 'Arial, negrita, 9', salida, 'S');
  list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');

  datosdb.Filtrar(cabestadia, 'fechaegreso >= ' + '''' + utiles.sExprFecha2000(xdfecha) + '''' + ' and fechaegreso <= ' + '''' + utiles.sExprFecha2000(xhfecha) + '''');
  cabestadia.First; l := False;
  while not cabestadia.Eof do Begin
    if (cabestadia.FieldByName('usuario').AsString = xusuario) or (xusuario = '') then Begin
      pasajero.getDatos(cabestadia.FieldByName('idpasajero').AsString);
      list.Linea(0, 0, utiles.sFormatoFecha(cabestadia.FieldByName('fechaegreso').AsString) + ' - ' + cabestadia.FieldByName('horaegreso').AsString, 1, 'Arial, normal, 8', salida, 'N');
      list.Linea(17, list.Lineactual, pasajero.Nombre, 2, 'Arial, normal, 8', salida, 'N');
      list.Linea(45, list.Lineactual, pasajero.domicilio, 3, 'Arial, normal, 8', salida, 'N');
      list.Linea(65, list.Lineactual, cabestadia.FieldByName('procedencia').AsString, 4, 'Arial, normal, 8', salida, 'N');
      list.Linea(85, list.Lineactual, cabestadia.FieldByName('destino').AsString, 5, 'Arial, normal, 8', salida, 'S');
      totales[2] := totales[2] + 1;
      if BuscarDistribucion(cabestadia.FieldByName('nroregistro').AsString) then Begin
        totales[3] := totales[3] + distribucion.FieldByName('efectivo').AsFloat;
        totales[4] := totales[4] + distribucion.FieldByName('cheque').AsFloat;
        totales[5] := totales[5] + distribucion.FieldByName('tarjeta').AsFloat;
        totales[6] := totales[6] + distribucion.FieldByName('descuento').AsFloat;
      end;
      lista.Add(cabestadia.FieldByName('nroregistro').AsString);   // Para control de tarjetas / cheques
      l := True;
    end;
    cabestadia.Next;
  end;
  datosdb.QuitarFiltro(cabestadia);

  if not l then Begin
    list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
    list.Linea(0, 0, 'No se Registraron Operaciones', 1, 'Arial, normal, 9', salida, 'S');
  end;

  list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
  list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'S');
  list.Linea(0, 0, 'Cantidad de Ingresos:      ' + FloatToStr(totales[1]), 1, 'Arial, negrita, 9', salida, 'N');
  list.Linea(40, list.Lineactual, 'Cantidad de Egresos:      ' + FloatToStr(totales[2]), 2, 'Arial, negrita, 9', salida, 'S');

  list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
  list.Linea(0, 0, 'Recaudación / Efectivo:', 1, 'Arial, negrita, 8', salida, 'N');
  list.importe(30, list.Lineactual, '', totales[3], 2, 'Arial, negrita, 8');
  list.Linea(35, list.Lineactual, 'Cheques:', 3, 'Arial, negrita, 8', salida, 'N');
  list.importe(56, list.Lineactual, '', totales[4], 4, 'Arial, negrita, 8');
  list.Linea(58, list.Lineactual, 'Tarjetas:', 5, 'Arial, negrita, 8', salida, 'N');
  list.importe(76, list.Lineactual, '', totales[5], 6, 'Arial, negrita, 8');
  list.Linea(78, list.Lineactual, 'Descuentos:', 7, 'Arial, negrita, 8', salida, 'N');
  list.importe(96, list.Lineactual, '', totales[6], 8, 'Arial, negrita, 8');

  list.Linea(96, list.Lineactual, '', 9, 'Arial, negrita, 8', salida, 'S');

  list.Linea(0, 0, 'Total Recaudación:', 1, 'Arial, negrita, 9', salida, 'N');
  list.importe(35, list.Lineactual, '', (totales[3] + totales[4] + totales[5]) - totales[6], 2, 'Arial, negrita, 9');

  list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
  list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');

  if totales[4] > 0 then Begin  //Control de Cheques
    l := False;
    For i := 1 to lista.Count do Begin
      if BuscarCheque(lista.Strings[i-1], '001') then Begin
        if not l then Begin
          list.Linea(0, 0, '  ***  Detalle de Cheques', 1, 'Arial, negrita, 8', salida, 'S');
          list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
          list.Linea(0, 0, 'Nro.Cheque', 1, 'Arial, normal, 7', salida, 'N');
          list.Linea(9, list.Lineactual, 'Fecha', 2, 'Arial, normal, 7', salida, 'N');
          list.Linea(20, list.Lineactual, 'Cobro', 3, 'Arial, normal, 7', salida, 'N');
          list.Linea(35, list.Lineactual, 'Entidad Bancaria', 4, 'Arial, normal, 7', salida, 'N');
          list.Linea(78, list.Lineactual, 'Monto', 5, 'Arial, normal, 7', salida, 'N');
          list.Linea(85, list.Lineactual, 'Sucursal', 6, 'Arial, normal, 7', salida, 'S');
          list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
          l := True;
        end;

        while not cheques.Eof do Begin
          if cheques.FieldByName('nroregistro').AsString <> lista.Strings[i-1] then Break;
          entbcos.getDatos(cheques.FieldByName('codbco').AsString);
          list.Linea(0, 0, cheques.FieldByName('nrocheque').AsString, 1, 'Arial, normal, 7', salida, 'N');
          list.Linea(9, list.Lineactual, utiles.sFormatoFecha(cheques.FieldByName('fecha').AsString), 2, 'Arial, normal, 7', salida, 'N');
          list.Linea(20, list.Lineactual, utiles.sFormatoFecha(cheques.FieldByName('fecobro').AsString), 3, 'Arial, normal, 7', salida, 'N');
          list.Linea(35, list.Lineactual, entbcos.descrip, 4, 'Arial, normal, 7', salida, 'N');
          list.importe(82, list.Lineactual, '', cheques.FieldByName('monto').AsFloat, 5, 'Arial, normal, 7');
          list.Linea(85, list.Lineactual, cheques.FieldByName('sucursal').AsString, 6, 'Arial, normal, 7', salida, 'S');
          cheques.Next;
        end;
      end;
    end;
  end;

  if totales[5] > 0 then Begin  //Control de Tarjetas
    list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'S');
    l := False;
    For i := 1 to lista.Count do Begin
      if BuscarTarjeta(lista.Strings[i-1], '001') then Begin
        if not l then Begin
          list.Linea(0, 0, '  ***  Detalle de Tarjetas', 1, 'Arial, negrita, 8', salida, 'S');
          list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
          list.Linea(0, 0, 'Nro.Tarjeta', 1, 'Arial, normal, 7', salida, 'N');
          list.Linea(9, list.Lineactual, 'Fecha', 2, 'Arial, normal, 7', salida, 'N');
          list.Linea(20, list.Lineactual, 'Tarjeta', 3, 'Arial, normal, 7', salida, 'N');
          list.Linea(78, list.Lineactual, 'Monto', 4, 'Arial, normal, 7', salida, 'S');
          list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
          l := True;
        end;

        while not tarjetas.Eof do Begin
          if tarjetas.FieldByName('nroregistro').AsString <> lista.Strings[i-1] then Break;
          tarjeta.getDatos(tarjetas.FieldByName('idtarjeta').AsString);
          list.Linea(0, 0, tarjetas.FieldByName('nrotarjeta').AsString, 1, 'Arial, normal, 7', salida, 'N');
          list.Linea(9, list.Lineactual, utiles.sFormatoFecha(tarjetas.FieldByName('fecha').AsString), 2, 'Arial, normal, 7', salida, 'N');
          list.Linea(20, list.Lineactual, tarjeta.Tarjeta, 3, 'Arial, normal, 7', salida, 'N');
          list.importe(82, list.Lineactual, '', tarjetas.FieldByName('monto').AsFloat, 4, 'Arial, normal, 7');
          list.Linea(85, list.Lineactual, '', 5, 'Arial, normal, 7', salida, 'S');
          tarjetas.Next;
        end;
      end;
    end;
  end;

  list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');

  list.Linea(0, 0, '', 1, 'Arial, normal, 48', salida, 'S');
  list.Linea(0, 0, '', 1, 'Arial, normal, 48', salida, 'S');


  list.Linea(0, 0, '.........................................', 1, 'Arial, normal, 12', salida, 'N');
  list.Linea(75, list.Lineactual, '.........................................', 2, 'Arial, normal, 12', salida, 'S');
  list.Linea(0, 0, '                      Firma', 1, 'Arial, cursiva, 8', salida, 'N');
  list.Linea(75, list.Lineactual, '                  Aclaración', 2, 'Arial, cursiva, 8', salida, 'S');



  cabestadia.IndexFieldNames := 'Nroregistro';

  list.FinList;
end;

procedure TTEstadia.ListarDetalleMovimientoPasajeros(xdfecha, xhfecha: String; salida: char);
// Objetivo...: Listar Nómina de Ingresos
begin
  list.setear(salida);
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Detalle Movimiento por Pasajero - Lapso: ' + xdfecha + ' - ' + xhfecha, 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Fecha', 1, 'Arial, cursiva, 8');
  List.Titulo(10, List.lineactual, 'Nombre del Pasajero', 2, 'Arial, cursiva, 8');
  List.Titulo(45, List.lineactual, 'Dirección', 3, 'Arial, cursiva, 8');
  List.Titulo(65, List.lineactual, 'Procedencia', 4, 'Arial, cursiva, 8');
  List.Titulo(85, List.lineactual, 'Destino', 5, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  cabestadia.IndexFieldNames := 'FechaIngreso';
  datosdb.Filtrar(cabestadia, 'fechaegreso >= ' + '''' + utiles.sExprFecha2000(xdfecha) + '''' + ' and fechaegreso <= ' + '''' + utiles.sExprFecha2000(xhfecha) + '''');
  cabestadia.First;
  while not cabestadia.Eof do Begin
    pasajero.getDatos(cabestadia.FieldByName('idpasajero').AsString);
    list.Linea(0, 0, 'Pasajero: ' + pasajero.Nombre, 1, 'Arial, negrita, 9', salida, 'N');
    list.Linea(36, list.Lineactual, 'Pro./Dest.: ' + Copy(cabestadia.FieldByName('procedencia').AsString, 1, 35), 2, 'Arial, negrita, 9', salida, 'N');
    list.Linea(65, list.Lineactual, Copy(cabestadia.FieldByName('destino').AsString, 1, 35), 3, 'Arial, normal, 9', salida, 'N');
    list.Linea(90, list.Lineactual, 'Sal.: ' + utiles.sFormatoFecha(cabestadia.FieldByName('fechaegreso').AsString) + ' - ' + cabestadia.FieldByName('horaegreso').AsString, 4, 'Arial, negrita, 9', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
    ListarDetalleEstadia(cabestadia.FieldByName('nroregistro').AsString, salida);
    cabestadia.Next;
  end;
  datosdb.QuitarFiltro(cabestadia);
  cabestadia.IndexFieldNames := 'Nroregistro';

  list.FinList;
end;

procedure TTEstadia.ListarDetalleEstadia(xnroregistro: String; salida: char);
Begin
  BuscarDistribucion(xnroregistro);
  list.Linea(0, 0, 'Efectivo:', 1, 'Arial, normal, 9', salida, 'N');
  list.importe(20, list.Lineactual, '', distribucion.FieldByName('efectivo').AsFloat, 2, 'Arial, normal, 9');
  list.Linea(25, list.Lineactual, 'Cheques:', 3, 'Arial, normal, 9', salida, 'N');
  list.importe(45, list.Lineactual, '', distribucion.FieldByName('cheque').AsFloat, 4, 'Arial, normal, 9');
  list.Linea(50, list.Lineactual, 'Tarjetas:', 5, 'Arial, normal, 9', salida, 'N');
  list.importe(70, list.Lineactual, '', distribucion.FieldByName('tarjeta').AsFloat, 6, 'Arial, normal, 9');
  list.Linea(95, list.Lineactual, '', 7, 'Arial, normal, 8', salida, 'S');

  ListDetalleCheques(xnroregistro, salida);
  ListDetalleTarjetas(xnroregistro, salida);

  list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S');
end;

procedure TTEstadia.ListDetalleCheques(xnroregistro: String; salida: char);
// Objetivo...: Buscar cheque
var
  l: Boolean;
begin
  if BuscarCheque(xnroregistro, '001') then Begin
    list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S');
    while not cheques.Eof do Begin
      if cheques.FieldByName('nroregistro').AsString <> xnroregistro then Break;
      entbcos.getDatos(cheques.FieldByName('codbco').AsString);
      if not l then list.Linea(0, 0, '     Cheques:', 1, 'Arial, normal, 8', salida, 'N') else list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'N');
      l := True;
      list.Linea(10, list.Lineactual, cheques.FieldByName('nrocheque').AsString, 2, 'Arial, normal, 8', salida, 'N');
      list.Linea(20, list.Lineactual, utiles.sFormatoFecha(cheques.FieldByName('fecobro').AsString), 3, 'Arial, normal, 8', salida, 'N');
      list.Linea(27, list.Lineactual, entbcos.descrip, 4, 'Arial, normal, 8', salida, 'N');
      list.importe(75, list.Lineactual, '', cheques.FieldByName('monto').AsFloat, 5, 'Arial, normal, 8');
      list.Linea(76, list.Lineactual, cheques.FieldByName('sucursal').AsString, 6, 'Arial, normal, 8', salida, 'S');
      cheques.Next;
    end;
    list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S');
  end;
end;

procedure TTEstadia.ListDetalleTarjetas(xnroregistro: String; salida: char);
// Objetivo...: Buscar cheque
var
  l: Boolean;
begin
  if BuscarTarjeta(xnroregistro, '001') then Begin
    list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S');
    while not tarjetas.Eof do Begin
      if tarjetas.FieldByName('nroregistro').AsString <> xnroregistro then Break;
      tarjeta.getDatos(tarjetas.FieldByName('idtarjeta').AsString);
      if not l then list.Linea(0, 0, '     Tarjetas:', 1, 'Arial, normal, 8', salida, 'N') else list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'N');
      l := True;
      list.Linea(10, list.Lineactual, tarjetas.FieldByName('nrotarjeta').AsString, 2, 'Arial, normal, 8', salida, 'N');
      list.Linea(20, list.Lineactual, utiles.sFormatoFecha(tarjetas.FieldByName('fecha').AsString), 3, 'Arial, normal, 8', salida, 'N');
      list.Linea(27, list.Lineactual, tarjeta.Tarjeta, 4, 'Arial, normal, 8', salida, 'N');
      list.importe(75, list.Lineactual, '', tarjetas.FieldByName('monto').AsFloat, 5, 'Arial, normal, 8');
      list.Linea(76, list.Lineactual, '', 6, 'Arial, normal, 8', salida, 'S');
      tarjetas.Next;
    end;
    list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S');
  end;
end;

procedure TTEstadia.ListarDetalleCobros(xdfecha, xhfecha: String; salida: char);
// Objetivo...: Listar Detalle de Cobros
begin
  list.setear(salida);
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Detalle Movimiento de Cobros - Lapso: ' + xdfecha + ' - ' + xhfecha, 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Fecha', 1, 'Arial, cursiva, 8');
  List.Titulo(30, List.lineactual, 'Efectivo', 2, 'Arial, cursiva, 8');
  List.Titulo(45, List.lineactual, 'Cheques', 3, 'Arial, cursiva, 8');
  List.Titulo(60, List.lineactual, 'Tarjetas', 4, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  cabestadia.IndexFieldNames := 'Fechaegreso';
  datosdb.Filtrar(cabestadia, 'fechaegreso >= ' + '''' + utiles.sExprFecha2000(xdfecha) + '''' + ' and fechaegreso <= ' + '''' + utiles.sExprFecha2000(xhfecha) + '''');
  cabestadia.First; totales[1] := 0; totales[2] := 0; totales[3] := 0;
  while not cabestadia.Eof do Begin
    if cabestadia.FieldByName('fechaegreso').AsString <> idanter then LineaDetalleCobros(idanter, salida);
    if BuscarDistribucion(cabestadia.FieldByName('nroregistro').AsString) then Begin
      totales[1] := distribucion.FieldByName('efectivo').AsFloat;
      totales[2] := distribucion.FieldByName('cheque').AsFloat;
      totales[3] := distribucion.FieldByName('tarjeta').AsFloat;
    end;
    idanter := cabestadia.FieldByName('fechaegreso').AsString;
    cabestadia.Next;
  end;
  LineaDetalleCobros(idanter, salida);
  datosdb.QuitarFiltro(cabestadia);
  cabestadia.IndexFieldNames := 'Nroregistro';

  list.FinList;
end;

procedure TTEstadia.ListarDetalleEstadiaPasajero(xnroregistro: String; salida: char);
// Objetivo...: Listar Detalle Estadia
var
  cant: Real;
begin
  list.setear(salida);
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Detalle de la Estadía', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, cursiva, 8');
  List.Titulo(2, list.Lineactual, 'Cant.', 2, 'Arial, cursiva, 8');
  List.Titulo(10, list.Lineactual, 'Concepto', 3, 'Arial, cursiva, 8');
  List.Titulo(70, List.lineactual, 'P.Unit.', 4, 'Arial, cursiva, 8');
  List.Titulo(91, List.lineactual, 'Total', 5, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  if Buscar(xnroregistro) then Begin
    totales[2] := 0;
    pasajero.getDatos(cabestadia.FieldByName('idpasajero').AsString);
    list.Linea(0, 0, 'Registro: ' + xnroregistro, 1, 'Arial, negrita, 8', salida, 'N');
    list.Linea(18, list.Lineactual, 'Pasajero: ' + pasajero.nombre, 2, 'Arial, negrita, 8', salida, 'N');
    list.Linea(70, list.Lineactual, 'Ingreso/Egreso: ' + utiles.sFormatoFecha(cabestadia.FieldByName('fechaingreso').AsString) + ' - ' + utiles.sFormatoFecha(cabestadia.FieldByName('fechaegreso').AsString), 3, 'Arial, negrita, 8', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S');

    utiles.calc_antiguedad(cabestadia.FieldByName('fechaingreso').AsString, cabestadia.FieldByName('fechaegreso').AsString);
    cant := StrToFloat(IntToStr(utiles.getDias));
    if cant = 0 then cant := 1;

    if BuscarTarifa(xnroregistro, 'H', '001') then Begin
      habitacion.getDatos(dettarifas.FieldByName('iditems').AsString);
      list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'N');
      list.Importe(5, list.Lineactual, '', cant, 2, 'Arial, normal, 8');
      list.Linea(10, list.Lineactual, habitacion.Descrip, 3, 'Arial, normal, 8', salida, 'N');
      list.importe(75, list.Lineactual, '', habitacion.Precio, 4, 'Arial, normal, 8');
      list.importe(95, list.Lineactual, '', habitacion.Precio * cant, 5, 'Arial, normal, 8');
      list.Linea(95, list.Lineactual, '', 6, 'Arial, normal, 8', salida, 'S');
      totales[2] := totales[2] + (habitacion.Precio * cant);
    end;

    if BuscarTarifa(xnroregistro, 'T', '001') then Begin
      while not dettarifas.Eof do Begin
        if dettarifas.FieldByName('nroregistro').AsString <> xnroregistro then Break;
        tarifas.getDatos(dettarifas.FieldByName('iditems').AsString);
        if tarifas.Diaria = 'S' then cant := StrToFloat(IntToStr(utiles.getDias)) else cant := 1;
        list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'N');
        list.Importe(5, list.Lineactual, '', cant, 2, 'Arial, normal, 8');
        list.Linea(10, list.Lineactual, tarifas.Descrip, 3, 'Arial, normal, 8', salida, 'N');
        list.importe(75, list.Lineactual, '', tarifas.Monto, 4, 'Arial, normal, 8');
        list.importe(95, list.Lineactual, '', tarifas.Monto * cant, 5, 'Arial, normal, 8');
        list.Linea(95, list.Lineactual, '', 6, 'Arial, normal, 8', salida, 'S');
        totales[2] := totales[2] + (tarifas.Monto * cant);
        dettarifas.Next;
      end;
    end;

    if BuscarItemsFact(xnroregistro, '001') then Begin
      while not detfact.Eof do Begin
        if detfact.FieldByName('nroregistro').AsString <> xnroregistro then Break;
        list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'N');
        list.Importe(5, list.Lineactual, '', detfact.FieldByName('cantidad').AsFloat, 2, 'Arial, normal, 8');
        if detfact.FieldByName('items').AsString = '000' then list.Linea(10, list.Lineactual, detfact.FieldByName('descrip').AsString, 3, 'Arial, normal, 8', salida, 'N') else Begin
          itemsfact.getDatos(detfact.FieldByName('items').AsString);
          list.Linea(10, list.Lineactual, itemsfact.Descrip, 3, 'Arial, normal, 8', salida, 'N');
        end;
        list.importe(75, list.Lineactual, '', detfact.FieldByName('monto').AsFloat, 4, 'Arial, normal, 8');
        list.importe(95, list.Lineactual, '', detfact.FieldByName('cantidad').AsFloat * detfact.FieldByName('monto').AsFloat, 5, 'Arial, normal, 8');
        list.Linea(95, list.Lineactual, '', 6, 'Arial, normal, 8', salida, 'S');
        totales[2] := totales[2] + (detfact.FieldByName('cantidad').AsFloat * detfact.FieldByName('monto').AsFloat);
        detfact.Next;
      end;
    end;

  end;

  if totales[2] > 0 then Begin
    list.Linea(0, 0, '', 1, 'Arial, negrita, 8', salida, 'N');
    list.Linea(85, list.Lineactual, '------------------', 2, 'Arial, negrita, 8', salida, 'S');
    list.Linea(0, 0, 'Total Estadía:', 1, 'Arial, negrita, 8', salida, 'N');
    list.importe(95, list.Lineactual, '', totales[2], 2, 'Arial, negrita, 8');
    list.Linea(95, list.Lineactual, '', 3, 'Arial, negrita, 8', salida, 'S');
  end;

  list.FinList;
end;

procedure TTEstadia.LineaDetalleCobros(xidanter: String; salida: char);
// Objetivo...: Listar Detalle de Cobros
begin
  if totales[1] + totales[2] + totales[3] > 0 then Begin
    list.Linea(0, 0, utiles.sFormatoFecha(xidanter), 1, 'Arial, normal, 9', salida, 'N');
    list.importe(36, list.Lineactual, '', totales[1], 2, 'Arial, normal, 9');
    list.importe(52, list.Lineactual, '', totales[2], 3, 'Arial, normal, 9');
    list.importe(67, list.Lineactual, '', totales[3], 4, 'Arial, normal, 9');
    list.Linea(70, list.Lineactual, '', 5, 'Arial, normal, 9', salida, 'S');
    totales[1] := 0; totales[2] := 0; totales[3] := 0;
  end;
end;

function  TTEstadia.BuscarCheque(xnroregistro, xitems: String): Boolean;
// Objetivo...: Buscar cheque
begin
  if cheques.IndexFieldNames <> 'Nroregistro;Items' then cheques.IndexFieldNames := 'Nroregistro;Items';
  Result := datosdb.Buscar(cheques, 'nroregistro', 'items', xnroregistro, xitems);
end;

procedure TTEstadia.RegistrarCheques(xnroregistro, xitems, xnrocheque, xfecha, xcodbco, xsucursal, xfecobro: String; xmonto: Real; xcantitems: Integer);
// Objetivo...: Registrar cheque
begin
  if BuscarCheque(xnroregistro, xitems) then cheques.Edit else cheques.Append;
  cheques.FieldByName('nroregistro').AsString := xnroregistro;
  cheques.FieldByName('items').AsString       := xitems;
  cheques.FieldByName('nrocheque').AsString   := xnrocheque;
  cheques.FieldByName('fecha').AsString       := utiles.sExprFecha(xfecha);
  cheques.FieldByName('codbco').AsString      := xcodbco;
  cheques.FieldByName('sucursal').AsString    := xsucursal;
  cheques.FieldByName('monto').AsFloat        := xmonto;
  cheques.FieldByName('fecobro').AsString     := utiles.sExprFecha(xfecobro);
  try
    cheques.Post
   except
    cheques.Cancel
  end;
  if xitems = utiles.sLlenarIzquierda(IntToStr(xcantitems), 3, '0') then Begin
    datosdb.tranSQL('delete from ' + cheques.TableName + ' where nroregistro = ' + '''' + xnroregistro + '''' + ' and items > ' + '''' + utiles.sLlenarIzquierda(IntToStr(xcantitems), 3, '0') + '''');
    datosdb.closeDB(cheques); cheques.Open;
  end;
end;

procedure TTEstadia.BorrarCheques(xnroregistro: String);
// Objetivo...: Borrar Cheques
begin
  datosdb.tranSQL('delete from ' + cheques.TableName + ' where nroregistro = ' + '''' + xnroregistro + '''');
  datosdb.closeDB(cheques); cheques.Open;
end;

function  TTEstadia.setCheques(xnroregistro: String): TStringList;
// Objetivo...: Recuperar Lista de cheques
var
  l: TStringList;
begin
  l := TStringList.Create;
  if BuscarCheque(xnroregistro, '001') then Begin
    while not cheques.Eof do Begin
      if cheques.FieldByName('nroregistro').AsString <> xnroregistro then Break;
      l.Add(cheques.FieldByName('items').AsString + utiles.sFormatoFecha(cheques.FieldByName('fecha').AsString) + utiles.sFormatoFecha(cheques.FieldByName('fecobro').AsString) + cheques.FieldByName('codbco').AsString + cheques.FieldByName('nrocheque').AsString + ';1' + cheques.FieldByName('sucursal').AsString + ';2' + cheques.FieldByName('monto').AsString);
      cheques.Next;
    end;
  end;
  Result := l;
end;

function  TTEstadia.BuscarTarjeta(xnroregistro, xitems: String): Boolean;
// Objetivo...: Buscar cheque
begin
  if tarjetas.IndexFieldNames <> 'Nroregistro;Items' then tarjetas.IndexFieldNames := 'Nroregistro;Items';
  Result := datosdb.Buscar(tarjetas, 'nroregistro', 'items', xnroregistro, xitems);
end;

procedure TTEstadia.RegistrarTarjeta(xnroregistro, xitems, xnrotarjeta, xfecha, xidtarjeta: String; xmonto: Real; xcantitems: Integer);
// Objetivo...: Registrar Tarjetas
begin
  if BuscarTarjeta(xnroregistro, xitems) then tarjetas.Edit else tarjetas.Append;
  tarjetas.FieldByName('nroregistro').AsString := xnroregistro;
  tarjetas.FieldByName('items').AsString       := xitems;
  tarjetas.FieldByName('nrotarjeta').AsString  := xnrotarjeta;
  tarjetas.FieldByName('fecha').AsString       := utiles.sExprFecha(xfecha);
  tarjetas.FieldByName('idtarjeta').AsString   := xidtarjeta;
  tarjetas.FieldByName('monto').AsFloat        := xmonto;
  try
    tarjetas.Post
   except
    tarjetas.Cancel
  end;
  if xitems = utiles.sLlenarIzquierda(IntToStr(xcantitems), 3, '0') then Begin
    datosdb.tranSQL('delete from ' + tarjetas.TableName + ' where nroregistro = ' + '''' + xnroregistro + '''' + ' and items > ' + '''' + utiles.sLlenarIzquierda(IntToStr(xcantitems), 3, '0') + '''');
    datosdb.closeDB(tarjetas); tarjetas.Open;
  end;
end;

procedure TTEstadia.BorrarTarjetas(xnroregistro: String);
// Objetivo...: Borrar Tarjetas
begin
  datosdb.tranSQL('delete from ' + tarjetas.TableName + ' where nroregistro = ' + '''' + xnroregistro + '''');
  datosdb.closeDB(tarjetas); tarjetas.Open;
end;

function TTEstadia.BuscarDistribucion(xnroregistro: String): Boolean;
// Objetivo...: Recuperar una Instancia de Distribucion
begin
  Result := distribucion.FindKey([xnroregistro]);
end;

procedure TTEstadia.RegistrarDistribucion(xnroregistro, xfecha: String; xefectivo, xcheque, xtarjeta, xdescuento: Real);
// Objetivo...: Registrar una Instancia de Distribución
begin
  if BuscarDistribucion(xnroregistro) then distribucion.Edit else distribucion.Append;
  distribucion.FieldByName('nroregistro').AsString := xnroregistro;
  distribucion.FieldByName('fecha').AsString       := utiles.sExprFecha2000(xfecha);
  distribucion.FieldByName('efectivo').AsFloat     := xefectivo;
  distribucion.FieldByName('cheque').AsFloat       := xcheque;
  distribucion.FieldByName('tarjeta').AsFloat      := xtarjeta;
  distribucion.FieldByName('descuento').AsFloat    := xdescuento;
  try
    distribucion.Post
   except
    distribucion.Cancel
  end;
  datosdb.closeDB(distribucion); distribucion.Open;
end;

procedure TTEstadia.BorrarDistribucion(xnroregistro: String);
// Objetivo...: Borrar una Instancia de Distribución
begin
  if BuscarDistribucion(xnroregistro) then distribucion.Delete;
  datosdb.closeDB(distribucion); distribucion.Open;
end;

function  TTEstadia.BuscarAcompaniante(xnroregistro, xidpasajero, xitems: String): Boolean;
// Objetivo...: cerrar tablas de persistencia
begin
  if acompaniantes.IndexFieldNames <> 'Nroregistro;Idpasajero;Items' then acompaniantes.IndexFieldNames := 'Nroregistro;Idpasajero;Items';
  Result := datosdb.Buscar(acompaniantes, 'Nroregistro', 'Idpasajero', 'Items', xnroregistro, xidpasajero, xitems);
end;

procedure TTEstadia.RegistrarAcompaniante(xnroregistro, xidpasajero, xitems, xnrodoc, xnombre: String; xcantitems: Integer);
// Objetivo...: cerrar tablas de persistencia
begin
  if BuscarAcompaniante(xnroregistro, xidpasajero, xitems) then acompaniantes.Edit else acompaniantes.Append;
  acompaniantes.FieldByName('nroregistro').AsString := xnroregistro;
  acompaniantes.FieldByName('idpasajero').AsString  := xidpasajero;
  acompaniantes.FieldByName('items').AsString       := xitems;
  acompaniantes.FieldByName('nrodoc').AsString      := xnrodoc;
  acompaniantes.FieldByName('nombre').AsString      := xnombre;
  try
    acompaniantes.Post
   except
    acompaniantes.Cancel
  end;
  if xitems = utiles.sLlenarIzquierda(IntToStr(xcantitems), 2, '0') then Begin
    datosdb.tranSQL('delete from acompaniantes where nroregistro = ' + '''' + xnroregistro + '''' + ' and idpasajero = ' + '''' + xidpasajero + '''' + ' and items > ' + '''' + xitems + '''');
    datosdb.closeDB(acompaniantes); acompaniantes.Open;
  end;
end;

procedure TTEstadia.BorrarAcompaniantes(xnroregistro, xidpasajero: String);
// Objetivo...: cerrar tablas de persistencia
begin
  datosdb.tranSQL('delete from acompaniantes where nroregistro = ' + '''' + xnroregistro + '''' + ' and idpasajero = ' + '''' + xidpasajero + '''');
  datosdb.closeDB(acompaniantes); acompaniantes.Open;
end;

function TTEstadia.setAcompaniantes(xnroregistro, xidpasajero: String): TStringList;
// Objetivo...: devolver un set de acompaniantes
var
  l: TStringList;
begin
  l := TStringList.Create;
  if BuscarAcompaniante(xnroregistro, xidpasajero, '01') then Begin
    while not acompaniantes.Eof do Begin
      if acompaniantes.FieldByName('nroregistro').AsString <> xnroregistro then Break;
      l.Add(acompaniantes.FieldByName('items').AsString + acompaniantes.FieldByName('nrodoc').AsString + ';1' + acompaniantes.FieldByName('nombre').AsString);
      acompaniantes.Next;
    end;
  end;
  Result := l;
end;

function  TTEstadia.BuscarTarifa(xnroregistro, xtipoitems, xitems: String): Boolean;
// Objetivo...: Buscar un Items Tarifado
Begin
  Result := datosdb.Buscar(dettarifas, 'Nroregistro', 'Tipoitems', 'Items', xnroregistro, xtipoitems, xitems);
end;

procedure TTEstadia.RegistrarTarifa(xnroregistro, xtipoitems, xitems, xiditems: String; xmonto: Real);
// Objetivo...: Registrar Items
Begin
  if BuscarTarifa(xnroregistro, xtipoitems, xitems) then dettarifas.Edit else dettarifas.Append;
  dettarifas.FieldByName('nroregistro').AsString := xnroregistro;
  dettarifas.FieldByName('tipoitems').AsString   := xtipoitems;
  dettarifas.FieldByName('items').AsString       := xitems;
  dettarifas.FieldByName('iditems').AsString     := xiditems;
  dettarifas.FieldByName('monto').AsFloat        := xmonto;
  try
    dettarifas.Post
   except
    dettarifas.Cancel
  end;
  datosdb.refrescar(dettarifas);
  if xtipoitems = 'H' then habitacion.OcuparHabitacion(xiditems, xnroregistro); // Marcamos la Habitación como ocupada
end;

procedure TTEstadia.AjustarItems(xnroregistro, xtipoitems: String; xcantitems: Integer);
// Objetivo...: Ajustar Items
Begin
  datosdb.tranSQL('delete from detalle_tarifas where nroregistro = ' + '''' + xnroregistro + '''' + ' and tipoitems = ' + '''' + xtipoitems + '''' + ' and items > ' + '''' + utiles.sLlenarIzquierda(IntToStr(xcantitems), 3, '0') + '''');
  datosdb.closeDB(dettarifas); dettarifas.Open;
end;

procedure TTEstadia.BorrarTarifa(xnroregistro: String);
// Objetivo...: Borrar Tarifa
Begin
  datosdb.Filtrar(dettarifas, 'nroregistro = ' + '''' + xnroregistro + '''');  // Liberamos las Habitaciones
  dettarifas.First;
  while not dettarifas.Eof do Begin
    if dettarifas.FieldByName('tipoitems').AsString = 'H' then habitacion.DesocuparHabitacion(dettarifas.FieldByName('iditems').AsString);
    dettarifas.Next;
  end;
  datosdb.QuitarFiltro(dettarifas);
  datosdb.tranSQL('delete from detalle_tarifas where nroregistro = ' + '''' + xnroregistro + '''');
  datosdb.closeDB(dettarifas); dettarifas.Open;
end;

function  TTEstadia.setTarifas(xnroregistro: String): TStringList;
// Objetivo...: Buscar un gasto
var
  l: TStringList;
Begin
  l := TStringList.Create;
  datosdb.Filtrar(dettarifas, 'nroregistro = ' + '''' + xnroregistro + '''');
  dettarifas.First;
  while not dettarifas.Eof do Begin
    l.Add(dettarifas.FieldByName('tipoitems').AsString + dettarifas.FieldByName('items').AsString + dettarifas.FieldByName('iditems').AsString + dettarifas.FieldByName('monto').AsString);
    dettarifas.Next;
  end;
  datosdb.QuitarFiltro(dettarifas);
  Result := l;
end;

function  TTEstadia.setNroHabitacion(xnroregistro: String): String;
// Objetivo...: retornar número de habitación
Begin
  if BuscarTarifa(xnroregistro, 'H', '001') then Result := dettarifas.FieldByName('iditems').AsString else Result := '';
end;

function  TTEstadia.setHabitacion(xnroregistro: String): String;
// Objetivo...: retornar habitación
Begin
  if BuscarTarifa(xnroregistro, 'H', '001') then Begin
    habitacion.getDatos(dettarifas.FieldByName('iditems').AsString);
    Result := habitacion.Descrip;
  end else
    Result := '';
end;

function  TTEstadia.setTarifasPasajeroDiarias(xnroregistro: String): Real;
// Objetivo...: retornar tarifas diarias
var
  t: Real;
Begin
  t := 0;
  if BuscarTarifa(xnroregistro, 'T', '001') then Begin
    while not dettarifas.Eof do Begin
      if (dettarifas.FieldByName('nroregistro').AsString <> xnroregistro) or (dettarifas.FieldByName('tipoitems').AsString <> 'T') then Break;
      if tarifas.setTarifaDiaria(dettarifas.FieldByName('iditems').AsString) then  t := t + dettarifas.FieldByName('monto').AsFloat;
      dettarifas.Next;
    end;
  end;
  Result := t;
end;

function  TTEstadia.setTarifasPasajeroIndividuales(xnroregistro: String): Real;
// Objetivo...: retornar tarifas fijas
var
  t: Real;
Begin
  t := 0;
  if BuscarTarifa(xnroregistro, 'T', '001') then Begin
    while not dettarifas.Eof do Begin
      if (dettarifas.FieldByName('nroregistro').AsString <> xnroregistro) or (dettarifas.FieldByName('tipoitems').AsString <> 'T') then Break;
      if not tarifas.setTarifaDiaria(dettarifas.FieldByName('iditems').AsString) then  t := t + dettarifas.FieldByName('monto').AsFloat;
      dettarifas.Next;
    end;
  end;
  Result := t;
end;

procedure TTEstadia.conectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones = 0 then Begin
    if not cabestadia.Active then cabestadia.Open;
    if not detfact.Active then detfact.Open;
    if not cheques.Active then cheques.Open;
    if not tarjetas.Active then tarjetas.Open;
    if not distribucion.Active then distribucion.Open;
    if not acompaniantes.Active then acompaniantes.Open;
    if not dettarifas.Active then dettarifas.Open;
  end;
  Inc(conexiones);
  pasajero.conectar;
  habitacion.conectar;
  netos.conectar;
  itemsfact.conectar;
  compregis.conectar;
  tarjeta.conectar;
  entbcos.conectar;
  tarifas.conectar;
end;

procedure TTEstadia.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  Dec(conexiones);
  if conexiones = 0 then Begin
    datosdb.closeDB(cabestadia);
    datosdb.closeDB(detfact);
    datosdb.closeDB(cheques);
    datosdb.closeDB(tarjetas);
    datosdb.closeDB(distribucion);
    datosdb.closeDB(acompaniantes);
    datosdb.closeDB(dettarifas);
  end;
  pasajero.desconectar;
  habitacion.desconectar;
  netos.desconectar;
  itemsfact.desconectar;
  compregis.desconectar;
  tarjeta.desconectar;
  entbcos.desconectar;
  tarifas.desconectar;
end;

{===============================================================================}

function estadia: TTEstadia;
begin
  if xestadia = nil then
    xestadia := TTEstadia.Create;
  Result := xestadia;
end;

{===============================================================================}

initialization

finalization
  xestadia.Free;

end.
