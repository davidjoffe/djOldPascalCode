{$G+}
unit w_mouse;
{ David Joffe '94/12 }
{ mouse routines for DJWIN }

interface

uses
  dos,u_mouse,graph,uo_obj;

var
  OldViewPort: ViewPortType;
  ox,oy,x,y,b: integer;
  dx,dy: integer;
  r: TRect;
  MouseVisible: boolean;
  MouseSave: array[0..260] of byte;
  OldTimerInt: pointer;
  SaveColor: byte;
  Busy: boolean;

procedure MouseInit;
procedure NewTimerInt; interrupt;
procedure wGetMouse(var x,y,b: integer);
procedure SetMouseRange(x1,y1,x2,y2: integer);
procedure wMouseHide;
procedure wMouseShow;
procedure SetDefaultMouseRange;
procedure MouseDone;
procedure wWaitForMouseRelease;
procedure wWaitForMousePress;


implementation

{----------------------------------------------------------[ TApplication ]--}

procedure MouseInit;
begin
  SetDefaultMouseRange;
  ox:=0; oy:=0;
  MouseVisible:=false;
  wMouseShow;
  GetIntVec($1C,OldTimerInt);
  SetIntVec($1C,@NewTimerInt);
end;

procedure wMouseHide;
begin
  if MouseVisible then begin
    MouseVisible:=false;
    repeat until not busy;
    { save viewport }
    GetViewSettings(OldViewPort);
    SetViewPort(0,0,GetMaxX,GetMaxY,true);
    PutImage(ox,oy,MouseSave,NormalPut);
    { restore viewport }
    with OldViewPort do SetViewPort(x1,y1,x2,y2,clip);
  end;
end;
procedure wMouseShow;
begin
  if not MouseVisible then begin
    GetViewSettings(OldViewPort);
    SetViewPort(0,0,GetMaxX,GetMaxY,false);
    GetImage(ox,oy,ox+8,oy+8,MouseSave);
    with OldViewPort do SetViewPort(x1,y1,x2,y2,clip);
    MouseVisible:=true;
  end;
end;

procedure NewTimerInt;
begin
  Busy:=true;
  if MouseVisible then begin
    GetViewSettings(OldViewPort);
    SetViewPort(0,0,GetMaxX,GetMaxY,true);
    PutImage(ox,oy,MouseSave,NormalPut);
    GetMouseMotion(dx,dy);
    ox:=ox+(dx div 2);
    oy:=oy+(dy div 2);
    if ox<r.a.x then ox:=r.a.x;
    if oy<r.a.y then oy:=r.a.y;
    if ox>r.b.x then ox:=r.b.x;
    if oy>r.b.y then oy:=r.b.y;
    GetImage(ox,oy,ox+8,oy+8,MouseSave);
    SaveColor:=getcolor;

 {   setcolor(0);
    outtextxy(0,300,'ллллл');
    outtextxy(0,310,'ллллл');
    setcolor(7);
    outtextxy(0,300,IntStr(GetMouseMotionX,10)+'  ');
    outtextxy(0,310,IntStr(GetMouseMotionY,10)+'  ');}

    setcolor(0);
    line(ox+1,oy,ox+6,oy+2);
    line(ox+1,oy,ox+3,oy+5);
    line(ox+1,oy,ox+8,oy+7);
    setcolor(15);
    line(ox,oy,ox+5,oy+2);
    line(ox,oy,ox+2,oy+5);
    line(ox,oy,ox+8,oy+8);
    setcolor(SaveColor);
    with OldViewPort do SetViewPort(x1,y1,x2,y2,clip);
  end;
  Busy:=false;
end;

procedure wGetMouse(var x,y,b: integer);
begin
  b:=MousePressed;
  repeat until not Busy;
  x:=ox;y:=oy;
end;

procedure SetDefaultMouseRange;
begin
  SetMouseRange(0,0,GetMaxX-8,GetMaxY-8);
end;

procedure SetMouseRange(x1,y1,x2,y2: integer);
begin
  r.SetXYXY(x1,y1,x2,y2);
end;

procedure MouseDone;
begin
  MouseHide;
  SetIntVec($1C,OldTimerInt);
end;

procedure wWaitForMouseRelease;
  var b: integer;
begin
  repeat
    b:=MousePressed;
  until b=0;
end;

procedure wWaitForMousePress;
  var b: integer;
begin
  repeat
    b:=MousePressed;
  until b<>0;
end;


end.