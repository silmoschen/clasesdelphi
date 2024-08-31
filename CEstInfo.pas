unit CEstInfo;

interface

uses CEstadisticas, SysUtils, DB, DBTables, CVias, CUtiles, CListar, CBDT, CIDBFM;

type

TTInformesEstadisticos = class(TTEstadistica)
 public
  NombreEntidad: String;
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  { Cuentas Corrientes }
  procedure   ListSaldosCobrar(salida: char);
  procedure   ListCobrosEfectuados(salida: char);
  procedure   ListCuotasVencidas(salida: char);

  { Proyecciones Compras-Ventas }
  procedure   ProyeccionMensual(salida: char; xtitulo: string);
private
  { Declaraciones Privadas }
  importe, total1: real;
protected
  { Declaraciones Protegidas }
  procedure verifListado(salida: char);
end;

function estadistsocios: TTInformesEstadisticos;

implementation

var
  xestadistica: TTInformesEstadisticos = nil;

constructor TTInformesEstadisticos.Create;
begin
  fecha1 := ''; fecha2 := '';
  NombreEntidad := 'Cliente';
  inherited Create;
end;

destructor TTInformesEstadisticos.Destroy;
begin
  inherited Destroy;
end;

procedure TTInformesEstadisticos.verifListado(salida: char);
// Objetivo...: Verificar emisión del Listado
begin
  if not s_inicio then inherited Titulos('Informe Estadítico', salida);   // Sio no se listo nada, tiramos los titulos
end;

procedure TTInformesEstadisticos.ListSaldosCobrar(salida: char);
// Objetivo...: Listar las Facturas de ventas emitidas en el día
begin
  verifListado(salida);

  List.Linea(0, 0, 'Saldos a Cobrar', 1, 'Arial, negrita, 12', salida, 'S');
  List.Linea(0, 0, ' ', 1, 'Courier New, normal, 9', salida, 'S');

  Q.Open; Q.First; total := 0;
  if Q.RecordCount > 0 then items := meses[StrToInt(Copy(Q.FieldByName('fecha').AsString, 5, 2))];
  while not Q.EOF do
    begin
      if Copy(Q.FieldByName('fecha').AsString, 5, 2) <> Copy(idanter, 5, 2) then Begin
        if importe > 0 then DatosGrafico(importe);
        importe := 0;
      end;
      List.Linea(0, 0, utiles.sFormatoFecha(Q.FieldByName('fecha').AsString) + '  ' + {Q.FieldByName('tipo').AsString + ' ' + Q.FieldByName('sucursal').AsString + ' ' + Q.FieldByName('numero').AsString + '   ' + Q.FieldByName('idtitular').AsString + '-' +} Q.FieldByName('clavecta').AsString + '    ' + Q.FieldByName('nombre').AsString, 1, 'Arial, normal, 8', salida, 'N');
      List.Linea(55, list.lineactual, Q.FieldByName('concepto').AsString, 2, 'Arial, normal, 8', salida, 'N');
      List.importe(95, list.lineactual, '', (Q.FieldByName('importe').AsFloat - Q.FieldByName('entrega').AsFloat), 3, 'Arial, normal, 8');
      List.Linea(96, list.lineactual, ' ', 4, 'Arial, normal, 8', salida, 'S');
      total   := total + (Q.FieldByName('importe').AsFloat - Q.FieldByName('entrega').AsFloat);
      importe := importe + (Q.FieldByName('importe').AsFloat - Q.FieldByName('entrega').AsFloat);
      idanter := Copy(Q.FieldByName('fecha').AsString, 5, 2);
      items   := meses[StrToInt(Copy(Q.FieldByName('fecha').AsString, 5, 2))];
      Q.Next;
    end;
  DatosGrafico(importe);

  if total > 0 then Begin
    List.Linea(0, 0, ' ', 1, 'Arial, normal, 8', salida, 'N');
    List.derecha(95, list.lineactual, '', '--------------', 2, 'Arial, normal, 8');
    List.Linea(0, 0, 'Total a Cobrar .....:', 1, 'Arial, negrita, 8', salida, 'N');
    List.importe(95, list.lineactual, '', total, 2, 'Arial, negrita, 8');
    List.Linea(96, list.lineactual, ' ', 3, 'Arial, normal, 8', salida, 'S');
    List.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
    List.Linea(0, 0, ' ', 1, 'Courier New, normal, 8', salida, 'S');
  end else Begin
    List.Linea(0, 0, 'No Existen Datos para Listar', 1, 'Arial, cursiva, 8', salida, 'S');
    list.Linea(0, 0, ' ', 1, 'Arial, normal, 8', salida, 'S');
  end;

  Q.Close;
end;

procedure TTInformesEstadisticos.ListCobrosEfectuados(salida: char);
// Objetivo...: Listar las Facturas de ventas emitidas en el día
begin
  verifListado(salida);

  List.Linea(0, 0, ' ', 1, 'Courier New, normal, 8', salida, 'S');
  List.Linea(0, 0, 'Ingresos por Cobros Efectuados', 1, 'Arial, negrita, 12', salida, 'S');
  List.Linea(0, 0, ' ', 1, 'Courier New, normal, 5', salida, 'S');
  List.Linea(0, 0, 'Fecha Comprobante  Cuenta - ' + NombreEntidad, 1, 'Arial, cursiva, 8', salida, 'N');
  List.Linea(55, list.Lineactual, 'Concepto', 2, 'Arial, cursiva, 8', salida, 'N');
  List.Linea(76, list.Lineactual, 'Importe', 3, 'Arial, cursiva, 8', salida, 'N');
  List.Linea(88, list.Lineactual, 'Recargo', 4, 'Arial, cursiva, 8', salida, 'S');
  List.Linea(0, 0, ' ', 1, 'Arial, normal, 9', salida, 'S');

  Q.Open; Q.First; total := 0; total1 := 0;
  while not Q.EOF do
    begin
      if Copy(Q.FieldByName('fecha').AsString, 5, 2) <> Copy(idanter, 5, 2) then Begin
        if importe > 0 then DatosGrafico(importe);
        importe := 0;
      end;
      if Q.FieldByName('importe').AsFloat > 0 then Begin
        List.Linea(0, 0, utiles.sFormatoFecha(Q.FieldByName('fecha').AsString) + ' ' + Q.FieldByName('tipo').AsString + ' ' + Q.FieldByName('sucursal').AsString + ' ' + Q.FieldByName('numero').AsString + '   ' + Q.FieldByName('idtitular').AsString + '-' + Q.FieldByName('clavecta').AsString + ' ' + Q.FieldByName('nombre').AsString, 1, 'Arial, normal, 8', salida, 'N');
        List.Linea(55, list.lineactual, Copy(Q.FieldByName('concepto').AsString, 1, 25), 2, 'Arial, normal, 8', salida, 'N');
        List.importe(83, list.lineactual, '', Q.FieldByName('importe').AsFloat, 3, 'Arial, normal, 8');
        List.importe(95, list.lineactual, '', Q.FieldByName('recargo').AsFloat, 4, 'Arial, normal, 8');
        List.Linea(97, list.lineactual, ' ', 5, 'Arial, normal, 8', salida, 'S');
        total := total + Q.FieldByName('importe').AsFloat;
        importe := importe + (Q.FieldByName('importe').AsFloat);
        total1  := total1  + (Q.FieldByName('recargo').AsFloat);
        idanter := Copy(Q.FieldByName('fecha').AsString, 5, 2);
        items   := meses[StrToInt(Copy(Q.FieldByName('fecha').AsString, 5, 2))];
      end;
      Q.Next;
    end;
  DatosGrafico(importe);

  if total > 0 then Begin
    List.Linea(0, 0, ' ', 1, 'Arial, normal, 8', salida, 'N');
    List.derecha(83, list.lineactual, '', '--------------', 2, 'Arial, normal, 8');
    List.derecha(95, list.lineactual, '', '--------------', 3, 'Arial, normal, 8');
    List.Linea(0, 0, 'Total de Ingresos / Ingresos por recargos .....:', 1, 'Arial, negrita, 8', salida, 'N');
    List.importe(83, list.lineactual, '', total, 2, 'Arial, negrita, 8');
    List.importe(95, list.lineactual, '', total1, 3, 'Arial, negrita, 8');
    List.Linea(97, list.lineactual, ' ', 4, 'Arial, normal, 8', salida, 'S');
  end else Begin
    List.Linea(0, 0, 'No Existen datos para Listar', 1, 'Arial, cursiva, 8', salida, 'S');
    list.Linea(0, 0, ' ', 1, 'Arial, normal, 8', salida, 'S');
  end;

  List.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
  List.Linea(0, 0, ' ', 1, 'Courier New, normal, 8', salida, 'S');

  Q.Close;
end;

procedure TTInformesEstadisticos.ListCuotasVencidas(salida: char);
// Objetivo...: Listar las Facturas de ventas emitidas en el día
begin
  verifListado(salida);

  List.Linea(0, 0, ' ', 1, 'Courier New, normal, 8', salida, 'S');
  List.Linea(0, 0, 'Cobros Vencidos', 1, 'Arial, negrita, 12', salida, 'S');
  List.Linea(0, 0, ' ', 1, 'Courier New, normal, 9', salida, 'S');

  Q.Open; Q.First; total := 0;
  while not Q.EOF do
    begin
      if Copy(Q.FieldByName('fecha').AsString, 5, 2) <> Copy(idanter, 5, 2) then Begin
        if importe > 0 then DatosGrafico(importe);
        importe := 0;
      end;
      List.Linea(0, 0, utiles.sFormatoFecha(Q.FieldByName('fecha').AsString) + ' ' + Q.FieldByName('tipo').AsString + ' ' + Q.FieldByName('sucursal').AsString + ' ' + Q.FieldByName('numero').AsString + '   ' + Q.FieldByName('idtitular').AsString + '-' + Q.FieldByName('clavecta').AsString + ' ' + Q.FieldByName('nombre').AsString, 1, 'Arial, normal, 8', salida, 'N');
      List.Linea(55, list.lineactual, Q.FieldByName('concepto').AsString, 2, 'Arial, normal, 8', salida, 'N');
      List.importe(92, list.lineactual, '', (Q.FieldByName('importe').AsFloat - Q.FieldByName('entrega').AsFloat), 3, 'Arial, normal, 8');
      List.Linea(95, list.lineactual, ' ', 4, 'Arial, normal, 8', salida, 'S');
      total := total + (Q.FieldByName('importe').AsFloat - Q.FieldByName('entrega').AsFloat);
      importe := importe + (Q.FieldByName('importe').AsFloat - Q.FieldByName('entrega').AsFloat);
      idanter := Copy(Q.FieldByName('fecha').AsString, 5, 2);
      items   := meses[StrToInt(Copy(Q.FieldByName('fecha').AsString, 5, 2))];
      Q.Next;
    end;
  DatosGrafico(importe);

  if total > 0 then Begin
    List.Linea(0, 0, ' ', 1, 'Arial, normal, 8', salida, 'N');
    List.derecha(92, list.lineactual, '', '--------------', 2, 'Arial, normal, 8');
    List.Linea(0, 0, 'Total a Cobrar  .....:', 1, 'Arial, negrita, 8', salida, 'N');
    List.importe(92, list.lineactual, '', total, 2, 'Arial, negrita, 8');
    List.Linea(95, list.lineactual, ' ', 3, 'Arial, normal, 8', salida, 'S');
  end else Begin
    List.Linea(0, 0, 'No Existen Datos para Listar', 1, 'Arial, cursiva, 8', salida, 'S');
    list.Linea(0, 0, ' ', 1, 'Arial, normal, 8', salida, 'S');
  end;
  List.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
  List.Linea(0, 0, ' ', 1, 'Courier New, normal, 8', salida, 'S');

  Q.Close;
end;

//------------------------------------------------------------------------------

procedure TTInformesEstadisticos.ProyeccionMensual(salida: char; xtitulo: string);
// Objetivo...: Listar las Facturas emitidas en el día
begin
  verifListado(salida);

  List.Linea(0, 0, ' ', 1, 'Courier New, normal, 5', salida, 'S');
  List.Linea(0, 0, 'Comprobantes Emitidos - ' + xtitulo, 1, 'Arial, negrita, 12', salida, 'S');
  List.Linea(0, 0, ' ', 1, 'Courier New, normal, 9', salida, 'S');

  Q.Open; Q.First; total := 0;
  while not Q.EOF do
    begin
      List.Linea(0, 0, utiles.sFormatoFecha(Q.FieldByName('fecha').AsString) + ' ' + Q.FieldByName('tipo').AsString + ' ' + Q.FieldByName('sucursal').AsString + ' ' + Q.FieldByName('numero').AsString + '   ' + Q.FieldByName('cod').AsString + ' ' + Q.FieldByName('clipro').AsString, 1, 'Arial, normal, 8', salida, 'N');
      List.importe(92, list.lineactual, '', (Q.FieldByName('subtotal').AsFloat - Q.FieldByName('bonif').AsFloat + Q.FieldByName('impuestos').AsFloat + Q.FieldByName('ivari').AsFloat + Q.FieldByName('ivarni').AsFloat + Q.FieldByName('sobretasa').AsFloat), 2, 'Arial, normal, 8');
      List.Linea(95, list.lineactual, ' ', 3, 'Arial, normal, 8', salida, 'S');
      total := total + (Q.FieldByName('subtotal').AsFloat - Q.FieldByName('bonif').AsFloat + Q.FieldByName('impuestos').AsFloat + Q.FieldByName('ivari').AsFloat + Q.FieldByName('ivarni').AsFloat + Q.FieldByName('sobretasa').AsFloat);
      Q.Next;
    end;

  List.Linea(0, 0, ' ', 1, 'Arial, normal, 8', salida, 'N');
  List.derecha(92, list.lineactual, '', '--------------', 2, 'Arial, normal, 8');
  List.Linea(0, 0, 'Total ...............:', 1, 'Arial, negrita, 8', salida, 'N');
  List.importe(92, list.lineactual, '', total, 2, 'Arial, negrita, 8');
  List.Linea(95, list.lineactual, ' ', 3, 'Arial, normal, 8', salida, 'S');
  List.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
  List.Linea(0, 0, ' ', 1, 'Courier New, normal, 8', salida, 'S');

  Q.Close;
end;

{===============================================================================}

function estadistsocios: TTInformesEstadisticos;
begin
  if xestadistica = nil then
    xestadistica := TTInformesEstadisticos.Create;
  Result := xestadistica;
end;

{===============================================================================}

initialization

finalization
  xestadistica.Free;

end.
