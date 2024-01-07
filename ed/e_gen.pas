{$G+,S-}
unit e_gen;
{ David Joffe '94/12 }
{ General constants etc. for ED }

interface

uses w_stddlg,w_files,graph,ed_data;

type
  pimagearr = ^timagearr;
  timagearr = array[0..65000] of byte;


{ standard definitions for the size etc. of the isometric blocks }
const
  TLOC_STRUCT_ED_MAXCHAR=16;
  PALETTE_FILE='ED.COL';

  BlockX=24;
  BlockY=BlockX div 2;
  BlockWidth=BlockX*2;

  litX=10; litY=10;

  HeightMin=-9;
  HeightMax=19;

  Numbers: array[0..15*11-1] of byte=(
    15,15,15,
    15, 0,15,
    15, 0,15,
    15, 0,15,
    15,15,15,

    15,15, 0,
     0,15, 0,
     0,15, 0,
     0,15, 0,
    15,15,15,

    15,15,15,
     0, 0,15,
    15,15,15,
    15, 0, 0,
    15,15,15,

    15,15,15,
     0, 0,15,
     0,15,15,
     0, 0,15,
    15,15,15,

    15, 0,255,
    15, 0, 0,
    15, 0,15,
    15,15,15,
     0, 0,15,

    15,15,15,
    15, 0, 0,
    15,15,15,
     0, 0,15,
    15,15,15,

    15,15,15,
    15, 0, 0,
    15,15,15,
    15, 0,15,
    15,15,15,

    15,15,15,
     0, 0,15,
    255, 0,15,
    255, 0,15,
    255, 0,15,

    15,15,15,
    15, 0,15,
    15,15,15,
    15, 0,15,
    15,15,15,

    15,15,15,
    15, 0,15,
    15,15,15,
     0, 0,15,
    15,15,15,

    255,255,255,
     0, 0, 0,
    15,15,15,
     0, 0, 0,
    255,255,255
  );


var
  DlgResize: TDlgResize;
  DlgWarning: TDlgWarning;

{draw the tiny height numbers}
procedure WriteNums(x,y,num: integer);

{a very general LoadAnMGF procedure}
procedure LoadAnMGF(iFileName: string; var iFile: TFile; var main_image,map_image: Ppicture; var curData,numData: integer);

{a general procedure for drawing a 256 color "getimage" image}
procedure Draw256(image: pimagearr; x,y,xsize,ysize: integer);

implementation

uses u_useful,crt;

(*--------------------------------------------------------------------------*)
procedure Draw256(image: pimagearr; x,y,xsize,ysize: integer);
  var i,j: integer;
begin
  {if screen colors is set to 255 then pic can be put}
  if (getmaxcolor = 255) then begin
    putimage(x,y,image^[0],normalput);
  {draw pixel by pixel}
  end else begin
    for i:=0 to ysize-1 do begin
      for j:=0 to xsize-1 do begin
        PutPixel(x+j,y+i,image^[4+j+(i*xsize)]);
      end;
    end;
  end;
end;

(*--------------------------------------------------------------------------*)
procedure LoadAnMGF(
	iFileName: string;
	var iFile: TFile;
	var main_image,map_image: Ppicture;
	var curData,numData: integer
);
  var
    i,n1,n2: integer;
    m,n,version: byte;
    offset_table:array[0..127] of longint;
{    TPicFile: TFile;}
  label error_handler;
begin
  if iFileName='' then goto error_handler;
  if Pos('.',iFileName)=0 then iFileName:=iFilename+'.MGF';

  iFile.init;
  iFile.AssignFile(iFileName);
  if not iFile.FileExist then goto error_handler;
  iFile.OpenFile;

  iFile.ReadFile(m,1); if m<>ord('M') then goto error_handler;
  iFile.ReadFile(m,1); if m<>ord('G') then goto error_handler;
  iFile.ReadFile(m,1); if m<>ord('F') then goto error_handler;

  {if main_image, map_image exist, dispose of the lists}
  Dispose_Picture(main_image);
  Dispose_picture(map_image);

  {current and size set to 0}
  curData:=0;
  NumData:=0;

  iFile.ReadFile(version,1);
  {case version of}
  if version<2 then
    for m:=1 to 52 do iFile.ReadFile(n,1)
  else
    for m:=1 to 50 do iFile.ReadFile(n,1);
  {endif}

  iFile.ReadFile(NumData,2);

  if version>1 then begin
    ifile.readfile(offset_table[0],512);
  end;
  if version<2 then for m:=1 to 25 do iFile.ReadFile(n,1);

  for m:=1 to NumData do begin
    New_Picture(map_image,litX*litY); {<- chug new picture at end of list}
{******************************************************************
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
******************************************************************}
{    DataPtr(map_image,m)^.Xsize:=litX; {redundant!!!}
{    DataPtr(map_image,m)^.Ysize:=litY; {maybe not...}
    picture_Ptr(map_image,m)^.LoadXY(litX,litY); {<-set xy field}
    iFile.ReadFile(picture_Ptr(map_image,m)^.buffer^[4],litX*litY);
    iFile.ReadFile(n1,2); {<-big picture x,y}
    iFile.ReadFile(n2,2);
    if version<2 then for i:=0 to 7 do iFile.ReadFile(n,1);

    New_Picture(main_image,n2*n1);
{    picture_Ptr(main_image,m)^.Xsize:=n1;}
    picture_ptr(main_image,m)^.LoadXY(n1,n2);
    {oh shit. what a mess}
    { not going to load correctly, is it? } {<-guess it does :) 95/10/07}
    iFile.ReadFile(picture_ptr(main_image,m)^.buffer^[4],n2*n1);
  end;
  iFile.CloseFile;
  {beep(1000,100);}
  exit; {success}

error_handler:
  delay(200);
  Beep(150,100);
  delay(150);
  Beep(150,100);
  delay(150);
  Beep(150,100);
  delay(150);
  Beep(150,100);
  delay(400);
  iFile.CloseFile;
end;


(*--------------------------------------------------------------------------*)
procedure WriteNums(x,y,num: integer);
  var i,j,k,offs: integer;
    tstr,t: string;
    n1,code: integer;
begin
  tstr:=intstr(num,10);
  for i:=1 to length(tstr) do begin
    t:=copy(tstr,i,1);
    if t='-' then begin
      offs:=15*10;
    end else begin
      val(t,n1,code);
      offs:=n1*15;
    end;
    for j:=0 to 4 do begin
      for k:=0 to 2 do begin
	if numbers[offs]<>255 then putpixel(x+k,y+j,Numbers[offs]);
	inc(offs);
      end;
    end;
    inc(x,4);

  end;
end;

end.
