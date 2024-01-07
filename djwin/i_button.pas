{$G+}
unit i_buttons;
{ David Joffe '94/12 }
{ library of button-type items }

{ TextButton }
{ TextSwitch }

interface

uses crt,w_item,graph;

const
  MAX_BUTTON_STRING_LENGTH=20;

type
  PTextButton=^TTextButton;
  TTextButton=object(TItem)
    Str: string[MAX_BUTTON_STRING_LENGTH];
    c: byte;
    constructor Init(x1,y1,x2,y2: integer; iStr: string; iRetCmd: integer);
    procedure HandleMouse(x,y,b: integer); virtual;
    procedure DrawBorder(c1,c2:byte);
    procedure Show; virtual;
  end;

  PTextSwitch=^TTextSwitch;
  TTextSwitch=object(TTextButton)
    Status: boolean;
    constructor Init(x1,y1,x2,y2: integer; iStr: string; iStatus: boolean; iRetCmd: integer);
    procedure HandleMouse(x,y,b: integer); virtual;
    procedure SetStatus(iStatus: boolean);
  end;

function NewTextButton(x1,y1,x2,y2: integer; iStr: string; iRetCmd: integer; nextItem: PItem): PItem;

implementation
uses w_mouse;

{== TEXT SWITCH BUTTON =====================================================}
constructor TTextSwitch.init;
begin
  TTextButton.init(x1,y1,x2,y2,iStr,iRetCmd);
  Status:=iStatus;
  if Status then c:=10 else c:=2;
end;
procedure TTextSwitch.SetStatus(iStatus: boolean);
begin
  Status:=iStatus;
  wMouseHide;
  if Status then c:=10 else c:=2;
  Show;
  wMouseShow;
end;
procedure TTextSwitch.HandleMouse(x,y,b: integer);
begin
  wMouseHide;
  DrawBorder(0,7);
  wMouseShow;
  delay(140);
  wMouseHide;
{  DrawBorder(7,0);}
  Status:=not Status;
  if Status then c:=10 else c:=2;
  Show;
  wMouseShow;
end;
{== TEXT BUTTON ============================================================}
function NewTextButton(x1,y1,x2,y2: integer; iStr: string; iRetCmd: integer; nextItem: PItem): PItem;
  var temp_item: pitem;
begin
  temp_Item:=new(PTextButton, init(x1,y1,x2,y2,iStr,iRetCmd));
  temp_Item^.next:=nextItem;
  NewTextButton:=temp_Item;
end;
constructor TTextButton.init(x1,y1,x2,y2: integer; iStr: string; iRetCmd: integer);
begin
  TItem.Init(x1,y1,x2,y2,iRetCmd);
  Str:=iStr;
  c:=15;
end;
procedure TTextButton.show;
begin
  setfillstyle(solidfill,8);
  with r do bar(a.x,a.y,b.x,b.y);
  DrawBorder(7,0);
  setcolor(c);
  with r do
    outtextxy(a.x+((size.x-TextWidth(Str)) div 2),1+a.y+(size.y div 2)-4,Str);
end;
procedure TTextButton.HandleMouse(x,y,b: integer);
begin
  wMouseHide;
  DrawBorder(0,7);
  wMouseShow;
  delay(140);
  wMouseHide;
  DrawBorder(7,0);
  wMouseShow;
end;
procedure TTextButton.DrawBorder(c1,c2: byte);
begin
  setcolor(c1);
  with r do begin
   { line(a.x,a.y,a.x+size.x,a.y);
    line(a.x,a.y,a.x,a.y+size.y);
    line(a.x,a.y+1,a.x+size.x-1,a.y+1);
    line(a.x+1,a.y,a.x+1,a.y+size.y-1);}
    rectangle(a.x,a.y,a.x+size.x,a.y+1);
    rectangle(a.x,a.y,a.x+1,a.y+size.y);
  end;
  setcolor(c2);
  with r do begin
    line(a.x+size.x,a.y,a.x+size.x,a.y+size.y);
    line(a.x,a.y+size.y,a.x+size.x,a.y+size.y);
    line(a.x+size.x-1,a.y+1,a.x+size.x-1,a.y+size.y);
    line(a.x+1,a.y+size.y-1,a.x+size.x,a.y+size.y-1);
  end;
end;


end.