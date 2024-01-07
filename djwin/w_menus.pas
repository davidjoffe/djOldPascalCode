{$G+}
unit w_menus;
{ David Joffe '94/11-12       }
{ objects for menu for DJWIN. }

{$X+}

interface

uses crt,u_useful,uo_obj,graph,u_keys,u_files;

{const
{  InitFontFile='\fonts\egasmc.fnt';
  FontHeight=14;}

type
  HotKeyRec=record
    k1,k2: byte
  end;

const      {Hot key constants}
  NoHotKey: HotKeyRec=(k1: 0; k2: 0);
  NoShortCutKey=0;

  {creating one's own hot keys is not recommended: rather stick to these}
  {defined here:}
  F1: HotKeyRec=(k1: 0; k2: kyF1);
  F2: HotKeyRec=(k1: 0; k2: kyF2);
  F3: HotKeyRec=(k1: 0; k2: kyF3);
  F4: HotKeyRec=(k1: 0; k2: kyF4);
  F5: HotKeyRec=(k1: 0; k2: kyF5);
  F6: HotKeyRec=(k1: 0; k2: kyF6);
  F7: HotKeyRec=(k1: 0; k2: kyF7);
  F8: HotKeyRec=(k1: 0; k2: kyF8);
  F9: HotKeyRec=(k1: 0; k2: kyF9);
  F11: HotKeyRec=(k1: 0; k2: kyF11);

  AltN: HotKeyRec=(k1: kyAlt; k2: kyN);
  AltX: HotKeyRec=(k1: kyAlt; k2: kyX);

  AltF1 :HotKeyRec=(k1: kyAlt; k2: kyF1);
  AltF2 :HotKeyRec=(k1: kyAlt; k2: kyF2);
  AltF3 :HotKeyRec=(k1: kyAlt; k2: kyF3);
  AltF4 :HotKeyRec=(k1: kyAlt; k2: kyF4);
  AltF5 :HotKeyRec=(k1: kyAlt; k2: kyF5);
  AltF6 :HotKeyRec=(k1: kyAlt; k2: kyF6);
  AltF7 :HotKeyRec=(k1: kyAlt; k2: kyF7);
  AltF8 :HotKeyRec=(k1: kyAlt; k2: kyF8);
  AltF9 :HotKeyRec=(k1: kyAlt; k2: kyF9);
  AltF10:HotKeyRec=(k1: kyAlt; k2: kyF10);
  CtrlF1 :HotKeyRec=(k1: kyCtrl; k2: kyF1);
  CtrlF2 :HotKeyRec=(k1: kyCtrl; k2: kyF2);
  CtrlF3 :HotKeyRec=(k1: kyCtrl; k2: kyF3);
  CtrlF4 :HotKeyRec=(k1: kyCtrl; k2: kyF4);
  CtrlF5 :HotKeyRec=(k1: kyCtrl; k2: kyF5);
  CtrlF6 :HotKeyRec=(k1: kyCtrl; k2: kyF6);
  CtrlF7 :HotKeyRec=(k1: kyCtrl; k2: kyF7);
  CtrlF8 :HotKeyRec=(k1: kyCtrl; k2: kyF8);
  CtrlF9 :HotKeyRec=(k1: kyCtrl; k2: kyF9);
  CtrlF10:HotKeyRec=(k1: kyCtrl; k2: kyF10);
  ShiftF1 :HotKeyRec=(k1: kyShift; k2: kyF1);
  ShiftF2 :HotKeyRec=(k1: kyShift; k2: kyF2);
  ShiftF3 :HotKeyRec=(k1: kyShift; k2: kyF3);
  ShiftF4 :HotKeyRec=(k1: kyShift; k2: kyF4);
  ShiftF5 :HotKeyRec=(k1: kyShift; k2: kyF5);
  ShiftF6 :HotKeyRec=(k1: kyShift; k2: kyF6);
  ShiftF7 :HotKeyRec=(k1: kyShift; k2: kyF7);
  ShiftF8 :HotKeyRec=(k1: kyShift; k2: kyF8);
  ShiftF9 :HotKeyRec=(k1: kyShift; k2: kyF9);
  ShiftF10:HotKeyRec=(k1: kyShift; k2: kyF10);

type
  TMenuColorRec=record
    Normal,
    ShortCut,
    Selected,
    SelectedShortCut: TColor;
  end;

const
  Seperator='/';
type
  PMenuItem=^TMenuItem;
  TMenuItem=object
    next: PMenuItem;
    prev: PMenuItem;
    y   : integer;
    Str1: string[40]; {text}
    Str2: string[9];  {hotkeytext}
    ShortCutKey: byte;
    Hot : HotKeyRec;
    constructor Init(iStr1,iStr2: string; iShortCutKey: byte; iHot: HotKeyRec);
  end;

  PMenu=^TMenu;
  TMenu=object
    Height,curr,col,mcol,wid : integer;
    Header     : string[30];
    temp,head  : PMenuItem;
    constructor Init(iHead: string; iCol,iWid: integer; items: PMenuItem);
    procedure Show(mSize: integer; mColors: TMenuColorRec);
    procedure Hide(mSize: integer; mColors: TMenuColorRec);

    procedure ItemPrint(ItemNum: integer; mColors: TMenuColorRec; Selected: boolean);
    procedure CurMove(cD: integer; mColors: TMenuColorRec);
    function LastMenuItem: integer;
    function PItem(ItemNum: integer): PMenuItem;
    function GetShortCutKey: integer;
    function CheckHotKey: word;

    destructor done;
  end;

  {image underneath save array}
{  TMenuSave=array[0..32766] of byte;}

const
  MaxItems=10;
type
  PMenuBar=^TMenuBar;
  TMenuBar=object
    MenuInit      : boolean;
    curr          : integer;
    Colors        : TMenuColorRec;
    NumItems      : byte;
    size          : integer;
    Item          : array[1..MaxItems] of TMenu;
    ShortKey      : array[1..MaxItems] of byte;
    constructor Init(iSize: integer; iColors: TMenuColorRec);
    procedure NewHead(iHead: string; iCol,iWidth: integer; iShortCutKey: byte; items: PMenuItem);

    function MenuCheck: word;
    procedure EnterMenu(var CmdGet: word);
    procedure MenuCheckMove(MenuD: integer);

    procedure Show;
    destructor done;
  end;

{function NewHead(): PMenu;}
function NewItem(iStr1,iStr2: string; iShortCutKey: byte; iHot: HotKeyRec; NextItem: PMenuItem):PMenuItem;
function NewLine(NextItem: PMenuItem):PMenuItem;
procedure MenuPrint(x,y: integer; Str: string; mColors: TMenuColorRec; Selected: boolean);
procedure ColorPrint(Str: string; c1,c2: byte);

{var
  MenuSave: ^TMenuSave;}

implementation
uses w_mouse,w;

procedure TMenuBar.NewHead(iHead: string; iCol,iWidth: integer; iShortCutKey: byte; items: PMenuItem);
begin
  if NumItems=MaxItems then exit;
  inc(NumItems);

  Item[NumItems].init(iHead,iCol,iWidth,items);

  iCol:=icol-4;
  if iCol+iwidth>Size then iCol:=Size-iwidth;
  if iCol<3 then iCol:=3;
  Item[NumItems].mCol:=icol;

  ShortKey[NumItems]:=iShortCutKey;
end;

constructor TMenuBar.Init;
begin
  NumItems:=0;
  MenuInit:=true;
  Colors:=iColors;
  Size:=iSize;
end;

procedure TMenuBar.Show;
  var i: integer;
begin
  wMouseHide;
  setfillstyle(solidfill,Colors.normal.back);;
  bar(0,0,size,9);
  for i:=1 to NumItems do
    MenuPrint(Item[i].col,0,Item[i].Header,Colors,false);
  wMouseShow;
end;

function TMenuBar.MenuCheck: word;
  var i: integer;
      tCmd: word;
  label ExitMenuCheck;
begin
  {find hot keys}
  for i:=1 to NumItems do begin
    tCmd:=Item[i].CheckHotKey;
    if tCmd<>0 then begin
      tCmd:=i*256+tCmd;
      goto ExitMenuCheck;
    end;
  end;
  tCmd:=0;

  {find header short cut keys}
  if k[kyAlt] then begin
    for i:=1 to NumItems do begin
      if k[ShortKey[i]] then begin
        curr:=i;
        EnterMenu(tCmd);
        goto ExitMenuCheck;
      end;
    end;
  end;
  ExitMenuCheck:
  MenuCheck:=tCmd;
end;
procedure TMenuBar.EnterMenu;
  var ShortK,df: word;
  label MLoop;
begin
  wMouseHide;
  Item[curr].Show(size,Colors);

  MLoop:

    ShortK:=Item[curr].GetShortCutKey;
    if ShortK<>0 then begin
      Item[curr].CurMove(ShortK-Item[curr].curr,Colors);
      CmdGet:=(curr shl 8)+Item[curr].curr;
      Item[curr].Hide(size,Colors);
      wMouseShow;
      exit;
    end;

    {temporary key screen capturer, ctrl+alt+c}
  {note that in implementation part of unit, u_files is only for this:}
    if (k[kyAlt] and k[kyCtrl] and k[kyC]) then begin
      CreateFile('scrncap.dat');
      openfile('scrncap.dat',67);
     { wmousehide;}
      portw[$3C4]:=$F02;
      port[$3CE]:=4;
      for df:=0 to 3 do begin
        port[$3CF]:=df;
        writefile(67, ptr($A000,0), 38400);
      end;
      port[$3CE]:=5;
      port[$3CF]:=0;
{      wmouseshow;}
      closefile(67);
      sound(1000);
      delay(40);
      nosound;
    end;
  {end of screen capturer}





    if k[kyLeft] then MenuCheckMove(-1);
    if k[kyRight] then MenuCheckMove(1);
    if k[kyUp] then Item[curr].CurMove(-1,Colors);
    if k[kyDown] then Item[curr].CurMove(1,Colors);
    if k[kyEND] then Item[curr].CurMove(Item[curr].LastMenuItem-Item[curr].curr,Colors);
    if k[kyHOME] then Item[curr].CurMove(Item[curr].LastMenuItem+1,Colors);

    if k[kyENTER] then begin
      CmdGet:=(curr shl 8)+Item[curr].curr;
      Item[curr].Hide(size,Colors);
      wMouseShow;
      exit;
    end;

    if k[kyESC] then begin
      CmdGet:=0;
      Item[curr].Hide(size,Colors);
      wMouseShow;
      exit;
    end;
  goto MLoop;

end;
procedure TMenuBar.MenuCheckMove(MenuD: integer);
begin
  Item[curr].Hide(size,Colors);
  inc(curr,MenuD);
  if curr<1 then curr:=NumItems;
  if curr>NumItems then curr:=1;
  Item[curr].Show(size,Colors);
  delay(50);
end;
destructor TMenuBar.done;
begin
end;


constructor TMenuItem.Init;
begin
  Str1:=iStr1;
  Str2:=iStr2;
  ShortCutKey:=iShortCutKey;
  Hot:=iHot;
end;


constructor TMenu.Init(iHead: string; iCol,iWid: integer; items: PMenuItem);
  var temp2: PMenuItem;
begin
  curr:=1;

  col:=iCol; wid:=iWid;
  Header:=iHead;
  head:=items;

  { calculate height: }
  height:=4;
  temp:=head;
  while temp<>nil do begin {merge}
    temp^.y:=Height+10;
    if temp^.Str1=Seperator then inc(Height,7) else inc(Height,10);
    temp:=temp^.next;
  end;
  inc(Height,3);
  { calculate prev's: }
  temp:=head;
  if head<>nil then head^.prev:=nil;
  while temp<>nil do begin
    temp2:=temp;
    temp:=temp^.next;
    if temp<>nil then temp^.prev:=temp2;
  end;

end;
procedure TMenu.Show(mSize: integer; mColors: TMenuColorRec);
  var Ty  : integer;
begin

  SaveImage(mcol-3,10,mcol+wid,10+Height+3);
{  s:=ImageSize(0,0,wid+3,Height+3);
  GetMem(MenuSave, s);
  GetImage(mcol-3,10,mcol+wid,10+Height+3,MenuSave^);}

  setcolor(mColors.Normal.fore);
  rectangle(mcol-3,13,mcol+wid-3,13+Height);
  setfillstyle(solidfill,mColors.Normal.back);
  bar(mcol,10,mcol+wid,10+Height);
  rectangle(mcol,10,mcol+wid,10+Height);

  Ty:=14;

  temp:=head;
  while temp<>nil do begin
    if temp^.Str1=seperator then begin
      setcolor(mColors.Normal.fore);
{      inc(Ty,3);}
      line(mcol,temp^.y+3,mcol+wid,temp^.y+3);
{      inc(Ty,3);}
    end else begin
      MenuPrint(mcol+8,temp^.y,temp^.Str1,mColors,false);
      MenuPrint((mcol+wid)-73,temp^.y,temp^.Str2,mColors,false);
      {CurPrint(mSize,mColors,false);}
{      inc(Ty,10);}
    end;

    temp:=temp^.next;
  end;

  CurMove(0,mColors);

end;

procedure TMenu.Hide;
begin
{  s:=ImageSize(0,0,wid+3,Height+3);
  PutImage(mcol-3,10,MenuSave^,NormalPut);
  FreeMem(MenuSave, s);}
  RestoreImage;
end;

procedure TMenu.ItemPrint(ItemNum: integer; mColors: TMenuColorRec; Selected: boolean);
begin

  if Selected then
    setfillstyle(solidfill,mColors.Selected.Back)
  else
    setfillstyle(solidfill,mColors.Normal.Back);
  {endif}
  bar(mcol+1,PItem(ItemNum)^.y,mcol+wid-1,PItem(ItemNum)^.y+10);

  MenuPrint(mcol+8,PItem(ItemNum)^.y,PItem(ItemNum)^.Str1,mColors,Selected);
  MenuPrint((mcol+wid)-73,PItem(ItemNum)^.y,PItem(ItemNum)^.Str2,mColors,Selected);
end;


procedure TMenu.CurMove(cD: integer; mColors: TMenuColorRec);
begin
  {bar}
  ItemPrint(curr,mColors,false);
  repeat
    curr:=curr+cD;
    if curr<1 then curr:={Height}LastMenuItem;
    if curr>LastMenuItem then curr:=1;
  until PItem(curr)^.Str1<>seperator;
  ItemPrint(curr,mColors,true);
  delay(120);
end;

function TMenu.LastMenuItem;
  var count: integer;
begin
  count:=0;
  temp:=head;
  while temp<>nil do begin
    inc(count);
    temp:=temp^.next;
  end;
  LastMenuItem:=count;
end;

function TMenu.PItem(ItemNum: integer): PMenuItem;
  var count: integer;
begin
  temp:=head;
  count:=1;
  while (temp<>nil) and (count<>ItemNum) do begin
    inc(count);
    temp:=temp^.next;
  end;
  PItem:=temp;
end;

function TMenu.GetShortCutKey: integer;
  var Num,count: integer;
begin
  temp:=head;
  Num:=0; count:=0;
  while temp<>nil do begin
    inc(count);
    if k[temp^.ShortCutKey] then Num:=count;
    temp:=temp^.next
  end;
  GetShortCutKey:=Num;
end; {--------------------------------------------[ TMenu.GetShortCutKey ]--}

function TMenu.CheckHotKey: word;
var Num,Count: integer;
begin
  temp:=head;
  count:=0;
  Num:=0;
  while temp<>nil do begin
    inc(count);
    { Check if item hot keys are pressed }

    {if k[temp^.Hot2] and (
       (k[kyALT]  and (temp^.Hot1=kyALT)) or
       (k[kyCTRL] and (temp^.Hot1=kyCTRL)) or
       ((k[kyLSHIFT] or k[kyRSHIFT]) and (temp^.Hot1=kySHIFT)) or
       ((not k[kyALT]) and (not k[kyCTRL]) and (not(k[kyLSHIFT] or k[kyRSHIFT])) and (temp^.Hot1=NoHotKey))       )
    then Num:=count;}

{    if temp^.Hot1=NoHotKey then begin
      if k[] and k[] then Num:=count;
    end else begin
      if k[] then Num:=count;
    end;}

{    if
     ((temp^.Hot1=NoHotKey) and k[temp^.Hot2] and
      not (k[kyShift] or k[kyAlt] or k[kyCtrl]))
    or
     ( (temp^.Hot1<>NoHotKey) and (temp^.Hot1<>kyShift) and k[temp^.Hot1] and k[temp^.Hot2])
    or
     ( (temp^.Hot1=kyShift) and k[kyShift] and k[temp^.Hot2])
    then Num:=count;}

    {REDO  }


    temp:=temp^.next;
  end;
  CheckHotKey:=Num;
end; {-----------------------------------------------[ TMenu.CheckHotKey ]--}

destructor TMenu.done;
begin

end;

procedure MenuPrint(x,y: integer; Str: string; mColors: TMenuColorRec; Selected: boolean);
{ Special PrintString routine that interprets menu special characters }
  var i: integer; tc: TColor;
begin
 { MoveTo(x,y);}
  MoveTo(x,y);
  for i:=1 to length(Str) do begin
    if Selected then tc:=mColors.Selected else tc:=mColors.Normal;

    if Copy(Str,i,1)='~' then begin
      if Selected then tc:=mColors.SelectedShortCut else tc:=mColors.ShortCut;
      inc(i);
    end;
    if Copy(Str,i,1)='/' then begin
      ColorPrint('  ',tc.fore,tc.back);
      {inc(x,2);}
    end else begin
      ColorPrint(Copy(Str,i,1),tc.fore,tc.back);
{      inc(x);}
    end;
  end;
end;

procedure ColorPrint(Str: string; c1,c2: byte);
  var oldX,oldY: integer;
begin
  setfillstyle(solidfill,c2);
  OldX:=GetX; OldY:=GetY;
  bar(OldX,OldY,Oldx+TextWidth(Str),Oldy+TextHeight(Str)+1);
  MoveTo(OldX,OldY+1);
  setcolor(c1);
  outtext(Str);
  MoveTo(GetX,GetY-1);
end;


function NewItem(iStr1,iStr2: string; iShortCutKey: byte; iHot: HotKeyRec; NextItem: PMenuItem):PMenuItem;
  var TempItem: PMenuItem;
begin
  TempItem:=new(PMenuItem, init(iStr1,iStr2,iShortCutKey,iHot ));
  TempItem^.next:=NextItem;
  NewItem:=TempItem;
end;
function NewLine(NextItem: PMenuItem):PMenuItem;
  var TempItem: PMenuItem;
begin
  TempItem:=new(PMenuItem, init(Seperator,'',NoShortCutKey,NoHotKey));
  TempItem^.next:=NextItem;
  NewLine:=TempItem;
end;


end.