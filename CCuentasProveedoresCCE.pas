unit CCuentasProveedoresCCE;

interface

uses CBDT, SysUtils, DBTables, CUtiles, CListar, CIDBFM, CCProveedoresCCE,
     CCuentasTransferenciasCCE;

type

TTCtaProveedores = class(TTCtaTransferencias)
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  procedure   Listar(salida: char);

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
end;

function cuentaproveedor: TTCtaProveedores;

implementation

var
  xcuentaproveedor: TTCtaProveedores = nil;

constructor TTCtaProveedores.Create;
begin
  tabla := datosdb.openDB('ctasproveedores', '');
end;

destructor TTCtaProveedores.Destroy;
begin
  inherited Destroy;
end;

procedure TTCtaProveedores.Listar(salida: char);
// Objetivo...: Listar Datos de Provincias
var
  idanter: String;

  procedure ListLinea(salida: char);
  Begin
    if tabla.FieldByName('codigo').AsString <> idanter then Begin
      proveedor.getDatos(tabla.FieldByName('codigo').AsString);
      if Length(Trim(idanter)) > 0 then List.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S');
      List.Linea(0, 0, 'Proveedor: ' + proveedor.codigo + ' - ' + proveedor.nombre, 1, 'Arial, negrita, 9', salida, 'S');
      idanter := tabla.FieldByName('codigo').AsString;
    end;
    List.Linea(0, 0, '  ' + tabla.FieldByName('nrocuenta').AsString, 1, 'Arial, normal, 8', salida, 'N');
    List.Linea(12, list.Lineactual, tabla.FieldByName('descrip').AsString, 2, 'Arial, normal, 8', salida, 'S');
  end;

begin
  list.Setear(salida);
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Listado de Cuentas Transferibles de Proveedores', 1, 'Arial, negrita, 14');
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

procedure TTCtaProveedores.conectar;
// Objetivo...: cerrar tablas de persistencia
begin
  proveedor.conectar;
  inherited conectar;
end;

procedure TTCtaProveedores.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  proveedor.desconectar;
  inherited desconectar;
end;

{===============================================================================}

function cuentaproveedor: TTCtaProveedores;
begin
  if xcuentaproveedor = nil then
    xcuentaproveedor := TTCtaProveedores.Create;
  Result := xcuentaproveedor;
end;

{===============================================================================}

initialization

finalization
  xcuentaproveedor.Free;

end.
