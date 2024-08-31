unit CRegistracionLlamadasTelefonicas;

interface

uses SysUtils, DBTables, CUtiles, CIDBFM, CListar, CBDT, ProcesandoDatos, Forms,
     CClientDamevin;

type

TTCallerIDCentral = class(TObject)
  Nrotel, Nombre, Direccion, Fecha, Hora, LineaEntrada, Interno, Ring, Transf, Linea, Duracion, HoraParaIniciarNumeroPedido, NroLinea, TelLinea: String;
  llamadasEnt, llamadasSal, IniciarRegEntrantes, IniciarRegSalientes, horainiciopedidos, registro, bloqueos, lineas, hE, hS: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  function    Buscar(xfecha, xhora, xnrotel, xinterno: String; xregistro: TTable): Boolean;
  procedure   Registrar(xfecha, xhora, xnrotel, xinterno, xring, xtransf, xlinea, xduracion, xES, xnombre, xdireccion, xpagblan: String; xregistro: Integer);
  procedure   Corregir(xfecha, xhora, xnrotel, xinterno, xnombre, xdireccion, xES: String);
  procedure   Borrar(xfecha, xhora, xnrotel, xinterno, xregistro, xES: String);
  procedure   getDatos(xfecha, xhora, xnrotel, xinterno, xES: String);  // hasta aca stored proc

  function    ActualizarGuia: String; overload;
  function    ActualizarGuia(xnrotel, xnombre, xdireccion: String): String; overload;

  procedure   FiltrarPorFecha(xfecha: String);
  procedure   FiltrarTelefonosConocidos;
  procedure   FiltrarTelefonosDesconocidos;
  procedure   QuitarFiltro;
  procedure   verificarFiltro;

  procedure   ListarPorFechas(xdfecha, xhfecha: String; xEntSal, salida: Char);
  procedure   ListarNumerosConocidos(xdfecha, xhfecha: String; xEntSal, salida: Char);
  procedure   ListarNumerosDesconocidos(xdfecha, xhfecha: String; xEntSal, salida: Char);

  procedure   EstablecerHoraNuevoPedido(xhora: String);
  function    setCompletarNumeroCelular(xnrotel: String): String;

  procedure   GuardarLinea(xlinea, xnrotel: String);
  procedure   BorrarLinea(xlinea: String);
  procedure   getDatosLinea(xlinea: String);

  procedure   Refrescar;

  procedure   DepurarLlamadasEntrantes(xfecha: String);
  procedure   DepurarLlamadasSalientes(xfecha: String);

  procedure   conectar;
  procedure   desconectar;

  procedure   conectarHistorico;
  procedure   desconectarHistorico;
 private
  { Declaraciones Privadas }
  conexiones, nroentrada, nrosalida: Integer; Filtro: String;
  stp: TStoredProc;
  procedure   Depurar(xfecha: String);
  procedure   Listar(xtitulo: String; salida: Char);
  function    NumeroDePedido(xfecha, xhora, xES: String): Integer;
  procedure   InitTable(registro: TTable);
  procedure   Bloquear(xtabla: TTable; xbloquear: Boolean);
  function    verificarBloqueo(xtabla: TTable): Boolean;
end;

function llamada: TTCallerIDCentral;

implementation

var
  xllamada: TTCallerIDCentral = nil;

constructor TTCallerIDCentral.Create;
begin
  inherited Create;
  llamadasEnt         := datosdb.openDB('llamadasEnt', '');
  llamadasSal         := datosdb.openDB('llamadasSal', '');
  IniciarRegEntrantes := datosdb.openDB('IniciarRegEntrantes', '');
  IniciarRegSalientes := datosdb.openDB('IniciarRegSalientes', '');
  horainiciopedidos   := datosdb.openDB('horainiciopedidos', '');
  bloqueos            := datosdb.openDB('bloqueos', '');
  lineas              := datosdb.openDB('lineas', '');
  nroentrada          := 0;
  nrosalida           := 0;
end;

destructor TTCallerIDCentral.Destroy;
begin
  inherited Destroy;
end;

function  TTCallerIDCentral.Buscar(xfecha, xhora, xnrotel, xinterno: String; xregistro: TTable): Boolean;
Begin
  if dbs.StoredProc = 'N' then Begin
    if xregistro.IndexFieldNames <> 'Fecha;Hora;Nrotel;Interno' then xregistro.IndexFieldNames := 'Fecha;Hora;Nrotel;Interno';
    if Copy(xfecha, 3, 1) = '/' then Result := datosdb.Buscar(xregistro, 'Fecha', 'Hora', 'Nrotel', 'Interno', utiles.sExprFecha2000(xfecha), xhora, Trim(xnrotel), xinterno) else Result := datosdb.Buscar(registro, 'Fecha', 'Hora', 'Nrotel', 'Interno', xfecha, xhora, xnrotel, xinterno);
  end;
  if dbs.StoredProc = 'S' then Begin
    stp := datosdb.crearStoredProc(dbs.baseDat, 'buscarllamada');
    if Copy(xfecha, 3, 1) = '/' then stp.ParamByName('fecha').AsString := utiles.sExprFecha2000(xfecha) else stp.ParamByName('fecha').AsString := xfecha;
    stp.ParamByName('hora').AsString    := xhora;
    stp.ParamByName('nrotel').AsString  := Trim(xnrotel);
    stp.ParamByName('interno').AsString := xinterno;
    if lowercase(xregistro.TableName) = 'llamadasent' then stp.ParamByName('tipo_llamada').AsString := 'E';
    if lowercase(xregistro.TableName) = 'llamadassal' then stp.ParamByName('tipo_llamada').AsString := 'S';
    stp.ExecProc;
    if stp.ParamByName('encontrado').AsInteger = 0 then Result := False else Result := True;
    stp.Free;
  end;
end;

procedure   TTCallerIDCentral.Registrar(xfecha, xhora, xnrotel, xinterno, xring, xtransf, xlinea, xduracion, xES, xnombre, xdireccion, xpagblan: String; xregistro: Integer);
var
  nroPedido: Integer;
Begin
  if dbs.StoredProc = 'N' then Begin
    registro := TTable.Create(nil);
    if xES = 'E' then registro := llamadasEnt else registro := llamadasSal;  // Determinamos la tabla de acuerdo al tipo de llamada
    Bloquear(registro, True);
    datosdb.QuitarFiltro(registro);
    getDatosLinea(xlinea);
    if Buscar(xfecha, xhora, xnrotel, xinterno, registro) then registro.Edit else Begin
      registro.Append;
      nroPedido := NumeroDePedido(xfecha, Copy(xhora, 1, 5), xES);
      registro.FieldByName('fecha').AsString     := utiles.sExprFecha2000(xfecha);
      registro.FieldByName('hora').AsString      := xhora;
      registro.FieldByName('nrotel').AsString    := Trim(xnrotel);
      registro.FieldByName('interno').AsString   := xinterno;
      registro.FieldByName('Registro').AsInteger := nroPedido;
    end;
    registro.FieldByName('nombre').AsString    := UpperCase(xnombre);
    registro.FieldByName('direccion').AsString := xdireccion;
    registro.FieldByName('fecha1').AsString    := xfecha;
    registro.FieldByName('ring').AsString      := xring;
    registro.FieldByName('Transf').AsString    := xtransf;
    registro.FieldByName('Linea').AsString     := xlinea;
    registro.FieldByName('Duracion').AsString  := xduracion;
    registro.FieldByName('Lineaent').AsString  := TelLinea;
    try
      registro.Post
     except
      registro.Cancel
    end;
    Bloquear(registro, False);
    verificarFiltro;
    Buscar(xfecha, xhora, xnrotel, xinterno, registro);
  end;
  if dbs.StoredProc = 'S' then Begin
    registro := TTable.Create(nil);
    if xES = 'E' then registro := llamadasEnt else registro := llamadasSal;  // Determinamos la tabla de acuerdo al ti
    Bloquear(registro, True);
    getDatosLinea(xlinea);
    if not Buscar(xfecha, xhora, xnrotel, xinterno, registro) then nroPedido := NumeroDePedido(xfecha, Copy(xhora, 1, 5), xES) else nroPedido := 0;
    stp := datosdb.crearStoredProc(dbs.baseDat, 'registrarllamada');
    stp.ParamByName('fecha').AsString        := utiles.sExprFecha2000(xfecha);
    stp.ParamByName('hora').AsString         := xhora;
    stp.ParamByName('nrotel').AsString       := Trim(xnrotel);
    stp.ParamByName('interno').AsString      := xinterno;
    stp.ParamByName('registro').AsInteger    := nropedido;
    stp.ParamByName('nombre').AsString       := Copy(UpperCase(xnombre), 1, 40);
    stp.ParamByName('direccion').AsString    := Copy(xdireccion, 1, 35);
    stp.ParamByName('fecha1').AsString       := xfecha;
    stp.ParamByName('ring').AsString         := xring;
    stp.ParamByName('transf').AsString       := xtransf;
    stp.ParamByName('linea').AsString        := xlinea;
    stp.ParamByName('duracion').AsString     := xduracion;
    stp.ParamByName('lineaent').AsString     := tellinea;
    stp.ParamByName('tipo_llamada').AsString := xes;
    stp.ParamByName('pagblan').AsString      := xpagblan;
    stp.ExecProc;
    stp.Free;
    Bloquear(registro, False);
    verificarFiltro;
    Buscar(xfecha, xhora, xnrotel, xinterno, registro);
    refrescar;
  end;
end;

procedure  TTCallerIDCentral.Corregir(xfecha, xhora, xnrotel, xinterno, xnombre, xdireccion, xES: String);
Begin
  if dbs.StoredProc = 'N' then Begin
    registro := TTable.Create(nil);
    if xES = 'E' then registro := llamadasEnt else registro := llamadasSal;  // Determinamos la tabla de acuerdo al tipo de llamada
    Bloquear(registro, True);
    datosdb.QuitarFiltro(registro);
    if Buscar(xfecha, xhora, xnrotel, xinterno, registro) then Begin
      registro.Edit;
      registro.FieldByName('fecha').AsString     := utiles.sExprFecha2000(xfecha);
      registro.FieldByName('hora').AsString      := xhora;
      registro.FieldByName('nrotel').AsString    := Trim(xnrotel);
      registro.FieldByName('interno').AsString   := xinterno;
      registro.FieldByName('nombre').AsString    := xnombre;
      registro.FieldByName('direccion').AsString := xdireccion;
      try
        registro.Post
       except
        registro.Cancel
      end;
    end;
    Bloquear(registro, False);
    verificarFiltro;
    Buscar(xfecha, xhora, xnrotel, xinterno, registro);
  end;
  if dbs.StoredProc = 'S' then Begin
    registro := TTable.Create(nil);
    if xES = 'E' then registro := llamadasEnt else registro := llamadasSal;  // Determinamos la tabla de acuerdo al tipo de llamada
    Bloquear(registro, True);
    datosdb.QuitarFiltro(registro);
    if Buscar(xfecha, xhora, xnrotel, xinterno, registro) then Begin
      stp := datosdb.crearStoredProc(dbs.baseDat, 'corregirentrada');
      stp.ParamByName('fecha').AsString        := utiles.sExprFecha2000(xfecha);
      stp.ParamByName('hora').AsString         := xhora;
      stp.ParamByName('nrotel').AsString       := Trim(xnrotel);
      stp.ParamByName('interno').AsString      := xinterno;
      stp.ParamByName('nombre').AsString       := Copy(xnombre, 1, 40);
      stp.ParamByName('direccion').AsString    := Copy(xdireccion, 1, 35);
      stp.ParamByName('tipo_llamada').AsString := xes;
      stp.ExecProc;
      stp.Free;
    end;
    verificarFiltro;
    Bloquear(registro, False);
    refrescar;
    Buscar(xfecha, xhora, xnrotel, xinterno, registro);
  end;
end;

function   TTCallerIDCentral.NumeroDePedido(xfecha, xhora, xES: String): Integer;
var
  np: Integer; hora: String;
  iniciarnuevopedido, registro: TTable;
Begin
  if xES = 'E' then iniciarnuevopedido := IniciarRegEntrantes else iniciarnuevopedido := IniciarRegSalientes;
  if xES = 'E' then registro := llamadasEnt else registro := llamadasSal;  // Determinamos la tabla de acuerdo al tipo de llamada
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

procedure  TTCallerIDCentral.Borrar(xfecha, xhora, xnrotel, xinterno, xregistro, xES: String);
Begin
  registro := TTable.Create(nil);
  if xES = 'E' then registro := llamadasEnt else registro := llamadasSal;  // Determinamos la tabla de acuerdo al tipo de llamada
  Bloquear(registro, True);
  datosdb.QuitarFiltro(registro);
  if dbs.StoredProc = 'N' then Begin
    datosdb.tranSQL('DELETE FROM ' + registro.TableName + ' WHERE fecha = ' + '"' + xfecha + '"' + ' AND hora = ' + '"' + xhora + '"' + ' AND nrotel = ' + '"' + Trim(xnrotel) + '"' + ' AND interno = ' + '"' + xinterno + '"' + ' AND registro = ' + '"' + xregistro + '"');
  end else Begin
    stp := datosdb.crearStoredProc(dbs.baseDat, 'borrarllamada');
    stp.ParamByName('fecha').AsString        := xfecha;
    stp.ParamByName('hora').AsString         := xhora;
    stp.ParamByName('nrotel').AsString       := Trim(xnrotel);
    stp.ParamByName('interno').AsString      := xinterno;
    stp.ParamByName('registro').AsString     := xregistro;
    stp.ParamByName('tipo_llamada').AsString := xes;
    stp.ExecProc;
    stp.Free;
  end;
  Bloquear(registro, False);
  verificarFiltro;
  registro.Last;
end;

procedure  TTCallerIDCentral.getDatos(xfecha, xhora, xnrotel, xinterno, xES: String);
Begin
  if xES = 'E' then registro := llamadasEnt else registro := llamadasSal;  // Determinamos la tabla de acuerdo al tipo de llamada
  Bloquear(registro, True);
  datosdb.QuitarFiltro(registro);
  if dbs.StoredProc = 'N' then Begin
    if Buscar(xfecha, xhora, xnrotel, xinterno, registro) then Begin
      NroTel       := Trim(registro.FieldByName('Nrotel').AsString);
      Nombre       := registro.FieldByName('nombre').AsString;
      Direccion    := registro.FieldByName('direccion').AsString;
      Ring         := registro.FieldByName('ring').AsString;
      Transf       := registro.FieldByName('transf').AsString;
      Linea        := registro.FieldByName('linea').AsString;
      Duracion     := registro.FieldByName('duracion').AsString;
    end else Begin
      Nrotel := ''; Nombre := ''; Direccion := ''; Ring := ''; Transf := ''; Linea := ''; Duracion := '';
    end;
  end;
  if dbs.StoredProc = 'S' then Begin
    stp := datosdb.crearStoredProc(dbs.baseDat, 'getllamada');
    stp.ParamByName('fecha').AsString        := utiles.sExprFecha2000(xfecha);
    stp.ParamByName('hora').AsString         := xhora;
    stp.ParamByName('nrotel').AsString       := Trim(xnrotel);
    stp.ParamByName('interno').AsString      := xinterno;
    stp.ParamByName('tipo_llamada').AsString := xes;
    stp.ExecProc;
    stp.Free;
  end;
  Bloquear(registro, False);
  verificarFiltro;
end;

function  TTCallerIDCentral.ActualizarGuia: String;
// Objetivo...: Actualizar Guía con los datos entrantes
Begin
  registro := llamadasEnt;
  stp := datosdb.crearStoredProc(dbs.baseDat, 'actualizarcliente');
  stp.ParamByName('nrotel').AsString    := Trim(registro.FieldByName('Nrotel').AsString);
  stp.ParamByName('nombre').AsString    := registro.FieldByName('nombre').AsString;
  stp.ParamByName('direccion').AsString := registro.FieldByName('direccion').AsString;
  stp.ExecProc;
  stp.Free;
  Result := Trim(registro.FieldByName('Nrotel').AsString);
end;

function  TTCallerIDCentral.ActualizarGuia(xnrotel, xnombre, xdireccion: String): String;
// Objetivo...: Actualizar Guía con los datos entrantes
Begin
  registro := llamadasEnt;
  stp := datosdb.crearStoredProc(dbs.baseDat, 'actualizarcliente');
  stp.ParamByName('nrotel').AsString    := xnrotel;
  stp.ParamByName('nombre').AsString    := xnombre;
  stp.ParamByName('direccion').AsString := xdireccion;
  stp.ExecProc;
  stp.Free;
  Result := xnrotel;
end;

procedure  TTCallerIDCentral.FiltrarPorFecha(xfecha: String);
Begin
  Bloquear(registro, True);
  Filtro  := 'fecha = ' + utiles.sExprFecha2000(xfecha);
  datosdb.Filtrar(registro, Filtro);
  registro.Last;
  Bloquear(registro, False);
end;

procedure  TTCallerIDCentral.FiltrarTelefonosConocidos;
Begin
  Bloquear(registro, True);
  Filtro  := 'nombre <> ' + '''' + '*** Desconocido ***' + '''';
  datosdb.Filtrar(registro, Filtro);
  registro.Last;
  Bloquear(registro, True);
end;

procedure  TTCallerIDCentral.FiltrarTelefonosDesconocidos;
Begin
  Bloquear(registro, True);
  Filtro  := 'nombre = ' + '''' + '*** Desconocido ***' + '''';
  datosdb.Filtrar(registro, Filtro);
  registro.Last;
  Bloquear(registro, False);
end;

procedure  TTCallerIDCentral.QuitarFiltro;
Begin
  Bloquear(registro, True);
  datosdb.QuitarFiltro(registro);
  registro.Last;
  Bloquear(registro, False);
end;

procedure  TTCallerIDCentral.verificarFiltro;
Begin
  if Length(Trim(Filtro)) > 0 then Begin
    Bloquear(registro, True);
    datosdb.Filtrar(registro, Filtro);
    registro.Last;
    Bloquear(registro, False);
  end else
    datosdb.QuitarFiltro(registro);
end;

procedure TTCallerIDCentral.GuardarLinea(xlinea, xnrotel: String);
Begin
  if lineas.FindKey([xlinea]) then lineas.Edit else lineas.Append;
  lineas.FieldByName('linea').AsString  := xlinea;
  lineas.FieldByName('nrotel').AsString := xnrotel;
  try
    lineas.Post
   except
    lineas.Cancel
  end;
end;

procedure TTCallerIDCentral.BorrarLinea(xlinea: String);
Begin
  if lineas.FindKey([xlinea]) then lineas.Delete;
end;

procedure TTCallerIDCentral.getDatosLinea(xlinea: String);
Begin
  if not lineas.Active then lineas.Open;
  if lineas.FindKey([xlinea]) then TelLinea := lineas.FieldByName('nrotel').AsString else TelLinea := '';
end;

procedure TTCallerIDCentral.Refrescar;
Begin
  if not verificarBloqueo(llamadasEnt) then Begin
    if llamadasEnt.IndexName <> 'llamadasent_reg' then llamadasEnt.IndexName := 'llamadasent_reg';
    llamadasEnt.Refresh;
    llamadasEnt.Last;
  end;
  if not verificarBloqueo(llamadasSal) then Begin
    if llamadasSal.IndexName <> 'llamadassal_reg' then llamadasSal.IndexName := 'llamadassal_reg';
    llamadasSal.Refresh;
    llamadasSal.Last;
  end;
end;

procedure  TTCallerIDCentral.Depurar(xfecha: String);
// Objetivo...: Depurar Registro de Llamadas
{var
  t: TTable;
  i: Integer;
  v: String;}
Begin

  {if Lowercase(registro.TableName) = 'llamadasent' then v := 'Llamadas Entrantes.';
  if Lowercase(registro.TableName) = 'llamadassal' then v := 'Llamadas Salientes.';
  utiles.MsgProcesandoDatos('Iniciando ' + v);
  if Lowercase(registro.TableName) = 'llamadasent' then t := datosdb.openDB('llamadasenthist', '');
  if Lowercase(registro.TableName) = 'llamadassal' then t := datosdb.openDB('llamadassalhist', '');
  t.Open; i := 0;
  registro.IndexFieldNames := 'Fecha;Hora';
  registro.First;
  while not registro.Eof do Begin
    utiles.MsgProcesandoDatos(IntToStr(i) + ' registros procesados. ' + v);
    if registro.FieldByName('Fecha').AsString <= utiles.sExprFecha2000(xfecha) then Begin
      Inc(i);
      if datosdb.Buscar(t, 'Fecha', 'Hora', 'Nrotel', 'Interno', registro.FieldByName('fecha').AsString, registro.FieldByName('hora').AsString, registro.FieldByName('nrotel').AsString, registro.FieldByName('interno').AsString) then t.Edit else t.Append;
      t.FieldByName('fecha').AsString     := registro.FieldByName('fecha').AsString;
      t.FieldByName('hora').AsString      := registro.FieldByName('hora').AsString;
      t.FieldByName('nrotel').AsString    := registro.FieldByName('nrotel').AsString;
      t.FieldByName('interno').AsString   := registro.FieldByName('interno').AsString;
      t.FieldByName('nombre').AsString    := registro.FieldByName('nombre').AsString;
      t.FieldByName('direccion').AsString := registro.FieldByName('direccion').AsString;
      t.FieldByName('fecha1').AsString    := registro.FieldByName('fecha1').AsString;
      t.FieldByName('lineaent').AsString  := registro.FieldByName('lineaent').AsString;
      t.FieldByName('registro').AsInteger := registro.FieldByName('registro').AsInteger;
      t.FieldByName('ring').AsString      := registro.FieldByName('ring').AsString;
      t.FieldByName('transf').AsString    := registro.FieldByName('transf').AsString;
      t.FieldByName('linea').AsString     := registro.FieldByName('linea').AsString;
      t.FieldByName('duracion').AsString  := registro.FieldByName('duracion').AsString;
      try
        t.Post
      except
        t.Cancel
      end;
    end;
    registro.Next;
    if registro.FieldByName('Fecha').AsString > utiles.sExprFecha2000(xfecha) then Break;
  end;
  datosdb.tranSQL('DELETE FROM ' + registro.TableName + ' WHERE fecha <= ' + '''' + utiles.sExprFecha2000(xfecha) + '''');
  t.Close; t.Free;
  utiles.MsgFinalizarProcesandoDatos;}
end;

procedure TTCallerIDCentral.DepurarLlamadasEntrantes(xfecha: String);
Begin
  stp := datosdb.crearStoredProc(dbs.baseDat, 'borrarllamadas');
  stp.ParamByName('tipo_llamada').AsString := 'E';
  stp.ParamByName('fecha').AsString        := utiles.sExprFecha2000(xfecha);
  stp.ExecProc;
  stp.Free;
  //registro := LlamadasEnt;
  //Depurar(xfecha);
end;

procedure TTCallerIDCentral.DepurarLlamadasSalientes(xfecha: String);
Begin
  stp := datosdb.crearStoredProc(dbs.baseDat, 'borrarllamadas');
  stp.ParamByName('tipo_llamada').AsString := 'S';
  stp.ParamByName('fecha').AsString        := utiles.sExprFecha2000(xfecha);
  stp.ExecProc;
  stp.Free;
  //registro := LlamadasSal;
  //Depurar(xfecha);
end;

procedure  TTCallerIDCentral.Listar(xtitulo: String; salida: Char);
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
  Bloquear(registro, False);

  if cantidad > 0 then Begin
    list.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');
    list.Linea(0, 0, 'Nro. de Llamadas Listadas:      ' + IntToStr(cantidad), 1, 'Arial, negrita, 8', salida, 'S');
  end else
    list.Linea(0, 0, 'No Existen Llamadas para Listar ...!', 1, 'Arial, normal, 10', salida, 'S');

  list.FinList;
  verificarFiltro;
end;

procedure TTCallerIDCentral.ListarPorFechas(xdfecha, xhfecha: String; xEntSal, salida: Char);
Begin
  if xEntSal = 'E' then registro := llamadasEnt else registro := llamadasSal;
  Bloquear(registro, True);
  datosdb.QuitarFiltro(registro);
  datosdb.Filtrar(registro, 'fecha >= ' + '''' + utiles.sExprfecha2000(xdfecha) + '''' + ' and fecha <= ' + '''' + utiles.sExprFecha2000(xhfecha) + '''');
  Listar('LLamadas Registradas entre:   ' + xdfecha + ' - ' + xhfecha, salida);
end;

procedure TTCallerIDCentral.ListarNumerosConocidos(xdfecha, xhfecha: String; xEntSal, salida: Char);
Begin
  if xEntSal = 'E' then registro := llamadasEnt else registro := llamadasSal;
  Bloquear(registro, True);
  datosdb.QuitarFiltro(registro);
  datosdb.Filtrar(registro, 'nombre <> ' + '''' + '*** Desconocido ***' + '''' + ' and fecha >= ' + '''' + utiles.sExprfecha2000(xdfecha) + '''' + ' and fecha <= ' + '''' + utiles.sExprFecha2000(xhfecha) + '''');
  Listar('LLamadas de Números Existentes', salida);
end;

procedure TTCallerIDCentral.ListarNumerosDesconocidos(xdfecha, xhfecha: String; xEntSal, salida: Char);
Begin
  if xEntSal = 'E' then registro := llamadasEnt else registro := llamadasSal;
  Bloquear(registro, True);
  datosdb.QuitarFiltro(registro);
  datosdb.Filtrar(registro, 'nombre = ' + '''' + '*** Desconocido ***' + '''' + ' and fecha >= ' + '''' + utiles.sExprfecha2000(xdfecha) + '''' + ' and fecha <= ' + '''' + utiles.sExprFecha2000(xhfecha) + '''');
  Listar('LLamadas de Números Inexistentes', salida);
end;

procedure  TTCallerIDCentral.EstablecerHoraNuevoPedido(xhora: String);
Begin
  if horainiciopedidos.RecordCount = 0 then horainiciopedidos.Append else horainiciopedidos.Edit;
  horainiciopedidos.FieldByName('hora').AsString := xhora;
  horainiciopedidos.Post;
  datosdb.refrescar(horainiciopedidos);
  HoraParaIniciarNumeroPedido := xhora;
end;

function TTCallerIDCentral.setCompletarNumeroCelular(xnrotel: String): String;
var
  xnro: String;
Begin
  if Copy(TrimLeft(xnrotel), 1, 1) < '5' then xnro := TrimLeft(xnrotel) else xnro := '15' + TrimLeft(xnrotel);
  if Copy(TrimLeft(xnrotel), 1, 2) = '44' then xnro := '15' + TrimLeft(xnrotel);
  Result := xnro;
end;

procedure  TTCallerIDCentral.InitTable(registro: TTable);
Begin
  //utiles.msgError(registro.TableName);
  if not registro.Active then Begin
    registro.Open;
    registro.FieldByName('Nrotel').DisplayLabel := 'Nro. Tél.'; registro.FieldByName('Nrotel').DisplayWidth := 10; registro.FieldByName('Registro').DisplayWidth := 14; registro.FieldByName('Nombre').DisplayLabel := 'Nombre'; registro.FieldByName('Direccion').DisplayLabel := 'Dirección'; registro.FieldByName('Fecha1').DisplayLabel := 'Fecha'; registro.FieldByName('Hora').DisplayLabel := 'Hora'; registro.FieldByName('Nombre').DisplayWidth := 35; registro.FieldByName('Direccion').DisplayWidth := 33; registro.FieldByName('lineaEnt').DisplayLabel := 'Linea Ent.'; registro.FieldByName('Registro').DisplayLabel := 'Nº'; registro.FieldByName('Registro').DisplayWidth := 4;
    registro.FieldByName('Interno').DisplayLabel := 'Int.'; registro.FieldByName('Registro').DisplayWidth := 4; registro.FieldByName('Ring').DisplayLabel := 'Ring'; registro.FieldByName('Ring').DisplayWidth := 2; registro.FieldByName('Transf').DisplayLabel := 'Trans.'; registro.FieldByName('Registro').DisplayWidth := 5; registro.FieldByName('Linea').DisplayLabel := 'Linea'; registro.FieldByName('Registro').DisplayWidth := 3; registro.FieldByName('duracion').DisplayLabel := 'Duración'; registro.FieldByName('Duracion').DisplayWidth := 6;
    registro.FieldByName('Registro').Index := 0; registro.FieldByName('Nrotel').Index := 1; registro.FieldByName('Fecha1').Index := 2; registro.FieldByName('Hora').Index := 3; registro.FieldByName('Nombre').Index := 4; registro.FieldByName('Duracion').Index := 7; registro.FieldByName('Direccion').Index := 6; registro.FieldByName('Interno').Index := 8;
    registro.FieldByName('Fecha').Visible := False;
    registro.Last;
  end;
end;

procedure  TTCallerIDCentral.Bloquear(xtabla: TTable; xbloquear: Boolean);
// Objetivo...: Bloquear tabla para procesos de escritura
Begin
  if Bloqueos.FindKey([xtabla.TableName]) then Bloqueos.Edit else Begin
    Bloqueos.Append;
    Bloqueos.FieldByName('tabla').AsString := xtabla.TableName;
  end;
  if xbloquear then Bloqueos.FieldByName('estado').AsString := 'B' else Bloqueos.FieldByName('estado').AsString := 'L';
  try
    Bloqueos.Post
   except
    Bloqueos.Cancel
  end;
end;

function   TTCallerIDCentral.verificarBloqueo(xtabla: TTable): Boolean;
// Objetivo...: Verificar Bloqueo
Begin
  Result := False;
  if Bloqueos.FindKey([xtabla.TableName]) then
    if Bloqueos.FieldByName('estado').AsString = 'B' then Result := True else Result := False;
end;

procedure  TTCallerIDCentral.conectar;
Begin
  if conexiones = 0 then Begin
    InitTable(llamadasEnt);
    InitTable(llamadasSal);
    if not IniciarRegEntrantes.Active  then  IniciarRegEntrantes.Open;
    if not IniciarRegSalientes.Active  then  IniciarRegSalientes.Open;
    if not horainiciopedidos.Active    then  horainiciopedidos.Open;
    if not Bloqueos.Active             then  Bloqueos.Open;
    if not lineas.Active               then  lineas.Open;
    if horainiciopedidos.recordcount > 0 then HoraParaIniciarNumeroPedido := horainiciopedidos.FieldByName('hora').AsString else HoraParaIniciarNumeroPedido := '06:00';
  end;
  Inc(conexiones);
  Refrescar;
end;

procedure  TTCallerIDCentral.desconectar;
Begin
  if conexiones > 0 then Dec(conexiones);
  if conexiones = 0 then Begin
    if llamadasEnt.Active          then  llamadasEnt.Close;
    if llamadasSal.Active          then  llamadasSal.Close;
    if IniciarRegEntrantes.Active  then  IniciarRegEntrantes.Close;
    if IniciarRegSalientes.Active  then  IniciarRegSalientes.Close;
    if Bloqueos.Active             then  Bloqueos.Close;
    if lineas.Active               then  lineas.Close;
  end;
end;

procedure TTCallerIDCentral.conectarHistorico;
Begin
  hE := datosdb.openDB('llamadasenthist', 'Fecha;Hora');
  hS := datosdb.openDB('llamadassalhist', 'Fecha;Hora');
  hE.Open; hS.Open;
  hE.FieldByName('Nrotel').DisplayLabel := 'Nro. Tél.'; hE.FieldByName('Nrotel').DisplayWidth := 10; hE.FieldByName('registro').DisplayWidth := 14; hE.FieldByName('Nombre').DisplayLabel := 'Nombre'; hE.FieldByName('Direccion').DisplayLabel := 'Dirección'; hE.FieldByName('Fecha1').DisplayLabel := 'Fecha'; hE.FieldByName('Hora').DisplayLabel := 'Hora'; hE.FieldByName('Nombre').DisplayWidth := 35; hE.FieldByName('Direccion').DisplayWidth := 33; hE.FieldByName('lineaEnt').DisplayLabel := 'Linea Ent.'; hE.FieldByName('registro').DisplayLabel := 'Nº'; hE.FieldByName('registro').DisplayWidth := 4;
  hE.FieldByName('Interno').DisplayLabel := 'Int.'; hE.FieldByName('registro').DisplayWidth := 4; hE.FieldByName('Ring').DisplayLabel := 'Ring'; hE.FieldByName('Ring').DisplayWidth := 2; hE.FieldByName('Transf').DisplayLabel := 'Trans.'; hE.FieldByName('registro').DisplayWidth := 5; hE.FieldByName('Linea').DisplayLabel := 'Linea'; hE.FieldByName('registro').DisplayWidth := 3; hE.FieldByName('duracion').DisplayLabel := 'Duración'; hE.FieldByName('Duracion').DisplayWidth := 6;
  hE.FieldByName('registro').Index := 0; hE.FieldByName('Nrotel').Index := 1; hE.FieldByName('Fecha1').Index := 2; hE.FieldByName('Hora').Index := 3; hE.FieldByName('Nombre').Index := 4; hE.FieldByName('Duracion').Index := 7; hE.FieldByName('Direccion').Index := 6; hE.FieldByName('Interno').Index := 8;
  hE.FieldByName('Fecha').Visible := False;
  hS.FieldByName('Nrotel').DisplayLabel := 'Nro. Tél.'; hS.FieldByName('Nrotel').DisplayWidth := 10; hS.FieldByName('registro').DisplayWidth := 14; hS.FieldByName('Nombre').DisplayLabel := 'Nombre'; hS.FieldByName('Direccion').DisplayLabel := 'Dirección'; hS.FieldByName('Fecha1').DisplayLabel := 'Fecha'; hS.FieldByName('Hora').DisplayLabel := 'Hora'; hS.FieldByName('Nombre').DisplayWidth := 35; hS.FieldByName('Direccion').DisplayWidth := 33; hS.FieldByName('lineaEnt').DisplayLabel := 'Linea Ent.'; hS.FieldByName('registro').DisplayLabel := 'Nº'; hS.FieldByName('registro').DisplayWidth := 4;
  hS.FieldByName('Interno').DisplayLabel := 'Int.'; hS.FieldByName('registro').DisplayWidth := 4; hS.FieldByName('Ring').DisplayLabel := 'Ring'; hS.FieldByName('Ring').DisplayWidth := 2; hS.FieldByName('Transf').DisplayLabel := 'Trans.'; hS.FieldByName('registro').DisplayWidth := 5; hS.FieldByName('Linea').DisplayLabel := 'Linea'; hS.FieldByName('registro').DisplayWidth := 3; hS.FieldByName('duracion').DisplayLabel := 'Duración'; hS.FieldByName('Duracion').DisplayWidth := 6;
  hS.FieldByName('registro').Index := 0; hS.FieldByName('Nrotel').Index := 1; hS.FieldByName('Fecha1').Index := 2; hS.FieldByName('Hora').Index := 3; hS.FieldByName('Nombre').Index := 4; hS.FieldByName('Duracion').Index := 7; hS.FieldByName('Direccion').Index := 6; hS.FieldByName('Interno').Index := 8;
  hS.FieldByName('Fecha').Visible := False;
end;

procedure TTCallerIDCentral.desconectarHistorico;
Begin
  hE.Close; hS.Close;
  hE.Free; hS.Free;
end;


{===============================================================================}

function llamada: TTCallerIDCentral;
begin
  if xllamada = nil then
    xllamada := TTCallerIDCentral.Create;
  Result := xllamada;
end;

{===============================================================================}

initialization

finalization
  xllamada.Free;

end.
