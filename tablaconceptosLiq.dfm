�
 TFMTABLALIQSUELDOS 0\  TPF0TfmTablaLiqSueldosfmTablaLiqSueldosLeft� Top� Width�Height� Caption    Concepto Liquidación de SueldosColor	clBtnFaceFont.CharsetDEFAULT_CHARSET
Font.ColorclWindowTextFont.Height�	Font.NameSystem
Font.Style OldCreateOrder	OnClose	FormCloseOnResize
FormResizeOnShowFormShowPixelsPerInch`
TextHeight TPanelPanel2Left TopWidth�Height~AlignalClient
BevelInner	bvLoweredBorderWidthCaptionPanel2TabOrder OnResizePanel2Resize 
TScrollBox	ScrollBoxLeftTopWidth�HeightrHorzScrollBar.IncrementHorzScrollBar.MarginHorzScrollBar.Range
VertScrollBar.MarginVertScrollBar.Range
AlignalClient
AutoScrollBorderStylebsNoneFont.CharsetDEFAULT_CHARSET
Font.ColorclBlackFont.Height�	Font.NameMS Sans Serif
Font.Style 
ParentFontTabOrder  TLabelLabel1Left$Top
Width$Height	AlignmenttaRightJustifyCaption   Código:  TLabelLabel2LeftrTop
Width1Height	AlignmenttaRightJustifyCaption	Concepto:  TLabelLabel3Left� Top Width0Height	AlignmenttaRightJustifyCaption	Tipo Mov.  TLabelLabel4Left� Top.Width,Height	AlignmenttaRightJustifyCaption	(R/T/E) :  TLabelLabel5Left.Top%Width6Height	AlignmenttaRightJustifyCaptionPorcentaje:  TLabelLabel7LeftTop Width+Height	AlignmenttaRightJustifyCaption	Aplicable  TLabelLabel8Left8Top-WidthHeight	AlignmenttaRightJustifyCaptionen:  TLabelLabel6Left Top?Width(Height	AlignmenttaRightJustifyCaption	   Fórmula:  TLabelLabel9Left6Top:WidthHeight	AlignmenttaRightJustifyCaptionMonto  TLabelLabel10LeftBTopEWidthHeight	AlignmenttaRightJustifyCaptionFijo:  TLabelLabel11LeftTopSWidthCHeight	AlignmenttaRightJustifyCaptionTipo de Carga  TLabelLabel12LeftTopaWidth+Height	AlignmenttaRightJustifyCaption(C/M/N):  TLabelLabel13LeftoTopSWidth/Height	AlignmenttaRightJustifyCaption
Aplicar en  TLabelLabel14LeftfTopaWidth8Height	AlignmenttaRightJustifyCaptionPer. Desde:  TLabelLabel15Left� TopaWidth)Height	AlignmenttaRightJustifyCaption	   Período:  TLabelLabel16Left� TopSWidthHeight	AlignmenttaRightJustifyCaptionHasta  TLabelLabel17LefteTopSWidthHeight	AlignmenttaRightJustifyCaptionNro.  TLabelLabel18LefteTopaWidthHeight	AlignmenttaRightJustifyCaptionLiq.:  	TMaskEditcodigoLeftKTopWidth"HeightEditMask999;1; 	MaxLengthTabOrder Text   	OnKeyDowncodigoKeyDown  	TMaskEditconceptoLeft� TopWidth� HeightTabOrder	OnKeyDownconceptoKeyDown  	TMaskEdittipomovLeftTop#WidthHeightCharCaseecUpperCase	MaxLengthTabOrder	OnKeyDowntipomovKeyDown  
TEditValid
porcentajeLeftgTop"Width.HeightTabOrder	OnKeyDownporcentajeKeyDownValidtvDecimalPos  	TComboBox	aplicableLeftKTop#Width� Height
ItemHeightTabOrderTextTodas las Liquidaciones	OnKeyDownaplicableKeyDownItems.StringsTodas las Liquidaciones   1º Quincena   2º QuincenaMensual   	TMaskEditformulaLeftKTop=Width� HeightTabOrder	OnKeyDownformulaKeyDown  
TEditValid	montofijoLeftYTop=Width<HeightTabOrder	OnKeyDownmontofijoKeyDownValidtvDecimalPos  	TMaskEdit	tipocargaLeftKTopWWidthHeightCharCaseecUpperCaseTabOrder	OnKeyDowntipocargaKeyDown  	TMaskEditperdesdeLeft� TopWWidth:HeightEditMask99/9999;1; 	MaxLengthTabOrderText  /    	OnKeyDownperdesdeKeyDown  	TMaskEditperhastaLeftTopVWidth:HeightEditMask99/9999;1; 	MaxLengthTabOrder	Text  /    	OnKeyDownperhastaKeyDown  	TMaskEditnroliqLeft�TopVWidthHeightEditMask99;1; 	MaxLengthTabOrder
Text  	OnKeyDownnroliqKeyDown    
TStatusBar
StatusBar1Left Top� Width�HeightPanelsWidth@ Width2  SimplePanel  TPanelPanel1Left Top Width�HeightAlignalTop
BevelOuterbvNoneTabOrder TToolBarToolBar1Left Top Width�HeightCaptionToolBar1EdgeBorders Flat	ImagescontenedorImg.ImagenesFormsTabOrder  TDBNavigatorDBNavigatorLeft Top Width`Height
DataSourceDTSVisibleButtonsnbFirstnbPriornbNextnbLast Flat	Hints.StringsPrimer RegistroRegistro AnteriorRegistro SiguienteUltimo Registro TabOrder BeforeActionDBNavigatorBeforeAction  TToolButtonAltaLeft`Top HintAgregar RegistroCaptionAlta
ImageIndexParentShowHintShowHint	OnClick	AltaClick  TToolButtonBajaLeftwTop HintEliminar RegistroCaptionBaja
ImageIndexParentShowHintShowHint	OnClick	BajaClick  TToolButton	ModificarLeft� Top HintModificar DatosCaption	Modificar
ImageIndexParentShowHintShowHint	OnClickModificarClick  TToolButtonBuscarLeft� Top Hint
Buscar ...CaptionBuscar
ImageIndexParentShowHintShowHint	  TToolButtonDeshacerLeft� Top HintDeshacerCaptionDeshacer
ImageIndexParentShowHintShowHint	  TToolButtonSalirLeft� Top HintSalirCaptionSalir
ImageIndex	ParentShowHintShowHint	OnClick
SalirClick    TDataSourceDTSLeft    