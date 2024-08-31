unit CRaveReports;

interface

uses SysUtils, CUtiles, CIDBFM, RpBase, RpSystem, RpDefine, RpRave;

type

TTRaveReport = class
  RvProject: TRvProject;
  RvSystem: TRvSystem;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  procedure   RvSystemPrint(Sender: TObject);
 private
  { Declaraciones Privadas }

end;

function report: TTRaveReport;

implementation

var
  xreport: TTRaveReport = nil;

constructor TTRaveReport.Create;
begin
end;

destructor TTRaveReport.Destroy;
begin
  inherited Destroy;
end;

procedure TTRaveReport.RvSystemPrint(Sender: TObject);
begin
  with Sender as TBaseReport do
    begin
      SetFont('Arial', 15);
      GotoXY(1,1);
      Print('Welcome to Code Based Reporting in Rave');
    end;
end;


{===============================================================================}

function report: TTRaveReport;
begin
  if xreport = nil then
    xreport := TTRaveReport.Create;
  Result := xreport;
end;

{===============================================================================}

initialization

finalization
  xreport.Free;

end.
