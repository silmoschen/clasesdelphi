unit CDDBExpress;

interface

uses FMTBcd, DB, SqlExpr, Provider, DBClient, SysUtils, Dialogs;

type

TTdbExpress = class
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  function   Conectar(xbasedatos, xusuario, xpassword, xdriver, xgetDriverFunc, xLibraryName, xvendorLib: String): Boolean; overload;
  function   Conectar(xarchivo: String): Boolean; overload;
  function   Conectar(xarchivo, xbasedatos, xusuario, xpassword: String): Boolean; overload;
  procedure  Desconectar;
  function   setConexion: TSQLConnection;

  function   Buscar(xtabla: TClientDataSet; xcampo1, xvalor1: String): boolean; overload;
  function   Buscar(xtabla: TClientDataSet; xcampo1, xcampo2, xvalor1, xvalor2: String): boolean; overload;
  function   Buscar(xtabla: TClientDataSet; xcampo1, xcampo2, xcampo3, xvalor1, xvalor2, xvalor3: String): boolean; overload;
  function   Buscar(xtabla: TClientDataSet; xcampo1, xcampo2, xcampo3, xcampo4, xvalor1, xvalor2, xvalor3, xvalor4: String): boolean; overload;
  function   Buscar(xtabla: TClientDataSet; xcampo1, xcampo2, xcampo3, xcampo4, xcampo5, xvalor1, xvalor2, xvalor3, xvalor4, xvalor5: String): boolean; overload;
  function   Buscar(xtabla: TClientDataSet; xcampo1, xcampo2, xcampo3, xcampo4, xcampo5, xcampo6, xvalor1, xvalor2, xvalor3, xvalor4, xvalor5, xvalor6: String): boolean; overload;
  function   Buscar(xtabla: TClientDataSet; xcampo1, xcampo2, xcampo3, xcampo4, xcampo5, xcampo6, xcampo7, xvalor1, xvalor2, xvalor3, xvalor4, xvalor5, xvalor6, xvalor7: String): boolean; overload;

  procedure  BuscarEnFormaContextual(xtabla: TClientDataSet; xcampo1, xvalor1: String); overload;
  procedure  BuscarEnFormaContextual(xtabla: TClientDataSet; xcampo1, xcampo2, xvalor1, xvalor2: String); overload;

  function   InstanciarTabla(xtabla: String): TClientDataSet; overload;
  function   InstanciarTabla(xtabla: String; c: TSQLConnection): TClientDataSet; overload;
  procedure  closeDB(xtabla: TClientDataSet);
  function   tranSQL(xsql: String): TClientDataSet;

  procedure  Filtrar(xtabla: TClientDataSet; expresion: String);
  procedure  QuitarFiltro(xtabla: TClientDataSet);
 private
  { Declaraciones Privadas }
  indice: String;
  DBEDatabase: TSQLConnection;
  DBETable: TSQLTable;
  DataSetProvider: TDataSetProvider;
  ClientDataSet: TClientDataSet;
end;

function dbExpress: TTdbExpress;

implementation

var
  xdbExpress: TTdbExpress = nil;

constructor TTdbExpress.Create;
begin
end;

destructor TTdbExpress.Destroy;
begin
  inherited Destroy;
end;

function TTdbExpress.Conectar(xbasedatos, xusuario, xpassword, xdriver, xgetDriverFunc, xLibraryName, xvendorLib: String): Boolean;
// Objetivo...: Establecer una conexión a un Driver
Begin
  if DBEDatabase = Nil then Begin
    DBEDatabase := TSQLConnection.Create(nil);
    DBEDatabase.DriverName    := xdriver;
    DBEDatabase.Params.Add('database=' + xbasedatos);
    DBEDatabase.Params.Add('user_name=' + xusuario);
    DBEDatabase.Params.Add('password=' + xpassword);
    DBEDatabase.GetDriverFunc := xgetDriverFunc;
    DBEDatabase.LibraryName   := xlibraryName;
    DBEDatabase.VendorLib     := xvendorLib;
    DBEDatabase.LoginPrompt   := False;
    try
      DBEDatabase.Connected := True;
    except
      on E:TSQLConnection do showmessage('Error al Conectar');    //(E.Message + ' ' + IntToStr(E.IBErrorCode));
    end;
    Result := DBEDatabase.Connected;
  End else
    Result := False;
End;

function TTdbExpress.Conectar(xarchivo: String): Boolean;
// Objetivo...: Establecer la conexión desde una DB
var
  archivo: TextFile;
  driver, database, username, pass, driverfun, libraryname, vendorlib: String;
Begin
  if FileExists(xarchivo) then Begin
    AssignFile(archivo, xarchivo);
    reset(archivo);
    readln(archivo, database);
    readln(archivo, username);
    readln(archivo, pass);
    readln(archivo, driver);
    readln(archivo, driverfun);
    readln(archivo, libraryname);
    readln(archivo, vendorlib);
    closeFile(archivo);
    result := Conectar(database, username, pass, driver, trim(driverfun), libraryname, vendorlib);
  end else
    Result := False;
End;

function TTdbExpress.Conectar(xarchivo, xbasedatos, xusuario, xpassword: String): Boolean;
// Objetivo...: Conectar a un Driver proporcionando la base de datos y el usuario
var
  archivo: TextFile;
  driver, database, username, pass, driverfun, libraryname, vendorlib: String;
Begin
  if FileExists(xarchivo) then Begin
    AssignFile(archivo, xarchivo);
    reset(archivo);
    readln(archivo, driver);
    readln(archivo, database);
    readln(archivo, username);
    readln(archivo, pass);
    readln(archivo, driverfun);
    readln(archivo, libraryname);
    readln(archivo, vendorlib);
    closeFile(archivo);
    database := xbasedatos;
    username := xusuario;
    pass     := xpassword;
    result   := Conectar(database, username, pass, driver, trim(driverfun), libraryname, vendorlib);
  end else
    Result := False;
End;

procedure TTdbExpress.Desconectar;
// Objetivo...: Desconectar Driver
Begin
  if DBEDatabase <> Nil then
    if DBEDatabase.Connected then Begin
      DBEDatabase.Connected := False;
      DBEDatabase.Destroy;
      DBEDatabase := Nil;
    end;
end;

function TTdbExpress.setConexion: TSQLConnection;
// Objetivo...: Retornar Conexión
Begin
  Result := DBEDatabase;
end;

function  TTdbExpress.InstanciarTabla(xtabla: String): TClientDataSet;
// Objetivo...: Instanciar tabla/client data set
Begin
  DBETable                   := TSQLTable.Create(nil);
  DBETable.SQLConnection     := DBEDatabase;
  DBETable.TableName         := xtabla;
  DataSetProvider            := TDataSetProvider.Create(nil);
  DataSetProvider.DataSet    := DBETable;
  ClientDataSet              := TClientDataSet.Create(nil);
  ClientDataSet.SetProvider(DataSetProvider);
  Result                     := ClientDataSet;
end;

function  TTdbExpress.InstanciarTabla(xtabla: String; c: TSQLConnection): TClientDataSet;
// Objetivo...: Instanciar tabla/client data set
Begin
  DBETable                   := TSQLTable.Create(nil);
  DBETable.SQLConnection     := c;
  DBETable.TableName         := xtabla;
  DataSetProvider            := TDataSetProvider.Create(nil);
  DataSetProvider.DataSet    := DBETable;
  ClientDataSet              := TClientDataSet.Create(nil);
  ClientDataSet.SetProvider(DataSetProvider);
  Result                     := ClientDataSet;
end;

function  TTdbExpress.tranSQL(xsql: String): TClientDataSet;
// Objetivo...: Disparar una Sentencia SQL
var
  DBEsql: TSQLQuery;
Begin
  DBEsql                     := TSQLQuery.Create(nil);
  DBEsql.SQLConnection       := DBEDatabase;
  DBEsql.SQL.Add(xsql);
  DataSetProvider            := TDataSetProvider.Create(nil);
  DataSetProvider.DataSet    := DBEsql;
  ClientDataSet              := TClientDataSet.Create(nil);
  ClientDataSet.SetProvider(DataSetProvider);
  ClientDataSet.Execute;
  Result                     := ClientDataSet;
end;

procedure TTdbExpress.closeDB(xtabla: TClientDataSet);
// Objetivo...: Cerrar tabla/client data set
Begin
  if xtabla.Active then
    if xtabla.ChangeCount > 0 then xtabla.ApplyUpdates(-1);
  if xtabla.Active then xtabla.Close;
  xtabla.DestroyComponents;
  //xtabla.Free;
End;

function TTdbExpress.Buscar(xtabla: TClientDataSet; xcampo1, xvalor1: String): boolean;
// Objetivo...: Recuperar una Instancia
Begin
  if xtabla.IndexFieldNames <> UpperCase(xcampo1) then xtabla.IndexFieldNames := UpperCase(xcampo1);
  Result := xtabla.FindKey([xvalor1]);
end;

function TTdbExpress.Buscar(xtabla: TClientDataSet; xcampo1, xcampo2, xvalor1, xvalor2: String): boolean;
// Objetivo...: Recuperar una Instancia
Begin
  indice := UpperCase(xcampo1 + ';' + xcampo2);
  if xtabla.IndexFieldNames <> indice then xtabla.IndexFieldNames := UpperCase(indice);
  xtabla.SetKey;
  xtabla.FieldByName(xcampo1).AsString := xvalor1;
  xtabla.FieldByName(xcampo2).AsString := xvalor2;
  Result := xtabla.GotoKey;
end;

function TTdbExpress.Buscar(xtabla: TClientDataSet; xcampo1, xcampo2, xcampo3, xvalor1, xvalor2, xvalor3: String): boolean;
// Objetivo...: Recuperar una Instancia
Begin
  indice := UpperCase(xcampo1 + ';' + xcampo2 + ';' + xcampo3);
  if xtabla.IndexFieldNames <> indice then xtabla.IndexFieldNames := UpperCase(indice);
  xtabla.SetKey;
  xtabla.FieldByName(xcampo1).AsString := xvalor1;
  xtabla.FieldByName(xcampo2).AsString := xvalor2;
  xtabla.FieldByName(xcampo3).AsString := xvalor3;
  Result := xtabla.GotoKey;
end;

function TTdbExpress.Buscar(xtabla: TClientDataSet; xcampo1, xcampo2, xcampo3, xcampo4, xvalor1, xvalor2, xvalor3, xvalor4: String): boolean;
// Objetivo...: Recuperar una Instancia
Begin
  indice := UpperCase(xcampo1 + ';' + xcampo2 + ';' + xcampo3 + ';' + xcampo4);
  if xtabla.IndexFieldNames <> indice then xtabla.IndexFieldNames := UpperCase(indice);
  xtabla.SetKey;
  xtabla.FieldByName(xcampo1).AsString := xvalor1;
  xtabla.FieldByName(xcampo2).AsString := xvalor2;
  xtabla.FieldByName(xcampo3).AsString := xvalor3;
  xtabla.FieldByName(xcampo4).AsString := xvalor4;
  Result := xtabla.GotoKey;
end;

function TTdbExpress.Buscar(xtabla: TClientDataSet; xcampo1, xcampo2, xcampo3, xcampo4, xcampo5, xvalor1, xvalor2, xvalor3, xvalor4, xvalor5: String): boolean;
// Objetivo...: Recuperar una Instancia
Begin
  indice := UpperCase(xcampo1 + ';' + xcampo2 + ';' + xcampo3 + ';' + xcampo4 + ';' + xcampo5);
  if xtabla.IndexFieldNames <> indice then xtabla.IndexFieldNames := UpperCase(indice);
  xtabla.SetKey;
  xtabla.FieldByName(xcampo1).AsString := xvalor1;
  xtabla.FieldByName(xcampo2).AsString := xvalor2;
  xtabla.FieldByName(xcampo3).AsString := xvalor3;
  xtabla.FieldByName(xcampo4).AsString := xvalor4;
  xtabla.FieldByName(xcampo5).AsString := xvalor5;
  Result := xtabla.GotoKey;
end;

function TTdbExpress.Buscar(xtabla: TClientDataSet; xcampo1, xcampo2, xcampo3, xcampo4, xcampo5, xcampo6, xvalor1, xvalor2, xvalor3, xvalor4, xvalor5, xvalor6: String): boolean;
// Objetivo...: Recuperar una Instancia
Begin
  indice := UpperCase(xcampo1 + ';' + xcampo2 + ';' + xcampo3 + ';' + xcampo4 + ';' + xcampo5 + ';' + xcampo6);
  if xtabla.IndexFieldNames <> indice then xtabla.IndexFieldNames := UpperCase(indice);
  xtabla.SetKey;
  xtabla.FieldByName(xcampo1).AsString := xvalor1;
  xtabla.FieldByName(xcampo2).AsString := xvalor2;
  xtabla.FieldByName(xcampo3).AsString := xvalor3;
  xtabla.FieldByName(xcampo4).AsString := xvalor4;
  xtabla.FieldByName(xcampo5).AsString := xvalor5;
  xtabla.FieldByName(xcampo6).AsString := xvalor6;
  Result := xtabla.GotoKey;
end;

function TTdbExpress.Buscar(xtabla: TClientDataSet; xcampo1, xcampo2, xcampo3, xcampo4, xcampo5, xcampo6, xcampo7, xvalor1, xvalor2, xvalor3, xvalor4, xvalor5, xvalor6, xvalor7: String): boolean;
// Objetivo...: Recuperar una Instancia
Begin
  indice := UpperCase(xcampo1 + ';' + xcampo2 + ';' + xcampo3 + ';' + xcampo4 + ';' + xcampo5 + ';' + xcampo6 + ';' + xcampo7);
  if xtabla.IndexFieldNames <> indice then xtabla.IndexFieldNames := UpperCase(indice);
  xtabla.SetKey;
  xtabla.FieldByName(xcampo1).AsString := xvalor1;
  xtabla.FieldByName(xcampo2).AsString := xvalor2;
  xtabla.FieldByName(xcampo3).AsString := xvalor3;
  xtabla.FieldByName(xcampo4).AsString := xvalor4;
  xtabla.FieldByName(xcampo5).AsString := xvalor5;
  xtabla.FieldByName(xcampo6).AsString := xvalor6;
  xtabla.FieldByName(xcampo7).AsString := xvalor7;
  Result := xtabla.GotoKey;
end;

procedure TTdbExpress.BuscarEnFormaContextual(xtabla: TClientDataSet; xcampo1, xvalor1: String);
// Objetivo...: Busqueda contextual
Begin
  if xtabla.IndexFieldNames <> UpperCase(xcampo1) then xtabla.IndexFieldNames := UpperCase(xcampo1);
  xtabla.FindNearest([xvalor1]);
end;

procedure TTdbExpress.BuscarEnFormaContextual(xtabla: TClientDataSet; xcampo1, xcampo2, xvalor1, xvalor2: String);
// Objetivo...: Recuperar una Instancia
Begin
  indice := UpperCase(xcampo1 + ';' + xcampo2);
  if xtabla.IndexFieldNames <> indice then xtabla.IndexFieldNames := UpperCase(indice);
  xtabla.SetKey;
  xtabla.FieldByName(xcampo1).AsString := xvalor1;
  xtabla.FieldByName(xcampo2).AsString := xvalor2;
  xtabla.GotoNearest;
end;


procedure TTdbExpress.Filtrar(xtabla: TClientDataSet; expresion: String);
// Objetivo...: Filtrar Tuplas
Begin
  xtabla.Filtered := False;
  xtabla.Filter   := expresion;
  xtabla.Filtered := True;
end;

procedure TTdbExpress.QuitarFiltro(xtabla: TClientDataSet);
// Objetivo...: Quitar Filtro
Begin
  xtabla.Filtered := False;
end;

{===============================================================================}

function dbExpress: TTdbExpress;
begin
  if xdbExpress = nil then
    xdbExpress := TTdbExpress.Create;
  Result := xdbExpress;
end;

{===============================================================================}

initialization

finalization
  xdbExpress.Free;

end.
