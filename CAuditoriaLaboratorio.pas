unit CAuditoriaLaboratorio;

interface

uses CAuditoria, CSolAnalisisFabrissin, Ccctelab, CProfesional, CPaciente, SysUtils, DB, DBTables, CBDT, CVias, CUtiles, CListar, CIDBFM;

type

TTAuditoriaLaboratorio = class(TTAuditoria)
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  procedure   PrepararAuditoria(xfecha: string);
  procedure   FinalizarAuditoria(xfecha: string);

  procedure   ListSolicitudesGeneradas(salida: char);
  procedure   ListValoresaCobrar(salida: char);
  procedure   ListIngresosPorCobros(salida: char);
private
  { Declaraciones Privadas }
end;

function auditorialaboratorio: TTAuditoriaLaboratorio;

implementation

var
  xauditoria: TTAuditoriaLaboratorio = nil;

constructor TTAuditoriaLaboratorio.Create;
begin
  fecha := '';
  inherited Create;
end;

destructor TTAuditoriaLaboratorio.Destroy;
begin
  inherited Destroy;
end;

procedure TTAuditoriaLaboratorio.PrepararAuditoria(xfecha: string);
// Objetivo...: Setear información para el manejo de la auditoria
begin
  setFecha(xfecha);
  paciente.conectar;
  profesional.conectar;
end;

procedure TTAuditoriaLaboratorio.FinalizarAuditoria(xfecha: string);
// Objetivo...: Setear información para el manejo de la auditoria
begin
  paciente.desconectar;
  profesional.desconectar;
end;

procedure TTAuditoriaLaboratorio.ListSolicitudesGeneradas(salida: char);
// Objetivo...: Solicitudes Generadas en una fecha
begin
  verifListado(salida);

  Q := solanalisis.setAuditoriaSolicitudes(fecha);

  List.Linea(0, 0, 'Solicitudes Ingresadas', 1, 'Arial, negrita, 10', salida, 'S');
  List.Linea(0, 0, ' ', 1, 'Courier New, normal, 9', salida, 'S');

  Q.Open; Q.First; total := 0;
  while not Q.EOF do
    begin
      paciente.getDatos(Q.FieldByName('codpac').AsString);
      profesional.getDatos(Q.FieldByName('codprof').AsString);
      List.Linea(0, 0, Q.FieldByName('nrosolicitud').AsString + ' ' + Q.FieldByName('protocolo').AsString, 1, 'Arial, normal, 8', salida, 'N');
      List.Linea(12, list.lineactual, paciente.nombre, 2, 'Arial, normal, 8', salida, 'S');
      List.Linea(63, list.lineactual, profesional.nombres, 3, 'Arial, normal, 8', salida, 'S');
      total := total + 1;
      Q.Next;
    end;

  List.Linea(0, 0, ' ', 1, 'Arial, normal, 8', salida, 'S');
  List.Linea(0, 0, 'Cantidad de Solicitudes Ingresadas ...:', 1, 'Arial, negrita, 8', salida, 'N');
  List.importe(40, list.lineactual, '#####', total, 2, 'Arial, normal, 8');
  List.Linea(60, list.lineactual, ' ', 3, 'Arial, normal, 8', salida, 'S');
  List.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');

  Q.Close;
end;

procedure TTAuditoriaLaboratorio.ListValoresaCobrar(salida: char);
// Objetivo...: Emisión de valores a cobrar por solicitudes efectuadas
var
  xnombre: string;
begin
  Q := cclab.AuditoriaSolicitudesEmitidas(fecha);
  verifListado(salida);

  List.Linea(0, 0, ' ', 1, 'Courier New, normal, 5', salida, 'S');
  List.Linea(0, 0, 'Solicitudes - Montos a Cobrar por Análisis', 1, 'Arial, negrita, 10', salida, 'S');
  List.Linea(0, 0, ' ', 1, 'Courier New, normal, 9', salida, 'S');

  Q.Open; Q.First; total := 0; idanter := ''; xnombre := '';
  while not Q.EOF do
    begin
      if Q.FieldByName('nombre').AsString <> idanter then xnombre := Q.FieldByName('nombre').AsString else xnombre := '';
      List.Linea(0, 0, xnombre, 1, 'Arial, normal, 8', salida, 'N');
      List.Linea(55, list.lineactual, Q.FieldByName('concepto').AsString, 2, 'Arial, normal, 8', salida, 'S');
      List.importe(90, list.lineactual, '', Q.FieldByName('importe').AsFloat, 3, 'Arial, normal, 8');
      List.Linea(95, list.lineactual, ' ', 4, 'Arial, normal, 8', salida, 'S');
      total := total + Q.FieldByName('importe').AsFloat;
      idanter := Q.FieldByName('nombre').AsString;
      Q.Next;
    end;

  List.Linea(0, 0, ' ', 1, 'Arial, normal, 8', salida, 'N');
  List.derecha(90, list.lineactual, '', '--------------', 2, 'Arial, normal, 8');
  List.Linea(0, 0, 'Total Valores a Cobrar ....:', 1, 'Arial, negrita, 8', salida, 'N');
  List.importe(90, list.lineactual, '', total, 2, 'Arial, normal, 8');
  List.Linea(95, list.lineactual, ' ', 3, 'Arial, normal, 8', salida, 'S');
  List.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');

  Q.Close;
end;

procedure TTAuditoriaLaboratorio.ListIngresosPorCobros(salida: char);
// Objetivo...: Listar las Facturas de ventas emitidas en el día
begin
  Q := cclab.AuditoriaRecaudacionesCobros(fecha);
  inherited ListRecaudacionCobros(salida);
end;

{===============================================================================}

function auditorialaboratorio: TTAuditoriaLaboratorio;
begin
  if xauditoria = nil then
    xauditoria := TTAuditoriaLaboratorio.Create;
  Result := xauditoria;
end;

{===============================================================================}

initialization

finalization
  xauditoria.Free;

end.
