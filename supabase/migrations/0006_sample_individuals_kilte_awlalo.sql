-- Sample Kilte Awlalo HDSS Individuals
-- Realistic Ethiopian individuals from the 10 Tabias
-- Uses authentic Tigrinya names and location codes

-- Clear any existing sample data
TRUNCATE TABLE public.dss_individuals CASCADE;

-- Insert 50 sample individuals across Kilte Awlalo Tabias
INSERT INTO public.dss_individuals (
    dss_id, first_name, middle_name, last_name,
    tl_first_name, tl_middle_name, tl_last_name,
    gender, birth_day, birth_month, birth_year,
    village, subvillage
) VALUES
    -- Agbe Tabia (KA-AGBE) - 10 individuals
    ('KA-AGBE-001', 'Tesfay', 'Gebrehiwot', 'Haile', 'Tesfay', 'Gebrehiwot', 'Haile', 'M', '15', '3', '1985', 'KA-AGBE', 'KA-AGBE-01'),
    ('KA-AGBE-002', 'Alem', 'Tekle', 'Gebremariam', 'Alem', 'Tekle', 'Gebremariam', 'F', '22', '7', '1990', 'KA-AGBE', 'KA-AGBE-01'),
    ('KA-AGBE-003', 'Gebre', 'Mesele', 'Weldu', 'Gebre', 'Mesele', 'Weldu', 'M', '8', '11', '1978', 'KA-AGBE', 'KA-AGBE-02'),
    ('KA-AGBE-004', 'Mulu', 'Abraha', 'Kiros', 'Mulu', 'Abraha', 'Kiros', 'F', '30', '5', '1995', 'KA-AGBE', 'KA-AGBE-02'),
    ('KA-AGBE-005', 'Girmay', 'Hagos', 'Berhe', 'Girmay', 'Hagos', 'Berhe', 'M', '12', '9', '1982', 'KA-AGBE', 'KA-AGBE-03'),
    ('KA-AGBE-006', 'Tsehay', 'Gebremedhin', 'Teklay', 'Tsehay', 'Gebremedhin', 'Teklay', 'F', '5', '2', '1988', 'KA-AGBE', 'KA-AGBE-03'),
    ('KA-AGBE-007', 'Kahsay', 'Teklu', 'Abraha', 'Kahsay', 'Teklu', 'Abraha', 'M', '18', '12', '1975', 'KA-AGBE', 'KA-AGBE-04'),
    ('KA-AGBE-008', 'Letekiros', 'Berhane', 'Hagos', 'Letekiros', 'Berhane', 'Hagos', 'F', '25', '6', '1992', 'KA-AGBE', 'KA-AGBE-04'),
    ('KA-AGBE-009', 'Teklay', 'Kiros', 'Gebreselassie', 'Teklay', 'Kiros', 'Gebreselassie', 'M', '3', '10', '1980', 'KA-AGBE', 'KA-AGBE-01'),
    ('KA-AGBE-010', 'Mehret', 'Woldu', 'Tesfay', 'Mehret', 'Woldu', 'Tesfay', 'F', '14', '4', '1997', 'KA-AGBE', 'KA-AGBE-02'),

    -- Wukro Town Tabia (KA-WUKRO) - 10 individuals
    ('KA-WUKRO-001', 'Berhane', 'Haile', 'Gebru', 'Berhane', 'Haile', 'Gebru', 'M', '20', '8', '1983', 'KA-WUKRO', 'KA-WUKRO-01'),
    ('KA-WUKRO-002', 'Yordanos', 'Mekonnen', 'Aregay', 'Yordanos', 'Mekonnen', 'Aregay', 'F', '10', '1', '1991', 'KA-WUKRO', 'KA-WUKRO-01'),
    ('KA-WUKRO-003', 'Amanuel', 'Gebre', 'Mezgebe', 'Amanuel', 'Gebre', 'Mezgebe', 'M', '7', '5', '1987', 'KA-WUKRO', 'KA-WUKRO-02'),
    ('KA-WUKRO-004', 'Tirhas', 'Tekeste', 'Gebrehiwot', 'Tirhas', 'Tekeste', 'Gebrehiwot', 'F', '28', '9', '1994', 'KA-WUKRO', 'KA-WUKRO-02'),
    ('KA-WUKRO-005', 'Kiros', 'Berhe', 'Hagos', 'Kiros', 'Berhe', 'Hagos', 'M', '16', '3', '1976', 'KA-WUKRO', 'KA-WUKRO-03'),
    ('KA-WUKRO-006', 'Hiwet', 'Teklay', 'Weldu', 'Hiwet', 'Teklay', 'Weldu', 'F', '2', '11', '1989', 'KA-WUKRO', 'KA-WUKRO-03'),
    ('KA-WUKRO-007', 'Gebremeskel', 'Aregay', 'Tesfay', 'Gebremeskel', 'Aregay', 'Tesfay', 'M', '23', '7', '1981', 'KA-WUKRO', 'KA-WUKRO-04'),
    ('KA-WUKRO-008', 'Senait', 'Mehari', 'Gebru', 'Senait', 'Mehari', 'Gebru', 'F', '11', '12', '1993', 'KA-WUKRO', 'KA-WUKRO-04'),
    ('KA-WUKRO-009', 'Haile', 'Teklu', 'Kiros', 'Haile', 'Teklu', 'Kiros', 'M', '19', '6', '1979', 'KA-WUKRO', 'KA-WUKRO-05'),
    ('KA-WUKRO-010', 'Almaz', 'Hagos', 'Tesfaye', 'Almaz', 'Hagos', 'Tesfaye', 'F', '26', '2', '1996', 'KA-WUKRO', 'KA-WUKRO-05'),

    -- Chele Tabia (KA-CHELE) - 6 individuals
    ('KA-CHELE-001', 'Gebru', 'Weldu', 'Tekeste', 'Gebru', 'Weldu', 'Tekeste', 'M', '9', '4', '1984', 'KA-CHELE', 'KA-CHELE-01'),
    ('KA-CHELE-002', 'Bizunesh', 'Abraha', 'Gebre', 'Bizunesh', 'Abraha', 'Gebre', 'F', '17', '10', '1990', 'KA-CHELE', 'KA-CHELE-01'),
    ('KA-CHELE-003', 'Mekonnen', 'Berhane', 'Haile', 'Mekonnen', 'Berhane', 'Haile', 'M', '4', '8', '1977', 'KA-CHELE', 'KA-CHELE-02'),
    ('KA-CHELE-004', 'Awet', 'Kiros', 'Teklay', 'Awet', 'Kiros', 'Teklay', 'F', '21', '1', '1992', 'KA-CHELE', 'KA-CHELE-02'),
    ('KA-CHELE-005', 'Tekeste', 'Mehari', 'Abraha', 'Tekeste', 'Mehari', 'Abraha', 'M', '13', '5', '1986', 'KA-CHELE', 'KA-CHELE-03'),
    ('KA-CHELE-006', 'Lemlem', 'Gebrehiwot', 'Berhe', 'Lemlem', 'Gebrehiwot', 'Berhe', 'F', '6', '9', '1995', 'KA-CHELE', 'KA-CHELE-03'),

    -- Dera Tabia (KA-DERA) - 6 individuals
    ('KA-DERA-001', 'Hagos', 'Tekle', 'Gebre', 'Hagos', 'Tekle', 'Gebre', 'M', '24', '11', '1982', 'KA-DERA', 'KA-DERA-01'),
    ('KA-DERA-002', 'Tsehaynesh', 'Gebremariam', 'Weldu', 'Tsehaynesh', 'Gebremariam', 'Weldu', 'F', '15', '3', '1988', 'KA-DERA', 'KA-DERA-01'),
    ('KA-DERA-003', 'Abraha', 'Aregay', 'Kiros', 'Abraha', 'Aregay', 'Kiros', 'M', '8', '7', '1975', 'KA-DERA', 'KA-DERA-02'),
    ('KA-DERA-004', 'Eyerusalem', 'Hagos', 'Tesfay', 'Eyerusalem', 'Hagos', 'Tesfay', 'F', '27', '12', '1991', 'KA-DERA', 'KA-DERA-02'),
    ('KA-DERA-005', 'Teklu', 'Berhane', 'Gebru', 'Teklu', 'Berhane', 'Gebru', 'M', '1', '6', '1980', 'KA-DERA', 'KA-DERA-03'),
    ('KA-DERA-006', 'Kidane', 'Tesfaye', 'Mezgebe', 'Kidane', 'Tesfaye', 'Mezgebe', 'F', '18', '2', '1994', 'KA-DERA', 'KA-DERA-03'),

    -- Endahwukro Tabia (KA-ENDAHWUKRO) - 6 individuals
    ('KA-ENDRA-001', 'Aregay', 'Mezgebe', 'Tekle', 'Aregay', 'Mezgebe', 'Tekle', 'M', '12', '9', '1983', 'KA-ENDAHWUKRO', 'KA-ENDRA-01'),
    ('KA-ENDRA-002', 'Hanna', 'Weldu', 'Haile', 'Hanna', 'Weldu', 'Haile', 'F', '29', '5', '1990', 'KA-ENDAHWUKRO', 'KA-ENDRA-01'),
    ('KA-ENDRA-003', 'Gebremedhin', 'Hagos', 'Gebrehiwot', 'Gebremedhin', 'Hagos', 'Gebrehiwot', 'M', '5', '1', '1978', 'KA-ENDAHWUKRO', 'KA-ENDRA-02'),
    ('KA-ENDRA-004', 'Mebrat', 'Kiros', 'Tesfay', 'Mebrat', 'Kiros', 'Tesfay', 'F', '22', '10', '1987', 'KA-ENDAHWUKRO', 'KA-ENDRA-02'),
    ('KA-ENDRA-005', 'Weldu', 'Gebru', 'Abraha', 'Weldu', 'Gebru', 'Abraha', 'M', '16', '4', '1985', 'KA-ENDAHWUKRO', 'KA-ENDRA-03'),
    ('KA-ENDRA-006', 'Freweyni', 'Tesfaye', 'Berhe', 'Freweyni', 'Tesfaye', 'Berhe', 'F', '3', '8', '1993', 'KA-ENDAHWUKRO', 'KA-ENDRA-03'),

    -- Genfel Tabia (KA-GENFEL) - 4 individuals
    ('KA-GENFEL-001', 'Mezgebe', 'Teklay', 'Tekeste', 'Mezgebe', 'Teklay', 'Tekeste', 'M', '10', '2', '1981', 'KA-GENFEL', 'KA-GENFEL-01'),
    ('KA-GENFEL-002', 'Rahel', 'Aregay', 'Gebre', 'Rahel', 'Aregay', 'Gebre', 'F', '25', '6', '1989', 'KA-GENFEL', 'KA-GENFEL-01'),
    ('KA-GENFEL-003', 'Gebreyesus', 'Haile', 'Weldu', 'Gebreyesus', 'Haile', 'Weldu', 'M', '7', '11', '1976', 'KA-GENFEL', 'KA-GENFEL-02'),
    ('KA-GENFEL-004', 'Tsige', 'Mehari', 'Kiros', 'Tsige', 'Mehari', 'Kiros', 'F', '19', '3', '1995', 'KA-GENFEL', 'KA-GENFEL-03'),

    -- Hareza Tabia (KA-HAREZA) - 4 individuals
    ('KA-HAREZA-001', 'Tesfaye', 'Gebru', 'Hagos', 'Tesfaye', 'Gebru', 'Hagos', 'M', '14', '7', '1984', 'KA-HAREZA', 'KA-HAREZA-01'),
    ('KA-HAREZA-002', 'Wubalem', 'Tekle', 'Tesfay', 'Wubalem', 'Tekle', 'Tesfay', 'F', '21', '12', '1991', 'KA-HAREZA', 'KA-HAREZA-02'),
    ('KA-HAREZA-003', 'Gebreselassie', 'Kiros', 'Berhane', 'Gebreselassie', 'Kiros', 'Berhane', 'M', '30', '5', '1979', 'KA-HAREZA', 'KA-HAREZA-03'),
    ('KA-HAREZA-004', 'Tigist', 'Abraha', 'Mezgebe', 'Tigist', 'Abraha', 'Mezgebe', 'F', '4', '9', '1996', 'KA-HAREZA', 'KA-HAREZA-04'),

    -- Shibdih Tabia (KA-SHIBDIH) - 4 individuals
    ('KA-SHIBDIH-001', 'Berhe', 'Weldu', 'Tekeste', 'Berhe', 'Weldu', 'Tekeste', 'M', '11', '1', '1982', 'KA-SHIBDIH', 'KA-SHIBDIH-01'),
    ('KA-SHIBDIH-002', 'Abeba', 'Gebremedhin', 'Hagos', 'Abeba', 'Gebremedhin', 'Hagos', 'F', '26', '6', '1990', 'KA-SHIBDIH', 'KA-SHIBDIH-02'),
    ('KA-SHIBDIH-003', 'Mehari', 'Haile', 'Aregay', 'Mehari', 'Haile', 'Aregay', 'M', '2', '10', '1977', 'KA-SHIBDIH', 'KA-SHIBDIH-03'),
    ('KA-SHIBDIH-004', 'Desta', 'Kiros', 'Gebru', 'Desta', 'Kiros', 'Gebru', 'F', '17', '4', '1994', 'KA-SHIBDIH', 'KA-SHIBDIH-02'),

    -- Tsaeda Tabia (KA-TSAEDA) - No individuals yet (reserved for testing)

    -- Zaba Tabia (KA-ZABA) - No individuals yet (reserved for testing)

    -- Add some individuals with partial names for fuzzy matching tests
    ('KA-WUKRO-011', 'Tesfay', 'G', 'Haile', 'Tesfay', 'G', 'Haile', 'M', '15', '3', '1985', 'KA-WUKRO', 'KA-WUKRO-01'), -- Similar to KA-AGBE-001
    ('KA-AGBE-011', 'Tesfy', 'Gebrehiot', 'Haile', 'Tesfy', 'Gebrehiot', 'Haile', 'M', '15', '3', '1985', 'KA-AGBE', 'KA-AGBE-01'); -- Typo variant of KA-AGBE-001

-- Verify data insertion
SELECT
    village,
    COUNT(*) as individual_count,
    COUNT(DISTINCT subvillage) as kushet_count,
    COUNT(CASE WHEN gender = 'M' THEN 1 END) as males,
    COUNT(CASE WHEN gender = 'F' THEN 1 END) as females
FROM public.dss_individuals
GROUP BY village
ORDER BY village;
