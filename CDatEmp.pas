unit CDatEmp;

interface

uses SysUtils, DB, DBTables, CBDT, CUtiles, CIDBFM;

type

TTDatosEmpresa = class(TObject)            // Superclase
  cuit, rsocial, domicilio, telefonos: string;
  tabla: TTable;
 public
  { Declaraciones Públicas }
  constructor Create(xcuit, xrsocial, xdomicilio, xtelefonos: string);
  destructor  Destroy; override;

  function    getCuit: string;
  function    getRsocial: string;
  function    getDomicilio: string;
  function    getTelefonos: string;

  procedure   Grabar(xcuit, xrsocial, xdomicilio, xtelefonos: string);
  procedure   getDatos;

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
end;

function datosemp: TTDatosEmpresa;

implementation

var
  xdatosemp: TTDatosEmpresa = nil;

constructor TTDatosEmpresa.Create(xcuit, xrsocial, xdomicilio, xtelefonos: string);
begin
  inherited Create;
  cuit      := xcuit;
  rsocial   := xrsocial;
  domicilio := xdomicilio;
  telefonos := xtelefonos;
  tabla     := datosdb.openDB('datosemp.DB', 'cuit');
end;

destructor TTDatosEmpresa.Destroy;
begin
  inherited Destroy;
end;

function TTDatosEmpresa.getCuit: string;
begin
  Result := cuit;
end;

function TTDatosEmpresa.getRsocial: string;
begin
  Result := rsocial;
end;

function TTDatosEmpresa.getDomicilio: string;
begin
  Result := domicilio;
end;

function TTDatosEmpresa.getTelefonos: string;
begin
  Result := telefonos;
end;

procedure TTDatosEmpresa.Grabar(xcuit, xrsocial, xdomicilio, xtelefonos: string);
// Objetivo...: Grabar Atributos del Objeto
begin
  if tabla.RecordCount > 0 then tabla.Edit else tabla.Append;
  tabla.FieldByName('cuit').AsString       := xcuit;
  tabla.FieldByName('rsocial').AsString    := xrsocial;
  tabla.FieldByName('domicilio').AsString  := xdomicilio;
  tabla.FieldByName('telefonos').AsString  := xtelefonos;
  try
    tabla.Post;
  except
    tabla.Cancel;
  end;
end;

procedure  TTDatosEmpresa.getDatos;
// Objetivo...: Retornar/Iniciar Atributos
begin
  tabla.First;
  cuit      := tabla.FieldByName('cuit').AsString;
  rsocial   := tabla.FieldByName('rsocial').AsString;
  domicilio := tabla.FieldByName('domicilio').AsString;
  telefonos := tabla.FieldByName('telefonos').AsString;
end;

procedure TTDatosEmpresa.conectar;
// Objetivo...: conectar tablas de persistencia
begin
  if not tabla.Active then tabla.Open;
  getDatos;
end;

procedure TTDatosEmpresa.desconectar;
// Objetivo...: desconectar tablas de persistencia
begin
  if tabla.Active then
    begin
      tabla.Refresh; tabla.Close;
    end;
end;

{===============================================================================}

function datosemp: TTDatosEmpresa;
begin
  if xdatosemp = nil then
    xdatosemp := TTDatosEmpresa.Create('', '', '', '');
  Result := xdatosemp;
end;

{===============================================================================}

initialization

finalization
  xdatosemp.Free;

end.