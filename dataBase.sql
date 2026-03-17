DROP DATABASE IF EXISTS travel_agency_2025;
CREATE DATABASE travel_agency_2025;
USE travel_agency_2025;

CREATE TABLE admin(
                      adm_AT CHAR(10) NOT NULL,
                      adm_type ENUM('LOGISTICS','ADMINISTRATIVE','ACCOUNTING') NOT NULL,
                      adm_diploma VARCHAR(200) DEFAULT NULL,
                      PRIMARY KEY(adm_AT)
) ENGINE=InnoDB;

CREATE TABLE branch(
                       br_code INT(11) NOT NULL AUTO_INCREMENT,
                       br_street VARCHAR(50) NOT NULL,
                       br_num INT(4) NOT NULL,
                       br_city VARCHAR(30) NOT NULL,
                       br_manager_AT CHAR(10) DEFAULT NULL,
                       PRIMARY KEY(br_code),
                       CONSTRAINT CNSTR_branch_manager
                           FOREIGN KEY (br_manager_AT) REFERENCES admin(adm_AT)
                               ON DELETE SET NULL ON UPDATE CASCADE
) ;

CREATE TABLE phones(
                       ph_br_code INT(11) NOT NULL,
                       ph_number VARCHAR(15) NOT NULL,
                       PRIMARY KEY(ph_br_code, ph_number),
                       CONSTRAINT CNSTR_phones_branch
                           FOREIGN KEY (ph_br_code) REFERENCES branch(br_code)
                               ON DELETE CASCADE ON UPDATE CASCADE
) ;

CREATE TABLE manages(
                        mng_adm_AT CHAR(10) NOT NULL,
                        mng_br_code INT(11) NOT NULL,
                        PRIMARY KEY(mng_adm_AT, mng_br_code),
                        CONSTRAINT CNSTR_manage_admin
                            FOREIGN KEY (mng_adm_AT) REFERENCES admin(adm_AT)
                                ON DELETE CASCADE ON UPDATE CASCADE,
                        CONSTRAINT CNSTR_manages_branch
                            FOREIGN KEY (mng_br_code) REFERENCES branch(br_code)
                                ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE worker(
                       wrk_AT CHAR(10) NOT NULL,
                       wrk_name VARCHAR(30) NOT NULL,
                       wrk_lname VARCHAR(30) NOT NULL,
                       wrk_email VARCHAR(100) DEFAULT NULL,
                       wrk_salary DECIMAL(10,2) NOT NULL,
                       wrk_br_code INT(11) NOT NULL,
                       PRIMARY KEY(wrk_AT),
                       CONSTRAINT CNSTR_work_branch
                           FOREIGN KEY (wrk_br_code) REFERENCES branch(br_code)
                               ON DELETE CASCADE ON UPDATE CASCADE
) ;

ALTER TABLE admin
    ADD CONSTRAINT CNSTRT_branch_manager
        FOREIGN KEY (adm_AT) REFERENCES worker(wrk_AT)
            ON DELETE CASCADE ON UPDATE CASCADE;


CREATE TABLE driver(
                       drv_AT CHAR(10) NOT NULL,
                       drv_licence ENUM('A','B','C','D') NOT NULL,
                       drv_route ENUM('LOCAL','ABROAD') NOT NULL,
                       drv_experience TINYINT(4) DEFAULT '0',
                       PRIMARY KEY(drv_AT),
                       CONSTRAINT CNSTR_driver_is_worker
                           FOREIGN KEY (drv_AT) REFERENCES worker(wrk_AT)
                               ON DELETE CASCADE ON UPDATE CASCADE
) ;


CREATE TABLE guide(
                      gui_AT CHAR(10) NOT NULL,
                      gui_cv TEXT,
                      PRIMARY KEY(gui_AT),
                      CONSTRAINT CNSTR_guide_is_worker
                          FOREIGN KEY (gui_AT) REFERENCES worker(wrk_AT)
                              ON DELETE CASCADE ON UPDATE CASCADE
);


CREATE TABLE trip(
                     tr_id INT(11) NOT NULL AUTO_INCREMENT,
                     tr_departure DATETIME NOT NULL,
                     tr_return DATETIME NOT NULL,
                     tr_maxseats TINYINT NOT NULL,
                     tr_cost_adult DECIMAL(10,2) NOT NULL,
                     tr_cost_child DECIMAL(10,2) DEFAULT NULL,
                     tr_status ENUM('PLANNED','CONFIRMED','ACTIVE','COMPLETED','CANCELLED'),
                     tr_min_participants TINYINT  DEFAULT '1',
                     tr_br_code INT(11) NOT NULL,
                     tr_gui_AT CHAR(10) NOT NULL,
                     tr_drv_AT CHAR(10) NOT NULL,
                     PRIMARY KEY(tr_id),
                     CONSTRAINT CNSTR_trip_branch
                     FOREIGN KEY (tr_br_code) REFERENCES branch(br_code)
                     ON DELETE CASCADE ON UPDATE CASCADE,
                     CONSTRAINT CNSTR_trip_guide
                     FOREIGN KEY (tr_gui_AT) REFERENCES guide(gui_AT)
                     ON DELETE CASCADE ON UPDATE CASCADE,
                     CONSTRAINT CNSTR_trip_driver
                     FOREIGN KEY (tr_drv_AT) REFERENCES driver(drv_AT)
                     ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;


CREATE TABLE language_ref(
                             lang_code VARCHAR(5) NOT NULL,
                             lang_name VARCHAR(50) NOT NULL,
                             PRIMARY KEY(lang_code)
) ENGINE=InnoDB;


CREATE TABLE languages(
                          lng_gui_AT CHAR(10) NOT NULL,
                          lng_language_code VARCHAR(5) NOT NULL,
                          PRIMARY KEY(lng_gui_AT, lng_language_code),
                          CONSTRAINT CNSTR_lang_guide
                          FOREIGN KEY (lng_gui_AT) REFERENCES guide(gui_AT)
                          ON DELETE CASCADE ON UPDATE CASCADE,
                          CONSTRAINT CNSTR_lang_ref
                          FOREIGN KEY (lng_language_code) REFERENCES language_ref(lang_code)
                          ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;


CREATE TABLE customer(
                         cust_id INT(11) NOT NULL AUTO_INCREMENT,
                         cust_name VARCHAR(30) NOT NULL,
                         cust_lname VARCHAR(30) NOT NULL,
                         cust_email VARCHAR(100) DEFAULT NULL,
                         cust_phone VARCHAR(15) DEFAULT NULL,
                         cust_address TEXT,
                         cust_birth_date DATE DEFAULT NULL,
                         PRIMARY KEY(cust_id)
) ENGINE=InnoDB;


CREATE TABLE event(
                      ev_tr_id INT(11) NOT NULL,
                      ev_start DATETIME NOT NULL,
                      ev_end DATETIME NOT NULL,
                      ev_descr TEXT,
                      PRIMARY KEY(ev_tr_id, ev_start),
                      CONSTRAINT CNSTR_event_trip
                          FOREIGN KEY (ev_tr_id) REFERENCES trip(tr_id)
                              ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;


CREATE TABLE reservation(
                            res_tr_id INT(11) NOT NULL,
                            res_seatnum TINYINT(4) NOT NULL,
                            res_cust_id INT(11) NOT NULL,
                            res_status ENUM('PENDING','CONFIRMED','PAID','CANCELLED'),
                            res_total_cost DECIMAL(10,2) DEFAULT NULL,
                            PRIMARY KEY(res_tr_id, res_seatnum),
                            CONSTRAINT CNSTR_res_trip
                                FOREIGN KEY (res_tr_id) REFERENCES trip(tr_id)
                                    ON DELETE CASCADE ON UPDATE CASCADE,
                            CONSTRAINT CNSTR_res_cust
                                FOREIGN KEY (res_cust_id) REFERENCES customer(cust_id)
                                    ON DELETE CASCADE ON UPDATE CASCADE
);


CREATE TABLE destination(
                            dst_id INT(11) NOT NULL AUTO_INCREMENT,
                            dst_name VARCHAR(100) NOT NULL,
                            dst_descr TEXT,
                            dst_rtype ENUM('LOCAL','ABROAD') NOT NULL,
                            dst_language_code VARCHAR(5) NOT NULL,
                            dst_location INT(11) DEFAULT NULL,
                            PRIMARY KEY(dst_id),
                            CONSTRAINT CNSTR_dest_lang
                                FOREIGN KEY(dst_language_code) REFERENCES language_ref(lang_code)
                                    ON DELETE CASCADE ON UPDATE CASCADE,
                            CONSTRAINT CNSTR_dest_dest
                                FOREIGN KEY (dst_location) REFERENCES destination(dst_id)
                                    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;


CREATE TABLE travel_to(
                          to_tr_id INT(11) NOT NULL ,
                          to_dst_id INT(11) NOT NULL,
                          to_arrival DATETIME NOT NULL,
                          to_departure DATETIME NOT NULL,
                          to_sequence TINYINT(4) NOT NULL,
                          PRIMARY KEY(to_tr_id, to_dst_id),
                          CONSTRAINT CNSTR_travel_trip
                              FOREIGN KEY (to_tr_id) REFERENCES trip(tr_id)
                                  ON DELETE CASCADE ON UPDATE CASCADE,
                          CONSTRAINT CNSTR_travel_dest
                              FOREIGN KEY (to_dst_id) REFERENCES destination(dst_id)
                                  ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE accommodation
(
    acc_id                INT(11) NOT NULL AUTO_INCREMENT,
    acc_name              VARCHAR(100) NOT NULL,
    acc_type              ENUM ('HOTEL','HOSTEL','RESORT','APARTMENT','ROOMS_TO_RENT') NOT NULL,
    acc_stars             INT(1) DEFAULT NULL,
    acc_rating            DECIMAL(3, 2) DEFAULT 0,
    acc_status            ENUM ('AVAILABLE','UNAVAILABLE') NOT NULL,
    acc_inactive          ENUM ('RENOVATION','CLOSE','OTHER REASON') DEFAULT NULL,

    acc_street            VARCHAR(50) NOT NULL,
    acc_number            INT(11) NOT NULL,
    acc_city              VARCHAR(30)  NOT NULL,
    acc_zipcode           VARCHAR(10)  NOT NULL,
    acc_phone             VARCHAR(15)  NOT NULL,
    acc_email             VARCHAR(80) NOT NULL,

    acc_total_rooms       INT(11) DEFAULT 0,
    acc_price_per_night2 decimal(10, 2) NOT NULL,

    acc_wifi              TINYINT(1) DEFAULT 0,
    acc_restaurant_bar    TINYINT(1) DEFAULT 0,
    acc_ac                TINYINT(1) DEFAULT 0,
    acc_accesibility      TINYINT(1) DEFAULT 0,

    acc_dst_id            INT(11) NOT NULL,
    PRIMARY KEY (acc_id),
    CONSTRAINT CNSTR_acc_destination
        FOREIGN KEY (acc_dst_id) REFERENCES destination (dst_id)
            ON DELETE CASCADE ON UPDATE CASCADE

);

DELIMITER $$
CREATE TRIGGER check_accommodation_data
    BEFORE INSERT ON accommodation
    FOR EACH ROW
BEGIN
    IF NEW.acc_type IN ('HOTEL', 'RESORT') THEN
        IF NEW.acc_stars IS NULL OR NEW.acc_stars < 1 OR NEW.acc_stars > 5 THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Hotel και Resorts μπορουν να εχουν απο 1 εωσ 5 αστερια.';
        END IF;
    ELSE
        IF NEW.acc_stars IS NOT NULL THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Μονο τα hotel και τα Resort μπορουν να εχουν αστερια';
        END IF;
    END IF;

    IF NEW.acc_rating <0.00 OR NEW.acc_rating > 5.00 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT='Η βαθμολογια μπορει να ειναι μεταξυ 0.00 και 5.00';
        END IF;

    IF NEW.acc_status='AVAILABLE' AND NEW.acc_inactive IS NOT NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT='Τα διαθεσιμα καταλυματα δεν ε[πιτρεπεται να εχουν αιτια μη διαθεσιμοτητασ';
        ELSEIF NEW.acc_status='UNAVAILABLE' AND NEW.acc_inactive IS NULL THEN
            SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT='Τα μη διαθεσιμα καταλυματα πρεπει να εχουν συγκεκριμενο λογο ';
    end if;


    IF NEW.acc_type IN ('HOTEL', 'RESORT') THEN
        IF NEW.acc_stars IS NULL OR NEW.acc_stars < 1 OR NEW.acc_stars > 5 THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Hotel και Resorts μπορουν να εχουν απο 1 εωσ 5 αστερια.';
        END IF;
    ELSE
        IF NEW.acc_stars IS NOT NULL THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Μονο τα hotel και τα Resort μπορουν να εχουν αστερια';
        END IF;
    END IF;
END$$

DELIMITER ;


#syndeontai edo tajidi-katalima gia krathseis
CREATE TABLE trip_accommodation(
    re_trip_id INT(11) NOT NULL,
    re_acc_id INT(11) NOT NULL,
    re_check_in DATE NOT NULL,
    re_check_out DATE NOT NULL,
    re_rooms INT(11) NOT NULL DEFAULT 1,

    PRIMARY KEY (re_trip_id, re_acc_id),
    CONSTRAINT CNSTR_re_trip
         FOREIGN KEY (re_trip_id) REFERENCES trip(tr_id)
         ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT CNSTR_re_acc
         FOREIGN KEY (re_acc_id) REFERENCES accommodation(acc_id)
         ON DELETE CASCADE ON UPDATE CASCADE

);

DELIMITER $$
CREATE TRIGGER check_trip_dates_insert
    before insert on trip_accommodation
    for each row
    begin
        IF NEW.re_check_out < NEW.re_check_in THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT ='Η ημερομνιαα αναχωρησεισ δεν γινεται να ειναι πριν την ημερομηνια αφιξησ';
        end if ;
        end $$

CREATE TRIGGER check_trip_dates_update
    before update on trip_accommodation
    for each row
begin
    IF NEW.re_check_out < NEW.re_check_in THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT ='Η ημερομνιαα αναχωρησεισ δεν γινεται να ειναι πριν την ημερομηνια αφιξησ';
    end if ;
end $$

DELIMITER ;


CREATE TABLE travel_history(
                               th_id  INT(11) NOT NULL,
                               th_departure_date DATE NOT NULL,
                               th_return_date DATE NOT NULL,
                               th_total_destinations INT(11) NOT NULL,
                               th_total_customers INT(11) NOT NULL,
                               th_total_profit DECIMAL(10,2) NOT NULL
);

CREATE TABLE database_admin (
                                dbadmin_AT CHAR(10) NOT NULL,
                                dba_start_date DATE NOT NULL,
                                dba_end_date DATE DEFAULT NULL,
                                PRIMARY KEY (dbadmin_AT),
                                CONSTRAINT DBA
                                    FOREIGN KEY (dbadmin_AT) REFERENCES admin(adm_AT)
                                        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE log (
                     log_id INT(11) NOT NULL AUTO_INCREMENT,
                     log_date DATE NOT NULL,
                     log_time TIME NOT NULL,
                     log_dba_username VARCHAR(50) NOT NULL,
                     log_change_type ENUM('INSERT', 'UPDATE', 'DELETE'),
                     log_table VARCHAR(50) NOT NULL,  #onoma pinaka pou allaxe
                     PRIMARY KEY (log_id)
);

DROP TABLE IF EXISTS vehicle;
CREATE TABLE vehicle
(
    veh_id             INT(11) NOT NULL AUTO_INCREMENT,
    veh_brand          VARCHAR(30) NOT NULL,
    veh_model          VARCHAR(30) NOT NULL,
    veh_traffic_number VARCHAR(15) NOT NULL,
    veh_type           ENUM ('BUS','MINI BUS','VAN','CAR') NOT NULL,
    veh_status         ENUM ('AVAILABLE','UNDER MAINTENANCE','IN USE') NOT NULL,
    veh_capacity       INT(2) NOT NULL,
    veh_kilometers     INT(10) NOT NULL DEFAULT 0,
    veh_br_code        INT(11) NOT NULL,
    PRIMARY KEY (veh_id),
    UNIQUE (veh_traffic_number),
    CONSTRAINT veh_belongs_to_branch
        FOREIGN KEY (veh_br_code) REFERENCES branch (br_code)
            ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT chk_veh_capacity CHECK (
        (veh_type = 'BUS' AND veh_capacity > 20) OR
        (veh_type = 'MINI BUS' AND veh_capacity BETWEEN 10 AND 20) OR
        (veh_type = 'VAN' AND veh_capacity BETWEEN 6 AND 9) OR
        (veh_type = 'CAR' AND veh_capacity <= 5)
        )

);





INSERT INTO language_ref VALUES
                             ('SP', 'Spanish'),
                             ('EN', 'English'),
                             ('GR', 'Greek'),
                             ('DE', 'German'),
                             ('IT', 'Italian'),
                             ('CN', 'Chinese'),
                             ('FR', 'French'),
                             ('RU', 'Russian'),
                             ('JP', 'Japanese');

INSERT INTO customer VALUES
                         (NULL,'Milena', 'Skondra', 'milena12@gmail.com', '6954895236', 'Amerikis 15', '2005-01-07'),
                         (NULL,'Niki', 'Panagaki', 'nikip@gmail.com', '6978596234', 'Astiggos 76', '2005-11-03'),
                         (NULL,'Maria', 'Aisopou', 'mariaes@gmail.com', '6925698741', 'Karaiskaki 35', '2005-09-14'),
                         (NULL,'Giorgos' , 'Triantafyllou', 'gfullou@gmail.com' , '6971548963', 'Aratou 88', '2005-12-15'),
                         (NULL,'Dionysios', 'Papadopoulos', 'dennispap@ac.upatras.com', '6987234569', 'Maizonos 34', '1982-04-25'),
                         (NULL,'Dimitra', 'Konstadopoulou', 'dimkos@gmail.com', '6935698741', 'Kanari 5 ', '1975-06-08'),
                         (NULL,'Markos', 'Giannakis', 'markosgiann23@gmail.com', '698854796314', 'Mitropoleos 71', '2000-01-28'),
                         (NULL,'Konstantina', 'Apostolopoulou', 'konnaapost00@gmail.com', '6945632178', 'Agias Sofias 55','2000-09-19'),
                         (NULL,'Antonis', 'Oikonomopoulos', 'antoik78@yahoo.com', '6954872196', 'Kanakari 150', '1999-12-22'),
                         (NULL,'Ioannis', 'Petropoulos', 'johnpetrop@gmail.com', '6923568974', 'Notara 91', '2001-03-11'),
                         (NULL,'Vasiliki', 'Sellou', 'vasilsel@gmail.com', '6958947503', 'Xalkidikis 6', '2005-10-04'),
                         (NULL,'Ntona', 'Petroxilou', 'ntonapetro@gmail.com', '6978196053', 'Agia 69', '2004-03-27'),
                         (NULL,'Nefeli', 'Texlemtzi', 'Neftex@gmail.com', '6915039753', 'Tsitouri 10', '2005-02-09'),
                         (NULL,'Nikos', 'Mixail', 'nikmich@gmail.com', '6972305861', '28s Oktobriou 12', '2003-10-19'),
                         (NULL,'Aris', 'Vogiatzis', 'Arisvogia@gmail.com', '6949602378', 'Agiou Ioannou 34', '2006-07-07'),
                         (NULL,'Nikoleta', 'Mpovoli', 'nikmpov@gmail.com', '6979631250', 'Aitolias 4', '2003-09-09'),
                         (NULL,'Apostolos', 'Spanos', 'apostolspano@gmail.com', '6971720090', 'Zaimi 4', '2001-02-14'),
                         (NULL,'Giannis', 'Mpaklatzoglou', 'giannismpa@gmail.com', '6989102652', 'Ellinos Strtioti 34', '2001-04-17'),
                         (NULL,'Evelina', 'Strafioti', 'evelinastra@gmail.com', '6979568120', 'Gounari 39', '1985-07-06'),
                         (NULL,'Ioannis', 'Petropoulos', 'johnpetrop@gmail.com', '6923568974', 'Notara 91', '2001-03-11'),
                         (NULL,'Nikoleta', 'Giannakopoulou', 'nikolgiana@gmail.com', '6959842063', 'Smirnis 56', '1955-11-11'),
                         (NULL,'Niki', 'Tapiki', 'niktap@gmail.com', '6946305968', 'Korinthou 56 ', '1972-08-24'),
                         (NULL,'Panagiotis', 'Skondras', 'pskondras@gmail.com', '6972117090', 'Tsitouri 34', '1972-04-24'),
                         (NULL,'Katerina', 'Papastelatou', 'katpapa@gmail.com', '6972117206', 'Karolou 78', '1976-05-11'),
                         (NULL,'Nefeli', 'Stavropoulou', 'nefstav@gmail.com', '6985692015', 'Thesalias 45', '1988-09-04'),
                         (NULL,'Anastasia', 'Eleftheriou', 'anastaele@gmail.com', '6967286523', 'Makedonias 89', '1986-07-30'),
                         (NULL,'Andreas', 'Papagianatos', 'andreapapa@gmail.com', '6986643538', 'Papaflesa 19', '2001-11-28'),
                         (NULL,'Katerina', 'Stamatopoulou', 'katsta@gmail.com', '6936940284', 'Notara 56', '1947-08-02'),
                         (NULL,'Andreas', 'Trompetas', 'andtrompe@gmail.com', '6980829097', 'Adrianou 4', '1983-12-25'),
                         (NULL,'Theodoris', 'Stamatopoulos', 'teosta@gmail.com', '6996404873', 'Lontou', '2005-03-29');


INSERT INTO branch VALUES
                       (NULL,'Themistokleous', 1 , 'Athina', NULL),
                       (NULL,'Gounari', 2 , 'Patra', NULL),
                       (NULL,'Tsimiski', 7 , 'Thessaloniki', NULL),
                       (NULL,'Adrianou', 56 , 'Larisa', NULL),
                       (NULL,'Koronis', 20 , 'Ioannina', NULL),
                       (NULL,'Amfisis', 9 , 'Volos', NULL),
                       (NULL,'Nikaias', 3 , 'Lamia', NULL),
                       (NULL,'Karatza', 36 , 'Kiato', NULL),
                       (NULL,'Omirou', 10 , 'Xalkida', NULL);




INSERT INTO worker VALUES
                       #admin
                       ('A052416398', 'Andreas', 'Ioannou', 'andreasioannou@gmail.com', 2800.00, 4),
                       ('AB96857432', 'Ourania', 'Konstadinopoulou', 'ouraniakon@yahoo.com', 1300.50 , 2),
                       ('AO47895612', 'Grigoris', 'Michalopoulos', 'michalopgreg@gmail.com', 2000.00, 3),
                       ('EA12568974', 'Nikos', 'Panagopoulos', 'panagopnikos@gmail.com', 1500.50, 8),
                       ('AB36987412', 'Athanasia', 'Markopoulou', 'markopathanasia@gmail.com', 2000.00, 9),
                       ('XO78639541', 'Apostolis', 'Mpekiris', 'mpekiris1971@yahoo.com', 1500.60, 1),
                       ('AD58987496', 'Georgios', 'Nikolaou', 'nikolaougeorge@gmail.com', 2700.80 , 7),
                       ('AK12356987', 'Melina', 'Nikolopoulou', 'melinanikolop@gmail.com', 3400.40, 3),
                       ('XY96214756', 'Eleni', 'Takopoulou', 'elenitakopoulou@gmail.com', 1088.60 ,6 ),
                       ('AP45879612', 'Katerina', 'Mesmpouri', 'meskaterina@yahoo.com', 1500.76 , 3),
                       ('AS10258746', 'Eliza', 'Oikonomou', 'oikonomoueliza33@gmail.com', 3300.90 , 1),
                       ('AF65478957', 'Sofoklis', 'Manolopoulos', 'sofoklismanolop@gmail.com', 3780.80 , 4),
                       ('XY32145698', 'Konstantinos', 'Anagnostopoulos', 'anagnostopoulos76@yahoo.com', 1200.40 , 5),
                       ('AC89561056', 'Nikos', 'Vlaxogiannis', 'nikvla@gmail.com', 2500.00, 2),
                       ('BW59634182', 'Giota', 'Filaou', 'giotafil@yahoo.com', 1000.50 , 4),
                       #drivers
                       ('AP10263987', 'Panagiota', 'Michail', 'panamick@gmail.com', 600.30, 6),
                       ('EN89753032', 'Stamatia', 'Vamvakidi', 'stamavam@gmail.com', 390.50, 9),
                       ('AN06985312', 'Ioanna', 'Apostolidi', 'aposion@gmail.com', 2010.90, 7),
                       ('VW49631567', 'Donata', 'Plarinou', 'plarinoudo@yahoo.com', 1400.60, 1),
                       ('AD72646159', 'Theodora', 'Pothitou', 'pothitou78@gmail.com', 1400.70 , 7),
                       ('BN02365489', 'Ismini', 'Rigopoulou', 'ismini2@gmail.com', 2400.10, 3),
                       ('XU45210397', 'Hlias', 'Tselai', 'hliastsele@gmail.com', 288.50 , 4),
                       ('AL03697412', 'Kiki', 'Karagianni', 'kikikara@yahoo.com', 1290.70, 5),
                       ('MK03697416', 'Orestis', 'Labidas', 'oreslav@gmail.com', 1300.00 , 8),
                       ('KE02634586', 'Sotiris', 'Apostolopoulos', 'sotapo@gmail.com', 980.80 , 1),
                       ('NK02975458', 'Katerina', 'Damiri', 'katerina67@yahoo.com', 3300.20 , 9),
                       ('BI54896012', 'Ioanna', 'Lazari', 'lazio@gmail.com', 1500.90, 2),
                       #guide
                       ('AE59631056', 'Marieta', 'Thanopoulou', 'thanopouloumar@yahoo.com', 1400.00 , 2),
                       ('QO05697820', 'Eleftheria', 'Liarou', 'liarou78@gmail.com', 900.20, 3),
                       ('NY59630214', 'Xrisi', 'Sifogiorgaki', 'sifoxrisi@gmail.com', 790.40, 6),
                       ('JK26987103', 'Lenia', 'Xatziapostolou', 'lxatzi@gmail.com', 1110.80, 1),
                       ('AK56971230', 'Xristos', 'Koliopantos', 'kolio67xri@yahoo.com', 320.90, 7),
                       ('AX54069738', 'Amfiloxos', 'Stamatiou', 'stamatiouA@gmail.com', 1040.30 , 8),
                       ('LK20697203', 'Manolis', 'Papanastasopoulos', 'papamano@gmail.com', 1400.90, 5),
                       ('EH52630189', 'Ioanna', 'Salata', 'iosala@gmail.com', 1298.40 , 9),
                       ('XI53601203', 'Marios', 'Koukoutsis', 'koukouma@yahoo.com', 2450.30, 3),
                       ('ZG56310125', 'Nikos', 'Letonis', 'niklet@gmail.com', 390.40 , 4),
                       ('OL26397410', 'Irini', 'Mpoudou', 'irini65@gmail.com', 1280.70 , 6),
                       ('QV49630527', 'Iasonas', 'Sellos', 'sellos5@yahoo.com', 2300.70 , 9);



INSERT INTO admin VALUES
                      ('A052416398', 'LOGISTICS', 'Logistiki ASOE , Panepistimio Athinon'),
                      ('AB96857432', 'ADMINISTRATIVE', 'Dioikisi Epixoiriseon,Panepistimio Patron'),
                      ('AO47895612', 'LOGISTICS', 'Dioikitikis Epistimis kai Texnologias, Panepistimio Peiraia'),
                      ('EA12568974', 'ACCOUNTING' , 'Tmima Oikonomikwn , EKPA'),
                      ('AB36987412', 'ACCOUNTING', 'Logistiki kai Xrimatooikonomiki, Panepistimio Makedonias'),
                      ('XO78639541', 'ACCOUNTING', 'Logistiki ,Panepistimio Volou'),
                      ('AD58987496', 'LOGISTICS', 'Viomixaniki Anaptiji,Panepistimio Patron'),
                      ('AK12356987', 'ADMINISTRATIVE','NULL'),
                      ('XY96214756', 'LOGISTICS' , 'Tmima Oikonomikwn , ASOE'),
                      ('AP45879612', 'ADMINISTRATIVE', 'Dimosia Diikisi, Panepistimio Thesalonikis'),
                      ('AS10258746', 'ACCOUNTING', 'Oikonomikon Epistimon,Panepistimio Ioanninon'),
                      ('AF65478957', 'LOGISTICS', 'Naftiliaka,Panepistimio Athinon'),
                      ('XY32145698', 'ADMINISTRATIVE','NULL'),
                      ('AC89561056', 'LOGISTICS' , 'Tmima Oikonomikon , PAPEI'), -- Διορθώθηκε το Α
                      ('BW59634182', 'ADMINISTRATIVE', 'NULL');

UPDATE branch SET br_manager_AT = 'XO78639541' WHERE br_code = 1;
UPDATE branch SET br_manager_AT = 'AB96857432' WHERE br_code = 2;
UPDATE branch SET br_manager_AT = 'AO47895612' WHERE br_code = 3;
UPDATE branch SET br_manager_AT = 'A052416398' WHERE br_code = 4;
UPDATE branch SET br_manager_AT = 'XY32145698' WHERE br_code = 5;
UPDATE branch SET br_manager_AT = 'XY96214756' WHERE br_code = 6;
UPDATE branch SET br_manager_AT = 'AD58987496' WHERE br_code = 7;
UPDATE branch SET br_manager_AT = 'EA12568974' WHERE br_code = 8;
UPDATE branch SET br_manager_AT = 'AB36987412' WHERE br_code = 9;


INSERT INTO driver VALUES
                       ('AP10263987', 'A', 'ABROAD', 14),
                       ('EN89753032', 'B', 'ABROAD', 20),
                       ('AN06985312', 'C', 'LOCAL', 25),
                       ('VW49631567', 'D', 'LOCAL', 22),
                       ('AD72646159', 'A', 'ABROAD', 7),
                       ('BN02365489', 'C', 'LOCAL', 10),
                       ('XU45210397', 'D', 'LOCAL', 9),
                       ('AL03697412', 'A', 'ABROAD', 17),
                       ('MK03697416', 'B', 'LOCAL', 24),
                       ('KE02634586', 'D', 'ABROAD', 23),
                       ('NK02975458', 'A', 'ABROAD', 18),
                       ('BI54896012', 'D', 'LOCAL', DEFAULT);


INSERT INTO guide VALUES
                      ('AE59631056', 'Ksenagos me eidikeusi stin elliniki koultoura kai politismo.'),
                      ('NY59630214', 'Agapi gia tin Europaiki Koultoura. Pathos gia tin istoria kai tis topikes paradoseis.'),
                      ('JK26987103', 'Metaptuxiako se Panepistimio tis Ollandias kai polueth empeiria ston xwro.'),
                      ('AK56971230', 'Aptesti gnosi tis Ispanikis glossas. Pathos gia thn Ispaniki koultoura'),
                      ('AX54069738', 'Emfasi sto poto kai to fagito tis Iaponias.'),
                      ('LK20697203', 'Agapi gia tin Europaiki Koultoura. Pathos gia tin istoria kai tis topikes paradoseis.'),
                      ('EH52630189', 'Empiria 10 xronon sthn Latiniki Ameriki kai ton politismo tis.'),
                      ('XI53601203', 'Latris tis fisis kai ton topion tis'),
                      ('ZG56310125', 'Aristi gnosi se pezopories kai dianikterefsis sto bouno.'),
                      ('OL26397410', 'Agapi gia thalasia zoi kai ta magika topia tis.'),
                      ('QV49630527', 'Diamoni 32 xronia sthn gallia kai tin latrefti kouzina ths.'),
                      ('QO05697820', 'Kali gnosi Iaponikon kai gallikon.');



INSERT INTO phones VALUES
                       (1,'2107869453'),
                       (2,'2103621478'),
                       (3,'2610369845'),
                       (4,'2315621983'),
                       (5,'2310789579'),
                       (6,'2105428931'),
                       (7,'2109686451'),
                       (8,'2610897510'),
                       (9,'2710568916'),
                       (1,'2105897456'),
                       (6,'2109674102'),
                       (7,'2108963410'),
                       (2,'2105994523'),
                       (9,'2710696856'),
                       (1,'2105652548');

INSERT INTO manages VALUES
                        ('XO78639541',1),
                        ('AB96857432',2),
                        ('AO47895612',3),
                        ('A052416398',4),
                        ('XY32145698',5),
                        ('XY96214756',6),
                        ('AD58987496',7),
                        ('EA12568974',8),
                        ('AB36987412',9);


INSERT INTO languages VALUES
                          ('AE59631056','GR'),
                          ('NY59630214','DE'),
                          ('JK26987103','SP'),
                          ('AK56971230','SP'),
                          ('AX54069738','JP'),
                          ('LK20697203','FR'),
                          ('EH52630189','SP'),
                          ('XI53601203','RU'),
                          ('ZG56310125','IT'),
                          ('OL26397410','GR'),
                          ('QV49630527','FR'),
                          ('QO05697820','JP');


INSERT INTO destination VALUES
                            (NULL,'Argentini','Xora sti latiniki ameriki','ABROAD','SP',NULL),
                            (NULL,'Kerkyra', 'Nisi stin Ellada', 'LOCAL','GR',NULL),
                            (NULL,'Gallia','Xora kentrikis Europis','ABROAD','FR',NULL),
                            (NULL,'Ispania','Xwra tis Europis me mesogiako klima', 'ABROAD', 'SP',NULL),
                            (NULL,'Agglia', 'Boreia Europaiki xora', 'ABROAD', 'EN',NULL),
                            (NULL,'Buenos Aires','Protevousa tis Argentinis','ABROAD','SP',1),
                            (NULL,'Paris', 'Protevousa tis Gallias', 'ABROAD','FR',3),
                            (NULL,'Barkeloni','Parathalassia poli tis Ispanias','ABROAD','SP',4),
                            (NULL,'Londino','Protevousa tis Agglias', 'ABROAD', 'EN',5),
                            (NULL,'Iaponia', 'Xora tis Asias', 'ABROAD', 'JP',NULL),
                            (NULL,'Italia','Xora sth mesogeio thalassa','ABROAD','IT',NULL),
                            (NULL,'Rosia', 'H megaluteri xora tis Asias', 'ABROAD','RU',NULL),
                            (NULL,'Tokyo','Protevousa tis Iaponias','ABROAD','JP',10),
                            (NULL,'Napoli','Poli tis Italias', 'ABROAD', 'IT',11),
                            (NULL,'Mosxa', 'Protevousa tis Rosias', 'ABROAD', 'RU',12),
                            (NULL,'Germania', 'Xwra kentrikis Europis', 'ABROAD', 'DE',NULL),
                            (NULL,'Nyrembergi', 'Mageutiki poli ths Germanias', 'ABROAD', 'DE',16);

SELECT * FROM destination;

INSERT INTO trip VALUES
                     (NULL,'2026-05-01', '2026-05-07', 10, 1200.00, 450.00,'PLANNED', 5, 1, 'JK26987103','KE02634586'),
                     (NULL,'2026-08-24', '2026-08-27', 16, 500.00, 230.00, 'CONFIRMED',8, 4, 'ZG56310125','XU45210397'),
                     (NULL,'2026-01-13', '2026-01-17',15, 850.00, 300.00, 'CANCELLED',7, 3, 'QO05697820','BN02365489'),
                     (NULL,'2026-12-23', '2026-12-27',20, 1500.00, 800.00, 'ACTIVE', 10, 2, 'AE59631056', 'BI54896012'),
                     (NULL,'2026-03-17', '2026-03-20', 35, 400.00, 270.00, 'COMPLETED', 12, 6, 'NY59630214', 'AP10263987'),
                     (NULL,'2026-09-24','2026-09-28', 25, 760.00, 430.00, 'PLANNED', 15 , 7, 'AK56971230', 'AN06985312'),
                     (NULL,'2026-11-15','2026-11-20', 15, 1000.00, 850.00, 'CONFIRMED', 10, 8, 'AX54069738','MK03697416'),
                     (NULL,'2026-09-05', '2026-09-13', 5, 450.00, 300.00,'PLANNED', 3, 9, 'QV49630527','EN89753032'),
                     (NULL,'2026-01-04', '2026-01-18', 22, 1500.00, 1000.00, 'CONFIRMED',12, 5, 'LK20697203','AL03697412'),
                     (NULL,'2026-03-29', '2026-04-05',40, 600.00, 350.00, 'CANCELLED',7, 5, 'LK20697203','AL03697412'),
                     (NULL,'2026-12-06', '2026-12-12',35, 700.00, 550.00, 'ACTIVE', 10, 1, 'JK26987103', 'VW49631567'),
                     (NULL,'2026-05-24', '2026-05-30', 25, 400.00, 270.00, 'COMPLETED', 14, 4, 'ZG56310125', 'XU45210397'),
                     (NULL,'2026-10-19','2026-10-24', 30, 250.00, 170.00, 'PLANNED', 17 , 7, 'AK56971230', 'AD72646159'),
                     (NULL,'2026-04-05','2026-04-10', 20, 900.00, 750.00, 'CONFIRMED', 10, 8, 'AX54069738','MK03697416'),
                     (NULL,'2026-11-04', '2026-11-09', 10, 1300.00, 700.00,'PLANNED', 5, 2, 'AE59631056','BI54896012'),
                     (NULL,'2026-08-10', '2026-08-15', 20, 550.00, 260.00, 'CONFIRMED',10, 4, 'ZG56310125','XU45210397'),
                     (NULL,'2026-01-20', '2026-01-28',20, 1000.00, 550.00, 'CANCELLED',9, 7, 'AK56971230','AD72646159'),
                     (NULL,'2026-07-18', '2026-07-23',15, 1400.00, 800.00, 'ACTIVE', 8, 6, 'NY59630214', 'AP10263987'),
                     (NULL,'2026-06-15', '2026-06-20', 35, 150.00, 100.00, 'COMPLETED', 12, 8, 'AX54069738', 'MK03697416'),
                     (NULL,'2026-10-24','2026-10-28', 30, 780.00, 460.00, 'PLANNED', 15 , 3, 'XI53601203', 'BN02365489'),
                     (NULL,'2026-02-17','2026-02-22', 30, 1000.00, 750.00, 'CONFIRMED', 17, 5, 'LK20697203','AL03697412');

SELECT * FROM trip;
SELECT * FROM destination;

INSERT INTO travel_to VALUES
                          (1, 3, '2026-05-01 10:00:00','2026-05-07 08:00:00',1),
                          (3, 4, '2026-01-13 09:00:00','2026-01-17 14:00:00',2),
                          (2, 2, '2026-08-24 12:00:00','2026-08-27 09:00:00',1),
                          (7, 1, '2026-11-15 14:00:00','2026-11-20 12:00:00',1),
                          (4, 5, '2026-12-23 13:00:00','2026-12-27 18:00:00',1),
                          (5, 4, '2026-03-17 10:00:00','2026-03-20 11:30:00',1),
                          (6, 2, '2026-09-24 15:00:00','2026-09-28 16:30:00',1),
                          (8, 10, '2026-09-05 11:50:00','2026-09-13 02:10:00',1),
                          (9, 11, '2026-01-04 19:20:00','2026-01-18 01:20:00',2),
                          (10, 15, '2026-03-29 11:40:00','2026-04-05 02:55:00',1),
                          (11, 17, '2026-12-16 06:10:00','2026-12-12 19:40:00',1),
                          (12, 8, '2026-05-24 08:10:00','2026-05-30 20:10:00',1),
                          (13, 9, '2026-10-19 01:40:00','2026-10-24 22:50:00',1),
                          (14, 6, '2026-04-05 07:20:00','2026-04-10 15:40:00',1),
                          (15, 7, '2026-11-04 01:40:00','2026-04-10 22:10:00',1),
                          (16, 12, '2026-08-10 15:20:00','2026-08-15 21:20:00',2),
                          (17, 14, '2026-01-20 09:50:00','2026-01-28 23:55:00',1),
                          (18, 13, '2026-07-18 08:30:00','2026-07-23 18:40:00',1),
                          (19, 16, '2026-06-15 05:50:00','2026-06-20 15:30:00',1),
                          (20, 12, '2026-10-24 02:10:00','2026-10-28 21:20:00',1),
                          (21, 15, '2026-02-17 06:30:00','2026-02-22 17:10:00',1);

INSERT INTO event VALUES
                      (1, '2026-05-03 12:30:00', '2026-05-03 15:00:00','Bolta stin kentriki plateia tis polis kai stasi gia fagito'),
                      (1, '2026-05-05 10:15:00', '2026-05-05 11:30:00', 'Episkepsi stin ethiniki pinakothiki'),
                      (4, '2026-12-24 08:00:00', '2026-08-25 14:00:00', 'Ski'),
                      (4, '2026-12-25 14:30:00', '2026-12-25 16:30:00', 'Xristougenniatiko deipno se estiatorio sto vouno'),
                      (3, '2026-01-15 09:00:00', '2026-01-15 10:30:00','Ksenagisi sto mouseio polemou'),
                      (2, '2026-08-25 11:00:00', '2026-08-25 17:00:00', 'Oloimeri ekdromi me skafos'),
                      (2, '2026-08-26 21:00:00', '2026-08-27 02:00:00', 'Nyxterini eksodos se club'),
                      (3, '2026-01-16 18:00:00', '2026-01-16 20:00:00', 'Volta gia psonia sto kentro'),
                      (5, '2026-03-18 10:00:00', '2026-03-18 13:00:00', 'Pezoporia sto dasos'),
                      (6, '2026-09-25 12:00:00', '2026-09-25 15:00:00', 'Dokimi krasion se topiko oinopoieio'),
                      (6, '2026-09-27 09:00:00', '2026-09-27 14:00:00', 'Anavasi sto vouno'),
                      (7, '2026-11-17 09:00:00', '2026-11-17 17:00:00', 'Parakolouthisi synedriou texnologias'),
                      (7, '2026-11-19 20:00:00', '2026-11-19 23:00:00', 'Episimo deipno me synergates'),
                      (8, '2026-09-07 10:00:00', '2026-09-07 12:30:00', 'Ksenagisi stin palia poli'),
                      (8, '2026-09-10 18:00:00', '2026-09-10 21:00:00', 'Synavlia jazz mousikis'),
                      (9, '2026-01-08 14:00:00', '2026-01-08 16:00:00', 'Episkepsi se emporiko kentro'),
                      (9, '2026-01-12 11:00:00', '2026-01-12 13:00:00', 'Kafes sto limani'),
                      (10, '2026-03-30 09:30:00', '2026-03-30 14:30:00', 'Ekdromi stous katarraktes'),
                      (10, '2026-04-02 20:00:00', '2026-04-02 23:00:00', 'Theatriki parastasi'),
                      (11, '2026-12-08 10:00:00', '2026-12-08 15:00:00', 'Episkepsi se thematiko parko'),
                      (11, '2026-12-10 17:00:00', '2026-12-10 19:00:00', 'Xalarosi se Spa'),
                      (12, '2026-05-26 11:00:00', '2026-05-26 14:00:00', 'Mathimata katadysis (Scuba Diving)'),
                      (13, '2026-10-21 16:00:00', '2026-10-21 19:00:00', 'Fotografikos peripatos'),
                      (14, '2026-04-07 13:00:00', '2026-04-07 15:30:00', 'Gevma se estiatorio me thea'),
                      (15, '2026-11-06 09:00:00', '2026-11-06 12:00:00', 'Seminar business management'),
                      (16, '2026-08-12 12:00:00', '2026-08-12 18:00:00', 'Party stin pisina tou xenodoxeiou'),
                      (16, '2026-08-14 19:30:00', '2026-08-14 21:30:00', 'Iliovasilema sto kastro'),
                      (17, '2026-01-23 10:00:00', '2026-01-23 14:00:00', 'Ekserevnisi spilaion'),
                      (18, '2026-07-20 10:00:00', '2026-07-20 16:00:00', 'Diaskedasi se water park'),
                      (19, '2026-06-17 11:00:00', '2026-06-17 19:00:00', 'Monimeri krouaziera se kontino nisi'),
                      (20, '2026-10-28 11:00:00', '2026-10-28 13:00:00', 'Parakolouthisi parastasis mpaletou'),
                      (21, '2026-02-20 21:00:00', '2026-02-21 03:00:00', 'Apokriatiko party maske'),
                      (21, '2026-02-18 18:00:00', '2026-02-18 20:00:00', 'Volta stous dromous me ta armata');



INSERT INTO reservation VALUES
                            (1, 7, 1, 'PAID', 1200.00),
                            (2, 11, 2, 'CONFIRMED', 500.00),
                            (3, 3, 3, 'PENDING', 850.00),
                            (4, 17, 4, 'PAID', 1500.00),
                            (5, 30, 5, 'CONFIRMED', 400.00),
                            (6, 7, 6, 'PAID', 760.00),
                            (7, 12, 7, 'CANCELLED', 0.00),
                            (8, 3, 8, 'PAID', 450.00),
                            (9, 21, 9, 'PENDING', 1500.00),
                            (10, 37, 10, 'PAID', 600.00),
                            (11, 29, 11, 'CONFIRMED', 700.00),
                            (12, 2, 12, 'PENDING', 400.00),
                            (13, 16, 13, 'PAID', 250.00 ),
                            (14, 13, 14, 'CONFIRMED', 900.00),
                            (15, 1, 15, 'PENDING', 700.00),
                            (16, 17, 16, 'PAID', 550.00),
                            (17, 14, 17, 'CONFIRMED', 1000.00),
                            (18, 8, 18, 'PAID', 1400.00),
                            (19, 7, 19, 'CANCELLED', 150.00),
                            (20, 27, 20, 'PAID', 780.00),
                            (21, 6, 21, 'PENDING', 1000.00),
                            (17, 10, 22, 'PAID', 1000.00),
                            (19, 34, 23, 'CONFIRMED', 150.00),
                            (18, 4, 24, 'PENDING', 1400.00),
                            (12, 24, 25, 'PAID', 400.00),
                            (7, 8, 26, 'CONFIRMED', 1000.00),
                            (3, 9, 27, 'PENDING', 850.00),
                            (9, 20, 28, 'PAID', 1500.00),
                            (6, 21, 29, 'CONFIRMED', 760.00),
                            (11, 34, 30, 'PAID', 700.00),
                            (20, 4, 4, 'CANCELLED', 780.00),
                            (14, 11, 14, 'PAID', 900.00),
                            (7, 6, 21, 'PENDING', 1000.00),
                            (1, 8, 19, 'PAID', 1200.00),
                            (19, 30, 27, 'CONFIRMED', 150.00),
                            (2, 14, 29, 'PENDING', 500.00);


INSERT INTO accommodation  VALUES

(NULL, 'Le Grand Paris Hotel', 'HOTEL', 5, 4.80, 'AVAILABLE', NULL, 'Champs Elysees', 10, 'Paris', '75008', '331400011', 'contact@grandparis.fr', 50, 350.00, 1, 1, 1, 1, 7),
(NULL, 'Eiffel Tower View', 'APARTMENT', NULL, 4.50, 'AVAILABLE', NULL, 'Ave de la Bourdonnais', 5, 'Paris', '75007', '336123456', 'stay@eiffelview.com', 4, 200.00, 1, 0, 1, 0, 7),
(NULL, 'Backpackers Paris', 'HOSTEL', NULL, 3.20, 'AVAILABLE', NULL, 'Rue de Belleville', 25, 'Paris', '75019', '331500033', 'info@backpackers.fr', 20, 45.00, 1, 0, 0, 0, 7),
(NULL, 'Montmartre Secret', 'ROOMS_TO_RENT', NULL, 4.10, 'AVAILABLE', NULL, 'Rue Lepic', 12, 'Paris', '75018', '336987654', 'rooms@montmartre.fr', 6, 90.00, 1, 0, 0, 0, 7),
(NULL, 'Parisian Luxury Suites', 'HOTEL', 5, 4.95, 'AVAILABLE', NULL, 'Place Vendome', 1, 'Paris', '75001', '331888899', 'concierge@luxuryparis.com', 30, 600.00, 1, 1, 1, 1, 7),
(NULL, 'The Royal London', 'HOTEL', 5, 4.70, 'AVAILABLE', NULL, 'Park Lane', 44, 'London', 'W1K1AA', '4420711122', 'res@royal-london.co.uk', 120, 450.00, 1, 1, 1, 1, 9),
(NULL, 'Camden Hostel', 'HOSTEL', NULL, 3.80, 'AVAILABLE', NULL, 'Camden High St', 102, 'London', 'NW17JE', '4420733344', 'hi@camdenhostel.uk', 50, 40.00, 1, 1, 0, 0, 9),
(NULL, 'London Eye Rooms', 'ROOMS_TO_RENT', NULL, 3.50, 'AVAILABLE', NULL, 'Westminster Bridge Rd', 88, 'London', 'SE17PB', '4420756666', 'rent@londoneye.com', 8, 85.00, 1, 0, 1, 0, 9),
(NULL, 'Chelsea Apartments', 'APARTMENT', NULL, 4.30, 'AVAILABLE', NULL, 'Kings Road', 200, 'London', 'SW35XP', '4477778888', 'stay@chelsea.uk', 10, 180.00, 1, 0, 1, 1, 9),
(NULL, 'West End Hotel', 'HOTEL', 4, 4.20, 'AVAILABLE', NULL, 'Shaftesbury Ave', 55, 'London', 'W1D6EG', '4420799000', 'info@westendhotel.com', 80, 220.00, 1, 1, 1, 1, 9),
(NULL, 'Catalonia Plaza', 'HOTEL', 4, 4.40, 'AVAILABLE', NULL, 'Placa Espanya', 5, 'Barcelona', '08014', '349312367', 'plaza@catalonia.es', 100, 160.00, 1, 1, 1, 1, 8),
(NULL, 'Barceloneta Beach', 'APARTMENT', NULL, 4.60, 'AVAILABLE', NULL, 'Passeig Maritim', 32, 'Barcelona', '08003', '349876543', 'beach@bcn.es', 15, 140.00, 1, 0, 1, 0, 8),
(NULL, 'Sagrada Familia Hostel', 'HOSTEL', NULL, 3.90, 'AVAILABLE', NULL, 'Carrer de Mallorca', 401, 'Barcelona', '08013', '349551212', 'info@sagrada.es', 40, 35.00, 1, 0, 1, 0, 8),
(NULL, 'Ramblas Hotel', 'HOTEL', 3, 3.70, 'AVAILABLE', NULL, 'La Rambla', 90, 'Barcelona', '08002', '349367788', 'contact@ramblashotel.com', 60, 110.00, 1, 1, 1, 0, 8),
(NULL, 'Sakura Hotel', 'HOTEL', 3, 4.10, 'AVAILABLE', NULL, 'Shinjuku', 1, 'Tokyo', '160002', '813123478', 'info@sakura.jp', 150, 110.00, 1, 1, 1, 1, 13),
(NULL, 'Tokyo Tower Resort', 'RESORT', 5, 4.90, 'AVAILABLE', NULL, 'Minato City', 4, 'Tokyo', '105001', '813987432', 'resort@tokyotower.jp', 200, 500.00, 1, 1, 1, 1, 13),
(NULL, 'Shibuya Capsule Inn', 'HOSTEL', NULL, 4.00, 'AVAILABLE', NULL, 'Dogenzaka', 2, 'Tokyo', '150004', '813555444', 'capsule@shibuya.jp', 300, 30.00, 1, 0, 1, 0, 13),
(NULL, 'Asakusa Ryokan', 'ROOMS_TO_RENT', NULL, 4.80, 'AVAILABLE', NULL, 'Kaminarimon', 2, 'Tokyo', '111003', '813222111', 'stay@ryokan.jp', 12, 150.00, 1, 0, 1, 0, 13),
(NULL, 'Vesuvius Resort', 'RESORT', 5, 4.85, 'AVAILABLE', NULL, 'Via Partenope', 40, 'Napoli', '80121', '390812567', 'relax@vesuvius.it', 30, 400.00, 1, 1, 1, 0, 14),
(NULL, 'Pizza & Bed', 'ROOMS_TO_RENT', NULL, 4.20, 'AVAILABLE', NULL, 'Via dei Tribunali', 32, 'Napoli', '80138', '3909998888', 'pizza@napoli.it', 5, 70.00, 1, 0, 1, 0, 14),
(NULL, 'Napoli Central Hotel', 'HOTEL', 3, 3.50, 'AVAILABLE', NULL, 'Piazza Garibaldi', 10, 'Napoli', '80142', '3908776666', 'central@napoli.it', 45, 90.00, 1, 1, 1, 1, 14),
(NULL, 'Corfu Palace', 'RESORT', 5, 4.70, 'AVAILABLE', NULL, 'Leoforos Dimokratias', 2, 'Corfu', '49100', '3026611111', 'info@corfupalace.gr', 100, 250.00, 1, 1, 1, 1, 2),
(NULL, 'Sidari Rooms', 'ROOMS_TO_RENT', NULL, 3.90, 'AVAILABLE', NULL, 'Sidari Main Rd', 15, 'Corfu', '49081', '3026630222', 'rooms@sidari.gr', 10, 60.00, 0, 0, 1, 0, 2),
(NULL, 'Kavos Party Hostel', 'HOSTEL', NULL, 3.00, 'AVAILABLE', NULL, 'Kavos Strip', 1, 'Corfu', '49080', '3026620333', 'party@kavos.gr', 80, 25.00, 1, 1, 0, 0, 2),
(NULL, 'Tango Hotel', 'HOTEL', 4, 4.50, 'AVAILABLE', NULL, 'Av. 9 de Julio', 100, 'Buenos Aires', 'C1043', '5411445555', 'tango@ba.ar', 70, 130.00, 1, 1, 1, 1, 6),
(NULL, 'Palermo Soho Apts', 'APARTMENT', NULL, 4.60, 'AVAILABLE', NULL, 'Honduras', 4500, 'Buenos Aires', 'C1414', '5416667777', 'soho@ba.ar', 15, 95.00, 1, 0, 1, 0, 6),
(NULL, 'Red Square Hotel', 'HOTEL', 5, 4.80, 'AVAILABLE', NULL, 'Tverskaya St', 3, 'Moscow', '125009', '749512233', 'info@redsquare.ru', 200, 300.00, 1, 1, 1, 1, 15),
(NULL, 'Moscow City Hostel', 'HOSTEL', NULL, 3.60, 'AVAILABLE', NULL, 'Arbat St', 20, 'Moscow', '119002', '749922244', 'hostel@moscow.ru', 60, 30.00, 1, 0, 1, 0, 15),
(NULL, 'Kaiserburg Hotel', 'HOTEL', 4, 4.30, 'AVAILABLE', NULL, 'Burgstrasse', 10, 'Nuremberg', '90403', '499113456', 'hotel@kaiserburg.de', 55, 140.00, 1, 1, 1, 0, 17),
(NULL, 'Old Town Apartments', 'APARTMENT', NULL, 4.10, 'AVAILABLE', NULL, 'Konigstrasse', 5, 'Nuremberg', '90402', '499119654', 'apts@nuremberg.de', 8, 110.00, 1, 0, 1, 0, 17),
(NULL, 'Old Paris Inn', 'HOTEL', 2, 2.50, 'UNAVAILABLE', 'RENOVATION', 'Rue Saint-Denis', 88, 'Paris', '75002', '33144556677', 'old@paris.fr', 10, 80.00, 0, 0, 0, 0, 7),
(NULL, 'Closed London B&B', 'ROOMS_TO_RENT', NULL, 2.00, 'UNAVAILABLE', 'CLOSE', 'Baker St', 221, 'London', 'NW16XE', '442070000000', 'closed@london.uk', 4, 50.00, 0, 0, 0, 0, 9),
(NULL, 'Bankrupt Resort', 'RESORT', 3, 1.50, 'UNAVAILABLE', 'OTHER REASON', 'Unknown Beach', 0, 'Corfu', '49000', '3026000000', 'bankrupt@corfu.gr', 100, 50.00, 0, 1, 0, 0, 2);



INSERT INTO trip_accommodation VALUES

(1, 1, '2026-05-01', '2026-05-07', 5),
(2, 22, '2026-08-24', '2026-08-27', 8),
(3, 11, '2026-01-13', '2026-01-17', 6),
(4, 6, '2026-12-23', '2026-12-27', 10),
(5, 13, '2026-03-17', '2026-03-20', 15),
(6, 23, '2026-09-24', '2026-09-28', 12),
(7, 25, '2026-11-15', '2026-11-20', 5),
(8, 15, '2026-09-05', '2026-09-13', 2),
(9, 19, '2026-01-04', '2026-01-18', 10),
(10, 27, '2026-03-29', '2026-04-05', 20),
(11, 29, '2026-12-06', '2026-12-12', 15),
(12, 12, '2026-05-24', '2026-05-30', 10),
(13, 10, '2026-10-19', '2026-10-24', 8),
(14, 26, '2026-04-05', '2026-04-10', 8),
(15, 5, '2026-11-04', '2026-11-09', 2),
(16, 28, '2026-08-10', '2026-08-15', 10),
(17, 21, '2026-01-20', '2026-01-28', 9),
(18, 16, '2026-07-18', '2026-07-23', 4),
(19, 30, '2026-06-15', '2026-06-20', 12),
(20, 27, '2026-10-24', '2026-10-28', 15),
(21, 30, '2026-02-17', '2026-02-22', 10),
(1, 2, '2026-05-05', '2026-05-07', 4),
(4, 7, '2026-12-23', '2026-12-27', 8),
(9, 8, '2026-01-10', '2026-01-15', 5),
(13, 9, '2026-10-19', '2026-10-24', 6),
(8, 17, '2026-09-05', '2026-09-10', 10),
(12, 14, '2026-05-24', '2026-05-30', 8),
(2, 24, '2026-08-24', '2026-08-27', 15),
(5, 12, '2026-03-17', '2026-03-20', 10),
(18, 18, '2026-07-18', '2026-07-23', 6),
(9, 20, '2026-01-05', '2026-01-10', 4),
(10, 28, '2026-03-29', '2026-04-02', 12),
(21, 29, '2026-02-20', '2026-02-22', 10);




INSERT INTO database_admin VALUES
                               ('A052416398' , '2017-01-25', NULL),
                               ('AB96857432' , '2017-05-01', '2024-09-20'),
                               ('AO47895612' , '2016-02-15', NULL),
                               ('EA12568974' ,'2018-09-01' , NULL),
                               ('AB36987412' , '2018-06-23', '2025-11-03'),
                               ('XO78639541' , '2020-04-20', NULL);



ALTER TABLE trip
    ADD tr_veh_id INT(11),
    ADD CONSTRAINT cnstr_trip_veh
        FOREIGN KEY (tr_veh_id) REFERENCES vehicle (veh_id)
            ON DELETE CASCADE ON UPDATE CASCADE;

INSERT INTO vehicle (veh_id, veh_brand, veh_model, veh_traffic_number, veh_type, veh_status, veh_capacity,
                     veh_kilometers, veh_br_code)
VALUES
-- Branch 1
(NULL, 'Mercedes', 'Benz', 'AO3X48', 'CAR', 'AVAILABLE', 4, 13000, 1),
(NULL, 'VW', 'Transporter', 'VW1A11', 'VAN', 'AVAILABLE', 8, 45000, 1),
(NULL, 'Mercedes', 'Sprinter', 'MS1B12', 'MINI BUS', 'AVAILABLE', 15, 85000, 1),
(NULL, 'Setra', 'S515', 'ST1C13', 'BUS', 'AVAILABLE', 52, 120000, 1),

-- Branch 2
(NULL, 'Toyota', 'Corolla', 'BK2Y59', 'CAR', 'AVAILABLE', 5, 25000, 2),
(NULL, 'Ford', 'Transit', 'FT2D21', 'VAN', 'AVAILABLE', 9, 32000, 2),
(NULL, 'Iveco', 'Daily', 'ID2E22', 'MINI BUS', 'AVAILABLE', 12, 60000, 2),
(NULL, 'Man', 'Lion Coach', 'MN2F23', 'BUS', 'AVAILABLE', 49, 150000, 2),

-- Branch 3
(NULL, 'Skoda', 'Octavia', 'SO3G31', 'CAR', 'AVAILABLE', 5, 20000, 3),
(NULL, 'Fiat', 'Ducato', 'FD3H32', 'VAN', 'AVAILABLE', 7, 28000, 3),
(NULL, 'Renault', 'Master', 'RM3I33', 'MINI BUS', 'AVAILABLE', 14, 45000, 3),
(NULL, 'Volvo', '9700', 'VL3J34', 'BUS', 'AVAILABLE', 55, 95000, 3),

-- Branch 4
(NULL, 'Hyundai', 'i30', 'HI4K41', 'CAR', 'AVAILABLE', 5, 18000, 4),
(NULL, 'Opel', 'Vivaro', 'OV4L42', 'VAN', 'AVAILABLE', 9, 55000, 4),
(NULL, 'Nissan', 'NV300', 'NN4M43', 'MINI BUS', 'AVAILABLE', 18, 75000, 4),
(NULL, 'Neoplan', 'Skyliner', 'NP4N44', 'BUS', 'AVAILABLE', 75, 200000, 4),

-- Branch 5
(NULL, 'Peugeot', '5008', 'PZ5O51', 'CAR', 'AVAILABLE', 5, 30000, 5),
(NULL, 'Citroen', 'Jumpy', 'CJ5P52', 'VAN', 'AVAILABLE', 8, 42000, 5),
(NULL, 'Mercedes', 'Sprinter', 'MS5Q53', 'MINI BUS', 'AVAILABLE', 19, 88000, 5),
(NULL, 'Iveco', 'Magelys', 'IM5R54', 'BUS', 'AVAILABLE', 48, 135000, 5),

-- Branch 6
(NULL, 'BMW', 'X3', 'BX6S61', 'CAR', 'AVAILABLE', 5, 27000, 6),
(NULL, 'Ford', 'Transit', 'FT6T62', 'VAN', 'AVAILABLE', 9, 51000, 6),
(NULL, 'Toyota', 'Hiace', 'TH6U63', 'MINI BUS', 'AVAILABLE', 12, 65000, 6),
(NULL, 'Man', 'Lion Coach', 'MN6V64', 'BUS', 'AVAILABLE', 50, 110000, 6),

-- Branch 7
(NULL, 'Audi', 'A4', 'AA7W71', 'CAR', 'AVAILABLE', 5, 45000, 7),
(NULL, 'Renault', 'Traffic', 'RT7X72', 'VAN', 'AVAILABLE', 8, 35000, 7),
(NULL, 'Peugeot', 'Expert', 'PE7Y73', 'MINI BUS', 'AVAILABLE', 14, 45000, 7),
(NULL, 'Setra', 'S415', 'ST7Z74', 'BUS', 'AVAILABLE', 55, 180000, 7),

-- Branch 8
(NULL, 'Nissan', 'Micra', 'NM8A81', 'CAR', 'AVAILABLE', 5, 15000, 8),
(NULL, 'Fiat', 'Talento', 'FT8B82', 'VAN', 'AVAILABLE', 9, 50000, 8),
(NULL, 'VW', 'Crafter', 'VW8C83', 'MINI BUS', 'AVAILABLE', 16, 70000, 8),
(NULL, 'Volvo', '9900', 'VL8D84', 'BUS', 'AVAILABLE', 50, 110000, 8),

-- Branch 9
(NULL, 'Toyota', 'Yaris', 'TY9E91', 'CAR', 'AVAILABLE', 5, 12000, 9),
(NULL, 'Opel', 'Movano', 'OM9F92', 'VAN', 'AVAILABLE', 9, 62000, 9),
(NULL, 'Mercedes', 'Vito', 'MV9G93', 'MINI BUS', 'AVAILABLE', 13, 55000, 9),
(NULL, 'Irizar', 'i8', 'IZ9H94', 'BUS', 'AVAILABLE', 60, 145000, 9);



