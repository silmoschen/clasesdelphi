unit CtitularPreveer_Expensas;

interface

uses CPersona, CBDT, SysUtils, DB, DBTables, CUtiles, CListar, CIDBFM, CObrasSociales;

type

TTitular = class(TTPersona)
  telefono, email, contrato, M, F, P, Fallecido, Fechafall, Fechain, Serviciosep, Observacion: string;
  tit: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  function    Buscar(xidtitular: string): boolean;
  procedure   Grabar(xidtitular, xnombre, xdomicilio, xcontrato, xtelefono, xemail, xM, xF, xP, xfallecido, xfechafall, xfechain, xserviciosep, xobservacion: string);
  procedure   Borrar(xidtitular: string);
  procedure   getDatos(xidtitular: string);
  procedure   Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);

  procedure   BuscarPorCodigo(xexpr: string);
  procedure   BuscarPorNombre(xexpr: string);

  function    setTitulares: TQuery;

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  conexiones: shortint;
  procedure   List_linea(salida: char);
  procedure   List_Tit(salida: char);
end;

function titular: TTitular;

implementation

var
  xpaciente: TTitular = nil;

constructor TTitular.Create;
begin
  inherited Create('', '', '', '', ''); // Hereda de Persona
  tperso   := datosdb.openDB('tit_expensas', 'Idtitular');
  tit      := datosdb.openDB('tit_expensash', 'Idtitular');
  if not datosdb.verificarSiExisteCampo('tit_expensash', 'fallecido', dbs.DirSistema + '\arch') then
    datosdb.tranSQL(dbs.DirSistema + '\arch', 'alter table tit_expensash add fallecido char(50)');
  if not datosdb.verificarSiExisteCampo('tit_expensash', 'fechafall', dbs.DirSistema + '\arch') then
    datosdb.tranSQL(dbs.DirSistema + '\arch', 'alter table tit_expensash add fechafall char(8)');
  if not datosdb.verificarSiExisteCampo('tit_expensash', 'fechain', dbs.DirSistema + '\arch') then
    datosdb.tranSQL(dbs.DirSistema + '\arch', 'alter table tit_expensash add fechain char(8)');
  if not datosdb.verificarSiExisteCampo('tit_expensash', 'serviciosep', dbs.DirSistema + '\arch') then
    datosdb.tranSQL(dbs.DirSistema + '\arch', 'alter table tit_expensash add serviciosep char(50)');
  if not datosdb.verificarSiExisteCampo('tit_expensash', 'observacion', dbs.DirSistema + '\arch') then
    datosdb.tranSQL(dbs.DirSistema + '\arch', 'alter table tit_expensash add observacion char(80)');
end;

destructor TTitular.Destroy;
begin
  inherited Destroy;
end;

function  TTitular.Buscar(xidtitular: string): boolean;
// Objetivo...: Buscar una instancia
begin
  if tperso.IndexFieldNames <> 'Idtitular' then tperso.IndexFieldNames := 'Idtitular';
  if tit.FindKey([xidtitular]) then Begin
    inherited Buscar(xidtitular);
    Result := True;
  end else
    Result := False;
end;

procedure TTitular.Grabar(xidtitular, xnombre, xdomicilio, xcontrato, xtelefono, xemail, xM, xF, xP, xfallecido, xfechafall, xfechain, xserviciosep, xobservacion: string);
// Objetivo...: Almacenar una instacia de la clase
begin
  if Buscar(xidtitular) then tit.Edit else tit.Append;
  tit.FieldByName('idtitular').AsString   := xidtitular;
  tit.FieldByName('contrato').AsString    := xcontrato;
  tit.FieldByName('M').AsString           := xM;
  tit.FieldByName('F').AsString           := xF;
  tit.FieldByName('P').AsString           := xP;
  tit.FieldByName('telefono').AsString    := xtelefono;
  tit.FieldByName('email').AsString       := xemail;
  tit.FieldByName('fallecido').AsString   := xfallecido;
  tit.FieldByName('fechafall').AsString   := utiles.sExprFecha2000(xfechafall);
  tit.FieldByName('fechain').AsString     := utiles.sExprFecha2000(xfechain);
  tit.FieldByName('serviciosep').AsString := xserviciosep;
  tit.FieldByName('observacion').AsString := xobservacion;
  try
    tit.Post
  except
    tit.Cancel
  end;
  inherited Grabar(xidtitular, xnombre, xdomicilio, '', '');
end;

procedure TTitular.Borrar(xidtitular: string);
// Objetivo...: Eliminar una instancia
begin
  if Buscar(xidtitular) then Begin
    tit.Delete;
    inherited Borrar(xidtitular);
    getDatos(tit.FieldByName('idtitular').AsString);
  end;
end;

procedure TTitular.getDatos(xidtitular: string);
// Objetivo...: Cargar/iniciar los atributos para una instancia
begin
  if Buscar(xidtitular) then Begin
    contrato    := tit.FieldByName('contrato').AsString;
    M           := TrimLeft(tit.FieldByName('M').AsString);
    F           := TrimLeft(tit.FieldByName('F').AsString);
    P           := TrimLeft(tit.FieldByName('P').AsString);
    telefono    := tit.FieldByName('telefono').AsString;
    email       := tit.FieldByName('email').AsString;
    fallecido   := tit.FieldByName('fallecido').AsString;
    fechafall   := utiles.sFormatoFecha(tit.FieldByName('fechafall').AsString);
    fechain     := utiles.sFormatoFecha(tit.FieldByName('fechain').AsString);
    serviciosep := tit.FieldByName('serviciosep').AsString;
    observacion := tit.FieldByName('observacion').AsString;
  end else Begin
    contrato := ''; M := ''; F := ''; P := ''; telefono := ''; email := ''; fallecido := ''; serviciosep := ''; observacion := '';
  end;
  inherited getDatos(xidtitular);
end;

procedure TTitular.List_Tit(salida: char);
// Objetivo...: Listar una Línea
begin
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Listado de Titulares', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Cód.      Apellido y Nombre', 1, 'Arial, cursiva, 8');
  List.Titulo(40, List.lineactual, 'Dirección', 2, 'Arial, cursiva, 8');
  List.Titulo(65, List.lineactual, 'Teléfono', 2, 'Arial, cursiva, 8');
  List.Titulo(80, List.lineactual, 'Ubicación', 4, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');
end;

procedure TTitular.List_linea(salida: char);
// Objetivo...: Listar una Línea
begin
  tit.FindKey([tperso.FieldByName('idtitular').AsString]);   // Sincronizamos las tablas
  List.Linea(0, 0, tperso.FieldByName('idtitular').AsString + '  ' + tperso.FieldByName('nombre').AsString, 1, 'Arial, normal, 8', salida, 'N');
  List.Linea(40, List.lineactual, tperso.FieldByName('direccion').AsString, 2, 'Arial, normal, 8', salida, 'N');
  List.Linea(65, List.lineactual, tit.FieldByName('telefono').AsString, 3, 'Arial, normal, 8', salida, 'N');
  List.Linea(80, List.lineactual, tit.FieldByName('M').AsString, 4, 'Arial, normal, 8', salida, 'N');
  List.Linea(83, List.lineactual, tit.FieldByName('F').AsString, 5, 'Arial, normal, 8', salida, 'N');
  List.Linea(86, List.lineactual, tit.FieldByName('P').AsString, 6, 'Arial, normal, 8', salida, 'S');
end;

procedure TTitular.Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
// Objetivo...: Listado de la clase
begin
  if orden = 'A' then tperso.IndexName := tperso.IndexDefs.Items[1].Name;
  list_Tit(salida);

  tperso.First;
  while not tperso.EOF do
    begin
      // Ordenado por Código
      if (ent_excl = 'E') and (orden = 'C') then
        if (tperso.FieldByName('idtitular').AsString >= iniciar) and (tperso.FieldByName('idtitular').AsString <= finalizar) then List_linea(salida);
      if (ent_excl = 'X') and (orden = 'C') then
        if (tperso.FieldByName('idtitular').AsString < iniciar) or (tperso.FieldByName('idtitular').AsString > finalizar) then List_linea(salida);
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

procedure TTitular.BuscarPorCodigo(xexpr: string);
// Objetivo...: buscar por código
begin
  tperso.IndexFieldNames := 'idtitular';
  tperso.FindNearest([xexpr]);
end;

procedure TTitular.BuscarPorNombre(xexpr: string);
// Objetivo...: buscar por nombre
begin
  tperso.IndexFieldNames := 'Nombre';
  tperso.FindNearest([xexpr]);
end;

function  TTitular.setTitulares: TQuery;
// Objetivo...: Devolver un set con los titulares
Begin
  Result := datosdb.tranSQL('SELECT * FROM ' + tperso.TableName + ' ORDER BY Nombre'); 
end;

procedure TTitular.conectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones = 0 then Begin
    if not tperso.Active then tperso.Open;
    if not tit.Active then tit.Open;
  end;
  tperso.FieldByName('idtitular').DisplayLabel := 'Id.'; tperso.FieldByName('nombre').DisplayLabel := 'Nombre y Apellido'; tperso.FieldByName('direccion').DisplayLabel := 'Dirección';
  tperso.FieldByName('cp').Visible := False; tperso.FieldByName('orden').Visible := False;
  Inc(conexiones);
end;

procedure TTitular.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  Dec(conexiones);
  if conexiones = 0 then Begin
    datosdb.closeDB(tperso);
    datosdb.closeDB(tit);
  end;
end;

{===============================================================================}

function titular: TTitular;
begin
  if xpaciente = nil then
    xpaciente := TTitular.Create;
  Result := xpaciente;
end;

{===============================================================================}

initialization

finalization
  xpaciente.Free;

end.
