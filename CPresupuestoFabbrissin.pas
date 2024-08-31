unit CPresupuestoFabbrissin;

interface

uses CPaciente, CProfesional, CNomecla, CPlantanalisis, CObrasSociales, CTitulos, CNBU,
     CBDT, SysUtils, DBTables, CUtiles, CListar, CIDBFM, CSolAnalisis, CCBloqueosLaboratorios;

const
  meses: array[1..12] of string = ('Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Setiembre', 'Octubre', 'Noviembre', 'Diciembre');

type

TTpresupuestoAnalisis = class(TObject)
  nropres, fecha, hora, codpac, codprof, codos, resultanalisis, nroanalisis, entorden, obspresupuesto, obsitems, identidad: string;
  importe: real;
  exipresupuesto: boolean;
  presupuesto, detpres, ultnro: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  function    ultimapresupuesto: string;

  function    Buscar(xnropres: string): boolean; overload;
  procedure   Grabar(xnropres, xfecha, xhora, xcodpac, xcodprof, xcodos, xitems, xcodanalisis, xcodosan, xidentidad, xdescrip: string; xosrie, xosug, xnorie, xnoug, ximporte, xcftoma: real; xcantitems: Integer); overload;
  procedure   Grabar(xnropres, xobservacion: String); overload;
  procedure   Borrar(xnropres: string); overload;
  procedure   Borrar(xnropres, xcodanalisis: string); overload;
  procedure   getDatos(xnropres: string);
  function    NuevoPresupuesto: string;
  function    setImportePacientePor_ObraSocial(xcodpac, xcodob, xdfecha, xhfecha: string): real;
  function    setAnalisis: TQuery;
  procedure   ListarPresupuesto(xdfecha, xhfecha, xcodos, xprotocoloini, xprotocolofin: string; salida: char);
  procedure   PresentarInforme;

  procedure   Depurar(xfecha: string);
  function    verificarPaciente(xcodpac: string): boolean;
  function    verificarProfesional(xcodprof: string): boolean;
  function    verificarEntidadDerivacion(xidentidad: string): boolean;
  procedure   RegistrarUltimapresupuesto(xnropres: string);

  { Presupuesto Rápido }
  procedure   RegistrarItemsPresupuestoRapido(xitems, xcodanalisis, xdescrip, xprecio, xpreciototal, xcftoma, xtotal, xiva: String; xcantidaditems: Integer); overload;
  procedure   RegistrarItemsPresupuestoRapido(xitems, xcantidad, xcodanalisis, xdescrip, xprecio, xpreciototal, xcftoma, xtotal, xiva: String; xcantidaditems: Integer); overload;
  procedure   ImprimirPresupuestoRapido(salida: char);

  function    Bloquear: Boolean;
  procedure   QuitarBloqueo;

  procedure   conectar;
  procedure   desconectar;
 protected
  { Declaraciones Privadas }
  procedure   TituloSol(salida: char); virtual;
  procedure   ListSol(xcodpac, xidprof: string; salida: char); virtual;
 private
  { Declaraciones Privadas }
  r: TQuery; controlSQL, s_inicio: boolean;
  archivo: array[1..90, 1..6] of String;
  totales: array[1..5] of String;
  conexiones, totitems: integer;
  procedure   BorrarItems(xnropres: string);
  procedure   Grabar(xnropres, xfecha, xhora, xcodpac, xcodprof, xcodos: string); overload;
  procedure   Refrescar;
end;

function presupuesto: TTpresupuestoAnalisis;

implementation

var
  xsolanalisis: TTpresupuestoAnalisis = nil;

constructor TTpresupuestoAnalisis.Create;
begin
  if dbs.BaseClientServ = 'N' then Begin
    presupuesto := datosdb.openDB('presupuesto', 'Nropres');
    detpres     := datosdb.openDB('detpres', 'Nropres;Items');
    ultnro      := datosdb.openDB('ultnro', 'Nrosolicitud');
  end;
  if dbs.BaseClientServ = 'S' then Begin
    presupuesto := datosdb.openDB('presupuesto', 'Nropres', '', dbs.baseDat_N);
    detpres     := datosdb.openDB('detpres', 'Nropres;Items', '', dbs.baseDat_N);
    ultnro      := datosdb.openDB('ultnro', 'Nrosolicitud', '', dbs.baseDat_N);
  end;
end;

destructor TTpresupuestoAnalisis.Destroy;
begin
  inherited Destroy;
end;

function TTpresupuestoAnalisis.ultimapresupuesto: string;
begin
  Result := ultnro.FieldByName('nropres').AsString;
end;

function  TTpresupuestoAnalisis.Buscar(xnropres: string): boolean;
// Objetivo...: Buscar una instancia
begin
  exipresupuesto := presupuesto.FindKey([xnropres]);
  Result         := exipresupuesto;
end;

procedure TTpresupuestoAnalisis.Grabar(xnropres, xfecha, xhora, xcodpac, xcodprof, xcodos, xitems, xcodanalisis, xcodosan, xidentidad, xdescrip: string; xosrie, xosug, xnorie, xnoug, ximporte, xcftoma: real; xcantitems: Integer);
// Objetivo...: Almacenar una instacia de la clase - Atributos de una presupuesto de análisis
var
  codrecep: string;
begin
  if xitems = '01' then Grabar(xnropres, xfecha, xhora, xcodpac, xcodprof, xcodos);   // Soliticitud
  if datosdb.Buscar(detpres, 'nropres', 'items', xnropres, xitems) then detpres.Edit else detpres.Append;
  detpres.FieldByName('nropres').AsString := xnropres;
  detpres.FieldByName('items').AsString        := xitems;
  detpres.FieldByName('codanalisis').AsString  := xcodanalisis;
  detpres.FieldByName('codos').AsString        := xcodosan;
  detpres.FieldByName('identidad').AsString    := xidentidad;
  if xcodanalisis = '9999' then detpres.FieldByName('descrip').AsString      := xdescrip;
  detpres.FieldByName('osub').AsFloat          := xosrie;
  detpres.FieldByName('osug').AsFloat          := xosug;
  detpres.FieldByName('noub').AsFloat          := xnorie;
  detpres.FieldByName('noug').AsFloat          := xnoug;
  detpres.FieldByName('importe').AsFloat       := ximporte;
  detpres.FieldByName('cftoma').AsFloat        := xcftoma;
  // Obtenemos los datos del codigo del nomeclador de toma y recepción
  if (Length(trim(xcodanalisis)) = 4) then begin
    nomeclatura.getDatos(xcodanalisis);
    codrecep := nomeclatura.cftoma;
    nomeclatura.getDatos(codrecep);
    detpres.FieldByName('cfub').AsFloat := nomeclatura.ub;
    detpres.FieldByName('cfug').AsFloat := nomeclatura.gastos;
  end else begin
    detpres.FieldByName('cfub').AsFloat := 0;
    detpres.FieldByName('cfug').AsFloat := 0;
  end;
  try
    detpres.Post
   except
    detpres.Cancel
  end;
  datosdb.refrescar(detpres);
  if xitems = utiles.sLlenarIzquierda(IntToStr(xcantitems), 2, '0') then Begin
    datosdb.tranSQL(detpres.DatabaseName, 'delete from detpres where nropres = ' + '"' + xnropres + '"' + ' and items > ' + '"' + utiles.sLlenarIzquierda(IntToStr(xcantitems), 2, '0') + '"');
    refrescar;
  end;  
end;

procedure TTpresupuestoAnalisis.Grabar(xnropres, xfecha, xhora, xcodpac, xcodprof, xcodos: string);
// Objetivo...: Almacenar una instacia de la clase - Pedido de presupuesto de análisis
begin
  if Buscar(xnropres) then presupuesto.Edit else presupuesto.Append;
  presupuesto.FieldByName('nropres').AsString      := xnropres;
  presupuesto.FieldByName('fecha').AsString        := utiles.sExprFecha2000(xfecha);
  presupuesto.FieldByName('hora').AsString         := xhora;
  presupuesto.FieldByName('codpac').AsString       := xcodpac;
  presupuesto.FieldByName('codprof').AsString      := xcodprof;
  presupuesto.FieldByName('codos').AsString        := xcodos;
  try
    presupuesto.Post
  except
    presupuesto.Cancel
  end;
  if not exipresupuesto then  // Si la presupuesto es Nueva actualizamos el ultimo nro de protocolo para la correlatividad
    if utiles.sLlenarIzquierda(NuevoPresupuesto, 5, '0') <= utiles.sLlenarIzquierda(xnropres, 5, '0') then RegistrarUltimapresupuesto(xnropres);
  datosdb.refrescar(presupuesto);
end;

procedure TTpresupuestoAnalisis.Grabar(xnropres, xobservacion: String);
// Objetivo...: Grabar las observaciones del presupuesto
begin
  if Buscar(xnropres) then Begin
    presupuesto.Edit;
    presupuesto.FieldByName('observaciones').AsString := xobservacion;
    try
      presupuesto.Post
     except
      presupuesto.Cancel
    end;
    datosdb.refrescar(presupuesto); 
  end;
end;

procedure TTpresupuestoAnalisis.RegistrarUltimapresupuesto(xnropres: string);
// Objetivo...: Almacenar el último de la ultima presupuesto válida
begin
  if ultnro.Active then Begin
    ultnro.Close;
    ultnro.Open;
  end;
  if ultnro.RecordCount = 0 then ultnro.Append else ultnro.Edit;  // Guardamos el último nro. de presupuesto
  ultnro.FieldByName('nropres').AsString := xnropres;
  try
    ultnro.Post
  except
    ultnro.Cancel
  end;
  datosdb.refrescar(ultnro);
end;

procedure TTpresupuestoAnalisis.Borrar(xnropres: string);
// Objetivo...: Eliminar una instancia
begin
  if Buscar(xnropres) then Begin
    presupuesto.Delete;
    BorrarItems(xnropres);
    getDatos(presupuesto.FieldByName('nropres').AsString);
    datosdb.refrescar(presupuesto);
  end;
end;

procedure TTpresupuestoAnalisis.Borrar(xnropres, xcodanalisis: string);
// Objetivo...: Anular los items de un resultado de análisis determinado
begin
  datosdb.tranSQL(detpres.DatabaseName, 'DELETE FROM resultado WHERE nropres = ' + '''' + xnropres + '''' + ' AND codanalisis = ' + '''' + xcodanalisis + '''');
end;

procedure TTpresupuestoAnalisis.BorrarItems(xnropres: string);
// Objetivo...: Anular los items de un análisis determinado
begin
  datosdb.tranSQL(detpres.DatabaseName, 'DELETE FROM detpres WHERE nropres = ' + '''' + xnropres + '''');
  datosdb.refrescar(detpres);
end;

procedure TTpresupuestoAnalisis.getDatos(xnropres: string);
// Objetivo...: Cargar/iniciar los atributos para una instancia
begin
  if Buscar(xnropres) then
    begin
      nropres        := presupuesto.FieldByName('nropres').AsString;
      fecha          := utiles.sFormatoFecha(presupuesto.FieldByName('fecha').AsString);
      hora           := presupuesto.FieldByName('hora').AsString;
      codpac         := presupuesto.FieldByName('codpac').AsString;
      codprof        := presupuesto.FieldByName('codprof').AsString;
      codos          := presupuesto.FieldByName('codos').AsString;
      entorden       := presupuesto.FieldByName('entorden').AsString;
      obspresupuesto := presupuesto.FieldByName('observaciones').Value;
      exipresupuesto := true;
    end
  else
    begin
      nropres := ''; fecha := utiles.sFormatoFecha(utiles.sExprFecha2000(DateToStr(Now()))); codpac := ''; codprof := ''; codos := ''; entorden := ''; obspresupuesto := ''; hora := '';
      exipresupuesto := false;
    end;
end;

function TTpresupuestoAnalisis.NuevoPresupuesto: string;
// Objetivo...: Obtener el siguiente nro. de presupuesto
begin
  ultnro.First;
  if ultnro.RecordCount = 0 then Result := '1' else Result := IntToStr(ultnro.FieldByName('nropres').AsInteger + 1);
end;

procedure TTpresupuestoAnalisis.TituloSol(salida: char);
// Objetivo...: Listar títulos de resultados de análisis
begin
  titulos.base_datos := dbs.baseDat_N;
  titulos.conectar;
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 12');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 17'); List.Titulo(34, list.lineactual, ' ' + titulos.titulo, 2, 'Arial, negrita, 17');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 17'); List.Titulo(66, list.lineactual, titulos.profesional, 2, 'Arial, cursiva, 13, clBlue');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 17'); List.Titulo(81, list.lineactual, titulos.actividad, 2, 'Arial, normal, 9');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, negrita, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 6');
  List.Titulo(0, 0, titulos.direccion, 1, 'Arial, normal, 10');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, negrita, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  titulos.desconectar;
end;

procedure TTpresupuestoAnalisis.ListSol(xcodpac, xidprof: string; salida: char);
// Objetivo...: Listar datos de la solictud - Paciente y Profesional
begin
  paciente.getDatos(xcodpac);
  profesional.getDatos(xidprof);
  List.Linea(0, 0, '     Paciente:  ' + UpperCase(paciente.Nombre), 1, 'Times New Roman, normal, 10, clTeal', salida, 'S');
  List.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');
  List.Linea(0, 0, '     Indicación del Dr/a.:  ', 1, 'Times New Roman, normal, 10', salida, 'N');
  List.Linea(19, list.lineactual, profesional.Nombres, 2, 'Times New Roman, negrita, 10', salida, 'S');
  List.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');
  List.Linea(0, 0, '     Protocolo Nº ' + presupuesto.FieldByName('protocolo').AsString, 1, 'Times New Roman, normal, 10', salida, 'S');
  List.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');
  List.Linea(0, 0, '     Fecha: ' + Copy(presupuesto.FieldByName('fecha').AsString, 7, 2) + ' de ' + meses[StrToInt(Copy(presupuesto.FieldByName('fecha').AsString, 5, 2))] + ' ' +  Copy(presupuesto.FieldByName('fecha').AsString, 1, 4), 1, 'Times New Roman, normal, 10', salida, 'S');
  List.Linea(0, 0, ' ', 1, 'Arial, normal, 8', salida, 'S');
  List.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, negrita, 11', salida, 'S');
  List.Linea(0, 0, ' ', 1, 'Arial, normal, 16', salida, 'S');
  List.Linea(0, 0, ' ', 1, 'Arial, normal, 24', salida, 'S');
end;

procedure TTpresupuestoAnalisis.Depurar(xfecha: string);
// Objetivo...: Depurar Información
var
  r: TQuery; us, pr: string;
begin
  us := '999999'; pr := '';
  r  := datosdb.tranSQL(presupuesto.DatabaseName, 'SELECT * FROM presupuesto WHERE fecha <= ' + '"' + utiles.sExprFecha2000(xfecha) + '"');
  if not (r.EOF) or (r.BOF) then Begin
    r.Open; r.First;
    while not r.EOF do Begin
      if r.FieldByName('nropres').AsString < us then Begin
          us := r.FieldByName('nropres').AsString;   // Guardamos el nro mas chico depurado para comenzar la numeración de sol....
          pr := r.FieldByName('protocolo').AsString;
        end;
        datosdb.tranSQL(detpres.DatabaseName, 'DELETE FROM detpres     WHERE nropres = ' + '"' + r.FieldByName('nropresupuesto').AsString + '"');
        datosdb.tranSQL(detpres.DatabaseName, 'DELETE FROM presupuesto WHERE nropres = ' + '"' + r.FieldByName('nropresupuesto').AsString + '"');
        datosdb.refrescar(presupuesto); datosdb.refrescar(detpres);
        //datosdb.tranSQL(detpres.DatabaseName, 'DELETE FROM resultado   WHERE nropres = ' + '"' + r.FieldByName('nropresupuesto').AsString + '"');
        //datosdb.tranSQL(detpres.DatabaseName, 'DELETE FROM refanalisis WHERE nropres = ' + '"' + r.FieldByName('nropresupuesto').AsString + '"');
        //datosdb.tranSQL(detpres.DatabaseName, 'DELETE FROM obsanalisis WHERE nropres = ' + '"' + r.FieldByName('nropresupuesto').AsString + '"');
      end;
      r.Next;
    end;
    r.Close; r.Free;
end;

function  TTpresupuestoAnalisis.verificarPaciente(xcodpac: string): boolean;
// Objetivo...: Verificar paciente en presupuesto
var
  t: boolean;
begin
  t := False;
  if not presupuesto.Active then Begin
    presupuesto.Open;
    t := True;
  end;

  Result := False;
  presupuesto.First;
  while not presupuesto.EOF do Begin
    if presupuesto.FieldByName('codpac').AsString = xcodpac then Begin
      Result := True;
      Break;
    end;
    presupuesto.Next;
  end;

  if t then presupuesto.Close;
end;

function  TTpresupuestoAnalisis.verificarProfesional(xcodprof: string): boolean;
// Objetivo...: Verificar profesional en presupuesto
var
  t: boolean;
begin
  t := False;
  if not presupuesto.Active then Begin
    presupuesto.Open;
    t := True;
  end;

  Result := False;
  presupuesto.First;
  while not presupuesto.EOF do Begin
    if presupuesto.FieldByName('codprof').AsString = xcodprof then Begin
      Result := True;
      Break;
    end;
    presupuesto.Next;
  end;

  if t then presupuesto.Close;
end;

function  TTpresupuestoAnalisis.verificarEntidadDerivacion(xidentidad: string): boolean;
// Objetivo...: Verificar entidades en las presupuestoes
var
  t: boolean;
begin
  t := False;
  if not detpres.Active then Begin
    detpres.Open;
    t := True;
  end;

  Result := False;
  detpres.First;
  while not detpres.EOF do Begin
    if detpres.FieldByName('identidad').AsString = xidentidad then Begin
      Result := True;
      Break;
    end;
    detpres.Next;
  end;

  if t then detpres.Close;
end;

function TTpresupuestoAnalisis.setImportePacientePor_ObraSocial(xcodpac, xcodob, xdfecha, xhfecha: string): real;
// Objetivo...: Calcular el importe de analisis de obras sociales para un presupuesto dada
var
  t: real;
begin
  t := 0;
  if not controlSQL then Begin
    r := datosdb.tranSQL(detpres.DatabaseName, 'SELECT detpres.Nropres, detpres.Codos, detpres.Items, presupuesto.Codpac, presupuesto.Fecha FROM presupuesto, detpres WHERE presupuesto.codpac = ' + '"' + xcodpac + '"' + ' AND presupuesto.fecha >= ' + '"' + utiles.sExprFecha2000(xdfecha) + '"' + ' AND presupuesto.fecha <= ' + '"' + utiles.sExprFecha2000(xhfecha) + '"' + ' AND Nropres = presupuesto.Nropres');
    r.Open;
  end;
  r.First;
  while not r.EOF do Begin
    //if r.FieldByName('codos').AsString = xcodob then t := t + setValorAnalisis(r.FieldByName('nropresupuesto').AsString, r.FieldByName('items').AsString);
    r.Next;
  end;
  r.Close; r.Free;
  controlSQL := True;
  Result := t;
end;

function TTpresupuestoAnalisis.setAnalisis: TQuery;
// Objetivo...: devolver los analisis para un presupuesto dado
begin
  Result := datosdb.tranSQL(detpres.DatabaseName, 'SELECT * FROM detpres WHERE Nropres = ' + '"' + nropres + '"');
end;

procedure TTpresupuestoAnalisis.ListarPresupuesto(xdfecha, xhfecha, xcodos, xprotocoloini, xprotocolofin: string; salida: char);
// Objetivo...: Emisión del presupuesto
var
  Q: TQuery;
  idpac, idos, det: string; total, totiva: real; listmov: boolean;
begin
  Q := datosdb.tranSQL(presupuesto.DatabaseName, 'SELECT nropres, Codpac, Items, Codanalisis, Entorden, codos, OSUB, NOUB, OSUG, NOUG, importe FROM presupuesto, detpres WHERE presupuesto.Nropres = detpres.Nropres AND fecha >= ' + '"' + utiles.sExprFecha2000(xdfecha) + '"' + ' AND fecha <= ' + '"' + utiles.sExprFecha2000(xhfecha) + '"' + ' ORDER BY Codpac, Codos, Items');
  if not s_inicio then Begin
    profesional.getDatos(presupuesto.FieldByName('codprof').AsString);
    list.Setear(salida);
    titulos.base_datos := dbs.baseDat_N;
    titulos.conectar;
    list.Titulo(0, 0, ' ', 1, 'Arial, negrita, 18');
    list.Titulo(0, 0, TrimLeft(titulos.titulo), 1, titulos.fTitulo);
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 5');
    list.Titulo(0, 0, TrimLeft(titulos.subtitulo), 1, titulos.fSubtitulo);
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 5');
    list.ListMemoRecortandoStringIzquierda_Titulos('Actividad', titulos.fprofesion, 0, salida, titulos.tabla, 0);
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 5');
    list.ListMemoRecortandoStringIzquierda_Titulos('Direccion', titulos.fdirtel, 0, salida, titulos.tabla, 0);
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 10');
    list.Titulo(0, 0, 'Presupuesto', 1, 'Arial, negrita, 14');
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 6');
    list.Titulo(0, 0, 'Para:  ' + paciente.nombre, 1, 'Arial, cursiva, 10');
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 6');
    List.Titulo(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11');
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 5');

    List.Titulo(0, 0, ' ', 1, 'Arial, cursiva, 8');
    List.Titulo(10, list.Lineactual, ' ', 2, 'Arial, cursiva, 8');
    List.Titulo(20, list.Lineactual, 'Análisis', 3, 'Arial, cursiva, 8');
    List.Titulo(92, list.Lineactual, 'Importe', 4, 'Arial, cursiva, 8');
    List.Titulo(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11');
    List.Titulo(0, 0, ' ', 1, 'Arial, cursiva, 8');
    List.Linea(0, 0, '    ', 1, 'Arial, normal, 10', salida, 'S');
  end;
  s_inicio := True;

  listmov := False;
  if xcodos = '-' then listmov := True;

  Q.Open; idpac := ''; idos := '';  total := 0; totiva := 0;
  while not Q.EOF do Begin
   if (Q.FieldByName('nropres').AsString >= xprotocoloini) and (Q.FieldByName('nropres').AsString <= xprotocolofin) then Begin
    if xcodos <> '-' then if Q.FieldByName('codos').AsString = xcodos then listmov := True else listmov := False;
    if listmov then begin
      paciente.getDatos(Q.FieldByName('codpac').AsString);
      obsocial.getDatos(Q.FieldByName('codos').AsString);
      if (length(trim(Q.FieldByName('codanalisis').AsString)) = 4) then begin
        nomeclatura.getDatos(Q.FieldByName('codanalisis').AsString);
        det := nomeclatura.descrip;
      end else begin
        nbu.getDatos(Q.FieldByName('codanalisis').AsString);
        det := nbu.descrip;
      end;
      if Q.FieldByName('codos').AsString <> idos then list.Linea(0, 0, '  ', 1, 'Arial, normal, 8', salida, 'N') else list.Linea(0, 0, '  ', 1, 'Arial, normal, 8', salida, 'N');
      list.Linea(10, list.Lineactual, '  ', 2, 'Arial, normal, 8', salida, 'N');
      if Q.FieldByName('codanalisis').AsString <> '9999' then list.Linea(20, list.Lineactual, Q.FieldByName('codanalisis').AsString  + '  ' + det, 3, 'Arial, normal, 8', salida, 'N') else list.Linea(20, list.Lineactual, Q.FieldByName('codanalisis').AsString  + '  ' + Q.FieldByName('descrip').AsString, 3, 'Arial, normal, 8', salida, 'N');
      list.importe(98, list.Lineactual, '', Q.FieldByName('importe').AsFloat, 4, 'Arial, normal, 8');
      list.Linea(99, list.Lineactual, '  ', 5, 'Arial, normal, 8', salida, 'S');
      total  := total + Q.FieldByName('importe').AsFloat;
      totiva := totiva + (Q.FieldByName('importe').AsFloat * (obsocial.Retencioniva * 0.01));
      idpac  := Q.FieldByName('codpac').AsString;
      idos   := Q.FieldByName('codos').AsString;
    end;
   end;
   Q.Next;
  end;
  Q.Close; Q.Free;

  if total <> 0 then Begin
    List.Linea(0, 0, '    ', 1, 'Arial, normal, 8', salida, 'S');
    List.derecha(98, list.Lineactual, '###################', '-------------------', 2, 'Arial, normal, 9');
    List.Linea(0, 0, 'Subtotal:', 1, 'Arial, negrita, 8', salida, 'S');
    List.importe(98, list.lineactual, '', total, 2, 'Arial, negrita, 8');
    list.Linea(98, list.Lineactual, '', 3, 'Arial, negrita, 9', salida, 'S');
    List.Linea(0, 0, 'I.V.A.:', 1, 'Arial, negrita, 8', salida, 'S');
    List.importe(98, list.lineactual, '', totiva, 2, 'Arial, negrita, 8');
    list.Linea(98, list.Lineactual, '', 3, 'Arial, negrita, 9', salida, 'S');
    List.Linea(0, 0, 'Total:', 1, 'Arial, negrita, 8', salida, 'S');
    List.importe(98, list.lineactual, '', total + totiva, 2, 'Arial, negrita, 8');
    list.Linea(98, list.Lineactual, '', 3, 'Arial, negrita, 9', salida, 'S');
    total := total + totiva;
    List.Linea(0, 0, '    ', 1, 'Arial, negrita, 4', salida, 'S');
    List.Linea(0, 0, 'Son Pesos ' + utiles.xIntToLletras(StrToInt(Copy(utiles.FormatearNumero(FloatToStr(total)), 1, Length(Trim(utiles.FormatearNumero(FloatToStr(total)))) - 3))) + ' con ' + Copy(utiles.FormatearNumero(FloatToStr(total)), Length(Trim(utiles.FormatearNumero(FloatToStr(total)))) - 1, 2) + ' centavos.', 1, 'Arial, negrita, 8', salida, 'S');
  end;
  List.Linea(0, 0, '    ', 1, 'Arial, negrita, 8', salida, 'S');

  list.ListMemo('observaciones', 'Arial, cursiva, 8', 0, salida, presupuesto, 0);

  list.FinList;
end;

procedure TTpresupuestoAnalisis.PresentarInforme;
begin
  //list.FinList;
  s_inicio := False;
end;

procedure TTpresupuestoAnalisis.refrescar;
// Objetivo...: refrescar tablas
begin
  datosdb.refrescar(presupuesto);
  datosdb.refrescar(detpres);
  datosdb.refrescar(ultnro);
end;

procedure   TTpresupuestoAnalisis.RegistrarItemsPresupuestoRapido(xitems, xcodanalisis, xdescrip, xprecio, xpreciototal, xcftoma, xtotal, xiva: String; xcantidaditems: Integer);
// Objetivo...: registrar Items Presupuesto rápido
Begin
  archivo[StrToInt(xitems), 1] := xitems;
  archivo[StrToInt(xitems), 2] := xcodanalisis;
  archivo[StrToInt(xitems), 3] := xdescrip;
  archivo[StrToInt(xitems), 4] := xprecio;
  archivo[StrToInt(xitems), 5] := xcftoma;
  totitems   := xcantidaditems;
  totales[1] := xpreciototal;
  totales[2] := xcftoma;
  totales[3] := xtotal;
  totales[4] := xiva;
end;

procedure   TTpresupuestoAnalisis.RegistrarItemsPresupuestoRapido(xitems, xcantidad, xcodanalisis, xdescrip, xprecio, xpreciototal, xcftoma, xtotal, xiva: String; xcantidaditems: Integer);
// Objetivo...: registrar Items Presupuesto rápido
Begin
  archivo[StrToInt(xitems), 1] := xitems;
  archivo[StrToInt(xitems), 2] := xcodanalisis;
  archivo[StrToInt(xitems), 3] := xdescrip;
  archivo[StrToInt(xitems), 4] := xprecio;
  archivo[StrToInt(xitems), 5] := xcftoma;
  archivo[StrToInt(xitems), 6] := xcantidad;
  totitems   := xcantidaditems;
  totales[1] := xpreciototal;
  totales[2] := xcftoma;
  totales[3] := xtotal;
  totales[4] := xiva;
end;

procedure   TTpresupuestoAnalisis.ImprimirPresupuestoRapido(salida: char);
// Objetivo...: Imprimir Presupuesto rápido
var
  i: Integer;
Begin
  list.NoImprimirPieDePagina;
  list.Titulo(0, 0, '', 1, 'Arial, negrita, 14');
  list.Titulo(0, 0, 'Presupuesto al:  ' + utiles.setFechaActual, 1, 'Arial, negrita, 11');
  list.Titulo(0, 0, '', 1, 'Arial, negrita, 5');
  list.Titulo(0, 0, 'It.  Código    Determinación', 1, 'Arial, cursiva, 8');
  list.Titulo(52, list.Lineactual, 'Monto', 2, 'Arial, cursiva, 8');
  list.Titulo(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 7');
  list.Titulo(0, 0, '', 1, 'Arial, negrita, 5');

  For i := 1 to totitems do Begin
    list.Linea(0, 0, archivo[i, 1] + '  ' + archivo[i, 2] + ' - ' + archivo[i, 3], 1, 'Arial, normal, 8', salida, 'N');
    list.importe(56, list.Lineactual, '', StrToFloat(archivo[i, 4]), 2, 'Arial, normal, 8');
    list.Linea(60, list.Lineactual, ' ', 3, 'Arial, normal, 8', salida, 'S');
  end;
  //falta subtotal ...
  list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
  list.Linea(0, 0, 'Subtotal:', 1, 'Arial, negrita, 8', salida, 'N');
  list.Importe(25, list.Lineactual, '', StrToFloat(totales[1]), 2, 'Arial, negrita, 8');
  list.Linea(30, list.Lineactual, 'Rec. y Toma:', 3, 'Arial, negrita, 9', salida, 'N');
  list.Importe(56, list.Lineactual, '', StrToFloat(totales[2]), 4, 'Arial, negrita, 8');
  list.Linea(57, list.Lineactual, '', 5, 'Arial, negrita, 8', salida, 'S');

  list.Linea(0, 0, 'I.V.A.:', 1, 'Arial, negrita, 8', salida, 'N');
  list.Importe(25, list.Lineactual, '', StrToFloat(totales[4]), 2, 'Arial, negrita, 8');
  list.Linea(30, list.Lineactual, 'Subtotal:', 3, 'Arial, negrita, 8', salida, 'N');
  list.Importe(56, list.Lineactual, '', StrToFloat(totales[3]), 4, 'Arial, negrita, 8');
  list.Linea(56, list.Lineactual, '', 5, 'Arial, negrita, 8', salida, 'S');
  list.Linea(0, 0, 'Total:', 1, 'Arial, negrita, 8', salida, 'N');
  list.Importe(25, list.Lineactual, '', StrToFloat(totales[4]) + StrToFloat(totales[3]), 2, 'Arial, negrita, 8');
  list.Linea(56, list.Lineactual, '', 3, 'Arial, negrita, 8', salida, 'S');

  list.FinList;
end;

function  TTpresupuestoAnalisis.Bloquear: Boolean;
// Objetivo...: Bloquear Proceso
begin
  Result := bloqueo.Bloquear('presupuesto');
end;

procedure TTpresupuestoAnalisis.QuitarBloqueo;
// Objetivo...: QuitarBloqueo
begin
  bloqueo.QuitarBloqueo('presupuesto');
end;

procedure TTpresupuestoAnalisis.conectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones = 0 then Begin
    paciente.conectar;
    profesional.conectar;
    nomeclatura.conectar;
    if not presupuesto.Active then presupuesto.Open;
    if not detpres.Active then detpres.Open;
    if not ultnro.Active then ultnro.Open;
  end;
  Inc(conexiones);
end;

procedure TTpresupuestoAnalisis.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  controlSQL := False;
  if conexiones > 0 then Dec(conexiones);
  if conexiones = 0 then Begin
    paciente.desconectar;
    profesional.desconectar;
    nomeclatura.desconectar;
    if presupuesto.Active then datosdb.closeDB(presupuesto);
    if detpres.Active     then datosdb.closeDB(detpres);
    if ultnro.Active      then datosdb.closeDB(ultnro);
  end;
end;

{===============================================================================}

function presupuesto: TTpresupuestoAnalisis;
begin
  if xsolanalisis = nil then
    xsolanalisis := TTpresupuestoAnalisis.Create;
  Result := xsolanalisis;
end;

{===============================================================================}

initialization

finalization
  xsolanalisis.Free;

end.
