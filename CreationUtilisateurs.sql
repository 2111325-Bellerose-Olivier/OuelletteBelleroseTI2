USE RessourcesMonstrueuses;

/* création des roles */
CREATE ROLE administrateur_système;
CREATE ROLE responsable_visites;
CREATE ROLE responsable_entretient;
CREATE ROLE service_ressources_monstrueuses;


/* grant sur les roles */
GRANT ALL ON * TO administrateur_système;

GRANT CREATE,INSERT,UPDATE,DELETE ON Visite_salle TO responsable_visites;
GRANT CREATE,INSERT,UPDATE,DELETE ON Expedition TO responsable_visites;
GRANT CREATE,INSERT,UPDATE,DELETE ON Expedition_aventurier TO responsable_visites;
GRANT CREATE,INSERT,UPDATE,DELETE ON Inventaire_expedition TO responsable_visites;
GRANT CREATE,INSERT,UPDATE,DELETE ON Aventurier TO responsable_visites;

GRANT CREATE,INSERT,UPDATE,DELETE ON Coffre_tresor TO responsable_entretient;
GRANT CREATE,INSERT,UPDATE,DELETE ON Ligne_coffre TO responsable_entretient;
GRANT CREATE,INSERT,UPDATE,DELETE ON Objet TO responsable_entretient;

GRANT CREATE,INSERT,UPDATE,DELETE ON Humanoide TO service_ressources_monstrueuses;
GRANT CREATE,INSERT,UPDATE,DELETE ON Mort_vivant TO service_ressources_monstrueuses;
GRANT CREATE,INSERT,UPDATE,DELETE ON Elementaire TO service_ressources_monstrueuses;
GRANT CREATE,INSERT,UPDATE,DELETE ON Famille_monstre TO service_ressources_monstrueuses;
GRANT CREATE,INSERT,UPDATE,DELETE ON Monstre TO service_ressources_monstrueuses;
GRANT CREATE,INSERT,UPDATE,DELETE ON Responsabilite TO service_ressources_monstrueuses;
GRANT CREATE,INSERT,UPDATE,DELETE ON Affectation_salle TO service_ressources_monstrueuses;

/* Creation des users */
CREATE USER daenerys IDENTIFIED BY 'dragons3'
	DEFAULT ROLE administrateur_systeme;
    
CREATE USER jon IDENTIFIED BY 'Jenesaisrien'
	DEFAULT ROLE responsable_visites,responsable_entretien;
    
CREATE USER baelish IDENTIFIED BY 'lord'
	DEFAULT ROLE service_ressources_monstrueuses;
    
