create or replace function verifierIntegriteSolde(integer, integer) returns text 

language plpgsql
as
$$

declare

	curseur cursor for select * from operation where num_compte = $1 and id_type = $2 ;
	resultat record;
	solde_c integer;
	montant integer;


begin

	select solde into solde_c from compte where num_compte = $1 and id_type = $2;

	montant := 0;
	
	open curseur ;
	loop
		fetch curseur into resultat ;
		exit when not found ;
		
		if resultat.type_operation = 'CREDIT' then
			montant := montant + resultat.montant ;
		else
			montant := montant - resultat.montant;
		end if;	
	end loop;
	
	if solde_c = montant then
		
		return 'OK';
		
	else
		return 'NOK';
		
	end if;	
	close curseur;
	


end;
$$;



create or replace function detecterIncidents(integer, integer) returns void
language plpgsql
as
$$

declare

	curseur cursor for select * from operation where num_compte = $1 and id_type = $2 ;
	resultat record;
	solde_c integer;
	montant integer;
	 

begin


	select solde into solde_c from compte where num_compte = $1 and id_type = $2;

	montant := 0;
	
	open curseur ;
	loop
		fetch curseur into resultat ;
		exit when not found ;
		
		if resultat.type_operation = 'DEBIT' then
			montant := montant - resultat.montant ;	
			
		else
			montant := montant + resultat.montant ;
		end if;
		if montant < 0 then
		
			raise info 'id_operation : %  num_compte : % date : % montant : % solde : %' , resultat.id_operation, resultat.num_compte, resultat.date, resultat.montant , montant ;  
				
		end if;
	end loop;
	
	close curseur;
end;
$$;


create or replace function enregistrerNbIncidents(integer, integer) returns void
language plpgsql
as
$$

declare

	curseur cursor for select * from operation where num_compte = $1 and id_type = $2 ;
	resultat record;
	solde_c integer;
	montant integer;
	compteur integer;
	 

begin



	montant := 0;
	compteur := 0;
	
	open curseur ;
	loop
		fetch curseur into resultat ;
		exit when not found ;
		
		if resultat.type_operation = 'DEBIT' then
			montant := montant - resultat.montant ;	
			
		else
			montant := montant + resultat.montant ;
		end if;
		if montant < 0 then
		
			compteur := compteur + 1;
			
			if exists(select * from nb_incidents where num_compte = $1 and id_type = $2) then
			
				execute 'update nb_incidents set nombre = nombre + 1' ;
			
			else
				
				execute 'insert into nb_incidents (num_compte, id_type, nombre) values('||$1||', '||$2||', '||compteur||')' ;
			end if;	
		end if;
	end loop;
	
	close curseur;
end;
$$;

create or replace function majBilanNbIncidents() returns void
language plpgsql
as
$$

declare

	curseur cursor for select * from operation ;
	resultat record;
	soldeC integer;
	compteur integer;
	compteur2 integer;
	 

begin



	soldeC := 0;
	compteur := 0;
	
	open curseur ;
	loop
		fetch curseur into resultat ;
		exit when not found ;
		
		if(resultat.num_compte != compteur2) then
			soldeC := 0;
			
		end if;
		
		compteur2 := resultat.num_compte;
		
		if (resultat.type_operation = 'CREDIT') then
			soldeC :=  soldeC + resultat.montant ;	
			
		else
			
			if(resultat.type_operation not like 'CREDIT') then
				soldeC := soldeC - resultat.montant ;
				if(soldeC < 0) then
				
					compteur := compteur + 1;
					
					if exists( select * from nb_incidents where num_compte = resultat.num_compte and id_type = resultat.id_type) then
						
						execute 'update nb_incidents set nombre = nombre + 1 where num_compte = '||resultat.num_compte||' and id_type = '||resultat.id_type||'' ;
					
					else
						
						execute 'insert into nb_incidents (num_compte, id_type, nombre) values('||resultat.num_compte||', '||resultat.id_type||', '||compteur||')' ;
					end if;
				end if;
			end if;
		end if;
				
	end loop;
	
	close curseur;
end;
$$;
