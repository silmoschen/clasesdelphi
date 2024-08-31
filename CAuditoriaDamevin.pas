unit CAuditoriaDamevin;

interface

uses CAuditoria, CClienteDamevin, CPedidos, SysUtils, DB, DBTables, CBDT, CVias, CUtiles, CListar, CIDBFM;

type

TTAuditoriaDamevin = class(TTAuditoria)
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  procedure   PrepararAuditoria(xfecha: string);
  procedure   FinalizarAuditoria(xfecha: string);

  procedure   ListPedidos(salida: char);
private
  { Declaraciones Privadas }
  totimporte: real;
end;

function listauditoria: TTAuditoriaDamevin;

implementation

var
  xauditoria: TTAuditoriaDamevin = nil;

constructor TTAuditoriaDamevin.Create;
begin
  fecha := '';
  inherited Create;
end;

destructor TTAuditoriaDamevin.Destroy;
begin
  inherited Destroy;
end;

procedure TTAuditoriaDamevin.PrepararAuditoria(xfecha: string);
// Objetivo...: Setear información para el manejo de la auditoria
begin
  setFecha(xfecha);
  pedido.conectar;
end;

procedure TTAuditoriaDamevin.FinalizarAuditoria(xfecha: string);
// Objetivo...: Setear información para el manejo de la auditoria
begin
  pedido.desconectar;
end;

procedure TTAuditoriaDamevin.ListPedidos(salida: char);
// Objetivo...: Solicitudes Generadas en una fecha
begin
  verifListado(salida);

  Q := pedido.setPedidosAuditoria(fecha);

  List.Linea(0, 0, 'Pedidos Ingresadas', 1, 'Arial, negrita, 10', salida, 'S');
  List.Linea(0, 0, ' ', 1, 'Courier New, normal, 9', salida, 'S');

  Q.Open; Q.First; total := 0; totimporte := 0;
  while not Q.EOF do
    begin
      cliente.getDatos(Q.FieldByName('nrotel').AsString);
      List.Linea(0, 0, Q.FieldByName('nrotel').AsString, 1, 'Arial, normal, 8', salida, 'N');
      List.Linea(15, list.lineactual, cliente.nombre, 2, 'Arial, normal, 8', salida, 'S');
      List.Linea(63, list.lineactual, cliente.domicilio, 3, 'Arial, normal, 8', salida, 'N');
      List.importe(95, list.lineactual, '', Q.FieldByName('importe').AsFloat, 4, 'Arial, normal, 8');
      List.Linea(98, list.lineactual, ' ', 5, 'Arial, normal, 8', salida, 'S');
      total := total + 1;
      totimporte := totimporte + Q.FieldByName('importe').AsFloat;
      Q.Next;
    end;

  List.Linea(0, 0, ' ', 1, 'Arial, normal, 8', salida, 'S');
  List.Linea(0, 0, 'Cantidad de Pedidos Ingresados ...:', 1, 'Arial, negrita, 8', salida, 'N');
  List.importe(40, list.lineactual, '#####', total, 2, 'Arial, normal, 8');
  List.Linea(60, list.lineactual, ' ', 3, 'Arial, normal, 8', salida, 'S');
  List.Linea(0, 0, 'Ingresos por Pedidos ...:', 1, 'Arial, negrita, 8', salida, 'N');
  List.importe(40, list.lineactual, '', totimporte, 2, 'Arial, normal, 8');
  List.Linea(60, list.lineactual, ' ', 3, 'Arial, normal, 8', salida, 'S');

  List.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');

  Q.Close;
end;

{===============================================================================}

function listauditoria: TTAuditoriaDamevin;
begin
  if xauditoria = nil then
    xauditoria := TTAuditoriaDamevin.Create;
  Result := xauditoria;
end;

{===============================================================================}

initialization

finalization
  xauditoria.Free;

end.
