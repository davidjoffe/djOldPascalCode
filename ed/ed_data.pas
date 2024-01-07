{$G+,S-}
unit ed_data;
{ David Joffe '94/12 }
{ General data class }

{ The fairly unelegant solution to my problem is rather unfortunate, but the
  only way out that I can see at this frustrated stage. The name ppicture is
  now rather confusing. But that is just tough. }
{ If I could only have seen the problem from the front... }
{ Maybe if a picture was a totally different object from pdata }
{ But then how could TGrid and it's descendants be able to handle both
  pictures and map type grids? I guess that is the whole problem in a
  nutshell. }
{ If only pascal was a bit more flexible with it's pointer types.
  I guess that is a pretty good reason to move to C++ }
{ It has had to now virtually become seperate objects. I foresee
  problems with grid... }
{ What a mess I have made... }

{ ta-daaaa. I have seperated the data and picture objects. Hope it works. }

{ Updates as they occur... }

{ Ten years later the problem seemed to be solved. Of course several other
  small bugs did appear after that. Pity about the name... }

interface


type
  PArr=^TArr;
  TArr=array[0..65519] of byte;


  ploc_item=^tloc_item;
  tloc_item=object
    height   : byte;
    file_slot: byte;
    character: byte;

    next: ploc_item;
    constructor init(iheight,ifile_slot,icharacter: byte);
  end;

  ploc_item_arr=^tloc_item_arr;
  tloc_item_arr=array[0..((64000 div sizeof(ploc_item))-1)] of ploc_item;

  pbuffer=^tbuffer;
  tbuffer=array[0..65519] of byte;

  pdata=^tdata;
  tdata=object
    buffer : pbuffer;
    size,xsize,ysize  : integer;
    next : pdata;
    constructor init(isize: integer);
    function get(position: integer): integer; virtual;
    procedure put(position: integer; new_val: byte); virtual;
    procedure ResizeDataXY(oldx,oldy,newx,newy: integer); virtual;

    procedure LoadXY(newX, newY: integer); virtual;

    procedure SetNewSize(iSize: integer); virtual;
    destructor done; virtual;
  end;

  {This is the current being used, so that putimage can be used:}
  ppicture=^tpicture;
  tpicture=object
    buffer: pbuffer;
    size,xsize,ysize: integer;

    next: ppicture; {=a list}

    constructor init(isize: integer);
    (* Retrieve an int(?) from position position (adds 4) *)
    function    get(position: integer): integer; virtual;
    (* Retrieve an int(?) from real position position *)
    function    get_real(position: integer): integer; virtual;
    procedure   put(position: integer; new_val: byte); virtual;
    procedure   put_real(position: integer; new_val: byte); virtual;
    procedure   ResizeDataXY(oldx,oldy,newx,newy: integer); virtual;
    procedure   SetNewSize(iSize: integer); virtual;
    {the diff is the loading into the first 4 bytes also: }
    procedure   LoadXY(newX, newY: integer); virtual;

    destructor done; virtual;
  end;

{  PParr=^TParr;
  TParr=array[-4 to 32766] of byte;}

  PSArr=^TSArr;
  TSArr=array[0..65519] of Shortint;

{  PData=^TData;
  TData=object
    Data: Parr;
    size: integer;
    Xsize,Ysize: integer;
    next: PData;
    constructor init(iSize: integer);
    destructor done;
    procedure ResizeDataXY(oldx,oldy,newx,newy: integer);
    procedure SetNewSize(iSize: integer);
  end;}

  PLocData=^TLocData;
  TLocData=object(Tpicture)
    HeightData: PSarr;
    {WhateverData: PArr}

    constructor init(iSize: integer);
{    procedure AdjustHeight(index,diff: integer);}
    destructor done; virtual;
  end;

{making the general a picture type is not the most elegant solution to the
massive problem on my hands, since the name "picture" makes it seem as if
this cannot be used for the general data type which would be more commonly
used. However this is about the best solution I can come up with to solve
this problem that has nearly destroyed me. }

procedure NewData(var DataList: Pdata; iSize: integer);
procedure new_picture(var picture_list: ppicture; isize: integer);

function DataListSize(DataList: Pdata): integer;
function PictureListSize(picture_List: Ppicture): integer;

function DataPtr(DataList: Pdata; DataNum: integer): Pdata;
function picture_ptr(picture_list: ppicture; picture_num: integer):ppicture;
function plocdata_ptr(picture_list: plocdata; num: integer): plocdata;

{even if you use the pdata type as a parameter it _should_, i think, call the
correct destructors etc, since it should pass the table of virtual methods
for the current instance to the procedure (I hope)}
{nope.}
procedure DisposeData(var DataList: Pdata);
procedure dispose_picture(var picture_list: ppicture);

{var
  zData: PData;}

implementation
uses w_mouse, e_gen;

constructor tloc_item.init(iheight,ifile_slot,icharacter: byte);
begin
  height:=iheight;
  file_slot:=ifile_slot;
  character:=icharacter;
  next:=nil;
end;

(*--------------------------------------------------------------------------*)
procedure NewData(var DataList: Pdata; iSize: integer);
  var zdata: PData;
begin
  if DataList=nil then begin
    Datalist:=new(PData, init(iSize));
    DataList^.next:=nil;
  end else begin
    zData:=DataPtr(DataList,DataListSize(DataList));
    zData^.next:=new(PData, init(iSize));
    zData^.next^.next:=nil;
  end;
end;

(*--------------------------------------------------------------------------*)
procedure new_picture(var picture_list: ppicture; isize: integer);
  var temp_picture: ppicture;
begin
  if picture_list=nil then begin
    picture_list:=new(ppicture, init(isize));
    picture_list^.next:=nil;
  end else begin
    temp_picture:=picture_ptr(picture_list, picturelistsize(picture_list));
    temp_picture^.next:=new(ppicture, init(isize));
    temp_picture^.next^.next:=nil;
  end;
end;

(*--------------------------------------------------------------------------*)
function tdata.get(position: integer): integer;
begin
  get:=buffer^[position];
end;
(*--------------------------------------------------------------------------*)
procedure tdata.put(position: integer; new_val: byte);
begin
  buffer^[position]:=new_val;
end;
(*--------------------------------------------------------------------------*)
procedure tdata.loadXY(newX,newY: integer);
begin
  xsize:=newx;
  ysize:=newy;
end;



(*-[ TPicture ]-------------------------------------------------------------*)
function tpicture.get(position: integer): integer;
begin
  get:=buffer^[position+4];
end;
(*--------------------------------------------------------------------------*)
function tpicture.get_real(position: integer): integer;
begin
  get_real:=buffer^[position];
end;
(*--------------------------------------------------------------------------*)
procedure tpicture.put(position: integer; new_val: byte);
begin
  buffer^[position+4]:=new_val;
end;
(*--------------------------------------------------------------------------*)
procedure tpicture.put_real(position: integer; new_val: byte);
begin
  buffer^[position]:=new_val;
end;
(*--------------------------------------------------------------------------*)
constructor tpicture.init(isize: integer);
begin
  buffer:=nil;
  size:=isize;
  if (size<>-1) then begin
    getmem(buffer,size+4);
    FillChar(buffer^[0], size+4, 0);
    {for i:=0 to size+3 do buffer^[i]:=0;}
  end;
  xsize:=0; ysize:=0;
  next := nil;
end;
(*--------------------------------------------------------------------------*)
destructor tpicture.done;
begin
  if buffer <> nil then freemem(buffer,size+4);
  buffer := nil;
end;
(*--------------------------------------------------------------------------*)
procedure tpicture.loadXY(newX,newY: integer);
begin
  xsize:=newx;
  ysize:=newy;
  memw[seg(buffer^[0]):ofs(buffer^[0])]:=newX-1;
  memw[seg(buffer^[0]):ofs(buffer^[2])]:=newY-1;
end;
(*--------------------------------------------------------------------------*)
constructor tdata.init(isize: integer);
  var i: integer;
begin
  size:=isize;
  getmem(buffer,size);
  for i:=0 to size-1 do buffer^[i]:=0;
  xsize:=0; ysize:=0;
end;
(*--------------------------------------------------------------------------*)
destructor tdata.done;
begin
  if buffer <> nil then freemem(buffer,size);
  buffer := nil;
end;

(*--------------------------------------------------------------------------*)
constructor TLocData.init;
  var i: integer;
begin

  Tpicture.init(iSize);

  GetMem(HeightData, size);
  for i:=0 to size-1 do HeightData^[i]:=0;

end;

destructor TLocData.done;
begin
  TPicture.done;
  if (HeightData <> nil) then freeMem(HeightData,size);
  HeightData := nil;
end;

{procedure TLocData.AdjustHeight(index,Diff: integer);
begin
  HeightData^[index]:=HeightData^[index]+Diff;
  if HeightData^[index]<HeightMin then HeightData^[index]:=HeightMin;
  if HeightData^[index]>HeightMax then HeightData^[index]:=HeightMax;
  wWaitForMouseRelease;
end;}


(*--------------------------------------------------------------------------*)
procedure TData.ResizeDataXY(oldx,oldy,newx,newy: integer);
  var DataSave: PArr;
    sizeSave: integer;
    i,j,n1,n2: integer;
begin
  sizeSave:=size;
  GetMem(DataSave, sizeSave);

  Move(buffer^[0],DataSave^[0],size);

  SetNewSize(newx*newy);
  n1:=newx; n2:=newy;
  if n1>oldx then n1:=oldx;
  if n2>oldy then n2:=oldy;
  for i:=0 to n2-1 do begin
    for j:=0 to n1-1 do begin
      put(i*newX+j,DataSave^[i*oldX+j]);
    end;
  end;

  XSize:=newX; YSize:=newY;
{  for i:=0 to size-1 do DataSave^[i]:=Data^[i];}
  FreeMem(DataSave, sizeSave);
end;

(*--------------------------------------------------------------------------*)
procedure Tpicture.ResizeDataXY(oldx,oldy,newx,newy: integer);
  var DataSave: PArr;
    sizeSave: integer;
    i,j,n1,n2: integer;
begin
  sizeSave:=size;
  GetMem(DataSave, sizeSave);

  Move(buffer^[4],DataSave^[0],size);

  SetNewSize(newx*newy);

  n1:=newx; n2:=newy;
  if n1>oldx then n1:=oldx;
  if n2>oldy then n2:=oldy;

  for i:=0 to n2-1 do begin
    for j:=0 to n1-1 do begin
      put(i*newX+j,DataSave^[i*oldX+j]);
    end;
  end;

  XSize:=newX; YSize:=newY;
{  for i:=0 to size-1 do DataSave^[i]:=Data^[i];}
  FreeMem(DataSave, sizeSave);
end;

(*--------------------------------------------------------------------------*)
procedure TData.SetNewSize(iSize: integer);
  var i: integer;
begin
  FreeMem(buffer, size);
  size:=iSize;
  GetMem(buffer, size);
  for i:=0 to size-1 do buffer^[i]:=0;
end;
(*--------------------------------------------------------------------------*)
procedure Tpicture.SetNewSize(iSize: integer);
  var i: integer;
begin
  FreeMem(buffer, size+4);
  size:=iSize;
  GetMem(buffer, size+4);
  for i:=0 to size+3 do buffer^[i]:=0;
end;



(*--------------------------------------------------------------------------*)
procedure DisposeData(var DataList: Pdata);
  var Tptr: Pdata;
    num,i: integer;
begin
  num:=DataListSize(DataList);
  for i:=1 to num do begin
{    freemem(DataPtr(DataList,i)^.buffer,DataPtr(DataList,i)^.size);}
   {NB here to use the methods now to avoid heap leaks}
    DataPtr(DataList, i)^.done;
  end;
  for i:=num-1 downto 1 do begin
    {done?}
    dispose(DataPtr(DataList,i)^.next);
  end;
  if DataList<>nil then dispose(DataList);
  DataList:=nil;
end;

(*--------------------------------------------------------------------------*)
procedure dispose_picture(var picture_list: ppicture);
  var Tptr: Ppicture;
    num,i: integer;
begin
  if picture_list = nil then exit;
  num:=PictureListSize(picture_List);
  for i:=1 to num do begin
{    freemem(DataPtr(DataList,i)^.buffer,DataPtr(DataList,i)^.size);}
   {NB here to use the methods now to avoid heap leaks}
    Picture_Ptr(picture_List, i)^.done;
  end;
  for i:=num-1 downto 1 do begin
    {done?}
    dispose(picture_Ptr(Picture_List,i)^.next);
  end;
  if Picture_List<>nil then dispose(Picture_List);
  picture_List:=nil;
end;


(*--------------------------------------------------------------------------*)
function DataListSize(DataList: Pdata): integer;
  var count: integer;
    xdata: Pdata;
begin
  count:=0;
  xData:=DataList;
  while xData<>nil do begin
    inc(Count);
    xData:=xData^.next;
  end;
  DataListSize:=count;
end;

(*--------------------------------------------------------------------------*)
function PictureListSize(picture_List: Ppicture): integer;
  var count: integer;
    xdata: Pdata;
begin
  count:=0;
  xData:=pdata(picture_List);
  while xData<>nil do begin
    inc(Count);
    xData:=xData^.next;
  end;
  pictureListSize:=count;
end;

(*--------------------------------------------------------------------------*)
function DataPtr(DataList: Pdata; DataNum: integer): Pdata;
  var xdata: pdata;
begin
  xData:=DataList;
  while (xData<>nil) and (DataNum>1) do begin
    dec(DataNum);
    xData:=xData^.next;
  end;
  DataPtr:=xData;
end;

(*--------------------------------------------------------------------------*)
function picture_ptr(picture_list: ppicture; picture_num: integer): ppicture;
  var temp_picture: ppicture;
begin
  temp_picture:=picture_list;
  while (temp_picture<>nil) and (picture_num>1) do begin
    dec(picture_num);
    temp_picture:=temp_picture^.next;
  end;
  picture_ptr:=temp_picture;
end;
function plocdata_ptr(picture_list: plocdata; num: integer): plocdata;
  var temp_picture: plocdata;
begin
  temp_picture:=picture_list;
  while (temp_picture<>nil) and (num>1) do begin
    dec(num);
    temp_picture:=plocdata(temp_picture^.next);
  end;
  plocdata_ptr:=temp_picture;
end;


end.