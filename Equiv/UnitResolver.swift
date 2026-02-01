//
//  UnitResolver.swift
//  Equiv
//
//  Created by Callum Black on 31/01/2026.
//

import Foundation

struct ResolvedUnit {
    let category: UnitCategoryType
    let index: Int
    let symbol: String
}

struct UnitResolver {
    private static let aliases: [(pattern: String, category: UnitCategoryType, index: Int)] = [
        // Length
        ("meters", .length, 0), ("metres", .length, 0), ("m", .length, 0), ("meter", .length, 0), ("metre", .length, 0),
        ("kilometers", .length, 1), ("kilometres", .length, 1), ("km", .length, 1),
        ("centimeters", .length, 2), ("centimetres", .length, 2), ("cm", .length, 2),
        ("millimeters", .length, 3), ("millimetres", .length, 3), ("mm", .length, 3),
        ("miles", .length, 4), ("mi", .length, 4), ("mile", .length, 4),
        ("yards", .length, 5), ("yd", .length, 5), ("yard", .length, 5),
        ("feet", .length, 6), ("foot", .length, 6), ("ft", .length, 6),
        ("inches", .length, 7), ("inch", .length, 7), ("in", .length, 7),
        ("nautical miles", .length, 8), ("nmi", .length, 8),
        ("micrometers", .length, 9), ("micrometres", .length, 9), ("µm", .length, 9), ("um", .length, 9),

        // Mass
        ("kilograms", .mass, 0), ("kg", .mass, 0), ("kilo", .mass, 0), ("kilos", .mass, 0),
        ("grams", .mass, 1), ("g", .mass, 1), ("gram", .mass, 1),
        ("milligrams", .mass, 2), ("mg", .mass, 2),
        ("pounds", .mass, 3), ("lbs", .mass, 3), ("lb", .mass, 3), ("pound", .mass, 3),
        ("ounces", .mass, 4), ("oz", .mass, 4), ("ounce", .mass, 4),
        ("stones", .mass, 5), ("stone", .mass, 5), ("st", .mass, 5),
        ("metric tons", .mass, 6), ("tonnes", .mass, 6), ("metric ton", .mass, 6), ("tonne", .mass, 6),
        ("short tons", .mass, 7), ("tons", .mass, 7), ("ton", .mass, 7),

        // Temperature
        ("celsius", .temperature, 0), ("c", .temperature, 0), ("centigrade", .temperature, 0),
        ("fahrenheit", .temperature, 1), ("f", .temperature, 1),
        ("kelvin", .temperature, 2), ("k", .temperature, 2),

        // Volume
        ("liters", .volume, 0), ("litres", .volume, 0), ("l", .volume, 0), ("liter", .volume, 0), ("litre", .volume, 0),
        ("milliliters", .volume, 1), ("millilitres", .volume, 1), ("ml", .volume, 1),
        ("gallons", .volume, 2), ("gal", .volume, 2), ("gallon", .volume, 2),
        ("quarts", .volume, 3), ("qt", .volume, 3), ("quart", .volume, 3),
        ("pints", .volume, 4), ("pt", .volume, 4), ("pint", .volume, 4),
        ("cups", .volume, 5), ("cup", .volume, 5),
        ("fluid ounces", .volume, 6), ("fl oz", .volume, 6),
        ("tablespoons", .volume, 7), ("tbsp", .volume, 7), ("tablespoon", .volume, 7),
        ("teaspoons", .volume, 8), ("tsp", .volume, 8), ("teaspoon", .volume, 8),
        ("cubic meters", .volume, 9), ("cubic metres", .volume, 9), ("m3", .volume, 9),

        // Area
        ("square meters", .area, 0), ("sq m", .area, 0), ("m2", .area, 0),
        ("square kilometers", .area, 1), ("sq km", .area, 1), ("km2", .area, 1),
        ("square feet", .area, 2), ("sq ft", .area, 2), ("ft2", .area, 2),
        ("square yards", .area, 3), ("sq yd", .area, 3), ("yd2", .area, 3),
        ("square miles", .area, 4), ("sq mi", .area, 4), ("mi2", .area, 4),
        ("acres", .area, 5), ("acre", .area, 5),
        ("hectares", .area, 6), ("ha", .area, 6), ("hectare", .area, 6),
        ("square inches", .area, 7), ("sq in", .area, 7), ("in2", .area, 7),
        ("square centimeters", .area, 8), ("sq cm", .area, 8), ("cm2", .area, 8),

        // Speed
        ("meters per second", .speed, 0), ("m/s", .speed, 0),
        ("kilometers per hour", .speed, 1), ("km/h", .speed, 1), ("kph", .speed, 1),
        ("miles per hour", .speed, 2), ("mph", .speed, 2),
        ("knots", .speed, 3), ("kn", .speed, 3), ("knot", .speed, 3),

        // Time
        ("seconds", .time, 0), ("sec", .time, 0), ("s", .time, 0), ("second", .time, 0),
        ("minutes", .time, 1), ("min", .time, 1), ("minute", .time, 1),
        ("hours", .time, 2), ("hr", .time, 2), ("h", .time, 2), ("hour", .time, 2),

        // Digital Storage
        ("bytes", .digitalStorage, 0), ("byte", .digitalStorage, 0),
        ("kilobytes", .digitalStorage, 1), ("kb", .digitalStorage, 1),
        ("megabytes", .digitalStorage, 2), ("mb", .digitalStorage, 2),
        ("gigabytes", .digitalStorage, 3), ("gb", .digitalStorage, 3),
        ("terabytes", .digitalStorage, 4), ("tb", .digitalStorage, 4),
        ("petabytes", .digitalStorage, 5), ("pb", .digitalStorage, 5),
        ("kibibytes", .digitalStorage, 6), ("kib", .digitalStorage, 6),
        ("mebibytes", .digitalStorage, 7), ("mib", .digitalStorage, 7),
        ("gibibytes", .digitalStorage, 8), ("gib", .digitalStorage, 8),
        ("tebibytes", .digitalStorage, 9), ("tib", .digitalStorage, 9),

        // Energy
        ("joules", .energy, 0), ("j", .energy, 0), ("joule", .energy, 0),
        ("kilojoules", .energy, 1), ("kj", .energy, 1),
        ("calories", .energy, 2), ("cal", .energy, 2), ("calorie", .energy, 2),
        ("kilocalories", .energy, 3), ("kcal", .energy, 3),
        ("kilowatt hours", .energy, 4), ("kwh", .energy, 4),

        // Pressure
        ("pascals", .pressure, 0), ("pa", .pressure, 0), ("pascal", .pressure, 0),
        ("kilopascals", .pressure, 1), ("kpa", .pressure, 1),
        ("hectopascals", .pressure, 2), ("hpa", .pressure, 2),
        ("bars", .pressure, 3), ("bar", .pressure, 3),
        ("millibars", .pressure, 4), ("mbar", .pressure, 4),
        ("psi", .pressure, 5), ("pounds per square inch", .pressure, 5),
        ("mmhg", .pressure, 6), ("millimeters of mercury", .pressure, 6),
        ("inhg", .pressure, 7), ("inches of mercury", .pressure, 7),

        // Angle
        ("degrees", .angle, 0), ("deg", .angle, 0), ("degree", .angle, 0),
        ("radians", .angle, 1), ("rad", .angle, 1), ("radian", .angle, 1),
        ("revolutions", .angle, 2), ("rev", .angle, 2), ("revolution", .angle, 2),
        ("arcminutes", .angle, 3), ("arc minutes", .angle, 3),
        ("arcseconds", .angle, 4), ("arc seconds", .angle, 4),
        ("gradians", .angle, 5), ("gradian", .angle, 5), ("gon", .angle, 5),

        // Frequency
        ("hertz", .frequency, 0), ("hz", .frequency, 0),
        ("kilohertz", .frequency, 1), ("khz", .frequency, 1),
        ("megahertz", .frequency, 2), ("mhz", .frequency, 2),
        ("gigahertz", .frequency, 3), ("ghz", .frequency, 3),
        ("terahertz", .frequency, 4), ("thz", .frequency, 4),

        // Fuel Economy
        ("liters per 100 kilometers", .fuelEconomy, 0), ("l/100km", .fuelEconomy, 0),
        ("miles per gallon", .fuelEconomy, 1), ("mpg", .fuelEconomy, 1),
        ("miles per imperial gallon", .fuelEconomy, 2), ("mpg imp", .fuelEconomy, 2),

        // Power
        ("watts", .power, 0), ("w", .power, 0), ("watt", .power, 0),
        ("kilowatts", .power, 1), ("kw", .power, 1),
        ("megawatts", .power, 2), ("mw", .power, 2),
        ("horsepower", .power, 3), ("hp", .power, 3),
        ("milliwatts", .power, 4),

        // Force (custom)
        ("newtons", .force, 0), ("newton", .force, 0), ("n", .force, 0),
        ("kilonewtons", .force, 1), ("kn", .force, 1),
        ("pound-force", .force, 2), ("lbf", .force, 2),
        ("dynes", .force, 3), ("dyn", .force, 3), ("dyne", .force, 3),
        ("kilogram-force", .force, 4), ("kgf", .force, 4),

        // Data Transfer Rate (custom)
        ("bits per second", .dataTransferRate, 0), ("bps", .dataTransferRate, 0),
        ("kilobits per second", .dataTransferRate, 1), ("kbps", .dataTransferRate, 1),
        ("megabits per second", .dataTransferRate, 2), ("mbps", .dataTransferRate, 2),
        ("gigabits per second", .dataTransferRate, 3), ("gbps", .dataTransferRate, 3),
        ("bytes per second", .dataTransferRate, 4), ("b/s", .dataTransferRate, 4),
        ("kilobytes per second", .dataTransferRate, 5), ("kb/s", .dataTransferRate, 5),
        ("megabytes per second", .dataTransferRate, 6), ("mb/s", .dataTransferRate, 6),

        // Torque (custom)
        ("newton-metres", .torque, 0), ("newton-meters", .torque, 0), ("nm", .torque, 0), ("n·m", .torque, 0),
        ("foot-pounds", .torque, 1), ("ft·lbf", .torque, 1), ("ft-lbf", .torque, 1),
        ("inch-pounds", .torque, 2), ("in·lbf", .torque, 2), ("in-lbf", .torque, 2),
        ("kilogram-force metres", .torque, 3), ("kgf·m", .torque, 3), ("kgf-m", .torque, 3),

        // Density (custom)
        ("kilograms per cubic metre", .density, 0), ("kg/m3", .density, 0), ("kg/m³", .density, 0),
        ("grams per cubic centimetre", .density, 1), ("g/cm3", .density, 1), ("g/cm³", .density, 1),
        ("pounds per cubic foot", .density, 2), ("lb/ft3", .density, 2), ("lb/ft³", .density, 2),
        ("pounds per cubic inch", .density, 3), ("lb/in3", .density, 3), ("lb/in³", .density, 3),
        ("grams per litre", .density, 4), ("grams per liter", .density, 4), ("g/l", .density, 4),

        // Illuminance (custom)
        ("lux", .illuminance, 0), ("lx", .illuminance, 0),
        ("foot-candles", .illuminance, 1), ("fc", .illuminance, 1), ("foot-candle", .illuminance, 1),
        ("phot", .illuminance, 2), ("ph", .illuminance, 2),
        ("nox", .illuminance, 3), ("nx", .illuminance, 3),
    ]

    static func resolve(_ input: String) -> ResolvedUnit? {
        let normalized = input.lowercased().trimmingCharacters(in: .whitespaces)

        // Exact match first, preferring longer patterns
        let sorted = aliases.sorted { $0.pattern.count > $1.pattern.count }
        for alias in sorted {
            if normalized == alias.pattern {
                let vm = ConverterViewModel(category: alias.category)
                return ResolvedUnit(
                    category: alias.category,
                    index: alias.index,
                    symbol: vm.unitSymbol(at: alias.index)
                )
            }
        }
        return nil
    }
}
