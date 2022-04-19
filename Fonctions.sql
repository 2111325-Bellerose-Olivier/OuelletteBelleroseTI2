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
	SET @_texte_crypte = AES_ENCRYPT(_donnee, UNHEX(SHA2('mortauxheros', 256)));

	RETURN @_texte_crypte;
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
	DECLARE _texte_clair BLOB;
	#Decrypter _donnee_cryptee avec cle 'mortauxheros'
	SET @_texte_clair = AES_DECRYPT(_donnee_cryptee, UNHEX(SHA2('mortauxheros', 256)));

	RETURN @_texte_clair;
END $$
DELIMITER ;

/**
 * Fonction pour savoir si tous les monstres sont morts
 *
 * @param _id_salle Une salle a valider.
 * @param _moment_precis Un moment ou faire la validation.
 * @return NOT _tous_morts Un booleen, 0 si tous mort, 1 s'il y a des vivants.
 */
DROP FUNCTION IF EXISTS monstres_en_vie;
DELIMITER $$
CREATE FUNCTION monstres_en_vie(_id_salle INTEGER, _moment_precis DATETIME) RETURNS INTEGER CONTAINS SQL DETERMINISTIC
BEGIN
	DECLARE _tous_morts INTEGER;#bool
    DECLARE _total_vie INTEGER DEFAULT 404;
    
    SELECT
		SUM(point_vie)
	INTO
		@_total_vie
	FROM
		Monstre
        INNER JOIN Affectation_salle ON id_monstre = monstre
		INNER JOIN Salle ON salle = id_salle
	WHERE
		(id_salle = _id_salle) AND
        (_moment_precis BETWEEN debut_affectation AND fin_affectation)
	GROUP BY id_salle
	;
		
	#retourne s'ils sont tous mort
    IF @_total_vie = 0 THEN
		SET @_tous_morts = 1;#true
	ELSE
		SET @_tous_morts = 0;#false
	END IF;
	RETURN NOT @_tous_morts;
END $$
DELIMITER ;




















