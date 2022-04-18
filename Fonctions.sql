/*
 * Fonctions pour la bd pour Donjon Inc.
 *
 * Fichier : Fonctions.sql
 * Auteur : Olivier Belrose et Antoine Ouellette
 * Langage : SQL
 * Date : avril 2022
 */
 
USE RessourcesMonstrueuses;

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




















