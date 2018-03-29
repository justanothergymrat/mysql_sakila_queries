use sakila;

-- 1a. Display the first and last names of all actors from the table actor.

select first_name, last_name from actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.

select concat(actor.first_name,' ', actor.last_name)  as 'Actor Name' from actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." 
-- What is one query would you use to obtain this information?

select actor_id, first_name, last_name from actor where first_name="Joe";

-- 2b. Find all actors whose last name contain the letters GEN:

select concat(actor.first_name, ' ', actor.last_name) as 'lastname has GEN' from actor where last_name like '%GEN%';

-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:

select first_name, last_name from actor where last_name like '%LI%' order by first_name,last_name;

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:

select country_id, country from country where country in ('Afghanistan', 'Bangladesh', 'China');

-- 3a. Add a middle_name column to the table actor. Position it between first_name and last_name. Hint: you will need to specify the data type.

alter table actor add column middle_name text after first_name;

describe actor;

-- 3b. You realize that some of these actors have tremendously long last names. Change the data type of the middle_name column to blobs.

alter table actor modify column middle_name blob;

describe actor;

-- 3c. Now delete the middle_name column.

alter table actor drop column middle_name;

describe actor;

-- 4a. List the last names of actors, as well as how many actors have that last name.

select distinct last_name, count(last_name) from actor group by last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors

select last_name, count(last_name) from actor group by last_name having (count(last_name) > 1);

-- 4c. Oh, no! The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS, the name of 
-- Harpo's second cousin's husband's yoga teacher. Write a query to fix the record.

update actor set first_name='harpo' where (first_name='groucho' and last_name='williams');

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all!
-- In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO. Otherwise, change the first name to
-- MUCHO GROUCHO, as that is exactly what the actor will be with the grievous error. BE CAREFUL NOT TO CHANGE THE 
-- FIRST NAME OF EVERY ACTOR TO MUCHO GROUCHO, HOWEVER! (Hint: update the record using a unique identifier.)

update actor set first_name = ( case 
	when first_name='harpo' then 'groucho'
	when first_name='groucho' then 'mucho groucho'
	end)
where first_name in ('harpo','groucho');

select * from actor;

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?

show create table address;

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:

select staff.first_name as 'Employee First Name', staff.last_name as 'Employee Last Name', address.address as 'Employee Address'
from staff inner join address on  staff.address_id = address.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.

select sum(payment.amount) as 'Total Payments 2005'
from payment inner join staff on  staff.staff_id = payment.staff_id
where payment.payment_date like '2005%';

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.

select film.title as 'Film Title', count(actor_id) as 'Number of Actors)'
from film inner join film_actor on film.film_id = film_actor.film_id
group by film.title;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?

select count(inventory_id) as '# of Copies' from inventory where film_id = (select film_id from film where title = 'Hunchback Impossible');

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:

select c.first_name as 'First Name', c.last_name as 'Last Name', sum(p.amount) as 'Total Paid'
from payment p inner join customer c on c.customer_id = p.customer_id
group by c.last_name, c.first_name;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters 
-- K and Q have also soared in popularity. Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.

select title from film where (title like 'k%') or (title like 'q%') and language_id = (select language_id from language where name = 'english');
    
    
-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.

select first_name as 'First Name', last_name as 'Last Name' from actor where actor_id in
(select actor_id from film_actor where film_id = (select film_id from film where title = 'alone trip'));

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. 
-- Use joins to retrieve this information.

select first_name as 'First Name', last_name as 'Last Name', email as 'Email'  from customer where customer_id in
(SELECT id FROM `sakila`.`customer_list` where country = 'canada');

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as famiy films.

select * from film where film_id in
(select film_id from film_category where category_id = 
(select category_id from category where name='family'));

-- or 
select * from film_list where category = 'family';

-- 7e. Display the most frequently rented movies in descending order.

select r.inventory_id as 'Inventory ID', i.film_id as 'Film ID', f.title as 'Title', count(r.rental_id) as 'Times rented' 
from ((film f
inner join inventory i on f.film_id = i.film_id) 
inner join rental r on r.inventory_id = i.inventory_id)
group by r.inventory_id order by count(r.rental_id) desc ;

-- 7f. Write a query to display how much business, in dollars, each store brought in.

SELECT `sales_by_store`.`store`,
    `sales_by_store`.`total_sales`
FROM `sakila`.`sales_by_store`;

-- or
select p.staff_id as 'Staff Number', sum(p.amount) as 'Total Sales', s.store_id as 'Store ID', a.address as 'Store Address'
from ((payment p
inner join staff s on p.staff_id = s.staff_id
inner join address a on s.address_id = a.address_id))
group by p.staff_id;

-- 7g. Write a query to display for each store its store ID, city, and country.

select sid, city, country from staff_list;

-- or
select store.store_id  as 'Store Number', city.city as 'City', country.country as 'Country'
from ((store
inner join address on store.address_id = address.address_id)
inner join city on address.city_id = city.city_id)
inner join country on city.country_id = country.country_id;

-- 7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables:
--  category, film_category, inventory, payment, and rental.)

select * from sales_by_film_category order by total_sales desc limit 5;

-- or
select c.name as 'Genre', sum(p.amount) as 'Gross Revenue'
from(((((payment p
inner join rental r on p.rental_id = r.rental_id)
inner join inventory i on r.inventory_id = i.inventory_id)
inner join film f on i.film_id = f.film_id)
inner join film_category f_c on f.film_id = f_c.film_id)
inner join category c on f_c.category_id = c.category_id) group by c.name order by sum(p.amount) desc limit 5;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
-- Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
create view View_top_5_genre as
select c.name as 'Genre', sum(p.amount) as 'Gross Revenue'
from(((((payment p
inner join rental r on p.rental_id = r.rental_id)
inner join inventory i on r.inventory_id = i.inventory_id)
inner join film f on i.film_id = f.film_id)
inner join film_category f_c on f.film_id = f_c.film_id)
inner join category c on f_c.category_id = c.category_id) group by c.name order by sum(p.amount) desc limit 5;

-- 8b. How would you display the view that you created in 8a?

select * from View_top_5_genre;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.

drop view View_top_5_genre;