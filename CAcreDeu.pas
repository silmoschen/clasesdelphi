unit CAcreDeu;

interface

uses CBDT, CPersona, CCodpost, SysUtils, DB, DBTables, CUtiles, CIDBFM;

const
  docnac: array[1..3] of string = ('D.N.I.', 'L.E.', 'L.C.');
  docext: array[1..3] of string = ('D.N.I.', 'C.I.', 'PASAP.');
  estciv: array[1..5] of string = ('Soltero', 'Casado', 'Viudo', 'Divorc.', 'Nupcia Nº');

type

TTAcreedorDeudor = class(TTPersona)          // Clase TVendedor Heredada de Persona
  numero, piso, depto, partdepto, fechanac, nrodoc: string;
  tdocnac, tdocext, estcivil: byte;
  tabla2 : TTable;         // Tablas para la Persistencia de Objetos
 public
  { Declaraciones Públicas }
  constructor Create(xnrocuit, xnombre, xdomicilio, xcp, xorden, xnumero, xpiso, xdepto, xpartdepto, xfechanac, xnrodoc: string; xtdocnac, xtdocext, xestcivil: byte);
  destructor  Destroy; override;

  function    getNacionalidad: string;
  function    getTipoDocumento: string;
  function    getEstadoCivil: string;

  procedure   Grabar(xnrocuit, xnombre, xdomicilio, xcp, xorden, xnumero, xpiso, xdepto, xpartdepto, xfechanac, xnrodoc: string; xtdocnac, xtdocext, xestcivil: byte);
  function    Borrar(xnrocuit: string): string;
  function    Buscar(xnrocuit: string): boolean;

  procedure   getDatos(xnrocuit: string);

  procedure   conectar; overload;
  procedure   desconectar;

  procedure   Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
 private
  { Declaraciones Privadas }
  conexiones: shortint;
  procedure   List_linea(salida: char);
end;

function acrdeu: TTAcreedorDeudor;

implementation

var
  xacrdeu: TTAcreedorDeudor = nil;

constructor TTAcreedorDeudor.Create(xnrocuit, xnombre, xdomicilio, xcp, xorden, xnumero, xpiso, xdepto, xpartdepto, xfechanac, xnrodoc: string; xtdocnac, xtdocext, xestcivil: byte);
// Vendedor - Heredada de Persona
begin
  inherited Create(xnrocuit, xnombre, xdomicilio, xcp, xorden);
  numero    := xnumero;
  piso      := xpiso;
  depto     := xdepto;
  partdepto := xpartdepto;
  fechanac  := xfechanac;
  tdocnac   := xtdocnac;
  tdocext   := xtdocext;
  estcivil  := xestcivil;
  nrodoc    := xnrodoc;
end;

destructor TTAcreedorDeudor.Destroy;
begin
  inherited Destroy;
end;

function TTAcreedorDeudor.getNacionalidad: string;
begin
 if tdocnac > 0 then Result := 'Argentino';
 if tdocext > 0 then Result := 'Extranjero';
end;

function TTAcreedorDeudor.getTipoDocumento: string;
begin
 if tdocnac > 0 then Result := docnac[tdocnac];
 if tdocext > 0 then Result := docext[tdocext];
end;

function TTAcreedorDeudor.getEstadoCivil: string;
begin
  if estcivil < 1 then Result := '' else
   if estcivil < 5 then Result := estciv[estcivil] else Result := estciv[estcivil]+ ' ' + IntToStr(estcivil);
end;

procedure TTAcreedorDeudor.Grabar(xnrocuit, xnombre, xdomicilio, xcp, xorden, xnumero, xpiso, xdepto, xpartdepto, xfechanac, xnrodoc: string; xtdocnac, xtdocext, xestcivil: byte);
// Objetivo...: Grabar Atributos de Vendedores
begin
  // Actualizamos los Atributos de la Clase Persona
  inherited Grabar(xnrocuit, xnombre, xdomicilio, xcp, xorden);  //* Metodo de la Superclase
  if Buscar(xnrocuit) then tabla2.Edit else tabla2.Append;
  tabla2.FieldByName('nrocuit').AsString    := xnrocuit;
  tabla2.FieldByName('numero').AsString     := xnumero;
  tabla2.FieldByName('piso').AsString       := xpiso;
  tabla2.FieldByName('depto').AsString      := xdepto;
  tabla2.FieldByName('partdepto').AsString  := xpartdepto;
  tabla2.FieldByName('fechanac').AsString   := utiles.sExprFecha(xfechanac);
  tabla2.FieldByName('tdocnac').AsInteger   := xtdocnac;
  tabla2.FieldByName('tdocext').AsInteger   := xtdocext;
  tabla2.FieldByName('estcivil').AsInteger  := xestcivil;
  tabla2.FieldByName('nrodoc').AsString     := xnrodoc;
  try
    tabla2.Post;
  except
    tabla2.Cancel;
  end;
end;

procedure  TTAcreedorDeudor.getDatos(xnrocuit: string);
// Objetivo...: Obtener/Inicializar los Atributos para un objeto Vendedor
begin
  tabla2.Refreh;
  inherited getDatos(xnrocuit);  // Heredamos de la Superclase
   if Buscar(xnrocuit) then
    begin
      numero    := tabla2.FieldByName('numero').AsString;
      piso      := tabla2.FieldByName('piso').AsString;
      depto     := tabla2.FieldByName('depto').AsString;
      partdepto := tabla2.FieldByName('partdepto').AsString;
      fechanac  := utiles.sFormatoFecha(tabla2.FieldByName('fechanac').AsString);
      tdocnac   := tabla2.FieldByName('tdocnac').AsInteger;
      tdocext   := tabla2.FieldByName('tdocext').AsInteger;
      estcivil  := tabla2.FieldByName('estcivil').AsInteger;
      nrodoc    := tabla2.FieldByName('nrodoc').AsString;
    end
  else
    begin
      numero := ''; piso := ''; depto := ''; partdepto := ''; fechanac := ''; nrodoc := ''; tdocnac := 0; tdocext := 0; estcivil := 0;
    end;
end;

function TTAcreedorDeudor.Borrar(xnrocuit: string): string;
// Objetivo...: Eliminar un Instancia de Vendedor
begin
  if Buscar(xnrocuit) then
    begin
      inherited Borrar(xnrocuit);  // Metodo de la Superclase Persona
      tabla2.Delete;
      getDatos(tabla2.FieldByName('nrocuit').AsString);  // Fijamos los Atributos Siguientes al Objeto Borrado
    end;
end;

function TTAcreedorDeudor.Buscar(xnrocuit: string): boolean;
// Objetivo...: Verificar si Existe el Vendedor
begin
 if not (tperso.Active) or not (tabla2.Active) then conectar;
 if tabla2.FieldByName('nrocuit').AsString = xnrocuit then Result := True else
  begin
   inherited Buscar(xnrocuit);  // Método de la Superclase (Sincroniza los Valores de las Tablas)
   if tabla2.FindKey([xnrocuit]) then Result := True else Result := False;
  end;
end;

procedure TTAcreedorDeudor.conectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones = 0 then Begin
    if not tperso.Active then tperso.Open;
    if not tabla2.Active then tabla2.Open;
    cpost.conectar;
  end;
  Inc(conexiones);
end;

procedure TTAcreedorDeudor.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  Dec(conexiones);
  if conexiones = 0 then Begin
    datosdb.closeDB(tperso);
    datosdb.closeDB(tabla2);
    cpost.desconectar;
  end;
end;

procedure TTAcreedorDeudor.List_linea(salida: char);
// Objetivo...: Listar una Línea
begin
  {if cpost.Buscar(tperso.FieldByName('cp').AsString, tperso.FieldByName('orden').AsString) then cpost.getDatos(tperso.FieldByName('cp').AsString, tperso.FieldByName('orden').AsString);
  tabla2.FindKey([tperso.FieldByName('codcli').AsString]);   // Sincronizamos las tablas
  List.Linea(0, 0, tperso.FieldByName('codcli').AsString + '  ' + tperso.FieldByName('nombre').AsString, 1, 'Arial, normal, 8', salida, 'N');
  List.Linea(40, List.lineactual, tperso.FieldByName('domicilio').AsString, 2, 'Arial, normal, 8', salida, 'N');
  List.Linea(67, List.lineactual, tperso.FieldByName('cp').AsString + ' ' + tperso.FieldByName('orden').AsString + '  ' + cpost.getLocalidad, 3, 'Arial, normal, 8', salida, 'N');
  List.Linea(95, List.lineactual, tabla2.FieldByName('codpfis').AsString, 4, 'Arial, normal, 8', salida, 'S');}
end;

procedure TTAcreedorDeudor.Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
// Objetivo...: Listar Datos de Provincias
begin
  if orden = 'A' then tperso.IndexName := tperso.IndexDefs.Items[1].Name;

  {List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Listado de Clientes', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Cód.  Razón Social', 1, 'Arial, cursiva, 8');
  List.Titulo(40, List.lineactual, 'Domicilio', 2, 'Arial, cursiva, 8');
  List.Titulo(67, List.lineactual, 'CP  Orden   Localidad', 3, 'Arial, cursiva, 8');
  List.Titulo(94, List.lineactual, 'I.V.A.', 4, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  tperso.First;
  while not tperso.EOF do
    begin
      // Ordenado por Código
      if (ent_excl = 'E') and (orden = 'C') then
        if (tperso.FieldByName('codcli').AsString >= iniciar) and (tperso.FieldByName('codcli').AsString <= finalizar) then List_linea(salida);
      if (ent_excl = 'X') and (orden = 'C') then
        if (tperso.FieldByName('codcli').AsString < iniciar) or (tperso.FieldByName('codcli').AsString > finalizar) then List_linea(salida);
      // Ordenado Alfabéticamente
      if (ent_excl = 'E') and (orden = 'A') then
        if (tperso.FieldByName('nombre').AsString >= iniciar) and (tperso.FieldByName('nombre').AsString <= finalizar) then List_linea(salida);
      if (ent_excl = 'X') and (orden = 'A') then
        if (tperso.FieldByName('nombre').AsString < iniciar) or (tperso.FieldByName('nombre').AsString > finalizar) then List_linea(salida);

      tperso.Next;
    end;
    List.FinList;

    tperso.IndexFieldNames := tperso.IndexFieldNames;
    tperso.First;}
end;

{===============================================================================}

function acrdeu: TTAcreedorDeudor;
begin
  if xacrdeu = nil then
    xacrdeu := TTAcreedorDeudor.Create('', '', '', '', '', '', '', '', '', '', '', 0, 0, 0);
  Result := xacrdeu;
end;

{===============================================================================}

initialization

finalization
  xacrdeu.Free;

end.
