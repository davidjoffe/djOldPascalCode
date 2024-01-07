{ David Joffe '94/12                }
{ Standard window objects for DJWIN }
{ see provided documentation for rather sketchy help on usage }
unit w_win;
{$G+}

interface

uses uo_obj,w_item,graph,u_mouse,u_useful;

const
  {window "types": for internal use}
  WinTypeDialog=1;
  WinTypeApp=2;
  WinTypeAppWin=3;
{HandleCmd must return for the following:}
  DlgExit=-1;
  DLG_EXIT=-1;
  DlgBreak=-2;

type
  PWindow=^TWindow;
  TWindow=object {abstract?}
    items : PItem;
    WinType,Num1,Num2: integer;
    {use:
     in initwindow:
            NewStaticText(.....,nil)))));}
    title    : string[80];
    r        : TRect;
    procedure DrawItems(cur: PItem);
    function HandleCmd(cmdNum: integer): integer; virtual;
    {call all items in list destructors}
    procedure DestroyItems(cur: PItem);
  end;

  PDialog=^TDialog;
  TDialog=object(TWindow) {abstract}
    constructor init{(x1,y1,x2,y2: integer; iTitle: string; ItemList: PItem)};
    procedure InitAll; virtual;  {first init to initialise size etc.}
    procedure InitInfo; virtual; {init on every call, to initialise switches etc.}
    procedure ShutDown; virtual; {called when Dlg box quit with ESC, to avoid}
                                 {crashes when this is used alternative to cancel}
{  DlgExit=-1;
  DlgBreak=-2;}
    {handlecmd;return -1 if you wish to exit the dialog box}
  end;

procedure ShowTitle(Win: PWindow; Enabled: boolean);
procedure ShowWindow(win: PWindow; Enabled: boolean);

var
  OldViewPort: ViewPortType;

implementation
uses w_mouse;

constructor TDialog.init;
begin
  WinType:=WinTypeDialog;
  InitAll;
  {TWindow.DrawItems(itemList);}
end;
procedure TDialog.InitAll;
begin
end;
procedure TDialog.InitInfo;
begin
end;
procedure TDialog.ShutDown;
begin
end;

procedure TWindow.DestroyItems(cur: PItem);
  var temp: PItem;
begin
  {call all item's done destructors}
  while (cur <> nil) do begin
    temp := cur;
    cur := cur^.next;
    if (temp <> nil) then Dispose(temp, done);
  end;
  {physically junk items, oops, this wont work.}
  {some are instances .. so eek, hm... done not}
  {implemented for them, so .. do it anyway :) }

  {Will change instance crap, that was a dumb  }
  {idea anyway.                                }
end;

procedure TWindow.DrawItems(cur: PItem);
begin
{  if cur=nil then exit;
  cur^.Show;
  DrawItems(cur^.next);}
  while (cur <> nil) do begin
    cur^.show;
    cur := cur^.next;
  end;
end;

{ note: for TApp the HandleCmd is called as a procedure; for
  TDialog it is called as a function because the dialog control
  function needs to communicate with the window }
function TWindow.HandleCmd(cmdNum: integer): integer;
begin
end;


procedure ShowTitle(Win: PWindow; Enabled: boolean);
  var num: integer;
    tstr: string[5];
begin
  if Win^.WinType=WinTypeDialog then num:=4;
  If Win^.WinType=WinTypeApp then num:=1;
  if Win^.WinType=WinTypeAppWin then num:=5;
  if not Enabled then num:=8;
  setfillstyle(solidfill,num);
  bar(15,1,win^.r.size.x-1,14);
  {If Win^.WinType=WinTypeApp then num:=15;
  if Win^.WinType=WinTypeAppWin then num:=13;
  if not Enabled then num:=7;}
  if Enabled then num:=15 else num:=7;
  setcolor(num);
  outtextxy(18,4,win^.Title);
  Tstr:=IntStr(win^.Num1,10);
  {num2=owner}
  if (Win^.WinType=WinTypeAppWin) then Tstr:=IntStr(Win^.Num2,10)+':'+TStr;
  outtextxy(win^.r.size.x-8-TextWidth(Tstr),4,TStr);

  setcolor(7);
  rectangle(0,0,15,15);
  setfillstyle(solidfill,black);
  bar(1,1,14,14);
  setfillstyle(solidfill,white);
  bar(4,6,11,9);

end;

procedure ShowWindow(Win: PWindow; Enabled: boolean);
  var Num: integer;
begin
  wMouseHide;
  GetViewSettings(OldViewPort);
  with win^.r do begin
    setviewport(a.x,a.y,b.x,b.y,true);
  end;

  setfillstyle(solidfill,8);
  bar(0,0,win^.r.size.x,win^.r.size.y);

  ShowTitle(Win,Enabled);

  setcolor(7);
  rectangle(0,0,win^.r.size.x,win^.r.size.y);

  line(0,15,win^.r.size.x,15);

{  if win^.items<>nil then begin
   sound(1000);
   delay(100);
   nosound;
   delay(80);
  end;}
{  if MouseVisible then begin
    wMouseHide;
    setcolor(14);
    with Win^.r do line(a.x,a.y,b.x,b.y);
    wMouseShow;
  end else begin
    setcolor(14);
    with Win^.r do line(a.x,a.y,b.x,b.y);
  end;
  sound(400);
  delay(1000);
  nosound;}

  win^.DrawItems(win^.items);

{  SetViewPort(0,0,GetMaxX,GetMaxY,true);}
  wMouseShow;
end;


end.