unit CCVentas_CCB;

interface

uses CInsumos_Centrobioq, CProfesionalCCB, CBDT, SysUtils, DBTables, CUtiles, CListar, CIDBFM, Classes;

const
  idm = 'FI1';
  tamanio = 600;

type

TTVentasCCB = class
  Periodo, Idprof, Items, Idinsumo, Fecha, Concepto: String; Cantidad, Monto: Real;
  ModeloImpr: String; Copias, Topeitems, Separacion: Integer;
  ExisteOrden: Boolean;
  tabla, detalle, modelo: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  function    Buscar(xperiodo, xidprof, xitems: String): Boolean;
  procedure   Registrar(xperiodo, xidprof, xitems, xnroitems, xidinsumo, xfecha, xconcepto: String; xcantidad, xmonto: Real; xcantidadItems: Integer);
  procedure   Borrar(xperiodo, xidprof, xitems: String); overload;
  procedure   Borrar(xperiodo, xidprof: String); overload;
  procedure   getDatos(xperiodo, xidprof, xitems: String);
  function    setOrdenes(xperiodo, xidprof: String): TStringList;
  function    setItems: TStringList;

  procedure   ImprimirOrden(salida: char);
  procedure   ListarDetalleOperaciones(xperiodo: String; lista: TStringList; salida: char);

  function    BuscarModelo: Boolean;
  procedure   DefinirModeloImpresion(xformatoimpr: String; xcopias, xtopeitems, xseparacion: Integer);
  procedure   getDatosModeloImpresion;

  function    setVentaInsumosProfesionales(xperiodo: String): TStringList;
  function    setTotalVentaInsumosPorProfesional(xperiodo: String): TStringList;
  procedure   ListarResumenProfesional(xperiodo: String; lista: TStringList; salida: char);

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  conexiones: shortint;
  basedatos: String;
  totales: array[1..5] of Real;
  lin: Boolean;
  function    BuscarItems(xperiodo, xidprof, xitems, xnroitems: String): Boolean;
  procedure   ListTotalProf(salida: char);
  procedure   TotalGeneral(salida: char);
end;

function ventainsumos: TTVentasCCB;

implementation

var
  xventainsumos: TTVentasCCB = nil;

constructor TTVentasCCB.Create;
begin
  {if dbs.BaseClientServ = 'N' then basedatos := dbs.DirSistema + '\distribucion\arch' else basedatos := 'distribucion';
  basedatos  := dbs.DirSistema + '\distribucion\arch';}
  //utiles.msgError('dist');
  {dbs.getParametrosDB2;     // Base de datos adicional 2
  if Length(Trim(dbs.db2)) > 0 then Begin
    dbs.NuevaBaseDeDatos2(dbs.db2, dbs.us2, dbs.pa2);
    basedatos := dbs.db2;
  end else
    basedatos := dbs.DirSistema + '\distribucion\arch';}

  tabla   := datosdb.openDB('ventas_cab', '', '', dbs.baseDat);
  detalle := datosdb.openDB('ventas_det', '', '', dbs.baseDat);
  modelo  := datosdb.openDB('modeloImpr', '', '', dbs.baseDat);
end;

destructor TTVentasCCB.Destroy;
begin
  inherited Destroy;
end;

function  TTVentasCCB.Buscar(xperiodo, xidprof, xitems: String): Boolean;
Begin
  if tabla.IndexFieldNames <> 'Periodo;Items;Idprof' then tabla.IndexFieldNames := 'Periodo;Items;Idprof';
  ExisteOrden := datosdb.Buscar(tabla, 'Periodo', 'Idprof', 'Items', xperiodo, xidprof, xitems);
  Periodo     := xperiodo;
  Idprof      := xidprof;
  Result      := ExisteOrden;
end;

function  TTVentasCCB.BuscarItems(xperiodo, xidprof, xitems, xnroitems: String): Boolean;
Begin
  if detalle.IndexFieldNames <> 'Periodo;Idprof;Items;Nroitems' then detalle.IndexFieldNames := 'Periodo;Idprof;Items;Nroitems';
  Result := datosdb.Buscar(detalle, 'Periodo', 'Idprof', 'Items', 'Nroitems', xperiodo, xidprof, xitems, xnroitems);
end;

procedure TTVentasCCB.Registrar(xperiodo, xidprof, xitems, xnroitems, xidinsumo, xfecha, xconcepto: String; xcantidad, xmonto: Real; xcantidadItems: Integer);
Begin
  if xnroitems = '001' then Begin
    if (Length(Trim(xitems)) = 0) then Items := utiles.setIdRegistroFecha else Items := xitems;
    //datosdb.tranSQL(basedatos, 'delete from ventas_det where periodo = ' + '"' + xperiodo + '"' + ' and items = ' + '"' + Items + '"' + ' and idprof = ' + '"' + xidprof + '"');
    //datosdb.refrescar(detalle);
    if Buscar(xperiodo, xidprof, Items) then tabla.Edit else tabla.Append;
    tabla.FieldByName('periodo').AsString  := xperiodo;
    tabla.FieldByName('idprof').AsString   := xidprof;
    tabla.FieldByName('items').AsString    := Items;
    tabla.FieldByName('fecha').AsString    := utiles.sExprFecha2000(xfecha);
    try
      tabla.Post
     except
      tabla.Cancel
    end;
    datosdb.closeDB(tabla); tabla.Open;
  end;

  if BuscarItems(xperiodo, xidprof, Items, xnroitems) then detalle.Edit else detalle.Append;
  detalle.FieldByName('periodo').AsString  := xperiodo;
  detalle.FieldByName('idprof').AsString   := xidprof;
  detalle.FieldByName('items').AsString    := Items;
  detalle.FieldByName('nroitems').AsString := xnroitems;
  detalle.FieldByName('idinsumo').AsString := xidinsumo;
  detalle.FieldByName('concepto').AsString := xconcepto;
  detalle.FieldByName('cantidad').AsFloat  := xcantidad;
  detalle.FieldByName('monto').AsFloat     := xmonto;
  try
    detalle.Post
   except
    detalle.Cancel
  end;
  //detalle.Refresh;

  if xnroitems = utiles.sLlenarIzquierda(IntToStr(xcantidaditems), 3, '0') then Begin
    datosdb.tranSQL(basedatos, 'delete from ventas_det where periodo = ' + '"' + xperiodo + '"' + ' and items = ' + '"' + Items + '"' + ' and idprof = ' + '"' + xidprof + '"' + ' and nroitems > ' + '"' + utiles.sLlenarIzquierda(IntToStr(xcantidaditems), 3, '0') + '"');
    datosdb.closeDB(detalle); detalle.Open;
  end;

end;

procedure TTVentasCCB.Borrar(xperiodo, xidprof, xitems: String);
Begin
  if Buscar(xperiodo, xidprof, xitems) then Begin
    tabla.Delete;
    datosdb.tranSQL(basedatos, 'delete from ventas_det where periodo = ' + '"' + xperiodo + '"' + ' and items = ' + '"' + Items + '"' + ' and idprof = ' + '"' + xidprof + '"');
    datosdb.closeDB(tabla); tabla.Open;
    datosdb.closeDB(detalle); detalle.Open;
  end;
end;

procedure TTVentasCCB.Borrar(xperiodo, xidprof: String);
Begin
  datosdb.tranSQL(basedatos, 'delete from ventas_cab where periodo = ' + '"' + xperiodo + '"' + ' and idprof = ' + '"' + xidprof + '"');
  datosdb.tranSQL(basedatos, 'delete from ventas_det where periodo = ' + '"' + xperiodo + '"' + ' and idprof = ' + '"' + xidprof + '"');
  datosdb.refrescar(tabla);
  datosdb.refrescar(detalle);
end;

procedure TTVentasCCB.getDatos(xperiodo, xidprof, xitems: String);
Begin
  if Buscar(xperiodo, xidprof, xitems) then Begin
    Periodo  := tabla.FieldByName('periodo').AsString;
    Idprof   := tabla.FieldByName('idprof').AsString;
    Items    := tabla.FieldByName('items').AsString;
    Fecha    := utiles.sFormatoFecha(tabla.FieldByName('fecha').AsString);
  end else Begin
    Periodo := ''; Idprof := ''; Items := ''; Fecha := '';
  end;
end;

function  TTVentasCCB.setOrdenes(xperiodo, xidprof: String): TStringList;
// Objetivo...: Devolver Lista de Ordenes del Profesional
var
  l: TStringList;
Begin
  l := TStringList.Create;
  tabla.IndexFieldNames := 'Periodo;Idprof';
  if datosdb.Buscar(tabla, 'Periodo', 'Idprof', xperiodo, xidprof) then Begin
    while not tabla.Eof do Begin
      if tabla.FieldByName('idprof').AsString <> xidprof then Break;
      l.Add(tabla.FieldByName('fecha').AsString + tabla.FieldByName('items').AsString);
      tabla.Next;
    end;
  end;
  tabla.IndexFieldNames := 'Periodo;Items;Idprof';

  Result := l;
end;

function TTVentasCCB.setItems: TStringList;
// Objetivo...: Devolver Items de la Orden
var
  l: TStringList;
  r: TQuery;
Begin
  r := datosdb.tranSQL('select * from ventas_det where periodo = ' + '''' + periodo + '''' + ' and idprof = ' + '''' + idprof + '''' + ' order by nroitems');
  r.open;

  l := TStringList.Create;
  while not r.Eof do Begin
    l.Add(r.FieldByName('idinsumo').AsString + r.FieldByName('cantidad').AsString + ';1' + r.FieldByName('monto').AsString + ';2' + r.FieldByName('monto').AsString);
    r.Next;
  end;

  r.close; r.free;

  {
  if BuscarItems(Periodo, Idprof, Items, '001') then Begin
    while not detalle.Eof do Begin
      if detalle.FieldByName('items').AsString <> Items then Break;
      l.Add(detalle.FieldByName('idinsumo').AsString + detalle.FieldByName('cantidad').AsString + ';1' + detalle.FieldByName('monto').AsString + ';2' + detalle.FieldByName('monto').AsString);
      detalle.Next;
    end;
  end;
  }
  Result := l;
end;

procedure TTVentasCCB.ImprimirOrden(salida: char);
// Objetivo...: Imprimir Orden
var
  i, j, k: Integer;
begin
  list.Setear(salida);
  list.altopag := 0; list.m := 0;
  list.IniciarTitulos;
  list.NoImprimirPieDePagina;
  getDatosModeloImpresion;
  for i := 1 to copias do Begin
   getDatos(tabla.FieldByName('periodo').AsString, tabla.FieldByName('idprof').AsString, tabla.FieldByName('items').AsString);

   profesional.getDatos(tabla.FieldByName('idprof').AsString);
   list.IniciarMemoImpresiones(modelo, 'modelo', Tamanio);
   list.RemplazarEtiquetasEnMemo('#profesional', profesional.nombre);
   list.RemplazarEtiquetasEnMemo('#cuenta', profesional.codigo);
   list.RemplazarEtiquetasEnMemo('#fecha', Fecha);
   list.ListMemo('', 'Arial, normal, 8', 0, salida, nil, tamanio, 5, '#parte1_inicio', '#parte1_fin');

   totales[1] := 0; k := 0;
   if BuscarItems(Periodo, Idprof, Items, '001') then Begin
     while not detalle.Eof do Begin
       if detalle.FieldByName('items').AsString <> Items then Break;
       insumo.getDatos(detalle.FieldByName('idinsumo').AsString);
       list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'N');
       list.importe(10, list.Lineactual, '', detalle.FieldByName('cantidad').AsFloat, 2, 'Arial, normal, 8');
       list.Linea(12, list.Lineactual, insumo.Id + '   ' + insumo.Descrip, 3, 'Arial, normal, 8', salida, 'N');
       list.importe(75, list.Lineactual, '', detalle.FieldByName('Monto').AsFloat, 4, 'Arial, normal, 8');
       list.importe(90, list.Lineactual, '', detalle.FieldByName('Monto').AsFloat * detalle.FieldByName('cantidad').AsFloat, 5, 'Arial, normal, 8');
       list.Linea(95, list.Lineactual, ' ', 6, 'Arial, normal, 8', salida, 'S');
       totales[1] := totales[1] + (detalle.FieldByName('Monto').AsFloat * detalle.FieldByName('cantidad').AsFloat);
       detalle.Next;
       Inc(k);
     end;
   end;

   for j := k to topeitems do list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'S');

   list.RemplazarEtiquetasEnMemo('#total', utiles.FormatearNumero(FloatToStr(totales[1])));
   list.ListMemo('', 'Arial, normal, 8', 0, salida, nil, tamanio, 5, '#parte2_inicio', '#parte2_fin');
   list.LiberarMemoImpresiones;

   if  i = Copias then list.CompletarPagina else
     for j := 1 to Separacion do list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'S');
  end;

  list.FinList;
end;

procedure TTVentasCCB.ListarDetalleOperaciones(xperiodo: String; lista: TStringList; salida: char);
var
  idanter: String;
  detalle: TQuery;
Begin
  list.Setear(salida);
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Detalle Venta Insumos a Profesionales  - Período: ' + xperiodo, 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Fecha', 1, 'Arial, cursiva, 8');
  List.Titulo(8, list.Lineactual, 'Cant.', 2, 'Arial, cursiva, 8');
  List.Titulo(13, list.Lineactual, 'Código   Descripción Insumo', 3, 'Arial, cursiva, 8');
  list.Titulo(70, list.Lineactual, 'Precio', 4, 'Arial, cursiva, 8');
  list.Titulo(90, list.Lineactual, 'Total', 5, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  tabla.IndexFieldNames := 'Periodo;Idprof;Fecha';
  datosdb.Filtrar(tabla, 'periodo = ' + '''' + xperiodo + '''');
  tabla.First; totales[1] := 0; totales[2] := 0; lin := False;
  while not tabla.Eof do Begin
    if utiles.verificarItemsLista(lista, tabla.FieldByName('idprof').AsString) then Begin
      if tabla.FieldByName('idprof').AsString <> idanter then Begin
        ListTotalProf(salida);
        profesional.getDatos(tabla.FieldByName('idprof').AsString);
        list.Linea(0, 0, 'Profesional:  ' + profesional.codigo + '  ' + profesional.nombre, 1, 'Arial, negrita, 8', salida, 'S');
        list.Linea(0, 0, ' ', 1, 'Arial, negrita, 5', salida, 'S');
        idanter := tabla.FieldByName('idprof').AsString;
      end;

      //if BuscarItems(tabla.FieldByName('periodo').AsString, tabla.FieldByName('idprof').AsString, tabla.FieldByName('items').AsString, '001') then Begin
      detalle := datosdb.tranSQL('select * from ventas_det where periodo = ' + '''' + tabla.FieldByName('periodo').AsString + '''' + ' and idprof = ' + '''' + tabla.FieldByName('idprof').AsString + '''' + ' order by nroitems');
      detalle.open;
        while not detalle.Eof do Begin
          if detalle.FieldByName('items').AsString <> tabla.FieldByName('items').AsString then Break;
          if detalle.FieldByName('nroitems').AsString = '001' then Begin
            list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
            list.Linea(0, 0, utiles.sFormatoFecha(tabla.FieldByName('fecha').AsString), 1, 'Arial, normal, 8', salida, 'N');
          end else
            list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'N');
          list.importe(12, list.Lineactual, '', detalle.FieldByName('cantidad').AsFloat, 2, 'Arial, normal, 8');
          insumo.getDatos(detalle.FieldByName('idinsumo').AsString);
          list.Linea(13, list.Lineactual, insumo.Id + '  ' + insumo.Descrip, 3, 'Arial, normal, 8', salida, 'N');
          list.importe(75, list.Lineactual, '', detalle.FieldByName('monto').AsFloat, 4, 'Arial, normal, 8');
          list.importe(95, list.Lineactual, '', detalle.FieldByName('monto').AsFloat * detalle.FieldByName('cantidad').AsFloat, 5, 'Arial, normal, 8');
          list.Linea(95, list.Lineactual, '', 6, 'Arial, normal, 8', salida, 'S');
          totales[1] := totales[1] + (detalle.FieldByName('monto').AsFloat * detalle.FieldByName('cantidad').AsFloat);
          lin := True;
          detalle.Next;
        end;

      detalle.Close;
      detalle.free;
      //end;
    end;
    tabla.Next;
  end;

  ListTotalProf(salida);
  TotalGeneral(salida);

  datosdb.QuitarFiltro(tabla);
  tabla.IndexFieldNames := 'Periodo;Items;Idprof';

  if lin then list.FinList else utiles.msgError('No Existen Datos para Listar en este Período ...!');
end;

procedure TTVentasCCB.ListTotalProf(salida: char);
Begin
  if totales[1] > 0 then Begin
    list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'N');
    list.derecha(95, list.Lineactual, '##############', '---------------', 2, 'Arial, normal, 8');
    list.Linea(0, 0, 'Subtotal:', 1, 'Arial, negrita, 8', salida, 'N');
    list.importe(95, list.Lineactual, '', totales[1], 2, 'Arial, negrita, 8');
    list.Linea(95, list.Lineactual, '', 3, 'Arial, normal, 8', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'S');
    totales[2] := totales[2] + totales[1];
    totales[1] := 0;
  end;
end;

function TTVentasCCB.BuscarModelo: Boolean;
Begin
  Result := modelo.FindKey([idm]);
end;

procedure TTVentasCCB.DefinirModeloImpresion(xformatoimpr: String; xcopias, xtopeitems, xseparacion: Integer);
// Objetivo...: Definir Modelo Impesion
Begin
  if BuscarModelo then modelo.Edit else modelo.Append;
  modelo.FieldByName('id').AsString          := idm;
  modelo.FieldByName('modelo').AsString      := xformatoimpr;
  modelo.FieldByName('copias').AsInteger     := xcopias;
  modelo.FieldByName('topeitems').AsInteger  := xtopeitems;
  modelo.FieldByName('separacion').AsInteger := xseparacion;
end;

procedure TTVentasCCB.getDatosModeloImpresion;
Begin
  if BuscarModelo then Begin
    modeloImpr := modelo.FieldByName('modelo').AsString;
    copias     := modelo.FieldByName('copias').AsInteger;
    topeitems  := modelo.FieldByName('topeitems').AsInteger;
    separacion := modelo.FieldByName('separacion').AsInteger;
  end else Begin
    modeloImpr := ''; copias := 0; topeitems := 0; separacion := 0;
  end;
end;

function TTVentasCCB.setVentaInsumosProfesionales(xperiodo: String): TStringList;
// Objetivo...: Listar Total Venta Insumos
var
  tot: array[1..3] of Real;
  idanter, idanter1: String;
  l: TStringList;
Begin
  l := TStringList.Create;
  conectar;
  detalle.IndexFieldNames := 'Periodo;Idprof;Idinsumo';
  datosdb.Filtrar(detalle, 'periodo = ' + '''' + xperiodo + '''');
  detalle.First; tot[1] := 0; tot[2] := 0; tot[3] := 0;
  idanter  := detalle.FieldByName('idprof').AsString;
  idanter1 := detalle.FieldByName('idinsumo').AsString;
  while not detalle.Eof do Begin
    if (detalle.FieldByName('idinsumo').AsString <> idanter1) or (detalle.FieldByName('idprof').AsString <> idanter) then Begin
      l.Add(idanter + idanter1 + ';1' + utiles.FormatearNumero(FloatToStr(tot[1])) + ';2' + utiles.FormatearNumero(FloatToStr(tot[2])) + ';3' + utiles.FormatearNumero(FloatToStr(tot[3])));
      tot[1] := 0; tot[2] := 0; tot[3] := 0;
      idanter1 := detalle.FieldByName('idinsumo').AsString;
      idanter  := detalle.FieldByName('idprof').AsString;
    end;
    tot[1]   := tot[1] + detalle.FieldByName('cantidad').AsFloat * detalle.FieldByName('monto').AsFloat;
    tot[2]   := tot[2] + detalle.FieldByName('cantidad').AsFloat;
    tot[3]   := tot[3] + detalle.FieldByName('monto').AsFloat;
    detalle.Next;
  end;
  if tot[1] > 0 then l.Add(idanter + idanter1 + ';1' + utiles.FormatearNumero(FloatToStr(tot[1])) + ';2' + utiles.FormatearNumero(FloatToStr(tot[2])) + ';3' + utiles.FormatearNumero(FloatToStr(tot[3])));

  datosdb.QuitarFiltro(detalle);
  detalle.IndexFieldNames := 'Periodo;Idprof;Items;Nroitems';
  desconectar;

  Result := l;
end;

function  TTVentasCCB.setTotalVentaInsumosPorProfesional(xperiodo: String): TStringList;
// Objetivo...: Devolver el total de Ventas
var
  tot: array[1..3] of Real;
  idanter: String;
  l: TStringList;
Begin
  l := TStringList.Create;
  conectar;
  detalle.IndexFieldNames := 'Periodo;Idprof;Idinsumo';
  datosdb.Filtrar(detalle, 'periodo = ' + '''' + xperiodo + '''');
  detalle.First; tot[1] := 0;
  idanter  := detalle.FieldByName('idprof').AsString;
  while not detalle.Eof do Begin
    if detalle.FieldByName('idprof').AsString <> idanter then Begin
      l.Add(idanter + utiles.FormatearNumero(FloatToStr(tot[1])));
      tot[1] := 0;
      idanter  := detalle.FieldByName('idprof').AsString;
    end;
    tot[1]   := tot[1] + detalle.FieldByName('cantidad').AsFloat * detalle.FieldByName('monto').AsFloat;
    detalle.Next;
  end;
  if tot[1] > 0 then l.Add(idanter + utiles.FormatearNumero(FloatToStr(tot[1])));

  datosdb.QuitarFiltro(detalle);
  detalle.IndexFieldNames := 'Periodo;Idprof;Items;Nroitems';
  desconectar;

  Result := l;
end;

procedure TTVentasCCB.ListarResumenProfesional(xperiodo: String; lista: TStringList; salida: char);
// Objetivo...: Listar Resumen Venta Insumos
var
  l: TStringList;
  i, p1, p2, p3: Integer;
  idanter: String;
Begin
  list.Setear(salida);
  list.Titulo(0, 0, '', 1, 'Arial, negrita, 14');
  list.Titulo(0, 0, 'Resumen Venta Insumos por Profesional', 1, 'Arial, negrita, 14');
  list.Titulo(0, 0, '', 1, 'Arial, negrita, 5');
  list.Titulo(0, 0, '    Cód.     Descripción del Insumo', 1, 'Arial, cursiva, 8');
  list.Titulo(54, list.Lineactual, 'Cantidad', 2, 'Arial, cursiva, 8');
  list.Titulo(68, list.Lineactual, 'Precio', 3, 'Arial, cursiva, 8');
  list.Titulo(91, list.Lineactual, 'Total', 4, 'Arial, cursiva, 8');
  list.Titulo(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11');
  list.Titulo(0, 0, '  ', 1, 'Arial, normal, 5');

  l := setVentaInsumosProfesionales(xperiodo);
  totales[1] := 0; lin := False;

  for i := 1 to l.Count do Begin
    if utiles.verificarItemsLista(lista, Copy(l.Strings[i-1], 1, 6)) then Begin

      if Copy(l.Strings[i-1], 1, 6) <> idanter then Begin
        if totales[1] > 0 then ListTotalProf(salida);
        profesional.getDatos(Copy(l.Strings[i-1], 1, 6));
        list.Linea(0, 0, 'Profesional:   ' + Copy(l.Strings[i-1], 1, 6) + '-' + profesional.nombre, 1, 'Arial, negrita, 8', salida, 'S');
        list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
        idanter    := Copy(l.Strings[i-1], 1, 6);
        totales[1] := 0;
      end;

      insumo.getDatos(Copy(l.Strings[i-1], 7, 5));
      p1 := Pos(';1', l.Strings[i-1]);
      p2 := Pos(';2', l.Strings[i-1]);
      p3 := Pos(';3', l.Strings[i-1]);
      list.Linea(0, 0, '    ' + Copy(l.Strings[i-1], 7, 5) + '   ' + insumo.Descrip, 1, 'Arial, nomal, 8', salida, 'N');
      list.importe(60, list.Lineactual, '', StrToFloat(Copy(l.Strings[i-1], p2+2, p3 - (p2+2))), 2, 'Arial, normal, 8');
      list.importe(72, list.Lineactual, '', StrToFloat(Trim(Copy(l.Strings[i-1], p3+2, 10))), 3, 'Arial, normal, 8');
      list.importe(95, list.Lineactual, '', StrToFloat(Copy(l.Strings[i-1], 14, (p2-(p1+2)))), 4, 'Arial, normal, 8');
      list.Linea(95, list.Lineactual, '', 5, 'Arial, normal, 8', salida, 'S');
      totales[1] := totales[1] + StrToFloat(Copy(l.Strings[i-1], 14, (p2-(p1+2))));
      lin := True;

    end;
  end;

  if totales[1] > 0 then ListTotalProf(salida);
  TotalGeneral(salida);

  if lin then list.FinList else utiles.msgError('No Existen Datos para Listar en este Período ...!');
end;

procedure TTVentasCCB.TotalGeneral(salida: char);
// Objetivo...: total general
begin
  if totales[2] > 0 then Begin
    list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'N');
    list.derecha(95, list.Lineactual, '##############', '---------------', 2, 'Arial, normal, 8');
    list.Linea(0, 0, 'Total General:', 1, 'Arial, negrita, 8', salida, 'N');
    list.importe(95, list.Lineactual, '', totales[2], 2, 'Arial, negrita, 8');
    list.Linea(95, list.Lineactual, '', 3, 'Arial, normal, 8', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'S');
  end;
  totales[2] := 0;
end;

procedure TTVentasCCB.conectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones = 0 then Begin
    if not tabla.Active then tabla.Open;
    if not detalle.Active then detalle.Open;
    if not modelo.Active then modelo.Open;
  end;
  Inc(conexiones);
  profesional.conectar;
  insumo.conectar;
end;

procedure TTVentasCCB.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  Dec(conexiones);
  if conexiones = 0 then Begin
    datosdb.closeDB(tabla);
    datosdb.closeDB(detalle);
    datosdb.closeDB(modelo);
    if Length(Trim(dbs.db2)) > 0 then
      if dbs.TDB2.Connected then dbs.TDB2.Close;
  end;
  profesional.desconectar;
  insumo.desconectar;
end;

{===============================================================================}

function ventainsumos: TTVentasCCB;
begin
  if xventainsumos = nil then
    xventainsumos := TTVentasCCB.Create;
  Result := xventainsumos;
end;

{===============================================================================}

initialization

finalization
  xventainsumos.Free;

end.
