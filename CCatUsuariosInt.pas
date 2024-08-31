unit CCatUsuariosInt;

interface

uses SysUtils, CListar, DB, DBTables, CUtiles, CIDBFM;

type

TTCatUS = class(TObject)            // Superclase
  idcategoria, categoria: string;
  tabla: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  procedure   Grabar(xidcategoria, xcategoria: string);
  procedure   Borrar(xidcategoria: string);
  function    Buscar(xidcategoria: string): boolean;
  function    Nuevo: string;
  procedure   getDatos(xidcategoria: string);
  procedure   Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
  procedure   BuscarPorCodigo(xcodigo: string);
  procedure   BuscarPorNombre(xcategoria: string);
  function    setBancos: TQuery;

  procedure   conectar;
  procedure   desconectar;
 private
  conexiones: shortint;
  { Declaraciones Privadas }
end;

function catusuariosint: TTCatUS;

implementation

var
  xbanco: TTCatUS = nil;

constructor TTCatUS.Create;
begin
  inherited Create;
  tabla    := datosdb.openDB('catusuarios', '');
end;

destructor TTCatUS.Destroy;
begin
  inherited Destroy;
end;

procedure TTCatUS.Grabar(xidcategoria, xcategoria: string);
// Objetivo...: Grabar Atributos del Objeto
begin
  if Buscar(xidcategoria) then tabla.Edit else tabla.Append;
  tabla.FieldByName('idcategoria').Value := xidcategoria;
  tabla.FieldByName('categoria').Value  := xcategoria;
  try
    tabla.Post;
  except
    tabla.Cancel;
  end;
end;

procedure TTCatUS.Borrar(xidcategoria: string);
// Objetivo...: Eliminar un Objeto
begin
  if Buscar(xidcategoria) then
    begin
      tabla.Delete;
      getDatos(tabla.FieldByName('idcategoria').Value);  // Fijamos los Atributos Siguientes al Objeto Borrado
    end;
end;

function TTCatUS.Buscar(xidcategoria: string): boolean;
// Objetivo...: Buscar el Objeto solicitado
begin
  if not tabla.Active then tabla.Open;
  if tabla.IndexFieldNames <> 'idcategoria' then tabla.IndexFieldNames := 'idcategoria';
  if tabla.FindKey([xidcategoria]) then Result := True else Result := False;
end;

procedure  TTCatUS.getDatos(xidcategoria: string);
// Objetivo...: Retornar/Iniciar Atributos
begin
  if Buscar(xidcategoria) then
    begin
      idcategoria := tabla.FieldByName('idcategoria').Value;
      categoria  := tabla.FieldByName('categoria').Value;
    end
   else
    begin
      idcategoria := ''; categoria := '';
    end;
end;

function TTCatUS.Nuevo: string;
// Objetivo...: Generar un Nuevo Atributo Código
var
  indice: String;
begin
  indice := tabla.IndexFieldNames;
  tabla.IndexFieldNames := 'idcategoria';
  tabla.Refresh; tabla.Last;
  if Length(Trim(tabla.FieldByName('idcategoria').AsString)) > 0 then Result := IntToStr(tabla.FieldByName('idcategoria').AsInteger + 1) else Result := '1';
  tabla.IndexFieldNames := indice;
end;

function TTCatUS.setBancos: TQuery;
// Objetivo...: devolver un set con los bancos existentes
begin
  Result := datosdb.tranSQL('SELECT idcategoria, categoria FROM entbcos ORDER BY categoria');
end;

procedure TTCatUS.Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
// Objetivo...: Listar Datos de Provincias
begin
  if orden = 'A' then tabla.IndexFieldNames := 'categoria';

  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Listado de Bancos', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Cód.' + utiles.espacios(3) +  'Banco', 1, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  tabla.First;
  while not tabla.EOF do
    begin
      // Ordenado por Código
      if (ent_excl = 'E') and (orden = 'C') then
        if (tabla.FieldByName('idcategoria').AsString >= iniciar) and (tabla.FieldByName('idcategoria').AsString <= finalizar) then List.Linea(0, 0, tabla.FieldByName('idcategoria').AsString + '     ' + tabla.FieldByName('categoria').AsString, 1, 'Arial, normal, 8', salida, 'S');
      if (ent_excl = 'X') and (orden = 'C') then
        if (tabla.FieldByName('idcategoria').AsString < iniciar) or (tabla.FieldByName('idcategoria').AsString > finalizar) then List.Linea(0, 0, tabla.FieldByName('idcategoria').AsString + '     ' + tabla.FieldByName('categoria').AsString, 1, 'Arial, normal, 8', salida, 'S');
      // Ordenado Alfabéticamente
      if (ent_excl = 'E') and (orden = 'A') then
        if (tabla.FieldByName('categoria').AsString >= iniciar) and (tabla.FieldByName('categoria').AsString <= finalizar) then List.Linea(0, 0, tabla.FieldByName('idcategoria').AsString + '     ' + tabla.FieldByName('categoria').AsString, 1, 'Arial, normal, 8', salida, 'S');
      if (ent_excl = 'X') and (orden = 'A') then
        if (tabla.FieldByName('categoria').AsString < iniciar) or (tabla.FieldByName('categoria').AsString > finalizar) then List.Linea(0, 0, tabla.FieldByName('idcategoria').AsString + '     ' + tabla.FieldByName('categoria').AsString, 1, 'Arial, normal, 8', salida, 'S');

      tabla.Next;
    end;
    List.FinList;

    tabla.IndexFieldNames := tabla.IndexFieldNames;
    tabla.First;
end;

procedure TTCatUS.BuscarPorCodigo(xcodigo: string);
begin
  if tabla.IndexFieldNames <> 'idcategoria' then tabla.IndexFieldNames := 'idcategoria';
  tabla.FindNearest([xcodigo]);
end;

procedure TTCatUS.BuscarPorNombre(xcategoria: string);
begin
  if tabla.IndexName <> 'categoria' then tabla.IndexFieldNames := 'categoria';
  tabla.FindNearest([xcategoria]);
end;

procedure TTCatUS.conectar;
// Objetivo...: conectar tablas de persistencia
begin
  if conexiones = 0 then Begin
    if not tabla.Active then tabla.Open;
    tabla.FieldByName('idcategoria').DisplayLabel := 'Cód.'; tabla.FieldByName('categoria').DisplayLabel := 'Categoría de Usuario';
  end;
  Inc(conexiones);
end;

procedure TTCatUS.desconectar;
// Objetivo...: desconectar tablas de persistencia
begin
  if conexiones < 0 then Dec(conexiones);
  if conexiones = 0 then datosdb.closeDB(tabla);
end;

{===============================================================================}

function catusuariosint: TTCatUS;
begin
  if xbanco = nil then
    xbanco := TTCatUS.Create;
  Result := xbanco;
end;

{===============================================================================}

initialization

finalization
  xbanco.Free;

end.
