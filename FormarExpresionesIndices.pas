unit FormarExpresionesIndices;
{Objetivo ...: de acuerdo al Indice seleccionado; determinar los los Campos que
 Formarán parte de la Búsqueda y su ubicación dentro de la Tabla de Base de Datos}

interface

uses SysUtils, DBTables, DB;

{Declaración de Arrays ...}
var
  iSCampos  : array [1..15] of integer;
  nCampos   : array [1..15] of string;
  exprClaves: array [1..3]  of string;
  posisubstr: array [1..10, 1..2] of byte;   {Parta a Substraer de la Entrada para los Valores de Búsqueda}
  p, ExClave: string;
  v, cClaves, i, ps, f: byte;

procedure Expresion(Tabla: TTable; Indice: string);
function  DeterminarPosicion(xTabla: TTable): byte;
function  DeterminarIndiceActivo(Tabla: TTable): byte;
function  FormarExpresionClave(Tabla: TTable): string;

implementation

procedure Expresion(Tabla: TTable; Indice: string);
var
  t, x     : byte;
  separador: string;
begin
  cClaves := 0;
  i       := 0;
  ps      := 0;
  f       := 0;

  //Tomamos la Expresión de Indice de la Tabla en cuestión
  if Indice <> 'XX00' then  ExClave := FormarExpresionClave(Tabla) else ExClave := tabla.IndexFieldNames;

  {Extraemos Campos de la Tabla carga}
  {... sólo los que tienen la propiedad visible a True y los que no son Calculados}
  v := 0;
  For t := 1 to Tabla.FieldCount do
    if (Tabla.Fields[t-1].Visible) and not (Tabla.Fields[t-1].Calculated) = True then Inc(v);
                                                  {Cantidad de Campos en la Tabla actual}
  For x := 1 to v do iSCampos[x] := Tabla.FieldDefs.Items[x-1].Size;    {Tamaño de los campos de la Tabla}

  {Contamos la Cantidad de Campos que forman la Clave ...}
  {... y vamos aislando los nombres de los campos claves}
  t := 0;
  i := 1;
  ps:= 0;

  //Verificamos el tipo de Tabla para determinar el separador
  if UpperCase(Copy(Tabla.TableName, Length(Tabla.TableName) - 2, Length(Tabla.TableName))) = 'DBF' then separador := '+' else separador := ';';

  while t = 0 do
    begin
      if Copy(ExClave, i, 1) = separador then
        begin
          Inc(cClaves);
          {Averiguamos en que posición de la tabla está la columna que forma la clave}
          DeterminarPosicion(Tabla);
        end
      else
        p := p + Copy(ExClave, i, 1);
      Inc(i);
      if i >= Length(ExClave) then
         begin
           {Finalizamos con el último campo}
           t := 1;
           p := p + Copy(ExClave, i, 1);
           DeterminarPosicion(Tabla);
           posisubstr[ps+1, 2] := Tabla.FieldDefs.Items[f-1].Size;
         end;
    end;
    cClaves := cClaves + 1;
end;

function DeterminarPosicion(xTabla: TTable): byte;
{Objetivo...: Determinar a que columna de la Tabla corresponde el Campo actual de la clave}
var
  x: byte;
begin

  Result := 0;
  For x := 1 to v do
    if xTabla.FieldDefs.Items[x-1].Name = p then
      begin
        Inc(f);
        nCampos[f] := p;
        Inc(ps);
        if ps = 1 then posisubstr[ps, 1] := 1 else
          posisubstr[ps, 1] := posisubstr[ps-1, 1] + xTabla.FieldByName(ncampos[f-1]).Size;
        posisubstr[ps, 2] := xTabla.FieldByName(ncampos[f]).Size;
        Result := x;
      end;
  p := '';
end;

function DeterminarIndiceActivo(Tabla: TTable): byte;
{Objetivo...: Determinar el Nro. de Indice que está en Curso}
var
  x, j : byte;
begin
 j := 0;
 For x := 1 to Tabla.IndexDefs.Count do
    if Tabla.IndexDefs.Items[x-1].Name = Tabla.IndexName then j := x - 1;
 if j <= 0 then j := 0;
 Result := j;
end;

function FormarExpresionClave(Tabla: TTable): string;
{Objetivo...: Determinar el o los campo(s) que componen la clave}
begin
  if Length(Tabla.IndexDefs.Items[DeterminarIndiceActivo(Tabla)].Expression) > 0 then Result := Tabla.IndexDefs.Items[DeterminarIndiceActivo(tabla)].Expression
    else Result := Tabla.IndexDefs.Items[DeterminarIndiceActivo(Tabla)].Fields;
end;

end.
