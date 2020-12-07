/*Exercice 1*/
create or replace function calculer_longueur_max(str1 varchar(100), str2 varchar(100) )returns integer as
$$
	declare 
		length1 integer;
		length2 integer;
	
	begin 
		
		length1 := length(str1);
		length2 := length(str2);
		if length1 > length2 then
			return length1;
		else
			return length2;
		
		end if ;
	
	end;
		
$$
language plpgsql;

/*Exercice 2*/
create or replace function nb_occurences(arg1 char(1), arg2 varchar(100), arg3 integer, arg4 integer) returns integer as 
$$
	declare
	
	nbOccurences integer;
	compteur integer;
	compteur2 integer;
	num integer; 
	
	begin
		
		compteur := 0;
		compteur2 := 0;
		num := 1;
		for num in arg3..arg4 loop
		
			if arg1 = SUBSTR(arg2, compteur, 1)::char(1) then
			
				compteur2 := compteur2 + 1;
				
			end if ;	
			compteur := compteur + 1;
			
		end loop;
			
 
	return compteur2;
	
	end;
$$
language plpgsql;


create or replace function nb_occurences(arg1 char(1), arg2 varchar(100), arg3 integer, arg4 integer) returns integer as 
$$
	declare
	
	nbOccurences integer;
	compteur integer;
	compteur2 integer;
	num integer; 
	
	begin
		
		compteur := 0;
		compteur2 := 0;
		num := 1;
		loop
		
			if arg1 = SUBSTR(arg2, compteur, 1)::char(1) then
			
				compteur2 := compteur2 + 1;
				
			end if ;	
			compteur := compteur + 1;
		exit when compteur - 1 = arg4 ;	
		end loop;
			
 
	return compteur2;
	
	end;
$$
language plpgsql;



create or replace function nb_occurences(arg1 char(1), arg2 varchar(100), arg3 integer, arg4 integer) returns integer as 
$$
	declare
	
	nbOccurences integer;
	compteur integer;
	compteur2 integer;
	num integer; 
	
	begin
		
		compteur := 0;
		compteur2 := 0;
		num := 1;
		while compteur - 1 != arg4 loop
		
			if arg1 = SUBSTR(arg2, compteur, 1)::char(1) then
			
				compteur2 := compteur2 + 1;
				
			end if ;	
			compteur := compteur + 1;	
		end loop;
			
 
	return compteur2;
	
	end;
$$
language plpgsql;

/*Exercice 3*/
create or replace function getNbJoursParMois(date) returns integer as
$$
	declare
	goal int;
	
	
	begin
		goal := DATE_PART('days', 
			DATE_TRUNC('month', $1) 
			+ '1 MONTH'::INTERVAL 
			- '1 DAY'::INTERVAL
    );
	return goal;
	end;
	
$$
language plpgsql;

/*Exercice 4*/	
create or replace function dateSqlToDatefr(date) returns text as
$$
	declare
		
		dd text;
		mm text;
		yyyy text;
		
		date1 text;
		date2 text;
		date3 text;
		date4 text;
		
	begin
	
		dd := EXTRACT(Day from $1);
		mm := EXTRACT(Month from $1);
		yyyy := EXTRACT(Year from $1);
		
		date1 := dd || '/';
		date2 := date1 || mm;
		date3 := date2 || '/';
		date4 := date3 || yyyy;
	
		return date4;
	
	end;
		
$$ 
language plpgsql;

/*Exercice 5*/
create or replace function getNomJour(date) returns text as
$$
	declare
	
		i integer;
		nomJours text;

	begin
		
		
		i:= EXTRACT(isodow from $1);
		case i
			when 1 then nomJours := 'Lundi';
			when 2 then nomJours := 'Mardi';
			when 3 then nomJours := 'Mercredi';
			when 4 then nomJours := 'Jeudi';
			when 5 then nomJours := 'Vendredi';
			when 6 then nomJours := 'Samedi';
			when 7 then nomJours := 'Dimanche';
		end case;
	return nomJours;
	end;
	
$$
language plpgsql;

/*Exercice 6*/

create or replace function getNbClientsDebiteur() returns integer as
$$

	declare
	
		i integer;
		ii integer;
		max integer;
	
	begin
		
		i := 0;
		ii := 0;
		select max(id_operation) into max from operation;
		while i < max
			loop
				if exists (select num_compte from operation where type_operation = 'DEBIT' and num_compte = i) then
					ii := ii + 1;
				end if;
				i := i + 1;
			end loop;
			
	return ii;		
	
	end;

$$
language plpgsql;

/*Exercice 7*/

create or replace function nb_client_ville(text) returns integer as
$$

	declare
		ville text;
		split text;
		i integer;
		ii integer;
		iii integer;
		max integer;
		compteur integer;
		
	
	begin
		i := 1;
		select max(num_client) into max from client;
		while i < max
			loop
				if exists (select adresse_client from client where num_client = i) then 
					select adresse_client into ville from client where num_client = i;
					split := split_part(ville, ', ', 2);
					
					ii := position(' ' in split);
					iii := char_length(split);
					split := substr(split, ii + 1, iii);
					
					if lower($1) = lower(split)then
						select count(num_client) into compteur from client where adresse_client = ville;
						return compteur;
					end if;
					else
						compteur := 0;
					
				end if;
			i := i + 1;
			end loop;
		return compteur;
						
			
			
	
	end;

$$
language plpgsql;

/*Exercice 8*/
create or replace function enregistrer_client(text, text, text, text, text) returns text as
$$
	declare
	
		i integer;
		max integer;
		max2 integer;

	begin
		
		select max(num_client) into max from client;
		max := max + 1;
		execute 'insert into client values('||max||' , '''||$1||''' , '''||$2||''' , '''||$3||''' , '''||$4||''' , '''||$5||''')' ;
		select max(num_client) into max2 from client;
		if exists(select * from client where num_client = max and nom_client = $1 and prenom_client = $2)then
			
			return '1';
		end if;
		return '0';	
		
	end;
	
$$
language plpgsql;		

	


