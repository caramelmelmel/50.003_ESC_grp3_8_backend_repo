DROP TABLE IF EXISTS singhealth_institutions CASCADE;
DROP TABLE IF EXISTS category CASCADE;
DROP TABLE IF EXISTS new_audit CASCADE;
DROP TABLE IF EXISTS staff cascade; 
DROP TABLE IF EXISTS checklist cascade;
DROP TABLE IF EXISTS audit_in_progress cascade;
DROP TABLE IF EXISTS tenant cascade;
DROP TABLE IF EXISTS past_audits cascade;
DROP TABLE IF EXISTS resolved_audits cascade;
DROP TABLE IF EXISTS images cascade;
DROP TABLE IF EXISTS update_compliance cascade;
DROP TABLE IF EXISTS institute_monthly cascade;
DROP TABLE IF EXISTS resolve_compliance;

CREATE TABLE singhealth_institutions(
    institution_id serial PRIMARY KEY, 
    institution_name VARCHAR(50) UNIQUE NOT NULL
);

-- FB and non_fb for tenant checklist
CREATE TABLE category(
    category_ID serial PRIMARY KEY,
    category_name VARCHAR(50) UNIQUE NOT NULL
);

--group the following into categories for the respective checklist FB and non fb
CREATE TABLE checklistfb(
    fb_id serial PRIMARY KEY,
    category_ID integer references category,
    fb_cat_name varchar(255) 
);
create table checklistnonfb(
    nonfb_id serial PRIMARY KEY,
    category_ID integer references category,
    nonfb_cat_name varchar(255)
);

CREATE TABLE staff(
    staff_id serial PRIMARY KEY,
    staff_name VARCHAR (50) NOT NULL,
    email VARCHAR (255) UNIQUE NOT NULL,
    institution_id integer not null,
   CONSTRAINT fk_Institution
      FOREIGN KEY(institution_id)
          REFERENCES singhealth_institutions(institution_id)
          ON DELETE CASCADE
);

-- On registration
CREATE TABLE tenant(
    tenant_id serial PRIMARY KEY, 
    tenant_name varchar(50),
    category_ID integer,
    store_des VARCHAR(250),
    email TEXT UNIQUE NOT NULL,
    store_id integer,
    CONSTRAINT fk_cat
    FOREIGN KEY(category_ID)
        REFERENCES category(category_ID)
        ON DELETE CASCADE
    , 
    expiry_date date
);


CREATE TABLE new_audit(
    resolve_status boolean,
    Audit_ID serial PRIMARY KEY,
    aud_score integer,
    date_record date, 
    inst_id integer,
    category_ID integer,
    CONSTRAINT fk_cat
    FOREIGN KEY(category_ID)
        REFERENCES category(category_ID)
        ON DELETE CASCADE
);

-- contains each and every checklist id that is passed here
--front end to call this checklist
CREATE TABLE checklist(
    checklist_id serial primary key,
    category_ID integer,
    check_name varchar,
    CONSTRAINT fk_category_id
    FOREIGN KEY (category_ID)
        REFERENCES category(category_ID)
        ON DELETE CASCADE
);

CREATE TABLE audit_in_progress(
     audit_date date,
     aud_score integer,
     noncompliances json not null,
     category_ID integer references category
     ON DELETE CASCADE,
     audit_id integer references new_audit
     ON DELETE CASCADE,
     tenant_id integer references tenant
     ON DELETE CASCADE
);

CREATE TABLE past_audits(
    audit_id integer references new_audit
    ON DELETE CASCADE,
    aud_score integer,
    tenant_id integer references tenant
    ON DELETE CASCADE,
    audit_date date,
    updates json not null               
);

--storage of the image in the blob format
--resolving of the images
CREATE TABLE images(
    img_id serial primary key,
    imgname text, 
    imgoid oid
);

--for tenants to resolve
CREATE TABLE update_compliance(
    checklist_id integer references checklist,
    dateline date,
    img_id integer references images,
    resolve_status boolean
);

CREATE TABLE resolved_audits(
    audit_id integer references new_audit,
    resolve_status boolean CHECK (resolve_status = true)
);

CREATE TABLE institute_monthly(
    aud_month varchar,
    inst_id integer references singhealth_institutions,
    avg_score integer
);

--for staff to resolve the compliance for the tenant
CREATE TABLE resolve_compliance(
    aud_id integer references singhealth_institutions,
    checklist_id integer references checklist,
    resolve_status boolean
);

--INSERT commands for the hardcoded ones
INSERT INTO category(category_name) values('FB'),('Non_FB');

--INSERT INTO checklist(category_ID,check_name) values
--()