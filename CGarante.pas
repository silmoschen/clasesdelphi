unit CGarante;

interface

uses CBDT, CPersona, Cliengar, CListar, DB, DBTables, CIDBFM;

type

TTGarante = class(TTPersona)          // Clase TVendedor Heredada de Persona
 public
  { Declaraciones Públicas }
  constructor Create(xcodigo, xnombre, xdomicilio, xcp, xorden, xatresp, xdomcob, xtelcom, xtelcob, xtelalt, xcodpfis, xnrocuit: string);
  destructor  Destroy; override;
  procedure   conectar;
  procedure   desconectar;
  procedure   Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
 private
  { Declaraciones Privadas }
  procedure List_linea(salida: char);
end;

function garante: TTGarante;

implementation

var
  xgarante: TTGarante = nil;

constructor TTGarante.Create(xcodigo, xnombre, xdomicilio, xcp, xorden, xatresp, xdomcob, xtelcom, xtelcob, xtelalt, xcodpfis, xnrocuit: string);
// Vendedor - Heredada de Persona
begin
  inherited Create(xcodigo, xnombre, xdomicilio, xcp, xorden);  // Constructor de la Superclase

  tperso := datosdb.openDB('garante', 'Nrodoc');
end;


destructor TTGarante.Destroy;
begin
  inherited Destroy;
end;

procedure TTGarante.conectar;
// Objetivo...: cerrar tablas de persistencia
begin
  clientegar.conectar;
  tperso.Open;
end;

procedure TTGarante.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  clientegar.desconectar;
  datosdb.closeDB(tperso);
end;

procedure TTGarante.List_linea(salida: char);
// Objetivo...: Listar una Línea
begin
  clientegar.BuscarNrodoc(tperso.FieldByName('nrodoc').AsString);
  List.Linea(0, 0, tperso.FieldByName('nrodoc').AsString + '  ' + tperso.FieldByName('nombre').AsString, 1, 'Arial, normal, 8', salida, 'N');
  List.Linea(50, List.lineactual, tperso.FieldByName('domicilio').AsString, 2, 'Arial, normal, 8', salida, 'N');
  List.Linea(75, List.lineactual, clientegar.Nombre, 3, 'Arial, normal, 8', salida, 'N');
end;

procedure TTGarante.Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
// Objetivo...: Listar Datos de Provincias
begin
  if orden = 'A' then tperso.IndexName := tperso.IndexDefs.Items[1].Name;

  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Listado de Garantes', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Nº Documento  Nombre', 1, 'Arial, cursiva, 8');
  List.Titulo(50, List.lineactual, 'Domicilio', 2, 'Arial, cursiva, 8');
  List.Titulo(75, List.lineactual, 'Cliente en Garantia', 3, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  tperso.First;
  while not tperso.EOF do
    begin
      // Ordenado por Código
      if (ent_excl = 'E') and (orden = 'C') then
        if (tperso.FieldByName('nrodoc').AsString >= iniciar) and (tperso.FieldByName('nrodoc').AsString <= finalizar) then List_linea(salida);
      if (ent_excl = 'X') and (orden = 'C') then
        if (tperso.FieldByName('nrodoc').AsString < iniciar) or (tperso.FieldByName('nrodoc').AsString > finalizar) then List_linea(salida);
      // Ordenado Alfabéticamente
      if (ent_excl = 'E') and (orden = 'A') then
        if (tperso.FieldByName('nombre').AsString >= iniciar) and (tperso.FieldByName('nombre').AsString <= finalizar) then List_linea(salida);
      if (ent_excl = 'X') and (orden = 'A') then
        if (tperso.FieldByName('nombre').AsString < iniciar) or (tperso.FieldByName('nombre').AsString > finalizar) then List_linea(salida);

      tperso.Next;
    end;
    List.FinList;

    tperso.IndexFieldNames := tperso.IndexFieldNames;
    tperso.First;
end;

{===============================================================================}

function garante: TTGarante;
begin
  if xgarante = nil then
    xgarante := TTGarante.Create('', '', '', '', '', '', '', '', '', '', '', '');
  Result := xgarante;
end;

{===============================================================================}

initialization

finalization
  xgarante.Free;

end.