unit CManzanas_CCSRural;

interface

uses SysUtils, CListar, DBTables, CBDT, CUtiles, CIDBFM;

type

TTManzanas = class
  Id, Descrip: string;
  tabla: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;
  procedure   Grabar(xid, xDescrip: string);
  procedure   Borrar(xid: string);
  function    Buscar(xid: string): boolean;
  function    Nuevo: string;
  procedure   getDatos(xid: string);
  procedure   BuscarPorDescrip(xexpr: string);
  procedure   BuscarPorCodigo(xexpr: string);

  procedure   conectar;
  procedure   desconectar;
  procedure   Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
 private
  { Declaraciones Privadas }
  conexiones: shortint;
end;

function manzana: TTManzanas;

implementation

var
  xmanzana: TTManzanas = nil;

constructor TTManzanas.Create;
begin
  tabla := datosdb.openDB('manzanas', '');
  inherited Create;
end;

destructor TTManzanas.Destroy;
begin
  inherited Destroy;
end;

procedure TTManzanas.Grabar(xid, xDescrip: string);
// Objetivo...: Grabar Atributos del Objeto
begin
  if Buscar(xid) then tabla.Edit else tabla.Append;
  tabla.FieldByName('id').AsString      := xid;
  tabla.FieldByName('Descrip').AsString := xDescrip;
  try
    tabla.Post;
  except
    tabla.Cancel;
  end;
end;

procedure TTManzanas.Borrar(xid: string);
// Objetivo...: Eliminar un Objeto
begin
  if Buscar(xid) then Begin
    tabla.Delete;
    getDatos(tabla.FieldByName('id').AsString);  // Fijamos los Atributos Siguientes al Objeto Borrado
  end;
end;

function TTManzanas.Buscar(xid: string): boolean;
// Objetivo...: Buscar el Objeto solicitado
begin
  if not tabla.Active then conectar;
  tabla.IndexFieldNames := 'id';
  if tabla.FindKey([xid]) then Result := True else Result := False;
end;

procedure  TTManzanas.getDatos(xid: string);
// Objetivo...: Retornar/Iniciar Atributos
begin
  if Buscar(xid) then Begin
    id      := tabla.FieldByName('id').AsString;
    Descrip := tabla.FieldByName('Descrip').AsString;
  end else Begin
    id := ''; Descrip := '';
  end;
end;

function TTManzanas.Nuevo: string;
// Objetivo...: Generar un Nuevo Atributo Código
begin
  tabla.Refresh;
  tabla.IndexFieldNames := 'Id';
  tabla.Last;
  if tabla.RecordCount > 0 then Result := IntToStr(tabla.FieldByName('id').AsInteger + 1) else Result := '1';
end;

procedure TTManzanas.Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
// Objetivo...: Listar Datos de Descrips
begin
  if orden = 'A' then tabla.IndexFieldNames := 'Descrip';

  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Listado de Manzanas', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Cód.' + utiles.espacios(3) +  'Descripción', 1, 'Courier New, cursiva, 9');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  tabla.First;
  while not tabla.EOF do
    begin
      // Ordenado por Código
      if (ent_excl = 'E') and (orden = 'C') then
        if (tabla.FieldByName('idmanzana').AsString >= iniciar) and (tabla.FieldByName('idmanzana').AsString <= finalizar) then List.Linea(0, 0, tabla.FieldByName('idmanzana').AsString + '     ' + tabla.FieldByName('Descrip').AsString, 1, 'Courier New, normal, 9', salida, 'S');
      if (ent_excl = 'X') and (orden = 'C') then
        if (tabla.FieldByName('idmanzana').AsString < iniciar) or (tabla.FieldByName('idmanzana').AsString > finalizar) then List.Linea(0, 0, tabla.FieldByName('idmanzana').AsString + '     ' + tabla.FieldByName('Descrip').AsString, 1, 'Courier New, normal, 9', salida, 'S');
      // Ordenado Alfabéticamente
      if (ent_excl = 'E') and (orden = 'A') then
        if (tabla.FieldByName('Descrip').AsString >= iniciar) and (tabla.FieldByName('Descrip').AsString <= finalizar) then List.Linea(0, 0, tabla.FieldByName('idmanzana').AsString + '     ' + tabla.FieldByName('Descrip').AsString, 1, 'Courier New, normal, 9', salida, 'S');
      if (ent_excl = 'X') and (orden = 'A') then
        if (tabla.FieldByName('Descrip').AsString < iniciar) or (tabla.FieldByName('Descrip').AsString > finalizar) then List.Linea(0, 0, tabla.FieldByName('idmanzana').AsString + '     ' + tabla.FieldByName('Descrip').AsString, 1, 'Courier New, normal, 9', salida, 'S');

      tabla.Next;
    end;
    List.FinList;

    tabla.IndexFieldNames := tabla.IndexFieldNames;
    tabla.First;
end;

procedure TTManzanas.BuscarPorDescrip(xexpr: string);
begin
  tabla.IndexFieldNames := 'Descrip';
  tabla.FindNearest([xexpr]);
end;

procedure TTManzanas.BuscarPorCodigo(xexpr: string);
begin
  tabla.IndexFieldNames := 'idmanzana';
  tabla.FindNearest([xexpr]);
end;

procedure TTManzanas.conectar;
// Objetivo...: Abrir tablas de persistencia
begin
  if conexiones = 0 then Begin
    if not tabla.Active then tabla.Open;
    tabla.FieldByName('id').DisplayLabel := 'Id.'; tabla.FieldByName('Descrip').DisplayLabel := 'Descripción';
  end;
  Inc(conexiones);
end;

procedure TTManzanas.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones > 0 then Dec(conexiones);
  if conexiones = 0 then datosdb.closeDB(tabla);
end;

{===============================================================================}

function manzana: TTManzanas;
begin
  if xmanzana = nil then
    xmanzana := TTManzanas.Create;
  Result := xmanzana;
end;

{===============================================================================}

initialization

finalization
  xmanzana.Free;

end.
