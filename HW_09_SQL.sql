-- HW Assignment 09-SQL --
-- Erica Leon --

USE sakila;
SELECT * from actor;

-- 1a. Display the first and last names of all actors from the table actor.
SELECT actor.first_name, actor.last_name
FROM actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
ALTER TABLE sakila.actor
ADD COLUMN actor_name VARCHAR(75);

UPDATE sakila.actor 
SET actor_name = CONCAT(first_name, ' ', last_name);

SELECT actor_name AS "Actor Name" FROM actor;

/* 2a. You need to find the ID number, first name, and last name of an actor, --
of whom you know only the first name, "Joe." What is one query would you use to obtain this information? */
Select actor_id, first_name, last_name
FROM actor
WHERE first_name LIKE "Joe";

-- 2b. Find all actors whose last name contain the letters GEN:
Select * FROM actor
WHERE last_name LIKE "%GEN%";

/* 2c. Find all actors whose last names contain the letters LI.
This time, order the rows by last name and first name, in that order: */
SELECT last_name, first_name FROM actor
WHERE last_name LIKE "%LI%";

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT country_id, country FROM sakila.country
WHERE country IN ("Afghanistan", "Bangladesh", "China");

/* 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, 
so create a column in the table actor named description and use the data type BLOB */
ALTER TABLE sakila.actor
ADD COLUMN `description` BLOB NULL;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.
ALTER TABLE sakila.actor
DROP COLUMN `description`;

-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, COUNT(last_name) as `Last Name Count` from sakila.actor
GROUP BY last_name;

/* 4b. List last names of actors and the number of actors who have that last name,
but only for names that are shared by at least two actors */
SELECT last_name, COUNT(last_name) as `Last Name Count` from sakila.actor
GROUP BY last_name
HAVING `Last Name Count` > 1;

/*4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS.
Write a query to fix the record.*/
SELECT * from actor
WHERE actor_name = "HARPO WILLIAMS";

UPDATE sakila.actor
	SET first_name = "HARPO",
    actor_name = "HARPO WILLIAMS"
    WHERE actor_name = "GROUCHO WILLIAMS";
    
/*4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! --
In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.*/
UPDATE sakila.actor
	SET first_name = "HARPO"
    WHERE first_name = "GROUCHO";

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
SHOW CREATE TABLE address;

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
SELECT s.first_name, s.last_name, a.address
FROM staff s
INNER JOIN address a
ON (s.address_id = a.address_id);

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
select s.staff_id, s.first_name, s.last_name, sum(p.amount) as 'Total Amount'
from staff s
join payment p
on (s.staff_id = p.staff_id)
WHERE p.payment_date LIKE '2005-08%'
group by s.staff_id;

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
SELECT f.film_id, f.title, COUNT(a.film_id) AS 'Number of Actors'
FROM film f
INNER JOIN film_actor a
ON (f.film_id = a.film_id)
GROUP BY f.film_id;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT SUM(film_id) AS 'Hunchback Impossible Inventory'
FROM inventory
WHERE film_id IN
(
	SELECT film_id 
    FROM film
	WHERE title = "Hunchback Impossible"
);

/* 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. 
List the customers alphabetically by last name: */
Select c.last_name, c.first_name, c.customer_id, sum(p.amount) as 'Total Paid'
FROM customer c
JOIN payment p
ON (c.customer_id = p.customer_id)
GROUP BY c.customer_id
ORDER BY c.last_name ASC;

/* 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, 
films starting with the letters K and Q have also soared in popularity. Use subqueries to display the titles of movies 
starting with the letters K and Q whose language is English. */
SELECT f.title
FROM film f
WHERE (f.title LIKE "K%" OR f.title LIKE "Q%")
AND f.language_id IN
(
	SELECT l.language_id
    FROM language l
    WHERE l.name = "English"
);

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT first_name, last_name
from actor
where actor_id IN
(
	SELECT actor_id
	from film_actor
	where film_id in
	(
		SELECT film_id
		from film
		where title = "Alone Trip"
	)
);

/* 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of
all Canadian customers. Use joins to retrieve this information. use customer, address.city_id, city (city_id & country_id), country */
SELECT c.first_name, c.last_name, c.email
FROM (((customer c 
INNER JOIN address a ON c.address_id = a.address_id)
INNER JOIN city ct ON a.city_id = ct.city_id)
INNER JOIN country cn ON ct.country_id = cn.country_id)
WHERE cn.country = "Canada";

/* 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
Identify all movies categorized as family films. */
SELECT film.title FROM film
WHERE film_id IN
(
	SELECT film_id FROM film_category
	WHERE category_id IN
	(
		SELECT category_id FROM category
		WHERE category.name = "Family"
	));

-- 7e. Display the most frequently rented movies in descending order.
SELECT f.title, COUNT(f.title) as `Rentals`
FROM ((film f
INNER JOIN inventory i ON f.film_id = i.film_id
INNER JOIN rental r ON i.inventory_id = r.inventory_id))
GROUP BY f.title
ORDER BY `Rentals` DESC;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT st.store_id, SUM(p.amount) AS 'Total Dollars'
FROM ((payment p
INNER JOIN staff s ON p.staff_id = s.staff_id)
INNER JOIN store st ON s.store_id = st.store_id)
GROUP BY store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT s.store_id, c.city, cn.country
FROM (((store s
INNER JOIN address a ON s.address_id = a.address_id)
INNER JOIN city c ON a.city_id = c.city_id)
INNER JOIN country cn ON c.country_id = cn.country_id);


/* 7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: 
category, film_category, inventory, payment, and rental.) */
SELECT c.name, SUM(p.amount) AS `Revenue`
FROM ((((category c
INNER JOIN film_category f ON c.category_id = f.category_id)
INNER JOIN inventory i ON f.film_id = i.film_id)
INNER JOIN rental r ON i.inventory_id = r.inventory_id)
INNER JOIN payment p ON r.rental_id = p.rental_id)
GROUP BY c.name
ORDER BY `Revenue` DESC
LIMIT 5;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
CREATE VIEW Top_5 AS (
SELECT c.name, SUM(p.amount) AS `Revenue`
FROM ((((category c
INNER JOIN film_category f ON c.category_id = f.category_id)
INNER JOIN inventory i ON f.film_id = i.film_id)
INNER JOIN rental r ON i.inventory_id = r.inventory_id)
INNER JOIN payment p ON r.rental_id = p.rental_id)
GROUP BY c.name
ORDER BY `Revenue` DESC
LIMIT 5);

-- 8b. How would you display the view that you created in 8a?
SELECT * FROM Top_5;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW Top_5;