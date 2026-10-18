/// Mock spending figures for Home's statistics card until the API lands.
library;

/// What the main account spent each day this week, Monday first.
const weekSpending = [8200, 12500, 6400, 9800, 21300, 11200, 15400];

/// Last week's total, to compare this week against.
const lastWeekTotal = 96400;

/// This week's spending by kind: label and amount.
const weekCategories = [('Хоол', 46200), ('Тээвэр', 21800), ('Тоглоом', 16800)];

/// Short Mongolian day names, Monday first.
const weekdayLabels = ['Да', 'Мя', 'Лх', 'Пү', 'Ба', 'Бя', 'Ня'];
