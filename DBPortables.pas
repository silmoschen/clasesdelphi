unit DBPortables;

interface

uses SysUtils, DBTables, CUtiles;

type

TTDBPortables = class
  setSQL: TQuery;
  tabla : TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  function    openDB(idtabla, indiceactivo, sesion, privatedir: string): TTable;
  procedure   closeDB(tabla: TTable);
  function    tranSQL(xpath, xsql: string): TQuery;

  function    Buscar(tabla: TTable; c1, v1: string): boolean; overload;
  function    Buscar(tabla: TTable; c1, c2, v1, v2: string): boolean; overload;
  function    Buscar(tabla: TTable; c1, c2, c3, v1, v2, v3: string): boolean; overload;
  function    Buscar(tabla: TTable; c1, c2, c3, c4, v1, v2, v3, v4: string): boolean; overload;
  function    Buscar(tabla: TTable; c1, c2, c3, c4, c5, v1, v2, v3, v4, v5: string): boolean; overload;
  function    Buscar(tabla: TTable; c1, c2, c3, c4, c5, c6, v1, v2, v3, v4, v5, v6: string): boolean; overload;
  function    Buscar(tabla: TTable; c1, c2, c3, c4, c5, c6, c7, v1, v2, v3, v4, v5, v6, v7: string): boolean; overload;
  function    Buscar(tabla: TTable; c1, c2, c3, c4, c5, c6, c7, c8, v1, v2, v3, v4, v5, v6, v7, v8: string): boolean; overload;
 private
  { Declaraciones Privadas }
end;

function connport: TTDBPortables;

implementation

var
  xconnport: TTDBPortables = nil;

constructor TTDBPortables.Create;
begin
end;

destructor TTDBPortables.Destroy;
begin
  inherited Destroy;
end;

function TTDBPortables.openDB(idtabla, indiceactivo, sesion, privatedir: string): TTable;
// Objetivo...: inicializar una tabla de persistencia de objetos - tomando como parámetros la información de la sesión de datos a gestionar
begin
  tabla := TTable.Create(nil);                    // Constructor
  tabla.DatabaseName := privatedir;
  tabla.TableName := idtabla; tabla.IndexDefs.Update;
  if Length(trim(indiceactivo)) > 0 then tabla.IndexFieldNames := indiceactivo;  // Indice primario
  Result := tabla;
end;

procedure TTDBPortables.closeDB(tabla: TTable);
// Objetivo...: cerrar una tabla de persistencia de objetos
begin
  if tabla.Active then Begin
    tabla.Filtered := False;
    tabla.FlushBuffers;
    tabla.Close; tabla := nil; tabla.Free;
  end;
end;

function TTDBPortables.tranSQL(xpath, xsql: string): TQuery;
// Objetivo...: ejecutar una consulta SQL en un Directorio Específico

  function rSQL(xsql: string): TQuery;
  // Objetivo...: procesar y devolver el resultado SQL de una transacción
  begin
    setSQL.SQL.Clear; setSQL.Close;
    setSQL.SQL.Add(xsql);
    setSQL.ExecSQL;
    try
      Result := setSQL;
     except
      on E: Exception do utiles.msgError(E.Message + chr(13) + xsql);
    end;
    setSQL := nil;
  end;

begin
  if Length(Trim(xpath)) > 0 then Begin
    setSQL := TQuery.Create(nil);
    setSQL.DatabaseName := xpath;
    Result := rSQL(xsql);
   end else
    result := Nil;
end;

//------------------------------------------------------------------------------
// Funciones de búsqueda - sobrecargadas
function TTDBPortables.Buscar(tabla: TTable; c1, v1: string): boolean;
// Objetivo...: Buscar dos atributos en una tabla
begin
  Result := tabla.FindKey([v1]);
end;

function TTDBPortables.Buscar(tabla: TTable; c1, c2, v1, v2: string): boolean;
// Objetivo...: Buscar dos atributos en una tabla
begin
  if not tabla.Active then tabla.Open;
  tabla.SetKey;
  tabla.FieldByName(c1).AsString := v1;
  tabla.FieldByName(c2).AsString := v2;
  if tabla.GotoKey then Result := True else Result := False;
end;

function TTDBPortables.Buscar(tabla: TTable; c1, c2, c3, v1, v2, v3: string): boolean;
// Objetivo...: Buscar tres atributos en una tabla
begin
  if not tabla.Active then tabla.Open;
  tabla.SetKey;
  tabla.FieldByName(c1).AsString := v1;
  tabla.FieldByName(c2).AsString := v2;
  tabla.FieldByName(c3).AsString := v3;
  if tabla.GotoKey then Result := True else Result := False;
end;

function TTDBPortables.Buscar(tabla: TTable; c1, c2, c3, c4, v1, v2, v3, v4: string): boolean;
// Objetivo...: Buscar cuatro atributos en una tabla
begin
  if not tabla.Active then tabla.Open;
  tabla.SetKey;
  tabla.FieldByName(c1).AsString := v1;
  tabla.FieldByName(c2).AsString := v2;
  tabla.FieldByName(c3).AsString := v3;
  tabla.FieldByName(c4).AsString := v4;
  if tabla.GotoKey then Result := True else Result := False;
end;

function TTDBPortables.Buscar(tabla: TTable; c1, c2, c3, c4, c5, v1, v2, v3, v4, v5: string): boolean;
// Objetivo...: Buscar cinco atributos en una tabla
begin
  if not tabla.Active then tabla.Open;
  tabla.SetKey;
  tabla.FieldByName(c1).AsString := v1;
  tabla.FieldByName(c2).AsString := v2;
  tabla.FieldByName(c3).AsString := v3;
  tabla.FieldByName(c4).AsString := v4;
  tabla.FieldByName(c5).AsString := v5;
  if tabla.GotoKey then Result := True else Result := False;
end;

function TTDBPortables.Buscar(tabla: TTable; c1, c2, c3, c4, c5, c6, v1, v2, v3, v4, v5, v6: string): boolean;
// Objetivo...: Buscar seis atributos en una tabla
begin
  if not tabla.Active then tabla.Open;
  tabla.SetKey;
  tabla.FieldByName(c1).AsString := v1;
  tabla.FieldByName(c2).AsString := v2;
  tabla.FieldByName(c3).AsString := v3;
  tabla.FieldByName(c4).AsString := v4;
  tabla.FieldByName(c5).AsString := v5;
  tabla.FieldByName(c6).AsString := v6;
  if tabla.GotoKey then Result := True else Result := False;
end;

function TTDBPortables.Buscar(tabla: TTable; c1, c2, c3, c4, c5, c6, c7, v1, v2, v3, v4, v5, v6, v7: string): boolean;
// Objetivo...: Buscar siete atributos en una tabla
begin
  if not tabla.Active then tabla.Open;
  tabla.SetKey;
  tabla.FieldByName(c1).AsString := v1;
  tabla.FieldByName(c2).AsString := v2;
  tabla.FieldByName(c3).AsString := v3;
  tabla.FieldByName(c4).AsString := v4;
  tabla.FieldByName(c5).AsString := v5;
  tabla.FieldByName(c6).AsString := v6;
  tabla.FieldByName(c7).AsString := v7;
  if tabla.GotoKey then Result := True else Result := False;
end;

function TTDBPortables.Buscar(tabla: TTable; c1, c2, c3, c4, c5, c6, c7, c8, v1, v2, v3, v4, v5, v6, v7, v8: string): boolean;
// Objetivo...: Buscar siete atributos en una tabla
begin
  if not tabla.Active then tabla.Open;
  tabla.SetKey;
  tabla.FieldByName(c1).AsString := v1;
  tabla.FieldByName(c2).AsString := v2;
  tabla.FieldByName(c3).AsString := v3;
  tabla.FieldByName(c4).AsString := v4;
  tabla.FieldByName(c5).AsString := v5;
  tabla.FieldByName(c6).AsString := v6;
  tabla.FieldByName(c7).AsString := v7;
  tabla.FieldByName(c8).AsString := v8;
  if tabla.GotoKey then Result := True else Result := False;
end;

{===============================================================================}

function connport: TTDBPortables;
begin
  if xconnport = nil then
    xconnport := TTDBPortables.Create;
  Result := xconnport;
end;

{===============================================================================}

initialization

finalization
  xconnport.Free;

end.
