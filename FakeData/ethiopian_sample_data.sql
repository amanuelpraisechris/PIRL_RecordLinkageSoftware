-- Sample Ethiopian HDSS Data
-- Insert test data for Ethiopian context
-- This data represents typical HDSS records from various Ethiopian regions

-- Sample individuals with Ethiopian names and administrative divisions
INSERT INTO public.dss_individuals
(dss_id, first_name, middle_name, first_name_latin, father_name_latin, grandfather_name,
 gender, birth_day, birth_month, birth_year, birth_year_ethiopian, calendar_type,
 region, woreda, kebele, gott)
VALUES

-- Amhara Region Samples
('ETH-AM-001', 'አበበ', 'በቀለ', 'Abebe', 'Bekele', 'Haile', 'M', '15', '05', '1985', '1977', 'ethiopian',
 'Amhara', 'Gondar Zuria', 'Azezo', 'Maraki'),

('ETH-AM-002', 'አልማዝ', 'ደስታ', 'Almaz', 'Desta', 'Gebre', 'F', '20', '08', '1990', '1982', 'ethiopian',
 'Amhara', 'Gondar Zuria', 'Azezo', 'Maraki'),

('ETH-AM-003', 'ተስፋዬ', 'ወልዴ', 'Tesfaye', 'Woldए', 'Mulugeta', 'M', '10', '03', '1978', '1970', 'ethiopian',
 'Amhara', 'Bahir Dar Zuria', 'Tis Abay', 'Zenzelima'),

('ETH-AM-004', 'ብርቱካን', 'ገብሩ', 'Birtukan', 'Gebru', 'Kebede', 'F', '25', '11', '1988', '1980', 'ethiopian',
 'Amhara', 'Bahir Dar Zuria', 'Tis Abay', 'Zenzelima'),

-- Oromia Region Samples
('ETH-OR-001', 'Chaltu', 'Tadese', 'Chaltu', 'Tadese', 'Bekele', 'F', '05', '07', '1992', '1984', 'ethiopian',
 'Oromia', 'Adama', 'Bole', 'Wonji'),

('ETH-OR-002', 'Gemechu', 'Hundesa', 'Gemechu', 'Hundesa', 'Merga', 'M', '12', '09', '1986', '1978', 'ethiopian',
 'Oromia', 'Adama', 'Bole', 'Wonji'),

('ETH-OR-003', 'Aster', 'Dereje', 'Aster', 'Dereje', 'Alemu', 'F', '18', '04', '1995', '1987', 'ethiopian',
 'Oromia', 'Jimma', 'Seka Chekorsa', 'Gibe'),

-- SNNPR Samples
('ETH-SN-001', 'Yohanes', 'Amare', 'Yohanes', 'Amare', 'Tekle', 'M', '22', '06', '1983', '1975', 'ethiopian',
 'SNNPR', 'Hawassa Zuria', 'Alamura', 'Tikur Wuha'),

('ETH-SN-002', 'ሄለን', 'ታደሰ', 'Helen', 'Tadese', 'Yohannes', 'F', '30', '12', '1991', '1983', 'ethiopian',
 'SNNPR', 'Hawassa Zuria', 'Alamura', 'Tikur Wuha'),

('ETH-SN-003', 'Dawit', 'Mekonnen', 'Dawit', 'Mekonnen', 'Gebreyes', 'M', '08', '02', '1980', '1972', 'ethiopian',
 'SNNPR', 'Butajira', 'Meskan', 'Alicho'),

-- Tigray Region Samples
('ETH-TI-001', 'Mulu', 'Hagos', 'Mulu', 'Hagos', 'Teklay', 'F', '14', '10', '1989', '1981', 'ethiopian',
 'Tigray', 'Kilite Awlaelo', 'Tsaeda Anbesa', 'May Kinetal'),

('ETH-TI-002', 'Gebrehiwot', 'Berhe', 'Gebrehiwot', 'Berhe', 'Haile', 'M', '27', '01', '1987', '1979', 'ethiopian',
 'Tigray', 'Kilite Awlaelo', 'Tsaeda Anbesa', 'May Kinetal'),

-- Sidama Region Samples
('ETH-SD-001', 'Fiseha', 'Tadesse', 'Fiseha', 'Tadesse', 'Wolde', 'M', '16', '08', '1994', '1986', 'ethiopian',
 'Sidama', 'Hawassa Zuria', 'Shera', 'Fura'),

('ETH-SD-002', 'Meseret', 'Girma', 'Meseret', 'Girma', 'Tesfaye', 'F', '19', '03', '1993', '1985', 'ethiopian',
 'Sidama', 'Hawassa Zuria', 'Shera', 'Fura'),

-- Addis Ababa Samples
('ETH-AA-001', 'Solomon', 'Tekle', 'Solomon', 'Tekle', 'Woldemichael', 'M', '11', '07', '1985', '1977', 'ethiopian',
 'Addis Ababa', 'Bole', 'Kebele 03', 'Gerji'),

('ETH-AA-002', 'Tigist', 'Alemu', 'Tigist', 'Alemu', 'Bekele', 'F', '24', '05', '1990', '1982', 'ethiopian',
 'Addis Ababa', 'Bole', 'Kebele 03', 'Gerji'),

-- Name Variations for Testing Fuzzy Matching
('ETH-AM-005', 'Abebe', 'Bikila', 'Abebe', 'Bikila', 'Desta', 'M', '15', '05', '1985', '1977', 'ethiopian',
 'Amhara', 'Gondar Zuria', 'Azezo', 'Maraki'), -- Similar to ETH-AM-001 for testing

('ETH-AM-006', 'Ababa', 'Bekele', 'Ababa', 'Bekele', 'Hayle', 'M', '15', '05', '1984', '1976', 'ethiopian',
 'Amhara', 'Gondar Zuria', 'Azezo', 'Maraki'), -- Spelling variation for testing

-- Names with Transliterations
('ETH-AM-007', 'ሃይሌ', 'ማርያም', 'Haile', 'Mariam', 'Selassie', 'M', '07', '09', '1982', '1974', 'ethiopian',
 'Amhara', 'Debre Birhan', 'Kebele 01', 'Shewa Robit'),

('ETH-AM-008', 'መሩሂ', 'ኃይሉ', 'Meruhi', 'Hailu', 'Gebru', 'F', '13', '11', '1996', '1988', 'ethiopian',
 'Amhara', 'Debre Birhan', 'Kebele 01', 'Shewa Robit'),

-- Elderly individuals
('ETH-OR-004', 'Beyene', 'Tolessa', 'Beyene', 'Tolessa', 'Admasu', 'M', '20', '04', '1950', '1942', 'ethiopian',
 'Oromia', 'Jimma', 'Seka Chekorsa', 'Gibe'),

('ETH-OR-005', 'Woizero', 'Girma', 'Woizero', 'Girma', 'Teshome', 'F', '18', '06', '1948', '1940', 'ethiopian',
 'Oromia', 'Jimma', 'Seka Chekorsa', 'Gibe'),

-- Young children
('ETH-AA-003', 'Natnael', 'Solomon', 'Natnael', 'Solomon', 'Tekle', 'M', '05', '01', '2015', '2007', 'ethiopian',
 'Addis Ababa', 'Bole', 'Kebele 03', 'Gerji'),

('ETH-AA-004', 'Selam', 'Dawit', 'Selam', 'Dawit', 'Mekonnen', 'F', '12', '08', '2016', '2008', 'ethiopian',
 'Addis Ababa', 'Bole', 'Kebele 03', 'Gerji'),

-- Common Ethiopian names for testing frequency
('ETH-AM-009', 'Mulugeta', 'Abebe', 'Mulugeta', 'Abebe', 'Tekle', 'M', '10', '02', '1975', '1967', 'ethiopian',
 'Amhara', 'Dessie Zuria', 'Boru', 'Ambassel'),

('ETH-AM-010', 'Almaz', 'Tesfaye', 'Almaz', 'Tesfaye', 'Kebede', 'F', '14', '07', '1977', '1969', 'ethiopian',
 'Amhara', 'Dessie Zuria', 'Boru', 'Ambassel');

-- Update totals
DO $$
BEGIN
    RAISE NOTICE 'Inserted 25 sample Ethiopian HDSS individuals';
    RAISE NOTICE 'Regions represented: Amhara (10), Oromia (5), SNNPR (3), Tigray (2), Sidama (2), Addis Ababa (4)';
    RAISE NOTICE 'Age ranges: Children (2), Young adults (10), Adults (10), Elderly (2)';
END $$;

-- Verify insertion
SELECT
    region,
    COUNT(*) as count,
    COUNT(*) FILTER (WHERE gender = 'M') as males,
    COUNT(*) FILTER (WHERE gender = 'F') as females
FROM public.dss_individuals
WHERE dss_id LIKE 'ETH-%'
GROUP BY region
ORDER BY count DESC;
