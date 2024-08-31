unit CEstadisticasSocios;

interface

uses CEstInfo, Ccctsoc, CFondoG, CDepSoc, CSocio, SysUtils, DB, DBTables, CVias, CUtiles, CListar, CBDT, CIDBFM;

type

TTestadisticasocios = class(TTInformesEstadisticos)
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  procedure   ListSaldosCobrar(salida: char);
  procedure   ListCobrosEfectuados(salida: char);
  procedure   ListCuotasVencidas(salida: char);
  procedure   ListRetirosEfectuados(salida: char);
  procedure   ListDepositosEfectuados(salida: char);
  procedure   ListCuotasRegistradas(salida: char);
  procedure   ObtenerPorcentajeSocio;

  procedure   conectar;
  procedure   desconectar;
private
  { Declaraciones Privadas }
end;

function estadisticasocios: TTestadisticasocios;

implementation

var
  xestadistica: TTestadisticasocios = nil;

constructor TTestadisticasocios.Create;
begin
  inherited Create;
  //r := datosdb.openDB('datest.DB', 'IdSerie');
end;

destructor TTestadisticasocios.Destroy;
begin
  inherited Destroy;
end;

procedure TTestadisticasocios.ListSaldosCobrar(salida: char);
// Objetivo...: Listar las Facturas de ventas emitidas en el día
begin
  Q := ccsoc.EstsqlSaldosCobrar(fecha1, fecha2);
  inherited ListSaldosCobrar(salida);
end;

procedure TTestadisticasocios.ListCobrosEfectuados(salida: char);
// Objetivo...: Listar las Facturas de ventas emitidas en el día
begin
  Q := ccsoc.EstsqlCobrosEfectuados(fecha1, fecha2);
  inherited ListCobrosEfectuados(salida);
end;

procedure TTestadisticasocios.ListCuotasVencidas(salida: char);
// Objetivo...: Listar las Facturas de ventas emitidas en el día
begin
  Q := ccsoc.EstsqlCuotasVencidas(fecha1, fecha2);
  inherited ListCuotasVencidas(salida);
end;

procedure TTestadisticasocios.ObtenerPorcentajeSocio;
// Objetivo...: Obtener el total de depósitos de cada socio
begin
{  datosdb.tranSQL('DELETE FROM datest');
  ccsoc.conectar;
  socio.tperso.First;
  while not socio.tperso.EOF do
    begin
      r.Append;
      r.FieldByName('idserie').AsString := socio.tperso.FieldByName('codsocio').AsString;
      r.FieldByName('serie').AsString   := socio.tperso.FieldByName('nombre').AsString;
      r.FieldByName('valor').AsFloat    := fondog.getTotalCuotas(socio.tperso.FieldByName('codsocio').AsString);
      try
        r.Post;
      except
        r.Cancel;
      end;
      socio.tperso.Next;
    end;
  ccsoc.desconectar;}
end;

procedure TTestadisticasocios.ListDepositosEfectuados(salida: char);
// Objetivo...: Estadística de los depósitos efectuados por socios titulares
begin
  verifListado(salida);

  Q := depsocios.EstSqlDepSocios(fecha1, fecha2);

  List.Linea(0, 0, 'Depósitos Efectuados por Socios Titulares', 1, 'Arial, negrita, 12', salida, 'S');
  List.Linea(0, 0, ' ', 1, 'Courier New, normal, 9', salida, 'S');

  Q.Open; Q.First; total := 0;
  while not Q.EOF do
    begin
      List.Linea(0, 0, utiles.sFormatoFecha(Q.FieldByName('fecha').AsString) + '  ' + Q.FieldByName('codsocio').AsString + ' ' + Q.FieldByName('nombre').AsString, 1, 'Arial, normal, 8', salida, 'N');
      List.importe(92, list.lineactual, '', Q.FieldByName('deposito').AsFloat, 2, 'Arial, normal, 8');
      List.Linea(95, list.lineactual, ' ', 3, 'Arial, normal, 8', salida, 'S');
      total := total + Q.FieldByName('deposito').AsFloat;
      Q.Next;
    end;

  List.Linea(0, 0, ' ', 1, 'Arial, normal, 8', salida, 'N');
  List.derecha(92, list.lineactual, '', '--------------', 2, 'Arial, normal, 8');
  List.Linea(0, 0, 'Total de Depósitos ..:', 1, 'Arial, negrita, 8', salida, 'N');
  List.importe(92, list.lineactual, '', total, 2, 'Arial, normal, 8');
  List.Linea(95, list.lineactual, ' ', 3, 'Arial, normal, 8', salida, 'S');
  List.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');

  Q.Close;
end;

procedure TTestadisticasocios.ListRetirosEfectuados(salida: char);
// Objetivo...: Listar las Facturas de ventas emitidas en el día
begin
  verifListado(salida);

  Q := fondog.EstSqlRetiros(fecha1, fecha2);

  List.Linea(0, 0, ' ', 1, 'Courier New, normal, 5', salida, 'S');
  List.Linea(0, 0, 'Retiros Efectuados Fondo A.A.R.', 1, 'Arial, negrita, 12', salida, 'S');
  List.Linea(0, 0, ' ', 1, 'Courier New, normal, 9', salida, 'S');

  Q.Open; Q.First; total := 0;
  while not Q.EOF do
    begin
      List.Linea(0, 0, utiles.sFormatoFecha(Q.FieldByName('fecha').AsString) + ' ' + Q.FieldByName('codsocio').AsString + ' ' + Q.FieldByName('nombre').AsString, 1, 'Arial, normal, 8', salida, 'N');
      List.Linea(60, list.lineactual, Q.FieldByName('concepto').AsString, 2, 'Arial, normal, 8', salida, 'N');
      List.importe(92, list.lineactual, '', Q.FieldByName('monto').AsFloat, 3, 'Arial, normal, 8');
      List.Linea(95, list.lineactual, ' ', 4, 'Arial, normal, 8', salida, 'S');
      total := total + Q.FieldByName('monto').AsFloat;
      Q.Next;
    end;

  List.Linea(0, 0, ' ', 1, 'Arial, normal, 8', salida, 'N');
  List.derecha(92, list.lineactual, '', '--------------', 2, 'Arial, normal, 8');
  List.Linea(0, 0, 'Total de Retiros ......:', 1, 'Arial, negrita, 8', salida, 'N');
  List.importe(92, list.lineactual, '', total, 2, 'Arial, normal, 8');
  List.Linea(95, list.lineactual, ' ', 3, 'Arial, normal, 8', salida, 'N');
  List.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');

  Q.Close;
end;

procedure TTestadisticasocios.ListCuotasRegistradas(salida: char);
// Objetivo...: Listar las Facturas de ventas emitidas en el día
begin
  verifListado(salida);

  Q := fondog.EstSqlCuotasReg(fecha1, fecha2);

  List.Linea(0, 0, ' ', 1, 'Courier New, normal, 5', salida, 'S');
  List.Linea(0, 0, 'Cuotas Socios Registradas - Fondo A.A.R.', 1, 'Arial, negrita, 12', salida, 'S');
  List.Linea(0, 0, ' ', 1, 'Courier New, normal, 9', salida, 'S');

  Q.Open; Q.First; total := 0;
  while not Q.EOF do
    begin
      List.Linea(0, 0, utiles.sFormatoFecha(Q.FieldByName('fecha').AsString) + ' ' + Q.FieldByName('codsocio').AsString + ' ' + Q.FieldByName('nombre').AsString, 1, 'Arial, normal, 8', salida, 'N');
      List.Linea(60, list.lineactual, Q.FieldByName('concepto').AsString, 2, 'Arial, normal, 8', salida, 'N');
      List.importe(92, list.lineactual, '', Q.FieldByName('monto').AsFloat, 3, 'Arial, normal, 8');
      List.Linea(95, list.lineactual, ' ', 4, 'Arial, normal, 8', salida, 'S');
      total := total + Q.FieldByName('monto').AsFloat;
      Q.Next;
    end;

  List.Linea(0, 0, ' ', 1, 'Arial, normal, 8', salida, 'N');
  List.derecha(92, list.lineactual, '', '--------------', 2, 'Arial, normal, 8');
  List.Linea(0, 0, 'Total de Retiros ......:', 1, 'Arial, negrita, 8', salida, 'N');
  List.importe(92, list.lineactual, '', total, 2, 'Arial, normal, 8');
  List.Linea(95, list.lineactual, ' ', 3, 'Arial, normal, 8', salida, 'N');
  List.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');

  Q.Close;
end;

procedure TTestadisticasocios.conectar;
begin
  //if not r.Active then r.Open;
end;

procedure TTestadisticasocios.desconectar;
begin
  //if r.Active then r.Close;
end;

{===============================================================================}

function estadisticasocios: TTestadisticasocios;
begin
  if xestadistica = nil then
    xestadistica := TTestadisticasocios.Create;
  Result := xestadistica;
end;

{===============================================================================}

initialization

finalization
  xestadistica.Free;

end.
