# Ethiopian HDSS UI Components
## Phase 1 Week 3-4 Deliverables

This directory contains three custom Blazor components designed specifically for the Ethiopian Health and Demographic Surveillance System (HDSS) context in Kilte Awlalo Woreda, Tigray Region.

---

## Components Overview

### 1. **EthiopianDatePicker.razor** ✅
Dual-calendar date picker supporting both Ethiopian (Ge'ez) and Gregorian calendars.

### 2. **LocationPicker.razor** ✅
Hierarchical location selector for Kilte Awlalo: Woreda → Tabia → Kushet → Gott.

### 3. **LanguageSwitcher.razor** ✅
Multi-language switcher: Tigrinya (ትግርኛ), Amharic (አማርኛ), English.

---

## 1. Ethiopian Date Picker

### Features
- ✅ Dual calendar support (Ethiopian ↔ Gregorian)
- ✅ 13 Ethiopian months with Tigrinya/Amharic names
- ✅ Automatic year conversion (EC ↔ AD)
- ✅ Age-only mode (for those who don't know exact birth date)
- ✅ Responsive design (mobile-friendly)
- ✅ Localized labels

### Usage

```razor
@page "/example"

<EthiopianDatePicker
    @bind-Day="birthDay"
    @bind-Month="birthMonth"
    @bind-Year="birthYear"
    CalendarType="@calendarType"
    Language="@currentLanguage"
    AgeOnly="@ageOnlyMode" />

@code {
    private string? birthDay;
    private string? birthMonth;
    private string? birthYear;
    private string calendarType = "Ethiopian"; // or "Gregorian"
    private string currentLanguage = "ti"; // ti, am, or en
    private bool ageOnlyMode = false;
}
```

### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `Day` | `string?` | `null` | Birth day (1-30) |
| `Month` | `string?` | `null` | Birth month (1-13 for Ethiopian, 1-12 for Gregorian) |
| `Year` | `string?` | `null` | Birth year |
| `CalendarType` | `string` | `"Ethiopian"` | Calendar system: "Ethiopian" or "Gregorian" |
| `Language` | `string` | `"ti"` | Language: "ti" (Tigrinya), "am" (Amharic), "en" (English) |
| `AgeOnly` | `bool` | `false` | If true, only year is required (day/month cleared) |

### Ethiopian Months (Tigrinya)

1. መስከረም (Meskerem) - Sept 11 to Oct 10
2. ጥቅምቲ (Tikimt) - Oct 11 to Nov 9
3. ሕዳር (Hidar) - Nov 10 to Dec 9
4. ታሕሳስ (Tahsas) - Dec 10 to Jan 8
5. ጥሪ (Tir) - Jan 9 to Feb 7
6. የካቲት (Yekatit) - Feb 8 to Mar 9
7. መጋቢት (Megabit) - Mar 10 to Apr 8
8. ሚያዝያ (Miazia) - Apr 9 to May 8
9. ግንቦት (Ginbot) - May 9 to Jun 7
10. ሰነ (Sene) - Jun 8 to Jul 7
11. ሐምለ (Hamle) - Jul 8 to Aug 6
12. ነሐሴ (Nehase) - Aug 7 to Sep 5
13. ጳጉሜ (Pagume) - Sep 6 to Sep 10/11 (5-6 days)

### Year Conversion

- **Ethiopian → Gregorian:** Add 7-8 years
  - Example: 2017 EC ≈ 2024-2025 AD
  - Exact conversion depends on month (Sept-Dec: +7, Jan-Aug: +8)
- **Current:** Component shows approximate Gregorian year below input

---

## 2. Location Picker

### Features
- ✅ Hierarchical cascading selection (Tabia → Kushet)
- ✅ All 10 Kilte Awlalo Tabias pre-loaded
- ✅ All 33 Kushets mapped to Tabias
- ✅ Trilingual names (Tigrinya, Amharic, English)
- ✅ Population estimates shown
- ✅ Gott/sub-village free text input
- ✅ Automatic filtering (Kushets filtered by selected Tabia)

### Usage

```razor
@page "/example"

<LocationPicker
    @bind-TabiaCode="selectedTabia"
    @bind-KushetCode="selectedKushet"
    @bind-Gott="gottName"
    Language="@currentLanguage" />

@code {
    private string? selectedTabia;
    private string? selectedKushet;
    private string? gottName;
    private string currentLanguage = "ti";
}
```

### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `TabiaCode` | `string?` | `null` | Selected Tabia code (e.g., "KA-AGBE") |
| `KushetCode` | `string?` | `null` | Selected Kushet code (e.g., "KA-AGBE-01") |
| `Gott` | `string?` | `null` | Gott/sub-village name (free text) |
| `Language` | `string` | `"ti"` | Language: "ti", "am", or "en" |

### 10 Kilte Awlalo Tabias

1. **Agbe** (ኣግበ) - 7,200 pop - 4 Kushets
2. **Wukro Town** (ውቕሮ) - 12,500 pop - 5 Kebeles
3. **Chele** (ጨሌ) - 6,800 pop - 3 Kushets
4. **Dera** (ዴራ) - 5,900 pop - 3 Kushets
5. **Endahwukro** (እንዳሁውቕሮ) - 6,400 pop - 3 Kushets
6. **Genfel** (ገንፈል) - 5,500 pop - 3 Kushets
7. **Hareza** (ሓረዛ) - 7,100 pop - 4 Kushets
8. **Shibdih** (ሽብዲህ) - 6,200 pop - 3 Kushets
9. **Tsaeda Emba** (ጻዕዳ) - 5,400 pop - 3 Kushets
10. **Zaba Guna** (ዛባ) - 4,000 pop - 2 Kushets

**Total:** ~67,000 population, 33 Kushets

### Example: Agbe Tabia Kushets

- KA-AGBE-01: Agbe (2,400)
- KA-AGBE-02: Genfel (2,100)
- KA-AGBE-03: May Chew (1,500)
- KA-AGBE-04: Adi Kuwala (1,200)

---

## 3. Language Switcher

### Features
- ✅ 3 languages: Tigrinya (ትግርኛ), Amharic (አማርኛ), English
- ✅ Ethiopian flag (🇪🇹) for Tigrinya/Amharic
- ✅ Persistent preference (saved to localStorage)
- ✅ Dropdown with Ethiopic script labels
- ✅ Mobile-responsive (flag only on small screens)
- ✅ Event notification for language changes

### Usage

```razor
@page "/example"

<LanguageSwitcher
    @bind-CurrentLanguage="currentLanguage"
    OnLanguageChange="HandleLanguageChange" />

<p>Current language: @currentLanguage</p>

@code {
    private string currentLanguage = "ti"; // Default: Tigrinya

    private async Task HandleLanguageChange(string newLanguage)
    {
        // React to language change
        Console.WriteLine($"Language changed to: {newLanguage}");

        // Update all components, reload resources, etc.
        await InvokeAsync(StateHasChanged);
    }
}
```

### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `CurrentLanguage` | `string` | `"ti"` | Current language code: "ti", "am", or "en" |
| `OnLanguageChange` | `EventCallback<string>` | - | Event fired when language changes |

### Language Codes

| Code | Language | Display Name | Script |
|------|----------|--------------|--------|
| `ti` | Tigrinya | ትግርኛ | Ge'ez |
| `am` | Amharic | አማርኛ | Ge'ez |
| `en` | English | English | Latin |

### localStorage Key

- **Key:** `hdss_language`
- **Values:** `"ti"`, `"am"`, or `"en"`
- **Purpose:** Persist user's language preference across sessions

---

## Integration Example

### Complete Search Form with All Components

```razor
@page "/match"
@using PremiumMatcher.Web.Components

<div class="container mt-4">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h3>Record Matching</h3>
        <LanguageSwitcher @bind-CurrentLanguage="currentLanguage" OnLanguageChange="OnLanguageChanged" />
    </div>

    <div class="card mb-3">
        <div class="card-header">
            <h5>@GetLabel("SearchCriteria")</h5>
        </div>
        <div class="card-body">
            @* Name Fields *@
            <div class="row g-3 mb-3">
                <div class="col-md-4">
                    <label class="form-label">@GetLabel("GivenName")</label>
                    <input type="text" class="form-control" @bind="givenName" />
                </div>
                <div class="col-md-4">
                    <label class="form-label">@GetLabel("FatherName")</label>
                    <input type="text" class="form-control" @bind="fatherName" />
                </div>
                <div class="col-md-4">
                    <label class="form-label">@GetLabel("GrandfatherName")</label>
                    <input type="text" class="form-control" @bind="grandfatherName" />
                </div>
            </div>

            @* Date Picker Component *@
            <div class="mb-3">
                <EthiopianDatePicker
                    @bind-Day="birthDay"
                    @bind-Month="birthMonth"
                    @bind-Year="birthYear"
                    CalendarType="@calendarType"
                    Language="@currentLanguage" />
            </div>

            @* Location Picker Component *@
            <div class="mb-3">
                <LocationPicker
                    @bind-TabiaCode="tabiaCode"
                    @bind-KushetCode="kushetCode"
                    @bind-Gott="gott"
                    Language="@currentLanguage" />
            </div>

            @* Search Button *@
            <button class="btn btn-primary" @onclick="Search">
                @GetLabel("Search")
            </button>
        </div>
    </div>
</div>

@code {
    private string currentLanguage = "ti";
    private string? givenName, fatherName, grandfatherName;
    private string? birthDay, birthMonth, birthYear;
    private string calendarType = "Ethiopian";
    private string? tabiaCode, kushetCode, gott;

    private async Task OnLanguageChanged(string newLang)
    {
        currentLanguage = newLang;
        // Reload localized strings, update UI
        await InvokeAsync(StateHasChanged);
    }

    private async Task Search()
    {
        // Perform search with all criteria
        Console.WriteLine($"Searching: {givenName} {fatherName} (Tabia: {tabiaCode}, Year: {birthYear})");
    }

    private string GetLabel(string key)
    {
        // Load from resource files based on currentLanguage
        return key; // Placeholder
    }
}
```

---

## Styling Notes

### Ethiopic Font Support

Ensure Ethiopic fonts are loaded in your `wwwroot/index.html` or `_Host.cshtml`:

```html
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Noto+Sans+Ethiopic:wght@400;500;700&display=swap" rel="stylesheet">
```

### CSS Classes

All components use Bootstrap 5 classes and custom styles:
- `.ethiopian-date-picker` - Date picker container
- `.location-picker` - Location picker container
- `.language-switcher` - Language switcher container
- `.ethiopic-text` - For Ge'ez script text

---

## Mobile Responsiveness

All components are optimized for mobile/tablet use:
- **Ethiopian Date Picker:** Stacked layout on small screens
- **Location Picker:** Full-width dropdowns on mobile
- **Language Switcher:** Shows flag only on mobile (name hidden)

### Minimum Screen Size
- Phone: 320px width
- Tablet: 768px width (optimal)
- Desktop: 1024px+ width

---

## Testing Checklist

### Ethiopian Date Picker
- [ ] Toggle between Ethiopian and Gregorian calendars
- [ ] Select each of 13 Ethiopian months (Tigrinya names)
- [ ] Verify year conversion (2017 EC → 2024/2025 AD)
- [ ] Enable "Age only" mode (day/month cleared)
- [ ] Test with Tigrinya, Amharic, English
- [ ] Verify on mobile (touch-friendly)

### Location Picker
- [ ] Select each of 10 Tabias
- [ ] Verify Kushets filter correctly by Tabia
- [ ] Check population estimates display
- [ ] Test trilingual names (Tigrinya/Amharic/English)
- [ ] Enter free text in Gott field
- [ ] Verify cascading selection (Tabia change clears Kushet)

### Language Switcher
- [ ] Switch between Tigrinya, Amharic, English
- [ ] Verify localStorage saves preference
- [ ] Reload page - language persists
- [ ] Check Ethiopic script displays correctly
- [ ] Test on mobile (dropdown works)
- [ ] Verify event fires to parent components

---

## Browser Compatibility

| Browser | Version | Status |
|---------|---------|--------|
| Chrome | 90+ | ✅ Fully supported |
| Firefox | 88+ | ✅ Fully supported |
| Safari | 14+ | ✅ Fully supported |
| Edge | 90+ | ✅ Fully supported |
| Opera | 76+ | ✅ Fully supported |

**Note:** Requires JavaScript enabled for full functionality (especially localStorage in LanguageSwitcher).

---

## Future Enhancements

### Ethiopian Date Picker
- [ ] Date validation (e.g., Pagume max 6 days in leap year)
- [ ] Calendar widget (visual month/day picker)
- [ ] Full Ethiopian Calendar conversion service integration
- [ ] Historical date support (Julian calendar before 1582)

### Location Picker
- [ ] Load location data from API (not hardcoded)
- [ ] GPS coordinate input option
- [ ] Map integration (show selected location)
- [ ] Search/autocomplete for location names
- [ ] Support for other HDSS sites (Butajira, Arba Minch, etc.)

### Language Switcher
- [ ] Add Oromo (for other Ethiopian regions)
- [ ] Right-to-Left (RTL) support for future Arabic
- [ ] Language-specific number formatting (Ethiopian numerals)
- [ ] Voice input in local languages

---

## Dependencies

- **Blazor WebAssembly** or **Blazor Server** (.NET 6+)
- **Bootstrap 5.3+** (for styling and dropdowns)
- **JavaScript Runtime** (for localStorage in LanguageSwitcher)
- **Ethiopic fonts** (Noto Sans Ethiopic, Abyssinica SIL)

---

## Support & Feedback

**Questions or issues?**
1. Check `VERIFICATION_GUIDE.md` for troubleshooting
2. Review `PHASE1_PROGRESS.md` for implementation status
3. See `ETHIOPIAN_IMPLEMENTATION_PLAN.md` for roadmap

**Found a bug?**
- Report in project issue tracker
- Include browser, language, and steps to reproduce

---

## License

Part of PIRL Record Linkage Software adapted for Ethiopian HDSS.
See main repository LICENSE file.

---

**Last Updated:** December 2024
**Phase:** 1 (MVP Development)
**Sprint:** Week 3-4
**Status:** Components complete ✅ | Integration pending ⏳
