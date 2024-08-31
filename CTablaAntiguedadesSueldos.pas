unit CTablaAntiguedadesSueldos;

interface

uses SysUtils, DB, DBTables, CUtiles, CListar, CFirebird, CUtilidadesArchivos,
     IBDatabase, IBCustomDataSet, IBTable, Variants, CBDT, CEmpresasSueldos,
     Classes;

type

TTAntiguedades = class(TObject)
  Codigo, Descrip: string;
  tabla, escala: TIBTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  function    Nuevo: string;
  procedure   Grabar(xcodigo, xconcepto, xitems: string; xdesde, xhasta, xporcentaje: Real; xcantitems: Integer);
  procedure   Borrar(xcodigo: string);
  function    Buscar(xcodigo: string): boolean;
  procedure   getDatos(xcodigo: string);

  function    BuscarItems(xcodigo, xitems: string): boolean;
  function    setItems(xcodigo: String): TStringList;
  procedure   BorrarItems(xcodigo: String);
  
  procedure   conectar;
  procedure   desconectar;
 private
  conexiones: shortint;
  objfirebird: TTFirebird;
  { Declaraciones Privadas }
end;

function antiguedad: TTAntiguedades;

implementation

var
  xantiguedad: TTAntiguedades = nil;

constructor TTAntiguedades.Create;
begin
  objfirebird := TTFirebird.Create;
  firebird.getModulo('sueldos');
  objfirebird.Conectar(firebird.Host + '\' + empresa.setViaSeleccionada + '\datosempr.gdb', firebird.Usuario, firebird.Password);
  tabla  := objfirebird.InstanciarTabla('cab_antiguedad');
  escala := objfirebird.InstanciarTabla('tabla_antiguedad');
end;

destructor TTAntiguedades.Destroy;
begin
  inherited Destroy;
end;

function TTAntiguedades.Nuevo: string;
// Objetivo...: Generar un nuevo ID
begin
  tabla.Last;
  if tabla.RecordCount = 0 then Result := '1' else Begin
    Result := IntToStr(StrToInt(tabla.FieldByName('codigo').AsString) + 1);
  end;
end;

procedure TTAntiguedades.Grabar(xcodigo, xconcepto, xitems: string; xdesde, xhasta, xporcentaje: Real; xcantitems: Integer);
// Objetivo...: Grabar Atributos del Objeto
begin
  if xitems = '01' then Begin
    if Buscar(xcodigo) then tabla.Edit else tabla.Append;
    tabla.FieldByName('codigo').AsString   := xcodigo;
    tabla.FieldByName('descrip').AsString := xconcepto;
    try
      tabla.Post;
     except
      tabla.Cancel
    end;
    objfirebird.RegistrarTransaccion(tabla);
  end;

  if BuscarItems(xcodigo, xitems) then escala.Edit else escala.Append;
  escala.FieldByName('codigo').AsString    := xcodigo;
  escala.FieldByName('items').AsString     := xitems;
  escala.FieldByName('desde').AsFloat      := xdesde;
  escala.FieldByName('hasta').AsFloat      := xhasta;
  escala.FieldByName('porcentaje').AsFloat := xporcentaje;
  try
    escala.Post
   except
    escala.Cancel
  end;
  objfirebird.RegistrarTransaccion(escala);

  if xitems = utiles.sLlenarIzquierda(IntToStr(xcantitems), 2, '0') then Begin
    objfirebird.TransacSQL('delete from ' + escala.TableName + ' where codigo = ' + '''' + xcodigo + '''' + ' and items > ' + '''' + xitems + '''');
    objfirebird.RegistrarTransaccion(escala);
  end;
end;

procedure TTAntiguedades.Borrar(xcodigo: string);
// Objetivo...: Eliminar un Objeto
begin
  if Buscar(xcodigo) then Begin
    tabla.Delete;
    getDatos(tabla.FieldByName('codigo').AsString);  // Fijamos los Atributos Siguientes al Objeto Borrado
    objfirebird.RegistrarTransaccion(tabla);
  end;
end;

function TTAntiguedades.Buscar(xcodigo: string): boolean;
// Objetivo...: Buscar el Objeto solicitado
begin
  if tabla.IndexFieldNames <> 'CODIGO' then tabla.IndexFieldNames := 'CODIGO';
  Result := firebird.Buscar(tabla, 'CODIGO', xcodigo);
end;

procedure  TTAntiguedades.getDatos(xcodigo: string);
// Objetivo...: Retornar/Iniciar Atributos
begin
  if Buscar(xcodigo) then Begin
    codigo  := tabla.FieldByName('codigo').AsString;
    descrip := tabla.FieldByName('descrip').AsString;
  end else Begin
    codigo := ''; descrip := '';
  end;
end;

function  TTAntiguedades.BuscarItems(xcodigo, xitems: string): boolean;
// Objetivo...: Recuperar Instancia
Begin
  if escala.IndexFieldNames <> 'CODIGO;ITEMS' then escala.IndexFieldNames := 'CODIGO;ITEMS';
  Result := firebird.Buscar(escala, 'CODIGO;ITEMS', xcodigo, xitems);
end;

function  TTAntiguedades.setItems(xcodigo: String): TStringList;
// Objetivo...: Abrir tablas de persistencia
var
  l: TStringList;
begin
  l := TStringList.Create;
  objfirebird.Filtrar(escala, 'CODIGO = ' + '''' + xcodigo + '''');
  escala.First;
  while not escala.Eof do Begin
    l.Add(escala.FieldByName('items').AsString + utiles.FormatearNumero(escala.FieldByName('desde').AsString) + ';1' + utiles.FormatearNumero(escala.FieldByName('hasta').AsString) + ';2' + utiles.FormatearNumero(escala.FieldByName('porcentaje').AsString));
    escala.Next;
  end;
  objfirebird.QuitarFiltro(escala);
  Result := l;
end;

procedure TTAntiguedades.BorrarItems(xcodigo: String);
// Objetivo...: Borrar Items
Begin
  objfirebird.TransacSQL('delete from ' + escala.TableName + ' where codigo = ' + '''' + xcodigo + '''');
  objfirebird.RegistrarTransaccion(escala); 
end;

procedure TTAntiguedades.conectar;
// Objetivo...: Abrir tablas de persistencia
begin
  if conexiones = 0 then Begin
    if not tabla.Active then tabla.Open;
    if not escala.Active then escala.Open;
  end;
  Inc(conexiones);
end;

procedure TTAntiguedades.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones > 0 then Dec(conexiones);
  if conexiones = 0 then Begin
    firebird.closeDB(tabla);
    firebird.closeDB(escala);
  end;
end;

{===============================================================================}

function antiguedad: TTAntiguedades;
begin
  if xantiguedad = nil then
    xantiguedad := TTAntiguedades.Create;
  Result := xantiguedad;
end;

{===============================================================================}

initialization

finalization
  xantiguedad.Free;

end.
