unit CAgregadosDamevin;

interface

uses SysUtils, DB, DBTables, CBDT, CIDBFM, CUtiles, CListar;

type

TTAgregados = class(TObject)
  idagregado, tabulacion, idvariante, Descrip, Desvariant: string; precio: real;
  tabla, variante: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  procedure   Grabar(xidagregado, xtabulacion, xDescrip: string; xprecio: real); overload;
  procedure   Grabar(xidagregado, xidvariante, xDescrip: string); overload;
  procedure   Borrar(xidagregado: string); overload;
  procedure   Borrar(xidagregado, xidvariante: string); overload;
  function    Buscar(xidagregado: string): boolean; overload;
  function    Buscar(xidagregado, xidvariante: string): boolean; overload;
  procedure   getDatos(xidagregado: string); overload;
  procedure   getDatos(xidagregado, xidvariante: string); overload;
  function    setAgregados: TQuery;
  function    setVariantes: TQuery;
  procedure   FiltrarVariantes;
  procedure   BuscarPorDescrip(xexpr: string);
  procedure   BuscarPorId(xexpr: string);

  function    Nuevo: string;
  procedure   Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);

  procedure   conectar;
  procedure   desconectar;
 private
  conexiones: shortint; r: TQuery;
  procedure   ListarLinea(salida: char);
  { Declaraciones Privadas }
end;

function agregado: TTAgregados;

implementation

var
  xcomprob: TTAgregados = nil;

constructor TTAgregados.Create;
begin
  inherited Create;
  tabla    := datosdb.openDB('agregados', 'idagregado');
  variante := datosdb.openDB('varagreg', 'idagregado;idvariante');
end;

destructor TTAgregados.Destroy;
begin
  inherited Destroy;
end;

procedure TTAgregados.Grabar(xidagregado, xtabulacion, xdescrip: string; xprecio: real);
// Objetivo...: Grabar Atributos del Objeto
begin
  if Buscar(xidagregado) then tabla.Edit else tabla.Append;
  tabla.FieldByName('idagregado').AsString := xidagregado;
  tabla.FieldByName('tabulacion').AsString := xtabulacion;
  tabla.FieldByName('descrip').AsString    := xdescrip;
  tabla.FieldByName('precio').AsFloat      := xprecio;
  try
    tabla.Post
  except
    tabla.Cancel
  end;
end;

procedure TTAgregados.Grabar(xidagregado, xidvariante, xdescrip: string);
// Objetivo...: Grabar Atributos del Objeto
begin
  if Buscar(xidagregado, xidvariante) then variante.Edit else variante.Append;
  variante.FieldByName('idagregado').AsString := xidagregado;
  variante.FieldByName('idvariante').AsString := xidvariante;
  variante.FieldByName('descrip').AsString    := xdescrip;
  try
    variante.Post;
  except
    variante.Cancel;
  end;
end;

procedure TTAgregados.Borrar(xidagregado: string);
// Objetivo...: Eliminar un Objeto
begin
  if Buscar(xidagregado) then
    begin
      tabla.Delete;
      getDatos(tabla.FieldByName('idagregado').AsString);  // Fijamos los Atributos Siguientes al Objeto Borrado
    end;
end;

procedure TTAgregados.Borrar(xidagregado, xidvariante: string);
// Objetivo...: Eliminar un Objeto
begin
  if Buscar(xidagregado, xidvariante) then
    begin
      variante.Delete;
      getDatos(variante.FieldByName('idagregado').AsString, variante.FieldByName('idvariante').AsString);  // Fijamos los Atributos Siguientes al Objeto Borrado
    end;
end;

function TTAgregados.Buscar(xidagregado: string): boolean;
// Objetivo...: Buscar el Objeto solicitado
begin
  if tabla.IndexFieldNames <> 'Idagregado' then tabla.IndexFieldNames := 'Idagregado';
  if tabla.FindKey([xidagregado]) then Result := True else Result := False;
end;

function TTAgregados.Buscar(xidagregado, xidvariante: string): boolean;
// Objetivo...: Buscar el Objeto solicitado
begin
  Result := datosdb.Buscar(variante, 'idagregado', 'idvariante', xidagregado, xidvariante);
end;

procedure  TTAgregados.getDatos(xidagregado: string);
// Objetivo...: Retornar/Iniciar Atributos
begin
  tabla.Refresh;
  if Buscar(xidagregado) then
    begin
      idagregado := tabla.FieldByName('idagregado').AsString;
      descrip    := tabla.FieldByName('descrip').AsString;
      tabulacion := tabla.FieldByName('tabulacion').AsString;
      precio     := tabla.FieldByName('precio').AsFloat;
    end
   else
    begin
      idagregado := xidagregado; tabulacion := ''; descrip := ''; precio := 0;
    end;
end;

procedure  TTAgregados.getDatos(xidagregado, xidvariante: string);
// Objetivo...: Retornar/Iniciar Atributos
begin
  variante.Refresh;
  if Buscar(xidagregado, xidvariante) then
    begin
      idagregado := variante.FieldByName('idagregado').AsString;
      idvariante := variante.FieldByName('idvariante').AsString;
      desvariant := variante.FieldByName('descrip').AsString;
    end
   else
    begin
      idagregado := ''; idvariante := ''; desvariant := '';
    end;
end;

function TTAgregados.setAgregados: TQuery;
// Objetivo...: devolver un set con los sabores disponibles
begin
  Result := datosdb.tranSQL('SELECT * FROM ' + tabla.TableName + ' ORDER BY tabulacion');
end;

function TTAgregados.setVariantes: TQuery;
// Objetivo...: devolver un set con los sabores disponibles
begin
  Result := datosdb.tranSQL('SELECT * FROM ' + variante.TableName + ' ORDER BY idagregado');
end;

function TTAgregados.Nuevo: string;
// Objetivo...: Abrir tablas de persistencia
begin
  tabla.Last;
  if tabla.RecordCount = 0 then Result := '1' else Result := IntToStr(StrToInt(tabla.FieldByName('idagregado').AsString) + 1);
end;

procedure TTAgregados.FiltrarVariantes;
// Objetivo...: Filtrar Variantes
begin
  datosdb.Filtrar(variante, 'Idagregado = ' + '''' + idagregado + '''');
end;

procedure TTAgregados.Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
// Objetivo...: Listar colección de objetos
begin
  r := setVariantes; r.Open;
  if orden = 'A' then tabla.IndexName := tabla.IndexDefs.Items[1].Name;

  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Listado Tabla de Agregados ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Id.  Producto', 1, 'Courier New, cursiva, 9');
  List.Titulo(79, list.Lineactual, 'Precio', 2, 'Courier New, cursiva, 9');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  tabla.First;
  while not tabla.EOF do
    begin
      // Ordenado por Código
      if (ent_excl = 'E') and (orden = 'C') then
        if (tabla.FieldByName('idagregado').AsString >= iniciar) and (tabla.FieldByName('idagregado').AsString <= finalizar) then ListarLinea(salida);
      if (ent_excl = 'X') and (orden = 'C') then
        if (tabla.FieldByName('idagregado').AsString < iniciar) or (tabla.FieldByName('idagregado').AsString > finalizar) then ListarLinea(salida);
      // Ordenado Alfabéticamente
      if (ent_excl = 'E') and (orden = 'A') then
        if (tabla.FieldByName('descrip').AsString >= iniciar) and (tabla.FieldByName('descrip').AsString <= finalizar) then ListarLinea(salida);
      if (ent_excl = 'X') and (orden = 'A') then
        if (tabla.FieldByName('descrip').AsString < iniciar) or (tabla.FieldByName('descrip').AsString > finalizar) then ListarLinea(salida);

      tabla.Next;
    end;
    List.FinList;

    tabla.IndexFieldNames := tabla.IndexFieldNames;
    tabla.First; r.Close;
end;

procedure TTAgregados.ListarLinea(salida: char);
var
  t: boolean;
begin
  r.First; t := False;
  List.Linea(0, 0, tabla.FieldByName('idagregado').AsString + '   ' + tabla.FieldByName('descrip').AsString, 1, 'Courier New, negrita, 10', salida, 'N');
  List.importe(85, list.Lineactual, '', tabla.FieldByName('precio').AsFloat, 2, 'Courier New, negrita, 10');
  List.Linea(90, list.Lineactual, ' ', 3, 'Courier New, negrita, 10', salida, 'S');
  while not r.EOF do Begin
    if r.FieldByName('idagregado').AsString = tabla.FieldByName('idagregado').AsString then Begin
      List.Linea(0, 0, '           ' + r.FieldByName('idvariante').AsString + '   ' + r.FieldByName('descrip').AsString, 1, 'Courier New, normal, 8', salida, 'S');
      t := True;
    end;
    r.Next;
  end;
  if t then List.Linea(0, 0, '  ', 1, 'Courier New, normal, 8', salida, 'S');
end;

procedure TTAgregados.BuscarPorDescrip(xexpr: string);
begin
  tabla.IndexName := 'Descrip';
  tabla.FindNearest([xexpr]);
end;

procedure TTAgregados.BuscarPorId(xexpr: string);
begin
  tabla.IndexFieldNames := 'Idagregado';
  tabla.FindNearest([xexpr]);
end;

procedure TTAgregados.conectar;
// Objetivo...: Abrir tablas de persistencia
begin
  if conexiones = 0 then Begin
    if not tabla.Active then tabla.Open;
    tabla.FieldByName('tabulacion').Visible := False; tabla.FieldByName('idagregado').DisplayLabel := 'Id. agregado'; tabla.FieldByName('descrip').DisplayLabel := 'Descripción'; tabla.FieldByName('precio').DisplayLabel := 'Precio';
    if not variante.Active then variante.Open;
    variante.FieldByName('idagregado').Visible := False; variante.FieldByName('idvariante').DisplayLabel := 'Id';
    variante.FieldByName('idvariante').DisplayLabel := 'Id.'; variante.FieldByName('descrip').DisplayLabel := 'Descripción';
  end;
  Inc(conexiones);
end;

procedure TTAgregados.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones > 0 then Dec(conexiones);
  if conexiones = 0 then Begin
    datosdb.closeDB(tabla);
    datosdb.closeDB(variante);
  end;
end;

{===============================================================================}

function agregado: TTAgregados;
begin
  if xcomprob = nil then
    xcomprob := TTAgregados.Create;
  Result := xcomprob;
end;

{===============================================================================}

initialization

finalization
  xcomprob.Free;

end.
