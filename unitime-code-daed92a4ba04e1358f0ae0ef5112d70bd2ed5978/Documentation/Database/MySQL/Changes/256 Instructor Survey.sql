/*
 * Licensed to The Apereo Foundation under one or more contributor license
 * agreements. See the NOTICE file distributed with this work for
 * additional information regarding copyright ownership.
 *
 * The Apereo Foundation licenses this file to you under the Apache License,
 * Version 2.0 (the "License"); you may not use this file except in
 * compliance with the License. You may obtain a copy of the License at:
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * 
*/


/* Instructor Survey Course Request Note Types */
create table instr_crsreq_note_type (
  uniqueid decimal(20,0) primary key not null,
  reference varchar(20) not null,
  label varchar(60) not null,
  length bigint(10) not null,
  sort_order bigint(10) not null
) engine = INNODB;

insert into rights (role_id, value)
  select distinct r.role_id, 'InstructorSurveyNoteTypes'
  from roles r, rights g where g.role_id = r.role_id and g.value = 'Majors';
insert into rights (role_id, value)
  select distinct r.role_id, 'InstructorSurveyNoteTypeEdit'
  from roles r, rights g where g.role_id = r.role_id and g.value = 'MajorEdit';
insert into rights (role_id, value)
  select distinct r.role_id, 'InstructorSurvey'
  from roles r, rights g where g.role_id = r.role_id and g.value = 'InstructorPreferences';
insert into rights (role_id, value)
  select distinct r.role_id, 'InstructorSurveyAdmin'
  from roles r, rights g where g.role_id = r.role_id and g.value = 'InstructorAdd';

select 32767 * next_hi into @id from hibernate_unique_key;
insert into instr_crsreq_note_type
  (uniqueid, reference, label, length, sort_order) values
  (@id+0, 'Section(s)', 'Section Identification', 8, 0),
  (@id+1, 'Notes', 'Instructor Requirements', 82, 1);
update hibernate_unique_key set next_hi=next_hi+1;

/* Preference notes */
alter table room_pref add note varchar(2048);
alter table room_feature_pref add note varchar(2048);
alter table building_pref add note varchar(2048);
alter table time_pref add note varchar(2048);
alter table date_pattern_pref add note varchar(2048);
alter table distribution_pref add note varchar(2048);
alter table room_group_pref add note varchar(2048);
alter table exam_period_pref add note varchar(2048);
alter table attribute_pref add note varchar(2048);
alter table course_pref add note varchar(2048);
alter table instructor_pref add note varchar(2048);

/* Instructor Survey */
create table instructor_survey (
  uniqueid decimal(20,0) primary key not null,
  session_id decimal(20,0) not null,
  external_uid varchar(40) not null,
  email varchar(200),
  note varchar(2048),
  submitted datetime
) engine = INNODB;
alter table instructor_survey add constraint fk_instr_surv_session foreign key (session_id)
  references sessions (uniqueid) on delete cascade;

/* Instructor Survey Course Requirements */
create table instr_crsreq (
  uniqueid decimal(20,0) primary key not null,
  survey_id decimal(20,0) not null,
  course varchar(1024),
  course_offering_id decimal(20,0)
) engine = INNODB;
alter table instr_crsreq add constraint fk_instr_crsreq_survey foreign key (survey_id)
  references instructor_survey (uniqueid) on delete cascade;
alter table instr_crsreq add constraint fk_instr_crsreq_course foreign key (course_offering_id)
  references course_offering (uniqueid) on delete set null;

/* Instructor Survey Course Requirement Notes */
create table instr_crsreq_note (
  requirement_id decimal(20,0) not null,
  type_id decimal(20,0) not null,
  note varchar(2048),
  primary key(requirement_id, type_id)
) engine = INNODB;
alter table instr_crsreq_note add constraint fk_instr_crsreq_note_req foreign key (requirement_id)
  references instr_crsreq (uniqueid) on delete cascade;
alter table instr_crsreq_note add constraint fk_instr_crsreq_note_type foreign key (type_id)
  references instr_crsreq_note_type (uniqueid) on delete cascade;
  
/*
 * Update database version
 */
  
update application_config set value='256' where name='tmtbl.db.version';

commit;
