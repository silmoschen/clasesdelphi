unit CEmpresas;

interface

uses CPersona, CVias, SysUtils, CDefViasIva, CListar, DB, DBTables, cbdt, CUtiles,
     CCodPost, CIDBFM, DepurarVias, Forms, FileCtrl, CUtilidadesArchivos, Classes,
     PreparacionViaTrabajo, Unit1;

type

TTEmpresa = class(TTPersona)            // Superclase
  nomvia, rsocial2, nrocuit, depdgi, codactivi, codpfis, mescierre, suscribe, caracter, discneto, clave, seleccion, periodo: string;
  tipocont, up_livacom, up_livaven, impresora_c, impresora_v, orientpag_c, orientpag_v, catempr, verific: integer;
  tipoimpr, margenes, lineas: shortint;
  verifper, perDesde, perHasta: string;
  Reintegro: Real;
  tempre, selempr, partxt: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  procedure   verificaDiscneto(xcodemp, xdn: string);
  procedure   Grabar(xcodemp, xnomvia, xnombre, xrsocial2, xnrocuit, xdomicilio, xdepdgi, xcodactivi, xcodpfis, xmescierre, xsuscribe, xcaracter, xdiscneto, xclave, xperiodo, xcp, xorden: string; xtipocont, xcatempr, xverific: integer; xreintegro: real); overload;
  procedure   EstablecerParametros(xcodemp:string; xup_livacom, xup_livaven, ximpresora_c, ximpresora_v, xorientpag_c, xorientpag_v: integer);
  procedure   Borrar(xcodemp: string);
  function    Buscar(xcodemp: string): boolean;
  procedure   FijarPeriodoRegis(xcodemp, xperiodo: string);
  function    Nuevo: string;
  procedure   getDatos(xcodemp: string);
  procedure   Depurar(tipo: char; xcodemp, xdir: string);
  procedure   conectar;
  procedure   desconectar;
  procedure   Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
  procedure   GuardarNroPagina(xcodemp, libro: string; nro_pag: integer);
  function    setEmpresas: TQuery;
  procedure   ParametrosArchTexto(xtipoimpr, xmargenes, xlineas: integer);
  procedure   getDatosArchTexto;

  procedure   PrepararVia(xnomvia: String);

  function    getPeriodoRegis: string;
  procedure   Grabar(xcodemp, xclave, xrsocial1, xnomvia, xcuit, xcodpfis, xverifper: string); overload;
  procedure   BuscarPorCodigo(xexp: string);
  procedure   BuscarPorNombre(xexp: string);

  procedure   ExportarDatos(xcodemp, xvia: String);
  function    ImportarDatos(xdrive: String): TStringList;
  function    ProcesarDatosImportados(xcodemp: String): Boolean;
  function    CantidadEmpresas: Integer;
 private
  { Declaraciones Privadas }
  conexiones: ShortInt;
  procedure   List_Linea(salida: char);
end;

function empresa: TTEmpresa;

implementation

var
  xempresa: TTEmpresa = nil;

constructor TTEmpresa.Create;
begin
  inherited Create('', '', '', '', '');

  tperso  := datosdb.openDB('datempr', 'codemp');
  tempre  := datosdb.openDB('datemph', 'codemp');
  selempr := datosdb.openDB('selempr', '');
  partxt  := datosdb.openDB('paramtxt', '');
  getDatosArchTexto;
end;

destructor TTEmpresa.Destroy;
begin
  inherited Destroy;
end;

procedure TTEmpresa.Grabar(xcodemp, xnomvia, xnombre, xrsocial2, xnrocuit, xdomicilio, xdepdgi, xcodactivi, xcodpfis, xmescierre, xsuscribe, xcaracter, xdiscneto, xclave, xperiodo, xcp, xorden: string; xtipocont, xcatempr, xverific: integer; xreintegro: real);
// Objetivo...: Grabar Atributos del Objeto
begin
//  if tempre.recordcount > 2 then utiles.msgError('Versión Trial - No admite mas de dos empresas') else begin
  if Length(Trim(xcodemp)) > 0 then Begin
  inherited Grabar(xcodemp, xnombre, xdomicilio, xcp, xorden, xclave);
  if Buscar(xcodemp) then tempre.Edit else tempre.Append;
  tempre.FieldByName('codemp').Value    := xcodemp;
  tempre.FieldByName('nomvia').Value    := xnomvia;
  tempre.FieldByName('rsocial2').Value  := xrsocial2;
  tempre.FieldByName('nrocuit').Value   := xnrocuit;
  tempre.FieldByName('depdgi').Value    := xdepdgi;
  tempre.FieldByName('codactivi').Value := xcodactivi;
  tempre.FieldByName('codpfis').Value   := xcodpfis;
  tempre.FieldByName('nomvia').Value    := xnomvia;
  tempre.FieldByName('mescierre').Value := xmescierre;
  tempre.FieldByName('suscribe').Value  := xsuscribe;
  tempre.FieldByName('caracter').Value  := xcaracter;
  tempre.FieldByName('discneto').Value  := xdiscneto;
  tempre.FieldByName('periodo').Value   := xperiodo;
  tempre.FieldByName('tipocont').Value  := xtipocont;
  tempre.FieldByName('catempr').Value   := xcatempr;
  tempre.FieldByName('verifica').Value  := xverific;
  if datosdb.verificarSiExisteCampo(tempre, 'reintegro') then tempre.FieldByName('reintegro').Value := xreintegro;
  try
    tempre.Post
   except
    tempre.Cancel
  end;
  end;
end;

procedure TTEmpresa.EstablecerParametros(xcodemp: string; xup_livacom, xup_livaven, ximpresora_c, ximpresora_v, xorientpag_c, xorientpag_v: integer);
// Objetivo...: Establecer parámetros de configuración
begin
  if Buscar(xcodemp) then Begin
    tempre.Edit;
    tempre.FieldByName('up_livacom').AsInteger  := xup_livacom;
    tempre.FieldByName('up_livaven').AsInteger  := xup_livaven;
    tempre.FieldByName('impresora_c').AsInteger := ximpresora_c;
    tempre.FieldByName('impresora_v').AsInteger := ximpresora_v;
    tempre.FieldByName('orientpag_c').AsInteger := xorientpag_c;
    tempre.FieldByName('orientpag_v').AsInteger := xorientpag_v;
    try
      tempre.Post
    except
      tempre.Cancel
    end;
  end;
end;

procedure TTEmpresa.Borrar(xcodemp: string);
// Objetivo...: Eliminar un Objeto
begin
  if Buscar(xcodemp) then Begin
    inherited Borrar(xcodemp);
    tempre.Delete;
    getDatos(tempre.FieldByName('codemp').AsString);  // Fijamos los Atributos Siguientes al Objeto Borrado
  end;
end;

function TTEmpresa.Buscar(xcodemp: string): boolean;
// Objetivo...: Buscar el Objeto solicitado
begin
  if tperso.IndexFieldNames <> 'codemp' then tperso.IndexFieldNames := 'codemp';
  if tempre.FindKey([xcodemp]) then Begin
    inherited Buscar(xcodemp);
    Result := True;
  end else
    Result := False;
end;

procedure  TTEmpresa.getDatos(xcodemp: string);
// Objetivo...: Retornar/Iniciar Atributos
begin
  if Buscar(xcodemp) then Begin
    nomvia      := tempre.FieldByName('nomvia').AsString;
    rsocial2    := tempre.FieldByName('rsocial2').AsString;
    nrocuit     := tempre.FieldByName('nrocuit').AsString;
    depdgi      := tempre.FieldByName('depdgi').AsString;
    codactivi   := tempre.FieldByName('codactivi').AsString;
    codpfis     := tempre.FieldByName('codpfis').AsString;
    mescierre   := tempre.FieldByName('mescierre').AsString;
    suscribe    := tempre.FieldByName('suscribe').AsString;
    caracter    := tempre.FieldByName('caracter').AsString;
    discneto    := tempre.FieldByName('discneto').AsString;
    periodo     := tempre.FieldByName('periodo').AsString;
    tipocont    := tempre.FieldByName('tipocont').AsInteger;
    catempr     := tempre.FieldByName('catempr').AsInteger;
    verific     := tempre.FieldByName('verifica').AsInteger;
    clave       := tperso.FieldByName('clave').AsString;
    up_livacom  := tempre.FieldByName('up_livacom').AsInteger;
    up_livaven  := tempre.FieldByName('up_livaven').AsInteger;
    impresora_c := tempre.FieldByName('impresora_c').AsInteger;
    impresora_v := tempre.FieldByName('impresora_v').AsInteger;
    orientpag_c := tempre.FieldByName('orientpag_c').AsInteger;
    orientpag_v := tempre.FieldByName('orientpag_v').AsInteger;
    if datosdb.verificarSiExisteCampo(tempre, 'reintegro') then  Reintegro   := tempre.FieldByName('reintegro').AsFloat;
  end else Begin
    nomvia := ''; rsocial2 := ''; nrocuit := ''; depdgi := ''; codactivi := ''; depdgi := ''; mescierre := ''; suscribe := ''; caracter := ''; discneto := ''; clave := ''; periodo := ''; tipocont := 0; catempr := 0; verific := 0; up_livacom := 0; up_livaven := 0; impresora_c := 0; impresora_v := 0; orientpag_v := 0; orientpag_c := 0; codpfis := ''; Reintegro := 0;
  end;
  inherited getDatos(xcodemp);
end;

function TTEmpresa.Nuevo: string;
// Objetivo...: Generar un Nuevo Atributo Código
begin
  tempre.Last;
  if Length(Trim(tempre.FieldByName('codemp').AsString)) > 0 then  Result := IntToStr(tempre.FieldByName('codemp').AsInteger + 1) else Result := '1';
end;

procedure TTEmpresa.FijarPeriodoRegis(xcodemp, xperiodo: string);
// Objetivo...: Definir Periodo
begin
  if Buscar(xcodemp) then Begin
    tempre.Edit;
    tempre.FieldByName('periodo').AsString := xperiodo;
    try
      tempre.Post;
     except
      tempre.Cancel;
    end;
  end;
end;

procedure TTEmpresa.verificaDiscneto(xcodemp, xdn: string);
// Objetivo...: Determinamos si discrimina o no el Neto
begin
  if Buscar(xcodemp) then Begin
    tempre.Edit;
    tempre.FieldByName('discneto').AsString := xdn;
    try
      tempre.Post
     except
      tempre.Cancel
    end;
  end;
end;

procedure TTEmpresa.GuardarNroPagina(xcodemp, libro: string; nro_pag: integer);
// Objetivo...: Guardar Número de Página para el Libro correspondiente
begin
  if Buscar(xcodemp) then Begin
    tempre.Edit;
    if libro = 'ivacompras' then tempre.FieldByName('UP_LIVACOM').AsInteger := nro_pag;
    if libro = 'ivaventas'  then tempre.FieldByName('UP_LIVAVEN').AsInteger := nro_pag;
    try
      tempre.Post
     except
      tempre.Cancel
    end;
    datosdb.refrescar(tempre);
  end;
end;

function TTEmpresa.setEmpresas: TQuery;
// Objetivo...: retornar un set de empresas seleccionadas
begin
  Result := datosdb.tranSQL('SELECT * FROM datempr, datemph WHERE datempr.codemp = datemph.codemp ORDER BY rsocial1');
end;

procedure TTEmpresa.Depurar(tipo: char; xcodemp, xdir: string);
// Objetivo...: Eliminar la Información de una Empresa (Directorio)
var
  directorio, archivo: string; j, limite: integer; F: File; dd: boolean;
begin
  via.conectar; dd := False;
  directorio := dbs.DirSistema + '\' + xdir;

  if DirectoryExists(directorio) then Begin
    if tipo <> 'T' then Begin
      utilesarchivos.BorrarArchivos(directorio, '*.*');
      dd := True;
    end else
      utilesarchivos.Deltree(directorio);
  end;

  if (tipo = 'T') and (dd) then defviaiva.Borrar(xdir) else defviaiva.DesocuparVia(empresa.Nomvia);
  empresa.Borrar(xcodemp);
  selempr.First;
  if selempr.FieldByName('codemp').AsString = xcodemp then selempr.Delete;
end;

procedure TTEmpresa.List_linea(salida: char);
// Objetivo...: Listar una Línea
begin
  if cpost.Buscar(tperso.FieldByName('cp').AsString, tperso.FieldByName('orden').AsString) then cpost.getDatos(tperso.FieldByName('cp').AsString, tperso.FieldByName('orden').AsString);
  tempre.FindKey([tperso.FieldByName('codemp').AsString]);   // Sincronizamos las tablas
  List.Linea(0, 0, tperso.FieldByName('codemp').AsString + '  ' + tperso.FieldByName('rsocial1').AsString, 1, 'Arial, normal, 8', salida, 'N');
  List.Linea(40, List.lineactual, tempre.FieldByName('nrocuit').AsString, 2, 'Arial, normal, 8', salida, 'N');
  List.Linea(53, List.lineactual, tperso.Fields[2].AsString, 3, 'Arial, normal, 8', salida, 'N');
  List.Linea(85, List.lineactual,  Lowercase(tempre.FieldByName('nomvia').AsString), 4, 'Arial, normal, 8', salida, 'N');
  List.Linea(99, List.lineactual, tempre.FieldByName('codpfis').AsString, 5, 'Arial, normal, 8', salida, 'S');
end;

procedure TTEmpresa.Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
// Objetivo...: Listar Datos de Provincias
begin
  if orden = 'A' then tempre.IndexName := tperso.IndexDefs.Items[1].Name;

  list.Setear(salida); 
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Listado de Contribuyentes', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Cód.' + utiles.espacios(3) +  'Razón Social', 1, 'Arial, cursiva, 8');
  List.Titulo(40, list.Lineactual, 'Nº C.U.I.T.', 2, 'Arial, cursiva, 8');
  List.Titulo(53, list.Lineactual, 'Dirección', 3, 'Arial, cursiva, 8');
  List.Titulo(85, list.Lineactual, 'Vía Contribuyente', 4, 'Arial, cursiva, 8');
  List.Titulo(99, list.Lineactual, 'IVA', 5, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  tperso.First;
  while not tperso.EOF do
    begin
      // Ordenado por Código
      if (ent_excl = 'E') and (orden = 'C') then
        if (tperso.FieldByName('codemp').AsString >= iniciar) and (tperso.FieldByName('codemp').AsString <= finalizar) then List_Linea(salida);
      if (ent_excl = 'X') and (orden = 'C') then
        if (tperso.FieldByName('codemp').AsString < iniciar) or (tperso.FieldByName('codemp').AsString > finalizar) then List_linea(salida);
      // Ordenado Alfabéticamente
      if (ent_excl = 'E') and (orden = 'A') then
        if (tperso.FieldByName('rsocial1').AsString >= iniciar) and (tperso.FieldByName('rsocial1').AsString <= finalizar) then List_linea(salida);
      if (ent_excl = 'X') and (orden = 'A') then
        if (tperso.FieldByName('rsocial1').AsString < iniciar) or (tperso.FieldByName('roscial1').AsString > finalizar) then List_linea(salida);

      tperso.Next;
    end;
    List.FinList;

    tperso.IndexFieldNames := tempre.IndexFieldNames;
    tperso.First;
end;

// Rutinas para el manejo de elección de la empresa
procedure TTEmpresa.Grabar(xcodemp, xclave, xrsocial1, xnomvia, xcuit, xcodpfis, xverifper: string);
begin
  if selempr.RecordCount > 0 then selempr.Edit else selempr.Append;
  selempr.FieldByName('codemp').AsString   := xcodemp;
  selempr.FieldByName('clave').AsString    := xclave;
  selempr.FieldByName('rsocial1').AsString := xrsocial1;
  selempr.FieldByName('nomvia').AsString   := xnomvia;
  selempr.FieldByName('cuit').AsString     := xcuit;
  selempr.FieldByName('codpfis').AsString  := xcodpfis;
  selempr.FieldByName('verifper').AsString := xverifper;
  try
    selempr.Post;
  except
    selempr.Cancel;
  end;
end;

function TTEmpresa.getPeriodoRegis: string;
// Objetivo...: retornar el Período de Registración
begin
  empresa.getDatos(selempr.FieldByName('codemp').AsString);
  verifper := selempr.FieldByName('verifper').AsString;
  perDesde := '01/' + Copy(periodo, 1, 2) + '/' + Copy(periodo, 6, 2);
  perHasta := utiles.ultFechaMes(Copy(periodo, 1, 2), Copy(periodo, 4, 4)) + '/' + Copy(periodo, 1, 2) + '/' + Copy(periodo, 6, 2);
  Result   := Periodo;
end;

procedure TTEmpresa.ParametrosArchTexto(xtipoimpr, xmargenes, xlineas: integer);
// Objetivo...: establecer los parámetros para la emisión de archivos de texto
begin
  partxt.Open;
  if not partxt.RecordCount = 0 then partxt.Append else partxt.Edit;
  partxt.FieldByName('tipoimpr').AsInteger := xtipoimpr;
  partxt.FieldByName('MargenS').AsInteger  := xmargenes;
  partxt.FieldByName('lineas').AsInteger   := xlineas;
  try
    partxt.Post
   except
    partxt.Cancel
  end;
  partxt.Close;
end;

procedure TTEmpresa.getDatosArchTexto;
begin
  partxt.Open;
  if partxt.RecordCount > 0 then Begin
    tipoimpr := partxt.FieldByName('tipoimpr').AsInteger;
    margenes := partxt.FieldByName('MargenS').AsInteger;
    lineas   := partxt.FieldByName('lineas').AsInteger;
  end else Begin
    tipoimpr := 0;
    margenes := 0;
    lineas   := 0;
  end;
  partxt.Close;
end;

procedure TTEmpresa.PrepararVia(xnomvia: String);
// Objetivo...: Preparar Vía de Trabajo
Begin
  Application.CreateForm(TfmPreparacionVia, fmPreparacionVia);
  fmPreparacionVia.via.Caption            := dbs.dirSistema + '\' + xnomvia + '\';
  fmPreparacionVia.viaorigen.Caption      := dbs.dirSistema + '\estructu\';
  fmPreparacionVia.FileListBox1.Directory := dbs.dirSistema + '\estructu\';
  if not fmPreparacionVia.VerificarArchivos then fmPreparacionVia.ShowModal;
  fmPreparacionVia.Release; fmPreparacionVia := Nil;
end;

procedure TTEmpresa.BuscarPorCodigo(xexp: string);
begin
  tperso.IndexFieldNames := 'codemp';
  tperso.FindNearest([xexp]);
end;

procedure TTEmpresa.BuscarPorNombre(xexp: string);
begin
  tperso.IndexFieldNames := 'Rsocial1';
  tperso.FindNearest([xexp]);
end;

procedure TTEmpresa.ExportarDatos(xcodemp, xvia: String);
// Objetivo...: Exportar Datos
var
  te, th, vi: TTable;
Begin
  utilesarchivos.BorrarArchivos(dbs.DirSistema + '\_exportar\iva', '*.*');
  utilesarchivos.BorrarArchivos(dbs.DirSistema + '\_exportar\attach', '*.*');
  utilesarchivos.CopiarArchivos(dbs.DirSistema + '\_work\exportar', '*.*', dbs.DirSistema + '\_exportar\iva');
  conectar;
  getDatos(xcodemp);
  te := datosdb.openDB('datempr', '', '', dbs.DirSistema + '\_exportar\iva');
  th := datosdb.openDB('datemph', '', '', dbs.DirSistema + '\_exportar\iva');
  vi := datosdb.openDB('vias', '', '', dbs.DirSistema + '\_exportar\iva');
  te.Open; th.Open; vi.Open;
  te.Append;
  te.FieldByName('codemp').AsString    := codigo;
  te.FieldByName('rsocial1').AsString  := nombre;
  te.FieldByName('dire_tel').AsString  := domicilio;
  te.FieldByName('cp').AsString        := codpost;
  te.FieldByName('orden').AsString     := orden;
  te.FieldByName('clave').AsString     := clave;
  try
    te.Post
   except
    te.Cancel
  end;

  th.Append;
  th.FieldByName('codemp').AsString       := codigo;
  th.FieldByName('nomvia').AsString       := nomvia;
  th.FieldByName('rsocial2').AsString     := rsocial2;
  th.FieldByName('nrocuit').AsString      := nrocuit;
  th.FieldByName('depdgi').AsString       := depdgi;
  th.FieldByName('codactivi').AsString    := codactivi;
  th.FieldByName('codpfis').AsString      := codpfis;
  th.FieldByName('mescierre').AsString    := mescierre;
  th.FieldByName('suscribe').AsString     := suscribe;
  th.FieldByName('caracter').AsString     := caracter;
  th.FieldByName('tipocont').AsFloat      := tipocont;
  th.FieldByName('discneto').AsString     := discneto;
  th.FieldByName('up_livacom').AsInteger  := up_livacom;
  th.FieldByName('up_livaven').AsInteger  := up_livaven;
  th.FieldByName('impresora_c').AsInteger := impresora_c;
  th.FieldByName('impresora_v').AsInteger := impresora_v;
  th.FieldByName('orientpag_c').AsInteger := orientpag_c;
  th.FieldByName('orientpag_v').AsInteger := orientpag_v;
  th.FieldByName('periodo').AsString      := periodo;
  th.FieldByName('catempr').AsFloat       := catempr;
  th.FieldByName('verifica').AsInteger    := verific;
  try
    th.Post
   except
    th.Cancel
  end;

  defviaiva.conectar;
  defviaiva.getDatos(nomvia);
  vi.Append;
  vi.FieldByName('nomvia').AsString  := defviaiva.nomvia;
  vi.FieldByName('codemp').AsString  := defviaiva.codemp;
  vi.FieldByName('descrip').AsString := defviaiva.descrip;
  vi.FieldByName('estado').AsString  := defviaiva.estado;
  try
    vi.Post
   except
    vi.Cancel
  end;
  defviaiva.desconectar;

  desconectar;
  datosdb.closeDB(te); datosdb.closeDB(th); datosdb.closeDB(vi);

  // Copiamos los archivos correspondientes
  {utilesarchivos.CopiarArchivos(Copy(xvia, 1, Length(xvia) - 4), 'ivaventa.*', dbs.DirSistema + '\_exportar\iva');
  utilesarchivos.CopiarArchivos(Copy(xvia, 1, Length(xvia) - 4), 'ivacompr.*', dbs.DirSistema + '\_exportar\iva');
  utilesarchivos.CopiarArchivos(Copy(xvia, 1, Length(xvia) - 4), 'netdisco.*', dbs.DirSistema + '\_exportar\iva');
  utilesarchivos.CopiarArchivos(Copy(xvia, 1, Length(xvia) - 4), 'netdisve.*', dbs.DirSistema + '\_exportar\iva');}

  // Compactamos los datos
  utilesarchivos.CompactarArchivos(dbs.DirSistema + '\_exportar\iva\*.*', dbs.dirSistema + '\_exportar\attach\' + 'iva' + xcodemp + '.bck');
end;

procedure TTEmpresa.conectar;
// Objetivo...: conectar tablas de persistencia
begin
  cpost.conectar;
  via.conectar;
  if conexiones = 0 then Begin
    if not tperso.Active then tperso.Open;
    tperso.FieldByName('codemp').DisplayLabel := 'Cód.'; tperso.FieldByName('rsocial1').DisplayLabel := 'Razón Social 1'; tperso.FieldByName('dire_tel').DisplayLabel := 'Dirección / Teléfono';
    tperso.FieldByName('cp').Visible := False; tperso.FieldByName('orden').Visible := False;
    tperso.FieldByName('clave').EditMask := '**********';
    tperso.FieldByName('Sel').Visible := False;
    if not tempre.Active then tempre.Open;
    if not selempr.Active then selempr.Open;
    getPeriodoRegis;
  end;
  Inc(conexiones);
end;

function TTEmpresa.ImportarDatos(xdrive: String): TStringList;
// Objetivo...: Importar Datos
var
  l: TStringList;
Begin
  l := TStringList.Create;
  utilesarchivos.BorrarArchivos(dbs.DirSistema + '\_importar\attach', '*.bck');
  utilesarchivos.CopiarArchivos(xdrive, 'iva*.bck', dbs.DirSistema + '\_importar\attach');
  l := utilesarchivos.setListaArchivos(dbs.DirSistema + '\_importar\attach', '*.bck');
  Result := l;
end;

function TTEmpresa.ProcesarDatosImportados(xcodemp: String): Boolean;
// Objetivo...: Procesar Datos Importados
var
  t1, t2, v1: TTable;
Begin
  // Transferimos los datos
  Application.CreateForm(TfmBackup, fmBackup);
  fmBackup.DirectoryListBox1.Directory := dbs.DirSistema + '\_importar\attach';
  fmBackup.FileListBox1.ItemIndex := 0;
  fmBackup.FileListBox1Click(nil);   // Cargamos los datos del archivo
  fmBackup.rbOtherPath.Checked := True;
  fmBackup.EdPath.Text         := dbs.DirSistema + '\_importar\iva';
  fmBackup.OcultarMensaje      := True;
  fmBackup.Button3Click(Self);

  // Chequeamos la Empresa
  t1 := datosdb.openDB('datempr', '','', dbs.DirSistema + '\_importar\iva');
  t2 := datosdb.openDB('datemph', '','', dbs.DirSistema + '\_importar\iva');
  v1 := datosdb.openDB('vias', '','', dbs.DirSistema + '\_importar\iva');
  t1.Open; t2.Open; v1.Open;
  if t1.RecordCount > 0 then Begin
    if not Buscar(t1.FieldByName('codemp').AsString) then Begin // No Existe, la damos de alta
      Grabar(t1.FieldByName('codemp').AsString, t2.FieldByName('nomvia').AsString, t1.FieldByName('rsocial1').AsString, t2.FieldByName('rsocial2').AsString, t2.FieldByName('nrocuit').AsString, t1.FieldByName('dire_tel').AsString, t2.FieldByName('depdgi').AsString, t2.FieldByName('codactivi').AsString,
      t2.FieldByName('codpfis').AsString, t2.FieldByName('mescierre').AsString, t2.FieldByName('suscribe').AsString, t2.FieldByName('caracter').AsString, t2.FieldByName('discneto').AsString, t1.FieldByName('clave').AsString, t2.FieldByName('periodo').AsString, t2.FieldByName('cp').AsString, t2.FieldByName('orden').AsString,
      t2.FieldByName('tipocont').AsInteger,
      t2.FieldByName('catempr').AsInteger, t2.FieldByName('verifica').AsInteger, t2.FieldByName('reintegro').AsFloat);
      Grabar(t1.FieldByName('codemp').AsString, t1.FieldByName('clave').AsString, t1.FieldByName('rsocial1').AsString, t2.FieldByName('nomvia').AsString, t2.FieldByName('nrocuit').AsString, t2.FieldByName('codpfis').AsString, '');

      // Vía
      defviaiva.conectar;
      defviaiva.Grabar(v1.FieldByName('nomvia').AsString, v1.FieldByName('descrip').AsString);
      PrepararVia(v1.FieldByName('nomvia').AsString);
      defviaiva.OcuparVia(v1.FieldByName('nomvia').AsString, v1.FieldByName('codemp').AsString, t1.FieldByName('rsocial1').AsString);
      defviaiva.desconectar;
    end;

    datosdb.closeDB(t1);
    datosdb.closeDB(t2);
    datosdb.closeDB(v1);

    Result := True;
  end else
    Result := False;
end;

function  TTEmpresa.CantidadEmpresas: Integer;
Begin
  Result := tperso.RecordCount;
end;

procedure TTEmpresa.desconectar;
// Objetivo...: cerrar tempres de persistencia
begin
  via.desconectar;
  cpost.desconectar;
  if conexiones > 0 then Dec(conexiones);
  if conexiones = 0 then Begin
    datosdb.closeDB(tperso);
    datosdb.closeDB(tempre);
    datosdb.closeDB(selempr);
  end;
end;

{===============================================================================}

function empresa: TTEmpresa;
begin
  if xempresa = nil then
    xempresa := TTEmpresa.Create;
  Result := xempresa;
end;

{===============================================================================}

initialization

finalization
  xempresa.Free;

end.
