{ Objetivo...: Definir una clase base para dar soporte a los comprobantes de Numeracióbn Correlativa }
unit CRegistCompNumerados;

interface

uses CComregi, CComprobantes, CStock, CTablaIva, CLPsimpl, CUtiles, SysUtils, DB, DBTables, CIDBFM, CListar;

type

TTComprobantesVtasNumCorrelativa = class(TTComprobantereg)
  entregado: string;
  Ncodcomp, Nidcompr, Ndescrip, Ncodmov, Ncontrolstock: string;  // Atributos para manejar los Tipos de Comprobantes
  Ncodnumer, Nnroinicial, Nnrofinal, Nnroactual, Nimpresora, Nnmaximo, Nrecibo: integer;

  NFExpendio, NFDesExpen: string;
  NFcodnumer, NFnroinicial, NFnrofinal, NFnroactual, NFimpresora: integer;  // Atributos para el mamnejo de la numeración individual de cada comprobante
  deffact, ctrlstock, tnumfact: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  { Procedimientos correspondiente al manejo de los comprobantes definidos }
  function  BuscarDefF(xcodcomp, xidcompr: string): boolean;
  procedure BorrarDefF(xcodcomp, xidcompr: string);
  procedure GrabarDefF(xcodcomp, xidcompr, xdescrip, xcodmov: string; xcodnumer, xnroinicial, xnrofinal, xnroactual, ximpresora, xnmaximo: integer; xcontrolstock: string);
  procedure getDatosDefF(xcodcomp, xidcompr: string);
  procedure FijarReciboPorDefecto(xcodcomp, xidcompr: string);
  procedure FijarPuntoDeVenta(xcodnumer: integer; xpunto, xdescrip: string);
  procedure getReciboPagos;
  function  setComprobantesDefinidos: TQuery;
  procedure conectarDefF;
  procedure desconectarDefF;
  { Fin }

  { Procedimientos correspondiente al manejo de la numeración de los comprobantes individuales }
  function    BuscarNF(xcodnumer: integer): boolean;
  procedure   GrabarNF(xcodnumer, xnroinicial, xnrofinal, xnroactual: integer);
  procedure   getDatosNF(xcodnumer: integer);
  procedure   ActNuemeroActualNF(xnumero: string);
  function    getNroSiguienteNF(xcodnumer: integer): string;
  { Fin }

  procedure conectar;
  procedure desconectar;
 private
  { Declaraciones Privadas }
 protected
  { Declaraciones Protegidas }
end;

function comprNumCorrelativa: TTComprobantesVtasNumCorrelativa;

implementation

var
  xfactventa: TTComprobantesVtasNumCorrelativa = nil;

constructor TTComprobantesVtasNumCorrelativa.Create;
begin
  inherited Create;
end;

destructor TTComprobantesVtasNumCorrelativa.Destroy;
begin
  inherited Destroy;
end;

//******************************************************************************
{ Métodos para la definición de comprobantes }
function TTComprobantesVtasNumCorrelativa.BuscarDefF(xcodcomp, xidcompr: string): boolean;
begin
  Result := datosdb.Buscar(deffact, 'codcomp', 'idcompr', xcodcomp, xidcompr);
end;

procedure TTComprobantesVtasNumCorrelativa.GrabarDefF(xcodcomp, xidcompr, xdescrip, xcodmov: string; xcodnumer, xnroinicial, xnrofinal, xnroactual, ximpresora, xnmaximo: integer; xcontrolstock: string);
// Objetivo...: Grabar los Atributos
begin
  if BuscarDefF(xcodcomp, xidcompr) then deffact.Edit else deffact.Append;
  deffact.FieldByName('codcomp').AsString    := xcodcomp;
  deffact.FieldByName('idcompr').AsString    := xidcompr;
  deffact.FieldByName('descrip').AsString    := xdescrip;
  deffact.FieldByName('codmov').AsString     := xcodmov;
  deffact.FieldByName('codnumer').AsInteger  := xcodnumer;
  deffact.FieldByName('impresora').AsInteger := ximpresora;
  deffact.FieldByName('nmaximo').AsInteger   := xnmaximo;
  deffact.FieldByName('recibo').AsInteger    := 0;
  try
    deffact.Post;
  except
    deffact.Cancel;
  end;
  // Actualizamos los datos correspondientes a la numeración del comprobante
  GrabarNF(xcodnumer, xnroinicial, xnrofinal, xnroactual);
  if ctrlstock.RecordCount = 0 then ctrlstock.Append else ctrlstock.Edit;
  ctrlstock.FieldByName('controlstock').AsString := xcontrolstock;
  try
    ctrlstock.Post
  except
    ctrlstock.Cancel
  end;
end;

procedure TTComprobantesVtasNumCorrelativa.getDatosDefF(xcodcomp, xidcompr: string);
// Objetivo...: Actualizar los atributos de un comprobante
begin
  if BuscarDefF(xcodcomp, xidcompr) then
    begin
      Ncodcomp   := deffact.FieldByName('codcomp').AsString;
      Nidcompr   := deffact.FieldByName('idcompr').AsString;
      Ndescrip   := deffact.FieldByName('descrip').AsString;
      Ncodmov    := deffact.FieldByName('codmov').AsString;
      Ncodnumer  := deffact.FieldByName('codnumer').AsInteger;
      Nimpresora := deffact.FieldByName('impresora').AsInteger;
      Nnmaximo   := deffact.FieldByName('nmaximo').AsInteger;
      Nrecibo    := deffact.FieldByName('recibo').AsInteger;
    end
  else
    begin
      Ncodcomp := ''; Nidcompr := ''; Ndescrip := ''; Ncodmov := ''; Ncodnumer := 0; Nimpresora := 0; Nnmaximo := 0; Nrecibo := 0;
    end;
  // Extraigo la información pertinente a la numeración del comprobante
  getDatosNF(Ncodnumer);
  Nnroinicial := NFnroinicial;
  Nnrofinal   := NFnrofinal;
  Nnroactual  := NFnroactual;
end;

procedure TTComprobantesVtasNumCorrelativa.BorrarDefF(xcodcomp, xidcompr: string);
// Objetivo...: Eliminar un Objeto
begin
  if BuscarDefF(xcodcomp, xidcompr) then
    begin
      deffact.Delete;
      getDatosDefF(deffact.FieldByName('codcomp').AsString, deffact.FieldByName('idcompr').AsString);  // Fijamos los Atributos Siguientes al Objeto Borrado
    end;
end;

function  TTComprobantesVtasNumCorrelativa.setComprobantesDefinidos: TQuery;
// Objetivo...: Devolver un set de comprobantes definidos - habilitados para esta factura
begin
  Result := datosdb.tranSQL('SELECT * FROM ' + deffact.TableName);
end;

procedure TTComprobantesVtasNumCorrelativa.conectarDefF;
// Objetivo...: Conectar tabla de persistencia
begin
  if not deffact.Active then deffact.Open;
  deffact.FieldByName('codnumer').Visible := False; deffact.FieldByName('impresora').Visible := False;
  deffact.FieldByName('codcomp').DisplayLabel := 'Tipo'; deffact.FieldByName('idcompr').DisplayLabel := 'Comp.'; deffact.FieldByName('descrip').DisplayLabel := 'Descripción'; deffact.FieldByName('codnumer').DisplayLabel := 'Cód. Num';
  compregis.conectar;
  if not ctrlstock.Active then ctrlstock.Open;
  if not tnumfact.Active then tnumfact.Open;
  ctrlstock.First;
  Ncontrolstock := ctrlstock.FieldByName('controlstock').AsString;
end;

procedure TTComprobantesVtasNumCorrelativa.desconectarDefF;
// Objetivo...: Cerrar tabla de persistencia
begin
  datosdb.closeDB(deffact);
  compregis.desconectar;
  datosdb.closeDB(ctrlstock);
  datosdb.closeDB(tnumfact);
end;

//******************************************************************************
{ Métodos para controlar la numeración - correlatividad - de los comprobantes }
function TTComprobantesVtasNumCorrelativa.BuscarNF(xcodnumer: integer): boolean;
begin
  if tnumfact.FindKey([xcodnumer]) then Result := True else Result := False;
end;

procedure TTComprobantesVtasNumCorrelativa.GrabarNF(xcodnumer, xnroinicial, xnrofinal, xnroactual: integer);
// Objetivo...: Grabar los Atributos
begin
  if BuscarNF(xcodnumer) then tnumfact.Edit else tnumfact.Append;
  tnumfact.FieldByName('codnumer').AsInteger   := xcodnumer;
  tnumfact.FieldByName('nroinicial').AsInteger := xnroinicial;
  tnumfact.FieldByName('nrofinal').AsInteger   := xnrofinal;
  tnumfact.FieldByName('nroactual').AsInteger  := xnroactual;
  try
    tnumfact.Post;
  except
    tnumfact.Cancel;
  end;
end;

procedure TTComprobantesVtasNumCorrelativa.FijarPuntoDeVenta(xcodnumer: integer; xpunto, xdescrip: string);
// Objetivo...: Fijar punto de venta para un comprobante dado
begin
  if BuscarNF(xcodnumer) then Begin
    tnumfact.Edit;
    tnumfact.FieldByName('expendio').AsString := xpunto;
    tnumfact.FieldByName('descrip').AsString  := xdescrip;
    try
      tnumfact.Post;
    except
      tnumfact.Cancel;
    end;
  end;
end;

procedure TTComprobantesVtasNumCorrelativa.getDatosNF(xcodnumer: integer);
// Objetivo...: Actualizar los atributos de un comprobante
begin
  if BuscarNF(xcodnumer) then
    begin
      NFcodnumer   := tnumfact.FieldByName('codnumer').AsInteger;
      NFnroinicial := tnumfact.FieldByName('nroinicial').AsInteger;
      NFnrofinal   := tnumfact.FieldByName('nrofinal').AsInteger;
      NFnroactual  := tnumfact.FieldByName('nroactual').AsInteger;
      NFExpendio   := tnumfact.FieldByName('expendio').AsString;
      NFDesExpen   := tnumfact.FieldByName('descrip').AsString;
    end
  else
    begin
      NFcodnumer := 0; NFnroinicial := 0; NFnrofinal := 0; NFnroactual := 0; NFimpresora := 0;  NFExpendio := ''; NFDesExpen := '';
    end;
end;

procedure TTComprobantesVtasNumCorrelativa.ActNuemeroActualNF(xnumero: string);
begin
  if BuscarNF(NFcodnumer) then
    begin
      tnumfact.Edit;
      tnumfact.FieldByName('nroactual').AsString := xnumero;
      try
        tnumfact.Post;
      except
        tnumfact.Cancel;
      end;
    end;
end;

procedure TTComprobantesVtasNumCorrelativa.FijarReciboPorDefecto(xcodcomp, xidcompr: string);
// Objetivo...: Fijar el comprobante que será tomado como recibo - por defecto, para la liquidación de entregas iniciales
begin
  if BuscarDefF(xcodcomp, xidcompr) then
    begin
      deffact.Edit;
      deffact.FieldByName('recibo').AsInteger := 1;
      try
        deffact.Post
      except
        deffact.Cancel
      end;
    end;
end;

procedure TTComprobantesVtasNumCorrelativa.getReciboPagos;
// Objetivo...: Buscar Recibo para Liquidar pagos como Entregas iniciales
var
  c, i: string;
begin
  c := deffact.FieldByName('codcomp').AsString; i := deffact.FieldByName('idcompr').AsString;
  deffact.First;
  while not deffact.EOF do Begin
    if deffact.FieldByName('recibo').AsInteger = 1 then Begin
      Ncodcomp   := deffact.FieldByName('codcomp').AsString;
      Nidcompr   := deffact.FieldByName('idcompr').AsString;
      getDatosDefF(Ncodcomp, Nidcompr);
      Break;
    end;
    deffact.Next;
  end;
  BuscarDefF(c, i);
end;

function TTComprobantesVtasNumCorrelativa.getNroSiguienteNF(xcodnumer: integer): string;
// Objetivo...: retornar el siguiente
begin
  Result := '1';
  if BuscarNF(NFcodnumer) then Result := IntToStr(tnumfact.FieldByName('nroactual').AsInteger + 1);
end;

//******************************************************************************
//------------------------------------------------------------------------------

procedure TTComprobantesVtasNumCorrelativa.conectar;
// Objetivo...: conectar tablas de persistencia
begin
  inherited conectar;
  conectarDefF;
end;

procedure TTComprobantesVtasNumCorrelativa.desconectar;
// Objetivo...: desconectar tablas de persistencia
begin
  inherited desconectar;
  desconectarDefF;
end;

{===============================================================================}

function comprNumCorrelativa: TTComprobantesVtasNumCorrelativa;
begin
  if xfactventa = nil then
    xfactventa := TTComprobantesVtasNumCorrelativa.Create;
  Result := xfactventa;
end;

{===============================================================================}

initialization

finalization
  xfactventa.Free;

end.
