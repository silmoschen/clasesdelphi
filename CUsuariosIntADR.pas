unit CUsuariosIntADR;

interface

uses SysUtils, CListar, DB, DBTables, CUtiles, CIDBFM, CCatUsuariosInt;

type

TTUsuariosInt = class(TObject)            // Superclase
  idusuario, nombre, email, idcategoria: string;
  tabla: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  procedure   Grabar(xidusuario, xnombre, xemail, xidcategoria: string);
  procedure   Borrar(xidusuario: string);
  function    Buscar(xidusuario: string): boolean;
  function    Nuevo: string;
  procedure   getDatos(xidusuario: string);
  procedure   Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
  procedure   BuscarPorCodigo(xcodigo: string);
  procedure   BuscarPorNombre(xnombre: string);
  function    setusints: TQuery;

  procedure   conectar;
  procedure   desconectar;
 private
  conexiones: shortint;
  procedure   ListarLinea(salida: char);
  { Declaraciones Privadas }
end;

function usuarioint: TTUsuariosInt;

implementation

var
  xusint: TTUsuariosInt = nil;

constructor TTUsuariosInt.Create;
begin
  inherited Create;
  tabla    := datosdb.openDB('usuariosint', '');
end;

destructor TTUsuariosInt.Destroy;
begin
  inherited Destroy;
end;

procedure TTUsuariosInt.Grabar(xidusuario, xnombre, xemail, xidcategoria: string);
// Objetivo...: Grabar Atributos del Objeto
begin
  if Buscar(xidusuario) then tabla.Edit else tabla.Append;
  tabla.FieldByName('idusuario').Value    := xidusuario;
  tabla.FieldByName('nombre').Value       := xnombre;
  tabla.FieldByName('email').Value        := xemail;
  tabla.FieldByName('idcategoria').Value  := xidcategoria;
  try
    tabla.Post;
  except
    tabla.Cancel;
  end;
  datosdb.refrescar(tabla);
end;

procedure TTUsuariosInt.Borrar(xidusuario: string);
// Objetivo...: Eliminar un Objeto
begin
  if Buscar(xidusuario) then
    begin
      tabla.Delete;
      getDatos(tabla.FieldByName('idusuario').Value);  // Fijamos los Atributos Siguientes al Objeto Borrado
    end;
end;

function TTUsuariosInt.Buscar(xidusuario: string): boolean;
// Objetivo...: Buscar el Objeto solicitado
begin
  if not tabla.Active then tabla.Open;
  if tabla.IndexFieldNames <> 'idusuario' then tabla.IndexFieldNames := 'idusuario';
  if tabla.FindKey([xidusuario]) then Result := True else Result := False;
end;

procedure  TTUsuariosInt.getDatos(xidusuario: string);
// Objetivo...: Retornar/Iniciar Atributos
begin
  if Buscar(xidusuario) then
    begin
      idusuario   := tabla.FieldByName('idusuario').Value;
      nombre      := tabla.FieldByName('nombre').Value;
      email       := tabla.FieldByName('email').Value;
      idcategoria := tabla.FieldByName('idcategoria').Value;
    end
   else
    begin
      idusuario := ''; nombre := ''; email := ''; idcategoria := '';
    end;
end;

function TTUsuariosInt.Nuevo: string;
// Objetivo...: Generar un Nuevo Atributo Código
var
  indice: String;
begin
  indice := tabla.IndexFieldNames;
  tabla.IndexFieldNames := 'idusuario';
  tabla.Refresh; tabla.Last;
  if Length(Trim(tabla.FieldByName('idusuario').AsString)) > 0 then Result := IntToStr(tabla.FieldByName('idusuario').AsInteger + 1) else Result := '1';
  tabla.IndexFieldNames := indice;
end;

function TTUsuariosInt.setusints: TQuery;
// Objetivo...: devolver un set con los usints existentes
begin
  Result := datosdb.tranSQL('SELECT * FROM ' + tabla.TableName + ' ORDER BY nombre');
end;

procedure TTUsuariosInt.Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
// Objetivo...: Listar Datos de Provincias
begin
  if orden = 'A' then tabla.IndexFieldNames := 'nombre';

  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Listado de Usuarios Internos', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Id.' + utiles.espacios(4) +  'Nombre de Usuario', 1, 'Arial, cursiva, 8');
  List.Titulo(55, list.Lineactual, 'Email', 2, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  tabla.First;
  while not tabla.EOF do
    begin
      // Ordenado por Código
      if (ent_excl = 'E') and (orden = 'C') then
        if (tabla.FieldByName('idusuario').AsString >= iniciar) and (tabla.FieldByName('idusuario').AsString <= finalizar) then ListarLinea(salida);
      if (ent_excl = 'X') and (orden = 'C') then
        if (tabla.FieldByName('idusuario').AsString < iniciar) or (tabla.FieldByName('idusuario').AsString > finalizar) then ListarLinea(salida);
      // Ordenado Alfabéticamente
      if (ent_excl = 'E') and (orden = 'A') then
        if (tabla.FieldByName('nombre').AsString >= iniciar) and (tabla.FieldByName('nombre').AsString <= finalizar) then ListarLinea(salida);
      if (ent_excl = 'X') and (orden = 'A') then
        if (tabla.FieldByName('nombre').AsString < iniciar) or (tabla.FieldByName('nombre').AsString > finalizar) then ListarLinea(salida);

      tabla.Next;
    end;
    List.FinList;

    tabla.IndexFieldNames := tabla.IndexFieldNames;
    tabla.First;
end;

procedure TTUsuariosInt.ListarLinea(salida: char);
begin
  List.Linea(0, 0, tabla.FieldByName('idusuario').AsString + '     ' + tabla.FieldByName('nombre').AsString, 1, 'Arial, normal, 8', salida, 'N');
  List.Linea(55, list.Lineactual, tabla.FieldByName('email').AsString, 2, 'Arial, normal, 8', salida, 'S');
end;

procedure TTUsuariosInt.BuscarPorCodigo(xcodigo: string);
begin
  if tabla.IndexFieldNames <> 'idusuario' then tabla.IndexFieldNames := 'idusuario';
  tabla.FindNearest([xcodigo]);
end;

procedure TTUsuariosInt.BuscarPorNombre(xnombre: string);
begin
  if tabla.IndexName <> 'nombre' then tabla.IndexFieldNames := 'nombre';
  tabla.FindNearest([xnombre]);
end;

procedure TTUsuariosInt.conectar;
// Objetivo...: conectar tablas de persistencia
begin
  catusuariosint.conectar;
  if conexiones = 0 then Begin
    if not tabla.Active then tabla.Open;
    tabla.FieldByName('idusuario').DisplayLabel := 'Cód.'; tabla.FieldByName('nombre').DisplayLabel := 'Nombre de Usuario';
    tabla.FieldByName('email').DisplayLabel := 'Correo Electrónico'; tabla.FieldByName('idcategoria').DisplayLabel := 'Id.Cat.';
  end;
  Inc(conexiones);
end;

procedure TTUsuariosInt.desconectar;
// Objetivo...: desconectar tablas de persistencia
begin
  catusuariosint.desconectar;
  if conexiones < 0 then Dec(conexiones);
  if conexiones = 0 then datosdb.closeDB(tabla);
end;

{===============================================================================}

function usuarioint: TTUsuariosInt;
begin
  if xusint = nil then
    xusint := TTUsuariosInt.Create;
  Result := xusint;
end;

{===============================================================================}

initialization

finalization
  xusint.Free;

end.
