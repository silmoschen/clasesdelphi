unit CCinstviaCont;

interface

uses SysUtils, CUtiles, CPeriodo, CPlanctas, CLDiario, CVias, CBDT, CAsmodel, CLMayor, Cbalcss, CEstRes, CBalgen, CBalIe, CPlsaldo, CEstFin, CIdctas, CLDiaAuC, CLDiaAuV, CCiecont, CEmprcont;

type

TTCViasCont = class(TObject)            // Superclase
   xtsession: string;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  function    conectarPeriodo(xvia: string): boolean;
  function    conectarPlanctas(xvia: string): boolean;
  function    conectarLDiario(xvia: string): boolean;
  function    conectarLMayor(xvia: string): boolean;
  function    conectarBcss(xvia: string): boolean;
  function    conectarEstres(xvia: string): boolean;
  function    conectarBagen(xvia: string): boolean;
  function    conectarBalIE(xvia: string): boolean;
  function    conectarPlsaldos(xvia: string): boolean;
  function    conectarCierreCont(xvia: string): boolean;
  function    conectarAsienmod(xvia: string): boolean;
  function    conectarIdctasFijas(xvia: string): boolean;
  function    conectarLDiaAuxC(xvia: string): boolean;
  function    conectarLDiaAuxV(xvia: string): boolean;

  procedure   desconectarPeriodo;
  procedure   desconectarPlanctas;
  procedure   desconectarLDiario;
  procedure   desconectarLMayor;
  procedure   desconectarBcss;
  procedure   desconectarEstres;
  procedure   desconectarBagen;
  procedure   desconectarBalIE;
  procedure   desconectarPlsaldos;
  procedure   desconectarAsienmod;
  procedure   desconectarCierreCont;
  procedure   desconectarIdctasFijas;
  procedure   desconectarLDiaAuxC;
  procedure   desconectarLDiaAuxV;
  function    TestVia: boolean;
 private
  { Declaraciones Privadas }
  v_actual: string;
end;

function instviacont: TTCViasCont;

implementation

var
  xinstviacont: TTCViasCont = nil;

constructor TTCViasCont.Create;
begin
  inherited Create;
  xtsession := 'TSCONT';
end;

destructor TTCViasCont.Destroy;
begin
  inherited Destroy;
end;

function TTCViasCont.TestVia: boolean;
// Objetivo...: Testear Vía contabilidad
begin
  Result := False;
  defemprcont.conectar;
  v_actual := defemprcont.Nomvia;
  if Length(Trim(v_actual)) > 0 then Result := True;
  defemprcont.desconectar;
end;

function TTCViasCont.conectarPeriodo(xvia: string): boolean;
// Objetivo...: conectar Vía Ejercicios Económicos
begin
  if testVia then Begin
    per.Via(v_actual);
    Result := True;
   end
  else Result := False;
end;

function TTCViasCont.conectarPlanctas(xvia: string): boolean;
// Objetivo...: conectar Vía Plan de Cuentas
begin
  if testVia then Begin
//    planctas.Via(v_actual);
    Result := True;
   end
  else Result := False;
end;

function TTCViasCont.conectarLDiario(xvia: string): boolean;
// Objetivo...: conectar Vía Libro Diario
begin
  if testVia then Begin
//    ldiario.Via(v_actual);
    Result := True;
   end
  else Result := False;
end;

function TTCViasCont.conectarLMayor(xvia: string): boolean;
// Objetivo...: conectar Vía Libro Mayor
begin
  if testVia then Begin
//    lmayor.Via(v_actual);
    Result := True;
   end
  else Result := False;
end;

function TTCViasCont.conectarBcss(xvia: string): boolean;
// Objetivo...: conectar Vía Balance Comprob. Sumas y Saldos
begin
  if testVia then Begin
    bcss.Via(v_actual);
    Result := True;
   end
  else Result := False;
end;

function TTCViasCont.conectarEstres(xvia: string): boolean;
// Objetivo...: conectar Vía Estado de Resultados
begin
  if testVia then Begin
    estres.Via(v_actual);
    Result := True;
   end
  else Result := False;
end;

function TTCViasCont.conectarBagen(xvia: string): boolean;
// Objetivo...: conectar Vía Balance General
begin
  if testVia then Begin
    balgen.Via(v_actual);
    Result := True;
   end
  else Result := False;
end;

function TTCViasCont.conectarBalIE(xvia: string): boolean;
// Objetivo...: conectar Vía Balance Ingresos/Egresos
begin
  if testVia then Begin
    balingegr.Via(v_actual);
    Result := True;
   end
  else Result := False;
end;

function TTCViasCont.conectarPlsaldos(xvia: string): boolean;
// Objetivo...: conectar Vía Saldos Generales
begin
  if testVia then Begin
    plsaldos.Via(v_actual);
    Result := True;
   end
  else Result := False;
end;

function TTCViasCont.conectarAsienmod(xvia: string): boolean;
// Objetivo...: conectar Vía Netos discriminados
begin
  if testVia then Begin
    asienmod.Via(v_actual);
    Result := True;
   end
  else Result := False;
end;

function TTCViasCont.conectarCierreCont(xvia: string): boolean;
// Objetivo...: conectar Vía Netos discriminados
begin
  if testVia then Begin
    cieapcont.Via(v_actual);
    Result := True;
   end
  else Result := False;
end;

function TTCViasCont.conectarIdctasFijas(xvia: string): boolean;
// Objetivo...: conectar cuentas fijas
begin
  if testVia then Begin
    idctas.Via(v_actual);
    Result := True;
   end
  else Result := False;
end;

function TTCViasCont.conectarLDiaAuxC(xvia: string): boolean;
// Objetivo...: Conectar Puente entre Módulo I.V.A. Compras y Contabilidad
begin
  if testVia then Begin
    ldiarioauxc.Via(v_actual);
    Result := True;
   end
  else Result := False;
end;

function TTCViasCont.conectarLDiaAuxV(xvia: string): boolean;
// Objetivo...: Conectar Puente entre Módulo I.V.A. Ventas y Contabilidad
begin
  if testVia then Begin
    ldiarioauxv.Via(v_actual);
    Result := True;
   end
  else Result := False;
end;

procedure TTCViasCont.desconectarPeriodo;
// Objetivo...: desconectar Vía Contabilidad
begin
  per.desconectar;
end;

procedure TTCViasCont.desconectarPlanctas;
// Objetivo...: desconectar Plan de Cuentas
begin
  planctas.desconectar;
end;

procedure TTCViasCont.desconectarLDiario;
// Objetivo...: desconectar Libro Diario
begin
  ldiario.desconectar;
end;

procedure TTCViasCont.desconectarLMayor;
// Objetivo...: desconectar Libro Mayor
begin
  lmayor.desconectar;
end;

procedure TTCViasCont.desconectarBcss;
// Objetivo...: desconectar Balance de Comprobanción de Sumas y Saldos
begin
  bcss.desconectar;
end;

procedure TTCViasCont.desconectarBagen;
// Objetivo...: desconectar Balance General
begin
  balgen.desconectar;
end;

procedure TTCViasCont.desconectarEstres;
// Objetivo...: desconectar Estado de Resultados
begin
  estres.desconectar;
end;

procedure TTCViasCont.desconectarBalie;
// Objetivo...: desconectar Balance General I/E
begin
  balingegr.desconectar;
end;

procedure TTCViasCont.desconectarPlsaldos;
// Objetivo...: desconectar Saldos Generales
begin
  plsaldos.desconectar;
end;

procedure TTCViasCont.desconectarCierreCont;
// Objetivo...: desconectar Módulo Cierre Ejercicios Contables
begin
  estcont.desconectar;
end;

procedure TTCViasCont.desconectarAsienmod;
// Objetivo...: desconectar Asientos Modelos
begin
  asienmod.desconectar;
end;

procedure TTCViasCont.desconectarIdctasFijas;
// Objetivo...: desconectar tabla de cuentas fijas
begin
  idctas.desconectar;
end;

procedure TTCViasCont.desconectarLDiaAuxC;
// Objetivo...: desconectar tabla referencia IVA Compras - Contabilidad
begin
  ldiarioauxc.desconectar;
end;

procedure TTCViasCont.desconectarLDiaAuxV;
// Objetivo...: desconectar tabla referencia IVA Ventas - Contabilidad
begin
  ldiarioauxv.desconectar;
end;

{===============================================================================}

function instviacont: TTCViasCont;
begin
  if xinstviacont = nil then
    xinstviacont := TTCViasCont.Create;
  Result := xinstviacont;
end;

{===============================================================================}

initialization

finalization
  xinstviacont.Free;

end.