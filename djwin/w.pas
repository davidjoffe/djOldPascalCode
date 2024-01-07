{ David Joffe '94/12 }
{ This module contains the main window handling functions in a program     }
{ written by the DJ application framework; i.e. the "kernel", so to speak. }
unit w;
{$G+}

interface

uses
  crt,dos,graph,w_init,w_done,w_menus,u_keys,uo_obj,w_app,w_win,w_item,
  w_mouse,w_stddlg;

const
  MenuColors: TMenuColorRec=(
    Normal          : (fore: Yellow     ; back: Magenta );
    ShortCut        : (fore: LightCyan  ; back: Magenta );
    Selected        : (fore: LightRed   ; back: Black   );
    SelectedShortCut: (fore: LightGreen ; back: Black   )
  );

type
  PApplication=^TApplication;
  TApplication=object
    constructor init(GraphDriver,GraphMode: integer);
    procedure Run;
    procedure HandleMenuCommand(cmdNum: integer); virtual;
    destructor done;
  end;

  TImageArr=array[0..2047] of byte;

  PImageSave=^TImageSave;
  TImageSave=array[0..65519] of byte;

var
  ADlgWarning     : TDlgWarning;
  ImageSave       : PImageSave;
  im              : TPoint;
  imSize          : word;

  MidX,MidY       : integer;

  MenuBar         : TMenuBar;
  MenuCommand     : integer;
  head,temp,temp2 : PApp;
  NumApps         : integer; {all}
  NumTrueApps     : integer; {all parent-only (type TApp)}
  curApp          : integer;
  curTrueApp      : integer;
  numAppWins      : integer;

  curAppWin       : integer;

  curDialog       : PDialog;
  DialogCmd       : integer;

  ImageArr        : array[0..3] of ^TImageArr;

{general item list linking functions}
function Link(ThisItem, NextItem: PItem): PItem;
function LinkList(ItemList, NextItem: PItem): PItem;

{draws the background fill pattern on a given rectangle}
procedure RestoreDeskTop(x1,y1,x2,y2: integer);

{return a pointer to the appnumth app}
function AppPtr(AppNum: integer): PApp;

{creating new apps}
procedure NewApp(App: PApp);
procedure NewAppWin(App: PApp);
procedure RemApp(num: integer);

{execute a dialog box}
function Dialog(Dlg: PDialog): integer;

{window and window re-drawing routines}
procedure set_cur_app(AppNum: integer);
procedure bring_to_top(app_num: integer);
procedure show_all_windows;

{general routines for screen manipulation}
procedure SaveImage(x1,y1,x2,y2: integer);
procedure RestoreImage;

implementation

{only for screen capturer:}
uses u_files,u_useful;

(*--------------------------------------------------------------------------*)
function Link(ThisItem, NextItem: PItem): PItem;
begin
  ThisItem^.next:=NextItem;
  Link:=ThisItem;
end;

(*--------------------------------------------------------------------------*)
function LinkList(ItemList, NextItem: PItem): PItem;
  var temp1: PItem;
begin
  temp1:=ItemList;
  while temp1^.next<>nil do begin
    temp1:=temp1^.next;
  end;
  temp1^.next:=NextItem;
  LinkList:=ItemList;
end;

(*--------------------------------------------------------------------------*)
procedure RestoreDeskTop(x1,y1,x2,y2: integer);
begin
  setfillstyle(11,1);
  bar(x1,y1,x2,y2);
{EmptyFill      ³   0     ³ Uses background color
SolidFill      ³   1     ³ Uses draw color
LineFill       ³   2     ³ --- fill
LtSlashFill    ³   3     ³ /// fill
SlashFill      ³   4     ³ /// thick fill
BkSlashFill    ³   5     ³ \thick fill
LtBkSlashFill  ³   6     ³ \fill
HatchFill      ³   7     ³ Light hatch fill
XHatchFill     ³   8     ³ Heavy cross hatch
InterleaveFill ³   9     ³ Interleaving line
WideDotFill    ³   10    ³ Widely spaced dot
CloseDotFill   ³   11    ³ Closely spaced dot
UserFill       ³   12    ³ User-defined fill}
end;



{----------------------------------------------------------[ TApplication ]--}
(*--------------------------------------------------------------------------*)
constructor TApplication.Init(GraphDriver,GraphMode: integer);
begin
  NumApps:=0;
  NumTrueApps:=0;
  NumAppWins:=0;
  InitGraphics(GraphDriver,GraphMode);
  MidX:=GetMaxX div 2;
  MidY:=GetMaxY div 2;
  InitDeskTop;
  KeyInit(true);
  MouseInit;
end;

(*--------------------------------------------------------------------------*)
procedure TApplication.Run;
  var num,i,tx,ty, Xofs, Yofs: integer;
      App: PApp;
      ta,tsize,Tofs: TPoint;
  label OutOfHere;
begin
  setviewport(0,0,GetMaxX,GetMaxY,true);
  If MenuBar.MenuInit then MenuBar.Show;

  while (not (k[kyAlt] and k[kyCtrl] and k[kyEsc])) do begin
  {temporary key screen capturer, ctrl+alt+c}
  {note that in implementation part of unit, u_files is only for this:}
    if (k[kyAlt] and k[kyCtrl] and k[kyC]) then begin
      CreateFile('scrncap.dat');
      openfile('scrncap.dat',67);
      wmousehide;
      portw[$3C4]:=$F02;
      port[$3CE]:=4;
      for i:=0 to 3 do begin
        port[$3CF]:=i;
        writefile(67, ptr($A000,0), 38400);
      end;
      port[$3CE]:=5;
      port[$3CF]:=0;
      wmouseshow;
      closefile(67);
      sound(1000);
      delay(40);
      nosound;
    end;
  {end of screen capturer}

    setviewport(0,0,GetMaxX,GetMaxY,true);

    {Check Menubar}
    if MenuBar.MenuInit then begin
      MenuCommand:=MenuBar.MenuCheck;
      if MenuCommand<>0 then begin
        HandleMenuCommand(MenuCommand);
        continue;
      end;
    end;

    if NumApps=0 then continue;

    wGetMouse(x,y,b);

    App:=AppPtr(curApp);
    with App^.r do SetViewPort(a.x,a.y,b.x,b.y, true);

    {if mouse_clicked and in current app's window (not bar)}
    if (b<>0) and pointIn(x,y,App^.r.a.x,App^.r.a.y+16,App^.r.b.x,App^.r.b.y) then begin
      {num returns a pressed items command (RetNo)}
      num:=ItemMouseIn(App^.items,x-App^.r.a.x,y-App^.r.a.y,b);

      if App^.WinType=WinTypeApp then
        App^.HandleCmd(num)
      else {AppWindow (a child window of an app)}
        AppPtr(curTrueApp)^.HandleAppWin(App^.num1,num);

      continue;
    end;

    {if mouse_clicked and in current app's sys-box, ask to close}
    if (b<>0) and pointIn(x,y,App^.r.a.x,App^.r.a.y,App^.r.a.x+15,App^.r.a.y+15) then begin
      ADlgWarning.init('Close window..','Are you sure?');
      Dialog(@ADlgWarning);
      if ADlgWarning.OKStatus then begin
        RemApp(curApp);
      end;
    end;

    {if mouse_clicked and in current app's bar}
    if (b<>0) and pointIn(x,y,App^.r.a.x+16,App^.r.a.y,App^.r.b.x,App^.r.a.y+15) then begin
      ta:=App^.r.a; tsize:=App^.r.size;
      Tofs.setXY(x-ta.x,y-ta.y);
      Xofs := ta.x;
      Yofs := ta.y;

      SetMouseRange(Tofs.x+8,Tofs.y+16 ,GetMaxX-((ta.x+tsize.x)-x)-8,GetMaxY-((ta.y+tsize.y)-y)-8);

      for num:=0 to 3 do begin
        GetMem(ImageArr[num], 2048);
      end;

      wMouseHide;
      with App^.r do setViewPort(a.x,a.y,b.x,b.y,true);

      GetImage(0      ,0      ,tsize.x,0      ,ImageArr[0]^[0]);
      GetImage(0      ,tsize.y,tsize.x,tsize.y,ImageArr[1]^[0]);
      GetImage(0      ,0      ,0      ,tsize.y,ImageArr[2]^[0]);
      GetImage(tsize.x,0      ,tsize.x,tsize.y,ImageArr[3]^[0]);

      setcolor(15);
      rectangle(0,0,Tsize.x,TSize.y);

      SetViewPort(0,0,GetMaxX,GetMaxY,true);
      wMouseShow;
      tx:=x; ty:=y;
      repeat
        if (tx<>x) or (ty<>y) then begin {moved}
          wMouseHide;

          Xofs:=tx-Tofs.x; {offsets onto screen under rectangle}
          Yofs:=ty-Tofs.y;
          PutImage(Xofs        ,Yofs        ,ImageArr[0]^[0],NormalPut);
          PutImage(Xofs        ,Yofs+tsize.y,ImageArr[1]^[0],NormalPut);
          PutImage(Xofs        ,Yofs        ,ImageArr[2]^[0],NormalPut);
          PutImage(Xofs+tsize.x,Yofs        ,ImageArr[3]^[0],NormalPut);

          Xofs:=x-Tofs.x;  {offsets onto screen of new rectangle to be drawn}
          Yofs:=y-Tofs.y;
          GetImage(Xofs        ,Yofs        ,Xofs+tsize.x,Yofs        ,ImageArr[0]^[0]);
          GetImage(Xofs        ,Yofs+tsize.y,Xofs+tsize.x,Yofs+tsize.y,ImageArr[1]^[0]);
          GetImage(Xofs        ,Yofs        ,Xofs        ,Yofs+tsize.y,ImageArr[2]^[0]);
          GetImage(Xofs+tsize.x,Yofs        ,Xofs+tsize.x,Yofs+tsize.y,ImageArr[3]^[0]);

          rectangle(Xofs,Yofs,Xofs+Tsize.x,Yofs+Tsize.y);

          wMouseShow;
{          ta.SetXY(Xofs,Yofs); {new x,y offset for app, when "dropped"}
        end;
        tx:=x; ty:=y;     {store old mouse coords}
        wGetMouse(x,y,b); {get new mouse coords}
      until (b=0); {mouse let go}
      wMouseHide;
      {draw over old with bground:}
      with App^.r do RestoreDeskTop(a.x,a.y,b.x,b.y);
      App^.r.setXYXY(Xofs,Yofs,Xofs+tsize.x,Yofs+tsize.y);
      with App^.r do setViewPort(a.x,a.y,b.x,b.y,true);
      show_all_windows; {redraw all}
      SetDefaultMouseRange;
      wMouseShow;
      for num:=0 to 3 do FreeMem(ImageArr[num], 650);
      continue;
    end; {if}


    {check if in another window (not in current anyway here)}
    if (b<>0) and (NumApps>1) then begin
      for i:=NumApps downto 1 do begin
        App:=AppPtr(i);
{        if (i<>curApp) and (x>=App^.r.a.x) and (x<=App^.r.b.x)
        and (y>=App^.r.a.y) and (y<=App^.r.b.y)}
        if (i<>curApp) and pointIn(x,y,App^.r.a.x,App^.r.a.y,App^.r.b.x,App^.r.b.y) then begin
{          App:=AppPtr(curApp);}
          set_cur_app(i);
{          bring_to_top(i);}

          goto OutOfHere;
        end;
      end;
    end; {if}
OutOfHere:

  end;
end;

(*--------------------------------------------------------------------------*)
procedure TApplication.HandleMenuCommand(cmdNum: integer);
begin
  RunError(211); {call to abstract method}
end;

(*--------------------------------------------------------------------------*)
destructor TApplication.Done;
begin
  MouseDone;
  KeyDone;
  DoneGraphics;
  halt;
end;

(*--------------------------------------------------------------------------*)
procedure NewApp(App: PApp);
begin
  if NumApps=0 then begin
    head:=App;
  end else begin
    {set last ones next to new app}
    AppPtr(numApps)^.next := App;
  end;
  App^.next:=head;       {create linked circle}

  inc(NumApps);
  inc(NumTrueApps);  {number for corner of app}

  App^.Owner:=0; {for child windows}
  App^.num1:=NumTrueApps; {number in list of TApp types (excl. children)}
  App^.num2:=0; {for child windows}
  set_cur_app(NumApps);
end;
(*--------------------------------------------------------------------------*)
procedure NewAppWin(App: PApp);
begin
  if NumApps=0 then exit; {strange error (there has to be a parent)}

  AppPtr(numApps)^.next:=App; { <-- add onto App linked list }
  App^.next:=head;            {     form closed list         }

  {increment parents count for child windows:}
  inc(AppPtr(curTrueApp)^.NumWin); {curTrueApp and curApp should be = }

  {Numbers that appear in window:}
  App^.num1:=AppPtr(curApp)^.NumWin;{num1=number of child app,rel to owner}
  App^.num2:=AppPtr(curApp)^.Num1;  {num2=arbitrary display num of owner  }

  inc(NumApps);
  inc(NumAppWins);

  {child windows owner variable = true app number in entire list}
  App^.Owner:=curApp; {true number in list of owner app}

{  wMouseHide;
  {draw over old with bground:}
{  setViewPort(0,0,getmaxx,getmaxy,true);
{  RestoreDeskTop(0,0,getmaxx,getmaxy);
{  wMouseShow;}

  set_cur_app(NumApps);
end;
(*--------------------------------------------------------------------------*)
procedure RemApp(num: integer);
  var temp: Papp; i: integer;
begin
  if (NumApps = 0) then exit; {shouldnt happen, there for safety}
  temp := AppPtr(num);

  {Find and kill any possible children: (sounds gruesome)}
  if (temp^.winType = winTypeApp) then begin
    dec(NumTrueApps);
    for i:=1 to NumApps do begin
      if (AppPtr(i)^.owner = num) then begin
        remApp(i);
      end;
    end;
  end;

  {call all window's item destructors, and dispose of each element}
  {of the list}
  temp^.DestroyItems(temp^.items);

  if (NumApps = 1) then begin
    head := nil;
  end else begin
    AppPtr(num - 1)^.next := temp^.next;
    {if head was pointing to the app being removed, set head to next}
    if head = temp then head := temp^.next;
  end;

  if (temp^.winType = winTypeAppWin) then begin
    dec(AppPtr(temp^.owner)^.numWin );
    dec(NumAppWins);
  end;
  dec(NumApps);
  {dispose of the window}
  Dispose(temp, done);

{  if AppPtr(CurApp)^.WinType=WinTypeApp then CurTrueApp:=curApp;
  if AppPtr(CurApp)^.WinType=WinTypeAppWin then CurTrueApp:=AppPtr(curApp)^.Owner;}

  {junk it off the heap (junk temp)}

  {redraw screen properly}
  wMouseHide;
  setViewPort(0,0,getmaxx,getmaxy,true);
  restoreDeskTop(0,0,getmaxx,getmaxy);
  If MenuBar.MenuInit then MenuBar.Show;
  wMouseShow;

  set_Cur_App(num - 1);
end;


(*--------------------------------------------------------------------------*)
function AppPtr(AppNum: integer): PApp;
begin
  if NumApps=0 then exit;
  if AppNum<1 then AppNum:=NumApps;
  if AppNum>NumApps then AppNum:=1;
  temp2:=head;
  while (temp2<>nil){?shouldnt happen(circle)} and (AppNum>1) do begin
    dec(AppNum);
    temp2:=temp2^.next;
  end;
  AppPtr:=temp2;
end;

(*--------------------------------------------------------------------------*)
procedure set_cur_app(AppNum: integer);
  var num: integer;
begin
  if (NumApps = 0) then begin
    curApp := 0;
  end else begin
    if AppNum<1 then AppNum:=NumApps;
    if AppNum>NumApps then AppNum:=1;

    curApp:=AppNum;

    if AppPtr(CurApp)^.WinType=WinTypeApp then CurTrueApp:=curApp;
    {OWNER APP!!!}
    if AppPtr(CurApp)^.WinType=WinTypeAppWin then CurTrueApp:=AppPtr(curApp)^.Owner;
  end;
  if NumApps <> 0 then begin
    wMouseHide;
    with AppPtr(CurApp)^.r do setviewport(a.x,a.y,b.x,b.y,true);
    show_all_windows;
    wMouseShow;
  end;
end;

(*--------------------------------------------------------------------------*)
procedure bring_to_top(app_num: integer);
begin
  curApp:=app_num;

  if appptr(curapp)^.wintype=wintypeapp    then curtrueapp:=curapp;
  {If child window, then set curtrueapp to owner app: OWNER APP!!!};
  if AppPtr(CurApp)^.WinType=WinTypeAppWin then CurTrueApp:=AppPtr(curApp)^.Owner;

  wmousehide;
  with appptr(curapp)^.r do setviewport(a.x,a.y,b.x,b.y,true);
  ShowWindow(AppPtr(curApp),true);
  wmouseshow;
end;


(*--------------------------------------------------------------------------*)
{ Create a Dialog box Dlg, handle interfacing }
function Dialog(Dlg: PDialog): integer;
 var num: integer;
begin
  Dlg^.InitInfo;

  Dlg^.num1:=0;
  ShowWindow(Dlg,true);

  DialogCmd:=0; {/////default: -1=command to exit from dialog box}
  {0=no command}

  wMouseHide;
  with Dlg^.r do SetViewPort(a.x,a.y,b.x,b.y,true);
  wMouseShow;

  if Dlg^.items<>nil then begin
    while true do begin
      wGetMouse(x,y,b);
      if b<>0 then begin
        DialogCmd:=ItemMouseIn(Dlg^.items,x-Dlg^.r.a.x,y-Dlg^.r.a.y,b);
        num:=Dlg^.HandleCmd(DialogCmd);
        if num=DLG_EXIT then break;
        if num=DlgBreak then begin
          Dlg^.ShutDown;
          break;
        end;
      end;
      if k[kyESC] then begin
        Dlg^.ShutDown;
        break;
      end;
    end;
  end else begin {if dialog error (no items)}
    repeat until k[kyESC];
    Dlg^.ShutDown
  end;

  wMouseHide;
  RestoreDeskTop(0,0,Dlg^.r.size.x,Dlg^.r.size.y);
  show_all_windows;
  wMouseShow;

  Dialog:=DialogCmd;
end;


(*--------------------------------------------------------------------------*)
procedure show_all_windows;
  var num: integer;
     bool: boolean;
begin
  wMouseHide;
  setviewport(0,0,GetMaxX,GetMaxY,true);
  for num:=1 to NumApps do begin
    if (num<>curApp) then begin
      if (num=curTrueApp) then bool:=true else bool:=false;
      wMouseHide;
      ShowWindow(AppPtr(num),bool);
    end;
  end;

  if NumApps<>0 then ShowWindow(AppPtr(curApp),true);
end;

(*--------------------------------------------------------------------------*)
procedure SaveImage(x1,y1,x2,y2: integer);
begin
  imSize:=ImageSize(x1,y1,x2,y2);
  GetMem(ImageSave, imSize);
  getImage(x1,y1,x2,y2,ImageSave^);
  im.setXY(x1,y1);
end;

(*--------------------------------------------------------------------------*)
procedure RestoreImage;
begin
  PutImage(im.X,im.Y,ImageSave^,normalPut);
  FreeMem(ImageSave, imSize);
end;


(*==========================================================================*)
begin
  head:=nil;
end.