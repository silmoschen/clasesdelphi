unit CEstadisticas;

interface

uses SysUtils, DB, DBTables, CVias, CUtiles, CListar, CBDT, CIDBFM, CUtilidadesArchivos, CServers2000_Excel;

const
  meses: array[1..12] of string = ('Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre');

type

TTEstadistica = class(TObject)            // Superclase
  fecha1, fecha2, idanter, items: string;
  s_inicio, trazarGraficos, infresumido: boolean;
  total: real; nroitems: integer; LineasPag, lineas_blanco: Integer;
  ExportDatos: Boolean;
  Q: TQuery;
  resultados: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  procedure   setFecha(fi, ff: string);
  procedure   Titulos(xtitulo: string; salida: char);
  procedure   Listar(salida: Char);

  procedure   ExportarDatos(xarchivo: String);
  procedure   FinalizarExportacion;
 private
  { Declaraciones Privadas }
  conexiones: Integer;
 protected
  { Declaraciones Protegidas }
  existenDatos, NoTrazarLineaTitulos, exportar: boolean;
  totales: array[1..15] of Real;
  lineas: Integer; lin: String;
  arch, chr18, chr15: String;
  procedure   DatosGrafico(xmonto: real);
  procedure   conectar;
  procedure   desconectar;
  function    ControlarSalto: Boolean;
end;

function estadistica: TTEstadistica;

implementation

var
  xestadistica: TTEstadistica = nil;

constructor TTEstadistica.Create;
begin
  inherited Create;
  fecha1 := ''; fecha2 := '';
  resultados := datosdb.openDB('estadistica', '');
end;

destructor TTEstadistica.Destroy;
begin
  inherited Destroy;
end;

procedure TTEstadistica.setFecha(fi, ff: string);
begin
  s_inicio := False;
  fecha1   := utiles.sExprFecha2000(fi);
  fecha2   := utiles.sExprFecha2000(ff);
  if trazarGraficos then Begin     // si vamos a presentar gráficos, abrimos la tabla para conservar los resultados
    // 1º Vaciamos el contenido de la misma
    datosdb.tranSQL('DELETE FROM ' + resultados.TableName);
    // 2º Efectuamos la apertura
    if not resultados.Active then resultados.Open;
  end;
end;

procedure TTEstadistica.Listar(salida: Char);
// Objetivo...: Emitir el informe
begin
  if (salida = 'I') or (salida = 'P') then List.FinList;
  if salida = 'T' then List.FinalizarImpresionModoTexto(1);
  if salida = 'X' then excel.Visulizar;
  s_inicio := False;
end;

procedure TTEstadistica.DatosGrafico(xmonto: real);
begin
  // Guardamos el resultado, si el mismo es para armar un gráfico
  if trazarGraficos then Begin
     Inc(nroitems);
     resultados.Append;
     resultados.FieldByName('items').AsInteger := nroitems;
     resultados.FieldByName('dato').AsString   := items;
     resultados.FieldByName('valor').AsFloat   := xmonto;
     try
       resultados.Post
     except
       resultados.Cancel
     end;
  end;
end;

procedure TTEstadistica.ExportarDatos(xarchivo: String);
// Objetivo...: Exportar Datos
Begin
  exportar  := True;
  arch      := xarchivo;
  LineasPag := 65;
  chr18 := '';
  chr15 := '';
end;

procedure TTEstadistica.FinalizarExportacion;
// Objetivo...: Exportar Datos
Begin
  list.ExportarInforme(arch);  
  exportar := False;
  chr18 := CHR(18);
  chr15 := CHR(15);
end;

//------------------------------------------------------------------------------

procedure TTEstadistica.Titulos(xtitulo: string; salida: char);
// Objetivo...: Listar Datos de Provincias
begin
  if not s_inicio then Begin
    list.Setear(salida); list.altopag := 0; list.m := 0;
  end;
  if salida <> 'T' then
    if not s_inicio then list.IniciarTitulos;
  if salida = 'T' then
    if not s_inicio then
      if not exportar then list.IniciarImpresionModoTexto else list.ExportarInforme(arch);

  if salida <> 'T' then Begin
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
    if Length(Trim(fecha2)) > 0 then List.Titulo(0, 0, ' ' + xtitulo + ' -  Período ' + utiles.sFormatoFecha(fecha1) + '-' + utiles.sFormatoFecha(fecha2), 1, 'Arial, negrita, 14') else List.Titulo(0, 0, ' ' + xtitulo + ' -  Período ' + fecha1, 1, 'Arial, negrita, 14');
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
    if Not NoTrazarLineaTitulos then List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  end else Begin
    list.LineaTxt(chr18, True);
    if Length(Trim(fecha2)) > 0 then List.LineaTxt(' ' + xtitulo + ' -  Periodo ' + utiles.sFormatoFecha(fecha1) + '-' + utiles.sFormatoFecha(fecha2), True) else List.LineaTxt(' ' + xtitulo + ' -  Periodo ' + fecha1, True);
    List.LineaTxt(' ', True);
    if Not NoTrazarLineaTitulos then list.LineaTxt(utiles.sLlenarIzquierda(lin, 80, '-'), True);
    List.LineaTxt(' ', True);
    if Not NoTrazarLineaTitulos then lineas := 5 else lineas := 4;
  end;
  s_inicio := True;
end;

function TTEstadistica.ControlarSalto: boolean;
// Objetivo...: salto de linea para las impresiones basadas en texto
var
  k: Integer;
begin
  Result := False;
  if not ExportDatos then Begin
    if lineas >= LineasPag then Begin
      //list.lineatxt(inttostr(lineas), True);
      if lineas_blanco = 0 then list.LineaTxt(CHR(12), True) else
        for k := 1 to lineas_blanco do list.LineaTxt('', True);
      Result := True;
    end;
  end;
end;

procedure TTEstadistica.conectar;
begin
  if conexiones = 0 then
    if not resultados.Active then resultados.Open;
  Inc(conexiones);
end;

procedure TTEstadistica.desconectar;
begin
  if conexiones > 0 then Dec(conexiones);
  if conexiones = 0 then
    if resultados.Active then resultados.Close;
end;

{===============================================================================}

function estadistica: TTEstadistica;
begin
  if xestadistica = nil then
    xestadistica := TTEstadistica.Create;
  Result := xestadistica;
end;

{===============================================================================}

initialization

finalization
  xestadistica.Free;

end.
