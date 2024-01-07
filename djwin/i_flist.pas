{$G+}
unit w_items3;
{ David Joffe '94/12
{ More items for DJWin }

{ file List box: list types=filenames}

interface

uses
  crt,w_item,uo_obj,graph;

const
  FilesMax=256;

var
  filenames: array[1..FilesMax] of string[12];
  DFileName: string;

procedure SwapFileNames(index1,index2: integer);
type
  {lists, with scroll bar, single text items}
  TFileListBox=object(TItem)
    offset: integer;
    numitems: integer;

    ItemsThatFit: integer;
    c:TColor;
    constructor Init(x1,y1,x2,y2,c1,c2,iRetCmd: integer; iWild: string);

    procedure GetFileList(WildCard: string);
    procedure Show; virtual;
    procedure ShowItems;
    procedure HandleMouse(x,y,b: integer); virtual;
    procedure MoveOffset(OffD: integer);
  end;

  TIntRange=object(TItem)
    Number,NumMax,NumMin,Colour: integer;
    constructor init(x1,y1,n,nMin,nMax: integer);
    procedure Show; virtual;
    procedure ShowNum;
    procedure HandleMouse(x,y,b: integer); virtual;
  end;

implementation
uses w_mouse,u_files,u_useful;

constructor TIntRange.init(x1,y1,n,nMin,nMax: integer);
begin
  TItem.init(x1,y1,x1+32,y1+30,0);
  Colour:=15;
  Number:=n;
  NumMax:=nMax;
  NumMin:=nMin;
end;
procedure TIntRange.Show;
begin
  setfillstyle(1,0);
  with r do bar(a.x,a.y,b.x,b.y);
  setcolor(Colour);
  with r do begin
    rectangle(a.x,a.y,b.x,b.y);
    line(a.x,a.y+10,b.x,a.y+10);
    line(a.x,b.y-10,b.x,b.y-10);
    outtextxy(a.x+12,a.y+2,#24);
    outtextxy(a.x+12,a.y+22,#25);
  end;
  ShowNum;
end;
procedure TIntRange.ShowNum;
begin
  setfillstyle(1,0);
  with r do bar(a.x+1,a.y+11,b.x-1,a.y+19);
  setcolor(Colour);
  outtextxy(r.a.x+2,r.a.y+12,IntStr(Number,10));
end;
procedure TIntRange.HandleMouse(x,y,b: integer);
begin
  if PointIn(x,y,r.a.x,r.a.y+11,r.b.x,r.a.y+19) then exit;
  if y-r.a.y<=10 then inc(Number) else dec(Number);
  if Number<NumMin then Number:=NumMin;
  if Number>NumMax then Number:=NumMax;
  wMouseHide;
  ShowNum;
  wMouseShow;
  wWaitForMouseRelease;
end;

{== LIST BOX ===================================================================}
procedure SwapFileNames(index1,index2: integer);
  var t: string[12];
begin
  t:=filenames[index1];
  filenames[index1]:=filenames[index2];
  filenames[index2]:=t;
end;
{== LIST BOX ===================================================================}
procedure TFileListBox.GetFileList(WildCard: string);
  var s: string;
    i,j: integer;
begin
  numitems:=0; offset:=0;
  for i:=1 to FilesMax do filenames[i]:='[file '+IntStr(i,10)+'].......';

  s:=FirstFileNameMatch(WildCard);
  if s='' then begin
    exit;
  end;

  repeat
    inc(numitems);
    filenames[numitems]:=s;
    s:=NextFileNameMatch;
  until (s='') or (numitems=FilesMax);

  for i:=1 to numitems-1 do
    for j:=i+1 to numitems do
      if filenames[i]>filenames[j] then swapFileNames(i,j);
end;
constructor TFileListBox.init(x1,y1,x2,y2,c1,c2,iRetCmd: integer; iWild: string);
begin
  TItem.init(x1,y1,x2,y2,iRetCmd);
  {items:=iItems;}
  c.setColor(c1,c2);
  offset:=0;
  numitems:=0;
  ItemsThatFit:=(y2-y1-3) div 10;
  GetFileList(iWild);
end;
procedure TFileListBox.Show;
begin
  setfillstyle(1,c.back);
  with r do bar(a.x,a.y,b.x,b.y);
  setcolor(c.fore);
  with r do rectangle(a.x,a.y,b.x,b.y);
  line(r.b.x-10,r.a.y,r.b.x-10,r.b.y);
  line(r.b.x-10,r.a.y+10,r.b.x,r.a.y+10);
  line(r.b.x-10,r.b.y-10,r.b.x,r.b.y-10);
  outtextxy(r.b.x-9,r.a.y+1,'');
  outtextxy(r.b.x-9,r.b.y-9,'');
  ShowItems;
end;
procedure TFileListBox.ShowItems;
  var i: integer;
      num: integer;
begin
  setfillstyle(1,c.back);
  with r do bar(a.x+1,a.y+1,b.x-11,b.y-1);
  setcolor(c.fore);
  MoveTo(r.a.x+4,r.a.y+3);
  for i:=1 to ItemsThatFit do begin
    outtext(filenames[i+offset]);
    MoveTo(r.a.x+4,GetY+10);
  end;
end;
procedure TFileListBox.HandleMouse(x,y,b: integer);
begin
  if PointIn(x,y,r.b.x-10,r.a.y,r.b.x,r.a.y+10) then MoveOffset(-1);
  if PointIn(x,y,r.b.x-10,r.b.y-10,r.b.x,r.b.y) then MoveOffset(1);
  if PointIn(x,y,r.a.x,r.a.y+1,r.b.x-11,r.b.y-1) then begin
    DFileName:=FileNames[(((y-r.a.y)-2) div 10)+offset+1];
  end;
end;
procedure TFileListBox.MoveOffset(OffD: integer);
begin
  offset:=offset+OffD;
  if offset<0 then begin offset:=0; exit; end;
  if offset>FilesMax-ItemsThatFit then begin offset:=FilesMax-ItemsThatFit; exit; end;
  DFileName:='';
  delay(40);
  wMouseHide;
  ShowItems;
  wMouseShow;
end;


end.