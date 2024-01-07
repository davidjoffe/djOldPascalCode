{$G+,S-}
unit e_items;
{ David Joffe '94/12 }
{ Some of the items for ED }

interface

uses w_item,uo_obj,graph
     ,ed_data,e_gen;

const
  pic_boxX=16*litX;
  pic_boxY=8*litY;
type
  PGrafClipBoard=^TGrafClipBoard;
  TGrafClipBoard=object(TItem)
{    DataP: Ppicture;
    Data2P: Ppicture;}
    main_clip,map_clip: ppicture;
    constructor init(x1,y1,x2,y2: integer);
    procedure Show; virtual;
    procedure SetClipData(iDataP,iData2P: Ppicture);
    destructor done; virtual;
{    function GetClipData: PData;}
  end;

  PViewIso=^TViewIso;
  TViewIso=object(TItem)
    gData: PLocData;
    Datas: Ppicture;
    x,y,xo,yo: integer;
    constructor init(x1,y1,x2,y2,ix,iy,ixo,iyo:integer; igData: PLocData; iDatas: Ppicture);
    procedure Show; virtual;
  end;

  {Rectangular box with 128 pictures in}
  Ppic_box=^Tpic_box;
  Tpic_box=object(TItem)
    DataP: Ppicture;
    PicPressed: integer;
    ButPressed: integer;
    constructor Init(x1,y1,iRetCmd: integer; GrafData: Ppicture);
    procedure Show; virtual;
    procedure HandleMouse(x,y,b: integer); virtual;
  end;

  PPicSelection=^TPicSelection;
  TPicSelection=object(TItem)
    {big1list lit2list}       {lef right}
    Data1List,Data2List : array[0..1] of Ppicture;
    DataNum             : array[0..1] of Byte;
    constructor Init(x1,y1,iRetCmd: integer);
    {big} {lit}
    procedure SetLeftData (iDataa,iDatab: Ppicture; iNum: integer);
    procedure SetLeftNum  (iNum: integer);
    procedure SetRightNum (iNum: integer);
    procedure SetRightData(iDataa,iDatab: Ppicture; iNum: integer);
    procedure ShowLeftData;
    procedure ShowRightData;
    procedure Show; virtual;
  end;


implementation
uses w_mouse,u_useful,crt;
(*--------------------------------------------------------------------------*)
constructor TGrafClipBoard.init(x1,y1,x2,y2: integer);
begin
  TItem.init(x1,y1,x2,y2,0);
  main_clip:=nil; map_clip:=nil;
end;
(*--------------------------------------------------------------------------*)
destructor TGrafClipBoard.done;
begin
  if (main_clip <> nil) then dispose(main_clip, done);
  if (map_clip <> nil) then dispose(main_clip, done);
end;
(*--------------------------------------------------------------------------*)
procedure TGrafClipBoard.Show;
  var i,j,n1,n2,index: integer;
begin
  with r do TItem.FillBackground(1,0,a.x,a.y,b.x,b.y);

  if (main_clip=nil) or (map_clip=nil) then exit;

  n1:=main_clip^.YSize;
  n2:=main_clip^.XSize;

  if n1>r.size.y then n1:=r.size.y;
  if n2>r.size.x-litX then n2:=r.size.x-litX;

  {put small image}
{  putimage(r.a.x+n2+1,r.a.y+3,map_clip^.buffer^[0],normalput);}
  Draw256(pimagearr(map_clip^.buffer),r.a.x+n2+1,r.a.y+3,LITX,LITY);
  {this one we cant just put in case the image is too big for the board}
  index:=4;
  for i:=0 to n1-1 do begin
    for j:=0 to n2-1 do begin
      PutPixel(r.a.x+j,r.a.y+i,main_clip^.buffer^[index]);
      inc(index);
    end;
  end;
end;
(*--------------------------------------------------------------------------*)
procedure TGrafClipBoard.SetClipData(iDataP,iData2P: Ppicture);
  var i: integer;
begin
{  DataP:=iDataP;}
  if main_clip=nil then begin
  {  NewData(DataP,1);
    NewData(Data2P,1)}
  end else begin
    Dispose_picture(main_clip);
    Dispose_picture(map_clip);
  end;

  New_picture(main_clip,iDataP^.Xsize*iDataP^.ysize);
  New_picture(map_clip,litX*litY);

  main_clip^.loadXY(iDataP^.XSize,iDataP^.Ysize);
  map_clip^.loadXY(litX,litY);

  for i:=0 to iDataP^.size+3 do main_clip^.put_real(i,iDataP^.get_real(i));
  for i:=0 to iData2P^.size+3 do map_clip^.put_real(i,iData2P^.get_real(i));

  wMouseHide;
  Show;
  wMouseShow;
end;
{procedure TGrafClipBoard.GetClipData: PData;
begin

end;}


(*--------------------------------------------------------------------------*)
constructor TViewIso.init(x1,y1,x2,y2,ix,iy,ixo,iyo:integer; igData: PLocData; iDatas: Ppicture);
begin
  TItem.init(x1,y1,x2,y2,0);
  x:=ix; y:=iy;
  xo:=ixo; yo:=iyo;
  Datas:=iDatas;
  gData:=igData;
end;
(*--------------------------------------------------------------------------*)
procedure TViewIso.Show;
  var
    xp,yp,i,j,l,m,n1,n2,t : integer;
    index                 : integer;
    picVal,PicHeight      : integer;
    PicPtr                : Ppicture;
begin
  with r do FillBackground(SOLIDFILL,BLACK,a.x,a.y,b.x,b.y);

  xp:=r.a.x+(r.size.x div 2)-(BlockWidth);
  yp:=r.size.y-(BlockX*12)+38;

  n1:=12;
  n2:=12;
{  if n1>x then n1:=x;}
{  if n2>y then n2:=y;}

  for i:=0 to SmallerOf(n2,y)-1 do begin
    for j:=0 to SmallerOf(n1,x)-1 do begin
      PicVal:=gData^.get((i+yo)*x+(j+xo))+1;
      PicHeight:=gData^.HeightData^[(i+yo)*x+(j+xo)];
      xp:=xp+BlockX;
      yp:=yp+BlockY;
      index:=4;
      PicPtr:=picture_Ptr(Datas,PicVal);
      yp:=yp-PicPtr^.YSize-PicHeight*BlockY;
      for l:=0 to PicPtr^.YSize-1 do begin
        for m:=0 to PicPtr^.XSize-1 do begin
          t:=picptr^.buffer^[index];
          if t<>255 then
            PutPixel(xp+m,yp+l,t);
          inc(index);
        end;
      end;
      yp:=yp+PicHeight*BlockY+picptr^.YSize;
    end;
    xp:=xp-((SmallerOf(n1,x)+1){13}*BlockX);
    yp:=yp-BlockY*{11}(SmallerOf(n1,x)-1);
  end;
end;

(*--------------------------------------------------------------------------*)
procedure Tpic_box.HandleMouse(x,y,b: integer);
begin
  ButPressed:=b;
  PicPressed:=((y-r.a.y)div LitY)*16+(x-r.a.x)div LitX{+1};
end;


(*-[ TPICSELECTION ]--------------------------------------------------------*)
procedure TPicSelection.SetLeftNum(iNum: integer);
begin
  DataNum[0]:=iNum;
{  wMouseHide;
  ShowLeftData;
  wMouseShow;}
end;
(*--------------------------------------------------------------------------*)
procedure TPicSelection.SetRightNum(iNum: integer);
begin
  DataNum[1]:=iNum;
{  wMouseHide;
  ShowRightData;
  wMouseShow;}
end;

(*--------------------------------------------------------------------------*)
constructor TPicSelection.init(x1,y1,iRetCmd: integer);
  var i: integer;
begin
  TItem.init(x1,y1,x1+(BlockWidth*2)+7,y1+BlockWidth+litY+5,iRetCmd);
  for i:=0 to 1 do Begin
    Data1List[i]:=nil;
    Data2List[i]:=nil;
    DataNum[i]:=$FF;
  end;
end;
(*--------------------------------------------------------------------------*)
procedure TPicSelection.SetLeftData(iDataa,iDatab: Ppicture; iNum: integer);
begin
  Data1List[0]:=iDataa;
  Data2List[0]:=iDatab;
  SetLeftNum(iNum);
end;
(*--------------------------------------------------------------------------*)
procedure TPicSelection.SetRightData(iDataa,iDatab: Ppicture; iNum: integer);
begin
  Data1List[1]:=iDataa;
  Data2List[1]:=iDatab;
  SetRightNum(iNum);
end;
(*--------------------------------------------------------------------------*)
procedure TPicSelection.Show;
begin
  with r do FillBackGround(1,0,a.x,a.y,b.x,b.y);
  with r do ItemRectangle(10,a.x,a.y,b.x,b.y);
  with r do line(a.x+(size.x div 2),a.y,a.x+(size.x div 2),b.y);
  ShowLeftData;
  ShowRightData;
end;
(*--------------------------------------------------------------------------*)
procedure TPicSelection.ShowLeftData;
  var PicPtr1,PicPtr2: Ppicture;
      i,j,index: integer;
begin
  with r do FillBackGround(1,0,a.x+1,a.y+1,a.x+(size.x div 2)-1,b.y-1);

  setcolor(15);
  outtextxy(r.a.x+15,r.a.y+1,IntStr(DataNum[0],10));

  if (Datanum[0]=$FF) then begin exit; end;
  PicPtr1:=picture_Ptr(Data1List[0],DataNum[0]+1);
  PicPtr2:=picture_Ptr(Data2List[0],DataNum[0]+1);

  {if screen colors is set to 255 then pic can be put}
{  if (getmaxcolor = 255) then begin
    putimage(r.a.x+2,r.a.y+2,picptr2^.buffer^[0],normalput);
  end else begin
    for i:=0 to LITY-1 do begin
      for j:=0 to LITX-1 do begin
        PutPixel(r.a.x+2+j,r.a.y+2+i,PicPtr2^.get(i*LITX+j));
      end;
    end;
  end;  }
  Draw256(pimagearr(PicPtr2^.buffer),r.a.x+2,r.a.y+2,LITX,LITY);

  for i:=0 to SmallerOf(BlockWidth,PicPtr1^.YSize)-1 do begin
    for j:=0 to SmallerOf(BlockWidth,PicPtr1^.XSize)-1 do begin
      PutPixel(r.a.x+2+j,r.a.y+2+litY+i+3,PicPtr1^.get(i*PicPtr1^.XSize+j));
    end;
  end;
end;
(*--------------------------------------------------------------------------*)
procedure TPicSelection.ShowRightData;
  var PicPtr1,PicPtr2: Ppicture;
      i,j,index: integer;
begin
  with r do FillBackGround(1,0,a.x+(size.x div 2)+1,a.y+1,b.x-1,b.y-1);

  setcolor(15);
  outtextxy(r.a.x+(r.size.x div 2)+15,r.a.y+1,IntStr(DataNum[1],10));

  if (Datanum[1]=$FF) then exit;
  PicPtr1:=picture_Ptr(Data1List[1{?}],DataNum[1]+1);
  PicPtr2:=picture_Ptr(Data2List[1],DataNum[1]+1);
  if (PicPtr1=nil) or (PicPtr2=nil) then begin
    {make a noise}
    i:=300;
    repeat
      beep(300,i);
      i:=i+20;
    until i>700;
  end;

  {Draw smaller one}
  Draw256(pimagearr(PicPtr2^.buffer),r.a.x+2+(r.size.x div 2),r.a.y+2,LITX,LITY);
  {Draw bigger one, pixel by pixel (because may not fit in)}
  for i:=0 to SmallerOf(BlockWidth,PicPtr1^.YSize)-1 do begin
    for j:=0 to SmallerOf(BlockWidth,PicPtr1^.XSize)-1 do begin
      PutPixel(r.a.x+2+(r.size.x div 2)+j,r.a.y+2+litY+i+3,PicPtr1^.get(i*PicPtr1^.XSize+j));
    end;
  end;
end;


(*--------------------------------------------------------------------------*)
constructor Tpic_box.Init(x1,y1,iRetCmd: integer; GrafData: Ppicture);
begin
  TItem.init(x1,y1,x1+pic_boxX+2,y1+pic_boxY+2,iRetCmd);
  DataP:=GrafData;
  PicPressed:=0;
end;

(*--------------------------------------------------------------------------*)
procedure Tpic_box.Show;
  var num,i,j,k,l,c: integer;
    TempDataP: Ppicture;
begin
  with r do TItem.FillBackground(10,8,a.x,a.y,b.x,b.y);
  with r do Itemrectangle(7,a.x,a.y,b.x,b.y);
  if (DataP=nil) then exit;
  num:=pictureListSize(DataP);
  c:=0;
  for i:=0 to 7 do begin
    for j:=0 to 15 do begin
      inc(c);
      if c>num then begin
        {setcolor(8);}
        {line(1+r.a.x+j*litX,1+r.a.y+i*litY,1+r.a.x+j*litX+litX,1+r.a.y+i*litY+litY);
        line(1+r.a.x+j*litX,1+r.a.y+i*litY+litY,1+r.a.x+j*litX+litX,1+r.a.y+i*litY);}
{        setcolor(1);
        rectangle(r.a.x+j*litX,r.a.y+i*litY,r.a.x+j*litX+litX,r.a.y+i*litY+litY);}
      end else begin
        TempDataP:=picture_Ptr(DataP,c);
        {for k:=0 to litY-1 do begin
          for l:=0 to litX-1 do begin
            PutPixel(1+r.a.x+j*litX+l,1+r.a.y+i*litY+k,TempDataP^.get(k*TempDataP^.XSize+l));
          end;
        end;}

       {putimage(1+r.a.x+j*litX,1+r.a.y+i*litY,tempdataP^.buffer^[0],normalput);}
       Draw256(pimagearr(tempdataP^.buffer),1+r.a.x+j*litX,1+r.a.y+i*litY,LITX,LITY);

       setcolor(8);
       rectangle(1+r.a.x+j*litX,1+r.a.y+i*litY,1+r.a.x+j*litX+litX,1+r.a.y+i*litY+litY);
      end;
    end;
  end;
end;

end.
