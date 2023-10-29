/*
File Name:		fa-assets.sql
Version:		R12
Author:			Otcu
Author URL:		https://github.com/otcu
*/

-- ##################################################################
-- TABLE DUMPS
-- ##################################################################

select * from fa_additions_b where last_update_date > '01-AUG-2018' order by creation_date desc;
select * from fa_additions_b where asset_number = '366323';
select * from fa_additions_b order by creation_date desc;
select * from fa_additions_b where asset_number = 123456;
select * from fa_additions_b where '#' || asset_id <> '#' || asset_number;
select * from fa_additions_b where asset_category_id = 123456;
select * from fa_mass_additions where last_update_date > '01-AUG-2018';
select * from fa_mass_additions where asset_number = '123456';
select * from fa_additions_tl where asset_id = 123456;
select * from fa_mass_additions where asset_number in (123456,123457);
select * from fa_asset_keywords where last_update_date > '01-AUG-2018';
select * from fa_retirements where asset_id = 123456;
select * from fa_category_books;
select * from fa_categories_b where category_id in (123456,123457);
select * from fa_categories_tl where category_id in (123456,123457);
select depreciate_flag from fa_category_books where category_id in (123456,123457);
select depreciate_flag from fa_category_book_defaults where category_id in (123456,123457);
