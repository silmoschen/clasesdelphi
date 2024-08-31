unit CSEgresos;

interface

uses CSocTit, SysUtils, DB, DBTables, CBDT, CIDBFM, CListar, CUtiles, CConceRS;

type

TTEgrSocios = class(TObject)            // Superclase
  items, codsocio, fecha, codoper, concept: string;
  importe: real;
  tabla: TTable; r: TQuery;
 public
  { Declaraciones Públicas }
  constructor Create(xitems, xcodsocio, xfecha, xcodoper, xconcepto: string; ximporte: real);
  destructor  Destroy; override;

  function    getCodsocio: string;
  function    getItems: string;
  function    getFecha: string;
  function    getCodoper: string;
  function    getConcepto: string; overload;
  function    getConcepto(xcodoper: string): string; overload;
  function    getImporte: real;

  procedure   Grabar(xitems, xcodsocio, xfecha, xcodoper, xconcepto: string; ximporte: real);
  procedure   Borrar(xitems: string);
  function    Buscar(xitems: string): boolean;
  procedure   getDatos(xitems: string);
  procedure   Listar(f1, f2: string; salida: char);
  function    NuevoItems: string;
  function    getTotalEgresos(xcodsocio: string): real;
  function    AuditoriaEgresosSocios(xfecha: string): TQuery;
  procedure   Depurar(xfecha: string);
  function    setRetiros: TQuery; overload;
  function    setRetiros(xdf, xhf: string): TQuery; overload;

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  total: real; idanter: string;
  procedure   listlinea(salida: char);
  procedure   Subtotal(salida: char);
end;

function egrsocios: TTEgrSocios;

implementation

var
  xegrsocios: TTEgrSocios = nil;

constructor TTEgrSocios.Create(xitems, xcodsocio, xfecha, xcodoper, xconcepto: string; ximporte: real);
begin
  inherited Create;
  items    := xitems;
  codsocio := xcodsocio;
  fecha    := xfecha;
  codoper  := xcodoper;
  concept  := xconcepto;
  importe  := ximporte;

  tabla := datosdb.openDB('egrsocio.DB', 'Items');
end;

destructor TTEgrSocios.Destroy;
begin
  inherited Destroy;
end;

function TTEgrSocios.getCodsocio: string;
begin
  Result := codsocio;
end;

function TTEgrSocios.getItems: string;
begin
  Result := items;
end;

function TTEgrSocios.getFecha: string;
begin
  Result := utiles.sFormatoFecha(fecha);
end;

function TTEgrSocios.getConcepto: string;
begin
  Result := concept;
end;

function TTEgrSocios.getConcepto(xcodoper: string): string;
begin
  concepto.getDatos(xcodoper);
  Result := concepto.Descrip;
end;

function TTEgrSocios.getCodoper: string;
begin
  Result := codoper;
end;

function TTEgrSocios.getImporte: real;
begin
  Result := importe;
end;

procedure TTEgrSocios.Grabar(xitems, xcodsocio, xfecha, xcodoper, xconcepto: string; ximporte: real);
// Objetivo...: Guardar atributos del objeto en tabla de Persistencia
begin
  if Buscar(xitems) then tabla.Edit else tabla.Append;
  tabla.FieldByName('items').AsString    := xitems;
  tabla.FieldByName('codsocio').AsString := xcodsocio;
  tabla.FieldByName('fecha').AsString    := utiles.sExprFecha(xfecha);
  tabla.FieldByName('codoper').AsString  := xcodoper;
  tabla.FieldByName('concepto').AsString := xconcepto;
  tabla.FieldByName('importe').AsFloat   := ximporte;
  try
    tabla.Post;
  except
    tabla.Cancel;
  end;
end;

procedure TTEgrSocios.Borrar(xitems: string);
// Objetivo...: Eliminar un Objeto
begin
  if Buscar(xitems) then
    begin
      tabla.Delete;
      getDatos(tabla.FieldByName('items').AsString);  // Fijamos los Atributos Siguientes al Objeto Borrado
    end;
end;

function TTEgrSocios.Buscar(xitems: string): boolean;
// Objetivo...: Buscar el Objeto solicitado
begin
  if not tabla.Active then conectar;
  if tabla.FindKey([xitems]) then Result := True else Result := False;
end;

procedure  TTEgrSocios.getDatos(xitems: string);
// Objetivo...: Retornar/Iniciar Atributos
begin
  if Buscar(xitems) then
    begin
      items     := tabla.FieldByName('items').AsString;
      codsocio  := tabla.FieldByName('codsocio').AsString;
      fecha     := tabla.FieldByName('fecha').AsString;
      codoper   := tabla.FieldByName('codoper').AsString;
      concept   := tabla.FieldByName('concepto').AsString;
      importe   := tabla.FieldByName('importe').AsFloat;
    end
   else
    begin
      codsocio := ''; items := ''; fecha := ''; codoper := ''; concept := ''; importe := 0;
    end;
end;

procedure TTEgrSocios.Depurar(xfecha: string);
// Objetivo...: Depurar información
begin
  datosdb.tranSQL('DELETE FROM egrsocio WHERE fecha < ' + '''' + utiles.sExprFecha(xfecha) + '''');
end;

function TTEgrSocios.setRetiros: TQuery;
// Objetivo...: Devolver un set con los retiros efectuados
begin
  Result := datosdb.tranSQL('SELECT items, codsocio, fecha, codoper, importe, concepto FROM egrsocio ORDER BY codoper, fecha');
end;

function TTEgrSocios.setRetiros(xdf, xhf: string): TQuery;
// Objetivo...: Devolver un set con los retiros efectuados
begin
  Result := datosdb.tranSQL('SELECT items, codsocio, fecha, codoper, importe, concepto FROM egrsocio ' +
                            ' WHERE fecha >= ' + '''' + utiles.sExprFecha(xdf) + '''' + ' AND fecha <= ' + '''' + utiles.sExprFecha(xhf) + '''' + ' ORDER BY codoper, fecha');
end;

procedure TTEgrSocios.Listar(f1, f2: string; salida: char);
// Objetivo...: Informe de Cuotas Pagas
begin
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Listado de Retiros Efectuados', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, '        Fecha', 1, 'Arial, cursiva, 8');
  List.Titulo(15, list.lineactual, 'Tipo-Operación', 2, 'Arial, cursiva, 8');
  List.Titulo(70, list.lineactual, 'Importe', 3, 'Arial, cursiva, 8');
  List.Titulo(78, list.lineactual, 'Concepto Operación', 4, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  r := setRetiros;

  r.Open; r.First; total := 0; idanter := '';
  while not r.EOF do
    begin
      if (r.FieldByName('fecha').AsString >= utiles.sExprFecha(f1)) and (r.FieldByName('fecha').AsString <= utiles.sExprFecha(f2)) then
        begin
          ListLinea(salida);
          total := total + r.FieldByName('importe').AsFloat;
        end;
      idanter := r.FieldByName('codsocio').AsString;
      r.Next;
    end;
    Subtotal(salida);
    r.Close;
    List.FinList;
end;

procedure TTEgrSocios.Listlinea(salida: char);
// Objetivo...: Listar Línea
begin
  if r.FieldByName('codsocio').AsString <> idanter then
    begin
      if total <> 0 then Subtotal(salida);
      sociotitular.getDatos(r.FieldByName('codsocio').AsString);
      list.Linea(0, 0, 'Socio:  ' + r.FieldByName('codsocio').AsString + '  ' + sociotitular.Nombre, 1, 'Arial, negrita, 9', salida, 'S');
      total := 0;
    end;
  concepto.getDatos(r.FieldByName('codoper').AsString);
  list.Linea(0, 0, '      ' + utiles.sFormatoFecha(r.FieldByName('fecha').AsString), 1, 'Arial, normal, 8', salida, 'N');
  list.Linea(15, list.Lineactual, concepto.codconc + '-' + concepto.Descrip, 2, 'Arial, normal, 8', salida, 'N');
  list.importe(75, list.lineactual, '', r.FieldByName('importe').AsFloat, 3, 'Arial, normal, 8');
  list.Linea(78, list.Lineactual, r.FieldByName('concepto').AsString, 4, 'Arial, normal, 8', salida, 'S');
end;

procedure TTEgrSocios.Subtotal(salida: char);
// Objetivo...: Subtotal
begin
  list.Linea(0, 0, '  ', 1, 'Arial, normal, 8', salida, 'N');
  list.derecha(75, list.lineactual, '', '---------------------', 2, 'Arial, normal, 8');
  list.Linea(0, 0, 'Total de Retiros ....: ', 1, 'Arial, negrita, 8', salida, 'S');
  list.importe(75, list.lineactual, '', total, 2, 'Arial, negrita, 8');
  list.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');
end;

function TTEgrSocios.NuevoItems: string;
// Objetivo...: Generar un Nuevo Items de Registración
begin
  tabla.Last;
  if Length(trim(tabla.FieldByName('items').AsString)) > 0 then Result := IntToStr(tabla.FieldByName('items').AsInteger + 1) else Result := '1';
end;

function TTEgrSocios.getTotalEgresos(xcodsocio: string): real;
// Objetivo...: reclacular monto total de egresos para un socio dado
begin
  total := 0;
  tabla.First;
  while not tabla.EOF do
    begin
      if tabla.FieldByName('codsocio').AsString = xcodsocio then total := total + tabla.FieldByName('importe').AsFloat;
      tabla.Next;
    end;
  Result := total;
end;

function TTEgrSocios.AuditoriaEgresosSocios(xfecha: string): TQuery;
// Objetivo...: Abrir tablas de persistencia
begin
  Result := datosdb.tranSQL('SELECT egrsocio.codsocio, egrsocio.codoper, egrsocio.fecha, egrsocio.concepto, soctit.nombre, egrsocio.importe ' +
                            ' FROM egrsocio, soctit WHERE egrsocio.codsocio = soctit.codsocio AND fecha = ' + '''' + xfecha + '''');
end;

procedure TTEgrSocios.conectar;
// Objetivo...: Abrir tablas de persistencia
begin
  tabla.Open;
  tabla.FieldByName('codsocio').DisplayLabel := 'Cód.'; tabla.FieldByName('fecha').Visible := False;
  sociotitular.conectar;
  concepto.conectar;
end;

procedure TTEgrSocios.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  datosdb.closeDB(tabla);
  sociotitular.desconectar;
  concepto.desconectar;
end;

{===============================================================================}

function egrsocios: TTEgrSocios;
begin
  if xegrsocios = nil then
    xegrsocios := TTEgrSocios.Create('', '', '', '', '', 0);
  Result := xegrsocios;
end;

{===============================================================================}

initialization

finalization
  xegrsocios.Free;

end.
