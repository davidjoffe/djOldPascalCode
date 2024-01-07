{$G+,S-}
unit ed_app00;
{ David Joffe '94/12 }
{ Graphics editting App for ED }

  {MGF File structure: }

  {version 2 revamp: }
  {   3 [MGF]     }
  {   1 [version] }
  {  50 [comment] }
  {   2 [numpics] }
  { 512 [offsets] }
  {loop numpics times:}
    { 100[smallpic] }
    {   2[xsize]    }
    {   2[ysize]    }
    { x*y[data]     }
  {endloop}


interface

uses crt,u_useful,w_app,w_items,w_item,ed_data,w_files,w_stddlg,
     w_items3,w_win,e_gen,e_items,i_buttons,i_grids;

const
{jeez what a lot of nonsense this lot is!}
  Gx1=10;
  Gy1=26;
  Gx2=522;
  Gy2=368;
  Gsx=Gx2-Gx1;
  Gsy=Gy2-Gy1;
  ButS1=295;
  ButS2=295+51;
  But2S1=ButS2+1;
  But2S2=ButS2+(ButS2-ButS1);
  But3s1=239;
  But3s2=But3s1+51;

{button ret constants}
  gcCLEAR  =   1;
  gcNEW    =   3;
  gcNEXT   =   4;
  gcPREV   =   5;
  gcLOAD   =   6;
  gcSAVE   =   7;
  gcRESIZE =   8;
  gcLITBOX = 101;
  gcFILL   =   2;
  gcSEP    =   9;
  gcCLIP   =  10;
  gcPASTE  =  11;
  gcFLIPX  =  12;
  gcPASTE2 =  13;

  GridIn   =  60;
  Grid2In  =  61;

  GridDefX=BlockWidth; GridSX=6;
  GridDefY=BlockWidth; GridSY=6;

  signature: array[0..2] of char=('M','G','F');

type
  PGraphics=^TGraphics;
  TGraphics=object(TApp)
    ColorBox: P256Colors;

    ClipBoard: PGrafClipBoard;

    StatBar: PText;

    FillButton,SepButton: PTextSwitch;

    DlgFile: TDlgFile;
    DlgNewXY: TDlgNewXY;

    PicFile: TFile;

    pic_box: Ppic_box;

{    Datas,Data2s: PData; {....} {+}

    main_image,map_image: ppicture;
{    images:array[0..127] of ppicture;}

    CurData     : integer;
    NumData     : integer;

    Grid,Grid2  : PGrafGrid;

    procedure InitWindow; virtual;
    function HandleCmd(cmdNum: integer): integer; virtual;
    procedure SaveMGF;
    procedure SetCurData(NewCurData: integer);
    procedure set_current_picture(new_current_picture: integer);
    destructor done; virtual;
  end;

var
  p,q,version: byte;


implementation

uses w,w_mouse;

(*--------------------------------------------------------------------------*)
destructor TGraphics.done;
  var temp,temp2: ppicture;
begin
  if main_image <> nil then begin
    temp := main_image;
    while (temp <> nil) do begin
      temp2 := temp^.next;
      dispose(temp, done);
      temp := temp2;
    end;
  end;
  main_image := nil;

  if map_image <> nil then begin
    temp := map_image;
    while (temp <> nil) do begin
      temp2 := temp^.next;
      dispose(temp, done);
      temp := temp2;
    end;
  end;
  map_image := nil;
end;

(*--------------------------------------------------------------------------*)
function TGraphics.HandleCmd(cmdNum: integer): integer;

(*תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת*)
  procedure ReSizeData;
    var newx,newy,oldx,oldy,code: integer;
  begin
    oldx:=Grid^.Dim.X;
    oldy:=Grid^.Dim.Y;

    val(DlgReSize.NewX.Str,newx,code);
    val(DlgReSize.NewY.Str,newy,code);

    picture_Ptr(main_image,curData)^.ResizeDataXY(oldx,oldy,newx,newy); {+}

    Grid^.Dim.setXY(newX,newY);
    Grid^.o.setXY(0,0);
    wMouseHide;
    Grid^.Show;
    wMouseShow;
  end;

(*תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת*)
  procedure MakeNew;
    var newx,newy,code: integer;
  begin
    newx:=GridDefX; newy:=GridDefY;

    DlgNewXY.init(newx,newy);
    Dialog(@DlgNewXY);

    val(DlgNewXY.newX.str,newx,code);
    if code<>0 then exit;

    val(DlgNewXY.newY.str,newY,code);
    if code<>0 then exit;

    Grid^.Dim.setXY(newX,NewY);

    New_picture(main_image,Grid^.Dim.y*Grid^.Dim.x); {+}
    New_picture(map_image,litX*litY); {+}

    inc(NumData);

    picture_ptr(main_image,numdata)^.loadXY(newX,newY);
    picture_ptr(map_image,numdata)^.loadXY(litX,litY);
{    picture_Ptr(main_image,numData)^.Xsize:=NewX;  {+}
{    picture_Ptr(main_image,numData)^.Ysize:=NewY;  {+}
{    picture_Ptr(map_image,numData)^.Xsize:=litX; {redundant!!!} {+}
{    picture_Ptr(map_image,numData)^.Ysize:=litY; {+}

    SetCurData(numData);

    pic_box^.DataP:=map_image;

    wMouseHide;
    pic_box^.Show;        {??????????????????????????????????????}
    wMouseShow;
  end;

(*תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת*)
  procedure PasteFromClipBoard(CopyLit: boolean);
    var d: Ppicture; {+}
      i: integer;
  begin
    if main_image=nil then exit; {+}

    if ClipBoard^.main_clip=nil then exit; {+}

    d:=picture_Ptr(main_image,curData); {+}

    d^.SetNewSize(ClipBoard^.main_clip^.size); {+}

    for i:=0 to d^.size+3 do d^.put_real(i,ClipBoard^.main_clip^.get_real(i)); {+}

    d^.loadXY(ClipBoard^.main_clip^.Xsize,ClipBoard^.main_clip^.Ysize);
{    d^.XSize:=(ClipBoard.main_clip^.Xsize); {+}
{    d^.YSize:=(ClipBoard.main_clip^.Ysize); {+}

    Grid^.dim.setxy(d^.XSize,d^.YSize);
    Grid^.o.setXY(0,0);

    if CopyLit then begin
      d:=picture_ptr(map_image,curData); {+}
      for i:=0 to d^.size+3 do d^.put_real(i,ClipBoard^.map_clip^.get_real(i)); {+}
    end;

    wMouseHide;
    Grid^.DrawGrid;
    Grid2^.DrawGrid;
    pic_box^.Show;
    wMouseShow;
  end;

(*תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת*)
  procedure FlipDataX;
    var i,j,c: integer;
       TempArr: PArr;
       d: Ppicture;
  begin
    if main_image=nil then exit;
    d:=picture_ptr(main_image,curData);
    GetMem(TempArr, d^.size);
    if (TempArr = nil) then begin
      beep(300,50);
      exit; {error}
    end;
    for i:=0 to d^.size-1 do TempArr^[i]:=d^.get(i);
    c:=0;
    for i:=0 to Grid^.Dim.Y-1 do begin
      for j:=Grid^.Dim.X-1 downto 0 do begin
        d^.put(i*Grid^.Dim.X+j,TempArr^[c]);
        inc(c);
      end;
    end;
    FreeMem(TempArr, d^.size);
    wMouseHide;
    Grid^.DrawGrid;
    wMouseShow;
  end;

(*--------------------------------------------------------------------------*)
begin
  case cmdNum of
    gcFlipX: FlipDataX;

    gcClip:
      if main_image<>nil then begin
        ClipBoard^.SetClipData(picture_ptr(main_image,curData),picture_ptr(map_image,curData));
      end;

    gcPaste: PasteFromClipBoard(true);
    gcPaste2: PasteFromClipBoard(false);

    gcReSize:
      begin
        if numData<>0 then begin
          DlgResize.init('Resize picture: ['+IntStr(curData,10)+']',Grid^.Dim.X,Grid^.Dim.Y,Grid^.Dim.X,Grid^.Dim.Y);
          Dialog(@DlgResize);
          if (DlgResize.NewX.Str<>'') and (DlgResize.NewY.Str<>'') then begin
            DlgWarning.init('Data may be lost!','Proceed anyway?');
            Dialog(@DlgWarning);
            if DlgWarning.OKStatus then begin
              ReSizeData;
            end;
          end;
        end;
      end;

    gcLitBox:
      if pic_box^.PicPressed<=numData-1 then SetCurData(pic_box^.PicPressed+1);

    gcClear:
      begin
        {not yet implemented}
      end;

    gcFill: SepButton^.SetStatus(false);
    gcSep : FillButton^.SetStatus(false);

    gcNew: MakeNew;

    gcNext: SetCurData(curData+1);
    gcPrev: SetCurData(curData-1);

    gcLoad:
      begin
        DlgFile.init(' Load file','*.MGF');
        Dialog(@DlgFile);
{        LoadMGF;}
{        LoadAnMGF(DFileName,PicFile,Datas,Data2s,curData,numData);}
        LoadAnMGF(DFileName,picFile,main_image,map_image,curData,numData);

        SetCurData(numData);
        pic_box^.DataP:=map_image;
        Title:=' Map element editor: '+PicFile.FileName;
        {ShowWindow(@self,true);}
        wMouseHide;
        pic_box^.Show;
        ShowTitle(@self,true);
        wMouseShow;

      end;

    gcSave:
      begin
        if PicFile.FileName<>'NoFile' then
          DlgFile.init(' Save file',PicFile.FileName)
        else
          DlgFile.init(' Save file','*.MGF');
        {endif}
        Dialog(@DlgFile);
        SaveMGF;
      end;


    GridIn:
      begin
        if FillButton^.Status then begin
          Grid^.FillData(Grid^.Dim.X,Grid^.Dim.Y,ColorBox^.c.fore,ColorBox^.c.Back)
        end;
        if SepButton^.Status then begin
          Grid^.SepData(Grid^.Dim.X,Grid^.Dim.Y,ColorBox^.c.fore,ColorBox^.c.Back)
        end;
        if not (FillButton^.Status or SepButton^.Status) then begin
          Grid^.SetData(ColorBox^.c.fore,ColorBox^.c.Back);
        end;
      end;

    Grid2In:
      begin
        if FillButton^.Status then begin
          Grid2^.FillData(litX,litY,ColorBox^.c.fore,ColorBox^.c.Back)
        end;
        if SepButton^.Status then begin
          Grid2^.SepData(litX,litY,ColorBox^.c.fore,ColorBox^.c.Back);
        end;
        if not (FillButton^.Status or SepButton^.Status) then begin
          Grid2^.SetData(ColorBox^.c.fore,ColorBox^.c.Back);
        end;
  {      wMouseHide;
        pic_box^.Show;
        wMouseShow;}
      end;
  end;
end;


(*--------------------------------------------------------------------------*)
procedure tgraphics.set_current_picture(new_current_picture: integer);
  var temp_picture: ppicture;
begin
  if numdata=0 then begin
    statbar^.str:='Cur.pic: none';
    wmousehide;
    statbar^.show;
    wmouseshow;
    EXIT;
  end;

  if new_current_picture<1 then new_current_picture:=numdata;
  if new_current_picture>numdata then new_current_picture:=1;

  curdata:=new_current_picture;

{  temp_picture:=picture_ptr(main_image, curdata);}
{
  Grid^.datap:=temp_picture;
  Grid^.dim.setxy(temp_picture^.xsize,temp_picture^.ysize);

  Grid^.o.setXY(0,0);
  Grid2^.datap:=picture_ptr(map_image,curdata);

  wMouseHide;
  Grid^.drawgrid;
  Grid2^.drawgrid;

  statbar.str:='Cur.pic: '+intstr(curdata,10);
  statbar.show;
  wmouseshow;}

end;
(*--------------------------------------------------------------------------*)
procedure TGraphics.SetCurData(NewCurData: integer);
  var tp: Ppicture;
begin
  if NumData=0 then begin
    StatBar^.Str:='Cur.pic: none';
    wMouseHide;
    StatBar^.Show;
    wMouseShow;
    exit;
  end;

  if NewCurData<1 then NewCurData:=NumData;
  if NewCurData>NumData then NewCurData:=1;

  CurData:=NewCurData;

  tp:=picture_ptr(main_image,CurData);

  Grid^.data_ptr:=tp;
  Grid^.dim.SetXY(tp^.Xsize,tp^.YSize);

  Grid^.o.setXY(0,0);
  Grid2^.data_ptr:=picture_ptr(map_image,CurData);

  wMouseHide;
  Grid^.DrawGrid;   {grid size!!!}
  Grid2^.DrawGrid;

  StatBar^.Str:='Cur.pic: '+IntStr(curData,10);
  StatBar^.Show;
  wMouseShow;
end;


(*--------------------------------------------------------------------------*)
procedure TGraphics.InitWindow;
begin
  r.SetXYXY(Gx1,Gy1,Gx2,Gy2);
  PicFile.init;
  Title:=' Map elem['+IntStr(sizeof(TGraphics),10)+']ent editor: ['+PicFile.FileName+']';

  main_image:=nil; map_image:=nil; NumData:=0;
  New(ClipBoard, init(5,288,65,338));
{  ClipBoard.SetClipData(Datas,map_image);}

  New(FillButton, init(But2S1,20,But2S2,39,'Fill',false,gcFill));
  New(SepButton, init(But2S1,40,But2S2,59,'Sep.',false,gcSep));

  New(Grid, init(3,20,290,269,GridDefX,GridDefY,GridSX,GridSY,8,GridIn,true));
  New(Grid2, init(Gsx-112,20,Gsx-5,120,litX,litY,6,6,8,Grid2In,true));

  New(ColorBox, init(295,122,10,8,White,Black));
  ColorBox^.SetPalette(PALETTE_FILE);

  New(pic_box, init(295,256,gcLitBox,map_image));
  New(StatBar, init(5,272,289,282,10,1,'Cur.pic: none',Yellow,Magenta));
  items:=
    Link(ClipBoard,
    Link(Grid,
    Link(Grid2,
    Link(FillButton,
    Link(SepButton,
    Link(ColorBox,
    Link(pic_box,
    Link(StatBar,
    NewTextButton(ButS1,20,ButS2,39,'New',gcNEW,

    NewTextButton(ButS1,40,ButS1+((ButS2-ButS1) div 2),59,'',gcPREV,
    NewTextButton(ButS1+((ButS2-ButS1) div 2)+1,40,ButS2,59,#26,gcNEXT,

    NewTextButton(ButS1,60,ButS2,79,'Load',gcLOAD,
    NewTextButton(But2S1,60,But2S2,79,'Resize',gcRESIZE,

    NewTextButton(But2s1,80,But2s2,99,'Clip',gcCLIP,
    NewTextButton(But2s1,100,But2s2,119,'Paste',gcPASTE,

    newTextButton(But3s1,288,But3s2,307,'FlipX',gcFLIPX,
    newtextbutton(but3s1,308,but3s2,327,'Paste',gcPASTE2,

    NewTextButton(ButS1,80,ButS2,99,'Save',gcSAVE,
    NewTextButton(ButS1,100,ButS2,119,'Clear',gcCLEAR,
    NewRectangle(4,271,290,283,YELLOW,
    nil
  ))))))))))))))))))));
end;

(*--------------------------------------------------------------------------*)
procedure TGraphics.SaveMGF;
  var i: integer;
   offset_table: array[0..127] of longint;
   file_pointer: longint;
begin
  if DFileName='' then exit;
  if Pos('.',DFileName)=0 then DFileName:=DFilename+'.MGF';
  PicFile.AssignFile(DFileName);
  PicFile.CreateFile; {error check!!}
  PicFile.OpenFile;

  for p:=0 to 2 do PicFile.WriteFile(signature[p],1);
  p:=2; PicFile.WriteFile(p,1); {version}

  q:=ord('c');
  for p:=0 to 49 do PicFile.WriteFile(q,1); {comment!}

  PicFile.WriteFile(numData,2);
{version 2 implemented: a 512 byte offset table of drawings}
  for i:=0 to 127 do offset_table[i]:=-1; {default: no pic exist check}
  for i:=0 to 127 do picfile.writefile(offset_table[i],4);
{----------------------------------------------------------}

  file_pointer:=593;
  for p:=1 to NumData do begin
    offset_table[p]:=file_pointer;

    PicFile.WriteFile(picture_ptr(map_image,p)^.buffer^[4],100);
    PicFile.WriteFile(picture_ptr(main_image,p)^.XSize,2);
    PicFile.WriteFile(picture_ptr(main_image,p)^.YSize,2);

    PicFile.WriteFile(picture_ptr(main_image,p)^.buffer^[4],picture_ptr(main_image,p)^.size);

    file_pointer:=file_pointer+112+picture_ptr(main_image,p)^.size;
  end;

{version 2 implemented: -------------------------------------}
  picfile.move_file_pointer(56);
  picfile.writefile(offset_table[0],512);
{------------------------------------------------------------}

  PicFile.CloseFile;
  Title:=' Map element editor: '+PicFile.FileName;
  wMouseHide;
  ShowTitle(@self,true);
  wMouseShow;

  Beep(600,50);
end;

(*--------------------------------------------------------------------------*)
end.