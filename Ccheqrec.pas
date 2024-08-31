unit Ccheqrec;

interface

uses SysUtils, CBancos, CLibrobcos, DB, DBTables, tablas, CUtiles;

type

TTChequesrec = class(TTLBancos)            // Superclase
 public
  { Declaraciones Públicas }
  constructor Create(xcodbanco, xtcomprob, xtipomov, xfecha, xfecobro, xpagado, xconcepto: string; xmonto: real);
  destructor  Destroy; override;
  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
end;

function chequesrec: TTChequesrec;

implementation

var
  xchequesrec: TTChequesrec = nil;

constructor TTChequesrec.Create(xcodbanco, xtcomprob, xtipomov, xfecha, xfecobro, xpagado, xconcepto: string; xmonto: real);
begin
  inherited Create(xcodbanco, xtcomprob, xtipomov, xfecha, xfecobro, xpagado, xconcepto, xmonto);

  if tlbco = nil then
    begin
      tlbco := TTable.Create(nil);
      tlbco.DataBaseName := MD.DB.GetNamePath;
      tlbco.TableName := 'cheqrec.DB'; tlbco.IndexDefs.Update;
      tlbco.IndexFieldNames := 'Codbanco;Tcomprob;Tipomov';  // Indice primario
    end;
end;

destructor TTChequesrec.Destroy;
begin
  inherited Destroy;
end;

procedure TTChequesrec.conectar;
// Objetivo...: conectar tablas de persistencia
begin
  entbcos.conectar;
  if not tlbco.Active then tlbco.Open;
end;

procedure TTChequesrec.desconectar;
// Objetivo...: desconectar tablas de persistencia
begin
  entbcos.desconectar;
  if tlbco.Active then
    begin
      tlbco.Refresh; tlbco.Close;
    end;
end;

{===============================================================================}

function chequesrec: TTChequesrec;
begin
  if xchequesrec = nil then
    xchequesrec := TTChequesrec.Create('', '', '', '', '', '', '', 0);
  Result := xchequesrec;
end;

{===============================================================================}

initialization

finalization
  xchequesrec.Free;

end.
