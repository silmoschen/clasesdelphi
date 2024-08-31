unit CInfFactCIC;

interface

uses CBDT, SysUtils, DBTables, CUtiles, CListar, CIDBFM, Contnrs, Classes,
     CSociosCIC, CFactCuotasCIC, CFactInformesCIC, CParametrosEmpresa,
     CFactLiqVariasCIC;

type

TTInfFact = class
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  procedure   ListarComprobantesEmitidos(xdesde, xhasta: String; salida: char);
  procedure   ListarComprobantesLiquidados(xdesde, xhasta: String; salida: char; xfechaliq: boolean);

  procedure   ListarOperacionesAdicionalesPendientes(xdesde, xhasta: String; salida: char);
  procedure   ListarOperacionesAdicionalesLiquidadas(xdesde, xhasta: String; salida: char);
 protected
  { Declaraciones Protegidas }
 private
  { Declaraciones Privadas }
  subtotal1, subtotal2, subtotal3: Real;
end;

implementation

constructor TTInfFact.Create;
begin
end;

destructor TTInfFact.Destroy;
begin
  inherited Destroy;
end;

procedure TTInfFact.ListarComprobantesEmitidos(xdesde, xhasta: String; salida: char);
// Objetivo...: Lista comprobantes emitidos
var
  l: TObjectList;
  obj1: TTFactCIC;
  obj2: TTFactInfCIC;
  obj3: TTFactLVCIC;
  i: Integer;

  procedure subtotal(xtitulo: String; xmonto: real; salida: char);
  begin
    if (xmonto <> 0) then Begin
      list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
      list.Linea(0, 0, xtitulo, 1, 'Arial, negrita, 8', salida, 'N');
      list.importe(95, list.Lineactual, '', xmonto, 2, 'Arial, negrita, 8');
      list.Linea(95, list.Lineactual, '', 3, 'Arial, negrita, 8', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
    End;
  end;

Begin
  list.Setear(salida);
  empresa.conectar;
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, empresa.RSocial, 1, 'Arial, normal, 12');
  List.Titulo(0, 0, 'Informe de Comprobantes Emitidos en el Lapso ' + xdesde + ' - ' + xhasta, 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Fecha', 1, 'Arial, cursiva, 8');
  List.Titulo(10, List.lineactual, 'Comprobante', 2, 'Arial, cursiva, 8');
  List.Titulo(25, List.lineactual, 'Socio', 3, 'Arial, cursiva, 8');
  List.Titulo(90, List.lineactual, 'Monto', 4, 'Arial, cursiva, 8');
  List.Titulo(95, List.lineactual, 'E', 5, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');
  empresa.desconectar;

  subtotal1 := 0; subtotal2 := 0; subtotal3 := 0;

  factcuotas.conectar;
  factinforme.conectar;
  factlv.conectar;

  l := factcuotas.getComprobantesEmitidos(xdesde, xhasta);

  list.Linea(0, 0, '***  Comprobantes Emitidos por Cuotas  ***', 1, 'Arial, normal, 10', salida, 'S');
  list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');

  for i := 1 to l.Count do Begin
    obj1 := TTFactCIC(l.Items[i-1]);
    socio.getDatos(obj1.Entidad);
    list.Linea(0, 0, obj1.Fecha, 1, 'Arial, normal, 8', salida, 'N');
    list.Linea(10, list.Lineactual, obj1.Tipo + ' ' + obj1.Sucursal + '-' + obj1.Numero, 2, 'Arial, normal, 8', salida, 'N');
    list.Linea(25, list.Lineactual, socio.nombre, 3, 'Arial, normal, 8', salida, 'N');
    list.importe(95, list.Lineactual, '', obj1.Subtotal, 4, 'Arial, normal, 8');
    list.Linea(95, list.Lineactual, obj1.Estado, 5, 'Arial, normal, 8', salida, 'S');
    if obj1.Estado <> 'C' then subtotal1 := subtotal1 + obj1.Subtotal;
  End;
  l.Free; l := Nil;

  subtotal('Subtotal Cuotas:', subtotal1, salida);

  list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
  list.Linea(0, 0, '***  Comprobantes Emitidos por Informes  ***', 1, 'Arial, normal, 10', salida, 'S');
  list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');

  l := factinforme.getComprobantesEmitidos(xdesde, xhasta);

  for i := 1 to l.Count do Begin
    obj2 := TTFactInfCIC(l.Items[i-1]);
    socio.getDatos(obj2.Entidad);
    list.Linea(0, 0, obj2.Fecha, 1, 'Arial, normal, 8', salida, 'N');
    list.Linea(10, list.Lineactual, obj2.Tipo + ' ' + obj2.Sucursal + '-' + obj2.Numero, 2, 'Arial, normal, 8', salida, 'N');
    list.Linea(25, list.Lineactual, socio.nombre, 3, 'Arial, normal, 8', salida, 'N');
    list.importe(95, list.Lineactual, '', obj2.Subtotal, 4, 'Arial, normal, 8');
    list.Linea(95, list.Lineactual, obj2.Estado, 5, 'Arial, normal, 8', salida, 'S');
    if obj2.Estado <> 'C' then subtotal2 := subtotal2 + obj2.Subtotal;
  End;
  l.Free; l := Nil;

  subtotal('Subtotal Informes:', subtotal2, salida);

  l := factlv.getComprobantesEmitidos(xdesde, xhasta);

  list.Linea(0, 0, '***  Comprobantes Emitidos por Liquidaciones Varias  ***', 1, 'Arial, normal, 10', salida, 'S');
  list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');

  for i := 1 to l.Count do Begin
    obj3 := TTFactLVCIC(l.Items[i-1]);
    socio.getDatos(obj3.Entidad);
    list.Linea(0, 0, obj3.Fecha, 1, 'Arial, normal, 8', salida, 'N');
    list.Linea(10, list.Lineactual, obj3.Tipo + ' ' + obj3.Sucursal + '-' + obj3.Numero, 2, 'Arial, normal, 8', salida, 'N');
    list.Linea(25, list.Lineactual, socio.nombre, 3, 'Arial, normal, 8', salida, 'N');
    list.importe(95, list.Lineactual, '', obj3.Subtotal, 4, 'Arial, normal, 8');
    list.Linea(95, list.Lineactual, obj3.Estado, 5, 'Arial, normal, 8', salida, 'S');
    if obj1.Estado <> 'C' then subtotal3 := subtotal3 + obj3.Subtotal;
  End;
  l.Free; l := Nil;

  subtotal('Subtotal Liquidaciones Varias:', subtotal3, salida);

  subtotal('Total General:', subtotal1 + subtotal2 + subtotal3, salida);

  factcuotas.desconectar;
  factinforme.desconectar;

  list.FinList;
End;

procedure TTInfFact.ListarComprobantesLiquidados(xdesde, xhasta: String; salida: char; xfechaliq: boolean);
// Objetivo...: Lista de Operaciones Adicionales
var
  l: TObjectList;
  obj1: TTFactCIC;
  obj2: TTFactInfCIC;
  i: Integer;

  procedure subtotal(xtitulo: String; xmonto: real; salida: char);
  begin
    if (xmonto <> 0) then Begin
      list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
      list.Linea(0, 0, xtitulo, 1, 'Arial, negrita, 8', salida, 'N');
      list.importe(95, list.Lineactual, '', xmonto, 2, 'Arial, negrita, 8');
      list.Linea(95, list.Lineactual, '', 3, 'Arial, negrita, 8', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
    End;
  end;

Begin
  list.Setear(salida);
  empresa.conectar;
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, empresa.RSocial, 1, 'Arial, normal, 12');
  if not (xfechaliq) then
    List.Titulo(0, 0, 'Informe de Comprobantes Emitidos en el Lapso ' + xdesde + ' - ' + xhasta, 1, 'Arial, negrita, 14')
  else
    List.Titulo(0, 0, 'Informe de Comprobantes Liquidados en el Lapso ' + xdesde + ' - ' + xhasta, 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Fecha', 1, 'Arial, cursiva, 8');
  List.Titulo(10, List.lineactual, 'Comprobante', 2, 'Arial, cursiva, 8');
  List.Titulo(25, List.lineactual, 'Socio', 3, 'Arial, cursiva, 8');
  List.Titulo(74, List.lineactual, 'Liquidado', 4, 'Arial, cursiva, 8');
  List.Titulo(90, List.lineactual, 'Monto', 5, 'Arial, cursiva, 8');
  List.Titulo(95, List.lineactual, 'E', 6, 'Arial, cursiva, 8');

  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');
  empresa.desconectar;

  subtotal1 := 0; subtotal2 := 0;

  factcuotas.conectar;
  factinforme.conectar;

  if not (xfechaliq) then
    l := factcuotas.getComprobantesliquidados(xdesde, xhasta)
  else
    l := factcuotas.getComprobantesLiquidadosPorFechaLiquidacion(xdesde, xhasta);

  list.Linea(0, 0, '***  Comprobantes Emitidos por Cuotas  ***', 1, 'Arial, normal, 10', salida, 'S');
  list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');

  for i := 1 to l.Count do Begin
    obj1 := TTFactCIC(l.Items[i-1]);
    socio.getDatos(obj1.Entidad);
    list.Linea(0, 0, obj1.Fecha, 1, 'Arial, normal, 8', salida, 'N');
    list.Linea(10, list.Lineactual, obj1.Tipo + ' ' + obj1.Sucursal + '-' + obj1.Numero, 2, 'Arial, normal, 8', salida, 'N');
    list.Linea(25, list.Lineactual, socio.nombre, 3, 'Arial, normal, 8', salida, 'N');
    list.Linea(75, list.Lineactual, obj1.FechaLiq, 4, 'Arial, normal, 8', salida, 'N');
    list.importe(95, list.Lineactual, '', obj1.Subtotal, 5, 'Arial, normal, 8');
    list.Linea(95, list.Lineactual, obj1.Estado, 6, 'Arial, normal, 8', salida, 'S');
    if obj1.Estado <> 'C' then subtotal1 := subtotal1 + obj1.Subtotal;
  End;
  l.Free; l := Nil;

  subtotal('Subtotal Cuotas:', subtotal1, salida);

  list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
  list.Linea(0, 0, '***  Comprobantes Emitidos por Informes  ***', 1, 'Arial, normal, 10', salida, 'S');
  list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');

  l := factinforme.getComprobantesLiquidados(xdesde, xhasta);

  for i := 1 to l.Count do Begin
    obj2 := TTFactInfCIC(l.Items[i-1]);
    socio.getDatos(obj2.Entidad);
    list.Linea(0, 0, obj2.Fecha, 1, 'Arial, normal, 8', salida, 'N');
    list.Linea(10, list.Lineactual, obj2.Tipo + ' ' + obj2.Sucursal + '-' + obj2.Numero, 2, 'Arial, normal, 8', salida, 'N');
    list.Linea(25, list.Lineactual, socio.nombre, 3, 'Arial, normal, 8', salida, 'N');
    list.Linea(75, list.Lineactual, obj2.FechaLiq, 4, 'Arial, normal, 8', salida, 'N');
    list.importe(95, list.Lineactual, '', obj2.Subtotal, 5, 'Arial, normal, 8');
    list.Linea(95, list.Lineactual, obj2.Estado, 6, 'Arial, normal, 8', salida, 'S');
    if obj2.Estado <> 'C' then subtotal2 := subtotal2 + obj2.Subtotal;
  End;
  l.Free; l := Nil;

  subtotal('Subtotal Informes:', subtotal2, salida);

  subtotal('Total General:', subtotal1 + subtotal2, salida);

  factcuotas.desconectar;
  factinforme.desconectar;
  factlv.desconectar;

  list.FinList;
End;

procedure TTInfFact.ListarOperacionesAdicionalesPendientes(xdesde, xhasta: String; salida: char);
// Objetivo...: Lista comprobantes emitidos
var
  l: TObjectList;
  obj1: TTFactCIC;
  obj2: TTFactLVCIC;
  i: Integer;

  procedure subtotal(xtitulo: String; xmonto: real; salida: char);
  begin
    if (xmonto <> 0) then Begin
      list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
      list.Linea(0, 0, xtitulo, 1, 'Arial, negrita, 8', salida, 'N');
      list.importe(95, list.Lineactual, '', xmonto, 2, 'Arial, negrita, 8');
      list.Linea(95, list.Lineactual, '', 3, 'Arial, negrita, 8', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
    End;
  end;

Begin
  list.Setear(salida);
  empresa.conectar;
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, empresa.RSocial, 1, 'Arial, normal, 12');
  List.Titulo(0, 0, 'Informe de Operaciones Adicionales Pendientes en el Lapso ' + xdesde + ' - ' + xhasta, 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Fecha', 1, 'Arial, cursiva, 8');
  List.Titulo(10, List.lineactual, 'Comprobante', 2, 'Arial, cursiva, 8');
  List.Titulo(25, List.lineactual, 'Socio', 3, 'Arial, cursiva, 8');
  List.Titulo(60, List.lineactual, 'Concepto', 4, 'Arial, cursiva, 8');
  List.Titulo(80, List.lineactual, 'Cant.', 5, 'Arial, cursiva, 8');
  List.Titulo(90, List.lineactual, 'Monto', 6, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');
  empresa.desconectar;

  subtotal1 := 0; subtotal2 := 0;

  factcuotas.conectar;
  factlv.conectar;

  l := factcuotas.getOperacionesAdicionalesPendientes(xdesde, xhasta);

  list.Linea(0, 0, '***  Comprobantes Emitidos por Cuotas  ***', 1, 'Arial, normal, 10', salida, 'S');
  list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');

  for i := 1 to l.Count do Begin
    obj1 := TTFactCIC(l.Items[i-1]);
    socio.getDatos(obj1.Entidad);
    list.Linea(0, 0, obj1.Fecha, 1, 'Arial, normal, 8', salida, 'N');
    list.Linea(10, list.Lineactual, obj1.Tipo + ' ' + obj1.Sucursal + '-' + obj1.Numero, 2, 'Arial, normal, 8', salida, 'N');
    list.Linea(25, list.Lineactual, socio.nombre, 3, 'Arial, normal, 8', salida, 'N');
    list.Linea(60, list.Lineactual, obj1.Descrip, 4, 'Arial, normal, 8', salida, 'N');
    list.importe(84, list.Lineactual, '', obj1.Cantidad, 5, 'Arial, normal, 8');
    list.importe(95, list.Lineactual, '', (obj1.Cantidad * obj1.Monto), 6, 'Arial, normal, 8');
    list.Linea(95, list.Lineactual, '', 7, 'Arial, normal, 8', salida, 'S');
    subtotal1 := subtotal1 + (obj1.Cantidad * obj1.Monto);
  End;
  l.Free; l := Nil;

  subtotal('Total Operaciones por Cuotas:', subtotal1, salida);

  l := factlv.getComprobantesEnCtaCtePendientes(xdesde, xhasta);

  list.Linea(0, 0, '***  Comprobantes por Liquidaciones Varias Pendientes  ***', 1, 'Arial, normal, 10', salida, 'S');
  list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');

  for i := 1 to l.Count do Begin
    obj2 := TTFactLVCIC(l.Items[i-1]);
    socio.getDatos(obj2.Entidad);
    list.Linea(0, 0, obj2.Fecha, 1, 'Arial, normal, 8', salida, 'N');
    list.Linea(10, list.Lineactual, obj2.Tipo + ' ' + obj2.Sucursal + '-' + obj2.Numero, 2, 'Arial, normal, 8', salida, 'N');
    list.Linea(25, list.Lineactual, socio.nombre, 3, 'Arial, normal, 8', salida, 'N');
    list.Linea(60, list.Lineactual, obj2.Descrip, 4, 'Arial, normal, 8', salida, 'N');
    list.importe(84, list.Lineactual, '#####', obj2.Cantidad, 5, 'Arial, normal, 8');
    list.importe(95, list.Lineactual, '', obj2.Subtotal, 6, 'Arial, normal, 8');
    list.Linea(95, list.Lineactual, '', 7, 'Arial, normal, 8', salida, 'S');
    subtotal2 := subtotal2 + obj2.Subtotal;
  End;
  l.Free; l := Nil;

  subtotal('Total Operaciones por Liquidaciones Varias:', subtotal2, salida);

  subtotal('Total General de Operaciones:', subtotal1 + subtotal2, salida);

  factcuotas.desconectar;
  factlv.desconectar;

  list.FinList;
End;

procedure TTInfFact.ListarOperacionesAdicionalesLiquidadas(xdesde, xhasta: String; salida: char);
// Objetivo...: Lista comprobantes emitidos
var
  l: TObjectList;
  obj1: TTFactCIC;
  i: Integer;

  procedure subtotal(xtitulo: String; xmonto: real; salida: char);
  begin
    if (xmonto <> 0) then Begin
      list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
      list.Linea(0, 0, xtitulo, 1, 'Arial, negrita, 8', salida, 'N');
      list.importe(95, list.Lineactual, '', xmonto, 2, 'Arial, negrita, 8');
      list.Linea(95, list.Lineactual, '', 3, 'Arial, negrita, 8', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
    End;
  end;

Begin
  list.Setear(salida);
  empresa.conectar;
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, empresa.RSocial, 1, 'Arial, normal, 12');
  List.Titulo(0, 0, 'Informe de Operaciones Adicionales Liquidadas en el Lapso ' + xdesde + ' - ' + xhasta, 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Fecha', 1, 'Arial, cursiva, 8');
  List.Titulo(8, List.lineactual, 'Comprobante', 2, 'Arial, cursiva, 8');
  List.Titulo(21, List.lineactual, 'Socio', 3, 'Arial, cursiva, 8');
  List.Titulo(50, List.lineactual, 'Concepto', 4, 'Arial, cursiva, 8');
  List.Titulo(72, List.lineactual, 'F. Liq.', 5, 'Arial, cursiva, 8');
  List.Titulo(80, List.lineactual, 'Cant.', 6, 'Arial, cursiva, 8');
  List.Titulo(90, List.lineactual, 'Monto', 7, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');
  empresa.desconectar;

  subtotal1 := 0;

  factcuotas.conectar;

  l := factcuotas.getOperacionesAdicionalesLiquidadas(xdesde, xhasta);

  list.Linea(0, 0, '***  Comprobantes Emitidos por Cuotas  ***', 1, 'Arial, normal, 10', salida, 'S');
  list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');

  for i := 1 to l.Count do Begin
    obj1 := TTFactCIC(l.Items[i-1]);
    socio.getDatos(obj1.Entidad);
    list.Linea(0, 0, obj1.Fecha, 1, 'Arial, normal, 8', salida, 'N');
    list.Linea(8, list.Lineactual, obj1.Tipo + ' ' + obj1.Sucursal + '-' + obj1.Numero, 2, 'Arial, normal, 8', salida, 'N');
    list.Linea(21, list.Lineactual, Copy(socio.nombre, 1, 22), 3, 'Arial, normal, 8', salida, 'N');
    list.Linea(50, list.Lineactual, Copy(obj1.Descrip, 1, 25), 4, 'Arial, normal, 8', salida, 'N');
    list.Linea(72, list.Lineactual, obj1.FechaLiq, 5, 'Arial, normal, 8', salida, 'N');
    list.importe(84, list.Lineactual, '', obj1.Cantidad, 6, 'Arial, normal, 8');
    list.importe(95, list.Lineactual, '', (obj1.Cantidad * obj1.Monto), 7, 'Arial, normal, 8');
    list.Linea(95, list.Lineactual, '', 8, 'Arial, normal, 8', salida, 'S');
    subtotal1 := subtotal1 + (obj1.Cantidad * obj1.Monto);
  End;
  l.Free; l := Nil;

  subtotal('Total Operaciones:', subtotal1, salida);

  factcuotas.desconectar;

  list.FinList;
End;

end.
