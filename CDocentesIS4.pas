unit CDocentesIS4;

interface

uses CPersonaDBExpress, DBClient, CdbExpressBase, SysUtils, CUtiles, CListar,
     Classes, DBTables, CIDBFM, CBDT;

type

TTDocente = class(TTPersona)
  Apellido, Telefono, FechaNac, Estcivil, Email, Carpetam, Estante, Titulo: String;
  tabla: TClientDataSet;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  function    Buscar(xnrodoc: String): Boolean;
  procedure   Registrar(xnrodoc, xapellido, xnombre, xdireccion, xcp, xorden,
              xtelefono, xfechanac, xestcivil, xemail, xcarpetam, xestante, xtitulo: String);
  procedure   getDatos(xnrodoc: String);
  procedure   Borrar(xnrodoc: String);

  procedure   BuscarPorApellido(xexpr: String);
  procedure   BuscarPorDocumento(xexpr: String);

  function    setDocentesAlf: TClientDataSet;

  procedure   Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);

  procedure   Exportar(xlista: TStringList);
  procedure   Importar;

  procedure   Instaciar(xvia: String);
  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  conexiones: shortint;
  procedure   Enccol;
end;

function docente: TTDocente;

implementation

var
  xdocente: TTDocente = nil;

constructor TTDocente.Create;
begin
  tperso := dbEx.conn.InstanciarTabla('docentes');
  tabla  := dbEx.conn.InstanciarTabla('docentesh');
end;

destructor TTDocente.Destroy;
begin
  inherited Destroy;
end;

function  TTDocente.Buscar(xnrodoc: String): Boolean;
// Objetivo...: Buscar instancia del objeto
begin
  if tabla.IndexFieldNames <> 'nrodoc' then tabla.IndexFieldNames := 'nrodoc';
  if tperso.IndexFieldNames <> 'nrodoc' then tperso.IndexFieldNames := 'nrodoc';
  Result := tabla.FindKey([xnrodoc]);
  inherited Buscar(xnrodoc);
end;

procedure TTDocente.Registrar(xnrodoc, xapellido, xnombre, xdireccion, xcp, xorden,
              xtelefono, xfechanac, xestcivil, xemail, xcarpetam, xestante, xtitulo: String);
// Objetivo...: Registrar instancia del objeto
begin
  inherited GrabarApNombre(xnrodoc, xapellido, xnombre, xdireccion, xcp, xorden);
  if Buscar(xnrodoc) then tabla.Edit else tabla.Append;
  tabla.FieldByName('nrodoc').AsString       := xnrodoc;
  tabla.FieldByName('telefono').AsString     := xtelefono;
  tabla.FieldByName('fnac').AsString         := utiles.sExprFecha2000(xfechanac);
  tabla.FieldByName('estcivil').AsString     := xestcivil;
  tabla.FieldByName('email').AsString        := xemail;
  tabla.FieldByName('carpetam').AsString     := xcarpetam;
  tabla.FieldByName('estante').AsString      := xestante;
  tabla.FieldByName('titulo').AsString       := xtitulo;
  try
    tabla.Post
   except
    tabla.Cancel
  end;
  tabla.ApplyUpdates(-1);
  Enccol;
end;

procedure TTDocente.getDatos(xnrodoc: String);
// Objetivo...: Recuperar instancia del objeto
begin
  if Buscar(xnrodoc) then Begin
    apellido     := tperso.FieldByName('apellido').AsString;
    telefono     := tabla.FieldByName('telefono').AsString;
    fechanac     := utiles.sFormatoFecha(tabla.FieldByName('fnac').AsString);
    estcivil     := tabla.FieldByName('estcivil').AsString;
    email        := tabla.FieldByName('email').AsString;
    carpetam     := tabla.FieldByName('carpetam').AsString;
    estante      := tabla.FieldByName('estante').AsString;
    titulo       := tabla.FieldByName('titulo').AsString;
  end else Begin
    apellido := ''; telefono := ''; fechanac := ''; estcivil := ''; email := '';
    carpetam := ''; estante := ''; titulo := '';
  end;
  tperso.IndexFieldNames := 'nrodoc';
  inherited getDatosApNombre(xnrodoc);
end;

procedure TTDocente.Borrar(xnrodoc: String);
// Objetivo...: Borrar instancia del objeto
begin
  if Buscar(xnrodoc) then Begin
    tabla.Delete;
    tabla.ApplyUpdates(-1);
    inherited Borrar(xnrodoc);
  end;
end;

procedure TTDocente.BuscarPorApellido(xexpr: String);
// Objetivo...: buscar por apellido
begin
  if tperso.IndexFieldNames <> 'Apellido' then tperso.IndexFieldNames := 'Apellido';
  tperso.FindNearest([xexpr]);
end;

procedure TTDocente.BuscarPorDocumento(xexpr: String);
// Objetivo...: buscar por documento
begin
  if tperso.IndexFieldNames <> 'Nrodoc' then tperso.IndexFieldNames := 'Nrodoc';
  tperso.FindNearest([xexpr]);
end;

procedure TTDocente.Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
// Objetivo...: Listar Datos de Provincias

procedure list_linea(salida: char);
Begin
  tabla.FindKey([tperso.FieldByName('nrodoc').AsString]);
  list.Linea(0, 0, tperso.FieldByName('nrodoc').AsString, 1, 'Arial, normal, 8', salida, 'N');
  list.Linea(15, list.Lineactual, tperso.FieldByName('apellido').AsString + ', ' + tperso.FieldByName('nombres').AsString, 2, 'Arial, normal, 8', salida, 'N');
  list.Linea(60, list.Lineactual, tperso.FieldByName('domicilio').AsString, 3, 'Arial, normal, 8', salida, 'N');
  list.Linea(85, list.Lineactual, tabla.FieldByName('telefono').AsString, 4, 'Arial, normal, 8', salida, 'S');
end;

begin
  if orden = 'A' then tabla.IndexName := tabla.IndexDefs.Items[1].Name;

  list.Setear(salida);
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Listado de Docentes', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Documento', 1, 'Arial, cursiva, 8');
  List.Titulo(15, List.lineactual, 'Apellido y Nombres', 2, 'Arial, cursiva, 8');
  List.Titulo(60, List.lineactual, 'Direccion', 3, 'Arial, cursiva, 8');
  List.Titulo(85, List.lineactual, 'Teléfono', 4, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  tperso.First;
  while not tperso.EOF do
    begin
      // Ordenado por Código
      if (ent_excl = 'E') and (orden = 'C') then
        if (tperso.FieldByName('nrodoc').AsString >= iniciar) and (tperso.FieldByName('nrodoc').AsString <= finalizar) then list_linea(salida);

      if (ent_excl = 'X') and (orden = 'C') then
        if (tperso.FieldByName('nrodoc').AsString < iniciar) or (tperso.FieldByName('nrodoc').AsString > finalizar) then List_linea(salida);
      // Ordenado Alfabéticamente
      if (ent_excl = 'E') and (orden = 'A') then
        if (tperso.FieldByName('apellido').AsString >= iniciar) and (tperso.FieldByName('apellido').AsString <= finalizar) then List_linea(salida);
      if (ent_excl = 'X') and (orden = 'A') then
        if (tperso.FieldByName('apellido').AsString < iniciar) or (tperso.FieldByName('apellido').AsString > finalizar) then List_linea(salida);

      tperso.Next;
    end;
    List.FinList;

    tabla.First;
end;

function  TTDocente.setDocentesAlf: TClientDataSet;
// Objetivo...: Devolver Docentes ordenados alfabeticamente
begin
  Result := dbEx.conn.tranSQL('select nrodoc, apellido, nombres from docentes order by apellido');
end;

procedure TTDocente.Exportar(xlista: TStringList);
// Objetivo...: Exportar Docentes
var
  exp_tperso, exp_tabla: TTable;
  i: Integer;
Begin
  exp_tperso := datosdb.openDB('docentes', '', '', dbs.DirSistema + '\exportar\escalafon\work');
  exp_tabla  := datosdb.openDB('docentesh', '', '', dbs.DirSistema + '\exportar\escalafon\work');
  exp_tperso.Open; exp_tabla.Open;

  for i := 1 to xlista.Count do Begin
    if tperso.FindKey([xlista.Strings[i-1]]) then Begin
      if exp_tperso.FindKey([tperso.FieldByName('nrodoc').AsString]) then exp_tperso.Edit else exp_tperso.Append;
      exp_tperso.FieldByName('nrodoc').AsString    := tperso.FieldByName('nrodoc').AsString;
      exp_tperso.FieldByName('apellido').AsString  := tperso.FieldByName('apellido').AsString;
      exp_tperso.FieldByName('nombres').AsString   := tperso.FieldByName('nombres').AsString;
      exp_tperso.FieldByName('domicilio').AsString := tperso.FieldByName('domicilio').AsString;
      exp_tperso.FieldByName('cp').AsString        := tperso.FieldByName('cp').AsString;
      exp_tperso.FieldByName('orden').AsString     := tperso.FieldByName('orden').AsString;
      try
        exp_tperso.Post
       except
        exp_tperso.Cancel
      end;
    end;

    if tabla.FindKey([xlista.Strings[i-1]]) then Begin
      if exp_tabla.FindKey([tabla.FieldByName('nrodoc').AsString]) then exp_tabla.Edit else exp_tabla.Append;
      exp_tabla.FieldByName('nrodoc').AsString   := tabla.FieldByName('nrodoc').AsString;
      exp_tabla.FieldByName('telefono').AsString := tabla.FieldByName('telefono').AsString;
      exp_tabla.FieldByName('fnac').AsString     := tabla.FieldByName('fnac').AsString;
      exp_tabla.FieldByName('email').AsString    := tabla.FieldByName('email').AsString;
      exp_tabla.FieldByName('carpetam').AsString := tabla.FieldByName('carpetam').AsString;
      exp_tabla.FieldByName('benprev').AsString  := tabla.FieldByName('benprev').AsString;
      exp_tabla.FieldByName('estante').AsString  := tabla.FieldByName('estante').AsString;
      exp_tabla.FieldByName('estcivil').AsString := tabla.FieldByName('estcivil').AsString;
      exp_tabla.FieldByName('titulo').AsString   := tabla.FieldByName('titulo').AsString;
      try
        exp_tabla.Post
       except
        exp_tabla.Cancel
      end;
    end;
  end;

  datosdb.closeDB(exp_tperso);
  datosdb.closeDB(exp_tabla);
end;

procedure TTDocente.Importar;
// Objetivo...: Importar Docentes
var
  exp_tperso, exp_tabla: TTable;
  i: Integer;
Begin
  exp_tperso := datosdb.openDB('docentes', '', '', dbs.DirSistema + '\importar\escalafon\work');
  exp_tabla  := datosdb.openDB('docentesh', '', '', dbs.DirSistema + '\importar\escalafon\work');
  exp_tperso.Open; exp_tabla.Open;

  while not exp_tperso.Eof do Begin
    if tperso.FindKey([exp_tperso.FieldByName('nrodoc').AsString]) then tperso.Edit else tperso.Append;
    tperso.FieldByName('nrodoc').AsString    := exp_tperso.FieldByName('nrodoc').AsString;
    tperso.FieldByName('apellido').AsString  := exp_tperso.FieldByName('apellido').AsString;
    tperso.FieldByName('nombres').AsString   := exp_tperso.FieldByName('nombres').AsString;
    tperso.FieldByName('domicilio').AsString := exp_tperso.FieldByName('domicilio').AsString;
    tperso.FieldByName('cp').AsString        := exp_tperso.FieldByName('cp').AsString;
    tperso.FieldByName('orden').AsString     := exp_tperso.FieldByName('orden').AsString;
    try
      tperso.Post
     except
      tperso.Cancel
    end;
    tperso.ApplyUpdates(-1);
    exp_tperso.Next;
  end;

  while not exp_tabla.Eof do Begin
    if tabla.FindKey([exp_tabla.FieldByName('nrodoc').AsString]) then tabla.Edit else tabla.Append;
    tabla.FieldByName('nrodoc').AsString   := exp_tabla.FieldByName('nrodoc').AsString;
    tabla.FieldByName('telefono').AsString := exp_tabla.FieldByName('telefono').AsString;
    tabla.FieldByName('fnac').AsString     := exp_tabla.FieldByName('fnac').AsString;
    tabla.FieldByName('email').AsString    := exp_tabla.FieldByName('email').AsString;
    tabla.FieldByName('carpetam').AsString := exp_tabla.FieldByName('carpetam').AsString;
    tabla.FieldByName('benprev').AsString  := exp_tabla.FieldByName('benprev').AsString;
    tabla.FieldByName('estante').AsString  := exp_tabla.FieldByName('estante').AsString;
    tabla.FieldByName('estcivil').AsString := exp_tabla.FieldByName('estcivil').AsString;
    tabla.FieldByName('titulo').AsString   := exp_tabla.FieldByName('titulo').AsString;
    try
      tabla.Post
     except
      tabla.Cancel
    end;
    tabla.ApplyUpdates(-1);
    exp_tabla.Next;
  end;

  datosdb.closeDB(exp_tperso);
  datosdb.closeDB(exp_tabla);
end;

procedure TTDocente.Enccol;
// Objetivo...: Encabezado de columnas
begin
  tperso.FieldByName('nrodoc').Displaylabel := 'Nro. Doc.'; tperso.FieldByName('apellido').Displaylabel := 'Apellido';
  tperso.FieldByName('nombres').Displaylabel := 'Nombres'; tperso.FieldByName('domicilio').Displaylabel := 'Domicilio';
  tperso.FieldByName('cp').Displaylabel := 'CP'; tperso.FieldByName('orden').Displaylabel := 'Orden';
end;

procedure TTDocente.Instaciar(xvia: String);
// Objetivo...: Instanciar Persistencia en otra Vía
begin
  conexiones := 1;
  desconectar;
  //tperso := datosdb.openDB('docentes', '', '', xvia);
  //tabla  := datosdb.openDB('docentesh', '', '', xvia);
  conectar;
end;

procedure TTDocente.conectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones = 0 then Begin
    if not tperso.Active then tperso.Open;
    if not tabla.Active then tabla.Open;
  end;
  Inc(conexiones);
  Enccol;
end;

procedure TTDocente.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones > 0 then Dec(conexiones);
  if conexiones = 0 then Begin
    dbEx.conn.closeDB(tperso);
    dbEx.conn.closeDB(tabla);
  end;
end;

{===============================================================================}

function docente: TTDocente;
begin
  if xdocente = nil then
    xdocente := TTDocente.Create;
  Result := xdocente;
end;

{===============================================================================}

initialization

finalization
  xdocente.Free;

end.
