{$G+}
unit w_done;
{ David Joffe '94/12 }
{ Close-down process for DJ-win. }

interface

uses
  graph;

procedure DoneGraphics;

implementation
procedure DoneGraphics;
begin
  CloseGraph;
  writeln('That old message was pretty dull so I changed it.');
  writeln('This program was written solely by David Joffe. It consists of well over 5000');
  writeln('lines of pascal source code, so do not expect it to be completely free of bugs.');
  writeln('In fact bugs still keep turning up, and there are probably still quite a few');
  writeln('lingering out there. So if strange things start happening please tell me');
  writeln('exactly what they are.');
  writeln;
  writeln('Thanx');
  writeln(' - David Joffe.');
end;

end.