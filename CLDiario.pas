unit CLDiario;

interface

uses CRegCont, CPlanctas, SysUtils, CListar, DB, DBTables, CBDT, CUtiles, CIDBFM, CPeriodo;

type

TTLDiario = class(TTRegCont)
  periodo, nroasien, fecha, observac, clave, path: string;  // Cabecera
  nromovi, codcta, concepto, dh, cuenta: string;
  importe: real;
 public
  { Declaraciones Públicas }
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

  procedure   ListDiario(titulo, periodo: string; salida, ctrcostos: char; df, hf, dn, hn: string; tlist: char);
  procedure   Renumerar;
  procedure   CambiarCodCtas(xs, xp, actperiodo, codctaactual, codctaanterior: string);
  function    NuevoAsiento: string;
  function    CantidadAsientosRenumerados: integer;
 private
  { Declaraciones Privadas }
  nroasientoanterior, nuevonroasiento, fec, claveas, claveasiento: string;
  nroas, asientosrenumerados: integer;

  procedure   ListarItems(periodo, asiento, codcta: string; salida: char);
  procedure   Transporte(salida: char; ley: string);
  procedure   IniciarNuevoAsiento(periodo: string; salida: char);
  procedure   titulos(salida: char; xtitulo: string);
  procedure   BorrarCCostos(xperiodo, xnroasien, xcodcta: string); overload;
 protected
  { Declaraciones Protegidas }
   procedure  BorrarItems(xperiodo, xnroasien: string); overload;
   procedure  BorrarItems(xperiodo, xnroasien, xclave: string); overload;
end;

function ldiario: TTLDiario;

implementation

var
  xldiario: TTLDiario = nil;

constructor TTLDiario.Create;
begin
  inherited Create;
  path     := dbs.DirSistema + '\cont';
  cabasien := datosdb.openDB('cabasien', 'Periodo;Nroasien', '', path);
  asientos := datosdb.openDB('asientos', '', 'Idasiento', '', path);
  ccostos  := datosdb.openDB('ccostos', 'Periodo;Nroasien;Codcta;Nromovi', '', path);
end;

destructor TTLDiario.Destroy;
begin
  inherited Destroy;
end;

function TTLDiario.Buscar(xperiodo, xnroasien: string): boolean;
// Objetivo...: Buscar el Objeto solicitado
begin
  Result := datosdb.Buscar(cabasien, 'periodo', 'nroasien', xperiodo, xnroasien);
end;

function TTLDiario.Buscar(xperiodo, xnroasien, xnromovi, xcodcta: string): boolean;
// Objetivo...: Buscar el Objeto solicitado
begin
  if asientos.IndexName <> 'Idasiento' then asientos.IndexName := 'Idasiento';
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
  if Buscar(xperiodo, xnroasien) then
    begin
      claveasiento := cabasien.FieldByName('cl_asiento').AsString;
      cabasien.Edit;
      BorrarItems(xperiodo, xnroasien);
    end
  else Begin
    cabasien.Append;
    claveasiento := utiles.idregistro;
  end;
  cabasien.FieldByName('periodo').AsString    := xperiodo;
  cabasien.FieldByName('nroasien').AsString   := xnroasien;
  cabasien.FieldByName('cl_asiento').AsString := claveasiento;    /////utiles.idregistro;
  cabasien.FieldByName('fecha').AsString      := utiles.sExprFecha(xfecha);
  cabasien.FieldByName('observac').AsString   := xobservac;
  try
    cabasien.Post;
  except
    cabasien.Cancel;
  end;
end;

procedure TTLDiario.Grabar(xperiodo, xnroasien, xfecha, xcodcta, xnromovi, xconcepto, xdh: string; ximporte: real);
// Objetivo...: Grabar Atributos del Objeto - cuentas de asientos
begin
  if Buscar(xperiodo, xnroasien, xnromovi, xcodcta) then asientos.Edit else asientos.Append;
  asientos.FieldByName('periodo').AsString    := xperiodo;
  asientos.FieldByName('cl_asiento').AsString := xdh + Copy(utiles.idregistro, 1, 9);
  asientos.FieldByName('codcta').AsString     := xcodcta;
  asientos.FieldByName('nroasien').AsString   := xnroasien;
  asientos.FieldByName('fecha').AsString      := utiles.sExprFecha(xfecha);
  asientos.FieldByName('concepto').AsString   := xconcepto;
  asientos.FieldByName('nromovi').AsString    := xnromovi;
  asientos.FieldByName('dh').AsString         := xdh;
  asientos.FieldByName('importe').AsFloat     := ximporte;
  asientos.FieldByName('idasiento').AsString  := claveasiento;   ////cabasien.FieldByName('cl_asiento').AsString;
  try
    asientos.Post;
  except
    asientos.Cancel;
  end;
end;

procedure  TTLDiario.Grabar(xperiodo, xnroasien, xfecha, xcodcta, xnromovi, xconcepto, xdh, xclave: string; ximporte: real);
// Objetivo...: Grabar atributos relacionados al movimiento de una cuenta - incluyendo clave de asientos generados automáticamente
begin
  Grabar(xperiodo, xnroasien, xfecha, xcodcta, xnromovi, xconcepto, xdh, ximporte);
  asientos.Edit;
  asientos.FieldByName('clave').AsString := xclave;
  try
    asientos.Post;
  except
    asientos.Cancel;
  end;
end;

procedure  TTLDiario.Grabar(xperiodo, xnroasien, xfecha, xobservac, xclave: string);
// Objetivo...: Grabar atributos relacionados al movimiento de una cuenta - incluyendo clave de asientos generados automáticamente
begin
  if Buscar(xperiodo, xnroasien) then
    begin
      claveasiento := cabasien.FieldByName('cl_asiento').AsString;
      cabasien.Edit;
      BorrarItems(xperiodo, xnroasien, xclave);
    end
  else Begin
    cabasien.Append;
    claveasiento := utiles.idregistro;
  end;
  cabasien.FieldByName('periodo').AsString    := xperiodo;
  cabasien.FieldByName('nroasien').AsString   := xnroasien;
  cabasien.FieldByName('cl_asiento').AsString := claveasiento;
  cabasien.FieldByName('fecha').AsString      := utiles.sExprFecha(xfecha);
  cabasien.FieldByName('observac').AsString   := xobservac;
  cabasien.FieldByName('clave').AsString      := xclave;
  try
    cabasien.Post;
  except
    cabasien.Cancel;
  end;
end;

procedure TTLDiario.Grabar(xperiodo, xnroasien, xcodcta, xnromovi, xfecha, xconcepto: string; ximporte: real);
// Objetivo...: Grabar atributos relacionados al movimiento de una cuenta
begin
  if xnromovi = '001' then
    if BuscarDet(xperiodo, xnroasien, xcodcta, '001') then
      begin
        BorrarCCostos(xperiodo, xnroasien, xcodcta);
        BorrarItems(xperiodo, xnroasien);
      end;
  if BuscarDet(xperiodo, xnroasien, xcodcta, xnromovi) then ccostos.Edit else ccostos.Append;
  ccostos.FieldByName('periodo').AsString   := xperiodo;
  ccostos.FieldByName('nroasien').AsString  := xnroasien;
  ccostos.FieldByName('codcta').AsString    := xcodcta;
  ccostos.FieldByName('fecha').AsString     := utiles.sExprFecha(xfecha);
  ccostos.FieldByName('concepto').AsString  := xconcepto;
  ccostos.FieldByName('nromovi').AsString   := xnromovi;
  ccostos.FieldByName('monto').AsFloat      := ximporte;
  try
    ccostos.Post;
  except
    ccostos.Cancel;
  end;
end;

procedure TTLDiario.Borrar(xperiodo, xnroasien: string);
// Objetivo...: Borrar asiento - baja total
begin
  if Buscar(xperiodo, xnroasien) then
    begin
      cabasien.Delete;
      BorrarItems(xperiodo, xnroasien);
      nroasien := cabasien.FieldByName('nroasien').AsString;
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
end;

procedure TTLDiario.BorrarItems(xperiodo, xnroasien: string);
// Objetivo...: Borrar asiento - cuentas
begin
  datosdb.tranSQL(path, 'DELETE FROM asientos WHERE periodo = ' + '''' + xperiodo + '''' + ' AND nroasien = ' + '''' + xnroasien + '''');
end;

procedure TTLDiario.BorrarItems(xperiodo, xnroasien, xclave: string);
// Objetivo...: Borrar asiento - cuentas - tenemos en cuenta la tabla; asientos.tablename => Necesitamos que el tratamiento sea polimórfico
begin
  datosdb.tranSQL(path, 'DELETE FROM ' + asientos.TableName + ' WHERE periodo = ' + '''' + xperiodo + '''' + ' AND nroasien = ' + '''' + xnroasien + '''' + ' AND clave = ' + '''' + xclave + '''');
end;

procedure TTLDiario.BorrarCCostos(xperiodo, xnroasien, xcodcta: string);
// Objetivo...: Borrar detalle de movimientos de una cuenta
begin
  datosdb.tranSQL(path, 'DELETE FROM ccostos WHERE periodo = ' + '''' + xperiodo + '''' + ' AND nroasien = ' + '''' + xnroasien + '''' + ' AND codcta = ' + '''' + xcodcta + '''');
end;

function TTLDiario.setItems(xperiodo, xnroasien: string): TQuery;
// Objetivo...: devolver un set con los registros del asiento
begin
  Result := datosdb.tranSQL(path, 'SELECT * FROM ' + asientos.TableName + ' WHERE periodo = ' + '''' + xperiodo + '''' + ' AND nroasien = ' + '''' + xnroasien + '''');
end;

function TTLDiario.setAsientos(xperiodo: string): TQuery;
// Objetivo...: devolver un set con los asientos de un período, ordenados por fecha
begin
  Result := datosdb.tranSQL(path, 'SELECT * FROM ' + cabasien.TableName + ' WHERE periodo = ' + '"' + xperiodo + '"' + ' ORDER BY fecha');
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
  if Buscar(xperiodo, xnroasien) then
    begin
      periodo  := cabasien.FieldByName('periodo').AsString;
      nroasien := cabasien.FieldByName('nroasien').AsString;
      fecha    := utiles.sFormatoFecha(cabasien.FieldByName('fecha').AsString);
      observac := cabasien.FieldByName('observac').AsString;
      clave    := cabasien.FieldByName('clave').AsString;
      setItems(xperiodo, xnroasien);
    end
  else
    begin
      periodo := ''; nroasien := ''; fecha := ''; observac := ''; clave := '';
    end;
end;

function TTLDiario.NuevoAsiento: string;
// Objetivo...: generar un nuevo número de asiento
begin
  if not cabasien.Active then cabasien.Open;
  cabasien.Last;
  if Length(trim(cabasien.FieldByName('nroasien').AsString)) > 0 then
    Result := utiles.sLlenarIzquierda(IntToStr(cabasien.FieldByName('nroasien').AsInteger + 1), 4, '0')
  else
    Result := '0001';
end;

function TTLDiario.verifCuenta(xcodcta: string): boolean;
// Objetivo...: Verificar si una cuenta se encuentra el alguno de los asientos
begin
  TSQL := datosdb.tranSQL(path, 'SELECT * FROM asientos WHERE codcta = ' + '''' + xcodcta + '''');
  TSQL.Open;
  if TSQL.RecordCount > 0 then Result := True else Result := False;
  TSQL.Close;
end;

procedure TTLDiario.CambiarCodCtas(xs, xp, actperiodo, codctaactual, codctaanterior: string);
// Objetivo...: Cambiar código de cta. en los asientos
begin
  datosdb.tranSQL(path, 'UPDATE asientos SET codcta = ' + '''' + codctaactual + '''' + ' WHERE codcta = ' + '''' + codctaanterior + '''');
end;

procedure TTLDiario.ListDiario(titulo, periodo: string; salida, ctrcostos: char; df, hf, dn, hn: string; tlist: char);
// Objetivo...: Gestionar emisión Libro Diario
var
  listok: boolean; i: string;
begin
  i := asientos.IndexFieldNames;
  asientos.IndexName := 'Listdiario';
  ////ListDatosEmpresa(salida);
  titulos(salida, titulo);
  idanterior := ''; totdebe  := 0; tothaber := 0;
  asientos.First;
  while not asientos.EOF do
    begin
     if list.SaltoPagina then
       begin
         Transporte(salida, 'Transporte ...:');
         list.IniciarNuevaPagina;
       end;

      listok := False;           // Manejador de filtro
      if tlist = '1' then        // Asientos por fecha
        if (asientos.FieldByName('fecha').AsString >= utiles.sExprFecha(df)) and (asientos.FieldByName('fecha').AsString <= utiles.sExprFecha(hf)) then listok := True;
      if tlist = '2' then        // Asientos por Nº Asientos
        if (asientos.FieldByName('nroasien').AsString >= dn) and (asientos.FieldByName('nroasien').AsString <= hn) then listok := True;
      if tlist = '3' then        // Asientos automaticos
        if (asientos.FieldByName('periodo').AsString = df) and (Copy(asientos.FieldByName('clave').AsString, 3, 2) = hf) then listok := True;

      if listok then
        begin
          planctas.getDatos(asientos.FieldByName('codcta').AsString);
          if asientos.FieldByName('nroasien').AsString <> idanterior then IniciarNuevoAsiento(periodo, salida);
          if asientos.FieldByName('dh').AsString = '1' then List.Linea(0, 0, asientos.FieldByName('codcta').AsString + '  ' + planctas.Cuenta, 1, 'Arial, normal, 8', salida, 'N') else List.Linea(0, 0, asientos.FieldByName('codcta').AsString + '      ' + planctas.Cuenta, 1, 'Arial, normal, 8', salida, 'N');

          if asientos.FieldByName('dh').AsString = '1' then list.importe(55, list.lineactual, '', asientos.FieldByName('importe').AsFloat, 2, 'Arial, normal, 8') else list.importe(70, list.lineactual, '', asientos.FieldByName('importe').AsFloat, 3, 'Arial, normal, 8');
          if Length(Trim(asientos.FieldByName('concepto').AsString)) > 0 then list.Linea(80, list.lineactual, asientos.FieldByName('concepto').AsString, 4, 'Arial, fsBold, 8', salida, 'S');
          list.Linea(100, list.lineactual, ' ', 5, 'Arial, fsBold, 8', salida, 'S');

          if ctrcostos = 'S' then ListarItems(periodo, asientos.FieldByName('nroasien').AsString, asientos.FieldByName('codcta').AsString, salida);

          idanterior := asientos.FieldByName('nroasien').AsString;
          if asientos.FieldByName('dh').AsString = '1' then totdebe := totdebe + asientos.FieldByName('importe').AsFloat else tothaber := tothaber + asientos.FieldByName('importe').AsFloat;
        end;

      asientos.Next;
    end;

  Transporte(salida, 'Subtotlaes ...:');
  list.FinList;
  asientos.IndexFieldNames := i;
end;

procedure TTLDiario.titulos(salida: char; xtitulo: string);
{Objetivo...: Titulos del informe}
begin
  IniciarInforme(salida);
  List.Titulo(0, 0, xtitulo, 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Times New Roman, ninguno, 6');
  List.Titulo(0, 0, 'Fecha     Código          Cuenta', 1, 'Arial, cursiva, 8');
  List.Titulo(51, list.lineactual, 'Debe', 2, 'Arial, cursiva, 8');
  List.Titulo(65, list.lineactual, 'Haber', 3, 'Arial, cursiva, 8');
  List.Titulo(80, list.lineactual, 'Concepto Renglón', 4, 'Arial, cursiva, 8');
  List.Titulo(0, 0, list.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, '  ', 1, 'Arial, negrita, 8');
end;

procedure TTLDiario.Transporte(salida: char; ley: string);
{Objetivo...: Transporte del Asiento Contable}
begin
   list.CompletarPagina;
   list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
   list.Linea(0, 0, utiles.espacios(20) + ley, 1, 'Arial, cursiva, 8', salida, 'N');
   list.importe(55, list.lineactual, '', totdebe, 2, 'Arial, negrita, 8');
   list.importe(70, list.lineactual, '', tothaber, 3, 'Arial, negrita, 8');
end;

procedure TTLDiario.IniciarNuevoAsiento(periodo: string; salida: char);
// Objetivo...: Gestionar la emisión de un nuevo asiento contable
begin
  if (totdebe + tothaber) > 0 then
    begin
      list.Linea(0, 0, list.linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
      list.Linea(0, 0, ' ', 1, 'Arial, normal, 7', salida, 'S');
    end;
  datosdb.Buscar(cabasien, 'periodo', 'nroasien', asientos.FieldByName('periodo').AsString, asientos.FieldByName('nroasien').AsString);
  list.Linea(0, 0, 'Asiento Nro: ' + utiles.sLlenarIzquierda(asientos.FieldByName('nroasien').AsString, 4, '0') + utiles.espacios(40) + 'Fecha: ' + utiles.sFormatoFecha(cabasien.FieldByName('fecha').AsString) + utiles.espacios(50) + 'Concepto: ' + cabasien.FieldByName('observac').AsString, 1, 'Arial, negrita, 8', salida, 'S');
  list.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');
end;

procedure TTLDiario.ListarItems(periodo, asiento, codcta: string; salida: char);
// Objetivo...: Listar Centro de Costos de Cuentas
var
  t: TTable;
begin
  t := datosdb.Filtrar(ccostos, 'periodo = ' + '''' + periodo + '''' + ' and nroasien = ' + '''' + asiento + '''' + ' and codcta = ' + '''' + codcta + '''');
  t.Open; t.First;
  while not t.EOF do
    begin
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
  if per.VerificarPeriodoActivo then
    begin
      // Extraemos los asientos
      asientos.Filtered := False;
      r := setAsientos(per.periodo);
      r.Open; r.First;

      //Comenzamos a Chequear la Operación
      nroas := 0;
      while not r.EOF do
        begin
          nroas := nroas + 1;
          nuevonroasiento    := utiles.sLLenarIzquierda(IntToStr(nroas), 4, '0');
          fec                := r.FieldByName('fecha').AsString;    //Recuperamos la Fecha
          claveas            := r.FieldByName('clave').AsString;

          if r.FieldByName('nroasien').AsString <> nuevonroasiento then
            begin
              nroasientoanterior := r.FieldByName('nroasien').AsString;
              datosDB.tranSQL(path, 'UPDATE cabasien SET nroasien = ' + '"' + nuevonroasiento + '"' + ' WHERE nroasien = ' + '"' + nroasientoanterior + '"' + ' AND clave = ' + '"' + claveas + '"');  // Cabecera
              datosDB.tranSQL(path, 'UPDATE asientos SET nroasien = ' + '"' + nuevonroasiento + '"' + ' WHERE idasiento = ' + '"' + r.FieldByName('cl_asiento').AsString + '"' + ' AND periodo = ' + '"' + r.FieldByName('periodo').AsString + '"'); // Movimientos
              Inc(asientosrenumerados);
            end;
          r.Next;
        end;

    r.Close; r.Free;
  end;
end;

function TTLDiario.CantidadAsientosRenumerados: integer;
begin
  Result := asientosrenumerados;
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
