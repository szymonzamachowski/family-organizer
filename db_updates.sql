-- Add category column to shopping_list table
alter table shopping_list 
add column if not exists category text default 'Inne';

-- Optional: Update existing items to 'Inne' if needed (default handles new ones)
update shopping_list 
set category = 'Inne' 
where category is null;
