unit CLLamadasEntrantesCallerID;

interface

uses SysUtils, DBTables, CUtiles, CIDBFM, CListar;

type

TTCallerID = class(TObject)
  Nrotel, Nombre, Direccion, Fecha, Hora, LineaEntrada, Repartidor, HoraParaIniciarNumeroPedido: String; Vuelto: Real;
  registro, inicarnuevopedido, horainiciopedidos, historico: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  function    Buscar(xfecha, xhora: String): Boolean;
  procedure   Registrar(xnrotel, xnombre, xdireccion, xfecha, xhora, xlineaentr, xrepartidor: String; xvuelto: Real);
  procedure   Borrar(xfecha, xhora: String);
  procedure   getDatos(xfecha, xhora: String);

  procedure   FiltrarPorFecha(xfecha: String);
  procedure   FiltrarTelefonosConocidos;
  procedure   FiltrarTelefonosDesconocidos;
  procedure   QuitarFiltro;
  procedure   verificarFiltro;

  procedure   ListarPorFechas(xdfecha, xhfecha: String; salida: Char);
  procedure   ListarNumerosConocidos(xdfecha, xhfecha: String; salida: Char);
  procedure   ListarNumerosDesconocidos(xdfecha, xhfecha: String; salida: Char);

  procedure   EstablecerHoraNuevoPedido(xhora: String);
  function    setCompletarNumeroCelular(xnrotel: String): String;

  procedure   Refrescar;
  procedure   Depurar(xfecha: String);

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  conexiones: Integer; Bloqueo: Boolean; Filtro: String;
  procedure   Listar(xtitulo: String; salida: Char);
  function    NumeroDePedido(xfecha, xhora: String): Integer;
end;

function llamada: TTCallerId;

implementation

var
  xllamada: TTCallerId = nil;

constructor TTCallerId.Create;
begin
  inherited Create;
  registro          := datosdb.openDB('llamadasEntrantes', '');
  inicarnuevopedido := datosdb.openDB('iniciarnropedido', '');
  horainiciopedidos := datosdb.openDB('horainiciopedidos', '');
  historico         := datosdb.openDB('llamadasEntrantes_hist', '');
end;

destructor TTCallerId.Destroy;
begin
  inherited Destroy;
end;

function  TTCallerId.Buscar(xfecha, xhora: String): Boolean;
Begin
  if registro.IndexFieldNames <> 'Fecha;Hora' then registro.IndexFieldNames := 'Fecha;Hora';
  if Copy(xfecha, 3, 1) = '/' then Result := datosdb.Buscar(registro, 'Fecha', 'Hora', utiles.sExprFecha(xfecha), xhora) else Result := datosdb.Buscar(registro, 'Fecha', 'Hora', xfecha, xhora);
end;

procedure  TTCallerId.Registrar(xnrotel, xnombre, xdireccion, xfecha, xhora, xlineaentr, xrepartidor: String; xvuelto: Real);
var
  nroPedido: Integer;
Begin
  Bloqueo   := True; datosdb.QuitarFiltro(registro);
  nroPedido := NumeroDePedido(xfecha, Copy(xhora, 1, 5));
  if Buscar(xfecha, xhora) then registro.Edit else registro.Append;
  registro.FieldByName('fecha').AsString      := utiles.sExprFecha(xfecha);
  registro.FieldByName('hora').AsString       := xhora;
  registro.FieldByName('nrotel').AsString     := xnrotel;
  registro.FieldByName('nombre').AsString     := UpperCase(xnombre);
  registro.FieldByName('direccion').AsString  := xdireccion;
  registro.FieldByName('fecha1').AsString     := xfecha;
  registro.FieldByName('LineaEnt').AsString   := xLineaEntr;
  registro.FieldByName('Registro').AsInteger  := nroPedido;
  registro.FieldByName('repartidor').AsString := xrepartidor;
  registro.FieldByName('vuelto').AsFloat      := xvuelto;
  try
    registro.Post
   except
    registro.Cancel
  end;
  Bloqueo := False; verificarFiltro;
  Buscar(xfecha, xhora);
end;

function   TTCallerId.NumeroDePedido(xfecha, xhora: String): Integer;
var
  np: Integer; hora: String;
Begin
  hora := utiles.setHoraActual24(xhora + ':00');
  hora := Copy(hora, 1, 5);
  if inicarnuevopedido.RecordCount = 0 then Begin
    np := 1;
    inicarnuevopedido.Append;
    inicarnuevopedido.FieldByName('Fecha').AsString := xfecha;
    inicarnuevopedido.FieldByName('Numero').AsInteger := np;
  end else Begin
    inicarnuevopedido.Edit;
    if (inicarnuevopedido.FieldByName('Fecha').AsString <> xfecha) and (hora >= HoraParaIniciarNumeroPedido) then np := 1 else np  := inicarnuevopedido.FieldByName('Numero').AsInteger + 1;
    if np = 1 then inicarnuevopedido.FieldByName('Fecha').AsString := xfecha;
    inicarnuevopedido.FieldByName('Numero').AsInteger := np;
  end;
  inicarnuevopedido.FieldByName('hora').AsString    := hora;
  inicarnuevopedido.FieldByName('Estado').AsString  := 'I';
  inicarnuevopedido.Post;
  Result := np;
end;

procedure  TTCallerId.Borrar(xfecha, xhora: String);
Begin
  Bloqueo := True; datosdb.QuitarFiltro(registro);
  if datosdb.Buscar(registro, 'Fecha', 'Hora', xfecha, xhora) then registro.Delete;
  Bloqueo := False; verificarFiltro;
  registro.Last;
end;

procedure  TTCallerId.getDatos(xfecha, xhora: String);
Begin
  Bloqueo := True; datosdb.QuitarFiltro(registro);
  if datosdb.Buscar(registro, 'Fecha', 'Hora', xfecha, xhora) then Begin
    NroTel       := registro.FieldByName('Nrotel').AsString;
    Nombre       := registro.FieldByName('nombre').AsString;
    Direccion    := registro.FieldByName('direccion').AsString;
    LineaEntrada := registro.FieldByName('lineaent').AsString;
    repartidor   := registro.FieldByName('repartidor').AsString;
    vuelto       := registro.FieldByName('vuelto').AsFloat;
  end else Begin
    Nrotel := ''; Nombre := ''; Direccion := ''; LineaEntrada := ''; repartidor := ''; vuelto := 0;
  end;
  Bloqueo := False; verificarFiltro;
end;

procedure  TTCallerId.FiltrarPorFecha(xfecha: String);
Begin
  Bloqueo := True;
  Filtro  := 'fecha = ' + utiles.sExprFecha(xfecha);
  datosdb.Filtrar(registro, Filtro);
  registro.Last;
  Bloqueo := False;
end;

procedure  TTCallerId.FiltrarTelefonosConocidos;
Begin
  Bloqueo := True;
  Filtro  := 'nombre <> ' + '''' + '*** Desconocido ***' + '''';
  datosdb.Filtrar(registro, Filtro);
  registro.Last;
  Bloqueo := False;
end;

procedure  TTCallerId.FiltrarTelefonosDesconocidos;
Begin
  Bloqueo := True;
  Filtro  := 'nombre = ' + '''' + '*** Desconocido ***' + '''';
  datosdb.Filtrar(registro, Filtro);
  registro.Last;
  Bloqueo := False;
end;

procedure  TTCallerId.QuitarFiltro;
Begin
  Bloqueo := True;
  datosdb.QuitarFiltro(registro);
  registro.Last;
  Bloqueo := False;
  Filtro  := '';
end;

procedure  TTCallerId.verificarFiltro;
Begin
  if Length(Trim(Filtro)) > 0 then Begin
    Bloqueo := True;
    datosdb.Filtrar(registro, Filtro);
    registro.Last;
    Bloqueo := False;
  end else
    datosdb.QuitarFiltro(registro);
end;

procedure  TTCallerId.Refrescar;
Begin
  if not Bloqueo then Begin
    if registro.IndexFieldNames <> 'Fecha;Hora' then registro.IndexFieldNames := 'Fecha;Hora';
    registro.Refresh;
    registro.Last;
  end;
end;

procedure  TTCallerId.Depurar(xfecha: String);
// Objetivo...: Depurar Registro de Llamadas
Begin
  conectar;
  Bloqueo := True;
  registro.First;
  while not registro.Eof do Begin
    if registro.FieldByName('Fecha').AsString <= utiles.sExprFecha2000(xfecha) then Begin
      if datosdb.Buscar(historico, 'Fecha', 'Hora', registro.FieldByName('fecha').AsString, registro.FieldByName('hora').AsString) then historico.Edit else historico.Append;
      historico.FieldByName('fecha').AsString      := registro.FieldByName('fecha').AsString;
      historico.FieldByName('hora').AsString       := registro.FieldByName('hora').AsString;
      historico.FieldByName('nrotel').AsString     := registro.FieldByName('nrotel').AsString;
      historico.FieldByName('nombre').AsString     := registro.FieldByName('nombre').AsString;
      historico.FieldByName('direccion').AsString  := registro.FieldByName('direccion').AsString;
      historico.FieldByName('fecha1').AsString     := registro.FieldByName('fecha1').AsString;
      historico.FieldByName('LineaEnt').AsString   := registro.FieldByName('LineaEnt').AsString;
      historico.FieldByName('Registro').AsInteger  := registro.FieldByName('Registro').AsInteger;
      historico.FieldByName('repartidor').AsString := registro.FieldByName('repartidor').AsString;
      historico.FieldByName('vuelto').AsFloat      := registro.FieldByName('vuelto').AsFloat;
      try
        historico.Post
      except
       historico.Cancel
      end;
    end;
    registro.Next;
  end;

  datosdb.tranSQL('DELETE FROM ' + registro.TableName + ' WHERE fecha <= ' + '''' + utiles.sExprFecha2000(xfecha) + '''');
  Bloqueo := False;
  desconectar;
end;

procedure  TTCallerId.Listar(xtitulo: String; salida: Char);
// Objetivo...: Generar Informe de Llamadas
var
  cantidad: Integer;
Begin
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, xtitulo, 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Nº Teléfono', 1, 'Arial, cursiva, 8');
  List.Titulo(20, List.Lineactual, 'Nombre', 2, 'Arial, cursiva, 8');
  List.Titulo(55, List.lineactual, 'Dirección', 3, 'Arial, cursiva, 8');
  List.Titulo(80, List.lineactual, 'Fecha y Hora de LLamada', 4, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  registro.First; cantidad := 0;
  while not registro.Eof do Begin
    list.Linea(0, 0, registro.FieldByName('nrotel').AsString, 1, 'Arial, normal, 8', salida, 'N');
    list.Linea(20, list.Lineactual, registro.FieldByName('nombre').AsString, 2, 'Arial, normal, 8', salida, 'N');
    list.Linea(55, list.Lineactual, registro.FieldByName('direccion').AsString, 3, 'Arial, normal, 8', salida, 'N');
    list.Linea(80, list.Lineactual, registro.FieldByName('fecha1').AsString + '  ' + registro.FieldByName('hora').AsString, 4, 'Arial, normal, 8', salida, 'S');
    registro.Next;
    Inc(cantidad);
  end;
  if cantidad > 0 then Begin
    list.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');
    list.Linea(0, 0, 'Nro. de Llamadas Listadas:      ' + IntToStr(cantidad), 1, 'Arial, negrita, 8', salida, 'S');
  end else
    list.Linea(0, 0, 'No Existen Llamadas para Listar ...!', 1, 'Arial, normal, 10', salida, 'S');

  list.FinList;
  verificarFiltro;
  Bloqueo := False;
end;

procedure TTCallerId.ListarPorFechas(xdfecha, xhfecha: String; salida: Char);
Begin
  Bloqueo := True;
  datosdb.QuitarFiltro(registro);
  datosdb.Filtrar(registro, 'fecha >= ' + '''' + utiles.sExprfecha(xdfecha) + '''' + ' and fecha <= ' + '''' + utiles.sExprFecha(xhfecha) + '''');
  Listar('LLamadas Registradas entre:   ' + xdfecha + ' - ' + xhfecha, salida);
end;

procedure TTCallerId.ListarNumerosConocidos(xdfecha, xhfecha: String; salida: Char);
Begin
  Bloqueo := True;
  datosdb.QuitarFiltro(registro);
  datosdb.Filtrar(registro, 'nombre <> ' + '''' + '*** Desconocido ***' + '''' + ' and fecha >= ' + '''' + utiles.sExprfecha(xdfecha) + '''' + ' and fecha <= ' + '''' + utiles.sExprFecha(xhfecha) + '''');
  Listar('LLamadas de Números Existentes', salida);
end;

procedure TTCallerId.ListarNumerosDesconocidos(xdfecha, xhfecha: String; salida: Char);
Begin
  Bloqueo := True;
  datosdb.QuitarFiltro(registro);
  datosdb.Filtrar(registro, 'nombre = ' + '''' + '*** Desconocido ***' + '''' + ' and fecha >= ' + '''' + utiles.sExprfecha(xdfecha) + '''' + ' and fecha <= ' + '''' + utiles.sExprFecha(xhfecha) + '''');
  Listar('LLamadas de Números Inexistentes', salida);
end;

procedure  TTCallerId.EstablecerHoraNuevoPedido(xhora: String);
Begin
  if horainiciopedidos.RecordCount = 0 then horainiciopedidos.Append else horainiciopedidos.Edit;
  horainiciopedidos.FieldByName('hora').AsString := xhora;
  horainiciopedidos.Post;
  HoraParaIniciarNumeroPedido := xhora;
end;

function TTCallerId.setCompletarNumeroCelular(xnrotel: String): String;
var
  xnro: String;
Begin
  if Copy(TrimLeft(xnrotel), 1, 1) < '5' then xnro := Trim(xnrotel) else xnro := '15' + Trim(xnrotel);
  Result := Trim(xnro);
end;

procedure  TTCallerId.conectar;
Begin
  if conexiones = 0 then Begin
    if not registro.Active then Begin
      registro.Open;
      registro.FieldByName('Nrotel').DisplayLabel := 'Nro. Tél.'; registro.FieldByName('Nombre').DisplayLabel := 'Nombre'; registro.FieldByName('Direccion').DisplayLabel := 'Dirección'; registro.FieldByName('Fecha1').DisplayLabel := 'Fecha'; registro.FieldByName('Hora').DisplayLabel := 'Hora'; registro.FieldByName('Direccion').DisplayWidth := 33; registro.FieldByName('lineaEnt').DisplayLabel := 'Linea Ent.'; registro.FieldByName('Registro').DisplayLabel := 'Ped.'; registro.FieldByName('Registro').DisplayWidth := 5; registro.FieldByName('repartidor').DisplayLabel := 'Repartidor'; registro.FieldByName('Vuelto').DisplayLabel := 'Vuelto';
      registro.FieldByName('Registro').Index := 0; registro.FieldByName('Nrotel').Index := 1; registro.FieldByName('Fecha1').Index := 2; registro.FieldByName('Hora').Index := 3; registro.FieldByName('Nombre').Index := 4;
      registro.FieldByName('Fecha').Visible := False;
      registro.Last;
    end;
    if not inicarnuevopedido.Active then inicarnuevopedido.Open;
    if not horainiciopedidos.Active then  horainiciopedidos.Open;
    if not historico.Active then Begin
      historico.Open;
      historico.FieldByName('Nrotel').DisplayLabel := 'Nro. Tél.'; historico.FieldByName('Nombre').DisplayLabel := 'Nombre'; historico.FieldByName('Direccion').DisplayLabel := 'Dirección'; historico.FieldByName('Fecha1').DisplayLabel := 'Fecha'; historico.FieldByName('Hora').DisplayLabel := 'Hora'; historico.FieldByName('Direccion').DisplayWidth := 33; historico.FieldByName('lineaEnt').DisplayLabel := 'Linea Ent.'; historico.FieldByName('Registro').DisplayLabel := 'Ped.'; historico.FieldByName('Registro').DisplayWidth := 5; historico.FieldByName('repartidor').DisplayLabel := 'Repartidor'; historico.FieldByName('Vuelto').DisplayLabel := 'Vuelto';
      historico.FieldByName('Registro').Index := 0; historico.FieldByName('Nrotel').Index := 1; historico.FieldByName('Fecha1').Index := 2; historico.FieldByName('Hora').Index := 3; historico.FieldByName('Nombre').Index := 4;
      historico.FieldByName('Fecha').Visible := False;
      historico.Last;
    end;
    if horainiciopedidos.recordcount > 0 then HoraParaIniciarNumeroPedido := horainiciopedidos.FieldByName('hora').AsString else HoraParaIniciarNumeroPedido := '06:00';
  end;
  Inc(conexiones);
end;

procedure  TTCallerId.desconectar;
Begin
  if conexiones > 0 then Dec(conexiones);
  if conexiones = 0 then Begin
    if registro.Active then registro.Close;
    if inicarnuevopedido.Active then  inicarnuevopedido.Close;
    if horainiciopedidos.Active then  horainiciopedidos.Close;
    if historico.Active then historico.Close;
  end;
end;

{===============================================================================}

function llamada: TTCallerId;
begin
  if xllamada = nil then
    xllamada := TTCallerId.Create;
  Result := xllamada;
end;

{===============================================================================}

initialization

finalization
  xllamada.Free;

end.
