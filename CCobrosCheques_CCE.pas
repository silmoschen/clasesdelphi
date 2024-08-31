unit CCobrosCheques_CCE;

interface

uses CClienteCCE, CBancos, CFacturasCCE_Forms, CBDT, SysUtils, DBTables, CUtiles, CListar, CIDBFM, Contnrs;

type

TTCobroCheques = class
  Codcli, Nrocheque, Fecha, Feimput, Codbanco, Filial, Propio, Nrotrans, Idc, Tipo, Sucursal, Numero: String;
  Monto: Real;
  cheques, cheques_ref: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  function    Buscar(xcodcli, xnrocheque: String): Boolean;
  procedure   Registrar(xcodcli, xnrocheque, xfecha, xfeimput, xcodbanco, xfilial, xpropio, xnrotrans: String; xmonto: Real);
  procedure   RegistrarTransaccion(xcodcli, xnrocheque, xnrotrans: String);
  procedure   Borrar(xcodcli, xnrocheque: String);
  procedure   getDatos(xcodcli, xnrocheque: String);
  function    setChequesFecha(xfecha: String): TObjectList;
  function    setChequesCliente(xcodcli: String): TObjectList;

  function    BuscarRef(xcodcli, xnrocheque, xidc, xtipo, xsucursal, xnumero: String): Boolean;
  procedure   RegistrarRef(xcodcli, xnrocheque, xidc, xtipo, xsucursal, xnumero: String);
  procedure   BorrarRef(xcodcli, xnrocheque, xidc, xtipo, xsucursal, xnumero: String);
  function    setComprobantes(xcodcli, xnrocheque: String): TObjectList;

  procedure   Listar(xdesde, xhasta: String; salida: char);

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  conexiones: shortint;
end;

function cobrocheque: TTCobroCheques;

implementation

var
  xcobrocheque: TTCobroCheques = nil;

constructor TTCobroCheques.Create;
begin
  cheques     := datosdb.openDB('cheques_pagos', '');
  cheques_ref := datosdb.openDB('cheques_pagos_ref', '');
end;

destructor TTCobroCheques.Destroy;
begin
  inherited Destroy;
end;

function  TTCobroCheques.Buscar(xcodcli, xnrocheque: String): Boolean;
// Objetivo...: Recuperar Instancia
begin
  if cheques.IndexFieldNames <> 'codcli;nrocheque' then cheques.IndexFieldNames := 'codcli;nrocheque';
  Result := datosdb.Buscar(cheques, 'codcli', 'nrocheque', xcodcli, xnrocheque);
end;

procedure TTCobroCheques.Registrar(xcodcli, xnrocheque, xfecha, xfeimput, xcodbanco, xfilial, xpropio, xnrotrans: String; xmonto: Real);
// Objetivo...: Recuperar Instancia
begin
  if Buscar(xcodcli, xnrocheque) then cheques.Edit else cheques.Append;
  cheques.FieldByName('codcli').AsString    := xcodcli;
  cheques.FieldByName('nrocheque').AsString := xnrocheque;
  cheques.FieldByName('fecha').AsString     := utiles.sExprFecha2000(xfecha);
  cheques.FieldByName('feimput').AsString   := utiles.sExprFecha2000(xfeimput);
  cheques.FieldByName('codbanco').AsString  := xcodbanco;
  cheques.FieldByName('filial').AsString    := xfilial;
  cheques.FieldByName('propio').AsString    := xpropio;
  cheques.FieldByName('nrotrans').AsString  := xnrotrans;
  cheques.FieldByName('monto').AsFloat      := xmonto;
  try
    cheques.Post
   except
    cheques.Cancel
  end;
  datosdb.closeDB(cheques); cheques.Open;
end;

procedure TTCobroCheques.RegistrarTransaccion(xcodcli, xnrocheque, xnrotrans: String);
// Objetivo...: Rgistrar Transaccion de Caja
begin
  if Buscar(xcodcli, xnrocheque) then Begin
    cheques.Edit;
    cheques.FieldByName('codcli').AsString    := xcodcli;
    cheques.FieldByName('nrocheque').AsString := xnrocheque;
    cheques.FieldByName('nrotrans').AsString  := xnrotrans;
    try
      cheques.Post
     except
      cheques.Cancel
    end;
    datosdb.closeDB(cheques); cheques.Open;
  end;
end;

procedure TTCobroCheques.Borrar(xcodcli, xnrocheque: String);
// Objetivo...: Recuperar Instancia
begin
  if Buscar(xcodcli, xnrocheque) then Begin
    cheques.Delete;
    datosdb.closeDB(cheques); cheques.Open;
    datosdb.tranSQL('delete from ' + cheques_ref.TableName + ' where codcli = ' + '''' + xcodcli + '''' + ' and nrocheque = ' + '''' + xnrocheque + '''');
    datosdb.closeDB(cheques_ref); cheques_ref.Open;
  end;
end;

procedure TTCobroCheques.getDatos(xcodcli, xnrocheque: String);
// Objetivo...: Recuperar Instancia
begin
  if Buscar(xcodcli, xnrocheque) then Begin
    codcli    := cheques.FieldByName('codcli').AsString;
    nrocheque := cheques.FieldByName('nrocheque').AsString;
    fecha     := utiles.sFormatoFecha(cheques.FieldByName('fecha').AsString);
    feimput   := utiles.sFormatoFecha(cheques.FieldByName('feimput').AsString);
    codbanco  := cheques.FieldByName('codbanco').AsString;
    filial    := cheques.FieldByName('filial').AsString;
    propio    := cheques.FieldByName('propio').AsString;
    monto     := cheques.FieldByName('monto').AsFloat;
    Nrotrans  := cheques.FieldByName('nrotrans').AsString;
  end else Begin
    codcli := ''; nrocheque := ''; fecha := ''; feimput := ''; codbanco := ''; filial := ''; propio := ''; monto := 0; Nrotrans := '';
  end;
end;

function TTCobroCheques.setChequesFecha(xfecha: String): TObjectList;
// Objetivo...: Devolver un set de comprobantes
var
  l: TObjectList;
  objeto: TTCobroCheques;
Begin
  l := TObjectList.Create;
  datosdb.Filtrar(cheques, 'feimput = ' + '''' + utiles.sExprFecha2000(xfecha) + '''');
  cheques.First;
  while not cheques.Eof do Begin
    objeto            := TTCobroCheques.Create;
    objeto.Nrocheque  := cheques.FieldByName('nrocheque').AsString;
    objeto.Codcli     := cheques.FieldByName('codcli').AsString;
    objeto.Fecha      := cheques.FieldByName('fecha').AsString;
    objeto.Monto      := cheques.FieldByName('monto').AsFloat;
    l.Add(objeto);
    cheques.Next;
  end;
  datosdb.QuitarFiltro(cheques);

  Result :=  l;
end;

function TTCobroCheques.setChequesCliente(xcodcli: String): TObjectList;
// Objetivo...: Devolver un set de comprobantes
var
  l: TObjectList;
  objeto: TTCobroCheques;
Begin
  l := TObjectList.Create;
  datosdb.Filtrar(cheques, 'codcli = ' + '''' + xcodcli + '''');
  cheques.First;
  while not cheques.Eof do Begin
    objeto            := TTCobroCheques.Create;
    objeto.Nrocheque  := cheques.FieldByName('nrocheque').AsString;
    objeto.Codcli     := cheques.FieldByName('codcli').AsString;
    objeto.Fecha      := cheques.FieldByName('fecha').AsString;
    objeto.Monto      := cheques.FieldByName('monto').AsFloat;
    l.Add(objeto);
    cheques.Next;
  end;
  datosdb.QuitarFiltro(cheques);

  Result :=  l;
end;

function  TTCobroCheques.BuscarRef(xcodcli, xnrocheque, xidc, xtipo, xsucursal, xnumero: String): Boolean;
// Objetivo...: Recuperar Instancia
begin
  Result := datosdb.Buscar(cheques_ref, 'codcli', 'nrocheque', 'idc', 'tipo', 'sucursal', 'numero', xcodcli, xnrocheque, xidc, xtipo, xsucursal, xnumero);
end;

procedure TTCobroCheques.RegistrarRef(xcodcli, xnrocheque, xidc, xtipo, xsucursal, xnumero: String);
// Objetivo...: Registrar Instancia
begin
  if BuscarRef(xcodcli, xnrocheque, xidc, xtipo, xsucursal, xnumero) then cheques_ref.Edit else cheques_ref.Append;
  cheques_ref.FieldByName('codcli').AsString    := xcodcli;
  cheques_ref.FieldByName('nrocheque').AsString := xnrocheque;
  cheques_ref.FieldByName('idc').AsString       := xidc;
  cheques_ref.FieldByName('tipo').AsString      := xtipo;
  cheques_ref.FieldByName('sucursal').AsString  := xsucursal;
  cheques_ref.FieldByName('numero').AsString    := xnumero;
  try
    cheques_ref.Post
   except
    cheques_ref.Cancel
  end;
  datosdb.closeDB(cheques_ref); cheques_ref.Open;
end;

procedure TTCobroCheques.BorrarRef(xcodcli, xnrocheque, xidc, xtipo, xsucursal, xnumero: String);
// Objetivo...: Borrar Instancia
begin
  if BuscarRef(xcodcli, xnrocheque, xidc, xtipo, xsucursal, xnumero) then Begin
    cheques_ref.Delete;
    datosdb.closeDB(cheques_ref); cheques_ref.Open;
  end;
end;

function  TTCobroCheques.setComprobantes(xcodcli, xnrocheque: String): TObjectList;
// Objetivo...: Devolver un set de comprobantes
var
  l: TObjectList;
  objeto: TTCobroCheques;
Begin
  l := TObjectList.Create;
  datosdb.Filtrar(cheques_ref, 'codcli = ' + '''' + xcodcli + '''' + ' and nrocheque = ' + '''' + xnrocheque + '''');
  cheques_ref.First;
  while not cheques_ref.Eof do Begin
    objeto            := TTCobroCheques.Create;
    objeto.Idc        := cheques_ref.FieldByName('idc').AsString;
    objeto.Tipo       := cheques_ref.FieldByName('tipo').AsString;
    objeto.Sucursal   := cheques_ref.FieldByName('sucursal').AsString;
    objeto.Numero     := cheques_ref.FieldByName('numero').AsString;
    objeto.Codcli     := cheques_ref.FieldByName('codcli').AsString;
    objeto.Nrocheque  := cheques_ref.FieldByName('nrocheque').AsString;
    l.Add(objeto);
    cheques_ref.Next;
  end;
  datosdb.QuitarFiltro(cheques_ref);

  Result :=  l;
end;

procedure TTCobroCheques.Listar(xdesde, xhasta: String; salida: char);
// Objetivo...: Listar Detalle de Operaciones
var
  ldat: Boolean;
  totales: array[1..3] of Real;
Begin
  list.Setear(salida);
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Detalle de Cobro de Cheques de Terceros - Lapso: ' + xdesde + '-' + xhasta, 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Fecha', 1, 'Arial, cursiva, 8');
  List.Titulo(8, list.Lineactual, 'Cheque', 2, 'Arial, cursiva, 8');
  List.Titulo(22, list.Lineactual, 'Banco', 3, 'Arial, cursiva, 8');
  List.Titulo(60, list.Lineactual, 'Cliente', 4, 'Arial, cursiva, 8');
  List.Titulo(90, list.Lineactual, 'Monto', 5, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  if cheques.IndexFieldNames <> 'Feimput' then cheques.IndexFieldNames := 'Feimput';
  datosdb.Filtrar(cheques, 'feimput >= ' + '''' + utiles.sExprFecha2000(xdesde) + '''' + ' and feimput <= ' + '''' + utiles.sExprFecha2000(xhasta) + '''');
  cheques.First; ldat := False; totales[1] := 0;
  while not cheques.Eof do Begin
    entbcos.getDatos(cheques.FieldByName('codbanco').AsString);
    cliente.getDatos(cheques.FieldByName('codcli').AsString);
    list.Linea(0, 0, utiles.sFormatoFecha(cheques.FieldByName('fecha').AsString), 1, 'Arial, negrita, 8', salida, 'N');
    list.Linea(8, list.Lineactual, cheques.FieldByName('nrocheque').AsString, 2, 'Arial, negrita, 8', salida, 'N');
    list.Linea(22, list.Lineactual, Copy(entbcos.descrip, 1, 30), 3, 'Arial, negrita, 8', salida, 'N');
    list.Linea(60, list.Lineactual, Copy(cliente.nombre, 1, 30), 4, 'Arial, negrita, 8', salida, 'N');
    list.importe(95, list.Lineactual, '', cheques.FieldByName('monto').AsFloat, 5, 'Arial, negrita, 8');
    list.Linea(96, list.Lineactual, '', 6, 'Arial, negrita, 8', salida, 'S');
    totales[1] := totales[1] +  cheques.FieldByName('monto').AsFloat;
    ldat := True;
    datosdb.Filtrar(cheques_ref, 'codcli = ' + '''' + cheques.FieldByName('codcli').AsString + '''' + ' and nrocheque = ' + '''' + cheques.FieldByName('nrocheque').AsString + '''');
    cheques_ref.First;
    while not cheques_ref.Eof do Begin
      factform.getDatosFact(cheques_ref.FieldByName('idc').AsString, cheques_ref.FieldByName('tipo').AsString, cheques_ref.FieldByName('sucursal').AsString, cheques_ref.FieldByName('numero').AsString);
      cliente.getDatos(factform.Entidad);
      list.Linea(0, 0, '   ' + factform.Fecha, 1, 'Arial, normal, 8', salida, 'N');
      list.Linea(9, list.Lineactual, factform.Idc + ' ' + factform.Tipo + ' ' + factform.Sucursal + '-' + factform.Numero, 2, 'Arial, normal, 8', salida, 'N');
      list.Linea(25, list.Lineactual, cliente.nombre, 3, 'Arial, normal, 8', salida, 'N');
      list.importe(95, list.Lineactual, '', factform.Subtotal, 4, 'Arial, normal, 8');
      list.Linea(96, list.Lineactual, '', 5, 'Arial, negrita, 8', salida, 'S');
      cheques_ref.Next;
    end;
    datosdb.QuitarFiltro(cheques_ref);
    list.Linea(0, 0, ' ', 1, 'Arial, normal, 9', salida, 'S');
    cheques.Next;
  end;
  datosdb.QuitarFiltro(cheques);
  cheques.IndexFieldNames := 'Codcli;Nrocheque';

  if totales[1] > 0 then Begin
    list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
    list.Linea(0, 0, 'Total Cobros:', 1, 'Arial, negrita, 8', salida, 'N');
    list.importe(95, list.Lineactual, '', totales[1], 2, 'Arial, negrita, 8');
    list.Linea(96, list.Lineactual, '', 3, 'Arial, negrita, 8', salida, 'S');
  end;

  if not ldat then list.Linea(0, 0, 'No Existen Datos para Listar ...!', 1, 'Arial, normal, 11', salida, 'S');

  list.FinList;
end;

procedure TTCobroCheques.conectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones = 0 then Begin
    if not cheques.Active then cheques.Open;
    if not cheques_ref.Active then cheques_ref.Open;
  end;
  Inc(conexiones);
end;

procedure TTCobroCheques.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  Dec(conexiones);
  if conexiones = 0 then Begin
    datosdb.closeDB(cheques);
    datosdb.closeDB(cheques_ref);
  end;
end;

{===============================================================================}

function cobrocheque: TTCobroCheques;
begin
  if xcobrocheque = nil then
    xcobrocheque := TTCobroCheques.Create;
  Result := xcobrocheque;
end;

{===============================================================================}

initialization

finalization
  xcobrocheque.Free;

end.
