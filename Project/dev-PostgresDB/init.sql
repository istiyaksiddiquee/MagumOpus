CREATE USER magnumopus WITH PASSWORD '123456';
CREATE DATABASE magnum_rdbms;
CREATE DATABASE notice;
GRANT ALL PRIVILEGES ON DATABASE magnum_rdbms TO magnumopus;
GRANT ALL PRIVILEGES ON DATABASE notice TO magnumopus;

\c magnum_rdbms;

CREATE SEQUENCE serial START 1;
ALTER TABLE serial OWNER TO magnumopus;

CREATE TABLE IF NOT EXISTS t_audit (
	audit_id INT NOT NULL PRIMARY KEY DEFAULT nextval('serial'), 	
	created_on TIMESTAMP DEFAULT NOW(), 
	user_id INT NOT NULL, 
	affected_table VARCHAR,
	performed_operation VARCHAR,
	audit_msg VARCHAR
);
ALTER TABLE t_audit OWNER TO magnumopus;

CREATE TABLE IF NOT EXISTS t_faculty (
	faculty_id INT NOT NULL PRIMARY KEY DEFAULT nextval('serial'),
	audit_id INT, 
	name VARCHAR, 
	address VARCHAR,
	CONSTRAINT fk_faculty_audit FOREIGN KEY(audit_id) REFERENCES t_audit(audit_id) 	
);
ALTER TABLE t_faculty OWNER TO magnumopus;

CREATE TABLE IF NOT EXISTS t_department (
	department_id INT NOT NULL PRIMARY KEY DEFAULT nextval('serial'),
	audit_id INT, 
	name VARCHAR, 
	address VARCHAR, 
	faculty_id INT NOT NULL, 
	CONSTRAINT fk_dept_faculty FOREIGN KEY(faculty_id) REFERENCES t_faculty(faculty_id) 
	ON UPDATE CASCADE ON DELETE CASCADE,
	CONSTRAINT fk_department_audit FOREIGN KEY(audit_id) REFERENCES t_audit(audit_id)
);
ALTER TABLE t_department OWNER TO magnumopus;

CREATE TABLE IF NOT EXISTS t_course (
	course_id INT NOT NULL PRIMARY KEY DEFAULT nextval('serial'),
	audit_id INT, 
	title VARCHAR, 
	credit_points FLOAT(8),
	address VARCHAR, 
	department_id INT NOT NULL, 
	CONSTRAINT fk_course_dept FOREIGN KEY(department_id) REFERENCES t_department(department_id)
	ON UPDATE CASCADE ON DELETE CASCADE,
	CONSTRAINT fk_course_audit FOREIGN KEY(audit_id) REFERENCES t_audit(audit_id)
);
ALTER TABLE t_course OWNER TO magnumopus;

CREATE TABLE IF NOT EXISTS t_user (
	user_id INT NOT NULL PRIMARY KEY DEFAULT nextval('serial'),
	audit_id INT, 
	first_name VARCHAR, 
	last_name VARCHAR, 
	user_name VARCHAR NOT NULL UNIQUE, 
	email_id VARCHAR NOT NULL UNIQUE,
	password VARCHAR NOT NULL,
	address VARCHAR,
	CONSTRAINT fk_user_audit FOREIGN KEY(audit_id) REFERENCES t_audit(audit_id) 	
);
ALTER TABLE t_user OWNER TO magnumopus;

CREATE TABLE IF NOT EXISTS t_role_permission (
	role_permission_id INT NOT NULL PRIMARY KEY DEFAULT nextval('serial'),
	audit_id INT, 
	role_name VARCHAR NOT NULL, 
	privilege json NOT NULL,
	CONSTRAINT fk_role_audit FOREIGN KEY(audit_id) REFERENCES t_audit(audit_id)
);
ALTER TABLE t_role_permission OWNER TO magnumopus;

CREATE TABLE IF NOT EXISTS t_acl_rule (
	acl_rule_id INT NOT NULL PRIMARY KEY DEFAULT nextval('serial'),
	audit_id INT, 
	user_id INT NOT NULL,
	role_permission_id INT NOT NULL, 
	included json, 
	excluded json,
	
	CONSTRAINT fk_acl_user FOREIGN KEY(user_id) REFERENCES t_user(user_id)
	ON UPDATE CASCADE ON DELETE CASCADE,	
	CONSTRAINT fk_acl_role FOREIGN KEY(role_permission_id) REFERENCES t_role_permission(role_permission_id)
	ON UPDATE CASCADE ON DELETE CASCADE,
	CONSTRAINT fk_acl_audit FOREIGN KEY(audit_id) REFERENCES t_audit(audit_id) 	
);
ALTER TABLE t_acl_rule OWNER TO magnumopus;

CREATE TABLE IF NOT EXISTS t_group (
	group_id INT NOT NULL PRIMARY KEY DEFAULT nextval('serial'),
	audit_id INT, 
	group_name VARCHAR,		
	CONSTRAINT fk_group_audit FOREIGN KEY(audit_id) REFERENCES t_audit(audit_id)
);
ALTER TABLE t_group OWNER TO magnumopus;

CREATE TABLE IF NOT EXISTS t_group_user_mapping (
	group_user_mapping_id INT NOT NULL PRIMARY KEY DEFAULT nextval('serial'),
	audit_id INT, 
	user_id INT NOT NULL, 
	group_id INT NOT NULL, 
	
	CONSTRAINT fk_mapping_user FOREIGN KEY(user_id) REFERENCES t_user(user_id)
	ON UPDATE CASCADE ON DELETE CASCADE,	
	CONSTRAINT fk_mapping_group FOREIGN KEY(group_id) REFERENCES t_group(group_id)
	ON UPDATE CASCADE ON DELETE CASCADE,
	CONSTRAINT fk_mapping_audit FOREIGN KEY(audit_id) REFERENCES t_audit(audit_id)
);
ALTER TABLE t_group_user_mapping OWNER TO magnumopus;


INSERT INTO t_audit(user_id, affected_table, performed_operation, audit_msg) 
VALUES(1, 't_user', 'CREATE', 'Super user created');

INSERT INTO t_user(audit_id, first_name, last_name, user_name, email_id, password, address) 
VALUES(1, 'Istiyak', 'Siddiquee', 'istiyaksiddiquee', 'siddiquee@google.com', '123456', 'dummy address');

\c notice;

CREATE SEQUENCE notice_serial START 1;
ALTER TABLE notice_serial OWNER TO magnumopus;

CREATE TABLE IF NOT EXISTS t_notification (
	notification_id INT NOT NULL PRIMARY KEY DEFAULT nextval('notice_serial'),
	created_on TIMESTAMP DEFAULT NOW(), 	
	notification_details VARCHAR
);
ALTER TABLE t_notification OWNER TO magnumopus;

CREATE TABLE IF NOT EXISTS t_message (
	message_id INT NOT NULL PRIMARY KEY DEFAULT nextval('notice_serial'),
	created_on TIMESTAMP DEFAULT NOW(), 	
	message_details VARCHAR
);
ALTER TABLE t_message OWNER TO magnumopus;