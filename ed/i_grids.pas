{$G+}
unit i_grids;
{ David Joffe '94/12 }
{ library of Item objects: see W_ITEM.PAS }

{ Grid       }
  { GrafGrid   } {=pasgrid}
  { PasGrid  x }
  { PicGrid    }

    { LocGrid    }

interface

uses
  crt,w_item,uo_obj,graph,ed_data,w_files;

type
  PFillArr=^TFillArr;
  TFillArr=array[0..32766] of integer;

{  PGridArr=^TGridArr;
  TGridArr=array[0..32767] of byte;}
  PGrid=^TGrid;
  TGrid=object(TItem)
{    NOfs: integer;   {offset into data to set data}

    data_ptr: ppicture;

    Dim,S: TPoint;  {Max=grid dimensions; S=size of blockies}
    c: byte; {color of grid lines}

    ShowGrid: boolean;

    mx,my,mb: integer;
    o: TPoint;

    constructor Init(x1,y1,x2,y2,Dx,Dy,bx,by,iC,iRetCmd: integer; iShowGrid: boolean);
    procedure Show; virtual;
    procedure HandleMouse(x,y,b: integer); virtual;
    {after gridin press, to return left or right button}
    function GetGridButtonPress: integer;
    function GetGridIndex: integer;

{    procedure ShowBlockIndex(iIndex: integer);}
    procedure ShowBlock(x,y: integer); virtual;
    procedure Zoom(ZoomInc: integer); virtual;
    procedure View; virtual;

    procedure FillData(xsize,ysize: integer; d1,d2: byte);
    procedure SepData(xsize,ysize: integer; d1,d2: byte);

    procedure DrawGridBlock(x,y: integer);
    procedure SetData(d1,d2: byte);
{    procedure ReSize(nx,ny)}
    procedure MoveOffset(xd,yd: integer);
    procedure DrawGrid; virtual;
    destructor done; virtual;
  end;


  PGrafGrid=^TGrafGrid;
  TGrafGrid=object(TGrid)
    procedure ShowBlock(x,y: integer); virtual;
    procedure View; virtual;
  end;
  PPasGrid=^TPasGrid;
  TPasGrid=object(TGrafGrid)
    constructor Init(x1,y1,x2,y2,Dx,Dy,bx,by,iC,iRetCmd: integer; iShowGrid: boolean);
  end;
  PPicGrid=^TPicGrid;
  TPicGrid=object(TGrid)
    PicDataList: Ppicture;
    procedure ShowBlock(x,y: integer); virtual;
    procedure Zoom(ZoomInc: integer); virtual;
  end;
  PLocGrid=^TLocGrid;
  TLocGrid=object(TPicGrid)
    locDataP: PLocData;
    HeightsOn: boolean;
    constructor Init(x1,y1,x2,y2,Dx,Dy,bx,by,iC,iRetCmd: integer; iShowGrid: boolean);
    procedure SetHeights(iHeightsOn: boolean);
    procedure AdjustHeight(index,Diff: integer);
    procedure SetHeight(index,NewHt: integer);
    procedure ShowBlock(x,y: integer); virtual;
  end;


implementation

uses w_mouse,u_useful,u_keys,e_gen;

destructor TGrid.done;
begin
{  if (data_ptr <> nil) then data_ptr^.done;}
end;

constructor TPasGrid.init(x1,y1,x2,y2,Dx,Dy,bx,by,iC,iRetCmd: integer; iShowGrid: boolean);
begin
  TGrid.Init(x1,y1,x2,y2,Dx,Dy,bx,by,iC,iRetCmd,iShowGrid);
end;

constructor TLocGrid.Init(x1,y1,x2,y2,Dx,Dy,bx,by,iC,iRetCmd: integer; iShowGrid: boolean);
begin
  TGrid.Init(x1,y1,x2,y2,Dx,Dy,bx,by,iC,iRetCmd,iShowGrid);
  HeightsOn:=false;
end;

procedure TLocGrid.SetHeight(index,NewHt: integer);
  var ax,ay: integer;
begin
  LocDataP^.HeightData^[index]:=NewHt;
  ax:=(index mod Dim.X)-o.x;
  ay:=(index div Dim.X)-o.y;
  wMouseHide;
  ShowBlock(ax,ay);
  if ShowGrid then DrawGridBlock(ax,ay);
  wMouseShow;
  delay(20);
end;
procedure TLocGrid.AdjustHeight(index,Diff: integer);
  var{ BlocksThatFitIn: TPoint;}
    ax,ay: integer;
begin
{  BlocksThatFitIn.X:=(r.size.x-42) div s.x;
  BlocksThatFitIn.Y:=(r.size.y-4) div s.y;
  if BlocksThatFitIn.X>Dim.X then BlocksThatFitIn.X:=Dim.X;
  if BlocksThatFitIn.Y>Dim.Y then BlocksThatFitIn.Y:=Dim.Y;}

  LocDataP^.HeightData^[index]:=LocDataP^.HeightData^[index]+Diff;
  if LocDataP^.HeightData^[index]<HeightMin then LocDataP^.HeightData^[index]:=HeightMin;
  if LocDataP^.HeightData^[index]>HeightMax then LocDataP^.HeightData^[index]:=HeightMax;
  wWaitForMouseRelease;
  ax:=(index mod Dim.X)-o.x;
  ay:=(index div Dim.X)-o.y;
  wMouseHide;
  ShowBlock(ax,ay);
  if ShowGrid then DrawGridBlock(ax,ay);
{      ShowBlock(ax,ay);
      if ShowGrid then DrawGridBlock(ax,ay);}
  wMouseShow;
end;
procedure TLocGrid.SetHeights(iHeightsOn: boolean);
begin
  HeightsOn:=iHeightsOn;{  DrawGrid;}
end;
procedure TLocGrid.ShowBlock(x,y: integer);
  var i,j,index,ndx: integer;
    PicPtr: Ppicture;
    num: integer;
begin
  index:=0;
  ndx:=(y+o.y)*Dim.x+(x+o.x);
  num:=Data_Ptr^.get(ndx);
  PicPtr:=picture_Ptr(PicDataList, num+1);

  {for i:=0 to litY-1 do begin
    for j:=0 to litX-1 do begin
      PutPixel(r.a.x+2+x*s.x+j,r.a.y+2+y*s.y+i,PicPtr^.get(index));
      inc(index);
    end;
  end;}

  {putimage(r.a.x+2+x*s.x,r.a.y+2+y*s.y,PicPtr^.buffer^,normalput);}
  Draw256(pimagearr(PicPtr^.buffer),r.a.x+2+x*s.x,r.a.y+2+y*s.y,LITX,LITY);

  if HeightsOn then begin
    WriteNums(r.a.x+4+x*s.x,r.a.y+5+y*s.y,locDataP^.HeightData^[ndx]);
  end;
end;

{== PICTURE GRID ===========================================================}
procedure TPicGrid.ShowBlock(x,y: integer);
  var i,j,index: integer;
    PicPtr: Ppicture;
    num: integer;
begin
  index:=0;
  num:=data_ptr^.get(y+o.y)*Dim.x+(x+o.x);  {!!!!!!!!!!!!!!!!44444}
  PicPtr:=picture_Ptr(PicDataList, num+1);
  Draw256(pimagearr(PicPtr),r.a.x+2+x*s.x+j,r.a.y+2+y*s.y+i,LITX,LITY);
  {for i:=0 to litY-1 do begin
    for j:=0 to litX-1 do begin
      PutPixel(r.a.x+2+x*s.x+j,r.a.y+2+y*s.y+i,PicPtr^.get(index));{putim}
      {inc(index);
    end;
  end;}
  {PutImage!!}
end;
procedure TPicGrid.Zoom(ZoomInc: integer);
begin
  {un-zoomable}
end;
{== GRAPHICS GRID ==========================================================}
procedure TGrafGrid.ShowBlock(x,y: integer);
begin
  setfillstyle(1,Data_ptr^.get((y+o.y)*dim.x+(x+o.x)));
  with r do bar(a.x+2+x*s.x,a.y+2+y*s.y,a.x+1+x*s.x+s.x,a.y+1+y*s.y+s.y);
end;
procedure TGrafGrid.View;
  var i,j: integer;
begin
  if Data_Ptr=nil then exit;
  wMouseHide;
  setcolor(15);
  with r do rectangle(b.x-38,a.y+87,b.x-2,a.y+97);
  setfillstyle(1,0);
  with r do bar(a.x+2,a.y+2,b.x-40,b.y-2);
  for i:=0 to Data_Ptr^.YSize-1 do begin
    for j:=0 to Data_Ptr^.XSize-1 do begin
      PutPixel(r.a.x+2+j,r.a.y+2+i,Data_Ptr^.get(i*Data_Ptr^.XSize+j));
    end;
  end;
  wMouseShow;
  wWaitForMouseRelease;
  wWaitForMousePress;
  wMouseHide;
  setcolor(7);
  with r do rectangle(b.x-38,a.y+87,b.x-2,a.y+97);
  DrawGrid;
  wMouseShow;
  wWaitForMouseRelease;
end;
{== GRID ===================================================================}
constructor TGrid.Init(x1,y1,x2,y2,Dx,Dy,bx,by,iC,iRetCmd: integer; iShowGrid: boolean);
begin
  o.setXY(0,0);
  TItem.init(x1,y1,x2,y2,iRetCmd);
  Dim.SetXY(Dx,Dy);
  {XSize:=Dx; YSize:=Dy;}
  S.setxy(bx,by);
  c:=iC;
  ShowGrid:=iShowGrid;
  data_ptr:=nil;
end;
procedure TGrid.Show;
begin
  setfillstyle(1,0);
  with r do bar(a.x,a.y,b.x,b.y);
  setcolor(7);
  with r do rectangle(a.x+1,a.y+1,b.x-39,b.y-1);

  delay(100);

  setcolor(7);
  with r do begin
    outtextxy(b.x-38,a.y+2, 'ZOOM:');
    outtextxy(b.x-30,a.y+13,'IN');
    outtextxy(b.x-33,a.y+23,'OUT');
    rectangle(b.x-38,a.y+11,b.x-2,a.y+32);
    line(b.x-38,a.y+21,b.x-2,a.y+21);

    outtextxy(b.x-38,a.y+38,'MOVE:');
    outtextxy(b.x-24,a.y+50,'');
    outtextxy(b.x-36,a.y+60,'');
    outtextxy(b.x-24,a.y+60,'');
    outtextxy(b.x-12,a.y+60,#26);
    rectangle(b.x-38,a.y+58,b.x-2,a.y+70);
    rectangle(b.x-26,a.y+46,b.x-14,a.y+70);

    outtextxy(b.x-36,a.y+75,'Grid');
    if ShowGrid then setcolor(15);
    rectangle(b.x-38,a.y+74,b.x-2,a.y+84);
    setcolor(7);

    rectangle(b.x-38,a.y+87,b.x-2,a.y+97);
    outtextxy(b.x-36,a.y+89,'VIEW');
  end;

  DrawGrid;
end;
procedure TGrid.View;
begin
end;

procedure TGrid.HandleMouse(x,y,b: integer);
  var dumX,dumY,dumB: integer;
      BlocksThatFitIn: TPoint;
begin
  with r do begin
    if PointIn(x,y,b.x-38,a.y+11,b.x-2,a.y+21) then Zoom(1);
    if PointIn(x,y,b.x-38,a.y+22,b.x-2,a.y+32) then Zoom(-1);

    if PointIn(x,y,b.x-26,a.y+46,b.x-15,a.y+57) then MoveOffset(0,-1);
    if PointIn(x,y,b.x-26,a.y+58,b.x-15,a.y+69) then MoveOffset(0,1);
    if PointIn(x,y,b.x-38,a.y+58,b.x-27,a.y+69) then MoveOffset(-1,0);
    if PointIn(x,y,b.x-14,a.y+58,b.x-3,a.y+69) then MoveOffset(1,0);

    if PointIn(x,y,b.x-38,a.y+74,b.x-2,a.y+84) then begin
      ShowGrid:=not ShowGrid;
      wMouseHide;
      if ShowGrid then setcolor(15) else setcolor(7);
      rectangle(b.x-38,a.y+74,b.x-2,a.y+84);
      DrawGrid;
      wMouseShow;
      repeat wGetMouse(dumx,dumy,dumb) until dumb=0;
    end;

    if PointIn(x,y,b.x-38,a.y+87,b.x-2,a.y+97) then begin
      View;
    end;

  end;
  mx:=x; my:=y; mb:=b;

  BlocksThatFitIn.X:=(r.size.x-42) div s.x;
  BlocksThatFitIn.Y:=(r.size.y-4) div s.y;
  if BlocksThatFitIn.X>Dim.X then BlocksThatFitIn.X:=Dim.X;
  if BlocksThatFitIn.Y>Dim.Y then BlocksThatFitIn.Y:=Dim.Y;
  if not PointIn(mx,my,r.a.x+2,r.a.y+2,r.a.x+1+BlocksThatFitIn.x*s.x,r.a.y+1+BlocksThatFitIn.y*s.y) then begin
    mb:=0;
  end;
end;
procedure TGrid.FillData(xsize,ysize: integer; d1,d2: byte);
  var
   FCount,ax,ay,cul,ncul,fx,fy,z: integer;
   FillX,FillY                  : PFillArr;
   size                         : word;
   BlocksThatFitIn              : TPoint;
  label
   FillLoop;
  procedure
   CheckPoints(cx,cy: integer);
     var
      tfx,tfy,i : integer;
      AreaDone  : boolean;
   begin
    tfx:=fx; tfy:=fy;
    fx:=fx+cx; fy:=fy+cy;
    if not PointIn(fx,fy,0,0,xsize-1,ysize-1) then begin fx:=tfx; fy:=tfy; exit; end;
    if Data_Ptr^.get((fy)*xsize+fx) <> cul then begin fx:=tfx; fy:=tfy; exit; end;
    AreaDone := false;
    for i:=1 to FCount do
      if (fx = fillx^[i]) and (fy = filly^[i]) then AreaDone :=true;
    if not AreaDone then begin
      inc(FCount);
      fillx^[fcount] := fx;
      filly^[fcount] := fy;
    end;
    fx := tfx; fy := tfy;
  end;
begin
  BlocksThatFitIn.X:=(r.size.x-42) div s.x;
  BlocksThatFitIn.Y:=(r.size.y-4) div s.y;
  if BlocksThatFitIn.X>Dim.X then BlocksThatFitIn.X:=Dim.X;
  if BlocksThatFitIn.Y>Dim.Y then BlocksThatFitIn.Y:=Dim.Y;
  if (data_ptr<>nil)
  and (PointIn(mx,my,r.a.x+2,r.a.y+2,r.a.x+1+BlocksThatFitIn.x*s.x,r.a.y+1+BlocksThatFitIn.y*s.y)) then
  begin
    wMouseHide;
    size:=xsize*ysize*2;

    GetMem(FillX,size);
    GetMem(FillY,size);

    FillChar(FillX^,size,0);
    FillChar(FillY^,size,0);
    ax:=(mx-r.a.x-2) div s.x;
    ay:=(my-r.a.y-2) div s.y;

    cul:=data_ptr^.get((ay+o.y)*xsize+(ax+o.x));
    if mb=1 then ncul:=d1 else ncul:=d2;
    if cul=ncul then begin
      FreeMem(FillX,size);
      FreeMem(FillY,size);
      wMouseShow;
      exit;
    end;
    FCount:=0;
    FillX^[0]:=ax+o.x; FillY^[0]:=ay+o.y;
    z:=0;
    FillLoop:
      fx:=FillX^[z]; fy:=FillY^[z];
      CheckPoints(-1,0);
      CheckPoints(1,0);
      CheckPoints(0,-1);
      CheckPoints(0,1);
      data_ptr^.put((FillY^[z])*xsize + (FillX^[z]),ncul);
      inc(z);
    if z<=FCount then goto FillLoop;

    FreeMem(FillX,size);
    FreeMem(FillY,size);
    DrawGrid;
    wMouseShow;
  end;
end;
procedure TGrid.SepData(xsize,ysize: integer; d1,d2: byte);
  var
   ax,ay,i,cul,ncul: integer;
   size                  : word;
   BlocksThatFitIn       : TPoint;
begin
  BlocksThatFitIn.X:=(r.size.x-42) div s.x;
  BlocksThatFitIn.Y:=(r.size.y-4) div s.y;
  if BlocksThatFitIn.X>Dim.X then BlocksThatFitIn.X:=Dim.X;
  if BlocksThatFitIn.Y>Dim.Y then BlocksThatFitIn.Y:=Dim.Y;
  if (data_ptr<>nil)
  and (PointIn(mx,my,r.a.x+2,r.a.y+2,r.a.x+1+BlocksThatFitIn.x*s.x,r.a.y+1+BlocksThatFitIn.y*s.y)) then
  begin
    wMouseHide;
    size:=xsize*ysize;
    ax:=(mx-r.a.x-2) div s.x;
    ay:=(my-r.a.y-2) div s.y;
    cul:=Data_Ptr^.get((ay+o.y)*xsize+(ax+o.x));
    if mb=1 then ncul:=d1 else ncul:=d2;
    for i:=0 to size-1 do begin
      if data_ptr^.get(i)=cul then data_ptr^.put(i,ncul);

     { if data_ptr^.buffer^[i]=cul then data_ptr^.buffer^[i]:=ncul;}
    end;
    DrawGrid;
    wMouseShow;
  end;
end;
procedure TGrid.SetData(d1,d2: byte);
  var ax,ay,index,num: integer;
      BlocksThatFitIn: TPoint;
begin
  BlocksThatFitIn.X:=(r.size.x-42) div s.x;
  BlocksThatFitIn.Y:=(r.size.y-4) div s.y;
  if BlocksThatFitIn.X>Dim.X then BlocksThatFitIn.X:=Dim.X;
  if BlocksThatFitIn.Y>Dim.Y then BlocksThatFitIn.Y:=Dim.Y;

  if (Data_ptr<>nil)
  and (PointIn(mx,my,r.a.x+2,r.a.y+2,r.a.x+1+BlocksThatFitIn.x*s.x,r.a.y+1+BlocksThatFitIn.y*s.y)) then
  begin
    ax:=(mx-r.a.x-2) div s.x;
    ay:=(my-r.a.y-2) div s.y;
    Index:=(ay+o.y)*dim.x+(ax+o.x);
    num:=data_ptr^.get(Index);
    if mb=1 then data_ptr^.put(Index,d1) else Data_Ptr^.put(Index,d2);
    if num<>Data_Ptr^.get(Index) then begin
      wMouseHide;
      ShowBlock(ax,ay);
      if ShowGrid then DrawGridBlock(ax,ay);
      wMouseShow;
    end
  end;
end;
function TGrid.GetGridButtonPress: integer;
begin
  GetGridButtonPress:=mb;
end;
function TGrid.GetGridIndex: integer;
  var num,ax,ay: integer;
begin
  num:=-1;
  if (mb<>0) then begin
    ax:=(mx-r.a.x-2) div s.x;
    ay:=(my-r.a.y-2) div s.y;
    num:=(ay+o.y)*dim.x+(ax+o.x);
  end;
  GetGridIndex:=num;
end;

procedure TGrid.ShowBlock(x,y: integer);
begin
end;
procedure TGrid.DrawGridBlock(x,y: integer);
begin
  setcolor(c);
  with r do rectangle(a.x+2+x*s.x,a.y+2+y*s.y,a.x+2+x*s.x+s.x,a.y+2+y*s.y+s.y);
end;
procedure TGrid.Zoom(ZoomInc: integer);
  var BlocksThatFitIn: TPoint;
begin
  inc(s.x,ZoomInc);
  inc(s.y,ZoomInc);
  if s.x<1 then s.x:=1;
  if s.y<1 then s.y:=1;
  if s.x>r.size.x-42 then s.x:=r.size.x-42;
  if s.y>r.size.y-4 then s.y:=r.size.y-4;
  BlocksThatFitIn.X:=(r.size.x-42) div s.x;
  BlocksThatFitIn.Y:=(r.size.y-4) div s.y;
  if BlocksThatFitIn.X>Dim.X then BlocksThatFitIn.X:=Dim.X;
  if BlocksThatFitIn.Y>Dim.Y then BlocksThatFitIn.Y:=Dim.Y;
  if o.x+BlocksThatFitIn.X>dim.x then o.setXY(Dim.X-BlocksThatFitIn.x,o.y);
  if o.y+BlocksThatFitIn.Y>dim.y then o.setXY(o.x,Dim.Y-BlocksThatFitIn.Y);
  wMouseHide;
  DrawGrid;
  wMouseShow;
end;
procedure TGrid.MoveOffset(xd,yd: integer);
  var BlocksThatFitIn: TPoint;
    oxd,oyd: integer;
begin
  oxd:=xd; oyd:=yd;
  BlocksThatFitIn.X:=(r.size.x-42) div s.x;
  BlocksThatFitIn.Y:=(r.size.y-4) div s.y;
  if (BlocksThatFitIn.X>=Dim.X) and
     (BlocksThatFitIn.Y>=Dim.Y) then exit; {if all fits on already}

  if (yd<>0) and (Dim.y<=BlocksThatFitIn.Y) then yd:=0;
  if (xd<>0) and (Dim.x<=BlocksThatFitIn.X) then xd:=0;

  if o.x+xd+BlocksThatFitIn.X>Dim.x then xd:=0;
  if o.y+yd+BlocksThatFitIn.Y>Dim.y then yd:=0;
  if o.x+xd<0 then xd:=0;
  if o.y+yd<0 then yd:=0;

  o.setXY(o.x+xd,o.y+yd);
  {if o.x<0 then begin o.x:=0; exit end;
  if o.y<0 then begin o.y:=0; exit end;}

{  if o.x+BlocksThatFitIn.X>dim.x then begin o.setXY(o.x-xd,o.y); beep(100,100);exit end;
  if o.y+BlocksThatFitIn.Y>dim.y then begin o.setXY(o.x,o.y-yd); beep(1000,2);exit end;}
  if (oxd=xd) and (oyd=yd) then begin
    wMouseHide;
    DrawGrid;
    wMouseShow;
  end;
end;
procedure TGrid.DrawGrid;
  var i,j,num: integer;
    BlocksThatFitIn: TPoint;
begin
  if Data_Ptr=nil then exit;

  setfillstyle(1,0);
  with r do bar(a.x+2,a.y+2,b.x-40,b.y-2);

  BlocksThatFitIn.X:=(r.size.x-42) div s.x;
  BlocksThatFitIn.Y:=(r.size.y-4) div s.y;
  if BlocksThatFitIn.X>Dim.X then BlocksThatFitIn.X:=Dim.X;
  if BlocksThatFitIn.Y>Dim.Y then BlocksThatFitIn.Y:=Dim.Y;

  for i:=0 to BlocksThatFitIn.y-1 do
    for j:=0 to BlocksThatFitIn.x-1 do
      ShowBlock(j,i);
  if ShowGrid then begin
    setcolor(c);
    j:=r.a.y+2+BlocksThatFitIn.y*s.y;
    for i:=0 to BlocksThatFitIn.x do line(r.a.x+2+i*s.x, r.a.y+2, r.a.x+2+i*s.x,j);
    j:=r.a.x+2+BlocksThatFitIn.x*s.x;
    for i:=0 to BlocksThatFitIn.y do line(r.a.x+2,r.a.y+2+i*s.y,j,r.a.y+2+i*s.y);
  end; {if}
end;

end.