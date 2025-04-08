-- init_01_users.sql
-- Suppression des objets existants et création des utilisateurs/schémas

-- Se connecter en tant qu'admin système
CONNECT system/Luqman123

-- Supprimer les utilisateurs/schémas existants
BEGIN
   EXECUTE IMMEDIATE 'DROP USER c##glpi_central CASCADE';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -1918 THEN
         RAISE;
      END IF;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP USER c##glpi_cergy CASCADE';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -1918 THEN
         RAISE;
      END IF;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP USER c##glpi_pau CASCADE';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -1918 THEN
         RAISE;
      END IF;
END;
/

-- Supprimer les rôles existants
BEGIN
   EXECUTE IMMEDIATE 'DROP ROLE c##glpi_admin_role';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -1919 THEN
         RAISE;
      END IF;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP ROLE c##glpi_technicien_role';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -1919 THEN
         RAISE;
      END IF;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP ROLE c##glpi_enseignant_role';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -1919 THEN
         RAISE;
      END IF;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP ROLE c##glpi_etudiant_role';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -1919 THEN
         RAISE;
      END IF;
END;
/

-- Création des utilisateurs/schémas pour représenter les différents sites
CREATE USER c##glpi_central IDENTIFIED BY glpi_central;
CREATE USER c##glpi_cergy IDENTIFIED BY glpi_cergy;
CREATE USER c##glpi_pau IDENTIFIED BY glpi_pau;

-- Accorder les privilèges nécessaires
GRANT CONNECT, RESOURCE TO c##glpi_central;
GRANT CREATE VIEW, CREATE MATERIALIZED VIEW TO c##glpi_central;
GRANT CREATE TRIGGER, CREATE SEQUENCE, CREATE SYNONYM TO c##glpi_central;
GRANT UNLIMITED TABLESPACE TO c##glpi_central;
GRANT CREATE SESSION TO c##glpi_central;
GRANT CONNECT, RESOURCE TO c##glpi_cergy;
GRANT CREATE VIEW, CREATE MATERIALIZED VIEW TO c##glpi_cergy;
GRANT CREATE TRIGGER, CREATE SEQUENCE, CREATE SYNONYM TO c##glpi_cergy;
GRANT UNLIMITED TABLESPACE TO c##glpi_cergy;
GRANT CREATE SESSION TO c##glpi_cergy;

GRANT CONNECT, RESOURCE TO c##glpi_pau;
GRANT CREATE VIEW, CREATE MATERIALIZED VIEW TO c##glpi_pau;
GRANT CREATE TRIGGER, CREATE SEQUENCE, CREATE SYNONYM TO c##glpi_pau;
GRANT UNLIMITED TABLESPACE TO c##glpi_pau;
GRANT CREATE SESSION TO c##glpi_pau;

-- Création des rôles
CREATE ROLE c##glpi_admin_role;
CREATE ROLE c##glpi_technicien_role;
CREATE ROLE c##glpi_enseignant_role;
CREATE ROLE c##glpi_etudiant_role;


-- Grant system privileges

GRANT DBA TO c##glpi_central;
GRANT CREATE USER, ALTER USER, DROP USER TO c##glpi_central;
GRANT GRANT ANY ROLE TO c##glpi_central;
GRANT CREATE SESSION TO c##glpi_central;
GRANT CREATE ANY SEQUENCE TO c##glpi_central;
GRANT SELECT ANY SEQUENCE TO c##glpi_central;

-- Grant system privileges
GRANT CREATE USER, ALTER USER, DROP USER TO c##glpi_central;
GRANT CREATE SESSION TO c##glpi_cergy;
GRANT CREATE ANY SEQUENCE TO c##glpi_cergy;
GRANT SELECT ANY SEQUENCE TO c##glpi_cergy;

-- Grant system privileges
GRANT CREATE USER, ALTER USER, DROP USER TO c##glpi_central;
GRANT CREATE SESSION TO c##glpi_pau;
GRANT CREATE ANY SEQUENCE TO c##glpi_pau;
GRANT SELECT ANY SEQUENCE TO c##glpi_pau;
