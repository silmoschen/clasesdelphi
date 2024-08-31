unit CLLamadasEntrantes;

interface

uses SysUtils, DBTables, CUtiles, CIDBFM, CListar;

type

TTCallerID = class(TObject)
  Nrotel, Nombre, Direccion, Fecha, Hora, LineaEntrada, Interno, Ring, Transf, Linea, Duracion, HoraParaIniciarNumeroPedido: String;
  NroLlamadasEntrantes, NroLlamadasSalientes: Integer;
  llamadasEnt, llamadasSal, IniciarRegEntrantes, IniciarRegSalientes, horainiciopedidos, registro: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  function    Buscar(xfecha, xhora, xnrotel, xinterno: String; registro: TTable): Boolean;
  procedure   Registrar(xfecha, xhora, xnrotel, xinterno, xring, xtransf, xlinea, xduracion, xES, xnombre, xdireccion: String);
  procedure   Corregir(xfecha, xhora, xnrotel, xinterno, xnombre, xdireccion, xES: String);
  procedure   Borrar(xfecha, xhora, xnrotel, xinterno, xES: String);
  procedure   getDatos(xfecha, xhora, xnrotel, xinterno, xES: String);

  procedure   FiltrarPorFecha(xfecha, xES: String);
  procedure   FiltrarTelefonosConocidos(xES: String);
  procedure   FiltrarTelefonosDesconocidos(xES: String);
  procedure   QuitarFiltro(xES: String);
  procedure   verificarFiltro(xES: String);

  procedure   ListarPorFechas(xdfecha, xhfecha, xES: String; salida: Char);
  procedure   ListarNumerosConocidos(xdfecha, xhfecha, xES: String; salida: Char);
  procedure   ListarNumerosDesconocidos(xdfecha, xhfecha, xES: String; salida: Char);

  procedure   EstablecerHoraNuevoPedido(xhora: String);
  function    setCompletarNumeroCelular(xnrotel: String): String;

  procedure   Refrescar;
  procedure   Depurar(xfecha: String);

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  conexiones: Integer; Bloqueo: Boolean; Filtro: String;
  procedure   Listar(xtitulo, xES: String; salida: Char);
  function    NumeroDePedido(xfecha, xhora, xES: String): Integer;
  procedure   InitTable(registro: TTable);
end;

function llamada: TTCallerId;

implementation

var
  xllamada: TTCallerId = nil;

constructor TTCallerId.Create;
begin
  inherited Create;
  llamadasEnt         := datosdb.openDB('llamadasEnt', 'Fecha;Hora');
  llamadasSal         := datosdb.openDB('llamadasSal', 'Fecha;Hora');
  IniciarRegEntrantes := datosdb.openDB('IniciarRegEntrantes', '');
  IniciarRegSalientes := datosdb.openDB('IniciarRegSalientes', '');
  horainiciopedidos   := datosdb.openDB('horainiciopedidos', '');
end;

destructor TTCallerId.Destroy;
begin
  inherited Destroy;
end;

function  TTCallerId.Buscar(xfecha, xhora, xnrotel, xinterno: String; registro: TTable): Boolean;
Begin
  if registro.IndexFieldNames <> 'Fecha;Hora;Nrotel;Interno' then registro.IndexFieldNames := 'Fecha;Hora;Nrotel;Interno';
  if Copy(xfecha, 3, 1) = '/' then Result := datosdb.Buscar(registro, 'Fecha', 'Hora', 'Nrotel', 'Interno', utiles.sExprFecha(xfecha), xhora, xnrotel, xinterno) else Result := datosdb.Buscar(registro, 'Fecha', 'Hora', 'Nrotel', 'Interno', xfecha, xhora, xnrotel, xinterno);
end;

procedure   TTCallerId.Registrar(xfecha, xhora, xnrotel, xinterno, xring, xtransf, xlinea, xduracion, xES, xnombre, xdireccion: String);
var
  nroPedido: Integer;
Begin
  if xES = 'E' then registro := llamadasEnt else registro := llamadasSal;  // Determinamos la tabla de acuerdo al tipo de llamada
  Bloqueo   := True; datosdb.QuitarFiltro(registro);
  nroPedido := NumeroDePedido(xfecha, Copy(xhora, 1, 5), xES);
  if Buscar(xfecha, xhora, xnrotel, xinterno, registro) then registro.Edit else registro.Append;
  registro.FieldByName('fecha').AsString      := utiles.sExprFecha(xfecha);
  registro.FieldByName('hora').AsString       := xhora;
  registro.FieldByName('nrotel').AsString     := xnrotel;
  registro.FieldByName('nombre').AsString     := UpperCase(xnombre);
  registro.FieldByName('direccion').AsString  := xdireccion;
  registro.FieldByName('fecha1').AsString     := xfecha;
  registro.FieldByName('Registro').AsInteger  := nroPedido;
  registro.FieldByName('interno').AsString    := xinterno;
  registro.FieldByName('ring').AsString       := xring;
  registro.FieldByName('Transf').AsString     := xtransf;
  registro.FieldByName('Linea').AsString      := xlinea;
  registro.FieldByName('Duracion').AsString   := xduracion;
  try
    registro.Post
   except
    registro.Cancel
  end;
  if xES = 'E' then NroLlamadasEntrantes := nroPedido else NroLlamadasSalientes := nroPedido;
  Bloqueo := False; verificarFiltro(xES);
  Buscar(xfecha, xhora, xnrotel, xinterno, registro);
end;

procedure  TTCallerId.Corregir(xfecha, xhora, xnrotel, xinterno, xnombre, xdireccion, xES: String);
// Objetivo...: Corregir/Ajustar Entrada
Begin
  if xES = 'E' then registro := llamadasEnt else registro := llamadasSal;  // Determinamos la tabla de acuerdo al tipo de llamada
  Bloqueo   := True; datosdb.QuitarFiltro(registro);
  if Buscar(xfecha, xhora, xnrotel, xinterno, registro) then Begin
    registro.Edit;
    registro.FieldByName('nombre').AsString     := UpperCase(xnombre);
    registro.FieldByName('direccion').AsString  := xdireccion;
    try
      registro.Post
     except
      registro.Cancel
    end;
  end;
  Bloqueo := False; verificarFiltro(xES);
  Buscar(xfecha, xhora, xnrotel, xinterno, registro);
end;

function   TTCallerId.NumeroDePedido(xfecha, xhora, xES: String): Integer;
var
  np: Integer; hora: String;
  iniciarnuevopedido: TTable;
Begin
  if xES = 'E' then iniciarnuevopedido := IniciarRegEntrantes else iniciarnuevopedido := IniciarRegSalientes;
  hora := utiles.setHoraActual24(xhora + ':00');
  hora := Copy(hora, 1, 5);
  if iniciarnuevopedido.RecordCount = 0 then Begin
    np := 1;
    iniciarnuevopedido.Append;
    iniciarnuevopedido.FieldByName('Fecha').AsString := xfecha;
    iniciarnuevopedido.FieldByName('Numero').AsInteger := np;
  end else Begin
    iniciarnuevopedido.Edit;
    if (iniciarnuevopedido.FieldByName('Fecha').AsString <> xfecha) and (hora >= HoraParaIniciarNumeroPedido) then np := 1 else np  := iniciarnuevopedido.FieldByName('Numero').AsInteger + 1;
    if np = 1 then iniciarnuevopedido.FieldByName('Fecha').AsString := xfecha;
    iniciarnuevopedido.FieldByName('Numero').AsInteger := np;
  end;
  iniciarnuevopedido.FieldByName('hora').AsString    := hora;
  iniciarnuevopedido.FieldByName('Estado').AsString  := 'I';
  iniciarnuevopedido.Post;
  Result := np;
end;

procedure  TTCallerId.Borrar(xfecha, xhora, xnrotel, xinterno, xES: String);
Begin
  if xES = 'E' then registro := llamadasEnt else registro := llamadasSal;  // Determinamos la tabla de acuerdo al tipo de llamada
  Bloqueo := True; datosdb.QuitarFiltro(registro);
  if Buscar(xfecha, xhora, xnrotel, xinterno, registro) then registro.Delete;
  Bloqueo := False; verificarFiltro(xES);
  registro.Last;
end;

procedure  TTCallerId.getDatos(xfecha, xhora, xnrotel, xinterno, xES: String);
Begin
  if xES = 'E' then registro := llamadasEnt else registro := llamadasSal;  // Determinamos la tabla de acuerdo al tipo de llamada
  Bloqueo := True; datosdb.QuitarFiltro(registro);
  if Buscar(xfecha, xhora, xnrotel, xinterno, registro) then Begin
    NroTel       := registro.FieldByName('Nrotel').AsString;
    Nombre       := registro.FieldByName('nombre').AsString;
    Direccion    := registro.FieldByName('direccion').AsString;
    Ring         := registro.FieldByName('ring').AsString;
    Transf       := registro.FieldByName('transf').AsString;
    Linea        := registro.FieldByName('linea').AsString;
    Duracion     := registro.FieldByName('duracion').AsString;
  end else Begin
    Nrotel := ''; Nombre := ''; Direccion := ''; Ring := ''; Transf := ''; Linea := ''; Duracion := '';
  end;
  Bloqueo := False; verificarFiltro(xES);
end;

procedure  TTCallerId.FiltrarPorFecha(xfecha, xES: String);
Begin
  if xES = 'E' then registro := llamadasEnt else registro := llamadasSal;
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
// Objetivo...: Refrescar registro de llamadas
Begin
  if not Bloqueo then Begin
    if llamadasEnt.IndexFieldNames <> 'Fecha;Registro' then llamadasEnt.IndexFieldNames := 'Fecha;Registro';
    llamadasEnt.Refresh;
    llamadasEnt.Last;
    if llamadasSal.IndexFieldNames <> 'Fecha;Registro' then llamadasSal.IndexFieldNames := 'Fecha;Registro';
    llamadasSal.Refresh;
    llamadasSal.Last;
  end;
end;

procedure  TTCallerId.Depurar(xfecha: String);
// Objetivo...: Depurar Registro de Llamadas
Begin
  {conectar;
  Bloqueo := True;
  registro.First;
  while not registro.Eof do Begin
    if registro.FieldByName('Fecha').AsString <= utiles.sExprFecha(xfecha) then Begin
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

  datosdb.tranSQL('DELETE FROM ' + registro.TableName + ' WHERE fecha <= ' + '''' + utiles.sExprFecha(xfecha) + '''');
  Bloqueo := False;
  desconectar;}
end;

procedure  TTCallerId.Listar(xtitulo, xES: String; salida: Char);
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
  verificarFiltro(xES);
  Bloqueo := False;
end;

procedure TTCallerId.ListarPorFechas(xdfecha, xhfecha, xES: String; salida: Char);
Begin
  Bloqueo := True;
  datosdb.QuitarFiltro(registro);
  datosdb.Filtrar(registro, 'fecha >= ' + '''' + utiles.sExprfecha(xdfecha) + '''' + ' and fecha <= ' + '''' + utiles.sExprFecha(xhfecha) + '''');
  Listar('LLamadas Registradas entre:   ' + xdfecha + ' - ' + xhfecha, xES, salida);
end;

procedure TTCallerId.ListarNumerosConocidos(xdfecha, xhfecha, xES: String; salida: Char);
Begin
  Bloqueo := True;
  datosdb.QuitarFiltro(registro);
  datosdb.Filtrar(registro, 'nombre <> ' + '''' + '*** Desconocido ***' + '''' + ' and fecha >= ' + '''' + utiles.sExprfecha(xdfecha) + '''' + ' and fecha <= ' + '''' + utiles.sExprFecha(xhfecha) + '''');
  Listar('LLamadas de Números Existentes', xES, salida);
end;

procedure TTCallerId.ListarNumerosDesconocidos(xdfecha, xhfecha, xES: String; salida: Char);
Begin
  Bloqueo := True;
  datosdb.QuitarFiltro(registro);
  datosdb.Filtrar(registro, 'nombre = ' + '''' + '*** Desconocido ***' + '''' + ' and fecha >= ' + '''' + utiles.sExprfecha(xdfecha) + '''' + ' and fecha <= ' + '''' + utiles.sExprFecha(xhfecha) + '''');
  Listar('LLamadas de Números Inexistentes', xES, salida);
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
  if Copy(TrimLeft(xnrotel), 1, 1) < '5' then xnro := TrimLeft(xnrotel) else xnro := '15' + TrimLeft(xnrotel);
  Result := xnro;
end;

procedure  TTCallerId.InitTable(registro: TTable);
Begin
  if not registro.Active then Begin
    registro.Open;
    registro.FieldByName('Nrotel').DisplayLabel := 'Nro. Tél.'; registro.FieldByName('Nrotel').DisplayWidth := 10; registro.FieldByName('Registro').DisplayWidth := 14; registro.FieldByName('Nombre').DisplayLabel := 'Nombre'; registro.FieldByName('Direccion').DisplayLabel := 'Dirección'; registro.FieldByName('Fecha1').DisplayLabel := 'Fecha'; registro.FieldByName('Hora').DisplayLabel := 'Hora'; registro.FieldByName('Nombre').DisplayWidth := 35; registro.FieldByName('Direccion').DisplayWidth := 33; registro.FieldByName('lineaEnt').DisplayLabel := 'Linea Ent.'; registro.FieldByName('Registro').DisplayLabel := 'Nº'; registro.FieldByName('Registro').DisplayWidth := 4;
    registro.FieldByName('Interno').DisplayLabel := 'Int.'; registro.FieldByName('Registro').DisplayWidth := 4; registro.FieldByName('Ring').DisplayLabel := 'Ring'; registro.FieldByName('Ring').DisplayWidth := 2; registro.FieldByName('Transf').DisplayLabel := 'Trans.'; registro.FieldByName('Registro').DisplayWidth := 5; registro.FieldByName('Linea').DisplayLabel := 'Linea'; registro.FieldByName('Registro').DisplayWidth := 3; registro.FieldByName('duracion').DisplayLabel := 'Duración'; registro.FieldByName('Duracion').DisplayWidth := 6;
    registro.FieldByName('Registro').Index := 0; registro.FieldByName('Nrotel').Index := 1; registro.FieldByName('Fecha1').Index := 2; registro.FieldByName('Hora').Index := 3; registro.FieldByName('Nombre').Index := 4; registro.FieldByName('Duracion').Index := 7; registro.FieldByName('Direccion').Index := 6; registro.FieldByName('Interno').Index := 8;
    registro.FieldByName('Fecha').Visible := False;
    registro.Last;
  end;
end;

procedure  TTCallerId.conectar;
Begin
  if conexiones = 0 then Begin
    InitTable(llamadasEnt);
    InitTable(llamadasSal);
    if not IniciarRegEntrantes.Active  then  IniciarRegEntrantes.Open;
    if not IniciarRegSalientes.Active  then  IniciarRegSalientes.Open;
    if not horainiciopedidos.Active    then  horainiciopedidos.Open;
    if horainiciopedidos.recordcount > 0 then HoraParaIniciarNumeroPedido := horainiciopedidos.FieldByName('hora').AsString else HoraParaIniciarNumeroPedido := '06:00';
    NroLlamadasEntrantes := IniciarRegEntrantes.FieldByName('Numero').AsInteger;
    NroLlamadasSalientes := IniciarRegSalientes.FieldByName('Numero').AsInteger;
  end;
  Inc(conexiones);
end;

procedure  TTCallerId.desconectar;
Begin
  if conexiones > 0 then Dec(conexiones);
  if conexiones = 0 then Begin
    if llamadasEnt.Active          then  llamadasEnt.Close;
    if llamadasSal.Active          then  llamadasSal.Close;
    if IniciarRegEntrantes.Active  then  IniciarRegEntrantes.Close;
    if IniciarRegSalientes.Active  then  IniciarRegSalientes.Close;
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
