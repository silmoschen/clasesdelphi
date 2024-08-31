unit CIntegridadLaboratorioFabrissin;

interface

uses CBDT, SysUtils, DBTables, CUtiles, CIDBFM, CSolAnalisisFabrissin,
     CSolAnalisisFabrissinInternacion, CPaciente, Classes;

type

TTIntegridadLaboratorioFabrissin = class
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  procedure   CompactarPacientes;

 private
  { Declaraciones Privadas }
end;

function integridadLab: TTIntegridadLaboratorioFabrissin;

implementation

var
  xintegridadLab: TTIntegridadLaboratorioFabrissin = nil;

constructor TTIntegridadLaboratorioFabrissin.Create;
begin
end;

destructor TTIntegridadLaboratorioFabrissin.Destroy;
begin
  inherited Destroy;
end;

procedure TTIntegridadLaboratorioFabrissin.CompactarPacientes;
var
  l: TStringList;
  i, j: Integer;
Begin
  solanalisisint.conectar;
  solanalisis.conectar;
  l := paciente.setLista;
  For i := 1 to l.Count do Begin
    j := 0; 
    if solanalisis.BuscarPaciente(l.Strings[i-1]) then j := 1;
    if solanalisisint.BuscarPaciente(l.Strings[i-1]) then j := 1;
    if j = 0 then paciente.Borrar(l.Strings[i-1]);
  end;
  solanalisisint.desconectar;
  solanalisis.desconectar;
end;

{===============================================================================}

function integridadLab: TTIntegridadLaboratorioFabrissin;
begin
  if xintegridadLab = nil then
    xintegridadLab := TTIntegridadLaboratorioFabrissin.Create;
  Result := xintegridadLab;
end;

{===============================================================================}

initialization

finalization
  xintegridadLab.Free;

end.
