unit CImpFiscalLX300F;

interface

uses SysUtils, EPSON_Impresora_Fiscal_TLB;

type

TTIFiscal = class

 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  procedure   SetearPuerto(xpuerto: Integer);
  procedure   SetearVelocidad(xvelocidad: Integer);

  function    ImprimirCabeceraFactura(tidofi, salimp, letdoc, cantco, tiform, tiplet, reivem, reivco, nomco1, nomco2, tidoco, nudoco,
                                      bieuso, doco01, doco02, doco03, remit1, remit2, titait: WideString): Boolean;
  function    ImprimirItemsFactura(descri, cantid, preuni, tiva, parf1, parf2, parf3, extlin1, extlin2, extlin3, IVANO, parf4: WideString): Boolean;
  function    CerrarFactura(xopcion1, xopcion2: WideString): Boolean;
  function    TipoDePago(xtipopago, xcodigopago, xmodopago: WideString): Boolean;
  function    FinalizarFactura(xmodo, xletra, xcomentariofinal: WideString): Boolean;
 private
  { Declaraciones Privadas }
  PrinterFiscal: TPrinterFiscal;
end;

function impFiscalLX300: TTIFiscal;

implementation

var
  ximpFiscalLX300: TTIFiscal = nil;

constructor TTIFiscal.Create;
begin
  PrinterFiscal := TPrinterFiscal.Create(Nil);
  PrinterFiscal.PortNumber := 1;
  PrinterFiscal.BaudRate   := 9600;
end;

destructor TTIFiscal.Destroy;
begin
  inherited Destroy;
end;

procedure TTIFiscal.SetearPuerto(xpuerto: Integer);
// Objetivo...: Determinar el Puerto de Impresión
Begin
  PrinterFiscal.PortNumber := xpuerto;
end;

procedure TTIFiscal.SetearVelocidad(xvelocidad: Integer);
// Objetivo...: Determinar el Puerto de Impresión
Begin
  PrinterFiscal.BaudRate := xvelocidad;
end;

function TTIFiscal.ImprimirCabeceraFactura(tidofi, salimp, letdoc, cantco, tiform, tiplet, reivem, reivco, nomco1, nomco2, tidoco, nudoco,
                                    bieuso, doco01, doco02, doco03, remit1, remit2, titait: WideString): Boolean;
// Objetivo...: Impresión Datos de Cabecera
Begin
  Result := PrinterFiscal.openinvoice(tidofi, salimp, letdoc, cantco, tiform, tiplet, reivem, reivco, nomco1, nomco2, tidoco, nudoco, bieuso, doco01, doco02, doco03, remit1, remit2, titait);
end;

function TTIFiscal.ImprimirItemsFactura(descri, cantid, preuni, tiva, parf1, parf2, parf3, extlin1, extlin2, extlin3, IVANO, parf4: WideString): Boolean;
// Objetivo...: Impresión Items Factura
Begin
  Result := PrinterFiscal.SendInvoiceItem(descri, cantid, preuni, tiva, parf1, parf2, parf3, extlin1, extlin2, extlin3, IVANO, parf4);
end;

function TTIFiscal.CerrarFactura(xopcion1, xopcion2: WideString): Boolean;
// Objetivo...: Cerrar Factura
Begin
  Result := PrinterFiscal.GetInvoiceSubtotal(xopcion1, xopcion2);
end;

function TTIFiscal.TipoDePago(xtipopago, xcodigopago, xmodopago: WideString): Boolean;
// Objetivo...: Especificar Tipo de Pago
Begin
  Result := PrinterFiscal.SendInvoicePayment(xtipopago, xcodigopago, xmodopago);
end;

function TTIFiscal.FinalizarFactura(xmodo, xletra, xcomentariofinal: WideString): Boolean;
// Objetivo...: Cerrar Factura
Begin
  Result := PrinterFiscal.CloseInvoice(xmodo, xletra, xcomentariofinal);
end;

{===============================================================================}

function impFiscalLX300: TTIFiscal;
begin
  if ximpFiscalLX300 = nil then
    ximpFiscalLX300 := TTIFiscal.Create;
  Result := ximpFiscalLX300;
end;

{===============================================================================}

initialization

finalization
  ximpFiscalLX300.Free;

end.
