unit CBoletasADR;

interface

uses CBDT, SysUtils, DBTables, CUtiles, CListar, CIDBFM, Classes, CPrestatarios_Asociacion,
     CMunicipios_Asociacion, CAdmNumCompr, Contnrs;

type

TTBoletas = class
  codigobarra, fecha, hora, codprest, expediente, fechaemis, fechavto1, fechavto2, ctactebcaria, estado, tipobol, fechaliq, imput,
  Idc, Tipo, Sucursal, Numero, Nrotrans, Observac, Items, ConceptoItems: String;
  montovto1, montovto2, MontoItems: Real;
  boletas_work, boletas_detwork: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  procedure   RegistrarBoletaCodigoBarras(xcodigobarra, xfecha, xhora, xcodprest, xexpediente, xfechaemis, xfechavto1, xfechavto2, xctactebcaria: String; xmontovto1, xmontovto2: Real; xitems, xconceptoitems, xtipobol, xidc, xtipo, xsucursal, xnumero, xnrotrans: String; xmontoitems: Real; xcantitems: Integer);
  procedure   getDatosBoletaCodigoBarras(xcodigobarra, xfecha, xhora: String);
  function    setBoletasPendientes: TObjectList;
  function    setBoletasLiquidadas: TObjectList;
  function    setItemsBoleta: TObjectList;
  procedure   ListarBoletasPendientes(xdfecha, xhfecha: String; xresumen: Boolean; salida: char);
  procedure   ListarBoletasCobradas(xdfecha, xhfecha: String; xresumen: Boolean; salida: char);
  procedure   ListarBoletasAnuladas(xdfecha, xhfecha: String; salida: char);
  procedure   MarcarBoletaComoPaga(xcodigobarra, xfecha, xhora, xfechaliq, xmontoimput: String);
  procedure   AnularBoletaPaga(xcodigobarra, xfecha, xhora, xobservac, xfechaan: String);

  function    VerificarCantidadCuotasPendientes(xcodprest, xexpediente: String): Integer;

  procedure   FiltrarTipoBoleta(xtipo: String);
  procedure   QuitarFiltro;

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  totales: array[1..10] of real;
  conexiones: shortint;
  procedure IniciarTotales;
end;

function boleta: TTBoletas;

implementation

var
  xboleta: TTBoletas = nil;

constructor TTBoletas.Create;
begin
  boletas_work    := datosdb.openDB('boletas_work', '');
  boletas_detwork := datosdb.openDB('boletas_detwork', '');
end;

destructor TTBoletas.Destroy;
begin
  inherited Destroy;
end;

procedure TTBoletas.RegistrarBoletaCodigoBarras(xcodigobarra, xfecha, xhora, xcodprest, xexpediente, xfechaemis, xfechavto1, xfechavto2, xctactebcaria: String; xmontovto1, xmontovto2: Real; xitems, xconceptoitems, xtipobol, xidc, xtipo, xsucursal, xnumero, xnrotrans: String; xmontoitems: Real; xcantitems: Integer);
// Objetivo...: Registrar Boleta de Depósito
Begin
  if xitems = '01' then Begin
    if datosdb.Buscar(boletas_work, 'codigobarra', 'fecha', 'hora', xcodigobarra, utiles.sExprFecha2000(xfecha), xhora) then boletas_work.Edit else boletas_work.Append;
    boletas_work.FieldByName('codigobarra').AsString  := xcodigobarra;
    boletas_work.FieldByName('fecha').AsString        := utiles.sExprFecha2000(xfecha);
    boletas_work.FieldByName('hora').AsString         := xhora;
    boletas_work.FieldByName('codprest').AsString     := utiles.sLlenarIzquierda(xcodprest, 5, '0');
    boletas_work.FieldByName('expediente').AsString   := utiles.sLlenarIzquierda(xexpediente, 4, '0');
    boletas_work.FieldByName('fechaemis').AsString    := utiles.sExprFecha2000(xfechaemis);
    boletas_work.FieldByName('fechavto1').AsString    := utiles.sExprFecha2000(xfechavto1);
    boletas_work.FieldByName('fechavto2').AsString    := utiles.sExprFecha2000(xfechavto2);
    boletas_work.FieldByName('ctactebcaria').AsString := xctactebcaria;
    boletas_work.FieldByName('montovto1').AsFloat     := xmontovto1;
    boletas_work.FieldByName('montovto2').AsFloat     := xmontovto2;
    boletas_work.FieldByName('estado').AsString       := 'P';
    boletas_work.FieldByName('tipobol').AsString      := xtipobol;
    boletas_work.FieldByName('idc').AsString          := xidc;
    boletas_work.FieldByName('tipo').AsString         := xtipo;
    boletas_work.FieldByName('sucursal').AsString     := xsucursal;
    boletas_work.FieldByName('numero').AsString       := xnumero;
    boletas_work.FieldByName('nrotrans').AsString     := xnrotrans;
    try
      boletas_work.Post
     except
      boletas_work.Cancel
    end;
    datosdb.closeDB(boletas_work); boletas_work.Open;

    administNum.ActNuemeroActualNF(xnumero);
  end;

  if datosdb.Buscar(boletas_detwork, 'codigobarra', 'fecha', 'hora', 'items', xcodigobarra, utiles.sExprFecha2000(xfecha), xhora, xitems) then boletas_detwork.Edit else boletas_detwork.Append;
  boletas_detwork.FieldByName('codigobarra').AsString  := xcodigobarra;
  boletas_detwork.FieldByName('fecha').AsString        := utiles.sExprFecha2000(xfecha);
  boletas_detwork.FieldByName('hora').AsString         := xhora;
  boletas_detwork.FieldByName('items').AsString        := xitems;
  boletas_detwork.FieldByName('concepto').AsString     := xconceptoitems;
  boletas_detwork.FieldByName('monto').AsFloat         := xmontoitems;
  try
    boletas_detwork.Post
   except
    boletas_detwork.Cancel
  end;

  if xitems = utiles.sLlenarIzquierda(IntToStr(xcantitems), 2, '0') then Begin
    datosdb.tranSQL('delete from boletas_detwork where codigobarra = ' + '''' + xcodigobarra + '''' + ' and fecha = ' + '''' + utiles.sExprFecha2000(xfecha) + '''' + ' and hora = ' + '''' + xhora + '''' + ' and items > ' + '''' + xitems + '''');
    datosdb.closeDB(boletas_detwork); boletas_detwork.Open;
  end;
end;

procedure TTBoletas.getDatosBoletaCodigoBarras(xcodigobarra, xfecha, xhora: String);
// Objetivo...: Recuperar la instancia del objeto
Begin
  if datosdb.Buscar(boletas_work, 'codigobarra', 'fecha', 'hora', xcodigobarra, utiles.sExprFecha2000(xfecha), xhora) then Begin
    codigobarra  := boletas_work.FieldByName('codigobarra').AsString;
    fecha        := utiles.sFormatoFecha(boletas_work.FieldByName('fecha').AsString);
    hora         := boletas_work.FieldByName('hora').AsString;
    codprest     := boletas_work.FieldByName('codprest').AsString;
    expediente   := boletas_work.FieldByName('expediente').AsString;
    fechaemis    := utiles.sFormatoFecha(boletas_work.FieldByName('fechaemis').AsString);
    fechavto1    := utiles.sFormatoFecha(boletas_work.FieldByName('fechavto1').AsString);
    fechavto2    := utiles.sFormatoFecha(boletas_work.FieldByName('fechavto2').AsString);
    ctactebcaria := boletas_work.FieldByName('ctactebcaria').AsString;
    montovto1    := boletas_work.FieldByName('montovto1').AsFloat;
    montovto2    := boletas_work.FieldByName('montovto2').AsFloat;
    estado       := boletas_work.FieldByName('estado').AsString;
    tipobol      := boletas_work.FieldByName('tipobol').AsString;
    imput        := boletas_work.FieldByName('imput').AsString;
    idc          := boletas_work.FieldByName('idc').AsString;
    tipo         := boletas_work.FieldByName('tipo').AsString;
    sucursal     := boletas_work.FieldByName('sucursal').AsString;
    numero       := boletas_work.FieldByName('numero').AsString;
    nrotrans     := boletas_work.FieldByName('numero').AsString;
  end else Begin
    codigobarra := ''; fecha := ''; hora := ''; codprest := ''; expediente := ''; fechaemis := ''; fechavto1 := ''; fechavto2 := ''; ctactebcaria := ''; imput := '';
    montovto1 := 0; montovto2 := 0; estado := ''; tipobol := ''; imput := ''; idc := ''; tipo := ''; sucursal := ''; numero := ''; nrotrans := '';
  end;
end;

function  TTBoletas.setBoletasPendientes: TObjectList;
// Objetivo...: Devolver Boletas Impagas
var
  l: TObjectList;
  objeto: TTBoletas;
  e: Boolean;
Begin
  e := boletas_work.Active;
  if not boletas_work.Active then boletas_work.Open;
  l := TObjectList.Create;
  datosdb.Filtrar(boletas_work, 'estado = ' + '''' + 'P' + '''');
  boletas_work.First;
  while not boletas_work.Eof do Begin
    //l.Add(boletas_work.FieldByName('codigobarra').AsString + ';1' + utiles.sFormatoFecha(boletas_work.FieldByName('fecha').AsString) + boletas_work.FieldByName('hora').AsString + utiles.sLlenarIzquierda(boletas_work.FieldByName('codprest').AsString, 5, '0') + utiles.sLlenarIzquierda(boletas_work.FieldByName('expediente').AsString, 4, '0') + boletas_work.FieldByName('tipobol').AsString + boletas_work.FieldByName('estado').AsString + boletas_work.FieldByName('observac').AsString);
    objeto               := TTBoletas.Create;
    objeto.codigobarra   := boletas_work.FieldByName('codigobarra').AsString;
    objeto.fecha         := utiles.sFormatoFecha(boletas_work.FieldByName('fecha').AsString);
    objeto.hora          := boletas_work.FieldByName('hora').AsString;
    objeto.codprest      := utiles.sLlenarIzquierda(boletas_work.FieldByName('codprest').AsString, 5, '0');
    objeto.expediente    := utiles.sLlenarIzquierda(boletas_work.FieldByName('expediente').AsString, 4, '0');
    objeto.tipobol       := boletas_work.FieldByName('tipobol').AsString;
    objeto.estado        := boletas_work.FieldByName('estado').AsString;
    objeto.observac      := boletas_work.FieldByName('observac').AsString;
    objeto.Nrotrans      := boletas_work.FieldByName('nrotrans').AsString;
    l.Add(objeto);
    boletas_work.Next;
  end;
  datosdb.QuitarFiltro(boletas_work);
  boletas_work.Active := e;

  Result := l;
end;

function  TTBoletas.setBoletasLiquidadas: TObjectList;
// Objetivo...: Devolver Boletas Impagas
var
  l: TObjectList;
  objeto: TTBoletas;
  e: Boolean;
Begin
  e := boletas_work.Active;
  if not boletas_work.Active then boletas_work.Open;
  l := TObjectList.Create;
  datosdb.Filtrar(boletas_work, 'estado = ' + '''' + 'C' + '''');
  boletas_work.First;
  while not boletas_work.Eof do Begin
    //l.Add(boletas_work.FieldByName('codigobarra').AsString + ';1' + utiles.sFormatoFecha(boletas_work.FieldByName('fecha').AsString) + boletas_work.FieldByName('hora').AsString + utiles.sLlenarIzquierda(boletas_work.FieldByName('codprest').AsString, 5, '0') + utiles.sLlenarIzquierda(boletas_work.FieldByName('expediente').AsString, 4, '0') + boletas_work.FieldByName('tipobol').AsString + boletas_work.FieldByName('estado').AsString + boletas_work.FieldByName('observac').AsString);
    objeto.codigobarra   := boletas_work.FieldByName('codigobarra').AsString;
    objeto.fecha         := utiles.sFormatoFecha(boletas_work.FieldByName('fecha').AsString);
    objeto.hora          := boletas_work.FieldByName('hora').AsString;
    objeto.codprest      := utiles.sLlenarIzquierda(boletas_work.FieldByName('codprest').AsString, 5, '0');
    objeto.expediente    := utiles.sLlenarIzquierda(boletas_work.FieldByName('expediente').AsString, 4, '0');
    objeto.tipobol       := boletas_work.FieldByName('tipobol').AsString;
    objeto.estado        := boletas_work.FieldByName('estado').AsString;
    objeto.observac      := boletas_work.FieldByName('observac').AsString;
    objeto.Nrotrans      := boletas_work.FieldByName('nrotrans').AsString;
    l.Add(objeto);
    boletas_work.Next;
  end;
  datosdb.QuitarFiltro(boletas_work);
  boletas_work.Active := e;

  Result := l;
end;

function TTBoletas.setItemsBoleta: TObjectList;
// Objetivo...: Devolver los Items de una Boleta
var
  l: TObjectList;
  objeto: TTBoletas;
Begin
  l := TObjectList.Create;
  if datosdb.Buscar(boletas_detwork, 'codigobarra', 'fecha', 'hora', 'items', boletas_work.FieldByName('codigobarra').AsString, boletas_work.FieldByName('fecha').AsString, boletas_work.FieldByName('hora').AsString, '01') then Begin
    while not boletas_detwork.Eof do Begin
      if boletas_work.FieldByName('codigobarra').AsString <> boletas_detwork.FieldByName('codigobarra').AsString then Break;
      objeto               := TTBoletas.Create;
      objeto.Items         := boletas_detwork.FieldByName('items').AsString;
      objeto.ConceptoItems := boletas_detwork.FieldByName('concepto').AsString;
      objeto.MontoItems    := boletas_detwork.FieldByName('monto0').AsFloat;
      l.Add(objeto);
      //l.Add(boletas_detwork.FieldByName('items').AsString + boletas_detwork.FieldByName('concepto').AsString + ';1' + utiles.FormatearNumero(boletas_detwork.FieldByName('monto').AsString));
      boletas_detwork.Next;
    end;
  end;
  Result := l;
end;

procedure TTBoletas.ListarBoletasPendientes(xdfecha, xhfecha: String; xresumen: Boolean; salida: char);
// Objetivo...: Listar Boletas Pendientes
var
  t, l: Boolean;
  nombre: String;
Begin
  list.Setear(salida); list.altopag := 0; list.m := 0;
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Boletas Emitidas en el Lapso: ' + xdfecha + ' - ' + xhfecha, 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Fecha - Hora', 1, 'Arial, cursiva, 8');
  List.Titulo(16, list.Lineactual, 'Expediente / Prestatario', 2, 'Arial, cursiva, 8');
  List.Titulo(50, list.Lineactual, '1º Vto.', 3, 'Arial, cursiva, 8');
  List.Titulo(60, list.Lineactual, '2º Vto.', 4, 'Arial, cursiva, 8');
  List.Titulo(74, list.Lineactual, 'Monto 1', 5, 'Arial, cursiva, 8');
  List.Titulo(84, list.Lineactual, 'Monto 2', 6, 'Arial, cursiva, 8');
  List.Titulo(91, list.Lineactual, 'TP', 7, 'Arial, cursiva, 8');
  List.Titulo(95, list.Lineactual, 'Es.', 8, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  IniciarTotales;

  t := boletas_work.Active; l := False;
  if not boletas_work.Active then boletas_work.Open;
  datosdb.Filtrar(boletas_work, 'fecha >= ' + '''' + utiles.sExprFecha2000(xdfecha) + '''' + ' and fecha <= ' + '''' + utiles.sExprFecha2000(xhfecha) + '''' + ' and estado = ' + '''' + 'P' + '''');
  boletas_work.First;
  while not boletas_work.Eof do Begin
    if boletas_work.FieldByName('tipobol').AsString <> 'AMC' then Begin
      prestatario.getDatos(boletas_work.FieldByName('codprest').AsString);
      nombre := prestatario.nombre;
    end else Begin
      municipio.getDatos(Copy(boletas_work.FieldByName('codprest').AsString, 2, 4));
      nombre := municipio.nombre;
    end;
    l := True;
    list.Linea(0, 0, utiles.sFormatoFecha(boletas_work.FieldByName('fecha').AsString) + ' - ' + boletas_work.FieldByName('hora').AsString, 1, 'Arial, normal, 8', salida, 'N');
    list.Linea(16, list.Lineactual, boletas_work.FieldByName('codprest').AsString + '-' + boletas_work.FieldByName('expediente').AsString + '  ' + Copy(nombre, 1, 30), 2, 'Arial, normal, 8', salida, 'N');
    list.Linea(50, list.Lineactual, utiles.sFormatoFecha(boletas_work.FieldByName('fechavto1').AsString), 3, 'Arial, normal, 8', salida, 'N');
    list.Linea(60, list.Lineactual, utiles.sFormatoFecha(boletas_work.FieldByName('fechavto2').AsString), 4, 'Arial, normal, 8', salida, 'N');
    list.importe(80, list.Lineactual, '', boletas_work.FieldByName('montovto1').AsFloat, 5, 'Arial, normal, 8');
    list.importe(90, list.Lineactual, '', boletas_work.FieldByName('montovto2').AsFloat, 6, 'Arial, normal, 8');
    list.Linea(91, list.Lineactual, boletas_work.FieldByName('tipobol').AsString, 7, 'Arial, normal, 8', salida, 'N');
    list.Linea(96, list.Lineactual, boletas_work.FieldByName('estado').AsString, 8, 'Arial, normal, 8', salida, 'S');
    totales[1] := totales[1] + boletas_work.FieldByName('montovto1').AsFloat;
    totales[2] := totales[2] + boletas_work.FieldByName('montovto2').AsFloat;
    boletas_work.Next;
  end;
  datosdb.QuitarFiltro(boletas_work);
  boletas_work.Active := t;

  if not l then list.Linea(0, 0, 'No Existen Datos para Listar ...!', 1, 'Arial, normal, 10', salida, 'S');

  if totales[1] + totales[2] > 0 then Begin
    list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S');
    list.Linea(0, 0, 'Total a Cobrar:', 1, 'Arial, negrita, 8', salida, 'N');
    list.importe(80, list.Lineactual, '', totales[1], 2, 'Arial, negrita, 8');
    list.importe(90, list.Lineactual, '', totales[2], 3, 'Arial, negrita, 8');
    list.Linea(91, list.Lineactual, '', 4, 'Arial, negrita, 8', salida, 'S');
  end;

  list.FinList;
end;

procedure TTBoletas.ListarBoletasCobradas(xdfecha, xhfecha: String; xresumen: Boolean; salida: char);
// Objetivo...: Listar Boletas Pendientes
var
  t, l: Boolean;
  nombre: String;
  monto: Real;
Begin
  list.Setear(salida); list.altopag := 0; list.m := 0;
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Boletas Cobradas en el Lapso: ' + xdfecha + ' - ' + xhfecha, 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Fecha - Hora', 1, 'Arial, cursiva, 8');
  List.Titulo(16, list.Lineactual, 'Expediente / Prestatario', 2, 'Arial, cursiva, 8');
  List.Titulo(50, list.Lineactual, '1º Vto.', 3, 'Arial, cursiva, 8');
  List.Titulo(60, list.Lineactual, '2º Vto.', 4, 'Arial, cursiva, 8');
  List.Titulo(74, list.Lineactual, 'Cob.Vto.', 5, 'Arial, cursiva, 8');
  List.Titulo(85, list.Lineactual, 'Monto', 6, 'Arial, cursiva, 8');
  List.Titulo(91, list.Lineactual, 'TP', 7, 'Arial, cursiva, 8');
  List.Titulo(95, list.Lineactual, 'Es.', 8, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  IniciarTotales;

  t := boletas_work.Active; l := False;
  if not boletas_work.Active then boletas_work.Open;
  datosdb.Filtrar(boletas_work, 'fechaliq >= ' + '''' + utiles.sExprFecha2000(xdfecha) + '''' + ' and fechaliq <= ' + '''' + utiles.sExprFecha2000(xhfecha) + '''' + ' and estado = ' + '''' + 'C' + '''');

  list.Linea(0, 0, ' *** Ingreso por Cobro de Créditos ***', 1, 'Arial, normal, 11', salida, 'S');
  list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S');

  boletas_work.First; monto := 0;
  while not boletas_work.Eof do Begin
    if boletas_work.FieldByName('tipobol').AsString = 'REC' then Begin
      if boletas_work.FieldByName('tipobol').AsString <> 'AMC' then Begin
        prestatario.getDatos(boletas_work.FieldByName('codprest').AsString);
        nombre := prestatario.nombre;
      end else Begin
        municipio.getDatos(Copy(boletas_work.FieldByName('codprest').AsString, 2, 4));
        nombre := municipio.nombre;
      end;
      l := True;
      if boletas_work.FieldByName('imput').AsString = '1' then monto := boletas_work.FieldByName('montovto1').AsFloat else
        monto := boletas_work.FieldByName('montovto2').AsFloat;
      list.Linea(0, 0, utiles.sFormatoFecha(boletas_work.FieldByName('fecha').AsString) + ' - ' + boletas_work.FieldByName('hora').AsString, 1, 'Arial, normal, 8', salida, 'N');
      list.Linea(16, list.Lineactual, boletas_work.FieldByName('codprest').AsString + '-' + boletas_work.FieldByName('expediente').AsString + '  ' + Copy(nombre, 1, 30), 2, 'Arial, normal, 8', salida, 'N');
      list.Linea(50, list.Lineactual, utiles.sFormatoFecha(boletas_work.FieldByName('fechavto1').AsString), 3, 'Arial, normal, 8', salida, 'N');
      list.Linea(60, list.Lineactual, utiles.sFormatoFecha(boletas_work.FieldByName('fechavto2').AsString), 4, 'Arial, normal, 8', salida, 'N');
      list.Linea(78, list.Lineactual, boletas_work.FieldByName('imput').AsString, 5, 'Arial, normal, 8', salida, 'N');
      list.importe(90, list.Lineactual, '', monto, 6, 'Arial, normal, 8');
      list.Linea(91, list.Lineactual, boletas_work.FieldByName('tipobol').AsString, 7, 'Arial, normal, 8', salida, 'N');
      list.Linea(96, list.Lineactual, boletas_work.FieldByName('estado').AsString, 8, 'Arial, normal, 8', salida, 'S');
      totales[1] := totales[1] + monto;
    end;
    boletas_work.Next;
  end;
  datosdb.QuitarFiltro(boletas_work);
  boletas_work.Active := t;

  if totales[1] > 0 then Begin
    list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S');
    list.Linea(0, 0, 'Subtotal:', 1, 'Arial, negrita, 8', salida, 'N');
    list.importe(90, list.Lineactual, '', monto, 2, 'Arial, negrita, 8');
    list.Linea(91, list.Lineactual, '', 3, 'Arial, negrita, 8', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, negrita, 12', salida, 'S');
  end else Begin
    list.Linea(0, 0, '     *** No se Registraron Operaciones ***', 1, 'Arial, normal, 11', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'S');
  end;

  totales[3] := totales[3] + totales[1];
  totales[1] := 0;

  list.Linea(0, 0, ' *** Ingreso por Cobro de Sellado y Gastos Administrativos ***', 1, 'Arial, normal, 11', salida, 'S');
  list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S');

  boletas_work.First; monto := 0;
  while not boletas_work.Eof do Begin
    if boletas_work.FieldByName('tipobol').AsString = 'GAS' then Begin
      if boletas_work.FieldByName('tipobol').AsString <> 'AMC' then Begin
        prestatario.getDatos(boletas_work.FieldByName('codprest').AsString);
        nombre := prestatario.nombre;
      end else Begin
        municipio.getDatos(Copy(boletas_work.FieldByName('codprest').AsString, 2, 4));
        nombre := municipio.nombre;
      end;
      l := True;
      if boletas_work.FieldByName('imput').AsString = '1' then monto := boletas_work.FieldByName('montovto1').AsFloat else
        monto := boletas_work.FieldByName('montovto2').AsFloat;
      list.Linea(0, 0, utiles.sFormatoFecha(boletas_work.FieldByName('fecha').AsString) + ' - ' + boletas_work.FieldByName('hora').AsString, 1, 'Arial, normal, 8', salida, 'N');
      list.Linea(16, list.Lineactual, boletas_work.FieldByName('codprest').AsString + '-' + boletas_work.FieldByName('expediente').AsString + '  ' + Copy(nombre, 1, 30), 2, 'Arial, normal, 8', salida, 'N');
      list.Linea(50, list.Lineactual, utiles.sFormatoFecha(boletas_work.FieldByName('fechavto1').AsString), 3, 'Arial, normal, 8', salida, 'N');
      list.Linea(60, list.Lineactual, utiles.sFormatoFecha(boletas_work.FieldByName('fechavto2').AsString), 4, 'Arial, normal, 8', salida, 'N');
      list.Linea(78, list.Lineactual, boletas_work.FieldByName('imput').AsString, 5, 'Arial, normal, 8', salida, 'N');
      list.importe(90, list.Lineactual, '', monto, 6, 'Arial, normal, 8');
      list.Linea(91, list.Lineactual, boletas_work.FieldByName('tipobol').AsString, 7, 'Arial, normal, 8', salida, 'N');
      list.Linea(96, list.Lineactual, boletas_work.FieldByName('estado').AsString, 8, 'Arial, normal, 8', salida, 'S');
      totales[1] := totales[1] + monto;
    end;
    boletas_work.Next;
  end;
  datosdb.QuitarFiltro(boletas_work);
  boletas_work.Active := t;

  if totales[1] > 0 then Begin
    list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S');
    list.Linea(0, 0, 'Subtotal:', 1, 'Arial, negrita, 8', salida, 'N');
    list.importe(90, list.Lineactual, '', monto, 2, 'Arial, negrita, 8');
    list.Linea(91, list.Lineactual, '', 3, 'Arial, negrita, 8', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, negrita, 12', salida, 'S');
  end else Begin
    list.Linea(0, 0, '     *** No se Registraron Operaciones ***', 1, 'Arial, normal, 11', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'S');
  end;

  totales[3] := totales[3] + totales[1];
  totales[1] := 0;

  list.Linea(0, 0, ' *** Ingreso por Cobro de Aportes Municipios y Comunas ***', 1, 'Arial, normal, 11', salida, 'S');
  list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S');

  boletas_work.First; monto := 0;
  while not boletas_work.Eof do Begin
    if boletas_work.FieldByName('tipobol').AsString = 'AMC' then Begin
      if boletas_work.FieldByName('tipobol').AsString <> 'AMC' then Begin
        prestatario.getDatos(boletas_work.FieldByName('codprest').AsString);
        nombre := prestatario.nombre;
      end else Begin
        municipio.getDatos(Copy(boletas_work.FieldByName('codprest').AsString, 2, 4));
        nombre := municipio.nombre;
      end;
      l := True;
      if boletas_work.FieldByName('imput').AsString = '1' then monto := boletas_work.FieldByName('montovto1').AsFloat else
        monto := boletas_work.FieldByName('montovto2').AsFloat;
      list.Linea(0, 0, utiles.sFormatoFecha(boletas_work.FieldByName('fecha').AsString) + ' - ' + boletas_work.FieldByName('hora').AsString, 1, 'Arial, normal, 8', salida, 'N');
      list.Linea(16, list.Lineactual, boletas_work.FieldByName('codprest').AsString + '-' + boletas_work.FieldByName('expediente').AsString + '  ' + Copy(nombre, 1, 30), 2, 'Arial, normal, 8', salida, 'N');
      list.Linea(50, list.Lineactual, utiles.sFormatoFecha(boletas_work.FieldByName('fechavto1').AsString), 3, 'Arial, normal, 8', salida, 'N');
      list.Linea(60, list.Lineactual, utiles.sFormatoFecha(boletas_work.FieldByName('fechavto2').AsString), 4, 'Arial, normal, 8', salida, 'N');
      list.Linea(78, list.Lineactual, boletas_work.FieldByName('imput').AsString, 5, 'Arial, normal, 8', salida, 'N');
      list.importe(90, list.Lineactual, '', monto, 6, 'Arial, normal, 8');
      list.Linea(91, list.Lineactual, boletas_work.FieldByName('tipobol').AsString, 7, 'Arial, normal, 8', salida, 'N');
      list.Linea(96, list.Lineactual, boletas_work.FieldByName('estado').AsString, 8, 'Arial, normal, 8', salida, 'S');
      totales[1] := totales[1] + monto;
    end;
    boletas_work.Next;
  end;
  datosdb.QuitarFiltro(boletas_work);
  boletas_work.Active := t;

  if totales[1] > 0 then Begin
    list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S');
    list.Linea(0, 0, 'Subtotal:', 1, 'Arial, negrita, 8', salida, 'N');
    list.importe(90, list.Lineactual, '', monto, 2, 'Arial, negrita, 8');
    list.Linea(91, list.Lineactual, '', 3, 'Arial, negrita, 8', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, negrita, 12', salida, 'S');
  end else Begin
    list.Linea(0, 0, '     *** No se Registraron Operaciones ***', 1, 'Arial, normal, 11', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'S');
  end;

  totales[3] := totales[3] + totales[1];
  totales[1] := 0;

  if not l then list.Linea(0, 0, 'No Existen Datos para Listar ...!', 1, 'Arial, normal, 10', salida, 'S');

  list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
  list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S');
  list.Linea(0, 0, 'Total a General:', 1, 'Arial, negrita, 8', salida, 'N');
  list.importe(90, list.Lineactual, '', totales[3], 3, 'Arial, negrita, 8');
  list.Linea(91, list.Lineactual, '', 4, 'Arial, negrita, 8', salida, 'S');

  list.FinList;
end;

procedure TTBoletas.ListarBoletasAnuladas(xdfecha, xhfecha: String; salida: char);
// Objetivo...: Listar Boletas Anuladas
var
  t, l: Boolean;
  nombre: String;
  monto: Real;
Begin
  list.Setear(salida); list.altopag := 0; list.m := 0;
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Boletas Anuladas en el Lapso: ' + xdfecha + ' - ' + xhfecha, 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Fecha - Comprobante', 1, 'Arial, cursiva, 8');
  List.Titulo(16, list.Lineactual, 'Expediente / Prestatario', 2, 'Arial, cursiva, 8');
  List.Titulo(52, list.Lineactual, '1º Vto.', 3, 'Arial, cursiva, 8');
  List.Titulo(60, list.Lineactual, '2º Vto.', 4, 'Arial, cursiva, 8');
  List.Titulo(70, list.Lineactual, 'Monto', 5, 'Arial, cursiva, 8');
  List.Titulo(76, list.Lineactual, 'Fecha', 6, 'Arial, cursiva, 8');
  List.Titulo(83, list.Lineactual, 'Observación', 7, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  IniciarTotales;

  t := boletas_work.Active; l := False;
  if not boletas_work.Active then boletas_work.Open;
  datosdb.Filtrar(boletas_work, 'fechaliq >= ' + '''' + utiles.sExprFecha2000(xdfecha) + '''' + ' and fechaliq <= ' + '''' + utiles.sExprFecha2000(xhfecha) + '''' + ' and estado = ' + '''' + 'A' + '''');

  list.Linea(0, 0, ' *** Ingreso por Cobro de Créditos ***', 1, 'Arial, normal, 11', salida, 'S');
  list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S');

  boletas_work.First; monto := 0;
  while not boletas_work.Eof do Begin
    if boletas_work.FieldByName('tipobol').AsString = 'REC' then Begin
      if boletas_work.FieldByName('tipobol').AsString <> 'AMC' then Begin
        prestatario.getDatos(boletas_work.FieldByName('codprest').AsString);
        nombre := prestatario.nombre;
      end else Begin
        municipio.getDatos(Copy(boletas_work.FieldByName('codprest').AsString, 2, 4));
        nombre := municipio.nombre;
      end;
      l := True;
      if boletas_work.FieldByName('imput').AsString = '1' then monto := boletas_work.FieldByName('montovto1').AsFloat else
        monto := boletas_work.FieldByName('montovto2').AsFloat;
      list.Linea(0, 0, utiles.sFormatoFecha(boletas_work.FieldByName('fecha').AsString) + ' ' + boletas_work.FieldByName('idc').AsString + ' ' + boletas_work.FieldByName('tipo').AsString + ' ' + boletas_work.FieldByName('sucursal').AsString + '-' + boletas_work.FieldByName('numero').AsString, 1, 'Arial, normal, 8', salida, 'N');
      list.Linea(23, list.Lineactual, boletas_work.FieldByName('codprest').AsString + '-' + boletas_work.FieldByName('expediente').AsString + '  ' + Copy(nombre, 1, 30), 2, 'Arial, normal, 8', salida, 'N');
      list.Linea(52, list.Lineactual, utiles.sFormatoFecha(boletas_work.FieldByName('fechavto1').AsString), 3, 'Arial, normal, 8', salida, 'N');
      list.Linea(60, list.Lineactual, utiles.sFormatoFecha(boletas_work.FieldByName('fechavto2').AsString), 4, 'Arial, normal, 8', salida, 'N');
      list.importe(75, list.Lineactual, '', monto, 5, 'Arial, normal, 8');
      list.Linea(76, list.Lineactual, utiles.sFormatoFecha(boletas_work.FieldByName('fechaan').AsString), 6, 'Arial, normal, 8', salida, 'N');
      list.Linea(83, list.Lineactual, boletas_work.FieldByName('observac').AsString, 7, 'Arial, normal, 8', salida, 'S');
      totales[1] := totales[1] + monto;
    end;
    boletas_work.Next;
  end;
  boletas_work.Active := t;

  if totales[1] > 0 then Begin
    list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S');
    list.Linea(0, 0, 'Subtotal:', 1, 'Arial, negrita, 8', salida, 'N');
    list.importe(90, list.Lineactual, '', monto, 2, 'Arial, negrita, 8');
    list.Linea(91, list.Lineactual, '', 3, 'Arial, negrita, 8', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, negrita, 12', salida, 'S');
  end else Begin
    list.Linea(0, 0, '     *** No se Registraron Operaciones ***', 1, 'Arial, normal, 11', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'S');
  end;

  totales[3] := totales[3] + totales[1];
  totales[1] := 0;

  list.Linea(0, 0, ' *** Ingreso por Cobro de Sellado y Gastos Administrativos ***', 1, 'Arial, normal, 11', salida, 'S');
  list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S');

  boletas_work.First; monto := 0;
  while not boletas_work.Eof do Begin
    if boletas_work.FieldByName('tipobol').AsString = 'GAS' then Begin
      if boletas_work.FieldByName('tipobol').AsString <> 'AMC' then Begin
        prestatario.getDatos(boletas_work.FieldByName('codprest').AsString);
        nombre := prestatario.nombre;
      end else Begin
        municipio.getDatos(Copy(boletas_work.FieldByName('codprest').AsString, 2, 4));
        nombre := municipio.nombre;
      end;
      l := True;
      if boletas_work.FieldByName('imput').AsString = '1' then monto := boletas_work.FieldByName('montovto1').AsFloat else
        monto := boletas_work.FieldByName('montovto2').AsFloat;
      list.Linea(0, 0, utiles.sFormatoFecha(boletas_work.FieldByName('fecha').AsString) + ' ' + boletas_work.FieldByName('idc').AsString + ' ' + boletas_work.FieldByName('tipo').AsString + ' ' + boletas_work.FieldByName('sucursal').AsString + '-' + boletas_work.FieldByName('numero').AsString, 1, 'Arial, normal, 8', salida, 'N');
      list.Linea(23, list.Lineactual, boletas_work.FieldByName('codprest').AsString + '-' + boletas_work.FieldByName('expediente').AsString + '  ' + Copy(nombre, 1, 30), 2, 'Arial, normal, 8', salida, 'N');
      list.Linea(52, list.Lineactual, utiles.sFormatoFecha(boletas_work.FieldByName('fechavto1').AsString), 3, 'Arial, normal, 8', salida, 'N');
      list.Linea(60, list.Lineactual, utiles.sFormatoFecha(boletas_work.FieldByName('fechavto2').AsString), 4, 'Arial, normal, 8', salida, 'N');
      list.importe(75, list.Lineactual, '', monto, 5, 'Arial, normal, 8');
      list.Linea(76, list.Lineactual, utiles.sFormatoFecha(boletas_work.FieldByName('fechaan').AsString), 6, 'Arial, normal, 8', salida, 'N');
      list.Linea(83, list.Lineactual, boletas_work.FieldByName('observac').AsString, 7, 'Arial, normal, 8', salida, 'S');
      totales[1] := totales[1] + monto;
    end;
    boletas_work.Next;
  end;
  boletas_work.Active := t;

  if totales[1] > 0 then Begin
    list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S');
    list.Linea(0, 0, 'Subtotal:', 1, 'Arial, negrita, 8', salida, 'N');
    list.importe(90, list.Lineactual, '', monto, 2, 'Arial, negrita, 8');
    list.Linea(91, list.Lineactual, '', 3, 'Arial, negrita, 8', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, negrita, 12', salida, 'S');
  end else Begin
    list.Linea(0, 0, '     *** No se Registraron Operaciones ***', 1, 'Arial, normal, 11', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'S');
  end;

  totales[3] := totales[3] + totales[1];
  totales[1] := 0;

  list.Linea(0, 0, ' *** Ingreso por Cobro de Aportes Municipios y Comunas ***', 1, 'Arial, normal, 11', salida, 'S');
  list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S');

  boletas_work.First; monto := 0;
  while not boletas_work.Eof do Begin
    if boletas_work.FieldByName('tipobol').AsString = 'AMC' then Begin
      if boletas_work.FieldByName('tipobol').AsString <> 'AMC' then Begin
        prestatario.getDatos(boletas_work.FieldByName('codprest').AsString);
        nombre := prestatario.nombre;
      end else Begin
        municipio.getDatos(Copy(boletas_work.FieldByName('codprest').AsString, 2, 4));
        nombre := municipio.nombre;
      end;
      l := True;
      if boletas_work.FieldByName('imput').AsString = '1' then monto := boletas_work.FieldByName('montovto1').AsFloat else
        monto := boletas_work.FieldByName('montovto2').AsFloat;
      list.Linea(0, 0, utiles.sFormatoFecha(boletas_work.FieldByName('fecha').AsString) + ' - ' + boletas_work.FieldByName('idc').AsString + ' ' + boletas_work.FieldByName('tipo').AsString + ' ' + boletas_work.FieldByName('sucursal').AsString + '-' + boletas_work.FieldByName('numero').AsString, 1, 'Arial, normal, 8', salida, 'N');
      list.Linea(23, list.Lineactual, boletas_work.FieldByName('codprest').AsString + '-' + boletas_work.FieldByName('expediente').AsString + '  ' + Copy(nombre, 1, 30), 2, 'Arial, normal, 8', salida, 'N');
      list.Linea(52, list.Lineactual, utiles.sFormatoFecha(boletas_work.FieldByName('fechavto1').AsString), 3, 'Arial, normal, 8', salida, 'N');
      list.Linea(60, list.Lineactual, utiles.sFormatoFecha(boletas_work.FieldByName('fechavto2').AsString), 4, 'Arial, normal, 8', salida, 'N');
      list.importe(75, list.Lineactual, '', monto, 5, 'Arial, normal, 8');
      list.Linea(76, list.Lineactual, utiles.sFormatoFecha(boletas_work.FieldByName('fechaan').AsString), 6, 'Arial, normal, 8', salida, 'N');
      list.Linea(83, list.Lineactual, boletas_work.FieldByName('observac').AsString, 7, 'Arial, normal, 8', salida, 'S');
      totales[1] := totales[1] + monto;
    end;
    boletas_work.Next;
  end;
  datosdb.QuitarFiltro(boletas_work);
  boletas_work.Active := t;

  if totales[1] > 0 then Begin
    list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S');
    list.Linea(0, 0, 'Subtotal:', 1, 'Arial, negrita, 8', salida, 'N');
    list.importe(90, list.Lineactual, '', monto, 2, 'Arial, negrita, 8');
    list.Linea(91, list.Lineactual, '', 3, 'Arial, negrita, 8', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, negrita, 12', salida, 'S');
  end else Begin
    list.Linea(0, 0, '     *** No se Registraron Operaciones ***', 1, 'Arial, normal, 11', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'S');
  end;

  totales[3] := totales[3] + totales[1];
  totales[1] := 0;

  if not l then list.Linea(0, 0, 'No Existen Datos para Listar ...!', 1, 'Arial, normal, 10', salida, 'S');

  list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
  list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S');
  list.Linea(0, 0, 'Total a General:', 1, 'Arial, negrita, 8', salida, 'N');
  list.importe(90, list.Lineactual, '', totales[3], 3, 'Arial, negrita, 8');
  list.Linea(91, list.Lineactual, '', 4, 'Arial, negrita, 8', salida, 'S');

  list.FinList;
end;

procedure TTBoletas.MarcarBoletaComoPaga(xcodigobarra, xfecha, xhora, xfechaliq, xmontoimput: String);
// Objetivo...: Marcar la Boleta como Paga
Begin
  if datosdb.Buscar(boletas_work, 'codigobarra', 'fecha', 'hora', xcodigobarra, utiles.sExprFecha2000(xfecha), xhora) then Begin
    boletas_work.Edit;
    boletas_work.FieldByName('estado').AsString   := 'C';
    boletas_work.FieldByName('fechaliq').AsString := utiles.sExprFecha2000(xfechaliq);
    boletas_work.FieldByName('imput').AsString    := xmontoimput;
    try
      boletas_work.Post
     except
      boletas_work.Cancel
    end;
    datosdb.refrescar(boletas_work);
  end;
end;

procedure TTBoletas.AnularBoletaPaga(xcodigobarra, xfecha, xhora, xobservac, xfechaan: String);
// Objetivo...: Anular Boleta
Begin
  if datosdb.Buscar(boletas_work, 'codigobarra', 'fecha', 'hora', xcodigobarra, utiles.sExprFecha2000(xfecha), xhora) then Begin
    boletas_work.Edit;
    boletas_work.FieldByName('estado').AsString   := 'A';
    boletas_work.FieldByName('observac').AsString := xobservac;
    boletas_work.FieldByName('fechaan').AsString  := utiles.sExprFecha2000(xfechaan);
    try
      boletas_work.Post
     except
      boletas_work.Cancel
    end;
    datosdb.refrescar(boletas_work);
  end;
end;

procedure TTBoletas.IniciarTotales;
// Objetivo...: Reinicar arreglos
var
  i: Integer;
Begin
  for i := 1 to 10 do totales[i] := 0;
end;

function  TTBoletas.VerificarCantidadCuotasPendientes(xcodprest, xexpediente: String): Integer;
// Objetivo...: verificar si tiene cuotas pendientes
var
  cantidad: Integer;
Begin
  cantidad := 0;
  datosdb.Filtrar(boletas_work, 'codprest = ' + '''' + xcodprest + '''' + ' and expediente = ' + '''' + xexpediente + '''');
  boletas_work.First;
  while not boletas_work.Eof do Begin
    if boletas_work.FieldByName('estado').AsString = 'P' then Inc(cantidad);
    boletas_work.Next;
  end;
  datosdb.QuitarFiltro(boletas_work);
  Result := cantidad;
end;

procedure TTBoletas.FiltrarTipoBoleta(xtipo: String);
// Objetivo...: aplicar filtro por tipo de boleta
Begin
  datosdb.Filtrar(boletas_work, 'tipobol = ' + '''' + xtipo + '''');
end;


procedure TTBoletas.QuitarFiltro;
// Objetivo...: quitar filtro
Begin
  datosdb.QuitarFiltro(boletas_work);
end;

procedure TTBoletas.conectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones = 0 then Begin
    if not boletas_work.Active then boletas_work.Open;
    if not boletas_detwork.Active then boletas_detwork.Open;
  end;
  Inc(conexiones);
end;

procedure TTBoletas.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones > 0 then Dec(conexiones);
  if conexiones = 0 then Begin
    datosdb.closeDB(boletas_work);
    datosdb.closeDB(boletas_detwork);
  end;
end;

{===============================================================================}

function boleta: TTBoletas;
begin
  if xboleta = nil then
    xboleta := TTBoletas.Create;
  Result := xboleta;
end;

{===============================================================================}

initialization

finalization
  xboleta.Free;

end.
