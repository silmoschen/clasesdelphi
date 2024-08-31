unit CTablasVicentin;

interface

uses CBDT, SysUtils, DBTables, CUtiles, CListar, CIDBFM, Classes;

type

TTablas = class
  Idtabla, Descrip: String;
  tabla, tvalores: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  function    Buscar(xidtabla: String): Boolean;
  procedure   Registrar(xidtabla, xdescrip: String);
  procedure   Borrar(xidtabla: String);
  procedure   getDatos(xidtabla: String);
  function    setTablas: TStringList;
  function    Nuevo: String;

  function    BuscarItems(xidtabla, xsexo, xitems: String): Boolean;
  procedure   RegistrarItems(xidtabla, xsexo, xitems, xtalla: String; xpequenia, xmediana, xgrande: Real; xcantItems: Integer);
  function    setItems(xidtabla, xsexo: String): TStringList;

  procedure   Listar(xidtabla: String; salida: char);

  function   setPesoTeorico(xidtabla, xsexo, xtalla, xcontextura: String): String;

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  conexiones: shortint;
end;

function tablas: TTablas;

implementation

var
  xtablas: TTablas = nil;

constructor TTablas.Create;
begin
  tabla    := datosdb.openDB('tablas', '');
  tvalores := datosdb.openDB('tablas_valores', '');
end;

destructor TTablas.Destroy;
begin
  inherited Destroy;
end;

function  TTablas.Buscar(xidtabla: String): Boolean;
// Objetivo...: cerrar tablas de persistencia
begin
  if tabla.IndexFieldNames <> 'idtabla' then tabla.IndexFieldNames := 'idtabla';
  Result := tabla.FindKey([xidtabla]);
end;

procedure TTablas.Registrar(xidtabla, xdescrip: String);
// Objetivo...: cerrar tablas de persistencia
begin
  if Buscar(xidtabla) then tabla.Edit else tabla.Append;
  tabla.FieldByName('idtabla').AsString := xidtabla;
  tabla.FieldByName('descrip').AsString := xdescrip;
  try
    tabla.Post
   except
    tabla.Cancel
  end;
  datosdb.refrescar(tabla);
end;

procedure TTablas.Borrar(xidtabla: String);
// Objetivo...: cerrar tablas de persistencia
begin
  if Buscar(xidtabla) then Begin
    tabla.Delete;
    datosdb.tranSQL('delete from ' + tvalores.TableName + ' where idtabla = ' + '''' + xidtabla + '''');
  end;
end;

procedure TTablas.getDatos(xidtabla: String);
// Objetivo...: cerrar tablas de persistencia
begin
  if Buscar(xidtabla) then Begin
    idtabla := tabla.FieldByName('idtabla').AsString;
    descrip := tabla.FieldByName('descrip').AsString;
  end else Begin
    idtabla := ''; descrip := '';
  end;
end;

function  TTablas.Nuevo: String;
// Objetivo...: Nueva tabla
Begin
  if tabla.RecordCount = 0 then Result := '1' else Begin
    tabla.Last;
    Result := IntToStr(tabla.FieldByName('idtabla').AsInteger + 1);
  end;
end;

function TTablas.setTablas: TStringList;
var
  l: TStringList;
Begin
  l := TStringList.Create;
  tabla.IndexFieldNames := 'Descrip';
  tabla.First;
  while not tabla.Eof do Begin
    l.Add(tabla.FieldByName('idtabla').AsString + tabla.FieldByName('descrip').AsString);
    tabla.Next;
  end;
  Result := l;
end;

function  TTablas.BuscarItems(xidtabla, xsexo, xitems: String): Boolean;
// Objetivo...: cerrar tablas de persistencia
begin
  Result := datosdb.Buscar(tvalores, 'idtabla', 'sexo', 'items', xidtabla, xsexo, xitems);
end;

procedure TTablas.RegistrarItems(xidtabla, xsexo, xitems, xtalla: String; xpequenia, xmediana, xgrande: Real; xcantItems: Integer);
// Objetivo...: cerrar tablas de persistencia
begin
  if BuscarItems(xidtabla, xsexo, xitems) then tvalores.Edit else tvalores.Append;
  tvalores.FieldByName('idtabla').AsString := xidtabla;
  tvalores.FieldByName('sexo').AsString    := xsexo;
  tvalores.FieldByName('items').AsString   := xitems;
  tvalores.FieldByName('talla').AsString   := utiles.sLlenarIzquierda(xtalla, 3, '0');
  tvalores.FieldByName('pequenia').AsFloat := xpequenia;
  tvalores.FieldByName('mediana').AsFloat  := xmediana;
  tvalores.FieldByName('grande').AsFloat   := xgrande;
  try
    tvalores.Post
   except
    tvalores.Cancel
  end;
  if (xitems = utiles.sLlenarIzquierda(IntToStr(xcantitems), 2, '0')) then datosdb.tranSQL('delete from ' + tvalores.TableName + ' where idtabla = ' + '''' + xidtabla + '''' + ' and sexo = ' + '''' + xsexo + '''' + ' and items > ' + '''' + xitems + '''');
  datosdb.refrescar(tvalores);
end;

function  TTablas.setItems(xidtabla, xsexo: String): TStringList;
// Objetivo...: cerrar tablas de persistencia
var
  l: TStringList;
begin
  l := TStringList.Create;
  if BuscarItems(xidtabla, xsexo, '01') then Begin
    while not tvalores.Eof do Begin
      if (tvalores.FieldByName('idtabla').AsString <> xidtabla) or (tvalores.FieldByName('sexo').AsString <> xsexo) then Break;
      l.Add(tvalores.FieldByName('items').AsString + tvalores.FieldByName('talla').AsString + utiles.FormatearNumero(tvalores.FieldByName('pequenia').AsString) + ';1' + tvalores.FieldByName('mediana').AsString + ';2' + tvalores.FieldByName('grande').AsString);
      tvalores.Next;
    end;
  end;
  Result := l;
end;

procedure TTablas.Listar(xidtabla: String; salida: char);
// Objetivo...: Listar tabla de valores
var
  m, v: Boolean;
begin
  if Buscar(xidtabla) then Begin
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
    List.Titulo(0, 0, ' Listado Tabla de Valores', 1, 'Arial, negrita, 14');
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
    List.Titulo(0, 0, 'Talla', 1, 'Arial, cursiva, 8');
    List.Titulo(14, list.Lineactual, 'Pequeña', 2, 'Arial, cursiva, 8');
    List.Titulo(24, list.Lineactual, 'Mediana', 3, 'Arial, cursiva, 8');
    List.Titulo(35, list.Lineactual, 'Grande', 4, 'Arial, cursiva, 8');

    List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

    getDatos(xidtabla);
    list.Linea(0, 0, 'Tabla: ' + idtabla + ' - ' + descrip, 1, 'Arial, negrita, 9', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S');

    datosdb.Filtrar(tvalores, 'idtabla = ' + xidtabla);
    while not tvalores.Eof do Begin
      if (tvalores.FieldByName('sexo').AsString = 'F') and not (m) then Begin
        list.Linea(0, 0, 'Mujeres', 1, 'Arial, negrita, 8', salida, 'S');
        list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S');
        m := True;
      end;
      if (tvalores.FieldByName('sexo').AsString = 'M') and not (v) then Begin
        list.Linea(0, 0, '', 1, 'Arial, negrita, 10', salida, 'S');
        list.Linea(0, 0, 'Varones', 1, 'Arial, negrita, 8', salida, 'S');
        list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S');
        v := True;
      end;
      list.Linea(0, 0, tvalores.FieldByName('talla').AsString, 1, 'Arial, normal, 8', salida, 'N');
      list.importe(20, list.Lineactual, '', tvalores.FieldByName('pequenia').AsFloat, 2, 'Arial, normal, 8');
      list.importe(30, list.Lineactual, '', tvalores.FieldByName('mediana').AsFloat, 3, 'Arial, normal, 8');
      list.importe(40, list.Lineactual, '', tvalores.FieldByName('grande').AsFloat, 4, 'Arial, normal, 8');
      list.Linea(60, list.Lineactual, '', 5, 'Arial, normal, 8', salida, 'S');
      tvalores.Next;
    end;
    datosdb.QuitarFiltro(tvalores);

    list.FinList;
  end;
end;

function  TTablas.setPesoTeorico(xidtabla, xsexo, xtalla, xcontextura: String): String;
// Objetivo...: sacar el peso teórico
Begin
  datosdb.Filtrar(tvalores, 'idtabla = ' + '''' + xidtabla + '''' + ' and sexo = ' + '''' + xsexo + '''');
  tvalores.First;
  if xcontextura = 'Chica'   then Result := utiles.FormatearNumero(tvalores.FieldByName('pequenia').AsString);
  if xcontextura = 'Mediana' then Result := utiles.FormatearNumero(tvalores.FieldByName('mediana').AsString);
  if xcontextura = 'Grande'  then Result := utiles.FormatearNumero(tvalores.FieldByName('grande').AsString);
  while not tvalores.Eof do Begin
    if tvalores.FieldByName('talla').AsString > utiles.FormatearNumero(FloatToStr(StrToFloat(xtalla) * 100)) then Break;
    if xcontextura = 'Chica'   then Result := utiles.FormatearNumero(tvalores.FieldByName('pequenia').AsString);
    if xcontextura = 'Mediana' then Result := utiles.FormatearNumero(tvalores.FieldByName('mediana').AsString);
    if xcontextura = 'Grande'  then Result := utiles.FormatearNumero(tvalores.FieldByName('grande').AsString);
    tvalores.Next;
  end;
  datosdb.QuitarFiltro(tvalores); 
end;

procedure TTablas.conectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones = 0 then Begin
    if not tabla.Active then tabla.Open;
    if not tvalores.Active then tvalores.Open;
  end;
  Inc(conexiones);
end;

procedure TTablas.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  Dec(conexiones);
  if conexiones = 0 then Begin
    datosdb.closeDB(tabla);
    datosdb.closeDB(tvalores);
  end;
end;

{===============================================================================}

function tablas: TTablas;
begin
  if xtablas = nil then
    xtablas := TTablas.Create;
  Result := xtablas;
end;

{===============================================================================}

initialization

finalization
  xtablas.Free;

end.
