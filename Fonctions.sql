/*
 * Fonctions pour la bd pour Donjon Inc.
 *
 * Fichier : Fonctions.sql
 * Auteur : Olivier Belrose et Antoine Ouellette
 * Langage : SQL
 * Date : avril 2022
 */
 
USE RessourcesMonstrueuses;

/**
 * Fonction pour crypter une donnee
 *
 * @param _donnee Une chaine de texte a crypter.
 * @return _texte_crypte Un BLOB qui contient le texte crypte.
 */
DROP FUNCTION IF EXISTS crypter;
DELIMITER $$
CREATE FUNCTION crypter(_donnee VARCHAR(255)) RETURNS BLOB CONTAINS SQL DETERMINISTIC
BEGIN
	DECLARE _texte_crypte BLOB;
	#Crypter _donnee avec cle 'mortauxheros'
	SET _texte_crypte = AES_ENCRYPT(_donnee, UNHEX(SHA2('mortauxheros', 256)));

	RETURN _texte_crypte;
END $$
DELIMITER ;

/**
 * Fonction pour decrypter une donnee crypte
 *
 * @param _donnee_cryptee Un BLOB de la donnee cryptee.
 * @return _texte_clair Une donnee en texte clair.
 */
DROP FUNCTION IF EXISTS decrypter;
DELIMITER $$
CREATE FUNCTION decrypter(_donnee_cryptee BLOB) RETURNS VARCHAR(255) NO SQL DETERMINISTIC
BEGIN
	DECLARE _texte_clair VARCHAR(255);
	#Decrypter _donnee_cryptee avec cle 'mortauxheros'
	SET _texte_clair = AES_DECRYPT(_donnee_cryptee, UNHEX(SHA2('mortauxheros', 256)));

	RETURN _texte_clair;
END $$
DELIMITER ;

/**
*Fonction pour trouver le monstre le plus fort affecté à une certaine salle à un certain moment
*
*@param _fonction_salle chaine de caractère indiquant le fonction d'une salle
*@param _moment_affectation DATETIME qui indique à quel moment nous voulons trouver le responsable de la salle
*@return _id_monstre identifiant du monstre responsable assigné à la salle au moment du temps choisi
*/
DROP FUNCTION IF EXISTS responsable;
DELIMITER $$
CREATE FUNCTION responsable(_fonction_salle VARCHAR(255),_moment_affectation DATETIME) RETURNS INT READS SQL DATA NOT DETERMINISTIC
	BEGIN
		DECLARE _id_monstre INT;
			SET _id_monstre = (SELECT monstre, niveau_responsabilite FROM Salle INNER JOIN (Affectation_salle INNER JOIN Responsabilite
									ON responsabilite = id_responsabilite) ON id_salle = salle
									WHERE _moment_affectation BETWEEN debut_affectation AND fin_affectation
									AND fonction LIKE _fonction_salle
									ORDER BY niveau_responsabilite DESC LIMIT 1);
		IF _id_monstre IS NULL THEN
			SIGNAL SQLSTATE '01001' SET MESSAGE_TEXT = 'IL n\'y a pas de monstre affecté à salle au moment choisi.';
		ELSE RETURN _id_monstre;
        END IF;
	END $$
DELIMITER ;
            

/**
* Fonction pour trouver l'aventurier avec le plus haut niveau dans l'expédition
*
*@param _id_expedition chaine de caratère indiquant le nom de l'expédition
*@return _id_aventurier l'identifiant de l'aventurier avec le plus haut niveau
*/
DROP FUNCTION IF EXISTS leader;
DELIMITER $$
CREATE FUNCTION leader(_id_expedition INT) RETURNS INT READS SQL DATA DETERMINISTIC
	BEGIN 
		DECLARE _id_aventurier INT;
			SET _id_aventurier = (SELECT id_aventurier FROM Expedition_aventurier NATURAL JOIN Aventurier
									WHERE id_expedition = _id_expedition
									ORDER BY niveau DESC LIMIT 1);
			RETURN _id_aventurier;
	END $$
DELIMITER ;

/**
 * Fonction pour savoir si tous les monstres sont morts
 *
 * @param _id_salle Une salle a valider.
 * @param _moment_precis Un moment où faire la validation.
 * @return NOT _tous_morts Un booleen, 0 si tous mort, 1 s'il y a des vivants.
 */
DROP FUNCTION IF EXISTS monstres_en_vie;
DELIMITER $$
CREATE FUNCTION monstres_en_vie(_id_salle INTEGER, _moment_precis DATETIME) RETURNS INTEGER CONTAINS SQL DETERMINISTIC
BEGIN
	DECLARE _des_vivants INTEGER;#bool
    DECLARE _nbr_vivants INTEGER DEFAULT 404;
    
    SET _nbr_vivants = (
		SELECT
			count(point_vie)
		FROM
			Monstre
			INNER JOIN Affectation_salle ON id_monstre = monstre
			INNER JOIN Salle ON salle = id_salle
		WHERE
			(id_salle = _id_salle) AND
			(_moment_precis BETWEEN debut_affectation AND fin_affectation)
		#GROUP BY id_salle
	);
		
	#retourne s'ils sont tous mort
    IF _nbr_vivants = 0 THEN
		SET _des_vivants = 0;#false
	ELSE
		SET _des_vivants = 1;#true
	END IF;
	RETURN _des_vivants;
END $$
DELIMITER ;

/**
 * Fonction pour savoir si tous les aventuriers sont morts
 *
 * @param _id_expedition Une expédition où faire la vérification
 * @return NOT _tous_morts Un booleen, 0 si tous mort, 1 s'il y a des vivants.
 */
DROP FUNCTION IF EXISTS aventuriers_en_vie;
DELIMITER $$
CREATE FUNCTION aventuriers_en_vie(_id_expedition INTEGER) RETURNS INTEGER CONTAINS SQL DETERMINISTIC
BEGIN
	DECLARE _des_vivant INTEGER;#bool
    DECLARE _nbr_vivants INTEGER;
    
    #Sanity Check
    IF (SELECT id_expedition FROM Expedition WHERE id_expedition=_id_expedition)!=1 THEN #if(_id_expedition not found)
		SIGNAL SQLSTATE '02001' SET MESSAGE_TEXT = 'L\'expedition  n\'existe pas!';
	END IF;
    
    #Valider le SELECT return combien de vivants
    SET _nbr_vivants = (
		SELECT
			count(point_vie)
		FROM
			Aventurier
			NATURAL JOIN Expedition_aventurier
			NATURAL JOIN Expedition
		WHERE
			point_vie > 0 AND #vivant AND
			id_expedition = _id_expedition #dans l'expedition recherchee
	);

	IF _nbr_vivants = 0 THEN
		SET _des_vivant = 0;#false
	ELSE
		SET _des_vivant = 1;#true
	END IF;
	RETURN _des_vivant;
END $$
DELIMITER ;















