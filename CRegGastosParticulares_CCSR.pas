unit CRegGastosParticulares_CCSR;

interface

uses CRegGastos_CCSR, CPropitarios_CCSRural, CGastosParticulares_CCSRural, CBDT,
SysUtils, DBTables, CUtiles, CListar, CIDBFM, Classes, CLotes_CCSRural;

type

TTRegistracionGastosParticulares = class(TTRegistracionGastos)
  FechaReg, IdgastoReg, Periodoh2o, Idpropieth2o, Medidor, Fechah2o, Idgastoh2o: String;
  MontoFijo, MontoFijoReg, Primeros200, Siguientes, LecturaAnterior, LecturaAnt_Total,
  LecturaTotal, Lectura, Lecturah2oanter, TarifaAgua, Lecturah2o, Consumoh2o, Montoh2o: Real;
  ExisteConsumo: Boolean;
  IntervaloMesesConsEElectrica_Calculo: ShortInt;
  montosfijos, consumoenergia, tarifa_agua, consumo_agua: TTable;
 public
  { Declaraciones P�blicas }
  constructor Create;

  procedure   RegistrarMontosFijos(xmontofijo, xprimeros200, xsiguientes: Real);
  procedure   getMontosFijos;

  function    BuscarConsumoEnergiaElectrica(xperiodo, xidpropiet, xnroliq: String): Boolean;
  procedure   RegistrarConsumoEnergiaElectrica(xperiodo, xidpropiet, xfecha, xidgasto, xnroliq: String; xlectura, xmontofijo, xprimeros200, xsiguientes: Real);
  procedure   BorrarConsumoEnergiaElectrica(xperiodo, xidpropiet, xnroliq: String);
  procedure   getDatosConsumoEnergiaElectrica(xperiodo, xidpropiet, xnroliq: String);

  function    BuscarTarifaAgua(xperiodo, xnroliq: String): Boolean;
  procedure   RegistrarTarifaAgua(xperiodo, xnroliq: String; xmonto: Real);
  procedure   BorrarTarifaAgua(xperiodo, xnroliq: String);
  procedure   getTarifaAgua(xperiodo, xnroliq: String);
  function    getListConsumoAgua(xperiodo, xnroliq: string): TQuery;

  function    BuscarConsumoH2o(xperiodo, xidpropiet, xmedidor, xnroliq: String): Boolean;
  procedure   RegistrarConsumoH2o(xperiodo, xidpropiet, xmedidor, xfecha, xidgasto, xnroliq: String; xlectura, xlecturaanter, xconsumo, xmonto: Real);
  procedure   BorrarConsumoH2o(xperiodo, xidpropiet, xmedidor, xnroliq: String);
  procedure   getConsumoH2o(xperiodo, xidpropiet, xmedidor, xnroliq: String);
  function    LecturaMesAnteriorH2o(xperiodo, xidpropiet, xmedidor, xnroliq: String): Real;

  procedure   EstablecerIntervaloMesesConsumo(xintervalo: ShortInt);

  function    VerificarSiElPrestatarioTieneMovimientos(xidpropiet: String): Boolean;

  procedure   AplicarGastosFijos(xperiodo, xnroliq: string; list: TStringList; xfecha: string);

  procedure   borrarGastosFijos(xperiodo, xcodigo: string);

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  conexiones: ShortInt;
  archivo: TextFile;
end;

function reggastospart: TTRegistracionGastosParticulares;

implementation

var
  xreggastospart: TTRegistracionGastosParticulares = nil;

constructor TTRegistracionGastosParticulares.Create;
// Objetivo...: Cosntruir la instancia de un objeto
begin
  inherited Create;
  registro       := datosdb.openDB('movgastospart', '');
  montosfijos    := datosdb.openDB('montosfijos', '');
  consumoenergia := datosdb.openDB('consumoenergia', '');
  tarifa_agua    := datosdb.openDB('tarifa_agua', '');
  consumo_agua   := datosdb.openDB('consumo_agua', '');
end;

procedure TTRegistracionGastosParticulares.RegistrarMontosFijos(xmontofijo, xprimeros200, xsiguientes: Real);
// Objetivo...: aplicar montos fijos
Begin
  if montosfijos.RecordCount > 0 then montosfijos.Edit else montosfijos.Append;
  montosfijos.FieldByName('montofijo').AsFloat   := xmontofijo;
  montosfijos.FieldByName('primeros200').AsFloat := xprimeros200;
  montosfijos.FieldByName('siguientes').AsFloat  := xsiguientes;
  try
    montosfijos.Post
   except
    montosfijos.Cancel
  end;
  datosdb.closeDB(montosfijos); montosfijos.Open;
end;

procedure TTRegistracionGastosParticulares.getMontosFijos;
// Objetivo...: Obtener los montos fijos
Begin
  if montosfijos.RecordCount > 0 then Begin
    montofijo   := montosfijos.FieldByName('montofijo').AsFloat;
    primeros200 := montosfijos.FieldByName('primeros200').AsFloat;
    siguientes  := montosfijos.FieldByName('siguientes').AsFloat;
  end else Begin
    montofijo := 0; primeros200 := 0; siguientes := 0;
  end;
end;

function  TTRegistracionGastosParticulares.BuscarConsumoEnergiaElectrica(xperiodo, xidpropiet, xnroliq: String): Boolean;
Begin
  ExisteConsumo := datosdb.Buscar(consumoenergia, 'Periodo', 'Idpropiet', 'Nroliq', xperiodo, xidpropiet, xnroliq);
  Result := ExisteConsumo;
end;

procedure TTRegistracionGastosParticulares.RegistrarConsumoEnergiaElectrica(xperiodo, xidpropiet, xfecha, xidgasto, xnroliq: String; xlectura, xmontofijo, xprimeros200, xsiguientes: Real);
Begin
  if BuscarConsumoEnergiaElectrica(xperiodo, xidpropiet, xnroliq) then consumoenergia.Edit else consumoenergia.Append;
  consumoenergia.FieldByName('periodo').AsString    := xperiodo;
  consumoenergia.FieldByName('idpropiet').AsString  := xidpropiet;
  consumoenergia.FieldByName('nroliq').AsString     := xnroliq;
  consumoenergia.FieldByName('fecha').AsString      := utiles.sExprFecha2000(xfecha);
  consumoenergia.FieldByName('lectura').AsFloat     := xlectura;
  consumoenergia.FieldByName('montofijo').AsFloat   := xmontofijo;
  consumoenergia.FieldByName('primeros200').AsFloat := xprimeros200;
  consumoenergia.FieldByName('siguientes').AsFloat  := xsiguientes;
  consumoenergia.FieldByName('idgasto').AsString  := xidgasto;
  try
    consumoenergia.Post
   except
    consumoenergia.Cancel
  end;
  datosdb.closeDB(consumoenergia); consumoenergia.Open;
end;

procedure TTRegistracionGastosParticulares.getDatosConsumoEnergiaElectrica(xperiodo, xidpropiet, xnroliq: String);
var
  peranter, nroliqanter: String; i: Integer;
Begin
  LecturaAnt_Total := 0; LecturaTotal := 0; peranter := xperiodo;

  if (xnroliq = '01') then
    For i := 1 to IntervaloMesesConsEElectrica_Calculo do peranter := utiles.PeriodoAnterior(peranter);

  if (xnroliq = '02') then nroliqanter := '01' else nroliqanter := '01';


  if BuscarConsumoEnergiaElectrica(peranter, '0000', nroliqanter) then LecturaAnt_Total := consumoenergia.FieldByName('lectura').AsFloat;
  if BuscarConsumoEnergiaElectrica(xperiodo, '0000', nroliqanter) then LecturaTotal := consumoenergia.FieldByName('lectura').AsFloat;
  if BuscarConsumoEnergiaElectrica(peranter, xidpropiet, nroliqanter) then LecturaAnterior := consumoenergia.FieldByName('lectura').AsFloat else LecturaAnterior := 0;
  if BuscarConsumoEnergiaElectrica(xperiodo, xidpropiet, nroliqanter) then Begin
    lectura      := consumoenergia.FieldByName('lectura').AsFloat;
    fechareg     := utiles.sFormatoFecha(consumoenergia.FieldByName('fecha').AsString);
    MontoFijoReg := consumoenergia.FieldByName('montofijo').AsFloat;
    primeros200  := consumoenergia.FieldByName('primeros200').AsFloat;
    siguientes   := consumoenergia.FieldByName('siguientes').AsFloat;
    IdgastoReg   := consumoenergia.FieldByName('idgasto').AsString;
  end else Begin
    lectura := 0; primeros200 := 0; siguientes := 0; montofijoreg := 0; fechareg := utiles.setFechaActual; idgastoReg := '';
  end;
end;

function  TTRegistracionGastosParticulares.BuscarTarifaAgua(xperiodo, xnroliq: String): Boolean;
// Objetivo...: Recuperar una instancia
Begin
  Result := datosdb.Buscar(tarifa_agua, 'periodo', 'nroliq', xperiodo, xnroliq);
end;

procedure TTRegistracionGastosParticulares.RegistrarTarifaAgua(xperiodo, xnroliq: String; xmonto: Real);
// Objetivo...: Registrar una instancia
Begin
  if BuscarTarifaAgua(xperiodo, xnroliq) then tarifa_agua.Edit else tarifa_agua.Append;
  tarifa_agua.FieldByName('periodo').AsString := xperiodo;
  tarifa_agua.FieldByName('nroliq').AsString  := xnroliq;
  tarifa_agua.FieldByName('monto').AsFloat    := xmonto;
  try
    tarifa_agua.Post
   except
    tarifa_agua.Cancel
  end;
  datosdb.closeDB(tarifa_agua); tarifa_agua.Open;
end;

procedure TTRegistracionGastosParticulares.BorrarTarifaAgua(xperiodo, xnroliq: String);
// Objetivo...: Borrar una instancia
Begin
  if BuscarTarifaAgua(xperiodo, xnroliq) then Begin
    tarifa_agua.Delete;
    datosdb.closeDB(tarifa_agua); tarifa_agua.Open;
  end;
end;

procedure TTRegistracionGastosParticulares.getTarifaAgua(xperiodo, xnroliq: String);
// Objetivo...: Cargar una instancia
Begin
  if BuscarTarifaAgua(xperiodo, xnroliq) then Begin
    TarifaAgua := tarifa_agua.FieldByName('monto').AsFloat;
  end else Begin
    TarifaAgua := 0;
  end;
end;

function  TTRegistracionGastosParticulares.getListConsumoAgua(xperiodo, xnroliq: string): TQuery;
// Objetivo...: Cargar una instancia
Begin
  Result := datosdb.tranSQL('select consumo_agua.periodo, consumo_agua.fecha, consumo_agua.idpropiet, consumo_agua.medidor, consumo_agua.consumo, consumo_agua.monto, consumo_agua.lecturaanter, consumo_agua.lectura, propietarios.nombre ' +
  'from consumo_agua, propietarios where consumo_agua.idpropiet = propietarios.idpropiet and periodo = ' + '''' + xperiodo + '''' + '''' + ' and nroliq = ' + '''' + xnroliq + '''' + ' order by nombre, medidor');
end;

function  TTRegistracionGastosParticulares.BuscarConsumoH2o(xperiodo, xidpropiet, xmedidor, xnroliq: String): Boolean;
// Objetivo...: Cargar una instancia
Begin
  Result := datosdb.Buscar(consumo_agua, 'periodo', 'idpropiet', 'medidor', 'nroliq', xperiodo, xidpropiet, xmedidor, xnroliq);
end;

procedure TTRegistracionGastosParticulares.RegistrarConsumoH2o(xperiodo, xidpropiet, xmedidor, xfecha, xidgasto, xnroliq: String; xlectura, xlecturaanter, xconsumo, xmonto: Real);
// Objetivo...: Registrar una instancia
Begin
  if BuscarConsumoh2o(xperiodo, xidpropiet, xmedidor, xnroliq) then consumo_agua.Edit else consumo_agua.Append;
  consumo_agua.FieldByName('periodo').AsString     := xperiodo;
  consumo_agua.FieldByName('idpropiet').AsString   := xidpropiet;
  consumo_agua.FieldByName('medidor').AsString     := xmedidor;
  consumo_agua.FieldByName('fecha').AsString       := utiles.sExprFecha2000(xfecha);
  consumo_agua.FieldByName('idgasto').AsString     := xidgasto;
  consumo_agua.FieldByName('nroliq').AsString      := xnroliq;
  consumo_agua.FieldByName('lectura').AsFloat      := xlectura;
  consumo_agua.FieldByName('lecturaanter').AsFloat := xlecturaanter;
  consumo_agua.FieldByName('consumo').AsFloat      := xconsumo;
  consumo_agua.FieldByName('monto').AsFloat        := xmonto;
  try
    consumo_agua.Post
   except
    consumo_agua.Cancel
  end;
  datosdb.closeDB(consumo_agua); consumo_agua.Open;
end;

procedure TTRegistracionGastosParticulares.BorrarConsumoH2o(xperiodo, xidpropiet, xmedidor, xnroliq: String);
// Objetivo...: Borrar una instancia
Begin
  if BuscarConsumoh2o(xperiodo, xidpropiet, xmedidor, xnroliq) then Begin
    consumo_agua.Delete;
    datosdb.closeDB(consumo_agua); consumo_agua.Open;
  end;
end;

procedure TTRegistracionGastosParticulares.getConsumoH2o(xperiodo, xidpropiet, xmedidor, xnroliq: String);
// Objetivo...: Cargar una instancia
Begin
  if BuscarConsumoh2o(xperiodo, xidpropiet, xmedidor, xnroliq) then Begin
    periodoh2o      := consumo_agua.FieldByName('periodo').AsString;
    idpropieth2o    := consumo_agua.FieldByName('idpropiet').AsString;
    medidor         := consumo_agua.FieldByName('medidor').AsString;
    fechah2o        := utiles.sFormatoFecha(consumo_agua.FieldByName('fecha').AsString);
    idgastoh2o      := consumo_agua.FieldByName('idgasto').AsString;
    lecturah2o      := consumo_agua.FieldByName('lectura').AsFloat;
    lecturah2oanter := consumo_agua.FieldByName('lecturaanter').AsFloat;
    consumoh2o      := consumo_agua.FieldByName('consumo').AsFloat;
    montoh2o        := consumo_agua.FieldByName('monto').AsFloat;
  end else Begin
    periodoh2o := ''; idpropieth2o := ''; medidor := ''; fechah2o := ''; idgastoh2o := ''; lecturah2o := 0; consumoh2o := 0; montoh2o := 0; lecturah2oanter := 0; medidor := '';
  end;
end;

function  TTRegistracionGastosParticulares.LecturaMesAnteriorH2o(xperiodo, xidpropiet, xmedidor, xnroliq: String): Real;
// Objetivo...: Recuperar la lectura del mes anterior
var
  per: String;
Begin
  per := utiles.RestarPeriodo(xperiodo, '1');
  if BuscarConsumoH2o(per, xidpropiet, xmedidor, xnroliq) then Result := consumo_agua.FieldByName('lectura').AsFloat else Result := 0;
end;

procedure TTRegistracionGastosParticulares.EstablecerIntervaloMesesConsumo(xintervalo: ShortInt);
Begin
  AssignFile(archivo, dbs.DirSistema + '\mesesee.ini');
  Rewrite(archivo);
  WriteLn(archivo, xintervalo);
  closeFile(archivo);
  IntervaloMesesConsEElectrica_Calculo := xintervalo;
end;

function TTRegistracionGastosParticulares.VerificarSiElPrestatarioTieneMovimientos(xidpropiet: String): Boolean;
// Objetivo...: Verificar si el Items tiene Movimientos
var
  r: TQuery;
Begin
  r := datosdb.tranSQL('SELECT * FROM movgastospart WHERE idpropiet = ' + '"' + xidpropiet + '"');
  r.Open;
  if r.RecordCount > 0 then Result := True else Result := False;
  r.Close; r.Free;
end;

procedure TTRegistracionGastosParticulares.BorrarConsumoEnergiaElectrica(xperiodo, xidpropiet, xnroliq: String);
Begin
  if BuscarConsumoEnergiaElectrica(xperiodo, xidpropiet, xnroliq) then consumoenergia.Delete;
  datosdb.closeDB(consumoenergia); consumoenergia.Open;
end;

procedure TTRegistracionGastosParticulares.AplicarGastosFijos(xperiodo, xnroliq: string; list: TStringList; xfecha: string);
var
  r, t: TQuery;
  monto, montofijo, cantlotes: real;
  i: integer;
  dlote: string;
begin
  datosdb.tranSQL('delete from movgastospart where periodo = ' + '''' + xperiodo + '''' + ' and mfijo = ' + '''' + 'S' + '''' + ' and nroliq = ' + '''' + xnroliq + '''');
  datosdb.refrescar(registro);

  lote.conectar;

  r := gastospart.getListGastos;
  r.Open;
  while not r.eof do begin
    montofijo := gastospart.getMonto(r.FieldByName('sk_gasto').asstring);
    gastospart.getDatos(r.FieldByName('sk_gasto').asstring);

    if (gastospart.MFijo = 'S') then begin     // Gastos Masivos

      for i := 1 to list.Count do begin
        if (gastospart.mlote) then begin
          cantlotes := lote.getLotesPorPropietario(list.Strings[i-1]);
          dlote := ' (' + floattostr(cantlotes) + ' lote(s) )';
        end else cantlotes := 1;

        monto := montofijo * cantlotes;

        Registar(xperiodo, list.Strings[i-1], r.FieldByName('sk_gasto').asstring, '001', xnroliq, xfecha, '', gastospart.Descrip + dlote, monto, 1, 'S');
       end;
    end;

    if (gastospart.MFijo = 'P') then begin
      montofijo := 0;
      t := gastospart.getListGastosIndividuales(gastospart.Idgasto);
      t.open;
      while not t.eof do begin
        if (montofijo = 0) then montofijo := gastospart.getMonto(r.FieldByName('sk_gasto').asstring);
        Registar(xperiodo, t.FieldByName('idpropiet').asstring, r.FieldByName('sk_gasto').asstring, '001', xnroliq, xfecha, '', gastospart.Descrip, montofijo, 1, 'S');
        t.next;
      end;
      t.close; t.free;
    end;

    r.Next;
  end;
  r.close; r.free;

  lote.desconectar;
end;

procedure TTRegistracionGastosParticulares.borrarGastosFijos(xperiodo, xcodigo: string);
begin
  datosdb.tranSQL('delete from movgastospart where periodo = ' + '''' + xperiodo + '''' + ' and idgasto = ' + '''' + xcodigo + '''');
  datosdb.refrescar(registro);
end;

procedure TTRegistracionGastosParticulares.conectar;
// Objetivo...: cerrar tablas de persistencia
begin
  inherited conectar;
  propietario.conectar;
  gastospart.conectar;
  if conexiones = 0 then Begin
    if not montosfijos.Active then montosfijos.Open;
    if not consumoenergia.Active then consumoenergia.Open;
    if not tarifa_agua.Active then tarifa_agua.Open;
    if not consumo_agua.Active then consumo_agua.Open;
  end;
  Inc(conexiones);
  IntervaloMesesConsEElectrica_Calculo := 1;
  if FileExists(dbs.DirSistema + '\mesesee.ini') then Begin
    AssignFile(archivo, dbs.DirSistema + '\mesesee.ini');
    Reset(archivo);
    ReadLn(archivo, IntervaloMesesConsEElectrica_Calculo);
    closeFile(archivo);
  end;
end;

procedure TTRegistracionGastosParticulares.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  inherited desconectar;
  propietario.desconectar;
  gastospart.desconectar;
  if conexiones > 0 then Dec(conexiones);
  if conexiones = 0 then Begin
    datosdb.closeDB(montosfijos);
    datosdb.closeDB(consumoenergia);
    datosdb.closeDB(tarifa_agua);
    datosdb.closeDB(consumo_agua);
  end;
end;

{===============================================================================}

function reggastospart: TTRegistracionGastosParticulares;
begin
  if xreggastospart = nil then
    xreggastospart := TTRegistracionGastosParticulares.Create;
  Result := xreggastospart;
end;

{===============================================================================}

initialization

finalization
  xreggastospart.Free;

end.
