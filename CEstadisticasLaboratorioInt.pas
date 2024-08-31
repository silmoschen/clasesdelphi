unit CEstadisticasLaboratorioInt;

interface

uses CEstInfoLabInt, CSolAnalisisFabrissinInternacion, SysUtils, DB, DBTables, CUtiles,
     CListar, CBDT, CIDBFM, Classes;

type

TTEstadisticaLaboratorio= class(TTInformesEstadisticos)
 public
  { Declaraciones P�blicas }
  constructor Create;
  destructor  Destroy; override;

  procedure   ListEstAnalisisEfectuados(salida: char);
  procedure   ListEstPacientesIngresados(salida: char);
  procedure   ListPacientesObraSocial(salida: char);
  procedure   ListAnalisisEnviadosEntidades(listSel: TStringList; salida: char);
  procedure   ListListadoPorOrdenes(xdfecha, xhfecha: string; salida: char);
  procedure   ListPorObraSocial_Paciente(xdfecha, xhfecha, xcodos: string; salida: char);
private
  { Declaraciones Privadas }
end;

function estadisticalab: TTEstadisticaLaboratorio;

implementation

var
  xestadistica: TTEstadisticaLaboratorio= nil;

constructor TTEstadisticaLaboratorio.Create;
begin
  inherited Create;
end;

destructor TTEstadisticaLaboratorio.Destroy;
begin
  inherited Destroy;
end;

procedure TTEstadisticaLaboratorio.ListEstAnalisisEfectuados(salida: char);
// Objetivo...: Estad�stica de an�lisis efectuados
begin
  Q := solanalisisint.setEstadisticaSolicitudes(fecha1, fecha2);
  inherited ListEstAnalisisEfectuados(salida);
end;

procedure TTEstadisticaLaboratorio.ListEstPacientesIngresados(salida: char);
// Objetivo...: Estad�stica de pacientes ingresados
begin
  Q := solanalisisint.setEstadisticaSolicitudesPacientes(fecha1, fecha2);
  inherited ListEstPacientesIngresados(salida); 
end;

procedure TTEstadisticaLaboratorio.ListPacientesObraSocial(salida: char);
// Objetivo...: Estad�stica de pacientes por obras sociales
begin
  Q := solanalisisint.setEstadisticaObrasSociales(fecha1, fecha2);
  inherited ListPacientesObraSocial(salida);
end;

procedure TTEstadisticaLaboratorio.ListAnalisisEnviadosEntidades(listSel: TStringList; salida: char);
// Objetivo...: An�lisis enviados a Entidades
begin
  Q := solanalisisint.setEstadisticaAnalisisEnviados(fecha1, fecha2);
  inherited ListAnalisisEnviadosEntidades(listSel, salida);
end;

procedure TTEstadisticaLaboratorio.ListListadoPorOrdenes(xdfecha, xhfecha: string; salida: char);
// Objetivo...: Ordenes recibidas y no recibidas
begin
  Q := solanalisisint.setOrdenesAnalisis(xdfecha, xhfecha);
  inherited ListListadoPorOrdenes(salida);
end;

procedure TTEstadisticaLaboratorio.ListPorObraSocial_Paciente(xdfecha, xhfecha, xcodos: string; salida: char);
// Objetivo...: Solicitudes por paciente y obra social
begin
  Q := solanalisisint.setObrasSociales_Pacientes(xdfecha, xhfecha);
  if (salida = 'P') or (salida = 'I') then inherited ListPorObraSocial_Paciente(xdfecha, xhfecha, xcodos, salida);
end;


{===============================================================================}

function estadisticalab: TTEstadisticaLaboratorio;
begin
  if xestadistica = nil then
    xestadistica := TTEstadisticaLaboratorio.Create;
  Result := xestadistica;
end;

{===============================================================================}

initialization

finalization
  xestadistica.Free;

end.
