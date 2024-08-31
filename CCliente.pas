unit CCliente;

interface

uses CBDT, CPersona, CTPFiscal, CCodpost, SysUtils, DB, DBTables, CUtiles, CListar, CIDBFM;

type

TTCliente = class(TTPersona)          // Clase TVendedor Heredada de Persona
  atresp, domcob, telcom, telcob, telalt, codpfis, nrocuit, email, descodpfis: string;
  Existe: boolean;
  tabla2: TTable;         // Tablas para la Persistencia de Objetos
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  procedure   Grabar(xcodigo, xnombre, xdomicilio, xcp, xorden, xatresp, xdomcob, xtelcom, xtelcob, xtelalt, xcodpfis, xnrocuit, xemail: string);
  function    Borrar(xcodigo: string): string;
  function    Buscar(xcodigo: string): boolean;
  procedure   getDatos(xcodigo: string);

  function    VerificarCodpfis(cpf: string): boolean;
  procedure   Listar(orden, iniciar, finalizar, ent_excl: string; xsalida: char);
  function    setClientesAlf: TQuery;
  procedure   BuscarPorCodigo(xexpr: string);
  procedure   BuscarPorNombre(xexpr: string);
  procedure   BuscarPorDireccion(xexpr: string);

  procedure   Via(xvia: string);
  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  conexiones: shortint; path: string; lineas, LineasPag, pag: Integer; l: String;
  procedure   List_linea(salida: char);
  function    ControlarSalto: boolean;
  procedure   CompletarPagina;
  procedure   Titulo;
end;

function cliente: TTCliente;

implementation

var
  xcliente: TTCliente = nil;

constructor TTCliente.Create;
// Vendedor - Heredada de Persona
begin
  inherited Create('', '', '', '', '');  // Constructor de la Superclase
  LineasPag := 70;
end;

destructor TTCliente.Destroy;
begin
  inherited Destroy;
end;

procedure TTCliente.Grabar(xcodigo, xnombre, xdomicilio, xcp, xorden, xatresp, xdomcob, xtelcom, xtelcob, xtelalt, xcodpfis, xnrocuit, xemail: string);
// Objetivo...: Grabar Atributos de Vendedores
begin
  if Buscar(xcodigo) then tabla2.Edit else tabla2.Append;
  tabla2.FieldByName('codcli').AsString  := xcodigo;
  if xatresp <> '' then tabla2.FieldByName('atresp').AsString  := xatresp;
  if xdomcob <> '' then tabla2.FieldByName('domcob').AsString  := xdomcob;
  if xtelcom <> '' then tabla2.FieldByName('telcom').AsString  := xtelcom;
  if xtelcob <> '' then tabla2.FieldByName('telcob').AsString  := xtelcob;
  if xtelalt <> '' then tabla2.FieldByName('telalt').AsString  := xtelalt;
  if xemail  <> '' then tabla2.FieldByName('email').AsString   := xemail;
  tabla2.FieldByName('codpfis').AsString := xcodpfis;
  tabla2.FieldByName('nrocuit').AsString := xnrocuit;
  tabla2.Post;
  // Actualizamos los Atributos de la Clase Persona
  inherited Grabar(xcodigo, xnombre, xdomicilio, xcp, xorden);  //* Metodo de la Superclase
end;

procedure  TTCliente.getDatos(xcodigo: string);
// Objetivo...: Obtener/Inicializar los Atributos para un objeto Vendedor
begin
  tabla2.Refresh;
  if tperso.IndexFieldNames <> 'Codcli' then tperso.IndexFieldNames := 'Codcli';
  if Buscar(xcodigo) then Begin
    atresp  := tabla2.FieldByName('atresp').AsString;
    domcob  := tabla2.FieldByName('domcob').AsString;
    telcom  := tabla2.FieldByName('telcom').AsString;
    telcob  := tabla2.FieldByName('telcob').AsString;
    telalt  := tabla2.FieldByName('telalt').AsString;
    codpfis := tabla2.FieldByName('codpfis').AsString;
    nrocuit := tabla2.FieldByName('nrocuit').AsString;
    email   := tabla2.FieldByName('email').AsString;

    tcpfiscal.getDatos(codpfis);   // Instanciamos los Atributos del tipo de Condición Fiscal
    descodpfis := tcpfiscal.Descrip;
    if Length(Trim(nrocuit)) < 13 then nrocuit := '00-00000000-0';
  end else Begin
    atresp := ''; domcob := ''; telcom := ''; telcob := ''; telalt := ''; codpfis := ''; nrocuit := ''; email := ''; descodpfis := '';
  end;
  inherited getDatos(xcodigo);  // Heredamos de la Superclase
end;

function TTCliente.Borrar(xcodigo: string): string;
// Objetivo...: Eliminar un Instancia de Vendedor
begin
  try
    if Buscar(xcodigo) then
      begin
        inherited Borrar(xcodigo);  // Metodo de la Superclase Persona
        tabla2.Delete;
        getDatos(tabla2.FieldByName('codcli').AsString);  // Fijamos los Atributos Siguientes al Objeto Borrado
      end;
  except
  end;
end;

function TTCliente.Buscar(xcodigo: string): boolean;
// Objetivo...: Verificar si Existe el Vendedor
begin
  if not (tperso.Active) or not (tabla2.Active) then conectar;
  if tperso.IndexFieldNames <> 'Codcli' then tperso.IndexFieldNames := 'Codcli';
  if tabla2.FieldByName('codcli').AsString = xcodigo then Existe := True else Begin
    inherited Buscar(xcodigo);  // Método de la Superclase (Sincroniza los Valores de las Tablas)
    if tabla2.FindKey([xcodigo]) then Existe := True else Existe := False;
  end;
  Result := Existe;
end;

function TTCliente.VerificarCodpfis(cpf: string): boolean;
begin
  if tcpfiscal.Buscar(cpf) then
    begin
      tcpfiscal.getDatos(cpf);   // Instanciamos los Atributos del tipo de Condición Fiscal
      descodpfis := tcpfiscal.Descrip;
      Result := True;
    end
  else Result := False;
end;

procedure TTCliente.List_linea(salida: char);
// Objetivo...: Listar una Línea
begin
  if cpost.Buscar(tperso.FieldByName('cp').AsString, tperso.FieldByName('orden').AsString) then cpost.getDatos(tperso.FieldByName('cp').AsString, tperso.FieldByName('orden').AsString);
  tabla2.FindKey([tperso.FieldByName('codcli').AsString]);   // Sincronizamos las tablas
  if salida <> 'T' then Begin
    List.Linea(0, 0, tperso.FieldByName('codcli').AsString + '  ' + tperso.Fields[1].AsString, 1, 'Arial, normal, 8', salida, 'N');
    List.Linea(37, List.lineactual, tperso.Fields[2].AsString, 2, 'Arial, normal, 8', salida, 'N');
    List.Linea(60, List.lineactual, tabla2.FieldByName('nrocuit').AsString, 3, 'Arial, normal, 8', salida, 'N');
    List.Linea(72, List.lineactual, tperso.FieldByName('cp').AsString + ' ' + tperso.FieldByName('orden').AsString + '  ' + cpost.Localidad, 4, 'Arial, normal, 8', salida, 'N');
    List.Linea(97, List.lineactual, tabla2.FieldByName('codpfis').AsString, 5, 'Arial, normal, 8', salida, 'S');
  end else Begin
    list.LineaTxt(tperso.FieldByName('codcli').AsString + '  ' + tperso.Fields[1].AsString + utiles.espacios(32 - Length(TrimLeft(tperso.Fields[1].AsString))) + tabla2.FieldByName('nrocuit').AsString + utiles.espacios(14 - Length(tabla2.FieldByName('nrocuit').AsString)) + tperso.Fields[2].AsString + utiles.espacios(32 - Length(TrimLeft(tperso.Fields[2].AsString))) +  tperso.FieldByName('cp').AsString + '  ' + cpost.localidad + utiles.espacios(22 - Length(TrimLeft(cpost.localidad))) + ' ' + tabla2.FieldByName('codpfis').AsString, True); Inc(lineas); if controlarSalto then Titulo;
  end;
end;

procedure TTCliente.Listar(orden, iniciar, finalizar, ent_excl: string; xsalida: char);
// Objetivo...: Listar Datos de Provincias
var
  salida: Char;
begin
  salida := xsalida;
  if salida = 'I' then
    if list.ImpresionModoTexto then salida := 'T';

  if orden = 'A' then tperso.IndexFieldNames := 'Nombre';

  if salida <> 'T' then Begin
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
    List.Titulo(0, 0, ' Listado de Clientes', 1, 'Arial, negrita, 14');
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
    List.Titulo(0, 0, 'Cód.  Razón Social', 1, 'Arial, cursiva, 8');
    List.Titulo(37, List.lineactual, 'Domicilio', 2, 'Arial, cursiva, 8');
    List.Titulo(61, List.lineactual, 'Nº C.U.I.T.', 3, 'Arial, cursiva, 8');
    List.Titulo(72, List.lineactual, 'CP  Orden   Localidad', 4, 'Arial, cursiva, 8');
    List.Titulo(96, List.lineactual, 'I.V.A.', 5, 'Arial, cursiva, 8');
    List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');
  end else Begin
    pag := 0;
    list.IniciarImpresionModoTexto;
    Titulo;
  end;

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
        if (tperso.Fields[1].AsString >= iniciar) and (tperso.Fields[1].AsString <= finalizar) then List_linea(salida);
      if (ent_excl = 'X') and (orden = 'A') then
        if (tperso.Fields[1].AsString < iniciar) or (tperso.Fields[1].AsString > finalizar) then List_linea(salida);

      tperso.Next;
    end;
    if salida <> 'T' then List.FinList else Begin
      CompletarPagina;
      list.FinalizarImpresionModoTexto(1);
    end;

    tperso.IndexFieldNames := 'Codcli';
    tperso.First;
end;

procedure TTCliente.Titulo;
// Objetivo...: Titulo para la impresion en modo texto
begin
    Inc(pag);
    List.LineaTxt(CHR(18), True);
    List.LineaTxt('Listado de Clientes                                   Hoja: ' + utiles.sLlenarIzquierda(IntToStr(pag), 4, '0'), True);
    List.LineaTxt(CHR(15), True);
    List.LineaTxt('Cod.  Razon Social                    Nro. C.U.I.T. Domicilio                        CP   Localidad            I.V.A.' + CHR(18), True);
    list.LineaTxt(utiles.sLlenarIzquierda(l, 80, CHR(196)) + CHR(15), True);
    lineas := 5;
end;

function TTCliente.setClientesAlf: TQuery;
// Objetivo...: Devolver un set de registros con los clientes ordenados alfabeticamente
begin
  Result := datosdb.tranSQL(path, 'SELECT * FROM ' + tperso.TableName + ' ORDER BY nombre');
end;

procedure TTCliente.BuscarPorCodigo(xexpr: string);
// Objetivo...: buscar cliente por código
begin
  if tperso.IndexFieldNames <> 'Codcli' then tperso.IndexFieldNames := 'Codcli';
  tperso.FindNearest([xexpr]);
end;

procedure TTCliente.BuscarPorNombre(xexpr: string);
// Objetivo...: buscar por nombre
begin
  if tperso.IndexFieldNames <> 'Nombre' then tperso.IndexFieldNames := 'Nombre';
  tperso.FindNearest([xexpr]);
end;

procedure TTCliente.BuscarPorDireccion(xexpr: string);
// Objetivo...: buscar por nombre
begin
  if tperso.IndexFieldNames <> 'Direccion' then tperso.IndexFieldNames := 'Direccion';
  tperso.FindNearest([xexpr]);
end;

procedure TTCliente.Via(xvia: string);
// Objetivo...: conectar tablas de persistencia
begin
  tperso := nil; tabla2 := nil;
  tperso := datosdb.openDB('clientes', 'Codcli', '', dbs.dirSistema + '\' + xvia);
  tabla2 := datosdb.openDB('clienteh', 'Codcli', '', dbs.dirSistema + '\' + xvia);
  path := dbs.dirSistema + '\' + xvia;
  tperso.Open; tabla2.Open;
end;

function TTCliente.ControlarSalto: boolean;
// Objetivo...: salto de linea para las impresiones basadas en texto
begin
  LineasPag := list.AltoPagTxt;
  Result := False;
  if lineas > LineasPag then Begin
    list.LineaTxt(CHR(18) + utiles.sLlenarIzquierda(l, 80, CHR(196)), True);
    list.LineaTxt(CHR(12), True);
    Result := True;
  end;
end;

procedure TTCliente.CompletarPagina;
var
  i: integer;
begin
  For i := lineas to LineasPag do list.LineaTxt('  ', True);
  list.LineaTxt(CHR(18) + utiles.sLlenarIzquierda(l, 80, CHR(196)), True);
end;

procedure TTCliente.conectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones = 0 then Begin
    if not tperso.Active then tperso.Open;
    tperso.FieldByName('codcli').DisplayLabel := 'Código'; {tperso.FieldByName('cp').Visible := False; tperso.FieldByName('orden').Visible := False;}
    tperso.FieldByName('nombre').DisplayLabel := 'Nombre o Razón Social'; tperso.FieldByName('orden').DisplayLabel := 'Orden';{tperso.FieldByName('domicilio').DisplayLabel := 'Dirección';}
    if not tabla2.Active then tabla2.Open;
  end;
  cpost.conectar;
  tcpfiscal.conectar;
  Inc(conexiones);
end;

procedure TTCliente.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones > 0 then Dec(conexiones);
  if conexiones = 0 then Begin
    datosdb.closeDB(tperso);
    datosdb.closeDB(tabla2);
  end;
  cpost.desconectar;
  tcpfiscal.desconectar;
end;

{===============================================================================}

function cliente: TTCliente;
begin
  if xcliente = nil then
    xcliente := TTCliente.Create;
  Result := xcliente;
end;

{===============================================================================}

initialization

finalization
  xcliente.Free;

end.
