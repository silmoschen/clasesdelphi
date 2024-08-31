unit CCategoriasCCB;

interface

uses SysUtils, DB, DBTables, CBDT, CIDBFM, CUtiles, CListar, Forms;

type

TTCategorias = class(TObject)
  idcategoria, Categoria: string; porcUB, porcUG: real;
  tabla: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  procedure   Grabar(xidcategoria, xCategoria: string; xporcUB, xporcUG: real);
  procedure   Borrar(xidcategoria: string);
  function    Buscar(xidcategoria: string): boolean;
  procedure   getDatos(xidcategoria: string);
  function    setcategoriaes: TQuery;
  function    Nuevo: string;
  procedure   Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
  procedure   BuscarPorcategoria(xexpr: string);
  procedure   BuscarPorId(xexpr: string);

  procedure   conectar;
  procedure   desconectar;
 private
  conexiones: shortint;
  dbconexion: String;
  rsql: TQuery;
  procedure   ListLinea(salida: char);
  { Declaraciones Privadas }
end;

function categoria: TTCategorias;

implementation

var
  xcomprob: TTCategorias = nil;

constructor TTCategorias.Create;
begin
  inherited Create;
  if (LowerCase(ExtractFileName(Application.ExeName)) = 'shmsoftfccb.exe') or                  // Motor de Persitencia para las versiones de Laboratorios Cliente-Servidor
     (LowerCase(ExtractFileName(Application.ExeName)) = 'shmsoftfccbc.exe') or
     (LowerCase(ExtractFileName(Application.ExeName)) = 'shmsoftfccbcretivac.exe') or
     (LowerCase(ExtractFileName(Application.ExeName)) = 'shmsoftfccbcretiva.exe') then Begin   // Motor de Persitencia para las versiones de Laboratorios
    if dbs.BaseClientServ = 'N' then DBConexion := dbs.DirSistema + '\archdat' else DBConexion := dbs.TDB1.DatabaseName;
  end else Begin
    if dbs.BaseClientServ = 'N' then DBConexion := dbs.DirSistema + '\archdat' else DBConexion := dbs.baseDat;
  end;

  tabla := datosdb.openDB('categorias', 'idcategoria', '', dbconexion);
  //tabla := datosdb.openDB('categorias', 'idcategoria');
end;

destructor TTCategorias.Destroy;
begin
  inherited Destroy;
end;

procedure TTCategorias.Grabar(xidcategoria, xCategoria: string; xporcUB, xporcUG: real);
// Objetivo...: Grabar Atributos del Objeto
begin
  if Buscar(xidcategoria) then tabla.Edit else tabla.Append;
  tabla.FieldByName('idcategoria').AsString := xidcategoria;
  tabla.FieldByName('categoria').AsString   := xCategoria;
  tabla.FieldByName('porcUB').AsFloat       := xporcUB;
  tabla.FieldByName('porcUG').AsFloat       := xporcUG;
  try
    tabla.Post;
  except
    tabla.Cancel;
  end;
end;

procedure TTCategorias.Borrar(xidcategoria: string);
// Objetivo...: Eliminar un Objeto
begin
  if Buscar(xidcategoria) then
    begin
      rsql := datosdb.tranSQL(tabla.DatabaseName, 'select count(*) as cant from profesih where idcategoria = ' + '''' + xidcategoria + '''');
      rsql.Open;
      if (rsql.FieldByName('cant').AsInteger = 0) then begin
        tabla.Delete;
        getDatos(tabla.FieldByName('idcategoria').AsString);  // Fijamos los Atributos Siguientes al Objeto Borrado
      end else
        utiles.msgError('La Categoría tiene Profesionales Asociados.Baja Denegada ...!');
      rsql.Close; rsql.Free;    
    end;
end;

function TTCategorias.Buscar(xidcategoria: string): boolean;
// Objetivo...: Buscar el Objeto solicitado
begin
  if not tabla.Active then tabla.Open;
  tabla.Refresh;
  if tabla.IndexFieldNames <> 'Idcategoria' then tabla.IndexFieldNames := 'Idcategoria';
  if tabla.FindKey([xidcategoria]) then Result := True else Result := False;
end;

procedure  TTCategorias.getDatos(xidcategoria: string);
// Objetivo...: Retornar/Iniciar Atributos
begin
  if Buscar(xidcategoria) then Begin
    idcategoria := tabla.FieldByName('idcategoria').AsString;
    Categoria   := tabla.FieldByName('categoria').AsString;
    porcUB      := tabla.FieldByName('porcUB').AsFloat;
    porcUG      := tabla.FieldByName('porcUG').AsFloat;
  end else Begin
    idcategoria := ''; categoria := ''; porcUB := 0; porcUG := 0;
  end;
end;

function TTCategorias.setcategoriaes: TQuery;
// Objetivo...: devolver un set con los categoriaes disponibles
begin
  Result := datosdb.tranSQL('SELECT * FROM ' + tabla.TableName + ' ORDER BY categoria');
end;

function TTCategorias.Nuevo: string;
// Objetivo...: Abrir tablas de persistencia
begin
  tabla.Last;
  if tabla.RecordCount = 0 then Result := '1' else Result := IntToStr(StrToInt(tabla.FieldByName('idcategoria').AsString) + 1);
end;

procedure TTCategorias.Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
// Objetivo...: Listar colección de objetos
begin
  if orden = 'A' then tabla.IndexName := tabla.IndexDefs.Items[1].Name;

  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Listado de categoriaes', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Id.  Categoría', 1, 'Courier New, cursiva, 9');
  List.Titulo(64, 0, '% s/UB', 2, 'Courier New, cursiva, 9');
  List.Titulo(84, 0, '% s/UG', 3, 'Courier New, cursiva, 9');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  tabla.First;
  while not tabla.EOF do
    begin
      // Ordenado por Código
      if (ent_excl = 'E') and (orden = 'C') then
        if (tabla.FieldByName('idcategoria').AsString >= iniciar) and (tabla.FieldByName('idcategoria').AsString <= finalizar) then ListLinea(salida);
      if (ent_excl = 'X') and (orden = 'C') then
        if (tabla.FieldByName('idcategoria').AsString < iniciar) or (tabla.FieldByName('idcategoria').AsString > finalizar) then ListLinea(salida);
      // Ordenado Alfabéticamente
      if (ent_excl = 'E') and (orden = 'A') then
        if (tabla.FieldByName('categoria').AsString >= iniciar) and (tabla.FieldByName('categoria').AsString <= finalizar) then ListLinea(salida);
      if (ent_excl = 'X') and (orden = 'A') then
        if (tabla.FieldByName('categoria').AsString < iniciar) or (tabla.FieldByName('categoria').AsString > finalizar) then ListLinea(salida);

      tabla.Next;
    end;
    List.FinList;

    tabla.IndexFieldNames := tabla.IndexFieldNames;
    tabla.First;
end;

procedure TTCategorias.ListLinea(salida: char);
begin
  List.Linea(0, 0, tabla.FieldByName('idcategoria').AsString + '   ' + tabla.FieldByName('categoria').AsString, 1, 'Courier New, normal, 9', salida, 'N');
  List.importe(70, List.lineactual, '', tabla.FieldByName('porcUB').AsFloat, 2, 'Courier New, normal, 9');
  List.importe(90, List.lineactual, '', tabla.FieldByName('porcUG').AsFloat, 3, 'Courier New, normal, 9');
  List.Linea(95, list.lineactual, ' ', 4, 'Courier New, normal, 9', salida, 'S');
end;

procedure TTCategorias.BuscarPorcategoria(xexpr: string);
begin
  tabla.IndexFieldNames := 'Categoria';
  tabla.FindNearest([xexpr]);
end;

procedure TTCategorias.BuscarPorId(xexpr: string);
begin
  tabla.IndexFieldNames := 'idcategoria';
  tabla.FindNearest([xexpr]);
end;

procedure TTCategorias.conectar;
// Objetivo...: Abrir tablas de persistencia
begin
  if conexiones = 0 then Begin
    if not tabla.Active then tabla.Open;
    tabla.FieldByName('idcategoria').DisplayLabel := 'Id.'; tabla.FieldByName('categoria').DisplayLabel := 'Categoría'; tabla.FieldByName('porcub').DisplayLabel := '% UB'; tabla.FieldByName('porcug').DisplayLabel := '% UG';
  end;
  Inc(conexiones);
end;

procedure TTCategorias.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones > 0 then Dec(conexiones);
  if conexiones = 0 then datosdb.closeDB(tabla);
end;

{===============================================================================}

function categoria: TTCategorias;
begin
  if xcomprob = nil then
    xcomprob := TTCategorias.Create;
  Result := xcomprob;
end;

{===============================================================================}

initialization

finalization
  xcomprob.Free;

end.
