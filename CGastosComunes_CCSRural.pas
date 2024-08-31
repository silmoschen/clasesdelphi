unit CGastosComunes_CCSRural;

interface

uses CGastos_CCSRural, SysUtils, CListar, DBTables, CBDT, CUtiles, CIDBFM;

type

TTGastosComunes = class(TTGastos)
  Porcentaje, PorLote: Real;
  Recresiduos: String;
 public
  { Declaraciones P�blicas }
  constructor Create;
  destructor  Destroy; override;

  procedure   Grabar(xidgasto, xDescrip: string; xporcentaje, xporlote: Real; xrecresiduos: boolean);
  procedure   getDatos(xidgasto: string);

  procedure   Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
 private
  { Declaraciones Privadas }
  procedure   ListLinea(salida: char); override;
  procedure   ListarTitulo(titulo: String; salida: char); override;
end;

function gastoscom: TTGastosComunes;

implementation

var
  xgastoc: TTGastosComunes = nil;

constructor TTGastosComunes.Create;
begin
  inherited Create;
  tabla := datosdb.openDB('gastoscomunes', '');
end;

destructor TTGastosComunes.Destroy;
begin
  inherited Destroy;
end;

procedure TTGastosComunes.Grabar(xidgasto, xDescrip: string; xporcentaje, xporlote: Real; xrecresiduos: boolean);
// Objetivo...: Grabar Atributos del Objeto
begin
  if Buscar(xidgasto) then tabla.Edit else tabla.Append;
  tabla.FieldByName('idgasto').Value      := xidgasto;
  tabla.FieldByName('Descrip').Value      := xDescrip;
  tabla.FieldByName('porcentaje').AsFloat := xporcentaje;
  tabla.FieldByName('porlote').AsFloat    := xporlote;
  if (xrecresiduos) then tabla.FieldByName('recresiduos').AsString := 'S' else tabla.FieldByName('recresiduos').AsString := 'N';
  try
    tabla.Post;
  except
    tabla.Cancel;
  end;
  datosdb.refrescar(tabla);
end;

procedure  TTGastosComunes.getDatos(xidgasto: string);
// Objetivo...: Retornar/Iniciar Atributos
begin
  inherited getDatos(xidgasto);
  if Buscar(xidgasto) then Begin
    Porcentaje  := tabla.FieldByName('porcentaje').AsFloat;
    Recresiduos := tabla.FieldByName('recresiduos').AsString;
    PorLote  := tabla.FieldByName('porlote').AsFloat;
  end else Begin
    Porcentaje  := 0;
    Porlote := 0;
    Recresiduos := 'N';
  end;
end;

procedure  TTGastosComunes.Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
Begin
  inherited Listar('Listado de Gastos Comunes Consorcistas', orden, iniciar, finalizar, ent_excl, salida);
end;

procedure TTGastosComunes.ListLinea(salida: char);
begin
  List.Linea(0, 0, tabla.FieldByName('idgasto').AsString + '     ' + tabla.FieldByName('Descrip').AsString, 1, 'Courier New, normal, 9', salida, 'N');
  List.importe(95, list.Lineactual, '', tabla.FieldByName('porcentaje').AsFloat, 2, 'Courier New, normal, 9');
  List.Linea(95, list.Lineactual, '', 3, 'Courier New, normal, 9', salida, 'S');
end;

procedure TTGastosComunes.ListarTitulo(titulo: String; salida: char);
begin
  list.Setear(salida);
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ' + titulo, 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'C�d.' + utiles.espacios(3) +  'Descripci�n', 1, 'Courier New, cursiva, 9');
  List.Titulo(91, list.Lineactual, 'Por.', 2, 'Courier New, cursiva, 9');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');
end;

{===============================================================================}

function gastoscom: TTGastosComunes;
begin
  if xgastoc = nil then
    xgastoc := TTGastosComunes.Create;
  Result := xgastoc;
end;

{===============================================================================}

initialization

finalization
  xgastoc.Free;

end.
