{$G+}
unit w_item;
{ David Joffe '94/12
{ Definition for standard Item: its descendants get inserted into }
{ all window types, e.g icons, buttons, text, etc.                }
{ i.e. everything that appears within a window is one of these    }

interface

uses uo_obj;

type
  PItem=^TItem;
  TItem=object
    r: TRect; {a,b are offsets from App window(0,0)}
    RetCmd: integer; {an arbitrary number assigned by App to return the}
                     {pressed item. Each item's should be different.}
    next: PItem;

    constructor Init(x1,y1,x2,y2,iRetCmd: integer);
    procedure Show; virtual;
    procedure FillBackGround(style,colour,x1,y1,x2,y2: integer);
    procedure ItemRectangle(colour,x1,y1,x2,y2: integer);
    procedure HandleMouse(x,y,b: integer); virtual;
    procedure HandleKey; virtual;
    procedure Move(x,y: integer);
    destructor done; virtual;
  end;

function ItemMouseIn(ItemList: PItem; x,y,b: integer): integer;
{function ItemPtr(ItemList: PItem; ItemNum: integer): PItem;}

implementation
uses w_mouse,graph,u_useful;

{---------------------------------------------------------------------}
constructor TItem.init(x1,y1,x2,y2: integer; iRetCmd: integer);
begin
  r.SetXYXY(x1,y1,x2,y2);
  RetCmd:=iRetCmd;
end;
(*--------------------------------------------------------------------------*)
procedure TItem.Show;
begin
end;
(*--------------------------------------------------------------------------*)
procedure TItem.FillBackGround(style,colour,x1,y1,x2,y2: integer);
begin
  setfillstyle(style,colour);
  bar(x1,y1,x2,y2);
end;
(*--------------------------------------------------------------------------*)
procedure TItem.ItemRectangle(colour,x1,y1,x2,y2: integer);
begin
  setcolor(colour);
  rectangle(x1,y1,x2,y2);
end;
(*--------------------------------------------------------------------------*)
procedure TItem.Move(x,y: integer);
begin
  wMouseHide;
  setfillstyle(1,8);
  with r do bar(a.x,a.y,b.x,b.y);
  wMouseShow;
  r.setXYXY(x,y,x+r.size.x,y+r.size.y);
  wMouseHide;
  Show;
  wMouseShow;
end;
(*--------------------------------------------------------------------------*)
procedure TItem.HandleMouse;
begin
end;
(*--------------------------------------------------------------------------*)
procedure TItem.HandleKey;
begin
  {wow! this has definitely not yet been implemented.}
  {I didnt even remember that I actually put this here.}
end;
(*--------------------------------------------------------------------------*)
destructor TItem.done;
begin
  {Default is to do nothing}
end;
{---------------------------------------------------------------------}

(*--------------------------------------------------------------------------*)
function ItemMouseIn(ItemList: PItem; x,y,b: integer): integer;
  var T: PItem;
      tRetCmd: integer;
begin
  T:=ItemList;
  tRetCmd:=0;
  while (T<>nil) do begin
    if PointIn(x,y,T^.r.a.x,T^.r.a.y,T^.r.b.x,T^.r.b.y) then begin
      tRetCmd:=T^.RetCmd;
      T^.HandleMouse(x,y,b);
      break;
    end;
    T:=T^.next;
  end;
  ItemMouseIn:=tRetCmd;
end;

{function ItemPtr(ItemList: PItem; ItemNum: integer): PItem;
  var TempItem: PItem;
begin
  TempItem:=ItemList;
  while (TempItem<>nil) and (itemNum>1) do begin
    dec(ItemNum);
    TempItem:=TempItem^.next;
  end;
  ItemPtr:=TempItem;
end;}



end.