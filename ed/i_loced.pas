{$G+,S-}
unit i_loced;
{ David Joffe '94/12 }
{ The special items for the "little" loc ed window }

interface

uses
  w_item,uo_obj,graph,ed_data,e_gen;

type
  ploc_grid=^tloc_grid;
  tloc_grid=object(TItem)
    edit_mode      : integer;        { used for when placing etc.     }
    loc_item_arrp  : ploc_item_arr;  { ptr to array of ptrs to lists  }
    xsize,ysize    : integer;
    xpos,ypos,xo,yo: integer;        { scrolling + position for grid  }

    constructor init(x1,y1,x2,y2,iRetCmd,ixsize,iysize: integer);
    procedure show; virtual;
    procedure show_grid;
    procedure handlemouse(x,y,b: integer); virtual;
    destructor done; virtual;
  end;

  {tall thingy with rectangles}
  ploc_struct_ed=^tloc_struct_ed;
  tloc_struct_ed=object(TItem)
    size: integer;
    {array of tloc_item's}
    loc_item_arr: array[0..TLOC_STRUCT_ED_MAXCHAR-1] of tloc_item;
    constructor init(x1,y1,iRetCmd: integer);
    procedure show; virtual;
    procedure handlemouse(x,y,b: integer); virtual;
  end;

{=== EXCERPT FROM ED\ED_DATA.PAS:

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


=== END EXCERPT }


implementation

uses w_mouse,u_useful;

(*=======================================================================*)
constructor tloc_struct_ed.init;
  var i: integer;
begin
  TItem.init(x1,y1,x1+6+litY,y1+(TLOC_STRUCT_ED_MAXCHAR*litY)+6+27,iRetCmd);
  for i:=0 to TLOC_STRUCT_ED_MAXCHAR-1 do begin
    loc_item_arr[i].init(0,0,0);
  end;
  size:=0;
end;
procedure tloc_struct_ed.show;
  var i: integer;
begin
  with r do FillBackground(1,0,a.x,a.y,b.x,b.y);
  with r do ItemRectangle(7,a.x,a.y,b.x,b.y);

  {rectangles}
  setcolor(8);
  for i:=0 to TLOC_STRUCT_ED_MAXCHAR-1 do begin
    rectangle(r.a.x+3,r.a.y+3+i*litY,r.a.x+3+litX,r.a.y+3+i*litY+litY);
    {show}
  end;

  {arrow boxes}
  for i:=2 downto 1 do begin
    rectangle(r.a.x+2,r.b.y-2-i*12,r.b.x-2,r.b.y-2-i*12+12);
  end;
  outtextxy(r.a.x+5,r.b.y-2-12-12+3,'');
  outtextxy(r.a.x+5,r.b.y-2-12+3,'');
end;
procedure tloc_struct_ed.handlemouse;
begin

end;
(*=======================================================================*)
constructor tloc_grid.init;
  var i: integer;
begin
  TItem.init(x1,y1,x2,y2,iRetCmd);
  xpos:=0; ypos:=0; xo:=0; yo:=0;
  xsize:=ixsize;
  ysize:=iysize;
  if (maxavail < 4 * (xsize * ysize)) then begin
    beep(600,100);
    beep(400,100);
    beep(200,100);
    halt;
  end;
  {pointer size, times by array dimensions i.e. * [xsize][ysize]}
  getmem(loc_item_arrp, 4 * (xsize * ysize));
  for i:=0 to (xsize*ysize)-1 do begin
    loc_item_arrp^[i]^.init(0,0,0);
  end;
end;
destructor tloc_grid.done;
begin
  freemem(loc_item_arrp, 4 * (xsize * ysize));
end;
procedure tloc_grid.show_grid;
  var xfit,yfit,i,j: integer;
begin
  setcolor(8);
  xfit:=(((r.b.x-r.a.x+1)-4-40) div litX);
  yfit:=(((r.b.y-r.a.y+1)-4) div litY);
  if (xfit < 0) then xfit:=0;
  if (yfit < 0) then yfit:=0;
  if (xfit > xsize) then xfit:=xsize;
  if (yfit > ysize) then yfit:=ysize;
  for i:=0 to yfit-1 do begin
    for j:=0 to xfit-1 do begin
      with r do begin
        rectangle
        (a.x+j*litX+2,a.y+i*litY+2,a.x+j*litX+litX+2,a.y+i*litY+litY+2);
      end;
    end;
  end;
  setcolor(9);
end;
procedure tloc_grid.show;
begin
  setfillstyle(1,0);
  with r do bar(a.x,a.y,b.x,b.y);
  setcolor(7);
  with r do rectangle(a.x,a.y,b.x,b.y);
  show_grid;
  setcolor(8);

  outtextxy(r.b.x-38,r.a.y+4,'ED');
  rectangle(r.b.x-40,r.a.y+2,r.b.x-20,r.a.y+12);
  with r do begin
    outtextxy(b.x-38,a.y+38,'MOVE:');
    outtextxy(b.x-24,a.y+50,'');
    outtextxy(b.x-36,a.y+60,'');
    outtextxy(b.x-24,a.y+60,'');
    outtextxy(b.x-12,a.y+60,#26);
    rectangle(b.x-38,a.y+58,b.x-2,a.y+70);
    rectangle(b.x-26,a.y+46,b.x-14,a.y+70);
  end;

end;
procedure tloc_grid.handlemouse;
begin

end;
(*=======================================================================*)

end.