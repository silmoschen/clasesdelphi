unit CConcepto;

interface

uses SysUtils, DB, DBTables, CBDT, CIDBFM, CListar, CUtiles;

type

TTConceptos = class(TObject)            // Superclase
  codconc, Descrip: string;
  tabla: TTable;
 public
  { Declaraciones Públicas }
  constructor Create(xcodconc, xdescrip: string);
  destructor  Destroy; override;

  procedure   Grabar(xcodconc, xDescrip: string);
  procedure   Borrar(xcodconc: string);
  function    Buscar(xcodconc: string): boolean;
  procedure   getDatos(xcodconc: string);
  function    setConceptos: TQuery;
  procedure   Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  conexiones: shortint;
end;

function conceptos: TTConceptos;

implementation

var
  xconceptos: TTConceptos = nil;

constructor TTConceptos.Create(xcodconc, xdescrip: string);
begin
  inherited Create;
  codconc := xcodconc;
  descrip  := xdescrip;
end;

destructor TTConceptos.Destroy;
begin
  inherited Destroy;
end;

procedure TTConceptos.Grabar(xcodconc, xdescrip: string);
// Objetivo...: Grabar Atributos del Objeto
begin
  if Buscar(xcodconc) then tabla.Edit else tabla.Append;
  tabla.FieldByName('codconc').Value := xcodconc;
  tabla.FieldByName('descrip').Value  := xdescrip;
  try
    tabla.Post;
  except
    tabla.Cancel;
  end;
end;

procedure TTConceptos.Borrar(xcodconc: string);
// Objetivo...: Eliminar un Objeto
begin
  if Buscar(xcodconc) then
    begin
      tabla.Delete;
      getDatos(tabla.FieldByName('codconc').AsString);  // Fijamos los Atributos Siguientes al Objeto Borrado
    end;
end;

function TTConceptos.Buscar(xcodconc: string): boolean;
// Objetivo...: Buscar el Objeto solicitado
begin
  if tabla.FindKey([xcodconc]) then Result := True else Result := False;
end;

procedure  TTConceptos.getDatos(xcodconc: string);
// Objetivo...: Retornar/Iniciar Atributos
begin
  tabla.Refresh;
  if Buscar(xcodconc) then
    begin
      codconc  := tabla.FieldByName('codconc').Value;
      descrip  := tabla.FieldByName('descrip').Value;
    end
   else
    begin
      codconc := ''; descrip := '';
    end;
end;

function TTConceptos.setConceptos: TQuery;
// Objetivo...: Devolver un set con los conceptos definidos
begin
  Result := datosdb.tranSQL('SELECT * FROM ' + tabla.TableName + ' ORDER BY descrip');
end;

procedure TTConceptos.Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
// Objetivo...: Listar Datos de descrips
begin
  if orden = 'A' then tabla.IndexName := tabla.IndexDefs.Items[1].Name;

  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Listado de conceptos', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Cód.' + utiles.espacios(3) +  'concepto', 1, 'Courier New, cursiva, 9');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  tabla.First;
  while not tabla.EOF do
    begin
      // Ordenado por Código
      if (ent_excl = 'E') and (orden = 'C') then
        if (tabla.FieldByName('codconc').AsString >= iniciar) and (tabla.FieldByName('codconc').AsString <= finalizar) then List.Linea(0, 0, tabla.FieldByName('codconc').AsString + '   ' + tabla.FieldByName('descrip').AsString, 1, 'Courier New, normal, 9', salida, 'S');
      if (ent_excl = 'X') and (orden = 'C') then
        if (tabla.FieldByName('codconc').AsString < iniciar) or (tabla.FieldByName('codconc').AsString > finalizar) then List.Linea(0, 0, tabla.FieldByName('codconc').AsString + '    ' + tabla.FieldByName('descrip').AsString, 1, 'Courier New, normal, 9', salida, 'S');
      // Ordenado Alfabéticamente
      if (ent_excl = 'E') and (orden = 'A') then
        if (tabla.FieldByName('descrip').AsString >= iniciar) and (tabla.FieldByName('descrip').AsString <= finalizar) then List.Linea(0, 0, tabla.FieldByName('codconc').AsString + '   ' + tabla.FieldByName('descrip').AsString, 1, 'Courier New, normal, 9', salida, 'S');
      if (ent_excl = 'X') and (orden = 'A') then
        if (tabla.FieldByName('descrip').AsString < iniciar) or (tabla.FieldByName('descrip').AsString > finalizar) then List.Linea(0, 0, tabla.FieldByName('codconc').AsString + '   ' + tabla.FieldByName('descrip').AsString, 1, 'Courier New, normal, 9', salida, 'S');

      tabla.Next;
    end;
    List.FinList;

    tabla.IndexFieldNames := tabla.IndexFieldNames;
    tabla.First;
end;

procedure TTConceptos.conectar;
// Objetivo...: conectar tabla de Persistencia
begin
  if conexiones = 0 then
    if not tabla.Active then tabla.Open;
  Inc(conexiones);
end;

procedure TTConceptos.desconectar;
// Objetivo...: desconectar tabla de Persistencia
begin
  Dec(conexiones);
  if conexiones = 0 then datosdb.closeDB(tabla);
end;

{===============================================================================}

function conceptos: TTConceptos;
begin
  if xconceptos = nil then
    xconceptos := TTConceptos.Create('', '');
  Result := xconceptos;
end;


{===============================================================================}

initialization

finalization
  xconceptos.Free;

end.
