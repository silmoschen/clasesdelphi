unit CCIvaCCE;

interface

uses CBDT, SysUtils, DBTables, CUtiles, CListar, CIDBFM, CCNetos, CTablaiva, Contnrs;

type

TTIVACCE = class
  Idc, Tipo, Sucursal, Numero, Entidad, Nombre, CUIT, Codpfis, Fecha, Fecharecep, Codmov, Tipomov, Concepto, Codprovin, Condicion: String;
  Neto, Connograv, Exentas, Tasaiva, Tasaivani, Ivari, Ivarni, Impuestos, Percepcion, Sobretasa,
  Otrosimp, Impuestosint, Comprasni, Comprasmono, Total, Retencion, MontoIva, MontoIvaRec: Real;
  empresaRsocial, empresaRsocial2, empresaCuit, empresaDireccion, discriminaIVA: String;
  ImprModoTexto, Lineas, Margen, lineassep: Integer;
  tipolist: char;
  InfResumido: Boolean;
  tabla: TTable;
 public
  { Declaraciones P�blicas }
  constructor Create;
  destructor  Destroy; override;

  function    Buscar(xidc, xtipo, xsucursal, xnumero, xentidad: String): Boolean;
  procedure   Registrar(xidc, xtipo, xsucursal, xnumero, xentidad, xnombre, xCUIT, xcodpfis, xfecha, xfecharecep, xcodmov, xtipomov, xconcepto, xcodprovin, xcondicion: String;
                        xneto, xconnograv, xexentas, xtasaiva, xtasaivani, xivari, xivarni, ximpuestos, xpercepcion, xsobretasa,
                        xotrosimp, ximpuestosint, xcomprasni, xcomprasmono, xtotal, xretencion: Real);
  procedure   Borrar(xidc, xtipo, xsucursal, xnumero, xentidad: String);
  procedure   getDatos(xidc, xtipo, xsucursal, xnumero, xentidad: String); overload;
  procedure   getDatos; overload;

  procedure   AnularComprobante(xidc, xtipo, xsucursal, xnumero, xentidad: String);
  procedure   ReactivarComprobante(xidc, xtipo, xsucursal, xnumero, xentidad: String);

  function    CalcularIva(xmonto: Real; xcodmov: String): Real;

  procedure   getDatosEncabezadoInformes;
  function    setNumeroDePagina: Integer;
  procedure   GuardarNroPagina; overload;
  procedure   GuardarNroPagina(xnumero: Integer); overload;
  procedure   PresentarInforme;
  procedure   EstablecerDatosEncabezazoInformes(xrsocial, xcuit, xdireccion, xdiscr_iva: String; xmodotexto, xmargen, xlineas: Integer); overload;
  procedure   EstablecerDatosEncabezazoInformes(xrsocial, xcuit, xdireccion, xdiscr_iva: String; xmodotexto, xmargen, xlineas, xseparacion: Integer); overload;

  function    setTransaccionesFecha(xfecha: String): TObjectList;
  function    setTransaccionesEntidad(xentidad: String): TObjectList;

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
 protected
  { Declaraciones Protegidas }
  archivo: TextFile;
  conexiones: shortint;
  pag, espacios, UltimoNroPagina: Integer;
  inf_iniciado, iva_existe: Boolean;
  totNettot, totOpexenta, totConnograv, totIva, totIvarec, totPercepcion, totPergan, totTotOper, totCdfiscal, totRetencion, totImpuestosint,
  totOtrosImp, totComprasni, totComprasmono, totSobretasa: Real;
  xmes, modulo: String;
  procedure   CargarInstancia;
  procedure   IniciarInstancia;
  procedure   RegisInst(xidc, xtipo, xsucursal, xnumero, xentidad, xnombre, xCUIT, xcodpfis, xfecha, xfecharecep, xcodmov, xtipomov, xconcepto, xcodprovin, xcondicion: String;
                        xneto, xconnograv, xexentas, xtasaiva, xtasaivani, xivari, xivarni, ximpuestos, xpercepcion, xsobretasa,
                        xotrosimp, ximpuestosint, xcomprasni, xcomprasmono, xtotal, xretencion: Real);
  procedure   CambiarEstadoComprobante(xidc, xtipo, xsucursal, xnumero, xentidad, xestado: String);
  procedure   ListDatosEmpresa(salida: char);
  procedure   IniciarListado;
  procedure   IniciarInforme(salida: char);
end;

implementation

constructor TTIVACCE.Create;
begin
end;

destructor TTIVACCE.Destroy;
begin
  inherited Destroy;
end;

function  TTIVACCE.Buscar(xidc, xtipo, xsucursal, xnumero, xentidad: String): Boolean;
// Objetivo...: Buscar una Instancia
begin
  if tabla.IndexFieldNames <> 'idc;tipo;sucursal;numero;entidad' then tabla.IndexFieldNames := 'idc;tipo;sucursal;numero;entidad';
  Result := datosdb.Buscar(tabla, 'idc', 'tipo', 'sucursal', 'numero', 'entidad', xidc, xtipo, xsucursal, xnumero, xentidad);
end;

procedure TTIVACCE.Registrar(xidc, xtipo, xsucursal, xnumero, xentidad, xnombre, xCUIT, xcodpfis, xfecha, xfecharecep, xcodmov, xtipomov, xconcepto, xcodprovin, xcondicion: String;
                        xneto, xconnograv, xexentas, xtasaiva, xtasaivani, xivari, xivarni, ximpuestos, xpercepcion, xsobretasa,
                        xotrosimp, ximpuestosint, xcomprasni, xcomprasmono, xtotal, xretencion: Real);
// Objetivo...: Registrar una Instancia
begin
  if Buscar(xidc, xtipo, xsucursal, xnumero, xentidad) then tabla.Edit else tabla.Append;
  RegisInst(xidc, xtipo, xsucursal, xnumero, xentidad, xnombre, xCUIT, xcodpfis, xfecha, xfecharecep, xcodmov, xtipomov, xconcepto, xcodprovin, xcondicion,
            xneto, xconnograv, xexentas, xtasaiva, xtasaivani, xivari, xivarni, ximpuestos, xpercepcion, xsobretasa,
            xotrosimp, ximpuestosint, xcomprasni, xcomprasmono, xtotal, xretencion);
end;

procedure TTIVACCE.Borrar(xidc, xtipo, xsucursal, xnumero, xentidad: String);
// Objetivo...: Borrar una Instancia
begin
  if Buscar(xidc, xtipo, xsucursal, xnumero, xentidad) then Begin
    tabla.Delete;
    datosdb.closeDB(tabla); tabla.Open;
  end;
end;

procedure TTIVACCE.getDatos(xidc, xtipo, xsucursal, xnumero, xentidad: String);
// Objetivo...: Recuperar una Instancia
begin
  if Buscar(xidc, xtipo, xsucursal, xnumero, xentidad) then CargarInstancia else IniciarInstancia;
end;

procedure TTIVACCE.getDatos;
// Objetivo...: Recuperar una Instancia
begin
  CargarInstancia;
end;


procedure TTIVACCE.RegisInst(xidc, xtipo, xsucursal, xnumero, xentidad, xnombre, xCUIT, xcodpfis, xfecha, xfecharecep, xcodmov, xtipomov, xconcepto, xcodprovin, xcondicion: String;
                             xneto, xconnograv, xexentas, xtasaiva, xtasaivani, xivari, xivarni, ximpuestos, xpercepcion, xsobretasa,
                             xotrosimp, ximpuestosint, xcomprasni, xcomprasmono, xtotal, xretencion: Real);
// Objetivo...: Persistir una Instancia
begin
  tabla.FieldByName('idc').AsString         := xidc;
  tabla.FieldByName('tipo').AsString        := xtipo;
  tabla.FieldByName('sucursal').AsString    := xsucursal;
  tabla.FieldByName('numero').AsString      := xnumero;
  tabla.FieldByName('entidad').AsString     := xentidad;
  tabla.FieldByName('nombre').AsString      := xnombre;
  tabla.FieldByName('cuit').AsString        := xcuit;
  tabla.FieldByName('codpfis').AsString     := xcodpfis;
  tabla.FieldByName('fecha').AsString       := utiles.sExprFecha2000(xfecha);
  tabla.FieldByName('fecharecep').AsString  := utiles.sExprFecha2000(xfecharecep);
  tabla.FieldByName('codmov').AsString      := xcodmov;
  tabla.FieldByName('tipomov').AsString     := xtipomov;
  tabla.FieldByName('concepto').AsString    := xconcepto;
  tabla.FieldByName('codprovin').AsString   := xcodprovin;
  tabla.FieldByName('condicion').AsString   := xcondicion;
  tabla.FieldByName('neto').AsFloat         := xneto;
  tabla.FieldByName('connograv').AsFloat    := xconnograv;
  tabla.FieldByName('exentas').AsFloat      := xexentas;
  tabla.FieldByName('tasaiva').AsFloat      := xtasaiva;
  tabla.FieldByName('tasaivani').AsFloat    := xtasaivani;
  tabla.FieldByName('ivari').AsFloat        := xivari;
  tabla.FieldByName('ivarni').AsFloat       := xivarni;
  tabla.FieldByName('impuestos').AsFloat    := ximpuestos;
  tabla.FieldByName('percepcion').AsFloat   := xpercepcion;
  tabla.FieldByName('sobretasa').AsFloat    := xsobretasa;
  tabla.FieldByName('otrosimp').AsFloat     := xotrosimp;
  tabla.FieldByName('impuestosint').AsFloat := ximpuestosint;
  tabla.FieldByName('comprasni').AsFloat    := xcomprasni;
  tabla.FieldByName('comprasmono').AsFloat  := xcomprasmono;
  tabla.FieldByName('total').AsFloat        := xtotal;
  tabla.FieldByName('retencion').AsFloat    := xretencion;
  try
    tabla.Post
   except
    tabla.Cancel
  end;
  datosdb.closeDB(tabla); tabla.Open;
end;

//------------------------------------------------------------------------------

procedure TTIVACCE.CargarInstancia;
// Objetivo...: Cargar Atributos de una Instancia
begin
  idc          := tabla.FieldByName('idc').AsString;
  tipo         :=  tabla.FieldByName('tipo').AsString;
  sucursal     := tabla.FieldByName('sucursal').AsString;
  numero       := tabla.FieldByName('numero').AsString;
  entidad      := tabla.FieldByName('entidad').AsString;
  nombre       := tabla.FieldByName('nombre').AsString;
  cuit         := tabla.FieldByName('cuit').AsString;
  codpfis      := tabla.FieldByName('codpfis').AsString;
  fecha        := utiles.sFormatofecha(tabla.FieldByName('fecha').AsString);
  fecharecep   := utiles.sFormatoFecha(tabla.FieldByName('fecharecep').AsString);
  codmov       := tabla.FieldByName('codmov').AsString;
  tipomov      := tabla.FieldByName('tipomov').AsString;
  concepto     := tabla.FieldByName('concepto').AsString;
  codprovin    := tabla.FieldByName('codprovin').AsString;
  condicion    := tabla.FieldByName('condicion').AsString;
  neto         := tabla.FieldByName('neto').AsFloat;
  connograv    := tabla.FieldByName('connograv').AsFloat;
  exentas      := tabla.FieldByName('exentas').AsFloat;
  tasaiva      := tabla.FieldByName('tasaiva').AsFloat;
  tasaivani    := tabla.FieldByName('tasaivani').AsFloat;
  ivari        := tabla.FieldByName('ivari').AsFloat;
  ivarni       := tabla.FieldByName('ivarni').AsFloat;
  impuestos    := tabla.FieldByName('impuestos').AsFloat;
  percepcion   := tabla.FieldByName('percepcion').AsFloat;
  sobretasa    := tabla.FieldByName('sobretasa').AsFloat;
  otrosimp     := tabla.FieldByName('otrosimp').AsFloat;
  impuestosint := tabla.FieldByName('impuestosint').AsFloat;
  comprasni    := tabla.FieldByName('comprasni').AsFloat;
  comprasmono  := tabla.FieldByName('comprasmono').AsFloat;
  total        := tabla.FieldByName('total').AsFloat;
  retencion    := tabla.FieldByName('retencion').AsFloat;
end;

procedure TTIVACCE.IniciarInstancia;
// Objetivo...: Iniciar Atributos de una Instancia
begin
  idc          := '';
  tipo         := '';
  sucursal     := '';
  numero       := '';
  entidad      := '';
  nombre       := '';
  cuit         := '';
  codpfis      := '';
  fecha        := '';
  fecharecep   := '';
  codmov       := '';
  tipomov      := '';
  concepto     := '';
  codprovin    := '';
  condicion    := '';
  neto         := 0;
  connograv    := 0;
  exentas      := 0;
  tasaiva      := 0;
  tasaivani    := 0;
  ivari        := 0;
  ivarni       := 0;
  impuestos    := 0;
  percepcion   := 0;
  sobretasa    := 0;
  otrosimp     := 0;
  impuestosint := 0;
  comprasni    := 0;
  comprasmono  := 0;
  total        := 0;
  retencion    := 0;
end;

procedure TTIVACCE.CambiarEstadoComprobante(xidc, xtipo, xsucursal, xnumero, xentidad, xestado: String);
// Objetivo...: Modificar Estado Comprobante
begin
  if Buscar(xidc, xtipo, xsucursal, xnumero, xentidad) then Begin
    tabla.Edit;
    tabla.FieldByName('anulado').AsString := xestado;
    try
      tabla.Post
     except
      tabla.Cancel
    end;
    datosdb.closeDB(tabla); tabla.Open;
  end;
end;

procedure TTIVACCE.ListDatosEmpresa(salida: char);
// Objetivo...: Listar el encabezado de P�gina con los datos de la empresa
begin
  list.NoImprimirPieDePagina;
  Inc(pag);
  if (salida = 'P') or (salida = 'I') then Begin
    list.Titulo(0, 0, ' ', 1, 'Arial, negrita, 10');
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 8'); list.Titulo(espacios, list.Lineactual, empresaRsocial, 2, 'Arial, normal, 8');
    if empresaRsocial2 <> '' then Begin
      list.Titulo(0, 0, ' ', 1, 'Arial, normal, 7');
      list.Titulo(espacios, list.Lineactual, empresaRsocial2, 2, 'Arial, normal, 7');
    end;
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 7'); list.Titulo(espacios, list.Lineactual, empresaCuit, 2, 'Arial, normal, 7');
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 7'); list.Titulo(espacios, list.Lineactual, empresaDireccion, 2, 'Arial, normal, 7');
    list.Titulo(95, list.Lineactual, 'Hoja N�: #pagina', 3, 'Arial, normal, 7');
    list.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');
  end;
end;

procedure TTIVACCE.IniciarListado;
// Objetivo...: Inicializar los atributos a utilizar en los informes
begin
  list.altopag := 0; list.m := 0; pag := 0;
  inf_iniciado := True;
end;

procedure TTIVACCE.IniciarInforme(salida: char);
// Objetivo...: Desencadenar una secuencia de eventos para la Preparaci�n de Informes
begin
  IniciarListado;          // Emisi�n M�ltiple
  list.Setear(salida);     // Iniciar Listado
  list.FijarSaltoManual;   // Controlamos el Salto de la P�gina
  if salida = 'T' then list.IniciarImpresionModoTexto;
  if (salida = 'P') or (salida = 'I') then list.ImprimirHorizontal;
end;

procedure TTIVACCE.PresentarInforme;
begin
  //utiles.msgError(list.tipolist);
  if list.tipolist <> 'X' then list.CompletarPagina;
  if (list.tipolist = 'P') or (list.tipolist = 'I') then list.FinList;
  if list.tipolist = 'T' then list.FinalizarImpresionModoTexto(1);
  inf_iniciado := False; iva_existe := False;
  if list.tipolist = 'I' then list.ImprimirVetical;
end;

procedure TTIVACCE.getDatosEncabezadoInformes;
// Objetivo...: Recuperar Datos de la Empresa
Begin
  if FileExists(dbs.DirSistema + '\encLibros.ini') then Begin
    AssignFile(archivo, dbs.DirSistema + '\encLibros.ini');
    reset(archivo);
    ReadLn(archivo, empresaRsocial);
    ReadLn(archivo, empresaCuit);
    ReadLn(archivo, empresaDireccion);
    ReadLn(archivo, Lineas);
    ReadLn(archivo, Margen);
    ReadLn(archivo, ImprModoTexto);
    ReadLn(archivo, discriminaIVA);
    closeFile(archivo);
    if Length(Trim(empresaCuit)) < 13 then empresaCuit := '';
  end;
end;

function TTIVACCE.setNumeroDePagina: Integer;
// Objetivo...: Guardar el ultimo Nro. de P�gina
var
  a: String;
Begin
  UltimoNroPagina := 0;
  if modulo = 'C' then a := dbs.DirSistema + '\upc.ini' else a := dbs.DirSistema + '\upv.ini';
  if FileExists(a) then Begin
    AssignFile(archivo, a);
    reset(archivo);
    ReadLn(archivo, UltimoNroPagina);
    closeFile(archivo);
  end;
  Result := UltimoNroPagina;
end;

procedure TTIVACCE.GuardarNroPagina;
// objetivo...: Guardar el ultimo Nro. de P�gina
Begin
  if modulo = 'C' then AssignFile(archivo, dbs.DirSistema + '\upc.ini') else AssignFile(archivo, dbs.DirSistema + '\upv.ini');
  rewrite(archivo);
  WriteLn(archivo, UltimoNroPagina);
  closeFile(archivo);
end;

procedure TTIVACCE.GuardarNroPagina(xnumero: Integer);
// objetivo...: Guardar el ultimo Nro. de P�gina
Begin
  if modulo = 'C' then AssignFile(archivo, dbs.DirSistema + '\upc.ini') else AssignFile(archivo, dbs.DirSistema + '\upv.ini');
  rewrite(archivo);
  WriteLn(archivo, xnumero);
  closeFile(archivo);
end;

//------------------------------------------------------------------------------

procedure TTIVACCE.AnularComprobante(xidc, xtipo, xsucursal, xnumero, xentidad: String);
// Objetivo...: Anular Comprobante
begin
  CambiarEstadoComprobante(xidc, xtipo, xsucursal, xnumero, xentidad, 'A');
end;

procedure TTIVACCE.ReactivarComprobante(xidc, xtipo, xsucursal, xnumero, xentidad: String);
// Objetivo...: Reactivar Comprobante
begin
  CambiarEstadoComprobante(xidc, xtipo, xsucursal, xnumero, xentidad, '');
end;

function  TTIVACCE.CalcularIva(xmonto: Real; xcodmov: String): Real;
// Objetivo...: Calcular I.V.A.
Begin
  netos.getDatos(xcodmov);
  tabliva.getDatos(netos.codiva);
  if tabliva.coeinverso = 0 then Begin
    neto := xmonto;
    if tabliva.ivari > 0 then MontoIva     := xmonto * (tabliva.ivari * 0.01);
    if tabliva.ivarni > 0 then MontoIvaRec := xmonto * (tabliva.ivarni * 0.01);
  end else begin
    neto := xmonto / tabliva.coeinverso;
    if tabliva.ivari > 0 then MontoIva     := neto * (tabliva.ivari * 0.01);
    if tabliva.ivarni > 0 then MontoIvaRec := neto * (tabliva.ivarni * 0.01);
  end;
  if netos.tipoingreso = 1 then Begin   // Operaciones Exentas
    MontoIva    := 0;
    MontoIvaRec := 0;
  end;
end;

procedure TTIVACCE.EstablecerDatosEncabezazoInformes(xrsocial, xcuit, xdireccion, xdiscr_iva: String; xmodotexto, xmargen, xlineas: Integer);
// Objetivo...: Para Empresas Indivduales, Datos de la configuraci�n de informes
Begin
  AssignFile(archivo, dbs.DirSistema + '\encLibros.ini');
  rewrite(archivo);
  WriteLn(archivo, xrsocial);
  WriteLn(archivo, xcuit);
  WriteLn(archivo, xdireccion);
  WriteLn(archivo, xmargen);
  WriteLn(archivo, xlineas);
  WriteLn(archivo, xmodotexto);
  WriteLn(archivo, xdiscr_iva);
  closeFile(archivo);
  empresaRsocial   := xrsocial;
  empresaCuit      := xcuit;
  empresaDireccion := xdireccion;
  Lineas           := xlineas;
  Margen           := xmargen;
  ImprModoTexto    := xmodotexto;
end;

procedure TTIVACCE.EstablecerDatosEncabezazoInformes(xrsocial, xcuit, xdireccion, xdiscr_iva: String; xmodotexto, xmargen, xlineas, xseparacion: Integer);
// Objetivo...: Para Empresas Indivduales, Datos de la configuraci�n de informes
Begin
  AssignFile(archivo, dbs.DirSistema + '\encLibros.ini');
  rewrite(archivo);
  WriteLn(archivo, xrsocial);
  WriteLn(archivo, xcuit);
  WriteLn(archivo, xdireccion);
  WriteLn(archivo, xmargen);
  WriteLn(archivo, xlineas);
  WriteLn(archivo, xmodotexto);
  WriteLn(archivo, xdiscr_iva);
  WriteLn(archivo, xseparacion);
  closeFile(archivo);
  empresaRsocial   := xrsocial;
  empresaCuit      := xcuit;
  empresaDireccion := xdireccion;
  Lineas           := xlineas;
  Margen           := xmargen;
  ImprModoTexto    := xmodotexto;
  lineassep        := xseparacion;
end;

function TTIVACCE.setTransaccionesFecha(xfecha: String): TObjectList;
var
  l: TObjectList;
  objeto: TTIVACCE;
Begin
  l := TObjectList.Create;
  datosdb.Filtrar(tabla, 'fecha = ' + '''' + utiles.sExprFecha2000(xfecha) + '''');
  tabla.First;
  while not tabla.Eof do Begin
    objeto := TTIVACCE.Create;
    objeto.Idc         := tabla.FieldByName('idc').AsString;
    objeto.Tipo        := tabla.FieldByName('tipo').AsString;
    objeto.Sucursal    := tabla.FieldByName('sucursal').AsString;
    objeto.Numero      := tabla.FieldByName('numero').AsString;
    objeto.Fecha       := utiles.sFormatoFecha(tabla.FieldByName('fecha').AsString);
    objeto.Entidad     := tabla.FieldByName('entidad').AsString;
    l.Add(objeto);
    tabla.Next;
  end;
  datosdb.QuitarFiltro(tabla);
  Result := l;
end;

function TTIVACCE.setTransaccionesEntidad(xentidad: String): TObjectList;
var
  l: TObjectList;
  objeto: TTIVACCE;
Begin
  l := TObjectList.Create;
  datosdb.Filtrar(tabla, 'entidad = ' + '''' + xentidad + '''');
  tabla.First;
  while not tabla.Eof do Begin
    objeto := TTIVACCE.Create;
    objeto.Idc         := tabla.FieldByName('idc').AsString;
    objeto.Tipo        := tabla.FieldByName('tipo').AsString;
    objeto.Sucursal    := tabla.FieldByName('sucursal').AsString;
    objeto.Numero      := tabla.FieldByName('numero').AsString;
    objeto.Fecha       := utiles.sFormatoFecha(tabla.FieldByName('fecha').AsString);
    objeto.Entidad     := tabla.FieldByName('entidad').AsString;
    l.Add(objeto);
    tabla.Next;
  end;
  datosdb.QuitarFiltro(tabla);
  Result := l;
end;

procedure TTIVACCE.conectar;
// Objetivo...: cerrar tablas de persistencia
begin
  netos.conectar;
  tabliva.conectar;
  if conexiones = 0 then Begin
    if not tabla.Active then tabla.Open;
  end;
  Inc(conexiones);
end;

procedure TTIVACCE.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  netos.desconectar;
  tabliva.desconectar;
  Dec(conexiones);
  if conexiones = 0 then Begin
    datosdb.closeDB(tabla);
  end;
end;

end.
