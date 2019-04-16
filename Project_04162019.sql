Use sakila;

-- Display the first and last names of all actors from the table `actor`.

Select first_name, last_name
From actor;

-- -----------------------------------------------------------------------
-- -----------------------------------------------------------------------

-- Display the first and last name of each actor in a single column in upper 
-- case letters. Name the column `Actor Name`.

Alter Table actor
Add Column `Actor Name` Varchar(75);
SET SQL_SAFE_UPDATES = 0;
UPDATE actor
SET `Actor Name`  = CONCAT(first_name, ' ', last_name);

Select * From actor;

-- ------------------------------------------------------------------
-- ------------------------------------------------------------------

 -- You need to find the ID number, first name, and last name of an actor, 
 -- of whom you know only the first name, "Joe." What is one query would you
 -- use to obtain this information?
 
  Select actor_id From actor
  Where first_name Like 'JOE%';
 
 
 -- ------------------------------------------------------------------
 -- ------------------------------------------------------------------
 
 -- Find all actors whose last name contain the letters `GEN`
 
 Select * From actor
 Where last_name Like '%GEN%';
 
 -- -------------------------------------------------------------------
 -- -------------------------------------------------------------------
 
  -- Find all actors whose last names contain the letters `LI`. This time, 
  -- order the rows by last name and first name, in that order
  
  Select * From actor
  Where last_name Like '%LI%'
  Order By last_name, first_name ASC;
 
 -- --------------------------------------------------------------------
 -- --------------------------------------------------------------------
 
  -- Using `IN`, display the `country_id` and `country` columns of the 
  -- following countries: Afghanistan, Bangladesh, and China:

Select country_id, country From country
Where country IN ('Afghanistan', 'Bangladesh', 'China');

-- ---------------------------------------------------------------------
-- ---------------------------------------------------------------------

 -- You want to keep a description of each actor. You don't think you will be 
 -- performing queries on a description, so create a column in the table `actor` 
 -- named `description` and use the data type `BLOB` (Make sure to research the type
 -- `BLOB`, as the difference between it and `VARCHAR` are significant).
 
Alter Table actor
Add Column `Description` BLOB;

Select * From actor;

-- ----------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------

-- Very quickly you realize that entering descriptions for each actor is too much effort. 
-- Delete the `description` column.

Alter Table actor
Drop Column `Description`;

Select * from actor;

-- -------------------------------------------------------------------------------------
-- -------------------------------------------------------------------------------------

-- List the last names of actors, as well as how many actors have that last name.

Select last_name, Count(last_name) From actor
Group By last_name
Order By Count(last_name) Desc;

-- ----------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------

-- List last names of actors and the number of actors who have that last name, but only for 
-- names that are shared by at least two actors

Select last_name, Count(last_name) From actor
Group By last_name
Having Count(last_name) >= 2
Order By Count(last_name) Desc;

-- --------------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------------

-- The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`. 
-- Write a query to fix the record.

Select * From actor
Where `Actor Name` Like '% WILLIAMS';

SET SQL_SAFE_UPDATES = 0;
Update actor set first_name = Replace(first_name, 'GROUCHO', 'HARPO');

UPDATE actor
SET `Actor Name`  = CONCAT(first_name, ' ', last_name);

Select * From actor
Where `Actor Name` Like '% WILLIAMS';

-- ----------------------------------------------------------------
-- ----------------------------------------------------------------

-- Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns 
-- out that `GROUCHO` was the correct name after all! In a single query, 
-- if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.

Update actor
Set first_name = Case
	When first_name = 'HARPO' Then Replace(first_name, 'HARPO', 'GROUCHO')
    Else first_name
End;

UPDATE actor
SET `Actor Name`  = CONCAT(first_name, ' ', last_name);

Select * From actor
Where `Actor Name` Like '% WILLIAMS';

-- ----------------------------------------------------------------------
-- ----------------------------------------------------------------------

-- You cannot locate the schema of the `address` table. Which query would 
-- you use to re-create it?

  -- Hint: [https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html]
  -- (https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html)
  
  Show Create Table address;

-- ------------------------------------------------------------------------
-- ------------------------------------------------------------------------

-- Use `JOIN` to display the first and last names, as well as the address, of 
-- each staff member. Use the tables `staff` and `address`:

Select staff.first_name, staff.last_name, address.address
From staff
Inner Join address
On staff.address_id = address.address_id;

-- --------------------------------------------------------------------------
-- --------------------------------------------------------------------------

-- Use `JOIN` to display the total amount rung up by each staff member in August 
-- of 2005. Use tables `staff` and `payment`.

Select staff.first_name, staff.last_name, payment.payment_date, sum(payment.amount)
From staff
Inner Join payment
Where staff.staff_id = payment.staff_id And 
payment_date Like '2005-08%'
group by staff.staff_id;

-- ---------------------------------------------------------------
-- ---------------------------------------------------------------

-- List each film and the number of actors who are listed for that film. 
-- Use tables `film_actor` and `film`. Use inner join.

Select film.title, count(film_actor.actor_id)
From film
Inner Join film_actor
Where film.film_id = film_actor.film_id
Group By film.film_id;

-- -------------------------------------------------------------------
-- -------------------------------------------------------------------

-- How many copies of the film `Hunchback Impossible` exist in the inventory system?

Select film.title, count(inventory.film_id)
From film
Inner Join inventory
Where film.film_id = inventory.film_id
Group By film.title
Having film.title = 'Hunchback Impossible';

-- ----------------------------------------------------------------------
-- ----------------------------------------------------------------------

-- Using the tables `payment` and `customer` and the `JOIN` command, list 
-- the total paid by each customer. List the customers alphabetically by last name:

-- ![Total amount paid](Images/total_payment.png)

Select sum(payment.amount) as `Total Amount Paid`, customer.first_name, customer.last_name
From customer
Inner Join payment
Where customer.customer_id = payment.customer_id
Group By customer.customer_id
Order By customer.last_name asc;

-- ---------------------------------------------------------------------------
-- ---------------------------------------------------------------------------

-- The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
-- As an unintended consequence, films starting with the letters `K` and `Q` have 
-- also soared in popularity. Use subqueries to display the titles of movies starting 
-- with the letters `K` and `Q` whose language is English.

Select title
From film
Where language_id In
	(
    Select language_id
    From language
    Where name = 'English'
    )
And title Like 'K%' or 'Q%';

-- ---------------------------------------------------------------------------
-- ---------------------------------------------------------------------------

-- Use subqueries to display all actors who appear in the film `Alone Trip`.

Select `Actor Name`
From actor
Where actor_id IN
	(
    Select actor_id
    From film_actor
    Where film_id IN
		(
        Select film_id
        From film
        Where title = "Alone Trip"
        )
	);

-- ------------------------------------------------------------------
-- ------------------------------------------------------------------

-- You want to run an email marketing campaign in Canada, for which you 
-- will need the names and email addresses of all Canadian customers. Use 
-- joins to retrieve this information.

Select customer.first_name, customer.last_name, customer.email
From customer
Inner Join address 
On customer.address_id = address.address_id
Inner Join city
On address.city_id = city.city_id
Inner Join country
On city.country_id = country.country_id
Where country.country = 'Canada'
Group By customer.email;


-- ----------------------------------------------------------------------------
-- ----------------------------------------------------------------------------

-- Sales have been lagging among young families, and you wish to target all family 
-- movies for a promotion. Identify all movies categorized as _family_ films.

Select film.film_id, title
From film
Inner Join film_category
On film.film_id = film_category.film_id
Inner Join category
On film_category.category_id = category.category_id
Where category.name = 'Family';

-- --------------------------------------------------------------------------
-- --------------------------------------------------------------------------

-- Display the most frequently rented movies in descending order.

Select title, Count(rental.inventory_id)
From film
Inner Join inventory
On film.film_id = inventory.film_id
Inner Join rental
On inventory.inventory_id = rental.inventory_id
Group By title
Order By Count(rental.inventory_id) desc;

-- -------------------------------------------------------------------------
-- -------------------------------------------------------------------------

-- Write a query to display how much business, in dollars, each store brought in.

Select store.store_id, Sum(payment.amount)
From store
Inner Join customer
On store.store_id = customer.store_id
Inner Join payment
On customer.customer_id = payment.customer_id
Group By store.store_id;

-- -------------------------------------------------------------------
-- -------------------------------------------------------------------

-- Write a query to display for each store its store ID, city, and country.

Select store.store_id, city.city, country.country
From store
Inner Join address
On store.address_id = address.address_id
Inner Join city
On address.city_id = city.city_id
Inner Join country
On city.country_id = country.country_id
Group By store.store_id;
        
-- ----------------------------------------------------------------------
-- ----------------------------------------------------------------------

-- List the top five genres in gross revenue in descending order. (**Hint**: 
-- you may need to use the following tables: category, film_category, inventory, 
-- payment, and rental.)

Select category.name, Sum(payment.amount)
From category
Inner Join film_category
On category.category_id = film_category.category_id
Inner Join inventory
On film_category.film_id = inventory.film_id
Inner Join rental
On inventory.inventory_id = rental.inventory_id
Inner Join payment
On rental.rental_id = payment.rental_id
Group By category.name
Order By Sum(payment.amount) desc;

-- ------------------------------------------------------------------------------
-- ------------------------------------------------------------------------------

-- In your new role as an executive, you would like to have an easy way of viewing 
-- the Top five genres by gross revenue. Use the solution from the problem above to 
-- create a view. If you haven't solved 7h, you can substitute another query to create a view.

Create View genres as
	Select category.name, Sum(payment.amount)
	From category
	Inner Join film_category
	On category.category_id = film_category.category_id
	Inner Join inventory
	On film_category.film_id = inventory.film_id
	Inner Join rental
	On inventory.inventory_id = rental.inventory_id
	Inner Join payment
	On rental.rental_id = payment.rental_id
	Group By category.name
	Order By Sum(payment.amount) desc;


-- ---------------------------------------------------------------------------------------
-- ---------------------------------------------------------------------------------------

-- How would you display the view that you created in 8a?

Select * From genres;

-- --------------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------------

-- You find that you no longer need the view `top_five_genres`. Write a query to delete it.

Drop View genres;
