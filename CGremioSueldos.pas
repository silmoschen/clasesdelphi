unit CGremioSueldos;

interface

uses SysUtils, DB, DBTables, CUtiles, CListar, CFirebird,
     IBDatabase, IBCustomDataSet, IBTable, Variants, Classes;

type

TTGremios = class(TObject)
  codigo, Gremio, Nombrec: string;
  PorQuincena1, PorQuincena2, MFQuincena1, MFQuincena2: Real;
  tabla, retgremios: TIBTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  function    Nuevo: string;
  function    Buscar(xcodigo: string): boolean;
  procedure   Grabar(xcodigo, xgremio, xnombrec: string);
  procedure   Borrar(xcodigo: string);
  procedure   getDatos(xcodigo: string);
  procedure   BuscarPorDescrip(xexpr: string);
  procedure   BuscarPorCodigo(xexpr: string);
  procedure   Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);

  function    BuscarRetencion(xcodigo, xperiodo: String): Boolean;
  procedure   GuardarRetencion(xcodigo, xperiodo: String; xporquincena1, xmfquincena1, xporquincena2, xmfquincena2: Real);
  procedure   BorrarRetencion(xcodigo, xperiodo: String);
  function    setRetenciones(xcodigo: String): TStringList;
  procedure   getRetencion(xcodigo, xperiodo: String);

  procedure   conectar;
  procedure   desconectar;
 private
  conexiones: shortint;
  { Declaraciones Privadas }
  procedure ListLinea(salida: char);
end;

function gremio: TTGremios;

implementation

var
  xgremio: TTGremios = nil;

constructor TTGremios.Create;
begin
  inherited Create;
  firebird.getModulo('sueldos');
  firebird.Conectar(firebird.Host + '\arch\arch.gdb', firebird.Usuario, firebird.Password);
  tabla      := firebird.InstanciarTabla('gremios');
  retgremios := firebird.InstanciarTabla('retgremios');
end;

destructor TTGremios.Destroy;
begin
  inherited Destroy;
end;

function TTGremios.Nuevo: string;
// Objetivo...: Generar un nuevo ID
begin
  tabla.IndexFieldNames := 'CODIGO';
  tabla.Last;
  if tabla.RecordCount = 0 then Result := '1' else Begin
    Result := IntToStr(StrToInt(tabla.FieldByName('codigo').AsString) + 1);
  end;
end;

function TTGremios.Buscar(xcodigo: string): boolean;
// Objetivo...: Buscar el Objeto solicitado
begin
  Result := firebird.Buscar(tabla, 'codigo', xcodigo);
end;

procedure TTGremios.Grabar(xcodigo, xgremio, xnombrec: string);
// Objetivo...: Grabar Atributos del Objeto
begin
  if Buscar(xcodigo) then tabla.Edit else tabla.Append;
  tabla.FieldByName('codigo').AsString    := xcodigo;
  tabla.FieldByName('gremio').AsString    := xgremio;
  tabla.FieldByName('nombrec').AsString   := xnombrec;
  try
    tabla.Post;
   except
    tabla.Cancel
  end;
  firebird.RegistrarTransaccion(tabla);
end;

procedure TTGremios.Borrar(xcodigo: string);
// Objetivo...: Eliminar un Objeto
begin
  if Buscar(xcodigo) then Begin
    tabla.Delete;
    getDatos(tabla.FieldByName('codigo').AsString);  // Fijamos los Atributos Siguientes al Objeto Borrado
    firebird.RegistrarTransaccion(tabla);
  end;
end;

procedure  TTGremios.getDatos(xcodigo: string);
// Objetivo...: Retornar/Iniciar Atributos
begin
  if Buscar(xcodigo) then Begin
    codigo      := tabla.FieldByName('codigo').AsString;
    gremio      := tabla.FieldByName('gremio').AsString;
    nombrec     := tabla.FieldByName('nombrec').AsString;
  end else Begin
    codigo := ''; gremio := ''; nombrec := '';
  end;
end;

procedure TTGremios.BuscarPorDescrip(xexpr: string);
// Objetivo...: Busqueda contextual
begin
  firebird.BuscarContextualmente(tabla, 'gremio', xexpr);
end;

procedure TTGremios.BuscarPorCodigo(xexpr: string);
// Objetivo...: Busqueda contextual
begin
  firebird.BuscarContextualmente(tabla, 'codigo', xexpr);
end;

procedure TTGremios.Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
// Objetivo...: Listar colección de objetos
begin
  if orden = 'A' then tabla.IndexName := tabla.IndexDefs.Items[1].Name;

  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Listado de Gremios', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Cód.', 1, 'Arial, cursiva, 8');
  List.Titulo(5, list.Lineactual, 'Nombre del Gremio', 2, 'Arial, cursiva, 8');
  List.Titulo(65, list.Lineactual, 'Nombre Completo', 3, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  tabla.First;
  while not tabla.EOF do Begin
    // Ordenado por Código
    if (ent_excl = 'E') and (orden = 'C') then
      if (tabla.FieldByName('codigo').AsString >= iniciar) and (tabla.FieldByName('codigo').AsString <= finalizar) then ListLinea(salida);
    if (ent_excl = 'X') and (orden = 'C') then
      if (tabla.FieldByName('codigo').AsString < iniciar) or (tabla.FieldByName('codigo').AsString > finalizar) then ListLinea(salida);
    // Ordenado Alfabéticamente
    if (ent_excl = 'E') and (orden = 'A') then
      if (tabla.FieldByName('NOMBRE').AsString >= iniciar) and (tabla.FieldByName('gremio').AsString <= finalizar) then ListLinea(salida);
    if (ent_excl = 'X') and (orden = 'A') then
      if (tabla.FieldByName('NOMBRE').AsString < iniciar) or (tabla.FieldByName('gremio').AsString > finalizar) then ListLinea(salida);

    tabla.Next;
  end;
  List.FinList;

  tabla.IndexFieldNames := tabla.IndexFieldNames;
  tabla.First;
end;

procedure TTGremios.ListLinea(salida: char);
begin
  List.Linea(0, 0, tabla.FieldByName('codigo').AsString, 1, 'Arial, normal, 8', salida, 'N');
  List.Linea(5, list.Lineactual, tabla.FieldByName('gremio').AsString, 2, 'Arial, normal, 8', salida, 'N');
  List.Linea(65, list.Lineactual, tabla.FieldByName('nombrec').AsString, 3, 'Arial, normal, 8', salida, 'S');
end;

function TTGremios.BuscarRetencion(xcodigo, xperiodo: String): Boolean;
// Objetivo...: Buscar Instancia
begin
  Result := firebird.Buscar(retgremios, 'codigo;periodo', xcodigo, xperiodo);
end;

procedure TTGremios.GuardarRetencion(xcodigo, xperiodo: String; xporquincena1, xmfquincena1, xporquincena2, xmfquincena2: Real);
// Objetivo...: Guardar Retencion
begin
  if BuscarRetencion(xcodigo, xperiodo) then retgremios.Edit else retgremios.Append;
  retgremios.FieldByName('codigo').AsString      := xcodigo;
  retgremios.FieldByName('periodo').AsString     := xperiodo;
  retgremios.FieldByName('porquincena1').AsFloat := xporquincena1;
  retgremios.FieldByName('mfquincena1').AsFloat  := xmfquincena1;
  retgremios.FieldByName('porquincena2').AsFloat := xporquincena2;
  retgremios.FieldByName('mfquincena2').AsFloat  := xmfquincena2;
  try
    retgremios.Post
   except
    retgremios.Cancel
  end;
  firebird.RegistrarTransaccion(retgremios);
end;

procedure TTGremios.BorrarRetencion(xcodigo, xperiodo: String);
// Objetivo...: Borrar Retencion
begin
  if BuscarRetencion(xcodigo, xperiodo) then retgremios.Delete;
  firebird.RegistrarTransaccion(retgremios);
end;

function  TTGremios.setRetenciones(xcodigo: String): TStringList;
// Objetivo...: Lista de Retenciones
var
  l, l1, l2: TStringList;
  i: Integer;
Begin
  l  := TStringList.Create;
  l1 := TStringList.Create;
  l2 := TStringList.Create;
  i  := 0;
  firebird.Filtrar(retgremios, 'CODIGO = ' + xcodigo);
  retgremios.First;
  while not retgremios.Eof do Begin
    l.Add(retgremios.FieldByName('periodo').AsString + retgremios.FieldByName('codigo').AsString + utiles.FormatearNumero(retgremios.FieldByName('porquincena1').AsString) + ';1' +
          utiles.FormatearNumero(retgremios.FieldByName('mfquincena1').AsString) + ';2' + utiles.FormatearNumero(retgremios.FieldByName('porquincena2').AsString) + ';3' + utiles.FormatearNumero(retgremios.FieldByName('mfquincena2').AsString));
    l1.Add(Copy(retgremios.FieldByName('periodo').AsString, 4, 4) + Copy(retgremios.FieldByName('periodo').AsString, 1, 2) + IntToStr(i));
    Inc(i);
    retgremios.Next;
  end;
  firebird.QuitarFiltro(retgremios);
  l1.Sort;
  for i := 1 to l1.Count do
    l2.Add(l.Strings[StrToInt(Trim(Copy(l1.Strings[i-1], 7, 3)))]);
  l1.Destroy; l.Destroy;
  Result := l2;
end;

procedure TTGremios.getRetencion(xcodigo, xperiodo: String);
// Objetivo...: Buscar Retencion
Begin
  if not retgremios.Active then retgremios.Open;
  PorQuincena1 := 0; PorQuincena2 := 0; MFQuincena1 := 0; MFQuincena2 := 0;
  retgremios.First;
  while not retgremios.Eof do Begin
    if retgremios.FieldByName('codigo').AsString = xcodigo then Begin
      PorQuincena1 := retgremios.FieldByName('porquincena1').AsFloat * 0.01;
      PorQuincena2 := retgremios.FieldByName('porquincena2').AsFloat * 0.01;
      MFQuincena1  := retgremios.FieldByName('mfquincena1').AsFloat;
      MFQuincena2  := retgremios.FieldByName('mfquincena2').AsFloat;
      if (Copy(retgremios.FieldByName('periodo').AsString, 4, 4) + Copy(retgremios.FieldByName('periodo').AsString, 1, 2)) >= (Copy(xperiodo, 4, 4) + Copy(xperiodo, 1, 2)) then Break;
    end;
    retgremios.Next;
  end;
end;

procedure TTGremios.conectar;
// Objetivo...: Abrir tablas de persistencia
begin
  if conexiones = 0 then Begin
    if not tabla.Active then tabla.Open;
    if not retgremios.Active then retgremios.Open;
  end;
  tabla.FieldByName('codigo').DisplayLabel := 'Código'; tabla.FieldByName('gremio').DisplayLabel := 'Gremio';
  firebird.RegistrarTransaccion(tabla);
  Inc(conexiones);
end;

procedure TTGremios.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones > 0 then Dec(conexiones);
  if conexiones = 0 then Begin
    firebird.closeDB(tabla);
    firebird.closeDB(retgremios);
  end;
end;

{===============================================================================}

function gremio: TTGremios;
begin
  if xgremio = nil then
    xgremio := TTGremios.Create;
  Result := xgremio;
end;

{===============================================================================}

initialization

finalization
  xgremio.Free;

end.
