{$G+}
unit w_init;
{ David Joffe '94/12 }
{ Initialisation process for DJ-win. }

interface

uses
  graph;

const
  NumDrivers=1;
  PathToDrivers:string='.\';
{  GDriverArray:array[0..1,0..1] of integer=((0,2),(VGA,VGAHi));}

procedure InitGraphics(GraphDriver,GraphMode: integer);
procedure InitDeskTop;

var
  GDriver,GMode,GResult: integer;

implementation

uses w;

procedure InitGraphics(GraphDriver,GraphMode: integer);
  var GIndex: integer;
begin
  {GDriverArray[0,0]:=InstallUserDriver('SVGA256',nil);
  GIndex:=0;}
{  repeat
{    if GIndex=NumDrivers+1 then begin
{      writeln('Unable to initialize graphics.');
{    end;
{    GDriver:=GDriverArray[GIndex,0];
{    GMode:=GDriverArray[GIndex,1];
{
{  { create proper mode init!!! }
{{    GDriver:=VGA; GMode:=VGAHi;}
{{    GDriver:=EGA; GMode:=EGAHi;}
{
{    InitGraph(GDriver,GMode,PathToDrivers);
{    GResult:=GraphResult;
{    inc(GIndex);
{  until GResult=grOK;
{  SetTextStyle(DefaultFont, HorizDir, 1);}
  GDriver:=GraphDriver;
  GMode:=GraphMode;
  initgraph(GDriver,GMode,PathToDrivers);
  GResult:=GraphResult;
  if GResult<>grOK then begin
    writeln('Error initialising graphics: error code:',GResult);
    halt;
  end;

end; {InitGraphics}

procedure InitDeskTop;
begin
  RestoreDeskTop(0,0,GetMaxX,GetMaxY);
end;


end.