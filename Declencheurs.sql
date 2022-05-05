/*
 * Declencheurs pour la bd pour Donjon Inc.
 *
 * Fichier : Declencheurs.sql
 * Auteur : Olivier Belrose et Antoine Ouellette
 * Langage : SQL
 * Date : mai 2022
 */
USE RessourcesMonstrueuses;

/**
* Declencheur validation Coffre 1 : update
*
* @Dependencies Affectation_salle
*/
DROP TRIGGER IF EXISTS validation_coffre_update;
DELIMITER $$
CREATE TRIGGER validation_coffre_update BEFORE UPDATE ON Ligne_coffre FOR EACH ROW
BEGIN
	DECLARE _quantite_totale INTEGER;
    DECLARE _masse_coffre INTEGER;
    DECLARE _masse_objet INTEGER;
	# Trouver quelle est la masse de l'objet ajouté
    SET _masse_objet = (
			SELECT
				masse
			FROM
				Ligne_coffre
                INNER JOIN Objet ON objet = id_objet
			WHERE
				coffre = NEW.coffre AND objet = NEW.objet
    );
    
    # Calculer la somme des quantités de la old.Table
    # Retirer la donnée erronée de la somme du coffre
    # Ajouter/Remplacer par la nouvelle quantite du UPDATE
    SET _quantite_totale = (
			SELECT
				sum(quantite)
			FROM
				Ligne_coffre
			WHERE
				coffre = NEW.coffre
	) - OLD.quantite + NEW.quantite;
    
    # Calculer la somme des masses de la old.Table
    # Retirer la donnée erronée de la somme du coffre
    # Ajouter/Remplacer par la nouvelle masse du UPDATE
    SET _masse_coffre = (
			SELECT
				sum(quantite*masse)
			FROM
				Ligne_coffre
                INNER JOIN Objet ON objet = id_objet
			WHERE
				coffre = NEW.coffre
	) - (OLD.quantite*_masse_objet) + (NEW.quantite*_masse_objet);
    
    IF _quantite_totale>15 THEN
		SIGNAL SQLSTATE '02012' SET MESSAGE_TEXT = 'La somme des quantites des objets du coffre depasse 15.';
    END IF;
    IF _masse_coffre>300 THEN
		SIGNAL SQLSTATE '02013' SET MESSAGE_TEXT = 'La somme des masses dans le coffre depasse 300.';
    END IF;
END; $$
DELIMITER ;

/**
* Declencheur validation Coffre 2 : insert
*
* @Dependencies Affectation_salle
*/
DROP TRIGGER IF EXISTS validation_coffre_insert;
DELIMITER $$
CREATE TRIGGER validation_coffre_insert BEFORE INSERT ON Ligne_coffre FOR EACH ROW
BEGIN
	DECLARE _quantite_totale INTEGER;
    DECLARE _masse_coffre INTEGER;
    DECLARE _masse_objet INTEGER;
	# Trouver quelle est la masse de l'objet ajouté
    SET _masse_objet = (
			SELECT
				masse
			FROM
				Ligne_coffre
                INNER JOIN Objet ON objet = id_objet
			WHERE
				coffre = NEW.coffre AND objet = NEW.objet
    );
    
    # Ajouter la quantite a la somme des quantite de la old.Table
    SET _quantite_totale = (
			SELECT
				sum(quantite)
			FROM
				Ligne_coffre
			WHERE
				coffre = NEW.coffre
	) + NEW.quantite;
    
    # Ajouter la masse a la somme des masses de la old.Table
    SET _masse_coffre = (
			SELECT
				sum(quantite*masse)
			FROM
				Ligne_coffre
                INNER JOIN Objet ON objet = id_objet
			WHERE
				coffre = NEW.coffre
	) + (NEW.quantite*_masse_objet);
    
    SET @quantite_totale = _quantite_totale;
    SET @masse_coffre = _masse_coffre;
    IF _quantite_totale>15 THEN
		SIGNAL SQLSTATE '02012' SET MESSAGE_TEXT = 'La somme des quantites des objets du coffre depasse 15.';
    END IF;
    IF _masse_coffre>300 THEN
		SIGNAL SQLSTATE '02013' SET MESSAGE_TEXT = 'La somme des masses dans le coffre depasse 300.';
    END IF;
END; $$
DELIMITER ;

/**
* Declencheur mortalite : update
*
* @Dependencies Affectation_salle
*/
DROP TRIGGER IF EXISTS declencheur_mortalite;
DELIMITER $$
CREATE TRIGGER declencheur_mortalite AFTER UPDATE ON Monstre FOR EACH ROW
BEGIN
	IF NEW.point_vie <= 0 THEN
		UPDATE Affectation_salle INNER JOIN Monstre ON monstre = id_monstre
		SET Affectation_salle.fin_affectation = now()
		WHERE
            point_vie = NEW.point_vie;
	END IF;

END; $$
DELIMITER ;

/**
* Declencheur éléments opposé: insert
*
* @Dependencies Affectation_salle, Elementaire
*/
DROP TRIGGER IF EXISTS elements_oppose;
DELIMITER $$
CREATE TRIGGER elements_oppose AFTER INSERT ON Affectation_salle FOR EACH ROW
BEGIN
	DECLARE _salle INT;
    DECLARE _temps_debut DATETIME;
    DECLARE _temps_fin DATETIME;
    DECLARE _verification INT;
    
    SET _salle = (SELECT salle FROM Affectation_salle);
    SET _temps_debut = (SELECT debut_affectation FROM Affectation_salle);
    SET _temps_fin = (SELECT fin_affectation FROM Affectation_salle);
    
    SET _verification = (SELECT elements_opposes_piece(_salle,_temps_debut,_temps_fin));
    
    IF _verification = 1 THEN
		SIGNAL SQLSTATE '01002' SET MESSAGE_TEXT = 'Il y a un élémentaire d\'eau et de feu d\'assigné à la même salle.';
	END IF;
    
END $$
DELIMITER ;

/**
* Declencheur hashage : insert
* 
* @Dependencies Coffre_tresor
*/
DROP TRIGGER IF EXISTS hashage;
DELIMITER $$
CREATE TRIGGER hashage BEFORE INSERT ON Coffre_tresor FOR EACH ROW
BEGIN
	DECLARE _code CHAR(64);
    
    SET _code = (SELECT code_secret FROM Coffre_tresor);

     SET NEW.code_secret = SHA2(_code,256);
    
END $$
DELIMITER ;