unit CCheques_Terceros;

interface

uses CBDT, CBancos, SysUtils, DBTables, CUtiles, CListar, CIDBFM;

type

TTChequesTerceros = class
  Id_mov, Fecha, Codigo, Codbanco, Nrocheque, Entrega, Conceptorec, Tipo_oper, Conceptoent, Fecha_ent, Domicilio, Telefono, Control: String;
  Monto: Real;
  cheques: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  function    Buscar(xid: String): Boolean;
  procedure   Recibir(xid, xfecha, xcodigo, xcodbanco, xnrocheque, xentrega, xconcepto, xdomicilio, xtelefono, xcontrol: String; xmonto: Real);
  procedure   Borrar(xid: String);
  procedure   getDatos(xid: String);

  procedure   Entregar(xid, xfecha, xrecibe, xconcepto, xdomicilio, xtelefono: String);
  procedure   AnularEntrega(xid: String);
  procedure   Cobrar(xid, xfecha, xconcepto: String);

  procedure   ListarPlanillaControl(xdfecha, xhfecha: String; salida: char);
  procedure   ListarChequesRecibidos(xdfecha, xhfecha, xtitulo: String; listbcos: Array of String; salida: char);
  procedure   ListarChequesEntregados(xdfecha, xhfecha, xtitulo: String; listbcos: Array of String; salida: char);
  procedure   ListarChequesCobrados(xdfecha, xhfecha, xtitulo: String; listbcos: Array of String; salida: char);
  procedure   ListarCheques(xdfecha, xhfecha, xtitulo: String; listbcos: Array of String; salida: char);

  function    setEntrega: String;
  function    setRecibe: String;

  function    setTotalChequesCobrar: Real;
  function    setTotalChequesEntregados: Real;
  function    setTotalChequesCobrados: Real;

  function    NuevoCodigo: String;

  function    setChequesControl(xcontrol: String): TQuery;
  procedure   BorrarControl(xcontrol: String);
  procedure   Filtrar(xcontrol: String);

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  conexiones: shortint;
  rsql: TQuery;
  totales: array[1..4] of Real;
  procedure   ListCheques(xdfecha, xhfecha, xtitulo, xtipo_oper: String; listbcos: Array of String; salida: char);
  procedure   TituloCheques(xtitulo: String; salida: char);
  procedure   ListarTotalCheques(xleyenda: String; xtotal: Real; salida: char);
end;

function chequesterceros: TTChequesTerceros;

implementation

var
  xchequesterceros: TTChequesTerceros = nil;

constructor TTChequesTerceros.Create;
begin
  cheques := datosdb.openDB('cheques_terceros', '', '');
end;

destructor TTChequesTerceros.Destroy;
begin
  inherited Destroy;
end;

function  TTChequesTerceros.Buscar(xid: String): Boolean;
// Objetivo...: Buscar una Instancia
var
  tf: Boolean;
Begin
  tf := cheques.Filtered;
  cheques.Filtered := False;
  datosdb.refrescar(cheques);
  if cheques.IndexFieldNames <> 'idmov' then cheques.IndexFieldNames := 'idmov';
  Result := cheques.FindKey([xid]);
  Id_Mov := xid;
  cheques.Filtered := tf;
end;

procedure TTChequesTerceros.Recibir(xid, xfecha, xcodigo, xcodbanco, xnrocheque, xentrega, xconcepto, xdomicilio, xtelefono, xcontrol: String; xmonto: Real);
// Objetivo...: Registrar un Cheque de terceros
var
  id: String;
Begin
  entbcos.getDatos(xcodbanco);
  if Length(Trim(xid)) > 0 then id := xid else id := Trim(utiles.sExprFecha2000(utiles.setFechaActual) + Copy(utiles.setHoraActual24, 1, 2) + Copy(utiles.setHoraActual24, 4, 2) + Copy(utiles.setHoraActual24, 7, 2));
  if Buscar(id) then cheques.Edit else cheques.Append;
  cheques.FieldByName('idmov').AsString       := id;
  cheques.FieldByName('fecha').AsString       := xfecha;
  cheques.FieldByName('codigo').AsString      := xcodigo;
  cheques.FieldByName('codbanco').AsString    := xcodbanco;
  cheques.FieldByName('codbanco').AsString    := xcodbanco;
  cheques.FieldByName('banco').AsString       := entbcos.descrip;
  cheques.FieldByName('nrocheque').AsString   := xnrocheque;
  cheques.FieldByName('entrega').AsString     := xentrega;
  cheques.FieldByName('conceptorec').AsString := xconcepto;
  cheques.FieldByName('tipo_oper').AsString   := 'R';
  cheques.FieldByName('monto').AsFloat        := xmonto;
  cheques.FieldByName('fecha1').AsString      := utiles.sExprFecha2000(xfecha);
  cheques.FieldByName('domicilio').AsString   := xdomicilio;
  cheques.FieldByName('telefono').AsString    := xtelefono;
  cheques.FieldByName('control').AsString     := xcontrol;
  try
    cheques.Post
   except
    cheques.Cancel
  end;
  datosdb.refrescar(cheques);
end;

procedure TTChequesTerceros.Borrar(xid: String);
// Objetivo...: Borrar una instancia
Begin
  if Buscar(xid) then Begin
    cheques.Delete;
    datosdb.refrescar(cheques);
  end;
end;

procedure TTChequesTerceros.getDatos(xid: String);
// Objetivo...: Cargar una instancia
Begin
  if Buscar(xid) then Begin
    fecha       := cheques.FieldByName('fecha').AsString;
    codigo      := cheques.FieldByName('codigo').AsString;
    codbanco    := cheques.FieldByName('codbanco').AsString;
    nrocheque   := cheques.FieldByName('nrocheque').AsString;
    entrega     := cheques.FieldByName('entrega').AsString;
    conceptorec := cheques.FieldByName('conceptorec').AsString;
    conceptoent := cheques.FieldByName('conceptoent').AsString;
    Tipo_oper   := cheques.FieldByName('tipo_oper').AsString;
    monto       := cheques.FieldByName('monto').AsFloat;
    fecha_ent   := cheques.FieldByName('fecha_ent').AsString;
    Domicilio   := cheques.FieldByName('domicilio').AsString;
    telefono    := cheques.FieldByName('telefono').AsString;
    control     := cheques.FieldByName('control').AsString;
  end else Begin
    fecha := ''; codigo := ''; codbanco := ''; nrocheque := ''; entrega := ''; conceptoent := ''; conceptorec := ''; monto := 0; tipo_oper := ''; fecha_ent := ''; Domicilio := ''; Telefono := ''; control := '';
  end;
end;

procedure TTChequesTerceros.Entregar(xid, xfecha, xrecibe, xconcepto, xdomicilio, xtelefono: String);
// Objetivo...: Entregar Cheque
Begin
  if Buscar(xid) then Begin
    cheques.Edit;
    cheques.FieldByName('fecha_ent').AsString   := xfecha;
    cheques.FieldByName('conceptorec').AsString := xconcepto;
    cheques.FieldByName('recibe').AsString      := xrecibe;
    cheques.FieldByName('tipo_oper').AsString   := 'E';
    cheques.FieldByName('fecha1').AsString      := utiles.sExprFecha2000(xfecha);
    cheques.FieldByName('domicilio').AsString   := xdomicilio;
    cheques.FieldByName('telefono').AsString    := xtelefono;
    try
      cheques.Post
     except
      cheques.Cancel
    end;
  end;
end;

procedure TTChequesTerceros.AnularEntrega(xid: String);
// Objetivo...: Anular Entraga de Cheque
Begin
  if Buscar(xid) then Begin
    cheques.Edit;
    cheques.FieldByName('fecha_ent').AsString   := '';
    cheques.FieldByName('conceptorec').AsString := '';
    cheques.FieldByName('recibe').AsString      := '';
    cheques.FieldByName('tipo_oper').AsString   := 'R';
    try
      cheques.Post
     except
      cheques.Cancel
    end;
  end;
end;

procedure TTChequesTerceros.Cobrar(xid, xfecha, xconcepto: String);
// Objetivo...: Borrar Entrega
Begin
  if Buscar(xid) then Begin
    cheques.Edit;
    cheques.FieldByName('fecha_ent').AsString   := xfecha;
    cheques.FieldByName('conceptorec').AsString := xconcepto;
    cheques.FieldByName('tipo_oper').AsString   := 'C';
    cheques.FieldByName('fecha1').AsString      := utiles.sExprFecha2000(xfecha);
    try
      cheques.Post
     except
      cheques.Cancel
    end;
  end;
end;

{ ============================================================================= }

procedure TTChequesTerceros.ListarPlanillaControl(xdfecha, xhfecha: String; salida: char);
// Objetivo...: Listar Planilla para Control de Cheques
Begin
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, 'Planilla de Control de Cheques - Período: ' + xdfecha + ' - ' + xhfecha, 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Código', 1, 'Arial, cursiva, 8');
  List.Titulo(8, list.Lineactual, 'Entidad Bancaria', 2, 'Arial, cursiva, 8');
  List.Titulo(38, list.Lineactual, 'Nro. Cheque   Fecha', 3, 'Arial, cursiva, 8');
  List.Titulo(58, list.Lineactual, 'Monto', 4, 'Arial, normal, 8');
  List.Titulo(63, list.Lineactual, 'Concepto Operación', 5, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  rsql := datosdb.tranSQL('select * from ' + cheques.TableName + ' where fecha1 >= ' + '"' + utiles.sExprFecha2000(xdfecha) + '"' + ' and fecha1 <= ' + '"' + utiles.sExprFecha2000(xhfecha) + '"' + ' and tipo_oper = ' + '"' + 'R' + '"' + ' order by fecha, codigo');
  rsql.Open;
  while not rsql.Eof do Begin
    entbcos.getDatos(rsql.FieldByName('codbanco').AsString);
    list.Linea(0, 0, rsql.FieldByName('codigo').AsString, 1, 'Arial, normal, 8', salida, 'N');
    list.Linea(8, list.Lineactual, entbcos.descrip, 2, 'Arial, normal, 8', salida, 'N');
    list.Linea(38, list.Lineactual, rsql.FieldByName('nrocheque').AsString + '     ' + rsql.FieldByName('fecha').AsString, 3, 'Arial, normal, 8', salida, 'N');
    list.importe(62, list.Lineactual, '', rsql.FieldByName('monto').AsFloat, 4, 'Arial, normal, 8');
    list.Linea(63, list.Lineactual, '..................................................................................................', 5, 'Arial, normal, 8', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'S');
    rsql.Next;
  end;
  rsql.Close; rsql.Free;

  list.FinList;
end;

procedure TTChequesTerceros.ListarChequesRecibidos(xdfecha, xhfecha, xtitulo: String; listbcos: Array of String; salida: char);
// Objetivo...: Listar cheques recibidos
Begin
  TituloCheques(xtitulo, salida);
  ListCheques(xdfecha, xhfecha, xtitulo, 'R', listbcos, salida);
  list.FinList;
end;

procedure TTChequesTerceros.ListarChequesEntregados(xdfecha, xhfecha, xtitulo: String; listbcos: Array of String; salida: char);
// Objetivo...: Listar cheques entregados
Begin
  TituloCheques(xtitulo, salida);
  ListCheques(xdfecha, xhfecha, xtitulo, 'E', listbcos, salida);
  list.FinList;
end;

procedure TTChequesTerceros.ListarChequesCobrados(xdfecha, xhfecha, xtitulo: String; listbcos: Array of String; salida: char);
// Objetivo...: Listar cheques cobrados
Begin
  TituloCheques(xtitulo, salida);
  ListCheques(xdfecha, xhfecha, xtitulo, 'C', listbcos, salida);
  list.FinList;
end;

procedure TTChequesTerceros.ListarCheques(xdfecha, xhfecha, xtitulo: String; listbcos: Array of String; salida: char);
// Objetivo...: Listar todas las operaciones con cheques
Begin
  TituloCheques(xtitulo, salida);
  totales[2] := 0; totales[3] := 0; totales[4] := 0;
  ListCheques(xdfecha, xhfecha, xtitulo, 'R', listbcos, salida); totales[2] := totales[1];
  ListCheques(xdfecha, xhfecha, xtitulo, 'E', listbcos, salida); totales[3] := totales[1];
  ListCheques(xdfecha, xhfecha, xtitulo, 'C', listbcos, salida); totales[4] := totales[1];

  list.Linea(0, 0, '', 1, 'Arial, negrita, 8', salida, 'S');
  list.Linea(0, 0, 'Monto Disponible en Cheques:', 1, 'Arial, negrita, 9', salida, 'N');
  list.importe(57, list.Lineactual, '', totales[2], 2, 'Arial, negrita, 9');
  list.Linea(58, list.Lineactual, '', 3, 'Arial, negrita, 9', salida, 'S');

  list.FinList;
end;

{ ----------------------------------------------------------------------------- }

procedure TTChequesTerceros.ListCheques(xdfecha, xhfecha, xtitulo, xtipo_oper: String; listbcos: Array of String; salida: char);
// Objetivo...: Listar Cheques Recibidos
Begin
  rsql := datosdb.tranSQL('select * from ' + cheques.TableName + ' where fecha1 >= ' + '"' + utiles.sExprFecha2000(xdfecha) + '"' + ' and fecha1 <= ' + '"' + utiles.sExprFecha2000(xhfecha) + '"' + ' and tipo_oper = ' + '"' + xtipo_oper + '"' + ' order by fecha, codbanco, idmov');
  rsql.Open; totales[1] := 0;
  while not rsql.Eof do Begin
    if utiles.verificarItemsEnLista(listbcos, rsql.FieldByName('codbanco').AsString) then Begin
      entbcos.getDatos(rsql.FieldByName('codbanco').AsString);
      list.Linea(0, 0, rsql.FieldByName('fecha').AsString, 1, 'Arial, normal, 8', salida, 'N');
      if (xtipo_oper = 'E') or (xtipo_oper = 'C') then list.Linea(8, list.Lineactual, rsql.FieldByName('recibe').AsString, 2, 'Arial, normal, 8', salida, 'N');
      if xtipo_oper = 'R' then list.Linea(8, list.Lineactual, rsql.FieldByName('entrega').AsString, 2, 'Arial, normal, 8', salida, 'N');
      list.Linea(38, list.Lineactual, rsql.FieldByName('nrocheque').AsString, 3, 'Arial, normal, 8', salida, 'N');
      list.importe(57, list.Lineactual, '', rsql.FieldByName('monto').AsFloat, 4, 'Arial, normal, 8');
      list.Linea(58, list.Lineactual, rsql.FieldByName('conceptorec').AsString, 5, 'Arial, normal, 8', salida, 'N');
      list.Linea(82, list.Lineactual, entbcos.descrip, 6, 'Arial, normal, 8', salida, 'S');
      totales[1] := totales[1] + rsql.FieldByName('monto').AsFloat;
    end;
    rsql.Next;
  end;
  rsql.Close; rsql.Free;
  ListarTotalCheques('Total Operación:', totales[1], salida);
end;

{-------------------------------------------------------------------------------}
procedure TTChequesTerceros.TituloCheques(xtitulo: String; salida: char);
// Objetivo.... Listar cheques
Begin
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, xtitulo, 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Fecha', 1, 'Arial, normal, 8');
  List.Titulo(8, list.Lineactual, 'Entrego/Recibio', 2, 'Arial, normal, 8');
  List.Titulo(38, list.Lineactual, 'Nro. Cheque', 3, 'Arial, normal, 8');
  List.Titulo(52, list.Lineactual, 'Monto', 4, 'Arial, normal, 8');
  List.Titulo(58, list.Lineactual, 'Concepto Operación', 5, 'Arial, normal, 8');
  List.Titulo(82, list.Lineactual, 'Entidad Bancaria', 6, 'Arial, normal, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');
end;

procedure TTChequesTerceros.ListarTotalCheques(xleyenda: String; xtotal: Real; salida: char);
// Objetivo.... Listar cheques
Begin
  if xtotal <> 0 then Begin
    list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S');
    list.Linea(0, 0, xleyenda, 1, 'Arial, negrita, 8', salida, 'N');
    list.importe(57, list.Lineactual, '', xtotal, 2, 'Arial, negrita, 8');
    list.Linea(58, list.Lineactual, '', 3, 'Arial, negrita, 8', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S');
  end;
end;

{ ============================================================================= }

function TTChequesTerceros.setEntrega: String;
Begin
  Result := cheques.FieldByName('entrega').AsString;
end;

function TTChequesTerceros.setRecibe: String;
Begin
  Result := cheques.FieldByName('recibe').AsString;
end;

function TTChequesTerceros.setTotalChequesCobrar: Real;
Begin
  rsql := datosdb.tranSQL('select sum (monto) from cheques_terceros where tipo_oper = ' + '"' + 'R' + '"');
  rsql.Open;
  Result := rsql.Fields[0].AsFloat;
  rsql.Close; rsql.Free;
end;

function TTChequesTerceros.setTotalChequesEntregados: Real;
Begin
  rsql := datosdb.tranSQL('select sum (monto) from cheques_terceros where tipo_oper = ' + '"' + 'E' + '"');
  rsql.Open;
  Result := rsql.Fields[0].AsFloat;
  rsql.Close; rsql.Free;
end;

function TTChequesTerceros.setTotalChequesCobrados: Real;
Begin
  rsql := datosdb.tranSQL('select sum (monto) from cheques_terceros where tipo_oper = ' + '"' + 'C' + '"');
  rsql.Open;
  Result := rsql.Fields[0].AsFloat;
  rsql.Close; rsql.Free;
end;

function  TTChequesTerceros.NuevoCodigo: String;
// Objetivo...: Generar Nuevo Código de Cheque
var
  letra, nro: String;
  tf: Boolean;
Begin
  tf := cheques.Filtered;
  cheques.Filtered := False;
  cheques.IndexFieldNames := 'Fecha;Nrocheque';
  cheques.Last;
  if Length(Trim(cheques.FieldByName('codigo').AsString)) = 0 then Result := 'AA-01' else Begin
    letra := Copy(cheques.FieldByName('codigo').AsString, 1, 2);
    nro   := Copy(cheques.FieldByName('codigo').AsString, 4, 2);
    nro   := IntToStr(StrToInt(nro) + 1);
    if Length(Trim(nro)) <= 2 then Result := letra + '-' + utiles.sLlenarIzquierda(nro, 2, '0') else Begin
      nro := '01';
      if letra = 'AA' then letra := 'BB' else
        if letra = 'BB' then letra := 'CC' else
          if letra = 'CC' then letra := 'DD' else
            if letra = 'DD' then letra := 'EE' else
              if letra = 'EE' then letra := 'FF' else
                if letra = 'GG' then letra := 'HH' else
                  if letra = 'HH' then letra := 'II' else
                    if letra = 'II' then letra := 'JJ' else
                      if letra = 'JJ' then letra := 'KK' else
                        if letra = 'LL' then letra := 'MM' else
                          if letra = 'MM' then letra := 'NN' else
                            if letra = 'NN' then letra := 'OO' else
                              if letra = 'OO' then letra := 'PP' else
                                if letra = 'PP' then letra := 'QQ' else
                                  if letra = 'QQ' then letra := 'RR' else
                                    if letra = 'RR' then letra := 'SS' else
                                      if letra = 'SS' then letra := 'TT' else
                                        if letra = 'TT' then letra := 'UU' else
                                          if letra = 'UU' then letra := 'VV' else
                                            if letra = 'VV' then letra := 'WW' else
                                              if letra = 'WW' then letra := 'XX' else
                                                if letra = 'XX' then letra := 'YY' else
                                                  if letra = 'YY' then letra := 'ZZ' else
                                                    if letra = 'ZZ' then letra := 'AA';

      Result := letra + '-' + nro;
    end;
  end;
  cheques.Filtered := tf;
  cheques.IndexFieldNames := 'idmov';
end;

function TTChequesTerceros.setChequesControl(xcontrol: String): TQuery;
// Objetivo...: devolver cheques asociados a un modulo determinado
Begin
  Result := datosdb.tranSQL('select codigo, monto from cheques_terceros where control = ' + '"' + xcontrol + '"');
end;

procedure TTChequesTerceros.BorrarControl(xcontrol: String);
// Objetivo...: Borrar Cheques asociados a un modulo determinado
var
  ft: Boolean;
Begin
  ft     := cheques.Filtered;
  cheques.Filtered := False;
  datosdb.tranSQL('delete from cheques_terceros where control = ' + '"' + xcontrol + '"');
  cheques.Filtered := ft;
end;

procedure TTChequesTerceros.Filtrar(xcontrol: String);
// Objetivo...: Filtrar datos
Begin
  datosdb.Filtrar(cheques, 'control = ' + '''' + xcontrol + '''')
end;

procedure TTChequesTerceros.conectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones = 0 then Begin
    if not cheques.Active then cheques.Open;
    cheques.FieldByName('idmov').Visible := False; cheques.FieldByName('fecha1').Visible := False; cheques.FieldByName('tipo_oper').Visible := False;
    cheques.FieldByName('fecha').DisplayLabel := 'Recibido'; cheques.FieldByName('codigo').DisplayLabel := 'Código'; cheques.FieldByName('codbanco').Visible := False; cheques.FieldByName('banco').DisplayLabel := 'Banco';
    cheques.FieldByName('nrocheque').DisplayLabel := 'Nº Cheque'; cheques.FieldByName('monto').DisplayLabel := 'Monto'; cheques.FieldByName('entrega').DisplayLabel := 'Entrega'; cheques.FieldByName('recibe').DisplayLabel := 'Recibe';
    cheques.FieldByName('conceptorec').DisplayLabel := 'Concepto Recibido'; cheques.FieldByName('conceptoent').DisplayLabel := 'Concepto Entregado'; cheques.FieldByName('entrega').DisplayLabel := 'Entregado'; cheques.FieldByName('fecha_ent').DisplayLabel := 'Ent/Cobrado';
    cheques.FieldByName('domicilio').DisplayLabel := 'Domicilio'; cheques.FieldByName('telefono').DisplayLabel := 'Teléfono';
    cheques.FieldByName('codigo').Index := 0; cheques.FieldByName('banco').Index := 1; cheques.FieldByName('nrocheque').Index := 2; cheques.FieldByName('monto').Index := 3; cheques.FieldByName('fecha').Index := 4; cheques.FieldByName('entrega').Index := 5; cheques.FieldByName('domicilio').Index := 6; cheques.FieldByName('telefono').Index := 7;
  end;
  Inc(conexiones);
  entbcos.conectar;
end;

procedure TTChequesTerceros.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  Dec(conexiones);
  if conexiones = 0 then Begin
    datosdb.closeDB(cheques);
  end;
  entbcos.desconectar;
end;

{===============================================================================}

function chequesterceros: TTChequesTerceros;
begin
  if xchequesterceros = nil then
    xchequesterceros := TTChequesTerceros.Create;
  Result := xchequesterceros;
end;

{===============================================================================}

initialization

finalization
  xchequesterceros.Free;

end.
