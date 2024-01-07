program test;

uses
  crt;

var
  p: pointer;
  i: integer;

begin
  clrscr;
  i:=10;
  p:=addr(i);

  writeln(i);

  {round-about way of dereferencing to override pascals strict pointer
   type incompatibility}
  memw[seg(p^):ofs(p^)]:=15;
  writeln(i);

  repeat until readkey<>'';

end.