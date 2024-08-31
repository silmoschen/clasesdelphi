unit CFondoG;

interface

uses CSocTit, CSocAdherente, CConceAAR, SysUtils, DB, DBTables, CBDT, CIDBFM, CListar, CUtiles;

type

TTFondoGenuinos = class(TObject)            // Superclase
  codsocio, perit, fecha , concepto, tipomovi, codoper: string;
  importe: real;
  tabla: TTable;
 public
  { Declaraciones Públicas }
  constructor Create(xcodsocio, xperit, xfecha, xconcepto, xtipomovi, xcodoper: string; ximporte: real);
  destructor  Destroy; override;

  function    getUltimaCuotaPaga(xcodsocio: string): string;
  function    getTotalCuotas: real; overload;
  function    getTotalCuotas(xcodsocio: string): real; overload;
  function    getTotalEgresos(xcodsocio: string): real;

  function    Buscar(xcodsocio, xperit: string): boolean; overload;
  function    Buscar(xperit: string): boolean; overload;
  procedure   Grabar(xcodsocio, xperit, xfecha, xconcepto, xtipomovi, xcodoper: string; ximporte: real);
  procedure   Borrar(xcodsocio, xperit: string); overload;
  procedure   Borrar(xperit: string); overload;
  procedure   getDatos(xcodsocio, xperit: string); overload;
  procedure   getDatos(xperit: string); overload;
  function    NuevoItems: string;
  procedure   Listar(f1, f2: string; salida: char);
  function    AuditoriaCuotasRecaudadas(xfecha, xtm: string): TQuery;
  function    EstSqlCuotasReg(xdf, xhf: string): TQuery;
  function    EstSqlRetiros(xdf, xhf: string): TQuery;
  function    AuditoriaRetiros(xf: string): TQuery;
  procedure   Depurar(xfecha: string);
  procedure   FiltrarRetiros;
  procedure   FiltrarCuotas;

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  conexiones: shortint;
  ting, tegr: real;
  function   getTotalCuotas(xcodsocio, xfecha: string): real; overload;
  procedure  transfDatos(xfound: boolean);
end;

function fondog: TTFondoGenuinos;

implementation

var
  xfondog: TTFondoGenuinos = nil;

constructor TTFondoGenuinos.Create(xcodsocio, xperit, xfecha, xconcepto, xtipomovi, xcodoper: string; ximporte: real);
begin
  inherited Create;
  codsocio := xcodsocio;
  perit  := xperit;
  fecha    := xfecha;
  concepto := xconcepto;
  tipomovi := xtipomovi;
  codoper  := xcodoper;
  importe  := ximporte;

  tabla := datosdb.openDB('fondog', 'Codsocio;perit');
end;

destructor TTFondoGenuinos.Destroy;
begin
  inherited Destroy;
end;

procedure TTFondoGenuinos.Grabar(xcodsocio, xperit, xfecha, xconcepto, xtipomovi, xcodoper: string; ximporte: real);
// Objetivo...: Guardar atributos del objeto en tabla de Persistencia
begin
  if Buscar(xcodsocio, xperit) then tabla.Edit else tabla.Append;
  tabla.FieldByName('codsocio').AsString := xcodsocio;
  tabla.FieldByName('perit').AsString    := xperit;
  tabla.FieldByName('fecha').AsString    := utiles.sExprFecha(xfecha);
  tabla.FieldByName('concepto').AsString := xconcepto;
  tabla.FieldByName('codoper').AsString  := xcodoper;
  tabla.FieldByName('tipomovi').AsString := xtipomovi;
  tabla.FieldByName('monto').AsFloat     := ximporte;
  try
    tabla.Post;
  except
    tabla.Cancel;
  end;
end;

procedure TTFondoGenuinos.Depurar(xfecha: string);
// Objetivo...: Depurar Información cuotas registradas
var
  s: TQuery; totcuotas: real;
begin
  s := sociotitular.setSocios;
  s.Open; s.First;
  while not s.EOF do
    begin
      // Recalculamos el saldo de las cuotas anteriores a la fecha dada
      totcuotas := getTotalCuotas(s.FieldByName('codsocio').AsString, xfecha);
      // Borramos los movimientos anteriores a la fecha dada
      datosdb.tranSQL('DELETE FROM ' + tabla.TableName + ' WHERE fecha < ' + '''' + utiles.sExprFecha(xfecha) + '''' + ' AND codsocio = ' + '''' + s.FieldByName('codsocio').AsString + '''');
      // Grabamos el saldo inicial
      Grabar(s.FieldByName('codsocio').AsString, Copy(utiles.sExprFecha(xfecha), 5, 2) + '/' + Copy(utiles.sExprFecha(xfecha), 1, 4), xfecha, 'Capital inicial', '1', '', totcuotas);
      s.Next;
    end;
  s.Close; s.Free;
end;

procedure TTFondoGenuinos.Borrar(xcodsocio, xperit: string);
// Objetivo...: Eliminar un Objeto
begin
  if Buscar(xcodsocio, xperit) then
    begin
      tabla.Delete;
      getDatos(tabla.FieldByName('codsocio').AsString, tabla.FieldByName('perit').AsString);  // Fijamos los Atributos Siguientes al Objeto Borrado
    end;
end;

procedure TTFondoGenuinos.Borrar(xperit: string);
// Objetivo...: Eliminar un Objeto
begin
  if Buscar(xperit) then
    begin
      tabla.Delete;
      getDatos(tabla.FieldByName('perit').AsString);  // Fijamos los Atributos Siguientes al Objeto Borrado
    end;
end;

function TTFondoGenuinos.Buscar(xcodsocio, xperit: string): boolean;
// Objetivo...: Buscar el Objeto solicitado
begin
  if datosdb.Buscar(tabla, 'codsocio', 'perit', xcodsocio, xperit) then Result := True else Result := False;
end;

function TTFondoGenuinos.Buscar(xperit: string): boolean;
// Objetivo...: Buscar el Objeto solicitado
begin
  tabla.IndexName := 'Perit';
  if tabla.FindKey([xperit]) then Result := True else Result := False;
  tabla.IndexFieldNames := 'Codsocio;perit';
end;

procedure  TTFondoGenuinos.getDatos(xcodsocio, xperit: string);
// Objetivo...: Retornar/Iniciar Atributos
begin
  tabla.Refresh;
  if Buscar(xcodsocio, xperit) then transfDatos(True) else transfDatos(False);
end;

procedure  TTFondoGenuinos.getDatos(xperit: string);
// Objetivo...: Retornar/Iniciar Atributos - Por Items
begin
  tabla.Refresh;
  if Buscar(xperit) then transfDatos(True) else transfDatos(False);
end;

procedure  TTFondoGenuinos.transfDatos(xfound: boolean);
// Objetivo...: Cargar atributos
begin
  if xfound then
    begin
      codsocio  := tabla.FieldByName('codsocio').AsString;
      perit     := tabla.FieldByName('perit').AsString;
      fecha     := utiles.sFormatoFecha(tabla.FieldByName('fecha').AsString);
      concepto  := tabla.FieldByName('concepto').AsString;
      codoper   := tabla.FieldByName('codoper').AsString;
      tipomovi  := tabla.FieldByName('tipomovi').AsString;
      importe   := tabla.FieldByName('monto').AsFloat;
    end
   else
    begin
      codsocio := ''; perit := ''; fecha := ''; concepto := ''; importe := 0; codoper := ''; tipomovi := '';
    end;
end;

procedure TTFondoGenuinos.Listar(f1, f2: string; salida: char);
// Objetivo...: Informe de Cuotas Pagas
var
  ns: string;
begin
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Operaciones Efectuadas en el A.A.R.', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Fecha       Socio', 1, 'Arial, cursiva, 8');
  List.Titulo(40, list.lineactual, 'Concepto', 2, 'Arial, cursiva, 8');
  List.Titulo(77, list.lineactual, 'Ingresos', 3, 'Arial, cursiva, 8');
  List.Titulo(92, list.lineactual, 'Egresos', 4, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  tabla.First; ting := 0; tegr := 0;
  while not tabla.EOF do
    begin
      if (tabla.FieldByName('fecha').AsString >= utiles.sExprFecha(f1)) and (tabla.FieldByName('fecha').AsString <= utiles.sExprFecha(f2)) then //(tabla.FieldByName('tipomovi').AsString = '1') then
        begin
          if tabla.FieldByName('tipomovi').AsString = '1' then
            begin
              socioadherente.getDatos(tabla.FieldByName('codsocio').AsString);
              ns := socioadherente.Nombre;
            end
          else
            begin
              sociotitular.getDatos(tabla.FieldByName('codsocio').AsString);
              ns := sociotitular.Nombre;
            end;

          list.Linea(0, 0, utiles.sFormatoFecha(tabla.FieldByName('fecha').AsString) + '  ' + ns, 1, 'Arial, normal, 8', salida, 'N');
          list.Linea(40, list.Lineactual, tabla.FieldByName('concepto').AsString, 2, 'Arial, normal, 8', salida, 'N');
          if tabla.FieldByName('tipomovi').AsString = '1' then list.importe(83, list.lineactual, '', tabla.FieldByName('monto').AsFloat, 3, 'Arial, normal, 8') else list.importe(99, list.lineactual, '', tabla.FieldByName('monto').AsFloat, 3, 'Arial, normal, 8');
          list.Linea(99, list.Lineactual, ' ', 4, 'Arial, normal, 8', salida, 'S');
          if tabla.FieldByName('tipomovi').AsString = '1' then ting := ting + tabla.FieldByName('monto').AsFloat else tegr := tegr + tabla.FieldByName('monto').AsFloat;
        end;
      tabla.Next;
    end;
    list.Linea(0, 0, '  ', 1, 'Arial, normal, 8', salida, 'N');
    list.derecha(83, list.lineactual, '', '-------------------', 2, 'Arial, normal, 8');
    list.derecha(99, list.lineactual, '', '-------------------', 3, 'Arial, normal, 8');
    list.Linea(0, 0, '  ', 1, 'Arial, normal, 8', salida, 'S');
    list.importe(83, list.lineactual, '', ting, 2, 'Arial, normal, 8');
    list.importe(99, list.lineactual, '', tegr, 3, 'Arial, normal, 8');
    list.Linea(99, list.Lineactual, ' ', 4, 'Arial, normal, 8', salida, 'S');

    list.Linea(0, 0, 'Total Ingresos ........: ', 1, 'Courier New, normal, 9', salida, 'N');
    list.importe(50, list.lineactual, '', ting, 3, 'Arial, normal, 8');
    list.Linea(60, list.Lineactual, ' ', 4, 'Arial, normal, 8', salida, 'S');

    list.Linea(0, 0, 'Total Egresos .........: ', 1, 'Courier New, normal, 9', salida, 'N');
    list.importe(50, list.lineactual, '', tegr, 3, 'Arial, normal, 8');
    list.Linea(60, list.Lineactual, ' ', 4, 'Arial, normal, 8', salida, 'S');

    list.Linea(0, 0, 'Saldo A.A.R. ..........: ', 1, 'Courier New, normal, 9', salida, 'N');
    list.importe(50, list.lineactual, '', ting - tegr, 3, 'Arial, normal, 8');
    list.Linea(60, list.Lineactual, ' ', 4, 'Arial, normal, 8', salida, 'S');

    List.FinList;
end;

function TTFondoGenuinos.getTotalCuotas: real;
// Objetivo...: reclacular monto total de cuotas registradas
begin
  ting := 0;
  tabla.First;
  while not tabla.EOF do
    begin
      if tabla.FieldByName('tipomovi').AsString = '1' then ting := ting + tabla.FieldByName('monto').AsFloat;
      tabla.Next;
    end;
  Result := ting;
end;

function TTFondoGenuinos.getTotalCuotas(xcodsocio: string): real;
// Objetivo...: reclacular monto total de cuotas registradas para un socio específico
begin
  ting := 0;
  tabla.First;
  while not tabla.EOF do
    begin
      if (tabla.FieldByName('codsocio').AsString = xcodsocio) and (tabla.FieldByName('tipomovi').AsString = '1') then ting := ting + tabla.FieldByName('monto').AsFloat;
      tabla.Next;
    end;
  Result := ting;
end;

function TTFondoGenuinos.getTotalCuotas(xcodsocio, xfecha: string): real;
// Objetivo...: reclacular el capital para un socio específico y anteriores a una fecha dada
begin
  ting := 0;
  tabla.First;
  while not tabla.EOF do
    begin
      if (tabla.FieldByName('codsocio').AsString = xcodsocio) and (tabla.FieldByName('fecha').AsString < utiles.sExprFecha(xfecha)) then
        if tabla.FieldByName('tipomovi').AsString = '1' then ting := ting + tabla.FieldByName('monto').AsFloat else
          if tabla.FieldByName('tipomovi').AsString = '2' then ting := ting - tabla.FieldByName('monto').AsFloat;
      tabla.Next;
    end;
  Result := ting;
end;

function TTFondoGenuinos.getTotalEgresos(xcodsocio: string): real;
// Objetivo...: Retornar el total de Egresos para un socio Determinado
begin
  tegr := 0;
  tabla.First;
  while not tabla.EOF do
    begin
      if (tabla.FieldByName('codsocio').AsString = xcodsocio) and (tabla.FieldByName('tipomovi').AsString = '2') then tegr := tegr + tabla.FieldByName('monto').AsFloat;
      tabla.Next;
    end;
  Result := tegr;
end;

function TTFondoGenuinos.AuditoriaCuotasRecaudadas(xfecha, xtm: string): TQuery;
// Objetivo...: devolver un set con las cuotas cobradas en un día
begin
  Result := datosdb.tranSQL('SELECT fondog.codsocio, fondog.fecha, fondog.concepto, fondog.monto, socios.nombre FROM fondog, socios WHERE ' +
                            ' fondog.codsocio = socios.codsocio AND fondog.tipomovi = ' + '''' + xtm + '''' + ' AND fecha = ' + '''' + xfecha + '''');
end;

function TTFondoGenuinos.EstSqlRetiros(xdf, xhf: string): TQuery;
// Objetivo...: devolver un set con los retiros efectuados por socios
begin
  Result := datosdb.tranSQL('SELECT fondog.codsocio, fondog.fecha, fondog.concepto, fondog.monto, soctit.nombre FROM fondog, soctit WHERE ' +
                            ' fondog.codsocio = soctit.codsocio AND fondog.tipomovi = ' + '''' + '2' + '''' + ' AND fecha >= ' + '''' + xdf + '''' + ' AND fecha <= ' + '''' + xhf + '''');
end;

function TTFondoGenuinos.AuditoriaRetiros(xf: string): TQuery;
// Objetivo...: devolver un set con los retiros efectuados por socios
begin
  Result := datosdb.tranSQL('SELECT fondog.codsocio, fondog.fecha, fondog.concepto, fondog.monto, soctit.nombre FROM fondog, soctit WHERE ' +
                            ' fondog.codsocio = soctit.codsocio AND fondog.tipomovi = ' + '''' + '2' + '''' + ' AND fecha = ' + '''' + xf + '''');
end;

function TTFondoGenuinos.EstSqlCuotasReg(xdf, xhf: string): TQuery;
// Objetivo...: devolver un set con los retiros efectuados por socios
begin
  Result := datosdb.tranSQL('SELECT fondog.codsocio, fondog.fecha, fondog.concepto, fondog.monto, socios.nombre FROM fondog, socios WHERE ' +
                            ' fondog.codsocio = socios.codsocio AND fondog.tipomovi = ' + '''' + '1' + '''' + ' AND fecha >= ' + '''' + xdf + '''' + ' AND fecha <= ' + '''' + xhf + '''');
end;

procedure TTFondoGenuinos.FiltrarRetiros;
// Objetivo...: Filtrar los Retiros
begin
  datosdb.Filtrar(tabla, 'tipomovi = ' + '''' + '2' + '''');
end;

function TTFondoGenuinos.getUltimaCuotaPaga(xcodsocio: string): string;
// Objetivo...: Devolver la fecha de la ultima cuota Paga
var
  uf: string;
begin
  tabla.First;
  while not tabla.EOF do
    begin
      if (tabla.FieldByName('tipomovi').AsString = '1') and (tabla.FieldByName('codsocio').AsString = xcodsocio) then uf := tabla.FieldByName('fecha').AsString;
      tabla.Next;
    end;
  Result := uf;
end;

procedure TTFondoGenuinos.FiltrarCuotas;
// Objetivo...: Filtrar las cuotas
begin
  datosdb.Filtrar(tabla, 'tipomovi = ' + '''' + '1' + '''');
end;

function TTFondoGenuinos.NuevoItems: string;
// Objetivo...: Generar un Nuevo Items
var
  i: integer;
begin
  i := 0;
  tabla.Last;  // Extraemos el ultimo items
  while not tabla.BOF do
    begin
      if Copy(tabla.FieldByName('perit').AsString, 3, 1) <> '/' then
        begin
          i := tabla.FieldByName('perit').AsInteger;
          Break;
        end;
      tabla.Prior;
    end;
  Inc(i);
  Result := IntToStr(i);
end;

procedure TTFondoGenuinos.conectar;
// Objetivo...: Abrir tablas de persistencia
begin
  if conexiones = 0 then Begin
    tabla.Open;
    tabla.FieldByName('codsocio').DisplayLabel := 'Cód.'; tabla.FieldByName('perit').DisplayLabel := 'Período'; tabla.FieldByName('fecha').Visible := False; tabla.FieldByName('tipomovi').Visible := False;
    sociotitular.conectar;
    socioadherente.conectar;
    conceptoar.conectar;
  end;
  Inc(conexiones);
end;

procedure TTFondoGenuinos.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  Dec(conexiones);
  if conexiones = 0 then Begin
    datosdb.closeDB(tabla);
    sociotitular.desconectar;
    socioadherente.desconectar;
    conceptoar.desconectar;
  end;
end;

{===============================================================================}

function fondog: TTFondoGenuinos;
begin
  if xfondog = nil then
    xfondog := TTFondoGenuinos.Create('', '', '', '', '', '', 0);
  Result := xfondog;
end;

{===============================================================================}

initialization

finalization
  xfondog.Free;

end.
