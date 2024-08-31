unit CDistribucionComprasCCE;

interface

uses CBDT, SysUtils, DBTables, CUtiles, CListar, CIDBFM, Classes,
     CFacturasCCE_Cuotas, CFacturasCCE_Forms, CBancos, CCajaCCExterior,
     CTransferenciasBancariasCCE;

type

TTDistribucion = class
  Idc, Tipo, Sucursal, Numero, Nrocheque, Fecha, Tipomov, FechaCheque, Codbanco, Filial, Propio, Codmov, Referencia: String;
  Efectivo, Transferencia, Cheques, Retencion1, Retencion2: Real;
  distribucion, cheque: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  function    BuscarDist(xidc, xtipo, xsucursal, xnumero, xentidad: String): Boolean;
  procedure   RegistrarDist(xidc, xtipo, xsucursal, xnumero, xentidad, xfecha, xtipomov, xreferencia, xcodmov: String; xefectivo, xtransferencia, xcheques: Real);
  procedure   getDatosDist(xidc, xtipo, xsucursal, xnumero, xentidad: String); overload;
  procedure   BorrarDist(xidc, xtipo, xsucursal, xnumero, xentidad: String); overload;
  procedure   BorrarDist(xreferencia: String); overload;

  function    BuscarCheque(xidc, xtipo, xsucursal, xnumero, xentidad, xitems: String): Boolean;
  procedure   RegistrarCheque(xidc, xtipo, xsucursal, xnumero, xentidad, xitems, xnrocheque, xfechacheque, xcodbanco, xfilial, xpropio, xreferencia: String; xmonto: Real; xcantitems: Integer);
  function    setDatosCheque(xidc, xtipo, xsucursal, xnumero, xentidad: String): TStringList;

  function    setDatosChequeContado(xidc, xtipo, xsucursal, xnumero, xentidad: String): TStringList;
  procedure   BorrarCheque(xidc, xtipo, xsucursal, xnumero, xentidad: String); overload;
  procedure   BorrarCheque(xreferencia: String); overload;

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  conexiones: shortint;
  items, tmov: String;
  transfiere: Boolean;
  it: Integer;
end;

function distribucioncom: TTDistribucion;

implementation

var
  xdistribucion: TTDistribucion = nil;

constructor TTDistribucion.Create;
begin
  distribucion := datosdb.openDB('distribucioncompras', '');
  cheque       := datosdb.openDB('chequescom', '');
end;

destructor TTDistribucion.Destroy;
begin
  inherited Destroy;
end;

function TTDistribucion.BuscarDist(xidc, xtipo, xsucursal, xnumero, xentidad: String): Boolean;
// Objetivo...: Buscar una Instancia
begin
  Result := datosdb.Buscar(distribucion, 'idc', 'tipo', 'sucursal', 'numero', 'entidad', xidc, xtipo, xsucursal, xnumero, xentidad);
end;

procedure TTDistribucion.RegistrarDist(xidc, xtipo, xsucursal, xnumero, xentidad, xfecha, xtipomov, xreferencia, xcodmov: String; xefectivo, xtransferencia, xcheques: Real);
// Objetivo...: Registrar una Instancia
begin
  if BuscarDist(xidc, xtipo, xsucursal, xnumero, xentidad) then distribucion.Edit else distribucion.Append;
  distribucion.FieldByName('idc').AsString          := xidc;
  distribucion.FieldByName('tipo').AsString         := xtipo;
  distribucion.FieldByName('sucursal').AsString     := xsucursal;
  distribucion.FieldByName('numero').AsString       := xnumero;
  distribucion.FieldByName('entidad').AsString      := xentidad;
  distribucion.FieldByName('fecha').AsString        := utiles.sExprFecha2000(xfecha);
  distribucion.FieldByName('tipomov').AsString      := xtipomov;
  distribucion.FieldByName('referencia').AsString   := xreferencia;
  distribucion.FieldByName('codmov').AsString       := xcodmov;
  distribucion.FieldByName('efectivo').AsFloat      := xefectivo;
  distribucion.FieldByName('transferencia').AsFloat := xtransferencia;
  distribucion.FieldByName('cheques').AsFloat       := xcheques;
  try
    distribucion.Post
   except
    distribucion.Cancel
  end;
  datosdb.closeDB(distribucion); distribucion.Open;
end;

procedure TTDistribucion.getDatosDist(xidc, xtipo, xsucursal, xnumero, xentidad: String);
// Objetivo...: Recuperar una Instancia
begin
  if BuscarDist(xidc, xtipo, xsucursal, xnumero, xentidad) then Begin
    idc           := distribucion.FieldByName('idc').AsString;
    tipo          := distribucion.FieldByName('tipo').AsString;
    sucursal      := distribucion.FieldByName('sucursal').AsString;
    numero        := distribucion.FieldByName('numero').AsString;
    fecha         := utiles.sFormatoFecha(distribucion.FieldByName('fecha').AsString);
    tipomov       := distribucion.FieldByName('tipomov').AsString;
    codmov        := distribucion.FieldByName('codmov').AsString;
    referencia    := distribucion.FieldByName('referencia').AsString;
    efectivo      := distribucion.FieldByName('efectivo').AsFloat;
    transferencia := distribucion.FieldByName('transferencia').AsFloat;
    cheques       := distribucion.FieldByName('cheques').AsFloat;
  end else Begin
    idc := ''; tipo := ''; sucursal := ''; numero := ''; fecha := ''; tipomov := '';
    codmov := ''; referencia := ''; efectivo := 0; cheques := 0; transferencia := 0;
  end;
end;

procedure TTDistribucion.BorrarDist(xidc, xtipo, xsucursal, xnumero, xentidad: String);
// Objetivo...: Borrar una Instancia
begin
  if BuscarDist(xidc, xtipo, xsucursal, xnumero, xentidad) then Begin
    BorrarCheque(xidc, xtipo, xsucursal, xnumero, xentidad);
    caja.Borrar(distribucion.FieldByName('referencia').AsString);
    transferenciabancaria.conectar;
    transferenciabancaria.Borrar(distribucion.FieldByName('referencia').AsString);
    transferenciabancaria.desconectar;
    distribucion.Delete;
    datosdb.closeDB(distribucion); distribucion.Open;
  end;
end;

procedure TTDistribucion.BorrarDist(xreferencia: String);
// Objetivo...: Borrar una Instancia
begin
  BorrarCheque(xreferencia);
  caja.Borrar(xreferencia);
  transferenciabancaria.conectar;
  transferenciabancaria.Borrar(xreferencia);
  transferenciabancaria.desconectar;
  datosdb.tranSQL('delete from ' + distribucion.TableName + ' where referencia = ' + '''' + xreferencia + '''');
  datosdb.closeDB(distribucion); distribucion.Open;
end;

function  TTDistribucion.BuscarCheque(xidc, xtipo, xsucursal, xnumero, xentidad, xitems: String): Boolean;
// Objetivo...: Buscar una Instancia
begin
  Result := datosdb.Buscar(cheque, 'idc', 'tipo', 'sucursal', 'numero', 'entidad', 'items', xidc, xtipo, xsucursal, xnumero, xentidad, xitems);
end;

procedure TTDistribucion.RegistrarCheque(xidc, xtipo, xsucursal, xnumero, xentidad, xitems, xnrocheque, xfechacheque, xcodbanco, xfilial, xpropio, xreferencia: String; xmonto: Real; xcantitems: Integer);
// Objetivo...: Registrar una Instancia
begin
  if BuscarCheque(xidc, xtipo, xsucursal, xnumero, xentidad, xitems) then cheque.Edit else cheque.Append;
  cheque.FieldByName('idc').AsString        := xidc;
  cheque.FieldByName('tipo').AsString       := xtipo;
  cheque.FieldByName('sucursal').AsString   := xsucursal;
  cheque.FieldByName('numero').AsString     := xnumero;
  cheque.FieldByName('entidad').AsString    := xentidad;
  cheque.FieldByName('items').AsString      := xitems;
  cheque.FieldByName('nrocheque').AsString  := xnrocheque;
  cheque.FieldByName('fecha').AsString      := utiles.sExprFecha2000(xfechacheque);
  cheque.FieldByName('codbanco').AsString   := xcodbanco;
  cheque.FieldByName('filial').AsString     := xfilial;
  cheque.FieldByName('propio').AsString     := xpropio;
  cheque.FieldByName('referencia').AsString := xreferencia;
  cheque.FieldByName('monto').AsFloat       := xmonto;
  try
    cheque.Post
   except
    cheque.Cancel
  end;

  if xitems = utiles.sLlenarIzquierda(IntToStr(xcantitems), 2, '0') then Begin
    datosdb.tranSQL('delete from ' + cheque.TableName + ' where idc = ' + '''' + xidc + '''' + ' and tipo = ' + '''' + xtipo + '''' + ' and sucursal = ' + '''' + xsucursal + '''' + ' and numero = ' + '''' + xnumero + '''' + ' and items > ' + '''' + xitems + '''');
    datosdb.closeDB(cheque); cheque.Open;
  end;
end;

function  TTDistribucion.setDatosCheque(xidc, xtipo, xsucursal, xnumero, xentidad: String): TStringList;
// Objetivo...: Recuperar una Instancia
var
  l: TStringList;
begin
  l := TStringList.Create;
  if BuscarCheque(xidc, xtipo, xsucursal, xnumero, xentidad, '01') then Begin
    while not cheque.Eof do Begin
      if (cheque.FieldByName('idc').AsString <> xidc) or (cheque.FieldByName('tipo').AsString <> xtipo) or (cheque.FieldByName('sucursal').AsString <> xsucursal) or (cheque.FieldByName('numero').AsString <> xnumero) then Break;
      l.Add(cheque.FieldByName('items').AsString + cheque.FieldByName('nrocheque').AsString + ';1' + utiles.sFormatoFecha(cheque.FieldByName('fecha').AsString) + cheque.FieldByName('codbanco').AsString + cheque.FieldByName('filial').AsString + ';2' + cheque.FieldByName('propio').AsString + utiles.FormatearNumero(cheque.FieldByName('monto').AsString));
      cheque.Next;
    end;
  end;
  Result := l;
end;

function TTDistribucion.setDatosChequeContado(xidc, xtipo, xsucursal, xnumero, xentidad: String): TStringList;
// Objetivo...: Recuperar una Instancia de cheques de contado
var
  l: TStringList;
begin
  l := TStringList.Create;
  datosdb.Filtrar(cheque, 'idc = ' + '''' + xidc + '''' + ' and tipo = ' + '''' + xtipo + '''' + ' and sucursal = ' + '''' + xsucursal + '''' + ' and numero = ' + '''' + xnumero + '''');
  cheque.First;
  while not cheque.Eof do Begin
    l.Add(cheque.FieldByName('items').AsString + cheque.FieldByName('nrocheque').AsString + ';1' + utiles.sFormatoFecha(cheque.FieldByName('fecha').AsString) + cheque.FieldByName('codbanco').AsString + cheque.FieldByName('filial').AsString + ';2' + cheque.FieldByName('propio').AsString + utiles.FormatearNumero(cheque.FieldByName('monto').AsString));
    cheque.Next;
  end;
  datosdb.QuitarFiltro(cheque);
  Result := l;
end;

procedure TTDistribucion.BorrarCheque(xidc, xtipo, xsucursal, xnumero, xentidad: String);
// Objetivo...: Borrar una Instancia
begin
  datosdb.tranSQL('delete from ' + cheque.TableName + ' where idc = ' + '''' + xidc + '''' + ' and tipo = ' + '''' + xtipo + '''' + ' and sucursal = ' + '''' + xsucursal + '''' + ' and numero = ' + '''' + xnumero + '''' + ' and entidad = ' + '''' + xentidad + '''');
  datosdb.closeDB(cheque); cheque.Open;
end;

procedure TTDistribucion.BorrarCheque(xreferencia: String);
// Objetivo...: Borrar una Instancia
begin
  datosdb.tranSQL('delete from ' + cheque.TableName + ' where referencia = ' + '''' + xreferencia + '''');
  datosdb.closeDB(cheque); cheque.Open;
end;

procedure TTDistribucion.conectar;
// Objetivo...: cerrar tablas de persistencia
begin
  caja.conectar;
  if conexiones = 0 then Begin
    if not distribucion.Active then distribucion.Open;
    if not cheque.Active then cheque.Open;
  end;
  Inc(conexiones);
end;

procedure TTDistribucion.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  caja.desconectar;
  Dec(conexiones);
  if conexiones = 0 then Begin
    datosdb.closeDB(distribucion);
    datosdb.closeDB(cheque);
  end;
end;

{===============================================================================}

function distribucioncom: TTDistribucion;
begin
  if xdistribucion = nil then
    xdistribucion := TTDistribucion.Create;
  Result := xdistribucion;
end;

{===============================================================================}

initialization

finalization
  xdistribucion.Free;

end.
