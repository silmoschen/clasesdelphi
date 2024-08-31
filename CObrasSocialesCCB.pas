unit CObrasSocialesCCB;

interface

uses SysUtils, DB, DBTables, CIDBFM, CListar, CUtiles, CNomeclaCCB, CUsuario,
     CBDT, Classes, Forms, CUtilidadesArchivos, CNBU;

type

TTObraSocial = class(TObject)            // Superclase
  codos, Nombre, categoria, Nombrec, direccion, codpost, localidad, codpfis, nrocuit, tope, capitada,
  NoImporta, Periodo, Retieneiva, Codosdif, OSDif, Factnbu, Pernbu, FacturaNBU, Baja, Corteorden, Factexport, Convenio: string;
  UB, UG, RIEUB, RIEUG, porcentaje, topemin, topemax, retencioniva, valorNBU, valorNBUDif: real;
  MontoFijo, ArancelesDiferenciales, Rupturaorden: Boolean;
  tabla, apfijos, aranceles, retiva, arancelesNBU, apfijosNBU, arannbu, obsocial_reglas: TTable;
 public
  { Declaraciones P�blicas }
  constructor Create; virtual;
  destructor  Destroy; override;

  procedure   GrabarOS(xcodos, xNombre, xcategoria, xtope, xcapitada: string; xUB, xUG, xRIEUB, xRIEUG, xporcentaje, xtopemin, xtopemax, xretencioniva: real; xretieneiva, xfactnbu, xpernbu, xfactexport: String; xruptura_orden: boolean); overload;
  procedure   Grabar(xcodos, xNombre, xcategoria, xtope, xcapitada: string; xUB, xUG, xRIEUB, xRIEUG, xporcentaje, xtopemin, xtopemax, xretencioniva: real; xretieneiva, xfactnbu, xpernbu, xcorteorden: String; xruptura_orden: boolean); overload;
  procedure   Grabar(xcodos, xnombre, xdireccion, xcodpost, xlocalidad, xcodpfis, xnrocuit: string); overload;
  procedure   Borrar(xcodos: string);
  function    Buscar(xcodos: string): boolean;
  function    Nuevo: string;
  procedure   getDatos(xcodos: string);
  function    setobsocials: TQuery;
  function    setobsocialsAlf: TQuery;
  function    setobsocialsExportacion: TQuery;
  function    setObrasSocialesCapitadas: TQuery;
  procedure   BuscarPorCodigo(xexp: string);
  procedure   BuscarPorNombre(xexp: string);
  procedure   FiltrarObrasSocialesActivas;

  procedure   EstablecerObrasSocialesQueNoImportan(xlista: TStringList);
  function    setObrasSocialesQueNoImportan: TStringList;
  function    setListaObrasSociales: TStringList;

  function    BuscarAnalisisMontoFijo(xcodos, xcodanalisis: string): boolean;
  function    BuscarItemsMontoFijo(xcodos, xitems: string): boolean;
  procedure   GrabarAnalisisMontoFijo(xcodos, xitems, xcodanalisis, xperiodo, xperiodobaja: string; ximporte: real; xcantitems: Integer);
  procedure   BorrarAnalisisMontoFijo(xcodos, xitems: string);
  function    setAnalisisMontoFijo(xcodos: string): TQuery; overload;
  function    setAnalisisMontoFijo(xcodos, xcodigo: string): TQuery; overload;
  function    VerifcarSiElAnalisisTieneMontoFijo(xcodos, xcodanalisis: string): Real;
  function    setMontoFijo(xcodos, xcodanalisis, xperiodo: String): Real;
  procedure   BajaPeriodoMontoFijo(xcodos, xitems, xperiodo: string);

  function    BuscarAnalisisMontoFijoNBU(xcodos, xcodanalisis: string): boolean;
  function    BuscarItemsMontoFijoNBU(xcodos, xitems: string): boolean;
  procedure   GrabarAnalisisMontoFijoNBU(xcodos, xitems, xcodanalisis, xperiodo, xperiodobaja: string; ximporte: real; xcantitems: Integer);
  procedure   BorrarAnalisisMontoFijoNBU(xcodos, xitems: string);
  function    setAnalisisMontoFijoNBU(xcodos: string): TQuery; overload;
  function    setAnalisisMontoFijoNBU(xcodos, xcodigo: string): TQuery; overload;
  function    VerifcarSiElAnalisisTieneMontoFijoNBU(xcodos, xcodanalisis: string): Real;
  function    setMontoFijoNBU(xcodos, xcodanalisis, xperiodo: String): Real;
  procedure   BajaPeriodoMontoFijoNBU(xcodos, xitems, xperiodo: string);

  procedure   DarDeBaja(xcodos, xfecha: String);
  procedure   Reactivar(xcodos: String);
  function    verificarSiEstaDadaDeBaja: Boolean;

  procedure   VerDatosLiquidacion;
  procedure   FijarQuitarCategoria;

  procedure   conectar; overload;
  procedure   desconectar;
  procedure   Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
  procedure   ListarAnalisisMontoFijo(orden, iniciar, finalizar, ent_excl: string; salida: char);
  procedure   ListarNomecladorValorizado(orden, iniciar, finalizar, ent_excl, exportXML: String; salida: Char);
  procedure   ListarAranceles(orden, iniciar, finalizar, ent_excl: string; salida: char);
  procedure   ListarNomecladorNBUValorizado(orden, iniciar, finalizar, ent_excl, exportXML, xperiodo: String; salida: Char);
  procedure   ListarUnidadesNBU(orden, iniciar, finalizar, ent_excl: string; salida: char);

  { Manejo de Aranceles }
  function    BuscarArancel(xcodos, xperiodo: String): Boolean;
  procedure   GuardarArancel(xcodos, xperiodo, xtope: String; xub, xug, xrieub, xrieug: Real);
  procedure   BorrarArancel(xcodos, xperiodo: String);
  function    setAranceles(xcodos: String): TStringList;
  procedure   ObtenerUltimosAranceles(xcodos: String);
  procedure   SincronizarArancel(xcodos, xperiodo: String);

  procedure   FijarPosicionFiscal(xcodos, xperiodo: String; xretiva: Real);
  procedure   BorrarPosicionFiscal(xcodos, xperiodo: String);
  function    setPosicionFiscal(xcodos: String): TStringList;
  procedure   SincronizarPosicionFiscal(xcodos, xperiodo: String);

  function    BuscarArancelNBU(xcodos, xperiodo: String): Boolean;
  procedure   GuardarArancelNBU(xcodos, xperiodo: String; xvalor, xvalordif: Real);
  procedure   BorrarArancelNBU(xcodos, xperiodo: String);
  function    setArancelesNBU(xcodos: String): TStringList;
  procedure   ObtenerUltimosArancelesNBU(xcodos: String);
  procedure   SincronizarArancelNBU(xcodos, xperiodo: String);

  function    BuscarUnidadNBU(xcodos, xitems: String): Boolean;
  procedure   RegistrarUnidadNBU(xcodos, xitems, xcodigo, xperiodo_alta, xperiodo_baja: String; xunidad: Real; xcantitems: Integer);
  procedure   BorrarUnidadNBU(xcodos, xitems: String);
  function    setUnidadNBU(xcodos: String): TQuery; overload;
  function    setUnidadNBU(xcodos, xcodanalisis, xperiodo: String): Real; overload;

  { Soporte XML }
  procedure   PaginaInicialHTML;
  procedure   ExportarAnalisisMontoFijoXML;
  procedure   ExportarAnalisisMontoFijoNBU;
  procedure   ExportarObrasSocialesXML;
  procedure   ExportarArancelesXML;
  procedure   ExportarArancelesNBUXML;
  procedure   ExportarPosicionFiscalXML;
  procedure   ExportarUnidadesNBU;
  procedure   ImportarAnalisisMontoFijoXML(xlista: TStringList);
  procedure   ImportarAnalisisMontoFijoNBU(xlista: TStringList);
  procedure   ImportarObrasSocialesXML(xlista: TStringList);
  procedure   ImportarArancelesXML(xlista: TStringList);
  procedure   ImportarArancelesNBUXML(xlista: TStringList);
  procedure   ImportarPosicionFiscalXML(xlista: TStringList);
  procedure   ImportarUnidadesNBU(xlista: TStringList);

  procedure   ExportarOSXML;

  { Comopresion de Archivos }
  procedure   DescompactarArchivosActualizaciones;
  function    setObrasSocialesImportadas: TQuery;
  function    setObrasSocialesSoporteDigital: TQuery;
  function    getRegla(xcodos: string): integer;
  function    getReglas: TQuery; overload;
  function    getReglas(regla: string): TQuery; overload;
  function    getReglasCoseguros: TQuery;
 private
  { Declaraciones Privadas }
  conexiones: shortint; r: TQuery; idant: String;
  lista, lista2, lista3, ltope, listaNBU, lista4: TStringList;
  texport: TTable;
  procedure   ListLinea(salida: char);
  procedure   ListLineaMFijos(salida: char);
  procedure   ListDeterminaciones(salida: char);
  procedure   ListDeterminacionesNBU(xperiodo: String; salida: char);
  function    setValorAnalisis(xcodos, xcodanalisis: string; xOSUB, xNOUB, xOSUG, xNOUG: real): real;
  procedure   ListAranceles(salida: char);
  procedure   CargarLista;
  procedure   CargarListaNBU;
  procedure   CargarListaApFijos;
  procedure   CargarListaUnidadesNBU;
  procedure   CargarListaApFijosNBU;
  procedure   Enccol;
 protected
  { Declaraciones Protegidas }
  dbconexion: String;
end;

function obsocial: TTObraSocial;

implementation
//  uses CIntegridadReferencial;

var
  xobsocial: TTObraSocial = nil;

constructor TTObraSocial.Create;
begin
  inherited create;

  if dbs.TDB <> Nil then Begin  // Prevenci�n para los servicios CGI
    if (LowerCase(ExtractFileName(Application.ExeName)) = 'shmsoftfccb.exe') or                  // Motor de Persitencia para las versiones de Laboratorios Cliente-Servidor
       (LowerCase(ExtractFileName(Application.ExeName)) = 'shmsoftfccbc.exe') or
       (LowerCase(ExtractFileName(Application.ExeName)) = 'shmsoftfccbcretivac.exe') or
       (LowerCase(ExtractFileName(Application.ExeName)) = 'shmsoftlabinter.exe') or
       (LowerCase(ExtractFileName(Application.ExeName)) = 'shmsoft.exe') or
       (LowerCase(ExtractFileName(Application.ExeName)) = 'shmsoftfccbcretiva.exe') then Begin   // Motor de Persitencia para las versiones de Laboratorios
      if dbs.BaseClientServ = 'N' then DBConexion := dbs.DirSistema + '\archdat' else DBConexion := dbs.TDB1.DatabaseName;
    end else Begin
      if dbs.BaseClientServ = 'N' then DBConexion := dbs.DirSistema + '\archdat' else DBConexion := dbs.baseDat;
    end;

    {if dbs.BaseClientServ = 'S' then Begin
      tabla        := datosdb.openDB('obsocial', 'Codos');
      apfijos      := datosdb.openDB('apfijos', '');
      aranceles    := datosdb.openDB('obsociales_aranceles', '');
      retiva       := datosdb.openDB('obsocial_posiva', '');
      arancelesNBU := datosdb.openDB('arancelesNBU', '');
      apfijosNBU   := datosdb.openDB('apfijosNBU', '');
      arannbu      := datosdb.openDB('arannbu', '');
    end else Begin
      if Length(Trim(dbs.baseDat)) > 0 then Begin
        tabla        := datosdb.openDB('obsocial', 'Codos', '', dbs.baseDat);
        apfijos      := datosdb.openDB('apfijos', '', '', dbs.baseDat);
        aranceles    := datosdb.openDB('obsociales_aranceles', '', '', dbs.baseDat);
        retiva       := datosdb.openDB('obsocial_posiva', '', '', dbs.DirSistema + '\archdat');
        arancelesNBU := datosdb.openDB('arancelesNBU', '', '', dbs.baseDat);
        apfijosNBU   := datosdb.openDB('apfijosNBU', '', '', dbs.baseDat);
        arannbu      := datosdb.openDB('arannbu', '', '', dbs.baseDat);
      end;
    end;}

    tabla           := datosdb.openDB('obsocial', 'Codos', '', DBConexion);
    apfijos         := datosdb.openDB('apfijos', '', '', DBConexion);
    aranceles       := datosdb.openDB('obsociales_aranceles', '', '', DBConexion);
    retiva          := datosdb.openDB('obsocial_posiva', '', '', DBConexion);
    arancelesNBU    := datosdb.openDB('arancelesNBU', '', '', DBConexion);
    apfijosNBU      := datosdb.openDB('apfijosNBU', '', '', DBConexion);
    arannbu         := datosdb.openDB('arannbu', '', '', DBConexion);
    obsocial_reglas := datosdb.openDB('obsocial_reglas', '', '', DBConexion);

  end;

end;

destructor TTObraSocial.Destroy;
begin
  inherited Destroy;
end;

procedure TTObraSocial.GrabarOS(xcodos, xNombre, xcategoria, xtope, xcapitada: string; xUB, xUG, xRIEUB, xRIEUG, xporcentaje, xtopemin, xtopemax, xretencioniva: real; xretieneiva, xfactnbu, xpernbu, xfactexport: String; xruptura_orden: boolean);
// Objetivo...: Grabar Atributos del Objeto
begin
  if Buscar(xcodos) then tabla.Edit else tabla.Append;
  tabla.FieldByName('codos').AsString       := xcodos;
  tabla.FieldByName('Nombre').AsString      := TrimLeft(xNombre);
  tabla.FieldByName('categoria').AsString   := xcategoria;
  tabla.FieldByName('tope').AsString        := xtope;
  tabla.FieldByName('capitada').AsString    := xcapitada;
  tabla.FieldByName('UB').AsFloat           := xUB;
  tabla.FieldByName('UG').AsFloat           := xUG;
  tabla.FieldByName('RIEUB').AsFloat        := xRIEUB;
  tabla.FieldByName('RIEUG').AsFloat        := xRIEUG;
  tabla.FieldByName('porcentaje').AsFloat   := xporcentaje;
  tabla.FieldByName('topemax').AsFloat      := xtopemax;
  tabla.FieldByName('topemin').AsFloat      := xtopemin;
  tabla.FieldByName('retencioniva').AsFloat := xretencioniva;
  tabla.FieldByName('retieneiva').AsString  := xretieneiva;
  tabla.FieldByName('factnbu').AsString     := xfactnbu;
  tabla.FieldByName('pernbu').AsString      := xpernbu;
  tabla.FieldByName('exportfact').AsString  := xfactexport;
  if (xruptura_orden) then tabla.FieldByName('ruptura_orden').AsInteger := 1 else tabla.FieldByName('ruptura_orden').Clear;
  try
    tabla.Post
   except
    tabla.Cancel
  end;
  datosdb.closedb(tabla); tabla.Open;
  Enccol;
end;

procedure TTObraSocial.Grabar(xcodos, xNombre, xcategoria, xtope, xcapitada: string; xUB, xUG, xRIEUB, xRIEUG, xporcentaje, xtopemin, xtopemax, xretencioniva: real; xretieneiva, xfactnbu, xpernbu, xcorteorden: String; xruptura_orden: boolean);
// Objetivo...: Grabar Atributos del Objeto
begin
  if Buscar(xcodos) then tabla.Edit else tabla.Append;
  tabla.FieldByName('codos').AsString       := xcodos;
  tabla.FieldByName('Nombre').AsString      := TrimLeft(xNombre);
  tabla.FieldByName('categoria').AsString   := xcategoria;
  tabla.FieldByName('tope').AsString        := xtope;
  tabla.FieldByName('capitada').AsString    := xcapitada;
  tabla.FieldByName('UB').AsFloat           := xUB;
  tabla.FieldByName('UG').AsFloat           := xUG;
  tabla.FieldByName('RIEUB').AsFloat        := xRIEUB;
  tabla.FieldByName('RIEUG').AsFloat        := xRIEUG;
  tabla.FieldByName('porcentaje').AsFloat   := xporcentaje;
  tabla.FieldByName('topemax').AsFloat      := xtopemax;
  tabla.FieldByName('topemin').AsFloat      := xtopemin;
  tabla.FieldByName('retencioniva').AsFloat := xretencioniva;
  tabla.FieldByName('retieneiva').AsString  := xretieneiva;
  tabla.FieldByName('factnbu').AsString     := xfactnbu;
  tabla.FieldByName('pernbu').AsString      := xpernbu;
  tabla.FieldByName('corteorden').AsString  := xcorteorden;
  if (xruptura_orden) then tabla.FieldByName('ruptura_orden').AsInteger := 1 else tabla.FieldByName('ruptura_orden').Clear;
  try
    tabla.Post
   except
    tabla.Cancel
  end;
  datosdb.closedb(tabla); tabla.Open;
  Enccol;
end;

procedure TTObraSocial.Grabar(xcodos, xnombre, xdireccion, xcodpost, xlocalidad, xcodpfis, xnrocuit: string);
// Objetivo...: Grabar Atributos del Objeto
begin
  if Buscar(xcodos) then Begin
    tabla.Edit;
    tabla.FieldByName('nombrec').AsString   := TrimLeft(xnombre);
    tabla.FieldByName('direccion').AsString := TrimLeft(xdireccion);
    tabla.FieldByName('codpos').AsString    := TrimLeft(xcodpost);
    tabla.FieldByName('localidad').AsString := TrimLeft(xlocalidad);
    tabla.FieldByName('codpfis').AsString   := xcodpfis;
    tabla.FieldByName('nrocuit').AsString   := xnrocuit;
    try
      tabla.Post
     except
      tabla.Cancel
    end;
  end;
  datosdb.closedb(tabla); tabla.Open;
  Enccol;
end;

procedure TTObraSocial.Borrar(xcodos: string);
// Objetivo...: Eliminar un Objeto
begin
  if Buscar(xcodos) then Begin
    {
    if (verificarIntegridad.verificarObraSocial(xcodos)) then begin
      tabla.Delete;
      getDatos(tabla.FieldByName('codos').AsString);  // Fijamos los Atributos Siguientes al Objeto Borrado
    end else begin
      utiles.msgError('La Obra Social tiene Operaciones Asociadas. Baja Denegada ...!');
      getDatos(xcodos);
    end;
    }
  end;
end;

function TTObraSocial.Buscar(xcodos: string): boolean;
// Objetivo...: Buscar el Objeto solicitado
begin
  if not tabla.Active then Begin
    tabla.Open;
    Enccol;
  end;
  if tabla.IndexFieldNames <> 'codos' then tabla.IndexFieldNames := 'codos';
  if tabla.FindKey([xcodos]) then Result := True else Result := False;
end;

procedure  TTObraSocial.getDatos(xcodos: string);
// Objetivo...: Retornar/Iniciar Atributos
begin
  Rupturaorden := false;
  if Buscar(xcodos) then Begin
    codos        := tabla.FieldByName('codos').AsString;
    Nombre       := tabla.FieldByName('Nombre').AsString;
    tope         := tabla.FieldByName('tope').AsString;
    UB           := tabla.FieldByName('UB').AsFloat;
    UG           := tabla.FieldByName('UG').AsFloat;
    RIEUB        := tabla.FieldByName('RIEUB').AsFloat;
    RIEUG        := tabla.FieldByName('RIEUG').AsFloat;
    porcentaje   := tabla.FieldByName('porcentaje').AsFloat;
    topemax      := tabla.FieldByName('topemax').AsFloat;
    topemin      := tabla.FieldByName('topemin').AsFloat;
    categoria    := tabla.FieldByName('categoria').AsString;
    nombrec      := tabla.FieldByName('nombrec').AsString;
    direccion    := tabla.FieldByName('direccion').AsString;
    codpost      := tabla.FieldByName('codpos').AsString;
    localidad    := tabla.FieldByName('localidad').AsString;
    codpfis      := tabla.FieldByName('codpfis').AsString;
    nrocuit      := tabla.FieldByName('nrocuit').AsString;
    capitada     := tabla.FieldByName('capitada').AsString;
    noimporta    := tabla.FieldByName('noimport').AsString;
    retencioniva := tabla.FieldByName('retencioniva').AsFloat;
    retieneiva   := tabla.FieldByName('retieneiva').AsString;
    factnbu      := tabla.FieldByName('factnbu').AsString;
    pernbu       := tabla.FieldByName('pernbu').AsString;
    factexport   := tabla.FieldByName('exportfact').AsString;
    baja         := utiles.sFormatoFecha(tabla.FieldByName('baja').AsString);
    if (datosdb.verificarSiExisteCampo(tabla, 'corteorden')) then corteorden := tabla.FieldByName('corteorden').AsString else corteorden := 'N';
    if ArancelesDiferenciales then nombre := tabla.FieldByName('Nombre').AsString + ' - Un.Dif.';
    if (tabla.FieldByName('ruptura_orden').AsInteger = 1) then Rupturaorden := true;
    
  end else Begin
    codos := ''; Nombre := ''; UB := 0; UG := 0; RIEUB := 0; RIEUG := 0; porcentaje := 0; categoria := '';
    nombre := ''; direccion := ''; codpost := ''; localidad := ''; codpfis := ''; nrocuit := ''; Nombrec := ''; topemax := 0;
    topemin := 0; tope := ''; capitada := ''; noimporta := ''; retencioniva := 0; retieneiva := ''; factnbu := 'N';
    pernbu := ''; baja := ''; factexport := 'N';
  end;
  if Length(Trim(factnbu)) = 0 then factnbu := 'N';
  if Length(Trim(capitada)) = 0 then capitada := 'N';
  if Length(Trim(corteorden)) = 0 then corteorden := 'N';
  if Length(Trim(factexport)) = 0 then factexport := 'N';
end;

function TTObraSocial.Nuevo: string;
// Objetivo...: Generar un Nuevo Atributo C�digo
var
  indice: String;
begin
  indice := tabla.IndexFieldNames;
  tabla.IndexFieldNames := 'codos';
  tabla.Last;
  if Length(Trim(tabla.FieldByName('codos').AsString)) > 0 then Result := utiles.sLLenarIzquierda(IntToStr(tabla.FieldByName('codos').AsInteger + 1), 6, '0') else Result := '1';
  tabla.IndexFieldNames := indice;
end;

function TTObraSocial.setobsocials: TQuery;
// Objetivo...: retornar un set de obsocials
begin
  Result := datosdb.tranSQL('SELECT codos, Nombre FROM obsocial');
end;

function TTObraSocial.setobsocialsAlf: TQuery;
// Objetivo...: retornar un set de obsocials
begin
  Result := datosdb.tranSQL('SELECT codos, nombre, capitada, retieneiva FROM obsocial WHERE baja is NULL or baja = ' + '''' + '''' + ' ORDER BY Nombre');
end;

function TTObraSocial.setobsocialsExportacion: TQuery;
// Objetivo...: retornar un set de obsocials
begin
  Result := datosdb.tranSQL('SELECT codos, nombre, capitada, retieneiva FROM obsocial WHERE exportfact = ' + '''' + 'S' + ''''  + ' ORDER BY Nombre');
end;

function TTObraSocial.setObrasSocialesCapitadas: TQuery;
// Objetivo...: retornar un set de obsociales capitadas
begin
  if Length(Trim(dbs.baseDat)) = 0 then Begin
    {dbs.NuevaBaseDeDatos2('centrobioq', 'sysdba', 'masterkey');
    Result := datosdb.tranSQL('centrobioq', 'SELECT codos, nombre, capitada FROM obsocial WHERE capitada = ' + '"' + 'S' + '"' + ' ORDER BY Nombre');
    dbs.desconectarDB2;}
  end else
    Result := datosdb.tranSQL('SELECT codos, nombre, capitada FROM obsocial WHERE capitada = ' + '"' + 'S' + '"' + ' ORDER BY Nombre');
end;

procedure TTObraSocial.Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
// Objetivo...: Listar colecci�n de objetos
begin
  if orden = 'A' then tabla.IndexFieldNames := 'Nombre';

  list.Setear(salida);
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Listado de Obras Sociales', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'C�d.' + utiles.espacios(3) +  'Obra Social', 1, 'Arial, cursiva, 8');
  List.Titulo(43, list.Lineactual, 'F.NBU', 2, 'Arial, cursiva, 8');
  List.Titulo(50, list.Lineactual, 'U.B.', 3, 'Arial, cursiva, 8');
  List.Titulo(60, list.Lineactual, 'U.G.', 4, 'Arial, cursiva, 8');
  List.Titulo(68, list.Lineactual, 'RIE UB', 5, 'Arial, cursiva, 8');
  List.Titulo(78, list.Lineactual, 'RIE UG', 6, 'Arial, cursiva, 8');
  List.Titulo(86, list.Lineactual, '%Cob', 7, 'Arial, cursiva, 8');
  List.Titulo(92, list.Lineactual, 'Cat', 8, 'Arial, cursiva, 8');
  List.Titulo(96, list.Lineactual, 'Tope', 9, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  tabla.First;
  while not tabla.EOF do Begin
    // Ordenado por C�digo
    if (iniciar <> '******') then begin
      if (ent_excl = 'E') and (orden = 'C') then
        if (tabla.FieldByName('codos').AsString >= iniciar) and (tabla.FieldByName('codos').AsString <= finalizar) then ListLinea(salida);
      if (ent_excl = 'X') and (orden = 'C') then
        if (tabla.FieldByName('codos').AsString < iniciar) or (tabla.FieldByName('codos').AsString > finalizar) then ListLinea(salida);
      // Ordenado Alfab�ticamente
      if (ent_excl = 'E') and (orden = 'A') then
        if (tabla.FieldByName('Nombre').AsString >= iniciar) and (tabla.FieldByName('Nombre').AsString <= finalizar) then ListLinea(salida);
      if (ent_excl = 'X') and (orden = 'A') then
        if (tabla.FieldByName('Nombre').AsString < iniciar) or (tabla.FieldByName('Nombre').AsString > finalizar) then ListLinea(salida);
    end else
      if (tabla.FieldByName('factnbu').AsString = 'S') then ListLinea(salida);


    tabla.Next;
  end;
  List.FinList;

  tabla.IndexFieldNames := tabla.IndexFieldNames;
  tabla.First;
end;

procedure TTObraSocial.ListLinea(salida: char);
// Objetivo...: Listar Linea
var
  fnbu: string;
begin
  if (tabla.FieldByName('factnbu').AsString = '') then fnbu := 'N' else fnbu := tabla.FieldByName('factnbu').AsString;  
  List.Linea(0, 0, tabla.FieldByName('codos').AsString + '   ' + tabla.FieldByName('Nombre').AsString, 1, 'Arial, normal, 8', salida, 'N');
  List.Linea(45, list.Lineactual, fnbu, 2, 'Arial, normal, 8', salida, 'N');
  List.Importe(53, list.Lineactual, '', tabla.FieldByName('UB').AsFloat, 3, 'Arial, normal, 8');
  List.Importe(63, list.Lineactual, '', tabla.FieldByName('UG').AsFloat, 4, 'Arial, normal, 8');
  List.Importe(73, list.Lineactual, '', tabla.FieldByName('RIEUB').AsFloat, 5, 'Arial, normal, 8');
  List.Importe(83, list.Lineactual, '', tabla.FieldByName('RIEUG').AsFloat, 6, 'Arial, normal, 8');
  List.Importe(91, list.Lineactual, '', tabla.FieldByName('porcentaje').AsFloat, 7, 'Arial, normal, 8');
  List.Linea(93, list.Lineactual, tabla.FieldByName('categoria').AsString, 8, 'Arial, normal, 8', salida, 'N');
  List.Linea(98, list.Lineactual, tabla.FieldByName('tope').AsString, 9, 'Arial, normal, 8', salida, 'S');
end;

procedure TTObraSocial.ListarAnalisisMontoFijo(orden, iniciar, finalizar, ent_excl: string; salida: char);
Begin
  list.Setear(salida);
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Listado de Determinaciones con Monto Fijo', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'C�digo  Detrminaci�n', 1, 'Arial, cursiva, 8');
  List.Titulo(80, list.Lineactual, 'Importe', 2, 'Arial, cursiva, 8');
  List.Titulo(87, list.Lineactual, 'P.Alta', 3, 'Arial, cursiva, 8');
  List.Titulo(93, list.Lineactual, 'P.Baja', 4, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  if orden = 'C' then tabla.IndexFieldNames := 'codos';
  if orden = 'A' then tabla.IndexFieldNames := 'nombre';

  tabla.First;
  while not tabla.EOF do Begin
    // Ordenado por C�digo
    if (ent_excl = 'E') and (orden = 'C') then
      if (tabla.FieldByName('codos').AsString >= iniciar) and (tabla.FieldByName('codos').AsString <= finalizar) then ListLineaMFijos(salida);
    if (ent_excl = 'X') and (orden = 'C') then
      if (tabla.FieldByName('codos').AsString < iniciar) or (tabla.FieldByName('codos').AsString > finalizar) then ListLineaMFijos(salida);
    // Ordenado Alfab�ticamente
    if (ent_excl = 'E') and (orden = 'A') then
      if (tabla.FieldByName('Nombre').AsString >= iniciar) and (tabla.FieldByName('Nombre').AsString <= finalizar) then ListLineaMFijos(salida);
    if (ent_excl = 'X') and (orden = 'A') then
      if (tabla.FieldByName('Nombre').AsString < iniciar) or (tabla.FieldByName('Nombre').AsString > finalizar) then ListLineaMFijos(salida);

    tabla.Next;
  end;

  tabla.IndexFieldNames := 'codos';

  List.FinList;
end;

procedure TTObraSocial.ListLineaMFijos(salida: char);
// Objetivo...: Listar Linea
begin
  SincronizarArancelNBU(tabla.FieldByName('codos').AsString, utiles.setPeriodoActual);
  idant := '';

  if FacturaNBU <> 'S' then Begin

    datosdb.Filtrar(apfijos, 'codos = ' + '''' + tabla.FieldByName('codos').AsString + '''');

    apfijos.First;
    while not apfijos.Eof do Begin
      if tabla.FieldByName('codos').AsString = idant then List.Linea(0, 0, '   ', 1, 'Arial, normal, 8', salida, 'N') else
        List.Linea(0, 0, tabla.FieldByName('codos').AsString + '   ' + tabla.FieldByName('nombre').AsString, 1, 'Arial, normal, 8', salida, 'N');
      idant := tabla.FieldByName('codos').AsString;
      nomeclatura.getDatos(apfijos.FieldByName('codanalisis').AsString);
      List.Linea(40, list.Lineactual, apfijos.FieldByName('codanalisis').AsString, 2, 'Arial, normal, 8', salida, 'N');
      List.Linea(46, list.Lineactual, Copy(nomeclatura.descrip, 1, 42), 3, 'Arial, normal, 8', salida, 'N');
      List.Importe(86, list.Lineactual, '', apfijos.FieldByName('importe').AsFloat, 4, 'Arial, normal, 8');
      List.Linea(87, list.Lineactual, apfijos.FieldByName('periodo').AsString, 5, 'Arial, normal, 8', salida, 'N');
      List.Linea(93, list.Lineactual, apfijos.FieldByName('perhasta').AsString, 6, 'Arial, normal, 8', salida, 'S');
      apfijos.Next;
    end;
    datosdb.QuitarFiltro(apfijos);
  end;

  if FacturaNBU = 'S' then Begin

    datosdb.Filtrar(apfijosNBU, 'codos = ' + '''' + tabla.FieldByName('codos').AsString + '''');

    apfijosNBU.First;
    while not apfijosNBU.Eof do Begin
      if tabla.FieldByName('codos').AsString = idant then List.Linea(0, 0, '   ', 1, 'Arial, normal, 8', salida, 'N') else
        List.Linea(0, 0, tabla.FieldByName('codos').AsString + '   ' + tabla.FieldByName('nombre').AsString, 1, 'Arial, normal, 8', salida, 'N');
      idant := tabla.FieldByName('codos').AsString;
      nbu.getDatos(apfijosNBU.FieldByName('codanalisis').AsString);
      List.Linea(40, list.Lineactual, apfijosNBU.FieldByName('codanalisis').AsString, 2, 'Arial, normal, 8', salida, 'N');
      List.Linea(46, list.Lineactual, Copy(nbu.descrip, 1, 42), 3, 'Arial, normal, 8', salida, 'N');
      List.Importe(86, list.Lineactual, '', apfijosNBU.FieldByName('importe').AsFloat, 4, 'Arial, normal, 8');
      List.Linea(87, list.Lineactual, apfijosNBU.FieldByName('periodo').AsString, 5, 'Arial, normal, 8', salida, 'N');
      List.Linea(93, list.Lineactual, apfijosNBU.FieldByName('perhasta').AsString, 6, 'Arial, normal, 8', salida, 'S');
      apfijosNBU.Next;
    end;
    datosdb.QuitarFiltro(apfijosNBU);

  end;
end;

procedure TTObraSocial.ListarNomecladorValorizado(orden, iniciar, finalizar, ent_excl, exportXML: String; salida: Char);
// Objetivo...: Listar el nomeclador para una obra social
Begin
  idant := '';
  list.Setear('P');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Nomeclador Nacional Normalizado', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'C�digo  Determinaci�n', 1, 'Arial, cursiva, 8');
  List.Titulo(67, list.Lineactual, 'U.G.', 2, 'Arial, cursiva, 8');
  List.Titulo(77, list.Lineactual, 'U.B.', 3, 'Arial, cursiva, 8');
  List.Titulo(81, list.Lineactual, 'C.Fact.', 4, 'Arial, cursiva, 8');
  List.Titulo(91, list.Lineactual, 'Importe', 5, 'Arial, cursiva, 8');
  List.Titulo(97, list.Lineactual, 'RIE', 6, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  if salida = 'X' then Begin
    list.ExportarInforme(exportXML);
    list.LineaTxt('<?xml version="1.0"?>', True);
    list.LineaTxt('', True);
    list.LineaTxt('<nomeclatura>', True);
  end;

  tabla.Open; tabla.First;
  while not tabla.EOF do Begin
    // Ordenado por C�digo
    if (ent_excl = 'E') and (orden = 'C') then
      if (tabla.FieldByName('codos').AsString >= iniciar) and (tabla.FieldByName('codos').AsString <= finalizar) then ListDeterminaciones(salida);
    if (ent_excl = 'X') and (orden = 'C') then
      if (tabla.FieldByName('codos').AsString < iniciar) or (tabla.FieldByName('codos').AsString > finalizar) then ListDeterminaciones(salida);
    // Ordenado Alfab�ticamente
    if (ent_excl = 'E') and (orden = 'A') then
      if (tabla.FieldByName('Nombre').AsString >= iniciar) and (tabla.FieldByName('Nombre').AsString <= finalizar) then ListDeterminaciones(salida);
    if (ent_excl = 'X') and (orden = 'A') then
      if (tabla.FieldByName('Nombre').AsString < iniciar) or (tabla.FieldByName('Nombre').AsString > finalizar) then ListDeterminaciones(salida);

    tabla.Next;
  end;

  if salida <> 'X' then List.FinList;
  if salida = 'X' then Begin
    list.LineaTxt('</nomeclatura>', True);
    list.FinalizarExportacion;
  end;
end;

procedure TTObraSocial.ListDeterminaciones(salida: char);
// Objetivo...: Listar una linea de detalle
var
  m: Real;
Begin
  periodo := utiles.setPeriodoActual;
  SincronizarArancelNBU(tabla.FieldByName('codos').AsString, utiles.setPeriodoActual);

  if salida <> 'X' then Begin
    if facturaNBU <> 'S' then List.Linea(0, 0, 'Obra Social: ' + tabla.FieldByName('codos').AsString + '    ' + tabla.FieldByName('nombre').AsString, 1, 'Arial, negrita, 9, clNavy', salida, 'S') else
      List.Linea(0, 0, 'Obra Social: ' + tabla.FieldByName('codos').AsString + '    ' + tabla.FieldByName('nombre').AsString + '     ($  ' + utiles.FormatearNumero(FloatToStr(valorNBU)) + ')', 1, 'Arial, negrita, 9, clNavy', salida, 'S');
    List.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');
  end;

  if facturaNBU <> 'S' then Begin

    r := nomeclatura.setNomeclatura;
    r.Open;
    while not r.Eof do Begin
      if r.FieldByName('RIE').AsString <> '*' then m := setValorAnalisis(tabla.FieldByName('codos').AsString, r.FieldByName('codigo').AsString, r.FieldByName('ub').AsFloat, tabla.FieldByName('UB').AsFloat, r.FieldByName('gastos').AsFloat, tabla.FieldByName('UG').AsFloat) else m := setValorAnalisis(tabla.FieldByName('codos').AsString, r.FieldByName('codigo').AsString, r.FieldByName('ub').AsFloat, tabla.FieldByName('RIEUB').AsFloat, r.FieldByName('gastos').AsFloat, tabla.FieldByName('RIEUG').AsFloat);  // Valor de cada analisis
      if salida <> 'X' then Begin
        List.Linea(0, 0, r.FieldByName('codigo').AsString + '    ' + r.FieldByName('descrip').AsString, 1, 'Arial, normal, 8', salida, 'N');
        List.importe(70, list.lineactual, '', r.FieldByName('gastos').AsFloat, 2, 'Arial, normal, 8');
        List.importe(80, list.lineactual, '', r.FieldByName('ub').AsFloat, 3, 'Arial, normal, 8');
        List.Linea(81, list.lineactual, r.FieldByName('codfact').AsString, 4, 'Arial normal, 8', salida, 'N');
        List.importe(96, list.lineactual, '', m, 5, 'Arial, normal, 8');
        List.Linea(98, list.lineactual, r.FieldByName('RIE').AsString, 6, 'Arial, normal, 8', salida, 'S');
      end else Begin
        list.LineaTxt('  <determinacion>', True);
        list.LineaTxt('    <codigo>' + r.FieldByName('codigo').AsString + '</codigo>', True);
        list.LineaTxt('    <descrip>' + r.FieldByName('descrip').AsString + '</descrip>', True);
        list.LineaTxt('    <gastos>' + r.FieldByName('gastos').AsString + '</gastos>', True);
        list.LineaTxt('    <ub>' + r.FieldByName('ub').AsString + '</ub>', True);
        if Length(Trim(r.FieldByName('codfact').AsString)) > 0 then list.LineaTxt('    <codfact>' + r.FieldByName('codfact').AsString + '</codfact>', True) else
          list.LineaTxt('    <codfact>null</codfact>', True);
        list.LineaTxt('    <monto>' + utiles.FormatearNumero(FloatToStr(m)) + '</monto>', True);
        if r.FieldByName('rie').AsString = '*' then list.LineaTxt('    <rie>' + r.FieldByName('rie').AsString + '</rie>', True) else
          list.LineaTxt('    <rie>null</rie>', True);
        list.LineaTxt('  </determinacion>', True);
      end;
      r.Next;
    end;
    r.Close; r.Free;
    List.Linea(0, 0, ' ', 1, 'Arial, normal, 8', salida, 'N');
  end;

  if facturaNBU = 'S' then Begin

    r := nbu.setDeterminaciones;
    r.Open;
    while not r.Eof do Begin
      m := setValorAnalisis(tabla.FieldByName('codos').AsString, r.FieldByName('codigo').AsString, 0, 0, 0, 0);  // Valor de cada analisis
      List.Linea(0, 0, r.FieldByName('codigo').AsString + '    ' + r.FieldByName('descrip').AsString, 1, 'Arial, normal, 8', salida, 'N');
      List.importe(96, list.lineactual, '', m, 2, 'Arial, normal, 8');
      List.Linea(98, list.lineactual, '', 3, 'Arial, normal, 8', salida, 'S');
      r.Next;
    end;
    r.Close; r.Free;
    List.Linea(0, 0, ' ', 1, 'Arial, normal, 8', salida, 'N');
  end;
end;

procedure TTObraSocial.ListarAranceles(orden, iniciar, finalizar, ent_excl: string; salida: char);
// Objetivo...: Listar Obra Social con Aranceles
Begin
  idant := '';
  list.Setear(salida);
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Aranceles Obras Sociales', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'C�digo  Obra Social', 1, 'Arial, cursiva, 8');
  List.Titulo(50, list.Lineactual, 'Per�odo', 2, 'Arial, cursiva, 8');
  List.Titulo(61, list.Lineactual, 'UG', 3, 'Arial, cursiva, 8');
  List.Titulo(71, list.Lineactual, 'UB', 4, 'Arial, cursiva, 8');
  List.Titulo(80, list.Lineactual, 'RIE UB', 5, 'Arial, cursiva, 8');
  List.Titulo(90, list.Lineactual, 'RIE UG', 6, 'Arial, cursiva, 8');
  List.Titulo(96, list.Lineactual, 'Tope', 7, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  tabla.Open; tabla.First;
  while not tabla.EOF do Begin
    // Ordenado por C�digo
    if (ent_excl = 'E') and (orden = 'C') then
      if (tabla.FieldByName('codos').AsString >= iniciar) and (tabla.FieldByName('codos').AsString <= finalizar) then ListAranceles(salida);
    if (ent_excl = 'X') and (orden = 'C') then
      if (tabla.FieldByName('codos').AsString < iniciar) or (tabla.FieldByName('codos').AsString > finalizar) then ListAranceles(salida);
    // Ordenado Alfab�ticamente
    if (ent_excl = 'E') and (orden = 'A') then
      if (tabla.FieldByName('Nombre').AsString >= iniciar) and (tabla.FieldByName('Nombre').AsString <= finalizar) then ListAranceles(salida);
    if (ent_excl = 'X') and (orden = 'A') then
      if (tabla.FieldByName('Nombre').AsString < iniciar) or (tabla.FieldByName('Nombre').AsString > finalizar) then ListAranceles(salida);

    tabla.Next;
  end;

  List.FinList;
end;

procedure TTObraSocial.ListAranceles(salida: char);
// Objetivo...: Listar una linea de detalle de Aranceles
var
  m: Real;
  j, i: byte;
  l: TStringList;
Begin
  l := TStringList.Create;
  List.Linea(0, 0, tabla.FieldByName('codos').AsString + '   ' + tabla.FieldByName('nombre').AsString, 1, 'Arial, normal, 8', salida, 'S');

  SincronizarArancelNBU(tabla.FieldByName('codos').AsString, utiles.setPeriodoActual);
  if FacturaNBU <> 'S' then Begin
    datosdb.Filtrar(aranceles, 'codos = ' + tabla.FieldByName('codos').AsString);
    while not aranceles.Eof do Begin
      l.Add(Copy(aranceles.FieldByName('periodo').AsString, 4, 4) + Copy(aranceles.FieldByName('periodo').AsString, 1, 2));
      aranceles.Next;
    end;
    datosdb.QuitarFiltro(aranceles);

    l.Sort;
    For i := l.Count downto 1 do Begin
      if j > 0 then List.Linea(0, 0, ' ', 1, 'Arial, normal, 8', salida, 'N');
      if BuscarArancel(tabla.FieldByName('codos').AsString, Copy(l.Strings[i-1], 5, 2) + '/' + Copy(l.Strings[i-1], 1, 4)) then Begin
        list.Linea(50, list.Lineactual, aranceles.FieldByName('periodo').AsString, 2, 'Arial, normal, 7', salida, 'N');
        list.importe(65, list.Lineactual, '', aranceles.FieldByName('ub').AsFloat, 3, 'Arial, normal, 7');
        list.importe(75, list.Lineactual, '', aranceles.FieldByName('ug').AsFloat, 4, 'Arial, normal, 7');
        list.importe(85, list.Lineactual, '', aranceles.FieldByName('rieub').AsFloat, 5, 'Arial, normal, 7');
        list.importe(95, list.Lineactual, '', aranceles.FieldByName('rieug').AsFloat, 6, 'Arial, normal, 7');
        list.Linea(95, list.Lineactual, aranceles.FieldByName('tope').AsString, 7, 'Arial, normal, 8', salida, 'S');
      end;
      j := 1;
    end;
  end;

  if FacturaNBU = 'S' then Begin
    datosdb.Filtrar(arancelesNBU, 'codos = ' + tabla.FieldByName('codos').AsString);
    while not arancelesNBU.Eof do Begin
      l.Add(Copy(arancelesNBU.FieldByName('periodo').AsString, 4, 4) + Copy(arancelesNBU.FieldByName('periodo').AsString, 1, 2));
      arancelesNBU.Next;
    end;
    datosdb.QuitarFiltro(arancelesNBU);

    l.Sort;
    For i := l.Count downto 1 do Begin
      if j > 0 then List.Linea(0, 0, ' ', 1, 'Arial, normal, 8', salida, 'N');
      if BuscarArancelNBU(tabla.FieldByName('codos').AsString, Copy(l.Strings[i-1], 5, 2) + '/' + Copy(l.Strings[i-1], 1, 4)) then Begin
        list.Linea(50, list.Lineactual, arancelesNBU.FieldByName('periodo').AsString, 2, 'Arial, normal, 7', salida, 'N');
        list.importe(75, list.Lineactual, '', arancelesNBU.FieldByName('valor').AsFloat, 3, 'Arial, normal, 7');
        list.importe(85, list.Lineactual, '', arancelesNBU.FieldByName('valordif').AsFloat, 4, 'Arial, normal, 7');
        list.Linea(95, list.Lineactual, 'NBU', 5, 'Arial, normal, 8', salida, 'S');
      end;
      j := 1;
    end;
  end;

end;

procedure TTObraSocial.ListarNomecladorNBUValorizado(orden, iniciar, finalizar, ent_excl, exportXML, xperiodo: String; salida: Char);
// Objetivo...: Listar el nomeclador para una obra social
Begin
  idant := '';
  list.Setear(salida);
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Nomenclador NBU Valorizado', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'C�digo  Determinaci�n', 1, 'Arial, cursiva, 8');
  List.Titulo(80, list.Lineactual, 'M�dulos', 2, 'Arial, cursiva, 8');
  List.Titulo(91, list.Lineactual, 'Importe', 3, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  tabla.Open; tabla.First;
  while not tabla.EOF do Begin
    // Ordenado por C�digo
    if (ent_excl = 'E') and (orden = 'C') then
      if (tabla.FieldByName('codos').AsString >= iniciar) and (tabla.FieldByName('codos').AsString <= finalizar) then ListDeterminacionesNBU(xperiodo, salida);
    if (ent_excl = 'X') and (orden = 'C') then
      if (tabla.FieldByName('codos').AsString < iniciar) or (tabla.FieldByName('codos').AsString > finalizar) then ListDeterminacionesNBU(xperiodo, salida);
    // Ordenado Alfab�ticamente
    if (ent_excl = 'E') and (orden = 'A') then
      if (tabla.FieldByName('Nombre').AsString >= iniciar) and (tabla.FieldByName('Nombre').AsString <= finalizar) then ListDeterminacionesNBU(xperiodo, salida);
    if (ent_excl = 'X') and (orden = 'A') then
      if (tabla.FieldByName('Nombre').AsString < iniciar) or (tabla.FieldByName('Nombre').AsString > finalizar) then ListDeterminacionesNBU(xperiodo, salida);

    tabla.Next;
  end;

  List.FinList;
end;

procedure TTObraSocial.ListDeterminacionesNBU(xperiodo: String; salida: char);
// Objetivo...: Listar una linea de detalle
var
  m: Real;
Begin
  getDatos(tabla.FieldByName('codos').AsString);
  SincronizarArancelNBU(tabla.FieldByName('codos').AsString, xperiodo);
  List.Linea(0, 0, 'Obra Social: ' + tabla.FieldByName('codos').AsString + '    ' + tabla.FieldByName('nombre').AsString, 1, 'Arial, negrita, 9, clNavy', salida, 'N');
  List.Linea(70, list.Lineactual, 'Per�odo/Arancel: ' + xperiodo + '   ' + utiles.FormatearNumero(FloatToStr(valorNBU)), 2, 'Arial, negrita, 9, clNavy', salida, 'N');
  List.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');
  r := nbu.setDeterminaciones;
  r.Open;
  while not r.Eof do Begin
    m := setValorAnalisis(tabla.FieldByName('codos').AsString, r.FieldByName('codigo').AsString, 0, 0, 0, 0);
    List.Linea(0, 0, r.FieldByName('codigo').AsString + '    ' + r.FieldByName('descrip').AsString, 1, 'Arial, normal, 8', salida, 'N');
    List.importe(86, list.lineactual, '', r.FieldByName('unidad').AsFloat, 3, 'Arial, normal, 8');
    List.importe(97, list.lineactual, '', m, 4, 'Arial, normal, 8');
    List.Linea(98, list.lineactual, '', 5, 'Arial, normal, 8', salida, 'S');
    r.Next;
  end;
  r.Close; r.Free;
  List.Linea(0, 0, ' ', 1, 'Arial, normal, 8', salida, 'N');
end;

procedure TTObraSocial.CargarLista;
// Objetivo...: Cargar una Lista con las referencias de los aranceles de Obras Sociales
Begin
  if lista = Nil then lista := TStringList.Create else lista.Clear;
  if ltope = Nil then ltope := TStringList.Create else ltope.Clear;
  aranceles.First;
  while not aranceles.Eof do Begin
    lista.Add(aranceles.FieldByName('codos').AsString + Copy(aranceles.FieldByName('periodo').AsString, 4, 4) + Copy(aranceles.FieldByName('periodo').AsString, 1, 2));
    ltope.Add(aranceles.FieldByName('tope').AsString);
    aranceles.Next;
  end;

  lista.Sort;
end;

procedure TTObraSocial.CargarListaApFijos;
// Objetivo...: Cargar una Lista con las referencias de los Aportes Fijos
Begin
  if lista2 = Nil then lista2 := TStringList.Create else lista2.Clear;
  apfijos.IndexFieldNames := 'codos;items';
  apfijos.First;
  while not apfijos.Eof do Begin
    lista2.Add(apfijos.FieldByName('codos').AsString + apfijos.FieldByName('items').AsString + apfijos.FieldByName('codanalisis').AsString + apfijos.FieldByName('importe').AsString + ';1' + apfijos.FieldByName('periodo').AsString + apfijos.FieldByName('perhasta').AsString);
    apfijos.Next;
  end;
end;

procedure TTObraSocial.CargarListaApFijosNBU;
// Objetivo...: Cargar una Lista con las referencias de los Aportes Fijos
Begin
  if lista3 = Nil then lista3 := TStringList.Create else lista3.Clear;
  apfijosNBU.IndexFieldNames := 'codos;items';
  apfijosNBU.First;
  while not apfijosNBU.Eof do Begin
    lista3.Add(apfijosNBU.FieldByName('codos').AsString + apfijosNBU.FieldByName('items').AsString + apfijosNBU.FieldByName('codanalisis').AsString + apfijosNBU.FieldByName('importe').AsString + ';1' + apfijosNBU.FieldByName('periodo').AsString + apfijosNBU.FieldByName('perhasta').AsString);
    apfijosNBU.Next;
  end;
end;

procedure TTObraSocial.CargarListaUnidadesNBU;
// Objetivo...: Cargar una Lista con las referencias de las unidades fijas
Begin
  if lista4 = Nil then lista4 := TStringList.Create else lista4.Clear;
  arannbu.IndexFieldNames := 'codos;items';
  arannbu.First;
  while not arannbu.Eof do Begin
    lista4.Add(arannbu.FieldByName('codos').AsString + arannbu.FieldByName('items').AsString + arannbu.FieldByName('codigo').AsString + arannbu.FieldByName('unidad').AsString + ';1' + arannbu.FieldByName('perdesde').AsString + arannbu.FieldByName('perhasta').AsString);
    arannbu.Next;
  end;
end;

procedure TTObraSocial.BuscarPorCodigo(xexp: string);
begin
  if not (tabla.Active) then tabla.Open;  
  tabla.IndexFieldNames := 'codos';
  tabla.FindNearest([xexp]);
end;

procedure TTObraSocial.BuscarPorNombre(xexp: string);
begin
  if not (tabla.Active) then tabla.Open;  
  tabla.IndexFieldNames := 'Nombre';
  tabla.FindNearest([xexp]);
end;

procedure TTObraSocial.EstablecerObrasSocialesQueNoImportan(xlista: TStringList);
// Objetivo...: Establecer Obras Sociales que no importan
var
  i: Integer;
Begin
  tabla.First;
  while not tabla.Eof do Begin
    if tabla.FieldByName('noimport').AsString <> '' then Begin
      tabla.Edit;
      tabla.FieldByName('noimport').AsString := '';
      try
        tabla.Post
       except
        tabla.Cancel
      end;
    end;
    tabla.Next;
  end;

  if xlista <> Nil then Begin
    For i := 1 to xlista.Count do Begin
      if Buscar(xlista.Strings[i - 1]) then Begin
        tabla.Edit;
        tabla.FieldByName('noimport').AsString := 'N';
        try
          tabla.Post
         except
          tabla.Cancel
        end;
      end;
      datosdb.closeDB(tabla); tabla.Open;
      Enccol;
    end;
  end;
end;

function  TTObraSocial.setObrasSocialesQueNoImportan: TStringList;
// Objetivo...: Listar Obras Sociales que no importan
var
  l: TStringList;
Begin
  l := TStringList.Create;
  if not (tabla.Active) then tabla.Open;  
  tabla.First;
  while not tabla.Eof do Begin
    if tabla.FieldByName('noimport').AsString = 'N' then l.Add(tabla.FieldByName('codos').AsString);
    tabla.Next;
  end;
  Result := l;
end;

function TTObraSocial.setListaObrasSociales: TStringList;
// Objetivo...: Listar Obras Sociales
var
  l: TStringList;
Begin
  l := TStringList.Create;
  tabla.First;
  while not tabla.Eof do Begin
    l.Add(tabla.FieldByName('codos').AsString);
    tabla.Next;
  end;
  Result := l;
end;

function  TTObraSocial.BuscarAnalisisMontoFijo(xcodos, xcodanalisis: string): boolean;
begin
  if apfijos.IndexFieldNames <> 'codos;codanalisis' then apfijos.IndexFieldNames := 'codos;codanalisis';
  Result := datosdb.Buscar(apfijos, 'codos', 'codanalisis', xcodos, xcodanalisis);
end;

function  TTObraSocial.BuscarItemsMontoFijo(xcodos, xitems: string): boolean;
begin
  if apfijos.IndexFieldNames <> 'codos;items' then apfijos.IndexFieldNames := 'codos;items';
  Result := datosdb.Buscar(apfijos, 'codos', 'items', xcodos, xitems);
end;

procedure TTObraSocial.GrabarAnalisisMontoFijo(xcodos, xitems, xcodanalisis, xperiodo, xperiodobaja: string; ximporte: real; xcantitems: Integer);
begin
  if BuscarItemsMontoFijo(xcodos, xitems) then apfijos.Edit else apfijos.Append;
  apfijos.FieldByName('codos').AsString       := xcodos;
  apfijos.FieldByName('items').AsString       := xitems;
  apfijos.FieldByName('codanalisis').AsString := xcodanalisis;
  apfijos.FieldByName('periodo').AsString     := xperiodo;
  apfijos.FieldByName('importe').AsFloat      := ximporte;
  apfijos.FieldByName('perhasta').AsString    := xperiodobaja;
  try
    apfijos.Post
  except
    apfijos.Cancel
  end;
  if xitems = utiles.sLlenarIzquierda(IntToStr(xcantitems), 3, '0') then Begin
    datosdb.tranSQL('delete from apfijos where codos = ' + '''' + xcodos + '''' + ' and items > ' + '''' + xitems + '''');
    datosdb.closeDB(apfijos); apfijos.Open;
    CargarListaApFijos;
  end;
end;

procedure TTObraSocial.BorrarAnalisisMontoFijo(xcodos, xitems: string);
begin
  if BuscarItemsMontoFijo(xcodos, xitems) then Begin
    apfijos.Delete;
    CargarListaApFijos;
  end;
end;

function  TTObraSocial.setAnalisisMontoFijo(xcodos: string): TQuery;
begin
  Result := datosdb.tranSQL(apfijos.DatabaseName, 'SELECT * FROM apfijos WHERE codos = ' + '"' + xcodos + '"' + ' ORDER BY items');
end;

function  TTObraSocial.setAnalisisMontoFijo(xcodos, xcodigo: string): TQuery;
begin
  Result := datosdb.tranSQL(apfijos.DatabaseName, 'SELECT * FROM apfijos WHERE codos = ' + '"' + xcodos + '"' + ' AND codanalisis = ' + '''' + xcodigo + '''' + ' ORDER BY items');
end;

function  TTObraSocial.BuscarAnalisisMontoFijoNBU(xcodos, xcodanalisis: string): boolean;
begin
  if apfijosNBU.IndexFieldNames <> 'codos;codanalisis' then apfijosNBU.IndexFieldNames := 'codos;codanalisis';
  Result := datosdb.Buscar(apfijosNBU, 'codos', 'codanalisis', xcodos, xcodanalisis);
end;

function  TTObraSocial.BuscarItemsMontoFijoNBU(xcodos, xitems: string): boolean;
begin
  if apfijosNBU.IndexFieldNames <> 'codos;items' then apfijosNBU.IndexFieldNames := 'codos;items';
  Result := datosdb.Buscar(apfijosNBU, 'codos', 'items', xcodos, xitems);
end;

procedure TTObraSocial.GrabarAnalisisMontoFijoNBU(xcodos, xitems, xcodanalisis, xperiodo, xperiodobaja: string; ximporte: real; xcantitems: Integer);
begin
  if BuscarItemsMontoFijoNBU(xcodos, xitems) then apfijosNBU.Edit else apfijosNBU.Append;
  apfijosNBU.FieldByName('codos').AsString       := xcodos;
  apfijosNBU.FieldByName('items').AsString       := xitems;
  apfijosNBU.FieldByName('codanalisis').AsString := xcodanalisis;
  apfijosNBU.FieldByName('periodo').AsString     := xperiodo;
  apfijosNBU.FieldByName('perhasta').AsString    := xperiodobaja;
  apfijosNBU.FieldByName('importe').AsFloat      := ximporte;
  try
    apfijosNBU.Post
  except
    apfijosNBU.Cancel
  end;
  if xitems = utiles.sLlenarIzquierda(IntToStr(xcantitems), 3, '0') then Begin
    datosdb.tranSQL('delete from apfijosNBU where codos = ' + '''' + xcodos + '''' + ' and items > ' + '''' + xitems + '''');
    datosdb.closeDB(apfijosNBU); apfijosNBU.Open;
    CargarListaApFijosNBU;
  end;
end;

procedure TTObraSocial.BorrarAnalisisMontoFijoNBU(xcodos, xitems: string);
begin
  if BuscarItemsMontoFijoNBU(xcodos, xitems) then Begin
    apfijosNBU.Delete;
    CargarListaApFijosNBU;
  end;
end;

function  TTObraSocial.setAnalisisMontoFijoNBU(xcodos: string): TQuery;
begin
  Result := datosdb.tranSQL(apfijosNBU.DatabaseName, 'SELECT * FROM apfijosNBU WHERE codos = ' + '"' + xcodos + '"' + ' ORDER BY items');
end;

function  TTObraSocial.setAnalisisMontoFijoNBU(xcodos, xcodigo: string): TQuery;
begin
  Result := datosdb.tranSQL(apfijosNBU.DatabaseName, 'SELECT * FROM apfijosNBU WHERE codos = ' + '"' + xcodos + '"' + ' AND codanalisis = ' + '''' + xcodigo + '''' + ' ORDER BY items');
end;

procedure  TTObraSocial.VerDatosLiquidacion;
// Objetivo...: Visualizar solo los datos de liquidaci�n
var
  i: Integer;
begin
  For i := 1 to tabla.FieldCount do
    tabla.Fields[i-1].Visible := False;
  tabla.FieldByName('codos').Visible := True; tabla.FieldByName('Nombre').Visible := True;
end;

procedure TTObraSocial.DarDeBaja(xcodos, xfecha: String);
// Objetivo...: Dar de baja Obra Social
begin
  if Buscar(xcodos) then Begin
    tabla.Edit;
    tabla.FieldByName('baja').AsString := utiles.sExprFecha2000(xfecha);
    try
      tabla.Post
     except
      tabla.Cancel
    end;
    datosdb.refrescar(tabla);
  end;
end;

procedure TTObraSocial.Reactivar(xcodos: String);
// Objetivo...: Reactivar obra social est� activa
begin
  if Buscar(xcodos) then Begin
    tabla.Edit;
    tabla.FieldByName('baja').Clear;
    try
      tabla.Post
     except
      tabla.Cancel
    end;
    datosdb.refrescar(tabla);
  end;
end;

function  TTObraSocial.verificarSiEstaDadaDeBaja: Boolean;
// Objetivo...: Verificar si la obra social est� activa
Begin
  if (Length(Trim(baja)) = 0) then Result := False else
    if (utiles.sExprFecha2000(utiles.setFechaActual) >= utiles.sExprFecha2000(baja)) then Result := True else Result := False;
end;

procedure TTObraSocial.FijarQuitarCategoria;
begin
  tabla.Edit;
  if tabla.FieldByName('categoria').AsString = 'S' then tabla.FieldByName('categoria').AsString := 'N' else tabla.FieldByName('categoria').AsString := 'S';
  try
    tabla.Post
   except
    tabla.Cancel
  end;
  tabla.Next;
  if tabla.EOF then tabla.Last;
end;

function  TTObraSocial.VerifcarSiElAnalisisTieneMontoFijo(xcodos, xcodanalisis: string): Real;
// Objetivo...: Verificar si el analisis tiene, para la obra social, monto fijo
begin
  if BuscarAnalisisMontoFijo(xcodos, xcodanalisis) then
    if Length(Trim(apfijos.FieldByName('periodo').AsString)) < 7 then Result := apfijos.FieldByName('importe').AsFloat else Result := 0;
end;

function  TTObraSocial.VerifcarSiElAnalisisTieneMontoFijoNBU(xcodos, xcodanalisis: string): Real;
// Objetivo...: Verificar si el analisis tiene, para la obra social, monto fijo NBU
begin
  if BuscarAnalisisMontoFijoNBU(xcodos, xcodanalisis) then
    if Length(Trim(apfijosNBU.FieldByName('periodo').AsString)) < 7 then Result := apfijosNBU.FieldByName('importe').AsFloat else Result := 0;
end;

function TTObraSocial.setMontoFijo(xcodos, xcodanalisis, xperiodo: String): Real;
// Objetivo...: Recuperar Monto Fijo An�lisis por Per�odo
var
  i, p, p1, p2, p3: Integer;
  r: Real;
  t: string;
Begin
  r := 0; t := '';
  For i := 1 to lista2.Count do Begin
    p := Pos(';1', lista2.Strings[i-1]);
    if (xcodos = Copy(lista2.Strings[i-1], 1, 6)) and (xcodanalisis = Copy(lista2.Strings[i-1], 10, 4)) then Begin
      if Length(Trim(Copy(lista2.Strings[i-1], p+2, 7))) > 0 then Begin
        p1 := StrToInt(Copy(Copy(lista2.Strings[i-1], p+2, 7), 4, 4) + Copy(Copy(lista2.Strings[i-1], p+2, 7), 1, 2));
        p2 := StrToInt(Copy(xperiodo, 4, 4) + Copy(xperiodo, 1, 2));
        if  p1 >= p2 then Begin
          if p1 = p2 then t := (Copy(lista2.Strings[i-1], 14, p-14));
          //Break;
        end;
        t := (Copy(lista2.Strings[i-1], 14, p-14));
        // Verificamos el per�odo de Baja
        if Length(Trim( Copy( Copy(lista2.Strings[i-1], p+9, 7), 4, 4) + Copy( Copy(lista2.Strings[i-1], p+9, 7), 1, 2) )) > 0 then
          if (Copy(xperiodo, 4, 4) + Copy(xperiodo, 1, 2)) >= Copy( Copy(lista2.Strings[i-1], p+9, 7), 4, 4) + Copy( Copy(lista2.Strings[i-1], p+9, 7), 1, 2) then begin
            t := '';
            //if (length(trim(Copy( Copy(lista2.Strings[i-1], p+9, 7), 4, 4) + Copy( Copy(lista2.Strings[i-1], p+9, 7), 1, 2))) > 0) then break;
          end;

        //utiles.msgError((Copy(xperiodo, 4, 4) + Copy(xperiodo, 1, 2)) +  ' >= ' + Copy( Copy(lista2.Strings[i-1], p+9, 7), 4, 4) + Copy( Copy(lista2.Strings[i-1], p+9, 7), 1, 2));
      end;
    end;
  end;

  if Length(Trim(t)) = 0 then Begin
    MontoFijo := False;
    Result := r;
  end else Begin
    MontoFijo := True;
    Result := StrToFloat(t);
  end;
end;

procedure TTObraSocial.BajaPeriodoMontoFijo(xcodos, xitems, xperiodo: string);
begin
   if (BuscarItemsMontoFijo(xcodos, xitems)) then begin
     apfijos.Edit;
     apfijos.FieldByName('perhasta').AsString := xperiodo;
     try
       apfijos.Post
     except
       apfijos.Cancel
     end;
     datosdb.refrescar(apfijos);
   end;
end;

procedure TTObraSocial.BajaPeriodoMontoFijoNBU(xcodos, xitems, xperiodo: string);
begin
   if (BuscarItemsMontoFijoNBU(xcodos, xitems)) then begin
     apfijosnbu.Edit;
     apfijosnbu.FieldByName('perhasta').AsString := xperiodo;
     try
       apfijosnbu.Post
     except
       apfijosnbu.Cancel
     end;
     datosdb.refrescar(apfijosnbu);
   end;
end;

function TTObraSocial.setMontoFijoNBU(xcodos, xcodanalisis, xperiodo: String): Real;
// Objetivo...: Recuperar Monto Fijo An�lisis por Per�odo NBU
var
  i, p, p1, p2, mp: Integer;
  r: Real;
  t: string;
Begin
  r := 0; t := '';
  For i := 1 to lista3.Count do Begin
    p := Pos(';1', lista3.Strings[i-1]);
    if (xcodos = Copy(lista3.Strings[i-1], 1, 6)) and (xcodanalisis = Copy(lista3.Strings[i-1], 10, 6)) then Begin
      if Length(Trim(Copy(lista3.Strings[i-1], p+2, 7))) > 0 then Begin
        p1 := StrToInt(Copy(Copy(lista3.Strings[i-1], p+2, 7), 4, 4) + Copy(Copy(lista3.Strings[i-1], p+2, 7), 1, 2));
        p2 := StrToInt(Copy(xperiodo, 4, 4) + Copy(xperiodo, 1, 2));

        if  p1 >= p2 then Begin
          if p1 = p2 then t := (Copy(lista3.Strings[i-1], 16, p-16));
          Break;
        end;

        // Captamos el de mayor per�odo
        if p1 > mp then Begin
          t  := (Copy(lista3.Strings[i-1], 16, p-16));
          mp := p1;
        end;

        // Verificamos el per�odo de Baja
        if Length(Trim( Copy( Copy(lista3.Strings[i-1], p+9, 7), 4, 4) + Copy( Copy(lista3.Strings[i-1], p+9, 7), 1, 2) )) > 0 then
          if (Copy(xperiodo, 4, 4) + Copy(xperiodo, 1, 2)) >= Copy( Copy(lista3.Strings[i-1], p+9, 7), 4, 4) + Copy( Copy(lista3.Strings[i-1], p+9, 7), 1, 2) then t := '';
      end;
    end;
  end;
  if Length(Trim(t)) = 0 then Begin
    MontoFijo := False;
    Result := r;
  end else Begin
    MontoFijo := True;
    Result := StrToFloat(t);
  end;
end;

function TTObraSocial.setUnidadNBU(xcodos, xcodanalisis, xperiodo: String): Real;
// Objetivo...: Recuperar Monto Fijo An�lisis por Per�odo NBU
var
  i, p, p1, p2: Integer;
  r: Real;
  t: string;
Begin
  r := 0; t := '';
  For i := 1 to lista4.Count do Begin
    p := Pos(';1', lista4.Strings[i-1]);
    if (xcodos = Copy(lista4.Strings[i-1], 1, 6)) and (xcodanalisis = Copy(lista4.Strings[i-1], 10, 6)) then Begin
      if Length(Trim(Copy(lista4.Strings[i-1], p+2, 7))) > 0 then Begin
        p1 := StrToInt(Copy(Copy(lista4.Strings[i-1], p+2, 7), 4, 4) + Copy(Copy(lista4.Strings[i-1], p+2, 7), 1, 2));
        p2 := StrToInt(Copy(xperiodo, 4, 4) + Copy(xperiodo, 1, 2));
        if  p1 >= p2 then Begin
          if p1 = p2 then t := (Copy(lista4.Strings[i-1], 16, p-16));
          Break;
        end;
        t := (Copy(lista4.Strings[i-1], 16, p-16));
        // Verificamos el per�odo de Baja
        if Length(Trim( Copy( Copy(lista4.Strings[i-1], p+9, 7), 4, 4) + Copy( Copy(lista4.Strings[i-1], p+9, 7), 1, 2) )) > 0 then
          if (Copy(xperiodo, 4, 4) + Copy(xperiodo, 1, 2)) >= Copy( Copy(lista4.Strings[i-1], p+9, 7), 4, 4) + Copy( Copy(lista4.Strings[i-1], p+9, 7), 1, 2) then t := '';
      end;
    end;
  end;
  if Length(Trim(t)) = 0 then Begin
    Result := r;
  end else Begin
    Result := StrToFloat(t);
  end;
end;

function TTObraSocial.setValorAnalisis(xcodos, xcodanalisis: string; xOSUB, xNOUB, xOSUG, xNOUG: real): real;
var
  i, j, v, v9984, porcentOS: real; montoFijo: Boolean; codftoma: String;
begin
  if Factnbu = 'N' then Begin
  // Verificamos el porcentaje que paga la Obra Social
  if obsocial.porcentaje > 0 then porcentOS := (obsocial.porcentaje * 0.01) else porcentOS := (100 * 0.01);

  i := 0; j := 0; v9984 := 0;
  // 1� Verificamos que el analisis no tenga monto Fijo
  i := obsocial.VerifcarSiElAnalisisTieneMontoFijo(xcodos, xcodanalisis);
  if i = 0 then Begin
    // C�lculamos el valor del an�lisis
    i := (xOSUB * xNOUB) + (xOSUG * xNOUG);

    montoFijo := False;
  end else montoFijo := True;
  // Calculamos el valor del codigo de toma y recepci�n
  if Length(Trim(nomeclatura.cftoma)) > 0 then Begin
    codftoma := nomeclatura.cftoma;  // Capturamos el c�digo fijo de toma y recepcion
    nomeclatura.getDatos(codftoma);
    j := obsocial.VerifcarSiElAnalisisTieneMontoFijo(xcodos, codftoma);   // Verificamos si el 9984 tiene Monto Fijo

    if j = 0 then Begin      // Deducimos en Forma Normal
      v9984   := ((obsocial.UG * nomeclatura.ub) + (obsocial.UB * nomeclatura.gastos));

      if obsocial.tope = 'S' then Begin
        v := v9984;
        if v < obsocial.topemin then Begin
          v9984 := v * 2;   // Si monto menor a topemin entonces se multiplica por 2
        end;
        if (v > obsocial.topemin) and (v < obsocial.topemax) then v9984 := obsocial.topemax;  // Si esta comprendido entre los topes, toma el valor maximo
      end;
    end else Begin               // Monto Fijo del 9984
      v9984   := j;
    end;
  end;

  v := i;
  if not montoFijo then Begin          // Obras sociales que trabajan con topes
    if obsocial.tope = 'S' then Begin
      if v < obsocial.topemin then i := i * 2;   // Si monto menor a topemin entonces se multiplica por 2
      if (v > obsocial.topemin) and (v < obsocial.topemax) then i := obsocial.topemax;  // Si esta comprendido entre los topes, toma el valor maximo
    end;
  end;

  i := i * porcentOS;

  end;

  if FacturaNBU = 'S' then Begin
    nbu.getDatos(xcodanalisis);
    i := setMontoFijoNBU(xcodos, xcodanalisis, periodo);
    if i = 0 then begin
      if (nbu.Especial <> '*') then i := nbu.unidad * valorNBU;
      if (nbu.Especial = '*')  then i := nbu.unidad * valorNBUDif;
    end;
  end;

  Result := i;
end;

function  TTObraSocial.BuscarArancel(xcodos, xperiodo: String): Boolean;
// Objetivo...: Buscar Arancel
Begin
  Result := datosdb.Buscar(aranceles, 'codos', 'periodo', xcodos, xperiodo);
end;

procedure TTObraSocial.GuardarArancel(xcodos, xperiodo, xtope: String; xub, xug, xrieub, xrieug: Real);
// Objetivo...: Guardar Arancel
Begin
  if BuscarArancel(xcodos, xperiodo) then aranceles.Edit else aranceles.Append;
  aranceles.FieldByName('codos').AsString   := xcodos;
  aranceles.FieldByName('periodo').AsString := xperiodo;
  aranceles.FieldByName('ub').AsFloat       := xub;
  aranceles.FieldByName('ug').AsFloat       := xug;
  aranceles.FieldByName('rieub').AsFloat    := xrieub;
  aranceles.FieldByName('rieug').AsFloat    := xrieug;
  aranceles.FieldByName('tope').AsString    := xtope;
  try
    aranceles.Post
   except
    aranceles.Cancel
  end;
  datosdb.closedb(aranceles); aranceles.Open;
  CargarLista;
end;

procedure TTObraSocial.BorrarArancel(xcodos, xperiodo: String);
// Objetivo...: Borrar Arancel
Begin
  if BuscarArancel(xcodos, xperiodo) then Begin
    aranceles.Delete;
    datosdb.refrescar(aranceles);
    CargarLista;
  end;
end;

function  TTObraSocial.setAranceles(xcodos: String): TStringList;
// Objetivo...: Recuperar Aranceles
var
  l, l1, l2: TStringList;
  i: Integer;
Begin
  l  := TStringList.Create;
  l1 := TStringList.Create;
  l2 := TStringList.Create;
  i  := 0;
  datosdb.Filtrar(aranceles, 'codos = ' + xcodos);
  while not aranceles.Eof do Begin
    l.Add(aranceles.FieldByName('periodo').AsString + ';1' + aranceles.FieldByName('ub').AsString + ';2' + aranceles.FieldByName('ug').AsString + ';3' + aranceles.FieldByName('rieub').AsString + ';4' + aranceles.FieldByName('rieug').AsString + ';5' + aranceles.FieldByName('tope').AsString);
    l1.Add(Copy(aranceles.FieldByName('periodo').AsString, 4, 4) + Copy(aranceles.FieldByName('periodo').AsString, 1, 2) + IntToStr(i));
    Inc(i);
    aranceles.Next;
  end;
  datosdb.QuitarFiltro(aranceles);
  l1.Sort;
  for i := 1 to l1.Count do
    l2.Add(l.Strings[StrToInt(Trim(Copy(l1.Strings[i-1], 7, 3)))]);
  l1.Destroy; l.Destroy;
  Result := l2;
end;

procedure TTObraSocial.ObtenerUltimosAranceles(xcodos: String);
// Objetivo...: Recuperar los Ultimos Aranceles Aranceles
Begin
  datosdb.Filtrar(aranceles, 'codos = ' + xcodos);
  while not aranceles.Eof do Begin
    UB      := aranceles.FieldByName('UB').AsFloat;
    UG      := aranceles.FieldByName('UG').AsFloat;
    RIEUB   := aranceles.FieldByName('RIEUB').AsFloat;
    RIEUG   := aranceles.FieldByName('RIEUG').AsFloat;
    Periodo := aranceles.FieldByName('periodo').AsString;
    tope    := aranceles.FieldByName('tope').AsString;
    aranceles.Next;
  end;
  datosdb.QuitarFiltro(aranceles);
end;

procedure TTObraSocial.SincronizarArancel(xcodos, xperiodo: String);
// Objetivo...: Sincronizar Aranceles
var
  i: Integer;
  ccod: String;
Begin
  if ArancelesDiferenciales then ccod := codosdif else ccod := xcodos;

  // Chequeamos y Determinamos si el per�odo factura por NBU
  FacturaNBU := 'N';
  if factNBU = 'S' then
    //if (Copy(xperiodo, 1, 4) + Copy(xperiodo, 6, 2)) >= (Copy(perNBU, 1, 4) + Copy(perNBU, 6, 2)) then FacturaNBU := 'S';
    // 29/01/2008
    if (Copy(xperiodo, 4, 4) + Copy(xperiodo, 1, 2)) >= (Copy(perNBU, 4, 4) + Copy(perNBU, 1, 2)) then FacturaNBU := 'S';

  if FacturaNBU = 'S' then SincronizarArancelNBU(xcodos, xperiodo) else Begin

    if lista <> Nil then Begin
      For i := lista.Count downto 1 do Begin
        if (ccod = Copy(lista.Strings[i-1], 1, 6)) and (Copy(lista.Strings[i-1], 7, 6) <=  Copy(xperiodo, 4, 4) + Copy(xperiodo, 1, 2)) then Begin
          if BuscarArancel(ccod, Copy(lista.Strings[i-1], 11, 2) + '/' + Copy(lista.Strings[i-1], 7, 4)) then Begin
            UB      := aranceles.FieldByName('UB').AsFloat;
            UG      := aranceles.FieldByName('UG').AsFloat;
            RIEUB   := aranceles.FieldByName('RIEUB').AsFloat;
            RIEUG   := aranceles.FieldByName('RIEUG').AsFloat;
            tope    := aranceles.FieldByName('tope').AsString;
          end;
          Break;
        end;
      end;
    end;

  end;

  SincronizarPosicionFiscal(ccod, xperiodo);
end;

procedure TTObraSocial.FijarPosicionFiscal(xcodos, xperiodo: String; xretiva: Real);
// Objetivo...: Fijar Condici�n Fiscal Obra Social
Begin
  if datosdb.Buscar(retiva, 'Codos', 'Periodo', xcodos, xperiodo) then retiva.Edit else retiva.Append;
  retiva.FieldByName('codos').AsString     := xcodos;
  retiva.FieldByName('periodo').AsString   := xperiodo;
  retiva.FieldByName('retieneiva').AsFloat := xretiva;
  try
    retiva.Post
   except
    retiva.Cancel
  end;
  datosdb.closedb(retiva); retiva.Open;
end;

procedure TTObraSocial.BorrarPosicionFiscal(xcodos, xperiodo: String);
// Objetivo...: Borrar Condici�n Fiscal Obra Social
Begin
  if datosdb.Buscar(retiva, 'Codos', 'Periodo', xcodos, xperiodo) then retiva.Delete;
  datosdb.refrescar(retiva);
end;

function TTObraSocial.setPosicionFiscal(xcodos: String): TStringList;
// Objetivo...: Devolver un Set con Condiciones Fiscales
var
  l, s: TStringList;
  i: Integer;
Begin
  l := TStringList.Create; s := TStringList.Create;
  datosdb.Filtrar(retiva, 'codos = ' + '''' + xcodos + '''');
  while not retiva.Eof do Begin
    l.Add(Copy(retiva.FieldByName('periodo').AsString, 4, 4) + Copy(retiva.FieldByName('periodo').AsString, 1, 2) + retiva.FieldByName('retieneiva').AsString);
    retiva.Next;
  end;
  datosdb.QuitarFiltro(retiva);
  l.Sort;
  For i := 1 to l.Count do
    s.Add(Copy(l.Strings[i-1], 5, 2) + '/' + Copy(l.Strings[i-1], 1, 4) + Copy(l.Strings[i-1], 7, 20));

  Result := s;
end;

procedure TTObraSocial.SincronizarPosicionFiscal(xcodos, xperiodo: String);
// Objetivo...: Devolver un Set con Condiciones Fiscales
var
  l: TStringList;
  i: integer;
  peranter: String;
Begin
  {peranter := '';
  if not retiva.Active then retiva.Open;
  datosdb.Filtrar(retiva, 'codos = ' + '''' + xcodos + '''');
  retiva.First;
  while not retiva.Eof do Begin
    if Copy(retiva.FieldByName('periodo').AsString, 4, 4) + Copy(retiva.FieldByName('periodo').AsString, 1, 2) <= Copy(xperiodo, 4, 4) + Copy(xperiodo, 1, 2) then Begin
      if Copy(retiva.FieldByName('periodo').AsString, 4, 4) + Copy(retiva.FieldByName('periodo').AsString, 1, 2) >= peranter then retencioniva := retiva.FieldByName('retieneiva').AsFloat;
      peranter := Copy(retiva.FieldByName('periodo').AsString, 4, 4) + Copy(retiva.FieldByName('periodo').AsString, 1, 2);
    end;
    retiva.Next;
  end;
  datosdb.QuitarFiltro(retiva);}

  l := setPosicionFiscal(xcodos);
  for i := 1 to l.Count do begin
    peranter := Copy(l.Strings [i-1], 1, 7);
    if (copy(peranter, 4, 4) + copy(peranter, 1, 2)) < copy(xperiodo, 4, 4) + copy(xperiodo, 1, 2) then retencioniva := strtofloat(Trim(Copy(l.Strings [i-1], 8, 15)));
  end;
end;

function  TTObraSocial.BuscarArancelNBU(xcodos, xperiodo: String): Boolean;
// Objetivo...: Devolver Aranceles
Begin
  if arancelesNBU.IndexFieldNames <> 'codos;periodo' then arancelesNBU.IndexFieldNames := 'codos;periodo';
  Result := datosdb.Buscar(arancelesNBU, 'codos', 'periodo', xcodos, xperiodo);
end;

procedure TTObraSocial.GuardarArancelNBU(xcodos, xperiodo: String; xvalor, xvalordif: Real);
// Objetivo...: Registrar Aranceles
Begin
  if BuscarArancelNBU(xcodos, xperiodo) then arancelesNBU.Edit else arancelesNBU.Append;
  arancelesNBU.FieldByName('codos').AsString   := xcodos;
  arancelesNBU.FieldByName('periodo').AsString := xperiodo;
  arancelesNBU.FieldByName('valor').AsFloat    := xvalor;
  arancelesNBU.FieldByName('valordif').AsFloat := xvalordif;
  try
    arancelesNBU.Post
   except
    arancelesNBU.Cancel
  end;
  datosdb.closeDB(arancelesNBU); arancelesNBU.Open;
  CargarListaNBU;
end;

procedure TTObraSocial.BorrarArancelNBU(xcodos, xperiodo: String);
// Objetivo...: Devolver Borrar Aranceles
Begin
  if BuscarArancelNBU(xcodos, xperiodo) then Begin
    arancelesNBU.Delete;
    datosdb.closeDB(arancelesNBU); arancelesNBU.Open;
    CargarListaNBU;
  end;
end;

function  TTObraSocial.setArancelesNBU(xcodos: String): TStringList;
// Objetivo...: Recuperar Aranceles
var
  l, l1, l2: TStringList;
  i: Integer;
Begin
  l  := TStringList.Create;
  l1 := TStringList.Create;
  l2 := TStringList.Create;
  i  := 0;
  datosdb.Filtrar(arancelesNBU, 'codos = ' + xcodos);
  while not arancelesNBU.Eof do Begin
    l.Add(arancelesNBU.FieldByName('periodo').AsString + arancelesNBU.FieldByName('codos').AsString + arancelesNBU.FieldByName('valor').AsString + ';1' + arancelesNBU.FieldByName('valordif').AsString);
    l1.Add(Copy(arancelesNBU.FieldByName('periodo').AsString, 4, 4) + Copy(arancelesNBU.FieldByName('periodo').AsString, 1, 2) + IntToStr(i));
    Inc(i);
    arancelesNBU.Next;
  end;
  datosdb.QuitarFiltro(arancelesNBU);
  l1.Sort;
  for i := 1 to l1.Count do
    l2.Add(l.Strings[StrToInt(Trim(Copy(l1.Strings[i-1], 7, 3)))]);
  l1.Destroy; l.Destroy;
  Result := l2;
end;

procedure TTObraSocial.ObtenerUltimosArancelesNBU(xcodos: String);
// Objetivo...: Devolver Ultimos Aranceles
Begin
  datosdb.Filtrar(arancelesNBU, 'codos = ' + xcodos);
  while not arancelesNBU.Eof do Begin
    valorNBU    := arancelesNBU.FieldByName('valor').AsFloat;
    valorNBUDif := arancelesNBU.FieldByName('valordif').AsFloat;
    arancelesNBU.Next;
  end;
  datosdb.QuitarFiltro(arancelesNBU);
end;

procedure TTObraSocial.SincronizarArancelNBU(xcodos, xperiodo: String);
// Objetivo...: Devolver Aranceles
var
  i: Integer;
  ccod: String;
Begin
  FacturaNBU := 'N';
  if ArancelesDiferenciales then ccod := codosdif else ccod := xcodos;

  if listaNBU <> Nil then Begin
    For i := listaNBU.Count downto 1 do Begin
      if (ccod = Copy(listaNBU.Strings[i-1], 1, 6)) and (Copy(listaNBU.Strings[i-1], 7, 6) <=  Copy(xperiodo, 4, 4) + Copy(xperiodo, 1, 2)) then Begin
        if BuscarArancelNBU(ccod, Copy(listaNBU.Strings[i-1], 11, 2) + '/' + Copy(listaNBU.Strings[i-1], 7, 4)) then Begin
          valorNBU    := arancelesNBU.FieldByName('valor').AsFloat;
          valorNBUDif := arancelesNBU.FieldByName('valordif').AsFloat;
          FacturaNBU := 'S';
        end;
        Break;
      end;
    end;
  end;
end;

procedure TTObraSocial.CargarListaNBU;
// Objetivo...: Cargar una Lista con las referencias de los aranceles NBU de Obras Sociales
Begin
  if listaNBU = Nil then listaNBU := TStringList.Create else listaNBU.Clear;
  arancelesNBU.First;
  while not arancelesNBU.Eof do Begin
    listaNBU.Add(arancelesNBU.FieldByName('codos').AsString + Copy(arancelesNBU.FieldByName('periodo').AsString, 4, 4) + Copy(arancelesNBU.FieldByName('periodo').AsString, 1, 2));
    arancelesNBU.Next;
  end;

  listaNBU.Sort;
end;

function  TTObraSocial.BuscarUnidadNBU(xcodos, xitems: String): Boolean;
// Objetivo...: Buscar Instancia
Begin
  if arannbu.IndexFieldNames <> 'codos;items' then arannbu.IndexFieldNames := 'codos;items';
  Result := datosdb.Buscar(arannbu, 'codos', 'items', xcodos, xitems);
end;

procedure TTObraSocial.RegistrarUnidadNBU(xcodos, xitems, xcodigo, xperiodo_alta, xperiodo_baja: String; xunidad: Real; xcantitems: Integer);
// Objetivo...: Registrar Instancia
Begin
  if BuscarUnidadNBU(xcodos, xitems) then arannbu.Edit else arannbu.Append;
  arannbu.FieldByName('codos').AsString    := xcodos;
  arannbu.FieldByName('items').AsString    := xitems;
  arannbu.FieldByName('codigo').AsString   := xcodigo;
  arannbu.FieldByName('perdesde').AsString := xperiodo_alta;
  arannbu.FieldByName('perhasta').AsString := xperiodo_baja;
  arannbu.FieldByName('unidad').AsFloat    := xunidad;
  try
    arannbu.Post
   except
    arannbu.Cancel
  end;
  if xitems = utiles.sLlenarIzquierda(IntToStr(xcantitems), 3, '0') then Begin
    datosdb.tranSQL(arannbu.DatabaseName, 'delete from ' + arannbu.TableName + ' where codos = ' + '''' + xcodos + '''' + ' and items > ' + '''' + xitems + '''');
    datosdb.closeDB(arannbu); arannbu.Open;
  end;
  CargarListaUnidadesNBU;
end;

procedure TTObraSocial.BorrarUnidadNBU(xcodos, xitems: String);
// Objetivo...: Borrar Instancia
Begin
  if BuscarUnidadNBU(xcodos, xitems) then Begin
    arannbu.Delete;
    datosdb.closeDB(arannbu); arannbu.Open;
  end;
  CargarListaUnidadesNBU;
end;

function  TTObraSocial.setUnidadNBU(xcodos: String): TQuery;
// Objetivo...: Devolver Lista de Determinaciones
Begin
  Result := datosdb.tranSQL(arannbu.DatabaseName, 'select * from ' + arannbu.TableName + ' where codos = ' + '''' + xcodos + '''' + ' order by codos, items');
end;

procedure TTObraSocial.ListarUnidadesNBU(orden, iniciar, finalizar, ent_excl: string; salida: char);

procedure ListLineaNBU(salida: char);
Begin
  idant := '';

  datosdb.Filtrar(arannbu, 'codos = ' + '''' + tabla.FieldByName('codos').AsString + '''');

  arannbu.First;
  while not arannbu.Eof do Begin
    if tabla.FieldByName('codos').AsString = idant then List.Linea(0, 0, '   ', 1, 'Arial, normal, 8', salida, 'N') else
      List.Linea(0, 0, tabla.FieldByName('codos').AsString + '   ' + tabla.FieldByName('nombre').AsString, 1, 'Arial, normal, 8', salida, 'N');
    idant := tabla.FieldByName('codos').AsString;
    nbu.getDatos(arannbu.FieldByName('codigo').AsString);
    List.Linea(40, list.Lineactual, arannbu.FieldByName('codigo').AsString, 2, 'Arial, normal, 8', salida, 'N');
    List.Linea(46, list.Lineactual, Copy(nbu.descrip, 1, 35), 3, 'Arial, normal, 8', salida, 'N');
    List.Importe(86, list.Lineactual, '', arannbu.FieldByName('unidad').AsFloat, 4, 'Arial, normal, 8');
    List.Linea(87, list.Lineactual, arannbu.FieldByName('perdesde').AsString, 5, 'Arial, normal, 8', salida, 'N');
    List.Linea(93, list.Lineactual, arannbu.FieldByName('perhasta').AsString, 6, 'Arial, normal, 8', salida, 'S');
    arannbu.Next;
  end;
  datosdb.QuitarFiltro(arannbu);
end;

Begin
  list.Setear(salida);
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Listado de Unidades Diferenciales N.B.U.', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'C�digo  Detrminaci�n', 1, 'Arial, cursiva, 8');
  List.Titulo(80, list.Lineactual, 'Unidad', 2, 'Arial, cursiva, 8');
  List.Titulo(87, list.Lineactual, 'P.Alta', 3, 'Arial, cursiva, 8');
  List.Titulo(93, list.Lineactual, 'P.Baja', 4, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  if orden = 'C' then tabla.IndexFieldNames := 'codos';
  if orden = 'A' then tabla.IndexFieldNames := 'nombre';

  tabla.First;
  while not tabla.EOF do Begin
    // Ordenado por C�digo
    if (ent_excl = 'E') and (orden = 'C') then
      if (tabla.FieldByName('codos').AsString >= iniciar) and (tabla.FieldByName('codos').AsString <= finalizar) then ListLineaNBU(salida);
    if (ent_excl = 'X') and (orden = 'C') then
      if (tabla.FieldByName('codos').AsString < iniciar) or (tabla.FieldByName('codos').AsString > finalizar) then ListLineaNBU(salida);
    // Ordenado Alfab�ticamente
    if (ent_excl = 'E') and (orden = 'A') then
      if (tabla.FieldByName('Nombre').AsString >= iniciar) and (tabla.FieldByName('Nombre').AsString <= finalizar) then ListLineaNBU(salida);
    if (ent_excl = 'X') and (orden = 'A') then
      if (tabla.FieldByName('Nombre').AsString < iniciar) or (tabla.FieldByName('Nombre').AsString > finalizar) then ListLineaNBU(salida);

    tabla.Next;
  end;

  tabla.IndexFieldNames := 'codos';

  List.FinList;
end;

procedure TTObraSocial.PaginaInicialHTML;
// Objetivo...: Exportar determinaciones con monto fijo como xml
Begin
  list.ExportarInforme(dbs.DirSistema + '\actualizaciones_online\upload\intro.htm');
  list.LineaTxt('<html><head>', True);
  list.LineaTxt('<meta http-equiv=' + '"' + 'Content-Type' + '"' + ' content=' + '"' + 'text/html; charset=windows-1252' + '"'+ '>', True);
  list.LineaTxt('<meta name=' + '"' + 'GENERATOR' + '"' + ' content=' + '"' + 'Microsoft FrontPage 4.0' + '"' + '>', True);
  list.LineaTxt('<meta name=' + '"' + 'ProgId' + '"' + 'content=' + '"' + 'FrontPage.Editor.Document' + '"' + '>', True);
  list.LineaTxt('<title>CBLNSF</title><base target=' + '"' + 'principal' + '"' + '>', True);
  list.LineaTxt('</head><body>', True);
  list.LineaTxt('<font size=' + '"' + '5' + '"' + '>', True);

  list.LineaTxt('Centro de Bioqu�micos Litoral Norte de Santa Fe</font><br>', True);
  list.LineaTxt('<font size=' + '"' + '1' + '"' + '>Actualizada el ' + utiles.setFechaActual + '    ' + utiles.setHoraActual24 + '</font><br>', True);
  list.LineaTxt('<a href=' + '"' + 'obsocial.htm' + '"' + ' target=' + '"' + 'principal' + '"' + '>Obras Sociales</a>&nbsp;&nbsp;&nbsp;', True);
  list.LineaTxt('<a href=' + '" ' + 'aranceles_os.htm' + '"' + ' target=' + '"' + 'principal' + '"' + '>Aranceles Obras Sociales</a>&nbsp;&nbsp;&nbsp', True);
  list.LineaTxt('<a href=' + '" ' + 'nomeclador.htm' + '" ' + 'target=' + '"' + 'principal' + '"' + '>Nomeclador</a>&nbsp;&nbsp;&nbsp;', True);
  list.LineaTxt('<a href=' + '"' + 'apfijos.htm' + '" ' + 'target=' + '"' + 'principal' + '"' + '>Montos Fijos</a>&nbsp;&nbsp;&nbsp;', True);
  list.LineaTxt('<a href=' + '"' + 'ftp://ftp.trcnet.com.ar' + '"' + ' target=' + '"' + '_blank' + '"' + '>FTP</a>', True);

  list.LineaTxt('</body></html>', True);
  list.FinalizarExportacion;

  // Copiamos las Estructuras
  utilesarchivos.CopiarArchivos(dbs.DirSistema + '\work\actonline', '*.*', dbs.DirSistema + '\actualizaciones_online\upload\estructu');
end;

procedure TTObraSocial.ExportarAnalisisMontoFijoXML;
// Objetivo...: Exportar determinaciones con monto fijo como xml
Begin
  texport := datosdb.openDB('apfijos', '', '', dbs.DirSistema + '\actualizaciones_online\upload\estructu');
  texport.Open;
  list.ExportarInforme(dbs.DirSistema + '\actualizaciones_online\upload\apfijos.xml');
  list.LineaTxt('<?xml version="1.0"?>', True);
  list.LineaTxt('', True);
  list.LineaTxt('<determinacionesMontoFijo>', True);
  apfijos.First;
  while not apfijos.Eof do Begin
    obsocial.getDatos(apfijos.FieldByName('codos').AsString);
    list.LineaTxt('  <determinacion>', True);
    list.LineaTxt('  <codos>' + apfijos.FieldByName('codos').AsString + '</codos>', True);
    list.LineaTxt('  <items>' + apfijos.FieldByName('items').AsString + '</items>', True);
    if Length(Trim(obsocial.nombre)) > 0 then list.LineaTxt('  <obsocial>' + TrimLeft(obsocial.nombre) + '</obsocial>', True) else list.LineaTxt('  <obsocial>null</obsocial>', True);
    list.LineaTxt('  <codanalisis>' + apfijos.FieldByName('codanalisis').AsString + '</codanalisis>', True);
    list.LineaTxt('  <monto>' + utiles.FormatearNumero(apfijos.FieldByName('importe').AsString) + '</monto>', True);
    if Length(Trim(apfijos.FieldByName('periodo').AsString)) > 0 then list.LineaTxt('  <periodo>' + apfijos.FieldByName('periodo').AsString + '</periodo>', True) else list.LineaTxt('  <periodo>null</periodo>', True);
    list.LineaTxt('  </determinacion>', True);

    if datosdb.Buscar(texport, 'codos', 'items', 'codanalisis', apfijos.FieldByName('codos').AsString, apfijos.FieldByName('items').AsString, apfijos.FieldByName('codanalisis').AsString) then texport.Edit else texport.Append;
    texport.FieldByName('codos').AsString       := apfijos.FieldByName('codos').AsString;
    texport.FieldByName('items').AsString       := apfijos.FieldByName('items').AsString;
    texport.FieldByName('codanalisis').AsString := apfijos.FieldByName('codanalisis').AsString;
    texport.FieldByName('importe').AsFloat      := apfijos.FieldByName('importe').AsFloat;
    texport.FieldByName('periodo').AsString     := apfijos.FieldByName('periodo').AsString;
    texport.FieldByName('perhasta').AsString    := apfijos.FieldByName('perhasta').AsString;
    try
      texport.Post
     except
      texport.Cancel
    end;

    apfijos.Next;
  end;
  list.LineaTxt('</determinacionesMontoFijo>', True);
  list.FinalizarExportacion;
  datosdb.closeDB(texport);
end;

procedure TTObraSocial.ExportarAnalisisMontoFijoNBU;
// Objetivo...: Exportar determinaciones con monto fijo NBU
Begin
  texport := datosdb.openDB('apfijosNBU', '', '', dbs.DirSistema + '\actualizaciones_online\upload\estructu');
  texport.Open;
  apfijosNBU.First;
  while not apfijosNBU.Eof do Begin
    if datosdb.Buscar(texport, 'codos', 'items', apfijosNBU.FieldByName('codos').AsString, apfijosNBU.FieldByName('items').AsString) then texport.Edit else texport.Append;
    texport.FieldByName('codos').AsString       := apfijosNBU.FieldByName('codos').AsString;
    texport.FieldByName('items').AsString       := apfijosNBU.FieldByName('items').AsString;
    texport.FieldByName('codanalisis').AsString := apfijosNBU.FieldByName('codanalisis').AsString;
    texport.FieldByName('importe').AsFloat      := apfijosNBU.FieldByName('importe').AsFloat;
    texport.FieldByName('periodo').AsString     := apfijosNBU.FieldByName('periodo').AsString;
    texport.FieldByName('perhasta').AsString    := apfijosNBU.FieldByName('perhasta').AsString;
    try
      texport.Post
     except
      texport.Cancel
    end;

    apfijosNBU.Next;
  end;
  datosdb.closeDB(texport);
end;

procedure TTObraSocial.ExportarUnidadesNBU;
// Objetivo...: Exportar Unidades NBU
Begin
  texport := datosdb.openDB('aranNBU', '', '', dbs.DirSistema + '\actualizaciones_online\upload\estructu');
  texport.Open;
  aranNBU.First;
  while not aranNBU.Eof do Begin
    if datosdb.Buscar(texport, 'codos', 'items', aranNBU.FieldByName('codos').AsString, aranNBU.FieldByName('items').AsString) then texport.Edit else texport.Append;
    texport.FieldByName('codos').AsString    := aranNBU.FieldByName('codos').AsString;
    texport.FieldByName('items').AsString    := aranNBU.FieldByName('items').AsString;
    texport.FieldByName('codigo').AsString   := aranNBU.FieldByName('codigo').AsString;
    texport.FieldByName('unidad').AsFloat    := aranNBU.FieldByName('unidad').AsFloat;
    texport.FieldByName('perdesde').AsString := aranNBU.FieldByName('perdesde').AsString;
    texport.FieldByName('perhasta').AsString := aranNBU.FieldByName('perhasta').AsString;
    try
      texport.Post
     except
      texport.Cancel
    end;

    aranNBU.Next;
  end;
  datosdb.closeDB(texport);
end;

procedure TTObraSocial.ExportarObrasSocialesXML;
// Objetivo...: Exportar Obras Sociales
Begin
  texport := datosdb.openDB('obsocial', '', '', dbs.DirSistema + '\actualizaciones_online\upload\estructu');
  texport.Open;

  list.ExportarInforme(dbs.DirSistema + '\actualizaciones_online\upload\obsocial.xml');
  list.LineaTxt('<?xml version="1.0"?>', True);
  list.LineaTxt('', True);
  list.LineaTxt('<obrassociales>', True);
  tabla.IndexFieldNames := 'codos';
  tabla.First;
  while not tabla.Eof do Begin
    list.LineaTxt('  <obsocial>', True);
    list.LineaTxt('  <codos>' + tabla.FieldByName('codos').AsString + '</codos>', True);
    list.LineaTxt('  <nombre>' + TrimLeft(tabla.FieldByName('nombre').AsString) + '</nombre>', True);
    if Length(Trim(tabla.FieldByName('nombrec').AsString)) > 0 then list.LineaTxt('  <nombrec>' + TrimLeft(tabla.FieldByName('nombrec').AsString) + '</nombrec>', True) else list.LineaTxt('  <nombrec>null</nombrec>', True);
    if Length(Trim(tabla.FieldByName('direccion').AsString)) > 0 then list.LineaTxt('  <direccion>' + TrimLeft(tabla.FieldByName('direccion').AsString) + '</direccion>', True) else list.LineaTxt('  <direccion>null</direccion>', True);
    if Length(Trim(tabla.FieldByName('localidad').AsString)) > 0 then list.LineaTxt('  <localidad>' + TrimLeft(tabla.FieldByName('localidad').AsString) + '</localidad>', True) else list.LineaTxt('  <localidad>null</localidad>', True);
    if Length(Trim(tabla.FieldByName('codpos').AsString)) > 0 then list.LineaTxt('  <codpos>' + TrimLeft(tabla.FieldByName('codpos').AsString) + '</codpos>', True) else list.LineaTxt('  <codpos>null</codpos>', True);
    list.LineaTxt('  <ub>' + utiles.FormatearNumero(tabla.FieldByName('ub').AsString) + '</ub>', True);
    list.LineaTxt('  <ug>' + utiles.FormatearNumero(tabla.FieldByName('ug').AsString) + '</ug>', True);
    list.LineaTxt('  <rieub>' + utiles.FormatearNumero(tabla.FieldByName('rieub').AsString) + '</rieub>', True);
    list.LineaTxt('  <rieug>' + utiles.FormatearNumero(tabla.FieldByName('rieug').AsString) + '</rieug>', True);
    list.LineaTxt('  <porcentaje>' + utiles.FormatearNumero(tabla.FieldByName('porcentaje').AsString) + '</porcentaje>', True);
    if Length(Trim(tabla.FieldByName('codpfis').AsString)) > 0 then list.LineaTxt('  <codpfis>' + tabla.FieldByName('codpfis').AsString + '</codpfis>', True) else list.LineaTxt('  <codpfis>null</codpfis>', True);
    if Length(Trim(tabla.FieldByName('nrocuit').AsString)) = 13 then list.LineaTxt('  <nrocuit>' + TrimLeft(tabla.FieldByName('nrocuit').AsString) + '</nrocuit>', True) else list.LineaTxt('  <nrocuit>null</nrocuit>', True);
    if Length(Trim(tabla.FieldByName('categoria').AsString)) > 0 then list.LineaTxt('  <categoria>' + TrimLeft(tabla.FieldByName('categoria').AsString) + '</categoria>', True) else list.LineaTxt('  <categoria>null</categoria>', True);
    if Length(Trim(tabla.FieldByName('tope').AsString)) > 0 then list.LineaTxt('  <tope>' + tabla.FieldByName('tope').AsString + '</tope>', True) else list.LineaTxt('  <tope>null</tope>', True);
    list.LineaTxt('  <topemin>' + utiles.FormatearNumero(tabla.FieldByName('topemin').AsString) + '</topemin>', True);
    list.LineaTxt('  <topemax>' + utiles.FormatearNumero(tabla.FieldByName('topemax').AsString) + '</topemax>', True);
    if Length(Trim(tabla.FieldByName('capitada').AsString)) > 0 then list.LineaTxt('  <capitada>' + tabla.FieldByName('capitada').AsString + '</capitada>', True) else list.LineaTxt('  <capitada>null</capitada>', True);
    if Length(Trim(tabla.FieldByName('noimport').AsString)) > 0 then list.LineaTxt('  <noimport>' + tabla.FieldByName('noimport').AsString + '</noimport>', True) else list.LineaTxt('  <noimport>null</noimport>', True);
    list.LineaTxt('  <retencioniva>' + utiles.FormatearNumero(utiles.FormatearNumero(tabla.FieldByName('retencioniva').AsString)) + '</retencioniva>', True);
    list.LineaTxt('  <retieneiva>' + tabla.FieldByName('retieneiva').AsString + '</retieneiva>', True);
    list.LineaTxt('  <factnbu>' + tabla.FieldByName('factnbu').AsString + '</factnbu>', True);
    list.LineaTxt('  <pernbu>' + tabla.FieldByName('retieneiva').AsString + '</pernbu>', True);
    list.LineaTxt('  </obsocial>', True);

    if texport.FindKey([tabla.FieldByName('codos').AsString]) then texport.Edit else texport.Append;
    texport.FieldByName('codos').AsString          := tabla.FieldByName('codos').AsString;
    texport.FieldByName('nombre').AsString         := tabla.FieldByName('nombre').AsString;
    texport.FieldByName('nombrec').AsString        := tabla.FieldByName('nombrec').AsString;
    texport.FieldByName('direccion').AsString      := tabla.FieldByName('direccion').AsString;
    texport.FieldByName('localidad').AsString      := tabla.FieldByName('localidad').AsString;
    texport.FieldByName('codpos').AsString         := tabla.FieldByName('codpos').AsString;
    texport.FieldByName('ub').AsString             := tabla.FieldByName('ub').AsString;
    texport.FieldByName('ug').AsString             := tabla.FieldByName('ug').AsString;
    texport.FieldByName('rieub').AsString          := tabla.FieldByName('rieub').AsString;
    texport.FieldByName('rieug').AsString          := tabla.FieldByName('rieug').AsString;
    texport.FieldByName('porcentaje').AsString     := tabla.FieldByName('porcentaje').AsString;
    texport.FieldByName('codpfis').AsString        := tabla.FieldByName('codpfis').AsString;
    texport.FieldByName('nrocuit').AsString        := tabla.FieldByName('nrocuit').AsString;
    texport.FieldByName('categoria').AsString      := tabla.FieldByName('categoria').AsString;
    texport.FieldByName('tope').AsString           := tabla.FieldByName('tope').AsString;
    texport.FieldByName('topemin').AsString        := tabla.FieldByName('topemin').AsString;
    texport.FieldByName('topemax').AsString        := tabla.FieldByName('topemax').AsString;
    texport.FieldByName('capitada').AsString       := tabla.FieldByName('capitada').AsString;
    texport.FieldByName('noimport').AsString       := tabla.FieldByName('noimport').AsString;
    texport.FieldByName('retencioniva').AsString   := tabla.FieldByName('retencioniva').AsString;
    texport.FieldByName('retieneiva').AsString     := tabla.FieldByName('retieneiva').AsString;
    texport.FieldByName('factnbu').AsString        := tabla.FieldByName('factnbu').AsString;
    texport.FieldByName('pernbu').AsString         := tabla.FieldByName('pernbu').AsString;
    texport.FieldByName('baja').AsString           := tabla.FieldByName('baja').AsString;
    texport.FieldByName('exportfact').AsString     := tabla.FieldByName('exportfact').AsString;
    texport.FieldByName('ruptura_orden').AsInteger := tabla.FieldByName('ruptura_orden').AsInteger;
    try
      texport.Post
     except
      texport.Cancel
    end;

    tabla.Next;
  end;
  list.LineaTxt('</obrassociales>', True);
  list.FinalizarExportacion;
  datosdb.closeDB(texport);
end;

procedure TTObraSocial.ExportarArancelesXML;
// Objetivo...: Exportar Aranceles Obras Sociales
Begin
  texport := datosdb.openDB('obsociales_aranceles', '', '', dbs.DirSistema + '\actualizaciones_online\upload\estructu');
  texport.Open;

  list.ExportarInforme(dbs.DirSistema + '\actualizaciones_online\upload\aranceles_os.xml');
  list.LineaTxt('<?xml version="1.0"?>', True);
  list.LineaTxt('', True);
  list.LineaTxt('<arancelesos>', True);
  aranceles.First;
  while not aranceles.Eof do Begin
    list.LineaTxt('  <arancel>', True);
    obsocial.getDatos(aranceles.FieldByName('codos').AsString);
    list.LineaTxt('  <codos>' + aranceles.FieldByName('codos').AsString + '</codos>', True);
    if Length(Trim(obsocial.nombre)) > 0 then list.LineaTxt('  <obsocial>' + TrimLeft(obsocial.nombre) + '</obsocial>', True) else list.LineaTxt('  <obsocial>null</obsocial>', True);
    list.LineaTxt('  <periodo>' + aranceles.FieldByName('periodo').AsString + '</periodo>', True);
    list.LineaTxt('  <ub>' + utiles.FormatearNumero(aranceles.FieldByName('ub').AsString) + '</ub>', True);
    list.LineaTxt('  <ug>' + utiles.FormatearNumero(aranceles.FieldByName('ug').AsString) + '</ug>', True);
    list.LineaTxt('  <rieub>' + utiles.FormatearNumero(aranceles.FieldByName('rieub').AsString) + '</rieub>', True);
    list.LineaTxt('  <rieug>' + utiles.FormatearNumero(aranceles.FieldByName('rieug').AsString) + '</rieug>', True);
    list.LineaTxt('  <tope>' + aranceles.FieldByName('tope').AsString + '</tope>', True);
    list.LineaTxt('  </arancel>', True);

    if datosdb.Buscar(texport, 'codos', 'periodo', aranceles.FieldByName('codos').AsString, aranceles.FieldByName('periodo').AsString) then texport.Edit else texport.Append;
    texport.FieldByName('codos').AsString   := aranceles.FieldByName('codos').AsString;
    texport.FieldByName('periodo').AsString := aranceles.FieldByName('periodo').AsString;
    texport.FieldByName('ub').AsString      := aranceles.FieldByName('ub').AsString;
    texport.FieldByName('ug').AsString      := aranceles.FieldByName('ug').AsString;
    texport.FieldByName('rieub').AsString   := aranceles.FieldByName('rieub').AsString;
    texport.FieldByName('rieug').AsString   := aranceles.FieldByName('rieug').AsString;
    texport.FieldByName('tope').AsString    := aranceles.FieldByName('tope').AsString;
    try
      texport.Post
     except
      texport.Cancel
    end;

    aranceles.Next;
  end;
  list.LineaTxt('</arancelesos>', True);
  list.FinalizarExportacion;

  datosdb.closeDB(texport);
end;

procedure TTObraSocial.ExportarArancelesNBUXML;
// Objetivo...: Exportar Aranceles Obras Sociales NBU
Begin
  texport := datosdb.openDB('arancelesNBU', '', '', dbs.DirSistema + '\actualizaciones_online\upload\estructu');
  texport.Open;

  arancelesNBU.First;
  while not arancelesNBU.Eof do Begin
    if datosdb.Buscar(texport, 'codos', 'periodo', arancelesNBU.FieldByName('codos').AsString, arancelesNBU.FieldByName('periodo').AsString) then texport.Edit else texport.Append;
    texport.FieldByName('codos').AsString   := arancelesNBU.FieldByName('codos').AsString;
    texport.FieldByName('periodo').AsString := arancelesNBU.FieldByName('periodo').AsString;
    texport.FieldByName('valor').AsFloat    := arancelesNBU.FieldByName('valor').AsFloat;
    try
      texport.Post
     except
      texport.Cancel
    end;

    arancelesNBU.Next;
  end;

  datosdb.closeDB(texport);
end;

procedure TTObraSocial.ExportarPosicionFiscalXML;
// Objetivo...: Exportar Posiciones Fiscales
Begin
  texport := datosdb.openDB('obsocial_posiva', '', '', dbs.DirSistema + '\actualizaciones_online\upload\estructu');
  texport.Open;

  list.ExportarInforme(dbs.DirSistema + '\actualizaciones_online\upload\posicionFiscal.xml');
  list.LineaTxt('<?xml version="1.0"?>', True);
  list.LineaTxt('', True);
  list.LineaTxt('<posicionfiscal>', True);
  retiva.First;
  while not retiva.Eof do Begin
    list.LineaTxt('  <pfiscal>', True);
    list.LineaTxt('  <codos>' + retiva.FieldByName('codos').AsString + '</codos>', True);
    list.LineaTxt('  <periodo>' + retiva.FieldByName('periodo').AsString + '</periodo>', True);
    list.LineaTxt('  <retiva>' + utiles.FormatearNumero(retiva.FieldByName('retieneiva').AsString) + '</retiva>', True);
    list.LineaTxt('  </pfiscal>', True);

    if datosdb.Buscar(texport, 'codos', 'periodo', retiva.FieldByName('codos').AsString, retiva.FieldByName('periodo').AsString) then texport.Edit else texport.Append;
    texport.FieldByName('codos').AsString      := retiva.FieldByName('codos').AsString;
    texport.FieldByName('periodo').AsString    := retiva.FieldByName('periodo').AsString;
    texport.FieldByName('retieneiva').AsString := retiva.FieldByName('retieneiva').AsString;
    try
      texport.Post
     except
      texport.Cancel
    end;

    retiva.Next;
  end;
  list.LineaTxt('</posicionfiscal>', True);
  list.FinalizarExportacion;

  datosdb.closeDB(texport); 
end;

procedure TTObraSocial.ImportarAnalisisMontoFijoXML(xlista: TStringList);
// Objetivo...: Actualizar Datos a partir de una Fuente XML
{var
  i, k: Integer;
  valores: array[1..5] of String;}
Begin
  {domxml.Analizar(dbs.DirSistema + '\actualizaciones_online\download\apfijos.xml');
  lista1 := domxml.setDOMXMLDatos;
  if lista1 <> Nil then Begin
    k := 0;
    For i := 1 to lista1.Count do Begin
      Inc(k);
      if k = 1 then valores[1] := lista1.Strings[i-1];  // codos
      if k = 2 then valores[2] := lista1.Strings[i-1];  // items
      if k = 4 then valores[3] := lista1.Strings[i-1];  // codanalisis
      if k = 5 then valores[4] := lista1.Strings[i-1];  // monto
      if k = 6 then valores[5] := lista1.Strings[i-1];  // periodo
      if k = 6 then Begin                               // Lote completo, actualizamos
        if BuscarItemsMontoFijo(valores[1], valores[2]) then apfijos.Edit else apfijos.Append;
        apfijos.FieldByName('codos').AsString       := valores[1];
        apfijos.FieldByName('items').AsString       := valores[2];
        apfijos.FieldByName('codanalisis').AsString := valores[3];
        apfijos.FieldByName('importe').AsString     := utiles.FormatearNumero(valores[4]);
        if valores[5] <> 'null' then apfijos.FieldByName('periodo').AsString := valores[5] else apfijos.FieldByName('periodo').AsString := '';
        try
          apfijos.Post
         except
          apfijos.Cancel
        end;
        k := 0;
      end;
    end;
  end;
  datosdb.closedb(apfijos); apfijos.Open;
  lista1.Destroy;}

  texport := datosdb.openDB('apfijos', '', '', dbs.DirSistema + '\actualizaciones_online\download\estructu');
  texport.Open;

  while not texport.Eof do Begin
    if Length(Trim(texport.FieldByName('codos').AsString)) = 6 then Begin
    if utiles.verificarItemsLista(xlista, texport.FieldByName('codos').AsString) then Begin
      if BuscarItemsMontoFijo(texport.FieldByName('codos').AsString, texport.FieldByName('items').AsString) then apfijos.Edit else apfijos.Append;
        apfijos.FieldByName('codos').AsString       := texport.FieldByName('codos').AsString;
        apfijos.FieldByName('items').AsString       := texport.FieldByName('items').AsString;
        apfijos.FieldByName('codanalisis').AsString := texport.FieldByName('codanalisis').AsString;
        apfijos.FieldByName('importe').AsString     := texport.FieldByName('importe').AsString;
        apfijos.FieldByName('periodo').AsString     := texport.FieldByName('periodo').AsString;
        apfijos.FieldByName('perhasta').AsString    := texport.FieldByName('perhasta').AsString;
        try
          apfijos.Post
         except
          apfijos.Cancel
        end;
      end;
    end;
    texport.Next;
  end;

  datosdb.closedb(texport);

  CargarListaApFijos;
end;

procedure TTObraSocial.ImportarAnalisisMontoFijoNBU(xlista: TStringList);
// Objetivo...: Actualizar Datos a partir de una Fuente XML
Begin
  texport := datosdb.openDB('apfijosNBU', '', '', dbs.DirSistema + '\actualizaciones_online\download\estructu');
  texport.Open;

  while not texport.Eof do Begin
    if Length(Trim(texport.FieldByName('codos').AsString)) = 6 then Begin
      if utiles.verificarItemsLista(xlista, texport.FieldByName('codos').AsString) then Begin
        if BuscarItemsMontoFijoNBU(texport.FieldByName('codos').AsString, texport.FieldByName('items').AsString) then apfijosNBU.Edit else apfijosNBU.Append;
        apfijosNBU.FieldByName('codos').AsString       := texport.FieldByName('codos').AsString;
        apfijosNBU.FieldByName('items').AsString       := texport.FieldByName('items').AsString;
        apfijosNBU.FieldByName('codanalisis').AsString := texport.FieldByName('codanalisis').AsString;
        apfijosNBU.FieldByName('importe').AsString     := texport.FieldByName('importe').AsString;
        apfijosNBU.FieldByName('periodo').AsString     := texport.FieldByName('periodo').AsString;
        apfijosNBU.FieldByName('perhasta').AsString    := texport.FieldByName('perhasta').AsString;
        try
          apfijosNBU.Post
         except
          apfijosNBU.Cancel
        end;
      end;
    end;
    texport.Next;
  end;

  datosdb.closedb(texport);

  CargarListaApFijosNBU;
end;

procedure TTObraSocial.ImportarUnidadesNBU(xlista: TStringList);
// Objetivo...: Importar Aranceles NBU
Begin
  texport := datosdb.openDB('aranNBU', '', '', dbs.DirSistema + '\actualizaciones_online\download\estructu');
  texport.Open;

  while not texport.Eof do Begin
    if utiles.verificarItemsLista(xlista, texport.FieldByName('codos').AsString) then Begin
      if BuscarUnidadNBU(texport.FieldByName('codos').AsString, texport.FieldByName('items').AsString) then aranNBU.Edit else aranNBU.Append;
      aranNBU.FieldByName('codos').AsString    := texport.FieldByName('codos').AsString;
      aranNBU.FieldByName('items').AsString    := texport.FieldByName('items').AsString;
      aranNBU.FieldByName('codigo').AsString   := texport.FieldByName('codigo').AsString;
      aranNBU.FieldByName('unidad').AsString   := texport.FieldByName('unidad').AsString;
      aranNBU.FieldByName('perdesde').AsString := texport.FieldByName('perdesde').AsString;
      aranNBU.FieldByName('perhasta').AsString := texport.FieldByName('perhasta').AsString;
      try
        aranNBU.Post
       except
        aranNBU.Cancel
      end;
    end;
    texport.Next;
  end;

  datosdb.closedb(texport);

  CargarListaUnidadesNBU;
end;

procedure TTObraSocial.ExportarOSXML;
var
  archivo: TextFile;
Begin
  AssignFile(archivo, dbs.DirSistema + '\actualizaciones_online\upload\obrassociales.xml');
  Rewrite(archivo);

  WriteLn(archivo, '<obsocial>');
  tabla.First;
  while not tabla.Eof do Begin
    WriteLn(archivo, '<registro>');
    WriteLn(archivo, '<codos>' + tabla.FieldByName('codos').AsString + '</codos>');
    WriteLn(archivo, '<nombre>' + tabla.FieldByName('nombre').AsString + '</nombre>');
    WriteLn(archivo, '<capitada>' + tabla.FieldByName('capitada').AsString + '</capitada>');
    WriteLn(archivo, '</registro>');
    tabla.Next;
  end;
  WriteLn(archivo, '</obsocial>');
  closeFile(archivo);
end;

procedure TTObraSocial.ImportarObrasSocialesXML(xlista: TStringList);
Begin
  texport := datosdb.openDB('obsocial', '', '', dbs.DirSistema + '\actualizaciones_online\download\estructu');
  texport.Open;
  while not texport.Eof do Begin
    if utiles.verificarItemsLista(xlista, texport.FieldByName('codos').AsString) then Begin
      if Buscar(texport.FieldByName('codos').AsString) then tabla.Edit else tabla.Append;
      tabla.FieldByName('codos').AsString        := texport.FieldByName('codos').AsString;
      tabla.FieldByName('nombre').AsString       := texport.FieldByName('nombre').AsString;
      tabla.FieldByName('nombrec').AsString      := texport.FieldByName('nombrec').AsString;
      tabla.FieldByName('direccion').AsString    := texport.FieldByName('direccion').AsString;
      tabla.FieldByName('localidad').AsString    := texport.FieldByName('localidad').AsString;
      tabla.FieldByName('codpos').AsString       := texport.FieldByName('codpos').AsString;
      tabla.FieldByName('ub').AsString           := texport.FieldByName('ub').AsString;
      tabla.FieldByName('ug').AsString           := texport.FieldByName('ug').AsString;
      tabla.FieldByName('rieub').AsString        := texport.FieldByName('rieub').AsString;
      tabla.FieldByName('rieug').AsString        := texport.FieldByName('rieug').AsString;
      tabla.FieldByName('porcentaje').AsString   := texport.FieldByName('porcentaje').AsString;
      tabla.FieldByName('codpfis').AsString      := texport.FieldByName('codpfis').AsString;
      tabla.FieldByName('nrocuit').AsString      := texport.FieldByName('nrocuit').AsString;
      tabla.FieldByName('categoria').AsString    := texport.FieldByName('categoria').AsString;
      tabla.FieldByName('tope').AsString         := texport.FieldByName('tope').AsString;
      tabla.FieldByName('topemin').AsString      := texport.FieldByName('topemin').AsString;
      tabla.FieldByName('topemax').AsString      := texport.FieldByName('topemax').AsString;
      tabla.FieldByName('capitada').AsString     := texport.FieldByName('capitada').AsString;
      tabla.FieldByName('noimport').AsString     := texport.FieldByName('noimport').AsString;
      tabla.FieldByName('retencioniva').AsString := texport.FieldByName('retencioniva').AsString;
      tabla.FieldByName('retieneiva').AsString   := texport.FieldByName('retieneiva').AsString;
      tabla.FieldByName('factnbu').AsString      := texport.FieldByName('factnbu').AsString;
      tabla.FieldByName('pernbu').AsString       := texport.FieldByName('pernbu').AsString;
      if datosdb.verificarSiExisteCampo(texport, 'baja') then
        tabla.FieldByName('baja').AsString         := texport.FieldByName('baja').AsString;
      if datosdb.verificarSiExisteCampo(texport, 'ruptura_orden') then
        tabla.FieldByName('ruptura_orden').AsInteger := texport.FieldByName('ruptura_orden').AsInteger;
      if datosdb.verificarSiExisteCampo(texport, 'exportfact') then
        tabla.FieldByName('exportfact').AsString := texport.FieldByName('exportfact').AsString;

      try
        tabla.Post
       except
        tabla.Cancel
      end;
    end;
    texport.Next;
  end;

  datosdb.closedb(texport);
  datosdb.closedb(tabla); tabla.Open;
  Enccol;
end;

procedure TTObraSocial.ImportarArancelesXML(xlista: TStringList);
// Objetivo...: Actualizar Datos a partir de una Fuente XML
Begin
  texport := datosdb.openDB('obsociales_aranceles', '', '', dbs.DirSistema + '\actualizaciones_online\download\estructu');
  texport.Open;

  while not texport.Eof do Begin
    if utiles.verificarItemsLista(xlista, texport.FieldByName('codos').AsString) then Begin
      if BuscarArancel(texport.FieldByName('codos').AsString, texport.FieldByName('periodo').AsString) then aranceles.Edit else aranceles.Append;
      aranceles.FieldByName('codos').AsString   := texport.FieldByName('codos').AsString;
      aranceles.FieldByName('periodo').AsString := texport.FieldByName('periodo').AsString;
      aranceles.FieldByName('ub').AsString      := texport.FieldByName('ub').AsString;
      aranceles.FieldByName('ug').AsString      := texport.FieldByName('ug').AsString;
      aranceles.FieldByName('rieub').AsString   := texport.FieldByName('rieub').AsString;
      aranceles.FieldByName('rieug').AsString   := texport.FieldByName('rieug').AsString;
      aranceles.FieldByName('tope').AsString    := texport.FieldByName('tope').AsString;
      try
        aranceles.Post
       except
        aranceles.Cancel
      end;
    end;
    texport.Next;
  end;

  datosdb.closedb(texport);
  datosdb.closedb(aranceles); aranceles.Open;
end;

procedure TTObraSocial.ImportarArancelesNBUXML(xlista: TStringList);
// Objetivo...: Actualizar Datos a partir de una Fuente XML
Begin
  texport := datosdb.openDB('arancelesNBU', '', '', dbs.DirSistema + '\actualizaciones_online\download\estructu');
  texport.Open;

  while not texport.Eof do Begin
    if utiles.verificarItemsLista(xlista, texport.FieldByName('codos').AsString) then Begin
      if BuscarArancelNBU(texport.FieldByName('codos').AsString, texport.FieldByName('periodo').AsString) then arancelesNBU.Edit else arancelesNBU.Append;
      arancelesNBU.FieldByName('codos').AsString   := texport.FieldByName('codos').AsString;
      arancelesNBU.FieldByName('periodo').AsString := texport.FieldByName('periodo').AsString;
      arancelesNBU.FieldByName('valor').AsFloat    := texport.FieldByName('valor').AsFloat;
      try
        arancelesNBU.Post
       except
        arancelesNBU.Cancel
      end;
    end;
    texport.Next;
  end;

  datosdb.closedb(texport);
  datosdb.closedb(arancelesNBU); arancelesNBU.Open;
end;

procedure TTObraSocial.ImportarPosicionFiscalXML(xlista: TStringList);
// Objetivo...: Actualizar Datos a partir de una Fuente XML
Begin
  texport := datosdb.openDB('obsocial_posiva', '', '', dbs.DirSistema + '\actualizaciones_online\download\estructu');
  texport.Open;

  while not texport.Eof do Begin
    if utiles.verificarItemsLista(xlista, texport.FieldByName('codos').AsString) then Begin
      if datosdb.Buscar(retiva, 'codos', 'periodo', texport.FieldByName('codos').AsString, texport.FieldByName('periodo').AsString) then retiva.Edit else retiva.Append;
      retiva.FieldByName('codos').AsString      := texport.FieldByName('codos').AsString;
      retiva.FieldByName('periodo').AsString    := texport.FieldByName('periodo').AsString;
      retiva.FieldByName('retieneiva').AsFloat := texport.FieldByName('retieneiva').AsFloat;
      try
        retiva.Post
       except
        retiva.Cancel
      end;
    end;
    texport.Next;
  end;

  datosdb.closedb(texport);
  datosdb.closedb(retiva); retiva.Open;
end;

procedure TTObraSocial.DescompactarArchivosActualizaciones;
// Objetivo...: Descompactar Archivos
Begin
  utilesarchivos.DescompactarArchivos(dbs.DirSistema + '\actualizaciones_online\download', dbs.DirSistema + '\actualizaciones_online\download\estructu');
end;

function TTObraSocial.setObrasSocialesImportadas: TQuery;
// Objetivo...: Retornar una Lista de Obras Sociales Importadas
Begin
  Result := datosdb.tranSQL(dbs.DirSistema + '\actualizaciones_online\download\estructu', 'select codos, nombre from obsocial order by nombre');
end;

procedure TTObraSocial.FiltrarObrasSocialesActivas;
begin
  datosdb.Filtrar(tabla, 'baja = null or baja = ' + '''' + '''');
end;

function  TTObraSocial.setObrasSocialesSoporteDigital: TQuery;
begin
  result := datosdb.tranSQL(tabla.DatabaseName, 'select * from obsocial_reglas');
end;

function  TTObraSocial.getRegla(xcodos: string): integer;
var
  i: integer;
begin
  i := 1;
  if not obsocial_reglas.Active then obsocial_reglas.Open;
  if (datosdb.Buscar(obsocial_reglas, 'codos', xcodos)) then begin
    i := obsocial_reglas.FieldByName('regla').AsInteger;
    convenio := obsocial_reglas.FieldByName('convenio').AsString;
  end;
  result := i;
end;

function  TTObraSocial.getReglas: TQuery;
begin
  result := datosdb.tranSQL(obsocial_reglas.DatabaseName, 'select obsocial_reglas.* from obsocial_reglas, obsocial where novisible = 0 and obsocial_reglas.codos = obsocial.codos order by obsocial.nombre');
end;

function TTObraSocial.getReglas(regla: string): TQuery;
begin
  result := datosdb.tranSQL(obsocial_reglas.DatabaseName, 'select * from obsocial_reglas where regla = ' + regla + ' and novisible = 0 order by codos');
end;

function  TTObraSocial.getReglasCoseguros: TQuery;
begin
  result := datosdb.tranSQL(obsocial_reglas.DatabaseName, 'select * from obsocial_reglas where novisible = 0 and coseguro = "S" order by codos');
end;

{ ----------------------------------------------------------------------------- }

procedure TTObraSocial.Enccol;
// Objetivo...: Encabezado de columnas
begin
  tabla.FieldByName('codos').DisplayLabel := 'C�d.'; tabla.FieldByName('categoria').Index := 2; tabla.FieldByName('nombre').DisplayLabel := 'Nombre'; tabla.FieldByName('categoria').DisplayLabel := 'Cat.'; tabla.FieldByName('capitada').DisplayLabel := 'Capitada';
  tabla.FieldByName('codpfis').DisplayLabel := 'C.Fisc.'; tabla.FieldByName('nrocuit').DisplayLabel := 'N� C.U.I.T.'; tabla.FieldByName('categoria').DisplayLabel := 'Cat.'; tabla.FieldByName('Topemin').DisplayLabel := 'Tope Min.'; tabla.FieldByName('topemax').DisplayLabel := 'Tope Max.';
  tabla.FieldByName('nombrec').DisplayLabel := 'Nombre Completo'; tabla.FieldByName('direccion').DisplayLabel := 'Direcci�n'; tabla.FieldByName('localidad').DisplayLabel := 'Localidad'; tabla.FieldByName('codpos').DisplayLabel := 'CP'; tabla.FieldByName('RIEUB').DisplayLabel := 'RIE UB'; tabla.FieldByName('RIEUG').DisplayLabel := 'RIE UG';
  tabla.FieldByName('porcentaje').DisplayLabel := 'Porcentaje'; tabla.FieldByName('tope').Visible := False;
  tabla.FieldByName('noimport').DisplayLabel := 'Imp?'; tabla.FieldByName('retencioniva').DisplayLabel := 'IVA %'; tabla.FieldByName('retieneiva').DisplayLabel := 'R.IVA';
  tabla.FieldByName('factnbu').DisplayLabel := 'Fact. NBU?'; tabla.FieldByName('pernbu').DisplayLabel := 'Per. NBU';
end;

procedure TTObraSocial.conectar;
// Objetivo...: conectar tablas de persistencia
begin
  nomeclatura.conectar;
  nbu.conectar;
  if conexiones = 0 then Begin
    if not tabla.Active then tabla.Open;
    Enccol;
    if not apfijos.Active then apfijos.Open;
    if not aranceles.Active then aranceles.Open;
    if not retiva.Active then retiva.Open;
    if not arancelesNBU.Active then arancelesNBU.Open;
    if not apfijosNBU.Active then apfijosNBU.Open;
    if not aranNBU.Active then aranNBU.Open;
    if not obsocial_reglas.Active then obsocial_reglas.Open;
    CargarLista;
    CargarListaApFijos;
    CargarListaNBU;
    CargarListaApFijosNBU;
    CargarListaUnidadesNBU;
  end;
  Inc(conexiones);
end;

procedure TTObraSocial.desconectar;
// Objetivo...: desconectar tablas de persistencia
begin
  if conexiones > 0 then Dec(conexiones);
  if conexiones = 0 then Begin
    datosdb.closeDB(tabla);
    datosdb.closeDB(apfijos);
    datosdb.closeDB(aranceles);
    datosdb.closeDB(retiva);
    datosdb.closeDB(arancelesNBU);
    datosdb.closeDB(apfijosNBU);
    datosdb.closeDB(aranNBU);
    datosdb.closeDB(obsocial_reglas);
  end;
  nomeclatura.desconectar;
  nbu.desconectar;
end;

{===============================================================================}

function obsocial: TTObraSocial;
begin
  if xobsocial = nil then
    xobsocial := TTObraSocial.Create;
  Result := xobsocial;
end;

{===============================================================================}

initialization

finalization
  xobsocial.Free;

end.
