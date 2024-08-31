unit CopiarArch;

interface

uses SysUtils;

procedure CopiarArchivos(datorigen, datdestino: string);

implementation

procedure CopiarArchivos(datorigen, datdestino: string);
var
  // Variables de Archivos a Utilizar en la rutina de copiado
  InFile, OutFile: File;
  // Variables para llevar cuenta y relación de registros leídos y escritos
  NumRecsRead {, NumRecsWritten}: integer;
  // Buffer utilizado para copiar el archivo
  Buf: array[1..4096] of Byte;
begin
  AssignFile(InFile, datorigen);
  AssignFile(OutFile, datdestino);
  // Abre los Archivos y configura el tamaño del registro de 1 byte
  Reset(InFile, 1);
  Rewrite(OutFile, 1);

  while not EOF(InFile) do
    begin
      // Lee un bloque de 4K bytes en el buffer
      BlockRead(InFile, Buf, SizeOf(Buf), NumRecsRead);
      // Escribe un buffer de 4K bytes en el mismo archivo
      BlockWrite(OutFile, Buf, NumRecsRead);
    end;
    // Vacía los buffers en el disco
    CloseFile(InFile);
    CloseFile(OutFile);
end;

end.
