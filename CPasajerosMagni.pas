unit CPasajerosMagni;

interface

uses CPersona, CCodPost, CListar, CUtiles, SysUtils, DB, DBTables, CBDT, CIDBFM,
     CTPFiscal;

type

TTPasajero = class(TTPersona)
  Nacionalidad, Fechanac, Aniosrecpais, Estcivil, Profesion, DNI, Domreal, Codpfis, Nrocuit, Telefono, Observacion: string;
  tpasajero: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;
  procedure   Grabar(xcodigo, xnombre, xdomicilio, xcp, xorden, xnacionalidad, xfechanac, xaniosrecpais, xestcivil, xprofesion, xdni, xdomreal, xcodpfis, xnrocuit, xtelefono, xobservacion: string);
  function    Borrar(xcodigo: string): string;
  function    Buscar(xcodigo: string): boolean;
  procedure   getDatos(xcodigo: string);
  procedure   Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);

  procedure   BuscarPorCodigo(xexpr: string);
  procedure   BuscarPorNombre(xexpr: string);
  procedure   BuscarPorDocumento(xexpr: string);

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  conexiones: shortint;
  procedure   List_linea(salida: char);
end;

function pasajero: TTPasajero;

implementation

var
  xpasajero: TTPasajero = nil;

constructor TTPasajero.Create;
begin
  inherited Create('','', '', '', '');
  tperso    := datosdb.openDB('pasajeros', '');
  tpasajero := datosdb.openDB('pasajerosh', '');
end;

destructor TTPasajero.Destroy;
begin
  inherited Destroy;
end;

procedure TTPasajero.Grabar(xcodigo, xnombre, xdomicilio, xcp, xorden, xnacionalidad, xfechanac, xaniosrecpais, xestcivil, xprofesion, xdni, xdomreal, xcodpfis, xnrocuit, xtelefono, xobservacion: string);
// Objetivo...: Grabar Atributos del pasajero
begin
  if Buscar(xcodigo) then tpasajero.Edit else tpasajero.Append;
  tpasajero.FieldByName('idpasajero').AsString   := xcodigo;
  tpasajero.FieldByName('nacionalidad').AsString := xnacionalidad;
  tpasajero.FieldByName('fechanac').AsString     := utiles.sExprFecha2000(xfechanac);
  tpasajero.FieldByName('aniosrec').AsString     := xaniosrecpais;
  tpasajero.FieldByName('estcivil').AsString     := xestcivil;
  tpasajero.FieldByName('profesion').AsString    := xprofesion;
  tpasajero.FieldByName('dni').AsString          := xdni;
  tpasajero.FieldByName('domreal').AsString      := xdomreal;
  tpasajero.FieldByName('codpfis').AsString      := xcodpfis;
  tpasajero.FieldByName('cuit').AsString         := xnrocuit;
  tpasajero.FieldByName('telefono').AsString     := xtelefono;
  tpasajero.FieldByName('observacion').AsString  := xobservacion;
  try
    tpasajero.Post
   except
    tpasajero.Cancel
  end;
  inherited Grabar(xcodigo, xnombre, xdomreal, xcp, xorden);
end;

procedure  TTPasajero.getDatos(xcodigo: string);
// Objetivo...: Obtener/Inicializar los Atributos para un objeto pasajero
begin
  if Buscar(xcodigo) then Begin
    nacionalidad := tpasajero.FieldByName('nacionalidad').AsString;
    fechanac     := utiles.sFormatoFecha(tpasajero.FieldByName('fechanac').AsString);
    aniosrecpais := tpasajero.FieldByName('aniosrec').AsString;
    estcivil     := tpasajero.FieldByName('estcivil').AsString;
    profesion    := tpasajero.FieldByName('profesion').AsString;
    dni          := tpasajero.FieldByName('dni').AsString;
    domreal      := tpasajero.FieldByName('domreal').AsString;
    codpfis      := tpasajero.FieldByName('codpfis').AsString;
    nrocuit      := tpasajero.FieldByName('cuit').AsString;
    telefono     := tpasajero.FieldByName('telefono').AsString;
    observacion  := tpasajero.FieldByName('observacion').AsString;
    if Length(Trim(nrocuit)) < 13 then nrocuit := '00-00000000-0';
  end else Begin
    nacionalidad := ''; fechanac := ''; aniosrecpais := ''; estcivil := ''; profesion := ''; dni := ''; domreal := ''; Codpfis := ''; nrocuit := ''; telefono := ''; observacion := '';
  end;
  inherited getDatos(xcodigo);
end;

function TTPasajero.Borrar(xcodigo: string): string;
// Objetivo...: Eliminar un Instancia de pasajero
begin
  if Buscar(xcodigo) then Begin
    inherited Borrar(xcodigo);  // Metodo de la Superclase Persona
    tpasajero.Delete;
    getDatos(tpasajero.FieldByName('idpasajero').AsString);  // Fijamos los Atributos Siguientes al Objeto Borrado
  end;
end;

function TTPasajero.Buscar(xcodigo: string): boolean;
// Objetivo...: Verificar si Existe el pasajero
begin
  if not (tperso.Active) or not (tpasajero.Active) then conectar;
  if tperso.IndexFieldNames <> 'Idpasajero' then tperso.IndexFieldNames := 'Idpasajero';
  inherited Buscar(xcodigo);
  if tpasajero.IndexFieldNames <> 'Idpasajero' then tpasajero.IndexFieldNames := 'Idpasajero';
  if tpasajero.FindKey([xcodigo]) then Result := True else Result := False;
end;

procedure TTPasajero.List_linea(salida: char);
// Objetivo...: Listar una Línea
begin
  tpasajero.FindKey([tperso.FieldByName('idpasajero').AsString]);   // Sincronizamos las tablas
  List.Linea(0, 0, tperso.FieldByName('idpasajero').AsString + '  ' + tperso.FieldByName('nombre').AsString, 1, 'Arial, normal, 8', salida, 'N');
  List.Linea(37, List.lineactual, tperso.Fields[2].AsString, 2, 'Arial, normal, 8', salida, 'N');
  List.Linea(60, List.lineactual, utiles.sFormatoFecha(tpasajero.FieldByName('fechanac').AsString), 3, 'Arial, normal, 8', salida, 'N');
  List.Linea(67, List.lineactual, tpasajero.FieldByName('aniosrec').AsString, 4, 'Arial, normal, 8', salida, 'N');
  List.Linea(70, List.lineactual, tpasajero.FieldByName('estcivil').AsString, 5, 'Arial, normal, 8', salida, 'N');
  List.Linea(75, List.lineactual, tpasajero.FieldByName('dni').AsString, 6, 'Arial, normal, 8', salida, 'N');
  List.Linea(83, List.lineactual, tpasajero.FieldByName('profesion').AsString, 7, 'Arial, normal, 8', salida, 'S');
end;

procedure TTPasajero.Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
// Objetivo...: Listar Datos de Provincias
begin
  if orden = 'A' then tperso.IndexName := tperso.IndexDefs.Items[1].Name;

  list.setear(salida);
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Listado de Pasajeros', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Id.   Nombre del Pasajero', 1, 'Arial, cursiva, 8');
  List.Titulo(37, List.lineactual, 'Domicilio Real', 2, 'Arial, cursiva, 8');
  List.Titulo(60, List.lineactual, 'F. Nac.', 3, 'Arial, cursiva, 8');
  List.Titulo(67, List.lineactual, 'RP', 4, 'Arial, cursiva, 8');
  List.Titulo(70, List.lineactual, 'EC', 5, 'Arial, cursiva, 8');
  List.Titulo(75, List.lineactual, 'Nro.Doc.', 6, 'Arial, cursiva, 8');
  List.Titulo(83, List.lineactual, 'Profesión', 7, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  tperso.First;
  while not tperso.EOF do
    begin
      // Ordenado por Código
      if (ent_excl = 'E') and (orden = 'C') then
        if (tperso.FieldByName('idpasajero').AsString >= iniciar) and (tperso.FieldByName('idpasajero').AsString <= finalizar) then List_linea(salida);
      if (ent_excl = 'X') and (orden = 'C') then
        if (tperso.FieldByName('idpasajero').AsString < iniciar) or (tperso.FieldByName('idpasajero').AsString > finalizar) then List_linea(salida);
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

procedure TTPasajero.BuscarPorCodigo(xexpr: string);
begin
  if tperso.IndexFieldNames <> 'Nombre' then tperso.IndexFieldNames := 'idpasajero';
  tperso.FindNearest([xexpr]);
end;

procedure TTPasajero.BuscarPorNombre(xexpr: string);
begin
  if tperso.IndexFieldNames <> 'Nombre' then tperso.IndexFieldNames := 'Nombre';
  tperso.FindNearest([xexpr]);
end;

procedure TTPasajero.BuscarPorDocumento(xexpr: string);
begin
  if tpasajero.IndexFieldNames <> 'DNI' then tpasajero.IndexFieldNames := 'DNI';
  tpasajero.FindNearest([xexpr]);
  Buscar(tpasajero.FieldByName('idpasajero').AsString);
end;

procedure TTPasajero.conectar;
// Objetivo...: conectar tablas de persistencia - soporte multiempresa
begin
  if conexiones = 0 then Begin
    if not tperso.Active then tperso.Open;
    tperso.FieldByName('idpasajero').DisplayLabel := 'Cód.'; tperso.FieldByName('nombre').DisplayLabel := 'Nombre'; tperso.FieldByName('cp').Visible := False; tperso.FieldByName('orden').Visible := False;
    if not tpasajero.Active then tpasajero.Open;
  end;
  cpost.conectar;
  tcpfiscal.conectar;
  Inc(conexiones);
end;

procedure TTPasajero.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones > 0 then Dec(conexiones);
  if conexiones = 0 then Begin
    datosdb.closeDB(tperso);
    datosdb.closeDB(tpasajero);
  end;
  cpost.desconectar;
  tcpfiscal.desconectar;
end;

{===============================================================================}

function pasajero: TTPasajero;
begin
  if xpasajero = nil then
    xpasajero := TTPasajero.Create;
  Result := xpasajero;
end;

{===============================================================================}

initialization

finalization
  xpasajero.Free;

end.
