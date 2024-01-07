{$G+}
unit w_items;
{ David Joffe '94/12 }
{ library of Item objects: see W_ITEM.PAS }

{ Text       }
{ Rectangle  }
{ Choice box }
{ 256Colors  }
{ TextInput  }

interface

uses crt,w_item,uo_obj,graph,ed_data,w_files;

type
  PPalBuf=^TPalBuf;
  TPalBuf=array[0..767] of byte;

var
  PaletteBuffer: PPalBuf;

type
  PText=^TText;
  TText=object(TItem)
    Str: string[80];
    c  : TColor;
    off: TPoint;
    constructor Init(x1,y1,x2,y2,xo,yo: integer; iStr: string; c1,c2: byte);
    procedure SetStr(iStr: string);
    procedure Show; virtual;
  end;

  PRectangle=^TRectangle;
  TRectangle=object(TItem)
    colour: byte;
    constructor Init(x1,y1,x2,y2,c: integer);
    procedure Show; virtual;
  end;

    PChItem=^TChItem;
    TChItem=object
      Str: string;
      next: PChItem;
      constructor Init(iStr: string);
    end;
  PChoice=^TChoice;
  TChoice=object(TItem)
    c : TColor;
    ChCur: integer;
    ChItems: PChItem;
    constructor init(x1,y1,x2,y2,c1,c2,def: integer; ChItemList: PChItem);
    procedure HandleMouse(x,y,b: integer); virtual;
    procedure Show; virtual;
  end;

  P256Colors=^T256Colors;
  T256Colors=object(TItem)
    c: TColor;
    s: TPoint;
    PalFile: TFile;
    constructor init(x,y,sX,sY,c1,c2:integer);
    procedure HandleMouse(x,y,b: integer); virtual;
    procedure LoadPalette;
    procedure SetPalette(iFileName: string);
    procedure Show; virtual;
    procedure ShowColors;
    procedure ReSize(sX,sY: integer);
  end;

  TTextInput=object(TItem)
    Str: string[80];
    c: TColor;
    MaxLen: integer;
{    procedure HandleMouse}
    constructor init(x1,y1,x2,y2,c1,c2,iRetCmd: integer; iStr: string);
    procedure HandleMouse(x,y,b: integer); virtual;
    procedure UpDateStr(WithCursor: boolean);
    procedure Show; virtual;
  end;


function NewText(x1,y1,x2,y2,xo,yo: integer; iStr: string; c1,c2: byte; nextItem: PItem): PItem;
function NewRectangle(x1,y1,x2,y2,c: integer; nextitem: PItem): PItem;
function NewChoiceBox(x1,y1,x2,y2,c1,c2,def: integer; ChItemList: PChItem; nextitem: PItem):PItem;
  function NewChoiceItem(iStr: string; NextChItem: PChItem): PChItem;
  function GetNumChItems(ChItemHead: PChItem): integer;
  function ChItemPtr(ChItemList: PChItem; ChItemNum: integer): PChItem;
function New256Colors(x,y,sX,sY,c1,c2: integer; nextitem: PItem):Pitem;
{grid}

var TempItem: PItem; {for use in construction}

implementation
uses w_mouse,u_useful,u_keys,e_gen;

{== TEXT INPUT LINE ========================================================}
constructor TTextInput.init(x1,y1,x2,y2,c1,c2,iRetCmd: integer; iStr: string);
begin
  TItem.init(x1,y1,x2,y2,iRetCmd);
  c.setcolor(c1,c2);
  Str:=iStr;
  MaxLen:=(r.size.x-20) div 8;
end;
procedure TTextInput.HandleMouse(x,y,b: integer);
  var
      a: Char;
begin
  wMouseHide;

  UpDateStr(true);
  KeyDone;

  a:=#0;
  while (a<>#13) do begin
    if not keypressed then continue;
    a:=readkey;
    if a=#0 then begin {extended key}
      a:=readkey;
      continue;
    end;
    if (a=#8) and (length(Str)=0) then continue;
    if (a=#8) then begin
      Str:=Copy(Str,1,Length(Str)-1);
      UpDateStr(true);
      continue;
    end;
    if (a<#32) then continue;
    if length(Str)>MaxLen then continue; {20=temp}
    Str:=Str+a;
    UpDateStr(true);
  end;
  UpDateStr(false);
  KeyInit(true);
  wMouseShow;
end;
  procedure TTextInput.UpDateStr(WithCursor: boolean);
    var offset:TPoint;
      TStr: string;
  begin
    setfillstyle(1,c.back);
    with r do bar(a.x+1,a.y+1,b.x-1,b.y-1);
    setcolor(c.fore);
    offset.x:=r.a.x+4;
    offset.y:=r.a.y+(r.size.y div 2)-4;
    if WithCursor then TStr:='_ ' else TStr:=' ';
    OutTextXY(offset.x,offset.y,Str+TStr);
  end;
procedure TTextInput.Show;
  var offset: TPoint;
begin
  setfillstyle(1,c.back);
  with r do bar(a.x,a.y,b.x,b.y);
  setcolor(c.fore);
  with r do rectangle(a.x,a.y,b.x,b.y);

  offset.x:=r.a.x+4;
  offset.y:=r.a.y+(r.size.y div 2)-4;
  outtextxy(offset.x,offset.y,Str);
end;
{== 256 COLORS =============================================================}
function New256Colors(x,y,sX,sY,c1,c2: integer; nextitem: PItem):Pitem;
begin
  tempitem:=new(P256Colors, init(x,y,sX,sY,c1,c2));
  tempitem^.next:=nextitem;
  New256Colors:=tempitem;
end;
constructor T256Colors.init(x,y,sX,sY,c1,c2:integer);
begin
  TItem.init(x,y,x+16*sX+52,y+16*sY+4,0);
  c.setColor(c1,c2);
  s.setXY(sX,sY);
  PalFile.init;
end;
procedure T256Colors.HandleMouse(x,y,b: integer);
  var Num: integer;
      Already: boolean;
      TempVP: ViewPortType;
      dumx,dumy,dumb: integer;
begin
{  if PointIn(x,y,r.a.x+2,r.a.y+2,r.a.x+1+16*s.X,r.a.y+1+16*s.Y) then begin}
  if PointIn(x,y,r.a.x+2,r.a.y+2,r.b.x-47,r.b.y-2) then begin
    wMouseHide;
    num:=GetPixel(x,y);
    wMouseShow;
    Already:=false;
    if (b=1) and (c.fore=num) then Already:=true;
    if (b<>1) and (c.back=num) then Already:=true;
    if b=1 then c.fore:=num else c.back:=num;
    if not Already then begin
      wMouseHide;
      ShowColors;
      wMouseShow;
    end;
    delay(10);
  end;
  if PointIn(x,y,r.b.x-45,r.a.y+55,r.b.x-5,r.a.y+65) then begin {GET}
    wMouseHide;
    GetViewSettings(TempVP);
    setcolor(15);
    rectangle(r.b.x-45,r.a.y+55,r.b.x-5,r.a.y+65);
    setViewPort(0,0,GetMaxX,GetMaxY,true);
    wWaitForMouseRelease;
    wMouseShow;
    repeat
      wGetMouse(dumx,dumy,dumb);
    until dumb<>0;
    wMouseHide;
    if dumb=1 then c.fore:=GetPixel(dumx,dumy) else c.back:=GetPixel(dumx,dumy);
    with TempVP do SetViewPort(x1,y1,x2,y2,clip);
    ShowColors;
    wMouseShow;
    wWaitForMouseRelease;
    wMouseHide;
    setcolor(8);
    rectangle(r.b.x-45,r.a.y+55,r.b.x-5,r.a.y+65);
    wMouseShow;
  end;
end;
procedure T256Colors.Show;
  var i,j,count,ssize,bxsize,bysize: integer;
begin
  setfillstyle(solidfill,black);
  with r do bar(a.x,a.y,b.x,b.y);
  count:=0;
  ssize:=trunc(sqrt(GetMaxColor+1))-1;
  with r do begin
    bxsize:=((b.x - a.x - 49) div (ssize+1));
    bysize:=((b.y - a.y - 4) div (ssize+1));
  end;
  for i:=0 to ssize do
    for j:=0 to ssize do begin
{      MoveTo(r.a.x+2+j*s.x,r.a.y+2+i*s.y);}
      MoveTo(r.a.x+2+j*bxsize,r.a.y+2+i*bysize);
      setfillstyle(solidfill,count);
      inc(count);
      bar(GetX,GetY,GetX+bxsize-1,GetY+bysize-1);
    end;
  {end}
  setcolor(8);
  rectangle(r.b.x-45,r.a.y+55,r.b.x-5,r.a.y+65);
  outtextxy(r.b.x-37,r.a.y+57,'GET');
  ShowColors;
end;
procedure T256Colors.LoadPalette;
begin
  if PalFile.FileName='NoFile' then exit;
end;
procedure T256Colors.SetPalette(iFileName: string);
begin
  if (GetMaxColor <> 255) then exit;
  PalFile.AssignFile(iFileName);
  PalFile.OpenFile;
  GetMem(PaletteBuffer,768);
  PalFile.ReadFile(PaletteBuffer^,768);
  {later: mark sections!!!}
  asm
    les dx,PaletteBuffer
    mov cx,256
    xor bx,bx
    mov ax,1012h
    int 10h {set palette}
  end;
  FreeMem(PaletteBuffer,768);
  PalFile.CloseFile;
end;
procedure T256Colors.ShowColors;
begin
  setcolor(7);
  setfillstyle(1,c.back);
  bar(r.b.x-44,r.a.y+3,r.b.x-6,r.a.y+30);
  rectangle(r.b.x-45,r.a.y+2,r.b.x-5,r.a.y+31);
  setfillstyle(1,c.fore);
  bar(r.b.x-34,r.a.y+12,r.b.x-16,r.a.y+21);
  rectangle(r.b.x-35,r.a.y+11,r.b.x-15,r.a.y+22);
  setfillstyle(1,0);
  bar(r.b.x-35,r.a.y+35,r.b.x-12,r.a.y+50);
  outtextxy(r.b.x-35,r.a.y+35,WordStr(c.fore,10));
  outtextxy(r.b.x-35,r.a.y+43,WordStr(c.back,10));
end;
procedure T256Colors.ReSize(sX,sY: integer);
begin
  if sX<1 then sX:=1;
  if sY<1 then sY:=1;
  if sX>30 then sX:=30;
  if sY>30 then sY:=30;
  s.x:=sX; s.y:=sY;
  wMouseHide;
  setfillstyle(1,8);
  with r do bar(a.x,a.y,b.x,b.y);
  wMouseShow;
  r.setXYXY(r.a.x,r.a.y,r.a.x+16*sX+52,r.a.y+16*sY+4);
  wMouseHide;
  Show;
  wMouseShow;
end;
{== CHOICE BOX =============================================================}
function NewChoiceBox(x1,y1,x2,y2,c1,c2,def: integer; ChItemList: PChItem; nextitem: PItem):Pitem;
begin
  tempitem:=new(PChoice, init(x1,y1,x2,y2,c1,c2,def,ChItemList));
  tempItem^.next:=nextitem;
  NewChoiceBox:=tempitem;
end;
  function NewChoiceItem(iStr: string; NextChItem: PChItem): PChItem;
    var TempChItem: PChItem;
  begin
    TempChItem:=new(PChItem, init(iStr));
    TempChItem^.next:=NextChItem;
    NewChoiceItem:=TempChItem;
  end;
constructor TChoice.init(x1,y1,x2,y2,c1,c2,def: integer; ChItemList: PChItem);
begin
  TItem.init(x1,y1,x2,y2,0);
  c.setcolor(c1,c2);
  ChCur:=def;
  ChItems:=ChItemList;
end;
procedure TChoice.HandleMouse(x,y,b: integer);
  var num,xo,yo: integer;
begin
  xo:=x-r.a.x; yo:=y-r.a.y;
  if PointIn(xo,yo,3,5,27,5+GetNumChItems(ChItems)*10) then begin
    num:=(yo-6) div 10 + 1;
    if num<>ChCur then begin
      wMouseHide;
      setcolor(c.back);
      MoveTo(r.a.x+11,r.a.y+5+(ChCur-1)*10);
      OutText('Û');
      ChCur:=num;
      setcolor(c.fore);
      MoveTo(r.a.x+11,r.a.y+5+(ChCur-1)*10);
      OutText('X');
      wMouseShow;
    end;
  end;
end;
procedure TChoice.Show;
  var i: integer;
begin
  setfillstyle(SolidFill,c.back);
  bar(r.a.x,r.a.y,r.b.x,r.b.y);
  setcolor(c.fore);
  rectangle(r.a.x,r.a.y,r.b.x,r.b.y);

  MoveTo(r.a.x+3,r.a.y+5);
  for i:=1 to GetNumChItems(ChItems) do begin
    outtext('( ) '+ChItemPtr(ChItems,i)^.Str);
    MoveTo(r.a.x+3,GetY+10);
  end;
  MoveTo(r.a.x+11,r.a.y+5+(ChCur-1)*10);
  OutText('X');
end;
  function GetNumChItems(ChItemHead: PChItem): integer;
    var TempChItem: PChItem;
        count: integer;
  begin
    count:=0;
    TempChItem:=ChItemHead;
    while (tempChItem<>nil) do begin
      inc(count);
      TempChItem:=TempChItem^.next;
    end;
    GetNumChItems:=count;
  end;
  function ChItemPtr(ChItemList: PChItem; ChItemNum: integer): PChItem;
    var TempChItem: PChItem;
  begin
    TempChItem:=ChItemList;
    while (TempChItem<>nil) and (ChItemNum>1) do begin
      TempChItem:=TempChItem^.next;
      dec(ChItemNum);
    end;
    ChItemPtr:=TempChItem;
  end;
  constructor TChItem.init(iStr: string);
  begin
    Str:=iStr;
  end;
{== RECTANGLE ==============================================================}
function NewRectangle(x1,y1,x2,y2,c: integer; nextitem: PItem):Pitem;
begin
  tempItem := new(PRectangle, init(x1,y1,x2,y2,c));
  tempitem^.next := nextitem;
  NewRectangle := tempItem;    {return self}
end;
constructor TRectangle.init(x1,y1,x2,y2,c: integer);
begin
  TItem.init(x1,y1,x2,y2,0); colour:=c;
end;
procedure TRectangle.Show;
begin
  setcolor(colour); rectangle(r.a.x,r.a.y,r.b.x,r.b.y);
end;

{== TEXT ===================================================================}
function NewText(x1,y1,x2,y2,xo,yo: integer; iStr: string; c1,c2: byte; nextItem: PItem): PItem;
begin
  tempItem:=new(PText, init(x1,y1,x2,y2,xo,yo,iStr,c1,c2));
  tempItem^.next:=nextItem;
  NewText:=tempItem;
end;
constructor TText.Init(x1,y1,x2,y2,xo,yo: integer; iStr: string; c1,c2: byte);
begin
  TItem.Init(x1,y1,x2,y2,0);
  Str:=iStr;
  c.SetColor(c1,c2);
  off.setXY(xo,yo);
end;
procedure TText.SetStr(iStr: string);
begin
  Str:=iStr;
end;
procedure TText.Show;
begin
  setfillstyle(SolidFill,c.back);
  bar(r.a.x,r.a.y,r.b.x,r.b.y);
  setcolor(c.fore);
  outtextxy(r.a.x+off.x,r.a.y+off.y,Str);
end;

end.