unit Cccteprof;

interface

uses SysUtils, DB, DBTables, CCtactes, CProfesor, CDefCurs, CListar, CUtiles, CBDT, CIDBFM;

type

TTctacteprof = class(TTCtacte)            // Superclase
 public
  { Declaraciones Públicas }
  constructor Create(xperiodo, xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, xtm, xfecha, xfealta, xobs, xconcepto: string; ximporte: real);
  destructor  Destroy; override;

  function    getProfesor(xcodprof: string): string;

  procedure   Grabar(xperiodo, xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, xfecha, xtm, xconcepto, xcodcurso: string; ximporte: real);
  procedure   Borrar(xsucursal: string); overload;
  function    BuscarProfesor(xcprof: string): boolean;
  function    getMcctpr: TQuery; overload;
  function    getMcctpr(xidtitular: string): TQuery; overload;
  procedure   Depurar(fecha: string);
  procedure   conectar;
  procedure   desconectar;

  procedure   rListar(iniciar, finalizar: string; salida, tl: char);
  procedure   ListPlanillaSaldos(fecha: string; salida: char);
 private
  { Declaraciones Privadas }
  conexiones: shortint;
  v: array[1..3] of string;
  cantclases: integer; ic, mc: real;
  procedure rSubtotales(salida: char);
  procedure rSubtotales1(salida: char; t: string);
  procedure subtotcurso(salida, tlist: char);
  procedure ObtenerSaldo(xidtitular: string);
  function  obtener_total(fecha, idt, dc: string): real;
  procedure rList_linea(salida, tlist: char);
end;

function ccprof: TTctacteprof;

implementation

var
  xctactepr: TTctacteprof = nil;

constructor TTctacteprof.Create(xperiodo, xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, xtm, xfecha, xfealta, xobs, xconcepto: string; ximporte: real);
begin
  inherited Create(xperiodo, xclavecta, xidtitular, '', xidc, xtipo, xsucursal, xnumero, xtm, xfecha, xfealta, xobs, xconcepto, ximporte);
  tabla3 := datosdb.openDB('ctactepr.DB', 'Idtitular;Clavecta;Idcompr;Tipo;Sucursal;Numero');
end;

destructor TTctacteprof.Destroy;
begin
  inherited Destroy;
end;

function TTctacteprof.getProfesor(xcodprof: string): string;
begin
  profesor.getDatos(xcodprof);
  Result := profesor.getNombre;
end;

function TTctacteprof.BuscarProfesor(xcprof: string): boolean;
begin
  Result := profesor.Buscar(xcprof);
end;

function TTctacteprof.obtener_total(fecha, idt, dc: string): real;
// Objetivo...: devolver subtotal
begin
  datosdb.tranSQL('SELECT SUM(importe) FROM ctactepr WHERE fecha < ' + '''' + utiles.sExprFecha(fecha) + '''' + ' AND idtitular = ' + '''' + idt + '''' + ' AND DC = ' + '''' + dc + '''');
  datosdb.setSQL.Open;
  Result := datosdb.setSQL.Fields[0].AsFloat;
  datosdb.setSQL.Close;
end;

procedure TTctacteprof.Grabar(xperiodo, xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, xfecha, xtm, xconcepto, xcodcurso: string; ximporte: real);
// Objetivo...: Grabar los atributos referentes a una cuenta corriente
begin
  if xnumero = '00000001' then   // Eliminamos los movimientos viejos
    if BuscarOperacion(xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero) then Borrar(xsucursal);
  inherited Grabar(xperiodo, xclavecta, xidtitular, xidc, xtipo, xsucursal, xnumero, xfecha, xtm, xconcepto, ximporte);
  tabla3.Edit;
  tabla3.FieldByName('items').AsString    := Copy(xnumero, 6, 3);
  try
    tabla3.Post;
  except
    tabla3.Cancel;
  end;
end;

procedure TTctacteprof.Depurar(fecha: string);
// Objetivo...: Eliminar los movimientos que no se necesiten mas
var
  td, th: real; tm: string;
  r: TQuery;
begin
  r := profesor.setProfesores;
  r.Open; r.First;
  while not r.EOF do
    begin
      // 1º Obtenemos los totales para el saldo inicial
      td := obtener_total(fecha, r.FieldByName('nrolegajo').AsString, '1');
      th := obtener_total(fecha, r.FieldByName('nrolegajo').AsString, '2');
      // 2º Eliminamos los movimientos
      datosdb.tranSQL('DELETE FROM ctactepr WHERE fecha < ' + '''' + utiles.sExprFecha(fecha) + '''' + ' AND idtitular = ' + '''' + r.FieldByName('nrolegajo').AsString + '''');
      // 3º Grabamos el movimiento inicial
      if td - th <> 0 then
        begin
          if (td-th) >= 0 then tm := '1' else tm := '2';
          Grabar(Copy(utiles.sExprFecha(fecha), 1, 4), '', r.FieldByName('nrolegajo').AsString, 'NUE', 'X', '0000', '00000000', fecha, tm, 'Saldo inicial', '', (td - th));
        end;
      r.Next;
    end;
  r.Close; r.Free;
end;

procedure TTctacteprof.Borrar(xsucursal: string);
// Objetivo...: Anular una Liquidación completa
begin
  datosDB.tranSQL('DELETE FROM ctactepr WHERE sucursal = ' + '''' + xsucursal + '''');
end;

function TTctacteprof.getMcctpr: TQuery;
// Objetivo...: devolver un subset con las operaciones de la cuenta corriente
begin
  Result := datosdb.tranSQL('SELECT * FROM ctactepr WHERE idcompr <> ' + '''' + 'LIQ' + '''');
end;

function TTctacteprof.getMcctpr(xidtitular: string): TQuery;
// Objetivo...: devolver un subset con las operaciones de la cuenta corriente
begin
  Result := datosdb.tranSQL('SELECT * FROM ctactepr WHERE idtitular = ' + '''' + xidtitular + '''');
end;

procedure TTctacteprof.rSubtotales(salida: char);
// Objetivo...: Emitir Subtotales
begin
  List.Linea(0, 0, ' ', 1, 'Arial, negrita, 8', salida, 'N');
  List.derecha(70, list.lineactual, '', '--------------', 2, 'Arial, normal, 8');
  List.derecha(85, list.lineactual, '', '--------------', 3, 'Arial, normal, 8');
  List.derecha(100, list.lineactual, '', '--------------', 4, 'Arial, normal, 8');
  List.Linea(101, list.lineactual, ' ', 5, 'Arial, negrita, 8', salida, 'S');
  List.Linea(0, 0, 'Subtotal Cuenta ..........: ', 1, 'Arial, negrita, 8', salida, 'N');
  List.importe(70, list.lineactual, '', td, 2, 'Arial, normal, 8');
  List.importe(85, list.lineactual, '', th, 3, 'Arial, normal, 8');
  List.importe(100, list.lineactual, '', saldo, 4, 'Arial, normal, 8');
  List.Linea(0, 0, ' ', 1, 'Arial, negrita, 9', salida, 'S');
  saldo := 0; td := 0; th := 0;
end;

procedure TTctacteprof.rListar(iniciar, finalizar: string; salida, tl: char);
// Objetivo...: Listar Cuentas Corrientes de Proveedores Definidas
var
  indice: string;
begin
  indice := tabla3.IndexFieldNames;

  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, 'Liquidación de Honorarios', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Fecha', 1, 'Arial, cursiva, 8');
  List.Titulo(8, List.lineactual, 'Dias/Comprobante', 2, 'Arial, cursiva, 8');
  List.Titulo(24, List.lineactual, 'Horario / Concepto', 3, 'Arial, cursiva, 8');
  List.Titulo(65, List.lineactual, 'Debe', 4, 'Arial, cursiva, 8');
  List.Titulo(80, List.lineactual, 'Haber', 5, 'Arial, cursiva, 8');
  List.Titulo(95, List.lineactual, 'Saldo', 6, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  tabla3.IndexName := 'Listado';

  profesor.tperso.First;
  while not profesor.tperso.EOF do
    begin
      if profesor.tperso.FieldByName('sel').AsString = 'X' then
        begin
           saldo := 0; td := 0; th := 0; idant := ''; clant := ''; cantclases := 0;

           tabla3.First;
           while not tabla3.EOF do
             begin
               if (tabla3.FieldByName('idtitular').AsString = profesor.tperso.FieldByName('nrolegajo').AsString) then
                 begin
                   if tabla3.FieldByName('DC').AsString = '1' then saldo := saldo + tabla3.FieldByName('importe').AsFloat;
                   if tabla3.FieldByName('DC').AsString = '2' then saldo := saldo - tabla3.FieldByName('importe').AsFloat;
                   if (tabla3.FieldByName('fecha').AsString >= utiles.sExprFecha(iniciar)) and (tabla3.FieldByName('fecha').AsString <= utiles.sExprFecha(finalizar)) then rList_Linea(salida, tl);
                 end;

               tabla3.Next;
             end;

           if tabla3.FieldByName('DC').AsString = '1' then subtotcurso(salida, tl);
           if td + th <> 0 then rSubtotales(salida);
        end;

      profesor.tperso.Next;
    end;

    List.FinList;

    tabla3.IndexFieldNames := indice;
end;

procedure TTctacteprof.rList_linea(salida, tlist: char);
// Objetivo...: Listar una Línea
var
  pr: string;
begin
  v[2] := utiles.FormatearNumero(FloatToStr(td));
  if tabla3.FieldByName('DC').AsString = '1' then td := td + tabla3.FieldByName('importe').AsFloat;
  if tabla3.FieldByName('DC').AsString = '2' then th := th + tabla3.FieldByName('importe').AsFloat;
  defcurso.getDatos(tabla3.FieldByName('clavecta').AsString);

  if (tabla3.FieldByName('clavecta').AsString <> clant) and (cantclases > 0) then subtotcurso(salida, tlist);

  if tabla3.FieldByName('idtitular').AsString <> idant then
    begin
      // Subtotal
      if idant <> '' then rSubtotales(salida);

      pr := profesor.tperso.FieldByName('nombre').AsString;
      List.Linea(0, 0, 'Profesor: ' + tabla3.FieldByName('idtitular').AsString + '-' + tabla3.FieldByName('clavecta').AsString + '    ' + pr, 1, 'Arial, negrita, 12', salida, 'S');
      List.Linea(0, 0, ' ', 1, 'Arial, negrita, 5', salida, 'S');
      List.Linea(0, 0, utiles.espacios(140) + 'Saldo Anterior ....: ', 1, 'Arial, cursiva, 8', salida, 'S');
      if tabla3.FieldByName('DC').AsString = '1' then saldoanter := saldo - tabla3.FieldByName('importe').AsFloat else saldoanter := saldo + tabla3.FieldByName('importe').AsFloat;
      List.importe(100, list.lineactual, '', saldoanter, 2, 'Arial, cursiva, 8');
      List.Linea(101, list.lineactual, ' ', 3, 'Arial, cursiva, 8', salida, 'S');
      List.Linea(0, 0, ' ', 1, 'Arial, negrita, 5', salida, 'S');
    end;

  if tabla3.FieldByName('clavecta').AsString <> 'XXXXXX' then
   if tlist = '1' then
    begin
      List.Linea(0, 0, utiles.sFormatoFecha(tabla3.FieldByName('fecha').AsString), 1, 'Arial, normal, 8', salida, 'N');
      List.Linea(8, List.lineactual, defcurso.getDinicio + '-' + defcurso.getDfinal, 2, 'Arial, normal, 8', salida, 'N');
      List.Linea(20, List.lineactual, defcurso.getHinicio + '-' + defcurso.getHfinal + '   ' + tabla3.FieldByName('concepto').AsString, 3, 'Arial, normal, 8', salida, 'S');
      if tabla3.FieldByName('DC').AsString = '1' then List.importe(70, list.lineactual, '', tabla3.FieldByName('importe').AsFloat, 4, 'Arial, normal, 8');
      if tabla3.FieldByName('DC').AsString = '2' then List.importe(85, list.lineactual, '', tabla3.FieldByName('importe').AsFloat, 5, 'Arial, normal, 8');
      List.importe(100, list.lineactual, '', saldo, 6, 'Arial, normal, 8');
      List.Linea(101, List.lineactual, '', 8, 'Arial, normal, 7', salida, 'S');
    end;
  if tabla3.FieldByName('clavecta').AsString = 'XXXXXX' then
    begin
      List.Linea(0, 0, utiles.sFormatoFecha(tabla3.FieldByName('fecha').AsString), 1, 'Arial, normal, 8', salida, 'N');
      List.Linea(8, List.lineactual, tabla3.FieldByName('idcompr').AsString, 2, 'Arial, normal, 8', salida, 'N');
      List.Linea(12, List.lineactual, tabla3.FieldByName('tipo').AsString + ' ' + tabla3.FieldByName('sucursal').AsString + ' ' + tabla3.FieldByName('numero').AsString + '   ' + tabla3.FieldByName('concepto').AsString, 3, 'Arial, normal, 8', salida, 'S');
      if tabla3.FieldByName('DC').AsString = '1' then List.importe(70, list.lineactual, '', tabla3.FieldByName('importe').AsFloat, 4, 'Arial, normal, 8');
      if tabla3.FieldByName('DC').AsString = '2' then List.importe(85, list.lineactual, '', tabla3.FieldByName('importe').AsFloat, 5, 'Arial, normal, 8');
      List.importe(100, list.lineactual, '', saldo, 6, 'Arial, normal, 8');
      List.Linea(101, List.lineactual, '', 8, 'Arial, normal, 7', salida, 'S');
    end;

  if tabla3.FieldByName('DC').AsString = '1' then
    begin
      Inc(cantclases);
      v[1] := utiles.sFormatoFecha(tabla3.FieldByName('fecha').AsString);
      v[3] := defcurso.getObservac;
      mc   := mc + tabla3.FieldByName('importe').AsFloat;
    end;

  clant := tabla3.FieldByName('clavecta').AsString;
  idant := tabla3.FieldByName('idtitular').AsString;
end;

procedure TTctacteprof.subtotcurso(salida, tlist: char);
begin
  List.Linea(0, 0, ' ', 1, 'Arial, normal, 3', salida, 'N');
  List.Linea(0, 0, v[1] + ' ' + v[3] + '     Cant. Clases: ' + inttostr(cantclases) , 1, 'Arial, cursiva, 8', salida, 'N');
  List.importe(70, list.lineactual, '', mc, 2, 'Arial, normal, 8');
  List.importe(100, list.lineactual, '', StrToFloat(v[2]), 3, 'Arial, cursiva, 8');
  List.Linea(101, List.lineactual, '', 4, 'Arial, cursiva, 8', salida, 'S');
  List.Linea(0, 0, ' ', 1, 'Arial, normal, 3', salida, 'S');
  cantclases := 0; mc := 0;
end;

procedure TTctacteprof.rSubtotales1(salida: char; t: string);
// Objetivo...: Emitir Subtotales
var
  l: string;
begin
  if t = '1' then l := 'Total de cuotas ......:' else l := 'Total Pagado .....:';
  List.Linea(0, 0, ' ', 1, 'Arial, negrita, 8', salida, 'N');
  List.derecha(70, list.lineactual, '', '--------------', 2, 'Arial, normal, 8');
  List.derecha(85, list.lineactual, '', '--------------', 3, 'Arial, normal, 8');
  List.Linea(101, list.lineactual, ' ', 5, 'Arial, negrita, 8', salida, 'S');
  List.Linea(0, 0, l, 1, 'Arial, negrita, 8', salida, 'N');
  List.importe(70, list.lineactual, '', total, 2, 'Arial, normal, 8');
  List.importe(85, list.lineactual, '', recar, 3, 'Arial, normal, 8');
  if iss then
    begin
      List.Linea(0, 0, 'Saldo Actual ......:', 1, 'Arial, negrita, 8', salida, 'N');
      List.importe(30, list.lineactual, '', td - th, 2, 'Arial, negrita, 8');
    end;
  List.Linea(0, 0, ' ', 1, 'Arial, negrita, 9', salida, 'S');
end;

procedure TTctacteprof.ObtenerSaldo(xidtitular: string);
// Objetivo...: Calcular el saldo para una cuenta dada
begin
  td := 0; th := 0;
  TSQL.Open; TSQL.First;
  while not TSQL.EOF do
    begin
      if TSQL.FieldByName('idtitular').AsString = xidtitular then
        begin
          if TSQL.FieldByName('DC').AsString = '1' then td := td + TSQL.FieldByName('importe').AsFloat;
          if TSQL.FieldByName('DC').AsString = '2' then th := th + TSQL.FieldByName('importe').AsFloat;
        end;
      TSQL.Next;
    end;
end;

procedure TTctacteprof.ListPlanillaSaldos(fecha: string; salida: char);
// Objetivo...: Listar saldos individuales por cuenta
var
  pr, clant: string;
begin
  TSQL := datosdb.tranSQL('SELECT ctactepr.tipo, ctactepr.fecha, ctactepr.idtitular, ctactepr.clavecta, ctactepr.DC, ctactepr.importe FROM ctactepr WHERE fecha <= ' + '''' + utiles.sExprFecha(fecha) + '''');

  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, 'Planilla de Saldos Profesores', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, 'Saldos al ' + fecha, 1, 'Arial, negrita, 12');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'NºLeg.   Profesor', 1, 'Arial, cursiva, 8');
  List.Titulo(86, List.lineactual, 'Saldo', 2, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  total := 0;
  profesor.tperso.First;
  while not profesor.tperso.EOF do
    begin
      if profesor.tperso.FieldByName('sel').AsString = 'X' then
        begin
          ObtenerSaldo(profesor.tperso.FieldByName('nrolegajo').AsString);
          pr := profesor.tperso.FieldByName('nombre').AsString;

          List.Linea(0, 0, profesor.tperso.FieldByName('nrolegajo').AsString + '  ' + pr, 1, 'Arial, normal, 8', salida, 'N');
          List.importe(90, list.lineactual, '', td - th, 2, 'Arial, normal, 8');
          List.Linea(90, List.lineactual, ' ', 3, 'Arial, normal, 8', salida, 'S');
          total := total + (td - th);
        end;
      profesor.tperso.Next;
    end;

    TSQL.Close;

    list.Linea(0, 0, '  ', 1, 'Arial, normal, 8', salida, 'S');
    list.Linea(0, 0, '  ', 1, 'Arial, normal, 8', salida, 'S');
    list.derecha(90, list.lineactual, '##############', '--------------', 2, 'Arial, normal, 8');
    list.Linea(0, 0, 'Total ........: ', 1, 'Arial, normal, 8', salida, 'N');
    list.importe(90, list.lineactual, '', total, 2, 'Arial, normal, 8');
    list.Linea(92, list.lineactual, '  ', 3, 'Arial, normal, 8', salida, 'S');

    List.FinList;
end;

procedure TTctacteprof.conectar;
// Objetivo...: Abrir tablas de persistencia
begin
  if conexiones = 0 then Begin
    profesor.conectar;
    defcurso.conectar;
    if not profesor.tperso.Active then
      begin
        profesor.tperso.Open;
        profesor.tperso.FieldByName('fealta').Visible := False; profesor.tperso.FieldByName('clave').Visible := False; profesor.tperso.FieldByName('sel').Visible := False;
        profesor.tperso.FieldByName('idtitular').DisplayLabel := 'Titular'; profesor.tperso.FieldByName('clavecta').DisplayLabel := 'Cta.'; profesor.tperso.FieldByName('obs').DisplayLabel := 'Observaciones';
      end;
    if not tabla3.Active then tabla3.Open;
  end;
  Inc(conexiones);
end;

procedure TTctacteprof.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  Dec(conexiones);
  if conexiones = 0 then Begin
    profesor.desconectar;
    defcurso.desconectar;
    datosdb.closeDB(profesor.tperso);
    datosdb.closeDB(tabla3);
  end;
end;

{===============================================================================}

function ccprof: TTctacteprof;
begin
  if xctactepr = nil then
    xctactepr := TTctacteprof.Create('', '', '', '', '', '', '', '', '', '', '', '', 0);
  Result := xctactepr;
end;

{===============================================================================}

initialization

finalization
  xctactepr.Free;

end.
