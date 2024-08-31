unit CSoporteMagneticoPAMI;

interface

uses CBDT, SysUtils, DBTables, CUtiles, CListar, CIDBFM, CAuditoriaCCB, Classes,
     CUtilidadesArchivos, CProfesionalCCB, CFacturacionCCB, CNBU;

type

TTSoporteMagPAMI = class
  cuitefector, bocaefector, codefector, depefector, rsocialefector, ugl: String;
  cuitprof, bocaprof, codprof, docprof, nrodocprof, apellidoprof, nombreprof, prestacionprof, especialidadprof, matriculanacprof, matriculaprovprof, fechanacprof, sexoprof, idprof,
  d_calle, d_puerta, telefono: String;
  nrodocafil, tipodocafil, nrobeneficioafil, gradoparenafil, nombreafil: String;
  efect, datprof, afil, tabla: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  function    BuscarEfector(xcuit: String): Boolean;
  procedure   RegistrarEfector(xcuitefector, xbocaefector, xcodefector, xdepefector, xrsocialefector, xuglefector: String);
  procedure   getDatosEfector(xcuit: String);
  procedure   BorrarEfector(xcuit: String);

  function    BuscarProfesional(xcuit: String): Boolean;
  procedure   RegistrarProfesional(xcuitprof, xbocaprof, xcodprof, xdocprof, xnrodocprof, xapellidoprof, xnombreprof, xprestacionprof, xespecialidadprof, xmatriculanacprof, xmatriculaprovprof, xfechanacprof, xsexoprof, xidprof, xd_calle, xd_puerta, xtelefono: String);
  procedure   getDatosProfesional(xcuit: String);
  procedure   BorrarProfesional(xcuit: String);

  function    BuscarAfiliado(xnrodoc: String): Boolean;
  procedure   RegistrarAfiliado(xnrodoc, xtipodocafil, xnrobeneficio, xgradoparenafil, xnombreafil: String);
  procedure   getDatosAfiliado(xnrodoc: String);
  procedure   BorrarAfiliado(xnrodoc: String);
  procedure   BuscarNroDoc(xexpresion: String);
  procedure   BuscarNombre(xexpresion: String);

  function    GanerarDatosParaExportar(xperiodo, xcodos: String; xcodigosexcluir, xcodigosincluir: TStringList): TStringList;

  function    verificarPeriodo(xperiodo: String): Boolean;
  procedure   ConsultarAfiliados(xperiodo: String);
  procedure   ConsultarDatos(xperiodo: String);
  procedure   ConsultarProfesionales(xperiodo: String);
  procedure   ConsultarEfectores(xperiodo: String);

  procedure   ListarRechazados(salida: char);

  procedure   EmulacionPAMI(xperiodo: String);

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  listaN, listaC: TStringList;
  per: String;
  conexiones: shortint;
end;

function sopmag: TTSoporteMagPAMI;

implementation

var
  xsopmag: TTSoporteMagPAMI = nil;

constructor TTSoporteMagPAMI.Create;
begin
  efect   := datosdb.openDB('efec', '', '', dbs.DirSistema + '\soportemag\pami');
  datprof := datosdb.openDB('datprof', '', '', dbs.DirSistema + '\soportemag\pami');
  afil    := datosdb.openDB('padron', '', '', dbs.DirSistema + '\soportemag\pami\work');
  listaN  := TStringList.Create;
  listaC  := TStringList.Create;
end;

destructor TTSoporteMagPAMI.Destroy;
begin
  inherited Destroy;
end;

function  TTSoporteMagPAMI.BuscarEfector(xcuit: String): Boolean;
// Objetivo...: Buscar una instancia
Begin
  Result := efect.FindKey([xcuit]);
end;

procedure TTSoporteMagPAMI.RegistrarEfector(xcuitefector, xbocaefector, xcodefector, xdepefector, xrsocialefector, xuglefector: String);
// Objetivo...: Registrar una instancia
Begin
  if BuscarEfector(xcuitefector) then efect.Edit else efect.Append;
  efect.FieldByName('cuitefec').AsString  := xcuitefector;
  efect.FieldByName('bate').AsString      := xbocaefector;
  efect.FieldByName('dadm').AsString      := xdepefector;
  efect.FieldByName('pamiefec').AsString  := xcodefector;
  efect.FieldByName('rsoc').AsString      := xrsocialefector;
  efect.FieldByName('ugl').AsString       := xuglefector;
  try
    efect.Post
   except
    efect.Cancel
  end;
  datosdb.closeDB(efect); efect.Open;
end;

procedure TTSoporteMagPAMI.getDatosEfector(xcuit: String);
// Objetivo...: Recuperar una instancia
Begin
  if BuscarEfector(xcuit) then Begin
    cuitefector    := xcuit;
    bocaefector    := efect.FieldByName('bate').AsString;
    depefector     := efect.FieldByName('dadm').AsString;
    codefector     := efect.FieldByName('pamiefec').AsString;
    rsocialefector := efect.FieldByName('rsoc').AsString;
    ugl            := efect.FieldByName('ugl').AsString;
  end else Begin
    cuitefector    := xcuit;
    bocaefector    := '';
    depefector     := '';
    codefector     := '';
    rsocialefector := '';
    ugl            := '';
  end;
  if Length(Trim(xcuit)) < 13 then Begin
    cuitefector    := efect.FieldByName('cuitefec').AsString;
    bocaefector    := efect.FieldByName('bate').AsString;
    depefector     := efect.FieldByName('dadm').AsString;
    codefector     := efect.FieldByName('pamiefec').AsString;
    rsocialefector := efect.FieldByName('rsoc').AsString;
  end;
end;

procedure TTSoporteMagPAMI.BorrarEfector(xcuit: String);
// Objetivo...: Borrar una instancia
Begin
  if BuscarEfector(xcuit) then efect.Delete;
end;

function  TTSoporteMagPAMI.BuscarProfesional(xcuit: String): Boolean;
// Objetivo...: recuperar instancia
begin
  Result := datprof.FindKey([xcuit]);
end;

procedure TTSoporteMagPAMI.RegistrarProfesional(xcuitprof, xbocaprof, xcodprof, xdocprof, xnrodocprof, xapellidoprof, xnombreprof, xprestacionprof, xespecialidadprof, xmatriculanacprof, xmatriculaprovprof, xfechanacprof, xsexoprof, xidprof, xd_calle, xd_puerta, xtelefono: String);
// Objetivo...: registrar instancia
begin
  if BuscarProfesional(xcuitprof) then datprof.Edit else datprof.Append;
  datprof.FieldByName('cuitprof').AsString := xcuitprof;
  datprof.FieldByName('bateprof').AsString := xbocaprof;
  datprof.FieldByName('pamiprof').AsString := xcodprof;
  datprof.FieldByName('tdocprof').AsString := xdocprof;
  datprof.FieldByName('ndocprof').AsString := xnrodocprof;
  datprof.FieldByName('apel').AsString     := xapellidoprof;
  datprof.FieldByName('nomb').AsString     := xnombreprof;
  datprof.FieldByName('pres').AsString     := xprestacionprof;
  datprof.FieldByName('espe').AsString     := xespecialidadprof;
  datprof.FieldByName('mnac').AsString     := xmatriculanacprof;
  datprof.FieldByName('mpro').AsString     := xmatriculaprovprof;
  datprof.FieldByName('fnac').AsString     := xfechanacprof;
  datprof.FieldByName('sexo').AsString     := xsexoprof;
  datprof.FieldByName('idprof').AsString   := xidprof;
  datprof.FieldByName('d_calle').AsString  := xd_calle;
  datprof.FieldByName('d_puerta').AsString := xd_puerta;
  datprof.FieldByName('telefono').AsString := xtelefono;
  try
    datprof.Post
   except
    datprof.Cancel
  end;
  datosdb.closeDB(datprof); datprof.Open;
end;

procedure TTSoporteMagPAMI.getDatosProfesional(xcuit: String);
// Objetivo...: recuperar datos profesional
begin
  if BuscarProfesional(xcuit) then Begin
    cuitprof          := datprof.FieldByName('cuitprof').AsString;
    bocaprof          := datprof.FieldByName('bateprof').AsString;
    codprof           := datprof.FieldByName('pamiprof').AsString;
    docprof           := datprof.FieldByName('tdocprof').AsString;
    nrodocprof        := datprof.FieldByName('ndocprof').AsString;
    apellidoprof      := datprof.FieldByName('apel').AsString;
    nombreprof        := datprof.FieldByName('nomb').AsString;
    prestacionprof    := datprof.FieldByName('pres').AsString;
    especialidadprof  := datprof.FieldByName('espe').AsString;
    matriculanacprof  := datprof.FieldByName('mnac').AsString;
    matriculaprovprof := datprof.FieldByName('mpro').AsString;
    fechanacprof      := datprof.FieldByName('fnac').AsString;
    sexoprof          := datprof.FieldByName('sexo').AsString;
    idprof            := datprof.FieldByName('idprof').AsString;
    d_calle           := datprof.FieldByName('d_calle').AsString;
    d_puerta          := datprof.FieldByName('d_puerta').AsString;
    telefono          := datprof.FieldByName('telefono').AsString;
  end else Begin
    cuitprof := ''; bocaprof := ''; codprof := ''; docprof := ''; cuitprof := ''; bocaprof := ''; codprof := '';
    docprof := ''; nrodocprof := ''; apellidoprof := ''; nombreprof := ''; prestacionprof := ''; especialidadprof := '';
    matriculanacprof := ''; matriculaprovprof := ''; fechanacprof := ''; sexoprof := ''; idprof := ''; d_calle := ''; d_puerta := '';
    telefono := '';
  end;
end;

procedure TTSoporteMagPAMI.BorrarProfesional(xcuit: String);
// Objetivo...: borrar instancia
begin
  if BuscarProfesional(xcuit) then datprof.Delete;
end;

function  TTSoporteMagPAMI.BuscarAfiliado(xnrodoc: String): Boolean;
// Objetivo...: buscar instancia
begin
  if afil.IndexFieldNames <> 'n_docu' then afil.IndexFieldNames := 'n_docu';
  Result := afil.FindKey([utiles.sLlenarIzquierda(xnrodoc, 8, '0')]);
end;

procedure TTSoporteMagPAMI.RegistrarAfiliado(xnrodoc, xtipodocafil, xnrobeneficio, xgradoparenafil, xnombreafil: String);
// Objetivo...: registrar instancia
begin
  if BuscarAfiliado(xnrodoc) then afil.Edit else afil.Append;
  afil.FieldByName('n_docu').AsString     := xnrodoc;
  afil.FieldByName('t_docu').AsString     := xtipodocafil;
  afil.FieldByName('n_benefici').AsString := xnrobeneficio;
  afil.FieldByName('ap_nom').AsString     := xnombreafil;
  afil.FieldByName('grado_pa').AsString   := xgradoparenafil;
  try
    afil.Post
   except
    afil.Cancel
  end;
  datosdb.refrescar(afil);
end;

procedure TTSoporteMagPAMI.getDatosAfiliado(xnrodoc: String);
// Objetivo...: borrar instancia
begin
  if BuscarAfiliado(xnrodoc) then Begin
    nrodocafil       := afil.FieldByName('n_docu').AsString;
    tipodocafil      := afil.FieldByName('t_docu').AsString;
    nrobeneficioafil := afil.FieldByName('n_benefici').AsString;
    nombreafil       := afil.FieldByName('ap_nom').AsString;
    gradoparenafil   := afil.FieldByName('grado_pa').AsString;
  end else Begin
    nrodocafil := ''; tipodocafil := ''; nrobeneficioafil := ''; nombreafil := ''; gradoparenafil := '';
  end;
end;

procedure TTSoporteMagPAMI.BorrarAfiliado(xnrodoc: String);
// Objetivo...: borrar instancia
begin
  if BuscarAfiliado(xnrodoc) then Begin
    afil.Delete;
    datosdb.closeDB(afil); afil.Open;
  end;
end;

function TTSoporteMagPAMI.GanerarDatosParaExportar(xperiodo, xcodos: String; xcodigosexcluir, xcodigosincluir: TStringList): TStringList;
// Objetivo...: Generar Datos a Exportar
var
  l, t: TStringList;
  p, dt, cod: String;
  i, j, k, n, x: Integer;
  t_work, tabla, afil1, padron: TTable;
Begin
  listaN.Clear; listaC.Clear;

  nbu.conectar;
  // Preparamos el directorio
  p := Copy(xperiodo, 1, 2) +  Copy(xperiodo, 4, 4);
  if not DirectoryExists(dbs.DirSistema + '\soportemag\pami\work\' + p) then Begin
    utilesarchivos.CrearDirectorio(dbs.DirSistema + '\soportemag\pami\work\' + p);
  end;
  utilesarchivos.CopiarArchivos(dbs.DirSistema + '\soportemag\pami', '*.*', dbs.DirSistema + '\soportemag\pami\work\' + p);

  // Integramos los numeros de distribuciones que vienen a partir de la facturación
  utilesarchivos.CopiarArchivos(dbs.DirSistema + '\work\auditoria', '*.*', dbs.DirSistema + '\soportemag\pami\work');
  t_work := datosdb.openDB('ordenes_audit', '', '', dbs.DirSistema + '\soportemag\pami\work');
  t_work.Open;

  l := facturacion.setLaboratoriosImportados(xperiodo);
  For i := 1 to l.Count do Begin
    if FileExists(dbs.DirSistema + '\fact_lab\' + p + '\' + l.Strings[i-1] + '\ordenes_audit.db') then Begin
      tabla := datosdb.openDB('ordenes_audit', '', '', dbs.DirSistema + '\fact_lab\' + p + '\' + l.Strings[i-1]);
      tabla.Open;
      while not tabla.Eof do Begin
        if datosdb.Buscar(t_work, 'periodo', 'items', 'idprof', tabla.FieldByName('periodo').AsString, tabla.FieldByName('items').AsString, tabla.FieldByName('idprof').AsString) then t_work.Edit else t_work.Append;
        t_work.FieldByName('periodo').AsString      := tabla.FieldByName('periodo').AsString;
        t_work.FieldByName('items').AsString        := tabla.FieldByName('items').AsString;
        t_work.FieldByName('idprof').AsString       := tabla.FieldByName('idprof').AsString;
        t_work.FieldByName('nroauditoria').AsString := tabla.FieldByName('nroauditoria').AsString;
        t_work.FieldByName('facturada').AsString    := tabla.FieldByName('facturada').AsString;
        try
          t_work.Post
         except
          t_work.Cancel
        end;
        datosdb.refrescar(t_work);
        tabla.Next;
      end;
      datosdb.closeDB(tabla);
    end;
  end;
  datosdb.closedb(t_work);

  // Ahora comenzamos a extraer los datos

  tabla  := datosdb.openDB('ordenes_audit', 'nroauditoria', '', dbs.DirSistema + '\soportemag\pami\work');
  t_work := datosdb.openDB('datadlb.DBF', '', '', dbs.DirSistema + '\soportemag\pami\work\' + p);
  t_work.Open;
  tabla.Open;

  padron := datosdb.openDB('padron', '', '', dbs.DirSistema + '\soportemag\pami\work');
  padron.Open;
  afil1 := datosdb.openDB('afil.DBF', 'NBEN', '', dbs.DirSistema + '\soportemag\pami\work\' + p);
  afil1.Open;

  l := TStringList.Create;
  t := TStringList.Create;
  auditoriacb.conectar;
  l := auditoriacb.setOrdenesAuditadas(xperiodo, xcodos);
  For i := 1 to l.Count do Begin
    t := auditoriacb.setCodidosAuditados(l.Strings[i-1]);
    if t.Count > 0 then Begin
      auditoriacb.getDatos(l.Strings[i-1]);

      if tabla.FindKey([l.Strings[i-1]]) then Begin   // Averiguamos el profesional
        profesional.getDatos(tabla.FieldByName('idprof').AsString);
        getDatosProfesional(profesional.Nrocuit);

         t_work.Append;

         t_work.FieldByName('cuitasoc').AsString := cuitefector;
         t_work.FieldByName('pamiasoc').AsString := codefector;
         t_work.FieldByName('uglasoc').AsString  := ugl;
         t_work.FieldByName('cuitefec').AsString := cuitefector;
         t_work.FieldByName('pamiefec').AsString := codefector;
         t_work.FieldByName('bateefec').AsString := bocaefector;

         // Actualizamos padron de afiliados
         if padron.FindKey([auditoriacb.Nrodoc]) then Begin
           if afil1.FindKey([padron.FieldByName('n_benefici').AsString]) then afil1.Edit else afil1.Append;
           afil1.FieldByName('nben').AsString     := padron.FieldByName('n_benefici').AsString;
           afil1.FieldByName('gpar').AsString     := padron.FieldByName('grado_pa').AsString;
           afil1.FieldByName('tdocafil').AsString := padron.FieldByName('t_docu').AsString;
           afil1.FieldByName('ndocafil').AsString := padron.FieldByName('n_docu').AsString;
           afil1.FieldByName('apyn').AsString     := padron.FieldByName('ap_nom').AsString;
           afil1.FieldByName('fnac').AsString     := padron.FieldByName('fenac').AsString;
           afil1.FieldByName('sexo').AsString     := padron.FieldByName('sexo').AsString;
           try
             afil1.Post
            except
             afil1.Cancel
           end;
         end;

         if BuscarAfiliado(auditoriacb.Nrodoc) then Begin
           t_work.FieldByName('nben').AsString  := afil.FieldByName('n_benefici').AsString;
           t_work.FieldByName('gpar').AsString  := afil.FieldByName('grado_pa').AsString;
           t_work.FieldByName('mate').AsString  := '1';   // ?? Modalidad de atencion 1. Ambulatorio
           t_work.FieldByName('mpre').AsString  := '1';   // 1. Capitada
         end else Begin
           listaN.Add(l.Strings[i-1] + ' - ' + auditoriacb.Nrodoc);
           t_work.FieldByName('nben').AsString  := 'X';
         end;

         x := 0;
         For k := 1 to t.Count do Begin
           if not utiles.verificarItemsLista(xcodigosexcluir, t.Strings[k-1]) then Begin  // Verificamos que no sea un código a excluir
             cod := nbu.setCodigoNBU(t.Strings[k-1]);
             //t_work.FieldByName(dt).AsString := cod;
             if Length(Trim(cod)) = 0 then listaC.Add(t.Strings[k-1]) else Begin
               Inc(x);
               dt := 'dt' + utiles.sLlenarIzquierda(IntToStr(x), 2, '0');
               t_work.FieldByName(dt).AsString := cod;
             end;
           end;
         end;

         For n := 1 to xcodigosincluir.Count do Begin  // Códigos a Incluir
           Inc(x);
           dt := 'dt' + utiles.sLlenarIzquierda(IntToStr(x), 2, '0');
           t_work.FieldByName(dt).AsString := xcodigosincluir.Strings[n-1];
           Inc(k);
         end;

         try
           t_work.Post
         except
           t_work.Cancel
         end;
      end;
    end;
  end;

  datosdb.tranSQL(t_work.DatabaseName, 'delete from ' + t_work.TableName + ' where nben = ' + '''' + 'X' + '''');

  datosdb.closeDB(t_work);
  datosdb.closeDB(tabla);
  datosdb.closeDB(afil1);
  datosdb.closeDB(padron);

  nbu.desconectar;
  auditoriacb.desconectar;

  Result := listaN;
end;

procedure TTSoporteMagPAMI.BuscarNroDoc(xexpresion: String);
// Objetivo...: Buscar Documento
Begin
  if afil.IndexFieldNames <> 'n_docu' then afil.IndexFieldNames := 'n_docu';
  afil.FindNearest([xexpresion]);
end;

function  TTSoporteMagPAMI.verificarPeriodo(xperiodo: String): Boolean;
var
  p: String;
Begin
  if Length(Trim(xperiodo)) < 7 then Result := False else Begin
    p := Copy(xperiodo, 1, 2) +  Copy(xperiodo, 4, 4);
    if DirectoryExists(dbs.DirSistema + '\soportemag\pami\work\' + p) then Result := True else Result := False;
  end;
end;

procedure TTSoporteMagPAMI.ConsultarAfiliados(xperiodo: String);
// Objetivo...: Consultara  afiliados
var
  p: String;
begin
  if tabla <> Nil then
    if tabla.Active then tabla.Close;
  p := Copy(xperiodo, 1, 2) +  Copy(xperiodo, 4, 4);
  tabla := datosdb.openDB('afil.DBF', '', '', dbs.DirSistema + '\soportemag\pami\work\' + p);
  tabla.Open;
end;

procedure TTSoporteMagPAMI.ConsultarDatos(xperiodo: String);
// Objetivo...: Consultara  afiliados
var
  p: String;
begin
  if tabla <> Nil then
    if tabla.Active then tabla.Close;
  p := Copy(xperiodo, 1, 2) +  Copy(xperiodo, 4, 4);
  tabla := datosdb.openDB('datadlb.DBF', '', '', dbs.DirSistema + '\soportemag\pami\work\' + p);
  tabla.Open;
end;

procedure TTSoporteMagPAMI.ConsultarProfesionales(xperiodo: String);
// Objetivo...: Consultara  afiliados
var
  p: String;
begin
  if tabla <> Nil then
    if tabla.Active then tabla.Close;
  p := Copy(xperiodo, 1, 2) +  Copy(xperiodo, 4, 4);
  tabla := datosdb.openDB('datprof.DBF', '', '', dbs.DirSistema + '\soportemag\pami\work\' + p);
  tabla.Open;
end;

procedure TTSoporteMagPAMI.ConsultarEfectores(xperiodo: String);
// Objetivo...: Consultara  afiliados
var
  p: String;
begin
  if tabla <> Nil then
    if tabla.Active then tabla.Close;
  p := Copy(xperiodo, 1, 2) +  Copy(xperiodo, 4, 4);
  tabla := datosdb.openDB('efec.DBF', '', '', dbs.DirSistema + '\soportemag\pami\work\' + p);
  tabla.Open;
end;

procedure TTSoporteMagPAMI.BuscarNombre(xexpresion: String);
// Objetivo...: Buscar Documento
Begin
  if afil.IndexFieldNames <> 'ap_nom' then afil.IndexFieldNames := 'ap_nom';
  afil.FindNearest([xexpresion]);
end;

procedure TTSoporteMagPAMI.ListarRechazados(salida: char);
// objetivo...: Listar rechazados
var
  i: Integer;
  c: String;
begin
  list.Setear(salida);
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Listado de Nros. Auditoria Rechazados', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Número Auditoria', 1, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  List.Linea(0, 0, '*** Documentos Inexistentes ***', 1, 'Arial, normal, 10', salida, 'S');
  List.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');

  if (listaN.Count = 0) and (listaC.Count = 0) then List.Linea(0, 0, 'No hay Datos para Listar ...!', 1, 'Arial, normal, 11', salida, 'S') else Begin
    For i := 1 to listaN.Count do
      List.Linea(0, 0, listaN.Strings[i-1], 1, 'Arial, normal, 8', salida, 'S');
  end;

  List.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
  List.Linea(0, 0, '*** Códigos Inexistentes ***', 1, 'Arial, normal, 10', salida, 'S');
  List.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');

  listaC.Sort;
  For i := 1 to listaC.Count do Begin
    if listaC.Strings[i-1] <> c then List.Linea(0, 0, listaC.Strings[i-1], 1, 'Arial, normal, 8', salida, 'S');
    c := listaC.Strings[i-1];
  end;

  list.FinList;
end;

procedure TTSoporteMagPAMI.EmulacionPAMI(xperiodo: String);
// Objetivo...: Emular Sistema de PAMI
var
  archivo: TextFile;

  procedure IniciarEmulacion(xperiodo: String);
  Begin
    AssignFile(archivo, dbs.DirSistema + '\SoporteMag\export_' + Copy(xperiodo, 1, 2) + Copy(xperiodo, 4, 4) + '.txt');
    Rewrite(archivo);
  end;

  procedure FinalizarEmulacion;
  Begin
    CloseFile(archivo);
  end;

  procedure ExportarProfesional;
  Begin
    WriteLn(archivo, 'PROFESIONAL');
    datprof.First;
    while not datprof.Eof do Begin
      WriteLn(archivo, ';;;0;' + Copy(datprof.FieldByName('apel').AsString  + ' ' + datprof.FieldByName('nomb').AsString, 1, 60) + ';' +
              datprof.FieldByName('espe').AsString + ';' + datprof.FieldByName('mnac').AsString+ ';;' + datprof.FieldByName('tdocprof').AsString + ';' +
              datprof.FieldByName('ndocprof').AsString + ';' + datprof.FieldByName('cuitprof').AsString + ';' + datprof.FieldByName('d_calle').AsString + ';' +
              datprof.FieldByName('d_puerta').AsString + ';;' + 'Null' + ';' + datprof.FieldByName('telefono').AsString);
      datprof.Next;
    end;
  end;


Begin
  conectar;
  IniciarEmulacion(xperiodo);

  ExportarProfesional;

  desconectar;

  FinalizarEmulacion;
end;

procedure TTSoporteMagPAMI.conectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones = 0 then Begin
    if not efect.Active then efect.Open;
    if not datprof.Active then datprof.Open;
    if not afil.Active then afil.Open;
  end;
  Inc(conexiones);
  profesional.conectar;
end;

procedure TTSoporteMagPAMI.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if tabla <> Nil then
    if tabla.Active then tabla.Close;
  Dec(conexiones);
  if conexiones = 0 then Begin
    datosdb.closeDB(efect);
    datosdb.closeDB(datprof);
    datosdb.closeDB(afil);
  end;
  profesional.desconectar;
end;

{===============================================================================}

function sopmag: TTSoporteMagPAMI;
begin
  if xsopmag = nil then
    xsopmag := TTSoporteMagPAMI.Create;
  Result := xsopmag;
end;

{===============================================================================}

initialization

finalization
  xsopmag.Free;

end.
