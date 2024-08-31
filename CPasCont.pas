unit CPasCont;

interface

uses SysUtils, CRegCont, CLDiario, CCaja, CIdctas, DB, DBTables, CBDT, CUtiles, CIDBFM, CLDiaAuC, CLDiaAuV, CCNetos;

type

TTAsientosAutomaticos = class(TTRegCont)            // Supascontclase
  tmov: array[1..nroitems] of string; tcon: array[1..nroitems] of string;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  destroy; override;

  procedure AnularAsientos(xperiodo, xmes: string);
 protected
  { Declaraciones Protegidas }
  conc, idmov, path: string; f: boolean; // inidica si hubo operaciones
  procedure PrepararProceso;
  procedure BajaAsiento(xperiodo, xclave: string);
  procedure RegistrarAsiento(xperiodo, xmes , xdia: string);
end;

function pascont: TTAsientosAutomaticos;

implementation

var
  xpasescont: TTAsientosAutomaticos = nil;

constructor TTAsientosAutomaticos.Create;
begin
  inherited Create;
end;

destructor TTAsientosAutomaticos.Destroy;
begin
  inherited Destroy;
end;

{-------------------------------------------------------------------------------}
procedure TTAsientosAutomaticos.AnularAsientos(xperiodo, xmes: string);
// Objetivo...: Anular los asientos para un período dado
begin
  datosdb.tranSQL(dbs.dirSistema + path, 'DELETE FROM asientos WHERE periodo = ' + '"' + xperiodo + '"' + ' AND fecha >= ' + '"' + xperiodo + xmes + '00' + '"' + ' AND fecha <= ' + '"' + xperiodo + xmes + '31' + '"' + ' AND clave > ' + '"' + 'AA' + '"');
  datosdb.tranSQL(dbs.dirSistema + path, 'DELETE FROM cabasien WHERE periodo = ' + '"' + xperiodo + '"' + ' AND fecha >= ' + '"' + xperiodo + xmes + '00' + '"' + ' AND fecha <= ' + '"' + xperiodo + xmes + '31' + '"' + ' AND clave > ' + '"' + 'AA' + '"');
end;

procedure TTAsientosAutomaticos.BajaAsiento(xperiodo, xclave: string);
// Objetivo...: Anular un tipo de asiento por su id - clave
begin
  datosdb.tranSQL(dbs.dirSistema + path, 'DELETE FROM asientos WHERE periodo = ' + '''' + xperiodo + '''' + ' AND clave = ' + '''' + xclave + '''');
  datosdb.tranSQL(dbs.dirSistema + path, 'DELETE FROM cabasien WHERE periodo = ' + '''' + xperiodo + '''' + ' AND clave = ' + '''' + xclave + '''');
end;

procedure TTAsientosAutomaticos.PrepararProceso;
// Objetivo...: Inicializar procesos para generar asientos
begin
//  inherited Via(path);
  IniciarArray; xindice := 0; f := False;
end;

procedure TTAsientosAutomaticos.RegistrarAsiento(xperiodo, xmes , xdia: string);
// Objetivo....: Volcar los asientos compactados del diario auxiliar al diario final
var
  j, t: integer;
begin
  // Grabamos Cabecera del asiento
  numeroas := ldiario.NuevoAsiento;
  netos.getDatos(idmov);
  // Si hubo movimientos, grabamos la cabecera
  ldiario.Grabar(xperiodo, numeroas, xdia + '/' + xmes + '/' + Copy(xperiodo, 3, 2), netos.Descrip, claveas);
  // Grabamos los movimientos del haber - desde el array
  t := 0;
  For j := 1 to xindice do  // Debe
    if tmov[j] = '1' then
      if ttotdebe[j] > 0 then
        begin
          Inc(t);
          ldiario.Grabar(xperiodo, numeroas, xdia + '/' + xmes + '/' + Copy(xperiodo, 3, 2), cuenta[j], utiles.sLlenarIzquierda(IntToStr(t), 3, '0'), tcon[j], tmov[j], claveas, ttotdebe[j]);
        end;
  For j := 1 to xindice do  // Haber
    if tmov[j] = '2' then
      if ttothaber[j] > 0 then
        begin
          Inc(t);
          ldiario.Grabar(xperiodo, numeroas, xdia + '/' + xmes + '/' + Copy(xperiodo, 3, 2), cuenta[j], utiles.sLlenarIzquierda(IntToStr(t), 3, '0'), tcon[j], tmov[j], claveas, ttothaber[j]);
        end;

  IniciarArray; xindice := 0; // Inicilizamos para el proximo asiento
end;

{===============================================================================}

function pascont: TTAsientosAutomaticos;
begin
  if xpasescont = nil then
    xpasescont := TTAsientosAutomaticos.Create;
  Result := xpasescont;
end;

{===============================================================================}

initialization

finalization
  xpasescont.Free;

end.