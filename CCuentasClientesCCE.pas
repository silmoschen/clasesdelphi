unit CCuentasClientesCCE;

interface

uses CBDT, SysUtils, DBTables, CUtiles, CListar, CIDBFM, CClienteCCE,
     CCuentasTransferenciasCCE;

type

TTCtaClientes = class(TTCtaTransferencias)
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  procedure   Listar(salida: char);

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  conexiones: shortint;
end;

function cuentacliente: TTCtaClientes;

implementation

var
  xcuentacliente: TTCtaClientes = nil;

constructor TTCtaClientes.Create;
begin
  tabla := datosdb.openDB('ctasclientes', '');
end;

destructor TTCtaClientes.Destroy;
begin
  inherited Destroy;
end;

procedure TTCtaClientes.Listar(salida: char);
// Objetivo...: Listar Datos de Provincias
var
  idanter: String;

  procedure ListLinea(salida: char);
  Begin
    if tabla.FieldByName('codigo').AsString <> idanter then Begin
      cliente.getDatos(tabla.FieldByName('codigo').AsString);
      if Length(Trim(idanter)) > 0 then List.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S');
      List.Linea(0, 0, 'Cliente: ' + cliente.codigo + ' - ' + cliente.nombre, 1, 'Arial, negrita, 9', salida, 'S');
      idanter := tabla.FieldByName('codigo').AsString;
    end;
    List.Linea(0, 0, '  ' + tabla.FieldByName('nrocuenta').AsString, 1, 'Arial, normal, 8', salida, 'N');
    List.Linea(12, list.Lineactual, tabla.FieldByName('descrip').AsString, 2, 'Arial, normal, 8', salida, 'S');
  end;

begin
  list.Setear(salida);
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Listado de Cuentas Transferibles de Clientes', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Cuenta', 1, 'Arial, cursiva, 8');
  List.Titulo(12, list.Lineactual, 'Descripción', 2, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  tabla.First;
  while not tabla.EOF do Begin
    ListLinea(salida);
    tabla.Next;
  end;

  tabla.First;

  if Length(Trim(idanter)) = 0 then List.Linea(0, 0, 'No Existen Datos para Listar ...!', 1, 'Arial, normal, 11', salida, 'S');

  List.FinList;
end;

procedure TTCtaClientes.conectar;
// Objetivo...: cerrar tablas de persistencia
begin
  cliente.conectar;
  inherited conectar;
end;

procedure TTCtaClientes.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  cliente.desconectar;
  inherited desconectar;
end;

{===============================================================================}

function cuentacliente: TTCtaClientes;
begin
  if xcuentacliente = nil then
    xcuentacliente := TTCtaClientes.Create;
  Result := xcuentacliente;
end;

{===============================================================================}

initialization

finalization
  xcuentacliente.Free;

end.
