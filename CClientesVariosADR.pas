unit CClientesVariosADR;

interface

uses CPersona, CTPFiscal, CCodPost, CListar, CUtiles, SysUtils, DB, DBTables, CBDT, CIDBFM,
     Classes;

type

TTClientesVariosADR = class(TTPersona)          // Clase TVendedor Heredada de Persona
  telefono, nrocuit, codpfis, email: string;
  descodpfis : string;
  tprove     : TTable;         // Tablas para la Persistencia de Objetos
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;
  procedure   Grabar(xcodigo, xnombre, xdomicilio, xcp, xorden, xatencion, xtelefono, xnrocuit, xcodpfis, xemail: string);
  function    Borrar(cod: string): string;
  function    Buscar(cod: string): boolean;
  procedure   getDatos(cod: string);
  function    Nuevo: string;
  function    VerificarCodpfis(cpf: string): boolean;
  procedure   Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
  function    setClientesVariosAlf: TQuery;

  procedure   BuscarPorCodigo(xexpr: string);
  procedure   BuscarPorNombre(xexpr: string);

  function    setClientes: TStringList;
  function    setLocalidades: TStringList;

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  conexiones: shortint; path: string;
  procedure   List_linea(salida: char);
end;

function clientesvarios: TTClientesVariosADR;

implementation

var
  xclientesvarios: TTClientesVariosADR = nil;

constructor TTClientesVariosADR.Create;
// Vendedor - Heredada de Persona
begin
  inherited Create('','', '', '', '');
  tperso := datosdb.openDB('clientvarios', '');
  tprove := datosdb.openDB('clientvariosh', '');
end;

destructor TTClientesVariosADR.Destroy;
begin
  inherited Destroy;
end;

procedure TTClientesVariosADR.Grabar(xcodigo, xnombre, xdomicilio, xcp, xorden, xatencion, xtelefono, xnrocuit, xcodpfis, xemail: string);
// Objetivo...: Grabar Atributos del Proveedor
begin
  if Buscar(xcodigo) then tprove.Edit else tprove.Append;
  tprove.FieldByName('codprov').AsString := xcodigo;
  if Length(trim(xtelefono)) > 0 then tprove.FieldByName('telefono').AsString  := xtelefono;
  if Length(trim(xemail))     > 0 then tprove.FieldByName('email').AsString      := xemail;
  tprove.FieldByName('nrocuit').AsString := xnrocuit;
  tprove.FieldByName('codpfis').AsString := xcodpfis;
  tprove.Post;
  // Actualizamos los Atributos de la Clase Persona
  inherited Grabar(xcodigo, xnombre, xdomicilio, xcp, xorden);  //* Metodo de la Superclase
end;

procedure  TTClientesVariosADR.getDatos(cod: string);
// Objetivo...: Obtener/Inicializar los Atributos para un objeto Proveedor
begin
  if Buscar(cod) then begin
    telefono := tprove.FieldByName('telefono').AsString;
    nrocuit   := tprove.FieldByName('nrocuit').AsString;
    codpfis   := tprove.FieldByName('codpfis').AsString;
    email     := tprove.FieldByName('email').AsString;
    tcpfiscal.getDatos(codpfis);   // Instanciamos los Atributos del tipo de Condición Fiscal
    descodpfis := tcpfiscal.Descrip;
  end else begin
    telefono := ''; nrocuit := ''; codpfis := ''; email := '';
  end;
  inherited getDatos(cod);  // Heredamos de la Superclase}
  if Length(Trim(nrocuit)) < 13 then nrocuit := '00-00000000-0'; 
end;

function TTClientesVariosADR.Borrar(cod: string): string;
// Objetivo...: Eliminar un Instancia de Proveedor
begin
  if Buscar(cod) then begin
    inherited Borrar(cod);  // Metodo de la Superclase Persona
    tprove.Delete;
    getDatos(tprove.FieldByName('codprov').AsString);  // Fijamos los Atributos Siguientes al Objeto Borrado
  end;
end;

function TTClientesVariosADR.Buscar(cod: string): boolean;
// Objetivo...: Verificar si Existe el Proveedor
begin
  if not (tperso.Active) or not (tprove.Active) then conectar;
  if tperso.IndexFieldNames <> 'Codprov' then tperso.IndexFieldNames := 'Codprov';
  inherited Buscar(cod);  // Método de la Superclase (Sincroniza los Valores de las Tablas)
  if tprove.FindKey([cod]) then Result := True else Result := False;
end;

function TTClientesVariosADR.VerificarCodpfis(cpf: string): boolean;
begin
  if tcpfiscal.Buscar(cpf) then begin
    tcpfiscal.getDatos(cpf);   // Instanciamos los Atributos del tipo de Condición Fiscal
    descodpfis := tcpfiscal.Descrip;
    Result := True;
  end else Result := False;
end;

function TTClientesVariosADR.Nuevo: string;
begin
  Result := inherited Nuevo;
end;

procedure TTClientesVariosADR.List_linea(salida: char);
// Objetivo...: Listar una Línea
begin
  if cpost.Buscar(tperso.FieldByName('cp').AsString, tperso.FieldByName('orden').AsString) then cpost.getDatos(tperso.FieldByName('cp').AsString, tperso.FieldByName('orden').AsString);
  tprove.FindKey([tperso.FieldByName('codprov').AsString]);   // Sincronizamos las tablas
  List.Linea(0, 0, tperso.FieldByName('codprov').AsString + '  ' + tperso.FieldByName('nombre').AsString, 1, 'Arial, normal, 8', salida, 'N');
  List.Linea(37, List.lineactual, tperso.Fields[2].AsString, 2, 'Arial, normal, 8', salida, 'N');
  if Length(Trim(tprove.FieldByName('nrocuit').AsString)) > 10 then List.Linea(60, List.lineactual, tprove.FieldByName('nrocuit').AsString, 2, 'Arial, normal, 8', salida, 'N') else
    List.Linea(60, List.lineactual, '', 2, 'Arial, normal, 8', salida, 'N');
  List.Linea(74, List.lineactual, tperso.FieldByName('cp').AsString + ' ' + tperso.FieldByName('orden').AsString + '  ' + cpost.Localidad, 4, 'Arial, normal, 8', salida, 'N');
  List.Linea(100, List.lineactual, tprove.FieldByName('codpfis').AsString, 5, 'Arial, normal, 8', salida, 'S');
end;

procedure TTClientesVariosADR.Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
// Objetivo...: Listar Datos de Provincias
begin
  if orden = 'A' then tperso.IndexName := tperso.IndexDefs.Items[1].Name;

  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Nómina Créditos R.E.C.U.P.R.O.', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Cód.  Razón Social', 1, 'Arial, cursiva, 8');
  List.Titulo(37, List.lineactual, 'Domicilio', 2, 'Arial, cursiva, 8');
  List.Titulo(61, List.lineactual, 'Nº C.U.I.T.', 3, 'Arial, cursiva, 8');
  List.Titulo(74, List.lineactual, 'CP  Orden   Localidad', 4, 'Arial, cursiva, 8');
  List.Titulo(100, List.lineactual, 'IVA', 5, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  tperso.First;
  while not tperso.EOF do
    begin
      // Ordenado por Código
      if (ent_excl = 'E') and (orden = 'C') then
        if (tperso.FieldByName('codprov').AsString >= iniciar) and (tperso.FieldByName('codprov').AsString <= finalizar) then List_linea(salida);
      if (ent_excl = 'X') and (orden = 'C') then
        if (tperso.FieldByName('codprov').AsString < iniciar) or (tperso.FieldByName('codprov').AsString > finalizar) then List_linea(salida);
      // Ordenado Alfabéticamente
      if (ent_excl = 'E') and (orden = 'A') then
        if (tperso.FieldByName('nombre').AsString >= iniciar) and (tperso.FieldByName('nombre').AsString <= finalizar) then List_linea(salida);
      if (ent_excl = 'X') and (orden = 'A') then
        if (tperso.FieldByName('nombre').AsString < iniciar) or (tperso.FieldByName('nombre').AsString > finalizar) then List_linea(salida);

      tperso.Next;
    end;
    List.FinList;

    tperso.IndexFieldNames := tperso.IndexFieldNames;
    tperso.First;
end;

function TTClientesVariosADR.setClientesVariosAlf: TQuery;
// Objetivo...: Devolver un set de proveedores ordenados alfabeticamente
begin
  Result := datosdb.tranSQL(path, 'SELECT * FROM ' + tperso.TableName + ' ORDER BY rsocial');
end;

procedure TTClientesVariosADR.BuscarPorCodigo(xexpr: string);
begin
  tperso.IndexFieldNames := 'Codprov';
  tperso.FindNearest([xexpr]);
end;

procedure TTClientesVariosADR.BuscarPorNombre(xexpr: string);
begin
  tperso.IndexFieldNames := 'Nombre';
  tperso.FindNearest([xexpr]);
end;

function  TTClientesVariosADR.setClientes: TStringList;
var
  l: TStringList;
begin
  l := TStringList.Create;
  tperso.IndexFieldNames := 'Nombre';
  tperso.First;
  while not tperso.Eof do Begin
    l.Add(tperso.FieldByName('codprov').AsString + tperso.FieldByName('nombre').AsString);
    tperso.Next;
  end;
  Result := l;
end;

function  TTClientesVariosADR.setLocalidades: TStringList;
var
  l: TStringList;
  idanter1, idanter2: String;
begin
  l := TStringList.Create;
  tperso.IndexFieldNames := 'cp;orden';
  tperso.First;
  while not tperso.Eof do Begin
    if (tperso.FieldByName('cp').AsString <> idanter1) or (tperso.FieldByName('orden').AsString <> idanter2) then Begin
      if (Length(Trim(idanter1)) > 0) and (Length(Trim(idanter2)) > 0) then Begin
        l.Add(tperso.FieldByName('cp').AsString + tperso.FieldByName('orden').AsString);
      end;
      idanter1 := tperso.FieldByName('cp').AsString;
      idanter2 := tperso.FieldByName('orden').AsString;
    end;
    tperso.Next;
  end;
  tperso.IndexFieldNames := 'codprov';
  Result := l;
end;

procedure TTClientesVariosADR.conectar;
// Objetivo...: conectar tablas de persistencia - soporte multiempresa
begin
  if conexiones = 0 then Begin
    cpost.conectar;
    tcpfiscal.conectar;
    if not tperso.Active then tperso.Open;
    tperso.FieldByName('codprov').DisplayLabel := 'Cód.'; tperso.FieldByName('nombre').DisplayLabel := 'Razón Social'; tperso.FieldByName('cp').DisplayLabel := 'Cód.Post.';
    tperso.FieldByName('direccion').DisplayLabel := 'Dirección'; tperso.FieldByName('orden').DisplayLabel := 'Orden';
    if not tprove.Active then tprove.Open;
  end;
  Inc(conexiones);
end;

procedure TTClientesVariosADR.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones > 0 then Dec(conexiones);
  if conexiones = 0 then Begin
    cpost.desconectar;
    tcpfiscal.desconectar;
    datosdb.closeDB(tperso);
    datosdb.closeDB(tprove);
  end;
end;

{===============================================================================}

function clientesvarios: TTClientesVariosADR;
begin
  if xclientesvarios = nil then
    xclientesvarios := TTClientesVariosADR.Create;
  Result := xclientesvarios;
end;

{===============================================================================}

initialization

finalization
  xclientesvarios.Free;

end.
