TRUNCATE TABLE users, spaces, requests RESTART IDENTITY;

INSERT INTO users
		(name, username, email, password)
	VALUES
		('Sam', 'usersam', 'sam@email.com', 'sampassword'),
		('Gary', 'usergary', 'gary@email.com', 'garypassword'),
		('Jack', 'userjack', 'jack@email.com', 'jackpassword'),
		('Tom', 'usertom', 'tom@email.com', 'tompassword'),
		('Serkan', 'userserkan', 'serkan@email.com', 'serkanpassword');

INSERT INTO spaces
		(name, description, price_per_night, available_dates, owner_id)
	VALUES
		('Happy meadows', 'A happy place', 7.99, '{2023-4-17, 2023-4-17}'::date[], 1),
		('Scary fields', 'A scary field', 11.99, '{2023-3-16, 2023-3-17, 2023-3-18}'::date[], 2),
		('Melancholy marsh', 'A place to reflect', 10.50, '{2023-4-1, 2023-4-2, 2023-4-7}'::date[], 2),
		('Airy alpine', 'why not?', 20.00, '{2023-5-17}'::date[], 4),
		('Fiery flower patch', 'Only for the coolest', 99.99, '{2023-4-18, 2023-4-19, 2023-4-20, 2023-4-21}'::date[], 4),
		('Icy flower patch', 'Only for the hottest', 99.99, '{2023-4-18, 2023-4-19, 2023-4-20, 2023-4-21}'::date[], 4);

INSERT INTO requests 
		(space_id, requester_id, date, status)
	VALUES
		(1, 2, '2023-4-17', 'requested'),
		(1, 3, '2023-4-17', 'requested'),
		(2, 3, '2023-3-18', 'requested'),
		(3, 4, '2023-4-1',  'requested'),
		(5, 1, '2023-4-18', 'requested'),
		(1, 2, '2023-4-18', 'confirmed'),
		(1, 3, '2023-4-18', 'rejected');