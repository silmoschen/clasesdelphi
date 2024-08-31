unit CConyugePreveer_Sepelios;

interface

uses CPersona, CBDT, SysUtils, DB, DBTables, CUtiles, CListar, CIDBFM, CPreverCostos;

type

TTConyugeSepelio = class(TTPersona)
  NrodocConyuge, FechaNac, Telefono, Email: String;
  Costo: Real; Existe: Boolean;
  tit: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  function    Buscar(xNrodoc: string): boolean;
  procedure   Grabar(xNrodoc, xNrodocconyuge, xnombre, xdomicilio, xcp, xorden, xfechanac, xtelefono, xemail: String);
  procedure   Borrar(xNrodoc: string);
  procedure   getDatos(xNrodoc: string);

  procedure   BuscarPorCodigo(xexpr: string);
  procedure   BuscarPorNombre(xexpr: string);

  function    setMontoConyuge(xedad: String): Real;
  function    setMonto(xnrodoctitular: String): Real;

  procedure   RegistrarMontoGrupoFamiliar(xnrodoc: String; xmonto: Real);

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  conexiones: shortint;
end;

function conyuge: TTConyugeSepelio;

implementation

var
  xconyuge: TTConyugeSepelio = nil;

constructor TTConyugeSepelio.Create;
begin
  inherited Create('', '', '', '', ''); // Hereda de Persona
  tperso := datosdb.openDB('conyuge', 'Nrodoc', '', dbs.DirSistema + '\sepelio');
  tit    := datosdb.openDB('conyugeh', 'Nrodoc', '', dbs.DirSistema + '\sepelio');
end;

destructor TTConyugeSepelio.Destroy;
begin
  inherited Destroy;
end;

function  TTConyugeSepelio.Buscar(xNrodoc: string): boolean;
// Objetivo...: Buscar una instancia
begin
  if tperso.IndexFieldNames <> 'Nrodoc' then tperso.IndexFieldNames := 'Nrodoc';
  if tit.FindKey([xNrodoc]) then Begin
    inherited Buscar(xNrodoc);
    Existe := True;
  end else
    Existe := False;
  Result := Existe;
end;

procedure TTConyugeSepelio.Grabar(xNrodoc, xNrodocconyuge, xnombre, xdomicilio, xcp, xorden, xfechanac, xtelefono, xemail: String);
// Objetivo...: Almacenar una instacia de la clase
begin
  if Buscar(xNrodoc) then tit.Edit else tit.Append;
  tit.FieldByName('Nrodoc').AsString        := xNrodoc;
  tit.FieldByName('Nrodocconyuge').AsString := xnrodocconyuge;
  tit.FieldByName('fechanac').AsString      := utiles.sExprFecha(xfechanac);
  tit.FieldByName('telefono').AsString      := xtelefono;
  tit.FieldByName('email').AsString         := xemail;
  try
    tit.Post
  except
    tit.Cancel
  end;
  inherited Grabar(xNrodoc, xnombre, xdomicilio, xcp, xorden);
  //end;
end;

procedure TTConyugeSepelio.Borrar(xNrodoc: string);
// Objetivo...: Eliminar una instancia
begin
  if Buscar(xNrodoc) then Begin
    tit.Delete;
    inherited Borrar(xNrodoc);
    getDatos(tit.FieldByName('nrodoc').AsString);
  end;
end;

procedure TTConyugeSepelio.getDatos(xNrodoc: string);
// Objetivo...: Cargar/iniciar los atributos para una instancia
begin
  if Buscar(xNrodoc) then Begin
    FechaNac      := utiles.sFormatoFecha(tit.FieldByName('fechanac').AsString);
    Telefono      := TrimLeft(tit.FieldByName('telefono').AsString);
    Email         := TrimLeft(tit.FieldByName('email').AsString);
    Nrodocconyuge := TrimLeft(tit.FieldByName('nrodocconyuge').AsString);
    Costo         := tit.FieldByName('monto').AsFloat;
  end else Begin
    FechaNac := ''; Telefono := ''; Email := ''; Nrodocconyuge := ''; Costo := 0;
  end;
  inherited getDatos(xNrodoc);
end;

procedure TTConyugeSepelio.BuscarPorCodigo(xexpr: string);
// Objetivo...: buscar por código
begin
  tperso.IndexFieldNames := 'Nrodoc';
  tperso.FindNearest([xexpr]);
end;

procedure TTConyugeSepelio.BuscarPorNombre(xexpr: string);
// Objetivo...: buscar por nombre
begin
  tperso.IndexFieldNames := 'Nombre';
  tperso.FindNearest([xexpr]);
end;

function  TTConyugeSepelio.setMontoConyuge(xedad: String): Real;
// Objetivo...: Retornar costo
Begin
  Result := costogrupo.setMontoAPagar(xedad);
end;

function  TTConyugeSepelio.setMonto(xnrodoctitular: String): Real;
// Objetivo...: Obtener el monto a pagar
Begin
  getDatos(xnrodoctitular);
  Result := tit.FieldByName('monto').AsFloat;
end;

procedure TTConyugeSepelio.RegistrarMontoGrupoFamiliar(xnrodoc: String; xmonto: Real);
// Objetivo...: Registrar Monto a abonar
Begin
  if Buscar(xnrodoc) then Begin
    tit.Edit;
    tit.FieldByName('monto').AsFloat      := xmonto;
    try
      tit.Post
     except
      tit.Cancel
    end;
  end;
end;

procedure TTConyugeSepelio.conectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones = 0 then Begin
    if not tperso.Active then tperso.Open;
    tperso.FieldByName('nrodoc').DisplayLabel := 'Nº Doc.'; tperso.FieldByName('nombre').DisplayLabel := 'Nombre y Apellido'; tperso.FieldByName('direccion').DisplayLabel := 'Dirección';
    tperso.FieldByName('cp').Visible := False; tperso.FieldByName('orden').Visible := False;
    if not tit.Active then tit.Open;
  end;
  Inc(conexiones);
end;

procedure TTConyugeSepelio.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  Dec(conexiones);
  if conexiones = 0 then Begin
    datosdb.closeDB(tperso);
    datosdb.closeDB(tit);
  end;
end;

{===============================================================================}

function conyuge: TTConyugeSepelio;
begin
  if xconyuge = nil then
    xconyuge := TTConyugeSepelio.Create;
  Result := xconyuge;
end;

{===============================================================================}

initialization

finalization
  xconyuge.Free;

end.
