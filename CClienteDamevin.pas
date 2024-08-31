unit CClienteDamevin;

interface

uses CPersona, CListar, CUtiles, SysUtils, DB, DBTables, CBDT, CIDBFM, contenedorMemo, Forms;

const meses: array[1..12] of string = ('Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Setiembre', 'Octubre', 'Noviembre', 'Diciembre');

type

 TTCliente = class
  Codigo, Nombre, Domicilio, Codpost, Orden, Barrio, Email, Codcli, Fechanac, idcarta, carta, fuente, ciudad, localidad, letra, observa, fecha, fechaenvio: string; Existe, TelAlternativos, Filtro: boolean;
  orientacion: shortint;
  TelefonoExistente: Boolean;
  telefonos, numercli, listcartasenv: TTable; // Tablas para la Persistencia de Objetos
  tperso, modcarta: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;
  procedure   Grabar(xtelefono, xnombre, xdomicilio, xbarrio, xemail, xcodcli, xfechanac, xciudad, xlocalidad, xcp, xobserva, xfecha: string);
  function    Borrar(xtelefono: string): string;
  function    Buscar(xtelefono: string): boolean;
  procedure   getDatos(xtelefono: string);
  procedure   Listar(orden, iniciar, finalizar, ent_excl: string; salida: char); overload;
  procedure   Listar(orden, iniciar, finalizar: string; salida: char); overload;
  function    setClientesAlf: TQuery;
  procedure   BuscarPorNombre(xnombre: string);
  procedure   BuscarPorDireccion(xdireccion: string);
  procedure   BuscarPorTelefono(xcodigo: string);
  procedure   BuscarPorNumero(xcodigo: string);
  procedure   BuscarTelefono(xcodigo: string);
  procedure   GuardarTelefono(xnrotelefono: string);
  procedure   BorrarTelefono(xnrotelefono: string);
  function    setClientes: TQuery;
  function    setTelefonos: TQuery;
  function    setTelefonosAlt: TQuery;
  procedure   OrdenarAlfabeticamente;
  procedure   OrdenarPorNumero;
  procedure   OrdenarPorTelefono;
  function    getCodcli: string;
  function    getTelAlt: boolean;
  function    getNroClientes: integer;
  function    getLista: string;
  function    setNroTelefono(xnrotel: String): String;

  function    BuscarPorCodigo(xcodcli: string): boolean;
  function    NuevoCliente(xnrotel: string): string;
  procedure   AjustarCodCliente(xletra: string; xnumero: integer);
  function    getNumero(xletra: string): string;
  function    EstablecerNumero(xnrotel, xletra: string): String;
  procedure   FiltrarPorNumero;
  function    setClientesNumerados: TQuery;
  function    setClientesQueRecibieronCartas: TQuery;
  procedure   QuitarMarcaEnvioCarta(xnrotel: string);
  procedure   FiltrarLosQueRecibieronCarta;
  procedure   FijarFiltroPorCodPost(xcodpost: string);
  procedure   QuitarFiltro;
  function    CantidadDeClientes: Integer;

  procedure   GuardarModeloCarta(xidcarta, xcuerpo, xfuente: string; xorientacion: shortint);
  procedure   BorrarCarta;
  procedure   getDatosCarta(xidcarta: string);
  procedure   ListCarta(xidcarta, xnrotel: string; salida: char; guardarEnvio: Boolean);
  function    setCartas: TQuery;
  procedure   ArmarCarta(xidcarta, xnrotel: string; salida: char; guardarEnvio: Boolean);
  procedure   ListarCartas(salida: char);
  function    setCartasEnviadas(xidcarta: string): TQuery;
  procedure   BorrarCartasEnviadas(xidcarta, xnrotel, xfecha: string);
  function    BuscarCartasEnviadas(xidcarta, xnrotel: string): Boolean;
  procedure   Refrescar;

  procedure   conectar;
  procedure   desconectar;
 protected
  { Declaraciones Protegidas }
  StoredProc: TStoredProc;
 private
  { Declaraciones Privadas }
  conexiones: shortint; seteoImpr: boolean; fe: String;
  procedure   List_linea(salida: char);
end;

function cliente: TTCliente;

implementation

var
  xcliente: TTCliente = nil;

constructor TTCliente.Create;
// Vendedor - Heredada de Persona
begin
  tperso        := datosdb.openDB('clientes', 'Nrotel');
  telefonos     := datosdb.openDB('telefonos', 'Nrotel;Telalt');
  numercli      := datosdb.openDB('numercli', 'Letra');
  modcarta      := datosdb.openDB('modcarta', 'Idcarta');
  listcartasenv := datosdb.openDB('listcartasenv', 'Idcarta;Nrotel');
end;

destructor TTCliente.Destroy;
begin
  inherited Destroy;
end;

procedure TTCliente.Grabar(xtelefono, xnombre, xdomicilio, xbarrio, xemail, xcodcli, xfechanac, xciudad, xlocalidad, xcp, xobserva, xfecha: string);
// Objetivo...: Grabar Atributos del cliente
var
  r, f: boolean;
begin
  f := Filtro;
  if f then QuitarFiltro;
  if Buscar(xtelefono) then tperso.Edit else tperso.Append;
  tperso.Fields[0].AsString := xtelefono;
  tperso.Fields[1].AsString := xnombre;
  tperso.Fields[2].AsString := xdomicilio;
  tperso.FieldByName('nrocliente').AsString := xcodcli;
  tperso.FieldByName('observa').AsString    := xobserva;
  tperso.FieldByName('barrio').AsString     := xbarrio;
  tperso.FieldByName('email').AsString      := xemail;
  tperso.FieldByName('ciudad').AsString     := xciudad;
  tperso.FieldByName('localidad').AsString  := xlocalidad;
  tperso.FieldByName('fechanac').AsString   := utiles.sExprFecha(xfechanac);
  if Length(Trim(xfecha)) = 8 then tperso.FieldByName('fecha').AsString := utiles.sExprFecha(xfecha) else tperso.FieldByName('fecha').AsString := utiles.sExprFecha(utiles.setFechaActual);
  try
    tperso.Post
  except
    tperso.Cancel
  end;
  tperso.Refresh;
  if f then FiltrarPorNumero;
end;

function TTCliente.CantidadDeClientes: Integer;
// Objetivo...: retornar el número de clientes
begin
  Result := tperso.RecordCount;
end;

procedure  TTCliente.getDatos(xtelefono: string);
// Objetivo...: Obtener/Inicializar los Atributos para un objeto cliente
var
  l: Boolean;
begin
  l := False;
  if tperso.Fields[0].AsString = xtelefono then l := True else l := Buscar(xtelefono);
  if l then Begin
    codigo    := tperso.Fields[0].AsString;
    nombre    := tperso.Fields[1].AsString;
    domicilio := tperso.Fields[2].AsString;
    codpost   := tperso.Fields[3].AsString;
    orden     := tperso.Fields[4].AsString;
    barrio    := tperso.FieldByName('barrio').AsString;
    email     := tperso.FieldByName('email').AsString;
    fechanac  := utiles.sFormatoFecha(tperso.FieldByName('fechanac').AsString);
    ciudad    := tperso.FieldByName('ciudad').AsString;
    localidad := tperso.FieldByName('localidad').AsString;
  end else Begin
    codigo := ''; nombre := ''; domicilio := ''; codpost := ''; orden := ''; barrio := ''; email := ''; fechanac := ''; ciudad := ''; localidad := ''; codcli := '';
  end;
  if Length(Trim(nombre)) > 0 then Begin
    codcli  := tperso.FieldByName('nrocliente').AsString;
    observa := tperso.FieldByName('observa').AsString;
    fecha   := utiles.sFormatoFecha(tperso.FieldByName('fecha').AsString);
  end;
end;

function TTCliente.Borrar(xtelefono: string): string;
// Objetivo...: Eliminar un Instancia de cliente
begin
  if tperso.IndexFieldNames <> 'Nrotel' then tperso.IndexFieldNames := 'Nrotel';
  if Buscar(xtelefono) then Begin
    if dbs.StoredProc = 'N' then Begin  // Eliminación directa
      //datosdb.tranSQL('DELETE FROM ' + tperso.TableName + ' WHERE Nrotel = ' + '"' + xtelefono + '"');
      tperso.Delete; tperso.Refresh;
    end;
    if dbs.StoredProc = 'S' then Begin  // Llamada a un Procedimiento almacenado
      StoredProc := TStoredProc.Create(nil);
      StoredProc.DatabaseName := dbs.baseDat;
      StoredProc.StoredProcName := 'BorrarCliente';
      StoredProc.Params.Clear;
      StoredProc.Params.CreateParam(ftString, '@nrotel', ptInput);
      StoredProc.ParamByName('@nrotel').Text := xtelefono;
      StoredProc.ExecProc;
    end;
    getDatos(tperso.FieldByName('nrotel').AsString);  // Fijamos los Atributos Siguientes al Objeto Borrado
  end;
end;

function TTCliente.Buscar(xtelefono: string): boolean;
// Objetivo...: Verificar si Existe el cliente
begin
  if tperso.IndexFieldNames <> 'Nrotel' then tperso.IndexFieldNames := 'Nrotel';
  if telefonos.FindKey([xtelefono]) then TelAlternativos := True else TelAlternativos := False;
  telefonos.IndexFieldNames := 'Nrotel;Telalt';
  TelefonoExistente := tperso.FindKey([xtelefono]);
  Result := TelefonoExistente;
end;

function TTCliente.getNroClientes: integer;
// Objetivo...: devolver el nro. de clientes
begin
  Result := tperso.RecordCount;
end;

procedure TTCliente.List_linea(salida: char);
// Objetivo...: Listar una Línea
begin
  codcli := tperso.FieldByName('nrocliente').AsString;
  List.Linea(0, 0, tperso.FieldByName('nrotel').AsString, 1, 'Arial, normal, 8', salida, 'N');
  List.Linea(15, List.Lineactual, tperso.FieldByName('nombre').AsString, 2, 'Arial, normal, 8', salida, 'N');
  List.Linea(45, List.lineactual, tperso.FieldByName('direccion').AsString, 3, 'Arial, normal, 8', salida, 'N');
  List.Linea(75, List.lineactual, tperso.FieldByName('barrio').AsString, 4, 'Arial, normal, 8', salida, 'N');
  List.Linea(98, List.lineactual, codcli, 5, 'Arial, normal, 8', salida, 'S');
end;

procedure TTCliente.Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
// Objetivo...: Listar Datos de Provincias
begin
  if orden = 'A' then tperso.IndexName := tperso.IndexDefs.Items[1].Name;

  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Listado de la guía de teléfonos', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Nº Teléfono', 1, 'Arial, cursiva, 8');
  List.Titulo(15, List.Lineactual, 'Nombre', 2, 'Arial, cursiva, 8');
  List.Titulo(45, List.lineactual, 'Dirección', 3, 'Arial, cursiva, 8');
  List.Titulo(75, List.lineactual, 'Barrio', 4, 'Arial, cursiva, 8');
  List.Titulo(98, List.lineactual, 'Código', 5, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  tperso.First;
  while not tperso.EOF do
    begin
      // Ordenado por Código
      if (ent_excl = 'E') and (orden = 'C') then
        if (tperso.FieldByName('nrotel').AsString >= iniciar) and (tperso.FieldByName('nrotel').AsString <= finalizar) then List_linea(salida);
      if (ent_excl = 'X') and (orden = 'C') then
        if (tperso.FieldByName('nrolel').AsString < iniciar) or (tperso.FieldByName('nrotel').AsString > finalizar) then List_linea(salida);
      // Ordenado Alfabéticamente
      if (ent_excl = 'E') and (orden = 'A') then
        if (tperso.FieldByName('nombre').AsString >= iniciar) and (tperso.FieldByName('nombre').AsString <= finalizar) then List_linea(salida);
      if (ent_excl = 'X') and (orden = 'A') then
        if (tperso.FieldByName('nombre').AsString < iniciar) or (tperso.FieldByName('nombre').AsString > finalizar) then List_linea(salida);

      tperso.Next;
    end;
    List.FinList;

    tperso.IndexFieldNames := tperso.IndexFieldNames;
    tperso.First;
end;

procedure TTCliente.Listar(orden, iniciar, finalizar: string; salida: char);
// Objetivo...: Listar clientes por número
var
  x: string; r: TQuery;
begin
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Listado de Clientes por Número', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, '        Nº Cliente', 1, 'Arial, cursiva, 8');
  List.Titulo(15, List.Lineactual, 'Nombre', 2, 'Arial, cursiva, 8');
  List.Titulo(45, List.lineactual, 'Dirección', 3, 'Arial, cursiva, 8');
  List.Titulo(75, List.lineactual, 'Teléfono', 4, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  if orden <> 'A' then Begin

    tperso.First;

    while not tperso.EOF do Begin
      if Length(Trim(tperso.FieldByName('Nrocliente').AsString)) > 0 then Begin
       if (tperso.FieldByName('Nrocliente').AsString >= iniciar) and (tperso.FieldByName('Nrocliente').AsString <= finalizar) then Begin
        if Copy(tperso.FieldByName('nrocliente').AsString, 1, 1) <> x then Begin
          List.Linea(0, 0, Copy(tperso.FieldByName('nrocliente').AsString, 1, 1), 1, 'Arial, negrita, 16', salida, 'S');
          List.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');
        end;
        List.Linea(0, 0, '        ' + tperso.FieldByName('nrocliente').AsString, 1, 'Arial, normal, 8', salida, 'N');
        List.Linea(10, List.lineactual, tperso.FieldByName('nombre').AsString, 2, 'Arial, normal, 8', salida, 'N');
        List.Linea(45, List.lineactual, tperso.FieldByName('direccion').AsString, 3, 'Arial, normal, 8', salida, 'N');
        List.Linea(75, List.lineactual, tperso.FieldByName('nrotel').AsString, 4, 'Arial, normal, 8', salida, 'S');
        x := Copy(tperso.FieldByName('nrocliente').AsString, 1, 1);
       end;
      end;
      tperso.Next;
    end;

  end else Begin

    r := datosdb.tranSQL('SELECT * FROM ' + tperso.TableName + ' WHERE nrocliente > ' + '""' + ' ORDER BY nrocliente, nombre');
    r.Open; r.First;
    while not r.EOF do Begin
      if Length(Trim(r.FieldByName('Nrocliente').AsString)) > 0 then Begin
        if Copy(r.FieldByName('nrocliente').AsString, 1, 1) <> x then Begin
          List.Linea(0, 0, Copy(r.FieldByName('nrocliente').AsString, 1, 1), 1, 'Arial, negrita, 16', salida, 'S');
          List.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');
        end;
        List.Linea(0, 0, '        ' + r.FieldByName('nrocliente').AsString, 1, 'Arial, normal, 8', salida, 'N');
        List.Linea(10, List.lineactual, r.FieldByName('nombre').AsString, 2, 'Arial, normal, 8', salida, 'N');
        List.Linea(45, List.lineactual, r.FieldByName('direccion').AsString, 3, 'Arial, normal, 8', salida, 'N');
        List.Linea(75, List.lineactual, r.FieldByName('nrotel').AsString, 4, 'Arial, normal, 8', salida, 'S');
        x := Copy(r.FieldByName('nrocliente').AsString, 1, 1);
      end;
      r.Next;
    end;
    r.Close; r.Free;
  end;

  list.FinList;
end;

function TTCliente.setClientesAlf: TQuery;
// Objetivo...: Devolver un set de clientees ordenados alfabeticamente
begin
  Result := datosdb.tranSQL('SELECT * FROM clientes, clienth WHERE clientes.nrotel = clienth.nrotel ORDER BY nombre');
end;

procedure TTCliente.BuscarPorNombre(xnombre: string);
begin
  if tperso.IndexName <> 'Clientes_Nombre' then tperso.IndexName := 'Clientes_Nombre';
  tperso.FindNearest([xnombre]);
end;

procedure TTCliente.BuscarPorDireccion(xdireccion: string);
begin
  if tperso.IndexName <> 'Direccion' then tperso.IndexName := 'Direccion';
  tperso.FindNearest([xdireccion]);
end;

procedure TTCliente.BuscarPorTelefono(xcodigo: string);
begin
  if telefonos.IndexName <> 'Telalt' then telefonos.IndexName := 'Telalt';
  telefonos.FindNearest([xcodigo]);
  Buscar(telefonos.FieldByName('nrotel').AsString);
end;

procedure TTCliente.BuscarPorNumero(xcodigo: string);
begin
  if tperso.IndexName <> 'Nrocliente' then tperso.IndexName := 'Nrocliente';
  tperso.FindNearest([xcodigo]);
end;

procedure TTCliente.BuscarTelefono(xcodigo: string);
begin
  if tperso.IndexFieldNames <> 'Nrotel' then tperso.IndexFieldNames := 'Nrotel';
  tperso.FindNearest([xcodigo]);
end;

procedure TTCliente.GuardarTelefono(xnrotelefono: string);
begin
  if telefonos.IndexFieldNames <> 'nrotel;telalt' then telefonos.IndexFieldNames := 'nrotel;telalt';
  if not datosdb.Buscar(telefonos, 'nrotel', 'telalt', codigo, xnrotelefono) then telefonos.Append else telefonos.Edit;
  telefonos.FieldByName('nrotel').AsString := codigo;
  telefonos.FieldByName('telalt').AsString := xnrotelefono;
  try
    telefonos.Post
  except
    telefonos.Cancel
  end;
  // Señalamos que existen tel. alternativos
  tperso.Edit;
  tperso.FieldByName('TelAlt').AsString := 'S';
  try
    tperso.Post
  except
    tperso.Cancel
  end;
end;

procedure TTCliente.BorrarTelefono(xnrotelefono: string);
begin
  if telefonos.IndexFieldNames <> 'nrotel;telalt' then telefonos.IndexFieldNames := 'nrotel;telalt';
  if datosdb.Buscar(telefonos, 'nrotel', 'telalt', codigo, xnrotelefono) then telefonos.Delete;

  // Señalamos si no existen mas telefonos alternativos
  telefonos.IndexName := 'Nrotel';
  if not telefonos.FindKey([xnrotelefono]) then Begin
    tperso.Edit;
    tperso.FieldByName('telalt').AsString := ' ';
    try
      tperso.Post
    except
      tperso.Cancel
    end;
  end;
end;

function TTCliente.setTelefonos: TQuery;
begin
  Result := datosdb.tranSQL('SELECT * FROM telefonos WHERE nrotel = ' + '"' + codigo + '"');
end;

function TTCliente.setTelefonosAlt: TQuery;
begin
  Result := datosdb.tranSQL('SELECT telefonos.telalt, clientes.nombre, clientes.nrotel FROM telefonos, clientes WHERE telefonos.nrotel = clientes.nrotel ORDER BY Nombre');
end;

function TTCliente.BuscarPorCodigo(xcodcli: string): boolean;
begin
  tperso.IndexName := 'Nrocliente';
  if tperso.FindKey([xcodcli]) then Result := True else Result := False;
  codigo := tperso.FieldByName('nrotel').AsString;
  tperso.IndexFieldNames := 'Nrotel';
end;

procedure TTCliente.OrdenarAlfabeticamente;
begin
  tperso.IndexFieldNames := 'Nombre';
end;

procedure TTCliente.OrdenarPorNumero;
begin
  tperso.IndexFieldNames := 'Codcli';
end;

procedure TTCliente.OrdenarPorTelefono;
begin
  tperso.IndexFieldNames := 'Nrotel';
end;

function TTCliente.getCodcli: string;
begin
  Result := tperso.FieldByName('nrocliente').AsString;
end;

function TTCliente.NuevoCliente(xnrotel: string): string;
var
  NuevoID: integer;
begin
  getDatos(xnrotel);
  if Length(Trim(cliente.codcli)) = 0 then Begin
    // Extraemos el ultimo Nro. de cliente
    if numercli.FindKey([UpperCase(Copy(cliente.nombre, 1, 1))]) then Begin
      NuevoID := numercli.FieldByName('Nro').AsInteger + 1;
      numercli.Edit;
    end else Begin
      numercli.Append;
      numercli.FieldByName('Letra').AsString := UpperCase(Copy(cliente.nombre, 1, 1));
      NuevoID := 1;
    end;

    numercli.FieldByName('Nro').AsInteger  := NuevoID;
    try
      numercli.Post
     except
      numercli.Cancel
    end;

    if tperso.FindKey([xnrotel]) then Begin
      tperso.Edit;
      tperso.FieldByName('nrotel').AsString     := xnrotel;
      tperso.FieldByName('nrocliente').AsString := UpperCase(Copy(cliente.nombre, 1, 1)) + utiles.sLlenarIzquierda(IntToStr(NuevoID), 4, '0');
      try
        tperso.Post
      except
        tperso.Cancel
      end;
    end;
    Result := UpperCase(Copy(cliente.nombre, 1, 1)) + utiles.sLlenarIzquierda(IntToStr(NuevoID), 4, '0');
  end else Result := cliente.codcli;
end;

function TTCliente.setClientes: TQuery;
// Objetivo...: devolver los sabores seleccionados para un determinado pedido
begin
  Result := datosdb.tranSQL('SELECT * FROM telclientes, clientes WHERE telclientes.nrotel = clientes.nrotel ORDER BY nombre');
end;

procedure TTCliente.AjustarCodCliente(xletra: string; xnumero: integer);
// Objetivo...: Ajustar los parámetros que manejan la numeración
begin
  numercli.Open;
  if not numercli.FindKey([xletra]) then numercli.Append else numercli.Edit;
  numercli.FieldByName('Letra').AsString := xletra;
  numercli.FieldByName('Nro').AsInteger  := xnumero;
  try
    numercli.Post
   except
    numercli.Cancel
  end;
  numercli.Close;
end;

function TTCliente.getNumero(xletra: string): string;
var
  xnro: string; nro: integer; i: string;
begin
  i := tperso.IndexFieldNames;
  tperso.IndexFieldNames := 'Codcli';
  nro := 100;
  repeat
    Inc(nro);
    xnro := xletra + utiles.sLlenarIzquierda(IntToStr(nro), 4, '0');
  until not tperso.FindKey([xnro]);
  Result := xletra + utiles.sLlenarIzquierda(IntToStr(nro), 4, '0');
  tperso.IndexFieldNames := i;
end;

function TTCliente.EstablecerNumero(xnrotel, xletra: string): String;
var
  n: String;
Begin
  n := getNumero(xletra);
  if Buscar(xnrotel) then Begin
    tperso.Edit;
    tperso.FieldByName('nrocliente').AsString := n;
    try
      tperso.Post
     except
      tperso.Cancel
    end;
  end;
  Result := n;
end;

function TTCliente.getTelAlt: boolean;
// Objetivo...: verificar si tiene telefonos alternativos
begin
  if telefonos.FindKey([tperso.FieldByName('nrotel').AsString]) then Result := True else Result := False;
end;

procedure TTCliente.FiltrarPorNumero;
begin
  datosdb.Filtrar(tperso, 'Nrocliente > ' + '''A0000''');
  Filtro := True;
end;

function TTCliente.setClientesNumerados: TQuery;
begin
  Result := datosdb.tranSQL('SELECT clientes.Nrotel, clientes.Nombre, clientes.Nrocliente, clientes.Direccion, clientes.cp FROM ' + tperso.TableName + ' ORDER BY Nombre');
end;

function TTCliente.setClientesQueRecibieronCartas: TQuery;
begin
  Result := datosdb.tranSQL('SELECT * FROM ' + tperso.TableName + ' WHERE RecibioCarta = ' + '''S''');
end;

procedure TTCliente.FiltrarLosQueRecibieronCarta;
begin
  datosdb.Filtrar(tperso, 'RecibioCarta = ' + '''S''');
  Filtro := True;
  tperso.Refresh;
end;

procedure TTCliente.QuitarMarcaEnvioCarta(xnrotel: string);
begin
  if Buscar(xnrotel) then Begin
    tperso.Edit;
    tperso.FieldByName('recibiocarta').AsString := '';
    try
      tperso.Post
    except
      tperso.Cancel
    end
  end;
end;

procedure TTCliente.QuitarFiltro;
begin
  tperso.Filtered := False;
  Filtro := False;
end;

procedure TTCliente.FijarFiltroPorCodPost(xcodpost: string);
begin
  datosdb.Filtrar(tperso, 'cp = ' + xcodpost);
end;

procedure TTCliente.GuardarModeloCarta(xidcarta, xcuerpo, xfuente: string; xorientacion: shortint);
// Objetivo...: Guardar modelo de carta
begin
  modcarta.Open;
  if modcarta.FindKey([xidcarta]) then modcarta.Edit else modcarta.Append;
  modcarta.FieldByName('idcarta').AsString      := xidcarta;
  modcarta.FieldByName('cuerpo').Value          := xcuerpo;
  modcarta.FieldByName('fe').AsString           := xfuente;
  modcarta.FieldByName('orientacion').AsInteger := xorientacion;
  try
    modcarta.Post
  except
    modcarta.Cancel
  end;
  modcarta.Close;
end;

procedure TTCliente.getDatosCarta(xidcarta: string);
// Objetivo...: Recuperar modelo de carta
begin
  modcarta.Open;
  if modcarta.FindKey([xidcarta]) then Begin
    idcarta     := modcarta.FieldByName('idcarta').AsString;
    carta       := modcarta.FieldByName('cuerpo').Value;
    fuente      := modcarta.FieldByName('fe').AsString;
    orientacion := modcarta.FieldByName('orientacion').AsInteger;
  end else Begin
    idcarta := ''; carta := ''; fuente := ''; orientacion := 0;
  end;
  modcarta.Close;
end;

procedure TTCliente.BorrarCarta;
// Objetivo...: Borrar un modelo de carta
begin
  modcarta.Open;
  if modcarta.FindKey([idcarta]) then modcarta.Delete;
  modcarta.Close;
end;

function  TTCliente.setCartas: TQuery;
begin
  Result := datosdb.tranSQL('SELECT * FROM modcarta');
end;

procedure TTCliente.ArmarCarta(xidcarta, xnrotel: string; salida: char; guardarEnvio: Boolean);
begin
  if guardarEnvio then Begin
    if not datosdb.Buscar(listcartasenv, 'Idcarta', 'Nrotel', xidcarta, xnrotel) then listcartasenv.Append else listcartasenv.Edit;
    listcartasenv.FieldByName('Idcarta').AsString := xidcarta;
    listcartasenv.FieldByName('Nrotel').AsString  := xnrotel;
    listcartasenv.FieldByName('Fecha').AsString   := utiles.sExprFecha(utiles.setFechaActual);
    try
      listcartasenv.Post
     except
      listcartasenv.Cancel
     end;
  end;

  if not seteoImpr then list.Setear(salida);
  list.NoImprimirPieDePagina;
  if not modcarta.Active then modcarta.Open;

  modcarta.FindKey([xidcarta]);
  fe := modcarta.FieldByName('fe').AsString;

  list.IniciarMemoImpresiones(modcarta, 'cuerpo', 1000);
  // Remplazamos las etiquetas
  getDatos(xnrotel);
  list.RemplazarEtiquetasEnMemo('#fecha', utiles.setFechaActual);
  list.RemplazarEtiquetasEnMemo('#nombre', Nombre);
  list.RemplazarEtiquetasEnMemo('#direccion', Domicilio);
  list.RemplazarEtiquetasEnMemo('#telefono', codigo);
  list.RemplazarEtiquetasEnMemo('#codigo', codcli);
  list.RemplazarEtiquetasEnMemo('#localidad', localidad);
  list.RemplazarEtiquetasEnMemo('#ciudad', ciudad);
  list.ListMemo('', fe, 0, salida, nil, 1000);   // Imprimir la Plantilla
  list.CompletarPagina;
  seteoImpr := True;
end;

procedure TTCliente.ListCarta(xidcarta, xnrotel: string; salida: char; guardarEnvio: Boolean);
Begin
  ArmarCarta(xidcarta, xnrotel, salida, guardarEnvio);
  list.FinList;
  if modcarta.Active then modcarta.Close;
  seteoImpr := False;
end;

procedure TTCliente.ListarCartas(salida: char);
Begin
  list.FinList;
  if modcarta.Active then modcarta.Close;
  seteoImpr := False;
end;

function TTCliente.BuscarCartasEnviadas(xidcarta, xnrotel: string): Boolean;
// Objetivo...: Buscar cartas enviadas
begin
  if datosdb.Buscar(listcartasenv, 'Idcarta', 'Nrotel', xidcarta, xnrotel) then Begin
    fechaenvio := utiles.sFormatoFecha(listcartasenv.FieldByName('fecha').AsString);
    Result := True;
  end else Begin
    fechaenvio := '';
    Result := False;
  end;
end;

function TTCliente.setCartasEnviadas(xidcarta: string): TQuery;
// Objetivo...: devolver un set con las cartas enviadas
begin
  if xidcarta <> '< Todas >' then Result := datosdb.tranSQL('SELECT listcartasenv.idcarta, listcartasenv.Fecha, clientes.Nombre, clientes.Nrotel FROM listcartasenv, clientes WHERE listcartasenv.nrotel = clientes.nrotel AND idcarta = ' + '"' + xidcarta + '"' + ' ORDER BY listcartasenv.Idcarta, clientes.Nombre') else
    Result := datosdb.tranSQL('SELECT listcartasenv.idcarta, listcartasenv.Fecha, clientes.Nombre, clientes.Nrotel FROM listcartasenv, clientes WHERE listcartasenv.nrotel = clientes.nrotel ORDER BY listcartasenv.Idcarta, clientes.Nombre');
end;

procedure TTCliente.BorrarCartasEnviadas(xidcarta, xnrotel, xfecha: string);
// Objetivo...: eliminar una carta enviada
begin
  if datosdb.Buscar(listcartasenv, 'Idcarta', 'Nrotel', xidcarta, xnrotel) then listcartasenv.Delete;
end;

function TTCliente.getLista: string;
// Objetivo...: lista de numeros asignados por letra
var
  l: string;
begin
  numercli.First; l := '';
  while not numercli.EOF do Begin
    l := l + numercli.FieldByName('Letra').AsString + utiles.sLlenarIzquierda(numercli.FieldByName('Nro').AsString, 3, '0') + '   ';
    numercli.Next;
  end;
  Result := l;
end;

function TTCliente.setNroTelefono(xnrotel: String): String;
// Objetivo...: Devolver el nro de telefono solicitado
Begin
  if Buscar(TrimLeft(Copy(xnrotel, 1, 15))) then Begin
    Codigo    := tperso.FieldByName('Nrotel').AsString;
    Nombre    := tperso.FieldByName('Nombre').AsString;
    Domicilio := tperso.FieldByName('Direccion').AsString;
  end else Begin
    Nombre := '*** Desconocido ***'; Domicilio := '';
  end;
end;

procedure TTCliente.Refrescar;
// Objetivo...: Refrescar Datos
Begin
  tperso.Refresh;
end;

procedure TTCliente.conectar;
// Objetivo...: conectar tablas de persistencia - soporte multiempresa
begin
  if conexiones = 0 then Begin
    if not tperso.Active then tperso.Open;
    tperso.FieldByName('nrotel').DisplayLabel := 'Nº Teléfono'; tperso.FieldByName('cp').Visible := False; tperso.FieldByName('orden').Visible := False; tperso.FieldByName('Observa').DisplayLabel := 'Observaciones';
    tperso.FieldByName('Nrocliente').DisplayLabel := 'Número'; tperso.FieldByName('Telalt').DisplayLabel := 'Tél. Alternativo'; tperso.FieldByName('Nombre').DisplayLabel := 'Nombre'; tperso.FieldByName('direccion').DisplayLabel := 'Dirección';
    tperso.FieldByName('RecibioCarta').DisplayLabel := 'RC';
    if not telefonos.Active     then telefonos.Open;
    if not numercli.Active      then numercli.Open;
    if not listcartasenv.Active then listcartasenv.Open;
  end;
  Inc(conexiones);
end;

procedure TTCliente.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones > 0 then Dec(conexiones);
  if conexiones = 0 then Begin
    datosdb.closeDB(tperso);
    datosdb.closeDB(telefonos);
    datosdb.closeDB(numercli);
    datosdb.closeDB(listcartasenv);
  end;
end;

{===============================================================================}

function cliente: TTCliente;
begin
  if xcliente = nil then
    xcliente := TTCliente.Create;
  Result := xcliente;
end;

{===============================================================================}

initialization

finalization
  xcliente.Free;

end.
