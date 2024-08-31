unit CAgeCont;

interface

uses CPersona, CBDT, SysUtils, DB, DBTables, CUtiles, CListar, CIDBFM;

type

TTContacto = class(TTPersona)
  codcont, nrocuit, telefono, email, codcat, descrip, fechanac, notas, nota, idanter, ciudad, localidad: string;
  tabla2, cat, anotac: TTable; stp: TStoredProc;
 public
  { Declaraciones Públicas }
  constructor Create(xcodigo, xnombre, xdomicilio, xcp, xorden, xtelefono, xemail: string);
  destructor  Destroy; override;

  function    Buscar(xcodigo: string): boolean;
  procedure   Grabar(xcodigo, xnombre, xdomicilio, xcp, xorden, xtelefono, xemail, xnrocuit, xcodcat, xfechanac, xciudad, xlocalidad, xnota: string);
  procedure   Borrar(xcodigo: string);
  procedure   getDatos(xcodigo: string);
  function    setContactos: TQuery; overload;
  function    setContactos(xcategoria: string): TQuery; overload;
  function    ObtenerIdContacto(xnombre, xidsocio: String): String;

  procedure   GrabarAnotaciones(xfecha, xhora, xnota: string);
  function    BuscarAnotaciones(xfecha, xhora: string): boolean;
  procedure   getDatosAnotaciones(xfecha, xhora: string);
  function    setAnotaciones(xfecha: string): TQuery;
  procedure   BorrarAnotaciones(xfecha, xhora: string); overload;
  procedure   BorrarAnotaciones(xfecha: string); overload;
  procedure   RefrescarAnotaciones;
  procedure   Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
  procedure   ListarPorCategoria(orden, iniciar, finalizar, ent_excl: string; salida: char);

  function    BuscarCat(xcodcat: string): boolean;
  procedure   BuscarTelefono(xnrotel: string);
  function    BuscarFechaNac(xfecha: string): TQuery;
  procedure   BuscarDireccion(xdireccion: string);
  procedure   GrabarCat(xcodcat, xdescrip: string);
  procedure   BorrarCat;
  procedure   getDatosCat(xcodcat: string);
  function    setCategorias: TQuery;
  function    NuevaCategoria: string;
  procedure   Observaciones(xnota: string);
  procedure   BuscarPorCodCat(xexpr: string);
  function    BuscarPorCategoria(xexpr: string): boolean;
  function    NuevoContacto(letra: string): string;

  function    setListaDeContactos(xnombre: String): TQuery;

  procedure   ExportarEnFormatoHTML(xarchivo: string);
  function    setCantidadDeContactos: Integer;

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  conexiones: shortint; r, resultado: TQuery;
  procedure   List_linea(xorden: string; salida: char);
  procedure   Listar_linea(orden: string; salida: char);
  procedure   List_Tit(salida: char);
  procedure   List_Titulo(salida: char);
  procedure   AtributosContacto(xcodcont: string);
 public
  IdPorFecha: Boolean;
end;

function contacto: TTContacto;

implementation

var
  xcontacto: TTContacto = nil;

constructor TTContacto.Create(xcodigo, xnombre, xdomicilio, xcp, xorden, xtelefono, xemail: string);
begin
  inherited Create(xcodigo, xnombre, xdomicilio, xcp, xorden); // Hereda de Persona
  tperso := datosdb.openDB('contacto', 'Codcont');
  tabla2 := datosdb.openDB('contacth', 'Codcont');
  cat    := datosdb.openDB('catcont', 'codcat');
  anotac := datosdb.openDB('anotaciones', 'Fecha;Hora');
end;

destructor TTContacto.Destroy;
begin
  inherited Destroy;
end;

function  TTContacto.Buscar(xcodigo: string): boolean;
// Objetivo...: Buscar una instancia
begin
  if dbs.StoredProc = 'N' then Begin
    if tabla2.IndexFieldNames <> 'Codcont' then tabla2.IndexFieldNames := 'Codcont';
    if tperso.IndexFieldNames <> 'Codcont' then tperso.IndexFieldNames := 'Codcont';
    if tabla2.FindKey([xcodigo]) then Begin
      inherited Buscar(xcodigo);
      Result := True;
    end else
      Result := False;
  end;
  if dbs.StoredProc = 'S' then Begin
    stp := datosdb.crearStoredProc(dbs.baseDat, 'buscarcontact', 'codcont', xcodigo);
    stp.ExecProc;
    if stp.ParamByName('encontrado').AsInteger = 0 then Result := False else Result := True;
    stp.Free;
  end;
end;

procedure TTContacto.Grabar(xcodigo, xnombre, xdomicilio, xcp, xorden, xtelefono, xemail, xnrocuit, xcodcat, xfechanac, xciudad, xlocalidad, xnota: string);
// Objetivo...: Almacenar una instacia de la clase
begin
  if dbs.StoredProc = 'N' then Begin
    if Buscar(xcodigo) then tabla2.Edit else tabla2.Append;
    tabla2.FieldByName('codcont').AsString   := xcodigo;
    tabla2.FieldByName('telefono').AsString  := xtelefono;
    tabla2.FieldByName('email').AsString     := xemail;
    tabla2.FieldByName('nrocuit').AsString   := xnrocuit;
    tabla2.FieldByName('codcat').AsString    := xcodcat;
    tabla2.FieldByName('fechanac').AsString  := utiles.sExprFecha(xfechanac);
    tabla2.FieldByName('ciudad').AsString    := xciudad;
    tabla2.FieldByName('localidad').AsString := xlocalidad;
    tabla2.FieldByName('nota').AsString      := xnota;
    try
      tabla2.Post
     except
     tabla2.Cancel
    end;
    datosdb.refrescar(tabla2);
    inherited Grabar(xcodigo, xnombre, xdomicilio, '', '');
  end;
  if dbs.StoredProc = 'S' then Begin
    stp := datosdb.crearStoredProc(dbs.baseDat, 'guardarcontacto', 'codcont', xcodigo);
    stp.ParamByName('codcont').AsString   := xcodigo;
    stp.ParamByName('nombre').AsString    := xnombre;
    stp.ParamByName('direccion').AsString := xdomicilio;
    stp.ParamByName('cp').AsString        := xcp;
    stp.ParamByName('orden').AsString     := xorden;
    stp.ParamByName('telefono').AsString  := xtelefono;
    stp.ParamByName('email').AsString     := xemail;
    stp.ParamByName('codcat').AsString    := xcodcat;
    stp.ParamByName('fechanac').AsString  := utiles.sExprFecha(xfechanac);
    stp.ParamByName('ciudad').AsString    := xciudad;
    stp.ParamByName('localidad').AsString := xlocalidad;
    stp.ParamByName('nota').AsBlob        := xnota;
    stp.ExecProc;
  end;
end;

procedure TTContacto.Borrar(xcodigo: string);
// Objetivo...: Eliminar una instancia
begin
  if dbs.StoredProc = 'N' then Begin
    if Buscar(xcodigo) then Begin
      tabla2.Delete;
      inherited Borrar(xcodigo);
      getDatos(tabla2.FieldByName('codcont').AsString);
    end;
  end;
  if dbs.StoredProc = 'S' then Begin
    stp := datosdb.crearStoredProc(dbs.baseDat, 'borrarcontacto', 'codcont', xcodigo);
    stp.ExecProc;
    datosdb.cerrarStoredProc(stp);
  end;
end;

procedure TTContacto.getDatos(xcodigo: string);
// Objetivo...: Cargar/iniciar los atributos para una instancia
begin
  nrocuit := ''; telefono := ''; email := ''; codcat := ''; fechanac := ''; nota := ''; codcont := ''; ciudad := '';
  if dbs.StoredProc = 'N' then Begin
    tabla2.Refresh;
    inherited getDatos(xcodigo);
    if Buscar(xcodigo) then Begin
      codcont   := tabla2.FieldByName('codcont').AsString;
      telefono  := TrimLeft(tabla2.FieldByName('telefono').AsString);
      email     := tabla2.FieldByName('email').AsString;
      nrocuit   := tabla2.FieldByName('nrocuit').AsString;
      codcat    := tabla2.FieldByName('codcat').AsString;
      fechanac  := utiles.sFormatoFecha(tabla2.FieldByName('fechanac').AsString);
      ciudad    := tabla2.FieldByName('ciudad').AsString;
      localidad := tabla2.FieldByName('localidad').AsString;
      nota      := tabla2.FieldByName('nota').AsString;
    end;
  end;

  if dbs.StoredProc = 'S' then Begin
    stp       := datosdb.crearStoredProc(dbs.baseDat, 'getcontacto', 'codcont', xcodigo);
    codcont   := xcodigo;
    nombre    := stp.ParamByName('nombre').AsString;
    domicilio := stp.ParamByName('direccion').AsString;
    telefono  := stp.ParamByName('telefono').AsString;
    email     := stp.ParamByName('email').AsString;
    nrocuit   := stp.ParamByName('nrocuit').AsString;
    codcat    := stp.ParamByName('codcat').AsString;
    fechanac  := utiles.sFormatoFecha(stp.ParamByName('fechanac').AsString);
    ciudad    := stp.ParamByName('ciudad').AsString;
    localidad := stp.ParamByName('localidad').AsString;
    datosdb.cerrarStoredProc(stp);
    resultado := datosdb.tranSQL('select nota from contacth where codcont = ' + '"' + xcodigo + '"');
    resultado.Open;
    nota      := resultado.FieldByName('nota').AsString;
    resultado.Close; resultado.Free;
  end;
end;

function  TTContacto.setContactos: TQuery;
// Objetivo...: devolver un set de contactos por fecha
begin
  Result := datosdb.tranSQL('SELECT contacto.Codcont, contacto.Nombre, contacto.Direccion, contacth.Telefono, contacth.Nrocuit, contacth.Email FROM contacto, contacth WHERE contacto.Codcont = contacth.Codcont ORDER BY Nombre');
end;

function  TTContacto.ObtenerIdContacto(xnombre, xidsocio: String): String;
// Objetivo...: Generar el Id de contacto
var
  salir: boolean; Id: String;
Begin
  salir := False;
  if not IdPorFecha then Begin
    if UpperCase(Copy(xnombre, 1, 1)) <> Copy(xidsocio, 1, 1) then Begin
      while salir do Begin
        Id := UpperCase(Copy(xnombre, 1, 1)) + utiles.sLlenarIzquierda(IntToStr(Random(10000)), 8, '0');
        if dbs.StoredProc = 'N' then Begin
          if not Buscar(Id) then Break;
        end else Begin
          stp := datosdb.crearStoredProc(dbs.baseDat, 'buscarcontacto', 'codcont', Id);
          stp.ExecProc;
          if stp.ParamByName('encontrado').AsInteger = 0 then Break;
          datosdb.cerrarStoredProc(stp);
        end;
      end;
    end;
    Result := Id;
  end else Result := utiles.sExprFecha(utiles.setFechaActual) + utiles.setHoraActual24;
end;

function TTContacto.setContactos(xcategoria: string): TQuery;
begin
  Result := datosdb.tranSQL('SELECT contacto.Codcont, contacto.Nombre, contacto.Direccion, contacth.Telefono, contacth.Nrocuit, contacth.Email FROM contacto, contacth WHERE contacto.Codcont = contacth.Codcont AND contacth.Codcat = ' + '"' + xcategoria + '"' + ' ORDER BY Nombre');
end;

function TTContacto.BuscarCat(xcodcat: string): boolean;
begin
  if cat.IndexFieldNames <> 'codcat' then cat.IndexFieldNames := 'codcat';
  if cat.FindKey([xcodcat]) then Begin
    Result := True;
    codcat := xcodcat;
  end else Begin
    Result := False;
    codcat := '';
  end;
end;

procedure TTContacto.GrabarCat(xcodcat, xdescrip: string);
begin
  if BuscarCat(xcodcat) then cat.Edit else cat.Append;
  cat.FieldByName('codcat').AsString  := xcodcat;
  cat.FieldByName('descrip').AsString := xdescrip;
  try
    cat.Post
  except
    cat.Cancel
  end;
  datosdb.refrescar(cat);
end;

procedure TTContacto.BorrarCat;
begin
  if BuscarCat(codcat) then Begin
    cat.Delete;
    getDatosCat(cat.FieldByName('codcat').AsString);
  end;
end;

procedure TTContacto.getDatosCat(xcodcat: string);
begin
  if BuscarCat(xcodcat) then Begin
    codcat := xcodcat; descrip := cat.FieldByName('descrip').AsString
  end
  else Begin
    codcat := ''; descrip := '';
  end;
end;

function TTContacto.setCategorias: TQuery;
begin
  Result := datosdb.tranSQL('SELECT * FROM catcont ORDER BY descrip')
end;

function TTContacto.NuevaCategoria: string;
begin
  cat.IndexFieldNames := 'codcat';
  cat.Last;
  if cat.RecordCount > 0 then Result := utiles.sLlenarIzquierda(IntToStr(cat.FieldByName('codcat').AsInteger + 1), 2, '0') else Result := '01';
end;

procedure TTContacto.BuscarPorCodCat(xexpr: string);
// Objetivo...: Buscar por cod. categoria
begin
  if cat.IndexFieldNames <> 'codcat' then cat.IndexFieldNames := 'codcat';
  cat.FindNearest([xexpr]);
end;

function TTContacto.BuscarPorCategoria(xexpr: string): boolean;
// Objetivo...: buscar por categoria
begin
  if cat.IndexFieldNames <> 'Descrip' then cat.IndexFieldNames := 'Descrip';
  Result := cat.FindKey([xexpr]);
  cat.FindNearest([xexpr]);
end;

procedure TTContacto.GrabarAnotaciones(xfecha, xhora, xnota: string);
// Objetivo...: Guardar una entrada
begin
  if Length(Trim(xfecha)) > 0 then Begin
    if not BuscarAnotaciones(xfecha, xhora) then anotac.Append else anotac.Edit;
    anotac.FieldByName('fecha').AsString := utiles.sExprFecha(xfecha);
    anotac.FieldByName('hora').AsString  := xhora;
    anotac.FieldByName('nota').AsString  := xnota;
    try
      anotac.Post
    except
      anotac.Cancel
    end;
  end;
end;

function  TTContacto.BuscarAnotaciones(xfecha, xhora: string): boolean;
begin
  anotac.Refresh;
  if datosdb.Buscar(anotac, 'fecha', 'hora', utiles.sExprFecha(xfecha), xhora) then Result := True else Result := False;
end;

procedure TTContacto.getDatosAnotaciones(xfecha, xhora: string);
begin
  if BuscarAnotaciones(xfecha, xhora) then notas := anotac.FieldByName('nota').Value else notas := '';
end;

function TTContacto.setAnotaciones(xfecha: string): TQuery;
begin
  Result := datosdb.tranSQL('SELECT * FROM anotaciones WHERE Fecha = ' + '"' + utiles.sExprFecha(xfecha) + '"');
end;

procedure TTContacto.BorrarAnotaciones(xfecha, xhora: string);
begin
  if BuscarAnotaciones(xfecha, xhora) then Begin
    anotac.Delete;
    anotac.Refresh;
  end;
end;

procedure TTContacto.BorrarAnotaciones(xfecha: string);
begin
  datosdb.tranSQL('DELETE FROM anotaciones WHERE Fecha <= ' + '"' + utiles.sExprFecha(xfecha) + '"');
end;

procedure TTContacto.RefrescarAnotaciones;
begin
  anotac.Refresh;
end;

procedure TTContacto.List_Tit(salida: char);
// Objetivo...: Listar una Línea
begin
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Listado de Contactos', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Cód.  Apellido y Nombre', 1, 'Arial, cursiva, 8');
  List.Titulo(38, List.lineactual, 'Dirección', 2, 'Arial, cursiva, 8');
  List.Titulo(70, List.lineactual, 'Teléfono', 3, 'Arial, cursiva, 8');
  List.Titulo(90, List.lineactual, 'E-mail', 4, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');
end;

procedure TTContacto.List_Titulo(salida: char);
// Objetivo...: Listar una Línea
begin
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Listado de Contactos', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, '     Cód.  Apellido y Nombre', 1, 'Arial, cursiva, 8');
  List.Titulo(40, List.lineactual, 'Dirección', 2, 'Arial, cursiva, 8');
  List.Titulo(70, List.lineactual, 'Teléfono', 3, 'Arial, cursiva, 8');
  List.Titulo(90, List.lineactual, 'E-mail', 4, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');
end;

procedure TTContacto.List_linea(xorden: string; salida: char);
// Objetivo...: Listar una Línea
begin
  if xorden = 'A' then Begin
    if Copy(tperso.FieldByName('nombre').AsString, 1, 1) <> idanter then List.Linea(0, 0, Copy(tperso.FieldByName('nombre').AsString, 1, 1), 1, 'Arial, negrita, 14', salida, 'S');
    List.Linea(0, 0, '  ', 1, 'Arial, normal, 5', salida, 'S');
    idanter := Copy(tperso.FieldByName('nombre').AsString, 1, 1);
  end;
  tabla2.FindKey([tperso.FieldByName('codcont').AsString]);   // Sincronizamos las tablas
  List.Linea(0, 0, tperso.FieldByName('codcont').AsString + '  ' + tperso.FieldByName('nombre').AsString, 1, 'Arial, normal, 8', salida, 'N');
  List.Linea(38, List.lineactual, tperso.FieldByName('direccion').AsString, 2, 'Arial, normal, 7', salida, 'N');
  List.Linea(68, List.lineactual, TrimLeft(tabla2.FieldByName('telefono').AsString), 3, 'Arial, normal, 7', salida, 'N');
  List.Linea(88, List.lineactual, tabla2.FieldByName('email').AsString, 4, 'Arial, normal, 7', salida, 'S');
end;

procedure TTContacto.Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
// Objetivo...: Listado de la clase
begin
  if orden = 'A' then tperso.IndexName := tperso.IndexDefs.Items[1].Name;
  list_Tit(salida);

  tperso.First;
  while not tperso.EOF do
    begin
      // Ordenado por Código
      if (ent_excl = 'E') and (orden = 'C') then
        if (tperso.FieldByName('codcont').AsString >= iniciar) and (tperso.FieldByName('codcont').AsString <= finalizar) then List_linea(orden, salida);
      if (ent_excl = 'X') and (orden = 'C') then
        if (tperso.FieldByName('codcont').AsString < iniciar) or (tperso.FieldByName('codcont').AsString > finalizar) then List_linea(orden, salida);
      // Ordenado Alfabéticamente
      if (ent_excl = 'E') and (orden = 'A') then
        if (tperso.FieldByName('nombre').AsString >= iniciar) and (tperso.FieldByName('nombre').AsString <= finalizar) then List_linea(orden, salida);
      if (ent_excl = 'X') and (orden = 'A') then
        if (tperso.FieldByName('nombre').AsString < iniciar) or (tperso.FieldByName('nombre').AsString > finalizar) then List_linea(orden, salida);

      tperso.Next;
    end;
    List.FinList;

    tperso.IndexFieldNames := tperso.IndexFieldNames;
    tperso.First;
end;

procedure TTContacto.ListarPorCategoria(orden, iniciar, finalizar, ent_excl: string; salida: char);
// Objetivo...: Listado de la clase
begin
  idanter := '';
  if orden = 'C' then r := datosdb.tranSQL('SELECT * FROM contacto, contacth, catcont WHERE contacto.codcont = contacth.codcont AND contacth.codcat = catcont.codcat ORDER BY catcont.codcat, nombre') else
    r := datosdb.tranSQL('SELECT * FROM contacto, contacth, catcont WHERE contacto.codcont = contacth.codcont AND contacth.codcat = catcont.codcat ORDER BY descrip, nombre');

  list_Titulo(salida);

  r.Open;
  while not r.EOF do Begin
    // Ordenado por Código
    if (ent_excl = 'E') and (orden = 'C') then
      if (r.FieldByName('codcat').AsString >= iniciar) and (r.FieldByName('codcat').AsString <= finalizar) then Listar_linea(orden, salida);
    if (ent_excl = 'X') and (orden = 'C') then
      if (r.FieldByName('codcat').AsString < iniciar) or (r.FieldByName('codcat').AsString > finalizar) then Listar_linea(orden, salida);
    // Ordenado Alfabéticamente
    if (ent_excl = 'E') and (orden = 'A') then
      if (r.FieldByName('descrip').AsString >= iniciar) and (r.FieldByName('descrip').AsString <= finalizar) then Listar_linea(orden, salida);
    if (ent_excl = 'X') and (orden = 'A') then
      if (r.FieldByName('descrip').AsString < iniciar) or (r.FieldByName('descrip').AsString > finalizar) then Listar_linea(orden, salida);

    r.Next;
  end;
  r.Close; r.Free;

  List.FinList;
end;

procedure TTContacto.Listar_linea(orden: string; salida: char);
// Objetivo...: Listar una Línea
begin
  if orden = 'C' then Begin
    if r.FieldByName('codcat').AsString <> idanter then Begin
      if Length(Trim(idanter)) > 0 then List.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');
      List.Linea(0, 0, r.FieldByName('codcat').AsString + '  ' + r.FieldByName('descrip').AsString, 1, 'Arial, negrita, 11', salida, 'S');
    end;
  end;
  if orden = 'A' then Begin
    if r.FieldByName('descrip').AsString <> idanter then Begin
      if Length(Trim(idanter)) > 0 then List.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');
      List.Linea(0, 0, r.FieldByName('descrip').AsString, 1, 'Arial, negrita, 11', salida, 'S');
    end;
  end;
  List.Linea(0, 0, '  ' + r.FieldByName('codcont').AsString + '  ' + Copy(r.FieldByName('nombre').AsString, 1, 35), 1, 'Arial, normal, 7', salida, 'N');
  List.Linea(40, List.lineactual, Copy(r.FieldByName('direccion').AsString, 1, 30), 2, 'Arial, normal, 7', salida, 'N');
  List.Linea(68, List.lineactual, Copy(Trim(r.FieldByName('telefono').AsString), 1, 25), 3, 'Arial, normal, 7', salida, 'N');
  List.Linea(88, List.lineactual, r.FieldByName('email').AsString, 4, 'Arial, normal, 7', salida, 'S');
  if orden = 'C' then idanter := r.FieldByName('codcat').AsString;
  if orden = 'A' then idanter := r.FieldByName('descrip').AsString;
end;

procedure TTContacto.Observaciones(xnota: string);
// Objetivo...: Fijar observaciones para el contacto
begin
  if Buscar(codcont) then Begin
    tabla2.Edit;
    tabla2.FieldByName('nota').Value := xnota;
    try
      tabla2.Post
    except
      tabla2.Cancel
    end;
    tabla2.Refresh;
  end;
end;

procedure TTContacto.BuscarTelefono(xnrotel: string);
// Objetivo...: Buscar por telefono
begin
  if tabla2.IndexName <> 'telefono' then tabla2.IndexName := 'telefono';
  tabla2.FindNearest([xnrotel]);
  // Buscamos en la tabla superior
  AtributosContacto(tabla2.FieldByName('codcont').AsString);
end;

function TTContacto.BuscarFechaNac(xfecha: string): TQuery;
// Objetivo...: Buscar por telefono
var
  r: TQuery;
begin
  r := datosdb.tranSQL('SELECT ' + tperso.TableName + '.*, ' + tabla2.TableName + '.* FROM ' + tperso.TableName + ', ' + tabla2.TableName + ' WHERE ' + tperso.TableName + '.Codcont = ' + tabla2.TableName + '.Codcont');
  Result := datosdb.Filtrar(r, 'Fechanac = ' + '''' + utiles.sExprFecha(xfecha) + '''');
end;

procedure TTContacto.BuscarDireccion(xdireccion: string);
// Objetivo...: Buscar por telefono
begin
  if tperso.IndexName <> 'Direccion' then tperso.IndexName := 'Direccion';
  tperso.FindNearest([xdireccion]);
  // Buscamos en la tabla superior
  AtributosContacto(tperso.FieldByName('codcont').AsString);
end;

procedure TTContacto.AtributosContacto(xcodcont: string);
begin
  if tperso.IndexFieldNames <> 'Codcont' then tperso.IndexFieldNames := 'Codcont';
  if tperso.FindKey([xcodcont]) then Begin
    nombre    := tperso.FieldByName('nombre').AsString;
    domicilio := tperso.FieldByName('direccion').AsString;
    telefono  := tabla2.FieldByName('telefono').AsString;
    nrocuit   := tabla2.FieldByName('nrocuit').AsString;
  end else Begin
    nombre := ''; domicilio := ''; telefono := ''; nrocuit := '';
  end;
end;

function TTContacto.NuevoContacto(letra: string): string;
// Objetivo...: Generar un número nuevo
var
  x: string;
begin
  Random(999);
  repeat
    x := Trim(letra) + utiles.sLlenarIzquierda(IntToStr(Random(999)), 3, '0');
  until not Buscar(x);
  Result := x;
end;

function  TTContacto.setListaDeContactos(xnombre: String): TQuery;
// Objetivo...: Devolver aquellos contactos que coincidan con el nombre buscado
Begin
  Result := datosdb.tranSQL('select contacto.codcont, contacto.nombre, contacth.telefono, contacto.direccion, contacth.codcat from contacto, contacth where contacto.codcont = contacth.codcont and contacto.nombre LIKE ' + '"' + xnombre + '%' + '"');
end;

procedure TTContacto.ExportarEnFormatoHTML(xarchivo: string);
// Objetivo...: Exportar archivo a formato html
var
  r: TQuery; catanter: String;
  archivo: Text; i: Integer;
begin
  r := datosdb.tranSQL('select contacto.nombre, contacth.telefono, contacto.direccion, contacth.email, catcont.descrip from contacto, contacth, catcont where contacto.codcont = contacth.codcont and contacth.codcat = catcont.codcat order by descrip, nombre');

  Assign(archivo, xarchivo);
  Rewrite(archivo);
  WriteLn(archivo, '<HTML><HEAD><TITLE>N' + CHR(162) + 'mina de Contactos</TITLE></HEAD><BODY>');
  WriteLn(archivo, '<H1>Contactos</H1><HR>');
  WriteLn(archivo, '<TABLE>');

  r.Open; r.First; i := 0;
  while not r.EOF do Begin
    Inc(i);
    if r.FieldByName('descrip').AsString <> catanter then Begin
      if Length(Trim(catanter)) > 0 then Write(archivo, '<TR><TD>' + '  ' + '</TD>');
      Write(archivo, '<TR><TD><H3>' + r.FieldByName('descrip').AsString + '</H3></TD>');
      catanter := r.FieldByName('descrip').AsString;
      Write(archivo, '<TR><TD>' + '  ' + '</TD>');
    end;
    Write(archivo, '<TR><TD>' + r.FieldByName('nombre').AsString + '</TD>');
    if Length(Trim(r.FieldByName('email').AsString)) > 0 then Write(archivo, '<TD><A HREF=' + '"' + 'mailto:' + r.FieldByName('email').AsString + '">' + r.FieldByName('email').AsString + '</A>'  + '</TD>') else Write(archivo, '<TD>no posee</TD>');
    Write(archivo, '<TD>' + r.FieldByName('telefono').AsString + '</TD>');
    WriteLn(archivo, '<TD>' + r.FieldByName('direccion').AsString + '</TD></TR>');
    r.Next;
  end;
  r.Close; r.Free;

  WriteLn(archivo, '</TABLE>');
  WriteLn(archivo, '<BR><HR>Cantidad de contactos: ' + IntToStr(i));
  WriteLn(archivo, '</BODY></HTML>');
  CloseFile(archivo);

  tperso.IndexFieldNames := 'Codcont';
end;

function TTContacto.setCantidadDeContactos: Integer;
begin
  Result := tperso.RecordCount;
end;

procedure TTContacto.conectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones = 0 then Begin
    if not tperso.Active then tperso.Open;
    if not tabla2.Active then tabla2.Open;
    if not anotac.Active then anotac.Open;
    if not cat.Active then cat.Open;
    cat.FieldByName('codcat').DisplayLabel := 'Cód'; cat.FieldByName('descrip').DisplayLabel := 'Descripción';
  end;
  Inc(conexiones);
end;

procedure TTContacto.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones > 0 then Dec(conexiones);
  if conexiones = 0 then Begin
    datosdb.closeDB(tperso);
    datosdb.closeDB(tabla2);
    datosdb.closeDB(anotac);
    datosdb.closeDB(cat);
  end;
end;

{===============================================================================}

function contacto: TTContacto;
begin
  if xcontacto = nil then
    xcontacto := TTContacto.Create('', '', '', '', '', '', '');
  Result := xcontacto;
end;

{===============================================================================}

initialization

finalization
  xcontacto.Free;

end.
