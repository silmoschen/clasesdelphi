unit CLogSeg;

interface

uses CBDT, SysUtils, DBTables, CUtiles, CListar, CIDBFM;

type

TTlogsist = class
  tabla: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  procedure   RegistrarLog(xusuario, xmodulo, xoperacion: String);
  procedure   Filtrar(xfdesde, xfhasta: String);
  procedure   QuitarFiltro;

  procedure   Listar(salida: char);

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  conexiones: shortint;
end;

function logsist: TTlogsist;

implementation

var
  xlogsist: TTlogsist = nil;

constructor TTlogsist.Create;
begin
  if dbs.BaseClientServ = 'N' then tabla := datosdb.openDB('log', '', '', dbs.DirSistema + '\log') else Begin
    dbs.NuevaBaseDeDatos2('logadrreconquista', 'sysdba', 'masterkey');
    tabla := datosdb.openDB('log', '', '', dbs.TDB2.DatabaseName);
  end;
end;

destructor TTlogsist.Destroy;
begin
  inherited Destroy;
end;

procedure TTlogsist.RegistrarLog(xusuario, xmodulo, xoperacion: String);
// Objetivo...: Registrar Log
var
  id, it: String;
  i: Integer;
begin
  id := utiles.setIdRegistroFecha;
  tabla.Open;
  For i := 1 to 99 do Begin
    it := utiles.sLlenarIzquierda(IntToStr(i), 2, '0');
    if not datosdb.Buscar(tabla, 'id', 'items', id, it) then Begin
      tabla.Append;
      Break;
    end;
  end;

  tabla.FieldByName('id').AsString        := id;
  tabla.FieldByName('items').AsString     := it;
  tabla.FieldByName('usuario').AsString   := xusuario;
  tabla.FieldByName('fecha').AsString     := Copy(id, 1, 8);
  tabla.FieldByName('fecha1').AsString    := utiles.sFormatoFecha(Copy(id, 1, 8));
  tabla.FieldByName('modulo').AsString    := xmodulo;
  tabla.FieldByName('operacion').AsString := xoperacion;
  tabla.FieldByName('hora').AsString      := utiles.setHoraActual24;
  try
    tabla.Post
   except
    tabla.Cancel
  end;
  datosdb.closeDB(tabla);
end;

procedure TTlogsist.Filtrar(xfdesde, xfhasta: String);
// Objetivo...: Filtrar datos
begin
  datosdb.Filtrar(tabla, 'fecha >= ' + '''' + utiles.sExprFecha2000(xfdesde) + '''' + ' and fecha <= ' + '''' + utiles.sExprFecha2000(xfhasta) + '''');
  tabla.Last;
end;

procedure TTlogsist.Listar(salida: char);
// Objetivo...: Quitar filtro
begin
  list.Setear(salida); 
  list.Titulo(0, 0, '', 1, 'Arial, normal, 18');
  list.Titulo(0, 0, 'Detalle Operaciones Usuarios', 1, 'Arial, normal, 14');
  list.Titulo(0, 0, '', 1, 'Arial, normal, 5');
  list.Titulo(0, 0, 'Usuario', 1, 'Arial, cursiva, 8');
  list.Titulo(18, list.Lineactual, 'Fecha/Hora', 2, 'Arial, cursiva, 8');
  list.Titulo(35, list.Lineactual, 'Modulo', 3, 'Arial, cursiva, 8');
  list.Titulo(65, list.Lineactual, 'Operación', 4, 'Arial, cursiva, 8');
  list.Titulo(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11');
  list.Titulo(0, 0, '', 1, 'Arial, normal, 5');

  tabla.First;
  while not tabla.Eof do Begin
    list.Linea(0, 0, tabla.FieldByName('usuario').AsString, 1, 'Arial, normal, 8', salida, 'N');
    list.Linea(18, list.Lineactual, tabla.FieldByName('fecha1').AsString + '  ' + tabla.FieldByName('hora').AsString, 2, 'Arial, normal, 8', salida, 'N');
    list.Linea(35, list.Lineactual, tabla.FieldByName('modulo').AsString, 3, 'Arial, normal, 8', salida, 'N');
    list.Linea(65, list.Lineactual, tabla.FieldByName('operacion').AsString, 4, 'Arial, normal, 8', salida, 'S');
    tabla.Next;
  end;
  list.FinList;
end;

procedure TTlogsist.QuitarFiltro;
// Objetivo...: Quitar filtro
begin
  datosdb.QuitarFiltro(tabla);
  tabla.Last;
end;

procedure TTlogsist.conectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones = 0 then Begin
    if not tabla.Active then tabla.Open;
    tabla.FieldByName('id').DisplayLabel := 'Id.Trans.'; tabla.FieldByName('items').DisplayLabel := 'It.'; tabla.FieldByName('usuario').DisplayLabel := 'Usuario'; tabla.FieldByName('fecha1').DisplayLabel := 'Fecha'; tabla.FieldByName('modulo').DisplayLabel := 'Módulo'; tabla.FieldByName('operacion').DisplayLabel := 'Operación';
    tabla.FieldByName('fecha').Visible  := False; tabla.FieldByName('hora').DisplayLabel := 'Hora';
    tabla.Last;
  end;
  Inc(conexiones);
end;

procedure TTlogsist.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  Dec(conexiones);
  if conexiones = 0 then Begin
    datosdb.closeDB(tabla);
  end;
end;

{===============================================================================}

function logsist: TTlogsist;
begin
  if xlogsist = nil then
    xlogsist := TTlogsist.Create;
  Result := xlogsist;
end;

{===============================================================================}

initialization

finalization
  xlogsist.Free;

end.
