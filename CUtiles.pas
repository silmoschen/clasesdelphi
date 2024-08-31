unit CUtiles;

interface

uses
  SysUtils, WinTypes, Classes, Mask, Forms, Dialogs, {AutentificacionUsuario,}
  DepurarDatos, Controls, Graphics, Windows, Messages, StdCtrls, CUtilidadesDiscos, ProcesandoDatos,
  CExpira;

const
  meses: array [1..12] of String = ('Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Setiembre', 'Octubre', 'Noviembre', 'Diciembre');

type

TTUtiles = class(TObject)            // Superclase
    dias_adicionales: Integer;
    usuarioSel: String;
  public
    constructor Create;
    destructor  destroy; override;

    function    Sionoct(Valor: string; Cadena: String; MensgError: string): boolean;           {Valida una Cadena/Char Ingresado}
    procedure   LlenarIzquierda(Cadena: TMaskEdit; Largo: Integer; Caracter: String);  {Completa una cadena con un valor por la izquierda}
    function    sLlenarIzquierda(Cadena: string; Largo: Integer; Caracter: String): string;
    function    QuitarCaracteresIzquierda(cadena, caracter: String): String;
    function    sLlenarDerecha(Cadena: string; Largo: Integer; Caracter: String): string;
    function    espacios(Longitud: integer): string;
    function    StrQuitarCaracteresEspeciales(xcadena: String): String;
    function    StrQuitarTodosLosCaracteresEspeciales(xcadena: String): String;

    function    ctrlFecha(fecha: TMaskEdit): boolean; overload;
    function    ctrlFecha(fecha, msg: String): boolean; overload;
    function    ExprFecha(fecha: TMaskEdit): string;
    function    sExprFecha(fecha: string): string;
    function    sExprFecha2000(fecha: string): string;
    function    sFormatoFecha(Fecha: string): string;
    function    sFormatoFechaDDMMAAAA(Fecha: string): string;
    function    FechaCompleta(fecha: String): String;
    function    ultFechaMes(mes, anio: string): string;
    function    rangofechas(fechainicio: string; fechacierre, fecha: string): boolean;
    function    RepararFecha(xfecha: String): String;
    function    setFechaGregoriana(xfecha: String): String;
    function    FechaDiaDeLaSemana(xfecha: String): String;
    function    setFechaJuliana(xfecha: string): String;
    function    setPeriodoAPartirDeUnaFecha(xfecha: String): String;

    function    ctrlPeriodo(p1, p2, error: string; opcion: integer): boolean;
    function    verificarPeriodo(xperiodo: String): Boolean; overload;
    function    verificarPeriodo(xperiodo, xmensajeError: String): Boolean; overload;
    function    PeriodoAnterior(xperiodo: String): String;
    function    RestarPeriodo(xperiodo, xmeses: String): String;
    function    SumarPeriodo(xperiodo, xmeses: String): String;
    function    PeriodoSinSeparador(xperiodo: String): String;
    function    PeriodoIntervaloMeses(xperinicial, xperfinal: String): String;
    function    getPeriodoAAAAMM(xperiodo: string): string;
    function    getPeriodoMMAAAA(xperiodo: string): string;
    function    ultimodiames(mes, anio: string): string;
    function    RestarMeses(xfecha, xmeses: string): string;
    function    FechaRestarDias(xfecha: string; xdias: integer): string;
    function    FechaSumarDias(xfecha: string; xdias: integer): string;
    function    FechaSumarMeses(xfecha, xdiainicial: String; xmeses: Integer): String;
    function    RestarFechas(xfechaFinal, xfechaInicial: String): String;
    function    FechaPrimerDiaDelAnio: String;
    function    FechaUltimoDiaDelAnio: String;
    function    FormatearNumero(valor: string): string; overload;
    function    FormatearNumero(valor, mascara: string): string; overload;
    function    RedondearNumero(valor: string): string;
    function    FormatearNumeroSepPuntos(valor: string): string;
    function    AlinearStringDerecha(S: String; N: Integer): String;
    function    StringEnCaracteresEspaciados(xstring: String): String;
    function    VerificarSiElSgtringTieneUnNumeroValido(NumStr : string; Error: String): bool;
    function    idregistro: string;
    function    BajaRegistro(Leyenda: string): boolean;
    function    DarDeAlta(Msg: string): boolean;
    function    msgSiNo(Msg: string): boolean; overload;
    function    msgSiNo(Msg1, Msg2: string): boolean; overload;
    procedure   msgError(msg: string); overload;
    procedure   msgError(msg, titulo: string); overload;
    function    Proceder1(msg1, msg2: string): boolean;
    procedure   calc_antiguedad(df, hf: string);
    function    getDias: integer;
    function    getMeses: integer;
    function    getAnios: integer;
    function    difHoras(hi, hf: string): string;
    function    getHoras: string;
    function    getMinutos: string;
    function    getSegundos: string;
    function    difMinutos(hi, hf: string): integer;
    function    setEquivTotalHoras(xhora: String): String;
    function    HoraSumarMinutos(xhora, xminutos: String): String;
    function    IdUsuario(idusuario: string): boolean;
    function    getPeriodo: string;
    function    ctrlHora(xhora: string): boolean; overload;
    function    ctrlHora(xhora, xmsg: string): boolean; overload;
    function    setHoraActual24: String; overload;
    function    setHoraActual24(xhora: String): String; overload;
    function    ArreglarHora(xhora: String): String;
    function    totHoras: Integer;
    function    totMinutos: Integer;
    function    totSegundos: Integer;
    function    setHoraCompleta(xhora: String): String;
    function    xIntToLletras(Numero:LongInt): String;
    function    DepurarInformacion(xmensaje: string): boolean;
    function    Edad(FechaNacimiento:string):integer;
    function    Fuente: string;
    function    setMascaraNumeros: string;
    function    setFechaActual: string;
    function    setMes(xmes: ShortInt): String;
    function    setPeriodoActual: String;
    function    setPeriodo(xfecha: String): String;
    function    setNro2Dec(xnumero: Real): Real;

    function    verificarItemsEnLista(listArray: Array of String; xitems: String): Boolean; overload;
    function    verificarItemsEnLista(listArray: Array of String; xitems: String; ini_string, fin_string: ShortInt): Boolean; overload;
    function    ObtenerItemsEnLista(listArray: Array of String; xitems: String): Integer;

    function    verificarItemsLista(lista_buscar: TStringList; xitems: String): Boolean;

    function    Potencia(x, y: real): real;
    function    setIdRegistroFecha: String;

    function    validarEmail(xemail, xerror: String): Boolean;
    function    validarNumero(xnumero, xerror: String): Boolean;

    procedure   MsgProcesandoDatos(xmsg: String);
    procedure   MsgFinalizarProcesandoDatos;

    function    setMontoSinSignosDecimales(xnumero: String; xancho: Integer): String;

    function    setCompletarNroEnteroConPuntos(xnrodoc: String): String;

    function    StringLongitudFija(xstring: String; xlargo: Integer): String;
    function    StringRemplazarCaracteres(xcadena, xcaracter, xnuevo_caracter: String): String;
    function    StringQuitarCaracteresEnBlanco(xcadena: String): String;
    function    StringQuitarCaracteresEnNumeros(xcadena: String): String;

    function    ValidarCUIT(xcuit:String):boolean;
    function    ObtenerDigitoVerificadorCUIT(xcuit: String): String;

    function    getGuid: string;

    function   getNumberMask(xn: string): string;
  private
    StringFound    : boolean;
    dia, mes, anio, DigitoVerif: integer;
    horas, minutos, segundos: string;
    __tm: TMaskEdit;
    function sepaDecimal: string;
    function CantidadDiasMes(xfecha: String): Integer;
    function FechaSumarUnMes(xfecha, xdiainicial: String): String;
end;

function utiles: TTUtiles;

implementation

var
  xutiles: TTUtiles = nil;

constructor TTUtiles.Create;
begin
  inherited Create;
end;

destructor TTUtiles.destroy;
begin
  inherited Destroy;
end;

function TTUtiles.Sionoct(Valor: string; Cadena: String; MensgError: string): boolean;
begin
  StringFound := False;
  Result      := False;
  if Pos(Valor, Cadena) > 0 then Result := True else
    if Length(Trim(MensgError)) > 0 then msgError(MensgError);
end;

procedure TTUtiles.LlenarIzquierda(Cadena: TMaskEdit; Largo: Integer; Caracter: String);
{Objetivo....: Completar un string con alg�n valor por la izquierda}
var
  xcad, ncad       : String;
  xlargo, limite, i: Integer;

begin
  xcad   := Trim(Cadena.Text);
  xlargo := Length(xcad);
  limite := largo - xlargo;

  For i := 1 to Limite do
    ncad := ncad + caracter;

  Cadena.Text := '';
  Cadena.Text := ncad + xcad;
end;

function TTUtiles.sLlenarIzquierda(Cadena: string; Largo: Integer; Caracter: String): string;
var
  xcad, ncad       : String;
  xlargo, limite, i: Integer;

begin
  xcad   := Trim(Cadena);
  xlargo := Length(xcad);
  limite := largo - xlargo;

  For i := 1 to Limite do
    ncad := ncad + caracter;

  Cadena := '';
  Cadena := ncad + xcad;
  Result := cadena;
end;

function TTUtiles.QuitarCaracteresIzquierda(cadena, caracter: String): String;
var
  nstr: String; i: Integer;
begin
  for i := 1 to Length(cadena) do Begin
    if lowercase(Copy(cadena, i, 1)) <> lowercase(caracter) then Begin
      nstr := nstr + Copy(cadena, i, 1);
      Break;
    end;
  end;
  nstr := nstr + Copy(cadena, i+1, Length(cadena) - i);
  Result := nstr;
end;

function TTUtiles.sLlenarDerecha(Cadena: string; Largo: Integer; Caracter: String): string;
var
  xcad, ncad       : String;
  xlargo, limite, i: Integer;

begin
  xcad   := Trim(Cadena);
  xlargo := Length(xcad);
  limite := largo - xlargo;

  For i := 1 to Limite do
    ncad := ncad + caracter;

  Cadena := '';
  Cadena := xcad + ncad;
  Result := cadena;
end;

function TTUtiles.espacios(Longitud: integer): string;
{Objetivo....: devolver un string de N espacios}
var
  x: integer;
  l: string;
begin
  l := '';
  For x := 1 to Longitud do l := l + ' ';
  Result := l;
end;

function TTUtiles.StrQuitarCaracteresEspeciales(xcadena: String): String;
const
  c = 7;
  acentosMI: array[1..c] of String = ('�', '�', '�', '�', '�', '�', '�');
  valoresMI: array[1..c] of String = ('a', 'e', 'i', 'o', 'u', '#', '.');
  acentosMA: array[1..c] of String = ('�', '�', '�', '�', '�', '�', '�');
  valoresMA: array[1..c] of String = ('A', 'E', 'I', 'O', 'U', '#', '.');
var
  i, j: Integer;
  nstr, v: String;
begin
  nstr := xcadena;
  For i := 1 to Length(TrimRight(xcadena)) do Begin
    For j := 1 to c do Begin
      if Copy(xcadena, i, 1) = acentosMI[j] then Begin
        Delete(nstr, i, 1);
        v := valoresMI[j];
        Insert(v, nstr, i);
      end;
    end;
  end;
  For i := 1 to Length(TrimRight(xcadena)) do Begin
    For j := 1 to c do Begin
      if Copy(xcadena, i, 1) = acentosMA[j] then Begin
        Delete(nstr, i, 1);
        v := valoresMA[j];
        Insert(v, nstr, i);
      end;
    end;
  end;
  Result := nstr;
end;

{const
  c = 13;
  acentosMI: array[1..c] of String = ('�', '�', '�', '�', '�', '�', '�', '�', '�', '�', '�', '�', '�');
  valoresMI: array[1..c] of String = ('a', 'e', 'i', 'o', 'u', 'n', '.', '', 'a', 'e', 'i', 'o', 'u');
  acentosMA: array[1..c] of String = ('�', '�', '�', '�', '�', '�', '�', '�', '�', '�', '�', '�', '�');
  valoresMA: array[1..c] of String = ('A', 'E', 'I', 'O', 'U', 'N', '.', '.', 'A', 'E', 'I', 'O', 'U');

var
  i, j: Integer;
  nstr, v, cf: String;
begin
  nstr := xcadena;
  For i := 1 to Length(TrimRight(xcadena)) do Begin
    For j := 1 to c do Begin
      if Copy(xcadena, i, 1) = acentosMI[j] then Begin
        Delete(nstr, i, 1);
        v := valoresMI[j];
        Insert(v, nstr, i);
      end;
    end;
  end;
  For i := 1 to Length(TrimRight(xcadena)) do Begin
    For j := 1 to c do Begin
      if Copy(xcadena, i, 1) = acentosMA[j] then Begin
        Delete(nstr, i, 1);
        v := valoresMA[j];
        Insert(v, nstr, i);
      end;
    end;
  end;

  {for i := 1 to length(nstr) do begin
    if (uppercase(Copy(nstr, i, 1)) >= 'A') and (uppercase(Copy(nstr, i, 1)) <= 'Z') then cf := cf + Copy(nstr, i, 1);
    if (uppercase(Copy(nstr, i, 1)) >= '0') and (uppercase(Copy(nstr, i, 1)) <= '9') then cf := cf + Copy(nstr, i, 1);
    if (Copy(nstr, i, 1) = '-') or (Copy(nstr, i, 1) = '_') or (Copy(nstr, i, 1) = '(') or (Copy(nstr, i, 1) = ')') or
       (Copy(nstr, i, 1) = '[') or (Copy(nstr, i, 1) = ']') or (Copy(nstr, i, 1) = '') or
       (Copy(nstr, i, 1) = '*') or (Copy(nstr, i, 1) = '+')
       then cf := cf + Copy(nstr, i, 1);
    if (Copy(nstr, i, 1) = ' ') then cf := cf + Copy(nstr, i, 1);
  end;

  //Result := cf;

  result := nstr;
end;}

function TTUtiles.StrQuitarTodosLosCaracteresEspeciales(xcadena: String): String;
const
  c = 13;
  acentosMI: array[1..c] of String = ('�', '�', '�', '�', '�', '�', '�', '�', '�', '�', '�', '�', '�');
  valoresMI: array[1..c] of String = ('a', 'e', 'i', 'o', 'u', 'n', '.', '', 'a', 'e', 'i', 'o', 'u');
  acentosMA: array[1..c] of String = ('�', '�', '�', '�', '�', '�', '�', '�', '�', '�', '�', '�', '�');
  valoresMA: array[1..c] of String = ('A', 'E', 'I', 'O', 'U', 'N', '.', '.', 'A', 'E', 'I', 'O', 'U');

var
  i, j: Integer;
  nstr, v, cf: String;
begin
  nstr := xcadena;
  For i := 1 to Length(TrimRight(xcadena)) do Begin
    For j := 1 to c do Begin
      if Copy(xcadena, i, 1) = acentosMI[j] then Begin
        Delete(nstr, i, 1);
        v := valoresMI[j];
        Insert(v, nstr, i);
      end;
    end;
  end;
  For i := 1 to Length(TrimRight(xcadena)) do Begin
    For j := 1 to c do Begin
      if Copy(xcadena, i, 1) = acentosMA[j] then Begin
        Delete(nstr, i, 1);
        v := valoresMA[j];
        Insert(v, nstr, i);
      end;
    end;
  end;

  for i := 1 to length(nstr) do begin
    if (uppercase(Copy(nstr, i, 1)) >= 'A') and (uppercase(Copy(nstr, i, 1)) <= 'Z') then cf := cf + Copy(nstr, i, 1);
    if (uppercase(Copy(nstr, i, 1)) >= '0') and (uppercase(Copy(nstr, i, 1)) <= '9') then cf := cf + Copy(nstr, i, 1);
    if (Copy(nstr, i, 1) = '-') or (Copy(nstr, i, 1) = '_') or (Copy(nstr, i, 1) = '(') or (Copy(nstr, i, 1) = ')') or
       (Copy(nstr, i, 1) = '[') or (Copy(nstr, i, 1) = ']') or (Copy(nstr, i, 1) = '') or
       (Copy(nstr, i, 1) = '*') or (Copy(nstr, i, 1) = '+')
       then cf := cf + Copy(nstr, i, 1);
    if (Copy(nstr, i, 1) = ' ') then cf := cf + Copy(nstr, i, 1);
  end;

  result := cf;
end;
      
function  TTUtiles.ctrlFecha(fecha: TMaskEdit): boolean;
{Objetivo....: validar fechas}
var
  estado: boolean;
begin
  if Length(Trim(fecha.Text)) > 4 then
    begin
      dia    := StrToInt(Copy(fecha.Text, 1,2));
      mes    := StrToInt(Copy(fecha.Text, 4,2));
      anio   := StrToInt(Copy(fecha.Text, 7,2));
      estado := True;
    end
  else
    estado := False;
  {Control de Meses}
  if (mes < 1) or (mes > 12) then estado := False;
  {Control de d�as}
  {Meses de 31 d�as}
  if (mes = 1) or (mes = 3) or (mes = 5) or (mes = 7) or (mes = 8) or (mes = 10) or (mes = 12) then
    if (dia < 0) or (dia > 31) then estado := False;
  {Meses de 30 d�as}
  if (mes = 4) or (mes = 6) or (mes = 9) or (mes = 11) then
     if (dia < 0) or (dia > 30) then estado := False;
  {Mes de Febrero}
  if mes = 2 then
    begin
      if (anio mod 4 = 0) and (dia > 29) then estado := False;
      if not (anio mod 4 = 0) and (dia > 28) then estado := False;
    end;

  if not estado then MsgError('La Fecha introducida es Incorrecta ...!');
  if estado then Begin
    expira.Verificar(fecha.Text);
    Result := True;
  end else Result := False;
end;

function  TTUtiles.ctrlFecha(fecha, msg: String): boolean;
var
  estado: boolean;
begin
  if Length(Trim(fecha)) > 4 then
    begin
      dia    := StrToInt(Copy(fecha, 1,2));
      mes    := StrToInt(Copy(fecha, 4,2));
      anio   := StrToInt(Copy(fecha, 7,2));
      estado := True;
    end
  else
    estado := False;
  {Control de Meses}
  if (mes < 1) or (mes > 12) then estado := False;
  {Control de d�as}
  {Meses de 31 d�as}
  if (mes = 1) or (mes = 3) or (mes = 5) or (mes = 7) or (mes = 8) or (mes = 10) or (mes = 12) then
    if (dia < 0) or (dia > 31) then estado := False;
  {Meses de 30 d�as}
  if (mes = 4) or (mes = 6) or (mes = 9) or (mes = 11) then
     if (dia < 0) or (dia > 30) then estado := False;
  {Mes de Febrero}
  if mes = 2 then
    begin
      if (anio mod 4 = 0) and (dia > 29) then estado := False;
      if not (anio mod 4 = 0) and (dia > 28) then estado := False;
    end;

  if not estado then
    if Length(Trim(msg)) > 0 then MsgError(msg);
  if estado then Begin
    expira.Verificar(fecha);
    Result := True;
  end else Result := False;
end;

function  TTUtiles.ExprFecha(fecha: TMaskEdit): string;
{Objetivo....: Dada una fecha, convertirla al Formato aaaammdd}
begin
  Result := sExprFecha(fecha.Text);
end;

function  TTUtiles.sExprFecha(fecha: string): string;
{Objetivo....: Dada una fecha, convertirla al Formato aaaammdd}
var
  sFecha, anio: string;
begin
  //Result := '';
  if Length(Trim(fecha)) > 4 then
    begin
      if Length(Trim(sFecha)) = 8 then sFecha := FormatDateTime('dd/MM/yyyy', StrToDateTime(Fecha)) else sFecha := fecha;
      if Length(Trim(fecha)) = 8 then
        if (Copy(fecha, 7, 2) > '07') then anio := '19' + Copy(fecha, 7, 2) else anio := Copy(sFecha, 7, 4);
      if Length(Trim(fecha)) > 8 then
        if (Copy(fecha, 9, 2) > '07') then anio := '19' + Copy(fecha, 7, 2) else anio := Copy(sFecha, 7, 4);
      if Length(Trim(anio)) < 4 then anio := '20' + anio;
      Result := anio + Copy(sFecha, 4, 2) + Copy(sFecha, 1, 2);
    end
  else
    Result := '';
end;

function  TTUtiles.sExprFecha2000(fecha: string): string;
{Objetivo....: Dada una fecha, convertirla al Formato aaaammdd}
var
  sFecha, anio, s: string;
begin
  if Length(Trim(fecha)) > 4 then
    begin
      {
      if (Length(Trim(fecha)) = 8) then begin
        s := copy(fecha, 1, 6) + '20' + copy(fecha, 7, 2);
        fecha := s;
      end;
      }
      
      sFecha := FormatDateTime('dd/MM/yyyy', StrToDateTime(Fecha));
      {if Length(Trim(fecha)) = 8 then
        if (Copy(fecha, 7, 2) > '07') then anio := '20' + Copy(fecha, 7, 2) else anio := Copy(sFecha, 7, 4);
      if Length(Trim(fecha)) > 8 then
        if (Copy(fecha, 9, 2) > '07') then anio := '20' + Copy(fecha, 7, 2) else anio := Copy(sFecha, 7, 4);
      if Copy(anio, 3, 2) > '50' then anio := '19' + Copy(anio, 3, 2);}

      anio := Copy(sFecha, 7, 4);
      //if Copy(anio, 1, 2) = '19' then anio := '20' + Copy(anio, 3, 2);
      Result := anio + Copy(sFecha, 4, 2) + Copy(sFecha, 1, 2);
    end
  else
    Result := '';
end;

function  TTUtiles.sFormatoFecha(Fecha: string): string;
{Objetivo...: Tomar un dato tipo string y convertirlo en una expresi�n Fecha del tipo dd/mm/aa}
begin
  Result := '';
  if Length(Trim(Fecha)) = 8 then Result := Copy(Fecha, 7, 2) + '/' + Copy(Fecha, 5, 2) + '/' + Copy(Fecha, 3, 2);
end;

function  TTUtiles.sFormatoFechaDDMMAAAA(Fecha: string): string;
{Objetivo...: Tomar un dato tipo string y convertirlo en una expresi�n Fecha del tipo dd/mm/aa}
begin
  Result := '';
  if Length(Trim(Fecha)) = 8 then Result := Copy(Fecha, 7, 2) + '/' + Copy(Fecha, 5, 2) + '/' + Copy(Fecha, 1, 4);
end;

function  TTUtiles.FechaCompleta(fecha: String): String;
{Objetivo...: Tomar un dato tipo string y convertirlo en una expresi�n Fecha del tipo dd/mm/aaaa}
var
  f: String;
begin
  Result := '';
  f := sExprFecha2000(fecha);
  Result := Copy(f, 7, 2) + '/' + Copy(f, 5, 2) + '/' + Copy(f, 1, 4);
end;

function  TTUtiles.ultFechaMes(mes, anio: string): string;
// Objetivo...: Dado un mes Determinado, obtener el �ltimo d�a h�bil
begin
  if (mes = '01') or (mes = '03') or (mes = '05') or (mes = '07') or (mes = '08') or (mes = '10') or (mes = '12') then Result := '31';
  if (mes = '04') or (mes = '06') or (mes = '09') or (mes = '11') then Result := '30';
  if mes = '02' then
    if StrToInt(anio) mod 4 = 0 then Result := '29' else Result := '28';
end;

function TTUtiles.FormatearNumero(valor: string): string;
// Objetivo...: Dar Formato a una expresion numerica tipo
var
  v, m, c: String;
begin
  m := setMascaraNumeros;
  v := valor;
  if Pos('.', valor) > 0 then Begin
    if (Length(Trim(valor)) - Pos('.', valor)) <= 3 then
      c := utiles.sLlenarIzquierda(c, (Length(Trim(valor)) - Pos('.', valor)), '0')
    else
      c := utiles.sLlenarIzquierda(c, 4, '0');
    m := '##########0.' + c;
  end;
  if Pos(',', valor) > 0 then Begin
    if (Length(Trim(valor)) - Pos(',', valor)) <= 3 then
      c := utiles.sLlenarIzquierda(c, (Length(Trim(valor)) - Pos(',', valor)), '0')
    else
      c := utiles.sLlenarIzquierda(c, 4, '0');
    m := '##########0.' + c;
  end;
  m := setMascaraNumeros;

  if sepaDecimal = ',' then Begin
    if Pos('.', valor) > 0 then v := Copy(valor, 1, (Pos('.', valor) - 1)) + sepaDecimal + Copy(valor, (Pos('.', valor) + 1), 5);
  end else Begin
    if Pos(',', valor) > 0 then v := Copy(valor, 1, (Pos(',', valor) - 1)) + sepaDecimal + Copy(valor, (Pos(',', valor) + 1), 5);
  end;
  Result := '0' + sepaDecimal + '00';
  if Length(Trim(valor)) > 0 then
    Result := FormatFloat(m, StrToFloat(v));
end;

function TTUtiles.RedondearNumero(valor: string): string;
var
  s: String;
begin
  s := formatearnumero(valor, '##########0.0000');
  result := copy(s, 1, length(s) - 2);
end;

function TTUtiles.FormatearNumeroSepPuntos(valor: string): string;
// Objetivo...: Formatear un n�mero con . como separador decimal
var
  sepaDecimal: String;
  v, m, c: String;
Begin
  m := setMascaraNumeros;
  v := valor;
  if Pos('.', valor) > 0 then Begin
    if (Length(Trim(valor)) - Pos('.', valor)) <= 3 then
      c := utiles.sLlenarIzquierda(c, (Length(Trim(valor)) - Pos('.', valor)), '0')
    else
      c := utiles.sLlenarIzquierda(c, 4, '0');
    m := '###########0.' + c;
  end;
  if Pos(',', valor) > 0 then Begin
    if (Length(Trim(valor)) - Pos(',', valor)) <= 3 then
      c := utiles.sLlenarIzquierda(c, (Length(Trim(valor)) - Pos(',', valor)), '0')
    else
      c := utiles.sLlenarIzquierda(c, 4, '0');
    m := '############0.' + c;
  end;
  m := setMascaraNumeros;

  if sepaDecimal = ',' then Begin
    if Pos('.', valor) > 0 then v := Copy(valor, 1, (Pos('.', valor) - 1)) + sepaDecimal + Copy(valor, (Pos('.', valor) + 1), 5);
  end else Begin
    if Pos(',', valor) > 0 then v := Copy(valor, 1, (Pos(',', valor) - 1)) + sepaDecimal + Copy(valor, (Pos(',', valor) + 1), 5);
  end;
  Result := '0' + sepaDecimal + '00';
  if Length(Trim(valor)) > 0 then
    Result := FormatFloat(m, StrToFloat(v));
End;

function TTUtiles.FormatearNumero(valor, mascara: string): string;
// Objetivo...: Dar Formato a una expresion numerica tipo, a partir de una mascara de usuario
var
  v: String;
begin
   v := valor;
  if sepaDecimal = ',' then Begin
    if Pos('.', valor) > 0 then v := Copy(valor, 1, (Pos('.', valor) - 1)) + sepaDecimal + Copy(valor, (Pos('.', valor) + 1), 5);
  end else Begin
    if Pos(',', valor) > 0 then v := Copy(valor, 1, (Pos(',', valor) - 1)) + sepaDecimal + Copy(valor, (Pos(',', valor) + 1), 5);
  end;
  Result := '0' + sepaDecimal + '00';
  if Length(Trim(valor)) > 0 then
    Result := FormatFloat(mascara, StrToFloat(v));
end;

function TTUtiles.idregistro: string;
begin
  Result := Copy(TimeToStr(Time), 1, 2) + Copy(TimeToStr(Time), 4, 2) + Copy(TimeToStr(Time), 7, 2) + IntToStr(random(9999));
end;

function TTUtiles.DarDeAlta(Msg: string): boolean;
begin
  if MessageDlg('Seguro para Dar de Alta' + CHR(13) + Msg + ' ?', mtConfirmation, [mbYes, mbCancel], 0) = mrYes then  Result := True else Result := False;
  //if Application.MessageBox(PChar('Seguro para Dar de Alta' + CHR(13) + Msg + ' ?'), 'Nuevo Registro', MB_OKCANCEL + MB_DEFBUTTON1) = IDOK then Result := True else Result := False;
end;

function TTUtiles.msgSiNo(Msg: string): boolean;
begin
  {Application.CreateForm(TMensajeSiNo, MensajeSiNo);
  MensajeSiNo.Det.Caption := Msg;
  MensajeSiNo.ShowModal;
  if MensajeSiNo.siono then Result := True else Result := False;
  MensajeSiNo.Free;}
  if MessageDlg(Msg, mtConfirmation, [mbYes, mbNo], 0) = mrYes then  Result := True else Result := False;
end;

function TTUtiles.msgSiNo(Msg1, Msg2: string): boolean;
begin
  if MessageDlg(Msg1 + CHR(13) + Msg2, mtConfirmation, [mbYes, mbNo], 0) = mrYes then  Result := True else Result := False;
end;

procedure TTUtiles.msgError(msg: string);
begin
  MessageDlg(msg, mtError, [mbOK], 0);
end;

procedure TTUtiles.msgError(msg, titulo: string);
begin
  Application.MessageBox(PChar(msg), PChar(titulo), MB_OK + MB_DEFBUTTON1);
end;

function TTUtiles.BajaRegistro(Leyenda: string): boolean;
begin
  if Application.MessageBox(PChar(Leyenda), 'Borrar', MB_OKCANCEL + MB_DEFBUTTON1) = IDOK then Result := True else Result := False;
end;

function TTUtiles.rangofechas(fechainicio: string; fechacierre, fecha: string): boolean;
begin
 Result := False;
 {Verificamos el rango de fechas ...}
 if (utiles.sExprFecha2000(fecha) < utiles.sExprFecha2000(fechainicio)) or (utiles.sExprFecha2000(fecha) > utiles.sExprFecha2000(fechacierre)) then msgError('Fecha Incorrecta o Fuera de Per�odo ...!') else Result := True;
end;

function TTUtiles.setFechaGregoriana(xfecha: String): String;
// Obejtivo...: Devolver la fecha gregoriana
var
  f: String;
Begin
  f := sExprFecha2000(xfecha);
  Result := Copy(f, 3, 2) + Copy(f, 5, 2) + Copy(f, 7, 2);
end;

function TTUtiles.FechaDiaDeLaSemana(xfecha: String): String;
  var dia, a, m, d:byte;
      fecha: String;
begin
   fecha := sExprFecha2000(xfecha);
   a     := StrToInt(Copy(fecha, 1, 4));
   m     := StrToInt(Copy(fecha, 5, 2));
   d     := StrToInt(Copy(fecha, 7, 2));
   dia   := DayOfWeek(encodedate(a, m, d));
   case dia of
     7: Result := 'Domingo';
     1: Result := 'Lunes';
     2: Result := 'Martes';
     3: Result := 'Mi�rcoles';
     4: Result := 'Jueves';
     5: Result := 'Viernes';
     6: Result := 'S�bado';
   end;
end;

function TTUtiles.setFechaJuliana(xfecha: string): String;

function Juliana(Fecha: string): Integer;
var
  dTemp:TDate;
begin
  dTemp := StrToDate(Fecha);
  Result:= trunc(dTemp-
                StrToDate(FormatDateTime('01/01/yyyy',dTemp))
                )+1;
end;

begin
   Result := IntToStr( Juliana(xfecha) );
end;

function TTUtiles.setPeriodoAPartirDeUnaFecha(xfecha: String): String;
// Objetivo...: Devolver el Per�odo a partir de una fecha
var
  f: String;
begin
  f := sExprFecha2000(xfecha);
  Result := Copy(f, 5, 2) + '/' + Copy(f, 1, 4);
end;

function TTUtiles.ctrlPeriodo(p1, p2, error: string; opcion: integer): boolean;
// Objetivo...: Verificar que una Fecha este en un rango determinado
begin
  if opcion = 0 then Result := True else
    begin
      if p1 <> p2 then
        begin
          msgError(error);
          Result := False;
        end
      else
        Result := True;
    end;
end;

function TTUtiles.RepararFecha(xfecha: String): String;
// Objetivo...: Reacomodar Fechas
var
  f: String;
Begin
  f := xfecha;
  if Pos('/', f) = 2 then f := '0' + f;
  if Pos('/', f) = 4 then f := Copy(f, 1, 3) + '0' + Trim(Copy(f, 4, 10));
  Result := f;
end;

function TTUtiles.PeriodoAnterior(xperiodo: String): String;
// Objetivo...: Devolver el periodo anterior
var
  p, a: String;
begin
  a := Copy(xperiodo, 1, 2);
  p := Copy(xperiodo, 4, 4);
  if a > '01' then a := sLlenarIzquierda(IntToStr(StrToInt(a) - 1), 2, '0') else Begin
    a := '12';
    p := sLlenarIzquierda(IntToStr(StrToInt(p) - 1), 4, '0');
  end;
  Result := a + '/' + p;
end;

function TTUtiles.verificarPeriodo(xperiodo: String): Boolean;
// Objetivo...: Controlar un periodo ingresado
begin
  if ((Copy(xperiodo, 1, 2) > '00') and (Copy(xperiodo, 1, 2) < '13')) and (Length(Trim(xperiodo)) = 7) then Result := True else Begin
    msgError('Periodo Incorrecto ...!');
    Result := False;
  end;
end;

function TTUtiles.verificarPeriodo(xperiodo, xmensajeError: String): Boolean;
// Objetivo...: Controlar un periodo ingresado
begin
  if (length(trim(xperiodo)) <> 7) then begin
    result := false;
    exit;
  end;

  if Length(Trim(xperiodo)) = 1 then Result := True else Begin
    if (Copy(xperiodo, 1, 2) > '00') and (Copy(xperiodo, 1, 2) < '13') then Result := True else Begin
      if Length(Trim(xmensajeError)) > 0 then msgError(xmensajeError);
      Result := False;
    end;
  end;
end;

function TTUtiles.RestarPeriodo(xperiodo, xmeses: String): String;
// Objetivo...: restar per�odo
var
  r, t: ShortInt; p: LongInt;
begin
  r := StrToInt(Copy(xperiodo, 1, 2)) - StrToInt(xmeses);
  if r <= 0 then Begin
    t := 12 - (r * (-1));
    p := StrToInt(Copy(xperiodo, 4, 4)) - 1;
    Result := sLlenarIzquierda(IntToStr(t), 2, '0') + '/' + IntToStr(p);
  end else
    Result := sLlenarIzquierda(IntToStr(r), 2, '0') + Copy(xperiodo, 3, 5);
end;

function TTUtiles.SumarPeriodo(xperiodo, xmeses: String): String;
// Objetivo...: sumar per�odo
var
  r, t: ShortInt; p: LongInt;
begin
  r := StrToInt(Copy(xperiodo, 1, 2)) + StrToInt(xmeses);
  if r > 12 then Begin
    t := (12 - r) * (-1);
    p := StrToInt(Copy(xperiodo, 4, 4)) + 1;
    Result := sLlenarIzquierda(IntToStr(t), 2, '0') + '/' + IntToStr(p);
  end else
    Result := sLlenarIzquierda(IntToStr(r), 2, '0') + Copy(xperiodo, 3, 5);
end;

function TTUtiles.PeriodoSinSeparador(xperiodo: String): String;
//Objetivo...: Devolver un Periodo sin /
Begin
  Result := Copy(xperiodo, 1, 2) + Copy(xperiodo, 4, 4);
end;

function TTUtiles.PeriodoIntervaloMeses(xperinicial, xperfinal: String): String;
//Objetivo...: Devolver el �ltmio D�a del mes
var
  i, j: Integer;
Begin
  j := 0;
  For i := 1 to 12 do
    if (sLlenarIzquierda(IntToStr(i), 2, '0') >= Copy(xperinicial, 1, 2)) then Inc(j);

  if Copy(xperinicial, 4, 4) < Copy(xperfinal, 4, 4) then Begin
    For i := 1 to 12 do
      if (sLlenarIzquierda(IntToStr(i), 2, '0') < Copy(xperfinal, 1, 2)) then Inc(j);
  end;

  Result := IntToStr(j);
end;

function TTUtiles.getPeriodoAAAAMM(xperiodo: string): string;
//Objetivo...: Devolver un periodo en formato aaaamm
begin
  result := copy(xperiodo, 4, 4) + copy(xperiodo, 1, 2);
end;

function TTUtiles.getPeriodoMMAAAA(xperiodo: string): string;
//Objetivo...: Devolver un periodo en formato mm/aaaa
begin
  result := copy(xperiodo, 5, 2) + '/' + copy(xperiodo, 1, 4);
end;

function TTUtiles.ultimodiames(mes, anio: string): string;
//Objetivo...: Devolver el �ltmio D�a del mes
var
  dia: string;
begin
  dia := '';
  if (mes = '01') or (mes = '03') or (mes = '05') or (mes = '07') or (mes = '08') or (mes = '10') or (mes = '12') then dia := '31';
  if (mes = '04') or (mes = '06') or (mes = '09') or (mes = '11') then dia := '30';
  if (mes = '02') and  (StrToInt(anio) mod 4 = 0) then dia := '29';
  if (mes = '02') and  (StrToInt(anio) mod 4 <> 0) then dia := '28';
  Result := dia;
end;

function TTUtiles.RestarMeses(xfecha, xmeses: string): string;
// Objetivo...: Restarle meses una fecha
var
  mes, anio: Integer;
begin
  mes  := StrToInt(Copy(sExprFecha(xfecha), 5, 2)) - StrToInt(xmeses);
  anio := StrToInt(Copy(sExprFecha(xfecha), 1, 4));
  if mes < 1 then Begin
    mes := 12 + mes;
    Dec(anio);
  end;
  Result := Copy(sExprFecha(xfecha), 7, 2) + '/' + sLlenarIzquierda(IntToStr(mes), 2, '0') + '/' + Copy(IntToStr(anio), 3, 2);
end;

function TTUtiles.FechaRestarDias(xfecha: string; xdias: integer): string;
var
  difdias, dmes, danio, ddia: integer;
begin
  difdias := StrToInt(copy(xfecha, 1, 2)) - xdias;
  if difdias > 0 then Result := sLLenarIzquierda(IntToStr(difdias), 2, '0') + Copy(xfecha, 3, 6) else Begin
    danio := StrToInt(sExprFecha(xfecha));
    dmes  := StrToInt(copy(xfecha, 4, 2)) - 1;
    if dmes = 0 then dmes := 1;
    ddia := StrToInt(ultimodiames(sLlenarIzquierda(IntToStr(dmes), 2, '0'), copy(sExprFecha(xfecha), 1, 4))) - xdias;
    if ddia <= 0 then ddia := 1;
    if dmes <= 0 then Begin
      dmes  := 1;
      danio := StrToInt(copy(sExprFecha(xfecha), 1, 4)) - 1;
    end;

   Result := sLlenarIzquierda(IntToStr(ddia), 2, '0') + '/' + sLlenarIzquierda(IntToStr(dmes), 2, '0') + '/' + Copy(IntToStr(danio), 3, 2);
  end;
end;

function TTUtiles.FechaSumarDias(xfecha: string; xdias: integer): string;
{var
  difdias, dmes, danio, ddia, limite: integer; nf: String;}
var
  f: string;
begin
  f := datetostr(strtodate(xfecha) + xdias);
  result := copy(f, 1, 6) + copy(f, 9, 2);

  {limite := CantidadDiasMes(xfecha);

  difdias := StrToInt(copy(xfecha, 1, 2)) + xdias;
  if difdias <= limite then Result := sLLenarIzquierda(IntToStr(difdias), 2, '0') + Copy(xfecha, 3, 6) else Begin
    danio := StrToInt(sExprFecha('01' + Copy(xfecha, 3, 6)));
    ddia  := difdias - limite;
    dmes := StrToInt(copy(xfecha, 4, 2)) + 1;

    while difdias > limite do Begin
      difdias  := difdias - limite;
      ddia     := difdias;
      if difdias <= limite then Break;
      Inc(dmes);
    end;

    if ddia <= 0 then ddia := 1;
    if dmes <= 0 then Begin
      dmes  := 1;
      danio := StrToInt(copy(sExprFecha(xfecha), 1, 4)) + 1;
    end;
    if dmes > 12 then Begin
      dmes  := dmes - 12;
      danio := StrToInt(copy(sExprFecha(xfecha), 1, 4)) + 1;
    end;

    nf := sLlenarIzquierda(IntToStr(ddia), 2, '0') + '/' + sLlenarIzquierda(IntToStr(dmes), 2, '0') + '/' + Copy(IntToStr(danio), 3, 2);

    if StrToInt(Copy(nf, 1, 2)) > CantidadDiasMes(nf) then Begin   // Verificamos que no sobrepase el mes
      ddia := StrToInt(Copy(nf, 1, 2)) - CantidadDiasMes(nf);
      Inc(dmes);
      if dmes > 12 then Begin
        dmes  := dmes - 12;
        danio := StrToInt(copy(sExprFecha(xfecha), 1, 4)) + 1;
      end;
    end;

    Result := sLlenarIzquierda(IntToStr(ddia), 2, '0') + '/' + sLlenarIzquierda(IntToStr(dmes), 2, '0') + '/' + Copy(IntToStr(danio), 3, 2);
  end;}
end;

function TTUtiles.FechaSumarUnMes(xfecha, xdiainicial: String): String;
// Objetivo...: Sumar un mes
var
  dmes, danio, limite, din: Integer; nf: String;
begin
  dmes  := StrToInt(Copy(xfecha, 4, 2)) + 1;
  danio := StrToInt(Copy(xfecha, 7, 2));
  if dmes > 12 then Begin
    dmes  := 1;
    danio := danio + 1;
  end;
  if danio = 100 then danio := 0;
  nf   := Copy(xfecha, 1, 3) + sLlenarizquierda(IntToStr(dmes), 2, '0') + '/' + Copy(xfecha, 7, 2);
  limite := CantidadDiasMes(nf);
  if StrToInt(xdiainicial) > limite then din := limite else din := StrToInt(xdiainicial);
  Result := utiles.sLlenarIzquierda(IntToStr(din), 2, '0') + '/' + sLlenarizquierda(IntToStr(dmes), 2, '0') + '/' + sLlenarizquierda(IntToStr(danio), 2, '0');
end;

function TTUtiles.FechaSumarMeses(xfecha, xdiainicial: String; xmeses: Integer): String;
var
  f: String; i: Integer;
Begin
  f := xfecha;
  For i := 1 to xmeses do f := FechaSumarUnMes(f, xdiainicial);
  Result := f;
end;

function TTUtiles.RestarFechas(xfechaFinal, xfechaInicial: String): String;
var
  dias: Word;
Begin
  if sExprFecha2000(xfechaFinal) < sExprFecha2000(xfechaInicial) then Result := '0' else Begin
    dias   := Trunc(StrToDate(xfechaFinal) - StrToDate(xfechaInicial));
    Result := IntToStr(dias);
  end;
end;

function TTUtiles.FechaPrimerDiaDelAnio: String;
Begin
  Result := '01/01/' + Copy(setPeriodoActual, 6, 2);
end;

function TTUtiles.FechaUltimoDiaDelAnio: String;
Begin
  Result := '31/12/' + Copy(setPeriodoActual, 6, 2);
end;

function TTUtiles.CantidadDiasMes(xfecha: String): Integer;
begin
  Result := 0;
  if (Copy(xfecha, 4, 2) = '01') or (Copy(xfecha, 4, 2) = '03') or (Copy(xfecha, 4, 2) = '05') or (Copy(xfecha, 4, 2) = '07') or (Copy(xfecha, 4, 2) = '08') or (Copy(xfecha, 4, 2) = '10') or (Copy(xfecha, 4, 2) = '12') then Result := 31;
  if (Copy(xfecha, 4, 2) = '04') or (Copy(xfecha, 4, 2) = '06') or (Copy(xfecha, 4, 2) = '09') or (Copy(xfecha, 4, 2) = '11') then Result := 30;
  if (Copy(xfecha, 4, 2) = '02') then
    if ((StrToInt(Copy(xfecha, 7, 2))) + 2000) mod 4 = 0 then Result := 29 else Result := 28;
end;

function TTUtiles.Proceder1(msg1, msg2: string): boolean;
begin
  if Application.MessageBox(PChar(msg1 + CHR(13) + msg2), 'Borrar', MB_OKCANCEL + MB_DEFBUTTON1) = IDOK then Result := True else Result := False;
end;

procedure TTUtiles.calc_antiguedad(df, hf: string);
// Objetivo...: Determinar antiguedad entre dos fechas, expresada en dias, meses y anios
var
  anttot: string; j: Integer;
begin
  if Length(Trim(df)) > 4 then
    begin
      anttot := IntToStr(StrToInt(hf) - StrToInt(df));
      // Obtenemos la Antiguedad
      // A�o
      anio := StrToInt(Copy(hf, 1, 4)) - StrToInt(Copy(df, 1, 4));
      // Mes
      mes := StrToInt(Copy(hf, 5, 2)) - StrToInt(df);
      if mes < 0 then
        begin
          mes  := 12 + ((StrToInt(Copy(hf, 5, 2)) - StrToInt(Copy(df, 5, 2))));
          anio := anio - 1;
        end;
      if mes >= 12 then
        begin
          anio := anio + 1;
          mes  := mes - 12;
        end;

      //D�as
      dia := StrToInt(Copy(hf, 7, 2)) - StrToInt(Copy(df, 7, 2));

      if dia < 0 then
        begin
          if (mes = 1) or (mes = 3) or (mes = 5) or (mes = 7) or (mes = 8) or (mes = 10) or (mes = 12) then dia := 31 - (dia * (-1));
          if (mes = 4) or (mes = 6) or (mes = 9) or (mes = 11) then dia := 30 - (dia * (-1));
          if anio mod 4 = 0 then dia := 29 - (dia * (-1)) else dia := 28 - (dia * (-1));

          mes := mes - 1;
          if mes < 0 then mes := 0;
        end;

      if (Copy(df, 5, 2) <= '02') or (Copy(hf, 5, 2) >= '02') then   // Si Febrero esta en el medio
        if dia >= 30 then
          if (StrToInt(Copy(df, 5, 2)) mod 4 = 0) or (StrToInt(Copy(hf, 5, 2)) mod 4 = 0) then dia := dia - 1 else dia := dia - 2;

      dias_adicionales := 0;    //dias adicionales
      for j := StrToInt(Copy(df, 5, 2)) to StrToInt(Copy(df, 5, 2)) do
        if (j = 1) or (j = 3) or (j = 5) or (j = 7) or (j = 8) or (j = 10) or (j = 12) then dias_adicionales := dias_adicionales + 1;
  end;
end;

function TTUtiles.getAnios: integer;
begin
  Result := anio;
end;

function TTUtiles.getMeses: integer;
begin
  Result := mes;
end;

function TTUtiles.getDias: integer;
begin
  Result := dia;
end;

function TTUtiles.difHoras(hi, hf: string): string;
// Objetivo...: Determinar la diferencia entre dos horas
var
  hii, hff, him, hfm, difh, difm, his, difs: integer;
begin
  // Obtenemos la diferencia en horas
  hii   := StrToInt(Copy(hi, 1, 2)); hff := StrToInt(Copy(hf, 1, 2));
  difh  := hff - hii;
  // Obtenemos la diferencia entre minutos
  him   := StrToInt(Copy(hi, 4, 2)); hfm := StrToInt(Copy(hf, 4, 2));
  difm  := hfm - him;

  // Si la diferencia de minutos es negativa
  if difm < 0 then
    begin
      difm := 60 + difm;
      Dec(difh);
    end;

  // Obtenemos la diferencia entre segundos
  his   := StrToInt(Copy(hi, 7, 2)); hfm := StrToInt(Copy(hf, 7, 2));
  difs  := hfm - him;

  // Si la diferencia de minutos es negativa
  if difs < 0 then difs := 60 + difs;

  horas    := sLlenarIzquierda(IntToStr(difh), 2, '0');
  minutos  := sLlenarIzquierda(IntToStr(difm), 2, '0');
  segundos := sLlenarIzquierda(IntToStr(difs), 2, '0');
  Result  := horas + ':' + minutos;
end;

function TTUtiles.getHoras: string;
begin
  Result := horas;
end;

function TTUtiles.getMinutos: string;
begin
  Result := minutos;
end;

function TTUtiles.getSegundos: string;
begin
  Result := segundos;
end;

function TTUtiles.difMinutos(hi, hf: string): integer;
begin
  DifHoras(hi, hf);
  Result := (StrToInt(horas) * 60) + StrToInt(minutos);
end;

function TTUtiles.setEquivTotalHoras(xhora: String): String;
var
  h, m: String;
  p: Integer;
begin
  p := Pos(':', xhora);
  h := Copy(xhora, 1, p-1);
  m := Trim(Copy(xhora, p+1, 5));
  if StrToInt(m) < 60 then Result := xhora else Begin
    m := IntToStr(StrToInt(m) - (60 * (StrToInt(m) div 60)));
    h := IntToStr(StrToInt(h) + (StrToInt(Trim(Copy(xhora, p+1, 5))) div 60));
    if Length(Trim(m)) > 1 then Result := h + ':' + m else Result := h + ':' + m + '0';
  end;
end;

function TTUtiles.IdUsuario(idusuario: string): boolean;
begin
  Result := False;
  {Application.CreateForm(TfmAutentificacion, fmAutentificacion);
  fmAutentificacion.ShowModal;
  if not fmAutentificacion.modificado then Result := False else Begin
    if (fmAutentificacion.autorizar_ingreso) then Result := True else msgError('Identificaci�n Incorrecta ...!');
    if Result then usuarioSel := fmAutentificacion.idusuario.Text else usuarioSel := '';
  end;
  fmAutentificacion.Release; fmAutentificacion := nil;}
end;

function TTUtiles.HoraSumarMinutos(xhora, xminutos: String): String;
var
  h, m: Integer;
Begin
  h := StrToInt(Copy(xhora, 1, 2));
  m := StrToInt(Copy(xhora, 4, 2));
  m := m + StrToInt(xminutos);
  if m >= 60 then Begin
    m := m - 60;
    h := h + 1;
  end;
  Result := sLlenarIzquierda(IntToStr(h), 2, '0') + ':' + sLlenarIzquierda(IntToStr(m), 2, '0') + ':00';
end;

function TTUtiles.getPeriodo: string;
// Objetivo...: devolver el periodo del tipo mm/aaaa
var
  f: string;
begin
  f      := sExprFecha(DateToStr(now));
  Result := Copy(f, 5, 2) + '/' + Copy(f, 1, 4);
end;

function TTUtiles.ctrlHora(xhora: string): boolean;
// Objetivo...: Validar una hora ingresada
var
  r: boolean;
begin
  r := True;
  if Pos(':', xhora) = 1 then xhora := '0' + xhora;
  if Length(Trim(xhora)) > 0 then Begin
    if Length(Trim(Copy(xhora, 1, 2))) = 0 then r := False else
      if (StrToInt(Copy(xhora, 1, 2)) > 24) or (StrToInt(Copy(xhora, 1, 2)) < 0) then r := False;
    if Length(Trim(Copy(xhora, 4, 2))) = 0 then r := False else
      if (StrToInt(Copy(xhora, 4, 2)) > 59) or (StrToInt(Copy(xhora, 4, 2)) < 0) then r := False;
    if Length(Trim(Copy(xhora, 7, 2))) = 0 then r := False else
      if (StrToInt(Copy(xhora, 7, 2)) > 59) or (StrToInt(Copy(xhora, 7, 2)) < 0) then r := False;
  end;

  if not r then msgError('Hora Incorrecta ...!');
  Result := r;
end;

function TTUtiles.ctrlHora(xhora, xmsg: string): boolean;
// Objetivo...: Validar una hora ingresada
var
  r: boolean;
begin
  r := True;
  if Pos(':', xhora) = 1 then xhora := '0' + xhora;
  if Length(Trim(xhora)) > 0 then Begin
    if Length(Trim(Copy(xhora, 1, 2))) = 0 then r := False else
      if (StrToInt(Copy(xhora, 1, 2)) > 24) or (StrToInt(Copy(xhora, 1, 2)) < 0) then r := False;
    if Length(Trim(Copy(xhora, 4, 2))) = 0 then r := False else
      if (StrToInt(Copy(xhora, 4, 2)) > 59) or (StrToInt(Copy(xhora, 4, 2)) < 0) then r := False;
    if Length(Trim(Copy(xhora, 7, 2))) = 0 then r := False else
      if (StrToInt(Copy(xhora, 7, 2)) > 59) or (StrToInt(Copy(xhora, 7, 2)) < 0) then r := False;
  end;

  if not r then
    if Length(Trim(xmsg)) > 0 then msgError(xmsg);
  Result := r;
end;

function TTUtiles.setHoraActual24: String;
// Objetivo...: Devolver la hora actual
begin
  Result := setHoraActual24(FormatDateTime('hh:mm:ss am/pm', Now));
end;

function TTUtiles.ArreglarHora(xhora: String): String;
// Objetivo...: Arreglar hora
var
  h, m, s, p1, p2: Integer;
Begin
  p1 := 0; p2 := 0;
  For h := 1 to Length(Trim(xhora)) do Begin   // Obtenemos delimitadores ':'
    if Copy(xhora, h, 1) = ':' then
      if p1 = 0 then p1 := h else p2 := h;
  end;

  h := StrToInt(Copy(xhora, 1, p1-1));          // Aislamos h:m:s
  m := StrToInt(Copy(xhora, p1+1, (p2-(p1+1))));
  s := StrToInt(Copy(xhora, p2+1, Length(Trim(xhora)) - p2));

  if s > 60 then Begin
    m := m + (s div 60);
    s := s - (60 * (s div 60));
  end;

  if m > 60 then Begin
    h := h + (m div 60);
    m := m - (60 * (m div 60));
  end;

  dia := h; mes := m; anio := s;

  Result := InttoStr(h) + ':' + IntToStr(m) + ':' + IntToStr(s);
end;

function TTUtiles.totHoras: Integer;
Begin
  Result := dia;
end;

function TTUtiles.totMinutos: Integer;
Begin
  Result := mes;
end;

function TTUtiles.totSegundos: Integer;
Begin
  Result := anio;
end;

function TTUtiles.setHoraCompleta(xhora: String): String;
var
  h, m, s: String;
Begin
  if Length(Trim(Copy(xhora, 1, 2))) = 1 then h := '0' + Trim(Copy(xhora, 1, 2)) else h := Copy(xhora, 1, 2);
  if Length(Trim(Copy(xhora, 4, 2))) < 2 then m := '00' else m := Copy(xhora, 4, 2);
  if Length(Trim(Copy(xhora, 7, 2))) < 2 then s := '00' else s := Copy(xhora, 7, 2);
  Result := h + ':' + m + ':' + s;
end;

function TTUtiles.setHoraActual24(xhora: String): String;
// Objetivo...: Devolver la hora actual
var
  p: Integer; h: String;
begin
  h := lowercase(xhora);
  p := Pos('p', h);
  if p  = 0  then Result := Copy(h, 1, 8) else Result := IntToStr(StrToInt(Copy(h, 1, 2)) + 12) + Copy(h, 3, 6);
  if (p = 0) and (IntToStr(StrToInt(Copy(h, 1, 2)) + 12) = '24') then Result := '00' + Copy(h, 3, 6);
  if (p > 0) and (Copy(h, 1, 2) = '12') then Result := '12' +  Copy(h, 3, 6); 
end;

function TTUtiles.xIntToLletras(Numero:LongInt): String;

  function xxIntToLletras(Valor:LongInt):String;
  const
   aUnidad : array[1..15] of string =
     ('UN','DOS','TRES','CUATRO','CINCO','SEIS',
      'SIETE','OCHO','NUEVE','DIEZ','ONCE','DOCE',
      'TRECE','CATORCE','QUINCE');
   aCentena: array[1..9]  of string =
     ('CIENTO','DOSCIENTOS','TRESCIENTOS',
      'CUATROCIENTOS','QUINIENTOS','SEISCIENTOS',
      'SETECIENTOS','OCHOCIENTOS','NOVECIENTOS');
   aDecena : array[1..9]  of string =
    ('DIECI','VEINTI','TREINTA','CUARENTA','CINCUENTA',
     'SESENTA','SETENTA','OCHENTA','NOVENTA');
  var
   Centena, Decena, Unidad, Doble: LongInt;
   Linea: String;
  begin
   if valor=100 then Linea:=' CIEN '
   else begin
     Linea:='';
     Centena := Valor div 100;
     Doble   := Valor - (Centena*100);
     Decena  := (Valor div 10) - (Centena*10);
     Unidad  := Valor - (Decena*10) - (Centena*100);

     if Centena>0 then Linea := Linea + Acentena[centena]+' ';

     if Doble>0 then begin
       if Doble=20 then Linea := Linea +' VEINTE '
         else begin
          if doble<16 then Linea := Linea + aUnidad[Doble]
            else begin
                 Linea := Linea +' '+ Adecena[Decena];
                 if (Decena>2) and (Unidad<>0) then Linea := Linea+' Y ';
                 if Unidad>0 then Linea := Linea + aUnidad[Unidad];
            end;
         end;
     end;
   end;
   Result := Linea;
  end;

var
   Millones,Miles,Unidades: Longint;
   Linea : String;
begin
  {Inicializamos el string que contendr� las letras seg�n el valor
  num�rico}
  if numero=0 then Linea := 'CERO'
  else if numero<0 then Linea := 'MENOS '
       else if numero=1 then
            begin
              Linea := 'UN';
              xIntToLletras := Linea;
              exit
            end
            else if numero>1 then Linea := '';

  {Determinamos el N� de millones, miles y unidades de numero en
  positivo}
  Numero   := Abs(Numero);
  Millones := numero div 1000000;
  Miles     := (numero - (Millones*1000000)) div 1000;
  Unidades  := numero - ((Millones*1000000)+(Miles*1000));

  {Vamos poniendo en el string las cadenas de los n�meros(llamando
  a subfuncion)}
  if Millones=1 then Linea:= Linea + ' UN MILLON '
  else if Millones>1 then Linea := Linea + xxIntToLletras(Millones)
                                   + ' MILLONES ';

  if Miles =1 then Linea:= Linea + ' MIL '
  else if Miles>1 then Linea := Linea + xxIntToLletras(Miles)+
                                ' MIL ';

  if Unidades >0 then Linea := Linea + xxIntToLletras(Unidades);

  xIntToLletras := Linea;
end;

function  TTUtiles.DepurarInformacion(xmensaje: string): boolean;
begin
  Application.CreateForm(TfmDepurarDatos, fmDepurarDatos);
  fmDepurarDatos.Caption := xmensaje;
  fmDepurarDatos.ShowModal;
  Result := fmDepurarDatos.resultado;
  fmDepurarDatos.Free;
end;

function TTUtiles.Edad(FechaNacimiento:string):integer;
 var
     iTemp,iTemp2,Nada:word;
     Fecha:TDate;
begin
  Fecha:=StrToDate(FechaNacimiento);
  DecodeDate(Date,itemp,Nada,Nada);
  DecodeDate(Fecha,itemp2,Nada,Nada);
   if FormatDateTime('mmdd',Date) <
      FormatDateTime('mmdd',Fecha) then Result:=iTemp-iTemp2-1
                                   else Result:=iTemp-iTemp2;
end;

function  TTUtiles.Fuente: string;
var
  f: TFontDialog; estilo: string;
begin
  f := TFontDialog.Create(nil);
  estilo := 'Normal';
  if f.Execute then Begin
    if fsItalic In f.Font.Style    then estilo := 'Cursiva';
    if fsBold In f.Font.Style      then estilo := 'Negrita';
    if fsUnderline In f.Font.Style then estilo := 'Subrrayado';
    Result := f.Font.Name + ', ' + estilo + ', ' + IntToStr(f.Font.Size);
  end;
end;

function  TTUtiles.setMascaraNumeros: string;
begin
  Result := '##############0.00';
end;

function  TTUtiles.sepaDecimal: string;
var
  SeparadorDecimal: string;
begin
  SeparadorDecimal := Copy( FloatToStr(1.1) ,2,1 );
  Result := SeparadorDecimal;
end;

function TTUtiles.AlinearStringDerecha(S: String; N: Integer): String;
begin
  Result:=StringOfChar(' ',N-Length(S))+S;
end;

function TTUtiles.StringEnCaracteresEspaciados(xstring: String): String;
// Objetivo...: Devolver un String Espaciado
var
  i: Integer;
  rString: String;
Begin
  For i := 1 to Length(TrimRight(xstring)) do
    rString := rString + Copy(xstring, i, 1) + ' ';
  Result := rString;   
end;

function TTUtiles.VerificarSiElSgtringTieneUnNumeroValido(NumStr : string; Error: String) : bool;
// Objetivo...: Verificar que un n�mero resulte v�lido
var
  i: Integer;
begin
  Result := true;
  For i := 1 to Length(TrimRight(NumStr)) do Begin
    if ((UpperCase(Copy(NumStr, i, 1)) >= '0') and (UpperCase(Copy(NumStr, i, 1)) <= '9')) or ((UpperCase(Copy(NumStr, i, 1)) = '.') or (UpperCase(Copy(NumStr, i, 1)) = ',')) then else Begin
      if Length(Trim(Error)) > 0 then msgError(Error);
      result := False;
      Break;
    end;
  end;
end;

function TTUtiles.setFechaActual: string;
// Objetivo...: devolver la fecha actual en el formado dd/mm/aa
begin
  Result := sFormatoFecha(sExprFecha2000(DateToStr(now())));
end;

function TTUtiles.setMes(xmes: ShortInt): String;
// Objetivo...: retornar el mes pedido
begin
  Result := meses[xmes];
end;

function TTUtiles.setPeriodoActual: String;
begin
  Result := Copy(sExprFecha2000(DateToStr(Now)), 5, 2) + '/' + Copy(sExprFecha2000(DateToStr(Now)), 1, 4);
end;

function TTUtiles.setPeriodo(xfecha: String): String;
begin
  Result := Copy(sExprFecha2000(xfecha), 5, 2) + '/' + Copy(sExprFecha2000(xfecha), 1, 4);
end;

function TTUtiles.verificarItemsEnLista(listArray: Array of String; xitems: String): Boolean;
// Objetivo...: Verificar el nro. de posicion de un items en un array
var
  i: Integer;
begin
  Result := False;
  if Length(Trim(listArray[Low(listArray)])) = 0 then  Result := True else Begin  // Retornamos True si no hay elementos, es decir, se listan todas
    For i := Low(listArray) to High(listArray) do
      if listArray[i] = xitems then Begin
        Result := True;
        Break;
      end;
  end;
end;

function TTUtiles.setNro2Dec(xnumero: Real): Real;
// Objetivo...: Devolver un nro con 2 decimales
Begin
  Result := StrToFloat(utiles.FormatearNumero(FloatToStr(xnumero)));
end;

function TTUtiles.verificarItemsEnLista(listArray: Array of String; xitems: String; ini_string, fin_string: ShortInt): Boolean;
// Objetivo...: Verificar el nro. de posicion de un items en un array, aplicando substracci�n de cadena
var
  i: Integer;
begin
  Result := False;
  if Length(Trim(listArray[Low(listArray)])) = 0 then  Result := True else Begin  // Retornamos True si no hay elementos, es decir, se listan todas
    For i := Low(listArray) to High(listArray) do
      if Copy(listArray[i], ini_string, fin_string) = xitems then Begin
        Result := True;
        Break;
      end;
  end;
end;

function TTUtiles.ObtenerItemsEnLista(listArray: Array of String; xitems: String): Integer;
// Objetivo...: Verificar el nro. de posicion de un items en un array
var
  i: Integer;
begin
  Result := -1;
  For i := Low(listArray) to High(listArray) do
    if listArray[i] = xitems then Begin
      Result := i+1;
      Break;
    end;
end;

function TTUtiles.verificarItemsLista(lista_buscar: TStringList; xitems: String): Boolean;
// Objetivo...: Verificar Items en un StringList
var
  i: Integer;
Begin
  Result := False;
  if lista_buscar = Nil then Result := True else
    if lista_buscar.Count = 0 then Result := True else Begin
      for i := 1 to lista_buscar.Count do Begin
        if Trim(lista_buscar.Strings[i-1]) = Trim(xitems) then Begin
          Result := True;
          Break;
        end;
      end;
    end;
end;

function TTUtiles.potencia(x, y: real): real;
// Objetivo...: Calcular un numero elevado a una potencia
begin
  result := exp(ln(x) * y);
end;

function TTUtiles.setIdRegistroFecha: String;
// Objetivo...: Calcular un numero elevado a una potencia
var
  a, r, t: String; i: Integer;
begin
  r := sExprFecha2000(setFechaActual);
  t := Copy(setHoraActual24, 1, 8);
  a := Copy(t, 1, 2) + Copy(t, 4, 2) + Copy(t, 7, 2);
  i := Pos(':', a);
  Delete(a, i, 1);
  i := Pos(':', a);
  Delete(a, i, 1);
  Result := Trim(r + a);
end;

function TTUtiles.validarEmail(xemail, xerror: String): Boolean;
Begin
  if Length(Trim(xemail)) = 0 then Result := True else
    if Pos('@', xemail) > 0 then Result := True else Begin
      Result := False;
      if Length(Trim(xerror)) > 0 then msgError(xerror);
    end;
end;

function TTUtiles.validarNumero(xnumero, xerror: String): Boolean;
var
  i: Integer;
Begin
  if (xnumero = '') then begin
    Result := False;
    exit;
  end;
  Result := True;
  for i := 1 to Length(TrimRight(xnumero)) do Begin
    if (Copy(xnumero, i, 1) = '.') or (Copy(xnumero, i, 1) = ',') or (Copy(xnumero, i, 1) = '-') or ((Copy(xnumero, i, 1) = '0') or (Copy(xnumero, i, 1) = '1') or (Copy(xnumero, i, 1) = '2') or (Copy(xnumero, i, 1) = '3')
        or (Copy(xnumero, i, 1) = '4') or (Copy(xnumero, i, 1) = '5') or (Copy(xnumero, i, 1) = '6') or (Copy(xnumero, i, 1) = '7') or (Copy(xnumero, i, 1) = '8') or (Copy(xnumero, i, 1) = '9')) then Result := True else Begin
      Result := False;
      if Length(Trim(xerror)) > 0 then msgError(xerror);
      Break;
    end;
  end;
end;

procedure TTUtiles.MsgProcesandoDatos(xmsg: String);
Begin
  if not Assigned(fmProcesandoDatos) then Begin
    Application.CreateForm(TfmProcesandoDatos, fmProcesandoDatos);
    fmProcesandoDatos.Show;
  end;
  fmProcesandoDatos.msg.Caption := Copy(xmsg, 1, 100);
  //fmProcesandoDatos.Width := fmProcesandoDatos.msg.Width + 10;
  fmProcesandoDatos.msg.Refresh;
end;

procedure TTUtiles.MsgFinalizarProcesandoDatos;
Begin
  if fmProcesandoDatos <> Nil then Begin
    fmProcesandoDatos.Release;
    fmProcesandoDatos := Nil;
  end;
end;

function  TTUtiles.setMontoSinSignosDecimales(xnumero: String; xancho: Integer): String;
var
  nro, nro1: String;
  i: Integer;
Begin
  nro := FormatearNumero(xnumero);
  For i := 1 to Length(nro) do
    if (Copy(nro, i, 1) <> ',') then
      if (Copy(nro, i, 1) <> '.') then nro1 := nro1 + Copy(nro, i, 1);

  Result := sLlenarIzquierda(nro1, xancho, '0');
end;

function TTUtiles.setCompletarNroEnteroConPuntos(xnrodoc: String): String;
var
  n: String;
Begin
  n := xnrodoc;
  if Length(Trim(n)) > 3 then insert('.', n, Length(Trim(n)) - 2);
  if Length(Trim(n)) > 7 then insert('.', n, Length(Trim(n)) - 6);
  Result := n;
end;

function TTUtiles.StringLongitudFija(xstring: String; xlargo: Integer): String;
// Objetivo...: Devolver un String de Longitud fija
Begin
  Result := Copy(xstring, 1, xlargo) + espacios( (xlargo + 1) - Length({TrimRight(}Copy(xstring, 1, xlargo{)})));
end;

function TTUtiles.StringRemplazarCaracteres(xcadena, xcaracter, xnuevo_caracter: String): String;
// Objetivo...: Remplazar Caracteres
var
  i: Integer;
  n: String;
Begin
  For i := 1 to Length(xcadena) do Begin
    if Copy(xcadena, i, 1) = xcaracter then n := n + xnuevo_caracter else
      n := n + Copy(xcadena, i, 1);
  end;
  Result := n;
end;

function TTUtiles.StringQuitarCaracteresEnBlanco(xcadena: String): String;
// Objetivo...: Quitar los Blancos intermedios
var
  i, j: Integer;
  n: String;
Begin
  j := 0;
  For i := 1 to Length(xcadena) do Begin
    if Copy(xcadena, i, 1) <> ' ' then Begin
      n := n + Copy(xcadena, i, 1);
      j := 0;
    end else Begin
      if j = 0 then Begin
        n := n + Copy(xcadena, i, 1);
        j := 1;
      end;
    end;
  end;
  Result := n;
end;

function TTUtiles.StringQuitarCaracteresEnNumeros(xcadena: String): String;
// Objetivo...: Quitar los . y ,
var
  i: Integer;
  n: String;
Begin
  For i := 1 to Length(xcadena) do Begin
    if (Copy(xcadena, i, 1) <> ',') and (Copy(xcadena, i, 1) <> '.') then n := n + Copy(xcadena, i, 1);
  end;
  Result := n;
end;

function TTUtiles.ValidarCUIT(xcuit:String):boolean;
const
    TablaMul:Array[1..10] of Integer=(5,4,3,2,7,6,5,4,3,2); {Tabla Arbitraria}

 type
   ArrayDe11=Array[1..11] of Integer;
 var
   R:ArrayDe11;           {Resultados de Multiplicar por la Tabla Arbitraria}
   CUIT:ArrayDe11;        {Para convertir cada digito}
   I:Integer;             {Indice}
   Sumatoria,             {Sumatoria de los Digitos menos el �ltimo}
   Dividendo,             {Resultado de la Divisi�n}
   Producto,
   Diferencia:Integer;
   Num: String;
 begin
   if (Length(Trim(xcuit)) = 13) then
     Num := Copy(xcuit, 1, 2) + Copy(xcuit, 4, 8) + Copy(xcuit, 13, 1)
   else
     Num := '00000000000';

   if (length(trim(xcuit)) = 11) then Num := xcuit;
    

   result:=false;          { Asumir Invalido }
   if Length(Num) = 11 then
     begin
       try
         for i:=1 to 11 do CUIT[i]:=StrToInt(Num[i]); { Convertir cada caracter a N�mero}
       except
         Exit;                                        { Si hay error de
   conversi�n es CUIT invalido}
       end; { try }
   end else Exit; { if }  { Si no tiene 11 caracteres es CUIT invalido }

   for i:=1 to 10 do             // Multiplicar cada digito por la
     R[i]:=CUIT[i]*TablaMul[i];   // Tabla Arbitraria menos el �ltimo

   Sumatoria:=0;
   for i:=1 to 10 do
     Sumatoria:=Sumatoria+R[i];   // Calcular la sumatoria de los resultados

   Dividendo:=Sumatoria div 11;     //  Dividir por 11  (divisi�n entera)
   Producto:=Dividendo * 11;          // El resultado multiplica por 11
   Diferencia:=Sumatoria - Producto;  // Obtener la diferencia
   if Diferencia > 0 then             // Si la dif. es mayor a cero
      DigitoVerif:=11 - Diferencia  // El digito verificador es 11 menos la  diferencia
   else DigitoVerif:=Diferencia;       // sino es Cero.

   if (Num = '00000000000') then Result := False else
     if DigitoVerif = CUIT[11] then result:=true;  // si el Digito Verificador es igual
   if (xcuit = '00-00000000-0') then Result := True;
 end;

 function TTUtiles.ObtenerDigitoVerificadorCUIT(xcuit: String): String;
 // Objetivo...: Obtener el Digito Verificador
 Begin
   ValidarCUIT(xcuit);
   Result := IntToStr(DigitoVerif);
 End;

function TTUtiles.getGuid: string;
var
  Guid: TGUID;
  rs: string;
begin
  CreateGUID(Guid);
  rs := GUIDToString(Guid);
  rs := StringRemplazarCaracteres(rs, '{', '');
  rs := StringRemplazarCaracteres(rs, '}', '');
  result := rs;
end;

function TTUtiles.getNumberMask(xn: string): string;
var
 n: double;
begin
  n := strtofloat(xn);
  result := format('%n', [n]);
end;

{===============================================================================}

function utiles: TTUtiles;
begin
  if xutiles = nil then
    xutiles := TTUtiles.Create;
  Result := xutiles;
end;

{===============================================================================}

initialization

finalization
  xutiles.Free;

end.
