unit CCHistoriaDieteticaVicentin;

interface

uses CCAnamnesis_Vicentin, CTablasVicentin, CBDT, SysUtils, DBTables, CUtiles, CListar,
     CIDBFM, Classes, CDiagnosticoNutricional_Vicentin, CUtilidadesArchivos, CAtencionPacientes_Vicentin,
     Graphics, Forms, IRaveReport, Cimc;

type

TTHistoriaDietetica = class
  Nropaciente, Nombre, Fecha, Peso, Fechanac, Circmunieca, Ocupacion, Actfisica, Comidasrealiza, Quiencocina, Sexo, Atencion, Edad,
  Picotea, Alergia, Familia, Realizadieta, Logroresult, Espectativa, Tiempo, Motivoconsulta, Telefono, Idtabla, Diagnostico, Iddiag: String;
  Contextsexo: String; ContextChico, ContextMin, ContextMax, ContextGrande, Sobrepeso, Calorias, Caloriaskg, Agregar, CaloriasFS, PesoTeorico, Sobrepeso1, Sobrepeso2, Sobrepeso3: Real;
  vct, hdc, cal1, gr1, prot, cal2, gr2, gra, cal3, gr3, Hdc1, Prot1, Grasas, Cintura, Cadera: Real;
  Descrip, Minimo, Maximo, Referencia: String;
  HoraM1, HoraM2, HoraT1, HoraT2: String;
  Existe: Boolean;
  historia, anpac, tpeso, contextura, fsintet, formulades, parametrosbioq, valoresfd, requerimientos, pb_pac, columnas_oc, ph, turnos: TTable;
 public
  { Declaraciones P�blicas }
  constructor Create;
  destructor  Destroy; override;

  function    Nuevo: String;
  function    Buscar(xnropaciente: String): Boolean;
  procedure   Guardar(xnropaciente, xnombre, xfecha, xpeso, xfechanac, xcircmunieca, xocupacion, xactfisica, xcomidasrealiza, xquiencocina,
                      xpicotea, xalergia, xfamilia, xrealizadieta, xlogroresult, xespectativa, xtiempo, xmotivoconsulta, xtelefono, xsexo, xatencion: String);
  procedure   GuardarValoracionNutricional(xnropaciente, xidtabla, xdiagnostico, xiddiag: String; xsobrepeso, xpesoteorico, xsobrepeso1, xsobrepeso2, xsobrepeso3: Real);
  procedure   Borrar(xnropaciente: String);
  procedure   getDatos(xnropaciente: String);
  function    setHistorias: TStringList;

  function    BuscarAnamnesis(xcodpac, xitems: String): Boolean;
  procedure   RegistrarAnamnesis(xcodpac, xitems, xvalor: String; xcantitems: Integer);
  function    setValor(xcodpac, xitems: String): String;
  procedure   BorrarAnamnesis(xcodpac: String);

  function    BuscarPeso(xcodpac, xitems: String): Boolean;
  procedure   RegistrarPeso(xcodpac, xitems, xfecha, xhora, xsemana: String; xpeso, xtalla: Real; xvestimenta, xobservaciones: String; xcintura, xcadera: real; xcantitems: Integer);
  procedure   BorrarPeso(xcodpac, xitems: String); overload;
  procedure   BorrarPeso(xcodpac: String); overload;
  function    setPesos(xcodpac: String): TQuery;
  procedure   TransferirPesoHistorico(xnropaciente: String); overload;
  procedure   TransferirPesoHistorico(xnropaciente, xitems: String); overload;

  procedure   RegistrarRequerimientos(xcodpac: String; xcalorias, xcaloriaskg, xagregar: Real);
  procedure   RegistrarRequirimientosDieta(xcodpac, xit, xitems: String; xcantidad: Real; xcantitems: Integer);
  function    setRequerimientosDieta(xcodpac, xitems: String): String; overload;
  function    setRequerimientosDieta(xcodpac: String): TStringList; overload;
  procedure   BorrarRequirimientosDieta(xcodpac: String);
  procedure   RegistrarFormulaSinteticaPaciente(xcodpac: String; xhdc, xprot, xgrasas: Real);

  procedure   BuscarPorNroHistoria(xexpresion: String);
  procedure   BuscarPorNombre(xexpresion: String);

  procedure   Listar(xlista: TStringList; xhistoria, xpeso, xvaloracion, xrequerimientos, xparametrosbioq: Boolean; salida: char; xmargen_izquierdo: Integer);

  procedure   DefinirParametrosConextura(xsexo: String; xchica, xmediamin, xmediamax, xgrande: Real);
  procedure   getDatosConextura(xsexo: String);
  function    DeterminarContextura(xsexo: String; xtalla, xcirmunieca: Real): String;

  procedure   RegistrarFormulaSintetica(xvct, xhdc, xcal1, xgr1, xprot, xcal2, xgr2, xgra, xcal3, xgr3: Real);
  procedure   getRegistrarFormulaSintetica(xvct: Real);
  function    BuscarHistoriaSintetica(xvct: Real): Real;
  procedure   RegistrarTotalCalorias(xcodpac: String; xtotcalorias: Real);

  procedure   RegistrarItemsFormulaDes(xlinea, xitems, xid, xdescrip: String; xcantidad: Integer);
  function    setItemsFormulaDes(xlinea: String): TStringList; overload;
  function    setItemsFormulaDes(xlinea, xid: String): String; overload;

  procedure   RegistrarValoresEstandarFD(xitems1, xitems2: String; xvalor: Real; xcantitems: Integer);
  function    setValoresEstandar(xitems1, xitems2: String): String;
  function    setValorFD(xitems1, xitems2: String): String;

  function    BuscarParametrosBioquimicos(xitems: String): Boolean;
  procedure   RegistrarParametrosBioquimicos(xitems, xdescrip, xminimo, xmaximo, xreferencia: String);
  function    setParametrosBioquimicos: TStringList;
  procedure   getDatosParametrosBioquimicos(xitems: String);
  procedure   BuscarPorDescripPB(xexpresion: String);
  procedure   BuscarPorItemsPB(xexpresion: String);
  function    NuevoParametroBioquimico: String;
  procedure   BorrarParametrosBioquimicos(xitems: String);

  function    BuscarParametrosBioqPaciente(xnropaciente, xitems: String): Boolean;
  procedure   RegistrarParametrosBioqPaciente(xnropaciente, xfecha, xitems, xcodigo, xvalor, xobservacion, xreferencia: String; xcantitems: Integer);
  function    setParametrosBioqPaciente(xnropaciente: String): TStringList;
  function    setParametrosBioqPacienteLista(xnropaciente: String): TStringList;
  procedure   BorrarParametrosBioqPaciente(xnropaciente: String);

  procedure   OcultarColFil(xcodpac, xhv, xitems: String);
  procedure   BorrarColFil(xcodpac, xhv, xitems: String); overload;
  function    setColFil(xcodpac, xhv: String): TStringList;
  function    setColFilVisible(xcodpac, xhv, xitems: String): Boolean;
  procedure   BorrarColFil(xcodpac: String); overload;

  function    BuscarTurno(xfecha, xitems: String): Boolean;
  procedure   RegistrarTurno(xfecha, xitems, xhora, xcodpac, xnombre, xmotivo, xtelefono, xtt, xatencion: String; xdebe: Real; xcantitems: Integer);
  function    setTurnos(xfecha: String): TStringList;
  procedure   ListarTurnos(xfecha, xmaniana_tarde, xtitulo1, xtitulo2, xtitulo3: String; salida: char);
  procedure   ListarResumenTurnos(xdesde, xhasta, xtitulo1, xtitulo2, xtitulo3: String; salida: char);
  procedure   EstablecerHoras(xhoram1, xhoram2, xhorat1, xhorat2: String);
  procedure   getHoras;
  procedure   BorrarTurnos(xfecha: String);
  procedure   DepurarTurnos(xfecha: String);

  procedure   FiltrarFechas(xdfecha, xhfecha: String);
  procedure   QuitarFiltro;

  { Integridad Referencial }
  function    verificarAnamnesisRegistrada(xitems: String): Boolean;
  function    verificarTablaValores(xitems: String): Boolean;
  function    verificarRequerimientos(xitems: String): Boolean;
  function    verificarParametrosBioquimicos(xitems: String): Boolean;

  function    ObtenerFotoSiguiente(xcodpac: String): String;
  function    setFotos: TStringList;

  function    setCantidadPacientes: Integer;

  procedure   conectar;
  procedure   desconectar;
  procedure   conectarHD;
  procedure   desconectarHD;

  procedure   InformePaciente(xcodpac, xresultadobmi, xpesoposible, xtalla, xpesoactual, xpesoteorico, xcirccintura, xcontextura, xsobrepeso, xprimerconsulta, xultimo_peso, ximc, xbmi4, xbmi, xtitulo, xsubtitulo, xcirccadera, xindicecinturacadera, ximcobjetivo, xriesgo: string);
  procedure   InformePacienteSdo(xcodpac, xresultadobmi, xpesoposible, xtalla, xpesoactual, xpesoteorico, xcirccintura, xcontextura, xsobrepeso, xprimerconsulta, xultimo_peso, ximc, xbmi4, xbmi, xtitulo, xsubtitulo, xcirccadera, xindicecinturacadera, ximcobjetivo, xriesgo: string; lista: TStringList);
 private
  { Declaraciones Privadas }
  conexiones, conexionespac: shortint;
  lpeso: Boolean;
  archivo: TextFile;
  rsql: TQuery;
  lista: TStringList;
  listam: array[1..60, 1..25] of String;
  listat: array[1..60, 1..25] of String;
  procedure   ListarValoracionNutricional(xnropaciente: String; salida: char);
  procedure   ListarRequerimientos(xnropaciente: String; salida: char);
  procedure   ListarParametrosBioquimicos(xnropaciente: String; salida: char);
  procedure   ListarPeso(nropaciente: String; salida: char);
  procedure   IniciarColumnas;
end;

function historiadiet: TTHistoriaDietetica;

implementation

var
  xhistoriadiet: TTHistoriaDietetica = nil;

constructor TTHistoriaDietetica.Create;
begin
  historia       := datosdb.openDB('historiadiet_paciente', '');
  anpac          := datosdb.openDB('anamnesis_paciente', '');
  tpeso          := datosdb.openDB('peso_paciente', '');
  contextura     := datosdb.openDB('contextura', '');
  fsintet        := datosdb.openDB('formula_sintetica', '');
  formulades     := datosdb.openDB('formula_desarrollada', '');
  parametrosbioq := datosdb.openDB('parametros_bioquimicos', '');
  valoresfd      := datosdb.openDB('valores_formuladesarrollada', '');
  requerimientos := datosdb.openDB('requerimientos_paciente', '');
  pb_pac         := datosdb.openDB('parametrosbioq_paciente', '');
  columnas_oc    := datosdb.openDB('columnas_ocultas', '');
  ph             := datosdb.openDB('peso_pacientehist', '');
  turnos         := datosdb.openDB('turnos', '');
end;

destructor TTHistoriaDietetica.Destroy;
begin
  inherited Destroy;
end;

function  TTHistoriaDietetica.Nuevo: String;
// Objetivo...: Nueva Historia Diettetica
Begin
  if historia.Filtered then QuitarFiltro;
  if historia.IndexFieldNames <> 'nropaciente' then historia.IndexFieldNames := 'nropaciente';
  if historia.RecordCount = 0 then Result := '1' else Begin
    historia.Last;
    Result := IntToStr(historia.FieldByName('nropaciente').AsInteger + 1);
  end;
end;

function  TTHistoriaDietetica.Buscar(xnropaciente: String): Boolean;
// Objetivo...: Buscar Historia Diettetica
Begin
  if not historia.Active then Begin
    historia.Open;
    IniciarColumnas;
  end;
  if historia.Filtered then QuitarFiltro;
  if historia.IndexFieldNames <> 'nropaciente' then historia.IndexFieldNames := 'nropaciente';
  Existe := historia.FindKey([xnropaciente]);
  Result := Existe;
end;

procedure TTHistoriaDietetica.Guardar(xnropaciente, xnombre, xfecha, xpeso, xfechanac, xcircmunieca, xocupacion, xactfisica, xcomidasrealiza, xquiencocina,
                      xpicotea, xalergia, xfamilia, xrealizadieta, xlogroresult, xespectativa, xtiempo, xmotivoconsulta, xtelefono, xsexo, xatencion: String);
// Objetivo...: Registrar Historia Diettetica
Begin
  if Buscar(xnropaciente) then historia.Edit else historia.Append;
  historia.FieldByName('nropaciente').AsString    := xnropaciente;
  historia.FieldByName('nombre').AsString         := xnombre;
  historia.FieldByName('fecha').AsString          := utiles.sExprFecha2000(xfecha);
  historia.FieldByName('peso').AsString           := xpeso;
  historia.FieldByName('fechanac').AsString       := utiles.sExprFecha2000(xfechanac);
  historia.FieldByName('circmunieca').AsString    := utiles.FormatearNumero(xcircmunieca);
  historia.FieldByName('ocupacion').AsString      := xocupacion;
  historia.FieldByName('actfisica').AsString      := xactfisica;
  historia.FieldByName('comidasrealiza').AsString := xcomidasrealiza;
  historia.FieldByName('quiencocina').AsString    := xquiencocina;
  historia.FieldByName('picotea').AsString        := xpicotea;
  historia.FieldByName('alergia').AsString        := xalergia;
  historia.FieldByName('familia').AsString        := xfamilia;
  historia.FieldByName('realizadieta').AsString   := xrealizadieta;
  historia.FieldByName('logroresult').AsString    := xlogroresult;
  historia.FieldByName('espectativa').AsString    := xespectativa;
  historia.FieldByName('tiempo').AsString         := xtiempo;
  historia.FieldByName('motivoconsulta').AsString := xmotivoconsulta;
  historia.FieldByName('telefono').AsString       := xtelefono;
  historia.FieldByName('sexo').AsString           := xsexo;
  historia.FieldByName('atencion').AsString       := xatencion;
  try
    historia.Post
   except
    historia.Cancel
  end;
  datosdb.closeDB(historia); historia.Open;
  IniciarColumnas;
end;

procedure TTHistoriaDietetica.GuardarValoracionNutricional(xnropaciente, xidtabla, xdiagnostico, xiddiag: String; xsobrepeso, xpesoteorico, xsobrepeso1, xsobrepeso2, xsobrepeso3: Real);
// Objetivo...: Guardar Valores
Begin
  if Buscar(xnropaciente) then Begin
    historia.Edit;
    historia.FieldByName('diagnostico').AsString := xdiagnostico;
    historia.FieldByName('idtabla').AsString     := xidtabla;
    historia.FieldByName('sobrepeso').AsFloat    := xsobrepeso;
    historia.FieldByName('iddiag').AsString      := xiddiag;
    historia.FieldByName('pesoteorico').AsFloat  := xpesoteorico;
    historia.FieldByName('sob1').AsFloat         := xsobrepeso1;
    historia.FieldByName('sob2').AsFloat         := xsobrepeso2;
    historia.FieldByName('sob3').AsFloat         := xsobrepeso3;
    try
      historia.Post
     except
      historia.Cancel
    end;
    datosdb.closeDB(historia); historia.Open;
    IniciarColumnas;
    // Actualizamos Atributos del Objeto
    Idtabla     := xidtabla;
    Iddiag      := xiddiag;
    PesoTeorico := xpesoteorico;
    Sobrepeso1  := xsobrepeso1;
    Sobrepeso2  := xsobrepeso2;
    Sobrepeso3  := xsobrepeso3;
    Diagnostico := xdiagnostico;
  end;
end;

procedure TTHistoriaDietetica.Borrar(xnropaciente: String);
// Objetivo...: Borrar Historia Diettetica
Begin
  if Buscar(xnropaciente) then Begin
    historia.Delete;
    datosdb.refrescar(historia);
    BorrarPeso(xnropaciente);
    BorrarAnamnesis(xnropaciente);
    BorrarRequirimientosDieta(xnropaciente);
    BorrarParametrosBioqPaciente(xnropaciente);
    BorrarColFil(xnropaciente);
  end;
end;

procedure TTHistoriaDietetica.getDatos(xnropaciente: String);
// Objetivo...: Cargar Historia Diettetica
Begin
  lista := TStringList.Create;
  if Buscar(xnropaciente) then Begin
    nropaciente    := historia.FieldByName('nropaciente').AsString;
    nombre         := historia.FieldByName('nombre').AsString;
    fecha          := utiles.sFormatoFecha(historia.FieldByName('fecha').AsString);
    peso           := historia.FieldByName('peso').AsString;
    fechanac       := utiles.sFormatoFecha(historia.FieldByName('fechanac').AsString);
    circmunieca    := historia.FieldByName('circmunieca').AsString;
    ocupacion      := historia.FieldByName('ocupacion').AsString;
    actfisica      := historia.FieldByName('actfisica').AsString;
    comidasrealiza := historia.FieldByName('comidasrealiza').AsString;
    quiencocina    := historia.FieldByName('quiencocina').AsString;
    picotea        := historia.FieldByName('picotea').AsString;
    alergia        := historia.FieldByName('alergia').AsString;
    familia        := historia.FieldByName('familia').AsString;
    realizadieta   := historia.FieldByName('realizadieta').AsString;
    logroresult    := historia.FieldByName('logroresult').AsString;
    espectativa    := historia.FieldByName('espectativa').AsString;
    tiempo         := historia.FieldByName('tiempo').AsString;
    motivoconsulta := historia.FieldByName('motivoconsulta').AsString;
    telefono       := historia.FieldByName('telefono').AsString;
    sexo           := historia.FieldByName('sexo').AsString;
    diagnostico    := historia.FieldByName('diagnostico').AsString;
    idtabla        := historia.FieldByName('idtabla').AsString;
    sobrepeso      := historia.FieldByName('sobrepeso').AsFloat;
    calorias       := historia.FieldByName('calorias').AsFloat;
    caloriaskg     := historia.FieldByName('caloriaskg').AsFloat;
    agregar        := historia.FieldByName('agregar').AsFloat;
    CaloriasFS     := historia.FieldByName('caloriasfs').AsFloat;
    Iddiag         := historia.FieldByName('iddiag').AsString;
    atencion       := historia.FieldByName('atencion').AsString;
    Hdc1           := historia.FieldByName('hdc').AsFloat;
    Prot1          := historia.FieldByName('prot').AsFloat;
    Grasas         := historia.FieldByName('grasas').AsFloat;
    Pesoteorico    := historia.FieldByName('pesoteorico').AsFloat;
    Sobrepeso1     := historia.FieldByName('sob1').AsFloat;
    Sobrepeso2     := historia.FieldByName('sob2').AsFloat;
    Sobrepeso3     := historia.FieldByName('sob3').AsFloat;
    lista          := utilesarchivos.setListaArchivos(dbs.DirSistema + '\fotos', '*.jpg', nropaciente);
  end else Begin
    Nropaciente := ''; Nombre := ''; Fecha := ''; Peso := ''; Fechanac := ''; Circmunieca := ''; Ocupacion := ''; Actfisica := ''; Comidasrealiza := ''; Quiencocina := ''; sobrepeso := 0; idtabla := '';
    Picotea := ''; Alergia := ''; Familia := ''; Realizadieta := ''; Logroresult := ''; Espectativa := ''; Tiempo := ''; Motivoconsulta := ''; telefono := ''; sexo := ''; diagnostico := ''; calorias := 0;
    caloriaskg := 0; agregar := 0; caloriasfs := 0; iddiag := ''; atencion := ''; hdc1 := 50; prot1 := 20; grasas := 30; Pesoteorico := 0; Sobrepeso1 := 0; Sobrepeso2 := 0; Sobrepeso3 := 0;
  end;
end;

function  TTHistoriaDietetica.setHistorias: TStringList;
// Objetivo...: Devolver una lista con las historias dieteticas
var
  l: TStringList;
Begin
  l := TStringList.Create;
  historia.IndexFieldNames := 'Nombre';
  historia.First;
  while not historia.Eof do Begin
    l.Add(historia.FieldByName('nropaciente').AsString + historia.FieldByName('nombre').AsString);
    historia.Next;
  end;
  historia.IndexFieldNames := 'Nropaciente';
  Result := l;
end;

function  TTHistoriaDietetica.BuscarAnamnesis(xcodpac, xitems: String): Boolean;
// Objetivo...: Buscar Anamnesis
Begin
  Result := datosdb.Buscar(anpac, 'codpac', 'items', xcodpac, xitems);
end;

procedure TTHistoriaDietetica.RegistrarAnamnesis(xcodpac, xitems, xvalor: String; xcantitems: Integer);
// Objetivo...: Registrar Valores de Anamnesis
Begin
  if BuscarAnamnesis(xcodpac, xitems) then anpac.Edit else anpac.Append;
  anpac.FieldByName('codpac').AsString := xcodpac;
  anpac.FieldByName('items').AsString  := xitems;
  anpac.FieldByName('valor').AsString  := xvalor;
  try
    anpac.Post
   except
    anpac.Cancel
  end;
  if xitems = utiles.sLlenarIzquierda(IntToStr(xcantitems), 3, '0') then datosdb.tranSQL('delete from ' + anpac.TableName + ' where codpac = ' + '''' + xcodpac + '''' + ' and items > ' + '''' + xitems + '''');
  datosdb.closeDB(anpac); anpac.Open;
end;

function  TTHistoriaDietetica.setValor(xcodpac, xitems: String): String;
// Objetivo...: Buscar Anamnesis
Begin
  if BuscarAnamnesis(xcodpac, xitems) then Result := anpac.FieldByName('valor').AsString else Result := '';
end;

procedure TTHistoriaDietetica.BorrarAnamnesis(xcodpac: String);
// Objetivo...: Borrar Tabla Anamnesis Paciente
Begin
  datosdb.tranSQL('delete from ' + anpac.TableName + ' where codpac = ' + '''' + xcodpac + '''');
  datosdb.refrescar(anpac);
end;

function  TTHistoriaDietetica.BuscarPeso(xcodpac, xitems: String): Boolean;
// Objetivo...: Buscar Peso
Begin
  Result := datosdb.Buscar(tpeso, 'codpac', 'items', xcodpac, xitems);
end;

procedure TTHistoriaDietetica.RegistrarPeso(xcodpac, xitems, xfecha, xhora, xsemana: String; xpeso, xtalla: Real; xvestimenta, xobservaciones: String; xcintura, xcadera: real; xcantitems: Integer);
// Objetivo...: Buscar Anamnesis
Begin
  if BuscarPeso(xcodpac, xitems) then tpeso.Edit else tpeso.Append;
  tpeso.FieldByName('codpac').AsString        := xcodpac;
  tpeso.FieldByName('items').AsString         := xitems;
  tpeso.FieldByName('fecha').AsString         := utiles.sExprFecha2000(xfecha);
  tpeso.FieldByName('hora').AsString          := xhora;
  tpeso.FieldByName('semana').AsString        := xsemana;
  tpeso.FieldByName('peso').AsFloat           := xpeso;
  tpeso.FieldByName('talla').AsFloat          := xtalla;
  tpeso.FieldByName('vestimenta').AsString    := xvestimenta;
  tpeso.FieldByName('observaciones').AsString := xobservaciones;
  tpeso.FieldByName('cintura').AsFloat        := xcintura;
  tpeso.FieldByName('cadera').AsFloat         := xcadera;
  try
    tpeso.Post
   except
    tpeso.Cancel
  end;
  if xitems = utiles.sLlenarIzquierda(IntToStr(xcantitems), 3, '0') then datosdb.tranSQL('delete from ' + tpeso.TableName + ' where codpac = ' + '''' + xcodpac + '''' + ' and items > ' + '''' + xitems + '''');
  datosdb.closedb(tpeso); tpeso.Open;
end;

procedure TTHistoriaDietetica.BorrarPeso(xcodpac, xitems: String);
// Objetivo...: Buscar Anamnesis
Begin
  if BuscarPeso(xcodpac, xitems) then tpeso.Delete;
  datosdb.closeDB(tpeso); tpeso.Open;
end;

procedure TTHistoriaDietetica.BorrarPeso(xcodpac: String);
// Objetivo...: Buscar Anamnesis
Begin
  datosdb.tranSQL('delete from ' + tpeso.TableName + ' where codpac = ' + '''' + xcodpac + '''');
  datosdb.refrescar(tpeso);
end;

function  TTHistoriaDietetica.setPesos(xcodpac: String): TQuery;
// Objetivo...: devolver pesos
var
  r: TQuery;
Begin
  result := datosdb.tranSQL('select * from ' + tpeso.TableName + ' where codpac = ' + '''' +  xcodpac + '''' + ' order by codpac, items');
end;

procedure TTHistoriaDietetica.TransferirPesoHistorico(xnropaciente: String);
// Objetivo...: Transferir pesos al historico
var
  it: String;
Begin
  ph.Open;
  it := utiles.setIdRegistroFecha;
  if BuscarPeso(xnropaciente, '001') then Begin
    while not tpeso.Eof do Begin
      if tpeso.FieldByName('codpac').AsString <> xnropaciente then Break;
      if datosdb.Buscar(ph, 'codpac', 'items', 'idpase', xnropaciente, tpeso.FieldByName('items').AsString, it) then ph.Edit else ph.Append;
      ph.FieldByName('codpac').AsString        := tpeso.FieldByName('codpac').AsString;
      ph.FieldByName('items').AsString         := tpeso.FieldByName('items').AsString;
      ph.FieldByName('idpase').AsString        := it;
      ph.FieldByName('fecha').AsString         := tpeso.FieldByName('fecha').AsString;
      ph.FieldByName('hora').AsString          := tpeso.FieldByName('hora').AsString;
      ph.FieldByName('semana').AsString        := tpeso.FieldByName('semana').AsString;
      ph.FieldByName('peso').AsString          := tpeso.FieldByName('peso').AsString;
      ph.FieldByName('talla').AsString         := tpeso.FieldByName('talla').AsString;
      ph.FieldByName('vestimenta').AsString    := tpeso.FieldByName('vestimenta').AsString;
      ph.FieldByName('observaciones').AsString := tpeso.FieldByName('observaciones').AsString;
      try
        ph.Post
       except
        ph.Cancel
      end;
      tpeso.Next;
    end;
  end;
  datosdb.tranSQL('delete from ' + tpeso.TableName + ' where codpac = ' + '''' + xnropaciente + '''');
  datosdb.closedb(ph);
end;

procedure TTHistoriaDietetica.TransferirPesoHistorico(xnropaciente, xitems: String);
// Objetivo...: Transferir items de pesos al historico
var
  it: String;
Begin
  ph.Open;
  it := utiles.setIdRegistroFecha;
  if BuscarPeso(xnropaciente, '001') then Begin
    while not tpeso.Eof do Begin
      if tpeso.FieldByName('codpac').AsString <> xnropaciente then Break;
      if tpeso.FieldByName('items').AsString = xitems then Begin
        if datosdb.Buscar(ph, 'codpac', 'items', 'idpase', xnropaciente, tpeso.FieldByName('items').AsString, it) then ph.Edit else ph.Append;
        ph.FieldByName('codpac').AsString        := tpeso.FieldByName('codpac').AsString;
        ph.FieldByName('items').AsString         := tpeso.FieldByName('items').AsString;
        ph.FieldByName('idpase').AsString        := it;
        ph.FieldByName('fecha').AsString         := tpeso.FieldByName('fecha').AsString;
        ph.FieldByName('hora').AsString          := tpeso.FieldByName('hora').AsString;
        ph.FieldByName('semana').AsString        := tpeso.FieldByName('semana').AsString;
        ph.FieldByName('peso').AsString          := tpeso.FieldByName('peso').AsString;
        ph.FieldByName('talla').AsString         := tpeso.FieldByName('talla').AsString;
        ph.FieldByName('vestimenta').AsString    := tpeso.FieldByName('vestimenta').AsString;
        ph.FieldByName('observaciones').AsString := tpeso.FieldByName('observaciones').AsString;
        try
          ph.Post
         except
          ph.Cancel
        end;
      end;
      tpeso.Next;
    end;
  end;
  //datosdb.tranSQL('delete from ' + tpeso.TableName + ' where codpac = ' + '''' + xnropaciente + '''' + ' and items = ' + '''' + xitems + '''');
  datosdb.closedb(tpeso); tpeso.Open;
  datosdb.closedb(ph);
end;

procedure TTHistoriaDietetica.RegistrarRequerimientos(xcodpac: String; xcalorias, xcaloriaskg, xagregar: Real);
// Objetivo...: Registrar Requerimientos
Begin
  if Buscar(xcodpac) then Begin
    historia.Edit;
    historia.FieldByName('calorias').AsFloat   := xcalorias;
    historia.FieldByName('caloriaskg').AsFloat := xcaloriaskg;
    historia.FieldByName('agregar').AsFloat    := xagregar;
    try
      historia.Post
     except
      historia.Cancel
    end;
    datosdb.closeDB(historia); historia.Open;
    IniciarColumnas;
    Calorias   := xcalorias;
    CaloriasKg := xcaloriaskg;
    Agregar    := xagregar;
  end;
end;

procedure TTHistoriaDietetica.RegistrarRequirimientosDieta(xcodpac, xit, xitems: String; xcantidad: Real; xcantitems: Integer);
// Objetivo...: Buscar por nro. de historia
Begin
  if requerimientos.IndexFieldNames <> 'codpac;it' then requerimientos.IndexFieldNames := 'codpac;it'; 
  if datosdb.Buscar(requerimientos, 'codpac', 'it', xcodpac, xit) then requerimientos.Edit else requerimientos.Append;
  requerimientos.FieldByName('codpac').AsString  := xcodpac;
  requerimientos.FieldByName('it').AsString      := xit;
  requerimientos.FieldByName('items').AsString   := xitems;
  requerimientos.FieldByName('cantidad').AsFloat := xcantidad;
  try
    requerimientos.Post
   except
    requerimientos.Cancel
  end;
  datosdb.closeDB(requerimientos);
  if xitems = utiles.sLlenarIzquierda(IntToStr(xcantitems), 3, '0') then Begin
    datosdb.tranSQL('delete from requerimientos_paciente where codpac = ' + '''' + xcodpac + '''' + ' and items > ' + '''' + xitems + '''');
    datosdb.closeDB(requerimientos); requerimientos.Open;
  end;
end;

function  TTHistoriaDietetica.setRequerimientosDieta(xcodpac, xitems: String): String;
// Objetivo...: Buscar por nro. de historia
Begin
  if requerimientos.IndexFieldNames <> 'codpac;it' then requerimientos.IndexFieldNames := 'codpac;it';
  if datosdb.Buscar(requerimientos, 'codpac', 'it', xcodpac, xitems) then Result := requerimientos.FieldByName('cantidad').AsString else Result := '';
end;

function  TTHistoriaDietetica.setRequerimientosDieta(xcodpac: String): TStringList;
// Objetivo...: Devolver una Lista
var
  l: TStringList;
Begin
  l := TStringList.Create;
  requerimientos.IndexFieldNames := 'codpac;items';
  if datosdb.Buscar(requerimientos, 'codpac', 'items', xcodpac, '001') then Begin
    while not requerimientos.Eof do Begin
      if requerimientos.FieldByName('codpac').AsString <> xcodpac then Break;
      l.Add(requerimientos.FieldByName('items').AsString + requerimientos.FieldByName('it').AsString + ';1' + requerimientos.FieldByName('cantidad').AsString);
      requerimientos.Next;
    end;
  end;
  requerimientos.IndexFieldNames := 'codpac;it';
  Result := l;
end;

procedure TTHistoriaDietetica.BorrarRequirimientosDieta(xcodpac: String);
// Objetivo...: Borrar Requerimientos Historia Diet�tica
Begin
  datosdb.tranSQL('delete from ' + requerimientos.TableName + ' where codpac = ' + '''' + xcodpac + '''');
end;

procedure TTHistoriaDietetica.RegistrarFormulaSinteticaPaciente(xcodpac: String; xhdc, xprot, xgrasas: Real);
// Objetivo...: Registrar Formula Sintetica Paciente
Begin
  if Buscar(xcodpac) then Begin
    historia.Edit;
    historia.FieldByName('hdc').AsFloat    := xhdc;
    historia.FieldByName('prot').AsFloat   := xprot;
    historia.FieldByName('grasas').AsFloat := xgrasas;
    try
      historia.Post
     except
      historia.Cancel
    end;
    datosdb.closeDB(historia); historia.Open;
    IniciarColumnas;
  end;
end;

procedure TTHistoriaDietetica.BuscarPorNroHistoria(xexpresion: String);
// Objetivo...: Buscar por nro. de historia
Begin
  if not historia.Active then Begin
    historia.Open;
    IniciarColumnas;
  end;
  if historia.IndexFieldNames <> 'nropaciente' then historia.IndexFieldNames := 'nropaciente';
  historia.FindNearest([xexpresion]);
end;

procedure TTHistoriaDietetica.BuscarPorNombre(xexpresion: String);
// Objetivo...: Buscar por nro. de historia
Begin
  if not historia.Active then Begin
    historia.Open;
    IniciarColumnas;
  end;
  if historia.IndexFieldNames <> 'nombre' then historia.IndexFieldNames := 'nombre';
  historia.FindNearest([xexpresion]);
end;

procedure TTHistoriaDietetica.Listar(xlista: TStringList; xhistoria, xpeso, xvaloracion, xrequerimientos, xparametrosbioq: Boolean; salida: char; xmargen_izquierdo: Integer);
// Objetivo...: Listar Historia Dietetica
var
  i, it, j, k, s: Integer;
  m: array[1..100, 1..2] of String;
  v, p: Real;
  l: Boolean;
  ls: TStringList;
Begin
  list.Setear(salida, xmargen_izquierdo);
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  if xlista.Count > 1 then List.Titulo(0, 0, ' Historia Diet�tica', 1, 'Arial, negrita, 14') else Begin
    getDatos(xlista.Strings[0]);
    List.Titulo(0, 0, nombre, 1, 'Arial, negrita, 14');
  end;
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  For i := 1 to xlista.Count do Begin
    getDatos(xlista.Strings[i-1]);
    list.Linea(0, 0, '', 1, 'Arial, negrita, 9', salida, 'N');
    list.Linea(70, list.Lineactual, 'Fecha:  ' + fecha, 2, 'Arial, negrita, 9', salida, 'S');
    list.Linea(0, 0, 'Paciente:  ' + nropaciente +  ' - ' + nombre, 1, 'Arial, negrita, 9', salida, 'N');
    list.Linea(70, list.Lineactual, 'Tel�fono:  ' + telefono, 2, 'Arial, negrita, 9', salida, 'S');
    list.Linea(0, 0, 'Peso Habitual:  ' + peso, 1, 'Arial, negrita, 9', salida, 'N');
    utiles.calc_antiguedad(utiles.sExprFecha(fechanac), utiles.sExprFecha2000(utiles.setFechaActual));
    if utiles.getAnios > 0 then Edad := IntToStr(utiles.getAnios) else Edad := '0';
    list.Linea(50, list.Lineactual, 'Edad:  ' + Edad, 2, 'Arial, negrita, 9', salida, 'N');
    list.Linea(70, list.Lineactual, 'Circ. Mu�eca:  ' + circmunieca, 3, 'Arial, negrita, 9', salida, 'S');
    list.Linea(0, 0, 'Ocupaci�n:  ' + ocupacion, 1, 'Arial, negrita, 9', salida, 'N');
    list.Linea(50, list.Lineactual, 'Act. Fisica:  ' + actfisica, 2, 'Arial, negrita, 9', salida, 'S');
    list.Linea(0, 0, 'Motivo de Consulta:  ' + motivoconsulta, 1, 'Arial, negrita, 9', salida, 'N');

    list.Linea(0, 0, '', 1, 'Arial, negrita, 8', salida, 'S');

    if xhistoria then Begin
    list.Linea(0, 0, 'Anamnesis Alimentaria: ', 1, 'Arial, negrita, 9, clNavy', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S');

    it := 0;
    ls := anamnesis.setItemsLista;
    For s := 1 to ls.Count do Begin
      Inc(it);
      anamnesis.getDatos(Copy(ls.Strings[s-1], 4, 3));
      m[it, 1] := anamnesis.Descrip;
      if BuscarAnamnesis(nropaciente, Copy(ls.Strings[s-1], 1, 3)) then  m[it, 2] := anpac.FieldByName('valor').AsString else m[it, 2] := '';
    end;

    if it > 0 then Begin
      k := (it div 2) + 1;
      For j := 1 to k do Begin
        list.Linea(0, 0, m[j, 1], 1, 'Arial, normal, 8', salida, 'N');
        list.Linea(35, list.Lineactual, m[j, 2], 2, 'Arial, normal, 8', salida, 'N');
        list.Linea(50, list.Lineactual, m[j+k, 1], 3, 'Arial, normal, 8', salida, 'N');
        list.Linea(85, list.Lineactual, m[j+k, 2], 4, 'Arial, normal, 8', salida, 'S');
      end;
    end;

    list.Linea(0, 0, '', 1, 'Arial, normal, 10', salida, 'S');
    list.Linea(0, 0, 'Cuantas comidas realiza ?  ', 1, 'Arial, normal, 9', salida, 'N');
    list.Linea(24, list.Lineactual, comidasrealiza, 2, 'Arial, negrita, 9', salida, 'S');
    list.Linea(0, 0, 'Qui�n cocina ?', 1, 'Arial, normal, 9', salida, 'N');
    list.Linea(15, list.Lineactual, quiencocina, 2, 'Arial, negrita, 9', salida, 'S');
    list.Linea(0, 0, 'Picotea durante el d�a ?', 1, 'Arial, normal, 9', salida, 'N');
    list.Linea(22, list.Lineactual, picotea, 2, 'Arial, negrita, 9', salida, 'S');
    list.Linea(0, 0, 'Presenta alguna intolerancia o alergia alimentaria ?', 1, 'Arial, normal, 9', salida, 'N');
    list.Linea(44, list.Lineactual, alergia, 2, 'Arial, negrita, 9', salida, 'S');
    list.Linea(0, 0, 'Alguien en su familia presenta sobrepeso: mam�/pap�/hermanos ?', 1, 'Arial, normal, 9', salida, 'N');
    list.Linea(55, list.Lineactual, familia, 2, 'Arial, negrita, 9', salida, 'S');
    list.Linea(0, 0, 'Realiz� alg�n tipo de dieta ?', 1, 'Arial, normal, 9', salida, 'N');
    list.Linea(25, list.Lineactual, realizadieta, 2, 'Arial, negrita, 9', salida, 'S');
    list.Linea(0, 0, 'Logr� los resultados esperados ?', 1, 'Arial, normal, 9', salida, 'N');
    list.Linea(30, list.Lineactual, logroresult, 2, 'Arial, negrita, 9', salida, 'S');
    list.Linea(0, 0, 'Cu�les son sus espectativas para empezar el tratamiento ?', 1, 'Arial, normal, 9', salida, 'N');
    list.Linea(50, list.Lineactual, espectativa, 2, 'Arial, negrita, 9', salida, 'S');
    list.Linea(0, 0, 'Qu� tiempo cree que le llevar� lograrla ? ', 1, 'Arial, normal, 9', salida, 'N');
    list.Linea(35, list.Lineactual, tiempo, 2, 'Arial, negrita, 9', salida, 'S');
    list.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');
    list.Linea(0, 0, 'Motivo/s de consulta:', 1, 'Arial, normal, 9', salida, 'N');
    list.Linea(20, list.Lineactual, motivoconsulta, 2, 'Arial, negrita, 9', salida, 'S');

    list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
    list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
    end;

    if xpeso then ListarPeso(nropaciente, salida);
    if xvaloracion then
      if lpeso then ListarValoracionNutricional(nropaciente, salida);
    if xrequerimientos then ListarRequerimientos(nropaciente, salida);
    if xparametrosbioq then ListarParametrosBioquimicos(nropaciente, salida);
    lpeso := False;
    if i < xlista.Count then Begin
      list.CompletarPagina;
      list.IniciarNuevaPagina;
    end;
  end;
  list.FinList;
end;

procedure TTHistoriaDietetica.ListarPeso(nropaciente: String; salida: char);
// Objetivo...: Listar Valoraci�n nutricional
var
  i, it, j, k: Integer;
  m: array[1..100, 1..2] of String;
  v, p: Real;
Begin
  ph.Open;
  datosdb.Filtrar(ph, 'codpac = ' + '''' + nropaciente + '''');
  if ph.RecordCount > 0 then Begin
    list.Linea(0, 0, 'Control de Peso - Registros Hist�ricos', 1, 'Arial, negrita, 9, clNavy', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
    it := 0; v := 0;
    list.Linea(0, 0, 'Fecha', 1, 'Arial, normal, 8', salida, 'N');
    list.Linea(10, list.Lineactual, 'Hora', 2, 'Arial, normal, 8', salida, 'N');
    list.Linea(20, list.Lineactual, 'Semana', 3, 'Arial, normal, 8', salida, 'N');
    list.Linea(35, list.Lineactual, 'Peso', 4, 'Arial, normal, 8', salida, 'N');
    list.Linea(45, list.Lineactual, 'Var.', 5, 'Arial, normal, 8', salida, 'N');
    list.Linea(55, list.Lineactual, 'Talla', 6, 'Arial, normal, 8', salida, 'N');
    list.Linea(62, list.Lineactual, 'Vestimenta', 7, 'Arial, normal, 8', salida, 'N');
    list.Linea(85, list.Lineactual, 'Observaciones', 8, 'Arial, normal, 8', salida, 'S');
    list.Linea(0, 0, '------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------', 1, 'Arial, normal, 8', salida, 'S');
    while not ph.Eof do Begin
      if ph.FieldByName('codpac').AsString <> nropaciente then Break;
      list.Linea(0, 0, utiles.sFormatoFecha(ph.FieldByName('fecha').AsString), 1, 'Arial, normal, 8', salida, 'N');
      list.Linea(10, list.Lineactual, ph.FieldByName('hora').AsString, 2, 'Arial, normal, 8', salida, 'N');
      list.Linea(20, list.Lineactual, ph.FieldByName('semana').AsString, 3, 'Arial, normal, 8', salida, 'N');
      list.Linea(35, list.Lineactual, utiles.FormatearNumero(ph.FieldByName('peso').AsString), 4, 'Arial, normal, 8', salida, 'N');
      if it > 0 then v := ph.FieldByName('peso').AsFloat - p;
      Inc(it);
      list.Linea(45, list.Lineactual, utiles.FormatearNumero(FloatToStr(v)), 5, 'Arial, normal, 8', salida, 'N');
      list.Linea(55, list.Lineactual, ph.FieldByName('talla').AsString, 6, 'Arial, normal, 8', salida, 'N');
      list.Linea(62, list.Lineactual, ph.FieldByName('vestimenta').AsString, 7, 'Arial, normal, 8', salida, 'N');
      list.Linea(85, list.Lineactual, ph.FieldByName('observaciones').AsString, 8, 'Arial, normal, 8', salida, 'S');
      p := ph.FieldByName('peso').AsFloat;
      ph.Next;
    end;
  end;
  datosdb.closeDB(ph);
  if BuscarPeso(nropaciente, '001') then Begin
    lpeso := True;
    list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
    list.Linea(0, 0, 'Control de Peso', 1, 'Arial, negrita, 9, clNavy', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
    it := 0; v := 0;
    list.Linea(0, 0, 'Fecha', 1, 'Arial, normal, 8', salida, 'N');
    list.Linea(10, list.Lineactual, 'Hora', 2, 'Arial, normal, 8', salida, 'N');
    list.Linea(20, list.Lineactual, 'Semana', 3, 'Arial, normal, 8', salida, 'N');
    list.Linea(35, list.Lineactual, 'Peso', 4, 'Arial, normal, 8', salida, 'N');
    list.Linea(45, list.Lineactual, 'Var.', 5, 'Arial, normal, 8', salida, 'N');
    list.Linea(55, list.Lineactual, 'Talla', 6, 'Arial, normal, 8', salida, 'N');
    list.Linea(62, list.Lineactual, 'Vestimenta', 7, 'Arial, normal, 8', salida, 'N');
    list.Linea(85, list.Lineactual, 'Observaciones', 8, 'Arial, normal, 8', salida, 'S');
    list.Linea(0, 0, '------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------', 1, 'Arial, normal, 8', salida, 'S');
    peso := tpeso.FieldByName('peso').AsString;
    while not tpeso.Eof do Begin
      if tpeso.FieldByName('codpac').AsString <> nropaciente then Break;
      list.Linea(0, 0, utiles.sFormatoFecha(tpeso.FieldByName('fecha').AsString), 1, 'Arial, normal, 8', salida, 'N');
      list.Linea(10, list.Lineactual, tpeso.FieldByName('hora').AsString, 2, 'Arial, normal, 8', salida, 'N');
      list.Linea(20, list.Lineactual, tpeso.FieldByName('semana').AsString, 3, 'Arial, normal, 8', salida, 'N');
      list.Linea(35, list.Lineactual, utiles.FormatearNumero(tpeso.FieldByName('peso').AsString), 4, 'Arial, normal, 8', salida, 'N');
      if it > 0 then v := tpeso.FieldByName('peso').AsFloat - p;
      Inc(it);
      list.Linea(45, list.Lineactual, utiles.FormatearNumero(FloatToStr(v)), 5, 'Arial, normal, 8', salida, 'N');
      list.Linea(55, list.Lineactual, tpeso.FieldByName('talla').AsString, 6, 'Arial, normal, 8', salida, 'N');
      list.Linea(62, list.Lineactual, tpeso.FieldByName('vestimenta').AsString, 7, 'Arial, normal, 8', salida, 'N');
      list.Linea(85, list.Lineactual, tpeso.FieldByName('observaciones').AsString, 8, 'Arial, normal, 8', salida, 'S');
      p    := tpeso.FieldByName('peso').AsFloat;
      tpeso.Next;
    end;
  end;
end;

procedure TTHistoriaDietetica.ListarValoracionNutricional(xnropaciente: String; salida: char);
// Objetivo...: Listar Valoraci�n nutricional
var
  ta, pt, cont, ed, pp: String;
Begin
  list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
  list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
  list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');

  ed := Edad;
  list.Linea(0, 0, '', 1, 'Arial, normal, 10', salida, 'S');
  list.Linea(0, 0, 'Valoraci�n Nutricional', 1, 'Arial, negrita, 9, clNavy', salida, 'S');
  list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
  list.Linea(0, 0, 'Peso Actual:', 1, 'Arial, normal, 8', salida, 'N');
  list.Linea(18, list.Lineactual, Peso, 2, 'Arial, normal, 8', salida, 'N');
  list.Linea(26, list.Lineactual, 'Kg.', 3, 'Arial, normal, 8', salida, 'N');
  list.Linea(55, list.Lineactual, 'Peso Posible', 4, 'Arial, negrita, 8', salida, 'S');
  list.Linea(0, 0, 'Edad:', 1, 'Arial, normal, 8', salida, 'N');
  list.Linea(18, list.Lineactual, ed, 2, 'Arial, normal, 8', salida, 'N');
  list.Linea(26, list.Lineactual, 'a�os.', 3, 'Arial, normal, 8', salida, 'N');
  list.Linea(55, list.Lineactual, 'Peso Te�rico', 4, 'Arial, normal, 8', salida, 'S');
  if BuscarPeso(xnropaciente, '001') then ta := tpeso.FieldByName('talla').AsString;
  cont := DeterminarContextura(sexo, StrToFloat(ta), StrToFloat(Circmunieca));
  pt := tablas.setPesoTeorico(idtabla, sexo, ta, cont);
  if historia.FieldByName('PesoTeorico').AsFloat > 0 then pt := utiles.FormatearNumero(historia.FieldByName('PesoTeorico').AsString);
  list.Linea(80, list.Lineactual, pt, 5, 'Arial, normal, 8', salida, 'N');
  list.Linea(85, list.Lineactual, 'Kg.', 6, 'Arial, normal, 8', salida, 'S');
  list.Linea(0, 0, 'Talla:', 1, 'Arial, normal, 8', salida, 'N');
  list.Linea(18, list.Lineactual, ta, 2, 'Arial, normal, 8', salida, 'N');
  list.Linea(26, list.Lineactual, 'mts.', 3, 'Arial, normal, 8', salida, 'N');
  list.Linea(55, list.Lineactual, 'C/10 a�os despu�s de los 20', 4, 'Arial, normal, 8', salida, 'S');
  if historia.FieldByName('Sob1').AsFloat > 0 then list.Linea(80, list.Lineactual, utiles.FormatearNumero(FloattoStr(historia.FieldByName('Sob1').AsFloat)), 5, 'Arial, normal, 8', salida, 'N') else
    list.Linea(80, list.Lineactual, utiles.FormatearNumero(FloattoStr(((StrToFloat(ed) - 20)) / 10)), 5, 'Arial, normal, 8', salida, 'N');
  list.Linea(85, list.Lineactual, 'Kg.', 6, 'Arial, normal, 8', salida, 'S');
  list.Linea(0, 0, 'Contextura:', 1, 'Arial, normal, 8', salida, 'N');
  list.Linea(18, list.Lineactual, cont, 2, 'Arial, normal, 8', salida, 'N');
  list.Linea(26, list.Lineactual, '', 3, 'Arial, normal, 8', salida, 'N');
  list.Linea(55, list.Lineactual, 'C/10 kg. de sobrepeso', 4, 'Arial, normal, 8', salida, 'S');
  if historia.FieldByName('Sob2').AsFloat > 0 then list.Linea(80, list.Lineactual, utiles.FormatearNumero(FloattoStr(historia.FieldByName('Sob2').AsFloat)), 5, 'Arial, normal, 8', salida, 'N') else
    list.Linea(80, list.Lineactual, utiles.FormatearNumero(FloattoStr(((StrToFloat(peso) - StrToFloat(pt))) / 10)), 5, 'Arial, normal, 8', salida, 'N');
  list.Linea(85, list.Lineactual, 'Kg.', 6, 'Arial, normal, 8', salida, 'S');
  list.Linea(0, 0, 'Circ. mu�eca:', 1, 'Arial, normal, 8', salida, 'N');
  list.Linea(18, list.Lineactual, Circmunieca, 2, 'Arial, normal, 8', salida, 'N');
  list.Linea(26, list.Lineactual, 'cm.', 3, 'Arial, normal, 8', salida, 'N');
  list.Linea(55, list.Lineactual, 'C/10 a�os de sobrepeso', 4, 'Arial, normal, 8', salida, 'S');
  list.Linea(80, list.Lineactual, utiles.FormatearNumero(FloatToStr(sobrepeso)), 5, 'Arial, normal, 8', salida, 'N');
  list.Linea(85, list.Lineactual, 'Kg.', 6, 'Arial, normal, 8', salida, 'S');
  list.Linea(0, 0, 'Peso Te�rico:', 1, 'Arial, normal, 8', salida, 'N');
  list.Linea(18, list.Lineactual, pt, 2, 'Arial, normal, 8', salida, 'N');
  list.Linea(26, list.Lineactual, 'Kgs.', 3, 'Arial, normal, 8', salida, 'N');
  list.Linea(55, list.Lineactual, '', 4, 'Arial, normal, 8', salida, 'S');
  list.Linea(80, list.Lineactual, '----------------', 5, 'Arial, normal, 8', salida, 'N');
  list.Linea(85, list.Lineactual, '', 6, 'Arial, normal, 8', salida, 'S');
  if historia.FieldByName('Sob1').AsFloat > 0 then Sobrepeso1 := historia.FieldByName('sob1').AsFloat else Sobrepeso1 := (StrToFloat(ed) - 20) / 10;
  if historia.FieldByName('Sob2').AsFloat > 0 then Sobrepeso2 := historia.FieldByName('sob2').AsFloat else Sobrepeso2 := (StrToFloat(peso) - StrToFloat(pt)) / 10;
  pp := utiles.FormatearNumero(FloatToStr((StrToFloat(pt) + sobrepeso + Sobrepeso1 + Sobrepeso2)));
  list.Linea(0, 0, 'Peso Posible:', 1, 'Arial, normal, 8', salida, 'N');
  list.Linea(18, list.Lineactual, pp, 2, 'Arial, normal, 8', salida, 'N');
  list.Linea(26, list.Lineactual, 'Kgs.', 3, 'Arial, normal, 8', salida, 'N');
  list.Linea(55, list.Lineactual, 'PESO POSIBLE:', 4, 'Arial, normal, 8', salida, 'S');
  list.Linea(80, list.Lineactual, pp, 5, 'Arial, normal, 8', salida, 'N');
  list.Linea(85, list.Lineactual, '', 6, 'Arial, normal, 8', salida, 'S');

  list.Linea(0, 0, '', 1, 'Arial, normal, 10', salida, 'S');
  list.Linea(0, 0, '% de Adecuaci�n:', 1, 'Arial, normal, 8', salida, 'N');
  list.Linea(30, list.Lineactual, 'PA X 100', 2, 'Arial, normal, 8', salida, 'N');
  list.Linea(51, list.Lineactual, utiles.FormatearNumero(FloatToStr(StrToFloat(Peso))) + ' * 100', 3, 'Arial, normal, 8', salida, 'S');
  list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'N');
  list.Linea(30, list.Lineactual, '------------', 2, 'Arial, normal, 8', salida, 'N');
  list.Linea(48, list.Lineactual, '=', 3, 'Arial, normal, 8', salida, 'N');
  list.Linea(50, list.Lineactual, '----------------------', 4, 'Arial, normal, 8', salida, 'N');
  list.Linea(67, list.Lineactual, '=', 5, 'Arial, normal, 8', salida, 'N');
  list.Linea(70, list.Lineactual, utiles.FormatearNumero(FloatToStr((StrToFloat(peso) * 100) / StrToFloat(pp))) + '  %', 6, 'Arial, normal, 8', salida, 'S');
  list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'N');
  list.Linea(30, list.Lineactual, ' PP', 2, 'Arial, normal, 8', salida, 'N');
  list.Linea(51, list.Lineactual, {pt}pp, 3, 'Arial, normal, 8', salida, 'S');

  list.Linea(0, 0, '', 1, 'Arial, normal, 10', salida, 'S');
  list.Linea(0, 0, 'BMI', 1, 'Arial, normal, 8', salida, 'N');
  list.Linea(30, list.Lineactual, 'PA', 2, 'Arial, normal, 8', salida, 'N');
  list.Linea(51, list.Lineactual, peso, 3, 'Arial, normal, 8', salida, 'N');
  list.Linea(70, list.Lineactual, peso, 4, 'Arial, negrita, 8', salida, 'S');
  list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'N');
  list.Linea(30, list.Lineactual, '----', 2, 'Arial, normal, 8', salida, 'N');
  list.Linea(48, list.Lineactual, '=', 3, 'Arial, normal, 8', salida, 'N');
  list.Linea(51, list.Lineactual, '---------', 4, 'Arial, normal, 8', salida, 'N');
  list.Linea(70, list.Lineactual, '---------', 5, 'Arial, normal, 8', salida, 'N');
  list.Linea(77, list.Lineactual, '=', 6, 'Arial, normal, 8', salida, 'N');
  list.Linea(80, list.Lineactual, utiles.FormatearNumero(FloatToStr(utiles.setNro2Dec(StrToFloat(peso)) / utiles.setNro2Dec(((StrToFloat(ta) * StrToFloat(ta)))))), 7, 'Arial, negrita, 8', salida, 'S');
  list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'N');
  list.Linea(30, list.Lineactual, '(T)�', 2, 'Arial, normal, 8', salida, 'N');
  list.Linea(48, list.Lineactual, '=', 3, 'Arial, normal, 8', salida, 'N');
  list.Linea(51, list.Lineactual, '(' + utiles.FormatearNumero(ta) + ')�', 4, 'Arial, normal, 8', salida, 'N');
  list.Linea(70, list.Lineactual, utiles.FormatearNumero(FloatToStr(StrToFloat(ta) * StrToFloat(ta))), 5, 'Arial, normal, 8', salida, 'S');

  list.Linea(0, 0, '', 1, 'Arial, normal, 10', salida, 'S');
  list.Linea(0, 0, 'Contextura', 1, 'Arial, normal, 8', salida, 'N');
  list.Linea(30, list.Lineactual, 'talla', 2, 'Arial, normal, 8', salida, 'N');
  list.Linea(51, list.Lineactual, '=', 3, 'Arial, normal, 8', salida, 'N');
  list.Linea(70, list.Lineactual, ta, 4, 'Arial, normal, 8', salida, 'N');
  list.Linea(77, list.Lineactual, '=', 5, 'Arial, normal, 8', salida, 'S');
  list.Linea(80, list.Lineactual, utiles.FormatearNumero(FloatToStr((StrToFloat(ta) * 100) / StrToFloat(circmunieca))), 6, 'Arial, negrita, 8', salida, 'S');
  list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'N');
  list.Linea(30, list.Lineactual, '----------------', 2, 'Arial, normal, 8', salida, 'N');
  list.Linea(70, list.Lineactual, '---------', 3, 'Arial, normal, 8', salida, 'S');
  list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'N');
  list.Linea(30, list.Lineactual, 'Circ. mu�eca', 2, 'Arial, normal, 8', salida, 'N');
  list.Linea(51, list.Lineactual, '=', 3, 'Arial, normal, 8', salida, 'N');
  list.Linea(70, list.Lineactual, circmunieca, 4, 'Arial, normal, 8', salida, 'S');

  diagnosticonut.getDatos(iddiag);
  list.Linea(0, 0, '', 1, 'Arial, normal, 10', salida, 'S');
  list.Linea(0, 0, 'Diagn�stico Nutricional:', 1, 'Arial, normal, 9', salida, 'N');
  list.Linea(21, list.Lineactual, diagnosticonut.Descrip, 2, 'Arial, negrita, 9', salida, 'S');

  list.Linea(0, 0, '', 1, 'Arial, normal, 10', salida, 'S');
  list.Linea(0, 0, 'Observaciones:', 1, 'Arial, negrita, 9, clNavy', salida, 'S');
  list.Linea(0, 0, '', 1, 'Arial, cursiva, 5', salida, 'S');
  list.Linea(0, 0, '', 1, 'Arial, cursiva, 8', salida, 'N');
  list.ListarMemo('diagnostico', 'Arial, cursiva, 8', historia, 500, 10, 2, salida);
end;

procedure TTHistoriaDietetica.ListarRequerimientos(xnropaciente: String; salida: char);
// Objetivo...: Listar Requerimientos y Formulas
var
  l, m: TStringList;
  i, j, p, k, p1, q: Integer;
  cal: Real;
  v: array[1..20] of Real;
  t: array[1..20] of Real;
Begin
  list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
  list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
  list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');

  list.Linea(0, 0, '', 1, 'Arial, normal, 10', salida, 'S');
  list.Linea(0, 0, 'Requerimientos', 1, 'Arial, negrita, 9, clNavy', salida, 'S');
  list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
  list.Linea(0, 0, 'Calor�as:', 1, 'Arial, normal, 9', salida, 'N');
  list.Linea(10, list.Lineactual, utiles.FormatearNumero(FloatToStr(Calorias)), 2, 'Arial, normal, 9', salida, 'N');
  list.Linea(17, list.Lineactual, 'cal. x ' , 3, 'Arial, normal, 9', salida, 'N');
  list.Linea(23, list.Lineactual, utiles.FormatearNumero(FloatToStr(Caloriaskg)), 4, 'Arial, normal, 9', salida, 'N');
  list.Linea(31, list.Lineactual, 'kg. = ', 5, 'Arial, normal, 9', salida, 'N');
  list.Linea(36, list.Lineactual, utiles.FormatearNumero(FloatToStr(calorias * Caloriaskg)), 6, 'Arial, normal, 9', salida, 'N');
  list.Linea(55, list.Lineactual, 'Formula Sint�tica', 7, 'Arial, normal, 9', salida, 'S');

  list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
  list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'N');
  list.Linea(70, list.Lineactual, 'HdeC  ' + utiles.FormatearNumero(FloatToStr(hdc1)) + ' %  ' + utiles.FormatearNumero(FloatToStr(CaloriasFS * (hdc1 * 0.01))) + '  cal.  ' + utiles.FormatearNumero(FloatToStr((CaloriasFS * (hdc1 * 0.01)) / 4)) + ' gr.', 2, 'Arial, normal, 8', salida, 'S');
  list.Linea(0, list.Lineactual, '', 1, 'Arial, normal, 8', salida, 'N');
  list.Linea(55, list.Lineactual, 'VCT:  ' + utiles.FormatearNumero(FloatToStr(CaloriasFS)) + ' cal.', 2, 'Arial, normal, 8', salida, 'N');
  list.Linea(70, list.Lineactual, 'Prot  ' + utiles.FormatearNumero(FloatToStr(prot1)) + ' %  ' + utiles.FormatearNumero(FloatToStr(CaloriasFS * (prot1 * 0.01))) + '  cal.  ' + utiles.FormatearNumero(FloatToStr((CaloriasFS * (prot1 * 0.01)) /4)) + ' gr.', 3, 'Arial, normal, 8', salida, 'S');
  list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'N');
  list.Linea(70, list.Lineactual, 'Grasas  ' + utiles.FormatearNumero(FloatToStr(grasas)) + ' %  ' + utiles.FormatearNumero(FloatToStr(CaloriasFS * (grasas * 0.01))) + '  cal.  ' + utiles.FormatearNumero(FloatToStr((CaloriasFS * (grasas * 0.01)) / 9)) + ' gr.', 2, 'Arial, normal, 8', salida, 'S');

  list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'S');
  list.Linea(0, 0, 'Formula Desarrollada', 1, 'Arial, negrita, 9, clNavy', salida, 'S');
  list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');

  m := setItemsFormulaDes('H'); k := 0;
  for j := 1 to m.Count do Begin
    p := Pos(';1', m.Strings[j-1]);
    if j = 1 then list.Linea(0, 0, 'Alimentos', 1, 'Arial, negrita, 8', salida, 'N');
    if not setColFilVisible(xnropaciente, 'H', Copy(m.Strings[j-1], p+2, 16)) then Begin
      Inc(k);
      list.Linea((8 * k) + 10, list.Lineactual, Copy(m.Strings[j-1], 4, p-4), k+1, 'Arial, negrita, 8', salida, 'N');
    end;
  end;
  list.Linea(95, list.Lineactual, '', k+2, 'Arial, normal, 8', salida, 'S');

  l := setRequerimientosDieta(xnropaciente);
  k := 0;
  for i := 1 to l.Count do Begin
    Inc(k);
    p := Pos(';1', l.Strings[i-1]);
    if (Copy(setItemsFormulaDes('V', Copy(l.Strings[i-1], 4, 14)), 1, 13) = 'Subtotal') or (Copy(setItemsFormulaDes('V', Copy(l.Strings[i-1], 4, 14)), 1, 13) = 'TOTAL') then list.Linea(0, 0, Copy(setItemsFormulaDes('V', Copy(l.Strings[i-1], 4, 14)), 1, 13), 1, 'Arial, negrita, 8', salida, 'N') else
      list.Linea(0, 0, Copy(setItemsFormulaDes('V', Copy(l.Strings[i-1], 4, 14)), 1, 13), 1, 'Arial, normal, 8', salida, 'N');
    if StrToFloat(utiles.FormatearNumero(Trim(Copy(l.Strings[i-1], p+2, 10)))) > 0 then list.Importe(23, list.Lineactual, '', StrToFloat(utiles.FormatearNumero(Trim(Copy(l.Strings[i-1], p+2, 10)))), 2, 'Arial, normal, 8') else
      list.Importe(23, list.Lineactual, '##', 0, 2, 'Arial, normal, 8');

    k := 1;
    for j := 2 to m.Count do Begin
      p := Pos(';1', m.Strings[j-1]);
      if not setColFilVisible(xnropaciente, 'H', Copy(m.Strings[j-1], p+2, 16)) then Begin
        Inc(k);
        p1 := Pos(';1', l.Strings[i-1]);
        cal := (StrToFloat(Trim(Copy(l.Strings[i-1], p1+2, 10))) * StrToFloat(setValorFD(Copy(l.Strings[i-1], 4, 14), Copy(m.Strings[j-1], p+2, 16)))) / 100;
        if cal > 0 then list.importe((8 * k) + 14, list.Lineactual, '', cal, k+1, 'Arial, normal, 8') else list.importe((8 * k) + 14, list.Lineactual, '####', 0, k+1, 'Arial, normal, 8');
        v[k] := v[k] + cal;
      end;
    end;

    if (Copy(setItemsFormulaDes('V', Copy(l.Strings[i-1], 4, 14)), 1, 13) = 'Subtotal') or (Copy(setItemsFormulaDes('V', Copy(l.Strings[i-1], 4, 14)), 1, 13) = 'TOTAL') then Begin
      for q := 2 to k do
        list.importe((8 * q) + 14, list.Lineactual, '', v[q], q, 'Arial, negrita, 8');
      list.Linea(95, list.Lineactual, '', q+1, 'Arial, negrita, 8', salida, 'S');
      for q := 1 to 10 do
        t[q] := t[q] + v[q];
    end;

    k := 0;
  end;
  l.Destroy; m.Destroy;
end;

procedure TTHistoriaDietetica.ListarParametrosBioquimicos(xnropaciente: String; salida: char);
// Objetivo...: Listar Par�metros Bioquimicos
var
  l: TStringList;
  i, p1, p2, col: Integer;
  T: array[1..100, 1..150] of String;
  N: array[1..100, 1..150] of String;
  R: array[1..100, 1..150] of String;
  obs: String;
Begin
  list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
  list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
  list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');

  list.Linea(0, 0, '', 1, 'Arial, normal, 10', salida, 'S');
  list.Linea(0, 0, 'Par�metros Bioqu�micos', 1, 'Arial, negrita, 9, clNavy', salida, 'S');
  list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');

  l := setParametrosBioquimicos;
  For i := 1 to l.Count do Begin
    p1 := Pos(';1', l.Strings[i-1]);
    T[i, 1] := '1;' + Copy(l.Strings[i-1], 4, p1-4);
    N[i, 1] := Copy(l.Strings[i-1], 1, 3);
  end;
  if i > 0 then col := i div 6 else col := 1;
  if i > 6 then
    if i mod 6 > 0 then Inc(col);

  l := setParametrosBioqPaciente(xnropaciente);
  For i := 1 to l.Count do Begin
    p1 := Pos(';1', l.Strings[i-1]);
    p2 := Pos(';2', l.Strings[i-1]);
    R[1, i] := Copy(l.Strings[i-1], 9, 5);
    R[2, i] := Copy(l.Strings[i-1], 14, 3);
    historiadiet.getDatosParametrosBioquimicos(R[2, i]);
    R[3, i] := historiadiet.Descrip;
    R[4, i] := Copy(l.Strings[i-1], 17, p1-17);
    R[5, i] := Copy(l.Strings[i-1], p1+2, (p2-p1)-2);
    R[6, i] := Copy(l.Strings[i-1], p2+2, 40);
    R[7, i] := Copy(l.Strings[i-1], 1, 8);
  end;

  For i := 1 to 50 do Begin
    if Length(Trim(R[1, i])) = 0 then Break;
    For p1 := 1 to 60 do Begin
      if R[2, i] = N[p1, 1] then Begin
        For p2 := 1 to 50 do Begin
          if (Length(Trim(T[p1, p2])) = 0) or (Copy(T[p1, p2], 1, 8) = R[6, i]) then Begin
            if Length(Trim(R[5, i])) > 0 then obs := '*' else obs := '';
            T[p1, p2] :=  R[7, i] + '  ' + R[4, i] + ' ' + obs;
            Break;
          end
        end;
      end;
    end;
  end;

  p2 := 0;
  For p1 := 1 to col+1 do Begin
    For i := 1 to 50 do Begin
      if (Length(Trim(T[p2 + 1, i] + T[p2 + 2, i] + T[p2 + 3, i] + T[p2 + 4, i] + T[p2 + 5, i]))) = 0 then Break;
      if Copy(T[p2 + 1, i], 1, 2) <> '1;' then list.Linea(0, 0, T[p2 + 1, i], 1, 'Arial, normal, 8', salida, 'N') else list.Linea(0, 0, Copy(T[p2 + 1, i], 3, 20), 1, 'Arial, negrita, 8', salida, 'N');
      if Copy(T[p2 + 2, i], 1, 2) <> '1;' then list.Linea(18, list.Lineactual, T[p2 + 2, i], 2, 'Arial, normal, 8', salida, 'N') else list.Linea(18, list.Lineactual, Copy(T[p2 + 2, i], 3, 20), 2, 'Arial, negrita, 8', salida, 'N');
      if Copy(T[p2 + 3, i], 1, 2) <> '1;' then list.Linea(36, list.Lineactual, T[p2 + 3, i], 3, 'Arial, normal, 8', salida, 'N') else list.Linea(36, list.Lineactual, Copy(T[p2 + 3, i], 3, 20), 3, 'Arial, negrita, 8', salida, 'N');
      if Copy(T[p2 + 4, i], 1, 2) <> '1;' then list.Linea(54, list.Lineactual, T[p2 + 4, i], 4, 'Arial, normal, 8', salida, 'N') else list.Linea(54, list.Lineactual, Copy(T[p2 + 4, i], 3, 20), 4, 'Arial, negrita, 8', salida, 'N');
      if Copy(T[p2 + 5, i], 1, 2) <> '1;' then list.Linea(90, list.Lineactual, T[p2 + 5, i], 5, 'Arial, normal, 8', salida, 'S') else list.Linea(90, list.Lineactual, Copy(T[p2 + 5, i], 3, 20), 5, 'Arial, negrita, 8', salida, 'S');
    end;
    p2 := p2 + 5;
    list.Linea(0, 0, '  ', 1, 'Arial, normal, 5', salida, 'S');
  end;
end;

procedure TTHistoriaDietetica.DefinirParametrosConextura(xsexo: String; xchica, xmediamin, xmediamax, xgrande: Real);
// Objetivo...: Definir conextura
Begin
  if contextura.FindKey([xsexo]) then contextura.Edit else contextura.Append;
  contextura.FieldByName('sexo').AsString  := xsexo;
  contextura.FieldByName('chico').AsFloat  := xchica;
  contextura.FieldByName('medmin').AsFloat := xmediamin;
  contextura.FieldByName('medmax').AsFloat := xmediamax;
  contextura.FieldByName('grande').AsFloat := xgrande;
  try
    contextura.Post
   except
    contextura.Cancel
  end;
  datosdb.closeDB(contextura); contextura.Open;
end;

procedure TTHistoriaDietetica.getDatosConextura(xsexo: String);
// Objetivo...: Recuperar una Instancia
begin
  if not contextura.Active then contextura.Open;
  if contextura.FindKey([xsexo]) then Begin
    Contextsexo   := contextura.FieldByName('sexo').AsString;
    ContextChico  := contextura.FieldByName('chico').AsFloat;
    ContextMin    := contextura.FieldByName('medmin').AsFloat;
    ContextMax    := contextura.FieldByName('medmax').AsFloat;
    ContextGrande := contextura.FieldByName('grande').AsFloat;
  end else Begin
    Contextsexo := ''; contextchico := 0; contextmin := 0; contextmax := 0; contextgrande := 0;
  end;
end;

function  TTHistoriaDietetica.DeterminarContextura(xsexo: String; xtalla, xcirmunieca: Real): String;
// Objetivo...: calcular contextura
var
  c: Real;
begin
  getDatosConextura(xsexo);
  c := (xtalla * 100) / xcirmunieca;
  if c < ContextGrande then Result := 'Grande';
  if (c > ContextMax) and (c < ContextMin) then Result := 'Mediana';
  if c > ContextChico then Result := 'Chica';
end;

procedure TTHistoriaDietetica.RegistrarFormulaSintetica(xvct, xhdc, xcal1, xgr1, xprot, xcal2, xgr2, xgra, xcal3, xgr3: Real);
// Objetivo...: cerrar tablas de persistencia
begin
  if fsintet.FindKey([xvct]) then fsintet.Edit else fsintet.Append;
  fsintet.FieldByName('vct').AsFloat  := xvct;
  fsintet.FieldByName('hdc').AsFloat  := xhdc;
  fsintet.FieldByName('cal1').AsFloat := xcal1;
  fsintet.FieldByName('gr1').AsFloat  := xgr1;
  fsintet.FieldByName('prot').AsFloat := xprot;
  fsintet.FieldByName('cal2').AsFloat := xcal2;
  fsintet.FieldByName('gr2').AsFloat  := xgr2;
  fsintet.FieldByName('gra').AsFloat  := xgra;
  fsintet.FieldByName('cal3').AsFloat := xcal3;
  fsintet.FieldByName('gr3').AsFloat  := xgr3;
  try
    fsintet.Post
   except
    fsintet.Cancel
  end;
  datosdb.closeDB(fsintet); fsintet.Open;
end;

procedure TTHistoriaDietetica.getRegistrarFormulaSintetica(xvct: Real);
// Objetivo...: cerrar tablas de persistencia
begin
  if not fsintet.Active then fsintet.Open;
  fsintet.First;
  if (fsintet.FindKey([xvct])) or (xvct = 0) then Begin
    vct  := fsintet.FieldByName('vct').AsFloat;
    hdc  := fsintet.FieldByName('hdc').AsFloat;
    cal1 := fsintet.FieldByName('cal1').AsFloat;
    gr1  := fsintet.FieldByName('gr1').AsFloat;
    prot := fsintet.FieldByName('prot').AsFloat;
    cal2 := fsintet.FieldByName('cal2').AsFloat;
    gr2  := fsintet.FieldByName('gr2').AsFloat;
    gra  := fsintet.FieldByName('gra').AsFloat;
    cal3 := fsintet.FieldByName('cal3').AsFloat;
    gr3  := fsintet.FieldByName('gr3').AsFloat;
  end else Begin
    hdc := 0; cal1 := 0; gr1 := 0; prot := 0; cal2 := 0; gr2 := 0; gra := 0; cal3 := 0; gr3 := 0; vct := 0;
  end;
end;

function  TTHistoriaDietetica.BuscarHistoriaSintetica(xvct: Real): Real;
// Objetivo...: Recuperar una historia dietetica
var
  r: Real;
Begin
  fsintet.First; r := 0;
  while not fsintet.Eof do Begin
    if fsintet.FieldByName('vct').AsFloat > xvct then Begin
      r := fsintet.FieldByName('vct').AsFloat;
      Break;
    end;
    fsintet.Next;
  end;
  if r = 0 then
    if xvct > fsintet.FieldByName('vct').AsFloat then Begin
      fsintet.Last;
      r := fsintet.FieldByName('vct').AsFloat;
    end;
  getRegistrarFormulaSintetica(r);
  Result := r;
end;

procedure TTHistoriaDietetica.RegistrarTotalCalorias(xcodpac: String; xtotcalorias: Real);
// Objetivo...: registrar formula desarrollada
begin
  if Buscar(xcodpac) then Begin
    historia.Edit;
    historia.FieldByName('caloriasfs').AsFloat := xtotcalorias;
    try
      historia.Post
     except
      historia.Cancel
    end;
    datosdb.closeDB(historia); historia.Open;
    IniciarColumnas;
    CaloriasFS := xtotcalorias;
  end;
end;

procedure TTHistoriaDietetica.RegistrarItemsFormulaDes(xlinea, xitems, xid, xdescrip: String; xcantidad: Integer);
// Objetivo...: registrar formula desarrollada
begin
  if formulades.IndexFieldNames <> 'linea;items' then formulades.IndexFieldNames := 'linea;items';
  if datosdb.Buscar(formulades, 'linea', 'items', xlinea, xitems) then formulades.Edit else formulades.Append;
  formulades.FieldByName('linea').AsString   := xlinea;
  formulades.FieldByName('items').AsString   := xitems;
  formulades.FieldByName('id').AsString      := xid;
  formulades.FieldByName('descrip').AsString := xdescrip;
  try
    formulades.Post
   except
    formulades.Cancel
  end;
  if xitems = utiles.sLlenarIzquierda(inttostr(xcantidad), 3, '0') then datosdb.tranSQL('delete from formula_desarrollada where items > ' + '''' + xitems + '''' + ' and linea = ' + '''' + xlinea + '''');
  datosdb.closeDB(formulades); formulades.Open;
end;

function  TTHistoriaDietetica.setItemsFormulaDes(xlinea: String): TStringList;
// Objetivo...: devolver los items
var
  l: TStringList;
Begin
  l := TStringList.Create;
  if formulades.IndexFieldNames <> 'linea;items' then formulades.IndexFieldNames := 'linea;items';
  if datosdb.Buscar(formulades, 'linea', 'items', xlinea, '001') then Begin
    while not formulades.Eof do Begin
      if formulades.FieldByName('linea').AsString <> xlinea then Break;
      l.Add(formulades.FieldByName('items').AsString + formulades.FieldByName('descrip').AsString + ';1' + formulades.FieldByName('id').AsString);
      formulades.Next;
    end;
  end;
  Result := l;
end;

function  TTHistoriaDietetica.setItemsFormulaDes(xlinea, xid: String): String;
// Objetivo...: Registrar Par�metros Bioquimicos
Begin
  if formulades.IndexFieldNames <> 'linea;id' then formulades.IndexFieldNames := 'linea;id';
  if datosdb.Buscar(formulades, 'linea', 'id', xlinea, xid) then Begin
    if Copy(formulades.FieldByName('descrip').AsString, 1, 1) <> '#' then Result := formulades.FieldByName('descrip').AsString else Result := Copy(formulades.FieldByName('descrip').AsString, 2, 40);
  end else Result := '';
end;

procedure TTHistoriaDietetica.RegistrarValoresEstandarFD(xitems1, xitems2: String; xvalor: Real; xcantitems: Integer);
// Objetivo...: Registrar Par�metros Bioquimicos
Begin
  if datosdb.Buscar(valoresfd, 'items1', 'items2', xitems1, xitems2) then valoresfd.Edit else valoresfd.Append;
  valoresfd.FieldByName('items1').AsString  := xitems1;
  valoresfd.FieldByName('items2').AsString  := xitems2;
  valoresfd.FieldByName('cantidad').AsFloat := xvalor;
  try
    valoresfd.Post
   except
    valoresfd.Cancel
  end;
  datosdb.refrescar(valoresfd);
end;

function  TTHistoriaDietetica.setValoresEstandar(xitems1, xitems2: String): String;
// Objetivo...: recuperar los valores estandar
Begin
  if datosdb.Buscar(valoresfd, 'items1', 'items2', xitems1, xitems2) then Result := valoresfd.FieldByName('cantidad').AsString else Result := '';
end;

function TTHistoriaDietetica.setValorFD(xitems1, xitems2: String): String;
// Objetivo...: Recuperar Par�metros Bioqu�micos
Begin
  if datosdb.Buscar(valoresfd, 'items1', 'items2', xitems1, xitems2) then Result := valoresfd.FieldByName('cantidad').AsString else Result := '0';
end;

function  TTHistoriaDietetica.BuscarParametrosBioquimicos(xitems: String): Boolean;
// Objetivo...: Registrar Par�metros Bioqu�micos
Begin
  if parametrosbioq.IndexFieldNames <> 'items' then parametrosbioq.IndexFieldNames := 'items';
  if parametrosbioq.FindKey([xitems]) then Result := True else Result := False;
end;

procedure TTHistoriaDietetica.RegistrarParametrosBioquimicos(xitems, xdescrip, xminimo, xmaximo, xreferencia: String);
// Objetivo...: Registrar Par�metros Bioqu�micos
Begin
  if BuscarParametrosBioquimicos(xitems) then parametrosbioq.Edit else parametrosbioq.Append;
  parametrosbioq.FieldByName('items').AsString      := xitems;
  parametrosbioq.FieldByName('descrip').AsString    := xdescrip;
  parametrosbioq.FieldByName('minimo').AsString     := xminimo;
  parametrosbioq.FieldByName('maximo').AsString     := xmaximo;
  parametrosbioq.FieldByName('referencia').AsString := xreferencia;
  try
    parametrosbioq.Post
   except
    parametrosbioq.Cancel
  end;
  datosdb.closeDB(parametrosbioq); parametrosbioq.Open;
end;

function  TTHistoriaDietetica.setParametrosBioquimicos: TStringList;
// Objetivo...: Registrar Par�metros Bioqu�micos
var
  l: TStringList;
Begin
  l := TStringList.Create;
  if not parametrosbioq.Active then parametrosbioq.Open;
  parametrosbioq.IndexFieldNames := 'Items';
  parametrosbioq.First;
  while not parametrosbioq.Eof do Begin
    l.Add(parametrosbioq.FieldByName('items').AsString + parametrosbioq.FieldByName('descrip').AsString + ';1' + parametrosbioq.FieldByName('minimo').AsString + ';2' +
          parametrosbioq.FieldByName('maximo').AsString + ';3' + parametrosbioq.FieldByName('referencia').AsString);
    parametrosbioq.Next;
  end;
  Result := l;
end;

procedure TTHistoriaDietetica.getDatosParametrosBioquimicos(xitems: String);
// Objetivo...: cerrar tablas de persistencia
begin
  if BuscarParametrosBioquimicos(xitems) then Begin
    descrip    := parametrosbioq.FieldByName('descrip').AsString;
    minimo     := parametrosbioq.FieldByName('minimo').AsString;
    maximo     := parametrosbioq.FieldByName('maximo').AsString;
    referencia := parametrosbioq.FieldByName('referencia').AsString;
  end else Begin
    descrip := ''; minimo := ''; maximo := ''; referencia := '';
  end;
end;

procedure TTHistoriaDietetica.BorrarParametrosBioquimicos(xitems: String);
// Objetivo...: Borrar Par�metros Bioqu�micos
Begin
  if BuscarParametrosBioquimicos(xitems) then parametrosbioq.Delete;
end;

function TTHistoriaDietetica.NuevoParametroBioquimico: String;
// Objetivo...: Generar Nuevo Par�metro Bioquimico
Begin
  if parametrosbioq.RecordCount = 0 then Result := '1' else Begin
    parametrosbioq.IndexFieldNames := 'items';
    parametrosbioq.Last;
    Result := IntToStr(parametrosbioq.FieldByName('items').AsInteger + 1);
  end;
end;

procedure TTHistoriaDietetica.BuscarPorDescripPB(xexpresion: String);
// objetivo...: Buscar por descripci�n PB
Begin
  if parametrosbioq.IndexFieldNames <> 'descrip' then parametrosbioq.IndexFieldNames := 'descrip';
  parametrosbioq.FindNearest([xexpresion]);
end;

procedure TTHistoriaDietetica.BuscarPorItemsPB(xexpresion: String);
// objetivo...: Buscar por items PB
Begin
  if parametrosbioq.IndexFieldNames <> 'items' then parametrosbioq.IndexFieldNames := 'items';
  parametrosbioq.FindNearest([xexpresion]);
end;

function  TTHistoriaDietetica.BuscarParametrosBioqPaciente(xnropaciente, xitems: String): Boolean;
// Objetivo...: Buscar Instancia
begin
  if pb_pac.IndexFieldNames <> 'nropaciente;items' then pb_pac.IndexFieldNames := 'nropaciente;items';
  Result := datosdb.Buscar(pb_pac, 'nropaciente', 'items', xnropaciente, xitems);
end;

procedure TTHistoriaDietetica.RegistrarParametrosBioqPaciente(xnropaciente, xfecha, xitems, xcodigo, xvalor, xobservacion, xreferencia: String; xcantitems: Integer);
// Objetivo...: Registrar Instancia
begin
  if BuscarParametrosBioqPaciente(xnropaciente, xitems) then pb_pac.Edit else pb_pac.Append;
  pb_pac.FieldByName('nropaciente').AsString := xnropaciente;
  pb_pac.FieldByName('items').AsString       := xitems;
  pb_pac.FieldByName('fecha').AsString       := utiles.sExprFecha2000(xfecha);
  pb_pac.FieldByName('codigo').AsString      := xcodigo;
  pb_pac.FieldByName('valor').AsString       := xvalor;
  pb_pac.FieldByName('observacion').AsString := xobservacion;
  pb_pac.FieldByName('referencia').AsString  := xreferencia;
  try
    pb_pac.Post
   except
    pb_pac.Cancel
  end;

  if xitems = utiles.sLlenarIzquierda(IntToStr(xcantitems), 5, '0') then Begin
    datosdb.tranSQL('delete from ' + pb_pac.TableName + ' where nropaciente = ' + '''' + xnropaciente + '''' + ' and items > '  + '''' + xitems + '''');
    datosdb.closeDB(pb_pac); pb_pac.Open;
  end;
end;

function  TTHistoriaDietetica.setParametrosBioqPaciente(xnropaciente: String): TStringList;
// Objetivo...: Devolver Set con los par�metros bioq�micos
var
  l: TStringList;
begin
  l := TStringList.Create;
  if not pb_pac.Active then pb_pac.Open;
  if pb_pac.IndexFieldNames <> 'nropaciente;items' then pb_pac.IndexFieldNames := 'nropaciente;items';
  if pb_pac.FindKey([xnropaciente]) then Begin
    while not pb_pac.Eof do Begin
      if pb_pac.FieldByName('nropaciente').AsString <> xnropaciente then Break;
      l.Add(utiles.sFormatoFecha(pb_pac.FieldByName('fecha').AsString) + pb_pac.FieldByName('items').AsString + pb_pac.FieldByName('codigo').AsString + pb_pac.FieldByName('valor').AsString + ';1' + pb_pac.FieldByName('observacion').AsString + ';2' + pb_pac.FieldByName('referencia').AsString);
      pb_pac.Next;
    end;
  end;
  Result := l;
end;

procedure TTHistoriaDietetica.BorrarParametrosBioqPaciente(xnropaciente: String);
// Objetivo...: Borrar Par�metros Bioquimicos
Begin
  datosdb.tranSQL('delete from ' + pb_pac.TableName + ' where nropaciente = ' + '''' + xnropaciente + '''');
  datosdb.refrescar(pb_pac);
end;

function  TTHistoriaDietetica.setParametrosBioqPacienteLista(xnropaciente: String): TStringList;
// Objetivo...: Devolver Set con los par�metros bioq�micos
var
  l: TStringList;
begin
  l := TStringList.Create;
  datosdb.Filtrar(pb_pac, 'nropaciente = ' + '''' + xnropaciente + '''');
  if not pb_pac.Eof then Begin
    while not pb_pac.Eof do Begin
      if pb_pac.FieldByName('nropaciente').AsString <> xnropaciente then Break;
      l.Add(utiles.sFormatoFecha(pb_pac.FieldByName('fecha').AsString) + pb_pac.FieldByName('items').AsString + pb_pac.FieldByName('valor').AsString + ';1' + pb_pac.FieldByName('observacion').AsString + ';2' + pb_pac.FieldByName('referencia').AsString);
      pb_pac.Next;
    end;
  end;
  datosdb.QuitarFiltro(pb_pac);
  Result := l;
end;

procedure TTHistoriaDietetica.OcultarColFil(xcodpac, xhv, xitems: String);
// Objetivo...: Determinar las columnas visibles
Begin
  columnas_oc.Open;
  if datosdb.Buscar(columnas_oc, 'nropaciente', 'hv', 'items', xcodpac, xhv, xitems) then columnas_oc.Edit else columnas_oc.Append;
  columnas_oc.FieldByName('nropaciente').AsString := xcodpac;
  columnas_oc.FieldByName('hv').AsString          := xhv;
  columnas_oc.FieldByName('items').AsString       := xitems;
  try
    columnas_oc.Post
   except
    columnas_oc.Cancel
  end;
  datosdb.closeDB(columnas_oc);
end;

procedure TTHistoriaDietetica.BorrarColFil(xcodpac, xhv, xitems: String);
// Objetivo...: Borrar las columnas visibles
Begin
  columnas_oc.Open;
  if datosdb.Buscar(columnas_oc, 'nropaciente', 'hv', 'items', xcodpac, xhv, xitems) then columnas_oc.Delete;
  datosdb.closeDB(columnas_oc);
end;

function  TTHistoriaDietetica.setColFil(xcodpac, xhv: String): TStringList;
// Objetivo...: Devolver Columnas
var
  l: TStringList;
Begin
  columnas_oc.Open;
  datosdb.Filtrar(columnas_oc, 'nropaciente = ' + '''' + xcodpac + '''' + ' and hv = ' + '''' + xhv + '''');
  l := TStringList.Create;
  while not columnas_oc.Eof do Begin
    l.Add(columnas_oc.FieldByName('items').AsString);
    columnas_oc.Next;
  end;
  datosdb.QuitarFiltro(columnas_oc);
  Result := l;
end;

function TTHistoriaDietetica.setColFilVisible(xcodpac, xhv, xitems: String): Boolean;
// Objetivo...: Controlar si el items esta o no visible
begin
  columnas_oc.Open;
  if datosdb.Buscar(columnas_oc, 'nropaciente', 'hv', 'items', xcodpac, xhv, xitems) then Result := True else Result := False;
  datosdb.closeDB(columnas_oc);
end;

procedure TTHistoriaDietetica.BorrarColFil(xcodpac: String);
// Objetivo...: Borrar Filas/Columnas ocultas de un paciente
Begin
  datosdb.tranSQL('delete from ' + columnas_oc.TableName + ' where nropaciente = ' + '''' + xcodpac + '''');
  datosdb.refrescar(columnas_oc); 
end;

function  TTHistoriaDietetica.BuscarTurno(xfecha, xitems: String): Boolean;
// Objetivo...: Buscar Turno
begin
  Result := datosdb.Buscar(turnos, 'fecha', 'items', utiles.sExprFecha2000(xfecha), xitems);
end;

procedure TTHistoriaDietetica.RegistrarTurno(xfecha, xitems, xhora, xcodpac, xnombre, xmotivo, xtelefono, xtt, xatencion: String; xdebe: Real; xcantitems: Integer);
// Objetivo...: Registrar Turnos
begin
  turnos.Open;
  if BuscarTurno(xfecha, xitems) then turnos.Edit else turnos.Append;
  turnos.FieldByName('fecha').AsString    := utiles.sExprFecha2000(xfecha);
  turnos.FieldByName('items').AsString    := xitems;
  turnos.FieldByName('hora').AsString     := xhora;
  turnos.FieldByName('codpac').AsString   := xcodpac;
  turnos.FieldByName('nombre').AsString   := xnombre;
  turnos.FieldByName('opcion').AsString   := xmotivo;
  turnos.FieldByName('telefono').AsString := xtelefono;
  turnos.FieldByName('atencion').AsString := xatencion;
  turnos.FieldByName('tt').AsString       := xtt;
  turnos.FieldByName('debe').AsFloat      := xdebe;
  try
    turnos.Post
   except
    turnos.Cancel
  end;
  datosdb.closeDB(turnos);
  if xitems = utiles.sLlenarIzquierda(IntToStr(xcantitems), 2, '0') then datosdb.tranSQL('delete from turnos where fecha = ' + '''' + utiles.sExprFecha2000(xfecha) + '''' + ' and items > ' + '''' + xitems + '''');
end;

function  TTHistoriaDietetica.setTurnos(xfecha: String): TStringList;
// Objetivo...: Recuperar Turnos
var
  l: TStringList;
  tt: String;
begin
  turnos.Open;
  l := TStringList.Create;
  if BuscarTurno(xfecha, '01') then Begin
    while not turnos.Eof do Begin
      if turnos.FieldByName('fecha').AsString <> utiles.sExprFecha2000(xfecha) then Break;
      if Length(Trim(turnos.FieldByName('tt').AsString)) > 0 then tt := turnos.FieldByName('tt').AsString else tt := 'M';
      l.Add(turnos.FieldByName('items').AsString + turnos.FieldByName('hora').AsString + turnos.FieldByName('codpac').AsString + turnos.FieldByName('nombre').AsString + ';1' + turnos.FieldByName('opcion').AsString + ';2' + utiles.FormatearNumero(turnos.FieldByName('debe').AsString) + ';3' + turnos.FieldByName('telefono').AsString + ';4' + tt + turnos.FieldByName('atencion').AsString);
      turnos.Next;
    end;
  end;
  turnos.Close;
  Result := l;
end;

procedure TTHistoriaDietetica.ListarTurnos(xfecha, xmaniana_tarde, xtitulo1, xtitulo2, xtitulo3: String; salida: char);
var
  f, lm: Boolean;
Begin
  list.Setear(salida);
  //list.NoImprimirPieDePagina;
  list.SaltarHojaSinNumerarPagina;
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 10');
  if Length(Trim(xtitulo1)) > 0 then List.Titulo(0, 0, xtitulo1, 1, 'Arial, normal, 9');
  if Length(Trim(xtitulo2)) > 0 then List.Titulo(0, 0, xtitulo2, 1, 'Arial, normal, 8');
  if Length(Trim(xtitulo3)) > 0 then List.Titulo(0, 0, xtitulo3, 1, 'Arial, normal, 8');
  List.Titulo(0, 0, 'Turnos para el d�a - ' + (FormatDateTime( 'dddd, d "de" mmmm "del" yyyy', StrToDate(xfecha))), 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Hora', 1, 'Arial, cursiva, 9');
  List.Titulo(12, list.Lineactual, 'Nombre del Paciente', 2, 'Arial, cursiva, 9');
  List.Titulo(49, list.Lineactual, 'Mot.', 3, 'Arial, cursiva, 9');
  List.Titulo(60, list.Lineactual, 'Debe', 4, 'Arial, cursiva, 9');
  List.Titulo(90, list.Lineactual, 'Tel�fono', 5, 'Arial, cursiva, 9');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  turnos.Open;
  if BuscarTurno(xfecha, '01') then Begin
    while not turnos.Eof do Begin
      lm := False;
      if xmaniana_tarde = 'X' then lm := True;
      if xmaniana_tarde = 'M' then
        if Copy(turnos.FieldByName('hora').AsString, 1, 2) <= '14' then lm := True;
      if xmaniana_tarde = 'T' then
        if Copy(turnos.FieldByName('hora').AsString, 1, 2) >= '15' then lm := True;
      if lm then Begin
        if turnos.FieldByName('fecha').AsString <> utiles.sExprFecha2000(xfecha) then Break;
        list.Linea(0, 0, turnos.FieldByName('hora').AsString, 1, 'Arial, normal, 9', salida, 'N');
        if turnos.FieldByName('codpac').AsString = '00000' then nombre := turnos.FieldByName('nombre').AsString else getDatos(turnos.FieldByName('codpac').AsString);
        list.Linea(12, list.Lineactual, nombre, 2, 'Arial, normal, 9', salida, 'N');
        list.Linea(50, list.Lineactual, turnos.FieldByName('opcion').AsString, 3, 'Arial, normal, 9', salida, 'N');
        list.importe(65, list.Lineactual, '', turnos.FieldByName('debe').AsFloat, 4, 'Arial, normal, 9');
        list.Linea(80, list.Lineactual, turnos.FieldByName('telefono').AsString, 5, 'Arial, normal, 9', salida, 'S');
        list.Linea(0, 0, '................................................................................................................................................................................................................................................', 1, 'Arial, normal, 9', salida, 'S');
        f := True;
      end;
      turnos.Next;
    end;
  end;
  turnos.Close;

  if not f then list.Linea(0, 0, 'No hay Turnos Otorgados !' , 1, 'Arial, normal, 10', salida, 'S');
  list.CompletarPagina;
  list.FinList;
end;

procedure TTHistoriaDietetica.ListarResumenTurnos(xdesde, xhasta, xtitulo1, xtitulo2, xtitulo3: String; salida: char);
var
  f: Boolean;
  l1: array[1..31] of String;
  l2: array[1..31] of String;
  m1: array[1..31] of String;
  m2: array[1..31] of String;
  i, p, t, n, maxm, maxt, x: Integer;
Begin
  For i := 1 to 60 do
    For p := 1 to 25 do Begin
      listam[i, p] := '';
      listat[i, p] := '';
    end;

  list.Setear(salida);
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 10');
  if Length(Trim(xtitulo1)) > 0 then List.Titulo(0, 0, xtitulo1, 1, 'Arial, normal, 9');
  if Length(Trim(xtitulo2)) > 0 then List.Titulo(0, 0, xtitulo2, 1, 'Arial, normal, 8');
  if Length(Trim(xtitulo3)) > 0 then List.Titulo(0, 0, xtitulo3, 1, 'Arial, normal, 8');
  List.Titulo(0, 0, 'Resumen Turnos Semana: ' + xdesde + ' al ' + xhasta, 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Lunes', 1, 'Arial, cursiva, 9');
  List.Titulo(22, list.Lineactual, 'Martes', 2, 'Arial, cursiva, 9');
  List.Titulo(44, list.Lineactual, 'Mi�rcoles', 3, 'Arial, cursiva, 9');
  List.Titulo(66, list.Lineactual, 'Jueves', 4, 'Arial, cursiva, 9');
  List.Titulo(88, list.Lineactual, 'Viernes', 5, 'Arial, cursiva, 9');
  List.Titulo(0, 0, xdesde, 1, 'Arial, cursiva, 9');
  List.Titulo(22, list.Lineactual, utiles.FechaSumarDias(xdesde, 1), 2, 'Arial, cursiva, 9');
  List.Titulo(44, list.Lineactual, utiles.FechaSumarDias(xdesde, 2), 3, 'Arial, cursiva, 9');
  List.Titulo(66, list.Lineactual, utiles.FechaSumarDias(xdesde, 3), 4, 'Arial, cursiva, 9');
  List.Titulo(88, list.Lineactual, utiles.FechaSumarDias(xdesde, 4), 5, 'Arial, cursiva, 9');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  turnos.Open;
  datosdb.Filtrar(turnos, 'fecha >= ' + '''' + utiles.sExprFecha2000(xdesde) + '''' + ' and fecha <= ' + '''' + utiles.sExprFecha2000(xhasta) + '''');
  while not turnos.Eof do Begin
    if Length(Trim(turnos.FieldByName('atencion').AsString)) = 3 then atencionpac.getDatos(turnos.FieldByName('atencion').AsString);
    if Copy(turnos.FieldByName('hora').AsString, 1, 2) <= '14' then Begin
      // Rastreamos el 1� Turno - Ma�ana
      if Length(Trim(Copy(turnos.FieldByName('codpac').AsString, 1, 2))) > 0 then Begin
        if Length(Trim(l1[StrToInt(Copy(turnos.FieldByName('fecha').AsString, 7, 2))])) = 0 then l1[StrToInt(Copy(turnos.FieldByName('fecha').AsString, 7, 2))] := 'M' + turnos.FieldByName('hora').AsString;
        // 2� Turno
        l2[StrToInt(Copy(turnos.FieldByName('fecha').AsString, 7, 2))] := 'M' + turnos.FieldByName('hora').AsString + '  ' + UpperCase(Copy(atencionpac.descrip, 1, 6));
      end;
      // Detalle de turnos
      if Length(Trim(Copy(turnos.FieldByName('codpac').AsString, 1, 2))) > 0 then Begin
        for n := 1 to 50 do
          if Length(Trim(listam[n, StrToInt(Copy(turnos.FieldByName('fecha').AsString, 7, 2))])) = 0 then Break;
        listam[n, StrToInt(Copy(turnos.FieldByName('fecha').AsString, 7, 2))] := 'M' + turnos.FieldByName('hora').AsString + '  ' + turnos.FieldByName('nombre').AsString;
        if n > maxm then maxm := n;
      end;
    end;
    if Copy(turnos.FieldByName('hora').AsString, 1, 2) > '15' then Begin
      // Rastreamos el 1� Turno - Tarde
      if Length(Trim(Copy(turnos.FieldByName('codpac').AsString, 1, 2))) > 0 then Begin
        if Length(Trim(m1[StrToInt(Copy(turnos.FieldByName('fecha').AsString, 7, 2))])) = 0 then m1[StrToInt(Copy(turnos.FieldByName('fecha').AsString, 7, 2))] := 'T' + Copy(turnos.FieldByName('fecha').AsString, 7, 2) + turnos.FieldByName('hora').AsString;
        // 2� Turno
        m2[StrToInt(Copy(turnos.FieldByName('fecha').AsString, 7, 2))] := 'T' + Copy(turnos.FieldByName('fecha').AsString, 7, 2) + turnos.FieldByName('hora').AsString + '  ' + UpperCase(Copy(atencionpac.descrip, 1, 6));
      end;
      // Detalle de turnos
      if Length(Trim(Copy(turnos.FieldByName('codpac').AsString, 1, 2))) > 0 then Begin
        for n := 1 to 50 do
          if Length(Trim(listat[n, StrToInt(Copy(turnos.FieldByName('fecha').AsString, 7, 2))])) = 0 then Break;
        listat[n, StrToInt(Copy(turnos.FieldByName('fecha').AsString, 7, 2))] := 'T' + turnos.FieldByName('hora').AsString + '  ' + turnos.FieldByName('nombre').AsString;
        if n > maxt then maxt := n;
      end;
    end;
    turnos.Next;
  end;
  datosdb.QuitarFiltro(turnos);
  turnos.Close;

  t := 0;               // 1� Linea Ma�ana
  For i := 1 to 5 do Begin
    if i = 1 then p := StrToInt(Copy(xdesde, 1, 2)) else
      p := StrToInt(Copy(xdesde, 1, 2)) + (i-1);

    // Ajustamos el d�a
    if p > StrToInt(utiles.ultimodiames(Copy(xdesde, 4, 2), Copy(utiles.sExprFecha2000(xdesde), 1, 4))) then
      p := p - StrToInt(utiles.ultimodiames(Copy(xdesde, 4, 2), Copy(utiles.sExprFecha2000(xdesde), 1, 4)));

    if i = 1 then Begin
      if Copy(l1[p], 1, 1) = 'M' then list.Linea(0, 0, Trim(Copy(l1[p], 2, 12)) + '-' + TrimLeft(Copy(l2[p], 2, 15)), 1, 'Arial, negrita, 9', salida, 'N') else list.Linea(0, 0, '', 1, 'Arial, negrita, 9', salida, 'N');
    end else Begin
      t := t + 22;
      if Copy(l1[p], 1, 1) = 'M' then list.Linea(t, list.Lineactual, Trim(Copy(l1[p], 2, 12)) + '-' + TrimLeft(Copy(l2[p], 2, 15)), i, 'Arial, negrita, 9', salida, 'N') else list.Linea(0, 0, '', i, 'Arial, negrita, 9', salida, 'N');
    end;
  end;
  list.Linea(t+5, list.Lineactual, '', i+1, 'Arial, normal, 9', salida, 'S');

  list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');

  //----------------------------------------------------------------------------

  for x := 1 to maxm do Begin // Detalle Turnos Ma�ana
    t := 0;
    For i := 1 to 5 do Begin
      if i = 1 then p := StrToInt(Copy(xdesde, 1, 2)) else
        p := StrToInt(Copy(xdesde, 1, 2)) + (i-1);

      // Ajustamos el d�a
      if p > StrToInt(utiles.ultimodiames(Copy(xdesde, 4, 2), Copy(utiles.sExprFecha2000(xdesde), 1, 4))) then
        p := p - StrToInt(utiles.ultimodiames(Copy(xdesde, 4, 2), Copy(utiles.sExprFecha2000(xdesde), 1, 4)));

      if i = 1 then Begin
        if Copy(listam[x, p], 1, 1) = 'M' then list.Linea(0, 0, Copy(listam[x, p], 2, 27), 1, 'Arial, normal, 8', salida, 'N') else list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'N');
      end else Begin
        t := t + 22;
        if Copy(listam[x, p], 1, 1) = 'M' then list.Linea(t, list.Lineactual, Copy(listam[x, p], 2, 27), i, 'Arial, normal, 8', salida, 'N') else list.Linea(0, 0, '', i, 'Arial, normal, 8', salida, 'N');
      end;

      list.Linea(t+15, list.Lineactual, '', i+1, 'Arial, normal, 9', salida, 'S');
    end;
  end;

  list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
  list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'S');

  //----------------------------------------------------------------------------

  t := 0;               // 1� Linea Tarde
  For i := 1 to 5 do Begin
    if i = 1 then p := StrToInt(Copy(xdesde, 1, 2)) else
      p := StrToInt(Copy(xdesde, 1, 2)) + (i-1);

    // Ajustamos el d�a
    if p > StrToInt(utiles.ultimodiames(Copy(xdesde, 4, 2), Copy(utiles.sExprFecha2000(xdesde), 1, 4))) then
      p := p - StrToInt(utiles.ultimodiames(Copy(xdesde, 4, 2), Copy(utiles.sExprFecha2000(xdesde), 1, 4)));

    if i = 1 then Begin
      if Copy(m1[p], 1, 1) = 'T' then list.Linea(0, 0, Trim(Copy(m1[p], 4, 12)) + '-' + TrimLeft(Copy(m2[p], 4, 15)), 1, 'Arial, negrita, 9', salida, 'N') else list.Linea(0, 0, '', 1, 'Arial, negrita, 9', salida, 'N');
    end else Begin
      t := t + 22;
      if Copy(m1[p], 1, 1) = 'T' then list.Linea(t, list.Lineactual, Trim(Copy(m1[p], 4, 12)) + '-' + TrimLeft(Copy(m2[p], 4, 15)), i, 'Arial, negrita, 9', salida, 'N') else list.Linea(0, 0, '', i, 'Arial, negrita, 9', salida, 'N');
    end;
  end;
  list.Linea(t+15, list.Lineactual, '', i+1, 'Arial, normal, 9', salida, 'S');

  list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');

  //----------------------------------------------------------------------------

  for x := 1 to maxt do Begin // Detalle Turnos Tarde
    t := 0;
    For i := 1 to 5 do Begin
      if i = 1 then p := StrToInt(Copy(xdesde, 1, 2)) else
        p := StrToInt(Copy(xdesde, 1, 2)) + (i-1);

      // Ajustamos el d�a
      if p > StrToInt(utiles.ultimodiames(Copy(xdesde, 4, 2), Copy(utiles.sExprFecha2000(xdesde), 1, 4))) then
        p := p - StrToInt(utiles.ultimodiames(Copy(xdesde, 4, 2), Copy(utiles.sExprFecha2000(xdesde), 1, 4)));

      if i = 1 then Begin
        if Copy(listat[x, p], 1, 1) = 'T' then list.Linea(0, 0, Copy(listat[x, p], 2, 27), 1, 'Arial, normal, 8', salida, 'N') else list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'N');
      end else Begin
        t := t + 22;
        if Copy(listat[x, p], 1, 1) = 'T' then list.Linea(t, list.Lineactual, Copy(listat[x, p], 2, 27), i, 'Arial, normal, 8', salida, 'N') else list.Linea(0, 0, '', i, 'Arial, normal, 8', salida, 'N');
      end;

      list.Linea(t+15, list.Lineactual, '', i+1, 'Arial, normal, 9', salida, 'S');
    end;
  end;

  list.Linea(0, 0, '', 1, 'Arial, normal, 12', salida, 'S');

  //----------------------------------------------------------------------------

  list.FinList;
end;

procedure TTHistoriaDietetica.EstablecerHoras(xhoram1, xhoram2, xhorat1, xhorat2: String);
// Objetivo...: cerrar tablas de persistencia
begin
  AssignFile(archivo, dbs.DirSistema + '\ctrlhoras.ini');
  Rewrite(archivo);
  WriteLn(archivo, xhoram1);
  WriteLn(archivo, xhoram2);
  WriteLn(archivo, xhorat1);
  WriteLn(archivo, xhorat2);
  closeFile(archivo);
end;

procedure TTHistoriaDietetica.getHoras;
// Objetivo...: cerrar tablas de persistencia
begin
  if FileExists(dbs.DirSistema + '\ctrlhoras.ini') then Begin
    AssignFile(archivo, dbs.DirSistema + '\ctrlhoras.ini');
    Reset(archivo);
    ReadLn(archivo, horam1);
    ReadLn(archivo, horam2);
    ReadLn(archivo, horat1);
    ReadLn(archivo, horat2);
    closeFile(archivo);
  end;
end;

procedure TTHistoriaDietetica.BorrarTurnos(xfecha: String);
// Objetivo...: Borrar turnos
Begin
  datosdb.tranSQL('delete from turnos where fecha = ' + '''' + utiles.sExprFecha2000(xfecha) + '''');
  datosdb.refrescar(turnos);
end;

procedure TTHistoriaDietetica.DepurarTurnos(xfecha: String);
// Objetivo...: Depurar Turnos
Begin
  datosdb.tranSQL('delete from turnos where fecha <= ' + '''' + utiles.sExprFecha2000(xfecha) + '''');
end;

procedure TTHistoriaDietetica.FiltrarFechas(xdfecha, xhfecha: String);
// Objetivo...: Filtrar Datos por Rango de Fechas
begin
  datosdb.Filtrar(historia, 'fecha >= ' + '''' + utiles.sExprFecha2000(xdfecha) + '''' + ' and fecha <= ' + '''' + utiles.sExprFecha2000(xhfecha) + '''');
end;

procedure TTHistoriaDietetica.QuitarFiltro;
// Objetivo...: Quitar Filtro
begin
  datosdb.QuitarFiltro(historia);
end;

function  TTHistoriaDietetica.verificarAnamnesisRegistrada(xitems: String): Boolean;
// Objetivo...: verificar Items
begin
  rsql := datosdb.tranSQL('select items from anamnesis_paciente where items = ' + '''' + xitems + '''');
  rsql.Open;
  if rsql.RecordCount > 0 then Result := True else Result := False;
  rsql.Close;
end;

function  TTHistoriaDietetica.verificarTablaValores(xitems: String): Boolean;
// Objetivo...: verificar Items
begin
  rsql := datosdb.tranSQL('select idtabla from historiadiet_paciente where idtabla = ' + '''' + xitems + '''');
  rsql.Open;
  if rsql.RecordCount > 0 then Result := True else Result := False;
  rsql.Close;
end;

function  TTHistoriaDietetica.verificarRequerimientos(xitems: String): Boolean;
// Objetivo...: verificar Items
begin
  rsql := datosdb.tranSQL('select it from requerimientos_paciente where it = ' + '''' + xitems + '''');
  rsql.Open;
  if rsql.RecordCount > 0 then Result := True else Result := False;
  rsql.Close;
end;

function  TTHistoriaDietetica.verificarParametrosBioquimicos(xitems: String): Boolean;
// Objetivo...: verificar Items
begin
  rsql := datosdb.tranSQL('select codigo from parametrosbioq_paciente where codigo = ' + '''' + xitems + '''');
  rsql.Open;
  if rsql.RecordCount > 0 then Result := True else Result := False;
  rsql.Close;
end;

procedure TTHistoriaDietetica.IniciarColumnas;
// Objetivo...: cerrar tablas de persistencia
begin
  historia.FieldByName('nropaciente').DisplayLabel := 'Nro.'; historia.FieldByName('nombre').DisplayLabel := 'Nombre del Paciente'; historia.FieldByName('telefono').DisplayLabel := 'Tel�fono';
  historia.FieldByName('fecha').Visible := False; historia.FieldByName('peso').Visible := False; historia.FieldByName('fechanac').Visible := False; historia.FieldByName('circmunieca').Visible := False;
  historia.FieldByName('ocupacion').Visible := False; historia.FieldByName('actfisica').Visible := False; historia.FieldByName('comidasrealiza').Visible := False; historia.FieldByName('quiencocina').Visible := False;
  historia.FieldByName('picotea').Visible := False; historia.FieldByName('alergia').Visible := False; historia.FieldByName('familia').Visible := False; historia.FieldByName('realizadieta').Visible := False;
  historia.FieldByName('logroresult').Visible := False; historia.FieldByName('espectativa').Visible := False; historia.FieldByName('tiempo').Visible := False; historia.FieldByName('motivoconsulta').Visible := False;
  historia.FieldByName('sexo').Visible := False; historia.FieldByName('idtabla').Visible := False; historia.FieldByName('sobrepeso').Visible := False; historia.FieldByName('diagnostico').Visible := False;
  historia.FieldByName('agregar').Visible := False; historia.FieldByName('caloriasfs').Visible := False; historia.FieldByName('iddiag').Visible := False;
  historia.FieldByName('calorias').Visible := False; historia.FieldByName('caloriaskg').Visible := False;
  historia.FieldByName('atencion').Visible := False; historia.FieldByName('hdc').Visible := False; historia.FieldByName('prot').Visible := False; historia.FieldByName('grasas').Visible := False;
  historia.FieldByName('pesoteorico').Visible := False; historia.FieldByName('sob1').Visible := False; historia.FieldByName('sob2').Visible := False; historia.FieldByName('sob3').Visible := False;
end;

function TTHistoriaDietetica.ObtenerFotoSiguiente(xcodpac: String): String;
// Objetivo...: obtener foto siguiente
var
  h: String;
begin
  h := utiles.sExprFecha2000(utiles.setFechaActual);
  Result := dbs.DirSistema + '\fotos\' + xcodpac + h + '.jpg';
end;

function TTHistoriaDietetica.setFotos: TStringList;
// Objetivo...: retornar fotos
begin
  lista.Sort;
  Result := lista;
end;

function TTHistoriaDietetica.setCantidadPacientes: Integer;
// Objetivo...: Devolver las Historias Dieteticas Procesadas
Begin
  Result := historia.RecordCount;
end;

procedure TTHistoriaDietetica.conectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones = 0 then Begin
    if not historia.Active then historia.Open;
    if not anpac.Active then anpac.Open;
    if not tpeso.Active then tpeso.Open;
    if not contextura.Active then contextura.Open;
    if not fsintet.Active then fsintet.Open;
    if not formulades.Active then formulades.Open;
    if not parametrosbioq.Active then parametrosbioq.Open;
    if not valoresfd.Active then valoresfd.Open;
    if not requerimientos.Active then requerimientos.Open;
    if not pb_pac.Active then pb_pac.Open;
    parametrosbioq.FieldByName('items').DisplayLabel := 'Items'; parametrosbioq.FieldByName('descrip').DisplayLabel := 'Determinaci�n'; parametrosbioq.FieldByName('minimo').DisplayLabel := 'M�nimo'; parametrosbioq.FieldByName('maximo').DisplayLabel := 'M�ximo'; parametrosbioq.FieldByName('referencia').DisplayLabel := 'Referencia';
    parametrosbioq.FieldByName('descrip').DisplayWidth := 50;
    IniciarColumnas;
  end;
  Inc(conexiones);
  anamnesis.conectar;
  tablas.conectar;
  diagnosticonut.conectar;
end;

procedure TTHistoriaDietetica.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  Dec(conexiones);
  if conexiones = 0 then Begin
    datosdb.closeDB(historia);
    datosdb.closeDB(anpac);
    datosdb.closeDB(tpeso);
    datosdb.closeDB(contextura);
    datosdb.closeDB(fsintet);
    datosdb.closeDB(formulades);
    datosdb.closeDB(parametrosbioq);
    datosdb.closeDB(valoresfd);
    datosdb.closeDB(requerimientos);
    datosdb.closeDB(pb_pac);
  end;
  anamnesis.desconectar;
  tablas.desconectar;
  diagnosticonut.desconectar;
end;

procedure TTHistoriaDietetica.conectarHD;
// Objetivo...: Abrir tablas de persistencia
begin
  if conexionespac = 0 then Begin
    if not historia.Active then historia.Open;
    IniciarColumnas;
  end;
  Inc(conexionespac);
end;

procedure TTHistoriaDietetica.desconectarHD;
// Objetivo...: Cerrar tablas de persistencia
begin
  if conexionespac > 0 then Dec(conexiones);
  if conexionespac = 0 then datosdb.closeDB(historia);
end;

procedure TTHistoriaDietetica.InformePaciente(xcodpac, xresultadobmi, xpesoposible, xtalla, xpesoactual, xpesoteorico, xcirccintura, xcontextura, xsobrepeso, xprimerconsulta, xultimo_peso, ximc, xbmi4, xbmi, xtitulo, xsubtitulo, xcirccadera, xindicecinturacadera, ximcobjetivo, xriesgo: string);
var
  cordx, cordy, linea, fuente, tamfuente: TStringList;
  Bitmap: TBitmap;
  i: Integer;
  c: Real;
  cs, ob1, ob2, ob3, ob4, ob5, ob6, idbmi: String;
  r: TQuery;
Begin
  getDatos(xcodpac);
  utiles.calc_antiguedad(utiles.sExprFecha(fechanac), utiles.sExprFecha2000(utiles.setFechaActual));
  if utiles.getAnios > 0 then edad := IntToStr(utiles.getAnios) else edad := '';


  Application.CreateForm(TIRR, IRR);

  cordx := TStringList.Create; cordy := TStringList.Create; linea := TStringList.Create; fuente := TStringList.Create; tamfuente := TStringList.Create;

  // Titulo
  cordx.Add('1,0'); cordy.Add('0,8');
  linea.Add(xtitulo);
  fuente.Add('Arial'); tamfuente.Add('16');
  cordx.Add('1,0'); cordy.Add('1,0');
  linea.Add(xsubtitulo);
  fuente.Add('Arial'); tamfuente.Add('12');
  cordx.Add('6,0'); cordy.Add('1,0');
  linea.Add('Fecha: ' + utiles.setFechaActual() );
  fuente.Add('Arial'); tamfuente.Add('9');

  // Encabezado
  cordx.Add('2,0'); cordy.Add('1,5');
  linea.Add('EVALUACION DEL ESTADO NUTRICIONAL');
  fuente.Add('Arial'); tamfuente.Add('12');
  cordx.Add('1,0'); cordy.Add('1,6');
  linea.Add('___________________________________________________________________');
  fuente.Add('Arial'); tamfuente.Add('12');


  cordx.Add('1,0'); cordy.Add('2,0');
  linea.Add('Paciente:  ' + nombre);
  fuente.Add('Arial'); tamfuente.Add('9');

  cordx.Add('3,0'); cordy.Add('2,0');
  linea.Add('Peso Actual:  ' + xpesoactual);
  fuente.Add('Arial'); tamfuente.Add('9');

  cordx.Add('5,0'); cordy.Add('2,0');
  linea.Add('Circ. Cintura:  ' + xcirccintura);
  fuente.Add('Arial'); tamfuente.Add('9');

  cordx.Add('1,0'); cordy.Add('2,2');
  linea.Add('F. 1� Consulta:  ' + xprimerconsulta);
  fuente.Add('Arial'); tamfuente.Add('9');

  cordx.Add('3,0'); cordy.Add('2,2');
  linea.Add('Peso Posible:  ' + xpesoposible);
  fuente.Add('Arial'); tamfuente.Add('9');

  cordx.Add('5,0'); cordy.Add('2,2');
  linea.Add('Circ. Cadera:  ' + xcirccadera);
  fuente.Add('Arial'); tamfuente.Add('9');

  cordx.Add('1,0'); cordy.Add('2,4');
  linea.Add('Sexo:  ' + sexo);
  fuente.Add('Arial'); tamfuente.Add('9');

  cordx.Add('3,0'); cordy.Add('2,4');
  linea.Add('IMC Inicial:  ' + xresultadobmi);
  fuente.Add('Arial'); tamfuente.Add('9');

  cordx.Add('5,0'); cordy.Add('2,4');
  linea.Add('Ind. Cint/Cad.:  ' + xindicecinturacadera);
  fuente.Add('Arial'); tamfuente.Add('9');

  cordx.Add('1,0'); cordy.Add('2,6');
  linea.Add('Edad:  ' + edad);
  fuente.Add('Arial'); tamfuente.Add('9');

  cordx.Add('3,0'); cordy.Add('2,6');
  linea.Add('IMC Objetivo:  ' + ximcobjetivo);
  fuente.Add('Arial'); tamfuente.Add('9');

  cordx.Add('5,0'); cordy.Add('2,6');
  linea.Add('Riesgo:  ' + xriesgo);
  fuente.Add('Arial'); tamfuente.Add('9');

  cordx.Add('1,0'); cordy.Add('2,8');
  linea.Add('Talla:  ' + xtalla);
  fuente.Add('Arial'); tamfuente.Add('9');

  cordx.Add('3,0'); cordy.Add('2,8');
  linea.Add('Sobrepeso:  ' + xsobrepeso);
  fuente.Add('Arial'); tamfuente.Add('9');

  // 2do. tramo
  cordx.Add('1,0'); cordy.Add('3,3');
  linea.Add('___________________________________________________________________');
  fuente.Add('Arial'); tamfuente.Add('12');
  cordx.Add('1,7'); cordy.Add('3,6');
  linea.Add('RECOMENDACIONES NUTRICIONALES SUGERIDAS');
  fuente.Add('Arial'); tamfuente.Add('12');
  cordx.Add('1,0'); cordy.Add('3,7');
  linea.Add('___________________________________________________________________');
  fuente.Add('Arial'); tamfuente.Add('12');

  cordx.Add('3,0'); cordy.Add('4,0');
  linea.Add('Hdc:  ' + utiles.FormatearNumero(floattostr(hdc)) + '%');
  fuente.Add('Arial'); tamfuente.Add('8');

  cordx.Add('4,0'); cordy.Add('4,0');
  linea.Add('cal:  ' + utiles.FormatearNumero(floattostr(cal1)));
  fuente.Add('Arial'); tamfuente.Add('8');

  cordx.Add('5,0'); cordy.Add('4,0');
  linea.Add('gr:  ' + utiles.FormatearNumero(floattostr(gr1)));
  fuente.Add('Arial'); tamfuente.Add('8');

  cordx.Add('1,2'); cordy.Add('4,2');
  linea.Add('VCT:  ' + utiles.FormatearNumero(floattostr(vct)));
  fuente.Add('Arial'); tamfuente.Add('8');

  cordx.Add('3,0'); cordy.Add('4,2');
  linea.Add('Prot:  ' + utiles.FormatearNumero(floattostr(prot)) + '%');
  fuente.Add('Arial'); tamfuente.Add('8');

  cordx.Add('4,0'); cordy.Add('4,2');
  linea.Add('cal:  ' + utiles.FormatearNumero(floattostr(cal2)));
  fuente.Add('Arial'); tamfuente.Add('8');

  cordx.Add('5,0'); cordy.Add('4,2');
  linea.Add('gr:  ' + utiles.FormatearNumero(floattostr(gr2)));
  fuente.Add('Arial'); tamfuente.Add('8');

  cordx.Add('3,0'); cordy.Add('4,4');
  linea.Add('Grasas:  ' + utiles.FormatearNumero(floattostr(gra)) + '%');
  fuente.Add('Arial'); tamfuente.Add('8');

  cordx.Add('4,0'); cordy.Add('4,4');
  linea.Add('cal:  ' + utiles.FormatearNumero(floattostr(cal3)));
  fuente.Add('Arial'); tamfuente.Add('8');

  cordx.Add('5,0'); cordy.Add('4,4');
  linea.Add('gr:  ' + utiles.FormatearNumero(floattostr(gr3)));
  fuente.Add('Arial'); tamfuente.Add('8');

  cordx.Add('1,0'); cordy.Add('4,5');
  linea.Add('___________________________________________________________________');
  fuente.Add('Arial'); tamfuente.Add('12');

  // 3er. tramo
  cordx.Add('1,0'); cordy.Add('4,8');
  linea.Add('Motivo de Consulta:  ' + motivoconsulta);
  fuente.Add('Arial'); tamfuente.Add('9');

  cordx.Add('1,0'); cordy.Add('5,0');
  linea.Add('Observaciones:  ' + diagnostico);
  fuente.Add('Arial'); tamfuente.Add('9');

  cordx.Add('1,0'); cordy.Add('5,1');
  linea.Add('___________________________________________________________________');
  fuente.Add('Arial'); tamfuente.Add('12');

  // Imagen
  idbmi := imc.getIMCId(strtofloat(xbmi));
  if (idbmi = '02') then ob1 := 'X';
  if (idbmi = '03') then ob2 := 'X';
  if (idbmi = '04') then ob3 := 'X';
  if (idbmi = '05') then ob4 := 'X';
  if (idbmi = '06') then ob5 := 'X';

  cordx.Add('1,7'); cordy.Add('7,5');
  linea.Add(ob1);
  fuente.Add('Arial'); tamfuente.Add('12');
  cordx.Add('2,9'); cordy.Add('7,5');
  linea.Add(ob2);
  fuente.Add('Arial'); tamfuente.Add('12');
  cordx.Add('4,1'); cordy.Add('7,5');
  linea.Add(ob3);
  fuente.Add('Arial'); tamfuente.Add('12');
  cordx.Add('5,3'); cordy.Add('7,5');
  linea.Add(ob4);
  fuente.Add('Arial'); tamfuente.Add('12');
  cordx.Add('6,5'); cordy.Add('7,5');
  linea.Add(ob5);
  fuente.Add('Arial'); tamfuente.Add('12');
  cordx.Add('7,7'); cordy.Add('7,5');
  linea.Add(ob6);
  fuente.Add('Arial'); tamfuente.Add('12');

  cordx.Add('1,0'); cordy.Add('7,8');
  linea.Add(imc.getIMC(strtofloat(xbmi)));
  fuente.Add('Arial'); tamfuente.Add('10');

  // Ultima parte
  cordx.Add('1,0'); cordy.Add('8,5');
  linea.Add('___________________________________________________________________');
  fuente.Add('Arial'); tamfuente.Add('12');

  cordx.Add('1,0'); cordy.Add('8,8');
  linea.Add('                             PA                     ' + xultimo_peso + '                    ' + xultimo_peso);
  fuente.Add('Arial'); tamfuente.Add('9');

  cordx.Add('1,0'); cordy.Add('8,9');
  linea.Add('IMC Actual       -------         =        -------          =         -------            ' + ximc);
  fuente.Add('Arial'); tamfuente.Add('9');

  cordx.Add('1,0'); cordy.Add('9,0');
  linea.Add('                             (T)�                  (' + xtalla + ')�                  ' + xbmi4);
  fuente.Add('Arial'); tamfuente.Add('9');

  cordx.Add('1,0'); cordy.Add('9,3');
  linea.Add('IMC (Valores de Referencia)');
  fuente.Add('Arial'); tamfuente.Add('9');

  c := 9.5;

  r := imc.getIndices;
  r.Open;
  while not r.eof do begin
    c := c + 0.150;
    cs := FloatToStr(c);
    cs := utiles.StringRemplazarCaracteres(cs, '.', ',');
    fuente.Add('Arial'); tamfuente.Add('8');
    cordx.Add('2,5'); cordy.Add(cs);
    linea.Add(utiles.FormatearNumero(r.FieldByName('minimo').AsString, '###0.00') + '  -  ' + utiles.FormatearNumero(r.FieldByName('maximo').AsString, '###0.00'));
    fuente.Add('Arial'); tamfuente.Add('8');
    cordx.Add('3,5'); cordy.Add(cs);
    linea.Add(r.FieldByName('descrip').AsString);
    fuente.Add('Arial'); tamfuente.Add('8');
    r.next;
  End;
  r.close; r.Free;

  // Coordenadas para ubicar la imagen
  IRR.icor1 := 1.1;
  IRR.icor2 := 5.5;
  IRR.icor3 := 7.1;
  IRR.icor4 := 7.2;

  IRR.PrintDetalle(cordx, cordy, linea, fuente, tamfuente, 'img_estado.bmp');

  IRR.Ejecutar;

  IRR.Release; IRR := Nil;
end;

procedure TTHistoriaDietetica.InformePacienteSdo(xcodpac, xresultadobmi, xpesoposible, xtalla, xpesoactual, xpesoteorico, xcirccintura, xcontextura, xsobrepeso, xprimerconsulta, xultimo_peso, ximc, xbmi4, xbmi, xtitulo, xsubtitulo, xcirccadera, xindicecinturacadera, ximcobjetivo, xriesgo: string; lista: TStringList);
var
  cordx, cordy, linea, fuente, tamfuente: TStringList;
  Bitmap: TBitmap;
  i, j, k, l: Integer;
  c: Real;
  cs, ob1, ob2, ob3, ob4, ob5, ob6, idbmi: String;
  r: TQuery;
  variacion, pesoanter, promedio: double;
  ok: boolean;
Begin
  getDatos(xcodpac);
  utiles.calc_antiguedad(utiles.sExprFecha(fechanac), utiles.sExprFecha2000(utiles.setFechaActual));
  if utiles.getAnios > 0 then edad := IntToStr(utiles.getAnios) else edad := '';


  Application.CreateForm(TIRR, IRR);

  cordx := TStringList.Create; cordy := TStringList.Create; linea := TStringList.Create; fuente := TStringList.Create; tamfuente := TStringList.Create;

  // Titulo
  cordx.Add('1,0'); cordy.Add('0,8');
  linea.Add(xtitulo);
  fuente.Add('Arial'); tamfuente.Add('16');
  cordx.Add('1,0'); cordy.Add('1,0');
  linea.Add(xsubtitulo);
  fuente.Add('Arial'); tamfuente.Add('12');
  cordx.Add('6,0'); cordy.Add('1,0');
  linea.Add('Fecha: ' + utiles.setFechaActual() );
  fuente.Add('Arial'); tamfuente.Add('9');


  // Encabezado
  cordx.Add('2,2'); cordy.Add('1,5');
  linea.Add('EVALUACION DEL ESTADO NUTRICIONAL');
  fuente.Add('Arial'); tamfuente.Add('12');
  cordx.Add('1,0'); cordy.Add('1,6');
  linea.Add('___________________________________________________________________');
  fuente.Add('Arial'); tamfuente.Add('12');

  cordx.Add('1,0'); cordy.Add('2,0');
  linea.Add('Paciente:  ' + nombre);
  fuente.Add('Arial'); tamfuente.Add('9');

  cordx.Add('3,0'); cordy.Add('2,0');
  linea.Add('Peso Actual:  ' + xpesoactual);
  fuente.Add('Arial'); tamfuente.Add('9');

  cordx.Add('5,0'); cordy.Add('2,0');
  linea.Add('Circ. Cintura:  ' + xcirccintura);
  fuente.Add('Arial'); tamfuente.Add('9');

  cordx.Add('1,0'); cordy.Add('2,2');
  linea.Add('F. 1� Consulta:  ' + xprimerconsulta);
  fuente.Add('Arial'); tamfuente.Add('9');

  cordx.Add('3,0'); cordy.Add('2,2');
  linea.Add('Peso Posible:  ' + xpesoposible);
  fuente.Add('Arial'); tamfuente.Add('9');

  cordx.Add('5,0'); cordy.Add('2,2');
  linea.Add('Circ. Cadera:  ' + xcirccadera);
  fuente.Add('Arial'); tamfuente.Add('9');

  cordx.Add('1,0'); cordy.Add('2,4');
  linea.Add('Sexo:  ' + sexo);
  fuente.Add('Arial'); tamfuente.Add('9');

  cordx.Add('3,0'); cordy.Add('2,4');
  linea.Add('IMC Inicial:  ' + xresultadobmi);
  fuente.Add('Arial'); tamfuente.Add('9');

  cordx.Add('5,0'); cordy.Add('2,4');
  linea.Add('Ind. Cint/Cad.:  ' + xindicecinturacadera);
  fuente.Add('Arial'); tamfuente.Add('9');

  cordx.Add('1,0'); cordy.Add('2,6');
  linea.Add('Edad:  ' + edad);
  fuente.Add('Arial'); tamfuente.Add('9');

  cordx.Add('3,0'); cordy.Add('2,6');
  linea.Add('IMC Objetivo:  ' + ximcobjetivo);
  fuente.Add('Arial'); tamfuente.Add('9');

  cordx.Add('5,0'); cordy.Add('2,6');
  linea.Add('Riesgo:  ' + xriesgo);
  fuente.Add('Arial'); tamfuente.Add('9');

  cordx.Add('1,0'); cordy.Add('2,8');
  linea.Add('Talla:  ' + xtalla);
  fuente.Add('Arial'); tamfuente.Add('9');

  cordx.Add('3,0'); cordy.Add('2,8');
  linea.Add('IMC Actual:  ' + ximc);
  fuente.Add('Arial'); tamfuente.Add('9');

  cordx.Add('5,0'); cordy.Add('2,8');
  linea.Add('Sobrepeso:  ' + xsobrepeso);
  fuente.Add('Arial'); tamfuente.Add('9');

  // 2do. tramo
  cordx.Add('1,0'); cordy.Add('3,3');
  linea.Add('___________________________________________________________________');
  fuente.Add('Arial'); tamfuente.Add('12');
  cordx.Add('3,0'); cordy.Add('3,6');
  linea.Add('EVOLUCION DEL PESO');
  fuente.Add('Arial'); tamfuente.Add('12');
  cordx.Add('1,0'); cordy.Add('3,7');
  linea.Add('___________________________________________________________________');
  fuente.Add('Arial'); tamfuente.Add('12');

  // Coordenadas para ubicar la imagen
  IRR.icor1 := 1.0;
  IRR.icor2 := 3.8;
  IRR.icor3 := 7.3;
  IRR.icor4 := 7.4;

  fuente.Add('Arial'); tamfuente.Add('8');
  cordx.Add('1,5'); cordy.Add('7,6');
  linea.Add('Fecha');
  fuente.Add('Arial'); tamfuente.Add('8');
  cordx.Add('2,0'); cordy.Add('7,6');
  linea.Add('Semana');
  fuente.Add('Arial'); tamfuente.Add('8');
  cordx.Add('2,5'); cordy.Add('7,6');
  linea.Add('Peso');
  fuente.Add('Arial'); tamfuente.Add('8');
  cordx.Add('2,9'); cordy.Add('7,6');
  linea.Add('Variaci�n');
  fuente.Add('Arial'); tamfuente.Add('8');
  cordx.Add('3,5'); cordy.Add('7,6');
  linea.Add('Promedio');
  fuente.Add('Arial'); tamfuente.Add('8');
  cordx.Add('4,2'); cordy.Add('7,6');
  linea.Add('Circ. Cintura');
  fuente.Add('Arial'); tamfuente.Add('8');
  cordx.Add('5,3'); cordy.Add('7,6');
  linea.Add('Circ. Cadera');
  fuente.Add('Arial'); tamfuente.Add('8');

  c := 7.7;
  r := historiadiet.setPesos(xcodpac);
  r.Open; i := 0; pesoanter := 0; variacion := 0; j := 0;
  k := r.RecordCount;
  l := k - 22;
  if (l < 1) then l := 0;
  r.First;
  while not r.eof do begin
    inc(j);
    if (lista = nil) then
      if (j > l) then ok := true;

    if not (lista = nil) then    
      if (utiles.verificarItemsLista(lista, r.FieldByName('items').AsString)) then ok := true;

    if (ok) then begin
      c := c + 0.150;
      cs := FloatToStr(c);
      cs := utiles.StringRemplazarCaracteres(cs, '.', ',');
      fuente.Add('Arial'); tamfuente.Add('8');
      cordx.Add('1,5'); cordy.Add(cs);
      linea.Add(utiles.sFormatoFecha(r.FieldByName('fecha').AsString));
      fuente.Add('Arial'); tamfuente.Add('8');
      cordx.Add('2,2'); cordy.Add(cs);
      linea.Add(r.FieldByName('semana').AsString);
      fuente.Add('Arial'); tamfuente.Add('8');
      cordx.Add('2,5'); cordy.Add(cs);
      linea.Add(utiles.FormatearNumero(r.FieldByName('peso').AsString));
      fuente.Add('Arial'); tamfuente.Add('8');
      if (pesoanter > 0) then begin
        variacion := r.FieldByName('peso').AsFloat - pesoanter;
        promedio := variacion / r.FieldByName('semana').AsFloat;
      end else
        pesoanter := r.FieldByName('peso').AsFloat;
      cordx.Add('3,0'); cordy.Add(cs);
      linea.Add(utiles.FormatearNumero(floattostr(variacion)));
      fuente.Add('Arial'); tamfuente.Add('8');
      cordx.Add('3,5'); cordy.Add(cs);
      linea.Add(utiles.FormatearNumero(floattostr(promedio)));
      fuente.Add('Arial'); tamfuente.Add('8');
      cordx.Add('4,5'); cordy.Add(cs);
      linea.Add(utiles.FormatearNumero(r.FieldByName('cintura').AsString));
      fuente.Add('Arial'); tamfuente.Add('8');
      cordx.Add('5,5'); cordy.Add(cs);
      linea.Add(utiles.FormatearNumero(r.FieldByName('cadera').AsString));
      fuente.Add('Arial'); tamfuente.Add('8');
    end;
    ok := false;

    r.next;
  End;
  r.close; r.Free;

  IRR.PrintDetalle(cordx, cordy, linea, fuente, tamfuente, 'grafico_peso.bmp');

  IRR.Ejecutar;

  IRR.Release; IRR := Nil;
end;

{===============================================================================}

function historiadiet: TTHistoriaDietetica;
begin
  if xhistoriadiet = nil then
    xhistoriadiet := TTHistoriaDietetica.Create;
  Result := xhistoriadiet;
end;

{===============================================================================}

initialization

finalization
  xhistoriadiet.Free;

end.
