unit CClientePanaderia;

interface

uses CBDT, CCliente, SysUtils, DB, DBTables, CUtiles, CIDBFM;

type

TTCliengar = class(TTCliente)          // Clase TVendedor Heredada de Persona
  nrodoc, docgarante, fechanac, tarjeta: string;
  ingreso: real;
  tabla3 : TTable;         // Tablas para la Persistencia de Objetos
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  procedure   Grabar(xcodigo, xnombre, xdomicilio, xcp, xorden, xatresp, xdomcob, xtelcom, xtelcob, xtelalt, xcodpfis, xnrocuit, xemail, xnrodoc, xdocgarante, xfechanac, xtarjeta: string; xingreso: real); overload;
  function    Borrar(cod: string): string;
  function    Buscar(cod: string): boolean;
  function    BuscarNrodoc(xnrodoc: string): boolean;
  function    BuscarDocumento(xnrodoc: string): boolean;

  procedure   getDatos(cod: string);

  procedure   desconectar;
  procedure   conectar;
 private
  { Declaraciones Privadas }
  conexiones: shortint;
end;

function clientegar: TTCliengar;

implementation

var
  xclientegar: TTCliengar = nil;

constructor TTCliengar.Create;
// Vendedor - Heredada de Persona
begin
  inherited Create;
  tperso := datosdb.openDB('clientes', 'Codcli');
  tabla2 := datosdb.openDB('clienteh', 'Codcli');
  tabla3 := datosdb.openDB('cliengar', 'Codcli');
end;

destructor TTCliengar.Destroy;
begin
  inherited Destroy;
end;

procedure TTCliengar.Grabar(xcodigo, xnombre, xdomicilio, xcp, xorden, xatresp, xdomcob, xtelcom, xtelcob, xtelalt, xcodpfis, xnrocuit, xemail, xnrodoc, xdocgarante, xfechanac, xtarjeta: string; xingreso: real);
// Objetivo...: Grabar Atributos de Vendedores
begin
  inherited Grabar(xcodigo, xnombre, xdomicilio, xcp, xorden, xatresp, xdomcob, xtelcom, xtelcob, xtelalt, xcodpfis, xnrocuit, xemail);
  tperso.Edit;
  tperso.FieldByName('tarjeta').AsString := xtarjeta;
  try
    tperso.Post
  except
    tperso.Cancel
  end;

  if Buscar(xcodigo) then tabla3.Edit else tabla3.Append;
  tabla3.FieldByName('codcli').AsString     := xcodigo;
  tabla3.FieldByName('nrodoc').AsString     := xnrodoc;
  tabla3.FieldByName('ingreso').AsFloat     := xingreso;
  tabla3.FieldByName('docgarante').AsString := xdocgarante;
  tabla3.FieldByName('fechanac').AsString   := utiles.sExprFecha(xfechanac);
  try
    tabla3.Post;
  except
    tabla3.Cancel;
  end;
end;

procedure  TTCliengar.getDatos(cod: string);
// Objetivo...: Obtener/Inicializar los Atributos para un objeto Vendedor
begin
  if conexiones = 0 then conectar;
  inherited getDatos(cod);  // Heredamos de la Superclase
  tarjeta := tperso.FieldByName('tarjeta').AsString;
  if Buscar(cod) then
    begin
      nrodoc     := tabla3.FieldByName('nrodoc').AsString;
      docgarante := tabla3.FieldByName('docgarante').AsString;
      ingreso    := tabla3.FieldByName('ingreso').AsFloat;
      fechanac   := utiles.sFormatoFecha(tabla3.FieldByName('fechanac').AsString);
    end
  else
    begin
      nrodoc := ''; docgarante := ''; fechanac := ''; ingreso := 0;
    end;
end;

function TTCliengar.Borrar(cod: string): string;
// Objetivo...: Eliminar un Instancia de Vendedor
begin
  try
    if Buscar(cod) then
      begin
        inherited Borrar(cod);  // Metodo de la Superclase Persona
        tabla3.Delete;
        getDatos(tabla3.FieldByName('codcli').AsString);  // Fijamos los Atributos Siguientes al Objeto Borrado
      end;
  except
  end;
end;

function TTCliengar.Buscar(cod: string): boolean;
// Objetivo...: Verificar si Existe el Cliente
begin
 if not tabla3.Active then conectar;
 if tabla3.FieldByName('codcli').AsString = cod then Result := True else
  begin
   inherited Buscar(cod);  // Método de la Superclase (Sincroniza los Valores de las Tablas)
   if tabla3.FindKey([cod]) then Result := True else Result := False;
  end;
end;

function TTCliengar.BuscarNrodoc(xnrodoc: string): boolean;
// Objetivo...: Buscar un cliente - garantido - por Nro. de documento
begin
  tabla3.IndexName := 'Nrodoc';
  if tabla3.FindKey([xnrodoc]) then Begin
    codigo := tabla3.FieldByName('codcli').AsString;
    Result := True;
   end
  else
    Result := False;
  tabla3.IndexFieldNames := 'Codcli';
end;

function TTCliengar.BuscarDocumento(xnrodoc: string): boolean;
// Objetivo...: Buscar un cliente - garantido - por Nro. de documento
begin
  tabla3.IndexName := 'Nrodoc';
  tabla3.FindNearest([xnrodoc]);
  codigo := tabla3.FieldByName('codcli').AsString;
  inherited Buscar(codigo);
  Result := True;
  tabla3.IndexFieldNames := 'Codcli';
end;

procedure TTCliengar.conectar;
// Objetivo...: Abrir las tablas de persistencia
begin
  inherited conectar;
  tperso.FieldByName('tarjeta').Visible := False;
  if conexiones = 0 then
    if not tabla3.Active then tabla3.Open;
  Inc(conexiones);
end;

procedure TTCliengar.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  inherited desconectar;
  if conexiones > 0 then Dec(conexiones);
  if conexiones = 0 then datosdb.closeDB(tabla3);
end;

{===============================================================================}

function clientegar: TTCliengar;
begin
  if xclientegar = nil then
    xclientegar := TTCliengar.Create;
  Result := xclientegar;
end;

{===============================================================================}

initialization

finalization
  xclientegar.Free;

end.