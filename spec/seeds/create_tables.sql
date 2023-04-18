DROP TABLE IF EXISTS "public"."users", "public"."spaces", "public"."bookings", "public"."requests";

CREATE TABLE users (
	id SERIAL PRIMARY KEY,
	name text NOT NULL,
	username text NOT NULL UNIQUE,
	email text NOT NULL UNIQUE,
	password text NOT NULL
);

CREATE TABLE spaces (
	id SERIAL PRIMARY KEY,
	name text NOT NULL,
	description text NOT NULL,
	price_per_night float,
	available_dates date[],
	owner_id int,
	CONSTRAINT fk_owner_id foreign key(owner_id) REFERENCES users(id) on delete cascade
);

CREATE TYPE status as ENUM ('requested', 'confirmed', 'rejected');

CREATE TABLE requests (
	id SERIAL PRIMARY KEY,
	space_id int,
	requester_id int,
	date date,
	status status,
	CONSTRAINT fk_space_id foreign key(space_id) REFERENCES spaces(id) on delete cascade,
	CONSTRAINT fk_requester_id foreign key(requester_id) REFERENCES users(id) on delete cascade
);
