/*
 * Code de création des données de la bd pour Donjon Inc.
 *
 * Fichier : CreationDonnees.sql
 * Auteur : Olivier Belrose et Antoine Ouellette
 * Langage : SQL
 * Date : février 2022
 */

DROP DATABASE IF EXISTS RessourcesMonstrueuses;
CREATE DATABASE RessourcesMonstrueuses;
USE RessourcesMonstrueuses;

CREATE TABLE Salle (
	id_salle INTEGER PRIMARY KEY AUTO_INCREMENT,
	fonction VARCHAR(255) NOT NULL,
	longueur FLOAT NOT NULL,
	largeur FLOAT NOT NULL,
	salle_suivante INTEGER UNIQUE,
	/* Contraintes */
	FOREIGN KEY (salle_suivante) REFERENCES Salle(id_salle)
);

CREATE TABLE Aventurier (
	id_aventurier INTEGER PRIMARY KEY AUTO_INCREMENT,
    nom VARCHAR(255) NOT NULL,
    classe VARCHAR(255) NOT NULL,
    niveau TINYINT NOT NULL,
    point_vie INTEGER NOT NULL,
    attaque INTEGER NOT NULL
);

CREATE TABLE Expedition (
	id_expedition INTEGER PRIMARY KEY AUTO_INCREMENT,
    nom_equipe VARCHAR(255) UNIQUE NOT NULL,
    depart DATETIME,
    terminaison DATETIME
);

CREATE TABLE Expedition_aventurier (
	id_expedition INTEGER,
    id_aventurier INTEGER,
    /* Contraintes */
    PRIMARY KEY (id_expedition, id_aventurier),
    FOREIGN KEY (id_expedition) REFERENCES Expedition(id_expedition),
    FOREIGN KEY (id_aventurier) REFERENCES Aventurier(id_aventurier)
);

CREATE TABLE Visite_salle (
	salle INTEGER,
    expedition INTEGER,
    moment_visite DATETIME NOT NULL,
    appreciation TEXT,
    /* Contraintes */
    PRIMARY KEY (salle, expedition),
    FOREIGN KEY (salle) REFERENCES Salle(id_salle),
    FOREIGN KEY (expedition) REFERENCES Expedition(id_expedition)
);

CREATE TABLE Objet (
	id_objet INTEGER PRIMARY KEY AUTO_INCREMENT,
    nom VARCHAR(255),
    valeur INT,
    masse FLOAT
);

CREATE TABLE Coffre_tresor (
	id_coffre_tresor INTEGER PRIMARY KEY AUTO_INCREMENT,
	code_secret CHAR(64),
    salle INTEGER,
    /* Contraintes */
    FOREIGN KEY (salle) REFERENCES Salle(id_salle)
);

CREATE TABLE Ligne_coffre (
	coffre INTEGER,
	objet INTEGER,
    quantite INTEGER,
    /* Contraintes */
    PRIMARY KEY (coffre, objet),
    FOREIGN KEY (coffre) REFERENCES Coffre_tresor(id_coffre_tresor),
    FOREIGN KEY (objet) REFERENCES Objet(id_objet)
);

CREATE TABLE Famille_monstre (
	id_famille INTEGER PRIMARY KEY AUTO_INCREMENT,
    nom_famille VARCHAR(255),
    point_vie_maximal INTEGER,
    degat_base INTEGER
);

CREATE TABLE Humanoide (
	id_humanoide INTEGER PRIMARY KEY AUTO_INCREMENT,
    famille INTEGER,
    arme VARCHAR(255),
    intelligence INTEGER,
    /* Contraintes */
    FOREIGN KEY (famille) REFERENCES Famille_monstre(id_famille)
);

CREATE TABLE Mort_vivant (
	id_mort_vivant INTEGER PRIMARY KEY AUTO_INCREMENT,
    famille INTEGER,
    vulnerable_soleil TINYINT,
    infectieux TINYINT,
    /* Contraintes */
    FOREIGN KEY (famille) REFERENCES Famille_monstre(id_famille)
);

CREATE TABLE Elementaire (
	id_elementaire INTEGER PRIMARY KEY AUTO_INCREMENT,
    famille INTEGER,
    element ENUM('air', 'feu', 'terre', 'eau'),
    taille ENUM('rikiki', 'moyen', 'grand', 'colossal'),
    /* Contraintes */
    FOREIGN KEY (famille) REFERENCES Famille_monstre(id_famille)
);

CREATE TABLE Monstre (
	id_monstre INTEGER PRIMARY KEY AUTO_INCREMENT,
	nom VARCHAR(255),
	code_employe CHAR(4),
	point_vie INTEGER,
	attaque INTEGER,
	numero_ass_maladie BLOB,
	id_famille INTEGER,
	experience INTEGER,
	/* Contraintes */
	FOREIGN KEY (id_famille) REFERENCES Famille_monstre(id_famille)
);

CREATE TABLE Responsabilite (
	id_responsabilite INTEGER PRIMARY KEY AUTO_INCREMENT,
	titre VARCHAR(255),
	niveau_responsabilite INTEGER
);

CREATE TABLE Affectation_salle (
	id_affectation INTEGER PRIMARY KEY AUTO_INCREMENT,
	monstre INTEGER,
    responsabilite INTEGER,
    salle INTEGER,
    debut_affectation DATETIME,
    fin_affectation DATETIME,
    /* Contraintes */
    FOREIGN KEY (monstre) REFERENCES Monstre(id_monstre),
    FOREIGN KEY (responsabilite) REFERENCES Responsabilite(id_responsabilite),
    FOREIGN KEY (salle) REFERENCES Salle(id_salle)
);