unit CViasSueldo;

interface

uses SysUtils, DB, DBTables, CUtiles, CListar, CFirebird, CUtilidadesArchivos,
     IBDatabase, IBCustomDataSet, IBTable, Variants, CBDT;

type

TTVias = class(TObject)
  Nomvia, Codemp, Descrip, Estado: string;
  tabla: TIBTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  procedure   Grabar(xnomvia, xdescrip: string);
  procedure   Borrar(xnomvia: string);
  function    Buscar(xnomvia: string): boolean;
  procedure   getDatos(xnomvia: string);
  function    BuscarPorDescrip(xexpr: string): Boolean;
  procedure   BuscarPorVia(xexpr: string);
  function    verificarSiLaViaEstaLibre(xnomvia, xcodemp: String): Boolean;
  procedure   FiltrarViasDesocupadas;
  procedure   QuitarFiltro;
  procedure   OcuparVia(xcodigo, xnomvia: String);
  procedure   PrepararVia(xnomvia: String);

  procedure   conectar;
  procedure   desconectar;
 private
  conexiones: shortint;
  { Declaraciones Privadas }
end;

function via: TTVias;

implementation

var
  xvia: TTVias = nil;

constructor TTVias.Create;
begin
  inherited Create;
  firebird.getModulo('sueldos');
  firebird.Conectar(firebird.Host + '\arch\arch.gdb', firebird.Usuario, firebird.Password);
  tabla := firebird.InstanciarTabla('vias');
end;

destructor TTVias.Destroy;
begin
  inherited Destroy;
end;

procedure TTVias.Grabar(xnomvia, xdescrip: string);
// Objetivo...: Grabar Atributos del Objeto
begin
  if Buscar(xnomvia) then tabla.Edit else tabla.Append;
  tabla.FieldByName('nomvia').AsString      := xnomvia;
  tabla.FieldByName('descrip').AsString     := xdescrip;
  if tabla.FieldByName('estado').AsString <> 'O' then tabla.FieldByName('estado').AsString := 'D';
  try
    tabla.Post;
   except
    tabla.Cancel
  end;
  firebird.RegistrarTransaccion(tabla);
end;

procedure TTVias.Borrar(xnomvia: string);
// Objetivo...: Eliminar un Objeto
begin
  if Buscar(xnomvia) then Begin
    tabla.Delete;
    getDatos(tabla.FieldByName('NOMVIA').AsString);  // Fijamos los Atributos Siguientes al Objeto Borrado
    firebird.RegistrarTransaccion(tabla);
  end;
end;

function TTVias.Buscar(xnomvia: string): boolean;
// Objetivo...: Buscar el Objeto solicitado
begin
  if tabla.IndexFieldNames <> 'NOMVIA' then tabla.IndexFieldNames := 'NOMVIA';
  Result := firebird.Buscar(tabla, 'NOMVIA', xnomvia);
end;

procedure  TTVias.getDatos(xnomvia: string);
// Objetivo...: Retornar/Iniciar Atributos
begin
  if Buscar(xnomvia) then Begin
    Nomvia      := tabla.FieldByName('NOMVIA').AsString;
    descrip     := tabla.FieldByName('DESCRIP').AsString;
  end else Begin
    nomvia := ''; descrip := '';
  end;
end;

function TTVias.BuscarPorDescrip(xexpr: string): Boolean;
// Objetivo...: Buscar Médico por nombre
begin
  if tabla.IndexFieldNames <> 'DESCRIP' then tabla.IndexFieldNames := 'DESCRIP';
  firebird.BuscarContextualmente(tabla, 'DESCRIP', xexpr);
end;

procedure TTVias.BuscarPorVia(xexpr: string);
begin
  if tabla.IndexFieldNames <> 'NOMVIA' then tabla.IndexFieldNames := 'NOMVIA';
  firebird.BuscarContextualmente(tabla, 'NOMVIA', xexpr);
end;

function TTVias.verificarSiLaViaEstaLibre(xnomvia, xcodemp: String): Boolean;
// Objetivo...: Buscar el Objeto solicitado
begin
  Result := True;
  if firebird.Buscar(tabla, 'NOMVIA', xnomvia) then Begin
    if (tabla.FieldByName('estado').AsString = 'O') and (tabla.FieldByName('codemp').AsString <> xcodemp)  then Result := False;
    if (tabla.FieldByName('estado').AsString = 'D') then Result := True;
  end;
end;

procedure TTVias.FiltrarViasDesocupadas;
// Objetivo...: Filtrar tablas desocupadas
Begin
  firebird.Filtrar(tabla, 'ESTADO = ' + '''' + 'D' + '''');
end;

procedure TTVias.QuitarFiltro;
// Objetivo...: quitar filtro
Begin
  firebird.QuitarFiltro(tabla);
end;

procedure TTVias.OcuparVia(xcodigo, xnomvia: String);
// Objetivo...: Ocupar Vía de trabajo
Begin
  if Buscar(xnomvia) then Begin
    tabla.Edit;
    tabla.FieldByName('codemp').AsString := xcodigo;
    tabla.FieldByName('estado').AsString := 'O';
    try
      tabla.Post;
     except
      tabla.Cancel
    end;
    firebird.RegistrarTransaccion(tabla);
  end;
end;

procedure TTVias.PrepararVia(xnomvia: String);
// Objetivo...: Definir Vía
begin
  if not DirectoryExists(dbs.DirSistema + '\' + xnomvia) then utilesarchivos.CrearDirectorio(dbs.DirSistema + '\' + xnomvia);
  if not FileExists(dbs.DirSistema + '\' + xnomvia + '\datosempr.gdb') then utilesarchivos.CopiarArchivos(dbs.DirSistema + '\estructu', '*.gdb', dbs.DirSistema + '\' + xnomvia);
end;

procedure TTVias.conectar;
// Objetivo...: Abrir tablas de persistencia
begin
  if conexiones = 0 then Begin
    if not tabla.Active then tabla.Open;
  end;
  tabla.FieldByName('NOMVIA').DisplayLabel := 'Vía'; tabla.FieldByName('DESCRIP').DisplayLabel := 'Descripción';
  Inc(conexiones);
end;

procedure TTVias.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones > 0 then Dec(conexiones);
  if conexiones = 0 then firebird.closeDB(tabla);
end;

{===============================================================================}

function via: TTVias;
begin
  if xvia = nil then
    xvia := TTVias.Create;
  Result := xvia;
end;

{===============================================================================}

initialization

finalization
  xvia.Free;

end.
