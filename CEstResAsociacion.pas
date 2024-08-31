{ Objetivo....: Gestionar los cálculos para la Emisión de los Informes Contables
  Fianales - Estado de Resultados, Balances, entre otros}

unit CEstResAsociacion;

interface

uses CEstFinAsociacion, CEEstResAsociacion, CPlanctasAsociacion, SysUtils, DBTables, CBDT, CUtiles, CIDBFM, CListar;

type

TTEstadoResultados = class(TTEstadosContables)
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  procedure   Listar(salida: char);
 private
  { Declaraciones Privadas }
  tm: shortint;
  function    ListMovimientos(digito: string; salida: char): integer;
  procedure   titulo;
 protected
  { Declaraciones Protegidas }
end;

function estres: TTEstadoResultados;

implementation

var
  xestres: TTEstadoResultados = nil;

constructor TTEstadoResultados.Create;
begin
  inherited Create;
end;

destructor TTEstadoResultados.Destroy;
begin
  inherited Destroy;
end;

function TTEstadoResultados.ListMovimientos(digito: string; salida: char): integer;
begin
  //ctestres.conectar;
  plctas.First;
  planctas.getDatos;
  tm := 0;
  while not plctas.EOF do
    begin
      if ((Copy(plctas.FieldByName('codcta').AsString, 1, 1) = digito) and (plctas.FieldByName('imputable').AsString = 'S')) and (plctas.FieldByName('totaldebe').AsFloat - plctas.FieldByName('totalhaber').AsFloat <> 0) then
        begin
          if (digito = planctas.Ganancias) and (plctas.FieldByName('codcta').AsString <> ctestres.Ctaingreso) and (plctas.FieldByName('sumariza').AsString <> ctestres.Ctaingreso) then
            begin
               if (salida = 'P') or (salida = 'I') then Begin
                 list.Linea(0, 0, utiles.espacios(10) + plctas.FieldByName('codcta').AsString + '  ' + Copy(plctas.FieldByName('cuenta').AsString, 1, 35), 1, 'Arial, normal, 9', salida, 'N');
                 if ((plctas.FieldByName('totaldebe').AsFloat - plctas.FieldByName('totalhaber').AsFloat) < 0) then Begin
                   list.importe(90, list.lineactual, '', (plctas.FieldByName('totaldebe').AsFloat - plctas.FieldByName('totalhaber').AsFloat) * (-1), 2, 'Arial, normal, 9');
                   totingresos := totingresos + ( (plctas.FieldByName('totaldebe').AsFloat - plctas.FieldByName('totalhaber').AsFloat) * (-1) );
                 end else Begin
                   list.importe(90, list.lineactual, '', (plctas.FieldByName('totaldebe').AsFloat - plctas.FieldByName('totalhaber').AsFloat), 2, 'Arial, normal, 9');
                   totingresos := totingresos + ( (plctas.FieldByName('totaldebe').AsFloat - plctas.FieldByName('totalhaber').AsFloat) );
                 end;
               end;
               if (salida = 'T') then Begin
                 list.LineaTxt(utiles.espacios(3) + plctas.FieldByName('codcta').AsString + ' ' + utiles.StringLongitudFija(Copy(plctas.FieldByName('cuenta').AsString, 1, 35), 48), False);
                 if ((plctas.FieldByName('totaldebe').AsFloat - plctas.FieldByName('totalhaber').AsFloat) < 0) then Begin
                   list.importetxt((plctas.FieldByName('totaldebe').AsFloat - plctas.FieldByName('totalhaber').AsFloat) * (-1), 12, 2, False);
                   totingresos := totingresos + ( (plctas.FieldByName('totaldebe').AsFloat - plctas.FieldByName('totalhaber').AsFloat) * (-1) );
                 end else Begin
                   list.importetxt((plctas.FieldByName('totaldebe').AsFloat - plctas.FieldByName('totalhaber').AsFloat), 12, 2, False);
                   totingresos := totingresos + ( (plctas.FieldByName('totaldebe').AsFloat - plctas.FieldByName('totalhaber').AsFloat) );
                 end;
                 list.LineaTxt('', True);
                 Inc(lineas); if ControlarSalto then titulo;
               end;
               //totingresos := totingresos + ( (plctas.FieldByName('totaldebe').AsFloat - plctas.FieldByName('totalhaber').AsFloat) * (-1) );
               tm := 1;
            end;
          if (digito = planctas.Perdidas) and (plctas.FieldByName('codcta').AsString <> ctestres.Ctaegreso) and (plctas.FieldByName('sumariza').AsString <> ctestres.Ctaegreso) then
            begin
              // Excluimos la cuenta de AREA
              if (plctas.FieldByName('codcta').AsString <> planctas.codarea) then Begin
                if (salida = 'P') or (salida = 'I') then Begin
                  list.Linea(0, 0, utiles.espacios(10) + plctas.FieldByName('codcta').AsString + '  ' + Copy(plctas.FieldByName('cuenta').AsString, 1, 35), 1, 'Arial, normal, 9', salida, 'N');
                  //list.importe(70, list.lineactual, '', plctas.FieldByName('totaldebe').AsFloat - plctas.FieldByName('totalhaber').AsFloat * (-1), 2, 'Arial, normal, 9');
                  if ((plctas.FieldByName('totaldebe').AsFloat - plctas.FieldByName('totalhaber').AsFloat) < 0) then Begin
                    list.importe(70, list.lineactual, '', plctas.FieldByName('totaldebe').AsFloat - plctas.FieldByName('totalhaber').AsFloat * (-1), 2, 'Arial, normal, 9');
                    //totegresos := totegresos + (plctas.FieldByName('totaldebe').AsFloat + plctas.FieldByName('totalhaber').AsFloat * (-1));
                  end else Begin
                    list.importe(70, list.lineactual, '', plctas.FieldByName('totaldebe').AsFloat - plctas.FieldByName('totalhaber').AsFloat, 2, 'Arial, normal, 9');
                    //totegresos := totegresos + (plctas.FieldByName('totaldebe').AsFloat + plctas.FieldByName('totalhaber').AsFloat);
                  end;
                  list.Linea(95, list.Lineactual, '', 3, 'Arial, normal, 9', salida, 'S');
                end;
                if (salida = 'T') then Begin
                  list.LineaTxt(utiles.espacios(3) + plctas.FieldByName('codcta').AsString + ' ' + utiles.StringLongitudFija(Copy(plctas.FieldByName('cuenta').AsString, 1, 35), 37), False);
                  if ((plctas.FieldByName('totaldebe').AsFloat - plctas.FieldByName('totalhaber').AsFloat) < 0) then Begin
                    list.importetxt(plctas.FieldByName('totaldebe').AsFloat - plctas.FieldByName('totalhaber').AsFloat * (-1), 12, 2, False);
                    //totegresos := totegresos + (plctas.FieldByName('totaldebe').AsFloat + plctas.FieldByName('totalhaber').AsFloat * (-1));
                  end else Begin
                    list.importetxt(plctas.FieldByName('totaldebe').AsFloat - plctas.FieldByName('totalhaber').AsFloat, 12, 2, False);
                    //totegresos := totegresos + (plctas.FieldByName('totaldebe').AsFloat + plctas.FieldByName('totalhaber').AsFloat);
                  end;
                  list.LineaTxt('', True);
                  Inc(lineas); if ControlarSalto then titulo;
                end;
                if (plctas.FieldByName('totaldebe').AsFloat - plctas.FieldByName('totalhaber').AsFloat < 0) then Begin
                  totegresos := totegresos + ((plctas.FieldByName('totaldebe').AsFloat - plctas.FieldByName('totalhaber').AsFloat) * (-1));
                end else Begin
                  totegresos := totegresos + (plctas.FieldByName('totaldebe').AsFloat - plctas.FieldByName('totalhaber').AsFloat);
                end;
                tm := 1;
              end;
            end;
        end;
        plctas.Next;
    end;
    Result := tm;
end;

procedure TTEstadoResultados.Listar(salida: char);
var
  l: Boolean;
begin
  {Abrimos la tabla con los Parámetros de Emisión}
  saldo := 0; totdebe := 0; tothaber := 0; totingresos := 0; totegresos := 0;
  if (salida = 'P') or (salida = 'I') then Begin
    list.Setear(salida);
    ListarDatosEmpresa(salida);
    list.Titulo(0, 0, ' Estado de Resultados', 1, 'Arial, negrita, 14');
    list.Titulo(0, 0, ' ', 1, 'Times New Roman, ninguno, 6');
    list.Titulo(0, 0, '  Código          Cuenta ', 1, 'Arial, cursiva, 9');
    list.Titulo(65, list.lineactual, 'Debe', 2, 'Arial, cursiva, 9');
    list.Titulo(84, list.lineactual, 'Haber', 3, 'Arial, cursiva, 9');
    list.Titulo(0, 0, list.linealargopagina(salida), 1, 'Arial, normal, 11');
    list.Titulo(0, 0, '  ', 1, 'Arial, negrita, 9');
  end;
  if (salida = 'T') then Begin
    list.IniciarImpresionModoTexto;
    Pag := 0;
    titulo;
  end;

  ctestres.getDatos;    // Extracción de las cuentas que determinan los niveles de ruptura

  if planctas.Buscar(ctestres.Ctaingreso) then Begin
    if (salida = 'P') or (salida = 'I') then Begin
      list.Linea(0, 0, utiles.espacios(10) + plctas.FieldByName('codcta').AsString + '  ' + plctas.FieldByName('cuenta').AsString, 1, 'Arial, negrita, 9', salida, 'N');
      list.importe(90, list.lineactual, '', (plctas.FieldByName('totaldebe').AsFloat - plctas.FieldByName('totalhaber').AsFloat) * (-1), 2, 'Arial, negrita, 9');
      tothaber := plctas.FieldByName('totaldebe').AsFloat - plctas.FieldByName('totalhaber').AsFloat;
      list.Linea(0, 0, 'menos', 1, 'Arial, normal, 9', salida, 'N');
    end;
    if (salida = 'T') then Begin
      list.LineaTxt(utiles.espacios(3) + plctas.FieldByName('codcta').AsString + ' ' + utiles.StringLongitudFija(plctas.FieldByName('cuenta').AsString, 48), False);
      list.importeTxt((plctas.FieldByName('totaldebe').AsFloat - plctas.FieldByName('totalhaber').AsFloat) * (-1), 12, 2, True);
      Inc(lineas); if ControlarSalto then titulo;
      tothaber := plctas.FieldByName('totaldebe').AsFloat - plctas.FieldByName('totalhaber').AsFloat;
      list.LineaTxt('menos', True);
      Inc(lineas); if ControlarSalto then titulo;
    end;
  end;

  if planctas.Buscar(ctestres.Ctaegreso) then Begin
    if (salida = 'P') or (salida = 'I') then Begin
      list.Linea(0, 0, utiles.espacios(10) + plctas.FieldByName('codcta').AsString + '  ' + plctas.FieldByName('cuenta').AsString, 1, 'Arial, negrita, 9', salida, 'N');
      list.importe(70, list.lineactual, '', plctas.FieldByName('totaldebe').AsFloat - plctas.FieldByName('totalhaber').AsFloat, 2, 'Arial, negrita, 9');
    end;
    if (salida = 'T') then Begin
      list.LineaTxt(utiles.espacios(3) + plctas.FieldByName('codcta').AsString + ' ' + utiles.StringLongitudFija(plctas.FieldByName('cuenta').AsString, 37), False);
      list.importeTxt(plctas.FieldByName('totaldebe').AsFloat - plctas.FieldByName('totalhaber').AsFloat, 12, 2, True);
      Inc(lineas); if ControlarSalto then titulo;
    end;
    totdebe := plctas.FieldByName('totaldebe').AsFloat - plctas.FieldByName('totalhaber').AsFloat;
  end;

  l := False;
  if (totdebe <> 0) and (tothaber <> 0) then Begin
    l := True;
    if (salida = 'P') or (salida = 'I') then Begin
      list.Linea(0, 0, 'igual', 1, 'Arial, normal, 9', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, normal, 9', salida, 'N');
      list.derecha(90, list.lineactual, '###############', '------------------', 2, 'Arial, negrita, 9');
      list.Linea(0, 0, 'UTILIDAD BRUTA', 1, 'Arial, negrita, 9', salida, 'N');
      list.importe(90, list.lineactual, '', (tothaber - (totdebe * (-1))) * (-1), 2, 'Arial, negrita, 9');
      list.Linea(0, 0, '', 1, 'Arial, normal, 9', salida, 'S');
      list.Linea(0, 0, 'mas', 1, 'Arial, normal, 9', salida, 'S');
      list.Linea(0, 0, utiles.espacios(5) + 'OTROS INGRESOS', 1, 'Arial, negrita, 9', salida, 'S');
    end;
    if (salida = 'T') then Begin
      list.LineaTxt('igual', True);
      Inc(lineas); if ControlarSalto then titulo;
      list.LineaTxt(utiles.espacios(54) + '-----------------------', True);
      Inc(lineas); if ControlarSalto then titulo;
      list.LineaTxt('UTILIDAD BRUTA                                                   ', False);
      list.importeTxt((tothaber - (totdebe * (-1))) * (-1), 12, 2, True);
      Inc(lineas); if ControlarSalto then titulo;
      list.LineaTxt('', True);
      Inc(lineas); if ControlarSalto then titulo;
      list.LineaTxt('mas', True);
      Inc(lineas); if ControlarSalto then titulo;
      list.LineaTxt(utiles.espacios(3) + 'OTROS INGRESOS', True);
      Inc(lineas); if ControlarSalto then titulo;
    end;
  end;

  if (salida = 'P') or (salida = 'I') then
    if l then list.Linea(0, 0, utiles.espacios(5) + 'OTROS INGRESOS', 1, 'Arial, negrita, 9', salida, 'S') else
      list.Linea(0, 0, utiles.espacios(5) + 'INGRESOS', 1, 'Arial, negrita, 9', salida, 'S');
  if (salida = 'T') then Begin
    if l then list.LineaTxt(utiles.espacios(3) + 'OTROS INGRESOS', True) else
      list.LineaTxt(utiles.espacios(3) + 'INGRESOS', True);
    Inc(lineas); if ControlarSalto then titulo;
  end;

  if ListMovimientos(ctestres.Digctaingr, salida) > 0 then
    begin
      if (salida = 'P') or (salida = 'I') then Begin
        list.Linea(0, 0, '', 1, 'Arial, normal, 9', salida, 'N');
        list.derecha(90, list.lineactual, '###############', '------------------', 2, 'Arial, negrita, 9');
        list.Linea(0, 0, ' ', 1, 'Arial, negrita, 9', salida, 'S');
        list.importe(90, list.lineactual, '', totingresos, 2, 'Arial, negrita, 9');
        list.Linea(0, 90, ' ', 3, 'Arial, negrita, 9', salida, 'S');
      end;
      if (salida = 'T') then Begin
        list.LineaTxt(utiles.espacios(55) +  '----------------------', True);
        Inc(lineas); if ControlarSalto then titulo;
        list.LineaTxt(utiles.espacios(65), False);
        list.importetxt(totingresos, 12, 2, True);
        Inc(lineas); if ControlarSalto then titulo;
      end;
    end;

  if (salida = 'P') or (salida = 'I') then Begin
    list.Linea(0, 0, 'menos', 1, 'Arial, normal, 9', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
    if l then list.Linea(0, 0, utiles.espacios(5) + 'OTROS EGRESOS', 1, 'Arial, negrita, 9', salida, 'S') else
      list.Linea(0, 0, utiles.espacios(5) + 'EGRESOS', 1, 'Arial, negrita, 9', salida, 'S');
  end;
  if (salida = 'T') then Begin
    list.LineaTxt('menos', True);
    Inc(lineas); if ControlarSalto then titulo;
    if l then list.LineaTxt('OTROS EGRESOS', True) else list.LineaTxt('EGRESOS', True);
    Inc(lineas); if ControlarSalto then titulo;
  end;

  if ListMovimientos(ctestres.Digctaegr, salida) > 0 then
    begin
      if (salida = 'P') or (salida = 'I') then Begin
        list.Linea(0, 0, '', 1, 'Arial, normal, 9', salida, 'N');
        list.derecha(70, list.lineactual, '###############', '------------------', 2, 'Arial, negrita, 9');
        list.Linea(0, 0, ' ', 1, 'Arial, negrita, 9', salida, 'N');
        list.importe(70, list.lineactual, '', totegresos, 2, 'Arial, negrita, 9');
        list.Linea(0, 80, ' ', 3, 'Arial, negrita, 9', salida, 'S');
      end;
      if (salida = 'T') then Begin
        list.LineaTxt(utiles.espacios(48) + '------------------', True);
        Inc(lineas); if ControlarSalto then titulo;
        list.LineaTxt(utiles.espacios(54), False);
        list.importetxt(totegresos, 12, 2, True);
        Inc(lineas); if ControlarSalto then titulo;
      end;
    end;

   if (salida = 'P') or (salida = 'I') then Begin
    list.Linea(0, 0, ' ', 1, 'Arial, negrita, 9', salida, 'S');
    list.Linea(0, 0, 'UTILIDAD NETA OPERATIVA', 1, 'Arial, negrita, 9', salida, 'S');
    if (tothaber - (totdebe * (-1))) * (-1) + (totingresos - totegresos) < 0 then list.importe(70, list.lineactual, '', (tothaber - (totdebe * (-1))) * (-1) + (totingresos - totegresos), 2, 'Arial, negrita, 9')
      else list.importe(90, list.lineactual, '', (tothaber - (totdebe * (-1))) * (-1) + (totingresos - totegresos), 2, 'Arial, negrita, 9');
   end;
   if (salida = 'T') then Begin
    list.LineaTxt('UTILIDAD NETA OPERATIVA                                          ', False);
    if (tothaber - (totdebe * (-1))) * (-1) + (totingresos - totegresos) < 0 then list.importeTxt((tothaber - (totdebe * (-1))) * (-1) + (totingresos - totegresos), 12, 2, True)
      else list.importetxt((tothaber - (totdebe * (-1))) * (-1) + (totingresos - totegresos), 12, 2, True);
    Inc(lineas); if ControlarSalto then titulo;
   end;


  //list.CompletarPagina;
  //list.Linea(0, 0, list.linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
  //list.Linea(0, 0, 'Pág.: ' + utiles.sLlenarIzquierda(IntToStr(list.nroPagina), 4, '0'), 1, 'Arial, normal, 8', salida, 'S');

  ctestres.desconectar;

  if (salida = 'P') or (salida = 'I') then list.FinList;
  if (salida = 'T') then list.FinalizarImpresionModoTexto(1); 
end;

procedure TTEstadoResultados.titulo;
// objetivo.... listar titulo en modo texto
Begin
  ListarDatosEmpresa('T');
  list.LineaTxt('', True);
  list.LineaTxt(CHR18 + 'Estado de Resultados                                       Hoja: ' + IntToStr(Pag), True);
   list.LineaTxt('', True);
  list.LineaTxt(CHR15 + 'Código            Cuenta                                     Debe      Haber', True);
  list.LineaTxt(CHR18 + utiles.sLlenarIzquierda(lin, 80, Caracter), True);
  list.LineaTxt('', True);
  Lineas := Lineas + 6;
end;

{===============================================================================}

function estres: TTEstadoResultados;
begin
  if xestres = nil then
    xestres := TTEstadoResultados.Create;
  Result := xestres;
end;

{===============================================================================}

initialization

finalization
  xestres.Free;

end.