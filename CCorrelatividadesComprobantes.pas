unit CCorrelatividadesComprobantes;

interface

uses CBDT, SysUtils, DBTables, CUtiles, CListar, CIDBFM;

type

TTCorrelatividades = class
  Codcomp, Idcompr, Sucursal, Numero: String;
  tabla: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  function    Buscar(xcodcomp, xidcompr: String): Boolean;
  procedure   Registrar(xcodcomp, xidcompr, xsucursal, xnumero: String);
  procedure   Borrar(xcodcomp, xidcompr: String);
  procedure   getDatos(xcodcomp, xidcompr: String);
  function    setComprobantes: TQuery;

  function    setNroSiguiente(xcodcomp, xidcompr: String): String;
  function    setNroActual(xcodcomp, xidcompr: String): String;
  procedure   ActualizarNumero(xcodcomp, xidcompr, xnroactual: String);

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  conexiones: shortint;
end;

function correlatividad: TTCorrelatividades;

implementation

var
  xcorrelatividad: TTCorrelatividades = nil;

constructor TTCorrelatividades.Create;
begin
  tabla := datosdb.openDB('correlatividades', '');
end;

destructor TTCorrelatividades.Destroy;
begin
  inherited Destroy;
end;

function  TTCorrelatividades.Buscar(xcodcomp, xidcompr: String): Boolean;
// Objetivo...: Buscar Instancia
Begin
  Result := datosdb.Buscar(tabla, 'codcomp', 'idcompr', xcodcomp, xidcompr);
end;

procedure TTCorrelatividades.Registrar(xcodcomp, xidcompr, xsucursal, xnumero: String);
// Objetivo...: Registrar Instancia
Begin
  if Buscar(xcodcomp, xidcompr) then tabla.Edit else tabla.Append;
  tabla.FieldByName('codcomp').AsString   := xcodcomp;
  tabla.FieldByName('idcompr').AsString   := xidcompr;
  tabla.FieldByName('sucursal').AsString  := xsucursal;
  tabla.FieldByName('ultimonro').AsString := xnumero;
  try
    tabla.Post
   except
    tabla.Cancel
  end;
  datosdb.closeDB(tabla); tabla.Open;
end;

procedure TTCorrelatividades.Borrar(xcodcomp, xidcompr: String);
// Objetivo...: Borrar Instancia
Begin
  if Buscar(xcodcomp, xidcompr) then Begin
    tabla.Delete;
    datosdb.closeDB(tabla); tabla.Open;
  end;
end;

procedure TTCorrelatividades.getDatos(xcodcomp, xidcompr: String);
// Objetivo...: Recuperar una instancia
Begin
  if Buscar(xcodcomp, xidcompr) then Begin
    Sucursal := tabla.FieldByName('sucursal').AsString;
    Numero   := tabla.FieldByName('ultimonro').AsString;
  end else Begin
    Sucursal := ''; Numero  := '';
  end;
end;

function  TTCorrelatividades.setComprobantes: TQuery;
// Objetivo...: devolver un set de comprobantes
Begin
  Result := datosdb.tranSQL('select correlatividades.codcomp, correlatividades.idcompr, tcomprob.descrip from correlatividades, tcomprob where correlatividades.idcompr = tcomprob.idcompr');
end;

function  TTCorrelatividades.setNroSiguiente(xcodcomp, xidcompr: String): String;
// Objetivo...: Retornar comprobante siguiente
begin
  if Buscar(xcodcomp, xidcompr) then Begin
    Sucursal := tabla.FieldByName('sucursal').AsString;
    Result   := utiles.sLlenarIzquierda( IntToStr( tabla.FieldByName('ultimonro').AsInteger + 1), 8, '0' );
  end else
    Result := 'N';
end;

function  TTCorrelatividades.setNroActual(xcodcomp, xidcompr: String): String;
// Objetivo...: Retornar comprobante actual
begin
  if Buscar(xcodcomp, xidcompr) then Begin
    Sucursal := tabla.FieldByName('sucursal').AsString;
    Result   := tabla.FieldByName('ultimonro').AsString;
  end else
    Result := 'N';
end;

procedure TTCorrelatividades.ActualizarNumero(xcodcomp, xidcompr, xnroactual: String); 
// Objetivo...: Ajustar Nro. de Comprobante
begin
  if Buscar(xcodcomp, xidcompr) then Begin
    if tabla.FieldByName('ultimonro').AsString < xnroactual then Begin
      tabla.Edit;
      tabla.FieldByName('ultimonro').AsString := xnroactual;
      try
        tabla.Post
       except
        tabla.Cancel
      end;
      datosdb.closeDB(tabla); tabla.Open;
    end;
  end;
end;

procedure TTCorrelatividades.conectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones = 0 then Begin
    if not tabla.Active then tabla.Open;
  end;
  Inc(conexiones);
end;

procedure TTCorrelatividades.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  Dec(conexiones);
  if conexiones = 0 then Begin
    datosdb.closeDB(tabla);
  end;
end;

{===============================================================================}

function correlatividad: TTCorrelatividades;
begin
  if xcorrelatividad = nil then
    xcorrelatividad := TTCorrelatividades.Create;
  Result := xcorrelatividad;
end;

{===============================================================================}

initialization

finalization
  xcorrelatividad.Free;

end.
