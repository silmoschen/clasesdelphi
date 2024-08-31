unit CModeloImpresionCIC;

interface

uses CBDT, SysUtils, DBTables, CUtiles, CListar, CIDBFM;

type

TTModeloImpresion = class
  Id, Cabecera, Detalle, Pie: String;
  Lineasdet, Lineassep: Integer;
  modeloImp: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  procedure   RegistrarFormato(xid, xcabecera, xdetalle, xpie: String; xlineasdet, xlineassep: Integer);
  procedure   getDatosFormato(xid: String);

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  conexiones: shortint;
end;

function modeloimp: TTModeloImpresion;

implementation

var
  xmodeloimp: TTModeloImpresion = nil;

constructor TTModeloImpresion.Create;
begin
  modeloImp := datosdb.openDB('modeloImpr', '');
end;

destructor TTModeloImpresion.Destroy;
begin
  inherited Destroy;
end;

procedure TTModeloImpresion.RegistrarFormato(xid, xcabecera, xdetalle, xpie: String; xlineasdet, xlineassep: Integer);
// Objetivo...: Registrar Formato Impresion
begin
  if modeloImp.FindKey([xid]) then modeloImp.Edit else modeloImp.Append;
  modeloImp.FieldByName('id').AsString         := xid;
  modeloImp.FieldByName('cabecera').AsString   := xcabecera;
  modeloImp.FieldByName('detalle').AsString    := xdetalle;
  modeloImp.FieldByName('pie').AsString        := xpie;
  modeloImp.FieldByName('lineasdet').AsInteger := xlineasdet;
  modeloImp.FieldByName('lineassep').AsInteger := xlineassep;
  try
    modeloImp.Post
   except
    modeloImp.Cancel
  end;
  datosdb.closeDB(modeloImp); modeloImp.Open;
end;

procedure TTModeloImpresion.getDatosFormato(xid: String);
// Objetivo...: Recuperar Instancia Formato Impresion
begin
  if modeloImp.FindKey([xid]) then Begin
    id        := modeloImp.FieldByName('id').AsString;
    cabecera  := modeloImp.FieldByName('cabecera').AsString;
    detalle   := modeloImp.FieldByName('detalle').AsString;
    pie       := modeloImp.FieldByName('pie').AsString;
    lineasdet := modeloImp.FieldByName('lineasdet').AsInteger;
    lineassep := modeloImp.FieldByName('lineassep').AsInteger;
  end else Begin
    id := ''; cabecera := ''; detalle := ''; pie := ''; lineasdet := 10; lineassep := 5;
  end;
end;

procedure TTModeloImpresion.conectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones = 0 then Begin
    if not modeloimp.Active then modeloimp.Open;
  end;
  Inc(conexiones);
end;

procedure TTModeloImpresion.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  Dec(conexiones);
  if conexiones = 0 then Begin
    datosdb.closeDB(modeloimp); 
  end;
end;

{===============================================================================}

function modeloimp: TTModeloImpresion;
begin
  if xmodeloimp = nil then
    xmodeloimp := TTModeloImpresion.Create;
  Result := xmodeloimp;
end;

{===============================================================================}

initialization

finalization
  xmodeloimp.Free;

end.
