// Borland C++ Builder
// Copyright (c) 1995, 1998 by Borland International
// All rights reserved

// (DO NOT EDIT: machine generated header) 'CDefVias.pas' rev: 3.00

#ifndef CDefViasHPP
#define CDefViasHPP
#include <tablas.hpp>
#include <DBTables.hpp>
#include <Db.hpp>
#include <SysUtils.hpp>
#include <SysInit.hpp>
#include <System.hpp>

//-- user supplied -----------------------------------------------------------

namespace Cdefvias
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TTDefvias;
class PASCALIMPLEMENTATION TTDefvias : public System::TObject 
{
	typedef System::TObject inherited;
	
public:
	System::AnsiString nomvia;
	System::AnsiString descrip;
	System::AnsiString estado;
	System::AnsiString codemp;
	Dbtables::TTable* tdefvia;
	__fastcall TTDefvias(System::AnsiString xnomvia, System::AnsiString xdescrip);
	__fastcall virtual ~TTDefvias(void);
	System::AnsiString __fastcall getNomvia();
	System::AnsiString __fastcall getDescrip();
	System::AnsiString __fastcall getEstado();
	System::AnsiString __fastcall getCodemp();
	bool __fastcall Buscar(System::AnsiString xnomvia);
	void __fastcall Grabar(System::AnsiString xnomvia, System::AnsiString xDescrip);
	void __fastcall Borrar(System::AnsiString xnomvia);
	void __fastcall getDatos(System::AnsiString xnomvia);
	void __fastcall OcuparVia(System::AnsiString xnomvia, System::AnsiString xcodemp, System::AnsiString 
		xempresa);
	void __fastcall ViasLibres(System::AnsiString empresa);
	void __fastcall conectar(void);
	void __fastcall desconectar(void);
};

//-- var, const, procedure ---------------------------------------------------
extern PACKAGE TTDefvias* __fastcall defvia(void);

}	/* namespace Cdefvias */
#if !defined(NO_IMPLICIT_NAMESPACE_USE)
using namespace Cdefvias;
#endif
//-- end unit ----------------------------------------------------------------
#endif	// CDefVias
