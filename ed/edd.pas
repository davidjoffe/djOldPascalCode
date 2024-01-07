{ David Joffe '94/12                       }
{ The main module for the isometric editor }
program isometric_landscape_editor;

{$M 16384,0,655360}  {memory sizes               }
{$G+}                {286 code generation on     }
{$S-}                {stack overflow checking off}

uses
  w,u_keys,w_menus,graph,i_buttons,w_items,w_win,w_app,
  ed_app00,ed_app01,w_stddlg,crt,u_useful,u_files,e_gen
;

const
{menu commands}
  cmNEW =$0101;
  cmMEM =$0102;
  cmEXIT=$0104;

  cmNEXT=$0201;
  cmPREV=$0202;

{control window command buttons}
  ccNEW=1;
  ccMEM=2;

type
  {=======================================================================}
  TDlgNew=object(TDialog)
    ChBox: TChoice;
    procedure InitAll; virtual;
    function HandleCmd(cmdNum: integer): integer; virtual;
  end;
  {=======================================================================}
  TEd=object(TApplication)
    procedure HandleMenuCommand(cmdNum: integer); virtual;
  end;
  {=======================================================================}
  PControl=^TControl;
  TControl=object(TApp)
    ButNew,ButMem,ButTemp: PTextButton;
    FreeMem: TDlgMem;
    procedure InitWindow; virtual;
    function HandleCmd(cmdNum: integer): integer; virtual;
  end;
  {=======================================================================}

var
  DlgNew: TDlgNew;
  DlgMem: TDlgMem;
  PalBuf: array[0..767] of byte;

(*--------------------------------------------------------------------------*)
procedure TControl.InitWindow;
begin
  Title:='Control';
  r.setXYXY(GetMaxX-120,GetMaxY-105,GetMaxX-30,GetMaxY-30{+15});
  New(ButNew, init(10,26,80,45,'New',ccNew));
  New(ButMem, init(10,46,80,65,'Memory',ccMem));
  items:=
    Link(ButNew,
    Link(ButMem,
    nil
  ));
end;
(*--------------------------------------------------------------------------*)
function TControl.HandleCmd(cmdNum: integer): integer;
  var num: integer;
begin
  case cmdNum of
    ccNEW:
      begin
        num:=Dialog(@DlgNew);
        case num of
          0: exit;
          1:
            begin
              case DlgNew.ChBox.chCur of
                1: NewApp(new(PGraphics,init));
                2: NewApp(new(PMapEd,init));
              end;
            end;
          2: exit;
        end;
      end;
    ccMEM:
      Dialog(@DlgMem);
{    123:
      NewApp(new(PControl,init));}
  end;
end;

{ DIALOGS: --------------------------------------------------------------}

{Choice dialog for a new editor:-----------------------------------------}

(*--------------------------------------------------------------------------*)
function TDlgNew.HandleCmd(cmdNum: integer): integer;
  var RetNum: integer;
begin
  RetNum:=0;
  case cmdNum of
    1,2: RetNum:=-1;
  end;
  HandleCmd:=RetNum;
end;

(*--------------------------------------------------------------------------*)
procedure TDlgNew.InitAll;
begin
  r.setXYXY(MidX-130,MidY-80,MidX+130,MidY+80);
  Title:='  New:';
  ChBox.init(9,40,251,78,Yellow,Magenta,2,
        NewChoiceItem('Graphics',
        NewChoiceItem('Terrain',nil)));
  items:=
    NewRectangle(9,24,251,40,Yellow,
    NewText(10,25,250,39,3,4,'Select type of editor:',Yellow,Magenta,
    NewTextButton(34,125,90,145,'OK',1,
    NewTextButton(170,125,226,145,'Cancel',2,@ChBox
  ))));
end;
{------------------------------------------------------------------------}


(*--------------------------------------------------------------------------*)
procedure TEd.HandleMenuCommand(cmdNum: integer);
  var num: integer;
begin
  case cmdNum of
    cmNEW:
      begin
        num:=Dialog(@DlgNew);
        case num of
          0: exit;
          1:  {ok}
            begin
              case DlgNew.ChBox.chCur of
                1: NewApp(new(PGraphics,init));
                2: NewApp(new(PMapEd,init));
              end;
            end;
          2: exit;  {cancel}
        end;
      end;

    cmEXIT: done;

    cmMEM :
      begin
        Dialog(@DlgMem);
      end;

    cmNEXT: set_cur_app(CurApp+1);
    cmPREV: set_cur_app(CurApp-1);

  end;
end;

(*--------------------------------------------------------------------------*)
procedure InitMenuBar;
begin
  MenuBar.Init(GetMaxX,MenuColors);
  MenuBar.NewHead('~File',8,170,kyF,
    NewItem('~New editor','Alt+N',kyN,AltN,
    NewItem('Avail. ~memory','',kyM,NoHotKey,
    NewLine(
    NewItem('E~xit','Alt+X',kyX,AltX,
    nil
  )))));
  MenuBar.NewHead('~Window',85,170,kyW,
    NewItem('~Next','F6',kyN,F6,
    NewItem('~Previous','Shift+F6',kyP,ShiftF6,
    nil
  )));
  MenuBar.NewHead('~Help',550,190,kyH,
    NewItem('Sorry - help not','',0,nohotkey,
    NewItem('implemented yet.','',0,nohotkey,
    NewItem('Ask me.','',0,nohotkey,
    nil
  ))));
end;

const
  ResOps:array[1..6] of string[60]=(
    ' <1: 640x400x256> (null)',
    '2: 640x480x256',
    '3: RealMode: 800x600x256 / DPMI: 640x480x256',
    '4: 1024x768x256',
    '5: 640x350x256',
    'Default: 640x480x16'
  );

var
  App: TEd;
  gd,gm: integer;
  DlgFile: TDlgFile;
  a: char;

{Protected mode only: (change to compiler defines)}
  PROCEDURE SVGADriver; FAR; EXTERNAL;          { <-- der Treiber }
  {$L SVGA.OBJ}                             { Einbinden der OBJ-Datei }
(*==========================================================================*)
begin
  clrscr;
  writeln('Select resolution: (ESC bypass:default = VGA 16 colors)');
  writeln;
  for gd:=1 to 6 do writeln(ResOps[gd]);
  writeln;

  repeat
    if not keypressed then continue;
    a:=readkey;
    if a=#27 then break;
    if a=#0 then a:=readkey;
  until (a>='2') and (a<='6');
  if (a<>#27) then gm:=ord(a)-48 else gm:=6;

{ SVGA protected mode }
    gd := InstallUserDriver ('SVGA', NIL);
    IF (gd < 0) THEN halt;
    IF (RegisterBGIDriver (@SVGADriver) < 0) THEN begin
      writeln('* Kapuff *');
      halt;
    end;

  if (gm <> 6) then begin
  { SVGA real mode:}
  {  gd:=InstallUserDriver('svga386',nil);}
    App.init(gd,gm);
  end else begin
  { VGA:}
    App.init(VGA,VGAHI);
  end;

  InitMenuBar;

  DlgMem.Init;
  DlgNew.Init;

  NewApp(new(PControl,init));

  {set the palette for 256-color modes}
  if (getmaxcolor = 255) then begin
    openfile(PALETTE_FILE,1);
    ReadFile(1,@PalBuf,768);
    asm
      mov ax,seg PalBuf
      mov es,ax
      mov dx,offset PalBuf   {ES:DX = palette buffer}
      mov cx,256
      xor bx,bx
      mov ax,1012h
      int 10h                {set palette}
    end;
    CloseFile(1);
  end;

  App.Run;
  App.done;
end.