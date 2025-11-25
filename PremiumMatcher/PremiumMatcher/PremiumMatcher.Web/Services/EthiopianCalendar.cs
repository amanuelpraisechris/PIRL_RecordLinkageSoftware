using System;

namespace PremiumMatcher.Web.Services;

/// <summary>
/// Ethiopian Calendar (Ge'ez Calendar) conversion utilities
/// Ethiopia uses a calendar that is approximately 7-8 years behind the Gregorian calendar
/// The Ethiopian year has 13 months: 12 months of 30 days + 1 month of 5-6 days (Pagume)
/// </summary>
public static class EthiopianCalendar
{
    // Ethiopian month names in Amharic
    public static readonly string[] MonthNamesAmharic = new[]
    {
        "መስከረም", // Meskerem (Sept 11 - Oct 10)
        "ጥቅምት",   // Tikimt (Oct 11 - Nov 9)
        "ኅዳር",    // Hidar (Nov 10 - Dec 9)
        "ታኅሣሥ",   // Tahsas (Dec 10 - Jan 8)
        "ጥር",     // Tir (Jan 9 - Feb 7)
        "የካቲት",   // Yekatit (Feb 8 - Mar 9)
        "መጋቢት",   // Megabit (Mar 10 - Apr 8)
        "ሚያዝያ",   // Miazia (Apr 9 - May 8)
        "ግንቦት",   // Ginbot (May 9 - June 7)
        "ሰኔ",     // Sene (June 8 - July 7)
        "ሐምሌ",    // Hamle (July 8 - Aug 6)
        "ነሐሴ",    // Nehasse (Aug 7 - Sept 5/6)
        "ጳጉሜን"    // Pagume (Sept 6-10/11) - 5 or 6 days
    };

    // English transliterations
    public static readonly string[] MonthNamesEnglish = new[]
    {
        "Meskerem", "Tikimt", "Hidar", "Tahsas", "Tir", "Yekatit",
        "Megabit", "Miazia", "Ginbot", "Sene", "Hamle", "Nehasse", "Pagume"
    };

    private const int JD_EPOCH_OFFSET_GREGORIAN = 1721426;
    private const int JD_EPOCH_OFFSET_ETHIOPIAN = 1724221;

    /// <summary>
    /// Check if Ethiopian year is a leap year
    /// Ethiopian leap year occurs every 4 years (like Gregorian)
    /// </summary>
    public static bool IsEthiopianLeapYear(int ethiopianYear)
    {
        return (ethiopianYear % 4) == 3;
    }

    /// <summary>
    /// Get number of days in a month for Ethiopian calendar
    /// </summary>
    public static int DaysInMonth(int month, int year)
    {
        if (month < 1 || month > 13)
            throw new ArgumentException("Ethiopian month must be between 1 and 13", nameof(month));

        if (month <= 12)
            return 30; // First 12 months always have 30 days

        // Pagume (13th month)
        return IsEthiopianLeapYear(year) ? 6 : 5;
    }

    /// <summary>
    /// Convert Ethiopian date to Gregorian date
    /// </summary>
    public static DateTime ToGregorian(int ethiopianYear, int ethiopianMonth, int ethiopianDay)
    {
        if (ethiopianMonth < 1 || ethiopianMonth > 13)
            throw new ArgumentException("Ethiopian month must be between 1 and 13", nameof(ethiopianMonth));

        if (ethiopianDay < 1 || ethiopianDay > DaysInMonth(ethiopianMonth, ethiopianYear))
            throw new ArgumentException($"Invalid day {ethiopianDay} for month {ethiopianMonth}", nameof(ethiopianDay));

        // Calculate Julian Day Number for Ethiopian date
        int jdn = JD_EPOCH_OFFSET_ETHIOPIAN +
                  (365 * ethiopianYear) +
                  (ethiopianYear / 4) +
                  (30 * (ethiopianMonth - 1)) +
                  ethiopianDay;

        // Convert Julian Day Number to Gregorian date
        return JulianDayToGregorian(jdn);
    }

    /// <summary>
    /// Convert Gregorian date to Ethiopian date
    /// </summary>
    public static (int year, int month, int day) ToEthiopian(DateTime gregorianDate)
    {
        // Convert Gregorian to Julian Day Number
        int jdn = GregorianToJulianDay(gregorianDate);

        // Convert JDN to Ethiopian
        int daysSinceEpoch = jdn - JD_EPOCH_OFFSET_ETHIOPIAN;

        int year = (4 * daysSinceEpoch + 1463) / 1461;
        int daysInYear = daysSinceEpoch - (365 * year + year / 4);

        int month = (daysInYear / 30) + 1;
        int day = (daysInYear % 30) + 1;

        // Handle edge case for 13th month
        if (month > 13)
        {
            year++;
            month = 1;
        }

        return (year, month, day);
    }

    /// <summary>
    /// Format Ethiopian date as string
    /// </summary>
    public static string FormatEthiopian(int year, int month, int day, bool useAmharic = true)
    {
        var monthName = useAmharic ? MonthNamesAmharic[month - 1] : MonthNamesEnglish[month - 1];
        return $"{day} {monthName} {year}";
    }

    /// <summary>
    /// Get current Ethiopian date
    /// </summary>
    public static (int year, int month, int day) Today()
    {
        return ToEthiopian(DateTime.Today);
    }

    /// <summary>
    /// Convert year only (approximate)
    /// Ethiopian year is approximately 7-8 years behind Gregorian
    /// </summary>
    public static int EthiopianToGregorianYear(int ethiopianYear)
    {
        // Simple approximation: Ethiopian year + 7 or 8
        // More accurate would depend on the month
        // Ethiopian New Year (Enkutatash) is Sept 11 (or Sept 12 in leap years)
        return ethiopianYear + 7; // Conservative estimate
    }

    /// <summary>
    /// Convert year only (approximate)
    /// </summary>
    public static int GregorianToEthiopianYear(int gregorianYear)
    {
        return gregorianYear - 7; // Conservative estimate
    }

    // Helper methods for Julian Day Number conversions
    private static int GregorianToJulianDay(DateTime date)
    {
        int a = (14 - date.Month) / 12;
        int y = date.Year + 4800 - a;
        int m = date.Month + 12 * a - 3;

        return date.Day +
               (153 * m + 2) / 5 +
               365 * y +
               y / 4 -
               y / 100 +
               y / 400 -
               32045;
    }

    private static DateTime JulianDayToGregorian(int jdn)
    {
        int a = jdn + 32044;
        int b = (4 * a + 3) / 146097;
        int c = a - (146097 * b) / 4;
        int d = (4 * c + 3) / 1461;
        int e = c - (1461 * d) / 4;
        int m = (5 * e + 2) / 153;

        int day = e - (153 * m + 2) / 5 + 1;
        int month = m + 3 - 12 * (m / 10);
        int year = 100 * b + d - 4800 + m / 10;

        return new DateTime(year, month, day);
    }

    /// <summary>
    /// Validate Ethiopian date
    /// </summary>
    public static bool IsValidDate(int year, int month, int day)
    {
        if (year < 1 || year > 9999)
            return false;

        if (month < 1 || month > 13)
            return false;

        if (day < 1 || day > DaysInMonth(month, year))
            return false;

        return true;
    }

    /// <summary>
    /// Parse Ethiopian date string (supports formats: "15/5/2017", "15-5-2017", etc.)
    /// </summary>
    public static bool TryParse(string dateString, out int year, out int month, out int day)
    {
        year = month = day = 0;

        if (string.IsNullOrWhiteSpace(dateString))
            return false;

        var parts = dateString.Split(new[] { '/', '-', ' ' }, StringSplitOptions.RemoveEmptyEntries);

        if (parts.Length != 3)
            return false;

        if (!int.TryParse(parts[0], out day))
            return false;

        if (!int.TryParse(parts[1], out month))
            return false;

        if (!int.TryParse(parts[2], out year))
            return false;

        return IsValidDate(year, month, day);
    }

    /// <summary>
    /// Get Ethiopian month name
    /// </summary>
    public static string GetMonthName(int month, bool useAmharic = true)
    {
        if (month < 1 || month > 13)
            throw new ArgumentException("Month must be between 1 and 13", nameof(month));

        return useAmharic ? MonthNamesAmharic[month - 1] : MonthNamesEnglish[month - 1];
    }

    /// <summary>
    /// Calculate age in years based on Ethiopian birth date
    /// </summary>
    public static int CalculateAge(int birthYear, int birthMonth, int birthDay)
    {
        var today = Today();
        int age = today.year - birthYear;

        // Adjust if birthday hasn't occurred this year
        if (today.month < birthMonth || (today.month == birthMonth && today.day < birthDay))
            age--;

        return age;
    }
}
