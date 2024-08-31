unit CCExpedientesBianchini;

interface

uses CBDT, SysUtils, DBTables, CUtiles, CListar, CIDBFM, Classes;

type

TTExpedientesBianchini = class
  NroExpediente, Folio, Anio, Nominacion, Actor, Demandado, Concepto, Fechainicio: String;
  Existe: Boolean;
  exptes, seguimiento, gastos: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  function    Buscar(xnroexpediente: String): Boolean;
  procedure   Registrar(xnroexpediente, xfolio, xanio, xnominacion, xactor, xdemandado, xconcepto, xfechainicio: String);
  procedure   getDatos(xnroexpediente: String);
  procedure   Borrar(xnroexpediente: String);
  function    setExpedientes: TStringList;
  function    Nuevo: String;

  procedure   BuscarPorExpediente(xexpresion: String);
  procedure   BuscarPorActor(xexpresion: String);
  procedure   BuscarPorDemandado(xexpresion: String);

  function    BuscarSeguimiento(xnroexpediente, xitems: String): Boolean;
  procedure   RegistrarSeguimiento(xnroexpediente, xitems, xfecha, xconcepto, xobservacion: String; xcantitems: Integer);
  procedure   BorrarSeguimiento(xnroexpediente: String);
  function    setItemsSeguimiento(xnroexpediente: String): TStringList;

  function    BuscarGasto(xnroexpediente, xitems: String): Boolean;
  procedure   RegistrarGasto(xnroexpediente, xitems, xfecha, xconcepto, xobservacion: String; xmonto: Real; xcantitems: Integer);
  procedure   BorrarGasto(xnroexpediente: String);
  function    setItemsGastos(xnroexpediente: String): TStringList;

  procedure   ListarExpediente(xlista: TStringList; xseg, xgastos: Boolean; salida: char);

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  conexiones: shortint;
end;

function expediente: TTExpedientesBianchini;

implementation

var
  xexpediente: TTExpedientesBianchini = nil;

constructor TTExpedientesBianchini.Create;
begin
  exptes      := datosdb.openDB('expedientes', '');
  seguimiento := datosdb.openDB('seguimiento_exptes', '');
  gastos      := datosdb.openDB('gastos_exptes', '');
end;

destructor TTExpedientesBianchini.Destroy;
begin
  inherited Destroy;
end;

function  TTExpedientesBianchini.Buscar(xnroexpediente: String): Boolean;
// Objetivo...: Buscar expediente
Begin
  if exptes.IndexFieldNames <> 'Nroexpediente' then exptes.IndexFieldNames := 'Nroexpediente';
  Existe := exptes.FindKey([xnroexpediente]);
  Result := Existe;
end;

procedure TTExpedientesBianchini.Registrar(xnroexpediente, xfolio, xanio, xnominacion, xactor, xdemandado, xconcepto, xfechainicio: String);
// Objetivo...: Buscar expediente
Begin
  if Buscar(xnroexpediente) then exptes.Edit else exptes.Append;
  exptes.FieldByName('nroexpediente').AsString := xnroexpediente;
  exptes.FieldByName('folio').AsString         := xfolio;
  exptes.FieldByName('anio').AsString          := xanio;
  exptes.FieldByName('nominacion').AsString    := xnominacion;
  exptes.FieldByName('actor').AsString         := xactor;
  exptes.FieldByName('demandado').AsString     := xdemandado;
  exptes.FieldByName('concepto').AsString      := xconcepto;
  exptes.FieldByName('fechainicio').AsString   := utiles.sExprFecha2000(xfechainicio);
  try
    exptes.Post
   except
    exptes.Cancel
  end;
  datosdb.closedb(exptes); exptes.Open;
end;

procedure TTExpedientesBianchini.getDatos(xnroexpediente: String);
// Objetivo...: Buscar expediente
Begin
  if Buscar(xnroexpediente) then Begin
    nroexpediente := exptes.FieldByName('nroexpediente').AsString;
    folio         := exptes.FieldByName('folio').AsString;
    anio          := exptes.FieldByName('anio').AsString;
    nominacion    := exptes.FieldByName('nominacion').AsString;
    actor         := exptes.FieldByName('actor').AsString;
    demandado     := exptes.FieldByName('demandado').AsString;
    concepto      := exptes.FieldByName('concepto').AsString;
    fechainicio   := utiles.sFormatoFecha(exptes.FieldByName('fechainicio').AsString);
  end else Begin
    nroexpediente := ''; folio := ''; nominacion := ''; actor := ''; demandado := ''; concepto := ''; fechainicio := ''; anio := '';
  end;
end;

procedure TTExpedientesBianchini.Borrar(xnroexpediente: String);
// Objetivo...: Buscar expediente
Begin
  if Buscar(xnroexpediente) then Begin
    exptes.Delete;
    datosdb.closedb(exptes); exptes.Open;
    BorrarSeguimiento(xnroexpediente);
    BorrarGasto(xnroexpediente);
  end;
end;

function TTExpedientesBianchini.setExpedientes: TStringList;
// Objetivo...: devolver un set con los expedientes
var
  l: TStringList;
Begin
  l := TStringList.Create;
  if exptes.IndexFieldNames <> 'Actor' then exptes.IndexFieldNames := 'Actor';
  exptes.First;
  while not exptes.Eof do Begin
    l.Add(exptes.FieldByName('nroexpediente').AsString + exptes.FieldByName('actor').AsString);
    exptes.Next;
  end;
  Result := l;
end;

function TTExpedientesBianchini.Nuevo: String;
// Objetivo...: Generar Nuevo Nro. de Expediente
Begin
  if exptes.RecordCount = 0 then Result := '1' else Begin
    exptes.IndexFieldNames := 'Nroexpediente';
    exptes.Last;
    Result := IntToStr(exptes.FieldByName('nroexpediente').AsInteger + 1);
  end;
end;

procedure  TTExpedientesBianchini.BuscarPorExpediente(xexpresion: String);
// Objetivo...: Buscar expediente
Begin
  if exptes.IndexFieldNames <> 'Nroexpediente' then exptes.IndexFieldNames := 'Nroexpediente';
  exptes.FindNearest([xexpresion]);
end;

procedure  TTExpedientesBianchini.BuscarPorActor(xexpresion: String);
// Objetivo...: Buscar expediente
Begin
  if exptes.IndexFieldNames <> 'Actor' then exptes.IndexFieldNames := 'Actor';
  exptes.FindNearest([xexpresion]);
end;

procedure  TTExpedientesBianchini.BuscarPorDemandado(xexpresion: String);
// Objetivo...: Buscar expediente
Begin
  if exptes.IndexFieldNames <> 'Demandado' then exptes.IndexFieldNames := 'Demandado';
  exptes.FindNearest([xexpresion]);
end;

function  TTExpedientesBianchini.BuscarSeguimiento(xnroexpediente, xitems: String): Boolean;
// Objetivo...: Buscar expediente
Begin
  Result := datosdb.Buscar(seguimiento, 'nroexpediente', 'items', xnroexpediente, xitems);
end;

procedure TTExpedientesBianchini.RegistrarSeguimiento(xnroexpediente, xitems, xfecha, xconcepto, xobservacion: String; xcantitems: Integer);
// Objetivo...: Buscar expediente
Begin
  if BuscarSeguimiento(xnroexpediente, xitems) then seguimiento.Edit else seguimiento.Append;
  seguimiento.FieldByName('nroexpediente').AsString := xnroexpediente;
  seguimiento.FieldByName('items').AsString         := xitems;
  seguimiento.FieldByName('fecha').AsString         := utiles.sExprFecha2000(xfecha);
  seguimiento.FieldByName('concepto').AsString      := xconcepto;
  seguimiento.FieldByName('observacion').AsString   := xobservacion;
  try
    seguimiento.Post
   except
    seguimiento.Cancel
  end;
  if utiles.sLlenarIzquierda(IntToStr(xcantitems), 3, '0') = xitems then Begin
    datosdb.tranSQL('delete from seguimiento_exptes where nroexpediente = ' + '''' + xnroexpediente + '''' + ' and items > ' + '''' + xitems + '''');
    datosdb.closedb(seguimiento); seguimiento.Open;
  end;
end;

procedure TTExpedientesBianchini.BorrarSeguimiento(xnroexpediente: String);
// Objetivo...: Borrar Expediente
Begin
  datosdb.tranSQL('delete from seguimiento_exptes where nroexpediente = ' + '''' + xnroexpediente + '''');
  datosdb.closedb(seguimiento); seguimiento.Open;
end;

function  TTExpedientesBianchini.setItemsSeguimiento(xnroexpediente: String): TStringList;
// Objetivo...: Buscar expediente
var
  l: TStringList;
Begin
  l := TStringList.Create;
  if BuscarSeguimiento(xnroexpediente, '001') then Begin
    while not seguimiento.Eof do Begin
      if seguimiento.FieldByName('nroexpediente').AsString <> xnroexpediente then Break;
      l.Add(seguimiento.FieldByName('items').AsString + utiles.sFormatoFecha(seguimiento.FieldByName('fecha').AsString) + seguimiento.FieldByName('concepto').AsString + ';1' + seguimiento.FieldByName('observacion').AsString);
      seguimiento.Next;
    end;
  end;
  Result := l;
end;

function  TTExpedientesBianchini.BuscarGasto(xnroexpediente, xitems: String): Boolean;
// Objetivo...: Buscar Gasto
Begin
  Result := datosdb.Buscar(gastos, 'nroexpediente', 'items', xnroexpediente, xitems);
end;

procedure TTExpedientesBianchini.RegistrarGasto(xnroexpediente, xitems, xfecha, xconcepto, xobservacion: String; xmonto: Real; xcantitems: Integer);
// Objetivo...: Buscar expediente
Begin
  if BuscarGasto(xnroexpediente, xitems) then gastos.Edit else gastos.Append;
  gastos.FieldByName('nroexpediente').AsString := xnroexpediente;
  gastos.FieldByName('items').AsString         := xitems;
  gastos.FieldByName('fecha').AsString         := utiles.sExprFecha2000(xfecha);
  gastos.FieldByName('concepto').AsString      := xconcepto;
  gastos.FieldByName('monto').AsFloat          := xmonto;
  gastos.FieldByName('observacion').AsString   := xobservacion;
  try
    gastos.Post
   except
    gastos.Cancel
  end;
  if utiles.sLlenarIzquierda(IntToStr(xcantitems), 4, '0') = xitems then Begin
    datosdb.tranSQL('delete from gastos_exptes where nroexpediente = ' + '''' + xnroexpediente + '''' + ' and items > ' + '''' + xitems + '''');
    datosdb.closedb(gastos); gastos.Open;
  end;
end;

procedure TTExpedientesBianchini.BorrarGasto(xnroexpediente: String);
// Objetivo...: Borrar Gastos Expediente
Begin
  datosdb.tranSQL('delete from gastos_exptes where nroexpediente = ' + '''' + xnroexpediente + '''');
  datosdb.closedb(gastos); gastos.Open;
end;

function  TTExpedientesBianchini.setItemsGastos(xnroexpediente: String): TStringList;
// Objetivo...: Buscar gastos
var
  l: TStringList;
Begin
  l := TStringList.Create;
  if BuscarGasto(xnroexpediente, '001') then Begin
    while not gastos.Eof do Begin
      if gastos.FieldByName('nroexpediente').AsString <> xnroexpediente then Break;
      l.Add(gastos.FieldByName('items').AsString + utiles.sFormatoFecha(gastos.FieldByName('fecha').AsString) + gastos.FieldByName('concepto').AsString + ';1' + gastos.FieldByName('observacion').AsString + ';2' + gastos.FieldByName('monto').AsString);
      gastos.Next;
    end;
  end;
  Result := l;
end;

procedure TTExpedientesBianchini.ListarExpediente(xlista: TStringList; xseg, xgastos: Boolean; salida: char);
// Objetivo...: Listar Expediente
var
  i: Integer;
Begin
  list.Titulo(0, 0, '', 1, 'Arial, normal, 14');
  list.Titulo(0, 0, 'Listado de Expedientes', 1, 'Arial, negrita, 14');
  list.Titulo(0, 0, '', 1, 'Arial, normal, 5');
  list.Titulo(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11');
  list.Titulo(0, 0, '', 1, 'Arial, normal, 5');

  for i := 1 to xlista.Count do Begin
    if i > 1 then list.ListTitulos;
    getDatos(xlista.Strings[i-1]);
    list.Linea(0, 0, 'Nro.Expediente:  ' + nroexpediente, 1, 'Arial, negrita, 9', salida, 'N');
    list.Linea(30, list.Lineactual, 'Folio:  ' + folio, 2, 'Arial, negrita, 9', salida, 'N');
    list.Linea(50, list.Lineactual, 'Año:  ' + anio, 3, 'Arial, negrita, 9', salida, 'N');
    list.Linea(50, list.Lineactual, 'Nominación:  ' + nominacion, 4, 'Arial, negrita, 9', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, negrita, 9', salida, 'S');
    list.Linea(0, 0, 'Actor:  ' + actor, 1, 'Arial, negrita, 9', salida, 'S');
    list.Linea(0, 0, 'Demandado:  ' + demandado, 1, 'Arial, negrita, 9', salida, 'S');
    list.Linea(0, 0, 'Concepto:  ' + concepto, 1, 'Arial, negrita, 9', salida, 'S');
    list.Linea(0, 0, 'Fecha de Inicio:  ' + fechainicio, 1, 'Arial, negrita, 9', salida, 'S');

    if xseg then Begin
      list.Linea(0, 0, '', 1, 'Arial, negrita, 10', salida, 'S');
      list.Linea(0, 0, 'Seguimiento ', 1, 'Arial, negrita, 9', salida, 'S');
      if BuscarSeguimiento(nroexpediente, '001') then Begin
        while not seguimiento.Eof do Begin
          if seguimiento.FieldByName('nroexpediente').AsString <> nroexpediente then Break;
          list.Linea(0, 0, '    ' + seguimiento.FieldByName('items').AsString + '   ' + seguimiento.FieldByName('concepto').AsString, 1, 'Arial, normal, 8', salida, 'N');
          list.Linea(50, list.Lineactual, seguimiento.FieldByName('observacion').AsString, 2, 'Arial, normal, 8', salida, 'S');
          seguimiento.Next;
        end;
      end;
    end;

    if xgastos then Begin
      list.Linea(0, 0, '', 1, 'Arial, negrita, 10', salida, 'S');
      list.Linea(0, 0, 'Gastos', 1, 'Arial, negrita, 9', salida, 'S');
      if BuscarGasto(nroexpediente, '001') then Begin
        while not gastos.Eof do Begin
          if gastos.FieldByName('nroexpediente').AsString <> nroexpediente then Break;
          list.Linea(0, 0, '    ' + gastos.FieldByName('items').AsString + '   ' + gastos.FieldByName('concepto').AsString, 1, 'Arial, normal, 8', salida, 'N');
          list.importe(55, list.Lineactual, '', gastos.FieldByName('monto').AsFloat, 3, 'Arial, normal, 8');
          list.Linea(60, list.Lineactual, gastos.FieldByName('observacion').AsString, 4, 'Arial, normal, 8', salida, 'S');
          gastos.Next;
        end;
      end;
    end;
    list.CompletarPaginaConNumeracion;
  end;
  list.FinList;
end;

procedure TTExpedientesBianchini.conectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones = 0 then Begin
    if not exptes.Active then exptes.Open;
    if not seguimiento.Active then seguimiento.Open;
    if not gastos.Active then gastos.Open;
  end;
  Inc(conexiones);
end;

procedure TTExpedientesBianchini.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  Dec(conexiones);
  if conexiones = 0 then Begin
    datosdb.closeDB(exptes);
    datosdb.closeDB(seguimiento);
    datosdb.closeDB(gastos);
  end;
end;

{===============================================================================}

function expediente: TTExpedientesBianchini;
begin
  if xexpediente = nil then
    xexpediente := TTExpedientesBianchini.Create;
  Result := xexpediente;
end;

{===============================================================================}

initialization

finalization
  xexpediente.Free;

end.
