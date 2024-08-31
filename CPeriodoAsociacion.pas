unit CPeriodoAsociacion;

interface

uses CContabilidadAsociacion, SysUtils, CListar, DB, DBTables, CBDT, CUtiles, CIDBFM;

type

TTPeriodo = class
  periodo, observacion, dfecha, hfecha, pgfecha, phfecha, proteger, activo, estado, path: string;
  tperiodo: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  destroy; override;
  function    ValidarFecha(xfecha: string): boolean;

  procedure   Grabar(xperiodo, xobservacion, xdfecha, xhfecha, xpgfecha, xphfecha, xproteger: string);
  function    Borrar(xperiodo: string): boolean;
  function    Buscar(xperiodo: string): boolean;
  function    Nuevo: string;
  procedure   getDatos(xperiodo: string);

  function    PeriodoActivo: string;
  function    VerificarPeriodoActivo: boolean;
  procedure   Activar(xperiodo, est: string);
  procedure   Re_abrir(xperiodo: string);
  procedure   Cerrar(xperiodo: string);
  procedure   PeriodoProteger(xperiodo, prot: string);
  function    getEstadoCerrarOK: boolean;
  function    setPeriodos: TQuery;
  function    setPeriodosCerrados: TQuery;

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  conexiones: shortint;
end;

function per: TTPeriodo;

implementation

var
  xperiodo: TTPeriodo = nil;

constructor TTPeriodo.Create;
begin
  inherited Create;
  tperiodo := datosdb.openDB('periodo', '', '', contabilidad.dbcc);
end;

destructor TTPeriodo.Destroy;
begin
  inherited Destroy;
end;

procedure TTPeriodo.Grabar(xperiodo, xobservacion, xdfecha, xhfecha, xpgfecha, xphfecha, xproteger: string);
// Objetivo...: Grabar Atributos del Objeto
begin
  if Buscar(xperiodo) then tperiodo.Edit else tperiodo.Append;
  tperiodo.FieldByName('periodo').AsString     := xperiodo;
  tperiodo.FieldByName('observacion').AsString := xobservacion;
  tperiodo.FieldByName('dfecha').AsString      := utiles.sExprFecha(xdfecha);
  tperiodo.FieldByName('hfecha').AsString      := utiles.sExprFecha(xhfecha);
  tperiodo.FieldByName('pgfecha').AsString     := utiles.sExprFecha(xpgfecha);
  tperiodo.FieldByName('phfecha').AsString     := utiles.sExprFecha(xphfecha);
  tperiodo.FieldByName('proteger').AsString    := xproteger;
  if tperiodo.FieldByName('estado').AsString <> 'C' then tperiodo.FieldByName('estado').AsString := 'A';
  try
    tperiodo.Post
  except
    tperiodo.Cancel
  end;
end;

function TTPeriodo.Borrar(xperiodo: string): boolean;
// Objetivo...: Eliminar un Objeto
begin
  if Buscar(xperiodo) then begin
    tperiodo.Delete;
    getDatos(tperiodo.FieldByName('periodo').AsString);  // Fijamos los Atributos Siguientes al Objeto Borrado
    Result := True;
  end else
    Result := False;
end;

function TTPeriodo.Buscar(xperiodo: string): boolean;
// Objetivo...: Buscar el Objeto solicitado
begin
  if not tperiodo.Active then tperiodo.Open;
  if tperiodo.FindKey([xperiodo]) then Result := True else Result := False;
end;

procedure  TTPeriodo.getDatos(xperiodo: string);
// Objetivo...: Retornar/Iniciar Atributos
begin
  if Buscar(xperiodo) then begin
    periodo     := tperiodo.FieldByName('periodo').AsString;
    observacion := tperiodo.FieldByName('observacion').AsString;
    dfecha      := utiles.sFormatoFecha(tperiodo.FieldByName('dfecha').AsString);
    hfecha      := utiles.sFormatoFecha(tperiodo.FieldByName('hfecha').AsString);
    pgfecha     := utiles.sFormatoFecha(tperiodo.FieldByName('pgfecha').AsString);
    phfecha     := utiles.sFormatoFecha(tperiodo.FieldByName('phfecha').AsString);
    proteger    := tperiodo.FieldByName('proteger').AsString;
    activo      := tperiodo.FieldByName('activo').AsString;
    estado      := tperiodo.FieldByName('estado').AsString;
  end else begin
    periodo := ''; observacion := ''; dfecha := ''; hfecha := ''; pgfecha := ''; phfecha := ''; proteger := ''; activo := ''; estado := '';
  end;
end;

function TTPeriodo.Nuevo: string;
// Objetivo...: Generar un Nuevo Atributo Código
begin
  tperiodo.Last;
  if tperiodo.RecordCount > 0 then Result := IntToStr(tperiodo.FieldByName('periodo').AsInteger + 1) else Result := Copy(utiles.sExprFecha(DateToStr(now)), 1, 4);
end;

function TTPeriodo.PeriodoActivo: string;
// Objetivo...: Devolver el Período Activo
var
  p_act: string;
begin
  if not tperiodo.Active then conectar;
  p_act := '';
  tperiodo.First;
  while not tperiodo.EOF do begin
    if tperiodo.FieldByName('activo').AsString = 'X' then begin
      p_act := tperiodo.FieldByName('periodo').AsString;
      getDatos(p_act);
      break;
    end;
    tperiodo.Next;
  end;
  Result := p_act;
end;

function TTPeriodo.VerificarPeriodoActivo: boolean;
// Objetivo...: determinar si existe Periodo Activo
begin
  if Length(Trim(PeriodoActivo)) > 0 then Result := True else Result := False;
end;

procedure TTPeriodo.Activar(xperiodo, est: string);
// Objetivo...: Activar un período
begin
  tperiodo.First;
  while not tperiodo.EOF do begin
    if tperiodo.FieldByName('activo').AsString = 'X' then begin
      tperiodo.Edit;
      tperiodo.FieldByName('activo').AsString := '';
      tperiodo.Post;
    end;
    if (tperiodo.FieldByName('periodo').AsString = xperiodo) and (est = 'S') then begin
      tperiodo.Edit;
      tperiodo.FieldByName('activo').AsString := 'X';
      tperiodo.Post;
    end;
    tperiodo.Next;
  end;
end;

procedure TTPeriodo.PeriodoProteger(xperiodo, prot: string);
// Objetivo...: Proteger un período económico
begin
  tperiodo.First;
  while not tperiodo.EOF do begin
    if (prot = 'S') and (tperiodo.FieldByName('periodo').AsString = xperiodo) then begin
      tperiodo.Edit;
      tperiodo.FieldByName('proteger').AsString := 'S';
      tperiodo.Post;
    end else begin
      tperiodo.Edit;
      tperiodo.FieldByName('proteger').AsString := 'N';
      tperiodo.Post;
    end;

    tperiodo.Next;
  end;
end;

procedure TTPeriodo.Cerrar(xperiodo: string);
// Objetivo...: Cerrar un Período contable
begin
  if Buscar(xperiodo) then begin
    tperiodo.Edit;
    tperiodo.FieldByName('estado').AsString   := 'C';
    try
      tperiodo.Post;
     except
      tperiodo.Cancel;
    end;
  end;
end;

procedure TTPeriodo.Re_abrir(xperiodo: string);
// Objetivo...: Rehabrir un Periodo Cerrado
begin
  if Buscar(xperiodo) then begin
    tperiodo.Edit;
    tperiodo.FieldByName('estado').AsString   := 'A';
    try
      tperiodo.Post;
    except
      tperiodo.Cancel;
    end;
  end;
end;

function TTPeriodo.getEstadoCerrarOK: boolean;
// Objetivo...: Determinar si están definidas las opciones necesarias para el Cierre de un Ejercicio Contable
//              Controlamos que exista la cuenta de equilibrio (Resultados del Ejercicio)
begin
  Result := True;
end;

function TTPeriodo.setPeriodos: TQuery;
// Objetivo...: Determinar características multiempresa
begin
  Result := datosdb.tranSQL(contabilidad.dbconexion, 'SELECT * FROM periodo');
end;

function TTPeriodo.setPeriodosCerrados: TQuery;
// Objetivo...: Determinar características multiempresa
begin
  Result := datosdb.tranSQL(contabilidad.dbconexion, 'SELECT * FROM periodo WHERE estado = ' + '''' + 'C' + '''');
end;

function TTPeriodo.ValidarFecha(xfecha: string): boolean;
// Objetivo...: Determinar características multiempresa
begin
  if utiles.rangofechas(Dfecha, HFecha, xfecha) then Result := True else Result := False;
end;

procedure TTPeriodo.conectar;
// Objetivo...: Abrir tperiodos de persistencia
begin
  if conexiones = 0 then
    if not tperiodo.Active then tperiodo.Open;
  tperiodo.FieldByName('periodo').DisplayLabel := 'Período'; tperiodo.FieldByName('observacion').DisplayLabel := 'Observación';
  tperiodo.FieldByName('dfecha').DisplayLabel := 'Desde'; tperiodo.FieldByName('hfecha').DisplayLabel := 'Hasta';
  tperiodo.FieldByName('pgfecha').DisplayLabel := 'PR Desde'; tperiodo.FieldByName('phfecha').DisplayLabel := 'PR Hasta';
  tperiodo.FieldByName('proteger').DisplayLabel := 'Prot?'; tperiodo.FieldByName('estado').DisplayLabel := 'Estado';
  Inc(conexiones);
end;

procedure TTPeriodo.desconectar;
// Objetivo...: cerrar tperiodos de persistencia
begin
  if conexiones > 0 then Dec(conexiones);
  if conexiones = 0 then datosdb.closeDB(tperiodo);
end;

{===============================================================================}

function per: TTPeriodo;
begin
  if xperiodo = nil then
    xperiodo := TTPeriodo.Create;
  Result := xperiodo;
end;

{===============================================================================}

initialization

finalization
  xperiodo.Free;

end.