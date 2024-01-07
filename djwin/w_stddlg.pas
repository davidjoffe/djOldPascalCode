{$G+}
unit w_stddlg;
{ David Joffe '94/12 }
{ Some general purpose dialog box objects for DJWIN }

interface

uses
  u_keys,w_item,w_items,w_items3,w_win,i_buttons,
  graph,w_files,u_useful
;

type
  PDlgMem=^TDlgMem;
  TDlgMem=object(TDialog)
    MemText: TText;
    function HandleCmd(cmdNum: integer): integer; virtual;
    procedure InitAll; virtual;
    procedure InitInfo; virtual;
  end;

  PDlgFile=^TDlgFile;
  TDlgFile=object(TDialog)
    WildText: TTextInput;
    FileListBox: TFileListBox;
    function HandleCmd(cmdNum: integer): integer; virtual;
    constructor Init(iTitle,iWild: string);
    procedure InitAll; virtual;
    procedure InitInfo; virtual;
    procedure ShutDown; virtual;
  end;

  PDlgResize=^TDlgResize;
  TDlgResize=object(TDialog)
    OldX,OldY: TText;
    NewXMsg,NewYMsg: TText;
    NewX,NewY: TTextInput;
    constructor init(iTitle: string; iOldX,iOldY,iNewX,iNewY: integer);
    function HandleCmd(cmdNum: integer): integer; virtual;
    procedure InitAll; virtual;
    procedure ShutDown; virtual;
  end;

  PDlgNewXY=^TDlgNewXY;
  TDlgNewXY=object(TDialog)
    NewX,NewY: TTextInput;
    OK,Cancel: TTextButton;
    constructor init(iNewX,iNewY: integer);
    function HandleCmd(cmdNum: integer):integer; virtual;
    procedure ShutDown; virtual;
  end;

  PDlgWarning=^TDlgWarning;
  TDlgWarning=object(TDialog)
    Str1,Str2: TText;
    OKStatus: boolean;
    constructor init(iStr1,iStr2: string);
    function HandleCmd(cmdNum: integer): integer; virtual;
    procedure InitAll; virtual;
    procedure ShutDown; virtual;

  end;

var
  StdDlgFileItems: PItem;

{return codes: -1=error, 0=filename, 1=wildcard}
function TestFileName(filename:string):integer;

implementation
uses w,crt,w_mouse;

(*--------------------------------------------------------------------------*)
constructor TDlgNewXY.init(iNewX,iNewY: integer);
begin
  TDialog.init;
  r.setXYXY(midx-100,midy-50,midx+100,midy+50);
  Title:='New X and Y:';
  NewX.init(10,26,60,36,Yellow,Magenta,10,IntStr(iNewX,10));
  NewY.init(70,26,120,36,Yellow,Magenta,11,IntStr(iNewY,10));
  OK.init(10,70,95,90,'OK',12);
  Cancel.init(105,70,190,90,'cancel',13);
  items:=
    Link(@NewX,
    Link(@NewY,
    Link(@OK,
    Link(@Cancel,
  nil))));
end;
(*--------------------------------------------------------------------------*)
function TDlgNewXY.HandleCmd(cmdNum: integer):integer;
  var tret: integer;
begin
  tret:=0;
  case cmdNum of
    12: tret:=DlgExit;
    13: tret:=DlgBreak;
  end;
  HandleCmd:=tret;
end;
(*--------------------------------------------------------------------------*)
procedure TDlgNewXY.ShutDown;
begin
  NewX.Str:='';
  NewY.Str:='';
end;


{== WARNING MESSAGE ========================================================}
(*--------------------------------------------------------------------------*)
constructor TDlgWarning.init(iStr1,iStr2: string);
begin
  TDialog.Init;
  Str1.init(10,26,190,36,2,1,iStr1,Yellow,Magenta);
  Str2.init(10,46,190,56,2,1,iStr2,Yellow,Magenta);
end;
(*--------------------------------------------------------------------------*)
procedure TDlgWarning.initall;
begin
  r.setXYXY(midX-100,MidY-56,MidX+100,MidY+56);
  Title:='   Warning!';
  items:=
    Link(@Str1,
    Link(@Str2,
    newtextbutton(15,76,93,96,'OK',10,
    newtextbutton(108,76,185,96,'cancel',11,
  nil))));
end;
(*--------------------------------------------------------------------------*)
function TDlgWarning.HandleCmd(cmdNum: integer): integer;
  var tret: integer;
begin
  tret:=0;
  case cmdNum of
    10:
      begin
        OKStatus:=true;
        tret:=DlgExit;
      end;
    11: tret:=DlgBreak;
  end;
  HandleCmd:=tret;
end;
(*--------------------------------------------------------------------------*)
procedure TDlgWarning.ShutDown;
begin
  OKStatus:=false;
end;

{== RESIZE =================================================================}
(*--------------------------------------------------------------------------*)
constructor TDlgResize.init(iTitle: string; iOldX,iOldY,iNewX,iNewY: integer);
begin
  TDialog.init;
  if iTitle='' then iTitle:='Resize';
  Title:=iTitle;
  OldX.Str:='Old X: '+IntStr(iOldX,10);
  OldY.Str:='Old Y: '+IntStr(iOldY,10);
  NewX.Str:=IntStr(iNewX,10);
  NewY.Str:=IntStr(iNewY,10);
  if NewX.Str='0' then NewX.Str:='';
  if NewY.Str='0' then NewY.Str:='';
end;
(*--------------------------------------------------------------------------*)
procedure TDlgResize.initall;
begin
  r.SetXYXY(MidX-129,MidY-56,MidX+129,MidY+56);

  OldX.init(10,26,90,38,3,3,'',Yellow,Magenta);
  OldY.init(110,26,190,38,3,3,'',Yellow,Magenta);
  NewXMsg.init(10,50,60,62,3,3,'New X:',Yellow,Magenta);
  NewYMsg.init(110,50,160,62,3,3,'New Y:',Yellow,Magenta);
  NewX.init(65,50,105,62,Yellow,Magenta,0,'');
  NewY.init(165,50,205,62,Yellow,Magenta,0,'');
  items:=
    Link(@OldX,
    Link(@OldY,
    Link(@NewX,
    Link(@NewY,
    Link(@NewXMsg,
    Link(@NewYMsg,
    NewTextButton(210,26,250,100,'OK',10,
    NewTextButton(10,74,205,100,'cancel',11,nil
  ))))))));
end;
(*--------------------------------------------------------------------------*)
function TDlgResize.HandleCmd(cmdNum: integer): integer;
  var tret: integer;
begin
  Tret:=0;
  case cmdNum of
    10:
      tret:=DlgExit;

    11: tret:=Dlgbreak; {will call shutdown}
  end;
  HandleCmd:=tret;
end;
(*--------------------------------------------------------------------------*)
procedure TDlgResize.ShutDown;
begin
  NewX.Str:='';
  NewY.Str:='';
end;




{== FILENAME ===============================================================}
(*--------------------------------------------------------------------------*)
constructor TDlgFile.init(iTitle,iWild: string);
begin
  TDialog.init;
  Title:=iTitle;
  WildText.Str:=iWild;
  DFileName:='';
end;
(*--------------------------------------------------------------------------*)
procedure TDlgFile.ShutDown;
begin
  DFileName:='';
end;
(*--------------------------------------------------------------------------*)
procedure TDlgFile.InitInfo;
begin
  FileListBox.GetFileList(WildText.Str);
  DFileName:='';
end;

(*--------------------------------------------------------------------------*)
function TDlgFile.HandleCmd(cmdNum: integer): integer;
  var Tret: integer;
begin
  Tret:=0;
  case cmdNum of
    1,10: {OK or ENTER press in file name text field}
    begin
      case testfilename(wildtext.str) of
        -1: {error}
        begin
          Beep(120,75);
        end;
        1: {normal filename}
        begin
          FileListBox.GetFileList(WildText.Str);
          wMouseHide;
          FileListBox.Show;
          wMouseShow;
        end;
        0: {normal filename: store in Dfilename and exit}
        begin
          DFileName:=WildText.Str;
          Tret:=DLG_EXIT;
        end;
      end; {case}
    end;
    2: {cancel}
    begin
      DFileName:='';
      Tret:=DLG_EXIT;
    end;
    11: {clicked in list box: select new filename from list}
    begin
      if DFileName<>'' then begin
        WildText.Str:=DFileName;
        wMouseHide;
        WildText.Show;
        wMouseShow;
      end;
    end;
  end;
  HandleCmd:=Tret;
end;

  {return codes: -1=error, 0=normal filename, 1=wildcard}
(*--------------------------------------------------------------------------*)
  function TestFileName(filename: string): integer;
    var i,Tret: integer;
       is_wild: boolean;
    label FoundResult;
  begin
    Tret:=-1; {default=error}

    if filename='' then goto FoundResult;

    {bad chars:}
    for i:=1 to length(filename) do begin
      if (copy(filename,i,1)<#33) then goto FoundResult;
    end;

    {assume normal filename}
    Tret:=0;

    {test if wildcard}
    is_wild:=((Pos('*',filename)<>0) or (Pos('?',filename)<>0));
    if is_wild then begin
      beep(1000,80);
      tret:=1;
    end;

    {for i:=1 to length(Str) do begin
      t:=Copy(Str,i,1);
      if (t='?') or (t='*') then Tret:=1;
    end;}

  FoundResult:
    TestFileName:=Tret;
  end;

(*--------------------------------------------------------------------------*)
procedure TDlgFile.InitAll;
begin
  r.setXYXY(MidX-110,MidY-81,MidX+110,MidY+81);

  WildText.init(10,39,210,54,Yellow,Magenta,10,'');
  FileListBox.init(10,70,130,153,Yellow,Magenta,11,'');

  items:=
    Link(@WildText,
    Link(@FileListBox,
    LinkList(StdDlgFileItems,nil
  )));
end;
{== MEMORY AVAILABLE =======================================================}
(*--------------------------------------------------------------------------*)
function TDlgMem.HandleCmd(cmdNum: integer): integer;
  var RetNum: integer;
begin
  RetNum:=0;
  if CmdNum<>0 then RetNum:=-1;
  HandleCmd:=RetNum;
end;
(*--------------------------------------------------------------------------*)
procedure TDlgMem.InitAll;
begin
  r.setXYXY(MidX-100,MidY-50,MidX+100,MidY+50);
  Title:=' Memory available:';
  MemText.init(10,25,190,40,3,4,'',Yellow,Magenta);
  MemText.next:=nil;
  items:=
    NewRectangle(9,24,191,41,Yellow,
    NewTextButton(70,65,130,88,'OK',1,@MemText)
  );
end;
(*--------------------------------------------------------------------------*)
procedure TDlgMem.InitInfo;
begin
  Str(MemAvail,MemText.Str);
  with MemText do Str:=Str+' bytes';
end;
{===========================================================================}

begin
  StdDlgFileItems:=
    NewText(10,26,64,38,4,2,'Name:',Yellow,Magenta,
    NewText(10,56,64,68,4,2,'Files:',Yellow,Magenta,
    NewTextButton(145,71,205,90,'OK',1,
    NewTextButton(145,101,205,120,'cancel',2,nil
  ))));
end.