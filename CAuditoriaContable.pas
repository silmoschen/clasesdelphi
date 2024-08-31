unit CAuditoriaContable;

interface

uses CEmpresas, CAuditoria, CIvaCompra, CIvaVenta, CLDiaAuc, CLDiaAuv, CLDiario, SysUtils, DB, DBTables, CBDT, CVias, CUtiles, CListar, CIDBFM;

type

TTAuditoriaContable = class(TTAuditoria)
  xvia, xempresa: string;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  procedure   PrepararAuditoria(xfecha: string);
  procedure   verifListado(salida: char);
  procedure   ListIngresosIvaCompra(salida: char);
  procedure   ListIngresosIvaVenta(salida: char);
  procedure   ListPasesDiarioCompra(salida: char);
  procedure   ListPasesDiarioVenta(salida: char);
  procedure   ListAsientosResumen(salida: char);
 private
  { Declaraciones Privadas }
  tot: array[1..4] of real;
  listRelacion: boolean;
  procedure ListInfIva(salida: char);
  procedure ListInfCont(salida: char);
end;

function auditoriacontable: TTAuditoriaContable;

implementation

var
  xauditoria: TTAuditoriaContable = nil;

constructor TTAuditoriaContable.Create;
begin
  fecha := '';
  inherited Create;
end;

destructor TTAuditoriaContable.Destroy;
begin
  inherited Destroy;
end;

procedure TTAuditoriaContable.verifListado(salida: char);
// Objetivo...: Verificar emisión del Listado
begin
  if not s_inicio then Begin
    inherited Titulos(salida);   // Sio no se listo nada, tiramos los titulos
    List.Titulo(0, 0, 'Contribuyente: ' + xempresa, 1, 'Arial, normal, 12');
    List.Titulo(0, 0, ' ', 1, 'Arial, normal, 5');
    s_inicio := True;
  end;
end;

procedure TTAuditoriaContable.PrepararAuditoria(xfecha: string);
// Objetivo...: Setear información para el manejo de la auditoria
begin
  setFecha(xfecha);
end;

procedure TTAuditoriaContable.ListIngresosIvaCompra(salida: char);
// Objetivo...: Operaciones IVA Compras
begin
  ivac.Via(xvia);
  verifListado(salida);
  Q := TQuery.Create(nil);
  Q := ivac.setAuditoria(fecha);
  List.Linea(0, 0, 'Comprobantes Ingresados en I.V.A. Compras', 1, 'Arial, negrita, 10', salida, 'S');
  List.Linea(0, 0, ' ', 1, 'Courier New, normal, 9', salida, 'S');
  ListInfIva(salida);
  ivac.desconectar;
end;

procedure TTAuditoriaContable.ListIngresosIvaVenta(salida: char);
// Objetivo...: Operaciones IVA Ventas
begin
  ivav.Via(xvia);
  verifListado(salida);
  Q := TQuery.Create(nil);
  Q := ivav.setAuditoria(fecha);
  List.Linea(0, 0, 'Comprobantes Ingresados en I.V.A. Ventas', 1, 'Arial, negrita, 10', salida, 'S');
  List.Linea(0, 0, ' ', 1, 'Courier New, normal, 9', salida, 'S');
  ListInfIva(salida);
  ivav.desconectar;
end;

procedure TTAuditoriaContable.ListInfIva(salida: char);
// Objetivo...: Dar forma al informe
begin
  tot[1] := 0; tot[2] := 0; tot[3] := 0; tot[4] := 0; total := 0;
  Q.Open; Q.First;
  while not Q.EOF do
    begin
      List.Linea(0, 0, Q.FieldByName('idcompr').AsString, 1, 'Arial, normal, 8', salida, 'N');
      List.Linea(4, list.Lineactual, Q.FieldByName('tipo').AsString + ' ' + Q.FieldByName('sucursal').AsString + ' ' + Q.FieldByName('numero').AsString, 2, 'Arial, normal, 8', salida, 'N');
      List.Linea(18, list.lineactual, Q.FieldByName('rsocial').AsString, 3, 'Arial, normal, 8', salida, 'S');
      List.importe(60, list.lineactual, '', Q.FieldByName('nettot').AsFloat, 4, 'Arial, normal, 8');
      List.importe(70, list.lineactual, '', Q.FieldByName('iva').AsFloat, 5, 'Arial, normal, 8');
      List.importe(80, list.lineactual, '', Q.FieldByName('ivarec').AsFloat, 6, 'Arial, normal, 8');
      List.importe(90, list.lineactual, '', Q.FieldByName('totoper').AsFloat, 7, 'Arial, normal, 8');
      List.Linea(95, list.lineactual, ' ', 8, 'Arial, normal, 8', salida, 'S');
      tot[1] := tot[1] + Q.FieldByName('nettot').AsFloat;
      tot[2] := tot[2] + Q.FieldByName('iva').AsFloat;
      tot[3] := tot[3] + Q.FieldByName('ivarec').AsFloat;
      tot[4] := tot[4] + Q.FieldByName('totoper').AsFloat;
      total  := total + 1;
      Q.Next;
    end;

  List.Linea(0, 0, ' ', 1, 'Arial, normal, 8', salida, 'S');
  List.Linea(50, list.Lineactual, '---------------------------------------------------------------------------', 2, 'Arial, negrita, 8', salida, 'S');
  List.Linea(0, 0, 'Subtotales ...:', 1, 'Arial, negrita, 8', salida, 'N');
  List.importe(60, list.lineactual, '', tot[1], 2, 'Arial, normal, 8');
  List.importe(70, list.lineactual, '', tot[2], 3, 'Arial, normal, 8');
  List.importe(80, list.lineactual, '', tot[3], 4, 'Arial, normal, 8');
  List.importe(90, list.lineactual, '', tot[4], 5, 'Arial, normal, 8');
  List.Linea(95, list.lineactual, ' ', 6, 'Arial, normal, 8', salida, 'S');

  List.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');
  List.Linea(0, 0, 'Cantidad de Comprobantes ...:', 1, 'Arial, negrita, 8', salida, 'N');
  List.importe(40, list.lineactual, '#####', total, 2, 'Arial, normal, 8');
  List.Linea(60, list.lineactual, ' ', 3, 'Arial, normal, 8', salida, 'S');
  List.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
  List.Linea(0, 0, ' ', 1, 'Arial, normal, 8', salida, 'S');

  Q.Close; Q.Free;
end;

procedure TTAuditoriaContable.ListPasesDiarioCompra(salida: char);
// Objetivo...: Pases del diario a la contabilidad
begin
  listRelacion := True;
  ldiarioauxc.Via(xvia);
  verifListado(salida);
  Q := TQuery.Create(nil);
  Q := ldiarioauxc.setAsientosAuditoria(fecha);
  List.Linea(0, 0, 'Asientos Generados a partir de I.V.A. Compras', 1, 'Arial, negrita, 10', salida, 'S');
  List.Linea(0, 0, ' ', 1, 'Courier New, normal, 9', salida, 'S');
  ListInfCont(salida);
  ldiarioauxc.desconectar;
end;

procedure TTAuditoriaContable.ListPasesDiarioVenta(salida: char);
// Objetivo...: Pases del diario a la contabilidad
begin
  listRelacion := True;
  ldiarioauxv.Via(xvia);
  verifListado(salida);
  Q := TQuery.Create(nil);
  Q := ldiarioauxv.setAsientosAuditoria(fecha);
  List.Linea(0, 0, 'Asientos Generados a partir de I.V.A. Ventas', 1, 'Arial, negrita, 10', salida, 'S');
  List.Linea(0, 0, ' ', 1, 'Courier New, normal, 9', salida, 'S');
  ListInfCont(salida);
  ldiarioauxv.desconectar;
end;

procedure TTAuditoriaContable.ListAsientosResumen(salida: char);
// Objetivo...: Pases del diario a la contabilidad
begin
  listRelacion := False;
//  ldiario.Via(xvia);
  verifListado(salida);
  Q := TQuery.Create(nil);
  Q := ldiario.setAsientosAuditoriaAutomaticos(fecha);
  List.Linea(0, 0, 'Asientos Compactados', 1, 'Arial, negrita, 10', salida, 'S');
  List.Linea(0, 0, ' ', 1, 'Courier New, normal, 9', salida, 'S');
  ListInfCont(salida);
  ldiario.desconectar;
end;

procedure TTAuditoriaContable.ListInfCont(salida: char);
// Objetivo...: Dar forma al informe
begin
  total := 0;
  Q.Open; Q.First;
  while not Q.EOF do
    begin
      if listRelacion then Begin
        List.Linea(0, 0, Q.FieldByName('nroasien').AsString + '  ' + Q.FieldByName('observac').AsString, 1, 'Arial, normal, 8', salida, 'N');
        List.Linea(80, list.Lineactual, Q.FieldByName('idc').AsString, 2, 'Arial, normal, 8', salida, 'N');
        List.Linea(83, list.Lineactual, Q.FieldByName('tipo').AsString + ' ' + Q.FieldByName('sucursal').AsString + ' ' + Q.FieldByName('numero').AsString, 3, 'Arial, normal, 8', salida, 'N');
       end
      else
        List.Linea(0, 0, Q.FieldByName('nroasien').AsString + '  ' + Q.FieldByName('observac').AsString, 1, 'Arial, normal, 8', salida, 'S');
      total  := total + 1;
      Q.Next;
    end;
  List.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');
  List.Linea(0, 0, 'Cantidad de Asientos ...:', 1, 'Arial, negrita, 8', salida, 'N');
  List.importe(40, list.lineactual, '#####', total, 2, 'Arial, normal, 8');
  List.Linea(60, list.lineactual, ' ', 3, 'Arial, normal, 8', salida, 'S');
  List.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
  List.Linea(0, 0, ' ', 1, 'Arial, normal, 8', salida, 'S');

  Q.Close; Q.Free;
end;

{===============================================================================}

function auditoriacontable: TTAuditoriaContable;
begin
  if xauditoria = nil then
    xauditoria := TTAuditoriaContable.Create;
  Result := xauditoria;
end;

{===============================================================================}

initialization

finalization
  xauditoria.Free;

end.
