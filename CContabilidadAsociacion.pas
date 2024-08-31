unit CContabilidadAsociacion;

interface

uses CBDT, SysUtils, DBTables, CUtiles, CIDBFM, CListar;

type

TTContabilidad = class(TObject)
  dbconexion, dbcc: String;
  EmpresaRsocial, EmpresaRsocial2, EmpresaCuit, EmpresaTelefono, EmpresaDireccion, EmpresaCodiva: String;
  LineasPag, Lineas_blanco: Integer; 
 public
  { Declaraciones Públicas }
  constructor Create; overload;
  constructor Create(xbase_datos, xusuario, xpassword: String); overload;
  destructor  Destroy; override;

  procedure   EstablecerParamtrosTitulo(xrsocial, xdireccion, xcuit, xtelefono, xcodiva: String);
  procedure   IniciarDatosEmpresa;
 protected
  { Declaraciones Protegidas }
  Pag, i, r, Cantcopias, Espacios: Integer;
  CHR18, CHR15, Caracter, lin: String;
  lineas: Integer;
  procedure   ListarDatosEmpresa(salida: char);
  function    ControlarSalto: boolean; virtual;
  procedure   RealizarSalto;
 private
  { Declaraciones Privadas }
  archivo: TextFile;
end;

function contabilidad: TTContabilidad;

implementation

var
  xcontabilidad: TTContabilidad = nil;

constructor TTContabilidad.Create;
begin
  inherited Create;
  IniciarDatosEmpresa;
  dbcc     := dbs.TDB.DatabaseName;
  CHR18    := CHR(18);
  CHR15    := CHR(15);
  Caracter := '-';

  {if dbs.TDB1 = nil then Begin
    if dbs.BaseClientServ = 'N' then Begin
      dbs.NuevaBaseDeDatos(dbs.DirSistema + '\cont', '', '');
      dbconexion := dbs.DirSistema + '\cont';
    end else Begin
      if Length(Trim(dbconexion)) > 0 then
        dbs.NuevaBaseDeDatos(dbconexion, 'sysdba', 'masterkey');
      if Length(Trim(dbconexion)) = 0 then
        dbs.NuevaBaseDeDatos('adrcontabilidad', 'sysdba', 'masterkey');
    end;
  end;
  if dbs.TDB1 <> nil then dbcc := dbs.TDB1.DatabaseName;}
end;

constructor TTContabilidad.Create(xbase_datos, xusuario, xpassword: String);
begin
  inherited Create;
  if dbs.TDB1 = nil then Begin
    if dbs.BaseClientServ = 'N' then Begin
      dbs.NuevaBaseDeDatos(dbs.DirSistema + '\cont', '', '');
      dbconexion := dbs.DirSistema + '\cont';
    end else Begin
      dbs.NuevaBaseDeDatos(xbase_datos, xusuario, xpassword);
    end;
  end;
  dbcc := dbs.TDB1.DatabaseName;
  IniciarDatosEmpresa;
end;


destructor TTContabilidad.Destroy;
begin
  inherited Destroy;
end;

procedure  TTContabilidad.IniciarDatosEmpresa;
// Objetivo...: Iniciar Datos para Impresion de Informes
Begin
  if FileExists(dbs.DirSistema + '\listinfcontables.ini') then Begin
    AssignFile(archivo, dbs.DirSistema + '\listinfcontables.ini');
    Reset(archivo);
    ReadLn(archivo, empresarsocial);
    ReadLn(archivo, empresadireccion);
    ReadLn(archivo, empresacuit);
    ReadLn(archivo, empresatelefono);
    ReadLn(archivo, empresacodiva);
    closeFile(archivo);
  end;
end;

procedure  TTContabilidad.EstablecerParamtrosTitulo(xrsocial, xdireccion, xcuit, xtelefono, xcodiva: String);
// Objetivo...: Definir Parametros para la Emisión de Titulos
Begin
  AssignFile(archivo, dbs.DirSistema + '\listinfcontables.ini');
  Rewrite(archivo);
  WriteLn(archivo, xrsocial);
  WriteLn(archivo, xdireccion);
  WriteLn(archivo, xcuit);
  WriteLn(archivo, xtelefono);
  WriteLn(archivo, xcodiva);
  closeFile(archivo);
  IniciarDatosEmpresa;
end;

procedure TTContabilidad.ListarDatosEmpresa(salida: char);
// Objetivo...: Listar Datos Empresa
Begin
  list.IniciarTitulos;
  pag := pag + 1; espacios := 2;
  IniciarDatosEmpresa;
  if (salida = 'I') or (salida = 'P') then Begin
    list.Titulo(0, 0, ' ', 1, 'Arial, negrita, 10');
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 8'); list.Titulo(espacios, list.Lineactual, empresaRsocial, 2, 'Arial, normal, 8');
    if Length(Trim(empresaRsocial2)) > 0 then Begin
      list.Titulo(0, 0, ' ', 1, 'Arial, normal, 7');
      list.Titulo(espacios, list.Lineactual, empresaRsocial2, 2, 'Arial, normal, 7');
    end;
    if Length(Trim(empresaCuit)) = 13 then Begin
     list.Titulo(0, 0, ' ', 1, 'Arial, normal, 7'); list.Titulo(espacios, list.Lineactual, empresaCuit, 2, 'Arial, normal, 7');
    end;
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 7'); list.Titulo(espacios, list.Lineactual, empresaDireccion, 2, 'Arial, normal, 7');
    list.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');
  end;
  if (salida = 'T') then Begin
    list.LineaTxt(CHR18, True);
    list.LineaTxt(empresaRsocial, True);
    Lineas := 2;
    if Length(Trim(empresaRsocial2)) > 0 then Begin
      list.LineaTxt(empresaRsocial2, True);
      Lineas := Lineas + 1;
    end;
    if Length(Trim(empresaCuit)) = 13 then Begin
     list.LineaTxt(empresaCuit, True);
     Lineas := Lineas + 1;
    end;
    list.LineaTxt(empresaDireccion, True);
    Lineas := Lineas + 1;
  end;
end;

function TTContabilidad.ControlarSalto: boolean;
// Objetivo...: salto de linea para las impresiones basadas en texto
var
  k: Integer;
begin
  Result := False;
  if lineas >= LineasPag then Begin
    //list.lineatxt(inttostr(lineas), True);
    if lineas_blanco = 0 then list.LineaTxt(CHR(12), True) else
      for k := 1 to lineas_blanco do list.LineaTxt('', True);
    Result := True;
  end;
end;

procedure TTContabilidad.RealizarSalto;
// Objetivo...: imprimir lineas en blanco hasta realizar salto de página
var
  k: Integer;
begin
  if lineas_blanco = 0 then list.LineaTxt(CHR(12), True) else Begin
    for k := lineas + 1 to LineasPag do list.LineaTxt('', True);
    lineas := LineasPag + 5;
    ControlarSalto;
  end;
end;

{===============================================================================}

function contabilidad: TTContabilidad;
begin
  if xcontabilidad = nil then
    xcontabilidad := TTContabilidad.Create;
  Result := xcontabilidad;
end;

{===============================================================================}

initialization

finalization
  xcontabilidad.Free;

end.
