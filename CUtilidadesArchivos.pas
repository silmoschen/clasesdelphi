unit CUtilidadesArchivos;

interface

uses
  SysUtils, WinTypes, Classes, Dialogs, Controls, Graphics, Windows, Messages,
  StdCtrls, CUtilidadesDiscos, Backup, CUtiles, Forms, Unit1;

type
  TTUtilidadesArchivos = class
    realizardiariamente, antiguedadparaborrar: ShortInt;

    constructor Create;
    destructor  Destroy; override;

    procedure   Deltree( cPath: string );
    procedure   CompactarArchivos(archivoorigen, archivodestino: string);
    procedure   DescompactarArchivos(archivoorigen, directoriodestino: string);
    procedure   CopiarArchivos(xdir, xarchivos, xdrive: string); overload;
    procedure   ListaDeArchivos(xdir, xarchivos, xdrive: string; var lista: array of String);
    procedure   CopiarArchivos(datorigen, datdestino: string); overload;
    procedure   BorrarArchivo(xarchivo: String);
    procedure   BorrarArchivos(xdir, xarchivos: String);
    procedure   BorrarBackupsTemporales(xdir, xfecha, xdias: string);
    procedure   CrearDirectorio(xdirectorio: String);
    function    WinExecNoWait32(FileName:String; Visibility : integer): Integer;
    function    FormatearDiskette(xdrive: Char): Boolean;
    function    verificarSiHayDiskette(xdrive: Char): Boolean;
    function    setListaArchivos(cPath, cExtension: String): TStringList; overload;
    function    setListaArchivos(cPath, cExtension, cCaracteresIniciales: String): TStringList; overload;
    function    setListaDirectorios(cPath: String): TStringList;
    procedure   GuardarConfiguracionBackup(xrealizardiariamente, xantiguedadparaborrar: ShortInt);
    procedure   CargarConfiguracionBackup;
    procedure   RestaurarBackup(xarchivo, xdirectorio: String);
  private
    { Private declarations }
    archivo: TextFile;
  public
    { Public declarations }
  end;

function utilesarchivos: TTUtilidadesArchivos;

implementation

var
  xutilesarch: TTUtilidadesArchivos = nil;

constructor TTUtilidadesArchivos.Create;
Begin
  inherited Create;
end;

destructor  TTUtilidadesArchivos.Destroy;
Begin
  inherited Destroy;
end;

procedure TTUtilidadesArchivos.Deltree( cPath: string );
// Objetivo...: Borrar directorios en cascada tipo deltree en DOS
var
   search: TSearchRec;
   nFiles: integer;
begin
     nFiles:=FindFirst( cPath + '\*.*', faAnyFile,  search );
     while nFiles=0 do
     begin
          if Search.Attr = faDirectory then
          begin
               if (Search.Name<>'.') and (Search.Name<>'..') then
               begin
                  if DirectoryExists (  cPath + '\' + Search.Name ) then Deltree( cPath + '\' + Search.Name );
                  if DirectoryExists (  cPath + '\' + Search.Name ) then RMDir( cPath + '\' + Search.Name );
               end;
          end
          else
              SysUtils.DeleteFile(cPath + '\' + Search.Name);
          nFiles:=FindNext( Search );
     end;
     FindClose(Search.FindHandle);
     ChDir('\');
     RMDir(cPath);
end;

procedure TTUtilidadesArchivos.CompactarArchivos(archivoorigen, archivodestino: string);
// Objetivo...: Compactar archivos
var
  BackupFile: TBackupFile;
  lista: TStringList;
Begin
  BackupFile := TBackupFile.Create(nil);
  lista := TStringList.Create;
  lista.Add(archivoorigen);
  BackupFile.maxSize := 0;
  Backupfile.backuptitle      := 'Facturacion';
  Backupfile.backupmode       := TBackupMode(0);
  Backupfile.compressionLevel := TCompressionLevel(0);
  Backupfile.SaveFileID       := True;
  backupfile.Backup(lista, archivodestino);
  BackupFile.Destroy;
  lista.Destroy;
end;

procedure TTUtilidadesArchivos.DescompactarArchivos(archivoorigen, directoriodestino: string);
// Objetivo...: Descompactamos los datos
begin
  Application.CreateForm(TfmBackup, fmBackup);
  fmBackup.DirectoryListBox1.Directory := archivoorigen;
  fmBackup.FileListBox1.ItemIndex := 0;
  fmBackup.FileListBox1Click(nil);   // Cargamos los datos del archivo
  fmBackup.rbOtherPath.Checked := True;
  fmBackup.EdPath.Text         := directoriodestino;
  fmBackup.OcultarMensaje      := True;
  fmBackup.Button3Click(Self);
  fmBackup.Release; fmBackup := nil;
end;

procedure TTUtilidadesArchivos.CopiarArchivos(xdir, xarchivos, xdrive: string);
// Objetivo...: copiar archivos a una unidad determinada
var
  DirInfo: TSearchRec; r: Integer;
begin
  r := FindFirst(xdir + '\' + xarchivos, FaAnyfile, DirInfo);
  while r = 0 do  begin
    if Copy(pChar(DirInfo.Name), Length(Trim(pChar(DirInfo.Name))) - 1, 1) <> '.' then
      CopiarArchivos(xdir + '\' + pChar(DirInfo.Name), xdrive + '\' + ExtractFileName(pChar(DirInfo.Name)));
    r := FindNext(DirInfo);
  end;
end;

procedure TTUtilidadesArchivos.ListaDeArchivos(xdir, xarchivos, xdrive: string; var lista: array of String);
// Objetivo...: copiar archivos a una unidad determinada
var
  DirInfo: TSearchRec; r, i: Integer;
begin
  i := 0;
  r := FindFirst(xdir + '\' + xarchivos, FaAnyfile, DirInfo);
  while r = 0 do  begin
    if Copy(pChar(DirInfo.Name), Length(Trim(pChar(DirInfo.Name))) - 1, 1) <> '.' then Begin
      Inc(i);
      lista[i] := xdrive + '\' + ExtractFileName(pChar(DirInfo.Name));
    end;
    // CopiarArchivos(xdir + '\' + pChar(DirInfo.Name), xdrive + '\' + ExtractFileName(pChar(DirInfo.Name)));
    r := FindNext(DirInfo);
  end;
end;

procedure TTUtilidadesArchivos.BorrarArchivo(xarchivo: String);
// Objetivo...: Borrar un archivo
var
  F: File;
begin
  if (FileExists(xarchivo)) and (xarchivo <> '.') then Begin
    AssignFile(F, xarchivo);
    Reset(F);
    CloseFile(F);
    try
      Erase(F);
    finally
    end;      
  end;
end;

procedure TTUtilidadesArchivos.BorrarArchivos(xdir, xarchivos: String);
// Objetivo...: Borrar archivos en lote
var
  DirInfo: TSearchRec; r: Integer;
begin
  r := FindFirst(xdir + '\' + xarchivos, FaAnyfile, DirInfo);
  while r = 0 do  begin
    BorrarArchivo(xdir + '\' + pChar(DirInfo.Name));
    r := FindNext(DirInfo);
  end;
end;

procedure TTUtilidadesArchivos.CrearDirectorio(xdirectorio: String);
// Objetivo...: Crear Directorio
begin
  if not DirectoryExists(xdirectorio) then
    if not CreateDir(xdirectorio) then
      raise Exception.Create('Se ha producido un Error, imposible crear directorio ' + xdirectorio);
end;

procedure TTUtilidadesArchivos.CopiarArchivos(datorigen, datdestino: string);
var
  // Variables de Archivos a Utilizar en la rutina de copiado
  InFile, OutFile: File;
  // Variables para llevar cuenta y relaci�n de registros le�dos y escritos
  NumRecsRead: integer;
  // Buffer utilizado para copiar el archivo
  Buf: array[1..4096] of Byte;
begin
  if (FileExists(datorigen)) and (DirectoryExists(ExtractFilePath(datdestino))) then Begin
    AssignFile(InFile, datorigen);
    AssignFile(OutFile, datdestino);
    // Abre los Archivos y configura el tama�o del registro de 1 byte
    Reset(InFile, 1);
    Rewrite(OutFile, 1);

    while not EOF(InFile) do
      begin
        // Lee un bloque de 4K bytes en el buffer
        BlockRead(InFile, Buf, SizeOf(Buf), NumRecsRead);
        // Escribe un buffer de 4K bytes en el mismo archivo
        BlockWrite(OutFile, Buf, NumRecsRead);
      end;
    // Vac�a los buffers en el disco
    CloseFile(InFile);
    CloseFile(OutFile);
  end;
end;

procedure TTUtilidadesArchivos.BorrarBackupsTemporales(xdir, xfecha, xdias: string);
// Objetivo...: Eliminar los backups temporales
var
  F: File;
begin
  if FileExists(xdir + '\' + utiles.sExprFecha(utiles.FechaRestarDias(xfecha, StrToInt(xdias))) + '.BCK') then Begin
    AssignFile(F, xdir + '\' + utiles.sExprFecha(utiles.FechaRestarDias(xfecha, StrToInt(xdias))) + '.BCK');
    Reset(F);
    CloseFile(F);
    Erase(F);
  end;
end;

function TTUtilidadesArchivos.WinExecNoWait32(FileName:String; Visibility : integer):integer;
// Funci�n que permite la ejecuci�n de un programa externo
var
  zAppName:array[0..512] of char;
  zCurDir:array[0..255] of char;
  WorkDir:String;
  StartupInfo:TStartupInfo;
  ProcessInfo:TProcessInformation;
begin
  StrPCopy(zAppName,FileName);
  GetDir(0,WorkDir);
  StrPCopy(zCurDir,WorkDir);
  FillChar(StartupInfo,Sizeof(StartupInfo),#0);
  StartupInfo.cb := Sizeof(StartupInfo);

  StartupInfo.dwFlags := STARTF_USESHOWWINDOW;
  StartupInfo.wShowWindow := Visibility;
  if not CreateProcess(nil,
    zAppName,          { pointer to command line string }
    nil,               { pointer to process security attributes}
    nil,                           { pointer to thread security attributes}
    false,             { handle inheritance flag }
    CREATE_NEW_CONSOLE or    { creation flags }
    NORMAL_PRIORITY_CLASS,
    nil,               { pointer to new environment block }
    nil,               { pointer to current directory name }
    StartupInfo,       { pointer to STARTUPINFO }
    ProcessInfo) then Result := -1 { pointer to PROCESS_INF }
end;

function TTUtilidadesArchivos.FormatearDiskette(xdrive: Char): Boolean;
// Objetivo...: Formatear Diskette
Begin
  Application.CreateForm(TTTUtilidadesDiscos, TTUtilidadesDiscos);
  Result := TTUtilidadesDiscos.FormatDiskette(xdrive, False);
  TTUtilidadesDiscos.Release; TTUtilidadesDiscos := nil;
end;

function TTUtilidadesArchivos.verificarSiHayDiskette(xdrive: Char): Boolean;
// Objetivo...: Verificar que la unidad este preparada
Begin
  Application.CreateForm(TTTUtilidadesDiscos, TTUtilidadesDiscos);
  Result := TTUtilidadesDiscos.DiskInDrive(xdrive);
  TTUtilidadesDiscos.Release; TTUtilidadesDiscos := nil;
end;

function  TTUtilidadesArchivos.setListaArchivos(cPath, cExtension: String): TStringList;
// Objetivo...: Devolver una lista con los archivos del directorio
var
  DirInfo: TSearchRec; r: Integer;
  l: TStringList;
begin
  l := TStringList.Create;
  r := FindFirst(cpath + '\' + cExtension, FaAnyfile, DirInfo);
  while r = 0 do  begin
    if Copy(pChar(DirInfo.Name), Length(Trim(pChar(DirInfo.Name))) - 1, 1) <> '.' then
      l.Add(cpath + '\' + pChar(DirInfo.Name));
    r := FindNext(DirInfo);
  end;
  Result := l;
end;

function  TTUtilidadesArchivos.setListaArchivos(cPath, cExtension, cCaracteresIniciales: String): TStringList;
// Objetivo...: Devolver una lista con los archivos del directorio
var
  DirInfo: TSearchRec; r: Integer;
  l: TStringList;
begin
  l := TStringList.Create;
  r := FindFirst(cpath + '\' + cExtension, FaAnyfile, DirInfo);
  while r = 0 do  begin
    if Copy(pChar(DirInfo.Name), Length(Trim(pChar(DirInfo.Name))) - 1, 1) <> '.' then
      if lowercase(Copy(pChar(DirInfo.Name), 1, Length(cCaracteresIniciales))) = lowercase(cCaracteresIniciales) then l.Add(cpath + '\' + pChar(DirInfo.Name));
    r := FindNext(DirInfo);
  end;
  Result := l;
end;

function  TTUtilidadesArchivos.setListaDirectorios(cPath: String): TStringList;
// Objetivo...: Devolver una lista con los archivos del directorio
var
  DirInfo: TSearchRec; r: Integer;
  l: TStringList;
begin
  l := TStringList.Create;
  r := FindFirst(cpath + '\*.*', FaAnyfile, DirInfo);
  while r = 0 do  begin
    if DirectoryExists(cPath + '\' + (pChar(DirInfo.Name))) then
      if Copy(pChar(DirInfo.Name), 1, 1) <> '.' then l.Add(pChar(DirInfo.Name));
    r := FindNext(DirInfo);
  end;
  Result := l;
end;

procedure TTUtilidadesArchivos.GuardarConfiguracionBackup(xrealizardiariamente, xantiguedadparaborrar: ShortInt);
// Objetivo...: Guardar configuraciones del backup
Begin
  AssignFile(archivo, ExtractFilePath(application.ExeName) + 'configbackup.ini');
  Rewrite(archivo);
  WriteLn(archivo, xrealizardiariamente);
  WriteLn(archivo, xantiguedadparaborrar);
  closeFile(archivo);
end;

procedure TTUtilidadesArchivos.CargarConfiguracionBackup;
// Objetivo...: Cargar configuraci�n del backup
Begin
  if FileExists(ExtractFilePath(application.ExeName) + 'configbackup.ini') then Begin
    AssignFile(archivo, ExtractFilePath(application.ExeName) + 'configbackup.ini');
    Reset(archivo);
    ReadLn(archivo, realizardiariamente);
    ReadLn(archivo, antiguedadparaborrar);
    closeFile(archivo);
  end else Begin
    realizardiariamente := 0; antiguedadparaborrar := 0;
  end;
end;

procedure TTUtilidadesArchivos.RestaurarBackup(xarchivo, xdirectorio: String);
// Objetivo...: Cargar configuraci�n del backup
var
  BackupFile: TBackupFile;
  lista: TStringList;
Begin
  BackupFile := TBackupFile.Create(nil);
  BackupFile.restore(xarchivo, xdirectorio);
  BackupFile.Destroy;
end;

{===============================================================================}

function utilesarchivos: TTUtilidadesArchivos;
begin
  if xutilesarch = nil then
    xutilesarch := TTUtilidadesArchivos.Create;
  Result := xutilesarch;
end;

{===============================================================================}

initialization

finalization
  xutilesarch.Free;

end.
