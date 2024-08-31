unit CccteclSimple;

interface

uses Ccctecl, SysUtils, DB, DBTables, CBDT, Cliengar, CListar, CUtiles, CIDBFM, WinProcs;

type

TTCtactecls = class(TTCtactecl)
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  procedure   ImprimirRecibo(xconcepto: string; ximporte: real; salida: char);
  procedure   ListClientesRecibieronCarta(xdf, xhf: string; salida: char);
  procedure   ListClientesQuePagaron(xdf, xhf: string; salida: char);

  procedure   ListClientesVistadosPorCobrador(xdf, xhf: string; salida: char);
  procedure   ListClientesVistadosQuePagaron(xdf, xhf: string; salida: char);

  procedure   conectar;
  procedure   desconectar;
  procedure   IniciarTablasObj; override;
 private
  { Declaraciones Privadas }
  procedure   DatosCliente; override;
end;

function cccls: TTCtactecls;

implementation

var
  xctactecls: TTCtactecls = nil;

constructor TTCtactecls.Create;
begin
  inherited Create;
  tabla1  := datosdb.openDB('cctcl', 'Idtitular;Clavecta');                        // Peristencia de Objetos c/c
  tabla2  := datosdb.openDB('ctactecf', 'Idcompr;Tipo;Sucursal;Numero');
  tabla3  := datosdb.openDB('ctactecl', 'Idtitular;Clavecta;Idcompr;Tipo;Sucursal;Numero;Items');
  morosos := datosdb.openDB('morosos1', 'Idtitular;Clavecta;Idc;Tipo;Sucursal;Numero');
end;

destructor TTCtactecls.Destroy;
begin
  inherited Destroy;
end;

procedure TTCtactecls.ImprimirRecibo(xconcepto: string; ximporte: real; salida: char);
// Objetivo...: Imprimir recibo
var
  i: integer;
begin
  if Buscar(clavecta, idtitular, idc, tipo, sucursal, numero, items) then Begin
    DatosCliente;
    listdat     := False;
    // Emisión del comprobante
    inherited getDatosFormatoCartas(50);
    inherited listRecibo(xconcepto, ximporte ,salida);
    For i := 1 to StrToInt(modeloc.FieldByName('fc').AsString) do List.Linea(0, 0, ' ', 1, 'Arial, normal, 8', salida, 'S');
    inherited listRecibo(xconcepto, ximporte, salida);

    if (salida = 'I') or (salida = 'P') then Begin
      list.CompletarPagina;
      list.FinList;
    end else
      Winexec('list.exe', 0);

    listdat := False;  // Fags para imprimir otro recibo
  end;
end;

procedure TTCtactecls.DatosCliente;
// Objetivo...: Datos del cliente;
begin
  // Atributos del cliente
  clientegar.getDatos(idtitular);
  rsCliente   := clientegar.nombre;
  domCliente  := clientegar.domicilio;
  rsLocalidad := clientegar.localidad;
  rsProvincia := clientegar.provincia;
  rsCodpfis   := clientegar.codpfis;
  rsNrocuit   := clientegar.nrocuit;
  docc        := clientegar.nrodoc;
end;

procedure TTCtactecls.ListClientesRecibieronCarta(xdf, xhf: string; salida: char);
// Objetivo...: Listar aquellos clientes que recibieron cartas
begin
  TSQL := datosdb.tranSQL('SELECT enviocartas.*, clientes.Codcli, clientes.Nombre, clientes.Domicilio FROM enviocartas, clientes, cctcl WHERE cctcl.Clavecta = enviocartas.Clavecta AND cctcl.Idtitular = enviocartas.Idtitular AND ' +
                          ' cctcl.Idtitular = clientes.Codcli AND enviocartas.Fecha >= ' + '"' + utiles.sExprFecha(xdf) + '"' + ' AND enviocartas.Fecha <= ' + '"' + utiles.sExprFecha(xhf) + '"');
  inherited ListClientesRecibieronCarta(xdf, xhf, salida);
end;

procedure TTCtactecls.ListClientesQuePagaron(xdf, xhf: string; salida: char);
// Objetivo...: Extraer aquellos clientes que pagaron, luego de ser intimados
begin
  TSQL := datosdb.tranSQL('SELECT enviocartas.*, ctactecl.Fecha AS fechavto, ctactecl.Importe, ctactecl.Numero, ctactecl.Estado, clientes.Nombre FROM enviocartas, ctactecl, clientes WHERE enviocartas.Idtitular = ctactecl.Idtitular AND enviocartas.Clavecta = ctactecl.Clavecta AND ' +
                          ' ctactecl.Idtitular = clientes.Codcli AND ctactecl.Fecha >= ' + '"' + utiles.sExprFecha(xdf) + '"' + ' AND ctactecl.Fecha <= ' + '"' + utiles.sExprFecha(xhf) + '"' + ' AND ctactecl.Estado = ' + '"' + 'R' + '"' + ' ORDER BY clientes.Nombre, enviocartas.Fecha, ctactecl.Estado');

  inherited ListClientesQuePagaron(xdf, xhf, salida);
end;

procedure TTCtactecls.ListClientesVistadosPorCobrador(xdf, xhf: string; salida: char);
// Objetivo...: Listar los clientes que fueron visitados por el cobrador
begin
  TSQL := datosdb.tranSQL('SELECT enviocobrador.*, clientes.Nombre FROM enviocobrador, clientes WHERE enviocobrador.Idtitular = clientes.Codcli AND fecha >= ' + '"' + utiles.sExprFecha(xdf) + '"' + ' AND fecha <= ' + '"' + utiles.sExprFecha(xhf) + '"');
  inherited ListClientesVistadosPorCobrador(xdf, xhf, salida);
end;

procedure TTCtactecls.ListClientesVistadosQuePagaron(xdf, xhf: string; salida: char);
// Objetivo...: Listar aquellos clientes visitados por el cobrador que pagaron
begin
  TSQL := datosdb.tranSQL('SELECT ctactecl.Fecha AS fechavto, ctactecl.Importe, ctactecl.Estado, clientes.Nombre, enviocobrador.* FROM ctactecl, clientes, enviocobrador WHERE ctactecl.Idtitular = clientes.Codcli AND ctactecl.Idtitular = enviocobrador.idtitular AND ' +
                          ' ctactecl.Clavecta = enviocobrador.Clavecta AND ctactecl.Fecha >= ' + '"' + utiles.sExprFecha(xdf) + '"' + ' AND ctactecl.Fecha <= ' + '"' + utiles.sExprFecha(xhf) + '"' + ' AND ctactecl.Estado = ' + '"' + 'R' + '"' + ' ORDER BY Nombre, ctactecl.Fecha');
  inherited ListClientesVistadosQuePagaron(xdf, xhf, salida);
end;

procedure TTCtactecls.IniciarTablasObj;
// Objetivo...: Instanciamos las tablas
begin
  htabla1 := datosdb.openDB('hcctcl', 'Idtitular;Clavecta', '', dbs.BDhistorico);
  htabla2 := datosdb.openDB('hctactecf', 'Idcompr;Tipo;Sucursal;Numero', '', dbs.BDhistorico);
  htabla3 := datosdb.openDB('hctactecl', 'Idtitular;Clavecta;Idcompr;Tipo;Sucursal;Numero;Items', '', dbs.BDhistorico);
  inherited IniciarTablasObj;
end;

procedure TTCtactecls.conectar;
// Objetivo...: Abrir tablas de persistencia
begin
  inherited conectar;
  clientegar.conectar;
end;

procedure TTCtactecls.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  inherited desconectar;
  clientegar.desconectar;
end;

{===============================================================================}

function cccls: TTCtactecls;
begin
  if xctactecls = nil then
    xctactecls := TTCtactecls.Create;
  Result := xctactecls;
end;

{===============================================================================}

initialization

finalization
  xctactecls.Free;

end.
