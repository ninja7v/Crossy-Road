program crossyroad;

uses  crt {couleur,goto}, keyboard {lire une touche}, dos {temps}, sysutils {fichier};

const largeurmax=13;{largeurmax>12}
	hauteurmax=13;{hauteurmax>=largeurmax}
	proportionvoiture=7;
	proportionarbre=4;
	proportiontronc=5;{proportiontronc>2}
	maxse=3; {max score enregistés}

type tab=array [1..largeurmax,1..hauteurmax] of integer;

Type score1=record
namescore:array[1..maxse] of string;
scorenbr:array[1..maxse] of integer;
end;



procedure choixcouleur(var couleur:char);

var c:integer;
	K:TKeyEvent;

begin
InitKeyBoard();
writeln('Choisisez votre couleur :');
writeln('');
writeln('Blanc [ ]');
writeln('Bleu  [ ]');
writeln('');
writeln('Touche ESPACE pour selectioner.');
gotoxy(8,3);
c:=1;

repeat
K:=GetKeyEvent();
K:=TranslateKeyEvent(K);
if ((KeyEventToString(K) = 'Up') and (wherey>3)) then	GotoXY(8,wherey-1);
if ((KeyEventToString(K) = 'Down') and (wherey<4))then	GotoXY(8,wherey+1);
c:=wherey;
until (KeyEventToString(K) = ' ');

if c=3 then couleur:='w';
if c=4 then couleur:='b';
end;



procedure initialisationgrille(var tab1,tab2:tab; var posx,posy:integer);

var i,j,x:integer;

begin
randomize;
{pour tab2}
for i:=1 to hauteurmax-2 do
begin
tab2[1,i]:=random(3); {0:herbe,1:route,2:riviere}
if tab2[1,i]=1 then tab2[2,i]:=random(2); {0:gauche,1:droite}
if (tab2[1,i]=2) and (tab2[1,i+1]<>2) then tab2[2,i]:=random(2); {pour que les troncs se croisent}
if (tab2[1,i]=2) and (tab2[1,i+1]=2) and (tab2[2,i+1]=1) then tab2[2,i]:=0; {avec les troncs et les voitures}
if (tab2[1,i]=2) and (tab2[1,i+1]=2) and (tab2[2,i+1]=0) then tab2[2,i]:=1;
end;
tab2[1,hauteurmax]:=0;
tab2[1,hauteurmax-1]:=0;

{pour tab1}
for i:=1 to hauteurmax-2 do
begin
	if tab2[1,i]=0 then 
		begin
		for j:=1 to largeurmax do
		begin
		x:=random(proportionarbre);{0:personnage,1:arbre,2:voiture,3:tronc,7:rien}
		if x=1 then tab1[j,i]:=1 else tab1[j,i]:=7;
		end;
		end;
	if tab2[1,i]=1 then
		begin
		for j:=1 to largeurmax do
		begin
		x:=random(proportionvoiture);
		if x=2 then tab1[j,i]:=2 else tab1[j,i]:=7;
		end;
		end;
	if tab2[1,i]=2 then
		begin
		for j:=1 to largeurmax do
		begin
		x:=random(proportiontronc);
		if x>2 then tab1[j,i]:=3 else tab1[j,i]:=7;
		end;
		end
end;
for j:=0 to 1 do for i:=1 to largeurmax do tab1[i,hauteurmax-j]:=7;
posx:=largeurmax div 2;
posy:=hauteurmax-1;
tab1[posx,posy]:=0
end;



procedure affichagegrille(tab1,tab2:tab; couleur:char);

var col,lin:integer;

begin
clrscr;

for lin:=1 to largeurmax do
for col:=1 to hauteurmax do
begin
if tab2[1,lin]=0 then textbackground(green);
if tab2[1,lin]=1 then textbackground(black);
if tab2[1,lin]=2 then textbackground(blue);
if (tab1[col,lin]=1) or (tab1[col,lin]=3) then textbackground(yellow);
if tab1[col,lin]=2 then textbackground(red);
if ((tab1[col,lin]=0) and (couleur='b')) then textbackground(blue);
if ((tab1[col,lin]=0) and (couleur='w')) then textbackground(white);

if col=largeurmax then writeln ('  ') else write ('  ');
end;
textbackground(black);
end;



procedure deplacement(tab2:tab; var posx,posy,score:integer; var tab1:tab; var victoire:boolean);

var	K:TKeyEvent;

begin
InitKeyBoard();
delay(3); {obligatoire pour que la procedure soit prise en compte dans la boucle repeat dans jeu}
if keypressed then 
repeat
K:=GetKeyEvent();
K:=TranslateKeyEvent(K);
if (KeyEventToString(K) = 'Up') and (posy>1) and (tab1[posx,posy-1]<>1) then
begin {Condition si on rentre dans une voiture ou on tombe dans l'eau}
if (tab1[posx,posy-1]=2) or ((tab2[1,posy-1]=2) and (tab1[posx,posy-1]=7)) then victoire:=false;
tab1[posx,posy]:=7;
tab1[posx,posy-1]:=0;
posy:=posy-1;
score:=score+1;
end
else if (KeyEventToString(K) = 'Down') and (posy<hauteurmax) and (tab1[posx,posy+1]<>1) then
	begin {Condition si on rentre dans une voiture ou on tombe dans l'eau}
	if (tab1[posx,posy-1]=2) or ((tab2[1,posy-1]=2) and (tab1[posx,posy-1]=7)) then victoire:=false;
	tab1[posx,posy]:=7;
	tab1[posx,posy+1]:=0;
	posy:=posy+1;
	end
else if (KeyEventToString(K) = 'Left') and (posx>1) and (tab1[posx-1,posy]<>1) then
	begin
	if (tab1[posx-1,posy]=2) or ((tab1[posx-1,posy]=7) and (tab2[1,posy]=2)) then victoire:=false;
	tab1[posx,posy]:=tab1[posx-1,posy];
	tab1[posx-1,posy]:=0;
	posx:=posx-1;
	end
else if (KeyEventToString(K) = 'Right') and (posx<largeurmax) and (tab1[posx+1,posy]<>1) then
	begin
	if (tab1[posx+1,posy]=2) or ((tab1[posx+1,posy]=7) and (tab2[1,posy]=2)) then victoire:=false;
	tab1[posx,posy]:=tab1[posx+1,posy];
	tab1[posx+1,posy]:=0;
	posx:=posx+1;
	end;
until (KeyEventToString(K) = 'Up')  or (KeyEventToString(K) = 'Down') or (KeyEventToString(K) = 'Right') or (KeyEventToString(K) = 'Left');
DoneKeyBoard();
end;



procedure decalagegrille(var tab1,tab2:tab; var posy:integer);

var i,j,k,x:integer;

begin
randomize;
{pour tab2}
for i:=hauteurmax downto 2 do for j:=1 to 2 do tab2[j,i]:=tab2[j,i-1];
tab2[1,1]:=random(3);
if tab2[1,1]=1 then tab2[2,1]:=random(2);
if (tab2[1,i]=2) and (tab2[1,i+1]<>2) then tab2[2,i]:=random(2);
if (tab2[1,i]=2) and (tab2[1,i+1]=2) and (tab2[2,i+1]=1) then tab2[2,i]:=0;
if (tab2[1,i]=2) and (tab2[1,i+1]=2) and (tab2[2,i+1]=0) then tab2[2,i]:=1;

{pour tab1}
for i:=hauteurmax downto 2 do
for j:=1 to largeurmax do tab1[j,i]:=tab1[j,i-1];

if tab2[1,1]=0 then
	begin
	for k:=1 to largeurmax do
	begin
	x:=random(proportionarbre);{0:personnage,1:arbre,2:voiture,7:rien}
	if x=1 then tab1[k,1]:=1 else tab1[k,1]:=7;
	end;
	end;
if tab2[1,1]=1 then
	begin
	for k:=1 to largeurmax do
	begin
	x:=random(proportionvoiture);
	if x=2 then tab1[k,1]:=2 else tab1[k,1]:=7;
	end;
	end;
if tab2[1,1]=2 then
	begin
	for k:=1 to largeurmax do
	begin
	x:=random(proportiontronc);
	if x>2 then tab1[k,1]:=3 else tab1[k,1]:=7;
	end;
	end;
		
posy:=posy+1;
end;



procedure depacementobjet(tab2:tab; posy:integer; var posx:integer; var tab1:tab; var victoire:boolean);

var i,j,x:integer;

begin
randomize;
for i:=1 to hauteurmax do
begin
if tab2[1,i]=1 then {pour les voitures}
	if tab2[2,i]=1 then {vers la droite}
		begin
		for j:=largeurmax downto 2 do
		begin
		if (tab1[j,i]=0) and (tab1[j-1,i]=2) then victoire:=false;
		if (tab1[j,i]<>0) and (tab1[j-1,i]<>0) then  tab1[j,i]:=tab1[j-1,i];
		end;
		tab1[1,i]:=7;
		x:=random(proportionvoiture);
		if x=2 then tab1[1,i]:=2;
		end
		else begin {vers la gauche}
			for j:=1 to largeurmax-1 do
			begin
			if (tab1[j,i]=0) and (tab1[j+1,i]=2) then victoire:=false;
			if (tab1[j,i]<>0) and (tab1[j+1,i]<>0) then tab1[j,i]:=tab1[j+1,i];
			end;
			tab1[largeurmax,i]:=7;
			x:=random(proportionvoiture);
			if x=2 then tab1[largeurmax,i]:=2;
			end;

if tab2[1,i]=2 then {pour les troncs}
	if tab2[2,i]=1 then {vers la droite}
		begin
		if tab1[largeurmax,i]=0 then victoire:=false;
		if (tab2[1,posy]=2) and (tab2[2,posy]=1) then posx:=posx+1;
		for j:=largeurmax downto 2 do tab1[j,i]:=tab1[j-1,i];
		tab1[1,i]:=7;
		x:=random(proportiontronc);
		if x>2 then tab1[1,i]:=3;
		end
		else begin {vers la gauche}
			if tab1[1,i]=0 then victoire:=false;
			if (tab2[1,posy]=2) and (tab2[2,posy]=0) then posx:=posx-1;
			for j:=1 to largeurmax-1 do tab1[j,i]:=tab1[j+1,i];
			tab1[largeurmax,i]:=7;
			x:=random(proportiontronc);
	 		if x>2 then tab1[largeurmax,i]:=3;
			end;
end;
end;



procedure menu(var gojeu,goscore,goregles:boolean);

var c:integer;
	K:TKeyEvent;

Begin
InitKeyBoard();
gojeu:=false;
goscore:=false;
goregles:=false;

writeln('CROSSYROAD par NINJA7V');
writeln('');
{liste des choix}
writeln('Jouer  [ ]');
writeln('Scores [ ]');
writeln('Regles [ ]');
writeln('');
writeln('Touche ESPACE pour selectioner.');
gotoxy(9,3);
c:=1;

repeat
K:=GetKeyEvent();
K:=TranslateKeyEvent(K);
if ((KeyEventToString(K) = 'Up') and (wherey>3)) then	GotoXY(9,wherey-1);
if ((KeyEventToString(K) = 'Down') and (wherey<5))then	GotoXY(9,wherey+1);
c:=wherey;
until (KeyEventToString(K) = ' ');

DoneKeyBoard();
if (c=3) then gojeu:=true;
if (c=4) then goscore:=true;
if (c=5) then goregles:=true;
End;



procedure regles (var retour:integer);

var	tab1,tab2:tab;
	couleur:char;
	posx,posy,pos,c:integer;
	K:TKeyEvent;

begin
clrscr;
couleur:='w';
initialisationgrille(tab1,tab2,posx,posy);
affichagegrille(tab1,tab2,couleur);
writeln('');
writeln('Crossy Road est un jeu sans fin, en theorie =D');
writeln('Les lignes vertes representent de l herbe.');
writeln('Les lignes noires representent des routes.');
writeln('Les lignes bleues representent des rivieres.');
writeln('Les carres jaunes represententent des arbres ou des troncs.');
writeln('Les carres rouges representent des voitures.');
writeln('Il faut donc eviter les voitures et ne pas tomber dans l eau !');
writeln('Attention a ne pas prendre trop de temps entre chaque coups.');
writeln('De plus, la vitesse de jeu augmentera en fonction de ton score ...');
writeln('Si ce dernier fais partit du top ',maxse,', alors il sera enregistre.');
writeln('');
writeln('Tu peux mettre PAUSE en apuyant sur n importe quelle touche.');
writeln('');
writeln('Menu [ ]');
writeln('Exit [ ]');
writeln('');
writeln('Touche ESPACE pour selectioner.');
pos:=wherey;
gotoxy(7,pos-4);
c:=1;
InitKeyBoard();
repeat
K:=GetKeyEvent();
K:=TranslateKeyEvent(K);
if ((KeyEventToString(K) = 'Up') and (wherey>pos-4)) then	GotoXY(7,wherey-1);
if ((KeyEventToString(K) = 'Down') and (wherey<pos-3))then	GotoXY(7,wherey+1);
c:=wherey;
until (KeyEventToString(K) = ' ');

DoneKeyBoard();
if (c=pos-4) then retour:=0;
if (c=pos-3) then retour:=1;
end;



procedure enregistrementscore(score:integer); 

var tabscore:score1;
	pseudo:string;
	i:integer;
	classement:file of score1;
	
begin
	{creation du fichier score}
if not (FileExists('fichierscorescrossyroad')) then
	Begin

	assign(classement, 'fichierscorescrossyroad');
	rewrite(classement);
	for i:=1 to maxse do
	begin
	tabscore.scorenbr[i]:=0;
	tabscore.namescore[i]:='user';
	end;
	write(classement,tabscore);		
	close(classement);
	end;

assign(classement, 'fichierscorescrossyroad');
reset(classement);
Read(classement, tabscore);

if (score>tabscore.scorenbr[maxse]) then
begin
rewrite(classement);
write('pseudo : ');
Readln(pseudo);

tabscore.scorenbr[maxse-i]:=score;
tabscore.namescore[maxse]:=pseudo;

i:=maxse;
repeat
	tabscore.scorenbr[i]:=tabscore.scorenbr[i-1];
	tabscore.namescore[i]:=tabscore.namescore[i-1];
	i:=i-1
until (score<tabscore.scorenbr[maxse-i]) or (i=1);

tabscore.scorenbr[i]:=score;
tabscore.namescore[i]:=pseudo;
write(classement, tabscore);
end;
close(classement);				
End;



procedure affichagescores(var retour:integer);

var classement:file of score1;
	i,c,pos:integer;
	K:TKeyEvent;
	tabscore:score1;

Begin
clrscr;
assign(classement, 'fichierscorescrossyroad');
reset(classement);
Read(classement, tabscore);

for i:=1 to maxse do
begin
if (tabscore.namescore[i]<>'user') then
	begin
	write(i,'- ',tabscore.namescore[i],' : ');
	write(tabscore.scorenbr[i]);
	writeln('');
	end;
end;
writeln('');
close(classement);
writeln('');
{liste des choix}
writeln('Reinitialiser les scores [ ]');
writeln('Menu                     [ ]');
writeln('Quiter                   [ ]');
writeln('');
writeln('Press SPACEBAR to select.');
pos:=wherey;
gotoxy(27,wherey-5);
c:=1;
InitKeyBoard();
repeat
K:=GetKeyEvent();
K:=TranslateKeyEvent(K);
if ((KeyEventToString(K) = 'Up') and (wherey>pos-5)) then	GotoXY(27,wherey-1);
if ((KeyEventToString(K) = 'Down') and (wherey<pos-3))then	GotoXY(27,wherey+1);
c:=wherey;
until (KeyEventToString(K) = ' ');

DoneKeyBoard();
if (c=pos-5) then
begin 
	assign(classement, 'fichierscorescrossyroad');
	reset(classement);
	rewrite(classement);
	for i:=1 to maxse do
		begin;
		tabscore.scorenbr[i]:=0;
		tabscore.namescore[i]:='user';
		end;
	write(classement,tabscore);
	close(classement);
end;
if (c=pos-4) then retour:=0;
if (c=pos-3) then retour:=1;
End;



procedure  jeu(var tab1,tab2:tab; var score,retour:integer; var victoire:boolean);

var posay,delai,posx,posy,pos,c1,score1:integer;
	couleur:char;
	K:TKeyEvent;
	t1,t2:longint;
	h,m,s,c:word;
	
begin
posay:=hauteurmax-1;
delai:=0;
score1:=0;
clrscr;
choixcouleur(couleur);
initialisationgrille(tab1,tab2,posx,posy);

repeat
gettime (h,m,s,c);
t1:=(h*36000+m*6000+s*100+c);
affichagegrille(tab1,tab2,couleur);
writeln('');
writeln('score : ',score);

repeat
deplacement(tab2,posx,posy,score,tab1,victoire);
if (posy<posay) and (posy<hauteurmax-1) then
begin
decalagegrille(tab1,tab2,posy);
affichagegrille(tab1,tab2,couleur);
end;
gettime (h,m,s,c);
t2:=(h*36000+m*6000+s*100+c);
posay:=posy;
until(t2-t1>100-2*score);

depacementobjet(tab2,posy,posx,tab1,victoire);
if score=score1 then delai:=delai+1 else delai:=0;
{delai maximum pour monter}
if delai=10 then victoire:=false;
score1:=score;
until (victoire=false);

affichagegrille(tab1,tab2,couleur);
writeln('GAME OVER');
textcolor(green);
writeln('Score : ',score);
textcolor(black);
writeln('');
enregistrementscore(score);
writeln('Menu [ ]');
writeln('Exit [ ]');
writeln('');
writeln('Touche ESPACE pour selectioner.');
pos:=wherey;
gotoxy(7,pos-4);
c1:=pos-4;
InitKeyBoard();
repeat
K:=GetKeyEvent();
K:=TranslateKeyEvent(K);
if ((KeyEventToString(K) = 'Up') and (wherey>pos-4)) then	GotoXY(7,wherey-1);
if ((KeyEventToString(K) = 'Down') and (wherey<pos-3))then	GotoXY(7,wherey+1);
c1:=wherey;
until (KeyEventToString(K) = ' ');
if c1=pos-3 then retour:=1;
DoneKeyBoard();
end;



//programe principal

var	tab1,tab2:tab;
	gojeu,goscore,goregles,victoire:boolean;
	retour,score:integer;

BEGIN
repeat
clrscr;
retour:=0;
score:=0;
victoire:=true;
menu(gojeu,goscore,goregles);
if goscore then affichagescores(retour);
if goregles then regles(retour);
if gojeu then jeu(tab1,tab2,score,retour,victoire);
until retour=1;
end.
