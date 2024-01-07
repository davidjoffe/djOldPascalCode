{$G+,S-}
program TestIso;

uses graph,crt;

const gs=12;
      s=24;

var
  gd,gm,i,j: integer;

begin
  gd:=installuserdriver('svga256',nil); gm:=2;
  initgraph(gd,gm,'\tp\bgi');

  setfillstyle(1,8);
  bar(0,0,GetMaxX,GetMaxY);
  setcolor(10);
  for i:=0 to gs do begin
    line(50+i*s,150+i*(s div 2), 50+(i+gs)*s,150+(i-gs)* (s div 2));
    line(50+i*s,150-i*(s div 2), 50+(i+gs)*s,150-(i-gs)* (s div 2));
  end;
  setfillstyle(1,2);
  for i:=0 to gs-1 do begin
    for j:=0 to gs-1 do begin
      FloodFill(350-(i*s) +(j*s)-s,(160-((gs*s)div 2)) +(i+j)*(s div 2),10);
    end;
  end;
  repeat until readkey<>'';
  setfillstyle(1,8);
  bar(0,0,GetMaxX,GetMaxY);
  for i:=0 to gs do begin
    for j:=0 to gs do begin
      PutPixel(  (GetMaxX div 2)-(i*s) +(j*s)-s,((GetMaxY div 2)-((gs*s)div 2)) +(i+j)*(s div 2),15);
    end;
  end;
  repeat until readkey<>'';
end.