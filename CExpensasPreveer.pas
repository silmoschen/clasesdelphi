unit CExpensasPreveer;

interface

uses CtitularPreveer_Expensas, CBDT, SysUtils, DB, DBTables, CIDBFM, CUtiles, CListar,
     CExpensas_Prever;

type

TTExpensas = class(TObject)
  modelo, encabezado, monto: String;
  modelos: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  destroy; override;

  function    Buscar(xidmodelo: ShortInt): Boolean;
  procedure   getDatos(xidmodelo: ShortInt);
  procedure   Grabar(xidmodelo: ShortInt; xmodelo, xencabezado, xmonto: String);

  procedure   Imprimir(xidtitular: String; xfilas, xcolumnas: ShortInt; xanio: String; salida: Char);

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  conexiones: ShortInt;
 protected
  { Declaraciones Protegidas }
end;

function expensas: TTExpensas;

implementation

var
  xexpensas: TTExpensas = nil;

constructor TTExpensas.Create;
begin
  inherited Create;
  modelos := datosdb.openDB('modelosImpr', '');
  if not datosdb.verificarSiExisteCampo('modelosImpr', 'monto', dbs.DirSistema + '\arch') then
    datosdb.tranSQL(dbs.DirSistema + '\arch', 'alter table modelosImpr add monto char(20)');
end;

destructor TTExpensas.Destroy;
begin
  inherited Destroy;
end;

function  TTExpensas.Buscar(xidmodelo: ShortInt): Boolean;
begin
  Result := modelos.FindKey([xidmodelo]);
end;

procedure TTExpensas.getDatos(xidmodelo: ShortInt);
begin
  if Buscar(xidmodelo) then Begin
    modelo     := modelos.FieldByName('modelo').AsString;
    encabezado := modelos.FieldByName('encabezado').AsString;
    monto      := modelos.FieldByName('monto').AsString;
  end else Begin
    modelo := ''; encabezado := ''; monto := '';
  end;
end;

procedure TTExpensas.Grabar(xidmodelo: ShortInt; xmodelo, xencabezado, xmonto: String);
begin
  if Buscar(xidmodelo) then modelos.Edit else modelos.Append;
  modelos.FieldByName('idmodelo').AsInteger  := xidmodelo;
  modelos.FieldByName('modelo').AsString     := xmodelo;
  modelos.FieldByName('encabezado').AsString := xencabezado;
  modelos.FieldByName('monto').AsString      := xmonto;
  try
    modelos.Post
   except
    modelos.Cancel
  end;
end;

procedure TTExpensas.Imprimir(xidtitular: String; xfilas, xcolumnas: ShortInt; xanio: String; salida: Char);
var
  f, c, x: ShortInt; ec, em, ef, ep: String;
  reg: Integer;
begin
  expensa.conectar;
  reg := titular.tperso.RecNo;
  getDatos(1);
  list.NoImprimirPieDePagina;
  titular.getDatos(xidtitular);
  list.Setear(salida);
  list.Titulo(0, 0,  ' ', 1, 'Arial, normal, 8');
  list.IniciarMemoImpresiones(modelos, 'encabezado', 1000);
  list.RemplazarEtiquetasEnMemo('#nombre', titular.nombre);
  list.RemplazarEtiquetasEnMemo('#direccion', titular.domicilio);
  list.RemplazarEtiquetasEnMemo('#contrato', titular.contrato);
  list.RemplazarEtiquetasEnMemo('#anio', xanio);
  list.RemplazarEtiquetasEnMemo('#M', titular.M);
  list.RemplazarEtiquetasEnMemo('#F', titular.F);
  list.RemplazarEtiquetasEnMemo('#P', titular.P);
  list.RemplazarEtiquetasEnMemo('#fallecido', titular.Fallecido);
  list.ListMemo('', 'Arial, normal, 8', 0, salida, nil, 1000);

  // Etiquetas
  For f := 1 to xfilas do Begin
    list.IniciarMemoImpresiones(modelos, 'modelo', 1000);
    // Prorrateo de Montos
    For x := 12 downto 1 do Begin
      expensa.SincronizarMonto(utiles.sLlenarIzquierda(IntToStr(x), 2, '0') + '/' + xanio);
      list.RemplazarEtiquetasEnMemo('#monto' + IntToStr(x), utiles.FormatearNumero(FloatToStr(expensa.MontoBase)));
    end;
    For c := 1 to xcolumnas do Begin
      ec := '#contrato' + IntToStr(c); em := '#M' + IntToStr(c); ef := '#F' + IntToStr(c); ep := '#P' + IntToStr(c);
      list.RemplazarTodasLasEtiquetasEnMemo(em, titular.M);
      list.RemplazarTodasLasEtiquetasEnMemo(ef, titular.F);
      list.RemplazarTodasLasEtiquetasEnMemo(ep, titular.P);
      list.RemplazarTodasLasEtiquetasEnMemo(ec, titular.contrato);
      list.RemplazarTodasLasEtiquetasEnMemo('#A1', Copy(xanio, 3, 2));
    end;

    list.ListMemo('', 'Arial, normal, 8', 0, salida, nil, 1000);
  end;

  list.CompletarPagina;

  titular.BuscarPorNombre('');
  titular.tperso.MoveBy(reg-1);
  expensa.desconectar;

  list.FinList;
end;

procedure TTExpensas.conectar;
begin
  titular.conectar;
  if conexiones = 0 then modelos.Open;
  Inc(conexiones);
end;

procedure TTExpensas.desconectar;
begin
  titular.desconectar;
  if conexiones > 0 then Dec(conexiones);
  if conexiones = 0 then modelos.Close;
end;

{===============================================================================}

function expensas: TTExpensas;
begin
  if xexpensas = nil then
    xexpensas := TTExpensas.Create;
  Result := xexpensas;
end;

{===============================================================================}

initialization

finalization
  xexpensas.Free;

end.
