unit CEstadisticasDamevin;

interface

uses CEstadisticas, CPedidos, CClienteDamevin, CTablaSabores, SysUtils, DB, DBTables, CVias, CUtiles, CListar, CBDT, CIDBFM;

type

TTEstadisticaDamevin= class(TTEstadistica)
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  procedure   ListEstPedidos(salida: char);
  procedure   ListEstSabores(salida: char);
  procedure   EstPedidosClientes(salida: char);
 protected
  { Declaraciones Protegidas }
  procedure verifListado(salida: char);
 private
  { Declaraciones Privadas }
  t: TTable;
  importe: real; telanter: string;
  procedure Titulos(salida: char);
  procedure GuardarResultado;
end;

function estadistica: TTEstadisticaDamevin;

implementation

var
  xestadistica: TTEstadisticaDamevin= nil;

constructor TTEstadisticaDamevin.Create;
begin
  inherited Create;
end;

destructor TTEstadisticaDamevin.Destroy;
begin
  inherited Destroy;
end;

procedure TTEstadisticaDamevin.verifListado(salida: char);
// Objetivo...: Verificar emisión del Listado
begin
  if not s_inicio then
    begin
      Titulos(salida);   // Sio no se listo nada, tiramos los titulos
      s_inicio := True;
    end;
end;

procedure TTEstadisticaDamevin.ListEstPedidos(salida: char);
// Objetivo...: Estadística de análisis efectuados
begin
  cliente.conectar;
  Q := TQuery.Create(nil);
  Q := pedido.setEstadisticaPedidos(fecha1, fecha2);
  verifListado(salida);

  List.Linea(0, 0, 'Pedidos Realizados por Clientes', 1, 'Arial, negrita, 12', salida, 'S');
  List.Linea(0, 0, ' ', 1, 'Courier New, normal, 9', salida, 'S');

  Q.Open; Q.First; total := 0; importe := 0;
  items   := meses[StrToInt(Copy(Q.FieldByName('fecha').AsString, 5, 2))];
  while not Q.EOF do
    begin
      if Copy(Q.FieldByName('fecha').AsString, 5, 2) <> Copy(idanter, 5, 2) then Begin
        if importe > 0 then DatosGrafico(importe);
        importe := 0;
      end;
      if not InfResumido then Begin
        cliente.getDatos(Q.FieldByName('nrotel').AsString);
        List.Linea(0, 0, utiles.sFormatoFecha(Q.FieldByName('fecha').AsString) + '  ' + Q.FieldByName('nrotel').AsString, 1, 'Arial, normal, 8', salida, 'N');
        List.Linea(20, list.lineactual, cliente.nombre, 2, 'Arial, normal, 8', salida, 'N');
        List.importe(92, list.lineactual, '', Q.FieldByName('importe').AsFloat, 3, 'Arial, normal, 8');
        List.Linea(95, list.lineactual, ' ', 4, 'Arial, normal, 8', salida, 'S');
      end;
      total   := total + 1;
      importe := importe + Q.FieldByName('importe').AsFloat;
      idanter := Copy(Q.FieldByName('fecha').AsString, 5, 2);
      items   := meses[StrToInt(Copy(Q.FieldByName('fecha').AsString, 5, 2))];
      Q.Next;
    end;
  DatosGrafico(importe);

  if not Infresumido then Begin
    List.Linea(0, 0, ' ', 1, 'Arial, normal, 8', salida, 'N');
    List.derecha(92, list.lineactual, '', '--------------', 2, 'Arial, normal, 8');
  end;
  List.Linea(0, 0, 'Cantidad de Pedidos Ingresados ...:', 1, 'Arial, negrita, 8', salida, 'N');
  List.importe(92, list.lineactual, '', total, 2, 'Arial, normal, 8');
  List.Linea(95, list.lineactual, ' ', 3, 'Arial, normal, 8', salida, 'S');
  List.Linea(0, 0, 'Importe Total Recaudado ...:', 1, 'Arial, negrita, 8', salida, 'N');
  List.importe(92, list.lineactual, '', importe, 2, 'Arial, normal, 8');
  List.Linea(95, list.lineactual, ' ', 3, 'Arial, normal, 8', salida, 'S');
  List.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');

  Q.Close; Q.Free;
  cliente.desconectar;
end;

procedure TTEstadisticaDamevin.ListEstSabores(salida: char);
// Objetivo...: Estadística de pacientes ingresados
begin
  sabor.conectar;
  Q := TQuery.Create(nil);
  Q := pedido.setEstadisticaSabores(fecha1, fecha2);
  verifListado(salida);

  List.Linea(0, 0, 'Sabores Pedidos', 1, 'Arial, negrita, 12', salida, 'S');
  List.Linea(0, 0, ' ', 1, 'Courier New, normal, 9', salida, 'S');

  Q.Open; Q.First; total := 0; importe := 0;
  idanter := Q.FieldByName('items').AsString;
  sabor.getDatos(idanter);
  items   := sabor.Descrip;
  while not Q.EOF do
    begin
      if Q.FieldByName('items').AsString <> idanter then Begin
        if total > 0 then DatosGrafico(total);
        sabor.getDatos(idanter);
        items   := sabor.Descrip;
        List.Linea(0, 0, idanter + '  ' + items, 1, 'Arial, normal, 8', salida, 'N');
        List.importe(92, list.lineactual, '#####', total, 2, 'Arial, normal, 8');
        List.Linea(95, list.lineactual, ' ', 3, 'Arial, normal, 8', salida, 'S');
        total := 0;
      end;

      total   := total + 1;
      idanter := Q.FieldByName('items').AsString;
      //items   := Q.FieldByName('items').AsString;
      Q.Next;
    end;

  sabor.getDatos(items);
  List.Linea(0, 0, idanter + '  ' + items, 1, 'Arial, normal, 8', salida, 'N');
  DatosGrafico(total);
  List.importe(92, list.lineactual, '######', total, 2, 'Arial, normal, 8');
  List.Linea(95, list.lineactual, ' ', 3, 'Arial, normal, 8', salida, 'S');

  List.Linea(95, list.lineactual, ' ', 3, 'Arial, normal, 8', salida, 'S');
  List.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');

  Q.Close; Q.Free;
  sabor.desconectar;
end;

procedure TTEstadisticaDamevin.EstPedidosClientes(salida: char);
// Objetivo...: Estadísticas de pedidos efectuados por clientes
begin
  cliente.conectar;
  t := datosdb.openDB('estpedidos', 'Nrotel');
  datosdb.tranSQL('DELETE FROM ' + t.TableName);
  t.Open;

  Q := pedido.setEstadisticaPedidosCli(fecha1, fecha2);
  Q.Open; Q.First; telanter := Q.FieldByName('nrotel').AsString; importe := 0;
  while not Q.EOF do Begin
    if Q.FieldByName('nrotel').AsString <> telanter then GuardarResultado;
    importe := importe + 1;
    telanter := Q.FieldByName('nrotel').AsString;
    Q.Next;
  end;
  GuardarResultado;
  Q.Close; Q.Free;

  t.IndexName := 'Nropedidos';
  t.First;

  verifListado(salida);
  List.Linea(0, 0, 'Pedidos Discriminados por Clientes', 1, 'Arial, negrita, 12', salida, 'S');
  List.Linea(0, 0, ' ', 1, 'Courier New, normal, 9', salida, 'S');

  while not t.EOF do Begin
    begin
      if total > 0 then DatosGrafico(t.FieldByName('nropedidos').AsFloat);
      cliente.getDatos(t.FieldByName('nrotel').AsString);
      items   := cliente.nombre;
      List.Linea(0, 0, t.FieldByName('nrotel').AsString, 1, 'Arial, normal, 8', salida, 'N');
      List.Linea(15, list.Lineactual, items, 2, 'Arial, normal, 8', salida, 'N');
      List.importe(92, list.lineactual, '#####', t.FieldByName('nropedidos').AsInteger, 3, 'Arial, normal, 8');
      List.Linea(95, list.lineactual, ' ', 4, 'Arial, normal, 8', salida, 'S');
      t.Next;
    end;
  end;
  t.Close; t.Free;
  cliente.desconectar;
end;

procedure TTEstadisticaDamevin.GuardarResultado;
begin
  if not t.FindKey([telanter]) then t.Append else t.Edit;
  t.FieldByName('nrotel').AsString    := telanter;
  t.FieldByName('nropedidos').AsFloat := importe;
  try
    t.Post
  except
    t.Cancel
  end;
  importe := 0;
end;

procedure TTEstadisticaDamevin.Titulos(salida: char);
// Objetivo...: Listar Datos de Provincias
begin
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Informe Estadístico -  Período ' + utiles.sFormatoFecha(fecha1) + '-' + utiles.sFormatoFecha(fecha2), 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');
end;

{===============================================================================}

function estadistica: TTEstadisticaDamevin;
begin
  if xestadistica = nil then
    xestadistica := TTEstadisticaDamevin.Create;
  Result := xestadistica;
end;

{===============================================================================}

initialization

finalization
  xestadistica.Free;

end.
