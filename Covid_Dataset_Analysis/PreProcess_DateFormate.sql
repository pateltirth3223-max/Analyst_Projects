-- 1. Add a new DATE-typed column
ALTER TABLE coviddeaths
  ADD COLUMN parsed_date DATE;

-- 2. Populate it by parsing the existing text column
UPDATE coviddeaths
SET parsed_date = STR_TO_DATE(date, '%d/%m/%y')
WHERE date IS NOT NULL AND date <> '';

-- 3. Verify parsing correctness
SELECT date AS original_text, parsed_date
FROM coviddeaths
WHERE parsed_date IS NULL AND date <> '';

-- 4. Drop the old text column
ALTER TABLE coviddeaths
  DROP COLUMN date;

-- 5. Rename the new column to the original name
ALTER TABLE coviddeaths
  CHANGE COLUMN parsed_date date DATE;

-- 6. (Optional) Add NOT NULL constraint if every row should have a date
ALTER TABLE coviddeaths
  MODIFY COLUMN date DATE NOT NULL;
