unit CDeudor;

interface

uses CBDT, CAcreDeu, SysUtils, DB, DBTables, CUtiles, CIDBFM;

type

TTDeudores = class(TTAcreedorDeudor)
  apnomcon: string;
  tabla3: TTable;
 public
  { Declaraciones Públicas }
  constructor Create(xnrocuit, xnombre, xdomicilio, xcp, xorden, xnumero, xpiso, xdepto, xpartdepto, xfechanac, xnrodoc, xapnom: string; xtdocnac, xtdocext, xestcivil: byte);
  destructor  Destroy; override;

  function    Buscar(xnrocuit: string): boolean;
  procedure   Grabar(xnrocuit, xnombre, xdomicilio, xcp, xorden, xnumero, xpiso, xdepto, xpartdepto, xfechanac, xnrodoc, xapnom: string; xtdocnac, xtdocext, xestcivil: byte);
  procedure   Borrar(xnrocuit: string);
  procedure   getDatos(xnrocuit: string);

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
end;

function deudor: TTDeudores;

implementation

var
  xdeudor: TTDeudores = nil;

constructor TTDeudores.Create(xnrocuit, xnombre, xdomicilio, xcp, xorden, xnumero, xpiso, xdepto, xpartdepto, xfechanac, xnrodoc, xapnom: string; xtdocnac, xtdocext, xestcivil: byte);
// Vendedor - Heredada de Persona
begin
  inherited Create(xnrocuit, xnombre, xdomicilio, xcp, xorden, xnumero, xpiso, xdepto, xpartdepto, xfechanac, xnrodoc, xtdocnac, xtdocext, xestcivil);
  tperso    := datosdb.openDB('deudores.DB', 'nrocuit');
  tabla2    := datosdb.openDB('deudorh1.DB', 'nrocuit');
  tabla3    := datosdb.openDB('deudorh2.DB', 'nrocuit');
end;

destructor TTDeudores.Destroy;
begin
  inherited Destroy;
end;

function  TTDeudores.Buscar(xnrocuit: string): boolean;
// Objetivo...: Buscar una instancia
begin
  if tabla3.FindKey([xnrocuit]) then Result := True else Result := False;
end;

procedure TTDeudores.Grabar(xnrocuit, xnombre, xdomicilio, xcp, xorden, xnumero, xpiso, xdepto, xpartdepto, xfechanac, xnrodoc, xapnom: string; xtdocnac, xtdocext, xestcivil: byte);
// Objetivo...: Persistir una instancia
begin
  inherited Grabar(xnrocuit, xnombre, xdomicilio, xcp, xorden, xnumero, xpiso, xdepto, xpartdepto, xfechanac, xnrodoc, xtdocnac, xtdocext, xestcivil);
  if Buscar(xnrocuit) then tabla3.Edit else tabla3.Append;
  tabla3.FieldByName('nrocuit').AsString  := xnrocuit;
  tabla3.FieldByName('apnomcon').AsString := xapnom;
  try
    tabla3.Post;
  except
    tabla3.Cancel;
  end;
end;

procedure TTDeudores.Borrar(xnrocuit: string);
// Objetivo...: Borrar una instancia
begin
  if Buscar(xnrocuit) then tabla3.Delete;
  getDatos(tabla3.FieldByName('nrocuit').AsString);
end;

procedure TTDeudores.getDatos(xnrocuit: string);
// Objetivo...: Actualizar atributos de la instancia
begin
  inherited getDatos(xnrocuit);
  if Buscar(xnrocuit) then
    begin
      apnomcon := tabla3.FieldByName('apnomcon').AsString;
    end
  else
    begin
      apnomcon := '';
    end;
end;

procedure TTDeudores.conectar;
// Objetivo...: cerrar tablas de persistencia
begin
  inherited conectar;
  if not tperso.Active then tperso.Open;
  if not tabla2.Active then tabla2.Open;
  if not tabla3.Active then tabla3.Open;
end;

procedure TTDeudores.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  inherited desconectar;
  datosdb.closeDB(tperso);
  datosdb.closeDB(tabla2);
  datosdb.closeDB(tabla3);
end;

{===============================================================================}

function deudor: TTDeudores;
begin
  if xdeudor = nil then
    xdeudor := TTDeudores.Create('', '', '', '', '', '', '', '', '', '', '', '', 0, 0, 0);
  Result := xdeudor;
end;

{===============================================================================}

initialization

finalization
  xdeudor.Free;

end.