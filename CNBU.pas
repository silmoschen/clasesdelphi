unit CNBU;

interface

uses SysUtils, DB, DBTables, CBDT, CIDBFM, CUtiles, CListar, Forms, CNomeclaCCB, Classes;

type

TTNBU = class(TObject)
  Codigo, Descrip, CodNNN, Especial: string; unidad, unidades: Real;
  tabla, codigosNBU, nbu_nnn: TTable;
 public
  { Declaraciones P�blicas }
  constructor Create;
  destructor  Destroy; override;

  procedure   Grabar(xcodigo, xdescrip, xcodnnn: string; xunidad, xunidades: Real);
  procedure   Borrar(xcodigo: string);
  function    Buscar(xcodigo: string): boolean;
  procedure   getDatos(xcodigo: string);
  function    setDeterminaciones: TQuery;
  function    setDescripes: TQuery;
  function    Nuevo: string;
  procedure   Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
  procedure   BuscarPorDescrip(xexpr: string);
  procedure   BuscarPorId(xexpr: string);
  procedure   BuscarPorCodigoNNN(xexpr: string);
  function    BuscarCodigoNNN(xcodnnn: String): Boolean; overload;
  function    setCodigoNBU(xcodnnn: String): String;

  procedure   Sincronizar;

  procedure   RegistrarCodigo(xitems, xestado, xcodigo: String; xcantitems: Integer);
  procedure   BorrarCodigo(xestado: String);
  function    setCodigos(xestado: String): TQuery;
  function    verificarCodigoExcluido(xcodigo: String): Boolean;

  function    BuscarCodigoNNN(xcodigonbu, xcodigonnn: String): Boolean; overload;
  procedure   RegistrarCodigoNNN(xcodigonbu, xcodigonnn: String);
  procedure   BorrarCodigoNNN(xcodigonbu, xcodigonnn: String);
  function    setCodigosNNN(xcodigonbu: String): TStringList;
  function    getListNNN: TQuery;
  procedure   MarcarDerivacion(xcodigo1, xcodigo2, xestado: string);

  procedure   MarcarPracticaDiferencial(xcodigo: string);

  procedure   Exportar;
  procedure   Importar;

  procedure   conectar;
  procedure   desconectar;
 private
  conexiones: shortint;
  texport, texportcodigosNBU, texportnbu_nnn: TTable;
  procedure   ListLinea(salida: char);
  { Declaraciones Privadas }
end;

function NBU: TTNBU;

implementation

var
  xNBU: TTNBU = nil;

constructor TTNBU.Create;
begin
  inherited Create;
  {if (LowerCase(ExtractFileName(Application.ExeName)) <> 'shmsoftlabinter.exe') or (dbs.BaseClientServ = 'N') then Begin
    tabla      := datosdb.openDB('NBU', '');
    codigosNBU := datosdb.openDB('codigosNBU', '');
    nbu_nnn    := datosdb.openDB('nbu_nnn', '');
  end else Begin
    tabla      := datosdb.openDB('NBU', '', '', dbs.TDB1.DatabaseName);
    codigosNBU := datosdb.openDB('codigosNBU', '', '', dbs.TDB1.DatabaseName);
    nbu_nnn    := datosdb.openDB('nbu_nnn', '', '', dbs.TDB1.DatabaseName);
  end;}

  tabla      := datosdb.openDB('NBU', '', '', dbs.TDB1.DatabaseName);
  codigosNBU := datosdb.openDB('codigosNBU', '', '', dbs.TDB1.DatabaseName);
  nbu_nnn    := datosdb.openDB('nbu_nnn', '', '', dbs.TDB1.DatabaseName);
end;

destructor TTNBU.Destroy;
begin
  inherited Destroy;
end;

function  TTNBU.getListNNN: TQuery;
begin
  result := datosdb.tranSQL(nbu_nnn.DatabaseName, 'select nbu_nnn.codigo, nbu_nnn.codnnn, nbu_nnn.deriva, nbu.descrip from nbu_nnn, nbu where nbu_nnn.codigo = nbu.codigo order by descrip');
end;

procedure TTNBU.MarcarDerivacion(xcodigo1, xcodigo2, xestado: string);
begin
  if BuscarCodigoNNN(xcodigo1, xcodigo2) then begin
    nbu_nnn.Edit;
    nbu_nnn.FieldByName('deriva').AsString := xestado;
    try
      nbu_nnn.Post
     except
      nbu_nnn.Cancel
    end;
  end;
  datosdb.closeDB(nbu_nnn); nbu_nnn.Open;
end;

procedure TTNBU.Grabar(xcodigo, xdescrip, xcodnnn: string; xunidad, xunidades: Real);
// Objetivo...: Grabar Atributos del Objeto
begin
  if Buscar(xcodigo) then tabla.Edit else tabla.Append;
  tabla.FieldByName('codigo').AsString  := xcodigo;
  tabla.FieldByName('Descrip').AsString := xdescrip;
  tabla.FieldByName('codnnn').AsString  := xcodnnn;
  tabla.FieldByName('unidad').AsFloat   := xunidad;
  tabla.FieldByName('unidades').AsFloat := xunidades;
  try
    tabla.Post;
  except
    tabla.Cancel;
  end;
  datosdb.refrescar(tabla);
  RegistrarCodigoNNN(xcodigo, xcodnnn);
end;

procedure TTNBU.Borrar(xcodigo: string);
// Objetivo...: Eliminar un Objeto
begin
  if Buscar(xcodigo) then Begin
    datosdb.tranSQL(nbu_nnn.DatabaseName, 'delete from ' + nbu_nnn.TableName + ' where codigo = ' + '''' + xcodigo + '''');
    datosdb.closeDB(nbu_nnn); nbu_nnn.Open;
    tabla.Delete;
    datosdb.closeDB(tabla); tabla.Open;
    getDatos(tabla.FieldByName('codigo').AsString);  // Fijamos los Atributos Siguientes al Objeto Borrado
  end;
end;

function TTNBU.Buscar(xcodigo: string): boolean;
// Objetivo...: Buscar el Objeto solicitado
begin
  if (conexiones > 0) and not (tabla.Active) then tabla.Open;
  if tabla.IndexFieldNames <> 'codigo' then tabla.IndexFieldNames := 'codigo';
  if tabla.FindKey([xcodigo]) then Result := True else Result := False;
end;

procedure  TTNBU.getDatos(xcodigo: string);
// Objetivo...: Retornar/Iniciar Atributos
begin
  if not (tabla.Active) then tabla.Open;  
  if Buscar(xcodigo) then Begin
    codigo   := tabla.FieldByName('codigo').AsString;
    Descrip  := tabla.FieldByName('Descrip').AsString;
    Codnnn   := tabla.FieldByName('codnnn').AsString;
    unidad   := tabla.FieldByName('unidad').AsFloat;
    unidades := tabla.FieldByName('unidades').AsFloat;
    especial := tabla.FieldByName('especial').AsString;
  end else Begin
    codigo := ''; Descrip := ''; unidad := 0; codnnn := ''; unidades := 0; especial := '';
  end;
end;

function TTNBU.setDeterminaciones: TQuery;
// Objetivo...: devolver un set con los Descripes disponibles
begin
  Result := datosdb.tranSQL('SELECT * FROM ' + tabla.TableName + ' ORDER BY Codigo');
end;

function TTNBU.setDescripes: TQuery;
// Objetivo...: devolver un set con los Descripes disponibles
begin
  Result := datosdb.tranSQL('SELECT * FROM ' + tabla.TableName + ' ORDER BY Descrip');
end;

function TTNBU.Nuevo: string;
// Objetivo...: Abrir tablas de persistencia
begin
  tabla.IndexFieldNames := 'codigo';
  tabla.Last;
  if tabla.RecordCount = 0 then Result := '1' else Result := IntToStr(StrToInt(tabla.FieldByName('codigo').AsString) + 1);
end;

procedure TTNBU.Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
// Objetivo...: Listar colecci�n de objetos
begin
  if orden = 'A' then tabla.IndexName := tabla.IndexDefs.Items[1].Name;

  list.Setear(salida);
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Listado de Diagn�sticos', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'C�digo   Descripci�n', 1, 'Arial, cursiva, 8');
  List.Titulo(64, list.Lineactual, 'Unidad', 2, 'Arial, cursiva, 8');
  List.Titulo(71, list.Lineactual, 'E', 3, 'Arial, cursiva, 8');
  List.Titulo(79, list.Lineactual, 'U. Esp.', 4, 'Arial, cursiva, 8');
  List.Titulo(92, list.Lineactual, 'C�d.NNN', 5, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  tabla.First;
  while not tabla.EOF do Begin
    // Ordenado por C�digo
    if (ent_excl = 'E') and (orden = 'C') then
      if (tabla.FieldByName('codigo').AsString >= iniciar) and (tabla.FieldByName('codigo').AsString <= finalizar) then ListLinea(salida);
    if (ent_excl = 'X') and (orden = 'C') then
      if (tabla.FieldByName('codigo').AsString < iniciar) or (tabla.FieldByName('codigo').AsString > finalizar) then ListLinea(salida);
    // Ordenado Alfab�ticamente
    if (ent_excl = 'E') and (orden = 'A') then
      if (tabla.FieldByName('Descrip').AsString >= iniciar) and (tabla.FieldByName('Descrip').AsString <= finalizar) then ListLinea(salida);
    if (ent_excl = 'X') and (orden = 'A') then
      if (tabla.FieldByName('Descrip').AsString < iniciar) or (tabla.FieldByName('Descrip').AsString > finalizar) then ListLinea(salida);

    tabla.Next;
  end;
  List.FinList;

  tabla.IndexFieldNames := tabla.IndexFieldNames;
  tabla.First;
end;

procedure TTNBU.ListLinea(salida: char);
begin
  List.Linea(0, 0, tabla.FieldByName('codigo').AsString + '   ' + tabla.FieldByName('Descrip').AsString, 1, 'Arial, normal, 8', salida, 'N');
  List.importe(70, list.lineactual, '', tabla.FieldByName('unidad').AsFloat, 2, 'Arial, normal, 8');
  List.Linea(71, list.lineactual, tabla.FieldByName('especial').AsString, 4, 'Arial, normal, 8', salida, 'S');
  List.importe(84, list.lineactual, '', tabla.FieldByName('unidades').AsFloat, 5, 'Arial, normal, 8');
  List.Linea(94, list.lineactual, tabla.FieldByName('codnnn').AsString, 6, 'Arial, normal, 8', salida, 'S');
end;

procedure TTNBU.BuscarPorDescrip(xexpr: string);
begin
  tabla.IndexFieldNames := 'Descrip';
  tabla.FindNearest([xexpr]);
end;

procedure TTNBU.BuscarPorId(xexpr: string);
begin
  tabla.IndexFieldNames := 'codigo';
  tabla.FindNearest([xexpr]);
end;

procedure TTNBU.BuscarPorCodigoNNN(xexpr: string);
begin
  tabla.IndexFieldNames := 'codnnn';
  tabla.FindNearest([xexpr]);
end;

function  TTNBU.BuscarCodigoNNN(xcodnnn: String): Boolean;
// Objetivo...: Retornar C�digo NBU
Begin
  if not (tabla.Active) then tabla.Open;
  tabla.IndexFieldNames := 'codnnn';
  Result := tabla.FindKey([xcodnnn]);
  tabla.IndexFieldNames := 'codigo';
end;

function  TTNBU.setCodigoNBU(xcodnnn: String): String;
// Objetivo...: Retornar C�digo NBU
Begin
  if not (nbu_nnn.Active) then nbu_nnn.Open;
  nbu_nnn.IndexFieldNames := 'codnnn';
  if nbu_nnn.FindKey([xcodnnn]) then Result := nbu_nnn.FieldByName('codigo').AsString else Result := '';
  nbu_nnn.IndexFieldNames := 'codigo';
end;

procedure TTNBU.Sincronizar;
// Objetivo...: Sincronizar con las tablas correspondientes
begin
  tabla.First;
  while not tabla.Eof do Begin
    tabla.Edit;
    tabla.FieldByName('codnnn').AsString := nomeclatura.setCodigoTresDigitos(Copy(tabla.FieldByName('codigo').AsString, 4, 3));
    try
      tabla.Post
     except
      tabla.Cancel
    end;
    datosdb.refrescar(tabla);
    tabla.Next;
  end;
end;

procedure TTNBU.RegistrarCodigo(xitems, xestado, xcodigo: String; xcantitems: Integer);
// Objetivo...: Registrar Codigos Incluidos/Excluidos
Begin
  codigosNBU.Open;
  if datosdb.Buscar(codigosNBU, 'items', 'estado', 'codigo', xitems, xestado, xcodigo) then codigosNBU.Edit else codigosNBU.Append;
  codigosNBU.FieldByName('items').AsString  := xitems;
  codigosNBU.FieldByName('estado').AsString := xestado;
  codigosNBU.FieldByName('codigo').AsString := xcodigo;
  try
    codigosNBU.Post
   except
    codigosNBU.Cancel
  end;
  datosdb.closeDB(codigosNBU);

  if xcantitems = 0 then datosdb.tranSQL('delete from codigosnbu where estado = ' + '''' + xestado + '''') else
    if xitems = utiles.sLlenarIzquierda(IntToStr(xcantitems), 3, '0') then datosdb.tranSQL('delete from codigosnbu where estado = ' + '''' + xestado + '''' + ' and items > ' + '''' + xitems + '''');
end;

function TTNBU.setCodigos(xestado: String): TQuery;
// Objetivo.... devolver codigos
Begin
  Result := datosdb.tranSQL('select * from codigosnbu where estado = ' + '''' + xestado + '''');
end;

function TTNBU.verificarCodigoExcluido(xcodigo: String): Boolean;
// Objetivo...: devolver c�digo excluido
Begin
  Result := False;
  codigosNBU.Open;
  codigosNBU.IndexFieldNames := 'codigo';
  if codigosnbu.FindKey([xcodigo]) then
    if codigosnbu.FieldByName('estado').AsString = 'E' then Result := True;
end;

procedure TTNBU.BorrarCodigo(xestado: String);
// Objetivo.... devolver codigos
Begin
  datosdb.tranSQL('delete from codigosnbu where estado = ' + '''' + xestado + '''');
end;

function  TTNBU.BuscarCodigoNNN(xcodigonbu, xcodigonnn: String): Boolean;
// Objetivo...: Buscar una instancia
begin
  nbu_nnn.IndexFieldNames := 'codigo;codnnn';
  Result := datosdb.Buscar(nbu_nnn, 'codigo', 'codnnn', xcodigonbu, xcodigonnn);
end;

procedure TTNBU.RegistrarCodigoNNN(xcodigonbu, xcodigonnn: String);
// Objetivo...: Registrar una instancia
begin
  if BuscarCodigoNNN(xcodigonbu, xcodigonnn) then nbu_nnn.Edit else nbu_nnn.Append;
  nbu_nnn.FieldByName('codigo').AsString := xcodigonbu;
  nbu_nnn.FieldByName('codnnn').AsString := xcodigonnn;
  try
    nbu_nnn.Post
   except
    nbu_nnn.Cancel
  end;
  datosdb.closeDB(nbu_nnn); nbu_nnn.Open;
end;

procedure TTNBU.BorrarCodigoNNN(xcodigonbu, xcodigonnn: String);
// Objetivo...: Borrar una instancia
begin
  if BuscarCodigoNNN(xcodigonbu, xcodigonnn) then Begin
    nbu_nnn.Delete;
    datosdb.closeDB(nbu_nnn); nbu_nnn.Open;
  end;
end;

function  TTNBU.setCodigosNNN(xcodigonbu: String): TStringList;
// Objetivo...: Abrir tablas de persistencia
var
  l: TStringList;
begin
  l := TStringList.Create;
  datosdb.Filtrar(nbu_nnn, 'codigo = ' + '''' + xcodigonbu + '''');
  nbu_nnn.First;
  while not nbu_nnn.Eof do Begin
    if (length(trim(nbu_nnn.FieldByName('codnnn').AsString)) > 0) then    
      l.Add(nbu_nnn.FieldByName('codnnn').AsString);
    nbu_nnn.Next;
  end;
  datosdb.QuitarFiltro(nbu_nnn);
  Result := l;
end;

procedure TTNBU.Exportar;
// Objetivo...: Exportar Datos
Begin
  texport := datosdb.openDB('NBU', '', '', dbs.DirSistema + '\actualizaciones_online\upload\estructu');
  texport.Open;
  tabla.First;
  while not tabla.Eof do Begin
    if texport.FindKey([tabla.FieldByName('codigo').AsString]) then texport.Edit else texport.Append;
    texport.FieldByName('codigo').AsString  := tabla.FieldByName('codigo').AsString;
    texport.FieldByName('descrip').AsString := tabla.FieldByName('descrip').AsString;
    texport.FieldByName('unidad').AsFloat   := tabla.FieldByName('unidad').AsFloat;
    try
      texport.Post
    except
      texport.Cancel
    end;
    tabla.Next;
  End;
  datosdb.closeDB(texport);

  texportcodigosNBU := datosdb.openDB('codigosNBU', '', '', dbs.DirSistema + '\actualizaciones_online\upload\estructu');
  texportcodigosNBU.Open;
  codigosNBU.Open;
  codigosNBU.First;
  while not codigosNBU.Eof do begin
    if datosdb.Buscar(texportcodigosNBU, 'items', 'estado', 'codigo', codigosNBU.FieldByName('items').AsString, codigosNBU.FieldByName('estado').AsString, codigosNBU.FieldByName('codigo').AsString) then texportcodigosNBU.Edit else texportcodigosNBU.Append;
    texportcodigosNBU.FieldByName('items').AsString  := codigosNBU.FieldByName('items').AsString;
    texportcodigosNBU.FieldByName('estado').AsString := codigosNBU.FieldByName('estado').AsString;
    texportcodigosNBU.FieldByName('codigo').AsString := codigosNBU.FieldByName('codigo').AsString;
    try
      texportcodigosNBU.Post
     except
      texportcodigosNBU.Cancel
    end;
    codigosNBU.Next;
  end;
  datosdb.closeDB(texportcodigosNBU);
  datosdb.closeDB(codigosNBU);

  texportnbu_nnn := datosdb.openDB('nbu_nnn', '', '', dbs.DirSistema + '\actualizaciones_online\upload\estructu');
  nbu_nnn.Open;
  nbu_nnn.First;
  while not nbu_nnn.Eof do begin
    if datosdb.Buscar(texportnbu_nnn, 'codigo', 'codnnn', nbu_nnn.FieldByName('codigo').AsString, nbu_nnn.FieldByName('codnnn').AsString) then texportnbu_nnn.Edit else texportnbu_nnn.Append;
    texportnbu_nnn.FieldByName('codigo').AsString := nbu_nnn.FieldByName('codigo').AsString;
    texportnbu_nnn.FieldByName('codnnn').AsString := nbu_nnn.FieldByName('codnnn').AsString;
    try
      texportnbu_nnn.Post
     except
      texportnbu_nnn.Cancel
    end;
    nbu_nnn.Next;
  end;
  datosdb.closeDB(texportnbu_nnn);
  datosdb.closeDB(nbu_nnn);
End;

procedure TTNBU.Importar;
// Objetivo...: Exportar Datos
Begin
  texport := datosdb.openDB('NBU', '', '', dbs.DirSistema + '\actualizaciones_online\download\estructu');
  texport.Open;
  texport.First;
  tabla.IndexFieldNames := 'CODIGO';
  while not texport.Eof do Begin
    if tabla.FindKey([texport.FieldByName('codigo').AsString]) then tabla.Edit else tabla.Append;
    tabla.FieldByName('codigo').AsString  := texport.FieldByName('codigo').AsString;
    tabla.FieldByName('descrip').AsString := texport.FieldByName('descrip').AsString;
    tabla.FieldByName('unidad').AsFloat   := texport.FieldByName('unidad').AsFloat;
    try
      tabla.Post
    except
      tabla.Cancel
    end;
    texport.Next;
  End;
  datosdb.closeDB(texport);

  texportcodigosNBU := datosdb.openDB('codigosNBU', '', '', dbs.DirSistema + '\actualizaciones_online\download\estructu');
  texportcodigosNBU.Open;
  codigosNBU.Open;
  codigosNBU.IndexFieldNames := 'ITEMS;CODIGO;ESTADO';
  texportcodigosNBU.First;
  while not texportcodigosNBU.Eof do begin
    if datosdb.Buscar(codigosNBU, 'items', 'estado', 'codigo', texportcodigosNBU.FieldByName('items').AsString, texportcodigosNBU.FieldByName('estado').AsString, texportcodigosNBU.FieldByName('codigo').AsString) then codigosNBU.Edit else codigosNBU.Append;
    codigosNBU.FieldByName('items').AsString  := texportcodigosNBU.FieldByName('items').AsString;
    codigosNBU.FieldByName('estado').AsString := texportcodigosNBU.FieldByName('estado').AsString;
    codigosNBU.FieldByName('codigo').AsString := texportcodigosNBU.FieldByName('codigo').AsString;
    try
      codigosNBU.Post
     except
      codigosNBU.Cancel
    end;
    texportcodigosNBU.Next;
  end;
  datosdb.closeDB(texportcodigosNBU);
  datosdb.closeDB(codigosNBU);

  texportnbu_nnn := datosdb.openDB('nbu_nnn', '', '', dbs.DirSistema + '\actualizaciones_online\download\estructu');
  texportnbu_nnn.Open;
  nbu_nnn.Open;
  texportnbu_nnn.First;
  while not texportnbu_nnn.Eof do begin
    if datosdb.Buscar(nbu_nnn, 'codigo', 'codnnn', texportnbu_nnn.FieldByName('codigo').AsString, texportnbu_nnn.FieldByName('codnnn').AsString) then nbu_nnn.Edit else nbu_nnn.Append;
    nbu_nnn.FieldByName('codigo').AsString := texportnbu_nnn.FieldByName('codigo').AsString;
    nbu_nnn.FieldByName('codnnn').AsString := texportnbu_nnn.FieldByName('codnnn').AsString;
    try
      nbu_nnn.Post
     except
      nbu_nnn.Cancel
    end;
    texportnbu_nnn.Next;
  end;
  datosdb.closeDB(texportnbu_nnn);
  datosdb.closeDB(nbu_nnn);
End;

procedure TTNBU.MarcarPracticaDiferencial(xcodigo: string);
begin
  if Buscar(xcodigo) then begin
    tabla.Edit;
    if (tabla.FieldByName('especial').AsString = '*') then
      tabla.FieldByName('especial').AsString := ''
    else
      tabla.FieldByName('especial').AsString := '*';
    try
      tabla.Post;
    except
      tabla.Cancel;
    end;
  end;
  datosdb.refrescar(tabla);
end;

procedure TTNBU.conectar;
// Objetivo...: Abrir tablas de persistencia
begin
  nomeclatura.conectar;
  if conexiones = 0 then Begin
    if not tabla.Active then tabla.Open;
    if not nbu_nnn.Active then nbu_nnn.Open;
    tabla.FieldByName('codigo').DisplayLabel := 'C�digo'; tabla.FieldByName('Descrip').DisplayLabel := 'Descripci�n';
    tabla.FieldByName('Unidad').DisplayLabel := 'Unidad'; tabla.FieldByName('codnnn').DisplayLabel := 'C�d. NNN';
    tabla.FieldByName('especial').DisplayLabel := 'E'; tabla.FieldByName('unidades').DisplayLabel := 'U.Dif.';
  end;
  Inc(conexiones);
end;

procedure TTNBU.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  nomeclatura.desconectar;
  if conexiones > 0 then Dec(conexiones);
  if conexiones = 0 then Begin
    datosdb.closeDB(tabla);
    datosdb.closeDB(nbu_nnn);
  end;
end;

{===============================================================================}

function NBU: TTNBU;
begin
  if xNBU = nil then
    xNBU := TTNBU.Create;
  Result := xNBU;
end;

{===============================================================================}

initialization

finalization
  xNBU.Free;

end.
