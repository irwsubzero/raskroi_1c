unit AddInObj;

interface

uses ComServ, ComObj, ActiveX, AddInLib,
	SysUtils, Windows, Messages, Classes, Graphics, Controls, StdCtrls,
	ExtCtrls, Forms, Dialogs, StdVcl, AxCtrls,Variants, pngimage,

	uMain, uMultiImpress, uRegister;

resourcestring
	strWidth = 'Width,Ширина';
	strHeight = 'Height,Высота';
	strLamelCount = 'LamelCount,КоличествоЛамелей';
	strLamelWidth = 'LamelWidth,ШиринаЛамели';
	strFoilLength = 'FoilLength,ДлинаФольги';
	strAdjustValanse = 'AdjustValanse,ДопускВаланса';
	strAdjustLamel = 'AdjustLamel,ДопускЛамелей';
	strAdjustGruver = 'AdjustGruvel,ДопускГрувера';
	strTest = 'Test,Тест';
	strOpen = 'Open,Открыть';
	strScheme = 'Scheme,Схема';
	strAdd = 'AddMaterial,ДобавитьМатериал';
	strClear = 'ClearMaterials,ОчиститьМатериалы';
	strGet = 'GetMaterial,ПолучитьМатериал';
	strMaterials = 'Materials,Материалы';
	strImage = 'Image,Эскиз';
	strColorDialog = 'ColorDialog,ВыборЦвета';
	strCount = 'Count,Количество';
	strReadOnly = 'ReadOnly,ТолькоЧтение';
	strReg = 'Register,Регистрация';
//	strScheme = 'Scheme,Схема';
//	strScheme = 'Scheme,Схема';
//	strScheme = 'Scheme,Схема';



const
	{ This GUID should be changed }
	CLSID_AddInObject: TGUID = '{1671BCED-567A-4AE7-A6E8-52A05108B7DA}';

type

	TProperties = (propWidth, propHeight, propLamelCount, propLamelWidth, propFoilLength, propScheme, propMaterials,
									propCount ,propReadOnly, propImage, propAdjValanse, propAdjLamel, propAdjGruver, LastProp);

	TMethods = (methTest, methOpen, methAdd, methClear, methColorDialog, methRegister, LastMethod);
	TStrs = array of array of string;
	PStrs = ^TStrs;

	TAddInObject = class(TComObject, IInitDone, IDispatch, ISpecifyPropertyPages, ILanguageExtender)
		{ Attributes }
		FWidth, FHeight, FLamelCount: Integer;
		FLamelWidth, FFoilLength: Integer;
		FReadOnly: Boolean;
		FAdjValanse, FAdjLamel, FAdjGruver: Integer;

		FScheme: String;
    	FImageData: string;

		pForm: Variant;
		{ Interfaces }
		pErrorLog: IErrorLog;
		pEvent: IAsyncEvent;
		pProfile: IPropertyProfile;
		pStatusLine: IStatusLine;

		pConnect: Variant;

		function LoadProperties: Boolean;
		procedure SaveProperties;
		{ This function is useful in ILanguageExtender implementation }
		function TermString(strTerm: string; iAlias: Integer): string;
		function CompareCommand(ACommand, ATerm: String): Boolean;

		{ These two methods is convenient way to access function
			parameters from SAFEARRAY vector of variants }
		function GetNParam(var pArray: PSafeArray; lIndex: Integer): OleVariant;
		procedure PutNParam(var pArray: PSafeArray; lIndex: Integer; var varPut: OleVariant);

		{ Interface implementation }
		{ IInitDone implementation }
		function Init(pConnection: IDispatch): HResult; stdcall;
		function Done: HResult; stdcall;
		function GetInfo(var pInfo: PSafeArray { (OleVariant) } ): HResult; stdcall;
		{ ISpecifyPropertyPages implementation }
		function GetPages(out Pages: TCAGUID): HResult; stdcall;
		{ ILanguageExtender implementation }
		function RegisterExtensionAs(var bstrExtensionName: WideString): HResult; stdcall;
		// совйства
		function GetNProps(var plProps: Integer): HResult; stdcall;
		function FindProp(const bstrPropName: WideString; var plPropNum: Integer): HResult; stdcall;
		function GetPropName(lPropNum, lPropAlias: Integer; var pbstrPropName: WideString): HResult; stdcall;
		function GetPropVal(lPropNum: Integer; var pvarPropVal: OleVariant): HResult; stdcall;
		function SetPropVal(lPropNum: Integer; var varPropVal: OleVariant): HResult; stdcall;
		function IsPropReadable(lPropNum: Integer; var pboolPropRead: Integer): HResult; stdcall;
		function IsPropWritable(lPropNum: Integer; var pboolPropWrite: Integer): HResult; stdcall;
		// методы
		function GetNMethods(var plMethods: Integer): HResult; stdcall;
		function FindMethod(const bstrMethodName: WideString; var plMethodNum: Integer): HResult; stdcall;
		function GetMethodName(lMethodNum, lMethodAlias: Integer; var pbstrMethodName: WideString): HResult; stdcall;
		function GetNParams(lMethodNum: Integer; var plParams: Integer): HResult; stdcall;
		function GetParamDefValue(lMethodNum, lParamNum: Integer; var pvarParamDefValue: OleVariant): HResult; stdcall;
		function HasRetVal(lMethodNum: Integer; var pboolRetValue: Integer): HResult; stdcall;
		function CallAsProc(lMethodNum: Integer; var paParams: PSafeArray { (OleVariant) } ): HResult; stdcall;
		function CallAsFunc(lMethodNum: Integer; var pvarRetValue: OleVariant; var paParams: PSafeArray { (OleVariant) } ): HResult; stdcall;

		{ IDispatch }
		function GetIDsOfNames(const IID: TGUID; Names: Pointer; NameCount, LocaleID: Integer; DispIDs: Pointer): HResult; virtual; stdcall;
		function GetTypeInfo(Index, LocaleID: Integer; out TypeInfo): HResult; virtual; stdcall;
		function GetTypeInfoCount(out Count: Integer): HResult; virtual; stdcall;
		function Invoke(DispID: Integer; const IID: TGUID; LocaleID: Integer; Flags: Word; var Params; VarResult, ExcepInfo, ArgErr: Pointer)
			: HResult; virtual; stdcall;

	end;

var

    gStarted: Boolean = false;

implementation

{$OPTIMIZATION ON}

function TAddInObject.LoadProperties: Boolean;
var
	iRes: Integer;
	varRead: OleVariant;
begin

	VarClear(varRead);
	{ SImply cast OleVariant to Integer (VT_I4) }
	varRead := 0;
	iRes := pProfile.Read('Enabled:0', varRead, nil);
	if (iRes <> S_OK) then begin
		LoadProperties := False;
		Exit;
	end;

	 //boolIsEnabled := varRead;

	LoadProperties := True;

end;

procedure TAddInObject.SaveProperties;
var
	varSave: OleVariant;
begin
	 //varSave := boolIsEnabled;
	pProfile.Write('Enabled:0', varSave);
end;

function TAddInObject.TermString(strTerm: string; iAlias: Integer): string;
var
	iSemicolon: Integer;
begin
	iSemicolon := Pos(',', strTerm);
	if (iAlias = 0) then
		if (iSemicolon = 0) then TermString := strTerm
		else
			TermString := Copy(strTerm, 1, iSemicolon - 1)
		else { iAlias = 1 }
		if (iSemicolon = 0) then TermString := ''
		else TermString := Copy(strTerm, iSemicolon + 1, Length(strTerm) - iSemicolon);
end;


function TAddInObject.CompareCommand(ACommand, ATerm: string): Boolean;
var
	iSemicolon: Integer;
	szCom: String;
begin
	ACommand:= AnsiUpperCase(ACommand);
	ATerm:= AnsiUpperCase(ATerm);
	Result:=False;
	iSemicolon := Pos(',', ATerm);
	// проверяем по очереди
	while (iSemicolon > 0) AND (NOT Result) do begin
		szCom:=Copy(ATerm, 1, iSemicolon - 1);
		Delete(ATerm, 1, iSemicolon);
		iSemicolon := Pos(',', ATerm);
		Result:= (ACommand = ATerm) OR (ACommand = szCom);
		Exit;
	end;

	// iSemicolon = 0
	Result:= ACommand = ATerm;

end;



function TAddInObject.GetNParam(var pArray: PSafeArray; lIndex: Integer): OleVariant;
var
	varGet: OleVariant;
begin
	SafeArrayGetElement(pArray, lIndex, varGet);
	GetNParam := varGet;
end;

procedure TAddInObject.PutNParam(var pArray: PSafeArray; lIndex: Integer; var varPut: OleVariant);
begin
	SafeArrayPutElement(pArray, lIndex, varPut);
end;

{ IInitDone interface }

function TAddInObject.Init(pConnection: IDispatch): HResult; stdcall;
var
	iRes: Integer;
begin
	pConnect := pConnection;

	pErrorLog := nil;
	pConnection.QueryInterface(IID_IErrorLog, pErrorLog);

	pEvent := nil;
	pConnection.QueryInterface(IID_IAsyncEvent, pEvent);

	pStatusLine := nil;
	pConnection.QueryInterface(IID_IStatusLine, pStatusLine);

	Materials:=TMaterials.Create;

	FReadOnly:= True;
	if not gStarted then Init := S_OK;

    gStarted:= true;
end;

function TAddInObject.Done: HResult; stdcall;
begin

	pForm:= varNull;
//
//    //pConnect:= nil;
//
	pConnect := varNull;
//
//
	if (pErrorLog <> nil) then pErrorLog._Release();
//    pErrorLog:=nil;
//
	if (pEvent <> nil) then	pEvent._Release();
//    pEvent := nil;
//
	if (pProfile <> nil) then pProfile._Release();
//pProfile   := nil;
//	if (pStatusLine <> nil) then pStatusLine._Release();
    pStatusLine    := nil;
//
//  // убиваем классы
	if Materials<> nil then FreeAndNil(Materials);
	if Multi<> nil then FreeAndNil(Multi);
	if fMain<> nil then FreeAndNil(fMain);

	Done := S_OK;
end;

function TAddInObject.GetInfo(var pInfo: PSafeArray { (OleVariant) } ): HResult; stdcall;
var
	varInfo: OleVariant;
begin
	varInfo := '2000';
	PutNParam(pInfo, 0, varInfo);
	GetInfo := S_OK;
end;

{ ISpecifyPropertyPages interface }

function TAddInObject.GetPages(out Pages: TCAGUID): HResult; stdcall;
begin
	//Pages.cElems := 0;
	//Pages.pElems := CoTaskMemAlloc(SizeOf(TGUID));
	//Pages.pElems[0]:= Class_AddInPropPage;

	Pages.cElems := 0;
//	Pages.pElems := CoTaskMemAlloc(SizeOf(TGUID));
//	Pages.pElems[0]:= CLASS_FormMaterial;
	GetPages := S_OK;
end;

{ ILanguageExtender interface }

// Название расширения, необходимо при вызове метода
function TAddInObject.RegisterExtensionAs(var bstrExtensionName: WideString): HResult; stdcall;
begin

	{ You may delete next lines and add your own implementation code here }
	{ Name of extension should be changed avoiding conflicts }
	bstrExtensionName := 'JalousieArcConstructor';
	RegisterExtensionAs := S_OK;
end;

////////////////////////////////////////////////////////////////////////////
// СВОЙСТВА
////////////////////////////////////////////////////////////////////////////


// Количество свойств(параметров)
function TAddInObject.GetNProps(var plProps: Integer): HResult; stdcall;
begin

	{ You may delete next lines and add your own implementation code here }
	plProps := Integer(LastProp);
	GetNProps := S_OK;
end;

// найти номер свойства по имени
function TAddInObject.FindProp(const bstrPropName: WideString; var plPropNum: Integer): HResult; stdcall;
begin
	plPropNum := -1;
	{ Assign proper value to plPropNum if property named bstrPropName is found }

	if CompareCommand(bstrPropName, strWidth) then plPropNum := Integer(propWidth)
	else if CompareCommand(bstrPropName, strHeight) then plPropNum := Integer(propHeight)
	else if CompareCommand(bstrPropName, strLamelCount) then plPropNum := Integer(propLamelCount)
	else if CompareCommand(bstrPropName, strScheme) then plPropNum := Integer(propScheme)
	else if CompareCommand(bstrPropName, strMaterials) then plPropNum := Integer(propMaterials)
	else if CompareCommand(bstrPropName, strCount) then plPropNum := Integer(propCount)
	else if CompareCommand(bstrPropName, strLamelWidth) then plPropNum := Integer(propLamelWidth)
	else if CompareCommand(bstrPropName, strFoilLength) then plPropNum := Integer(propFoilLength)
	else if CompareCommand(bstrPropName, strReadOnly) then plPropNum := Integer(propReadOnly)
	else if CompareCommand(bstrPropName, strImage) then plPropNum := Integer(propImage)
	else if CompareCommand(bstrPropName, strAdjustValanse) then plPropNum := Integer(propAdjValanse)
	else if CompareCommand(bstrPropName, strAdjustLamel) then plPropNum := Integer(propAdjLamel)
	else if CompareCommand(bstrPropName, strAdjustGruver) then plPropNum := Integer(propAdjGruver);


	if (plPropNum = -1) then begin
		FindProp := S_FALSE;
		Exit;
	end;

	FindProp := S_OK;
end;

function TAddInObject.GetPropName(lPropNum, lPropAlias: Integer; var pbstrPropName: WideString): HResult; stdcall;
begin
	pbstrPropName := '';
	case TProperties(lPropNum) of
		propWidth:	pbstrPropName := TermString(strWidth, lPropAlias);
		propHeight:	pbstrPropName := TermString(strHeight, lPropAlias);
		propLamelCount:	pbstrPropName := TermString(strLamelCount, lPropAlias);
		propLamelWidth:	pbstrPropName := TermString(strLamelWidth, lPropAlias);
		propFoilLength:	pbstrPropName := TermString(strFoilLength, lPropAlias);
		propReadOnly:	pbstrPropName := TermString(strReadOnly, lPropAlias);
	else
		GetPropName := S_FALSE;
		Exit;
	end;

	GetPropName := S_OK;
end;

// Возвращает в 1С значение свойства
function TAddInObject.GetPropVal(lPropNum: Integer; var pvarPropVal: OleVariant): HResult; stdcall;
var
	index,j,indexMaterial: Integer;
	PData: PStrs;
	pArray: array of array[0..4] of string;
begin

	VarClear(pvarPropVal);
	case TProperties(lPropNum) of
		propWidth:	pvarPropVal := FWidth;
		propHeight:	pvarPropVal := FHeight;
		propLamelCount:	pvarPropVal := FLamelCount;
		propLamelWidth:	pvarPropVal := FLamelWidth;
		propFoilLength:	pvarPropVal := FFoilLength;
		propScheme:	pvarPropVal := FScheme;
		propCount: pvarPropVal := Materials.Count;
		propReadOnly: pvarPropVal := FReadOnly;
		propMaterials: begin
			{Put some numbers in the array.}
			// формат материалов
			// 0 - НомерСтроки()
			// 1 - Код
			// 2 - Количество
			// 3 - Количество штук
			// фольга
			// 4 - характеристика
			SetLength(pArray, Materials.Count);

			indexMaterial:=0;
			// материалы
			for index := 0 to Materials.Count-1 do begin
				pArray[indexMaterial][0]:= IntToStr(index);
				pArray[indexMaterial][1]:= Materials[index].Code;
				pArray[indexMaterial][2]:= IntToStr(Materials[index].Length);
				pArray[indexMaterial][3]:= IntToStr(Materials[index].CountPcs);
				pArray[indexMaterial][4]:= 'М';
				inc(indexMaterial);
			end;

			// фольга
			for index := 0 to Materials.Count-1 do begin
				if Materials[index].Foil.Code<>'' then begin
					SetLength(pArray, indexMaterial + 1);
					pArray[indexMaterial][0]:= IntToStr(index);
					pArray[indexMaterial][1]:= Materials[index].Foil.Code;
					pArray[indexMaterial][2]:= IntToStr(Materials[index].Foil.Length);
					pArray[indexMaterial][3]:= IntToStr(Materials[index].Foil.CountPcs);
					pArray[indexMaterial][4]:= 'Ф';
					inc(indexMaterial);
				end;
			end;

			//Грувер
			if GruverMaterial.Code<>'' then begin
				SetLength(pArray, indexMaterial + 1);
				pArray[indexMaterial][0]:= IntToStr(index);
				pArray[indexMaterial][1]:= GruverMaterial.Code;
				pArray[indexMaterial][2]:= IntToStr(GruverMaterial.Length);
				pArray[indexMaterial][3]:= IntToStr(GruverMaterial.CountPcs);
				pArray[indexMaterial][4]:= 'Г';
				inc(indexMaterial);
			end;
//			iSize:=0;
//			for index := 0 to Materials.Count-1 do
//				for j:=0 to 4 do iSize:=iSize+Length(pArray[index][j]);


			{Create the variant array of bytes. Set the upper bound to the size
			of the array minus one because the array is zero based.}
			pvarPropVal := VarArrayCreate([0,4,0,indexMaterial-1], varOleStr);

			{Lock the variant array for faster access then copy the array to the
			variant array and unlock the variant array.}
			for index := 0 to indexMaterial-1 do
				for j:=0 to 4 do pvarPropVal[j,index]:= pArray[index,J];
//			pvarPropVal:= VarArrayOf(mtr);
			PData := VarArrayLock(pvarPropVal);

			//PData^[0][0]:=pArray[1][1];
			try
//				Move(pArray, PData^, SizeOf(pArray));


			finally
				VarArrayUnlock(pvarPropVal);
			end;
		end; // propMaterial
		propImage: begin
			//возвращаем строку
			pvarPropVal:= FImageData;

		end;

	else
		GetPropVal := S_FALSE;
		Exit;
	end;

	GetPropVal := S_OK;

end;

// устнавливает значение свойства взятого из 1С
function TAddInObject.SetPropVal(lPropNum: Integer; var varPropVal: OleVariant): HResult; stdcall;
begin

	case TProperties(lPropNum) of
		propWidth: FWidth:= varPropVal;
		propHeight: FHeight:= varPropVal;
		propLamelCount: FLamelCount:= varPropVal;
		propLamelWidth: FLamelWidth:= varPropVal;
		propFoilLength: FFoilLength:= varPropVal;
		propScheme: FScheme:= varPropVal;
		propReadOnly: FReadOnly:= varPropVal;
		propAdjValanse: FAdjValanse:= varPropVal;
		propAdjLamel: FAdjLamel:= varPropVal;
		propAdjGruver: FAdjGruver:= varPropVal;

	else
		SetPropVal := S_FALSE;
		Exit;
	end;

	SetPropVal := S_OK;

end;

// проверяет является ли свойство с номером lPropNum читаемым
function TAddInObject.IsPropReadable(lPropNum: Integer; var pboolPropRead: Integer): HResult; stdcall;
begin
	pboolPropRead:= 1;
	case TProperties(lPropNum) of
		propWidth: pboolPropRead := 1;
		propHeight: pboolPropRead := 1;
		propLamelCount: pboolPropRead := 1;
		propLamelWidth: pboolPropRead := 1;
		propFoilLength: pboolPropRead := 1;
		propScheme: pboolPropRead := 1;
		propReadOnly: pboolPropRead := 1;
		propImage: pboolPropRead := 1;
		propAdjValanse: pboolPropRead := 1;
		propAdjLamel: pboolPropRead := 1;
		propAdjGruver: pboolPropRead := 1;
	else
	 //	IsPropReadable := S_FALSE;
	 //	Exit;
	end;

	IsPropReadable := S_OK;

end;

// проверяет является ли свойство с номером lPropNum записываемым
function TAddInObject.IsPropWritable(lPropNum: Integer; var pboolPropWrite: Integer): HResult; stdcall;
begin
	pboolPropWrite := 1;
	case TProperties(lPropNum) of
		propWidth: pboolPropWrite := 1;
		propHeight: pboolPropWrite := 1;
		propLamelCount: pboolPropWrite := 1;
		propLamelWidth: pboolPropWrite := 1;
		propFoilLength: pboolPropWrite := 1;
		propScheme: pboolPropWrite := 1;
		propReadOnly: pboolPropWrite := 1;
		propAdjValanse: pboolPropWrite := 1;
		propAdjLamel: pboolPropWrite := 1;
		propAdjGruver: pboolPropWrite := 1;
	else
		//IsPropWritable := S_FALSE;
		//Exit;
	end;

	IsPropWritable := S_OK;

end;

//////////////////////////////////////////////////////////////////////////////
// МЕТОДЫ
//////////////////////////////////////////////////////////////////////////////

// Возвращает колличество доступных методов
function TAddInObject.GetNMethods(var plMethods: Integer): HResult; stdcall;
begin

	{ You may delete next lines and add your own implementation code here }

	plMethods := Integer(LastMethod);
	GetNMethods := S_OK;

end;

// ищет метод по имени и возвращает его номер, в дальнейшем все операции будут происходить по номеру метода
function TAddInObject.FindMethod(const bstrMethodName: WideString; var plMethodNum: Integer): HResult; stdcall;
begin
	plMethodNum := -1;

	{ Assign proper value to plMethodNum if method named bstrMethodName is found }
	if CompareCommand(bstrMethodName, TermString(strTest, 1)) then plMethodNum := Integer(methTest)
	else if CompareCommand(bstrMethodName, TermString(strOpen, 1)) then plMethodNum := Integer(methOpen)
	else if CompareCommand(bstrMethodName, TermString(strAdd, 1)) then plMethodNum := Integer(methAdd)
	else if CompareCommand(bstrMethodName, TermString(strClear, 1)) then plMethodNum := Integer(methClear)
	else if CompareCommand(bstrMethodName, TermString(strColorDialog, 1)) then plMethodNum := Integer(methColorDialog)
	else if CompareCommand(bstrMethodName, strReg) then plMethodNum := Integer(methRegister);

	if (plMethodNum = -1) then begin
		FindMethod := S_FALSE;
		Exit;
	end;

	FindMethod := S_OK;

end;

function TAddInObject.GetMethodName(lMethodNum, lMethodAlias: Integer; var pbstrMethodName: WideString): HResult; stdcall;
begin

	pbstrMethodName := '';

	case TMethods(lMethodNum) of
		methTest:	pbstrMethodName := TermString(strTest, lMethodAlias);
		methAdd: pbstrMethodName := TermString(strAdd, lMethodAlias);
		methOpen: pbstrMethodName := TermString(strOpen, lMethodAlias);
		methColorDialog: pbstrMethodName := TermString(strColorDialog, lMethodAlias);
		methRegister: pbstrMethodName := TermString(strReg, lMethodAlias);
	else
		GetMethodName := S_FALSE;
		Exit;
	end;

	GetMethodName := S_OK;

end;

// возвращает количество параметров для метода
function TAddInObject.GetNParams(lMethodNum: Integer; var plParams: Integer): HResult; stdcall;
begin

	plParams := 0;

	case TMethods(lMethodNum) of
		methTest: plParams := 0;
		methOpen: plParams := 0;
		methAdd: plParams := 3; // 1 - код, 2 - название, 3 - цвет
		methColorDialog: plParams := 1; // Текущий цвет
    methRegister: plParams := 0;

	else
			GetNParams := S_FALSE;
			Exit;
	end;

	GetNParams := S_OK;

end;

// возвращает значение по умолчанию для параметра lParamNum метода lMethodNum
function TAddInObject.GetParamDefValue(lMethodNum, lParamNum: Integer; var pvarParamDefValue: OleVariant): HResult; stdcall;
begin

	VarClear(pvarParamDefValue);
	case TMethods(lMethodNum) of
		{
			Differentiate cases here:
			Method1: ...
			Method2: ...
			...
			}
		{ This line is for successful build only and should be removed }
		methAdd: begin   // параметр 0 - Тип материала 1 - код, 2 - название, 3 - цвет, 4 - Ключ связи
			case lParamNum of
				1: pvarParamDefValue:='М';
				3: pvarParamDefValue:=RGB(100+ Random(155),100+ Random(155),100+ Random(155));
				4: pvarParamDefValue:=0;
				5: pvarParamDefValue:=0;
      end;
      end;
		methColorDialog: if lParamNum=0 then pvarParamDefValue:=0;
		else begin
			GetParamDefValue := S_FALSE;
			Exit;
		end;
	end; // case

	GetParamDefValue := S_OK;

end;


// определяет возвращает ли метод lMethodNum значение или нет
function TAddInObject.HasRetVal(lMethodNum: Integer; var pboolRetValue: Integer): HResult; stdcall;
begin
	pboolRetValue:= 0; // заглушка
	case TMethods(lMethodNum) of
		methOpen: pboolRetValue:=1;
		methColorDialog: pboolRetValue:=1;
    methRegister: pboolRetValue:=1;
		else begin
			HasRetVal := S_FALSE;
			Exit;
		end;
	end;

	HasRetVal := S_OK;

end;


// вызвать метод как процедуру( без возврата значения)
function TAddInObject.CallAsProc(lMethodNum: Integer; var paParams: PSafeArray { (OleVariant) } ): HResult; stdcall;
var
	index: integer;
	szParam:String;
begin

	case TMethods(lMethodNum) of
		methTest:	begin
                  pConnect.AppDispatch.Сообщить('Сообщение');
		end;
		methClear: begin
			Materials.Clear;
		end;
		methAdd: begin  // параметр 0- код, 1 - название, 2 - цвет
			Materials.Add(GetNParam(paParams,0), GetNParam(paParams,1),GetNParam(paParams,2));
		end;
		else begin
			CallAsProc := S_FALSE;
			Exit;
		end;
	end;

	CallAsProc := S_OK;
end;

// вызвать метод как Функцию( с возвратом значения)
function TAddInObject.CallAsFunc(lMethodNum: Integer; var pvarRetValue: OleVariant; var paParams: PSafeArray
	{ (OleVariant) } ): HResult; stdcall;
var
	ColorDialog: TColorDialog;
	pngImage: TPngImage;
	stImageData: TStringStream;
	ds: variant;
    szModulePath: String;
begin

	case TMethods(lMethodNum) of
		methOpen:	begin
			try
				if Multi = nil then begin
					Multi:= TMultiImage.Create(nil);
					Multi.MultiWidth:=FWidth;
					Multi.MultiHeight:=FHeight;
					Multi.FoilLength:=FFoilLength;
					Multi.LamelWidth:=FLamelWidth;
                    Multi.LamelCount:=FLamelCount;

					Multi.ReadOnly:=FReadOnly;
                    Multi.UseValance:= False;
				end;

				if fMain = nil then begin
					fMain:=TfMain.Create(nil);
					fMain.pConnect:=pConnect;
          //pConnect.AppDispatch.Сообщить('Сообщение');
          //pProfile.AppDispatch.Сообщить('аыва');
           //	CallAsFunc := S_OK;
           // exit;
          //АЛЬЯНС_ОбщийСервер.Тест();
          //ShowMessage('НЕДЩ');
					fMain.pForm_ФормаВыбора1С := pConnect.AppDispatch.ПолучитьФорму('Справочник.Номенклатура.Форма.АЛЬЯНС_ФормаВыбора');
                    fMain.pAppDispatch_Приложение1С := pConnect.AppDispatch;
					fMain.AdjustLamel:=FAdjLamel;
					fMain.AdjustValanse:=FAdjValanse;
					fMain.AdjustGruver:=FAdjGruver;
					fMain.InitMulti();
                    // получаем схему мультифактуры
					if Trim(FScheme)<>'' then begin
						fMain.SetScheme(FScheme);
						fMain.DrawMulti;
						fMain.SyncMultiLayers;
						fMain.FillMaterialList();
					end
                    else begin
                    	// если нет схемы, то создаем один слой
                        // рассчитывем минимальную длину нижних ламелей, чтобы не перекрывать рисунок

                        // добавляем слой
                        Multi.AddLayer(Multi.MultiHeight, 'ОсновнойCлой');
                        Multi.ActiveLayer := Multi.Layers.Count - 1;
                        // добавляем запись о слое в начало списка слоев (начинается с 1, т.к. 0 - фикс строка с названием колонок)
                        // создаем элементы
                        Multi.Draw();
                    end;

				end
				else fMain.WindowState:=wsMaximized;

				fMain.BringToFront;
				if fMain.ShowModal = mrOk then begin
					fMain.CalcMaterials;
					FScheme:=fMain.GetScheme();
					FLamelCount:= Multi.LamelCount;
					// конвертируем картинку в png
                    //для начала перерисуем красиво
                    Multi.ShowCenterLine:= False;
                    Multi.ShowCoordinate:= False;
                    Multi.Parent:= nil;
                    Multi.Scale:= 100;

                    Multi.Draw();
					pngImage:=TPngImage.Create;


					pngImage.Assign(Multi.Picture.Bitmap);

					// сохраняем в данные строку
					FImageData:='';
					stImageData:=TStringStream.Create;
					pngImage.SaveToStream(stImageData);
					stImageData.Position:=0;
					FImageData:= stImageData.ReadString(stImageData.Size);
					// отчищаем созданные классы
					FreeAndNil(pngImage);
					FreeAndNil(stImageData);

					pvarRetValue:=True;
				end
				else pvarRetValue:=False;
			finally
				try
					FreeAndNil(Multi);
				finally
					if fMain<> nil then begin
						fMain.pConnect:=varNull;
						fMain.pForm_ФормаВыбора1С:=varNull;
						FreeAndNil(fMain);
					end;
					CallAsFunc := S_OK;
				end;
			end;
		end;
		methColorDialog: begin
			ColorDialog:= TColorDialog.Create(nil);
			ColorDialog.Color:=GetNParam(paParams,0);
			ColorDialog.Execute();
			pvarRetValue:=ColorDialog.Color;
			FreeAndNil(ColorDialog);
			ColorDialog:=nil;
		end;
        methRegister: begin
            // регистритуем компоненту
        	pvarRetValue:= RegisterModule();
   // CloseHandle(HInstance);
        end
	else begin
				CallAsFunc := S_FALSE;
				Exit;
			end;
	end;

	CallAsFunc := S_OK;
end;


////////////////////////////////////////////////////////////////////////////
// { IDispatch } - Вызов COM объекта
////////////////////////////////////////////////////////////////////////////


function TAddInObject.GetIDsOfNames(const IID: TGUID; Names: Pointer; NameCount, LocaleID: Integer; DispIDs: Pointer): HResult;
begin
	Result := E_NOTIMPL;
end;

function TAddInObject.GetTypeInfo(Index, LocaleID: Integer; out TypeInfo): HResult;
begin
	Result := E_NOTIMPL;
end;

function TAddInObject.GetTypeInfoCount(out Count: Integer): HResult;
begin
	Result := E_NOTIMPL;
end;

function TAddInObject.Invoke(DispID: Integer; const IID: TGUID; LocaleID: Integer; Flags: Word; var Params;
	VarResult, ExcepInfo, ArgErr: Pointer): HResult;
begin
	Result := E_NOTIMPL;
end;

initialization

	ComServer.SetServerName('AddIn');
	TComObjectFactory.Create(ComServer, TAddInObject, CLSID_AddInObject, 'JalousieArcConstructor', 'Альянс-Софт: Жалюзи. Конструктор арочных жалюзи', ciMultiInstance);

end.
