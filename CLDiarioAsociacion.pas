unit CLDiarioAsociacion;

interface

uses CRegContAsociacion, CPlanctasAsociacion, SysUtils, CListar, DB, DBTables, CBDT,
     CUtiles, CIDBFM, CPeriodoAsociacion, Classes, CUtilidadesArchivos;

type

TTLDiario = class(TTRegCont)
  periodo, nroasien, fecha, observac, clave: string;  // Cabecera
  nromovi, codcta, concepto, dh, cuenta: string;
  importe: real;
  ExisteAsiento: Boolean;
 public
  { Declaraciones P�blicas }
  constructor Create;
  destructor  Destroy; override;

  function    Buscar(xperiodo, xnroasien: string): boolean; overload;
  function    Buscar(xperiodo, xnroasien, xnromovi, xcodcta: string): boolean; overload;
  function    BuscarDet(xperiodo, xnroasien, xcodcta, xnromovi: string): boolean; overload;
  procedure   Grabar(xperiodo, xnroasien, xfecha, xobservac: string); overload;
  procedure   Grabar(xperiodo, xnroasien, xfecha, xobservac, xclave: string); overload;
  procedure   Grabar(xperiodo, xnroasien, xfecha, xcodcta, xnromovi, xconcepto, xdh: string; ximporte: real); overload;
  procedure   Grabar(xperiodo, xnroasien, xfecha, xcodcta, xnromovi, xconcepto, xdh, xclave: string; ximporte: real); overload;
  procedure   Grabar(xperiodo, xnroasien, xcodcta, xnromovi, xfecha, xconcepto: string; ximporte: real); overload;
  procedure   Borrar(xperiodo, xnroasien: string); overload;
  procedure   Borrar(xperiodo, xnroasien, xclave: string); overload;
  procedure   getDatos(xperiodo, xnroasien: string);
  function    verifCuenta(xcodcta: string): boolean;
  function    setItems: TQuery; overload;
  function    setItems(xperiodo, xnroasien: string): TQuery; overload;
  function    setItems(xperiodo, xnroasien, xcodcta: string): TQuery; overload;
  function    setAsientos(xperiodo: string): TQuery;
  function    setAsientosAuditoria(xfecha: string): TQuery; virtual;
  function    setAsientosAuditoriaAutomaticos(xfecha: string): TQuery;
  function    setItemsLista: TStringList;

  procedure   ListDiario(titulo, periodo: string; salida, ctrcostos: char; df, hf, dn, hn: string; tlist: char);
  procedure   Renumerar;
  procedure   CambiarCodCtas(xs, xp, actperiodo, codctaactual, codctaanterior: string);
  function    NuevoAsiento(xperiodo: String): string;
  procedure   Filtrar(xperiodo: String);
  function    CantidadAsientosRenumerados: Integer;

  procedure   MarcarAsientoAutomatico(xperiodo, xnroasien, xid: String);
  procedure   BorrarAsientoAutomatico(xperiodo, xid: String);
  function    verificarAsientoRefundicionCuentasResultado(xperiodo: String): Boolean;
  function    verificarAsientoRefundicionCuentasPatrimoniales(xperiodo: String): Boolean;
  function    verificarAsientoApertura(xperiodo: String): Boolean;

  function    setAsientosFecha(xdfecha, xhfecha: String): TStringList;

  procedure   ExportarAsientos(xperiodo: String; lista: TStringList; xdrive: Char);
  function    TransferirAsientos(xperiodo: String; xdrive: String): TStringList;
  procedure   ImportarAsientos(xperiodo: String; lista: TStringList; xsobreescribir: Boolean);
 private
  { Declaraciones Privadas }
  nroasientoanterior, nuevonroasiento, fec, claveas, claveasiento: string;
  nroas, asientosrenumerados: integer;

  procedure   ListarItems(periodo, asiento, codcta: string; salida: char);
  procedure   Transporte(salida: char; ley: string);
  procedure   IniciarNuevoAsiento(periodo, titulo: string; salida: char);
  procedure   titulos(salida: char; xtitulo: string);
  procedure   BorrarCCostos(xperiodo, xnroasien, xcodcta: string); overload;
 protected
  { Declaraciones Protegidas }
  procedure  BorrarItems(xperiodo, xnroasien: string); overload;
  procedure  BorrarItems(xperiodo, xnroasien, xclave: string); overload;
  function   ControlarSalto: boolean; override;
end;

function ldiario: TTLDiario;

implementation

var
  xldiario: TTLDiario = nil;

constructor TTLDiario.Create;
begin
  inherited Create;
end;

destructor TTLDiario.Destroy;
begin
  inherited Destroy;
end;

function TTLDiario.Buscar(xperiodo, xnroasien: string): boolean;
// Objetivo...: Buscar el Objeto solicitado
begin
  if asientos.IndexFieldNames <> 'Periodo;Nroasien' then asientos.IndexFieldNames := 'Periodo;Nroasien';
  ExisteAsiento := datosdb.Buscar(cabasien, 'periodo', 'nroasien', xperiodo, xnroasien);
  Result := ExisteAsiento;
end;

function TTLDiario.Buscar(xperiodo, xnroasien, xnromovi, xcodcta: string): boolean;
// Objetivo...: Buscar el Objeto solicitado
begin
  if asientos.IndexFieldNames <> 'Periodo;Nroasien;Nromovi;Codcta' then asientos.IndexFieldNames := 'Periodo;Nroasien;Nromovi;Codcta';
  Result := datosdb.Buscar(asientos, 'periodo', 'nroasien', 'nromovi', 'codcta', xperiodo, xnroasien, xnromovi, xcodcta);
end;

function TTLDiario.BuscarDet(xperiodo, xnroasien, xcodcta, xnromovi: string): boolean;
// Objetivo...: Buscar el Objeto solicitado - movimiento de detalle de una cuenta registrada
begin
  Result := datosdb.Buscar(ccostos, 'periodo', 'nroasien', 'codcta', 'nromovi', xperiodo, xnroasien, xcodcta, xnromovi);
end;

procedure TTLDiario.Grabar(xperiodo, xnroasien, xfecha, xobservac: string);
// Objetivo...: Grabar Atributos del Objeto - cabecera de asientos
begin
  if Buscar(xperiodo, xnroasien) then begin
    claveasiento := cabasien.FieldByName('idasiento').AsString;
    cabasien.Edit;
    BorrarItems(xperiodo, xnroasien);
  end else Begin
    cabasien.Append;
    claveasiento := utiles.setIdRegistroFecha;
  end;
  cabasien.FieldByName('periodo').AsString    := xperiodo;
  cabasien.FieldByName('nroasien').AsString   := xnroasien;
  cabasien.FieldByName('idasiento').AsString  := claveasiento;
  cabasien.FieldByName('fecha').AsString      := utiles.sExprFecha2000(xfecha);
  cabasien.FieldByName('observac').AsString   := xobservac;
  try
    cabasien.Post;
  except
    cabasien.Cancel;
  end;
  datosdb.closeDB(cabasien); cabasien.Open;
end;

procedure TTLDiario.Grabar(xperiodo, xnroasien, xfecha, xcodcta, xnromovi, xconcepto, xdh: string; ximporte: real);
// Objetivo...: Grabar Atributos del Objeto - cuentas de asientos
begin
  if Buscar(xperiodo, xnroasien, xnromovi, xcodcta) then asientos.Edit else asientos.Append;
  asientos.FieldByName('periodo').AsString    := xperiodo;
  asientos.FieldByName('idasiento').AsString  := xdh + Copy(utiles.idregistro, 1, 9);
  asientos.FieldByName('codcta').AsString     := xcodcta;
  asientos.FieldByName('nroasien').AsString   := xnroasien;
  asientos.FieldByName('fecha').AsString      := utiles.sExprFecha2000(xfecha);
  asientos.FieldByName('concepto').AsString   := xconcepto;
  asientos.FieldByName('nromovi').AsString    := xnromovi;
  asientos.FieldByName('dh').AsString         := xdh;
  asientos.FieldByName('importe').AsFloat     := ximporte;
  asientos.FieldByName('idasiento').AsString  := claveasiento;
  try
    asientos.Post;
  except
    asientos.Cancel;
  end;
  datosdb.closeDB(asientos); asientos.Open;
end;

procedure  TTLDiario.Grabar(xperiodo, xnroasien, xfecha, xcodcta, xnromovi, xconcepto, xdh, xclave: string; ximporte: real);
// Objetivo...: Grabar atributos relacionados al movimiento de una cuenta - incluyendo clave de asientos generados autom�ticamente
begin
  Grabar(xperiodo, xnroasien, xfecha, xcodcta, xnromovi, xconcepto, xdh, ximporte);
  asientos.Edit;
  asientos.FieldByName('clave').AsString := xclave;
  try
    asientos.Post;
  except
    asientos.Cancel;
  end;
  datosdb.closeDB(asientos); asientos.Open;
end;

procedure  TTLDiario.Grabar(xperiodo, xnroasien, xfecha, xobservac, xclave: string);
// Objetivo...: Grabar atributos relacionados al movimiento de una cuenta - incluyendo clave de asientos generados autom�ticamente
begin
  if Buscar(xperiodo, xnroasien) then begin
    claveasiento := cabasien.FieldByName('idasiento').AsString;
    cabasien.Edit;
    BorrarItems(xperiodo, xnroasien, xclave);
  end else Begin
    cabasien.Append;
    claveasiento := utiles.setIdRegistroFecha;
  end;
  cabasien.FieldByName('periodo').AsString    := xperiodo;
  cabasien.FieldByName('nroasien').AsString   := xnroasien;
  cabasien.FieldByName('idasiento').AsString  := claveasiento;
  cabasien.FieldByName('fecha').AsString      := utiles.sExprFecha2000(xfecha);
  cabasien.FieldByName('observac').AsString   := xobservac;
  cabasien.FieldByName('clave').AsString      := xclave;
  try
    cabasien.Post;
  except
    cabasien.Cancel;
  end;
  datosdb.closeDB(cabasien); cabasien.Open;
end;

procedure TTLDiario.Grabar(xperiodo, xnroasien, xcodcta, xnromovi, xfecha, xconcepto: string; ximporte: real);
// Objetivo...: Grabar atributos relacionados al movimiento de una cuenta
begin
  if xnromovi = '001' then
    if BuscarDet(xperiodo, xnroasien, xcodcta, '001') then begin
      BorrarCCostos(xperiodo, xnroasien, xcodcta);
      BorrarItems(xperiodo, xnroasien);
    end;
  if BuscarDet(xperiodo, xnroasien, xcodcta, xnromovi) then ccostos.Edit else ccostos.Append;
  ccostos.FieldByName('periodo').AsString   := xperiodo;
  ccostos.FieldByName('nroasien').AsString  := xnroasien;
  ccostos.FieldByName('codcta').AsString    := xcodcta;
  ccostos.FieldByName('fecha').AsString     := utiles.sExprFecha2000(xfecha);
  ccostos.FieldByName('concepto').AsString  := xconcepto;
  ccostos.FieldByName('nromovi').AsString   := xnromovi;
  ccostos.FieldByName('monto').AsFloat      := ximporte;
  try
    ccostos.Post;
  except
    ccostos.Cancel;
  end;
  datosdb.closeDB(ccostos); ccostos.Open;
end;

procedure TTLDiario.Borrar(xperiodo, xnroasien: string);
// Objetivo...: Borrar asiento - baja total
begin
  if Buscar(xperiodo, xnroasien) then begin
    cabasien.Delete;
    BorrarItems(xperiodo, xnroasien);
    nroasien := cabasien.FieldByName('nroasien').AsString;
    datosdb.closeDB(cabasien); cabasien.Open;
  end;
end;

procedure TTLDiario.Borrar(xperiodo, xnroasien, xclave: string);
// Objetivo...: Borrar asiento - baja total
var
  r: TQuery;
begin
  datosdb.tranSQL(path, 'DELETE FROM ' + asientos.TableName + ' WHERE periodo = ' + '''' + xperiodo + '''' + ' AND nroasien = ' + '''' + xnroasien + '''' + ' AND clave = ' + '''' + xclave + '''');
  r := datosdb.tranSQL(path, 'SELECT * FROM ' + asientos.TableName + ' WHERE periodo = ' + '''' + xperiodo + '''' + ' AND nroasien = ' + '''' + xnroasien + '''');
  r.Open;
  if r.RecordCount = 0 then
  datosdb.tranSQL(path, 'DELETE FROM ' + cabasien.TableName + ' WHERE periodo = ' + '''' + xperiodo + '''' + ' AND nroasien = ' + '''' + xnroasien + '''' + ' AND clave = ' + '''' + xclave + '''');
  r.Close; r.Free;
  datosdb.closeDB(asientos); asientos.Open;
  datosdb.closeDB(cabasien); cabasien.Open;
end;

procedure TTLDiario.BorrarItems(xperiodo, xnroasien: string);
// Objetivo...: Borrar asiento - cuentas
begin
  datosdb.tranSQL(asientos.DatabaseName, 'DELETE FROM ' + asientos.TableName + ' WHERE periodo = ' + '''' + xperiodo + '''' + ' AND nroasien = ' + '''' + xnroasien + '''');
  datosdb.closeDB(asientos); asientos.Open;
end;

procedure TTLDiario.BorrarItems(xperiodo, xnroasien, xclave: string);
// Objetivo...: Borrar asiento - cuentas - tenemos en cuenta la tabla; asientos.tablename => Necesitamos que el tratamiento sea polim�rfico
begin
  datosdb.tranSQL(asientos.DatabaseName, 'DELETE FROM ' + asientos.TableName + ' WHERE periodo = ' + '''' + xperiodo + '''' + ' AND nroasien = ' + '''' + xnroasien + '''' + ' AND clave = ' + '''' + xclave + '''');
  datosdb.closeDB(asientos); asientos.Open;
end;

procedure TTLDiario.BorrarCCostos(xperiodo, xnroasien, xcodcta: string);
// Objetivo...: Borrar detalle de movimientos de una cuenta
begin
  datosdb.tranSQL(path, 'DELETE FROM ccostos WHERE periodo = ' + '''' + xperiodo + '''' + ' AND nroasien = ' + '''' + xnroasien + '''' + ' AND codcta = ' + '''' + xcodcta + '''');
  datosdb.closeDB(ccostos); ccostos.Open;
end;

function TTLDiario.setItems(xperiodo, xnroasien: string): TQuery;
// Objetivo...: devolver un set con los registros del asiento
begin
  Result := datosdb.tranSQL(path, 'SELECT * FROM ' + asientos.TableName + ' WHERE periodo = ' + '''' + xperiodo + '''' + ' AND nroasien = ' + '''' + xnroasien + '''');
end;

function TTLDiario.setAsientos(xperiodo: string): TQuery;
// Objetivo...: devolver un set con los asientos de un per�odo, ordenados por fecha
begin
  Result := datosdb.tranSQL(path, 'SELECT * FROM ' + cabasien.TableName + ' WHERE periodo = ' + '"' + xperiodo + '"' + ' ORDER BY periodo, fecha');
end;

function TTLDiario.setItems(xperiodo, xnroasien, xcodcta: string): TQuery;
// Objetivo...: devolver un set con los registros del asiento
begin
  Result := datosdb.tranSQL(path, 'SELECT * FROM ' + ccostos.TableName + ' WHERE periodo = ' + '''' + xperiodo + '''' + ' AND nroasien = ' + '''' + xnroasien + '''' + ' AND codcta = ' + '''' + xcodcta + '''');
end;

function TTLDiario.setItems: TQuery;
// Objetivo...: devolver un set con los registros del asiento activo
begin
  Result := datosdb.tranSQL(path, 'SELECT * FROM ' + asientos.TableName + ' WHERE periodo = ' + '''' + cabasien.FieldByName('periodo').AsString + '''' + ' AND nroasien = ' + '''' + cabasien.FieldByName('nroasien').AsString + '''');
end;

function TTLDiario.setItemsLista: TStringList;
// Objetivo...: devolver una lista con los items del asiento
var
  indice: String;
  l: TStringList;
begin
  indice := asientos.IndexFieldNames;
  l      := TStringList.Create;
  if asientos.IndexFieldNames <> 'Periodo;Nroasien' then asientos.IndexFieldNames := 'Periodo;Nroasien';
  if datosdb.Buscar(asientos, 'periodo', 'nroasien', cabasien.FieldByName('periodo').AsString, cabasien.FieldByName('nroasien').AsString) then Begin
    while not asientos.Eof do Begin
      if (asientos.FieldByName('periodo').AsString <> cabasien.FieldByName('periodo').AsString) or (asientos.FieldByName('nroasien').AsString <> cabasien.FieldByName('nroasien').AsString) then Break;
      if asientos.FieldByName('dh').AsString = '1' then l.Add(asientos.FieldByName('codcta').AsString + asientos.FieldByName('dh').AsString + asientos.FieldByName('importe').AsString + ';1' + asientos.FieldByName('concepto').AsString);
      asientos.Next;
    end;
    datosdb.Buscar(asientos, 'periodo', 'nroasien', cabasien.FieldByName('periodo').AsString, cabasien.FieldByName('nroasien').AsString);
    while not asientos.Eof do Begin
      if (asientos.FieldByName('periodo').AsString <> cabasien.FieldByName('periodo').AsString) or (asientos.FieldByName('nroasien').AsString <> cabasien.FieldByName('nroasien').AsString) then Break;
      if asientos.FieldByName('dh').AsString = '2' then l.Add(asientos.FieldByName('codcta').AsString + asientos.FieldByName('dh').AsString + asientos.FieldByName('importe').AsString + ';1' + asientos.FieldByName('concepto').AsString);
      asientos.Next;
    end;
  end;
  asientos.IndexFieldNames := indice;
  Result := l;
end;

function TTLDiario.setAsientosAuditoria(xfecha: string): TQuery;
// Objetivo...: devolver un set con los registros del asiento
begin
  Result := datosdb.tranSQL(path, 'SELECT * FROM ' + cabasien.TableName + ' WHERE fecha = ' + '"' + xfecha + '"');
end;

function TTLDiario.setAsientosAuditoriaAutomaticos(xfecha: string): TQuery;
// Objetivo...: devolver un set con los registros del asiento
begin
  Result := datosdb.tranSQL(path, 'SELECT * FROM ' + cabasien.TableName + ' WHERE fecha = ' + '"' + xfecha + '"' + ' AND clave > ' + '"' + '"');
end;

procedure TTLDiario.getDatos(xperiodo, xnroasien: string);
// Objetivos...: Actualizar los atributos para un objeto dado
begin
  if Buscar(xperiodo, xnroasien) then begin
    periodo  := cabasien.FieldByName('periodo').AsString;
    nroasien := cabasien.FieldByName('nroasien').AsString;
    fecha    := utiles.sFormatoFecha(cabasien.FieldByName('fecha').AsString);
    observac := cabasien.FieldByName('observac').AsString;
    clave    := cabasien.FieldByName('clave').AsString;
    //setItems(xperiodo, xnroasien);
  end else begin
    periodo := ''; nroasien := ''; fecha := ''; observac := ''; clave := '';
  end;
end;

function TTLDiario.NuevoAsiento(xperiodo: String): string;
// Objetivo...: generar un nuevo n�mero de asiento
begin
  if not cabasien.Active then cabasien.Open;
  datosdb.Filtrar(cabasien, 'periodo = ' + '''' + xperiodo + '''');
  cabasien.Last;
  if Length(trim(cabasien.FieldByName('nroasien').AsString)) > 0 then
    Result := utiles.sLlenarIzquierda(IntToStr(cabasien.FieldByName('nroasien').AsInteger + 1), 4, '0')
  else
    Result := '1';
  //datosdb.QuitarFiltro(cabasien);
end;

procedure TTLDiario.Filtrar(xperiodo: String);
// Objetivo...: Filtrar los asientos del per�odo
begin
  datosdb.Filtrar(cabasien, 'periodo = ' + '''' + xperiodo + '''');
end;

function TTLDiario.verifCuenta(xcodcta: string): boolean;
// Objetivo...: Verificar si una cuenta se encuentra el alguno de los asientos
begin
  TSQL := datosdb.tranSQL(cabasien.DatabaseName, 'SELECT codcta FROM asientos WHERE codcta = ' + '''' + xcodcta + '''');
  TSQL.Open;
  if TSQL.RecordCount > 0 then Result := True else Result := False;
  TSQL.Close;
end;

procedure TTLDiario.CambiarCodCtas(xs, xp, actperiodo, codctaactual, codctaanterior: string);
// Objetivo...: Cambiar c�digo de cta. en los asientos
begin
  datosdb.tranSQL(cabasien.DatabaseName, 'UPDATE asientos SET codcta = ' + '''' + codctaactual + '''' + ' WHERE codcta = ' + '''' + codctaanterior + '''');
  datosdb.closeDB(asientos); asientos.Open;
end;

procedure TTLDiario.ListDiario(titulo, periodo: string; salida, ctrcostos: char; df, hf, dn, hn: string; tlist: char);
// Objetivo...: Gestionar emisi�n Libro Diario
var
  listok: boolean; i: string;
begin
  i := asientos.IndexFieldNames;
  asientos.IndexFieldNames := 'Periodo;Nroasien;DH;nromovi';
  if salida = 'T' then list.IniciarImpresionModoTexto;
  LineasPag := LineasPag;
  titulos(salida, titulo);
  idanterior := ''; totdebe  := 0; tothaber := 0;
  asientos.First;
  while not asientos.EOF do begin
    if list.SaltoPagina then begin
      Transporte(salida, 'Transporte ...:');
      list.IniciarNuevaPagina;
    end;

    listok := False;           // Manejador de filtro
    if tlist = '1' then        // Asientos por fecha
      if (asientos.FieldByName('fecha').AsString >= utiles.sExprFecha2000(df)) and (asientos.FieldByName('fecha').AsString <= utiles.sExprFecha2000(hf)) then listok := True;
    if tlist = '2' then        // Asientos por N� Asientos
      if (asientos.FieldByName('nroasien').AsString >= dn) and (asientos.FieldByName('nroasien').AsString <= hn) then listok := True;
    if tlist = '3' then        // Asientos automaticos
      if (asientos.FieldByName('periodo').AsString = df) and (Copy(asientos.FieldByName('clave').AsString, 3, 2) = hf) then listok := True;

    if listok then begin
      planctas.getDatos(asientos.FieldByName('codcta').AsString);
      if asientos.FieldByName('nroasien').AsString <> idanterior then IniciarNuevoAsiento(periodo, titulo, salida);

      if asientos.FieldByName('dh').AsString = '1' then Begin
        if (salida = 'P') or (salida = 'I') then List.Linea(0, 0, asientos.FieldByName('codcta').AsString + '  ' + planctas.Cuenta, 1, 'Arial, normal, 8', salida, 'N');
        if (salida = 'T') then List.LineaTxt(CHR15 + asientos.FieldByName('codcta').AsString + ' ' +  utiles.StringLongitudFija(planctas.Cuenta, 41), False);
      end;
      if asientos.FieldByName('dh').AsString = '2' then Begin
        if (salida = 'P') or (salida = 'I') then List.Linea(0, 0, asientos.FieldByName('codcta').AsString + '      ' + planctas.Cuenta, 1, 'Arial, normal, 8', salida, 'N');
        if (salida = 'T') then List.LineaTxt(CHR15 + asientos.FieldByName('codcta').AsString + '  ' + utiles.StringLongitudFija(planctas.Cuenta, 40), False);
      end;

      if asientos.FieldByName('dh').AsString = '1' then Begin
        if (salida = 'P') or (salida = 'I') then list.importe(55, list.lineactual, '', asientos.FieldByName('importe').AsFloat, 2, 'Arial, normal, 8');
        if (salida = 'T') then Begin
          list.importetxt(asientos.FieldByName('importe').AsFloat, 10, 2, False);
          List.LineaTxt('            ', False);
        end;
      end;

      if asientos.FieldByName('dh').AsString = '2' then Begin
        if (salida = 'P') or (salida = 'I') then list.importe(70, list.lineactual, '', asientos.FieldByName('importe').AsFloat, 3, 'Arial, normal, 8');
        if (salida = 'T') then list.importetxt(asientos.FieldByName('importe').AsFloat, 22, 2, False);
      end;

      if (salida = 'P') or (salida = 'I') then Begin
        if Length(Trim(asientos.FieldByName('concepto').AsString)) > 0 then list.Linea(80, list.lineactual, asientos.FieldByName('concepto').AsString, 4, 'Arial, fsBold, 8', salida, 'S');
        list.Linea(110, list.lineactual, '', 5, 'Arial, fsBold, 8', salida, 'S');
      end;
      if (salida = 'T') then Begin
        list.LineaTxt(' ' + asientos.FieldByName('concepto').AsString, True);
        Inc(lineas); if ControlarSalto then titulos(salida, titulo);
      end;

      if ctrcostos = 'S' then ListarItems(periodo, asientos.FieldByName('nroasien').AsString, asientos.FieldByName('codcta').AsString, salida);

      idanterior := asientos.FieldByName('nroasien').AsString;
      if asientos.FieldByName('dh').AsString = '1' then totdebe := totdebe + asientos.FieldByName('importe').AsFloat else tothaber := tothaber + asientos.FieldByName('importe').AsFloat;
    end;

    asientos.Next;
  end;

  Transporte(salida, 'Subtotales ...:');
  if (salida = 'P') or (salida = 'I') then Begin
    list.CompletarPagina;
    list.FinList;
  end;
  if salida = 'T' then list.FinalizarImpresionModoTexto(1);
  asientos.IndexFieldNames := i;
end;

procedure TTLDiario.titulos(salida: char; xtitulo: string);
{Objetivo...: Titulos del informe}
begin
  if (salida = 'P') or (salida = 'I') then Begin
    list.Setear(salida);
    ListarDatosEmpresa(salida);
    List.Titulo(0, 0, xtitulo, 1, 'Arial, negrita, 14');
    List.Titulo(0, 0, ' ', 1, 'Times New Roman, ninguno, 6');
    List.Titulo(0, 0, 'Fecha     C�digo          Cuenta', 1, 'Arial, cursiva, 8');
    List.Titulo(51, list.lineactual, 'Debe', 2, 'Arial, cursiva, 8');
    List.Titulo(65, list.lineactual, 'Haber', 3, 'Arial, cursiva, 8');
    List.Titulo(80, list.lineactual, 'Concepto Rengl�n', 4, 'Arial, cursiva, 8');
    List.Titulo(0, 0, list.linealargopagina(salida), 1, 'Arial, normal, 11');
    List.Titulo(0, 0, '  ', 1, 'Arial, negrita, 8');
  end;
  if (salida = 'T') then Begin
    ListarDatosEmpresa(salida);
    List.LineaTxt(xtitulo, True);
    List.LineaTxt('', True);
    List.LineaTxt(CHR15 + 'C�digo       Cuenta                                          Debe       Haber Concepto Rengl�n', True);
    list.LineaTxt(CHR18 + utiles.sLlenarIzquierda(lin, 80, Caracter) + CHR15, True);
    lineas := lineas + 4;
  end;
end;

procedure TTLDiario.Transporte(salida: char; ley: string);
{Objetivo...: Transporte del Asiento Contable}
var
  i: Integer;
begin
  if (salida = 'P') or (salida = 'I') then Begin
    if Copy(ley, 1, 3) <> 'Sub' then list.CompletarPagina;
    list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
    list.Linea(0, 0, ley, 1, 'Arial, negrita, 8', salida, 'N');
    list.importe(55, list.lineactual, '', totdebe, 2, 'Arial, negrita, 8');
    list.importe(70, list.lineactual, '', tothaber, 3, 'Arial, negrita, 8');
  end;
  if (salida = 'T') then Begin
    if lineas > LineasPag then RealizarSalto else
      for i := lineas to LineasPag - 2 do list.LineaTxt('', True);
    list.LineaTxt(CHR18 + utiles.sLlenarIzquierda(lin, 80, Caracter), True);
    list.LineaTxt(CHR15 + utiles.StringLongitudFija(ley, 50), False);
    list.importetxt(totdebe, 12, 2, False);
    list.importetxt(tothaber, 12, 2, True);
  end;
end;

procedure TTLDiario.IniciarNuevoAsiento(periodo, titulo: string; salida: char);
// Objetivo...: Gestionar la emisi�n de un nuevo asiento contable
begin
  if (totdebe + tothaber) > 0 then begin
    if (salida = 'P') or (salida = 'I') then Begin
      list.Linea(0, 0, list.linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
      list.Linea(0, 0, ' ', 1, 'Arial, normal, 7', salida, 'S');
    end;
    if (salida = 'T') then Begin
      list.LineaTxt(CHR18 + utiles.sLlenarIzquierda(lin, 80, Caracter), True);
      Inc(lineas); if ControlarSalto then titulos(salida, titulo);
    end;
  end;
  datosdb.Buscar(cabasien, 'periodo', 'nroasien', asientos.FieldByName('periodo').AsString, asientos.FieldByName('nroasien').AsString);
  if (salida = 'P') or (salida = 'I') then Begin
    list.Linea(0, 0, 'Asiento Nro: ' + utiles.sLlenarIzquierda(asientos.FieldByName('nroasien').AsString, 4, '0') + utiles.espacios(40) + 'Fecha: ' + utiles.sFormatoFecha(cabasien.FieldByName('fecha').AsString) + utiles.espacios(50) + 'Concepto: ' + cabasien.FieldByName('observac').AsString, 1, 'Arial, negrita, 8', salida, 'S');
    list.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');
  end;
  if (salida = 'T') then Begin
    list.LineaTxt('', True);
    Inc(lineas); if ControlarSalto then titulos(salida, titulo);
    list.LineaTxt(CHR15 + 'Asiento Nro: ' + utiles.sLlenarIzquierda(asientos.FieldByName('nroasien').AsString, 4, '0') + '   Fecha: ' + utiles.sFormatoFecha(cabasien.FieldByName('fecha').AsString) + '   Concepto: ' + Copy(cabasien.FieldByName('observac').AsString, 1, 60), True);
    Inc(lineas); if ControlarSalto then titulos(salida, titulo);
    list.LineaTxt('', True);
    Inc(lineas); if ControlarSalto then titulos(salida, titulo);
  end;
end;

procedure TTLDiario.ListarItems(periodo, asiento, codcta: string; salida: char);
// Objetivo...: Listar Centro de Costos de Cuentas
var
  t: TTable;
begin
  t := datosdb.Filtrar(ccostos, 'periodo = ' + '''' + periodo + '''' + ' and nroasien = ' + '''' + asiento + '''' + ' and codcta = ' + '''' + codcta + '''');
  t.Open; t.First;
  while not t.EOF do begin
    list.Linea(0, 0, utiles.espacios(12) + t.FieldByName('concepto').AsString, 1, 'Arial, normal, 7', salida, 'N');
    list.importe(45, list.lineactual, '', t.FieldByName('monto').AsFloat, 2, 'Arial, normal, 7');
    t.Next;
  end;
end;

procedure TTLDiario.Renumerar;
// Objetivo...: Renumerar Asientos Contables
var
  r: TQuery;
begin
  if per.VerificarPeriodoActivo then begin
    // Extraemos los asientos
    asientos.Filtered := False;
    r := datosdb.tranSQL(cabasien.DatabaseName, 'SELECT * FROM ' + cabasien.TableName + ' WHERE periodo = ' + '"' + per.periodo + '"' + ' ORDER BY fecha');
    r.Open; r.First;

    //Comenzamos a Chequear la Operaci�n
    nroas := 0;
    while not r.EOF do begin
      nroas := nroas + 1;
      nuevonroasiento    := utiles.sLLenarIzquierda(IntToStr(nroas), 6, '0');
      fec                := r.FieldByName('fecha').AsString;    //Recuperamos la Fecha
      claveas            := r.FieldByName('idasiento').AsString;

      if r.FieldByName('nroasien').AsString <> nuevonroasiento then begin
        nroasientoanterior := r.FieldByName('nroasien').AsString;
        datosDB.tranSQL(cabasien.DatabaseName, 'UPDATE cabasien SET nroasien = ' + '''' + nuevonroasiento + '''' + ' WHERE idasiento = ' + '''' + claveas + '''' + ' AND periodo = ' + '''' + r.FieldByName('periodo').AsString + '''');  // Cabecera
        datosDB.tranSQL(cabasien.DatabaseName, 'UPDATE asientos SET nroasien = ' + '''' + nuevonroasiento + '''' + ' WHERE idasiento = ' + '''' + r.FieldByName('idasiento').AsString + '''' + ' AND periodo = ' + '"' + r.FieldByName('periodo').AsString + '"'); // Movimientos
        Inc(asientosrenumerados);
      end;
      r.Next;
    end;
    r.Close; r.Free;
  end;
  datosdb.closeDB(asientos); asientos.Open;
  datosdb.closeDB(cabasien); cabasien.Open;
end;

function TTLDiario.CantidadAsientosRenumerados: integer;
begin
  Result := asientosrenumerados;
end;

procedure TTLDiario.MarcarAsientoAutomatico(xperiodo, xnroasien, xid: String);
// Objetivo...: Marcar Asiento Automatico
Begin
  if Buscar(xperiodo, xnroasien) then Begin
    cabasien.Edit;
    cabasien.FieldByName('clave').AsString := xid;
    try
      cabasien.Post
     except
      cabasien.Cancel
    end;
    datosdb.closeDB(cabasien); cabasien.Open;
  end;
end;

procedure TTLDiario.BorrarAsientoAutomatico(xperiodo, xid: String);
// Objetivo...: Borrar Automatico
var
  r: TQuery;
Begin
  r := datosdb.tranSQL(cabasien.DatabaseName, 'select nroasien from cabasien where periodo = ' + '''' + xperiodo + '''' + ' and clave = ' + '''' + xid + '''');
  r.Open;
  if r.RecordCount > 0 then Begin
    datosdb.tranSQL(asientos.DatabaseName, 'delete from asientos where periodo = ' + '''' + xperiodo + '''' + ' and nroasien = ' + '''' + r.FieldByName('nroasien').AsString + '''');
    datosdb.closeDB(asientos); asientos.Open;
    datosdb.tranSQL(cabasien.DatabaseName, 'delete from cabasien where periodo = ' + '''' + xperiodo + '''' + ' and nroasien = ' + '''' + r.FieldByName('nroasien').AsString + '''');
    datosdb.closeDB(cabasien); cabasien.Open;
  end;
  r.Close; r.Free;
end;

function TTLDiario.verificarAsientoRefundicionCuentasResultado(xperiodo: String): Boolean;
// Objetivo...: Verificar si se refundieron las cuentas de resultado
var
  r: TQuery;
Begin
  r := datosdb.tranSQL(cabasien.DatabaseName, 'select nroasien from cabasien where periodo = ' + '''' + xperiodo + '''' + ' and clave = ' + '''' + 'A' + '''');
  r.Open;
  if r.RecordCount > 0 then Result := True else Result := False;
  r.Close; r.Free;
end;

function TTLDiario.verificarAsientoRefundicionCuentasPatrimoniales(xperiodo: String): Boolean;
// Objetivo...: Verificar si se refundieron las cuentas patrimoniales
var
  r: TQuery;
Begin
  r := datosdb.tranSQL(cabasien.DatabaseName, 'select nroasien from cabasien where periodo = ' + '''' + xperiodo + '''' + ' and clave = ' + '''' + 'B' + '''');
  r.Open;
  if r.RecordCount > 0 then Result := True else Result := False;
  r.Close; r.Free;
end;

function TTLDiario.verificarAsientoApertura(xperiodo: String): Boolean;
// Objetivo...: Verificar si se refundieron las cuentas patrimoniales
var
  r: TQuery;
Begin
  r := datosdb.tranSQL(cabasien.DatabaseName, 'select nroasien from cabasien where periodo = ' + '''' + xperiodo + '''' + ' and clave = ' + '''' + 'C' + '''');
  r.Open;
  if r.RecordCount > 0 then Result := True else Result := False;
  r.Close; r.Free;
end;

function TTLDiario.setAsientosFecha(xdfecha, xhfecha: String): TStringList;
// Objetivo...: Devolver un set con los asientos
var
  l: TStringList;
Begin
  l := TStringList.Create;
  datosdb.Filtrar(cabasien, 'fecha >= ' + '''' + utiles.sExprFecha2000(xdfecha) + '''' + ' and fecha <= ' + '''' + utiles.sExprFecha2000(xhfecha) + '''');
  cabasien.First;
  while not cabasien.Eof do Begin
    l.Add(cabasien.FieldByName('nroasien').AsString + utiles.sFormatoFecha(cabasien.FieldByName('fecha').AsString) + cabasien.FieldByName('observac').AsString);
    cabasien.Next;
  end;
  Result := l;
  datosdb.QuitarFiltro(cabasien);
end;

procedure TTLDiario.ExportarAsientos(xperiodo: String; lista: TStringList; xdrive: char);
// Objetivo...: Exportar Asientos
var
  i: Integer;
  cabasienexport, asientosexport: TTable;
Begin
  utilesarchivos.CopiarArchivos(dbs.DirSistema + '\work\cont', '*.*', dbs.DirSistema + '\export\cont');
  cabasienexport := datosdb.openDB('cabasien', '', '', dbs.DirSistema + '\export\cont');
  asientosexport := datosdb.openDB('asientos', '', '', dbs.DirSistema + '\export\cont');
  cabasienexport.Open;
  asientosexport.Open;

  cabasienexport.IndexFieldNames := 'Periodo;Nroasien';
  For i := 1 to lista.Count do Begin
    if Buscar(xperiodo, lista.Strings[i-1]) then Begin
      if datosdb.Buscar(cabasienexport, 'periodo', 'nroasien', xperiodo, lista.Strings[i-1]) then cabasienexport.Edit else cabasienexport.Append;
      cabasienexport.FieldByName('periodo').AsString   := xperiodo;
      cabasienexport.FieldByName('nroasien').AsString  := lista.Strings[i-1];
      cabasienexport.FieldByName('idasiento').AsString := cabasien.FieldByName('idasiento').AsString;
      cabasienexport.FieldByName('fecha').AsString     := cabasien.FieldByName('fecha').AsString;
      cabasienexport.FieldByName('observac').AsString  := cabasien.FieldByName('observac').AsString;
      cabasienexport.FieldByName('clave').AsString     := cabasien.FieldByName('clave').AsString;
      try
        cabasienexport.Post
       except
        cabasienexport.Cancel
      end;

      asientosexport.IndexFieldNames := 'Periodo;Nroasien;Nromovi;Idasiento';
      datosdb.Filtrar(asientos, 'periodo = ' + '''' + xperiodo + '''' + ' and nroasien = ' + '''' + lista.Strings[i-1] + '''');
      asientos.First;
      while not asientos.Eof do Begin
        if datosdb.Buscar(asientosexport, 'Periodo', 'Nroasien', 'Nromovi', 'Idasiento', asientos.FieldByName('periodo').AsString, asientos.FieldByName('nroasien').AsString,
           asientos.FieldByName('nromovi').AsString, asientos.FieldByName('idasiento').AsString) then asientosexport.Edit else asientosexport.Append;
        asientosexport.FieldByName('periodo').AsString   := asientos.FieldByName('periodo').AsString;
        asientosexport.FieldByName('nroasien').AsString  := asientos.FieldByName('nroasien').AsString;
        asientosexport.FieldByName('nromovi').AsString   := asientos.FieldByName('nromovi').AsString;
        asientosexport.FieldByName('idasiento').AsString := asientos.FieldByName('idasiento').AsString;
        asientosexport.FieldByName('fecha').AsString     := asientos.FieldByName('fecha').AsString;
        asientosexport.FieldByName('codcta').AsString    := asientos.FieldByName('codcta').AsString;
        asientosexport.FieldByName('dh').AsString        := asientos.FieldByName('dh').AsString;
        asientosexport.FieldByName('importe').AsString   := asientos.FieldByName('importe').AsString;
        asientosexport.FieldByName('concepto').AsString  := asientos.FieldByName('concepto').AsString;
        asientosexport.FieldByName('clave').AsString     := asientos.FieldByName('clave').AsString;
        asientosexport.FieldByName('senial').AsString    := asientos.FieldByName('senial').AsString;
        try
          asientosexport.Post
         except
          asientosexport.Cancel
        end;
        asientos.Next;
      end;
      datosdb.QuitarFiltro(asientos);
    end;
  end;

  datosdb.closeDB(cabasienexport);
  datosdb.closeDB(asientosexport);

  utilesarchivos.BorrarArchivo(dbs.DirSistema + '\export\attach\contexport.bck');
  utilesarchivos.CompactarArchivos(dbs.DirSistema + '\export\cont\*.*', dbs.dirSistema + '\export\attach\contexport.bck');

  if xdrive <> 'z' then utilesarchivos.CopiarArchivos(dbs.DirSistema + '\export\attach', '*.bck', xdrive + ':');
end;

function TTLDiario.TransferirAsientos(xperiodo: String; xdrive: String): TStringList;
// Objetivo...: Transferir Asientos
var
  cabasienexport: TTable;
  lista: TStringList;
Begin
  utilesarchivos.BorrarArchivos(dbs.DirSistema + '\import\cont', '*.*');
  utilesarchivos.CopiarArchivos(xdrive + ':', '*.bck', dbs.DirSistema + '\import\cont');
  utilesarchivos.DescompactarArchivos(dbs.DirSistema + '\import\cont\contexport.bck', dbs.DirSistema + '\import\cont');

  cabasienexport := datosdb.openDB('cabasien', '', '', dbs.DirSistema + '\import\cont\');

  lista := TStringList.Create;
  cabasienexport.Open;
  while not cabasienexport.Eof do Begin
    lista.Add(cabasienexport.FieldByName('nroasien').AsString + utiles.sFormatoFecha(cabasienexport.FieldByName('fecha').AsString) + cabasienexport.FieldByName('observac').AsString);
    cabasienexport.Next;
  end;
  datosdb.closeDB(cabasienexport);

  Result := lista;
end;

procedure TTLDiario.ImportarAsientos(xperiodo: String; lista: TStringList; xsobreescribir: Boolean);
var
  cabasienexport, asientosexport: TTable;
  it: String;
Begin
  cabasienexport := datosdb.openDB('cabasien', '', '', dbs.DirSistema + '\import\cont\');
  asientosexport := datosdb.openDB('asientos', '', '', dbs.DirSistema + '\import\cont\');
  cabasienexport.Open;
  asientosexport.Open;

  cabasienexport.Open;
  while not cabasienexport.Eof do Begin
    if utiles.verificarItemsLista(lista, cabasienexport.FieldByName('nroasien').AsString) then Begin

      if xsobreescribir then Begin   // Si Borra primero sobreescribimos
        datosdb.tranSQL(path, 'delete from cabasien where periodo = ' + '''' + xperiodo + '''' + ' and nroasien = ' + '''' + cabasienexport.FieldByName('nroasien').AsString + '''');
        datosdb.tranSQL(path, 'delete from asientos where periodo = ' + '''' + xperiodo + '''' + ' and nroasien = ' + '''' + cabasienexport.FieldByName('nroasien').AsString + '''');
      end;

      if Buscar(cabasienexport.FieldByName('periodo').AsString, cabasienexport.FieldByName('nroasien').AsString) then cabasien.Edit else cabasien.Append;
      cabasien.FieldByName('periodo').AsString   := cabasienexport.FieldByName('periodo').AsString;
      cabasien.FieldByName('nroasien').AsString  := cabasienexport.FieldByName('nroasien').AsString;
      cabasien.FieldByName('idasiento').AsString := cabasienexport.FieldByName('idasiento').AsString;
      cabasien.FieldByName('fecha').AsString     := cabasienexport.FieldByName('fecha').AsString;
      cabasien.FieldByName('observac').AsString  := cabasienexport.FieldByName('observac').AsString;
      cabasien.FieldByName('clave').AsString     := cabasienexport.FieldByName('clave').AsString;
      try
        cabasien.Post
       except
        cabasien.Cancel
      end;

      asientos.IndexFieldNames := 'Periodo;Nroasien;Nromovi;Idasiento';
      datosdb.Filtrar(asientosexport, 'nroasien = ' + '''' + cabasienexport.FieldByName('nroasien').AsString + '''');
      asientosexport.First;
      while not asientosexport.Eof do Begin
        if datosdb.Buscar(asientos, 'Periodo', 'Nroasien', 'Nromovi', 'Idasiento', asientosexport.FieldByName('periodo').AsString, asientosexport.FieldByName('nroasien').AsString,
          asientosexport.FieldByName('nromovi').AsString, asientosexport.FieldByName('idasiento').AsString) then asientos.Edit else asientos.Append;
        asientos.FieldByName('periodo').AsString   := asientosexport.FieldByName('periodo').AsString;
        asientos.FieldByName('nroasien').AsString  := asientosexport.FieldByName('nroasien').AsString;
        asientos.FieldByName('nromovi').AsString   := asientosexport.FieldByName('nromovi').AsString;
        asientos.FieldByName('idasiento').AsString := asientosexport.FieldByName('idasiento').AsString;
        asientos.FieldByName('fecha').AsString     := asientosexport.FieldByName('fecha').AsString;
        asientos.FieldByName('codcta').AsString    := asientosexport.FieldByName('codcta').AsString;
        asientos.FieldByName('dh').AsString        := asientosexport.FieldByName('dh').AsString;
        asientos.FieldByName('importe').AsString   := asientosexport.FieldByName('importe').AsString;
        asientos.FieldByName('concepto').AsString  := asientosexport.FieldByName('concepto').AsString;
        asientos.FieldByName('clave').AsString     := asientosexport.FieldByName('clave').AsString;
        asientos.FieldByName('senial').AsString    := asientosexport.FieldByName('senial').AsString;
        try
          asientos.Post
         except
          asientos.Cancel
        end;
        it := asientosexport.FieldByName('nromovi').AsString;
        asientosexport.Next;
      end;

      datosdb.tranSQL(path, 'delete from asientos where periodo = ' + '''' + xperiodo + '''' + ' and nroasien = ' + '''' + cabasienexport.FieldByName('nroasien').AsString + '''' + ' and nromovi > ' + '''' + it + '''');
      datosdb.QuitarFiltro(asientosexport);

    end;

    cabasienexport.Next;
  end;
  datosdb.closeDB(cabasienexport);
  datosdb.closeDB(asientosexport);
end;

function TTLDiario.ControlarSalto: boolean;
// Objetivo...: salto de linea para las impresiones basadas en texto
var
  k: Integer;
begin
  Result := False;
  if lineas >= LineasPag - 2 then Begin
    Transporte('T', 'Transporte:');
    if lineas_blanco = 0 then list.LineaTxt(CHR(12), True) else
      for k := 1 to lineas_blanco do list.LineaTxt('', True);
    Result := True;
  end;
end;

{===============================================================================}

function ldiario: TTLDiario;
begin
  if xldiario = nil then
    xldiario := TTLDiario.Create;
  Result := xldiario;
end;

{===============================================================================}

initialization

finalization
  xldiario.Free;

end.
