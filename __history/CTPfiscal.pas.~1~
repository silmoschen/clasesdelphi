unit CTPfiscal;

interface

uses SysUtils, DB, DBTables, CBDT, CIDBFM;

type

TTCPfiscal = class(TObject)            // Superclase
  codpfis, Descrip, Tipo, Idcompr, Discrimina_IVA: String;
  tpfis, compr: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  procedure   Grabar(xcodpfis, xDescrip: string);
  procedure   Borrar(xcodpfis: string);
  function    Buscar(xcodpfis: string): boolean;
  procedure   getDatos(xcodpfis: string);
  procedure   BuscarPorId(xexpr: string);
  procedure   BuscarPorNombre(xexpr: string);

  procedure   DefinirComprobantePredeterminado(xcodpfis, xtipo, xcomprob, xdiscr_iva: String);
  procedure   getDatosComprobantePredeterminado(xcodpfis: String);

  function    BuscarComprobante(xcodpfis, xidc, xtipo: String): Boolean;
  procedure   AgregarComprobante(xcodpfis, xidc, xtipo, xretiva, xdefecto: String);
  procedure   BorrarComprobante(xcodpfis, xidc, xtipo: String);
  function    setComprobantes(xcodpfis: String): TQuery;

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  conexiones: shortint;
end;

function tcpfiscal: TTCPfiscal;

implementation

var
  xtcpfiscal: TTCPfiscal = nil;

constructor TTCPfiscal.Create;
begin
  inherited Create;
  tpfis := datosdb.openDB('tpfiscal', '');
  compr := datosdb.openDB('comprobantesfact', '');
end;

destructor TTCPfiscal.Destroy;
begin
  inherited Destroy;
end;

//------------------------------------------------------------------------------

procedure TTCPfiscal.Grabar(xcodpfis, xdescrip: string);
// Objetivo...: Grabar Atributos del Objeto
begin
  if Buscar(xcodpfis) then tpfis.Edit else tpfis.Append;
  tpfis.FieldByName('codpfis').Value := xcodpfis;
  tpfis.FieldByName('descrip').Value  := xdescrip;
  try
    tpfis.Post;
  except
    tpfis.Cancel;
  end;
end;

procedure TTCPfiscal.Borrar(xcodpfis: string);
// Objetivo...: Eliminar un Objeto
begin
  if Buscar(xcodpfis) then Begin
    tpfis.Delete;
    getDatos(tpfis.FieldByName('codpfis').Value);  // Fijamos los Atributos Siguientes al Objeto Borrado
  end;
end;

function TTCPfiscal.Buscar(xcodpfis: string): boolean;
// Objetivo...: Buscar el Objeto solicitado
begin
  if not tpfis.Active then conectar;
  if tpfis.IndexFieldNames <> 'Codpfis' then tpfis.IndexFieldNames := 'Codpfis';
  if tpfis.FindKey([xcodpfis]) then Result := True else Result := False;
end;

procedure  TTCPfiscal.getDatos(xcodpfis: string);
// Objetivo...: Retornar/Iniciar Atributos
begin
  if Buscar(xcodpfis) then Begin
    codpfis        := tpfis.FieldByName('codpfis').AsString;
    descrip        := tpfis.FieldByName('descrip').AsString;
    discrimina_IVA := tpfis.FieldByName('discriva').AsString;
  end else begin
    codpfis := ''; descrip := ''; discrimina_IVA := '';
  end;
end;

procedure TTCPfiscal.BuscarPorId(xexpr: string);
begin
  tpfis.IndexName := 'Descrip';
  tpfis.FindNearest([xexpr]);
end;

procedure TTCPfiscal.BuscarPorNombre(xexpr: string);
begin
  tpfis.IndexFieldNames := 'Codpfis';
  tpfis.FindNearest([xexpr]);
end;

procedure TTCPfiscal.DefinirComprobantePredeterminado(xcodpfis, xtipo, xcomprob, xdiscr_iva: String);
// Objetivo...: Establecer Comprobante predeterminado para la registración
Begin
  if Buscar(xcodpfis) then Begin
    tpfis.Edit;
    tpfis.FieldByName('tipo').AsString     := xtipo;
    tpfis.FieldByName('idcompr').AsString  := xcomprob;
    tpfis.FieldByName('discriva').AsString := xdiscr_iva;
    try
      tpfis.Post
     except
      tpfis.Cancel
    end;
  end;
end;

procedure TTCPfiscal.getDatosComprobantePredeterminado(xcodpfis: String);
// Objetivo...: Cargar Datos Comprobantes Predeterminados
Begin
  Tipo := ''; Idcompr := ''; discrimina_IVA := '';
  compr.First;
  while not compr.Eof do Begin
    if (compr.FieldByName('defecto').AsString = 'S') and (compr.FieldByName('codpfis').AsString = xcodpfis) then Begin
      Tipo           := compr.FieldByName('tipo').AsString;
      Idcompr        := compr.FieldByName('Idc').AsString;
      discrimina_IVA := compr.FieldByName('retiva').AsString;
      Break;
    end;
    compr.Next;
  end;
end;

function  TTCPfiscal.BuscarComprobante(xcodpfis, xidc, xtipo: String): Boolean;
// Objetivo...: Buscar Instancia
Begin
  Result := datosdb.Buscar(compr, 'codpfis', 'idc', 'tipo', xcodpfis, xidc, xtipo);
end;

procedure TTCPfiscal.AgregarComprobante(xcodpfis, xidc, xtipo, xretiva, xdefecto: String);
// Objetivo...: Agregar Instancia
Begin
  if BuscarComprobante(xcodpfis, xidc, xtipo) then compr.Edit else compr.Append;
  compr.FieldByName('codpfis').AsString := xcodpfis;
  compr.FieldByName('idc').AsString     := xidc;
  compr.FieldByName('tipo').AsString    := xtipo;
  compr.FieldByName('retiva').AsString  := xretiva;
  compr.FieldByName('defecto').AsString := xdefecto;
  try
    compr.Post
   except
    compr.Cancel
  end;
  datosdb.closeDB(compr); compr.Open;
end;

procedure TTCPfiscal.BorrarComprobante(xcodpfis, xidc, xtipo: String);
// Objetivo...: Borrar Instancia
Begin
  if BuscarComprobante(xcodpfis, xidc, xtipo) then Begin
    compr.Delete;
    datosdb.closeDB(compr); compr.Open;
  end;
end;

function  TTCPfiscal.setComprobantes(xcodpfis: String): TQuery;
// Objetivo...: Devolver set
Begin
  Result := datosdb.tranSQL('select * from ' + compr.TableName + ' where codpfis = ' + '''' + xcodpfis + '''');
end;

procedure TTCPfiscal.conectar;
// Objetivo...: Abrir tablas de persistencia
var
  i: integer;
begin
  if conexiones = 0 then Begin
    if not datosdb.verificarSiExisteCampo('tpfiscal', 'discriva', dbs.baseDat) then
      datosdb.tranSQL(dbs.baseDat, 'alter table tpfiscal add discriva char(1)');
    tpfis.Open;
    tpfis.FieldByName('codpfis').DisplayLabel := 'Cód.'; tpfis.FieldByName('descrip').DisplayLabel := 'Descripción';
    For i := 3 to tpfis.FieldCount do
      tpfis.Fields[i - 1].Visible := False;

    if not compr.Active then compr.Open;
  end;
  Inc(conexiones);
end;

procedure TTCPfiscal.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones > 0 then Dec(conexiones);
  if conexiones = 0 then Begin
    datosdb.closeDB(tpfis);
    datosdb.closeDB(compr);
  end;
end;

{===============================================================================}

function tcpfiscal: TTCpfiscal;
begin
  if xtcpfiscal = nil then
    xtcpfiscal := TTCPfiscal.Create;
  Result := xtcpfiscal;
end;

{===============================================================================}

initialization

finalization
  xtcpfiscal.Free;

end.
