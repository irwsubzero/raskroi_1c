unit u_main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ExtCtrls,
  Vcl.Imaging.jpeg,uClasses, Vcl.CheckLst, Vcl.Grids, Vcl.ToolWin,
  System.Actions, Vcl.ActnList, System.ImageList, Vcl.ImgList, Vcl.Buttons;


type


  Tfrm_main = class(TForm)
    sb_main: TStatusBar;
    pnl_action: TPanel;
    edt_width: TEdit;
    edt_height: TEdit;
    tb_zoom: TTrackBar;
    scrollbox_main: TScrollBox;
    Label1: TLabel;
    Label2: TLabel;
    ActionList: TActionList;
    imgTool: TImageList;
    tb_left: TToolBar;
    tb_none: TToolButton;
    tb_move: TToolButton;
    tb_resize: TToolButton;
    tb_drawline: TToolButton;
    tb_movecutline: TToolButton;
    sb_main2: TStatusBar;
    tb_options: TToolBar;
    tb_separator: TToolButton;
    tb_cross: TToolButton;
    SplitterV: TSplitter;
    CategoryPanelGroup: TCategoryPanelGroup;
    catpnl_defect: TCategoryPanel;
    catpnl_useful: TCategoryPanel;
    catpnl_OrderPieces: TCategoryPanel;
    catpnl_cutlines: TCategoryPanel;
    pnl_defect: TPanel;
    imgButtons: TImageList;
    BitBtn_delete_defectrectangle: TBitBtn;
    BitBtn_add_defectrectangle: TBitBtn;
    action_add_defect_rectangle: TAction;
    action_delete_defect_rectangle: TAction;
    action_add_useful_rectangle: TAction;
    action_delete_useful_rectangle: TAction;
    Panel1: TPanel;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    lb_defect_rectangles: TListBox;
    lb_useful_rectangles: TListBox;
    lb_cutlines: TListBox;
    pnl_cutlines: TPanel;
    BitBtn_delete_cutline: TBitBtn;
    BitBtn_add_cutline: TBitBtn;
    action_add_cutline: TAction;
    action_delete_cutline: TAction;
    tb_showRectanglesInfo: TToolButton;
    btn_OK: TButton;
    ImgOptions: TImageList;
    lbl_materialname: TLabel;
    btn_close: TButton;
    tb_rotate: TToolButton;
    tb_saveimage: TToolButton;
    lb_order_rectangles: TListBox;
    tb_rotaterectangle: TToolButton;
    tb_vertline: TToolButton;
    tb_vertmovecutline: TToolButton;
    catpnl_vertcutlines: TCategoryPanel;
    lb_vertcutlines: TListBox;
    pnl_vertlines: TPanel;
    btn_delete_vert_cutline: TBitBtn;
    btn_add_vert_cutline: TBitBtn;
    action_add_vertcutline: TAction;
    action_delete_vertcutline: TAction;
    action_auto_height: TAction;
    tb_autoheight: TToolButton;
    sv_dialog: TSaveDialog;


    procedure btn_doClick(Sender: TObject);
    procedure tb_zoomChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btn_do2Click(Sender: TObject);
    procedure edt_widthChange(Sender: TObject);
    procedure edt_heightChange(Sender: TObject);
    procedure tb_noneClick(Sender: TObject);
    procedure tb_moveClick(Sender: TObject);
    procedure tb_resizeClick(Sender: TObject);
    procedure tb_drawlineClick(Sender: TObject);
    procedure tb_movecutlineClick(Sender: TObject);
    procedure btn_saveholstClick(Sender: TObject);
    procedure tb_crossClick(Sender: TObject);
    procedure action_add_defect_rectangleExecute(Sender: TObject);
    procedure action_delete_defect_rectangleExecute(Sender: TObject);
    procedure action_add_useful_rectangleExecute(Sender: TObject);
    procedure action_delete_useful_rectangleExecute(Sender: TObject);
    procedure action_add_cutlineExecute(Sender: TObject);
    procedure action_delete_cutlineExecute(Sender: TObject);
    procedure tb_showRectanglesInfoClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure tb_rotateClick(Sender: TObject);
    procedure tb_saveimageClick(Sender: TObject);
    procedure tb_rotaterectangleClick(Sender: TObject);
    procedure tb_vertlineClick(Sender: TObject);
    procedure tb_vertmovecutlineClick(Sender: TObject);
    procedure action_add_vertcutlineExecute(Sender: TObject);
    procedure btn_delete_vert_cutlineClick(Sender: TObject);
    procedure action_auto_heightExecute(Sender: TObject);
    procedure FormDestroy(Sender: TObject);

  private
    { Private declarations }
    procedure OnAddCutLine(var Msg: TMessage); message WM_ADDCUTLINE_MSG;
    procedure OnAddVertCutLine(var Msg:TMessage); message WM_ADDVERTCUTLINE_MSG;
    procedure FreeObjects(const AStrings: TStrings);
  public
    { Public declarations }

    Pieces: array of TRectangleData;
    json_schema: string;
    procedure CalcMaterials;
    function serializedSchema():string;
  end;




var
  frm_main: Tfrm_main;
  img_main:THolstImage;
  PiecesUseful,PiecesDefect: array of array [0..3] of string;
  PiecesOrders: array of array [0..3] of string;
  DefectArea:double;


implementation

{$R *.dfm}




procedure Tfrm_main.FormCreate(Sender: TObject);
begin
   img_main:=THolstImage.Create(frm_main);
   img_main.Parent:=scrollbox_main;

   //img_main.OriginalWidth:=StrToFloat(edt_width.Text);
   img_main.OriginalHeight:=StrToFloat(edt_height.Text);
   img_main.DrawGrid:=true;
   img_main.ShowCanvasSize:=true;
   img_main.ShowRectanglesInfo:=false;
   img_main.Scale:=tb_zoom.Position;

   //img_main.Draw;

end;

procedure Tfrm_main.FormClose(Sender: TObject; var Action: TCloseAction);
begin
//   if img_main<>nil  then
//     FreeAndNil(img_main);

end;


procedure Tfrm_main.FreeObjects(const AStrings: TStrings);  //http://mirsovetov.net/tstrings-free-object.html
var
  I : Integer;
  Obj: TObject;
begin
   for I := 0 to Pred(AStrings.Count) do begin
     Obj := AStrings.Objects[I];
     if Assigned(Obj) then
       FreeAndNil(Obj);
   end;
end;


procedure Tfrm_main.FormDestroy(Sender: TObject);
begin
   if lb_useful_rectangles.Items.Count>0 then
      FreeObjects(lb_useful_rectangles.Items);
   if lb_order_rectangles.Items.Count>0 then
      FreeObjects(lb_order_rectangles.Items);
   if lb_cutlines.Items.Count>0 then
      FreeObjects(lb_cutlines.Items);
    if lb_vertcutlines.Items.Count>0 then
      FreeObjects(lb_vertcutlines.Items);
end;


procedure Tfrm_main.CalcMaterials;
var
  i:integer;
  iUseFulCount,iDefectCount,iPiecesOrderCount:integer;
  x1,x2,x3:integer;
  TotalArea,UsefulArea:double;
begin
  iUseFulCount:=0;
  iDefectCount:=0;
  iPiecesOrderCount:=0;
  x1:=0;
  x2:=0;
  x3:=0;
  UsefulArea:=0;
  TotalArea:=img_main.OriginalWidth*img_main.OriginalHeight;

  for i := 0 to img_main.Rectangles.Count-1 do
     case img_main.Rectangles[i].RectangleType of
        rtUseFul: inc(iUseFulCount);
        rtDefect: inc(iDefectCount);
        rtOrder : inc(iPiecesOrderCount);
     end;

  SetLength(PiecesUseFul,iUseFulCount);
  SetLength(PiecesDefect,iDefectCount);
  Setlength(PiecesOrders,iPiecesOrderCount);

  for i := 0 to img_main.Rectangles.Count-1 do begin
    case img_main.Rectangles[i].RectangleType of
       rtUseFul: begin
         PiecesUseful[x1,0]:=img_main.Rectangles[i].ClothName;
         PiecesUseful[x1,1]:=img_main.Rectangles[i].Name;
         PiecesUseful[x1,2]:=FloatToStr(img_main.Rectangles[i].OriginalWidth);
         PiecesUseful[x1,3]:=FloatToStr(img_main.Rectangles[i].OriginalHeight);
         UsefulArea:=UsefulArea+img_main.Rectangles[i].OriginalWidth*img_main.Rectangles[i].OriginalHeight;
         inc(x1);
       end;
       // REFACTORING
       // Дефектные куски нужно убрать и сразу рассчитать забракованную площадь через свойство DefectArea
       rtDefect: begin
         PiecesDefect[x2,0]:=img_main.Rectangles[i].ClothName;
         PiecesDefect[x2,1]:=img_main.Rectangles[i].Name;
         PiecesDefect[x2,2]:=FloatToStr(img_main.Rectangles[i].OriginalWidth);
         PiecesDefect[x2,3]:=FloatToStr(img_main.Rectangles[i].OriginalHeight);
         inc(x2);
       end;
       rtOrder: begin
         PiecesOrders[x3,0]:=img_main.Rectangles[i].ClothName;
         PiecesOrders[x3,1]:=img_main.Rectangles[i].Name;
         // Если кусок материала был визуально повернут то меняем местами ширину и высоту т.к. он хранится в 1с
         if  not img_main.Rectangles[i].Rotated then begin
           PiecesOrders[x3,2]:=FloatToStr(img_main.Rectangles[i].OriginalWidth);
           PiecesOrders[x3,3]:=FloatToStr(img_main.Rectangles[i].OriginalHeight);
         end
         else begin
           PiecesOrders[x3,2]:=FloatToStr(img_main.Rectangles[i].OriginalHeight);
           PiecesOrders[x3,3]:=FloatToStr(img_main.Rectangles[i].OriginalWidth);
         end;
         UsefulArea:=UsefulArea+img_main.Rectangles[i].OriginalWidth*img_main.Rectangles[i].OriginalHeight;
         inc(x3);
       end;
    end;
  end;

  DefectArea:=TotalArea-UsefulArea;  // Высчитываем общую площадь дефектной(Ненужной) области для списания

end;


procedure Tfrm_main.OnAddCutLine(var Msg:TMessage);
{var
  tmpCutline:TCustomCutline;
  toppos:integer;
begin
  if img_main<>nil then begin
     toppos:=LongInt(Msg.WParam);
     tmpCutline:=img_main.Cutlines[img_main.Cutlines.Count-1];
     //img_main.Draw;
     lb_cutlines.Items.AddObject(tmpCutLine.Name,TObject(tmpCutline));
  end;}

var
  tmpCutLine:TCustomCutLine;
  toppos:integer;
begin
  if img_main<>nil then begin
    toppos:=LongInt(Msg.WParam);
    tmpCutLine:=img_main.Cutlines.CutLine[img_main.Cutlines.Count-1];
    lb_cutlines.Items.AddObject(tmpCutLine.Name,TObject(tmpCutline));
  end;
end;

procedure Tfrm_main.OnAddVertCutLine(var Msg: TMessage);
 var
  tmpVertCutLine:TCustomVertCutLine;
  leftpos:integer;
begin
  if img_main<>nil then begin
    leftpos:=LongInt(Msg.WParam);
    tmpVertCutLine:=img_main.VertCutlines.VertCutLine[img_main.VertCutLines.Count-1];
    lb_vertcutlines.Items.AddObject(tmpVertCutLine.Name,TObject(tmpVertCutLine));
  end;
end;



procedure Tfrm_main.tb_zoomChange(Sender: TObject);
begin
   img_main.Scale:=tb_zoom.Position;
   img_main.Draw;
   sb_main2.Panels[1].Text:='';
   sb_main.Panels[0].Text:='Ширина:'+inttostr(img_main.Width)+' Высота:'+inttostr(img_main.Height)+' Отступ:'+inttostr(img_main.ScaledOtstup);
//   if img_main.Rectangles.Count>0 then
//     with img_main.Rectangles[0] do
//       sb_main2.Panels[0].Text:='X:'+inttostr(Left)+' Y:'+inttostr(Top);
   sb_main2.Panels[1].Text:=sb_main2.Panels[1].Text+' Масштаб : '+floattostr(img_main.Scale);
end;




procedure Tfrm_main.tb_rotaterectangleClick(Sender: TObject);
begin
   img_main.Rectangles[img_main.Rectangles.Count-1].Rotate;
   img_main.Rectangles[img_main.Rectangles.Count-1].SetResizeBoundaries;
   img_main.Draw;

end;

procedure Tfrm_main.tb_movecutlineClick(Sender: TObject);
begin
  if (Sender as TToolButton).Down then begin
    img_main.tool:=dtMoveCutLine
  end
  else begin
    img_main.tool:=dtNone;
  end;
end;

procedure Tfrm_main.tb_noneClick(Sender: TObject);
begin
  if (Sender as TToolButton).Down then begin
    img_main.Tool:=dtNone;
  end;
end;


procedure Tfrm_main.tb_crossClick(Sender: TObject);
begin
  img_main.ShowCoordinates:=tb_cross.Down;
end;

procedure Tfrm_main.tb_drawlineClick(Sender: TObject);
begin
  if (Sender as TToolButton).Down then begin
    img_main.Tool:=dtCutLine
  end
  else begin
    img_main.tool:=dtNone;
  end;
end;

procedure Tfrm_main.tb_moveClick(Sender: TObject);
begin
  if (Sender as TToolButton).Down then begin
    img_main.Tool:=dtMoveRectangle
  end
  else begin
    img_main.tool:=dtNone;
  end;
end;


procedure Tfrm_main.tb_resizeClick(Sender: TObject);
begin
  if (Sender as TToolButton).Down then begin
    img_main.tool:=dtResizeRectangle
  end
  else begin
    img_main.tool:=dtNone;
  end;
end;



procedure Tfrm_main.tb_rotateClick(Sender: TObject);
begin
   img_main.Rotate;
  img_main.Draw;
  edt_width.Text:=Floattostr(img_main.OriginalWidth);
  edt_height.Text:=Floattostr(img_main.OriginalHeight);
end;

procedure Tfrm_main.tb_saveimageClick(Sender: TObject);
begin
   if img_main.Picture<>nil  then
     //if sv_dialog.Create then     
        img_main.Picture.SaveToFile('Holst.jpg');
end;

procedure Tfrm_main.tb_showRectanglesInfoClick(Sender: TObject);
begin
  img_main.ShowRectanglesInfo:=tb_showRectanglesInfo.Down;
  img_main.Draw;
end;

procedure Tfrm_main.tb_vertlineClick(Sender: TObject);
begin
   if (Sender as TToolButton).Down then begin
    img_main.Tool:=dtVertCutLine
  end
  else begin
    img_main.tool:=dtNone;
  end;
end;

procedure Tfrm_main.tb_vertmovecutlineClick(Sender: TObject);
begin
  if (Sender as TToolButton).Down then begin
    img_main.tool:=dtMoveVertCutLine
  end
  else begin
    img_main.tool:=dtNone;
  end;
end;

procedure Tfrm_main.action_add_defect_rectangleExecute(Sender: TObject);
var
  tmpRectangle:TCustomRectangle;
begin
  if img_main<>nil then begin
    tmpRectangle:=img_main.Rectangles.Add();
    tmpRectangle.Resizable:=true;
    tmpRectangle.RectangleType:=rtDefect;
    tmpRectangle.Scale:=img_main.Scale;
    tmpRectangle.SetResizeBoundaries;
    // Расчет верхней точки (реальный размер)
    tmpRectangle.Leftotstup:=round((tmpRectangle.Left)/tmpRectangle.Scale);
    tmpRectangle.Topotstup:=round((tmpRectangle.Top)/tmpRectangle.Scale);
    //lb_defect_rectangles.Items.addObject(Inttostr(img_main.Rectangles.Count-1),TObject(tmpRectangle));
    lb_defect_rectangles.Items.addObject(tmpRectangle.Name,TObject(tmpRectangle));
    img_main.Draw;
  end;
end;


procedure Tfrm_main.action_delete_defect_rectangleExecute(Sender: TObject);
var
  i:integer;
begin
  if (img_main<>nil) and (img_main.Rectangles.Count>0) then begin
    if Lb_defect_rectangles.ItemIndex>-1 then
      //img_main.Rectangles.Delete(StrToInt(lb_defect_rectangles.Items[lb_defect_rectangles.ItemIndex]));
      img_main.Rectangles.Delete(img_main.Rectangles.FindByName(lb_defect_rectangles.Items[lb_defect_rectangles.ItemIndex]));
      lb_defect_rectangles.DeleteSelected;
      lb_defect_rectangles.Clear;
      lb_useful_rectangles.Clear;
      for i := 0 to img_main.Rectangles.Count-1 do begin
        if img_main.Rectangles[i].Resizable then begin
          if  img_main.Rectangles[i].RectangleType=rtDefect then
            lb_useful_rectangles.Items.AddObject(img_main.Rectangles[i].Name,TObject(img_main.Rectangles[i]))
          else
            lb_defect_rectangles.Items.AddObject(img_main.Rectangles[i].Name,TObject(img_main.Rectangles[i]));
        end;
      end;

      img_main.Draw;
  end;
end;

procedure Tfrm_main.action_add_useful_rectangleExecute(Sender: TObject);
var
  tmpRectangle:TCustomRectangle;
begin
  if img_main<>nil then begin
    tmpRectangle:=img_main.Rectangles.Add();
    tmpRectangle.Resizable:=true;
    tmpRectangle.RectangleType:=rtUseFul;
    tmpRectangle.Scale:=img_main.Scale;
    tmpRectangle.SetResizeBoundaries;
    // Расчет верхней точки (реальный размер)
    tmpRectangle.Leftotstup:=round((tmpRectangle.Left)/tmpRectangle.Scale);
    tmpRectangle.Topotstup:=round((tmpRectangle.Top)/tmpRectangle.Scale);
    //lb_useful_rectangles.Items.addObject(Inttostr(img_main.Rectangles.Count-1),TObject(tmpRectangle));
    lb_useful_rectangles.Items.addObject(tmpRectangle.Name,TObject(tmpRectangle));
    img_main.Draw;
  end;
end;

procedure Tfrm_main.action_delete_useful_rectangleExecute(Sender: TObject);
var
  i:integer;
begin
  if (img_main<>nil) and (img_main.Rectangles.Count>0) then begin
    if Lb_useful_rectangles.ItemIndex>-1 then
      img_main.Rectangles.Delete(img_main.Rectangles.FindByName(lb_useful_rectangles.Items[lb_useful_rectangles.ItemIndex]));
      lb_useful_rectangles.DeleteSelected;
      lb_useful_rectangles.Clear;
      lb_defect_rectangles.Clear;
      for i := 0 to img_main.Rectangles.Count-1 do begin
        if img_main.Rectangles[i].Resizable then begin
          if  img_main.Rectangles[i].RectangleType=rtUseFul then
            lb_useful_rectangles.Items.AddObject(img_main.Rectangles[i].Name,TObject(img_main.Rectangles[i]))
          else
            lb_defect_rectangles.Items.AddObject(img_main.Rectangles[i].Name,TObject(img_main.Rectangles[i]));
        end;
      end;
     img_main.Draw;
  end;
end;


procedure Tfrm_main.action_add_vertcutlineExecute(Sender: TObject);
var
  tmpVertCutline:TCustomVertCutline;
begin
  if img_main<>nil then begin
     tmpVertCutline:=img_main.VertCutlines.Add(img_main.ScaledOtstup);
     lb_vertcutlines.Items.AddObject(tmpVertCutLine.Name,TObject(tmpVertCutline));
     img_main.Draw;
  end;
end;

procedure Tfrm_main.action_auto_heightExecute(Sender: TObject);
begin
  img_main.AutoCalcOriginalHeight;
  img_main.Draw;
  edt_height.Text:=FloatToStr(img_main.OriginalHeight);
end;

procedure Tfrm_main.action_add_cutlineExecute(Sender: TObject);
var
  tmpCutline:TCustomCutline;
begin
  if img_main<>nil then begin
     tmpCutline:=img_main.Cutlines.Add(img_main.ScaledOtstup);
     lb_cutlines.Items.AddObject(tmpCutLine.Name,TObject(tmpCutline));
     img_main.Draw;
  end;
end;

procedure Tfrm_main.action_delete_cutlineExecute(Sender: TObject);
var
  i:integer;
begin
  if (img_main<>nil) and (img_main.Cutlines.Count>0) then begin
    if Lb_cutlines.ItemIndex>-1 then
      img_main.Cutlines.Delete(img_main.Cutlines.FindByName(lb_cutlines.Items[lb_cutlines.ItemIndex]));
      lb_cutlines.DeleteSelected;
      lb_cutlines.Items.Clear;
      for i := 0 to img_main.Cutlines.Count-1 do begin
        lb_cutlines.Items.AddObject(img_main.Cutlines[i].Name,TObject(img_main.CutLines[i]));
      end;
      img_main.Draw;
  end;
end;





procedure Tfrm_main.btn_delete_vert_cutlineClick(Sender: TObject);
var
  i:integer;
begin
  if (img_main<>nil) and (img_main.VertCutlines.Count>0) then begin
    if Lb_vertcutlines.ItemIndex>-1 then
      img_main.VertCutlines.Delete(img_main.VertCutLines.FindByName(lb_vertcutlines.Items[lb_vertcutlines.ItemIndex]));
      lb_vertcutlines.DeleteSelected;
      lb_vertcutlines.Items.Clear;
      for i := 0 to img_main.VertCutlines.Count-1 do begin
        lb_vertcutlines.Items.AddObject(img_main.VertCutlines[i].Name,TObject(img_main.VertCutLines[i]));
      end;
      img_main.Draw;
  end;

end;

procedure Tfrm_main.btn_do2Click(Sender: TObject);
begin
   if img_main<>nil then
     img_main.CreateRandomRectangles;
   img_main.Draw;
end;

procedure Tfrm_main.btn_doClick(Sender: TObject);
begin
  img_main.Rotate;
  img_main.Draw;
  edt_width.Text:=Floattostr(img_main.OriginalWidth);
  edt_height.Text:=Floattostr(img_main.OriginalHeight);
end;




procedure Tfrm_main.btn_saveholstClick(Sender: TObject);
begin
   if img_main.Picture<>nil  then
     img_main.Picture.SaveToFile('Holst.jpg');
end;

procedure Tfrm_main.edt_heightChange(Sender: TObject);
var
  d:double;
begin
   if edt_height.Text<>'' then
     if TryStrToFloat(edt_width.Text,d) then begin
       img_main.OriginalHeight:=StrToFloat(edt_height.Text);
       img_main.Draw;
     end;
end;

procedure Tfrm_main.edt_widthChange(Sender: TObject);
var
  d:double;
begin
   if edt_width.Text<>'' then
     if TryStrToFloat(edt_width.Text,d) then begin
       img_main.OriginalWidth:=StrToFloat(edt_width.Text);
       img_main.Draw;
     end;
end;


function Tfrm_main.serializedSchema():string;
//var
   //jsonWriter:TJSon
begin

end;

end.
