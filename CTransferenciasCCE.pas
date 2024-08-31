unit CTransferenciasCCE;

interface

uses CBDT, SysUtils, DBTables, CUtiles, CListar, CIDBFM, Classes, Contnrs;

type

TTransferencias = class
  Idregistro, Transaccion, Fecha, Concepto, Entidad, Tipomov, Cuenta, Ajuste, Cuentatran, Entidadtran: String;
  Monto, Saldo, Netotran, Comisionestran, Impdebtran, Sellostran, Impuestostran, Telextran: Real;
  tabla: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  function    Buscar(xidregistro: String): Boolean;
  procedure   Registrar(xidregistro, xtransaccion, xfecha, xconcepto, xentidad, xtipomov, xcuenta, xajuste, xcuentatran, xentidadtran: String;
                        xmonto, xnetotran, xcomisionestran, ximpdebtran, xsellostran, ximpuestostran, xtelextran: Real);
  procedure   RegistrarTransPendientes(xidregistro, xtransaccion, xfecha, xconcepto, xentidad, xtipomov, xcuenta, xajuste, xcuentatran, xentidadtran: String;
                        xmonto, xnetotran, xcomisionestran, ximpdebtran, xsellostran, ximpuestostran, xtelextran: Real);
  procedure   getDatos(xidregistro: String);
  procedure   Borrar(xidregistro: String);
  procedure   RecalcularSaldo(xcuenta: String); overload;

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  conexiones: shortint;
  procedure   RecalcularSaldo(xfecha, xcuenta: String); overload;
end;

implementation

constructor TTransferencias.Create;
begin
end;

destructor TTransferencias.Destroy;
begin
  inherited Destroy;
end;

function  TTransferencias.Buscar(xidregistro: String): Boolean;
// Objetivo...: Buscar una Instancia
begin
  if tabla.IndexFieldNames <> 'Idregistro' then tabla.IndexFieldNames := 'Idregistro';
  Result := tabla.FindKey([xidregistro]);
end;

procedure TTransferencias.Registrar(xidregistro, xtransaccion, xfecha, xconcepto, xentidad, xtipomov, xcuenta, xajuste, xcuentatran, xentidadtran: String;
                                    xmonto, xnetotran, xcomisionestran, ximpdebtran, xsellostran, ximpuestostran, xtelextran: Real);
// Objetivo...: Persisitir una Instancia
begin
  if Buscar(xidregistro) then tabla.Edit else tabla.Append;
  tabla.FieldByName('idregistro').AsString    := xidregistro;
  tabla.FieldByName('transaccion').AsString   := xtransaccion;
  tabla.FieldByName('fecha').AsString         := utiles.sExprFecha2000(xfecha);
  tabla.FieldByName('concepto').AsString      := xconcepto;
  tabla.FieldByName('entidad').AsString       := xentidad;
  tabla.FieldByName('tipomov').AsString       := xtipomov;
  tabla.FieldByName('cuenta').AsString        := xcuenta;
  tabla.FieldByName('ajuste').AsString        := xajuste;
  tabla.FieldByName('cuentatran').AsString    := xcuentatran;
  tabla.FieldByName('entidadtran').AsString   := xentidadtran;
  tabla.FieldByName('monto').AsFloat          := xmonto;
  tabla.FieldByName('netotran').AsFloat       := xnetotran;
  tabla.FieldByName('comisionestran').AsFloat := xcomisionestran;
  tabla.FieldByName('impdebtran').AsFloat     := ximpdebtran;
  tabla.FieldByName('sellostran').AsFloat     := xsellostran;
  tabla.FieldByName('impuestostran').AsFloat  := ximpuestostran;
  tabla.FieldByName('telextran').AsFloat      := xtelextran;
  try
    tabla.Post
   except
    tabla.Cancel
  end;
  datosdb.closeDB(tabla); tabla.Open;
  RecalcularSaldo(xfecha, xcuenta);
  idregistro := xidregistro;
end;

procedure TTransferencias.RegistrarTransPendientes(xidregistro, xtransaccion, xfecha, xconcepto, xentidad, xtipomov, xcuenta, xajuste, xcuentatran, xentidadtran: String;
                                    xmonto, xnetotran, xcomisionestran, ximpdebtran, xsellostran, ximpuestostran, xtelextran: Real);
// Objetivo...: Persisitir una Instancia
begin
  if Buscar(xidregistro) then tabla.Edit else tabla.Append;
  tabla.FieldByName('idregistro').AsString    := xidregistro;
  tabla.FieldByName('transaccion').AsString   := xtransaccion;
  tabla.FieldByName('fecha').AsString         := utiles.sExprFecha2000(xfecha);
  tabla.FieldByName('concepto').AsString      := xconcepto;
  tabla.FieldByName('entidad').AsString       := xentidad;
  tabla.FieldByName('tipomov').AsString       := xtipomov;
  tabla.FieldByName('cuenta').AsString        := xcuenta;
  tabla.FieldByName('ajuste').AsString        := xajuste;
  tabla.FieldByName('cuentatran').AsString    := xcuentatran;
  tabla.FieldByName('entidadtran').AsString   := xentidadtran;
  tabla.FieldByName('monto').AsFloat          := xmonto;
  tabla.FieldByName('netotran').AsFloat       := xnetotran;
  tabla.FieldByName('comisionestran').AsFloat := xcomisionestran;
  tabla.FieldByName('impdebtran').AsFloat     := ximpdebtran;
  tabla.FieldByName('sellostran').AsFloat     := xsellostran;
  tabla.FieldByName('impuestostran').AsFloat  := ximpuestostran;
  tabla.FieldByName('telextran').AsFloat      := xtelextran;
  tabla.FieldByName('estado').AsString        := 'P';
  try
    tabla.Post
   except
    tabla.Cancel
  end;
  datosdb.closeDB(tabla); tabla.Open;
  if LowerCase(tabla.TableName) <> 'transbancariaspen' then RecalcularSaldo(cuenta);
  idregistro := xidregistro;
end;

procedure TTransferencias.getDatos(xidregistro: String);
// Objetivo...: Recuperar una Instancia
begin
  if Buscar(xidregistro) then Begin
    idregistro     := tabla.FieldByName('idregistro').AsString;
    transaccion    := tabla.FieldByName('transaccion').AsString;
    fecha          := utiles.sFormatoFecha(tabla.FieldByName('fecha').AsString);
    concepto       := tabla.FieldByName('concepto').AsString;
    entidad        := tabla.FieldByName('entidad').AsString;
    tipomov        := tabla.FieldByName('tipomov').AsString;
    cuenta         := tabla.FieldByName('cuenta').AsString;
    ajuste         := tabla.FieldByName('ajuste').AsString;
    cuentatran     := tabla.FieldByName('cuentatran').AsString;
    entidadtran    := tabla.FieldByName('entidadtran').AsString;
    monto          := tabla.FieldByName('monto').AsFloat;
    netotran       :=  tabla.FieldByName('netotran').AsFloat;
    comisionestran := tabla.FieldByName('comisionestran').AsFloat;
    impdebtran     := tabla.FieldByName('impdebtran').AsFloat;
    sellostran     := tabla.FieldByName('sellostran').AsFloat;
    impuestostran  := tabla.FieldByName('impuestostran').AsFloat;
    telextran      := tabla.FieldByName('telextran').AsFloat;
  end else Begin
    idregistro := ''; transaccion := ''; fecha := ''; concepto := ''; entidad := ''; tipomov := ''; cuenta := ''; monto := 0; ajuste := ''; cuentatran := ''; entidadtran := '';
    netotran := 0; comisionestran := 0; impdebtran := 0; sellostran := 0; impuestostran := 0; telextran := 0;
  end;
end;

procedure TTransferencias.Borrar(xidregistro: String);
// Objetivo...: Borrar una Instancia
begin
  if Buscar(xidregistro) then Begin
    cuenta := tabla.FieldByName('cuenta').AsString;
    tabla.Delete;
    datosdb.closeDB(tabla); tabla.Open;
    if LowerCase(tabla.TableName) <> 'transbancariaspen' then RecalcularSaldo(cuenta);
  end;
end;

procedure TTransferencias.RecalcularSaldo(xfecha, xcuenta: String);
// Objetivo...: recalcular saldo
var
  saldo: Real;
  l1, l2: TStringList;
  i: Integer;
begin
  l1 := TStringList.Create; l2 := TStringList.Create;
  tabla.IndexFieldNames := 'Fecha';
  datosdb.Filtrar(tabla, 'cuenta = ' + '''' + xcuenta + '''');
  if tabla.FindKey([utiles.sExprFecha2000(xfecha)]) then Begin
    if tabla.RecordCount > 1 then Begin
      tabla.Prior;
      saldo := tabla.FieldByName('saldo').AsFloat;
    end;
    tabla.FindKey([utiles.sExprFecha2000(xfecha)]);
    while not tabla.Eof do Begin
      if tabla.FieldByName('tipomov').AsString = '1' then saldo := saldo + tabla.FieldByName('monto').AsFloat;
      if tabla.FieldByName('tipomov').AsString = '2' then saldo := saldo - tabla.FieldByName('monto').AsFloat;
      if tabla.FieldByName('saldo').AsFloat <> saldo then Begin
        l1.Add(tabla.FieldByName('idregistro').AsString);
        l2.Add(FloatToStr(saldo));
      end;
      tabla.Next;
    end;
  end;

  datosdb.QuitarFiltro(tabla);  datosdb.closeDB(tabla); tabla.Open;
  tabla.IndexFieldNames := 'Idregistro';

  For i := 1 to l1.Count do Begin
    if Buscar(l1.Strings[i-1]) then Begin
      tabla.Edit;
      tabla.FieldByName('saldo').AsFloat := StrToFloat(l2.Strings[i-1]);
      try
        tabla.Post
       except
        tabla.Cancel
      end;
    end;
  end;

  l1.Destroy; l2.Destroy;
end;

procedure TTransferencias.RecalcularSaldo(xcuenta: String);
// Objetivo...: recalcular saldo
var
  saldo: Real;
  l1, l2: TStringList;
  i: Integer;
begin
  l1 := TStringList.Create; l2 := TStringList.Create;
  tabla.IndexFieldNames := 'Fecha';
  datosdb.Filtrar(tabla, 'cuenta = ' + '''' + xcuenta + '''');
  tabla.First;
  while not tabla.Eof do Begin
    if tabla.FieldByName('tipomov').AsString = '1' then saldo := saldo + tabla.FieldByName('monto').AsFloat;
    if tabla.FieldByName('tipomov').AsString = '2' then saldo := saldo - tabla.FieldByName('monto').AsFloat;
    if tabla.FieldByName('saldo').AsFloat <> saldo then Begin
      l1.Add(tabla.FieldByName('idregistro').AsString);
      l2.Add(FloatToStr(saldo));
    end;
    tabla.Next;
  end;

  datosdb.QuitarFiltro(tabla);  datosdb.closeDB(tabla); tabla.Open;
  tabla.IndexFieldNames := 'Idregistro';

  For i := 1 to l1.Count do Begin
    if Buscar(l1.Strings[i-1]) then Begin
      tabla.Edit;
      tabla.FieldByName('saldo').AsFloat := StrToFloat(l2.Strings[i-1]);
      try
        tabla.Post
       except
        tabla.Cancel
      end;
    end;
  end;

  l1.Destroy; l2.Destroy;
end;

procedure TTransferencias.conectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones = 0 then Begin
  end;
  Inc(conexiones);
end;

procedure TTransferencias.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  Dec(conexiones);
  if conexiones = 0 then Begin
  end;
end;

end.
