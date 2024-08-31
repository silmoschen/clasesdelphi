unit CtitularPreveer_Sepelios;

interface

uses CPersona, CConyugePreveer_Sepelios, CHijosPreveer_Sepelios, CPreverCostos, CBDT, SysUtils, DBTables, CUtiles, CListar, CIDBFM, CTercerosPreveer_Sepelios;

type

TTitularSepelio = class(TTPersona)
  FechaNac, Telefono, Email, EstadoCivil: String;
  Plus, CostoTitular, CostoHijos, CostoTerceros, CostoTotal, Adicional, Estudiante, Ttp: Real;
  Existe: Boolean;
  tit: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  function    Buscar(xNrodoc: string): boolean;
  procedure   Grabar(xNrodoc, xnombre, xdomicilio, xcp, xorden, xfechanac, xtelefono, xemail, xestcivil: String);
  procedure   Borrar(xNrodoc: string);
  procedure   getDatos(xNrodoc: string);
  procedure   Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);

  procedure   BuscarPorCodigo(xexpr: string);
  procedure   BuscarPorNombre(xexpr: string);

  function    setTitularesSepelio: TQuery;
  function    setMontoTitular(xedad: String): Real;
  function    setMontoHijos(xnrodoc: String): Real;
  function    setMontoTerceros(xnrodoc: String): Real;

  procedure   RegistrarMontoGrupoFamiliar(xnrodoc: String; xmonto, xhijos, xterceros, xplus, xttp, xtotalgrupo: Real);
  procedure   RecalcularMontos;

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  conexiones: shortint;
  procedure   List_linea(salida: char);
  procedure   List_Tit(salida: char);
end;

function titularsep: TTitularSepelio;

implementation

var
  xtitsep: TTitularSepelio = nil;

constructor TTitularSepelio.Create;
begin
  inherited Create('', '', '', '', ''); // Hereda de Persona
  tperso := datosdb.openDB('titulares', 'Nrodoc', '', dbs.DirSistema + '\sepelio');
  tit    := datosdb.openDB('titularesh', 'Nrodoc', '', dbs.DirSistema + '\sepelio');
end;

destructor TTitularSepelio.Destroy;
begin
  inherited Destroy;
end;

function  TTitularSepelio.Buscar(xNrodoc: string): boolean;
// Objetivo...: Buscar una instancia
begin
  if tperso.IndexFieldNames <> 'Nrodoc' then tperso.IndexFieldNames := 'Nrodoc';
  if tit.FindKey([xNrodoc]) then Begin
    inherited Buscar(xNrodoc);
    Existe := True;
  end else
    Existe := False;
  Result := Existe;
end;

procedure TTitularSepelio.Grabar(xNrodoc, xnombre, xdomicilio, xcp, xorden, xfechanac, xtelefono, xemail, xestcivil: String);
// Objetivo...: Almacenar una instacia de la clase
begin
  if Buscar(xNrodoc) then tit.Edit else tit.Append;
  tit.FieldByName('Nrodoc').AsString       := xNrodoc;
  tit.FieldByName('fechanac').AsString  := utiles.sExprFecha(xfechanac);
  tit.FieldByName('telefono').AsString  := xtelefono;
  tit.FieldByName('email').AsString     := xemail;
  tit.FieldByName('estcivil').AsString  := xestcivil;
  try
    tit.Post
  except
    tit.Cancel
  end;
  inherited Grabar(xNrodoc, xnombre, xdomicilio, xcp, xorden);
end;

procedure TTitularSepelio.Borrar(xNrodoc: string);
// Objetivo...: Eliminar una instancia
begin
  if Buscar(xNrodoc) then Begin
    conyuge.Borrar(xnrodoc);     { Borramos Conyuge }
    hijossep.Borrar(xnrodoc);    { Borramos Hijos }
    tercerossep.Borrar(xnrodoc); { Borramos terceros a cargo }
    tit.Delete;
    inherited Borrar(xNrodoc);
    getDatos(tit.FieldByName('nrodoc').AsString);
  end;
end;

procedure TTitularSepelio.getDatos(xNrodoc: string);
// Objetivo...: Cargar/iniciar los atributos para una instancia
begin
  if Buscar(xNrodoc) then Begin
    FechaNac      := utiles.sFormatoFecha(tit.FieldByName('fechanac').AsString);
    Telefono      := TrimLeft(tit.FieldByName('telefono').AsString);
    Email         := TrimLeft(tit.FieldByName('email').AsString);
    EstadoCivil   := TrimLeft(tit.FieldByName('estcivil').AsString);
    CostoTitular  := tit.FieldByName('monto').AsFloat;
    CostoHijos    := tit.FieldByName('hijos').AsFloat;
    CostoTerceros := tit.FieldByName('terceros').AsFloat;
    Ttp           := tit.FieldByName('ttp').AsFloat;
    CostoTotal    := tit.FieldByName('totalgrupo').AsFloat;
  end else Begin
    FechaNac := ''; Telefono := ''; Email := ''; EstadoCivil := ''; CostoTitular := 0; CostoHijos := 0; CostoTotal := 0; CostoTerceros := 0; ttp := 0;
  end;
  inherited getDatos(xNrodoc);
end;

procedure TTitularSepelio.List_Tit(salida: char);
// Objetivo...: Listar una Línea
begin
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Listado de Abonados', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Nº Doc.   Apellido y Nombre', 1, 'Arial, cursiva, 8');
  List.Titulo(40, List.lineactual, 'Dirección', 2, 'Arial, cursiva, 8');
  List.Titulo(65, List.lineactual, 'Teléfono', 3, 'Arial, cursiva, 8');
  List.Titulo(82, List.lineactual, 'Localidad', 4, 'Arial, cursiva, 8');
  List.Titulo(94, List.lineactual, 'Edad', 5, 'Arial, cursiva, 8');
  List.Titulo(99, List.lineactual, 'Est.', 6, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');
end;

procedure TTitularSepelio.List_linea(salida: char);
// Objetivo...: Listar una Línea
var
  r: TQuery;
  h: Boolean;
begin
  { Titular }
  getDatos(tperso.FieldByName('nrodoc').AsString);
  tit.FindKey([tperso.FieldByName('nrodoc').AsString]);   // Sincronizamos las tablas
  List.Linea(0, 0, tperso.FieldByName('nrodoc').AsString + '  ' + tperso.FieldByName('nombre').AsString, 1, 'Arial, negrita, 8', salida, 'N');
  List.Linea(40, List.lineactual, tperso.FieldByName('direccion').AsString, 2, 'Arial, negrita, 8', salida, 'N');
  List.Linea(65, List.lineactual, tit.FieldByName('telefono').AsString, 3, 'Arial, negrita, 8', salida, 'N');
  List.Linea(82, list.Lineactual, Localidad, 4, 'Arial, negrita, 8', salida, 'N');
  List.Linea(96, List.lineactual, IntToStr(utiles.Edad(copy(tit.FieldByName('fechanac').AsString, 7, 2) + '/' + copy(tit.FieldByName('fechanac').AsString, 5, 2) + '/' + copy(tit.FieldByName('fechanac').AsString, 1, 4))), 5, 'Arial, negrita, 8', salida, 'S');

  { Conyuge }
  conyuge.getDatos(tperso.FieldByName('nrodoc').AsString);
  if Length(Trim(conyuge.NrodocConyuge)) > 0 then Begin
    List.Linea(0, 0, conyuge.NrodocConyuge + '  ' + conyuge.nombre, 1, 'Arial, normal, 8', salida, 'N');
    List.Linea(40, List.lineactual, conyuge.domicilio, 2, 'Arial, normal, 8', salida, 'N');
    List.Linea(65, List.lineactual, conyuge.Telefono, 3, 'Arial, normal, 8', salida, 'N');
    List.Linea(82, list.Lineactual, conyuge.localidad, 4, 'Arial, normal, 8', salida, 'N');
    List.Linea(96, List.lineactual, IntToStr(utiles.Edad(copy(utiles.sExprFecha(conyuge.FechaNac), 7, 2) + '/' + copy(utiles.sExprFecha(conyuge.FechaNac), 5, 2) + '/' + copy(utiles.sExprFecha(conyuge.FechaNac), 1, 4))), 5, 'Arial, normal, 8', salida, 'S');
  end;

  { Hijos }
  r := hijossep.setPersonasACargo(tperso.FieldByName('nrodoc').AsString);
  r.Open; h := False;
  while not r.Eof do Begin
    if not h then List.Linea(0, 0, '  ', 1, 'Arial, normal, 5', salida, 'S');
    hijossep.getDatos(r.FieldByName('nrodoc').AsString, tperso.FieldByName('nrodoc').AsString);
    List.Linea(0, 0, hijossep.Nrodoc  + '  ' + hijossep.nombre, 1, 'Arial, normal, 8', salida, 'N');
    List.Linea(40, List.lineactual, hijossep.Direccion, 2, 'Arial, normal, 8', salida, 'N');
    List.Linea(65, List.lineactual, hijossep.Telefono, 3, 'Arial, normal, 8', salida, 'N');
    List.Linea(82, list.Lineactual, hijossep.Localidad, 4, 'Arial, normal, 8', salida, 'N');
    if Length(Trim(hijossep.FechaNac)) = 8 then List.Linea(96, List.lineactual, IntToStr(utiles.Edad(copy(utiles.sExprFecha(hijossep.FechaNac), 7, 2) + '/' + copy(utiles.sExprFecha(hijossep.FechaNac), 5, 2) + '/' + copy(utiles.sExprFecha(hijossep.FechaNac), 1, 4))), 5, 'Arial, normal, 8', salida, 'N') else List.Linea(96, List.lineactual, '', 5, 'Arial, normal, 8', salida, 'N');
    List.Linea(100, List.lineactual, hijossep.Estudiante, 6, 'Arial, normal, 8', salida, 'S');
    h := True;
    r.Next;
  end;
  if h then List.Linea(0, 0, '  ', 1, 'Arial, normal, 5', salida, 'S');

  { Terceros }
  r := tercerossep.setPersonasACargo(tperso.FieldByName('nrodoc').AsString);
  r.Open; h := False;
  while not r.Eof do Begin
    if not h then Begin
      List.Linea(0, 0, '  ', 1, 'Arial, normal, 5', salida, 'S');
      List.Linea(0, 0, 'Terceros a Cargo', 1, 'Arial, cursiva, 8', salida, 'S');
      List.Linea(0, 0, '  ', 1, 'Arial, normal, 5', salida, 'S');
    end;
    tercerossep.getDatos(r.FieldByName('nrodoc').AsString, tperso.FieldByName('nrodoc').AsString);
    List.Linea(0, 0, tercerossep.Nrodoc  + '  ' + tercerossep.nombre, 1, 'Arial, normal, 8', salida, 'N');
    List.Linea(40, List.lineactual, tercerossep.Direccion, 2, 'Arial, normal, 8', salida, 'N');
    List.Linea(65, List.lineactual, tercerossep.Telefono, 3, 'Arial, normal, 8', salida, 'N');
    List.Linea(82, list.Lineactual, tercerossep.Localidad, 4, 'Arial, normal, 8', salida, 'N');
    List.Linea(96, List.lineactual, IntToStr(utiles.Edad(copy(utiles.sExprFecha(tercerossep.FechaNac), 7, 2) + '/' + copy(utiles.sExprFecha(tercerossep.FechaNac), 5, 2) + '/' + copy(utiles.sExprFecha(tercerossep.FechaNac), 1, 4))), 5, 'Arial, normal, 8', salida, 'N');
    List.Linea(100, List.lineactual, tercerossep.Estudiante, 6, 'Arial, normal, 8', salida, 'S');
    h := True;
    r.Next;
  end;
  List.Linea(0, 0, '  ', 1, 'Arial, normal, 5', salida, 'S');

  { Costos }
  list.Linea(0, 0, 'Costos -   Titular: ', 1, 'Arial, cursiva, 8', salida, 'N');
  list.importe(23, list.Lineactual, '', titularsep.CostoTitular, 2, 'Arial, cursiva, 8');
  list.Linea(24, list.Lineactual, 'Conyuge: ', 3, 'Arial, cursiva, 8', salida, 'N');
  list.importe(41, list.Lineactual, '', conyuge.Costo, 4, 'Arial, cursiva, 8');
  list.Linea(43, list.Lineactual, 'Hijos: ', 5, 'Arial, cursiva, 8', salida, 'N');
  list.importe(57, list.Lineactual, '', titularsep.CostoHijos, 6, 'Arial, cursiva, 8');
  list.Linea(58, list.Lineactual, 'Terceros: ', 7, 'Arial, cursiva, 8', salida, 'N');
  list.importe(72, list.Lineactual, '', titularsep.CostoTerceros, 8, 'Arial, cursiva, 8');
  list.Linea(75, list.Lineactual, 'TOTAL GRUPO: ', 9, 'Arial, cursiva, 8', salida, 'N');
  list.importe(99, list.Lineactual, '', titularsep.CostoTotal, 10, 'Arial, cursiva, 8');
  list.Linea(99, list.Lineactual, '', 11, 'Arial, cursiva, 8', salida, 'S');

  List.Linea(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
  List.Linea(0, 0, '  ', 1, 'Arial, normal, 8', salida, 'S');
  r.Close; r.Free;
end;

procedure TTitularSepelio.Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
// Objetivo...: Listado de la clase
begin
  if orden = 'A' then tperso.IndexFieldNames := 'Nombre';
  list_Tit(salida);

  tperso.First;
  while not tperso.EOF do Begin
    // Ordenado por Código
    if (ent_excl = 'E') and (orden = 'C') then
      if (tperso.FieldByName('nrodoc').AsString >= iniciar) and (tperso.FieldByName('nrodoc').AsString <= finalizar) then List_linea(salida);
    if (ent_excl = 'X') and (orden = 'C') then
      if (tperso.FieldByName('nrodoc').AsString < iniciar) or (tperso.FieldByName('nrodoc').AsString > finalizar) then List_linea(salida);
    // Ordenado Alfabéticamente
    if (ent_excl = 'E') and (orden = 'A') then
      if (tperso.FieldByName('nombre').AsString >= iniciar) and (tperso.FieldByName('nombre').AsString <= finalizar) then List_linea(salida);
    if (ent_excl = 'X') and (orden = 'A') then
      if (tperso.FieldByName('nombre').AsString < iniciar) or (tperso.FieldByName('nombre').AsString > finalizar) then List_linea(salida);
    tperso.Next;
  end;
  List.FinList;

  tperso.IndexFieldNames := 'Nrodoc';
  tperso.First;
end;

procedure TTitularSepelio.BuscarPorCodigo(xexpr: string);
// Objetivo...: buscar por código
begin
  tperso.IndexFieldNames := 'Nrodoc';
  tperso.FindNearest([xexpr]);
end;

procedure TTitularSepelio.BuscarPorNombre(xexpr: string);
// Objetivo...: buscar por nombre
begin
  tperso.IndexFieldNames := 'Nombre';
  tperso.FindNearest([xexpr]);
end;

function  TTitularSepelio.setTitularesSepelio: TQuery;
// Objetivo...: Devolver un set con los titulares
Begin
  Result := datosdb.tranSQL('SELECT * FROM ' + tperso.TableName + ' ORDER BY Nombre');
end;

function  TTitularSepelio.setMontoTitular(xedad: String): Real;
// Objetivo...: Retornar costo
Begin
  Result     := costogrupo.setMontoAPagar(xedad);
  Plus       := costogrupo.Plus;
  Adicional  := costogrupo.Adicional;
  Estudiante := costogrupo.Estudiantes;
end;

procedure TTitularSepelio.RegistrarMontoGrupoFamiliar(xnrodoc: String; xmonto, xhijos, xterceros, xplus, xttp, xtotalgrupo: Real);
// Objetivo...: Registrar Monto a abonar
Begin
  if Buscar(xnrodoc) then Begin
    tit.Edit;
    tit.FieldByName('monto').AsFloat      := xmonto;
    tit.FieldByName('hijos').AsFloat      := xhijos;
    tit.FieldByName('terceros').AsFloat   := xterceros;
    tit.FieldByName('plus').AsFloat       := xplus;
    tit.FieldByName('ttp').AsFloat        := xttp;
    tit.FieldByName('totalgrupo').AsFloat := xtotalgrupo;
    try
      tit.Post
     except
      tit.Cancel
    end;
    tperso.Edit;
    tperso.FieldByName('totalgrupo').AsFloat := xtotalgrupo;
    try
      tperso.Post
     except
      tperso.Cancel
    end;
  end;
end;

procedure TTitularSepelio.RecalcularMontos;
// Objetivo...: Recalcular Montos
var
  tmonto, cmonto, hmonto, termonto, tplus: Real;
  e: Integer;
Begin
  tperso.First;
  while not tperso.Eof do Begin
    getDatos(tperso.FieldByName('nrodoc').AsString);
    tmonto := tit.FieldByName('monto').AsFloat;
    e := utiles.Edad(copy(tit.FieldByName('fechanac').AsString, 7, 2) + '/' + copy(tit.FieldByName('fechanac').AsString, 5, 2) + '/' + copy(tit.FieldByName('fechanac').AsString, 1, 4));
    setMontoTitular(IntToStr(e));
    hmonto   := setMontoHijos(tperso.FieldByName('nrodoc').AsString);
    termonto := setMontoTerceros(tperso.FieldByName('nrodoc').AsString);
    conyuge.getDatos(tperso.FieldByName('nrodoc').AsString);
    cmonto   := conyuge.setMonto(tperso.FieldByName('nrodoc').AsString);
    tplus    := tit.FieldByName('plus').AsFloat;
    RegistrarMontoGrupoFamiliar(tperso.FieldByName('nrodoc').AsString, tmonto, hmonto, termonto, tplus, ttp, tmonto + cmonto + hmonto + termonto + tplus + ttp);
    datosdb.refrescar(tperso); datosdb.refrescar(tit);
    tperso.Next;
  end;
end;

function  TTitularSepelio.setMontoHijos(xnrodoc: String): Real;
// Objetivo...: Devolver el monto de los hijos
var
  r: TQuery;
  t, m, x: Real;
  e: Integer;
Begin
  r := hijossep.setPersonasACargo(xnrodoc);
  r.Open; t := 0;
  while not r.Eof do Begin
    e := utiles.Edad(copy(r.FieldByName('fechanac').AsString, 7, 2) + '/' + copy(r.FieldByName('fechanac').AsString, 5, 2) + '/' + copy(r.FieldByName('fechanac').AsString, 1, 4));

    if EstadoCivil = 'C' then Begin                         { Casado }
      if r.FieldByName('estudiante').AsString = 'N' then    { $2 Estudiante }
        if (e > 21) and (e < 30) and (r.FieldByName('incapacitado').AsString = 'N') then t := t + Adicional;
      if (r.FieldByName('estudiante').AsString = 'S') and (r.FieldByName('incapacitado').AsString = 'N') then    { Estudiante }
        if e > 25 then t := t + Adicional;
    end else Begin
      if e <= 25 then m := Estudiante else x := Adicional;
    end;

    r.Next;
  end;
  r.Close; r.Free;
  Result := t + m + x;
end;

function  TTitularSepelio.setMontoTerceros(xnrodoc: String): Real;
// Objetivo...: Devolver el monto terceros
var
  r: TQuery;
  t, m, x: Real;
  e: Integer;
Begin
  r := tercerossep.setPersonasACargo(xnrodoc);
  r.Open; t := 0;
  while not r.Eof do Begin
    e := utiles.Edad(copy(r.FieldByName('fechanac').AsString, 7, 2) + '/' + copy(r.FieldByName('fechanac').AsString, 5, 2) + '/' + copy(r.FieldByName('fechanac').AsString, 1, 4));
    t := t + costogrupo.setMontoAPagar(IntToStr(e));
    r.Next;
  end;
  r.Close; r.Free;
  Result := t + m + x;
end;

procedure TTitularSepelio.conectar;
// Objetivo...: Cerrar tablas de persistencia
begin
  costogrupo.conectar;
  if conexiones = 0 then Begin
    if not tperso.Active then tperso.Open;
    tperso.FieldByName('nrodoc').DisplayLabel := 'Nº Doc.'; tperso.FieldByName('nombre').DisplayLabel := 'Nombre y Apellido'; tperso.FieldByName('direccion').DisplayLabel := 'Dirección';
    tperso.FieldByName('totalgrupo').DisplayLabel := 'Tot. Grupo'; tperso.FieldByName('cp').Visible := False; tperso.FieldByName('orden').Visible := False;
    if not tit.Active then tit.Open;
  end;
  Inc(conexiones);
end;

procedure TTitularSepelio.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  costogrupo.desconectar;
  Dec(conexiones);
  if conexiones = 0 then Begin
    datosdb.closeDB(tperso);
    datosdb.closeDB(tit);
  end;
end;

{===============================================================================}

function titularsep: TTitularSepelio;
begin
  if xtitsep = nil then
    xtitsep := TTitularSepelio.Create;
  Result := xtitsep;
end;

{===============================================================================}

initialization

finalization
  xtitsep.Free;

end.
