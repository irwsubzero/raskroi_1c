unit uClasses;

interface

uses
  Vcl.ExtCtrls, Vcl.Controls, SysUtils, Vcl.graphics, System.Classes,
  Vcl.Dialogs,
  System.Types, System.Math, Messages, Winapi.Windows,System.JSON,System.Generics.Collections;

const
  ResizeLimit = 0.1;
  CircleRadius = 6;

  WM_ADDCUTLINE_MSG = WM_APP + 1;
  WM_ADDVERTCUTLINE_MSG = WM_APP+2;

type
  TResizeMode = (rmNoMode, rmUpperLeft, rmUpperRight, rmLowerLeft,
    rmLowerRight,rmMiddleLeft,rmMiddleRight);
  TTool = (dtNone, dtResizeRectangle, dtMoveRectangle, dtCutLine,
    dtMoveCutLine,dtVertCutLine,dtMoveVertCutLine);
  TRectangleType=(rtUseFul,rtDefect,rtOrder);

  TRectangleData = record
    ClothName: string;
    OrderName: string;
    Width: double;
    Height: double;

  end;

  TResizeShape = class(TObject)
  public
    FSize: integer;
    FLeft: integer;
    FTop: integer;
    FRight: integer;
    FBottom: integer;

    FColor: TColor;
  end;

  { Имеет только значение координаты Y, т.к. координата X будет всегда награницах холста
    оставлена для будущего на всякий }
  TCustomCutLine = class(TObject)
  private
    //FScale: double;
    FName: string;
    FBeginPoint: TPoint;
    FTopOtstup: integer;
  public
    //property Scale: double read FScale write FScale;
    property Name: String read FName write FName;
    //property BeginPoint:TPoint read FBeginPoint write FBeginPoint;
    property TopOtstup:integer read FTopOtstup write FTopOtstup;  // Top позиция относительно холста в мм
  end;

  TCutLines = class(TObject)
  private
    Fitems: array of TCustomCutLine;
    FCount: integer;
    function getItem(index: integer): TCustomCutLine;
    procedure setItem(index: integer; Value: TCustomCutLine);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    function Add(X: integer): TCustomCutLine; overload;
    function Add(aBeginPoint: TPoint): TCustomCutLine; overload;
    function Delete(index: integer): integer;
    function FindByName(AName: string): integer;
    property Count: integer read FCount;
    property CutLine[index: integer]: TCustomCutLine read getItem
      write setItem; default;
  end;

  TCustomVertCutLine = class (TObject)
     private
     FScale: double;
     FName: string;
     FBeginPoint: TPoint;
     FLeftOtstup: integer;
  public
     property Scale: double read FScale write FScale;
     property Name: String read FName write FName;
     property LeftOtstup:integer read FLeftOtstup write FLeftOtstup;  // Left позиция относительно холста в мм
  end;

  TVertCutLines = class(TObject)
  private
    Fitems: array of TCustomVertCutLine;
    FCount: integer;
    function getItem(index: integer): TCustomVertCutLine;
    procedure setItem(index: integer; Value: TCustomVertCutLine);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    function Add(X: integer): TCustomVertCutLine; overload;
    function Add(aBeginPoint: TPoint): TCustomVertCutLine; overload;
    function Delete(index: integer): integer;
    function FindByName(AName: string): integer;
    property Count: integer read FCount;
    property VertCutLine[index: integer]: TCustomVertCutLine read getItem write setItem; default;
  end;



  TCustomRectangle = class(TObject)
  private
    FScale: double;
    FName: string;
    FRectangleData: TRectangleData;
    FupperLeft, FupperRight, FLowerLeft, FLowerRight,FmiddleLeft,FMiddleRight: TResizeShape;
    FLeftotstup: integer;  // Left  позиция относительно холста  в мм
    FTopOtstup: integer;   // Top позиция относительно холста    в  мм
    FLeft: integer;
    FTop: integer;
    FRight: integer;
    FBottom: integer;
    FScaledWidth: double;
    FScaledHeight: double;
    FResizable: boolean;
    FRotated : boolean; // флаг что кусок был повернут, чтобы вернуть в 1с не поменялись размеры местами
    {*} FrectangleType:TRectangleType;
    //FUseFul: boolean; // Забраковать кусок или нет
    procedure SetScale(Value: double);
    function getClothName: string;
    procedure setClothName(Value: string);
    function getOrderName: string;
    procedure setOrderName(Value: string);
    function getOriginalWidth: double;
    procedure setOriginalWidth(Value: double);
    function getOriginalHeight: double;
    procedure setOriginalHeight(Value: double);
  public
    property Scale: double read FScale write SetScale;
    property Name: string read FName write FName;
    property ClothName: string read getClothName write setClothName;
    property OrderName: string read getOrderName write setOrderName;
    property OriginalWidth: double read getOriginalWidth write setOriginalWidth;
    property OriginalHeight: double read getOriginalHeight
      write setOriginalHeight;
    property Width: double read FScaledWidth;
    property Height: double read FScaledHeight;
    { _temp } property Left: integer read FLeft;
    { _temp } property Top: integer read FTop;
    property Resizable: boolean read FResizable write FResizable;
    //property UseFul: boolean read FUseFul write FUseFul;
    {*} property RectangleType:TRectangleType read FrectangleType write FrectangleType;
    property propLeft: integer read FLeft write FLeft;
    property propTop: integer read FTop write FTop;
    property propRight: integer read FRight write FRight;
    property propBottom: integer read FBottom write FBottom;
    property LeftOtstup: integer read FLeftotstup write FLeftotstup;
    property TopOtstup: integer read FTopOtstup write FTopOtstup;
    property Rotated: boolean read FRotated write FRotated;
    constructor Create;
    destructor Destroy; override;
    procedure SetResizeBoundaries;
    procedure Rotate;
  end;

  TRectangles = class(TObject)
  private
    Fitems: array of TCustomRectangle;
    FCount: integer;
    function getItem(index: integer): TCustomRectangle;
    procedure setItem(index: integer; Value: TCustomRectangle);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    function Add(): TCustomRectangle; overload;
    function Add(AClothName, AOrderName: string;
      AOriginalWidth, AOriginalHeight: double): integer; overload;
    function Delete(index: integer): integer;
    function FindByName(AName: string): integer;
    property Count: integer read FCount;
    property Rectangle[index: integer]: TCustomRectangle read getItem
      write setItem; default;


  end;

  THolstImage = class(TImage)
  private
    FKoeff: integer; // коэффициент масштабирования для сетки
    // FOtstup:integer;
    FOtstup: double;
    FScaledOtstup: integer;
    FOriginalWidth: double;
    FOriginalHeight: double;
    FDrawGrid: boolean;
    FShowCanvasSize: boolean;

    FRectangles: TRectangles;
    FCutLines: TCutLines;
    FVertCutLines:TVertCutLines;
    FTool: TTool;
    FActiveRectangleIndex: integer;
    FActiveCutLineIndex: integer;
    FDragOffset: TPoint;
    FShowRectanglesInfo: boolean;
    FShowCoordinates: boolean;
    { * } FPos: TPoint;
    FShowContur: boolean;
    FResizeMode: TResizeMode;
    FConturRect: TRect;
    FConturLine: TPoint;
    FVertConturLine:TPoint;
    FNewRectanglePosRect: TRect;
    FOldCutLinePos: TPoint;
    FScale: double;

    //19.01.2019 не рисовать зеленым цветом текущий Кусок Ткани
    FDoNotPaintOverCurrentRectangle:boolean;
    FSerializedSchema:string;

    procedure SetScale(Value: double);

    procedure SetWidth(Value: double);
    procedure SetHeight(Value: double);

    procedure SetTool(ATool: TTool);
    function GetRectangleAt(AX, AY: integer): integer;
    function GetCutLineAt(AX, AY: integer): integer;
    function GetVertCutLineAt(AX, AY: integer): integer;
    // function InterSects(Rect1,Rect2:TCustomRectangle):boolean;
    // function InterSectsContur(Rect:TRect;Rect1:TCustomRectangle):boolean;
    // function OuterSects(Rect1:TCustomRectangle;Rect:TRect):boolean;
    function OuterSectsContur(Rect1, Rect2: TRect): boolean;
    function _IntersectRect(const Rect1, Rect2: TRect): boolean;


  public
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;
    procedure Draw;
    procedure Rotate;
    procedure MouseMove(Shift: TShiftState; X, Y: integer); override;
    procedure MoveToolMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure MoveToolMouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: integer);
    procedure MoveToolMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure ResizeToolMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure ResizeToolMouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: integer);
    procedure ResizeToolMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure CutLineToolMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure CutLineToolMouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: integer);
    procedure CutLineToolMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure MoveCutLineToolMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure MoveCutLineToolMouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: integer);
    procedure MoveCutLineToolMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure VertCutLineToolMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure VertCutLineToolMouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: integer);
    procedure VertCutLineToolMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure MoveVertCutLineToolMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure MoveVertCutLineToolMouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: integer);
    procedure MoveVertCutLineToolMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);

    procedure CreateRandomRectangles;
    property Rectangles: TRectangles read FRectangles;
    property Cutlines: TCutLines read FCutLines;
    property VertCutLines:TVertCutLines read FVertCutLines;
    property Tool: TTool read FTool write SetTool;
    property OriginalWidth: double read FOriginalWidth write SetWidth;
    property OriginalHeight: double read FOriginalHeight write SetHeight;
    property DrawGrid: boolean read FDrawGrid write FDrawGrid;
    property ShowCanvasSize: boolean read FShowCanvasSize write FShowCanvasSize;
    property Scale: double read FScale write SetScale;
    property Otstup: double read FOtstup write FOtstup;
    property ScaledOtstup: integer read FScaledOtstup; // для информации
    property ShowCoordinates: boolean read FShowCoordinates
      write FShowCoordinates;
    property ShowRectanglesInfo: boolean read FShowRectanglesInfo
      write FShowRectanglesInfo;

    property DoNotPaintOverCurrentRectangle:boolean read FDoNotPaintOverCurrentRectangle
      write FDoNotPaintOverCurrentRectangle;
    property SerializedSchema:string read FSerializedSchema write FSerializedSchema;


    procedure ReCalcLeftTopPositionForRectangles;
    procedure AutoCalcOriginalHeight;

    procedure SerializeSchema;
    procedure UnSerializeSchema;
  end;

implementation

{ TCustomRectangle------------------------------------------------------------- }

uses AddInObj;

constructor TCustomRectangle.Create;
begin
  FupperLeft := TResizeShape.Create;
  FupperRight := TResizeShape.Create;
  FLowerLeft := TResizeShape.Create;
  FLowerRight := TResizeShape.Create;
  FmiddleLeft :=TResizeShape.Create;
  FMiddleRight:=TResizeShape.Create;
end;

procedure TCustomRectangle.SetResizeBoundaries;
begin
  with FupperLeft do
  begin
    FSize := 5;
    FLeft := Self.FLeft;
    FTop := Self.FTop;
    FRight := FLeft + FSize;
    FBottom := FTop + FSize;
    FColor := cllime;
  end;
  with FupperRight do
  begin
    FSize := 5;
    FLeft := Self.FRight - FSize;
    FTop := Self.FTop;
    FRight := Self.FRight;
    FBottom := FTop + FSize;
    FColor := cllime;
  end;
  with FLowerLeft do
  begin
    FSize := 5;
    FLeft := Self.FLeft;
    FTop := Self.FBottom - FSize;
    FRight := Self.FLeft + FSize;
    FBottom := Self.FBottom;
    FColor := cllime;
  end;
  with FLowerRight do
  begin
    FSize := 5;
    FLeft := Self.FRight - FSize;
    FTop := Self.FBottom - FSize;
    FRight := Self.FRight;
    FBottom := Self.FBottom;
    FColor := cllime;
  end;
  with FmiddleLeft do begin
    FSize := 5;
    FLeft:=Self.FLeft;
    FTop:=round(Self.FTop+FScaledHeight/2-FSize/2);
    Fright:=Self.FLeft+FSize;
    FBottom:=round(Self.FBottom-FScaledHeight/2+FSize/2);
    FColor := cllime;
  end;
  with FMiddleRight do begin
    FSize := 5;
    FLeft:=Self.FRight-FSize;
    FTop:=round(Self.FTop+FScaledHeight/2-FSize/2);
    FRight:=Self.FRight;
    FBottom:=round(Self.FBottom-FScaledHeight/2+FSize/2);
    FColor := cllime;
  end;
end;

procedure TCustomRectangle.Rotate;
var
  w,h :Double;
begin
   w:=getOriginalWidth;
   h:=getOriginalHeight;
   setOriginalWidth(h);
   setOriginalHeight(w);
   FRight := FLeft + round(FScaledWidth);
   FBottom := FTop + round(FScaledHeight);
   FRotated:= not FRotated;
end;

procedure TCustomRectangle.SetScale(Value: double);
begin
  FScale := Value;

  FScaledWidth := FScale * (FRectangleData.Width * 1000);
  FScaledHeight := FScale * (FRectangleData.Height * 1000);
  FRight := FLeft + round(FScaledWidth);
  FBottom := FTop + round(FScaledHeight);
end;

function TCustomRectangle.getClothName: string;
begin
  Result := FRectangleData.ClothName;
end;

procedure TCustomRectangle.setClothName(Value: string);
begin
  FRectangleData.ClothName := Value;
end;

function TCustomRectangle.getOrderName: string;
begin
  Result := FRectangleData.OrderName;
end;

procedure TCustomRectangle.setOrderName(Value: string);
begin
  FRectangleData.OrderName := Value;
end;

function TCustomRectangle.getOriginalWidth: double;
begin
  Result := FRectangleData.Width;
end;

procedure TCustomRectangle.setOriginalWidth(Value: double);
begin
  FRectangleData.Width := Value;
  FScaledWidth := FRectangleData.Width * 1000 * FScale;
end;

function TCustomRectangle.getOriginalHeight: double;
begin
  Result := FRectangleData.Height;
end;

procedure TCustomRectangle.setOriginalHeight(Value: double);
begin
  FRectangleData.Height := Value;
  FScaledHeight := FRectangleData.Height * 1000 * FScale;
end;

destructor TCustomRectangle.Destroy;
begin
  FupperLeft.Free;
  FupperRight.Free;
  FLowerLeft.Free;
  FLowerRight.Free;
  FmiddleLeft.Free;
  FMiddleRight.Free;

  inherited;
end;

{ TRectangles------------------------------------------------------------------ }

constructor TRectangles.Create;
begin
  inherited;
  FCount := 0;
end;

destructor TRectangles.Destroy;
begin
  Clear();
  inherited;
end;

procedure TRectangles.Clear;
var
  index: integer;
begin
  for index := 0 to FCount - 1 do
  begin
    FreeAndNil(Fitems[index]);
  end;
  Fitems := nil;
  FCount := 0;
end;

function TRectangles.getItem(index: integer): TCustomRectangle;
begin
  if Index < FCount then
    Result := Fitems[index]
  else
    System.Error(reRangeError);
end;

procedure TRectangles.setItem(index: integer; Value: TCustomRectangle);
begin
  if Index < FCount then
    Fitems[index] := Value
  else
    System.Error(reRangeError);
end;

function TRectangles.Add(): TCustomRectangle;
begin
  setLength(Fitems, FCount + 1);
  FCount := FCount + 1;

  Fitems[High(Fitems)] := TCustomRectangle.Create;
  // Ширина и высота по умолчанию
  Fitems[High(Fitems)].OriginalWidth := 0.5;
  Fitems[High(Fitems)].OriginalHeight := 0.5;

  // Здесь не очень правильно задавать имя, но метод ADD() вызывается только для таких тканей
  Fitems[High(Fitems)].Name := 'Кусок ткани №' + inttostr(FCount);

  // Задание координат для выстраивания каскадом c учетом отступа главного холста
  Fitems[High(Fitems)].FLeft := FCount * 10;
  Fitems[High(Fitems)].FTop := FCount * 10;
  Fitems[High(Fitems)].FRight := Fitems[High(Fitems)].FLeft +
    round(Fitems[High(Fitems)].Width);
  Fitems[High(Fitems)].FBottom := Fitems[High(Fitems)].FTop +
    round(Fitems[High(Fitems)].Height);

  Fitems[High(Fitems)].Rotated:=false;

  Result := Fitems[High(Fitems)];
end;

function TRectangles.Add(AClothName, AOrderName: string;
  AOriginalWidth, AOriginalHeight: double): integer;
begin
  setLength(Fitems, FCount + 1);
  Fitems[High(Fitems)] := TCustomRectangle.Create;
  Fitems[High(Fitems)].Name := AClothName + '_' + Floattostr(AOriginalWidth) +
    'x' + Floattostr(AOriginalHeight) + '_' + inttostr(High(Fitems));
  Fitems[High(Fitems)].ClothName := AClothName;
  Fitems[High(Fitems)].OrderName := AOrderName;
  Fitems[High(Fitems)].OriginalWidth := AOriginalWidth;
  Fitems[High(Fitems)].OriginalHeight := AOriginalHeight;

  // Задание координат для выстраивания каскадом
  Fitems[High(Fitems)].FLeft := FCount * 10;
  Fitems[High(Fitems)].FTop := FCount * 10;
  Fitems[High(Fitems)].FRight := Fitems[High(Fitems)].FLeft +
    round(Fitems[High(Fitems)].Width);
  Fitems[High(Fitems)].FBottom := Fitems[High(Fitems)].FTop +
    round(Fitems[High(Fitems)].Height);

  Fitems[High(Fitems)].Rotated:=false;

  FCount := FCount + 1;
  Result := High(Fitems);
end;

function TRectangles.FindByName(AName: string): integer;
var
  index: integer;
begin
  for index := 0 to FCount - 1 do
  begin
    if Fitems[index].Name = AName then
    begin
      Result := index;
      Exit();
    end;
  end;
  Result := -1;
end;

function TRectangles.Delete(index: integer): integer;
var
  current: integer;
begin
  If FCount <= 0 then
    Exit;
  FreeAndNil(Fitems[Index]);
  for current := index + 1 to FCount - 1 do
  begin
    Fitems[current - 1] := Fitems[current];
    if Fitems[current - 1].FResizable then
      Fitems[current - 1].FName := 'Кусок ткани №' + inttostr(current);
  end;
  FCount := FCount - 1;
  setLength(Fitems, FCount)
end;




{ TCutLines-------------------------------------------------------------------- }

constructor TCutLines.Create;
begin
  inherited;
  FCount := 0;
end;

destructor TCutLines.Destroy;
begin
  Clear();
  inherited;
end;

procedure TCutLines.Clear;
var
  index: integer;
begin
  for index := 0 to FCount - 1 do
  begin
    FreeAndNil(Fitems[index]);
  end;
  Fitems := nil;
  FCount := 0;
end;

function TCutLines.getItem(index: integer): TCustomCutLine;
begin
  if Index < FCount then
    Result := Fitems[index]
  else
    System.Error(reRangeError);
end;

procedure TCutLines.setItem(index: integer; Value: TCustomCutLine);
begin
  if Index < FCount then
    Fitems[index] := Value
  else
    System.Error(reRangeError);
end;

function TCutLines.Add(X: integer): TCustomCutLine;
begin
  setLength(Fitems, FCount + 1);
  FCount := FCount + 1;
  Fitems[High(Fitems)] := TCustomCutLine.Create;

  // Для последовательного выстраивания
  Fitems[High(Fitems)].FBeginPoint := Point(X, FCount * 5); // 5 - произвольный шаг
  Fitems[High(Fitems)].FName := 'Линия отреза №' + inttostr(FCount);

  Result := Fitems[High(Fitems)];
end;

function TCutLines.Add(aBeginPoint: TPoint): TCustomCutLine;
begin
  setLength(Fitems, FCount + 1);
  FCount := FCount + 1;
  Fitems[High(Fitems)] := TCustomCutLine.Create;

  Fitems[High(Fitems)].FBeginPoint := aBeginPoint;
  Fitems[High(Fitems)].FName := 'Линия отреза №' + inttostr(FCount);

  Result := Fitems[High(Fitems)];
end;

function TCutLines.FindByName(AName: string): integer;
var
  index: integer;
begin
  for index := 0 to FCount - 1 do
  begin
    if Fitems[index].Name = AName then
    begin
      Result := index;
      Exit();
    end;
  end;
  Result := -1;
end;

function TCutLines.Delete(index: integer): integer;
var
  current: integer;
begin
  If FCount <= 0 then
    Exit;
  FreeAndNil(Fitems[Index]);
  for current := index + 1 to FCount - 1 do
  begin
    Fitems[current - 1] := Fitems[current];
    Fitems[current - 1].FName := 'Линия отреза №' + inttostr(current);
  end;
  FCount := FCount - 1;
  setLength(Fitems, FCount);

end;

{ TVertCutLines ---------------------------------------------------------------}



constructor TVertCutLines.Create;
begin
  inherited;
  FCount := 0;
end;

destructor TVertCutLines.Destroy;
begin
  Clear();
  inherited;
end;

procedure TVertCutLines.Clear;
var
  index: integer;
begin
  for index := 0 to FCount - 1 do
  begin
    FreeAndNil(Fitems[index]);
  end;
  Fitems := nil;
  FCount := 0;
end;

function TVertCutLines.getItem(index: integer): TCustomVertCutLine;
begin
  if Index < FCount then
    Result := Fitems[index]
  else
    System.Error(reRangeError);
end;

procedure TVertCutLines.setItem(index: integer; Value: TCustomVertCutLine);
begin
  if Index < FCount then
    Fitems[index] := Value
  else
    System.Error(reRangeError);
end;

function TVertCutLines.Add(X: integer): TCustomVertCutLine;
begin
  setLength(Fitems, FCount + 1);
  FCount := FCount + 1;
  Fitems[High(Fitems)] := TCustomVertCutLine.Create;

  // Для последовательного выстраивания
  Fitems[High(Fitems)].FBeginPoint := Point(X, FCount * 5);
  Fitems[High(Fitems)].FName := 'Линия отреза №' + inttostr(FCount);

  Result := Fitems[High(Fitems)];
end;

function TVertCutLines.Add(aBeginPoint: TPoint): TCustomVertCutLine;
begin
  setLength(Fitems, FCount + 1);
  FCount := FCount + 1;
  Fitems[High(Fitems)] := TCustomVertCutLine.Create;

  Fitems[High(Fitems)].FBeginPoint := aBeginPoint;
  Fitems[High(Fitems)].FName := 'Линия отреза №' + inttostr(FCount);

  Result := Fitems[High(Fitems)];
end;

function TVertCutLines.FindByName(AName: string): integer;
var
  index: integer;
begin
  for index := 0 to FCount - 1 do
  begin
    if Fitems[index].Name = AName then
    begin
      Result := index;
      Exit();
    end;
  end;
  Result := -1;
end;

function TVertCutLines.Delete(index: integer): integer;
var
  current: integer;
begin
  If FCount <= 0 then
    Exit ;
  FreeAndNil(Fitems[Index]);
  for current := index + 1 to FCount - 1 do
  begin
    Fitems[current - 1] := Fitems[current];
    Fitems[current - 1].FName := 'Линия отреза №' + inttostr(current);
  end;
  FCount := FCount - 1;
  setLength(Fitems, FCount);

end;


{ THolstImage----------------------------------------------------------------- }
constructor THolstImage.Create(aOwner: TComponent);
begin
  inherited Create(aOwner);

  FKoeff := 300; // подобран
  FOtstup := 0.5; // подобран

  FRectangles := TRectangles.Create;
  FCutLines := TCutLines.Create;
  FVertCutLines:=TVertCutLines.Create;
  FTool := dtNone;
  FShowRectanglesInfo := true;
  FShowCoordinates := true;

  FDoNotPaintOverCurrentRectangle:=true;

end;

destructor THolstImage.Destroy;
begin
  FreeAndNil(FCutLines);
  FreeAndNil(FVertCutLines);
  FreeAndNil(FRectangles);

  inherited;
end;

 procedure THolstImage.SetScale(Value: double);
var
  i: integer;
  // oldWidth, oldHeight: integer;
//  oldScale: double;

begin
  // oldWidth := Width;
  // oldHeight := Height;
  //oldScale := FScale;

  FScale := Value / 300;   // 300 поправочный коэффициент взят от фонаря
  FScaledOtstup := round(FOtstup * 1000 * FScale);

  Width := round((FOriginalWidth * 1000 + 2 * FOtstup * 1000) * FScale);
  Height := round((FOriginalHeight * 1000 + 2 * FOtstup * 1000) * FScale);

  if not(Picture.Graphic = nil) then
  begin
    Picture.Graphic.Width := Width;
    Picture.Graphic.Height := Height
  end;

  if FRectangles.Count > 0 then
  begin
    for i := 0 to FRectangles.FCount - 1 do
    begin
      FRectangles[i].FLeft := round(FRectangles[i].FLeftotstup * FScale);
      FRectangles[i].FTop := round(FRectangles[i].FTopOtstup * FScale);

      FRectangles[i].Scale := FScale;
      if FRectangles[i].FResizable then
        FRectangles[i].SetResizeBoundaries;
    end;
  end;

  if FCutLines.Count > 0 then
  begin
    for i := 0 to FCutLines.Count - 1 do
    begin
      FCutLines[i].FBeginPoint.Y := round((FCutLines[i].FTopOtstup) * FScale);
      //FCutLines[i].Scale := FScale;
    end;
  end;

  if FVertCutLines.Count> 0  then begin
    for i := 0 to FVertCutLines.Count -1  do begin
      FVertCutLines[i].FBeginPoint.X := round((FVertCutLines[i].FLeftOtstup) * FScale);
      FVertCutLines[i].Scale := FScale;
    end;
  end;

end;

{ * } procedure THolstImage.Rotate;
var
  iWidth, iHeight: double;
begin
  iWidth := FOriginalWidth;
  iHeight := FOriginalHeight;
  FOriginalWidth := iHeight;
  FOriginalHeight := iWidth;
  Width := round((FOriginalWidth * 1000 + FOtstup * 1000) * FScale);
  Height := round((FOriginalHeight * 1000 + FOtstup * 1000) * FScale);

end;

{ * } procedure THolstImage.SetWidth(Value: double);
begin
  FOriginalWidth := Value;
  Width := round((FOriginalWidth * 1000 + 2 * FOtstup * 1000) * FScale); // в мм

  if not(Picture.Graphic = nil) then
  begin
    Picture.Graphic.Width := Width;
  end;

end;

{ * } procedure THolstImage.SetHeight(Value: double);
begin
  FOriginalHeight := Value;
  Height := round((FOriginalHeight * 1000 + 2 * FOtstup * 1000) * FScale);
  // в мм

  if not(Picture.Graphic = nil) then
  begin
    Picture.Graphic.Height := Height;
  end;
end;

procedure THolstImage.Draw;
var
  i, j, k: integer;
  UpperLeftRect, UpperRightRect, LowerLeftRect, LowerRightRect,MiddleLeftRect,MiddleRightRect: TRect;
begin
  Canvas.Brush.Color := clWhite;
  Canvas.Rectangle(Rect(0, 0, Width, Height));

  // Окантовка холста
  with Canvas do
  begin
    Pen.Mode := pmCopy;
    Pen.Color := clGray;
    Pen.Style := psDot;
    Pen.Width := 1;
    Rectangle(0, 0, Width, Height);
  end;

  // Окантовка рабочей области
  with Canvas do
  begin
    Pen.Mode := pmCopy;
    Pen.Color := clGray;
    Pen.Style := psSolid;
    Pen.Width := 2;
    Rectangle(FScaledOtstup, FScaledOtstup, Width - FScaledOtstup,
      Height - FScaledOtstup);
  end;

  // Показать размеры
  if FShowCanvasSize then
  begin

    with Canvas do
    begin
      Pen.Mode := pmCopy;
      Pen.Color := clBlue;
      Pen.Style := psSolid;
      Pen.Width := 1;
      Font.Color := clMaroon;
      Font.Size := round(FScale * 80);

      MoveTo(FScaledOtstup, 2);
      LineTo(FScaledOtstup, FScaledOtstup);
      MoveTo(Width - FScaledOtstup - 1, 2);
      LineTo(Width - FScaledOtstup - 1, FScaledOtstup);
      MoveTo(round(FScaledOtstup / 2) + 5, round(FScaledOtstup / 2));
      LineTo(Width - 5, round(FScaledOtstup / 2));
      TextOut(round(Width / 2), 1, Floattostr(OriginalWidth) + 'м');

      MoveTo(2, FScaledOtstup);
      LineTo(FScaledOtstup, FScaledOtstup);
      MoveTo(2, Height - FScaledOtstup - 1);
      LineTo(FScaledOtstup, Height - FScaledOtstup - 1);
      MoveTo(round(FScaledOtstup / 2), round(FScaledOtstup / 2) + 5);
      LineTo(round(FScaledOtstup / 2), Height - 5);
      TextOut(1, round(Height / 2), Floattostr(OriginalHeight) + 'м');
    end;
  end;

  // Сетка
  if FDrawGrid then
  begin

    with Canvas do
    begin
      Pen.Mode := pmCopy;
      Pen.Color := clGray;
      Pen.Style := psDot;
      Pen.Width := 1;
      // горизонт. полосы
      for j := 1 to Height do
      begin

        // k:=FKoeff*round(Fscale);
        k := round(FKoeff * FScale);
        // Проверка чтобы координата Y при масштабировании не выходила за Height с учетом отступа
        if j * k + FScaledOtstup > Height - FScaledOtstup then
          continue;

        MoveTo(FScaledOtstup, j * k + FScaledOtstup);
        LineTo(Width - FScaledOtstup, j * k + FScaledOtstup);

      end;
      // вертик. полосы
      for i := 1 to Width do
      begin

        // k:=FKoeff*round(Fscale);
        k := round(FKoeff * FScale);
        // Проверка чтобы координата X при масштабировании не выходила за Width с учетом отступа
        if FScaledOtstup + i * k > Width - FScaledOtstup then
          continue;

        MoveTo(FScaledOtstup + i * k, FScaledOtstup);
        LineTo(FScaledOtstup + i * k, Height - FScaledOtstup);
      end;
    end;
  end;

  // рисуем квадраты
  if FRectangles.Count > 0 then
  begin

    for i := 0 to FRectangles.Count - 1 do
    begin

      if FRectangles[i].FResizable = false then
      begin
        Canvas.Pen.Mode := pmCopy;
        Canvas.Pen.Style := psSolid;
        Canvas.Pen.Width := 1;
        Canvas.Pen.Color := clBlack;

        { ********** REFACTORING******************************************************** }
        if FDoNotPaintOverCurrentRectangle then begin

          if i = FRectangles.Count - 1 then
          begin
            Canvas.Brush.Color := clCream;
          end
          else begin
            Canvas.Brush.Color := clWhite;
          end;

        end;
        { ********** REFACTORING******************************************************** }


        Canvas.Rectangle(FRectangles[i].FLeft, FRectangles[i].FTop,
          FRectangles[i].FRight, FRectangles[i].FBottom);

        Canvas.Font.Size := round(FRectangles[i].FScale * 2);

        if FShowRectanglesInfo { and (not FRectangles[i].FResizable) } then
        begin
          Canvas.Font.Size := round(FScale * 80);
          Canvas.TextOut(FRectangles[i].FLeft + 5, FRectangles[i].FTop + 5 +
            round(FRectangles[i].Height), FRectangles[i].OrderName);
        end;
      end;

      if (FRectangles[i].FResizable = true) then
      begin

        Canvas.Pen.Mode := pmCopy;
        Canvas.Pen.Style := psSolid;
        Canvas.Pen.Width := 1;
        Canvas.Pen.Color := clBlack;

        Canvas.Pen.Style := psSolid;

        if (FRectangles[i].FrectangleType=rtUseFul) then
          Canvas.Brush.Color:=$CCFFCC
        else
          Canvas.Brush.Color:=clWhite;

        Canvas.Rectangle(FRectangles[i].FLeft, FRectangles[i].FTop,
          FRectangles[i].FRight, FRectangles[i].FBottom);



        // Крестик
        //if FRectangles[i].FUseFul then
        if (FRectangles[i].FrectangleType=rtUseFul) then
        begin
          Canvas.Brush.Color := clWhite;
          Canvas.Pen.Color := clBlue;
          Canvas.Pen.Width := 1;
          Canvas.Pen.Style :=psDashDotDot;

           Canvas.TextOut(FRectangles[i].FLeft + 5, FRectangles[i].FTop + 5 +
            round(FRectangles[i].Height),'Полезный кусок ');
        end;
        if  FRectangles[i].FrectangleType=rtDefect then
        begin
          Canvas.Brush.Color := clWhite;
          Canvas.Pen.Color := clRed;
          Canvas.Pen.Width := 1;
          Canvas.Pen.Style := psDashDotDot;
        end;


        Canvas.MoveTo(FRectangles[i].FLeft, FRectangles[i].FTop);
        Canvas.LineTo(FRectangles[i].FRight, FRectangles[i].FBottom);
        Canvas.MoveTo(FRectangles[i].FLeft, FRectangles[i].FBottom);
        Canvas.LineTo(FRectangles[i].FRight, FRectangles[i].FTop);



        Canvas.Pen.Color := clBlack;
        Canvas.Pen.Width := 1;
        Canvas.Pen.Style:=psSolid;

        if FTool = dtResizeRectangle then
        begin

          // -------------------------------------------------------------
          with FRectangles[i] do
          begin
            Canvas.Brush.Color := FupperLeft.FColor;
            UpperLeftRect := Rect(FupperLeft.FLeft, FupperLeft.FTop,
              FupperLeft.FRight, FupperLeft.FBottom);

            Canvas.FillRect(UpperLeftRect);
            Canvas.Rectangle(UpperLeftRect);
            // -------------------------------------------------------------
            Canvas.Brush.Color := FupperRight.FColor;
            UpperRightRect := Rect(FupperRight.FLeft, FupperRight.FTop,
              FupperRight.FRight, FupperRight.FBottom);
            Canvas.FillRect(UpperRightRect);
            Canvas.Rectangle(UpperRightRect);
            // -------------------------------------------------------------
            Canvas.Brush.Color := FLowerLeft.FColor;
            LowerLeftRect := Rect(FLowerLeft.FLeft, FLowerLeft.FTop,
              FLowerLeft.FRight, FLowerLeft.FBottom);
            Canvas.FillRect(LowerLeftRect);
            Canvas.Rectangle(LowerLeftRect);
            // -------------------------------------------------------------
            Canvas.Brush.Color := FLowerRight.FColor;
            LowerRightRect := Rect(FLowerRight.FLeft, FLowerRight.FTop,
              FLowerRight.FRight, FLowerRight.FBottom);
            Canvas.FillRect(LowerRightRect);
            Canvas.Rectangle(LowerRightRect);
            // -------------------------------------------------------------
            Canvas.Brush.Color := FmiddleLeft.FColor;
            MiddleLeftRect:=Rect(FmiddleLeft.FLeft,FmiddleLeft.FTop,FmiddleLeft.FRight,FmiddleLeft.FBottom);
            Canvas.FillRect(MiddleLeftRect);
            Canvas.Rectangle(MiddleLeftRect);
            // -------------------------------------------------------------
            Canvas.Brush.Color := FMiddleRight.FColor;
            MiddleRightRect:=Rect(FmiddleRight.FLeft,FmiddleRight.FTop,FmiddleRight.FRight,FmiddleRight.FBottom);
            Canvas.FillRect(MiddleRightRect);
            Canvas.Rectangle(MiddleRightRect);
            // -------------------------------------------------------------
            Canvas.Brush.Color := clWhite;
          end;
        end;

        // Контурный ПреПрямоугольник
        if FShowContur then
        begin
          Canvas.Brush.Style := bsClear;
          Canvas.Pen.Style := psDot;
          Canvas.Rectangle(FConturRect);
          Canvas.TextOut(FConturRect.Left +
            round((FConturRect.Right - FConturRect.Left) / 2),
            FConturRect.Top + 5,
            Floattostr(RoundTo((FConturRect.Right - FConturRect.Left) /
            FScale, -2)));
          Canvas.TextOut(FConturRect.Left + 5,
            FConturRect.Top + round((FConturRect.Bottom - FConturRect.Top) / 2),
            Floattostr(RoundTo((FConturRect.Bottom - FConturRect.Top) /
            FScale, -2)));

          Canvas.Brush.Style := bsSolid;

        end;

      end;

      // Размеры
      Canvas.Brush.Color:=clWhite;
      Canvas.Pen.Color := clRed;
      // Canvas.Font.Size:=round(FRectangles[i].FScale*2);

      Canvas.Font.Size := round(FScale * 70);

//      Canvas.TextOut(FRectangles[i].FLeft +
//        round((FRectangles[i].FRight - FRectangles[i].FLeft) / 2),
//        FRectangles[i].FTop + 5,
//        Floattostr(FRectangles[i].OriginalWidth) + 'м');
//      Canvas.TextOut(FRectangles[i].FLeft + 5, FRectangles[i].FTop +
//        round((FRectangles[i].FBottom - FRectangles[i].FTop) / 2),
//        Floattostr(FRectangles[i].OriginalHeight) + 'м');

      Canvas.TextOut(FRectangles[i].FLeft + 2,FRectangles[i].FTop + 2,
        Floattostr(FRectangles[i].OriginalWidth) + 'м');

      Canvas.TextOut(FRectangles[i].FLeft + 2, FRectangles[i].FTop + round(FScale*110),

        Floattostr(FRectangles[i].OriginalHeight) + 'м');


      Canvas.Pen.Color := clBlack;

    end;

  end;

  // Рисование горизонтального контура линии отреза при нажатии на DrawTool
  Canvas.Pen.Color := clRed;
  Canvas.Brush.Style := bsClear;
  Canvas.Pen.Width := 1;
  Canvas.Pen.Style := psDot;

  if not FConturLine.IsZero then
  begin
    Canvas.TextOut(5,FConturLine.Y-8,FloatToStr((round((FConturLine.Y-FScaledOtstup)/FScale)/1000))+'м');
    Canvas.Ellipse(FScaledOtstup - CircleRadius * 2,
      FConturLine.Y - CircleRadius, FScaledOtstup,
      FConturLine.Y + CircleRadius);
    Canvas.MoveTo(FScaledOtstup, FConturLine.Y);
    Canvas.LineTo(Width - FScaledOtstup, FConturLine.Y);
    Canvas.Ellipse(Width - FScaledOtstup, FConturLine.Y - CircleRadius,
      Width - FScaledOtstup + CircleRadius * 2, FConturLine.Y + CircleRadius);
  end;
  Canvas.Brush.Style := bsSolid;

  // Рисование горизонтальных линий отреза
  if FCutLines.Count > 0 then
  begin
    Canvas.Pen.Color := clRed;
    Canvas.Pen.Width := 1;
    Canvas.Pen.Style := psDash;

    for i := 0 to FCutLines.Count - 1 do
    begin
      Canvas.TextOut(5,FCutLines[i].FBeginPoint.Y-8,FloatToStr((round((FCutLines[i].FBeginPoint.Y-FScaledOtstup)/FScale)/1000))+'м');
      Canvas.Ellipse(FScaledOtstup - CircleRadius * 2,
        FCutLines[i].FBeginPoint.Y - CircleRadius, FScaledOtstup,
        FCutLines[i].FBeginPoint.Y + CircleRadius);
      Canvas.MoveTo(FScaledOtstup, FCutLines[i].FBeginPoint.Y);
      Canvas.LineTo(Width - FScaledOtstup, FCutLines[i].FBeginPoint.Y);
      Canvas.Ellipse(Width - FScaledOtstup, FCutLines[i].FBeginPoint.Y -
        CircleRadius, Width - FScaledOtstup + CircleRadius * 2,
        FCutLines[i].FBeginPoint.Y + CircleRadius);
    end;

  end;


 // Рисование вертикального контура линии отреза при нажатии на DrawTool
  Canvas.Pen.Color := clRed;
  Canvas.Brush.Style := bsClear;
  Canvas.Pen.Width := 1;
  Canvas.Pen.Style := psDot;
  if not FVertConturLine.IsZero then
  begin
    Canvas.TextOut(FVertConturLine.X-8,3,FloatToStr((round((FVertConturLine.X-FScaledOtstup)/FScale)/1000))+'м');

    Canvas.Ellipse(FVertConturLine.X - CircleRadius,FScaledOtstup - CircleRadius * 2,
                   FVertConturLine.X + CircleRadius, FScaledOtstup);
    Canvas.MoveTo(FVertConturLine.X,FScaledOtstup );
    Canvas.LineTo(FVertConturLine.X,Height - FScaledOtstup);
    Canvas.Ellipse(FVertConturLine.X - CircleRadius,Height - FScaledOtstup,
                    FVertConturLine.X + CircleRadius,Height - FScaledOtstup + CircleRadius * 2);
  end;
  Canvas.Brush.Style := bsSolid;

  // Рисование вертикальных линий отреза
  if FVertCutLines.Count > 0 then begin
     Canvas.Pen.Color := clRed;
     Canvas.Pen.Width := 1;
     Canvas.Pen.Style := psDash;

     for i := 0 to FVertCutLines.Count - 1 do   begin
        Canvas.TextOut(FVertCutLines[i].FBeginPoint.X-8,3,FloatToStr((round((FVertCutLines[i].FBeginPoint.X-FScaledOtstup)/FScale)/1000))+'м');

        Canvas.Ellipse(FVertCutLines[i].FBeginPoint.X - CircleRadius,FScaledOtstup - CircleRadius * 2,
                       FVertCutLines[i].FBeginPoint.X + CircleRadius,FScaledOtstup);

        Canvas.MoveTo(FVertCutLines[i].FBeginPoint.X,FScaledOtstup);
        Canvas.LineTo(FVertCutLines[i].FBeginPoint.X,Height - FScaledOtstup);

        Canvas.Ellipse(FVertCutLines[i].FBeginPoint.X - CircleRadius,Height - FScaledOtstup,
                       FVertCutLines[i].FBeginPoint.X + CircleRadius,Height - FScaledOtstup + CircleRadius * 2);
     end;
  end;

end;

procedure THolstImage.SetTool(ATool: TTool);

begin
  FTool := ATool;

  case FTool of
    dtNone:
      begin
        OnMouseDown := nil;
        OnMouseMove := nil;
        OnMouseUp := nil;
        Cursor := crArrow;
        Draw;
      end;
    dtResizeRectangle:
      begin
        OnMouseDown := ResizeToolMouseDown;
        OnMouseMove := ResizeToolMouseMove;
        OnMouseUp := ResizeToolMouseUp;
        Cursor := crArrow;
         Draw;
      end;
    dtMoveRectangle:
      begin
        OnMouseDown := MoveToolMouseDown;
        OnMouseMove := MoveToolMouseMove;
        OnMouseUp := MoveToolMouseUp;
        Cursor := crHandPoint;
        Draw;
      end;
    dtCutLine:
      begin
        OnMouseDown := CutLineToolMouseDown;
        OnMouseMove := CutLineToolMouseMove;
        OnMouseUp := CutLineToolMouseUp;
        Cursor := crArrow;
         Draw;
      end;
    dtMoveCutLine:
      begin
        OnMouseDown := MoveCutLineToolMouseDown;
        OnMouseMove := MoveCutLineToolMouseMove;
        OnMouseUp := MoveCutLineToolMouseUp;
        Cursor := crHandPoint;
         Draw;
      end;
    dtVertCutLine:
      begin
         OnMouseDown := VertCutLineToolMouseDown;
         OnMouseMove := VertCutLineToolMouseMove;
         OnMouseUp := VertCutLineToolMouseUp;
         Cursor := crArrow;
      end;
    dtMoveVertCutLine:
      begin
          OnMouseDown := MoveVertCutLineToolMouseDown;
          OnMouseMove := MoveVertCutLineToolMouseMove;
          OnMouseUp := MoveVertCutLineToolMouseUp;
          Cursor := crHandPoint;
      end;
  end;

end;

function THolstImage.GetRectangleAt(AX: integer; AY: integer): integer;
var
  i: integer;
begin
  Result := -1;
  for i := FRectangles.Count - 1 downto 0 do
    with FRectangles[i] do
    begin
      if InRange(AX, FRectangles[i].FLeft, FRectangles[i].FRight) and
        InRange(AY, FRectangles[i].FTop, FRectangles[i].FBottom) then
        Exit(i);
    end;
end;

function THolstImage.GetCutLineAt(AX: integer; AY: integer): integer;
var
  i: integer;
begin
  Result := -1;
  for i := FCutLines.Count - 1 downto 0 do
    with FCutLines[i] do
    begin
      // if (FCutLines[i].FBeginPoint.Y=AY) and
      if (FCutLines[i].FBeginPoint.Y - 10 < AY) and
        (AY < FCutLines[i].FBeginPoint.Y + 10) and (AX >= FScaledOtstup) and
        (AX <= Width - FScaledOtstup) then
        Exit(i);
    end;
end;

function THolstImage.GetVertCutLineAt(AX: Integer; AY: Integer):integer;
var
  i: integer;
begin
  Result := -1;
  for i := FVertCutLines.Count - 1 downto 0 do
    with FVertCutLines[i] do
    begin
      // if (FCutLines[i].FBeginPoint.Y=AY) and
      if (FVertCutLines[i].FBeginPoint.X - 10 < AX) and
        (AX < FVertCutLines[i].FBeginPoint.X + 10) and (AY >= FScaledOtstup) and
        (AY <= Height - FScaledOtstup) then
        Exit(i);
    end;

end;

procedure THolstImage.MouseMove(Shift: TShiftState; X: integer; Y: integer);
var
  iTextOffsetX, iTextOffSetY: integer;
begin
  Draw;
  inherited;

  if FShowCoordinates then
  begin
    FPos := Point(X, Y);

    Canvas.Pen.Style := psDash;
    Canvas.Pen.Width := 1;
    Canvas.Pen.Mode := pmCopy;
    Canvas.Pen.Color := clGreen;
    Canvas.Font.Size := 6;

    // ось X
    Canvas.MoveTo(-Left, Y);
    Canvas.LineTo(-Left + Parent.ClientWidth, Y);
    // ось Y
    Canvas.MoveTo(X, -Top);
    Canvas.LineTo(X, -Top + Parent.ClientHeight);
    // рисуем текст
    if (X > BoundsRect.Left + FScaledOtstup + 15) and
      (X > BoundsRect.Right - FScaledOtstup - 15) then
      iTextOffsetX := -15
    else
      iTextOffsetX := 15;

    if (Y > BoundsRect.Top + FScaledOtstup + 15) and
      (Y > BoundsRect.Bottom - FScaledOtstup - 15) then
      iTextOffSetY := -15
    else
      iTextOffSetY := 15;

    Canvas.Font.Color := clRed;
    Canvas.TextOut(X + iTextOffsetX, Y + iTextOffSetY, inttostr(FPos.X) + ':' +
      inttostr(FPos.Y));
  end;
end;

procedure THolstImage.MoveToolMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X: integer; Y: integer);
var
  RectangleIndex: integer;
  TempRectangle: TCustomRectangle;
  i: integer;
begin
  if Button = mbLeft then
  BEGIN

    if (FRectangles.Count > 0) then
    begin

      // Двигание прямоугольных примитивов
      RectangleIndex := GetRectangleAt(X, Y);
      if RectangleIndex > -1 then
      begin
        FDragOffset.X := X - FRectangles[RectangleIndex].FLeft;
        FDragOffset.Y := Y - FRectangles[RectangleIndex].FTop;
        TempRectangle := FRectangles[RectangleIndex];
        for i := RectangleIndex to FRectangles.Count - 2 do
          FRectangles[i] := FRectangles[i + 1];
        FRectangles[FRectangles.Count - 1] := TempRectangle;
      end;
      FActiveRectangleIndex := RectangleIndex;

      // сохранение старой позиции прямоугольных примитивов
      // FNewRectanglePosRect.Left := FRectangles[FRectangles.Count - 1].FLeft;
      // FNewRectanglePosRect.Top := FRectangles[FRectangles.Count - 1].FTop;
      // FNewRectanglePosRect.Right := FRectangles[FRectangles.Count - 1].FRight;
      // FNewRectanglePosRect.Bottom := FRectangles[FRectangles.Count - 1].FBottom;

    end;

  END;
end;

procedure THolstImage.MoveToolMouseMove(Sender: TObject; Shift: TShiftState;
  X: integer; Y: integer);
var
  i: integer;
  bInterSects, bOuterSects, doDrag: boolean;
begin
  FNewRectanglePosRect.Left := X - FDragOffset.X;
  FNewRectanglePosRect.Top := Y - FDragOffset.Y;
  FNewRectanglePosRect.Right := FNewRectanglePosRect.Left +
    round(FRectangles[FRectangles.Count - 1].FScaledWidth);
  FNewRectanglePosRect.Bottom := FNewRectanglePosRect.Top +
    round(FRectangles[FRectangles.Count - 1].FScaledHeight);

  // двигание прямогоугольных примитивов
  if (ssLeft in Shift) then
  begin

    if (FRectangles.Count > 0) and (FActiveRectangleIndex > -1) then
    begin
      // Проверка на пересечение прямоугольников
      for i := 0 to FRectangles.Count - 2 do
      begin
        bInterSects := not System.Types.InterSectRect(FNewRectanglePosRect,
          Rect(FRectangles[i].FLeft, FRectangles[i].FTop, FRectangles[i].FRight,
          FRectangles[i].FBottom));

        if bInterSects = false then
          break;
      end;
      if FRectangles.Count = 1 then
        bInterSects := true;

      bOuterSects := OuterSectsContur(FNewRectanglePosRect, ClientRect);

      // doDrag := (bInterSects and bOuterSects);
      doDrag := bOuterSects;

      if doDrag then
      begin
        FRectangles[FRectangles.Count - 1].FLeft := FNewRectanglePosRect.Left;
        FRectangles[FRectangles.Count - 1].FTop := FNewRectanglePosRect.Top;
        FRectangles[FRectangles.Count - 1].FRight := FNewRectanglePosRect.Right;
        FRectangles[FRectangles.Count - 1].FBottom :=
          FNewRectanglePosRect.Bottom;
        if FRectangles[FRectangles.Count - 1].FResizable then
          FRectangles[FRectangles.Count - 1].SetResizeBoundaries;

      end;

      Draw;
    end;
  end;

end;

procedure THolstImage.MoveToolMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X: integer; Y: integer);
var
//  i: integer;
  leftpos, toppos: integer;
begin
  // Двигание прямоугольных примитивов
  if (FRectangles.Count > 0) then
  begin
    // Сохранение позиции Left Top для прямоугольника
    leftpos := round((FRectangles[FRectangles.Count - 1].FLeft) / FScale);
    toppos := round((FRectangles[FRectangles.Count - 1].FTop) / FScale);
    FRectangles[FRectangles.Count - 1].FLeftotstup := leftpos;
    FRectangles[FRectangles.Count - 1].FTopOtstup := toppos;

    FActiveRectangleIndex := -1;
    // Draw;
  end;

end;

procedure THolstImage.ResizeToolMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X: integer; Y: integer);
begin
  FShowContur := FResizeMode <> rmNoMode;
end;

procedure THolstImage.ResizeToolMouseMove(Sender: TObject; Shift: TShiftState;
  X: integer; Y: integer);
var
//  i: integer;
  newWidth, newHeight: double;
begin

  // рисуем контурный Препрямоугольник  ресайза
  if (FShowContur) and (ssLeft in Shift) then
  begin
    with FRectangles[FActiveRectangleIndex] do
      case FResizeMode of
        rmUpperLeft:
          begin
            newWidth := RoundTo((FRight - X) / FScale, -2) / 1000;
            newHeight := RoundTo((FBottom - Y) / FScale, -2) / 1000;
            if (newWidth > ResizeLimit) and (newHeight > ResizeLimit) then
            begin
              FConturRect.Left := X;
              FConturRect.Top := Y;
              FConturRect.Right := FRight;
              FConturRect.Bottom := FBottom;
            end;
            Draw;
          end;
        rmUpperRight:
          begin
            newWidth := RoundTo((X - FLeft) / FScale, -2) / 1000;
            newHeight := RoundTo((FBottom - Y) / FScale, -2) / 1000;
            if (newWidth > ResizeLimit) and (newHeight > ResizeLimit) then
            begin
              FConturRect.Left := FLeft;
              FConturRect.Top := FBottom;
              FConturRect.Right := X;
              FConturRect.Bottom := Y;
            end;
            Draw;
          end;
        rmLowerLeft:
          begin
            newWidth := RoundTo((FRight - X) / FScale, -2) / 1000;
            newHeight := RoundTo((Y - FTop) / FScale, -2) / 1000;
            if (newWidth > ResizeLimit) and (newHeight > ResizeLimit) then
            begin
              FConturRect.Left := X;
              FConturRect.Top := FTop;
              FConturRect.Right := FRight;
              FConturRect.Bottom := Y;
            end;
            Draw;
          end;
        rmLowerRight:
          begin
            newWidth := RoundTo((X - FLeft) / FScale, -2) / 1000;
            newHeight := RoundTo((Y - FTop) / FScale, -2) / 1000;
            if (newWidth > ResizeLimit) and (newHeight > ResizeLimit) then
            begin
              FConturRect.Left := FLeft;
              FConturRect.Top := FTop;
              FConturRect.Right := X;
              FConturRect.Bottom := Y;
            end;
            Draw;
          end;
         rmMiddleLeft: begin
            newWidth := RoundTo((FRight - X) / FScale, -2) / 1000;
            newHeight := Self.Height; // не меняется
            if (newWidth > ResizeLimit) and (newHeight > ResizeLimit) then
            begin
              FConturRect.Left := X;
              FConturRect.Top := FTop;
              FConturRect.Right := FRight;
              FConturRect.Bottom := FBottom;
            end;
            Draw;
         end;
         rmMiddleRight: begin
            newWidth := RoundTo((X - FLeft) / FScale, -2) / 1000;
            newHeight := Self.Height; // не меняется
            if (newWidth > ResizeLimit) and (newHeight > ResizeLimit) then
            begin
              FConturRect.Left := FLeft;
              FConturRect.Top := FTop;
              FConturRect.Right := X;
              FConturRect.Bottom := FBottom;
            end;
         end;
      end;
    Exit;
  end;

  // if FResizeMode=rmNoMode then
  FActiveRectangleIndex := GetRectangleAt(X, Y);

  if (FActiveRectangleIndex > -1) and FRectangles[FActiveRectangleIndex].FResizable
  then
  begin

    with FRectangles[FActiveRectangleIndex] do
    begin

      if (X >= FupperLeft.FLeft) and (X <= FupperLeft.FRight) and
        (Y >= FupperLeft.FTop) and (Y <= FupperLeft.FBottom) then
      begin
        Cursor := crSizeNWSE;
        FResizeMode := rmUpperLeft;
      end
      else if (X >= FupperRight.FLeft) and (X <= FupperRight.FRight) and
        (Y >= FupperRight.FTop) and (Y <= FupperRight.FBottom) then
      begin
        Cursor := crSizeNESW;
        FResizeMode := rmUpperRight;
      end
      else if (X >= FLowerLeft.FLeft) and (X <= FLowerLeft.FRight) and
        (Y >= FLowerLeft.FTop) and (Y <= FLowerLeft.FBottom) then
      begin
        Cursor := crSizeNESW;
        FResizeMode := rmLowerLeft;
      end
      else if (X >= FLowerRight.FLeft) and (X <= FLowerRight.FRight) and
        (Y >= FLowerRight.FTop) and (Y <= FLowerRight.FBottom) then
      begin
        Cursor := crSizeNWSE;
        FResizeMode := rmLowerRight;
      end
      else if (X >= FMiddleLeft.FLeft) and (X <= FMiddleLeft.FRight) and
        (Y >= FMiddleLeft.FTop) and (Y <= FMiddleLeft.FBottom) then
      begin
        Cursor := crSizeWE;
        FResizeMode := rmMiddleLeft;
      end
      else if (X >= FMiddleRight.FLeft) and (X <= FMiddleRight.FRight) and
        (Y >= FMiddleRight.FTop) and (Y <= FMiddleRight.FBottom) then
      begin
        Cursor := crSizeWE;
        FResizeMode := rmMiddleRight;
      end

      else
        Cursor := crArrow;

    end
  end
  else
  begin
    Cursor := crArrow;
    FResizeMode := rmNoMode;
  end;

end;

procedure THolstImage.ResizeToolMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X: integer; Y: integer);
var
  newWidth, newHeight: double;
//  i: integer;
begin

  if FActiveRectangleIndex > -1 then
  begin

    with FRectangles[FActiveRectangleIndex] do
    begin

      case FResizeMode of
        rmUpperLeft:
          begin
            if (Button = mbLeft) then
            begin
              FResizeMode := rmNoMode;

              newWidth := RoundTo((FRight - X) / FScale, -2) / 1000;
              newHeight := RoundTo((FBottom - Y) / FScale, -2) / 1000;

              if ((newWidth > ResizeLimit) and (newHeight > ResizeLimit)) then
              begin

                FLeft := X;
                FTop := Y;

                OriginalWidth := newWidth;
                OriginalHeight := newHeight;

                SetResizeBoundaries;
              end;

            end;
          end;
        rmUpperRight:
          begin
            if Button = mbLeft then
            begin
              FResizeMode := rmNoMode;

              newWidth := RoundTo((X - FLeft) / FScale, -2) / 1000;
              newHeight := RoundTo((FBottom - Y) / FScale, -2) / 1000;

              if ((newWidth > ResizeLimit) and (newHeight > ResizeLimit)) then
              begin

                FTop := Y;
                FRight := X;

                OriginalWidth := newWidth;
                OriginalHeight := newHeight;

                SetResizeBoundaries;
              end;
            end;
          end;
        rmLowerLeft:
          begin
            if Button = mbLeft then
            begin
              FResizeMode := rmNoMode;

              newWidth := RoundTo((FRight - X) / FScale, -2) / 1000;
              newHeight := RoundTo((Y - FTop) / FScale, -2) / 1000;

              if ((newWidth > ResizeLimit) and (newHeight > ResizeLimit)) then
              begin

                FLeft := X;
                FBottom := Y;

                OriginalWidth := newWidth;
                OriginalHeight := newHeight;

                SetResizeBoundaries;
              end;
            end;
          end;
        rmLowerRight:
          begin
            if Button = mbLeft then
            begin
              FResizeMode := rmNoMode;

              newWidth := RoundTo((X - FLeft) / FScale, -2) / 1000;
              newHeight := RoundTo((Y - FTop) / FScale, -2) / 1000;

              if ((newWidth > ResizeLimit) and (newHeight > ResizeLimit)) then
              begin

                FRight := X;
                FBottom := Y;

                OriginalWidth := newWidth;
                OriginalHeight := newHeight;

                SetResizeBoundaries;
              end;
            end;
          end;
          rmMiddleLeft: begin
            if Button = mbLeft then
            begin
              FResizeMode := rmNoMode;
              newWidth := RoundTo((FRight - X) / FScale, -2) / 1000;
              if (newWidth > ResizeLimit) then
              begin
                FLeft := X;
                OriginalWidth := newWidth;
                SetResizeBoundaries;
              end;
            end
          end;
          rmMIddleRight: begin
            if Button = mbLeft then
            begin
              FResizeMode := rmNoMode;
              newWidth := RoundTo((X - FLeft) / FScale, -2) / 1000;
              if (newWidth > ResizeLimit) then
              begin
                FRight := X;
                OriginalWidth := newWidth;
                SetResizeBoundaries;
              end;
            end
          end;
      end;

      FShowContur := false;
      Draw;
    end;
  end
  else
  begin
    FResizeMode := rmNoMode;
    FActiveRectangleIndex := GetRectangleAt(X, Y);
  end;

end;

procedure THolstImage.CutLineToolMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X: integer; Y: integer);
var
  CustomLine:TCustomCutLine;
  toppos:integer;
begin

  if (ssLeft in Shift) then
    if (Y >= FScaledOtstup) and (Y <= Height - FScaledOtstup) then
    begin
      //FCutLines.Add(Point(FScaledOtstup, Y));   // Убрано , т.к. создание идет через основную форму ивзне

      CustomLine:=FCutLines.Add(Point(FScaledOtstup, Y));
      //ОТправляем сообщению frm_main (родителю чтобы заполнить TListBox)
      //toppos:=round((Y-FScaledOtstup)/FScale);
      toppos:=round(Y/FScale); 
      FCutLines[FCutLines.Count - 1].FTopOtstup := toppos; 
      //PostMessage(Self.Parent.Parent.Handle,WM_ADDCUTLINE_MSG,0,0);
      PostMessage(Self.Parent.Parent.Handle,WM_ADDCUTLINE_MSG,longInt(toppos),0);
      
      FConturLine.X := 0;
      FConturLine.Y := 0;
      // Draw;
    end

end;

procedure THolstImage.CutLineToolMouseMove(Sender: TObject; Shift: TShiftState;
  X: integer; Y: integer);

begin

  if (Y >= FScaledOtstup) and (Y <= Height - FScaledOtstup) and
    (X >= FScaledOtstup) and (X <= Width - FScaledOtstup) then
  begin
    FConturLine.Y := Y;
    Draw;
  end
  else
  begin
    FConturLine.X := 0;
    FConturLine.Y := 0;
    // Draw;
  end;

end;

procedure THolstImage.CutLineToolMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X: integer; Y: integer);
//var
//  doDrag: boolean;
//  toppos: integer;
begin
  //toppos := round((FCutLines[FCutLines.Count - 1].FBeginPoint.Y) / FScale);
//  toppos:=round(Y/FScale);
//  FCutLines[FCutLines.Count - 1].FTopOtstup := toppos;
  {SendMessage(TWinControl(Sender).Parent.Parent.Handle, WM_MY_MESSAGE, longInt(toppos), 0);  // отправляем сообщение экземпляру объекта  Tfrm_main  - frm_main
  }
  //PostMessage(Self.Parent.Parent.Handle,WM_ADDCUTLINE_MSG,0,0);
end;

procedure THolstImage.MoveCutLineToolMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X: integer; Y: integer);
var
  CutLineIndex: integer;
  tempCutLine: TCustomCutLine;
  i: integer;
begin
  if Button = mbLeft then
  begin

    if FCutLines.Count > 0 then
    begin

      CutLineIndex := GetCutLineAt(X, Y);
      if CutLineIndex <> -1 then
      begin
        tempCutLine := FCutLines[CutLineIndex];
        for i := CutLineIndex to FCutLines.Count - 2 do
          FCutLines[i] := FCutLines[i + 1];
        FCutLines[FCutLines.Count - 1] := tempCutLine;
        FActiveCutLineIndex := CutLineIndex;

        // сохранение старой позиции линии отреза
        FOldCutLinePos := FCutLines[FCutLines.Count - 1].FBeginPoint;

      end
      else
        FActiveCutLineIndex := -1;
    end;

  end;
end;

procedure THolstImage.MoveCutLineToolMouseMove(Sender: TObject;
  Shift: TShiftState; X: integer; Y: integer);
begin
  // двигание линий отреза
  if FCutLines.Count > 0 then
  begin

    if (ssLeft in Shift) and (FActiveCutLineIndex > -1) then
    begin
      FConturLine.Y := Y;

    end;
    // Draw;
  end;
end;

procedure THolstImage.MoveCutLineToolMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X: integer; Y: integer);
var
  doDrag: boolean;
  old_toppos,toppos: integer;
begin
  // Двигание линий отреза

  if FCutLines.Count > 0 then
  begin

    FCutLines[FCutLines.Count - 1].FBeginPoint.Y := Y;

    old_toppos:=FCutLines[FCutLines.Count - 1].FTopOtstup;
    toppos := round((FCutLines[FCutLines.Count - 1].FBeginPoint.Y) / FScale);
    FCutLines[FCutLines.Count - 1].FTopOtstup := toppos;

    // Проверка выхода за пределы холста
    doDrag := (Y >= FScaledOtstup) and (Y <= Height - FScaledOtstup);
    // Проверка на пересечение линий отреза

    // ! Предусмотреть лимит к которому не приблизятся две линии отреза
    // for i := 0 to FCutLines.Count-2 do begin
    // if (Y<=FCutLines[i].FBeginPoint.Y-10) and (Y>=FCutLines[i].FBeginPoint.Y+10) then begin         //10 подобрано (изменить !!!)
    // doDrag:=false;
    // break;
    // end;
    //
    // end;

    if doDrag = false then
    begin
      FCutLines[FCutLines.Count - 1].FBeginPoint := FOldCutLinePos;
      FCutLines[FCutLines.Count - 1].FTopOtstup :=old_toppos;
    end;

    FActiveCutLineIndex := -1;
    FShowContur := false;
    FConturLine.X := 0;
    FConturLine.Y := 0;
    // Draw;
  end;

end;


procedure THolstImage.VertCutLineToolMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
var
  CustomVertLine:TCustomVertCutLine;
  leftpos:integer;
begin

  if (ssLeft in Shift) then
    if (X >= FScaledOtstup) and (X <= Width - FScaledOtstup) then
    begin

      CustomVertLine:=FVertCutLines.Add(Point(X,FScaledOtstup));
      //ОТправляем сообщению frm_main (родителю чтобы заполнить TListBox)
      //leftpos:=round((X-FScaledOtstup)/FScale);
      leftpos:=round(X/FScale);
      FVertCutLines[FVertCutLines.Count - 1].FLeftOtstup := leftpos;
      //PostMessage(Self.Parent.Parent.Handle,WM_ADDCUTLINE_MSG,0,0);
      PostMessage(Self.Parent.Parent.Handle,WM_ADDVERTCUTLINE_MSG,longInt(leftpos),0);

      FVertConturLine.X := 0;
      FVertConturLine.Y := 0;
      // Draw;
    end
end;

procedure THolstImage.VertCutLineToolMouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: integer);

begin

  if (Y >= FScaledOtstup) and (Y <= Height - FScaledOtstup) and
    (X >= FScaledOtstup) and (X <= Width - FScaledOtstup) then
  begin
    FVertConturLine.X := X;
    Draw;
  end
  else
  begin
    FVertConturLine.X := 0;
    FVertConturLine.Y := 0;
    // Draw;
  end;
end;

procedure THolstImage.VertCutLineToolMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
begin
  //
end;

procedure THolstImage.MoveVertCutLineToolMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
var
  VertCutLineIndex: integer;
  tempVertCutLine: TCustomVertCutLine;
  i: integer;
begin
  if Button = mbLeft then
  begin

    if FVertCutLines.Count > 0 then
    begin

      VertCutLineIndex := GetVertCutLineAt(X, Y);
      if VertCutLineIndex <> -1 then
      begin
        tempVertCutLine := FVertCutLines[VertCutLineIndex];
        for i := VertCutLineIndex to FVertCutLines.Count - 2 do
          FVertCutLines[i] := FVertCutLines[i + 1];
        FVertCutLines[FVertCutLines.Count - 1] := tempVertCutLine;
        FActiveCutLineIndex := VertCutLineIndex;

        // сохранение старой позиции линии отреза
        FOldCutLinePos := FVertCutLines[FVertCutLines.Count - 1].FBeginPoint;

      end
      else
        FActiveCutLineIndex := -1;
    end;

  end;
end;

procedure THolstImage.MoveVertCutLineToolMouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: integer);
begin
   // двигание линий отреза
  if FVertCutLines.Count > 0 then
  begin

    if (ssLeft in Shift) and (FActiveCutLineIndex > -1) then
    begin
      FVertConturLine.X := X;

    end;
    // Draw;
  end;
end;


procedure THolstImage.MoveVertCutLineToolMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
var
  doDrag: boolean;

  old_leftpos,leftpos: integer;
begin
  // Двигание линий отреза

  if FVertCutLines.Count > 0 then
  begin

    FVertCutLines[FVertCutLines.Count - 1].FBeginPoint.X := X;

    old_leftpos:=FVertCutLines[FVertCutLines.Count - 1].FLeftOtstup;
    leftpos := round((FVertCutLines[FVertCutLines.Count - 1].FBeginPoint.X) / FScale);
    FVertCutLines[FVertCutLines.Count - 1].FLeftOtstup := leftpos;

    // Проверка выхода за пределы холста
    doDrag := (X >= FScaledOtstup) and (X <= Width - FScaledOtstup);
    // Проверка на пересечение линий отреза

    // ! Предусмотреть лимит к которому не приблизятся две линии отреза
    // for i := 0 to FCutLines.Count-2 do begin
    // if (Y<=FCutLines[i].FBeginPoint.Y-10) and (Y>=FCutLines[i].FBeginPoint.Y+10) then begin         //10 подобрано (изменить !!!)
    // doDrag:=false;
    // break;
    // end;
    //
    // end;

    if doDrag = false then
    begin
      FVertCutLines[FVertCutLines.Count - 1].FBeginPoint := FOldCutLinePos;
      FVertCutLines[FVertCutLines.Count - 1].FLeftOtstup := old_leftpos;
    end;

    FActiveCutLineIndex := -1;
    FShowContur := false;
    FVertConturLine.X := 0;
    FVertConturLine.Y := 0;
    Draw;
  end;
end;

// Вычисляет высоту холста по самому нижнему прямоугольнику
procedure THolstImage.AutoCalcOriginalHeight;
var
  i:integer;
  maxrectanglebottom:integer;

begin
   maxrectanglebottom:=-1;
  if FRectangles.Count > 0 then
    for i := 0 to FRectangles.Count - 1 do  begin
       if  maxrectanglebottom<FRectangles[i].FBottom then
         maxrectanglebottom:=FRectangles[i].FBottom;
    end;

   OriginalHeight:= RoundTo((maxrectanglebottom-FScaledOtstup)/1000/FScale,-2);

end;

procedure THolstImage.CreateRandomRectangles;
var
  i: integer;
  rectanglesAr: array [0 .. 11] of TRectangleData;
  TempRectangle: TCustomRectangle;
  RectangleIndex: integer;
begin

  rectanglesAr[0].ClothName := 'РОЛО (01)';
  rectanglesAr[0].OrderName := 'Заказ Покупателя №1';
  rectanglesAr[0].Width := 4;
  rectanglesAr[0].Height := 1.50;

  rectanglesAr[1].ClothName := 'РОЛО (01)';
  rectanglesAr[1].OrderName := 'Заказ Покупателя №1';
  rectanglesAr[1].Width := 2;
  rectanglesAr[1].Height := 1.5;

  rectanglesAr[2].ClothName := 'РОЛО (02)';
  rectanglesAr[2].OrderName := 'Заказ Покупателя №2';
  rectanglesAr[2].Width := 2.5;
  rectanglesAr[2].Height := 2;

  rectanglesAr[3].ClothName := 'РОЛО (03)';
  rectanglesAr[3].OrderName := 'Заказ Покупателя №3';
  rectanglesAr[3].Width := 2.6;
  rectanglesAr[3].Height := 2;

  rectanglesAr[4].ClothName := 'РОЛО (03)';
  rectanglesAr[4].OrderName := 'Заказ Покупателя №3';
  rectanglesAr[4].Width := 1;
  rectanglesAr[4].Height := 2;

  rectanglesAr[5].ClothName := 'РОЛО (03)';
  rectanglesAr[5].OrderName := 'Заказ Покупателя №3';
  rectanglesAr[5].Width := 1;
  rectanglesAr[5].Height := 3;

  rectanglesAr[6].ClothName := 'РОЛО (03)';
  rectanglesAr[6].OrderName := 'Заказ Покупателя №3';
  rectanglesAr[6].Width := 2.6;
  rectanglesAr[6].Height := 3;

  rectanglesAr[7].ClothName := 'РОЛО (03)';
  rectanglesAr[7].OrderName := 'Заказ Покупателя №3';
  rectanglesAr[7].Width := 2.4;
  rectanglesAr[7].Height := 1.8;

  rectanglesAr[8].ClothName := 'РОЛО (03)';
  rectanglesAr[8].OrderName := 'Заказ Покупателя №3';
  rectanglesAr[8].Width := 2.4;
  rectanglesAr[8].Height := 1.6;

  rectanglesAr[9].ClothName := 'РОЛО (03)';
  rectanglesAr[9].OrderName := 'Заказ Покупателя №3';
  rectanglesAr[9].Width := 2.1;
  rectanglesAr[9].Height := 2;

  rectanglesAr[10].ClothName := 'РОЛО (03)';
  rectanglesAr[10].OrderName := 'Заказ Покупателя №3';
  rectanglesAr[10].Width := 1.5;
  rectanglesAr[10].Height := 2;

  rectanglesAr[11].ClothName := 'РОЛО (03)';
  rectanglesAr[11].OrderName := 'Заказ Покупателя №3';
  rectanglesAr[11].Width := 2.4;
  rectanglesAr[11].Height := 1.6;

  for i := 0 to 11 do
  begin
    RectangleIndex := Rectangles.Add(rectanglesAr[i].ClothName,
      rectanglesAr[i].OrderName, rectanglesAr[i].Width, rectanglesAr[i].Height);
    Rectangles[RectangleIndex].Scale := FScale;
    Rectangles[RectangleIndex].FResizable := false;
    Rectangles[RectangleIndex].FLeft := Rectangles[RectangleIndex].FLeft +
      FScaledOtstup;
    Rectangles[RectangleIndex].FTop := Rectangles[RectangleIndex].FTop +
      FScaledOtstup;
    Rectangles[RectangleIndex].FRight := Rectangles[RectangleIndex].FRight +
      FScaledOtstup;
    Rectangles[RectangleIndex].FBottom := Rectangles[RectangleIndex].FBottom +
      FScaledOtstup;
  end;

  // TempRectangle := Rectangles.Add();
  // TempRectangle.FResizable := true;
  //
  // TempRectangle.Scale := FScale;
  // TempRectangle.SetResizeBoundaries;
  //
  // TempRectangle := Rectangles.Add();
  // TempRectangle.FResizable := true;
  // TempRectangle.Scale := FScale;
  // TempRectangle.SetResizeBoundaries;
end;

/// /Возвращает True если Rect не пересекаются
// function THolstImage.InterSects(Rect1,Rect2:TCustomRectangle):boolean;
// var
// x1,y1,x2,y2,x3,y3,x4,y4:integer;
// begin
// x1:=Rect1.FLeft;
// y1:=Rect1.FTop;
// x2:=Rect1.FRight;
// y2:=Rect1.FBottom;
// x3:=Rect2.FLeft;
// y3:=Rect2.FTop;
// x4:=Rect2.FRight;
// y4:=Rect2.FBottom;
// //Result:= (y1<y4) or (y2>y3) or (x2<x3) or (x1>x4);
// result:= (x1<=x4) and (x2>=x3) and (y1<=y4) and (y2>=y3);
//
// end;


// Возвращает True если не пересекает границы
// function THolstImage.OuterSects(Rect1:TCustomRectangle;Rect:TRect): boolean;
// var
// x1,y1,x2,y2,x3,y3,x4,y4:integer;
// begin
// //Rect1 не вылезал за пределы Rect
// x1:=Rect1.FLeft;
// y1:=Rect1.FTop;
// x2:=Rect1.FRight;
// y2:=Rect1.FBottom;
// x3:=Rect.Left+FScaledOtstup;
// y3:=Rect.Top+FScaledOtstup;
// x4:=Rect.Right-FScaledOtstup;
// y4:=Rect.Bottom-FScaledOtstup;
// Result:= (x1>=x3) and (x2<=x4) and (y1>=y3) and (y2<=y4);
// end;




// function THolstImage.InterSectsContur(Rect:TRect;Rect1:TCustomRectangle):boolean;
// var
// x1,y1,x2,y2,x3,y3,x4,y4:integer;
// begin
// x1:=Rect.Left;
// y1:=Rect.Top;
// x2:=Rect.Right;
// y2:=Rect.Bottom;
//
// x3:=Rect1.FLeft;
// y3:=Rect1.FTop;
// x4:=Rect1.FRight;
// y4:=Rect1.FBottom;
//
// result:= (x1<=x4) and (x2>=x3) and  (y1<=y4) and (y2>=y3);
// end;

function THolstImage._IntersectRect(const Rect1, Rect2: TRect): boolean;
begin
  Result:= (Rect1.Left <= Rect2.Right) and (Rect1.Right >= Rect2.Left) and
    (Rect1.Top <= Rect2.Bottom) and (Rect1.Bottom >= Rect2.Top);
end;

// Возвращает True если не пересекает границы
function THolstImage.OuterSectsContur(Rect1: TRect; Rect2: TRect): boolean;
var
  x1, y1, x2, y2, x3, y3, x4, y4: integer;
begin
  // Rect1 не вылезал за пределы Rect2
  x1 := Rect1.Left;
  y1 := Rect1.Top;
  x2 := Rect1.Right;
  y2 := Rect1.Bottom;
  x3 := Rect2.Left + FScaledOtstup;
  y3 := Rect2.Top + FScaledOtstup;
  x4 := Rect2.Right - FScaledOtstup;
  y4 := Rect2.Bottom - FScaledOtstup;
  Result := (x1 >= x3) and (x2 <= x4) and (y1 >= y3) and (y2 <= y4);
end;

procedure THolstImage.ReCalcLeftTopPositionForRectangles;
// Для того чтобь присвоить значения для FleftOtstup и FTopOtstup для форм которые не двигали
var
  i: integer;
  leftpos, toppos: integer;
begin
  if FRectangles.Count > 0 then
    for i := 0 to FRectangles.Count - 1 do
    begin
      leftpos := round((FRectangles[i].FLeft) / FScale);
      toppos := round((FRectangles[i].FTop) / FScale);
      FRectangles[i].FLeftotstup := leftpos;
      FRectangles[i].FTopOtstup := toppos;
    end;

end;


procedure THolstImage.serializeSchema;
var
  json,jsonRectangle,jsonCutline,jsonVertCutLine,jsonNested: TJsonObject;
  jsonRectangles,jsonCutlines,jsonVertCutLines: TJSONArray;
  i:integer;

begin

   json:= TJSONObject.Create;

   json.AddPair('OriginalHeight',TJsonNumber.Create(FOriginalHeight));

  if FRectangles.Count>0 then begin

    jsonRectangles:= TJSOnArray.Create;

    for i := 0 to FRectangles.FCount-1 do begin

      
       jsonRectangle:= TJSONObject.Create;
       jsonRectangle.AddPair('FLeftOtstup',TJsonNumber.create(FRectangles[i].FLeftotstup));
       jsonRectangle.AddPair('FTopOtstup',TJsonNumber.Create(FRectangles[i].FTopOtstup));
       jsonRectangle.AddPair('FName',FRectangles[i].FName);
       jsonRectangle.AddPair('FResizable',TJSONBool.Create(FRectangles[i].FResizable));
       jsonRectangle.AddPair('FRotated',TJsonBool.Create(FRectangles[i].FRotated));
       jsonRectangle.AddPair('FrectangleType',TJsonNumber.Create(ord(FRectangles[i].FrectangleType)));

       jsonNested:= TJSONObject.Create;
       jsonNested.AddPair('Clothname',FRectangles[i].FRectangleData.ClothName);
       jsonNested.AddPair('Ordername',FRectangles[i].FRectangleData.OrderName);
       jsonNested.AddPair('Width',TJSONNumber.Create(FRectangles[i].FRectangleData.Width));
       jsonNested.AddPair('Height',TJsonNumber.Create(FRectangles[i].FRectangleData.Height));
       jsonRectangle.AddPair('FRectangleData',jsonNested);
       //jsonNested.Free;

       jsonRectangles.AddElement(jsonRectangle);
    end;

    json.AddPair('rectangles',jsonRectangles);
    //jsonRectangles.Free;
  end;

  if FCutLines.FCount>0 then begin
      jsonCutlines:=TJSONArray.Create;

      for i:= 0 to FCutLines.FCount-1 do begin
         jsonCutline:= TJSONObject.Create;
         //jsonCutline.AddPair('FScale',TJsonNumber.Create(FCutLines[i].FScale));
         jsonCutline.AddPair('FName',FCutLines[i].FName);
         jsonCutline.AddPair('FTopOtstup',TJSONNumber.Create(FCutLines[i].FTopOtstup)); // основная информация для сохранения , остальное не нужно

         jsonCutlines.AddElement(jsonCutline);
         //jsonCutline.Destroy;
      end;

      json.AddPair('cutlines',jsonCutlines);
     // jsonCutlines.Destroy;
  end;


  if FVertCutLines.FCount>0 then begin
      jsonVertCutLines:=TJSONArray.Create;

      for I:= 0 to FVertCutLines.FCount-1 do begin
         jsonVertCutLine:= TJSONObject.Create;
         jsonVertCutLine.AddPair('FScale',TJSONNumber.Create(FVertCutLines[i].FScale));
         jsonVertCutLine.AddPair('FName',FVertCutLines[i].FName);
         jsonVertCutLine.AddPair('FLeftOtstup',TJsonNUmber.Create(FVertCutLines[i].FLeftOtstup));

         jsonVertCutLines.AddElement(jsonVertCutline);
         //jsonVertCutLines.Destroy;
      end;

      json.AddPair('vertcutlines',jsonVertCutlines);
      //jsonCutlines.Destroy;
  end;

  FSerializedSchema:=json.ToJson;


  FreeAndNil(json);

end;


procedure THolstImage.UnSerializeSchema();
var
  jsonValue,jsonRectangleValue,jsonOriginalHeight:TJSONValue;
  i:integer;
  json_Rectangles,
  json_cutlines,
  json_vertcutlines:TJsonArray;
  rectangle:TCustomRectangle;
  point: TPoint;
  cutline:TCustomCutLine;
  vertcutline:TCustomVertCutLine;
  topOtstup,leftOtstup : integer;

begin

   jsonValue:=TJSONObject.ParseJSONValue(FSerializedSchema) as TJsonObject;

   if jsonValue.TryGetValue('OriginalHeight',jsonOriginalHeight) then begin
      OriginalHeight:=StrToFloat(jsonOriginalHeight.Value);
      FreeAndNil(jsonOriginalHeight);
   end;


   if jsonValue.TryGetValue('rectangles',json_Rectangles) and (json_rectangles.Count>0) then begin
      for i := 0 to json_Rectangles.Count-1 do begin

         rectangle:=Frectangles.Add();
         jsonRectangleValue:=json_Rectangles.Items[i].GetValue<TJSONObject>('FRectangleData');
         with rectangle.FRectangleData do begin
            ClothName:= jsonRectangleValue.GetValue<string>('Clothname');
            OrderName:= jsonRectangleValue.GetValue<string>('Ordername');
            Width:=     jsonRectangleValue.GetValue<Double>('Width');
            Height:=    jsonRectangleValue.GetValue<Double>('Height');
         end;

         rectangle.Name:=                   json_rectangles.Items[i].GetValue<string>('FName');
         rectangle.FLeftotstup:=            json_Rectangles.Items[i].GetValue<Integer>('FLeftOtstup');
         rectangle.FTopOtstup:=             json_Rectangles.Items[i].GetValue<Integer>('FTopOtstup');
         rectangle.FLeft:=                  round(rectangle.FLeftotstup*FScale);
         rectangle.FTop:=                   round(rectangle.FTopOtstup*FScale);
         rectangle.FResizable:=             json_Rectangles.Items[i].GetValue<Boolean>('FResizable');
         rectangle.FRotated:=               json_Rectangles.Items[i].GetValue<Boolean>('FRotated');
         rectangle.FrectangleType:=         TRectangleType(json_Rectangles.Items[i].GetValue<Integer>('FrectangleType'));
         rectangle.Scale:=                  FScale;  // здесь идет расчет FRight и FBottom

         //FreeAndNil(jsonRectangleValue);
      end;
   end;

   if jsonValue.TryGetValue('cutlines',json_cutlines) and (json_cutlines.Count>0) then begin
     for i:=0 to json_cutlines.Count-1 do begin


        topOtstup:=json_cutlines.Items[i].GetValue<Integer>('FTopOtstup');
        point:=TPoint.Create(FScaledOtstup,round(topOtstup * FScale));
        cutline:= FCutLines.Add(point);
        cutline.FName:= json_cutlines.Items[i].GetValue<string>('FName') ;
        cutline.FTopOtstup:=topOtstup; // основная информация
     end;

     //FreeAndNil(json_cutlines);
   end;

   if jsonValue.TryGetValue('vertcutlines',json_vertcutlines) and (json_vertcutlines.Count>0)  then begin
      for i := 0 to json_vertcutlines.Count-1 do  begin

        leftOtstup:=json_vertcutlines.Items[i].GetValue<Integer>('FLeftOtstup');
        point:=TPoint.Create(round(leftOtstup * FScale),FScaledOtstup);
        vertcutline:= FVertCutLines.Add(point);
        vertcutline.FName:= json_vertcutlines.Items[i].GetValue<string>('FName') ;
        vertcutline.FLeftOtstup:= leftOtstup;

      end;
      //FreeAndNil(json_vertcutlines);
   end;


   FreeAndNil(jsonValue);

end;

end.
