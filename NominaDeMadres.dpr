program NominaDeMadres;

uses
  Forms,
  NominaPadres in '..\SGen\cuotasfoot\NominaPadres.pas' {fmListPadres},
  ImgForms in '..\Interfases\ImgForms.pas' {contenedorImg},
  CMedidasDamevin in 'CMedidasDamevin.pas',
  ficha_padres in '..\SGen\cuotasfoot\ficha_padres.pas' {fmFichaPadres},
  CPadresFoot in 'CPadresFoot.pas',
  CLogSeg in 'CLogSeg.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TfmListPadres, fmListPadres);
  Application.CreateForm(TcontenedorImg, contenedorImg);
  Application.CreateForm(TfmFichaPadres, fmFichaPadres);
  Application.Run;
end.
