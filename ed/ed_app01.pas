{$G+   286 code generation}
{$S-   Stack-checking off }
unit ed_app01;
{ David Joffe '94/12 }
{ Graphics editting App for ED }

{ FILENAME.MF1 : "MapFile1 => dense storage }
{ [x][x][y][y] : int xSize, int ySize       }
{ array[ ][ ]  : char, height               }

interface

uses crt,w_app,w_items,w_item,ed_data,graph,w_files,w_stddlg,
     w_win,e_gen,e_items,w_items3,i_buttons,i_grids,
     i_loced;

const
  MX1=10;
  MY1=21;
  MX2=225;
  MY2=130;
  MAPX=340; {size of little loc edit window}
  MAPY=325;
  MButX=170;
  MButX2=MButX+60;

  McNEW=1;
  McLOAD=2;
  McDELETE=3;

  Mc2LINK=7;
  Mc1LINK=8;

  LcFILL    =  1;
  LcVIEW    =  2;
  LcSAVE    =  3;
  LcLOAD    =  4;
  LcSAVE1   =203;
  LcLOAD1   =204;
  LcRESIZE  =  5;
  LcRELOAD  =  6;
  LcHEIGHTS =  7;
  LcHT1     =  8;
  LcHT2     =  9;
  LcHT3     = 10;
  LcGRIDIN  =101;
  Lc_GRIDIN =102;
  LcPIC_BOX =201;
  Lc_FILE_LIST_BOX=301;
  Lc_GRID_PLACE_MODE=401;
  Lc_LOC_STRUCT_ED=402;
type
  TDlgNew=object(TDialog)
    Xinp,Yinp: TTextInput;
    DlgFile: TDlgFile;
    procedure InitAll; virtual;
    procedure ShutDown; virtual;
    function HandleCmd(cmdNum: integer): integer; virtual;
  end;

  TDlgView=object(TDialog)
    gData: PLocData;
    main_image: Ppicture;
    x,y,xo,yo: integer;
    ViewIso: TViewIso;
    constructor Init(ix,iy,ixo,iyo: integer; igData: PLocData; imain_image: Ppicture);
    function HandleCmd(cmdNum: integer): integer; virtual;
    procedure InitAll; virtual;
  end;

  PMapEd=^TMapEd;
  TMapEd=object(TApp)
    DlgFile: TDlgFile;
    DlgNew : TDlgNew;
    procedure InitWindow; virtual;
    function HandleCmd(cmdNum: integer): integer; virtual;
    procedure HandleAppWin(WinNum,WinCmd: integer); virtual;
  end;

  PTemp=^TTemp;
  TTemp=object(TAppWin)
    constructor init(x1,y1,x2,y2: integer);
    procedure InitWindow; virtual;
  end;

  {A location}
  PMap=^TMap;
  TMap=object(TAppWin)
    LOCfile                : TFile;

    gData                  : PLocData;

    Grid                   : PLocGrid;  {!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!}
    gXsize,gYsize          : integer;

    grid_place_mode        : PTextSwitch;
    loc_struct_ed          : Ploc_struct_ed;

    loc_grid               : tloc_grid;

    MGFFile                : TFile;
    numGraf,curGraf        : integer;

    MGF_file_list_box      : PFileListBox;

    {all this should change...}
    {these two are THE image pointers}
    main_image,map_image   : Ppicture;

    {FUNCTIONALITY/CONTROL:}
    msg_line               : PText;
    msg_rect               : PRectangle;
    cur_file_msg           : PText;
    cur_file_rect          : PRectangle;

    DlgFile                : TDlgFile;

    pic_box                : Ppic_box;
    PicSelection           : PPicSelection;

    FillButton             : PTextSwitch;
    HeightButton           : PTextSwitch;
    Ht1,Ht2,Ht3            : PTextSwitch;
    HtRange                : PIntRange;

    constructor init(x1,y1,x2,y2,xs,ys: integer; iMGFFile: string);
    procedure InitWindow; virtual;
    procedure LoadMGF;
    destructor done; virtual;
  end;

var
  DlgView: TDlgView;

implementation
uses w_mouse,w,u_useful;
procedure TTemp.initWindow;
begin
  Title := 'lksdfjksd';
  items := nil;
end;
constructor TTemp.init;
begin
  TAppWin.init(x1,y1,x2,y2);
end;

(*--------------------------------------------------------------------------*)
destructor TMap.done;
  var temp: PLocData;
      temp2: PPicture;
begin
  TAppWin.done; { <= this does nothing anyway :) }
  temp := gData;
  while (temp <> nil) do begin
    temp^.done;
    temp := PLocData(temp^.next);
  end;
  temp2 := main_image;
  while (temp2 <> nil) do begin
    temp2^.done;
    temp2 := PPicture(temp2^.next);
  end;
  temp2 := map_image;
  while (temp2 <> nil) do begin
    temp2^.done;
    temp2 := PPicture(temp2^.next);
  end;
end;

(*--------------------------------------------------------------------------*)
procedure TMapEd.HandleAppWin(WinNum,WinCmd: integer);
  var SaveVP: ViewPortType;
    w: PMap;
    tempBut: integer;
    Tindex: integer;
    temp : PLocData;
begin
  w:=PMap(AppPtr(curApp)) ;
  case WinCmd of
    Lc_FILE_LIST_BOX:
      begin
        {if clicked in file list box, update current file message:}
        if (DFileName <> '') then begin
          w^.cur_file_msg^.SetStr(DFileName);
          wMouseHide;
          w^.cur_file_msg^.show;
          wMouseShow;
        end;
      end;
    LcRELOAD:
      begin
        w^.LoadMGF;
        wMouseHide;
        w^.pic_box^.Show;
        w^.PicSelection^.Show;
        w^.Grid^.DrawGrid;
        wMouseShow;
      end;
    LcVIEW:
      begin
        DlgView.init(w^.Grid^.Dim.x,w^.Grid^.Dim.y,w^.Grid^.o.x,w^.Grid^.o.y,w^.gData,w^.main_image);
        Dialog(@DlgView);
      end;
    LcHEIGHTS:
      begin
        w^.Grid^.SetHeights(w^.HeightButton^.Status);
        wMouseHide;
        w^.Grid^.DrawGrid;
        wMouseShow;
      end;
    LcHT1:
      begin
        if not w^.Ht1^.Status then w^.Ht1^.SetStatus(true);
        w^.Ht2^.SetStatus(false);
        w^.Ht3^.SetStatus(false);
      end;
    LcHT2:
      begin
        if not w^.Ht2^.Status then w^.Ht2^.SetStatus(true);
        w^.Ht1^.SetStatus(false);
        w^.Ht3^.SetStatus(false);
      end;
    LcHT3:
      begin
        if not w^.Ht3^.Status then w^.Ht3^.SetStatus(true);
        w^.Ht1^.SetStatus(false);
        w^.Ht2^.SetStatus(false);
      end;
    LcGRIDIN:
      begin
        if w^.HeightButton^.Status then begin
          tempBut:=w^.Grid^.GetGridButtonPress;
          Tindex:=w^.Grid^.GetGridIndex;
          if (TIndex<>-1) then begin
            if w^.Ht1^.Status then begin
              if tempBut=1 then
                w^.Grid^.AdjustHeight(TIndex,1)
              else
                w^.Grid^.AdjustHeight(TIndex,-1);
            end;
            if w^.Ht2^.Status then begin
              w^.Grid^.SetHeight(TIndex,w^.HtRange^.Number);
            end;
            if w^.Ht3^.Status then begin
            end;
          end;
        end else
          if w^.FillButton^.Status then
            w^.Grid^.FillData(w^.Grid^.Dim.X,w^.Grid^.Dim.Y,w^.PicSelection^.DataNum[0],w^.PicSelection^.DataNum[1])
          else
            w^.Grid^.SetData(w^.PicSelection^.DataNum[0],w^.PicSelection^.DataNum[1]);
          {endif}
        {endif}
      end;
    {box that shows left/right mouse selection updated here}
    LcPIC_BOX:
      begin
        if (w^.pic_box^.PicPressed<=PictureListSize(w^.pic_box^.dataP)-1) then begin
          wMouseHide;
          if (w^.pic_box^.ButPressed=1) then begin
            w^.PicSelection^.SetLeftData(w^.main_image,w^.map_image,w^.pic_box^.PicPressed);
            w^.PicSelection^.ShowLeftData
          end else begin
            w^.PicSelection^.SetRightData(w^.main_image,w^.map_image,w^.pic_box^.PicPressed);
            w^.PicSelection^.ShowRightData
          end;
          wMouseShow;
        end;
      end;
    LcSAVE1:
      begin
        if w^.LocFile.FileName<>'NoFile' then
          w^.DlgFile.init(' Save file (simple:MF1)',w^.LocFile.FileName)
        else
          w^.DlgFile.init(' Save file (simple:MF1)','*.MF1');
        {endif}
        Dialog(Addr(w^.DlgFile));
      {  SaveMGF;}
        if (DFileName <> '') then begin {save}
          w^.LocFile.init;
          w^.LocFile.AssignFile(DFileName);
          w^.LocFile.CreateFile; {error check!!}
          w^.LocFile.OpenFile;

          w^.LocFile.WriteFile(w^.gXSize,2);
          w^.LocFile.WriteFile(w^.gYSize,2);

          w^.LocFile.WriteFile(w^.gData^.Buffer^[4], w^.gData^.size);
          w^.LocFile.WriteFile(w^.gData^.HeightData^[0], w^.gData^.size);

          w^.LocFile.CloseFile;
        end;



      {    DlgNew.init;
    Dialog(@DlgNew);
    if not((DlgNew.Xinp.Str='') or (DlgNew.Yinp.Str='')) then begin
      DlgFile.init(' Select a graphics file:','*.MGF');
      Dialog(@DlgFile);
      if DFileName<>'' then begin
        Val(DlgNew.Xinp.Str,n1,n3);
        if n3=0 then begin
          Val(DlgNew.Yinp.Str,n2,n3);
          if (n3=0) then begin
            TempFileName:=DFileName;
            DFileName:='';
            (*Create new location edit child window*)
            new(TempMap,init(20,96,20+MAPX,96+MAPY,n1,n2,TempFileName));
            NewAppWin(TempMap);
          end;
        end;
      end;
    end;
  end;}


      end;
    LcLOAD1:
      begin
        w^.DlgFile.init(' Load file (simple:MF1)','*.MF1');
        Dialog(Addr(w^.DlgFile));
        if (DFileName <> '') then begin

          {dispose of possible existing data: }
          temp := w^.gData;
          while (temp <> nil) do begin
            temp^.done;
            temp := PLocData(temp^.next);
          end;

          w^.LocFile.init;
          w^.LocFile.AssignFile(DFileName);
          w^.LocFile.OpenFile;

          w^.LocFile.ReadFile(w^.gXSize,2);
          w^.LocFile.ReadFile(w^.gYSize,2);

{          New(Grid, init(5,20,163,139,gXsize,gYsize,litX,litY,8,lcGridIn,true));}
          w^.Grid^.Dim.setXY(w^.gXSize,w^.gYSize);

          w^.gData^.init(w^.Grid^.Dim.y * w^.Grid^.Dim.x);
          w^.Grid^.Data_Ptr:=plocdata_ptr(w^.gData,1);
          w^.Grid^.LocDataP:=w^.gData;

          w^.LocFile.ReadFile(w^.gData^.Buffer^[4], w^.gData^.size);
          w^.LocFile.ReadFile(w^.gData^.HeightData^[0], w^.gData^.size);

          w^.LocFile.CloseFile;

        end;
        wMouseHide;
        show_all_windows;
        wMouseShow;
{        LoadMGF;}
{        LoadAnMGF(DFileName,PicFile,Datas,Data2s,curData,numData);}
     (*   LoadAnMGF(DFileName,picFile,main_image,map_image,curData,numData);*)

      (*  SetCurData(numData);
        pic_box^.DataP:=map_image;
        Title:=' Map element editor: '+PicFile.FileName; *)

        {ShowWindow(@self,true);}
        {wMouseHide;}
        {pic_box^.Show;}
        {ShowTitle(@self,true);}
        {wMouseShow;}

      end;
  end;
end;

{---------------------------------------------------------------------------------}



{== TMAP ===================================================================}

(*--------------------------------------------------------------------------*)
constructor TMap.init(x1,y1,x2,y2,xs,ys: integer; iMGFFile: string);
begin
{  sound(700);  delay(50);  nosound;  delay(80);}
  MGFFile.init;
  if (iMGFFile<>'') then MGFFile.AssignFile(iMGFFile);
  {initial grid size (default = 25x25)}
  gXsize:=xs; gYsize:=ys;
  main_image:=nil; map_image:=nil; gData:=nil;
  TAppWin.init(x1,y1,x2,y2);
end;

(*--------------------------------------------------------------------------*)
procedure TMap.InitWindow;
begin
  LOCFile.init;
  Title := '('+DFileName+')';
  if (DFileName<>'') then begin
    LOCFile.AssignFile(DFileName);
    Title:='[DBug]';
  end;
  Title:=Title+'<LocFile:'+LOCFile.FileName+'>';

  New(PicSelection, init(5,240,0));
  New(Grid, init(5,20,163,139,gXsize,gYsize,litX,litY,8,lcGridIn,true));

  if (MGFFile.FileName='NoFile') then begin {shouldnt happen(not yet)}
    beep(300,100);
    delay(100);
    beep(300,100);
    delay(100);
    beep(300,100);
    delay(100);
  end;
  if (MGFFile.FileName<>'NoFile') then begin
    LoadMGF;
    Title := Title + '['+MGFFile.FileName+'/'+'DBug2]';
  end;

  New(pic_box, init(5,152,lcpic_box,map_image));

  New(msg_line, init(6,MAPY-15,MAPX-6,MAPY-5,10,2,'Nothing to say right now',Yellow,Magenta));
  New(msg_rect, init(5,MAPY-16,MAPX-5,MAPY-4,14));

  New(MGF_file_list_box, init(170,152,285,218,15,1,lc_file_list_box,'*.MGF'));
  New(cur_file_msg, init(171,224,284,233,4 ,2,MGFFILE.FileName,Yellow,Magenta));
  New(cur_file_rect, init(170,223,285,234,Yellow));

{  exit;}
{-> THIS IS CAUSING THE FLIPPING BUG!!!!  }
{    loc_Grid^.init(3,20,167,146,lc_gridin,gXsize,gYsize);}

    New(grid_place_mode, init(170,120,230,139,'single',true,lc_grid_place_mode));
    New(loc_struct_ed, init(300,20,lc_loc_struct_ed));

  New(HtRange, init(MButX2+3,25    ,0        ,HeightMin,HeightMax));
  New(FillButton, init(MButX,40,MButX2,59       ,'Fill',       false,LcFILL));
  New(HeightButton, init(MButX,60,MButX2,79       ,'Heights',    false,LcHEIGHTS));
  New(Ht1, init(MButX2+1,60    ,MButX2+65,79,'Ind Adj', true ,LcHT1));
  New(Ht2, init(MButX2+1,80    ,MButX2+65,99,'Ind Set', false,LcHT2));
  New(Ht3, init(MButX2+1,100   ,MButX2+65,119,'FillSet',false,LcHT3));

{  sound(500);  delay(50);  nosound;  delay(80);}

  gData:=new(PLocData, init(Grid^.Dim.y*Grid^.Dim.x));
  if gData = nil then begin
    beep(200,100);
    beep(300,100);
    beep(400,100);
    beep(500,100);
    beep(600,100);
    halt;
  end;

  {data_ptr points at the first} {type = wrong?}
  Grid^.Data_Ptr:=plocdata_ptr(gData,1);
  Grid^.LocDataP:=gData;

  items:=
    link(loc_struct_ed,
    link(grid_place_mode,

    Link(Grid,              {later this must go}
 {   link(@loc_grid,          {also remember remove reload}

    Link(MGF_file_list_box, {File list box}
    link(cur_file_msg,      {File name selected}
    link(cur_file_rect,     {rectangle around that box}

    Link(msg_line,          {Message box}
    link(msg_rect,

    Link(FillButton,        {Buttons!}
    Link(HeightButton,
    Link(Ht1,
    Link(Ht2,
    Link(Ht3,
    Link(HtRange,           {Height selector box}

    Link(pic_box,
    Link(PicSelection,

    NewTextButton(MButX,20,MButX2,39,'View',lcView,
    NewTextButton(MButX,80,MButX2,99,'ReSize',lcReSize,
    NewTextButton(MButX,250,MButX2,269,'Load',lcLoad,
    NewTextButton(MButX,270,MButX2,289,'Save',lcSave,
    NewTextButton(MButX2+1,250,MButX2+1+(MButX2-MButX),269,'Load1',LcLOAD1,
    NewTextButton(MButX2+1,270,MButX2+1+(MButX2-MButX),289,'Save1',LcSAVE1,

    nil
  ))))))))))))))))))))));

  wMouseHide;
  beep(200,100);
  wMouseShow;
end;

{------------------------------------------------------------------------------}
function TMapEd.HandleCmd(cmdNum: integer): integer;
  var TempMap: PMap{ PTemp};
  procedure NewMap;
    var n1,n2,n3: integer;
    TempFileName: string;
  begin
{    new(TempMap, init(30,30,400,340));
    NewAppWin(TempMap);
    exit;}

    DlgNew.init;
    Dialog(@DlgNew);
    if not((DlgNew.Xinp.Str='') or (DlgNew.Yinp.Str='')) then begin
      DlgFile.init(' Select a graphics file:','*.MGF');
      Dialog(@DlgFile);
      if DFileName<>'' then begin
        {MGFAssignFile}
        Val(DlgNew.Xinp.Str,n1,n3);
        if n3=0 then begin
          Val(DlgNew.Yinp.Str,n2,n3);
          if (n3=0) then begin {no error}
            TempFileName:=DFileName;
            DFileName:='';
            {Create new location edit child window}
            new(TempMap,init(20,96,20+MAPX,96+MAPY,n1,n2,TempFileName));
            NewAppWin(TempMap);
          end;
        end;
      end;
    end;
  end;
begin
  case cmdNum of
    mcNew:
      begin
        NewMap;
      end;

    mcLoad: {not yet implemented}
      begin
        DlgFile.init(' Load location file','*.PAS'{LOC});
        Dialog(@DlgFile);
        if DFileName<>'' then begin {check for wildcard!!!}
{          new(TempMap,init(160,116,160+MapX,116+MapY,5,5,''));}
          {load}
          NewAppWin(TempMap);
{          TempMap^.AssignLOCfile(DFileName);}
        end;
      end;
  end;
end;
(*--------------------------------------------------------------------------*)
procedure TMapEd.InitWindow;
begin
  r.SetXYXY(GetMaxX-mx2+mx1,my1,GetMaxX-mx1,my2);
  Title:=' Location editor';
  items:=
    NewText(10,25,90,38,4,3,'Locations',Red,LightGray,
    NewTextButton(10,40,90,59,'New',mcNew,
    NewTextButton(10,60,90,79,'Load',mcLoad,
    NewTextButton(10,80,90,99,'Delete',mcDelete,
    NewRectangle(9,25,91,100,White,

    NewText(100,25,190,38,4,3,'  Links',Red,LightGray,
    NewTextButton(100,40,190,59,'2-way',mc2Link,
    NewTextButton(100,60,190,79,'1-way',mc1Link,
    NewRectangle(99,25,191,80,White,
  nil)))))))));
end;

{== NEW LOC DIALOG =========================================================}
(*--------------------------------------------------------------------------*)
procedure TMap.LoadMGF;
  var TFileName: string;
begin
  LoadAnMGF(MGFFile.FileName,MGFFile,main_image,map_image,curGraf,numGraf);
  Grid^.PicDataList:=map_image; {grid has pointer to image data}
  pic_box^.DataP:=map_image;    {pic-box has pointer to image data}
  {repetition in a picselection of main_ and map_image? How dumb.}
  PicSelection^.SetLeftData(main_image,map_image,0);
  PicSelection^.SetRightData(main_image,map_image,0);  {!!! (SHOWS???) }
end;

(*--------------------------------------------------------------------------*)
procedure TDlgNew.InitAll;
begin
  r.setXYXY(MidX-140,MidY-60,MidX+140,MidY+60);
  Title:=' New LOC window:';
  Xinp.init(68,25,130,37,Yellow,Magenta,0,'15');
  Yinp.init(208,25,270,37,Yellow,Magenta,0,'15');
  items:= {!!!erk: made and never destroyed!!!}
    NewText(10,26,66,36,0,1,'X size:',Yellow,Magenta,{White,8,}
    NewText(150,26,206,36,0,1,'Y size:',Yellow,Magenta,{15,8,}

    NewTextButton(13,50,134,110,'OK',1,
    NewTextButton(154,50,265,110,'Cancel',2,

    Link(@Xinp,
    Link(@Yinp,
  nil))))));
end;
procedure TDlgNew.ShutDown;
begin
  Xinp.Str:=''; YInp.Str:='';
end;
function TDlgNew.HandleCmd(cmdNum: integer): integer;
  var Tret:integer;
begin
  case cmdNum of
    1: {ok}
      begin
        if (Xinp.Str='') or (Yinp.Str='') then Tret:=DlgBreak
        else Tret:=DlgExit;
      end;
    2: {cancel} Tret:=DlgBreak;
  end;
  HandleCmd:=Tret;
end;


(*--------------------------------------------------------------------------*)
constructor TDlgView.Init(ix,iy,ixo,iyo: integer; igData: PLocData; imain_image: Ppicture);
begin
  TDialog.init;
  main_image:=imain_image;
  gData:=igData;
  x:=ix; y:=iy; xo:=ixo; yo:=iyo;
  ViewIso.init(10,26,590,336,x,y,xo,yo,gData,main_image);
end;
(*--------------------------------------------------------------------------*)
procedure TDlgView.InitAll;
begin
  r.setXYXY(MidX-300,MidY-186,MidX+300,MidY+191);
  Title:=' View location:'; {!!!}
  items:=
    Link(@ViewIso,
    NewTextButton(210,340,390,370,'OK',10,nil));
end;
(*--------------------------------------------------------------------------*)
function TDlgView.HandleCmd(cmdNum: integer): integer;
  var tret: integer;
begin
  tret:=0;
  case cmdNum of
    10: tret:=DlgExit;
  end;
  HandleCmd:=tret;
end;
{---------------------------------------------------------------------------------}

{------------------------------------------------------------------------------}
begin
end.