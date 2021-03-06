unit AddInObj;

interface

uses  { ????? ?????????? ?????????? }
  ComServ, ComObj, ActiveX, SysUtils, Windows, AddInLib,u_main,uclasses,
   Vcl.Controls,Vcl.Dialogs,System.Variants, pngimage,Classes;

resourcestring
   strWidth = 'Width,??????';
   strHeight ='Height,??????';
   strMaterial='Material,?????????????';
   strPieces ='OrderPieces,??????????????';
   strUsefulPieces='UsefulPieces,?????????????';
   strDefectPieces='DefectPieces,????????????????';
   strOpen='Open,???????';
   strImage='Image,?????';
   strDefectArea='DefectArea,??????????????????';
   strSerializedSchema='SerializedSchema,????????????';


     (*1*)
     const c_AddinName = 'RaskroiAddIn'; //??? ??????? ??????????

////////////////////////////////////////////////////////////////////////
     //?????????? ???????
     const c_PropCount = 5;  (*2*)

     //?????????????? ???????
     type TProperties = (
       propMaterial,
       propWidth,
       propHeight,
       propPieces,
       propUsefulPieces,
       propDefectPieces,
       propImage,
       propDefectArea,
       propSerializedSchema
     );

////////////////////////////////////////////////////////////////////////
    //?????????? ???????
     const c_MethCount = 5;   (*3*)
    //?????????????? ???????.
    type TMethods = (
       methOpen,
       meth2,
       meth3,
       meth4,
       meth5
       );

////////////////////////////////////////////////////////////////////////
const
//??????? Ctrl-Shift-G, ????? ????????????? ????? ?????????? ????????????? CLSID
//??????? ??????????.
     (*4*)
     CLSID_AddInObject : TGUID = '{EF763F50-33C7-4B6D-A0BA-6C9991638E50}';



////////////////////////////////////////////////////////////////////////
type

  TRectanglesArray=array of TRectangleData;


  AddInObject = class(TComObject, IDispatch, IInitDone, ILanguageExtender)

  public
    i1cv7: IDispatch;
    iStatus: IStatusLine;
    iExtWindows: IExtWndsSupport;
    iError: IErrorLog;
    iEvent : IAsyncEvent;
  protected


    //?????????? ??????? ??????? ??????????
    //vk_object: T_vk_object;
     FMaterial:Widestring;  // ???? ???????????? string ?? ?????? ?????? ??? ???????? ???????? ?????????
     FOriginalWidth,FOriginalHeight:double;
     FPieces:array of array [0..3] of Widestring; // ?????? ??? ????? ????????? ?????????? ????? ???????? ??????
     FPiecesCount:integer;
     FImageData:Widestring;
     FDefectArea:double; // ??????? ??????????? ???????
     //FUseFulPieces:TRectangles;
     FSerializedSchema:WideString;

    { This function is useful in ILanguageExtender implementation }
		function TermString(strTerm: string; iAlias: Integer): string;
		function CompareCommand(ACommand, ATerm: String): Boolean;

    { IInitDone implementation }
    function Init(pConnection: IDispatch): HResult; stdcall;
    function Done: HResult; stdcall;
    function GetInfo(var pInfo: PSafeArray): HResult; stdcall;

    { ILanguageExtender implementation }
    function RegisterExtensionAs(var bstrExtensionName: WideString): HResult; stdcall;
    function GetNProps(var plProps: Integer): HResult; stdcall;
    function FindProp(const bstrPropName: WideString; var plPropNum: Integer): HResult; stdcall;
    function GetPropName(lPropNum, lPropAlias: Integer; var pbstrPropName: WideString): HResult; stdcall;
    function GetPropVal(lPropNum: Integer; var pvarPropVal: OleVariant): HResult; stdcall;
    function SetPropVal(lPropNum: Integer; var varPropVal: OleVariant): HResult; stdcall;
    function IsPropReadable(lPropNum: Integer; var pboolPropRead: Integer): HResult; stdcall;
    function IsPropWritable(lPropNum: Integer; var pboolPropWrite: Integer): HResult; stdcall;
    function GetNMethods(var plMethods: Integer): HResult; stdcall;
    function FindMethod(const bstrMethodName: WideString; var plMethodNum: Integer): HResult; stdcall;
    function GetMethodName(lMethodNum, lMethodAlias: Integer; var pbstrMethodName: WideString): HResult; stdcall;
    function GetNParams(lMethodNum: Integer; var plParams: Integer): HResult; stdcall;
    function GetParamDefValue(lMethodNum, lParamNum: Integer; var pvarParamDefValue: OleVariant): HResult; stdcall;
    function HasRetVal(lMethodNum: Integer; var pboolRetValue: Integer): HResult; stdcall;
    function CallAsProc(lMethodNum: Integer; var paParams: PSafeArray): HResult; stdcall;
    function CallAsFunc(lMethodNum: Integer; var pvarRetValue: OleVariant; var paParams: PSafeArray): HResult; stdcall;

    { IDispatch }
    function GetIDsOfNames(const IID: TGUID; Names: Pointer;
      NameCount, LocaleID: Integer; DispIDs: Pointer): HResult; virtual; stdcall;
    function GetTypeInfo(Index, LocaleID: Integer; out TypeInfo): HResult; virtual; stdcall;
    function GetTypeInfoCount(out Count: Integer): HResult; virtual; stdcall;
    function Invoke(DispID: Integer; const IID: TGUID; LocaleID: Integer;
      Flags: Word; var Params; VarResult, ExcepInfo, ArgErr: Pointer): HResult; virtual; stdcall;

    { IStatusLine }
    function SetStatusLine(const bstrSource: WideString): HResult; safecall;
    function ResetStatusLine(): HResult; safecall;

    procedure ShowErrorLog(fMessage:WideString);



  end;

implementation

function AddInObject.TermString(strTerm: string; iAlias: Integer): string;
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


function AddInObject.CompareCommand(ACommand, ATerm: string): Boolean;
var
	iSemicolon: Integer;
	szCom: String;
begin
	ACommand:= AnsiUpperCase(ACommand);
	ATerm:= AnsiUpperCase(ATerm);
	Result:=False;
	iSemicolon := Pos(',', ATerm);
	// ????????? ?? ???????
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


////////////////////////////////////////////////////////////////////////
function AddInObject.GetPropVal(lPropNum: Integer; var pvarPropVal: OleVariant): HResult; stdcall;

//????? 1? ?????? ???????? ???????
var
  i:integer;
  iPiecesUseFulCount,iPiecesDefectCount,iPiecesOrdersCount:integer;
begin
     //VarClear(vk_object.g_Value);
     VarClear(pvarPropVal);
     try
       Result := S_OK;
       case TProperties(lPropNum) of

            propMaterial: begin
                             //vk_object.prop1(m_get_value);
                             pVarPropVal:=FMaterial;
            end;
            propWidth: begin
                          //vk_object.prop2(m_get_value);
                          pVarPropVal:=FOriginalWidth;
            end;
            propHeight: begin
                          //vk_object.prop3(m_get_value);
                          pvarPropVal:=FOriginalHeight;
            end;
            propPieces: begin
                          // vk_object.prop4(m_get_value);
                          iPiecesOrdersCount:=Length(PiecesOrders);
                           pvarPropVal:=VarArrayCreate([0,iPiecesOrdersCount,0,3], varOleStr);

                           for I := 0 to iPiecesOrdersCount-1 do begin
                             pvarPropVal[i,0]:=PiecesOrders[i,0];
                             pvarPropVal[i,1]:=PiecesOrders[i,1];
                             pvarPropVal[i,2]:=PiecesOrders[i,2];
                             pvarPropVal[i,3]:=PiecesOrders[i,3];
                           end;

            end;
            propUsefulPieces: begin
                                iPiecesUseFulCount:=Length(PiecesUseFul);
                                pvarPropVal:=VarArrayCreate([0,iPiecesUseFulCount,0,3], varOleStr);
                                for i := 0 to iPiecesuseFulCount-1 do begin
                                   pvarPropVal[i,0]:=FMaterial;
                                   pvarPropVal[i,1]:=PiecesUseFul[i,1];
                                   pvarPropVal[i,2]:=PiecesUseFul[i,2];
                                   pvarPropVal[i,3]:=PiecesUseFul[i,3];
                                end;
            end;
            propDefectPieces: begin
                               iPiecesDefectCount:=Length(PiecesDefect);
                               pvarPropVal:=VarArrayCreate([0,iPiecesDefectCount,0,3], varOleStr);
                               for i := 0 to iPiecesDefectCount-1 do begin
                                   pvarPropVal[i,0]:=FMaterial;
                                   pvarPropVal[i,1]:=PiecesDefect[i,1];
                                   pvarPropVal[i,2]:=PiecesDefect[i,2];
                                   pvarPropVal[i,3]:=PiecesDefect[i,3];
                                end;
            end;
            propImage : begin
              //?????????? ??????
              pvarPropVal:= FImageData;
            end;
            propDefectArea: begin
              // ??????? ??????????? ???????
              pvarPropVal:= FDefectArea;
            end;
            propSerializedSchema: begin
               // ?????? json ?? ?????? ??? ??????????
               pvarPropVal:= FSerializedSchema;
            end;
            (*5*)
            else
               Result := S_FALSE;
       end;

     except
       on E: Exception do begin
         ShowErrorLog('?????? ?????? ????????: '+E.Message);
         GetPropVal := S_FALSE;
       end;
     end;
end;

////////////////////////////////////////////////////////////////////////
//????? 1? ????????????? ???????? ???????
function AddInObject.SetPropVal(
  lPropNum: Integer; //????? ????????
  var varPropVal:  OleVariant //????????, ??????? 1? ????? ??????????
  ): HResult; stdcall;

var
   pArray:PSafeArray;
   i,iLow, iHigh : Integer;
   iIndexes:array [0..1] of integer;
   value:WideString;
begin
     try
       Result := S_OK;
       //vk_object.g_Value:=varPropVal;
       case TProperties(lPropNum) of
            propMaterial: FMaterial:=varPropVal;
            propWidth:  FOriginalWidth:=varPropVal;
            propHeight: FOriginalHeight:=varPropVal;
            propPieces: begin
               { ???????? ????????? ?? SafeMassive ???????? 4 ?? x , ??? x-
               ?????????? ??????? ? ???????}
               pArray:=PSafeArray(TVarData(varPropVal).VArray);
               SafeArrayGetLBound(pArray,2,iLow);
               SafeArrayGetUBound(pArray,2,iHigh);
               for i:=iLow to iHigh do begin
                 iIndexes[0]:=0;
                 iIndexes[1]:=i;
                 SetLength(FPieces,i+1);
                 //SafeArrayGetElement(pArray,iIndexes,wStringArray[0]);
                 SafeArrayGetElement(pArray,iIndexes,value);
                 FPieces[i,0]:=string(value);
                 iIndexes[0]:=1;
                 SafeArrayGetElement(pArray,iIndexes,value);
                 FPieces[i,1]:=string(value);
                 iIndexes[0]:=2;
                 SafeArrayGetElement(pArray,iIndexes,value);
                 FPieces[i,2]:=string(value);
                 iIndexes[0]:=3;
                 SafeArrayGetElement(pArray,iIndexes,value);
                 FPieces[i,3]:=string(value);
               end;
               FPiecesCount:=iHigh+1;
            end;
            propUsefulPieces: begin

            end;
            propDefectPieces: begin
            end;

            propSerializedSchema:begin
               FSerializedSchema:=varPropVal;
            end;
            (*6*)
            else
              Result := S_FALSE;
       end;
     except
       on E:Exception do begin
       ShowErrorLog('?????? ????????? ????????: '+E.Message);
       SetPropVal := S_FALSE;
       end;
     end;
end;



////////////////////////////////////////////////////////////////////////
function AddInObject.CallAsFunc(lMethodNum: Integer; var pvarRetValue: OleVariant; var paParams: PSafeArray): HResult; stdcall;
{????? 1? ????????? ??? ??????? ???????}
var
  i:integer;
  iRectangleIndex:integer;
  pngImage: TPngImage;
	stImageData: TStringStream;
  sOrderPieceName:string;
begin
     try
     //pvarRetValue:=0;


     case TMethods(lMethodNum) of
          methOpen: begin //vk_object.meth1(m_execute);
            try
              if frm_main=nil then begin
                 frm_main:=Tfrm_main.Create(nil);
                 frm_main.edt_width.Text:=FloatToStr(FOriginalWidth);
                 img_main.OriginalWidth:=FOriginalWidth;
                 frm_main.lbl_materialname.Caption:=FMaterial;
                 //frm_main.img_main.Scale:=frm_main.tb_zoom.Position/300;


                 if FSerializedSchema<>EmptyStr then begin // ???? ?????? ???????? ??????????????? ?????? ?? 1? ??? ?????????? ?? ???????? ????? ??????

                      img_main.SerializedSchema:= FSerializedSchema;
                      img_main.UnSerializeSchema;

                       for I:=0 to img_main.Rectangles.Count-1 do
                         case img_main.Rectangles[i].RectangleType of
                           rtUseFul: frm_main.lb_useful_rectangles.Items.addObject(img_main.Rectangles[i].Name,TObject(img_main.Rectangles[i]));
                           rtOrder:  frm_main.lb_order_rectangles.Items.addObject(img_main.Rectangles[i].Name,TObject(img_main.Rectangles[i]));
                         end;

                       for I := 0 to img_main.Cutlines.Count-1 do
                          frm_main.lb_cutlines.Items.AddObject(img_main.Cutlines[i].Name,TObject(img_main.Cutlines[i]));
                       for I := 0 to img_main.VertCutlines.Count-1 do
                          frm_main.lb_vertcutlines.Items.AddObject(img_main.VertCutlines[i].Name,TObject(img_main.VertCutlines[i]));

                       frm_main.edt_height.Text:=FloatToStr(img_main.OriginalHeight);   


                 end
                 else begin // ????? ????????? ?? ?????? ?????????? ?? ????   

                      for i := 0 to FPiecesCount-1 do begin
                           iRectangleIndex:=img_main.Rectangles.Add(FPieces[i,0],
                                                            FPieces[i,1],
                                                            StrToFloat(FPieces[i,2]),
                                                            StrToFloat(FPieces[i,3]));
                           img_main.Rectangles[iRectangleIndex].Scale:=img_main.Scale;
                           img_main.Rectangles[iRectangleIndex].Resizable:=false;
                           img_main.Rectangles[iRectangleIndex].propLeft:=img_main.Rectangles[iRectangleIndex].propLeft+img_main.ScaledOtstup;
                           img_main.Rectangles[iRectangleIndex].propTop:=img_main.Rectangles[iRectangleIndex].propTop+img_main.ScaledOtstup;
                           img_main.Rectangles[iRectangleIndex].propRight:=img_main.Rectangles[iRectangleIndex].propRight+img_main.ScaledOtstup;
                           img_main.Rectangles[iRectangleIndex].propBottom:=img_main.Rectangles[iRectangleIndex].propBottom+img_main.ScaledOtstup;
                           img_main.Rectangles[iRectangleIndex].RectangleType:=rtOrder;

                           sOrderPieceName:=FPieces[i,2]+' x '+FPieces[i,3]+' ('+FPieces[i,1]+')';
                           frm_main.lb_order_rectangles.AddItem(sOrderPieceName,TObject(img_main.Rectangles[iRectangleIndex]));

                      end;

                 end;

                 img_main.ReCalcLeftTopPositionForRectangles;

                 img_main.Draw;

                 if frm_main.ShowModal=mrOK then begin
                    // 19.01.2019 ?? ??????????? ??????? ?????????????
                    img_main.DoNotPaintOverCurrentRectangle:=false;
                    img_main.Draw;

                    ForiginalHeight:=StrToFloat(frm_main.edt_height.text);
                    frm_main.CalcMaterials;

                    // ???????? ??????? ?? ????? ??????? ??? ???????? ????????
                    img_main.Scale:=frm_main.tb_zoom.Max;


                    //????????? ???????? ? ????????
                    img_main.ShowCanvasSize:=true;
                    img_main.ShowRectanglesInfo:=false;
                    img_main.Draw;

                    pngImage:=TPngImage.Create;
                    pngImage.Assign(img_main.Picture.Bitmap);                   
                    //????????? ?????? ? ??????
                    FImageData:='';
                    stImageData:=TStringStream.Create;
                    try  
                      pngImage.SaveToStream(stImageData);
                      stImageData.Position:=0;
                      FImageData:= stImageData.ReadString(stImageData.Size);
                    finally
                    // ???????? ????????? ??????
                      FreeAndNil(pngImage);
                      FreeAndNil(stImageData);
                    end;

                    FDefectArea:=DefectArea;

                    //??????? ????? ??????? JSON ? ??????????
                    img_main.serializeSchema;
                    FSerializedSchema:= img_main.serializedSchema;

                    pvarRetValue:=True;
                 end
                 else
                   pvarRetValue:=false;
              end;
            finally
              if img_main<>nil then
                FreeAndNil(img_main);
              if frm_main <> nil then
                FreeAndNil(frm_main);
              CallAsFunc := S_OK;
            end;

          end;
        meth2:
          ; // vk_object.meth2(m_execute);
        meth3:
          ; // vk_object.meth3(m_execute);
        meth4:
          ; // vk_object.meth4(m_execute);
        meth5:
          ; // vk_object.meth5(m_execute)
        (* 7 *)

      else
        begin
          CallAsFunc := S_FALSE;
          Exit;
        end;
      end; // case
      // pvarRetValue := false;

//          if vk_object.g_Event<>'' then begin
//            iEvent.ExternalEvent(c_AddinName, vk_object.g_Event, vk_object.g_Event_Data);
//          end;

     except
        on E: Exception do begin
          ShowErrorLog(E.Message);
        end;
     end;


   //  CallAsFunc := S_OK;
end;

////////////////////////////////////////////////////////////////////////
function AddInObject.FindProp(const bstrPropName: WideString; var plPropNum: Integer): HResult; stdcall;
begin
   plPropNum:=-1;


   if CompareCommand(bstrPropName, strWidth) then plPropNum := Integer(propWidth)
   else if CompareCommand(bstrPropName, strHeight) then plPropNum := Integer(propHeight)
   else if CompareCommand(bstrPropName, strMaterial) then plPropNum := Integer(propMaterial)
   else if CompareCommand(bstrPropName, strPieces) then plPropNum := Integer(propPieces)
   else if CompareCommand(bstrPropName, strUsefulPieces) then plPropNum := Integer(propUsefulPieces)
   else if CompareCommand(bstrPropName, strDefectPieces) then plPropNum := Integer(propDefectPieces)
   else if CompareCommand(bstrPropName, strDefectArea) then plPropNum := Integer(propDefectArea)
   else if CompareCommand(bstrPropName, strImage) then plPropNum := Integer(propImage)
   else if CompareCommand(bstrPropName, strSerializedSchema) then plPropNum := Integer(propSerializedSchema);
   (*8*)

   if (plPropNum = -1) then begin
		FindProp := S_FALSE;
		Exit;
	end;

	FindProp := S_OK;

end;

////////////////////////////////////////////////////////////////////////
function AddInObject.FindMethod(const bstrMethodName: WideString; var plMethodNum: Integer): HResult; stdcall;
begin
  plMethodNum := -1;

	{ Assign proper value to plMethodNum if method named bstrMethodName is found }
	if CompareCommand(bstrMethodName, TermString(strOpen, 1)) then plMethodNum := Integer(methOpen);
	//else if CompareCommand(bstrMethodName, TermString(strOpen, 1)) then plMethodNum := Integer(methOpen)


	if (plMethodNum = -1) then begin
		FindMethod := S_FALSE;
		Exit;
	end;

	FindMethod := S_OK;
end;

////////////////////////////////////////////////////////////////////////
function AddInObject.GetNParams(lMethodNum: Integer; var plParams: Integer): HResult; stdcall;
//????? 1? ?????? ?????????? ?????????? ? ???????
begin
     //vk_object.g_NParams:=0;
     plParams:=0;
     case TMethods(lMethodNum) of
          methOpen: begin
               plParams:=0;
          end;
          meth2: begin
                   {vk_object.meth2(m_n_params)};
          end;
          meth3: begin
            //vk_object.meth3(m_n_params);
          end;
          meth4:begin
             //vk_object.meth4(m_n_params);
          end;
          meth5: begin
            //vk_object.meth5(m_n_params);
          end;
          (*10*)
     else
        GetNParams:=S_FALSE;
        Exit;
     end;
     GetNParams := S_OK;




end;


////////////////////////////////////////////////////////////////////////
function AddInObject.Init(pConnection: IDispatch): HResult; stdcall;
//1? ???????? ??? ??????? ??? ????????????? (??????) ??????????
begin
  i1cv7:=pConnection;

  iError:=nil;
  pConnection.QueryInterface(IID_IErrorLog,iError);

  iStatus:=nil;
  pConnection.QueryInterface(IID_IStatusLine,iStatus);

  iEvent := nil;
  pConnection.QueryInterface(IID_IAsyncEvent,iEvent);

  iExtWindows:=nil;
  pConnection.QueryInterface(IID_IExtWndsSupport,iExtWindows);

  //vk_object:=T_vk_object.Create();

  Init := S_OK;
end;

////////////////////////////////////////////////////////////////////////
function AddInObject.Done: HResult; stdcall;
//1? ???????? ??? ??????? ??? ?????????? ?????? ??????????
begin
  If ( iStatus <> nil ) then
    iStatus._Release();

  If ( iExtWindows <> nil ) then
    iExtWindows._Release();

  If ( iError <> nil ) then
    iError._Release();

  if (iEvent <> nil) then
    iEvent._Release();

  //vk_object.Destroy();

  if (img_main<>nil) then
    FreeAndNil(img_main);

{if (FPieces<>nil) then
    FreeAndNil(FPieces);}


  if (frm_main<>nil) then
    FreeAndNil(frm_main);



  Done := S_OK;
end;

////////////////////////////////////////////////////////////////////////
function AddInObject.GetInfo(var pInfo: PSafeArray{(OleVariant)}): HResult; stdcall;
var  varInfo : OleVariant;
var i: Integer;
begin
  varInfo := '2000';
  SafeArrayPutElement(pInfo,i,varInfo);

  GetInfo := S_OK;
end;

////////////////////////////////////////////////////////////////////////
function AddInObject.SetStatusLine(const bstrSource: WideString): HResult; safecall;
//??????? ??? ?????? ?? ??????? ?????????
begin
  SetStatusLine:=S_OK;
end;

////////////////////////////////////////////////////////////////////////
function AddInObject.ResetStatusLine(): HResult; safecall;
begin
  Result := S_OK;
end;

////////////////////////////////////////////////////////////////////////
function AddInObject.RegisterExtensionAs(var bstrExtensionName: WideString): HResult; stdcall;
begin
  bstrExtensionName := c_AddinName;
  RegisterExtensionAs := S_OK;
end;

////////////////////////////////////////////////////////////////////////
function AddInObject.GetNProps(var plProps: Integer): HResult; stdcall;
begin
     plProps := Integer(c_PropCount);
     GetNProps := S_OK;
end;


////////////////////////////////////////////////////////////////////////
function AddInObject.GetPropName(lPropNum, lPropAlias: Integer; var pbstrPropName: WideString): HResult; stdcall;
begin
     pbstrPropName := '';
     GetPropName := S_OK;
end;


////////////////////////////////////////////////////////////////////////
function AddInObject.IsPropReadable(lPropNum: Integer; var pboolPropRead: Integer): HResult; stdcall;
begin
  IsPropReadable := S_OK; //??? ???????? ????? ??????
end;

////////////////////////////////////////////////////////////////////////
function AddInObject.IsPropWritable(lPropNum: Integer; var pboolPropWrite: Integer): HResult; stdcall;
begin
     IsPropWritable := S_OK; //??? ???????? ????? ??????
end;

////////////////////////////////////////////////////////////////////////
function AddInObject.GetNMethods(var plMethods: Integer): HResult; stdcall;
begin
     plMethods := c_MethCount;
     GetNMethods := S_OK;
end;


////////////////////////////////////////////////////////////////////////
function AddInObject.GetMethodName(lMethodNum, lMethodAlias: Integer; var pbstrMethodName: WideString): HResult; stdcall;
begin
     pbstrMethodName := '';
     GetMethodName := S_OK;
end;


////////////////////////////////////////////////////////////////////////
function AddInObject.GetParamDefValue(lMethodNum, lParamNum: Integer; var pvarParamDefValue: OleVariant): HResult; stdcall;
//????????? ?????????? ???????? ?? ????????? ??? ??????????.
begin
  { Ther is no default value for any parameter }
  VarClear(pvarParamDefValue);
  GetParamDefValue := S_OK;
end;

////////////////////////////////////////////////////////////////////////
function AddInObject.HasRetVal(lMethodNum: Integer; var pboolRetValue: Integer): HResult; stdcall;
begin
	pboolRetValue:= 0; // ????????
	case TMethods(lMethodNum) of
		methOpen: pboolRetValue:=1;

		else begin
			HasRetVal := S_FALSE;
			Exit;
		end;
	end;

	HasRetVal := S_OK;
end;

////////////////////////////////////////////////////////////////////////
function AddInObject.CallAsProc(lMethodNum: Integer; var paParams: PSafeArray{(OleVariant)}): HResult; stdcall;
begin
    CallAsProc := S_FALSE;
end;



////////////////////////////////////////////////////////////////////////
function AddInObject.GetIDsOfNames(const IID: TGUID; Names: Pointer;
  NameCount, LocaleID: Integer; DispIDs: Pointer): HResult;
begin
  Result := E_NOTIMPL;
end;

////////////////////////////////////////////////////////////////////////
function AddInObject.GetTypeInfo(Index, LocaleID: Integer;
  out TypeInfo): HResult;
begin
  Result := E_NOTIMPL;
end;

////////////////////////////////////////////////////////////////////////
function AddInObject.GetTypeInfoCount(out Count: Integer): HResult;
begin
  Result := E_NOTIMPL;
end;

////////////////////////////////////////////////////////////////////////
function AddInObject.Invoke(DispID: Integer; const IID: TGUID; LocaleID: Integer;
  Flags: Word; var Params; VarResult, ExcepInfo, ArgErr: Pointer): HResult;
begin
  Result := E_NOTIMPL;
end;
////////////////////////////////////////////////////////////////////////
procedure AddInObject.ShowErrorLog(fMessage:WideString);
//????? ????????? ?? ??????.
var
  ErrInfo: PExcepInfo;
begin
  If Trim(fMessage) = '' then Exit;
  New(ErrInfo);
  ErrInfo^.bstrSource := c_AddinName;
  ErrInfo^.bstrDescription := fMessage;
  ErrInfo^.wCode:=1006;
  ErrInfo^.sCode:=E_FAIL;
  iError.AddError(nil, ErrInfo);
end;
////////////////////////////////////////////////////////////////////////

begin

  ComServer.SetServerName('RaskroiAddIn');
  TComObjectFactory.Create(ComServer,AddInObject,CLSID_AddInObject,
  c_AddinName,'?????????: ?????????? ??????? ?????????',ciMultiInstance);


end.
