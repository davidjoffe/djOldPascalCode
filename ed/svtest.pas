{
Einbindung des Treibers als OBJ-Datei
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Obwohl ich diesem Punkt in der Anleitung ein eigenes Kapitel gewidmet habe,
scheint dies eines der gr”áten Probleme zu sein. Hier also nochmals ein kurzes
Code-Fragment, das das prinzipielle Vorgehen zeigen soll. Der Treiber muá dazu
mittels

  BINOBJ SVGA.BGI SVGA.OBJ SVGADRIVER

in eine OBJ-Datei umgewandelt worden sein.

---------------- [ Beispiel Anfang ] --------------------}
program test_bgi;


  uses crt,graph;
  PROCEDURE SVGADriver; FAR; EXTERNAL;          { <-- der Treiber }
  {$L SVGA.OBJ}                                 { Einbinden der OBJ-Datei }

  VAR
    GraphDriver: INTEGER;                   { Nummer des SVGA-Treibers }

  PROCEDURE Install;
  { Fhrt die Installation des Treibers durch }
  BEGIN
    GraphDriver := InstallUserDriver ('SVGA', NIL);
    IF (GraphDriver < 0) THEN halt;
    IF (RegisterBGIDriver (@SVGADriver) < 0) THEN halt;
  END;


  PROCEDURE Init (GraphMode: INTEGER);
  { Schaltet die Grafik ein }
  BEGIN
    InitGraph (GraphDriver, GraphMode, '');
  END;


  BEGIN                         { Hauptprogramm }
    Install;
    Init (1);                   { Autodetect }
    setcolor(10);
    rectangle(0,0,100,100);
    repeat until readkey <> '';
  END.
