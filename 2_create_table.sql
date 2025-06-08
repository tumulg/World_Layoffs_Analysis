-- Create layoffs table
CREATE TABLE public.layoffs (
    company TEXT,
    location TEXT,
    industry TEXT,
    total_laid_off INT,
    percentage_laid_off NUMERIC,
    date DATE,
    stage TEXT,
    country TEXT,
    funds_raised_millions NUMERIC
);

-- Set ownership to postgres user
ALTER TABLE public.layoffs OWNER TO postgres;

-- Optional indexes for performance
CREATE INDEX idx_country ON public.layoffs (country);
CREATE INDEX idx_company ON public.layoffs (company);
CREATE INDEX idx_industry ON public.layoffs (industry);
CREATE INDEX idx_date ON public.layoffs (date);