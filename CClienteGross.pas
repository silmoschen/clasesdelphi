unit CClienteGross;

interface

uses CBDT, CCliente, SysUtils, DB, DBTables, CUtiles, CIDBFM, Classes, CListar, CCodPost;

type

TTClienteGross = class(TTCliente)
  Nrodoc, Fechanac, Tarjeta, Abonado: string;
  Abono: String; Monto, Descuento: Real;    // Atributos de los montos de abonos de socios
  CantidadDeMascotas, troquelespag, septroqueles, altoPag: Integer;
  tabonos, mesesabonados: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  procedure   Grabar(xcodigo, xnombre, xdomicilio, xcp, xorden, xatresp, xdomcob, xtelcom, xtelcob, xtelalt, xcodpfis, xnrocuit, xemail, xabonado: string; xcantmascotas: Integer);
  procedure   getDatos(xcodigo: string);

  { Manejo de Abonos }
  function    BuscarAbono(xabono: String): Boolean;
  procedure   GuardarAbono(xabono: String; xmonto: Real);
  procedure   BorrarAbono(xabono: String);
  procedure   getDatosAbono(xabono: String);
  procedure   RegistrarMesAbono(xcodcli, xanio, xmes, xabona: String);
  function    setMesesAbonados(xcodcli, xanio: String): TQuery;

  function    setClientesAbonados: TQuery;
  function    setClientesAbonadosAlf: TQuery;
  procedure   ListarTroquel(lista: TStringList; xperiodo: String; salida: char);
  procedure   ListarNominaDeAbonados(lista: TStringList; xperiodo: String; salida, xorden: char);

  procedure   desconectar;
  procedure   conectar;
 private
  { Declaraciones Privadas }
  conexiones: shortint;
end;

function cliente: TTClienteGross;

implementation

var
  xcliente: TTClienteGross = nil;

constructor TTClienteGross.Create;
begin
  inherited Create;
  tperso        := datosdb.openDB('clientes', 'Codcli');
  tabla2        := datosdb.openDB('clienteh', 'Codcli');
  tabonos       := datosdb.openDB('abonos', '');
  mesesabonados := datosdb.openDB('mesesabonados', '');
end;

destructor TTClienteGross.Destroy;
begin
  inherited Destroy;
end;

procedure TTClienteGross.Grabar(xcodigo, xnombre, xdomicilio, xcp, xorden, xatresp, xdomcob, xtelcom, xtelcob, xtelalt, xcodpfis, xnrocuit, xemail, xabonado: string; xcantmascotas: Integer);
begin
  inherited Grabar(xcodigo, xnombre, xdomicilio, xcp, xorden, xatresp, xdomcob, xtelcom, xtelcob, xtelalt, xcodpfis, xnrocuit, xemail);
  tabla2.Edit;
  tabla2.FieldByName('abonado').AsString       := xabonado;
  tabla2.FieldByName('cantmascotas').AsInteger := xcantmascotas;
  try
    tabla2.Post
   except
    tabla2.Cancel
  end;
end;

procedure TTClienteGross.getDatos(xcodigo: string);
begin
  inherited getDatos(xcodigo);
  if Existe then Begin
    abonado            := tabla2.FieldByName('abonado').AsString;
    CantidadDeMascotas := tabla2.FieldByName('cantmascotas').AsInteger;
  end else Begin
    abonado := ''; CantidadDeMascotas := 0;
  end;
  getDatosAbono(utiles.sLlenarIzquierda(IntToStr(CantidadDeMascotas), 2, '0'));
end;

function TTClienteGross.BuscarAbono(xabono: String): Boolean;
Begin
  Result := tabonos.FindKey([xabono]);
end;

procedure TTClienteGross.GuardarAbono(xabono: String; xmonto: Real);
Begin
  if BuscarAbono(xabono) then tabonos.Edit else tabonos.Append;
  tabonos.FieldByName('abono').AsString := xabono;
  tabonos.FieldByName('monto').AsFloat  := xmonto;
  try
    tabonos.Post
   except
    tabonos.Cancel
  end;
end;

procedure TTClienteGross.BorrarAbono(xabono: String);
Begin
  if BuscarAbono(xabono) then tabonos.Delete;
end;

procedure TTClienteGross.getDatosAbono(xabono: String);
Begin
  if BuscarAbono(xabono) then Begin
    Monto := tabonos.FieldByName('monto').AsFloat;
  end else Begin
    if StrToInt(xabono) = 0 then Monto := 0 else Begin
      tabonos.Last;
      Monto := tabonos.FieldByName('monto').AsFloat;
    end;
  end;
end;

procedure TTClienteGross.RegistrarMesAbono(xcodcli, xanio, xmes, xabona: String);
// Objetivo...: Registrar mes de abono
Begin
  if datosdb.Buscar(mesesabonados, 'codcli', 'anio', 'mes', xcodcli, xanio, xmes) then mesesabonados.Edit else mesesabonados.Append;
  mesesabonados.FieldByName('codcli').AsString := xcodcli;
  mesesabonados.FieldByName('anio').AsString   := xanio;
  mesesabonados.FieldByName('mes').AsString    := xmes;
  mesesabonados.FieldByName('estado').AsString := xabona;
  try
    mesesabonados.Post
   except
    mesesabonados.Cancel
  end;
end;

function  TTClienteGross.setMesesAbonados(xcodcli, xanio: String): TQuery;
// Objetivo...: devolver meses abonados
Begin
  Result := datosdb.tranSQL('SELECT * FROM mesesabonados WHERE codcli = ' + '"' + xcodcli + '"' + ' AND anio = ' + '"' + xanio + '"');
end;

function  TTClienteGross.setClientesAbonados: TQuery;
// Objetivo...: devolver clientes abonados
Begin
  Result := datosdb.tranSQL('SELECT clientes.nombre, clientes.codcli FROM clientes, clienteh WHERE clientes.codcli = clienteh.codcli and clienteh.abonado = ' + '"' + 'S' + '"' + ' order by codcli');
end;

function  TTClienteGross.setClientesAbonadosAlf: TQuery;
// Objetivo...: devolver clientes abonados
Begin
  Result := datosdb.tranSQL('SELECT clientes.nombre, clientes.codcli FROM clientes, clienteh WHERE clientes.codcli = clienteh.codcli and clienteh.abonado = ' + '"' + 'S' + '"' + ' order by nombre');
end;

procedure TTClienteGross.ListarTroquel(lista: TStringList; xperiodo: String; salida: char);
var
  i, j, lineas, k: Integer;
Begin
  if salida <> 'T' then Begin
    list.Setear(salida);
    list.Linea(0, 0, '', 1, 'Arial, negrita, 12', salida, 'S');
  end else Begin
    list.IniciarImpresionModoTexto;
    list.LineaTxt(CHR(18), True);
  end;

  tperso.First; i := 0; lineas := 0;
  while not tperso.Eof do Begin
    if utiles.verificarItemsLista(lista, tperso.FieldByName('codcli').AsString) then Begin
      tabla2.FindKey([tperso.FieldByName('codcli').AsString]);
      CantidadDeMascotas := tabla2.FieldByName('cantmascotas').AsInteger;
      getDatosAbono(utiles.sLlenarIzquierda(IntToStr(tabla2.FieldByName('cantmascotas').AsInteger), 2, '0'));
      if salida <> 'T' then Begin
        list.Linea(0, 0, '------------------------------------------------------', 1, 'Arial, normal, 8', salida, 'N');
        list.Linea(55, list.Lineactual, '-----------------------------------------------------', 2, 'Arial, normal, 8', salida, 'S');
        list.Linea(0, 0, '     VETERINARIA GROSS', 1, 'Arial, normal, 8', salida, 'N');
        list.Linea(55, list.Lineactual, '     VETERINARIA GROSS', 2, 'Arial, normal, 8', salida, 'S');
        list.Linea(0, 0, '     Abono Mensual', 1, 'Arial, normal, 8', salida, 'N');
        list.Linea(55, list.Lineactual, '     Abono Mensual', 2, 'Arial, normal, 8', salida, 'S');
        list.Linea(0, 0, '------------------------------------------------------', 1, 'Arial, normal, 8', salida, 'N');
        list.Linea(55, list.Lineactual, '-----------------------------------------------------', 2, 'Arial, normal, 8', salida, 'S');
        list.Linea(0, 0, tperso.FieldByName('codcli').AsString + '    ' + tperso.FieldByName('nombre').AsString, 1, 'Arial, normal, 8', salida, 'N');
        list.Linea(55, list.Lineactual, tperso.FieldByName('codcli').AsString + '    ' + tperso.FieldByName('nombre').AsString, 2, 'Arial, normal, 8', salida, 'S');
        list.Linea(0, 0, 'Mes:  ' + utiles.setMes(StrToInt(Copy(xperiodo, 1, 2))) + '  ' + Copy(xperiodo, 4, 4), 1, 'Arial, normal, 8', salida, 'N');
        list.Linea(55, list.Lineactual, 'Mes:  ' + utiles.setMes(StrToInt(Copy(xperiodo, 1, 2))) + '  ' + Copy(xperiodo, 4, 4), 2, 'Arial, normal, 8', salida, 'S');
        list.Linea(0, 0, 'Cantidad:  ' + IntToStr(CantidadDeMascotas), 1, 'Arial, normal, 8', salida, 'N');
        list.Linea(55, list.Lineactual, 'Cantidad:  ' + IntToStr(tabla2.FieldByName('cantmascotas').AsInteger), 2, 'Arial, normal, 8', salida, 'S');
        list.Linea(0, 0, 'Monto:  ' + utiles.FormatearNumero(FloatToStr(Monto)), 1, 'Arial, normal, 8', salida, 'N');
        list.Linea(55, list.Lineactual, 'Monto:  ' + utiles.FormatearNumero(FloatToStr(Monto)), 2, 'Arial, normal, 8', salida, 'S');
        list.Linea(0, 0, ' ', 1, 'Arial, normal, 8', salida, 'S');
        list.Linea(0, 0, 'p/Veterinaria', 1, 'Arial, normal, 8', salida, 'N');
        list.Linea(55, list.Lineactual, 'p/Abonado', 2, 'Arial, normal, 8', salida, 'S');
        list.Linea(0, 0, '------------------------------------------------------', 1, 'Arial, normal, 8', salida, 'N');
        list.Linea(55, list.Lineactual, '-----------------------------------------------------', 2, 'Arial, normal, 8', salida, 'S');
      end else Begin
        list.LineaTxt('-----------------------------------     ------------------------------------', True); Inc(lineas);
        list.LineaTxt('       VETERINARIA GROSS                         VETERINARIA GROSS', True); Inc(lineas);
        list.LineaTxt('         Abono Mensual                             Abono Mensual', True); Inc(lineas);
        list.LineaTxt('-----------------------------------     ------------------------------------', True);
        list.LineaTxt(tperso.FieldByName('codcli').AsString + ' ' + TrimRight(tperso.FieldByName('nombre').AsString) +
          utiles.espacios(40 - Length(tperso.FieldByName('codcli').AsString + ' ' + TrimRight(tperso.FieldByName('nombre').AsString))) + tperso.FieldByName('codcli').AsString + ' ' + TrimRight(tperso.FieldByName('nombre').AsString), True); Inc(lineas);
        list.LineaTxt('Mes:  ' + utiles.setMes(StrToInt(Copy(xperiodo, 1, 2))) + '  ' + Copy(xperiodo, 4, 4) + utiles.espacios(40 - Length('Mes:  ' + utiles.setMes(StrToInt(Copy(xperiodo, 1, 2))) + '  ' + Copy(xperiodo, 4, 4))) + 'Mes:  ' + utiles.setMes(StrToInt(Copy(xperiodo, 1, 2))) + '  ' + Copy(xperiodo, 4, 4), True); Inc(lineas);
        list.LineaTxt('Cantidad:  ' + IntToStr(tabla2.FieldByName('cantmascotas').AsInteger) + utiles.espacios(40 - Length('Cantidad:  ' + IntToStr(tabla2.FieldByName('cantmascotas').AsInteger))) + 'Cantidad:  ' + IntToStr(tabla2.FieldByName('cantmascotas').AsInteger), True); Inc(lineas);
        list.LineaTxt('Monto:  ' + utiles.FormatearNumero(FloatToStr(Monto)) + utiles.espacios(40 - Length('Monto:  ' + utiles.FormatearNumero(FloatToStr(Monto)))) + 'Monto:  ' + utiles.FormatearNumero(FloatToStr(Monto)), True); Inc(lineas);
        list.LineaTxt('', True); Inc(lineas);
        list.LineaTxt('p/Veterinaria                           p/Abonado', True); Inc(lineas);
        list.LineaTxt('-----------------------------------     ------------------------------------', True); Inc(lineas);
      end;

      Inc(i);
      if i >= troquelespag then Begin
        i := 0;
        if salida <> 'T' then list.CompletarPagina else Begin
          for k := 1 to (altoPag - lineas) do list.LineaTxt('', True);
          lineas := 0;
        end;
      end else Begin
        for j := 1 to septroqueles do
          if salida <> 'T' then list.Linea(0, 0, ' ', 1, 'Arial, normal, 8', salida, 'S') else Begin
            list.LineaTxt('', True);
            Inc(lineas);
          end;
      end;

    end;

    tperso.Next;
  end;


  if salida <> 'T' then list.FinList else list.FinalizarImpresionModoTexto(1);
end;

procedure TTClienteGross.ListarNominaDeAbonados(lista: TStringList; xperiodo: String; salida, xorden: char);
var
  indice: String;
Begin
  list.Setear(salida);
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Listado de Abonados', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Cód.  Razón Social', 1, 'Arial, cursiva, 8');
  List.Titulo(37, List.lineactual, 'Domicilio', 2, 'Arial, cursiva, 8');
  List.Titulo(61, List.lineactual, 'Nº C.U.I.T.', 3, 'Arial, cursiva, 8');
  List.Titulo(72, List.lineactual, 'CP  Orden   Localidad', 4, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  indice := tperso.IndexFieldNames;
  if xorden = 'A' then tperso.IndexFieldNames := 'Nombre' else tperso.IndexFieldNames := 'Codcli';
  tperso.First;
  while not tperso.Eof do Begin
    if utiles.verificarItemsLista(lista, tperso.FieldByName('codcli').AsString) then Begin
      cpost.getDatos(tperso.FieldByName('cp').AsString, tperso.FieldByName('orden').AsString);
      tabla2.FindKey([tperso.FieldByName('codcli').AsString]);
      List.Linea(0, 0, tperso.FieldByName('codcli').AsString + '  ' + tperso.Fields[1].AsString, 1, 'Arial, normal, 8', salida, 'N');
      List.Linea(37, List.lineactual, tperso.Fields[2].AsString, 2, 'Arial, normal, 8', salida, 'N');
      List.Linea(60, List.lineactual, tabla2.FieldByName('nrocuit').AsString, 3, 'Arial, normal, 8', salida, 'N');
      List.Linea(72, List.lineactual, tperso.FieldByName('cp').AsString + ' ' + tperso.FieldByName('orden').AsString + '  ' + cpost.Localidad, 4, 'Arial, normal, 8', salida, 'S');
    end;
    tperso.Next;
  end;

  tperso.IndexFieldNames := indice;
  list.FinList;
end;

procedure TTClienteGross.conectar;
// Objetivo...: Abrir las tablas de persistencia
begin
  inherited conectar;
  if conexiones = 0 then Begin
    if not tabonos.Active then tabonos.Open;
    if not mesesabonados.Active then mesesabonados.Open;
  end;
  Inc(conexiones);
end;

procedure TTClienteGross.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  inherited desconectar;
  if conexiones > 0 then Dec(conexiones);
  if conexiones = 0 then Begin
    datosdb.closeDB(tabonos);
    datosdb.closeDB(mesesabonados);
  end;
end;

{===============================================================================}

function cliente: TTClienteGross;
begin
  if xcliente = nil then
    xcliente := TTClienteGross.Create;
  Result := xcliente;
end;

{===============================================================================}

initialization

finalization
  xcliente.Free;

end.