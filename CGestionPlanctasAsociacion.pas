// agregar: copiarmovimiento, testintegridad

unit CGestionPlanctasAsociacion;

interface

uses CPlanctasAsociacion, Capitul, CLDiarioAsociacion, CUtiles, SysUtils, DBTables, CBDT, Forms, CIDBFM;

type

TTGestCuentas = class
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;
  function    Sepa: string;
  function    ObtenerCodigoCuenta(xcodactual: string; xNivel: byte): string;
  function    ObtenerNuevoCodigo(UltimoCodigo: string; xNivel: byte): string;
  function    ObtenerCodSumariza(Cod: string; xNivel: integer): string;
  function    ObtenerNivelCuenta(Codcta: string): byte;
  function    CodigoSumarizaOk(Sumatoria: string; xNivel: integer): boolean;
  procedure   AgregarCuenta(codactual: string; xNivel: byte);
  procedure   ProcederACopiar(codctaactual, codctaanterior: string);
  procedure   EliminarCuenta(cta1: string);
  function    testIntegridad(xcodcta: string): boolean;
 private
  { Declaraciones Privadas }
  procedure   quitarImputacion(codctaactual, codctaanterior: string);
end;

function gestplanctas: TTGestCuentas;

implementation

var
  xgestplanctas: TTGestCuentas = nil;

constructor TTGestCuentas.Create;
begin
  inherited Create;
end;

destructor TTGestCuentas.Destroy;
begin
  inherited Destroy;
end;

function TTGestCuentas.sepa: string;
{Objetivo...: Devolver el caracter separador de Niveles}
begin
  {Obtenemos el Separador de Niveles}
  planctas.getDatosSep;
  Result := planctas.Sepa;
end;

procedure TTGestCuentas.AgregarCuenta(codactual: string; xNivel: byte);
{Objetivo....: Agregar Nuevas Cuentas}
var
  ctok: boolean;
  xcod: string;
begin
  ctok := False; xcod := planctas.planctas.FieldByName('codcta').AsString;
  Application.CreateForm(TfmCuentas, fmCuentas);
  planctas.getDatosParam(xnivel);
  {Calculo el Siguiente Código de Acuerdo al Nivel}
  fmCuentas.CodCta.Text       := ObtenerCodigoCuenta(codactual, xNivel);
  fmCuentas.Sumatoria.Caption := ObtenerCodSumariza(fmCuentas.Codcta.Text, xNivel);
  fmCuentas.Nivel             := xNivel;
  {Transfiero al Formulario para dar de Alta; confirmo Alta}
  fmCuentas.Imputable         := planctas.Imputable;
  if CodigoSumarizaOk(fmCuentas.Sumatoria.Caption, xNivel) then Begin
    if utiles.DarDeAlta('Cód. Cta. ' + fmCuentas.Codcta.Text) then Begin
      fmCuentas.ShowModal;
    end;
  end;
  if fmCuentas.Grabado then planctas.Buscar(fmCuentas.Codcta.Text) else planctas.Buscar(xcod);

  // Agregamos una Nueva Cuenta
  //VerificarMovimientosCtaSumariza: rutina que se encarga, cuando se da de alta una cuenta de Nivel 5, de Verificar que la 4, que
  //será sumatoria, no tenga movimientos, si los tiene, los mismos se copian a la cuenta dada de alta
  {if (xNivel = 5) and (utiles.msgSiNo('Es Necesario Copiar los Movimientos de la Cuenta a la Sub Cuenta', 'Seguro para Proceder ?')) then Begin
    fmCuentas.ShowModal;
    if fmCuentas.Grabado then Begin
      ProcederACopiar(fmCuentas.codcta.Text, fmCuentas.sumatoria.Caption);   // Procedemos a copiar
      //Si se agregó un Movimiento, activamos el registro dado de Alta
      ctok := True;
      planctas.planctas.FindKey([codactual]);
    end;
  end;

  // Si se dio de alta una cuenta de Nivel 5 actualizamos - para el caso necesario - la de Nivel 4 como no imputable
  if xNivel = 5 then quitarImputacion(fmCuentas.codcta.Text, fmCuentas.Sumatoria.Caption);
  if ctok then planctas.getDatos(fmCuentas.CodCta.Text) else   // Posicionamos el puntero en la Nueva cuenta
    planctas.Buscar(xcod);}

   fmCuentas.Release; fmCuentas := Nil;
end;

procedure TTGestCuentas.ProcederACopiar(codctaactual, codctaanterior: string);
{Objetivo...: Formular y Ejecutar una Actualización SQL para efectuar en cambio}
begin
  {ldiario.CambiarCodCtas(path, actperiodo, codctaactual, codctaanterior);
  quitarImputacion(codctaactual, codctaanterior);}
end;

function TTGestCuentas.CodigoSumarizaOk(Sumatoria: string; xNivel: integer): boolean;
{Objetivo...: Controlar que el Cód. de Sumatoria sea Correcto}
var
  NroRegActual, NivelAct, error: integer;
  Filtro: boolean;
begin
  error := 0;
  {Extraemos el Nro. de Registro actual para luego restaurar posición}
  NroRegActual := planctas.planctas.RecNo;

  //Si existe algun Filtro, lo guardamos para luego restaurarlo
  Filtro := planctas.planctas.Filtered;
  planctas.planctas.Filtered := False;

  // Si el Nivel es mayor a uno hacemos el control de Sumatoria Existente
  if xNivel > 1 then Begin
    NivelAct     := planctas.planctas.FieldByName('Nivel').AsInteger;
    if not planctas.Buscar(sumatoria) then Begin
      utiles.msgError('Cód. de Cuenta Subtotalizadora Incorrecto ...!');
      error := 1;
    end else
      NivelAct := planctas.planctas.FieldByName('Nivel').AsInteger;
    if xNivel <> NivelAct + 1 then Begin
      utiles.msgError('No se ha definido Cuenta de Nivel ' + IntToStr(NivelAct + 1) + ' ->Superior');
      error := 1;
    end;
  end;

  //Si había Filtro, lo restablecemos
  if Filtro then planctas.planctas.Filtered := True;

  planctas.planctas.MoveBy (NroRegActual);
  if error = 0 then Result := True else Result := False;
end;

function TTGestCuentas.ObtenerCodSumariza(Cod: string; xNivel: integer): string;
{Objetivo...: Formar el Código de Sumatoria correspondiente}
begin
  Case xNivel of
    1: Result := Cod;
    2: Result := Copy(Cod, 1, 1) + sepa + '0'  + sepa + '0' + sepa + '00' + sepa + '000';
    3: Result := Copy(Cod, 1, 3) + sepa + '0'  + sepa + '00' + sepa + '000';
    4: Result := Copy(cod, 1, 5) + sepa + '00' + sepa + '000';
    5: Result := Copy(cod, 1, 8) + sepa + '000';
  end;
end;

{OBTENCIÓN DE CUENTAS POR NIVELES}

function TTGestCuentas.ObtenerCodigoCuenta(xcodactual: string; xNivel: byte): string;
{Objetivo...: Calcular Cód. de Cuenta para Nivel 3}
var
  UltimoCodigo: string;
  extension   : integer;
begin
  with planctas do Begin
    UltimoCodigo := '0'; extension := 0;
    if xNivel < 4 then extension := 1;
    if xNivel = 4 then extension := 2;
    if xNivel = 5 then extension := 3;

    //Recuperamos el Código Actual para Calcular el Siguiente ...

    planctas.First;  //Partimos desde el 1º
    while not planctas.EOF do Begin
      if xNivel > 1 then
      if Copy(planctas.FieldByName('codcta').AsString, 1, extension) > Copy(xcodactual, 1, extension) then Break;
      {Extraemos el Último Código de Acuerdo al Nivel}
      Case xNivel of
        1: UltimoCodigo := planctas.FieldByName('codcta').AsString;
        2: if Copy(planctas.FieldByName('codcta').AsString, 1, 1) = Copy(xcodactual, 1, 1) then UltimoCodigo := planctas.FieldByName('codcta').AsString;
        3: if Copy(planctas.FieldByName('codcta').AsString, 1, 4) = Copy(xcodactual, 1, 4) then UltimoCodigo := planctas.FieldByName('codcta').AsString;
        4: if Copy(planctas.FieldByName('codcta').AsString, 1, 6) = Copy(xcodactual, 1, 6) then UltimoCodigo := planctas.FieldByName('codcta').AsString;
        5: if Copy(planctas.FieldByName('codcta').AsString, 1, 8) = Copy(xcodactual, 1, 8) then UltimoCodigo := planctas.FieldByName('codcta').AsString;
      end;
      planctas.Next;
    end;
  end;
  {A calcular el Nuevo Código de Cuenta ...}
  Result := ObtenerNuevoCodigo(ultimoCodigo, xNivel);
end;

function TTGestCuentas.ObtenerNuevoCodigo(UltimoCodigo: string; xNivel: byte): string;
{Objetivo...: Obtener el Nuevo Código a partir del último}
var
  NuevoDigito: integer;
begin
  {Calculamos el Nuevo Dígito y Formamos el Nuevo Código ...}
  Case xNivel of
    1: begin
         NuevoDigito := StrToInt(Copy(UltimoCodigo, 1, 1)) + 1;
         Result      := IntToStr(NuevoDigito) + sepa + '0' + sepa + '0' + sepa + '00' + sepa + '000';
       end;
    2: begin
         NuevoDigito := StrToInt(Copy(UltimoCodigo, 3, 1)) + 1;
         Result      := Copy(UltimoCodigo, 1, 1) + sepa + IntToStr(NuevoDigito) + sepa + '0' + sepa + '00' + sepa + '000';
       end;
    3: begin
         NuevoDigito := StrToInt(Copy(UltimoCodigo, 5, 1)) + 1;
         Result      :=  Copy(UltimoCodigo, 1, 4) + IntToStr(NuevoDigito)+ sepa + '00' + sepa + '000';
       end;
    4: begin
         NuevoDigito := StrToInt(Copy(UltimoCodigo, 7, 2)) + 1;
         if NuevoDigito < 10 then Result := Copy(UltimoCodigo, 1, 6) + '0' + IntToStr(NuevoDigito) + sepa + '000'
                             else Result := Copy(UltimoCodigo, 1, 6) + IntToStr(NuevoDigito) + sepa + '000';
       end;
    5: begin
         NuevoDigito := StrToInt(Copy(UltimoCodigo, 10, 3)) + 1;
         Result := Copy(UltimoCodigo, 1, 9) + utiles.sLlenarIzquierda(IntToStr(NuevoDigito), 3, '0');
       end;
  end;
end;

function TTGestCuentas.ObtenerNivelCuenta(codcta: string): byte;
{Objetivo...: Dado un Cód. de Cuenta, Obtener su Nivel}
begin
  Result := 0;
  if StrToInt(Copy(codcta, 1, 1 )) > 0 then Result := 1;
  if StrToInt(Copy(codcta, 3, 1 )) > 0 then Result := 2;
  if StrToInt(Copy(codcta, 5, 1 )) > 0 then Result := 3;
  if StrToInt(Copy(codcta, 7, 2 )) > 0 then Result := 4;
  if StrToInt(Copy(codcta, 10,3 )) > 0 then Result := 5;
end;

procedure TTGestCuentas.quitarImputacion(codctaactual, codctaanterior: string);
begin
  //Marcamos la cuenta que ahora queda como subtotalizadora, como NO imputable
  planctas.planctas.FindKey([codctaanterior]);
  planctas.planctas.Edit;
  planctas.planctas.FieldByName('Imputable').AsString := 'N';
  planctas.planctas.Post;
end;

procedure TTGestCuentas.EliminarCuenta(cta1: string);
// Objetivo...: Gestionar baja de cuentas para el Plan de cuentas
var
  sumariza, ctsum, error, cc: string;
  Borrar, Eliminar, b: Boolean;
  Nivel : Byte; reg: integer;
begin
  Borrar := True; Eliminar := True; b := False;
  if not planctas.planctas.Eof then Begin
    planctas.planctas.Next;
    cc := planctas.planctas.FieldByName('codcta').AsString;
    planctas.planctas.Prior;
  end;
  //Localizamos la Cuenta a Eliminar
  if planctas.Buscar(cta1) then Begin
    sumariza := planctas.planctas.FieldByName('codcta').AsString;
    ctsum    := planctas.planctas.FieldByName('sumariza').AsString;
    Nivel    := planctas.planctas.FieldByName('nivel').AsInteger;
    //Realizamos el Control para la de Nivel 1
    if planctas.BuscarSumariza(sumariza) then
      if (planctas.planctas.FieldByName('nivel').AsInteger = 1) and (planctas.planctas.RecordCount > 1) then Begin
        planctas.planctas.Next;
        if (planctas.planctas.FieldByName('sumariza').AsString = sumariza) and not (planctas.planctas.EOF) then Begin
          Borrar := False;
          error :=  'La Cuenta Seleccionada tiene Ctas. Subordinadas ...!';
        end else begin
          Borrar := True;
          if not (planctas.planctas.EOF) then planctas.planctas.Prior;
        end;
      end else
        if planctas.Buscar(cta1) then
          if planctas.planctas.FieldByName('nivel').AsInteger > 1 then Begin
            error  :=  'La Cuenta Seleccionada tiene Ctas. Subordinadas ...!';
            Borrar := False;
          end else
            Borrar := True;
      if testIntegridad(cta1) then Begin
        error  := 'Cuenta con Movimientos, Imposible dar de Baja ...!';
        Borrar := False;
      end;
      //Si la Cuenta se puede Eliminar procedemos, de lo contrario Emitimos un Mensaje de Error}
      if not (Borrar) or not (Eliminar) then Begin
        planctas.planctas.Prior;
        utiles.msgError(error);
      end else begin
        if utiles.BajaRegistro('Seguro para Eliminar Cuenta ' + cta1 + ' ?') then begin
          planctas.Borrar(cta1);
          //Si se eliminó la(s) Cuenta(s) de Nivel 5, marcamos la de nivel 4 como imputable
          if Nivel = 5 then
          if not planctas.BuscarSumariza(ctsum) then planctas.ctImputable(ctsum);  // La marcamos como imputable
          b := True;
        end;
      end;
    end;
  if not b then planctas.Buscar(cta1) else planctas.Buscar(cc);
end;

function TTGestCuentas.testIntegridad(xcodcta: string): boolean;
// Objetivo...: verificar la relación de la cuenta en cuestión con el resto de los registros
begin
  Result := False;
  if ldiario.verifCuenta(xcodcta) then Result := True;
end;

{===============================================================================}

function gestplanctas: TTGestCuentas;
begin
  if xgestplanctas = nil then
    xgestplanctas := TTGestCuentas.Create;
  Result := xgestplanctas;
end;

{===============================================================================}

initialization

finalization
  xgestplanctas.Free;

end.
