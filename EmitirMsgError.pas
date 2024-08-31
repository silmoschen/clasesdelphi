{Objetivo....: Función que llama al cuadro de Mensajes de Error
 y visualiza el mensaje transmitido}
unit EmitirMsgError;

interface
uses SysUtils, Error;

procedure msgError(msg: string);

implementation

{Desarrollo de Procedimientos y Funciones}

procedure msgError(msg: string);
begin
  FError.MsgErr.Caption := msg;
  FError.ShowModal;
end;

end.
