unit CMedicosCabCCB;

interface

uses CBDT, SysUtils, DBTables, CUtiles, CListar, CIDBFM, Classes, CMedicosCCB, Contnrs;

type

TTMedicosCabCCB = class
  Codos, Idprof, Periodo: String; Cantcapitas: Real;
  medicoscab, medicoscap: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  function    BuscarMedicoCabecera(xcodos, xidprof: String): Boolean;
  procedure   RegistrarMedicoCabecera(xcodos, xidprof: String; xcantcapitas: Integer);
  procedure   BorrarMedicoCabecera(xcodos, xidprof: String);
  function    VerificarSiLaObraSocialTieneMedicoCabecera(xcodos: String): Boolean;
  function    setListaMedicosCabecera(xcodos: String): TStringList;
  function    setMedicoCabecera(xcodos, xidprof: String): String;

  function    BuscarCapita(xcodos, xidprof, xperiodo: String): Boolean;
  procedure   RegistrarCapita(xcodos, xidprof, xperiodo: String; xcantidad: Real);
  procedure   BorrarCapita(xcodos, xidprof, xperiodo: String);
  function    setCapitas(xcodos, xidprof: String): TObjectList;
  function    setCantidadCapitas(xcodos, xidprof, xperiodo: String): String;

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  conexiones: shortint;
  conexion: String;
end;

function medcab: TTMedicosCabCCB;

implementation

var
  xmedcab: TTMedicosCabCCB = nil;

constructor TTMedicosCabCCB.Create;
begin
  inherited Create;
  dbs.getParametrosDB1;     // Base de datos adicional 1
  if Length(Trim(dbs.db1)) > 0 then Begin
    dbs.NuevaBaseDeDatos(dbs.db1, dbs.us1, dbs.pa1);
    conexion := dbs.baseDat_N;
  end else
    conexion := dbs.DirSistema + '\auditoria';

  medicoscab := datosdb.openDB('medicos_cab', '', '', conexion);
  medicoscap := datosdb.openDB('medicos_cap', '', '', conexion);
end;

destructor TTMedicosCabCCB.Destroy;
begin
  inherited Destroy;
end;

function  TTMedicosCabCCB.BuscarMedicoCabecera(xcodos, xidprof: String): Boolean;
// Objetivo...: Buscar una instancia
begin
  if medicoscab.IndexFieldNames <> 'Codos;Idprof' then medicoscab.IndexFieldNames := 'Codos;Idprof';
  Result := datosdb.Buscar(medicoscab, 'codos', 'idprof', xcodos, xidprof);
end;

procedure TTMedicosCabCCB.RegistrarMedicoCabecera(xcodos, xidprof: String; xcantcapitas: Integer);
// Objetivo...: registrar una instancia
begin
  if BuscarMedicoCabecera(xcodos, xidprof) then medicoscab.Edit else medicoscab.Append;
  medicoscab.FieldByName('codos').AsString        := xcodos;
  medicoscab.FieldByName('idprof').AsString       := xidprof;
  medicoscab.FieldByName('cantcapitas').AsInteger := xcantcapitas;
  try
    medicoscab.Post
   except
    medicoscab.Cancel
  end;
  datosdb.closeDB(medicoscab); medicoscab.Open;
end;

procedure TTMedicosCabCCB.BorrarMedicoCabecera(xcodos, xidprof: String);
// Objetivo...: borrar una instancia
begin
  if BuscarMedicoCabecera(xcodos, xidprof) then Begin
    medicoscab.Delete;
    datosdb.closeDB(medicoscab); medicoscab.Open;
  end;
end;

function  TTMedicosCabCCB.VerificarSiLaObraSocialTieneMedicoCabecera(xcodos: String): Boolean;
// Objetivo...: verificar si la os tiene medico de cabecera
begin
  if medicoscab.IndexFieldNames <> 'Codos' then medicoscab.IndexFieldNames := 'Codos';
  Result := medicoscab.FindKey([xcodos]);
end;

function  TTMedicosCabCCB.setListaMedicosCabecera(xcodos: String): TStringList;
// Objetivo...: verificar si la os tiene medico de cabecera
var
  l: TStringList;
  f: Boolean;
begin
  f := medicoscab.Active;
  if not f then medicoscab.Active := True;
  l := TStringList.Create;
  if medicoscab.IndexFieldNames <> 'Codos;Idprof' then medicoscab.IndexFieldNames := 'Codos;Idprof';
  datosdb.Filtrar(medicoscab, 'codos = ' + '''' + xcodos + '''');
  medicoscab.First;
  while not medicoscab.Eof do Begin
    medico.getDatos(medicoscab.FieldByName('idprof').AsString);
    l.Add(medico.Nombre + ';1' + medicoscab.FieldByName('idprof').AsString + medicoscab.FieldByName('cantcapitas').AsString);
    medicoscab.Next;
  end;
  datosdb.QuitarFiltro(medicoscab);
  medicoscab.Active := f;
  l.Sort;
  Result := l;
end;

function  TTMedicosCabCCB.setMedicoCabecera(xcodos, xidprof: String): String;
// Objetivo...: buscar médico de cabecera
begin
  if BuscarMedicoCabecera(xcodos, xidprof) then Begin
    medico.getDatos(xidprof);
    Result := medico.Nombre;
  end else
    Result := 'Sin Definir';
end;

{function TTMedicosCabCCB.setCantidadCapitas(xcodos, xidprof: String): String;
// Objetivo...: devolver la cantidad de capitas del medico de cabecera
Begin
  if BuscarMedicoCabecera(xcodos, xidprof) then Result := medicoscab.FieldByName('cantcapitas').AsString else Result := '0';
end;}

function  TTMedicosCabCCB.BuscarCapita(xcodos, xidprof, xperiodo: String): Boolean;
// Objetivo...: Buscar Instancia
begin
  Result := datosdb.Buscar(medicoscap, 'codos', 'idprof', 'periodo', xcodos, xidprof, Copy(xperiodo, 4, 4) + Copy(xperiodo, 1, 2));
end;

procedure TTMedicosCabCCB.RegistrarCapita(xcodos, xidprof, xperiodo: String; xcantidad: Real);
// Objetivo...: Registrar Instancia
begin
  if BuscarCapita(xcodos, xidprof, xperiodo) then medicoscap.Edit else medicoscap.Append;
  medicoscap.FieldByName('codos').AsString   := xcodos;
  medicoscap.FieldByName('idprof').AsString  := xidprof;
  medicoscap.FieldByName('periodo').AsString := Copy(xperiodo, 4, 4) + Copy(xperiodo, 1, 2);
  medicoscap.FieldByName('capitas').AsFloat  := xcantidad;
  try
    medicoscap.Post
   except
    medicoscap.Cancel
  end;
  datosdb.closeDB(medicoscap); medicoscap.Open;
end;

procedure TTMedicosCabCCB.BorrarCapita(xcodos, xidprof, xperiodo: String);
// Objetivo...: Borrar Instancia
begin
  if BuscarCapita(xcodos, xidprof, xperiodo) then Begin
    medicoscap.Delete;
    datosdb.closeDB(medicoscap); medicoscap.Open;
  end;
end;

function  TTMedicosCabCCB.setCapitas(xcodos, xidprof: String): TObjectList;
// Objetivo...: Devolver una Colección
var
  l: TObjectList;
  objeto: TTMedicosCabCCB;
begin
  l := TObjectList.Create;
  datosdb.Filtrar(medicoscap, 'codos = ' + '''' + xcodos + '''' + ' and idprof = ' + '''' + xidprof + '''');
  medicoscap.First;
  while not medicoscap.Eof do Begin
    objeto := TTMedicosCabCCB.Create;
    objeto.Codos       := medicoscap.FieldByName('codos').AsString;
    objeto.Idprof      := medicoscap.FieldByName('idprof').AsString;
    objeto.Periodo     := Copy(medicoscap.FieldByName('periodo').AsString, 5, 2) + '/' + Copy(medicoscap.FieldByName('periodo').AsString, 1, 4);
    objeto.Cantcapitas := medicoscap.FieldByName('capitas').AsFloat;
    l.Add(objeto);
    medicoscap.Next;
  end;
  datosdb.QuitarFiltro(medicoscap);

  Result := l;
end;

function TTMedicosCabCCB.setCantidadCapitas(xcodos, xidprof, xperiodo: String): String;
// Objetivo...: devolver la cantidad de capitas del medico de cabecera
var
  r: String;
Begin
  r := '0';
  datosdb.Filtrar(medicoscap, 'codos = ' + '''' + xcodos + '''' + ' and idprof = ' + '''' + xidprof + '''');
  medicoscap.First;
  while not medicoscap.Eof do Begin
    if r = '0' then r := medicoscap.FieldByName('capitas').AsString;
    if (medicoscap.FieldByName('periodo').AsString <= Copy(xperiodo, 4, 4) + Copy(xperiodo, 1, 2)) then
      r := medicoscap.FieldByName('capitas').AsString
    else
      Break;
    medicoscap.Next;
  end;
  datosdb.QuitarFiltro(medicoscap);

  Result := r;
end;


procedure TTMedicosCabCCB.conectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones = 0 then Begin
    if not medicoscab.Active then medicoscab.Open;
    if not medicoscap.Active then medicoscap.Open;
  end;
  Inc(conexiones);

  if medicoscap.RecordCount = 0 then Begin
    medicoscab.First;
    while not medicoscab.Eof do Begin
      RegistrarCapita(medicoscab.FieldByname('codos').AsString, medicoscab.FieldByname('idprof').AsString, '01/2005', medicoscab.FieldByName('cantcapitas').AsFloat);
      medicoscab.Next;
    end;
    medicoscab.First;
  end;
end;

procedure TTMedicosCabCCB.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  Dec(conexiones);
  if conexiones = 0 then Begin
    datosdb.closeDB(medicoscab);
    datosdb.closeDB(medicoscap);
  end;
end;

{===============================================================================}

function medcab: TTMedicosCabCCB;
begin
  if xmedcab = nil then
    xmedcab := TTMedicosCabCCB.Create;
  Result := xmedcab;
end;

{===============================================================================}

initialization

finalization
  xmedcab.Free;

end.
