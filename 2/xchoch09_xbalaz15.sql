----------------------------------------------------------------------
--                                                                  --
-- Soubor: xchoch09_xbalaz15.sql                                    --
-- Vytvoren: 2022-03-12                                             --
-- Autori: David Chocholaty (xchoch09), Martin Balaz (xbalaz15)     --
-- Projekt: Projekt pro predmet IDS, cast 2                         --
-- Tema: Zadani c. 66, Spolujizda                                   --
-- Popis: SQL skript pro vytvoreni objektu schematu databaze        --
--                                                                  --
----------------------------------------------------------------------


------------------------- ODSTRANENI ---------------------------------

DROP TABLE uzivatel CASCADE CONSTRAINTS;
DROP TABLE hodnoceni_ridice;
DROP TABLE hodnoceni_spolucestujiciho;
DROP TABLE automobil CASCADE CONSTRAINTS;
DROP TABLE spolujizda CASCADE CONSTRAINTS;
DROP TABLE opravneni CASCADE CONSTRAINTS;
DROP TABLE prispevek;
DROP TABLE vylet CASCADE CONSTRAINTS;
DROP TABLE druh CASCADE CONSTRAINTS;
DROP TABLE aktivita CASCADE CONSTRAINTS;
DROP TABLE obsahuje;
DROP TABLE misto CASCADE CONSTRAINTS;
DROP TABLE stat;
DROP TABLE vybaveni CASCADE CONSTRAINTS;
DROP TABLE predpoklada;
DROP TABLE ucastni;
DROP TABLE nastoupi;
DROP TABLE vystoupi;
DROP TABLE zastavka CASCADE CONSTRAINTS;
DROP TABLE ridi;
DROP TABLE navstivi;
DROP TABLE pojede;

------------------------- VYTVORENI ----------------------------------

-- Tabulka Automobil --
CREATE TABLE automobil (
    registracni_znacka VARCHAR(8), -- maximalne 8 znaku
    znacka VARCHAR(32),
    oznaceni_modelu VARCHAR(64),
    -- maximalni kapacita bez ridice
    maximalni_kapacita NUMBER(2) CHECK (maximalni_kapacita BETWEEN 1 AND 10), -- rozsah mezi 1 a 10
    CONSTRAINT PK_automobil PRIMARY KEY (registracni_znacka)
);

-- Tabulka Vylet --
CREATE TABLE vylet (
    id_vylet INT GENERATED AS IDENTITY,
    popis_programu VARCHAR(2048),
    ubytovani VARCHAR(1024),
    naklady NUMBER(6) NOT NULL CHECK (naklady BETWEEN 0 AND 1000000), -- mezi 0 a 1000000
    narocnost NUMBER(1) CHECK (narocnost BETWEEN 1 and 5), -- rozsah mezi 1 a 5
    CONSTRAINT PK_vylet PRIMARY KEY (id_vylet)
);

-- Tabulka Spolujizda --
CREATE TABLE spolujizda (
    id_spolujizda INT GENERATED AS IDENTITY,
    registracni_znacka VARCHAR(8) CONSTRAINT spolujizda_registracni_znacka_NN NOT NULL,
    id_vylet INT,
    cas_vyjezdu DATE NOT NULL,
    nastupni_misto VARCHAR(512) NOT NULL,
    vystupni_misto VARCHAR(512) NOT NULL,
    cena NUMBER(5) NOT NULL CHECK (cena BETWEEN 0 AND 10000), -- mezi 0 a 10000,
    zajizdka VARCHAR(512),
    casova_flexibilita VARCHAR(512),
    zavazadla VARCHAR(512),
    pocet_volnych_mist NUMBER(2) CHECK (pocet_volnych_mist BETWEEN 1 AND 10), -- rozsah mezi 1 a 10
    CONSTRAINT PK_spolujizda PRIMARY KEY (id_spolujizda),
    ---- pouziva ----
    CONSTRAINT FK_spolujizda_registracni_znacka FOREIGN KEY (registracni_znacka)
        REFERENCES automobil
        ON DELETE CASCADE,
    ---- patri ----
    CONSTRAINT FK_spolujizda_id_vylet FOREIGN KEY (id_vylet)
        REFERENCES vylet
        ON DELETE CASCADE
);

-- Tabulka Zastavka --
CREATE TABLE zastavka (
    id_zastavka INT GENERATED AS IDENTITY,
    id_spolujizda INT CONSTRAINT zastavka_id_spolujizda_NN NOT NULL,
    misto VARCHAR(64) NOT NULL,
    poradi NUMBER(3) NOT NULL CHECK (poradi BETWEEN 1 AND 255), -- mezi 1 a 255
    cas_prijezdu DATE DEFAULT NULL,
    CONSTRAINT PK_zastavka PRIMARY KEY (id_zastavka),
    ---- patri ----
    CONSTRAINT FK_zastavka_id_spolujizda FOREIGN KEY (id_spolujizda)
        REFERENCES spolujizda
        ON DELETE CASCADE
);

-- Tabulka Uzivatel --
CREATE TABLE uzivatel (
    id_uzivatel INT GENERATED AS IDENTITY,
    jmeno VARCHAR(128) NOT NULL,
    prijmeni VARCHAR(128) NOT NULL,
    email VARCHAR(255) NOT NULL,
        CHECK(REGEXP_LIKE(
			email, '^[a-z]+[a-z0-9\.]*@[a-z0-9\.-]+\.[a-z]{2,}$', 'i'
		)),
    telefon_1 VARCHAR(15) DEFAULT NULL
        CHECK(REGEXP_LIKE(
            telefon_1, '^(\+|00)[1-9][0-9 \-\(\)\.]{7,32}$'
        )),
    telefon_2 VARCHAR(15) DEFAULT NULL
        CHECK(REGEXP_LIKE(
            telefon_2, '^(\+|00)[1-9][0-9 \-\(\)\.]{7,32}$'
            )),
    telefon_3 VARCHAR(15) DEFAULT NULL
        CHECK(REGEXP_LIKE(
            telefon_3, '^(\+|00)[1-9][0-9 \-\(\)\.]{7,32}$'
        )),
    popis VARCHAR(512),
    cesta_k_souboru_fotografie VARCHAR(1024) DEFAULT NULL
        CHECK(REGEXP_LIKE(
            cesta_k_souboru_fotografie, '^\/([a-z0-9-_+]+\/)*([a-z0-9]+\.(jpe?g|png|gif|bmp))$', 'i'
        )),
    hudba NUMBER(1,0),
    koureni NUMBER(1,0),
    zvirata NUMBER(1,0),
    komunikace VARCHAR(64),
    zkusenost INT DEFAULT 0,
    CONSTRAINT PK_uzivatel PRIMARY KEY (id_uzivatel)
);

-- Pridani ciziho klice id_uzivatel do tabulky Spolujizda --
ALTER TABLE spolujizda ADD (
    id_uzivatel INT CONSTRAINT spolujizda_id_uzivatel_NN NOT NULL,
    ---- nabizi ----
    CONSTRAINT FK_spolujizda_id_uzivatel FOREIGN KEY (id_uzivatel)
        REFERENCES uzivatel
        ON DELETE CASCADE
    );

-- Pridani ciziho klice id_uzivatel do tabulky Vylet --
ALTER TABLE vylet ADD (
    id_uzivatel INT CONSTRAINT vylet_id_uzivatel_NN NOT NULL,
    ---- nabizi ----
    CONSTRAINT FK_vylet_id_uzivatel FOREIGN KEY (id_uzivatel)
        REFERENCES uzivatel
        ON DELETE CASCADE
    );

-- Tabulka Ridi --
CREATE TABLE ridi (
    id_uzivatel INT CONSTRAINT ridi_id_uzivatel_NN NOT NULL,
    registracni_znacka VARCHAR(255) CONSTRAINT ridi_registracni_znacka_NN NOT NULL,
    CONSTRAINT PK_ridi PRIMARY KEY (id_uzivatel, registracni_znacka),
    CONSTRAINT FK_ridi_id_uzivatel FOREIGN KEY (id_uzivatel)
        REFERENCES uzivatel
        ON DELETE CASCADE,
    CONSTRAINT FK_ridi_registracni_znacka FOREIGN KEY (registracni_znacka)
        REFERENCES automobil
        ON DELETE CASCADE
);

-- Tabulka Ucastni --
CREATE TABLE ucastni (
    id_uzivatel INT CONSTRAINT ucastni_id_uzivatel_NN  NOT NULL,
    id_spolujizda INT CONSTRAINT ucastni_id_spolujizda_NN NOT NULL,
    CONSTRAINT PK_ucastni PRIMARY KEY (id_uzivatel, id_spolujizda),
    CONSTRAINT FK_ucastni_id_uzivatel FOREIGN KEY (id_uzivatel)
        REFERENCES uzivatel
        ON DELETE CASCADE,
    CONSTRAINT FK_ucastni_id_spolujizda FOREIGN KEY (id_spolujizda)
        REFERENCES spolujizda
        ON DELETE CASCADE
);

-- Tabulka Nastoupi --
CREATE TABLE nastoupi (
    id_uzivatel INT CONSTRAINT nastoupi_id_uzivatel NOT NULL,
    id_zastavka INT CONSTRAINT nastoupi_id_zastavka NOT NULL,
    CONSTRAINT PK_nastoupi PRIMARY KEY (id_uzivatel, id_zastavka),
    CONSTRAINT FK_nastoupi_id_uzivatel FOREIGN KEY (id_uzivatel)
        REFERENCES uzivatel
        ON DELETE CASCADE,
    CONSTRAINT FK_nastoupi_id_zastavka FOREIGN KEY (id_zastavka)
        REFERENCES zastavka
        ON DELETE CASCADE
);

-- Tabulka Vystoupi --
CREATE TABLE vystoupi (
    id_uzivatel INT CONSTRAINT vystoupi_id_uzivatel NOT NULL,
    id_zastavka INT CONSTRAINT vystoupi_id_zastavka NOT NULL,
    CONSTRAINT PK_vystoupi PRIMARY KEY (id_uzivatel, id_zastavka),
    CONSTRAINT FK_vystoupi_id_uzivatel FOREIGN KEY (id_uzivatel)
        REFERENCES uzivatel
        ON DELETE CASCADE,
    CONSTRAINT FK_vystoupi_id_zastavka FOREIGN KEY (id_zastavka)
        REFERENCES zastavka
        ON DELETE CASCADE
);

-- Tabulka Pojede --
CREATE TABLE pojede (
    id_uzivatel INT CONSTRAINT pojede_id_uzivatel_NN  NOT NULL,
    id_vylet INT CONSTRAINT pojede_id_vylet_NN NOT NULL,
    CONSTRAINT PK_pojede PRIMARY KEY (id_uzivatel, id_vylet),
    CONSTRAINT FK_pojede_id_uzivatel FOREIGN KEY (id_uzivatel)
        REFERENCES uzivatel
        ON DELETE CASCADE,
    CONSTRAINT FK_pojede_id_vylet FOREIGN KEY (id_vylet)
        REFERENCES vylet
        ON DELETE CASCADE
);

-- Tabulka Hodnoceni ridice --
CREATE TABLE hodnoceni_ridice (
    id_hodnoceni_ridice INT GENERATED AS IDENTITY,
    id_uzivatel INT,
    id_uzivatel_2 INT CONSTRAINT hodnoceni_ridice_id_uzivatel_2_NN  NOT NULL,
    obsah VARCHAR(512),
    pocet_hvezdicek NUMBER(1) CHECK (pocet_hvezdicek BETWEEN 1 and 5), -- rozsah mezi 1 a 5
    CONSTRAINT PK_hodnoceni_ridice PRIMARY KEY (id_hodnoceni_ridice),
    ---- vytvori ----
    CONSTRAINT FK_hodnoceni_ridice_id_uzivatel FOREIGN KEY (id_uzivatel)
        REFERENCES uzivatel
        ON DELETE SET NULL,
    ----  patri  ----
    CONSTRAINT FK_hodnoceni_ridice_id_uzivatel_2 FOREIGN KEY (id_uzivatel_2)
        REFERENCES uzivatel
        ON DELETE CASCADE
);

-- Tabulka Hodnoceni spolucestujiciho --
CREATE TABLE hodnoceni_spolucestujiciho (
    id_hodnoceni_spolucestujiciho INT GENERATED AS IDENTITY,
    id_uzivatel INT,
    id_uzivatel_2 INT CONSTRAINT hodnoceni_spolucestujiciho_id_uzivatel_2_NN  NOT NULL,
    obsah VARCHAR(512),
    spokojenost NUMBER(1) CHECK (spokojenost BETWEEN 1 and 5), -- rozsah mezi 1 a 5
    dochvilnost NUMBER(1) CHECK (dochvilnost BETWEEN 1 and 5), -- rozsah mezi 1 a 5
    pratelstvi NUMBER(1) CHECK (pratelstvi BETWEEN 1 and 5), -- rozsah mezi 1 a 5
    CONSTRAINT PK_hodnoceni_spolucestujiciho PRIMARY KEY (id_hodnoceni_spolucestujiciho),
    ---- vytvori ----
    CONSTRAINT FK_hodnoceni_spolucestujiciho_id_uzivatel FOREIGN KEY (id_uzivatel)
        REFERENCES uzivatel
        ON DELETE SET NULL,
    ----  patri  ----
    CONSTRAINT FK_hodnoceni_spolucestujiciho_id_uzivatel_2 FOREIGN KEY (id_uzivatel_2)
        REFERENCES uzivatel
        ON DELETE CASCADE
);

-- Tabulka Opravneni --
--
-- Generalizace, specializace -> disjunktni, totalni
--
-- Transformace: 
-- -> varianta (4) dle prednasek pro predmet IDS
-- -> uvedeni vsech hodnot v jedne tabulce (tabulka nadtypu),
--    tabulka obsahuje tzv. diskriminator pro rozliseni typu
CREATE TABLE opravneni (
    id_opravneni INT GENERATED AS IDENTITY,
    -- Diskriminator pro rozliseni typu
    typ VARCHAR(32) NOT NULL CHECK (typ IN ('verejny',
                                            'sdileny_mezi_ucastniky',
                                            'soukromy')),
    CONSTRAINT PK_opravneni PRIMARY KEY (id_opravneni)
);

-- Tabulka Prispevek --
--
-- Generalizace, specializace -> disjunktni, totalni
--
-- Transformace: 
-- -> varianta (4) dle prednasek pro predmet IDS
-- -> uvedeni vsech hodnot v jedne tabulce (tabulka nadtypu),
--    tabulka obsahuje tzv. diskriminator pro rozliseni typu a zaroven
--    ostatni sloupce podtypu mimo sloupcu pro dany typ obsahuji prazdnou hodnotu
CREATE TABLE prispevek (
    id_prispevek INT GENERATED AS IDENTITY,
    id_uzivatel INT,
    id_opravneni INT CONSTRAINT prispevek_id_opravneni_NN  NOT NULL,
    id_vylet INT CONSTRAINT prispevek_id_vylet_NN NOT NULL,
    -- Diskriminator pro rozliseni typu
    typ VARCHAR(8) NOT NULL CHECK (typ IN ('clanek','vlog')),
    obsah VARCHAR(2048) DEFAULT NULL,
    popis VARCHAR(512) DEFAULT NULL,
    cesta_k_souboru_videa VARCHAR(1024) DEFAULT NULL
        CHECK(REGEXP_LIKE(
                cesta_k_souboru_videa, '^\/([a-z0-9-_+]+\/)*([a-z0-9]+\.(mp4|mkv|wmv|m4v|mov|avi|flv|webm|flac|mka|m4a|aac|ogg))$', 'i'
            )),
    CONSTRAINT PK_prispevek PRIMARY KEY (id_prispevek),
    ---- vytvori ----
    CONSTRAINT FK_prispevek_id_uzivatel FOREIGN KEY (id_uzivatel)
        REFERENCES uzivatel
        ON DELETE SET NULL,
    ---- prideleno ----
    CONSTRAINT FK_prispevek_id_opravneni FOREIGN KEY (id_opravneni)
        REFERENCES opravneni
        ON DELETE CASCADE,
    ---- patri ----
    CONSTRAINT FK_prispevek_id_vylet FOREIGN KEY (id_vylet)
        REFERENCES vylet
        ON DELETE CASCADE,
    --- clanek -> obsah, vlog -> popis, cesta k souboru videa ----
    CONSTRAINT CHK_prispevek_clanek CHECK (
        (typ='clanek' AND popis=NULL AND cesta_k_souboru_videa=NULL) OR
        (typ='vlog' AND obsah=NULL)
    )
);

-- Tabulka Druh --
CREATE TABLE druh (
    id_druh INT GENERATED AS IDENTITY,
    nazev_druhu VARCHAR(32),
    CONSTRAINT PK_druh PRIMARY KEY (id_druh)
);

-- Tabulka Aktivita --
CREATE TABLE aktivita (
    id_aktivita INT GENERATED AS IDENTITY,
    id_druh INT,
    nazev VARCHAR(32),
    CONSTRAINT PK_aktivita PRIMARY KEY (id_aktivita),
    ---- spada ----
    CONSTRAINT FK_aktivita_id_druh FOREIGN KEY (id_druh)
        REFERENCES druh
        ON DELETE SET NULL
);

-- Tabulka Obsahuje --
CREATE TABLE obsahuje (
    id_vylet INT CONSTRAINT obsahuje_id_vylet_NN  NOT NULL,
    id_aktivita INT CONSTRAINT obsahuje_id_aktivita_NN  NOT NULL,
    CONSTRAINT PK_obsahuje PRIMARY KEY (id_vylet, id_aktivita),
    CONSTRAINT FK_obsahuje_id_vylet FOREIGN KEY (id_vylet)
        REFERENCES vylet
        ON DELETE CASCADE,
    CONSTRAINT FK_obsahuje_id_aktivita FOREIGN KEY (id_aktivita)
        REFERENCES aktivita
        ON DELETE CASCADE
);

CREATE TABLE stat (
    kod_statu VARCHAR(3),
    nazev VARCHAR(32),
    CONSTRAINT PK_stat PRIMARY KEY (kod_statu)
);

-- Tabulka Misto --
CREATE TABLE misto (
    id_misto INT GENERATED AS IDENTITY,
    kod_statu VARCHAR(3),
    nazev VARCHAR(64),
    CONSTRAINT PK_misto PRIMARY KEY (id_misto),
    ---- nachazi ----
    CONSTRAINT FK_misto_kod_statu FOREIGN KEY (kod_statu)
        REFERENCES stat
        ON DELETE SET NULL
);

-- Tabulka Navstivi --
CREATE TABLE navstivi (
    id_vylet INT CONSTRAINT navstivi_id_vylet_NN NOT NULL,
    id_misto INT CONSTRAINT navstivi_id_misto_NN NOT NULL,
    CONSTRAINT PK_navstivi PRIMARY KEY (id_vylet, id_misto),
    CONSTRAINT FK_navstivi_id_vylet FOREIGN KEY (id_vylet)
        REFERENCES vylet
        ON DELETE CASCADE,
    CONSTRAINT FK_navstivi_id_misto FOREIGN KEY (id_misto)
        REFERENCES misto
        ON DELETE CASCADE
);

-- Tabulka Vybaveni --
CREATE TABLE vybaveni (
    id_vybaveni INT GENERATED AS IDENTITY,
    id_druh INT,
    nazev VARCHAR(32),
    CONSTRAINT PK_vybaveni PRIMARY KEY (id_vybaveni),
    ---- spada ----
    CONSTRAINT FK_vybaveni_id_druh FOREIGN KEY (id_druh)
        REFERENCES druh
        ON DELETE SET NULL
);

-- Tabulka Predpoklada --
CREATE TABLE predpoklada (
    id_vylet INT CONSTRAINT predpoklada_id_vylet_NN  NOT NULL,
    id_vybaveni INT CONSTRAINT predpoklada_id_vybaveni_NN  NOT NULL,
    CONSTRAINT PK_predpoklada PRIMARY KEY (id_vylet, id_vybaveni),
    CONSTRAINT FK_predpoklada_id_vylet FOREIGN KEY (id_vylet)
        REFERENCES vylet
        ON DELETE CASCADE,
    CONSTRAINT FK_predpoklada_id_vybaveni FOREIGN KEY (id_vybaveni)
        REFERENCES vybaveni
        ON DELETE CASCADE
);

----------------------------------------------------------------------
-------------------------- VKLADANI ----------------------------------
----------------------------------------------------------------------

-------------------------- UZIVATEL ----------------------------------

INSERT INTO uzivatel (jmeno, prijmeni, email, telefon_1, popis,
                      cesta_k_souboru_fotografie, hudba, koureni,
                      zvirata, komunikace)
VALUES ('Josef', 'Novák', 'josefnovak@gmail.com', '+420777666555',
        'Lorem ipsum dolor sit amet, consectetuer adipiscing elit.', '/images/Pepa.jpg',
         1, 1, 1, 'Pouze pokud bude zajímavé téma pro konverzaci.');

INSERT INTO uzivatel (jmeno, prijmeni, email, telefon_1, telefon_2, popis,
                      hudba, koureni, zvirata, komunikace)
VALUES('Jan', 'Dvořák', 'jandvorak@seznam.cz', '+420724159021', '+420612457891',
       'Nullam lectus justo, vulputate eget mollis sed, tempor sed magna.',
        1, 0, 0, 'Podle nálady.');

INSERT INTO uzivatel (jmeno, prijmeni, email, telefon_1, popis,
                      hudba, koureni, zvirata, komunikace)
VALUES('David', 'Chocholatý', 'davidchocholaty@firmy.cz', '+420791546879',
       'Aliquam id dolor. Mauris dolor felis, sagittis at, luctus sed, aliquam non, tellus.',
        1, 0, 0, 'Rád si cestou popovídám.');

INSERT INTO uzivatel (jmeno, prijmeni, email, telefon_1, popis,
                      hudba, koureni, zvirata, komunikace)
VALUES('Martin', 'Baláž', 'martinbalaz@email.cz', '+420615754831',
       'Suspendisse nisl. Phasellus faucibus molestie nisl.',
        1, 1, 1, 'Jasně, pokecáme.');

---------------------- HODNOCENI RIDICE ------------------------------
INSERT INTO hodnoceni_ridice (id_uzivatel, id_uzivatel_2, obsah, pocet_hvezdicek)
VALUES (2, 1, 'Šílenec, už nikdy.', 1);

INSERT INTO hodnoceni_ridice (id_uzivatel, id_uzivatel_2, obsah, pocet_hvezdicek)
VALUES (2, 4, 'Pohodář. Řídí bezpečně. Mohu jenom doporučit.', 5);

INSERT INTO hodnoceni_ridice (id_uzivatel, id_uzivatel_2, obsah, pocet_hvezdicek)
VALUES (3, 4, 'Naprostá spokojenost. Rád se svezu i někdy příště.', 5);

-------------------- HODNOCENI UZIVATELE -----------------------------

INSERT INTO hodnoceni_spolucestujiciho (id_uzivatel, id_uzivatel_2, obsah, spokojenost, dochvilnost, pratelstvi)
VALUES (4, 3, 'Dík za super pokec.', 5, 4, 5);

INSERT INTO hodnoceni_spolucestujiciho (id_uzivatel, id_uzivatel_2, obsah, spokojenost, dochvilnost, pratelstvi)
VALUES (1, 2, 'Celou cestu jenom remcal. Příště ať jde pěšky.', 1, 1, 1);

-------------------------- AUTOMOBIL ---------------------------------
INSERT INTO automobil (registracni_znacka, znacka, oznaceni_modelu, maximalni_kapacita)
VALUES ('EL106AC', 'BMW', 'M760Li xDrive Model V12 Excellence', 3);

INSERT INTO automobil (registracni_znacka, znacka, oznaceni_modelu, maximalni_kapacita)
VALUES ('4A68244', 'Mercedes-Benz', 'AMG S63 S E Performance', 3);

INSERT INTO automobil (registracni_znacka, znacka, oznaceni_modelu, maximalni_kapacita)
VALUES ('DICTATOR', 'Fiat', 'Multipla', 5);

---------------------------- RIDI ------------------------------------
INSERT INTO ridi (id_uzivatel, registracni_znacka)
VALUES (1, 'DICTATOR');

INSERT INTO ridi (id_uzivatel, registracni_znacka)
VALUES (3, 'EL106AC');

INSERT INTO ridi (id_uzivatel, registracni_znacka)
VALUES (4, 'EL106AC');

INSERT INTO ridi (id_uzivatel, registracni_znacka)
VALUES (4, '4A68244');

---------------------------- VYLET -----------------------------------
-- Vylet ke kteremu zaroven patri i spolujizda
INSERT INTO vylet (id_uzivatel, popis_programu, ubytovani, naklady, narocnost)
VALUES (3, 'Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Etiam bibendum elit eget erat. Etiam posuere lacus quis dolor. In enim a arcu imperdiet malesuada.',
        'Hotel Na pláži', 12300, 4);

-- Vylet bez spolujizdy
INSERT INTO vylet (id_uzivatel, popis_programu, ubytovani, naklady, narocnost)
VALUES (4, 'Sed ac dolor sit amet purus malesuada congue. Fusce aliquam vestibulum ipsum. Mauris dolor felis, sagittis at, luctus sed, aliquam non, tellus.',
        'BEST WESTERN PREMIER Hotel International Brno', 7500, 2);

------------------------- SPOLUJIZDA ---------------------------------
INSERT INTO spolujizda (id_uzivatel, registracni_znacka, cas_vyjezdu,
                        nastupni_misto, vystupni_misto, cena, zajizdka,
                        casova_flexibilita, zavazadla, pocet_volnych_mist)
VALUES (4,
        'EL106AC',
        TO_DATE('01-03-2022 17:30', 'DD-MM-YYYY HH24:MI'),
        'Praha hlavní nádraží',
        'Fakulta informačních technologií Vysokého učení technického v Brně',
        150,
        'Jsem ochotný mít zajížďku v okruhu do 20 km.',
        'Zdržení do půl hodiny je pro mě ještě přijatelné.',
        'Volné místo cca pro jeden kufr a batoh.',
        2);

INSERT INTO spolujizda (id_uzivatel, registracni_znacka, cas_vyjezdu,
                        nastupni_misto, vystupni_misto, cena, zajizdka,
                        casova_flexibilita, zavazadla, pocet_volnych_mist)
VALUES (1,
        'DICTATOR',
        TO_DATE('05-03-2022 12:00', 'DD-MM-YYYY HH24:MI'),
        'Masarykovo náměstí, Hradec králové',
        'Alšovo náměstí, Ostrava Poruba',
        300,
        'Bez zajížďky.',
        'Bez zdržení.',
        'Už mám kufr plný.',
        5);

INSERT INTO spolujizda (id_uzivatel, registracni_znacka, cas_vyjezdu,
                        nastupni_misto, vystupni_misto, cena, zajizdka,
                        casova_flexibilita, zavazadla, pocet_volnych_mist)
VALUES (4,
        '4A68244',
        TO_DATE('07-03-2022 9:00', 'DD-MM-YYYY HH24:MI'),
        'Fakulta informačních technologií Vysokého učení technického v Brně',
        'Praha hlavní nádraží',
        150,
        'Jsem ochotný mít zajížďku v okruhu do 20 km.',
        'Zdržení do půl hodiny je pro mě ještě přijatelné.',
        'Volné místo cca pro dva kufry.',
        2);

-- Patri k vyletu
INSERT INTO spolujizda (id_uzivatel, registracni_znacka, id_vylet, cas_vyjezdu,
                        nastupni_misto, vystupni_misto, cena, zajizdka,
                        casova_flexibilita, zavazadla, pocet_volnych_mist)
VALUES (3,
        'EL106AC',
        1,
        TO_DATE('09-03-2022 14:00', 'DD-MM-YYYY HH24:MI'),
        'Brno Semilasso',
        'Máchovo jezero',
        250,
        'Zajížďka tak do 30 km je v pohodě.',
        'Zdržení maximálě do hodiny.',
        'Volné místo pro jeden velký kufr.',
        1);

-------------------------- ZASTAVKA ----------------------------------
INSERT INTO zastavka (id_spolujizda, misto, poradi, cas_prijezdu)
VALUES (1, 'Humpolec', 1, TO_DATE('01-03-2022 18:30', 'DD-MM-YYYY HH24:MI'));

INSERT INTO zastavka (id_spolujizda, misto, poradi, cas_prijezdu)
VALUES (1, 'Velká Bíteš', 2, TO_DATE('01-03-2022 19:30', 'DD-MM-YYYY HH24:MI'));

INSERT INTO zastavka (id_spolujizda, misto, poradi)
VALUES (3, 'Jihlava', 1);

INSERT INTO zastavka (id_spolujizda, misto, poradi)
VALUES (3, 'Havlíčkův Brod', 2);

INSERT INTO zastavka (id_spolujizda, misto, poradi)
VALUES (3, 'Humpolec', 3);

-------------------------- NASTOUPI ----------------------------------
-- 1) nastoupi v Humpolci a vystoupi ve Velke Bitesi
INSERT INTO nastoupi (id_uzivatel, id_zastavka)
VALUES (2, 1);

-- 2) nastoupi ve Velke Bitesi a vystoupi az v Brne
INSERT INTO nastoupi (id_uzivatel, id_zastavka)
VALUES (3, 2);

-------------------------- VYSTOUPI ----------------------------------
-- 1) nastoupi v Humpolci a vystoupi ve Velke Bitesi
INSERT INTO vystoupi (id_uzivatel, id_zastavka)
VALUES (2, 2);

-- 3) nastoupi uz v Brne a vystoupi v Jihlave
INSERT INTO vystoupi (id_uzivatel, id_zastavka)
VALUES (3, 3);

--------------------------- UCASTNI ----------------------------------
INSERT INTO ucastni (id_uzivatel, id_spolujizda)
VALUES (2, 1);

INSERT INTO ucastni (id_uzivatel, id_spolujizda)
VALUES (2, 2);

INSERT INTO ucastni (id_uzivatel, id_spolujizda)
VALUES (2, 3);

INSERT INTO ucastni (id_uzivatel, id_spolujizda)
VALUES (3, 1);

INSERT INTO ucastni (id_uzivatel, id_spolujizda)
VALUES (3, 3);

-- Patri k vyletu
INSERT INTO ucastni (id_uzivatel, id_spolujizda)
VALUES (2, 4);

-- Patri k vyletu
INSERT INTO ucastni (id_uzivatel, id_spolujizda)
VALUES (4, 4);

---------------------------- POJEDE ----------------------------------
INSERT INTO pojede (id_uzivatel, id_vylet)
VALUES (2, 1);

INSERT INTO pojede (id_uzivatel, id_vylet)
VALUES (4, 1);

INSERT INTO pojede (id_uzivatel, id_vylet)
VALUES (3, 2);

---------------------------- DRUH ------------------------------------
INSERT INTO druh (nazev_druhu)
VALUES ('sport');

INSERT INTO druh (nazev_druhu)
VALUES ('turistika');

-------------------------- AKTIVITA ----------------------------------
INSERT INTO aktivita (nazev, id_druh)
VALUES ('windsurfing', 1);

INSERT INTO aktivita (nazev, id_druh)
VALUES ('pěší turistika', 2);

-------------------------- OBSAHUJE ----------------------------------
INSERT INTO obsahuje (id_vylet, id_aktivita)
VALUES (1, 1);

INSERT INTO obsahuje (id_vylet, id_aktivita)
VALUES (1, 2);

---------------------------- STAT ------------------------------------
INSERT INTO stat (kod_statu, nazev)
VALUES ('CZE', 'Česko');

INSERT INTO stat (kod_statu, nazev)
VALUES ('POL', 'Polsko');

INSERT INTO stat (kod_statu, nazev)
VALUES ('DEU', 'Německo');

---------------------------- MISTO -----------------------------------
INSERT INTO misto (kod_statu, nazev)
VALUES ('CZE', 'Bezděz');

INSERT INTO misto (kod_statu, nazev)
VALUES ('CZE', 'Chráněná krajinná oblast Český ráj');

INSERT INTO misto (kod_statu, nazev)
VALUES ('POL', 'Lubań');

INSERT INTO misto (kod_statu, nazev)
VALUES ('DEU', 'Herrnhut');

INSERT INTO misto (kod_statu, nazev)
VALUES ('CZE', 'Vila Tugendhat');

-------------------------- NAVSTIVI ----------------------------------
INSERT INTO navstivi (id_vylet, id_misto)
VALUES (1, 1);

INSERT INTO navstivi (id_vylet, id_misto)
VALUES (1, 2);

INSERT INTO navstivi (id_vylet, id_misto)
VALUES (1, 3);

INSERT INTO navstivi (id_vylet, id_misto)
VALUES (1, 4);

INSERT INTO navstivi (id_vylet, id_misto)
VALUES (2, 5);

--------------------------- VYBAVENI ---------------------------------
INSERT INTO vybaveni (nazev, id_druh)
VALUES ('windsurf', 1);

INSERT INTO vybaveni (nazev, id_druh)
VALUES ('pohorky', 2);

------------------------- PREDPOKLADA --------------------------------
INSERT INTO predpoklada (id_vylet, id_vybaveni)
VALUES (1, 1);

INSERT INTO predpoklada (id_vylet, id_vybaveni)
VALUES (1, 2);

-------------------------- OPRAVNENI ---------------------------------
INSERT INTO opravneni (typ)
VALUES ('verejny');

INSERT INTO opravneni (typ)
VALUES ('sdileny_mezi_ucastniky');

INSERT INTO opravneni (typ)
VALUES ('soukromy');

-------------------------- PRISPEVEK ---------------------------------
INSERT INTO prispevek (id_uzivatel, id_opravneni, id_vylet, typ, obsah)
VALUES (2, 1, 1, 'clanek', 'Aenean id metus id velit ullamcorper pulvinar. Phasellus faucibus molestie nisl. Aliquam ornare wisi eu metus.');

INSERT INTO prispevek (id_uzivatel, id_opravneni, id_vylet, typ, popis, cesta_k_souboru_videa)
VALUES (4, 2, 1, 'vlog', 'Temporibus autem quibusdam et aut officiis debitis aut rerum necessitatibus saepe eveniet.', '/videos/vlog.mp4');
