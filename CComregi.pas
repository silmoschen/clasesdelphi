unit CComregi;

interface

uses SysUtils, DB, DBTables, CBDT, CComprob, CIDBFM, CUtiles;

type

TTCompregis = class(TTComprob)            // Superclase
  codcomp, idcompr, DC, AC, AV, LN, CTA, CTB, CTC, Otros, Codmov_vtas, Codmov_com, Factura_vtas, Factura_com, ControlaStock, CodNum: string;
  tabla1: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  procedure   Grabar(xcodcomp, xidcompr, xDescrip, xDC, xAC, xAV, xLN, xCTA, xCTB, xCTC, xOtros: string); overload;
  procedure   Grabar(xcodcomp, xidcompr, xDescrip, xDC, xAC, xAV, xLN, xCTA, xCTB, xCTC, xOtros, xcodmov_vtas, xcodmov_com, xfactura_vtas, xfactura_com: string); overload;
  procedure   Grabar(xcodcomp, xidcompr, xDescrip, xDC, xAC, xAV, xLN, xCTA, xCTB, xCTC, xOtros, xcodmov_vtas, xcodmov_com, xfactura_vtas, xfactura_com, xcontrolastock: string); overload;
  procedure   Borrar(xcodcomp, xidcompr: string); overload;
  function    Buscar(xcodcomp, xidcompr: string): boolean; overload;
  procedure   getDatos(xcodcomp, xidcompr: string); overload;
  procedure   getDatosMov(xcodcomp, xidcompr: string);
  procedure   getDatosCodNumeracion(xcodigo: string);
  function    VerifComprobante(xidcompr: string): boolean;
  function    getSetComprobantes(tipo: string): TQuery;
  function    setComprobantesCompras: TQuery;
  function    setComprobantesVentas: TQuery;
  function    setComprobantesFacturacionVentas: TQuery;
  function    setComprobantesFacturacionCompras: TQuery;
  procedure   EstablecerCodigoNumeracion(xcodcomp, xidcompr, xcodnum: String);
  procedure   SeleccionarComprobante(xcodmov: String; xcompra_venta: ShortInt);
   
  procedure   conectar;
  procedure   desconectar;
 private
  conexiones: shortint;
  { Declaraciones Privadas }
end;

function compregis: TTCompregis;

implementation

var
  xcompregis: TTCompregis = nil;

constructor TTCompregis.Create;
begin
  inherited Create;
  tabla1 := datosdb.openDB('comregis', 'Codcomp;Idcompr');
end;

destructor TTCompregis.Destroy;
begin
  inherited Destroy;
end;

procedure TTCompregis.Grabar(xcodcomp, xidcompr, xDescrip, xDC, xAC, xAV, xLN, xCTA, xCTB, xCTC, xOtros: string);
// Objetivo...: Grabar Atributos del Objeto
begin
  if Buscar(xcodcomp, xidcompr) then tabla1.Edit else tabla1.Append;
  tabla1.FieldByName('codcomp').AsString := xcodcomp;
  tabla1.FieldByName('idcompr').AsString := xidcompr;
  tabla1.FieldByName('DC').AsString      := xDC;
  tabla1.FieldByName('AC').AsString      := xAC;
  tabla1.FieldByName('AV').AsString      := xAV;
  tabla1.FieldByName('LN').AsString      := xLN;
  tabla1.FieldByName('CTA').AsString     := xCTA;
  tabla1.FieldByName('CTB').AsString     := xCTB;
  tabla1.FieldByName('CTC').AsString     := xCTC;
  tabla1.FieldByName('Otros').AsString   := xOtros;
  try
    tabla1.Post;
  except
    tabla1.Cancel;
  end;
end;

procedure TTCompregis.Grabar(xcodcomp, xidcompr, xDescrip, xDC, xAC, xAV, xLN, xCTA, xCTB, xCTC, xOtros, xcodmov_vtas, xcodmov_com, xfactura_vtas, xfactura_com, xcontrolastock: string);
// Objetivo...: Grabar Atributos del Objeto
Begin
  Grabar(xcodcomp, xidcompr, xDescrip, xDC, xAC, xAV, xLN, xCTA, xCTB, xCTC, xOtros, xcodmov_vtas, xcodmov_com, xfactura_vtas, xfactura_com);
  Buscar(xcodcomp, xidcompr);
  tabla1.Edit;
  tabla1.FieldByName('controlastock').AsString  := xcontrolastock;
  try
    tabla1.Post;
  except
    tabla1.Cancel;
  end;
  datosdb.refrescar(tabla1);
end;

procedure TTCompregis.Grabar(xcodcomp, xidcompr, xDescrip, xDC, xAC, xAV, xLN, xCTA, xCTB, xCTC, xOtros, xcodmov_vtas, xcodmov_com, xfactura_vtas, xfactura_com: string);
// Objetivo...: Grabar Atributos del Objeto
begin
  Grabar(xcodcomp, xidcompr, xDescrip, xDC, xAC, xAV, xLN, xCTA, xCTB, xCTC, xOtros);
  Buscar(xcodcomp, xidcompr);
  tabla1.Edit;
  tabla1.FieldByName('codmov_vtas').AsString  := xcodmov_vtas;
  tabla1.FieldByName('codmov_com').AsString   := xcodmov_com;
  tabla1.FieldByName('factura_vtas').AsString := xfactura_vtas;
  tabla1.FieldByName('factura_com').AsString  := xfactura_com;
  try
    tabla1.Post
  except
    tabla1.Cancel
  end;
end;

procedure TTCompregis.Borrar(xcodcomp, xidcompr: string);
// Objetivo...: Eliminar un Objeto
begin
  if Buscar(xcodcomp, xidcompr) then Begin
    tabla1.Delete;
    getDatos(tabla1.FieldByName('codcomp').AsString, tabla1.FieldByName('idcompr').AsString);  // Fijamos los Atributos Siguientes al Objeto Borrado
  end;
end;

function TTCompregis.Buscar(xcodcomp, xidcompr: string): boolean;
// Objetivo...: Buscar el Objeto solicitado
begin
  if conexiones = 0 then conectar; tabla1.Refresh;
  Result := datosdb.Buscar(tabla1, 'codcomp', 'idcompr', xcodcomp, xidcompr);
end;

procedure  TTCompregis.getDatos(xcodcomp, xidcompr: string);
// Objetivo...: Retornar/Iniciar Atributos
begin
  if Buscar(xcodcomp, xidcompr) then Begin
    codcomp := xcodcomp;
    idcompr := xidcompr;
    dc      := tabla1.FieldByName('DC').AsString;
    ac      := tabla1.FieldByName('AC').AsString;
    av      := tabla1.FieldByName('AV').AsString;
    ln      := tabla1.FieldByName('LN').AsString;
    cta     := tabla1.FieldByName('CTA').AsString;
    ctb     := tabla1.FieldByName('CTB').AsString;
    ctc     := tabla1.FieldByName('CTC').AsString;
    otros   := tabla1.FieldByName('Otros').AsString;
    if datosdb.verificarSiExisteCampo(tabla1, 'codNum') then codNum := tabla1.FieldByName('codNum').AsString;
    if datosdb.verificarSiExisteCampo(tabla1, 'controlastock') then controlastock := tabla1.FieldByName('controlastock').AsString;
  end else Begin
    dc := ''; ac := ''; av := ''; ln := ''; cta := ''; ctb := ''; ctc := ''; otros := ''; ControlaStock := 'N'; codnum := '';
  end;
  inherited getDatos(xidcompr);
end;

procedure  TTCompregis.getDatosMov(xcodcomp, xidcompr: string);
// Objetivo...: Retornar/Iniciar Atributos
begin
  //utiles.msgError(xcodcomp);
  if Buscar(xcodcomp, xidcompr) then Begin
    getDatos(xcodcomp, xidcompr);
    codmov_vtas  := tabla1.FieldByName('codmov_vtas').AsString;
    codmov_com   := tabla1.FieldByName('codmov_com').AsString;
    factura_vtas := tabla1.FieldByName('factura_vtas').AsString;
    factura_com  := tabla1.FieldByName('factura_com').AsString;
  end else Begin
    codmov_vtas := ''; codmov_com := ''; factura_vtas := ''; factura_com := '';
  end;
  inherited getDatos(xidcompr);
end;

procedure TTCompregis.getDatosCodNumeracion(xcodigo: string);
// Objetivo...: Cargar la Instancia de un comprobante por su código de numeración
Begin
  tabla1.First;
  while not tabla1.Eof do Begin
    if tabla1.FieldByName('codnum').AsString = xcodigo then Begin
      getDatosMov(tabla1.FieldByName('codcomp').AsString, tabla1.FieldByName('idcompr').AsString);
      Break;
    end;
    tabla1.Next;
  end;
end;

function TTCompregis.VerifComprobante(xidcompr: string): boolean;
// Objetivo...: Verificar que exista el comprobante base
begin
  if not inherited Buscar(xidcompr) then Result := False else Result := True;
end;

function  TTCompregis.getSetComprobantes(tipo: string): TQuery;
// Objetivo...: Devolver un Set de Comprobantes (Debito o Crédito);
var
  r: TQuery;
begin
  if Length(trim(tipo)) > 0 then r := datosdb.tranSQL('SELECT comregis.codcomp, comregis.idcompr, tcomprob.descrip, comregis.DC FROM comregis, tcomprob WHERE comregis.idcompr = tcomprob.idcompr AND comregis.DC = ' + '''' + tipo + '''')
   else r := datosdb.tranSQL('SELECT comregis.codcomp, comregis.idcompr, tcomprob.descrip, comregis.DC, comregis.AC, comregis.AV FROM comregis, tcomprob WHERE comregis.idcompr = tcomprob.idcompr');
  r.Open;
  r.FieldByName('idcompr').DisplayLabel := 'IDC'; r.FieldByName('codcomp').DisplayLabel := 'TC'; r.FieldByName('descrip').DisplayLabel := 'Descripción';
  Result := r;
  r.Close;
end;

function TTCompregis.setComprobantesCompras: TQuery;
// Objetivo...: Retornar un set con los comoprobantes de compras
begin
  Result := datosdb.tranSQL('SELECT comregis.codcomp, comregis.idcompr, tcomprob.descrip, comregis.DC FROM comregis, tcomprob WHERE comregis.idcompr = tcomprob.idcompr AND ac = ' + '"' + 'S' + '"');
end;

function TTCompregis.setComprobantesVentas: TQuery;
// Objetivo...: Retornar un set con los comoprobantes de compras
begin
  //Result := datosdb.tranSQL('SELECT * FROM comregis WHERE av = ' + '"' + 'S' + '"');
  Result := datosdb.tranSQL('SELECT comregis.codcomp, comregis.idcompr, tcomprob.descrip, comregis.DC FROM comregis, tcomprob WHERE comregis.idcompr = tcomprob.idcompr AND av = ' + '"' + 'S' + '"');
end;

function TTCompregis.setComprobantesFacturacionVentas: TQuery;
Begin
  Result := datosdb.tranSQL('SELECT comregis.codcomp, comregis.idcompr, tcomprob.descrip, comregis.DC, comregis.Codnum FROM comregis, tcomprob WHERE comregis.idcompr = tcomprob.idcompr AND factura_vtas = ' + '"' + 'S' + '"' + ' ORDER BY codcomp');
end;

function TTCompregis.setComprobantesFacturacionCompras: TQuery;
Begin
  Result := datosdb.tranSQL('SELECT comregis.codcomp, comregis.idcompr, tcomprob.descrip, comregis.DC FROM comregis, tcomprob WHERE comregis.idcompr = tcomprob.idcompr AND factura_com = ' + '"' + 'S' + '"');
end;

procedure TTCompregis.EstablecerCodigoNumeracion(xcodcomp, xidcompr, xcodnum: String);
// Objetivo...: Establecer código de numeración
Begin
  if Buscar(xcodcomp, xidcompr) then Begin
    tabla1.Edit;
    tabla1.FieldByName('codnum').AsString := xcodnum;
    try
      tabla1.Post
     except
      tabla1.Cancel
    end;
  end;
end;

procedure  TTCompregis.SeleccionarComprobante(xcodmov: String; xcompra_venta: ShortInt);
// Objetivo...: Abrir tablas de persistencia
begin
  tabla1.First;
  while not tabla1.Eof do Begin
    if xcompra_venta = 1 then
      if tabla1.FieldByName('codmov_com').AsString = xcodmov then getDatos(tabla1.FieldByName('codcomp').AsString, tabla1.FieldByName('idcompr').AsString);
    if xcompra_venta = 2 then
      if tabla1.FieldByName('codmov_vtas').AsString = xcodmov then getDatos(tabla1.FieldByName('codcomp').AsString, tabla1.FieldByName('idcompr').AsString);
    tabla1.Next;
  end;
end;

procedure TTCompregis.conectar;
// Objetivo...: Abrir tablas de persistencia
begin
  inherited conectar;
  if conexiones = 0 then Begin
    if not tabla1.Active then tabla1.Open;
    tabla1.FieldByName('cta').Visible := False; tabla1.FieldByName('ctb').Visible := False; tabla1.FieldByName('ctc').Visible := False; tabla1.FieldByName('otros').Visible := False;
    tabla1.FieldByName('codcomp').DisplayLabel := 'Tipo'; tabla1.FieldByName('idcompr').DisplayLabel := 'ID Comprobante';
  end;
  Inc(conexiones);
end;

procedure TTCompregis.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  inherited desconectar;
  if conexiones > 0 then Dec(conexiones);
  if conexiones = 0 then datosdb.closeDB(tabla1);
end;

{===============================================================================}

function compregis: TTCompregis;
begin
  if xcompregis = nil then
    xcompregis := TTCompregis.Create;
  Result := xcompregis;
end;

{===============================================================================}

initialization

finalization
  xcompregis.Free;

end.
