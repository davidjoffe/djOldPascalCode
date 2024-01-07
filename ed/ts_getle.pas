program TestGetAndPutDiffBetweenLettersAndPut;
{ David Joffe '95/01 }

uses crt,graph,dos,u_useful;

var gd,gm,i,j,k,l,n1,n2,c1,c2: integer;

const
  pic: array[0..15,0..15] of byte=(
    (15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15),
    (15, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 8),
    (15, 7, 7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 7, 7, 7, 8),
    (15, 7, 7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8, 7, 7, 8),
    (15, 7, 7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8, 7, 7, 8),
    (15, 7, 7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8, 7, 7, 8),
    (15, 7, 7, 0, 0, 0, 8, 8, 0, 0, 0, 0, 8, 7, 7, 8),
    (15, 7, 7, 0, 0, 8, 8, 7, 7, 0, 0, 0, 8, 7, 7, 8),
    (15, 7, 7, 0, 0, 8, 7, 7, 7, 0, 0, 0, 8, 7, 7, 8),
    (15, 7, 7, 0, 0, 0, 7, 7, 0, 0, 0, 0, 8, 7, 7, 8),
    (15, 7, 7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8, 7, 7, 8),
    (15, 7, 7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8, 7, 7, 8),
    (15, 7, 7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8, 7, 7, 8),
    (15, 7, 7, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 7, 7, 8),
    (15, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 8),
    (15, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8)
  );

var
  Img: array[0..1025] of byte;
  size,count: word;
  strn: string;
  s: string;
  o: pointer;

{$F+}
procedure NewTimer; interrupt;
begin
  inc(count);
end;
{$F-}
procedure SetTimer;
begin
  count:=0;
  getintvec($1C,o);
  setintvec($1c,@NewTimer);
end;
procedure ReSetTimer;
begin
  setintvec($1c,o);
end;
begin
  gd:=installuserdriver('svga256',nil);
  gm:=0;

{  gd:=vga;
  gm:=vgahi;}
  initgraph(gd,gm,'\tp\bgi');
  n1:=getmaxx div 16;
  n2:=getmaxy div 16;
  for i:=0 to 15 do for j:=0 to 15 do putpixel(j,i,pic[i,j]);
  getimage(0,0,15,15,img);

  repeat until readkey<>'';
  settimer;
  for i:=0 to n2 *2 do for j:=0 to 15 do begin
    setfillstyle(1,7);
    bar(j*48,i*8,j*48+47,i*8+7);
    setcolor(15);
    OutTextXY(j*48,i*8,' save ');
  end;
  ReSetTimer;
  c1:=count;
  repeat until readkey<>'';
  settimer;
  for i:=0 to n2 do for j:=0 to n1 div 2 do PutImage(j*16,i*16,img,NormalPut);
  resettimer;
  c2:=count;
  repeat until readkey<>'';
  setfillstyle(1,0);
  bar(0,0,100,32);
  outtextxy(0,0,intstr(c1,10));
  outtextxy(0,16,intstr(c2,10));
  repeat until readkey<>'';
end.